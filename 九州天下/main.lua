
GameObject = UnityEngine.GameObject
MainCamera = nil
_ = I18N.GetString
IS_AUDIT_VERSION = false

CAMERA_TYPE = 1 				-- 摄像机视角模式 0-自由视角 1-锁定视角
MainCameraFollow = nil			-- MainCamera上的camera_follow组件

local UnityApplication = UnityEngine.Application
local UnityRuntimePlatform = UnityEngine.RuntimePlatform

CTRL_STATE = {
	START = 0,
	UPDATE = 1,
	finish = 2,
	NONE = 3,
}

socket = require("socket")
mime = require("mime")
cjson = require("cjson.safe")
require("init/http_client")
require("systool/gameobject")

local ResPreload = require("core.res_preload")

local quick_login = require("editor/quick_login")
local develop_mode = require("editor/develop_mode")
local quick_restart = require("editor/quick_restart")

IsLowMemSystem = UnityEngine.SystemInfo.systemMemorySize <= 1500
GAME_FPS = 60

local ctrl_list = {}
function Sleep(n)
	socket.select(nil, nil, n)
end

function GameStart()
	-- 控制释放的时间(1G内存以下机子加快释放)
	if IsLowMemSystem then
		PrefabPool.Instance.DefaultReleaseAfterFree = 5
		SpritePool.Instance.DefaultReleaseAfterFree = 5
		GameObjectPool.Instance.DefaultReleaseAfterFree = 5
	else
		PrefabPool.Instance.DefaultReleaseAfterFree = 180
		SpritePool.Instance.DefaultReleaseAfterFree = 180
		GameObjectPool.Instance.DefaultReleaseAfterFree = 180
	end

	UnityEngine.Screen.sleepTimeout = UnityEngine.SleepTimeout.NeverSleep

	UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.BelowNormal

    ResPreload.init()

	if quick_login:IsOpenQuick() then
		quick_login:Start()
		return
	end

	PushCtrl(require("init/init_ctrl"))
end

function GameUpdate()
	local time = UnityEngine.Time.unscaledTime
	local delta_time = UnityEngine.Time.unscaledDeltaTime
	for k, v in pairs(ctrl_list) do
		v:Update(time, delta_time)
	end

	quick_login:Update(time, delta_time)
	develop_mode:Update(time, delta_time)
end

function GameStop()
	for k, v in pairs(ctrl_list) do
		v:Stop()
	end

	quick_login:Stop()
	develop_mode:OnGameStop()
end

local gamePaused = false;
function GameFocus(hasFocus)
	gamePaused = not hasFocus

	if nil ~= GlobalEventSystem then
		GlobalEventSystem:Fire(SystemEventType.GAME_FOCUS, hasFocus)
	end
end

function GamePause(pauseStatus)
	gamePaused = pauseStatus

	if nil ~= GlobalEventSystem then
		GlobalEventSystem:Fire(SystemEventType.GAME_PAUSE, pauseStatus)
	end
end

function ExecuteGm(gm)
	quick_login:ExecuteGm(gm)
end

function ExecuteHotUpdate(lua_name)
	print("[ExecuteHotUpdate]", lua_name)
	_G.package.loaded[lua_name] = nil
	require(lua_name)
end

function ExecuteQuickRestart(reload_files)
	quick_restart:Restart(reload_files)
end

function PushCtrl(ctrl)
	ctrl_list[ctrl] = ctrl
end

function PopCtrl(ctrl)
	ctrl_list[ctrl] = nil
end

if not UnityEngine.Debug.isDebugBuild then
	print_log = function() end
	print = function() end
end

math.randomseed(os.time())
GameStart()
