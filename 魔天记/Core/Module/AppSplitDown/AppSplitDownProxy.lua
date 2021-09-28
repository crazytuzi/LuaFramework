require "Core.Module.Pattern.Proxy"

AppSplitDownProxy = Proxy:New();
local HintLev = 60 -- 强制下载及提示等级
local notHintLev = 5 -- 下载及提示等级
AppSplitDownProxy._loaded = false
local force = false
local startFlg = false
local wifiFlg = false
function AppSplitDownProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.APP_DOWN_STATE, AppSplitDownProxy._OnGetAwardState);
end
function AppSplitDownProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.APP_DOWN_STATE, AppSplitDownProxy._OnGetAwardState);
end

function AppSplitDownProxy.InitStatic()
    AppSplitDownProxy.config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_APP_SPLIT)[1]
    AppSplitDownProxy._loaded = AssetsBehaviour.instance:AppSplitLoaded()
    Warning("AppSplitDownProxy._loaded=" .. tostring(AppSplitDownProxy._loaded))
    if AppSplitDownProxy._loaded then
        AppSplitDownProxy.process = 100
        AppSplitDownProxy._state = 5
    end
    if not AppSplitDownProxy._loaded then
        MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, AppSplitDownProxy._CheckSplitLoad, self);
    end
end
function AppSplitDownProxy._CheckSplitLoad()
    if AppSplitDownProxy._loaded then return end
    if NoviceManager and NoviceManager.Runing() then return end
    local lev = PlayerManager.GetPlayerLevel()
    if lev ~= notHintLev + 1 then return end
    AppSplitDownProxy._AppSplitLoad(nil, lev, startFlg, force)
end
function AppSplitDownProxy.Init()
    SocketClientLua.Get_ins():SendMessage(CmdType.APP_DOWN_STATE)
end
function AppSplitDownProxy._OnGetAwardState(com, data)
    -- Warning("_OnGetAwardState___" .. data.st)
    AppSplitDownProxy._awardState = data.st
    MessageManager.Dispatch(AppSplitDownNotes, AppSplitDownNotes.APPSPLITDOWN_CHANGE)
end
function AppSplitDownProxy.GetAwarded()
    return AppSplitDownProxy._awardState == 1
end
function AppSplitDownProxy.HasAward()
    return AppSplitDownProxy.Loaded() and not AppSplitDownProxy.GetAwarded()
end

function AppSplitDownProxy._AppSplitLoad(onComplete, level, startflg, force)
    Warning("_AppSplitLoad,wifi=" .. tostring(AppSplitDownProxy.IsWifi()).. tostring(force).. tostring(wifiFlg))
    -- AppSplitDownProxy.completeHandler = onComplete
    if not force and level < notHintLev then return end
    if not wifiFlg and not AppSplitDownProxy.IsWifi() then
        -- 	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
        -- 		title = LanguageMgr.Get("common/notice"),
        -- 		msg = LanguageMgr.Get("UI_AppSplitPanel/notWifi"),
        --          hander = force and AppSplitDownProxy._AppSplitLoadStart or nil
        --        })
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("UI_AppSplitPanel/notWifi"),
            hander = function()
                wifiFlg = true
                AppSplitDownProxy._AppSplitLoadStart(startflg)
            end
        } )
        return
    end
    AppSplitDownProxy._AppSplitLoadStart(startflg)
end
function AppSplitDownProxy._AppSplitLoadStart(startflg)
    -- Warning("_AppSplitLoadStart,puased=" .. tostring(AppSplitDownProxy.puased) .. tostring(AppSplitDownProxy.startup))
    if AppSplitDownProxy.startup then
        if startflg then AppSplitDownProxy.Start() end
        return
    end
    AppSplitDownProxy.startup = true
    AppSplitDownProxy.puased = false
    AssetsBehaviour.instance:AppSplitLoad(
    AppSplitDownProxy._OnComplete
    , AppSplitDownProxy._OnProcess
    , AppSplitDownProxy._OnStateChange
    , AppSplitDownProxy._OnError
    , startflg and 30 or 300)
    -- 下载延迟毫秒
end
function AppSplitDownProxy._OnComplete()
    AppSplitDownProxy._loaded = true
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, AppSplitDownProxy._CheckSplitLoad, self);
    ModuleManager.SendNotification(AppSplitDownNotes.CLOSE_APPSPLITDOWN)
    ModuleManager.SendNotification(AppSplitDownNotes.CLOSE_APPSPLITDOWN2)
    MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
    if AppSplitDownProxy.completeHandler then
        AppSplitDownProxy.completeHandler()
        AppSplitDownProxy.completeHandler = nil
    end
    MessageManager.Dispatch(AppSplitDownNotes, AppSplitDownNotes.APPSPLITDOWN_CHANGE)
end
AppSplitDownProxy.process = 0
AppSplitDownProxy._state = 1
function AppSplitDownProxy._OnProcess(current, total)
    -- Warning(current .. '---' .. total)
    AppSplitDownProxy.process = math.floor(current * 100 / total)
end
function AppSplitDownProxy._OnStateChange(st)
    AppSplitDownProxy._state = st
end
function AppSplitDownProxy._OnError(st, msg)
    AppSplitDownProxy.startup = false
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {
        title = LanguageMgr.Get("common/notice"),
        msg = LanguageMgr.Get(st == 1 and "UI_AppSplitPanel/netError" or "UI_AppSplitPanel/ioError"),
        hander = AppSplitDownProxy._CheckSplitLoad
    } )
    GuideManager.Stop()
end
function AppSplitDownProxy.OnDisConnection()
    AppSplitDownProxy.startup = false
end
function AppSplitDownProxy.GetStateIsLoading()
    local s = AppSplitDownProxy._state
    return(s ~= 11) and not AppSplitDownProxy.Loaded()
    -- 解压
end
function AppSplitDownProxy.GetProcessDec()
    local str = ""
    if AppSplitDownProxy.GetStateIsLoading() then
        str = LanguageMgr.Get("UI_AppSplitPanel/loading") .. AppSplitDownProxy.process .. "%"
    elseif AppSplitDownProxy._state == 11 then
        str = LanguageMgr.Get("UI_AppSplitPanel/decodeing") .. AppSplitDownProxy.process .. "%"
    elseif AppSplitDownProxy._state == 5 then
        str = LanguageMgr.Get("UI_AppSplitPanel/complete")
        MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
    end
    return str
end

-- 需要补丁包资源的系统功能检查( 返回是否已加载补丁包
function AppSplitDownProxy.SysCheckLoad(onComplete, level, showLoad)
    local flg = AppSplitDownProxy.Loaded()
    -- Warning("SysCheckLoad,level=" .. level .. tostring(flg))
    if not showLoad then
        if not flg then MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("UI_AppSplitPanel/notLoaded")) end
        return flg
    end
    if not flg then
        AppSplitDownProxy._ShowLoad()
        AppSplitDownProxy._AppSplitLoad(onComplete, level)
    end
    return flg
end
-- 登录检查加载补丁包
function AppSplitDownProxy.InGameCheckLoad(onComplete, level)
    -- Warning("AppSplitDownProxy.InGameCheckLoad,level=" .. level .. tostring(AppSplitDownProxy.Loaded()))
    local flg = AppSplitDownProxy.Loaded()
    if not flg then
        flg = level < HintLev
        if not flg then AppSplitDownProxy._ShowLoad() end
        AppSplitDownProxy._AppSplitLoad(onComplete, level, true)
    end
    return flg
end

-- 登录强制加载补丁包, level,-2强制加载
function AppSplitDownProxy.ForceLoad()
    local flg = AppSplitDownProxy.Loaded()
    if not flg then
        ModuleManager.SendNotification(AppSplitDownNotes.OPEN_APPSPLITDOWN2)
        startFlg = true
        force = true
        AppSplitDownProxy._AppSplitLoad(nil, 0, startFlg, force)
    end
    return flg
end
-- 检查补丁包是否加载
function AppSplitDownProxy._ShowLoad()
    MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("UI_AppSplitPanel/notLoaded"));
    ModuleManager.SendNotification(AppSplitDownNotes.OPEN_APPSPLITDOWN)
end

function AppSplitDownProxy.Loaded()
    return AppSplitDownProxy._loaded
end
AppSplitDownProxy.puased = true
function AppSplitDownProxy.Pause()
    AppSplitDownProxy.puased = true
    AssetsBehaviour.instance:AppSplitLoadPuase(AppSplitDownProxy.puased)
end
function AppSplitDownProxy.Start()
    AppSplitDownProxy.puased = false
    if AppSplitDownProxy.startup then
        AssetsBehaviour.instance:AppSplitLoadPuase(AppSplitDownProxy.puased)
    else
        AppSplitDownProxy._AppSplitLoadStart()
    end
    if not AppSplitDownProxy.IsWifi() then wifiFlg = true end
end
function AppSplitDownProxy.GetAward()
    SocketClientLua.Get_ins():SendMessage(CmdType.APP_DOWN_GET_AWARD)
    AppSplitDownProxy._awardState = 1
    MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
end
function AppSplitDownProxy.GetAwardConfig()
    return AppSplitDownProxy.config.award
end
function AppSplitDownProxy.IsWifi()
    local li = LogHelp.instance
    if li then return li:GetNetworkState() == "wifi" end
    return  Util.IsWifi
end
function AppSplitDownProxy.NetAvailable()
    return Util.NetAvailable()
end

