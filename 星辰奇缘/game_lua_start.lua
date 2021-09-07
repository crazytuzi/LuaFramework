-- lus 入口
GameLuaStart = GameLuaStart or BaseClass()

-- 加个若引用表检查BaseView类数量
MemoryCheckTable = {}
setmetatable(MemoryCheckTable, {__mode = "k"})

function GameLuaStart:__init()
    self.moduleManager = ModuleManager.New()
end

function GameLuaStart:Start()
    if Application.platform == RuntimePlatform.WindowsEditor or Application.platform == RuntimePlatform.OSXEditor then
        require("LuaDebuger")
    end

    Log.Error("wang  ==>  GameLuaStart  Start")

    Application.targetFrameRate = 45
    UnityEngine.Time.fixedDeltaTime = 0.025
    QualitySettings.blendWeights = BlendWeights.OneBone
    QualitySettings.antiAliasing = 0
    QualitySettings.anisotropicFiltering = AnisotropicFiltering.Disable
    ctx.MainCamera.useOcclusionCulling = false
    ctx.UICamera.nearClipPlane = -15
    if ctx.IsDebug then
        IS_DEBUG = true
    else
        Log.SetLev(3) -- Info
        IS_DEBUG = false
    end
    BaseUtils.CheckVerify()

    if BaseUtils.IsVerify then
        BaseUtils.VerifyRequire()
    end
    if IS_DEBUG then
        local __g = _G
        setmetatable(__g, {
            __newindex = function(_, name, value)
                local msg = "VARIABLE : '%s' SET TO GLOBAL VARIABLE \n%s"
                rawset(__g, name, value)
                local trace = debug.traceback()
                if name ~= "connection_recv_data" and string.sub(name, 1, 3) ~= "___" then
                    Log.Error(string.format(msg, name, trace), 0)
                end
            end
        })
    end
    self.moduleManager:Activate()
    EventMgr.Instance:Fire(event_name.end_mgr_init)
end

function GameLuaStart:FixedUpdate()
    self.moduleManager:FixedUpdate()
end

function GameLuaStart:HotUpdate()
    GmManager.Instance:HotUpdate()
end
