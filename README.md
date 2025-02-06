## akir-zimfw

```
基于 zimfw 的框架构建的 zsh 使用环境, 自定义多个功能模块, 整合常用插件, 添加一些常用脚本, 让 zsh 使用更加顺手

1. azim: 自定义核心模块, 配置补全, 历史信息, 按键绑定, hook 脚本等
2. colorful: 自定义颜色主题
3. extract: 文件解压缩模块
4. fzf: 结合 fzf.zsh 实现的更智能的命令行界面补全, 信息查看, 文件预览模块
5. fzf-tab-hook: fzf-tab 的 hook 脚本
6. git: 自定义 git 模块, 添加常用 git 命令别名
7. sudo: 快捷执行 sudo 命令
```

### 目录结构

```
 .
├── 󰃨 cache
├──  init.zsh
├──  LICENSE
├──  modules
│   ├──  azim
│   ├──  colorful
│   ├──  extract
│   ├──  fzf
│   ├──  fzf-tab-hook
│   ├──  git
│   └──  sudo
├──  README.md
└──  zimrc
```

### 环境依赖

```
1. 默认 shell 必须为 zsh
2. 需要安装 fd, exa, bat, fzf, ueberzug, lsd(可选), git, lua
```

### 安装使用

1. 切换终端的默认 shell 为 zsh

```zsh
# 查看 zsh  路径
chsh -l | grep zsh

# 切换 shell, 具体 shell 路径以上一条命令查找到的 zsh 路径为准
chsh -s /usr/bin/zsh
```

2. 安装环境依赖项, 某些功能依赖于下面的环境, **可选**

```zsh
# Arch Linux 直接安装
yay/pacman -S fd exa bat fzf ueberzug lsd git lua

# 其他 Linux 发行版以各自对应的包管理器为准进行安装
```

3. 安装 akir-zimfw

```zsh
# 使用下面的命令拉取仓库
git clone https://github.com/pomeluce/akir-zimfw.git ~/.config/akir-zimfw

# 执行如下命令进行配置
echo 'source ~/.config/akir-zimfw/init.zsh' >> ~/.zshrc

# 执行如下命令重新加载终端环境
source ~/.zshrc
```

### 可选配置

| 参数              | 默认值                              | 说明                                   |
| ----------------- | ----------------------------------- | -------------------------------------- |
| EXC_FOLDERS       | {.bzr,CVS,.git,.hg,.svn,.idea,.tox} | 设置 grep 命令要忽略的目录             |
| ZSH_CACHE_DIR     | $AZIM_HOME/cache                    | 设置 zsh 的 cache 目录                 |
| CASE_SENSITIVE    | false                               | 设置大小写是否敏感                     |
| AZIM_IN_LASTDIR   | false                               | 是否在启动时自动进入上次目录           |
| AZIM_HISTORY_SHOW | true                                | 绑定 Ctrl + r 快捷键, 展示搜索历史命令 |

### git 快捷命令

<!-- ``` -->

- gc 'url' : git clone 'url'
- gco : git checkout
- gpu: git push origin $(git symbolic-ref --short -q HEAD)
- gpd: git pull origin $(git symbolic-ref --short -q HEAD) --ff-only
- gd: git --no-pager diff
- gs: git --no-pager status
- gss: git --no-pager status -s
- gpt: git push origin --tags
- gtl: git tag -n --sort=taggerdate
- ga 'file' : git add 'file'
- gt 'tag' 'commit': git tag -a 'tag' -m "commit"
- gm 'commit': git commit -m "commit"
- gam 'commit': git add --all && git commit -m "commit"
- gll: git log (short)
- glla: git log (long)
- grv: git remote -v
- grs: git remote set-url origin url
- gra: git remote add origin url
- gfr: git fetch --all && git reset --hard origin && git pull
<!-- ``` -->
