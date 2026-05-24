# Coin Dash Roblox Demo

Coin Dash 是一个 AI 辅助构建的 Roblox 游戏原型 Demo。玩家需要在限定时间内收集 10 个金币，金币收集完后终点门打开，玩家触碰终点即可通关。

## 核心玩法

- 玩家出生在起点平台。
- 地图自动生成平台、金币、终点门和终点触发区。
- 收集金币会增加分数并播放反馈。
- 收集满 10 个金币后，终点门打开。
- 90 秒倒计时结束前到达终点即胜利。
- UI 显示金币数量、倒计时和任务状态。

## Roblox Studio 使用方法

1. 打开 Roblox Studio，新建 `Baseplate` 项目。
2. 在 `ServerScriptService` 里新建 Script，命名为 `GameManager`。
3. 将 `ServerScriptService/GameManager.server.lua` 的内容复制进去。
4. 在 `StarterPlayer > StarterPlayerScripts` 里新建 LocalScript，命名为 `CoinDashClient`。
5. 将 `StarterPlayerScripts/CoinDashClient.client.lua` 的内容复制进去。
6. 点击运行 Play。

## 可用于申请说明

这是一个 AI 辅助构建的 Roblox 游戏原型 Demo，包含地图自动生成、基础关卡流程、金币收集机制、胜负判定、倒计时 UI、交互反馈和可扩展脚本结构。后续可以扩展为关卡编辑器、障碍机关、排行榜、多人竞速和 AI 关卡生成工作流。

## Project Structure

```text
coin-dash-demo/
  ServerScriptService/
    GameManager.server.lua
  StarterPlayerScripts/
    CoinDashClient.client.lua
  docs/
    application-submit.md
    upload-checklist.md
```
