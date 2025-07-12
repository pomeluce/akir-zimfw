alias nx-switch='sudo nixos-rebuild switch --flake .'
alias nx-test='sudo nixos-rebuild test --flake .'
alias nx-boot='sudo nixos-rebuild boot --flake .'
alias nx-history='nix profile history --profile /nix/var/nix/profiles/system'

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
        "\($k): \(.value.version): \(.value.description)"
      else
        "\($k): \(.value.version)"
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
