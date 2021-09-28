protobuf = require "UF.net.pbc.protobuf"

-- 游戏内消息ID
G_EVENTMSGID     = require("app.network.EventMsgID")

G_NetMsg_ID = require("app.network.NetMsgID")
G_WP8 = require("app.setting.Wp8Addition")

G_Path = require("app.setting.Path")


G_Goods = require("app.setting.Goods")
G_Drops = require("app.setting.Drops")
G_NetworkManager = require("app.network.NetworkManager").new()

--多语言
G_lang = require("app.lang.Lang")
G_Setting = require("app.setting.Setting")
-- 玩家数据信息
G_Me       = require("app.data.Me").new()

G_NetMsgError = require("app.network.NetMsgError")

G_GlobalFunc = require("app.global.GlobalFunc")

-- topbar  类型
G_TopBarConst = require("app.const.TopBarConst")

G_playAttribute = require("app.scenes.common.PlayAttribute")
G_flyAttribute = require("app.scenes.common.FlyAttributes")

--服务器时间
G_ServerTime = require("app.data.ServerTime").new()

--服务器列表
G_ServerList = require("app.data.ServerList").new()

--平台登陆
--G_PlatformProxy = require("app.platform.PlatformProxy").new()
G_PlatformProxy = require(PROXY_CLASS).new()

--本地推送管理
G_NotifycationManager = require("app.common.tools.NotifycationManager").new()

G_HandlersManager = require("app.network.HandlersManager").new()

G_WaitingLayer = nil

MessageBoxEx = require("app.scenes.common.MessageBoxEx")

G_MovingTip = require("app.scenes.common.MovingTips").new()

G_Report = require("app.debug.report")


Colors = require("app.setting.Colors")

G_commonLayerModel = require("app.scenes.common.CommonLayerModel").new()

G_moduleUnlock = require("app.scenes.common.ModuleUnlock").new()

G_SoundManager = require("app.sound.SoundManager")

G_Notice = require("app.data.NoticeData").new()

G_Loading = require("app.scenes.common.LoadingCloud").new()

G_topLayer = nil

G_GameService = require("app.scenes.common.GameService").new()

G_ColorShaderManager = require("app.common.shader.ColorShaderManager").new()
G_SceneObserver = require("app.scenes.common.SceneObserver").new()
G_MemoryUtils = require("app.scenes.common.MemoryUtils").new()

G_ShareService = require("app.scenes.common.ShareService").new()


G_Job = require("app.debug.Job").new()

G_GuideMgr = nil

G_keyboardShowTimes = 0


G_RoleService = require("app.scenes.common.RoleService").new()

G_LogSetting = require("app.setting.LogSetting")

G_Downloading = require("app.scenes.common.CommonDownloadHandler")

-- clear global variables when exit 
ExitHelper:getInstance():addExitExcute(function (  )
	local TextureCaches = require("app.data.TextureCaches")
    TextureCaches.unloadCacheTextures()
    
	G_HandlersManager:clearHandlers()
	G_HandlersManager = nil

	G_WaitingLayer:removeFromParentAndCleanup(true)
	G_MovingTip:removeFromParentAndCleanup(true)

	G_commonLayerModel:onExit()
	G_commonLayerModel = nil

	G_moduleUnlock:unInit()
	G_moduleUnlock = nil
end)

