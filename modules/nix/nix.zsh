alias nxswitch='sudo nixos-rebuild switch --flake .'
alias nxtest='sudo nixos-rebuild test --flake .'
alias nxboot='sudo nixos-rebuild boot --flake .'
alias nxhistory='nix profile history --profile /nix/var/nix/profiles/system'
alias nxupdate='nix flake update'
alias nxdev='nix develop'

function nxgc() {
  function _nxgc_all() {
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage -d
    nix-collect-garbage -d
  }

  local older_than=${1:-7d}

  if [[ "$1" == "--all" || "$1" == "-a" ]]; then
    _nxgc_all
  else
    sudo nix profile wipe-history --older-than "$older_than" --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage -d --delete-older-than "$older_than"
    nix-collect-garbage -d --delete-older-than "$older_than"
  fi
}

function nxrun() {
  local pkg=$1
  local name
  case "$pkg" in
    github:*|.*|/*|*#*) name=$pkg ;;  # 支持 GitHub 引用、本地路径、带 # 的 flake
    *) name="nixpkgs#$pkg" ;;       # 其余映射到 nixpkgs
  esac
  nix run "$name"
}

function nxsearch() {
  local name=$1
  nix search nixpkgs "$name" --json |
  jq -r --arg name "$name" '
      to_entries[] |
      (.key | gsub("^legacyPackages\\.x86_64-linux\\."; "")) as $k |
      select($k | test($name; "i")) |
      if (.value.description != null and .value.description != "") then
        "\($k)(\(.value.version)): \(.value.description)"
      elif (.value.version != null and .value.version != "") then
        "\($k)(\(.value.version))"
      else
        "\($k)"
      end
  '
}

function nx() {
  local args=($@)
  local pkgs=()
  for pkg in "${args[@]}"; do
    case "$pkg" in
      github:*|.*|/*|*#*) pkgs+=("$pkg") ;;  # 保持原样
      *) pkgs+=("nixpkgs#$pkg") ;;             # 映射到 nixpkgs
    esac
  done
  echo "Entering shell with: ${pkgs[*]}"
  nix shell "${pkgs[@]}"
}

nxhash() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: nxhash [--both] [hash-type] <url>"
    echo "Example: nxhash sha512 https://example.com/file.tar.gz"
    echo "         nxhash --both sha256 https://example.com/file.tar.gz"
    return 1
  fi

  local both="false"
  local hash_type url raw_hash from_hint from_format help_out

  # 检查是否有 --both
  if [[ "$1" == "--both" ]]; then
    both="true"
    shift
  fi

  # 解析参数
  if [[ $# -ge 2 ]]; then
    hash_type="$1"
    url="$2"
    case "$hash_type" in
      md5|sha1|sha256|sha512) ;;
      *)
        echo "Unsupported hash type: $hash_type"
        echo "Supported: md5, sha1, sha256, sha512"
        return 1
        ;;
    esac
  else
    hash_type="sha256"
    url="$1"
  fi

  if [[ -z "$url" ]]; then
    echo "Error: URL is missing"
    echo "Usage: nxhash [--both] [hash-type] <url>"
    return 1
  fi

  # 检测 nix hash convert 支持的 base32 选项
  if help_out=$(nix hash convert --help 2>&1); then
    if echo "$help_out" | grep -q 'nix32'; then
      from_hint="nix32"
    elif echo "$help_out" | grep -q 'base32'; then
      from_hint="base32"
    else
      from_hint="nix32"
    fi
  else
    from_hint="nix32"
  fi

  # nix-prefetch-url 输出编码: md5 是 base16, 其余是 base32/nix32
  if [[ "$hash_type" == "md5" ]]; then
    from_format="base16"
  else
    from_format="$from_hint"
  fi

  # 获取原始哈希
  raw_hash=$(nix-prefetch-url --type "$hash_type" "$url" | tee /dev/tty | awk 'END{print $NF}')

  if [[ -z "$raw_hash" ]]; then
    echo "Failed to obtain hash from nix-prefetch-url"
    return 1
  fi

  if [[ "$both" == "true" ]]; then
    echo "Algorithm: $hash_type"
    echo "Raw ($from_format): $raw_hash"
    echo -n "SRI: "
    nix hash convert --hash-algo "$hash_type" --from "$from_format" --to sri "$raw_hash"
  else
    nix hash convert --hash-algo "$hash_type" --from "$from_format" --to sri "$raw_hash"
  fi
}
