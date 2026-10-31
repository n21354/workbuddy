# WorkBuddy 每日自动签到 + 派猫猫旅行（GitHub Actions 云端版）

基于社区验证的开源实现（FXmonkey/workbuddy_auto_checkin）。本文件夹可直接部署到 GitHub Actions，
每天**北京时间 08:10 / 14:10 / 20:10** 自动完成签到领积分、派猫猫旅行并领回礼物，**关机也照跑**。

## 文件说明
- `wb_auto.py`：云端执行主体。签到 + 派猫猫（先领后派）+ 推飞书。脚本幂等，多跑不会重复领取。
- `refresh_token.py`：在本机一次性运行，导出 WorkBuddy 登录态 token。Windows 也可直接双击 `refresh_token.exe`。
- `.github/workflows/daily.yml`：定时任务定义（cron，三个时段互为备份，抗 GitHub 定时丢弃）。

## 调用的接口（均来自 WorkBuddy 客户端，属私有接口）
- 基础地址：`https://copilot.tencent.com`
- 签到：
  - `POST /v2/billing/meter/checkin-activity-status`（查今日是否已签）
  - `POST /v2/billing/meter/daily-checkin`（领取，已签返回 code 10001）
- 猫猫旅行：
  - `GET  /v2/activity/growth/buddy/travel/status`（查状态）
  - `GET  /v2/activity/growth/buddy/travel/config`（取可派目的地）
  - `POST /v2/activity/growth/buddy/travel/claim`（领已到家的礼物）
  - `POST /v2/activity/growth/buddy/travel/depart`（派出，需带 `location_id`）
- 凭证：本机导出的 accessToken，作为 `Authorization: Bearer <token>` 注入。
- ⚠️ 这些是客户端私有接口，官方升级可能改变接口或凭据格式，届时需更新脚本。

## 部署步骤
1. **建仓库**：在 GitHub 新建一个 **Private** 仓库（如 `workbuddy-auto-checkin`），把本文件夹内容
   （必须包含 `.github/` 目录）上传；或在 GitHub 直接 Fork 原仓库 `FXmonkey/workbuddy_auto_checkin`，
   进自己仓库的 Actions 页签启用 workflows。
2. **（可选）飞书推送**：群设置 → 群机器人 → 自定义机器人，复制 webhook 地址。不配也能跑，只是不推送。
3. **本机导出 token**：在已登录 WorkBuddy 的 Windows 上运行：
   - 有 Python 3.8+：`python refresh_token.py` → 打印出两个标记之间的 token
   - 或无 Python：双击 `refresh_token.exe`
   复制 `----- 以下为 token -----` 与 `----- 以上为 token -----` 之间的内容。
4. **写 GitHub Secret**：仓库 `Settings → Secrets and variables → Actions → New repository secret`
   - `WB_ACCESS_TOKEN` = 第 3 步的 token（必填）
   - `FEISHU_WEBHOOK` = 第 2 步的 webhook（可选）
5. **手动验证**：`Actions → Buddy 加油站每日自动化 → Run workflow`，看飞书卡片或运行日志。

## 安全提醒
- 刷新令牌 = 账号钥匙，**只存 GitHub Secrets**，绝不写进代码、发群、贴到任何第三方站点。
- 仓库务必用 **Private**。
- token 有效期约 28 天；失效后重跑 `refresh_token.py` 更新 `WB_ACCESS_TOKEN` 即可。
- 只在自己账号上做日常自动领取，不要尝试绕过限制或批量刷。

## 已知限制
- 仅覆盖「签到」与「猫猫旅行」，不含盲盒、任务领取、连登兑换等其它玩法。
- 仅支持客户端 `sym-v1 / suite 1` 加密信封格式；其它格式会明确报错而不发无效请求。
