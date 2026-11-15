# CommonSkill

跨项目复用的 Agent 技能仓库。每个技能是一个独立目录，目录内 `SKILL.md` 带 YAML frontmatter。

## 包含的技能

| 技能 | 用途 |
|---|---|
| `workspace-architect` | 为项目规划目录结构与文件命名规范并写入 `AGENTS.md`；或按已有规范把杂乱文件归档 |
| `git-versioning` | 用自然语言保存、查看、比较、撤销、恢复项目文档版本（本地 Git，不涉及远程） |

## 安装

```sh
git clone https://github.com/Rainnnnnnnson/CommonSkill.git ~/CommonSkill
~/CommonSkill/install.sh
```

默认把每个技能**软链接**到 `~/.agents/skills/`，所有项目共享，且 `git pull` 后自动生效。

安装到某个项目（而非全局）：

```sh
cd /path/to/your-project
~/CommonSkill/install.sh --project
```

其他选项：

| 参数 | 作用 |
|---|---|
| `--copy` | 复制而非软链接（Windows 无符号链接权限时用） |
| `--link` | 强制使用软链接（默认） |
| `--force` | 覆盖目标位置已存在的同名技能 |
| `--project` / `--user` | 项目级 `.agents/skills` / 用户级 `~/.agents/skills` |

不加 `--force` 时，已存在的同名技能会跳过并在输出中提示，不会覆盖你本地改过的版本。

## 更新

```sh
cd ~/CommonSkill && git pull
```

软链接方式下无需重装，下次会话自动生效（DSH 的技能目录有 watcher）。

## 目录结构

```
CommonSkill/
├── README.md
├── install.sh
└── skills/
    ├── git-versioning/
    │   ├── SKILL.md
    │   └── references/
    └── workspace-architect/
        └── SKILL.md
```

## 新增技能

1. 在 `skills/` 下新建目录，放入 `SKILL.md`。
2. frontmatter 的 `name` 必须与目录同名，且为 **kebab-case**（小写字母、数字、连字符）。
3. 运行 `./install.sh --force` 重新安装。

`install.sh` 会校验名称格式。DSH 对不合法的技能名是**静默丢弃**——不报错，只是技能不出现，所以这一步校验很有必要。

## 技能发现规则（DSH）

技能按以下根目录扫描，同名时 rank 小的优先：

| Rank | 来源 | 路径 |
|---|---|---|
| 100 | 项目 | `<项目根>/.dsh/skills` |
| 200 | 项目 | `<项目根>/.agents/skills` |
| 400 | 用户 | `~/.dsh/skills` |
| 500 | 用户 | `~/.agents/skills` |

项目根指最近的含 `.git` 的祖先目录；没有 `.git` 时用当前目录。只识别直接子级：`<name>/SKILL.md` 或 `<name>.md`。
