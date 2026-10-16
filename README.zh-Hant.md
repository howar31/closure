# closure

[English](README.md) | 正體中文

給 [Claude Code](https://claude.com/claude-code) 用的 skill：在工作 session 結束前**稽核整個 session**，讓**每個未結事項都有明確處置**：當場解決、寫進文件、存進記憶、交接，或經你同意後捨棄。它會重新讀過 session，而不是做摘要，所以中途提出的事項不會在 session 結束時遺漏。不需要 hook、MCP server 或任何外部服務。

## 功能

### 稽核：`/closure`

重新讀過目前的 session，檢查四類事項：

1. **開場請求**：每一項是否都完整解決，包含驗證？「做了但沒測」仍算未結。
2. **中途事項**：過程中提出的附帶請求、方向調整與延後處理的事。
3. **意外發現**：順帶注意到的 bug、風險或技術債。
4. **決定**：只在對話中做出、還沒寫進任何持久位置的決定。

另外也會列出尚未 commit 或尚未 push 的變更。

```text
/closure            → 稽核這個 session，為每個未結事項提出處置
```

這個 skill 可由模型自動呼叫。「還有未盡事宜嗎」「收工」或 "anything left?"、"wrap up"、"loose ends" 這類說法都會觸發它，模型也可能在結束較長的 session 前主動執行。

### 處置方式

每個未結事項只會得到一種處置：

| 處置 | 適用情況 |
|---|---|
| **當場解決** | 範圍內且很快能完成 |
| **寫進文件** | 決定、行為、棄用事項：寫進專案文件或 issue tracker |
| **存進記憶** | 長期偏好、決定或專案狀態：寫進 agent 的持久記憶 |
| **交接** | 未完成、下個 session 需要脈絡才能接續的工作 |
| **捨棄** | 確實不需要，且必須經你明確同意 |

報告會逐項列出事項與處置，最後確認沒有任何事項缺少處置。需要動作的事項會直接執行，或先提出來等你同意。

### 配合你自己的設定

這個 skill 不指定任何搭配工具。如果某種處置有對應的 skill 可用，例如寫記憶的 skill、交接 session 的 skill，或維護專案文件的 skill，它會交給該 skill；沒有的話就自己處理。如果你自己的指示（例如你的 `CLAUDE.md`）規定了決定、文件或交接要放在哪裡，它會照著做。

有兩個公開的 skill 可以補上這些位置：記憶用 [claude-memory](https://github.com/howar31/claude-memory)，交接文件用 [handoff](https://github.com/howar31/handoff)。兩者都不是必要的。

## 架構

```
/closure  -->  重新讀過 session；檢查四類事項以及
               尚未 commit / push 的變更；每個未結事項給一種處置；
               回報；執行或提出
```

相關檔案：

```
~/.claude/skills/closure/          skill（symlink → repo）
```

這個 skill 本身不寫入任何檔案。不會安裝 hook，也不會修改 `settings.json`。

## 快速開始

### 1. Clone repo

```bash
git clone https://github.com/howar31/closure
```

位置不限；安裝程式會自行解析所在路徑，從哪裡執行都可以。

### 2. 安裝

```bash
cd closure && ./setup.sh
```

安裝程式把 `skills/closure` symlink 到 `~/.claude/skills/`，因此 skill 以 **`/closure`**（沒有命名空間前綴）呼叫，repo 維持唯一的來源。可重複執行，結果相同。如果 skill 路徑已經有實體目錄，它會停下並顯示訊息；加上 `--force` 會先把該目錄備份到 `~/.claude/skills/.bak/<timestamp>/` 再取代。

### 3. 驗證

```bash
./setup.sh             # 隨時可重跑；回報所有檢查結果或哪裡有問題
./setup.sh --dry-run   # 只預覽，不實際套用
./setup.sh --force     # 取代 skill 路徑上既有的實體目錄（先備份）
```

更新時在 clone 目錄執行 `git pull` 即可：已安裝的 skill 是 symlink，Claude Code 會直接讀到新檔案。只有 symlink 不見或指向別處時，才需要重跑 `setup.sh`。

### 4. 開始使用

Skill 會動態載入；如果 `/closure` 沒有立即出現，在進行中的 session 執行 `/reload-plugins`。不需要重新啟動。

## 其他安裝方式

### Plugin manager

透過 Claude Code 的 plugin manager 安裝同一個 skill。由 plugin 管理的 skill 有**命名空間**，因此名稱為 **`/closure:closure`**。兩種註冊方式安裝的是同一個 plugin，擇一即可。

**自架 marketplace**（這個 repo 本身就是 marketplace）：

```bash
claude plugin marketplace add howar31/closure
claude plugin install closure@closure
```

**中央 marketplace**（howar31 的所有 plugin；註冊一次，之後就能直接用名稱安裝其中任何一個）：

```bash
claude plugin marketplace add howar31/howar31-marketplace
claude plugin install closure@howar31
```

用 plugin 安裝時，以 `claude plugin update closure@howar31`（或 `closure@closure`）更新。Claude Code 預設只會自動更新官方 marketplace；想讓這個 marketplace 自動更新，可在 `/plugin` → Marketplaces 開啟。

### npx skills

這個 skill 沒有用到 Claude Code 專屬的路徑或工具，在其他 coding agent 也能用。跨 agent 的 [`npx skills`](https://github.com/vercel-labs/skills) CLI 會安裝到你在精靈中選擇的 agent：

```bash
npx skills add howar31/closure -g     # 接著依精靈操作
npx skills update closure -g          # 之後更新
```

### 選哪種安裝方式？

| | `setup.sh`（symlink） | npx skills | plugin manager |
|---|---|---|---|
| Slash 名稱 | `/closure`（最短） | `/closure` | `/closure:closure` |
| 安裝 / 更新 | clone + 執行 `setup.sh`；更新用 `git pull` | `npx skills add` / `update` | `claude plugin install` / `update` |
| 可被搜尋到 | 否 | 否 | 是（透過 marketplace） |

只用一種方式安裝：`setup.sh` 與 `npx skills` 都寫入 `~/.claude/skills/closure`，plugin manager 則會讓同一個 skill 多一個名稱。

## 使用時會看到什麼

執行 `/closure` 後，agent 會以簡短清單或表格列出找到的未結事項與各自的處置，並確認沒有任何事項缺少處置。接著執行範圍內的事項，其餘的先徵求你同意。沒有未結事項時，會直接說明。

## 備份

`~/.claude/skills/` 裡的 skill 目錄是指回 repo 的 symlink，repo 是唯一的來源，任何包含這份 clone 的備份都涵蓋它。

## 解除安裝

```bash
# setup.sh 安裝（被取代的實體目錄如果有，在 ~/.claude/skills/.bak/<timestamp>/）
rm ~/.claude/skills/closure

# npx skills 安裝
npx skills remove closure -g

# Plugin 安裝
claude plugin uninstall closure@closure   # 或 closure@howar31
```

`settings.json` 沒有需要還原的地方。

## 授權

MIT。見 [LICENSE](LICENSE)。
