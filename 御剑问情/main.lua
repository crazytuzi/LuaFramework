
MainCamera = nil
_ = I18N.GetString
IS_AUDIT_VERSION = false		-- 开启IOS审核

CAMERA_TYPE = 1 				-- 摄像机视角模式 0-自由视角 1-锁定视角
MainCameraFollow = nil			-- MainCamera上的camera_follow组件
IS_MERGE_SERVER = false			-- 是否是合服之后
SHIELD_VOICE = false 			-- 是否屏蔽语音聊天

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
local quick_restart = require("editor/quick_restart")
local develop_mode = require("editor/develop_mode")

local ctrl_list = {}
function Sleep(n)
	socket.select(nil, nil, n)
end

IsLowMemSystem = UnityEngine.SystemInfo.systemMemorySize <= 1500
GAME_FPS = 60

function GameStart()
	-- 控制释放的时间
	if IsLowMemSystem then
		PrefabPool.Instance.DefaultReleaseAfterFree = 30
		SpritePool.Instance.DefaultReleaseAfterFree = 30
		GameObjectPool.Instance.DefaultReleaseAfterFree = 30
	else
		PrefabPool.Instance.DefaultReleaseAfterFree = 180
		SpritePool.Instance.DefaultReleaseAfterFree = 180
		GameObjectPool.Instance.DefaultReleaseAfterFree = 180
	end

	if nil ~= rawget(getmetatable(PrefabPool), "SetMaxLoadingCount") then
		PrefabPool.Instance:SetMaxLoadingCount(5)
	end

	if nil ~= rawget(getmetatable(SpritePool), "SetMaxLoadingCount") then
		SpritePool.Instance:SetMaxLoadingCount(7)
	end

	if nil ~= rawget(getmetatable(TexturePool), "SetMaxLoadingCount") then
		TexturePool.Instance:SetMaxLoadingCount(2)
	end

	if nil ~= rawget(getmetatable(AssetManager), "SetAssetBundleLoadMaxCount") then
		AssetManager.SetAssetBundleLoadMaxCount(5, 2)
	end

	UnityEngine.Screen.sleepTimeout =
		UnityEngine.SleepTimeout.NeverSleep

	ResPreload.init()

	if quick_login:IsOpenQuick() then
		quick_login:Start()
		return
	end

	PushCtrl(require("init/init_ctrl"))
end

-- 兼容外服旧包
local is_handle_unactive_gamepool = false
function TryUnActiveGamePool()
	if is_handle_unactive_gamepool then
		return
	end

	local pool = GameObject.Find("GameObjectPool")
	if nil ~= pool then
		is_handle_unactive_gamepool = true
		pool:SetActive(false)
	end
end

function GameUpdate()
	TryUnActiveGamePool()

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

function Collectgarbage(param)
	return collectgarbage(param) or -1
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
