# CommonSkill

跨项目、跨 Agent 复用的技能仓库。每个技能是一个独立目录，内含带 YAML frontmatter 的 `SKILL.md`，遵循 [Agent Skills](https://agentskills.io) 开放格式。

## 包含的技能

| 技能 | 用途 |
|---|---|
| `skill-installer` | 按当前操作系统与 Agent 客户端，把技能装到真正被扫描的根目录 |
| `workspace-architect` | 规划目录结构、技术栈与命名规范并写入 `AGENTS.md`；确认语言时默认 TS + Bun / Python + uv（Go、Rust 需确认）；或按规范归档文件 |
| `git-versioning` | 用自然语言保存、查看、比较、撤销、恢复项目文档版本（本地 Git） |
| `clarify-decisions` | 按依赖顺序多轮澄清计划/想法/需求背后的决策，最后输出修订版方案；不进入执行 |
| `facts-searching` | 派并行子代理做网络调研，只返回与决策相关的结论 |
| `semantic-clarification` | 澄清任务描述中的术语误用、概念混淆与歧义，输出归一化后的任务描述 |

### 技能间依赖

`semantic-clarification` 在需要外部证据核对术语时，会委派 `facts-searching` 执行调研。两者建议一起安装。

## 安装

**不需要执行脚本。** 克隆仓库后，让你的 Agent 读取 `skills/skill-installer/SKILL.md` 并照做即可：

```sh
git clone https://github.com/Rainnnnnnnson/CommonSkill.git
```

然后对 Agent 说：

> 读一下 CommonSkill 里的 skill-installer，把这个仓库的技能装到我当前用的 Agent 里。

Agent 会自行判断当前平台和客户端，选对路径。也可以直接手动复制——技能就是普通目录：

```sh
# macOS / Linux，DSH 用户级
cp -R CommonSkill/skills/* ~/.agents/skills/

# macOS / Linux，Claude Code 个人级
cp -R CommonSkill/skills/* ~/.claude/skills/
```

Windows 用 PowerShell：

```powershell
# DSH 用户级
Copy-Item -Recurse -Force CommonSkill\skills\* $HOME\.agents\skills\

# Claude Code 个人级
Copy-Item -Recurse -Force CommonSkill\skills\* $HOME\.claude\skills\
```

## 为什么没有 install.sh

安装路径取决于两件事：**操作系统**和**当前 Agent 客户端**，两者都无法从一个 shell 脚本里可靠判断。

- `.sh` 在 Windows 上跑不了，PowerShell 版本又得单独维护
- Agent Skills 是开放标准，但**各客户端的技能根目录不同**：Claude Code 读 `~/.claude/skills`，DSH 读 `~/.agents/skills` 等，互不相认
- 一个脚本无法知道「现在是谁在读这些技能」

把这些判断交给 Agent，由它在执行时按实际环境决定，比维护多份平台脚本更可靠。技能本身是纯数据，任何平台复制过去就能用。

## 各客户端技能根目录

| 客户端 | 个人级 | 项目级 |
|---|---|---|
| DSH | `~/.agents/skills/`、`~/.dsh/skills/` | `<项目根>/.dsh/skills/`、`.agents/skills/` |
| Claude Code | `~/.claude/skills/` | `<项目根>/.claude/skills/` |

DSH 项目根指最近的含 `.git` 的祖先目录；没有 `.git` 时用当前目录。两者都只识别直接子级 `<name>/SKILL.md`（或 `<name>.md`），嵌套目录不扫描。

其他客户端请查其官方文档，不要套用上表。

## 更新

```sh
cd CommonSkill && git pull
```

若当初用的是软链接，无需重装；若是复制，重新复制一次并覆盖即可。

## 新增技能

1. 在 `skills/` 下新建目录，放入 `SKILL.md`
2. frontmatter 的 `name` 必须与目录同名，且为 **kebab-case**（小写字母、数字、连字符）
3. 重新安装或让 Agent 更新

**`name` 不合法会被静默丢弃**：客户端通常不报错，只是技能不出现。改完务必验证技能确实出现在会话的技能列表里。
