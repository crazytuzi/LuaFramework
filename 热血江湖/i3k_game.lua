----------------------------------------------------------------
local require = require

package.path	= "./script/?.lua;" .. package.path
package.cpath	= "./?.dll;./script/?.dll;" .. package.cpath

require("i3k_global");
require("i3k_engine");
require("i3k_ui_mgr");
require("i3k_coroutine_mgr");
require("i3k_download_mgr");
require("i3k_download_flag")
require("dataeye/i3k_data_eye_interface");
require("logic/i3k_demo");
require("logic/i3k_model_checker");
require("logic/i3k_main_game");
require("logic/network/i3k_network");
require("logic/network/i3k_connecting_state");
require("i3k_net_log")
require "functions"

----------------------------------------------------------------
local eMaxFrameTime		= 2; -- 2秒

-- game logic
local g_i3k_game_logic	= nil;
local g_i3k_game_pause	= false;
local g_i3k_entity_map	= { };
local g_i3k_entity_map_roleID = { };
local g_i3k_user_cfg = nil
local g_i3k_announcement = nil
local g_i3k_net_log = nil
local g_i3k_enableFogBeforeScene = nil
local g_i3k_StopBGMForScene = nil
local g_i3k_SceneEntitys = nil
local g_ignore_next_pause_resume = false
local g_i3k_scene_ani_state = false

g_VOICE_RECORDING_NIL = 0
g_VOICE_RECORDING_ONLINE_VOICE = 1
g_VOICE_RECORDING_VOICE_MSG = 2
g_VOICE_PLAYING_NIL = 100
g_VOICE_PLAYING_VOICE_MSG = 102
local i3k_voice_recording_state = g_VOICE_RECORDING_NIL
local i3k_voice_playing_state = g_VOICE_PLAYING_NIL

local g_i3k_extpack_filelist = {}
local g_i3k_extpack_size = {}

local g_i3k_net_state = { connected = false, state = i3k_connecting_state.new(), force_close_error_code = 0 }
---登录时生效
local g_i3k_area		= 1		--渠道Id
local g_i3k_plat		= 1		--平台Id 0:ios 1:android
local g_i3k_username    = ""    --注册名
local g_i3k_login_state = { NOTLOGIN = 1, LOGINING = 2, LOGINED = 3}
local g_i3k_login_data  = { has_authed = false, role_login_state = g_i3k_login_state.NOTLOGIN, server_addr = {host = "127.0.0.1", port = 1106}, uid = "", channel = "", ukey = "", server_id = 1}
local g_i3k_server_list  =
{
	[1] = {id=1, name="01服-天池", addr="127.0.0.1:1106", state=101, serverId = 1005},
	[2] = {id=2, name="02服-東嶽", addr="127.0.0.1:1107", state=211, serverId = 1004},
	[3] = {id=3, name="03服-南林", addr="127.0.0.1:1108", state=300, serverId = 1003},
	[4] = {id=4, name="04服-玄湖", addr="127.0.0.1:1109", state=210, serverId = 1002},
	[5] = {id=5, name="05服-神地", addr="127.0.0.1:1106", state=211, serverId = 1001},
}
local g_i3k_server_group =
{
	[1] = {
		[1] = {id=1, name="01服-天池", addr="127.0.0.1:1106", state=101, serverId = 1},
	},
	[2] = {
		[1] = {id=2, name="02服-東嶽", addr="127.0.0.1:1107", state=310, serverId = 2},
	},
}

local g_i3k_msdk        =
{
	gameAppID = "520050",
	deviceID = "",
	systemHardware = "unknown",
	systemSoftware = "",
	cpuHardware = "",
	screenWidth = 1080,
	screenHeight = 720,
	density = 1.2,
	network = 0,
	macAddr = "",
	memory = 2048,
	coreNum = 4,
	loginIP = "",
	locale = "",
	hasNotchAndroidP = 1,
}

local g_i3k_invite_code = ""
---登录时生效



local g_i3k_os_type		= 0;
local g_i3k_exe_path	= "";
local g_i3k_iosExamineServer = false;

local g_i3k_server_id = 0;
local g_i3k_server_open_day = 0;
local g_i3k_server_open_time = 0; --开服时间
local g_i3k_time		= 0;
local g_i3k_last_keepalive_time
						= 0;
local g_i3k_dev_mode	= false; -- 开发版
local g_i3k_debug_level	= 0;	-- 0 -- all; 1 -- warn/error; 2 -- error
local g_i3k_bgm_volume	= 1.0;
local g_i3k_gc_time_line = 0;
local g_i3k_short_cut_type	= 0; --shortcutItemType: 0：默认，1：福利，2：活动，3：排行榜
local g_i3k_is_create = false
local g_i3k_is_roleNameInvalid = false; --玩家角色名非法信息
local g_i3k_auto_fight_flag = {isAuto = false, mapType = -1}
local g_i3k_click_data = {} 	--检测玩家是否是工作室练号脚本按钮点击坐标
local g_i3k_click_total_num = 0 --检测玩家是否是工作室练号脚本按钮总次数

i3k_log = function(...)
	if g_i3k_dev_mode then
		if g_i3k_debug_level == 0 then
			--Debugger.Print("gclient: log at tick ", i3k_game_get_logic_tick(), i3k_game_get_delta_tick(), ...);
			Debugger.Print("gclient: log at tick ", i3k_game_get_logic_tick(), ...);
		end
	end
end

i3k_warn = function(...)
	if g_i3k_dev_mode then
		if g_i3k_debug_level < 2 then
			Debugger.Print("gclient: warn at tick ", i3k_game_get_logic_tick(), ...);
		end
	end
end

i3k_error = function(...)
	if g_i3k_dev_mode then
		Debugger.Print("gclient: error at tick ", i3k_game_get_logic_tick(), ...);
	end
end

function __I3K__TRACKBACK__DISABLE__(msg)
	i3k_log("----------------------------------------");
	i3k_log("LUA ERROR: " .. tostring(msg) .. "\n");
	i3k_log(debug.traceback());
	i3k_log("----------------------------------------");
end

__I3K__TRACKBACK__ = function(msg)
    return debug.traceback(msg, 2)
end

__G__TRACKBACK__ = function(msg)
    return debug.traceback(msg, 2)
end

function i3k_log_stack()
	if g_i3k_dev_mode then
		if g_i3k_debug_level == 0 then
			Debugger.Print("gclient: log at tick ", i3k_game_get_logic_tick(), "stack:");
			local s = debug.traceback();
			local t = string.split(s, "\n")
			for i, v in pairs(t) do
				Debugger.Print("gclient:\t\t\t\t\t\t\t", v);
			end
		end
	end
end

----------------------------------------------------------------
function i3k_game_create(os_type, exe_path, shortcutItemType)
	-- shortcutItemType = 1
	--shortcutItemType: 0：默认，1：福利，2：活动，3：排行榜
	collectgarbage("collect");
	collectgarbage("setpause", 100);
	collectgarbage("setstepmul", 500);
	g_i3k_is_create = true
	g_i3k_os_type	= os_type;
	g_i3k_exe_path	= exe_path;

	i3k_game_set_debug_level(0); -- warn/error

	i3k_global_create(g_i3k_dev_mode);
	i3k_engine_create();
	i3k_ui_mgr_create();
	i3k_coroutine_mgr_create();
	i3k_download_mgr_create();
	i3k_game_network_init();

	--test
	local words = Engine.StringVector();
	words:push_back("attempt to call global 'cb1' (a nil value)");
	--words:push_back("UIButton.lua:46");
	g_i3k_game_handler:ClsIgnoreAssertKeywords();
	g_i3k_game_handler:SetIgnoreAssertKeywords(words);

	--g_i3k_mmengine:SetLoadFlags(eDisLoadStaticNode + eDisLoadTerrain + eDisLoadGroupNode, eLoadPriority_Neg2);
	--g_i3k_mmengine:SetLoadFlags(eDisLoadStaticNode + eDisLoadGroupNode, eLoadPriority_Neg2);
	--g_i3k_mmengine:SetLoadFlags(eDisLoadTerrain, eLoadPriority_Neg2);
	--g_i3k_mmengine:SetLoadFlags(eDisLoadTexture, eLoadPriority_Neg2);
	--g_i3k_mmengine:SetLoadFlags(eDisLoadStaticNode + eDisLoadGroupNode, eLoadPriority_Neg2, 64);
	g_i3k_mmengine:SetLoadFlags(eLoadAllNode, eLoadPriority_Zero, 512);
	--g_i3k_mmengine:EnableSceneCheckPos(true, Engine.SVector3():ToEngine(), 32);
	g_i3k_mmengine:EnableSceneCheckPos(false, Engine.SVector3():ToEngine(), 32);

	g_i3k_mmengine:SetDistanceClipFactor(8);
	g_i3k_mmengine:SetNoClipDistance(40);
	if os_type == eOS_TYPE_WIN32 then
		g_i3k_mmengine:SetEffectPriority(EPP_3);
	end
	g_i3k_mmengine:SetMaxEffectNode(i3k_db_common.engine.maxEffectLimit[EPP_3]);

	g_i3k_game_logic = i3k_game_logic.new();
	--g_i3k_game_logic = i3k_demo.new();
	--g_i3k_game_logic = i3k_model_checker.new();

	i3k_set_short_cut_type(shortcutItemType)
	i3k_update_msdk()
	g_i3k_game_logic:Create();

	i3k_load_cfg()
	return 1;
end

--functions counter begin
local bProfEnable = false
local profCounters = {}
local profNames = {}
local profTime = -1
local profInterval = 1.0 -- -1: perframe

local function profHook (event)
	if event == "call" then
		local f = debug.getinfo(2, "f").func
		if profCounters[f] == nil then -- first time `f' is called?
			profCounters[f] = 1
			profNames[f] = debug.getinfo(2, "Sn")
		else -- only increment the counter
			profCounters[f] = profCounters[f] + 1
		end
	elseif event == "return" then
		--TODO calc time
	end
end
local function profGetName (func)
	local n = profNames[func]
	if n.what == "C" then
		return n.name
	end
	local loc = string.format("[%s]:%s", n.short_src, n.linedefined)
	if n.namewhat ~= "" then
		return string.format("%s (%s)", loc, n.name)
	else
		return string.format("%s", loc)
	end
end
local function profDump ()
	i3k_log("\n\n====prof dump begin====\n")
	local array = { }
	for func, count in pairs(profCounters) do
		table.insert(array, { name=func, count=count })
	end
	table.sort(array, function(a,b) return a.count > b.count end)
	for _, e in ipairs(array) do
		local name = profGetName(e.name)
		if name then
			i3k_log(name, e.count)
		end
	end
	i3k_log("\n====prof dump end====\n\n")
end
local function profStart()
	if bProfEnable then
		profCounters = {}
		profNames = {}
		debug.sethook(profHook, "cr")
	end
end
local function profEnd()
	if bProfEnable then
		debug.sethook()
		profDump()
	end
end
local function profUpdate(dTime)
	if bProfEnable then
		if profTime < 0 then
			profStart()
			profTime = 0
		else
			profTime = profTime + dTime
			if profInterval < 0 or profTime >= profInterval then
				profEnd()
				profStart()
				profTime = 0
			end
		end
	end
end
--functions counter end

local g_i3k_update_tick = 0
function i3k_get_update_tick()
	return g_i3k_update_tick
end
local frame_task_mgr = require("i3k_frame_task_mgr")

function i3k_do_gc()
	if g_i3k_gc_time_line > 15.0 then
		i3k_warn("i3k_do_gc500 !!!!!!!!!!!!!!!!!!!!!")
		frame_task_mgr.addNormalTask({
					taskType = "gc",
					run = function()
						--i3k_warn("gc start", i3k_integer(collectgarbage("count")));
						collectgarbage("step", 500);
						--i3k_warn("gc end  ", i3k_integer(collectgarbage("count")));
					end})

		g_i3k_gc_time_line = 0;
	end
end

local g_i3k_musicTimer = 0;
local g_i3k_musicStopped = true;
local g_i3k_musicStopTimer = 0;
local g_i3k_pre_clock = nil;


local function calc_delta_time()
	local curTime = os.clock();

	if not g_i3k_pre_clock then
		g_i3k_pre_clock = curTime;
	end
	local dTime = math.max(0, curTime - g_i3k_pre_clock);

	g_i3k_pre_clock = curTime;

	return dTime;
end

function i3k_game_update(dTime)
	if not g_i3k_is_create then
		return 0;
	end
	g_i3k_update_tick = g_i3k_update_tick + 1
	--在每帧开始的地方取帧间隔时间倍率，中间其他地方取可能会被中间的逻辑修改
	local frameTimeScale = g_i3k_game_handler:GetFrameIntervalScale()
	--local dTime = calc_delta_time();

	i3k_on_update_connect_state(1000 * dTime)
	--[[
	profUpdate(dTime)
	]]

	local now = i3k_game_update_time(dTime);
	if now > g_i3k_last_keepalive_time + 90 then
		i3k_game_send_str_cmd(i3k_sbean.keep_alive.new())
		g_i3k_last_keepalive_time = now;
	end

	g_i3k_musicTimer = g_i3k_musicTimer + dTime;
	g_i3k_musicStopTimer = g_i3k_musicStopTimer + dTime;
	if g_i3k_musicTimer > 2 then
		if not g_i3k_mmengine:IsBGMPlaying() then
			if not g_i3k_musicStopped then
				g_i3k_musicStopped = true;
				g_i3k_musicStopTimer = 0;
			end

			if g_i3k_musicStopTimer > 2 then
				g_i3k_mmengine:PlayBGM("", g_i3k_bgm_volume);
			end
		else
			g_i3k_musicStopped = false;
		end

		g_i3k_musicTimer = 0;
	end

	--[[
	g_i3k_gc_time_line = g_i3k_gc_time_line + dTime;
	if collectgarbage("step", 15) then
		g_i3k_gc_time_line = 0
	end
	if g_i3k_gc_time_line > 300.0 then
		i3k_do_gc()
	end
	]]

	if g_i3k_game_pause then
		return 0;
	end

	if g_i3k_game_logic and dTime < eMaxFrameTime then
		i3k_engine_update(dTime);
		if not i3k_is_role_logining() then
			if not g_i3k_game_context:getDebugOnUpdateUI() then
				i3k_coroutine_mgr_update(dTime);
				i3k_download_mgr_update(dTime);
				i3k_ui_mgr_update(dTime);
			end
		end

		frame_task_mgr.update(dTime)

		if not g_i3k_game_context:getDebugOnUpdateLogic() then
			g_i3k_game_logic:SetTimerScale(frameTimeScale)
			g_i3k_game_logic:OnUpdate(dTime);
		end
	end


	return 1;
end

function i3k_game_is_breakTasks(timeLimit, timeAcc, nTaskExec, nTaskLeft, frameInterval)
	local bBreak = false
	if timeLimit < timeAcc then
		bBreak = true
	end
	--i3k_warn("i3k_game_is_breakTasks(limit=" .. timeLimit .. ", timeUsed=" .. timeAcc .. ", nExec="
	--	.. nTaskExec .. ", nLeft=" .. nTaskLeft .. ", dTime=" .. frameInterval .. ") return " .. (bBreak and "true" or "false"))
	return bBreak and 1 or 0
end

function i3k_game_cleanup()
	if g_i3k_game_logic then
		g_i3k_game_logic:Release();
	end
	g_i3k_game_logic = nil;

	i3k_ui_mgr_cleanup();
	i3k_coroutine_mgr_cleanup();
	i3k_download_mgr_cleanUp();
	i3k_engine_cleanup();
	i3k_global_cleanup();
	g_i3k_is_create = false

	return 1;
end

function i3k_game_pause()
	if not g_i3k_game_pause then
		g_i3k_game_pause = true;
		g_i3k_download_mgr:setPowerSaveMode(false) -- 关闭省电模式
	end
end

function i3k_game_resume()
	if g_i3k_game_pause then
		g_i3k_game_pause = false;
	end
end

function i3k_game_is_pause()
	return g_i3k_game_pause;
end

function i3k_game_set_ignore_next_pause_resume_state(state)
	g_ignore_next_pause_resume = state
end

function i3k_game_on_pause()
	if g_ignore_next_pause_resume then
		return
	end
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_game_on_pause")
	i3k_game_network_disconnect()
end

function i3k_game_on_resume()
	if g_ignore_next_pause_resume then
		g_ignore_next_pause_resume = false
		return
	end
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_game_on_resume")
	i3k_game_network_reset()
	i3k_on_connection_closed()
end

function i3k_game_reset_time(time)
	g_i3k_time = time;
end

function i3k_game_update_time(dtime)
	g_i3k_time = g_i3k_time + dtime/g_i3k_frame_interval_scale

	return g_i3k_time;
end

function i3k_game_get_time()
	return math.modf(g_i3k_time);
end

function i3k_game_is_dev_mode()
	return g_i3k_dev_mode;
end

function i3k_game_set_debug_level(lvl)
	g_i3k_debug_level = lvl;
end

function i3k_game_clear_busy()
end

function i3k_get_server_list()
	if i3k_game_get_os_type() ~= eOS_TYPE_WIN32 then
		i3k_update_server_list()
	end
	return g_i3k_server_list
end

function i3k_get_server_group()
	if i3k_game_get_os_type() ~= eOS_TYPE_WIN32 then
		i3k_update_server_list()
	end
	return g_i3k_server_group
end

function i3k_update_server_list_from_netwrok()
	if i3k_game_get_os_type() ~= eOS_TYPE_WIN32 then
		i3k_update_server_list()
	end
end

function i3k_get_recommend_server_list(serverList)
	local recList = {}
		for i,v in ipairs(serverList) do
			local state = v.state
		local _, _, recommedState = i3k_get_split_server_state(state)
		if recommedState == 1 then --推荐
				table.insert(recList, v)
		end
	end
	return recList
end

function i3k_get_new_server_list(serverList)
	local newList = {}
		for i,v in ipairs(serverList) do
		local state = v.state
		local _, new = i3k_get_split_server_state(state)
		if new == 1 then --新服
			table.insert(newList, v)
		end
	end
	return newList
end

function i3k_get_recent_server_info(recentServerList)
	local serverList = i3k_get_server_list()
	if not next(serverList) then
		return nil
	end
	local serverInfo
	for i, e in ipairs(recentServerList) do
		for m, n in pairs(serverList) do
			if n.serverId == e then
				serverInfo = n
				break
			end
		end
		if serverInfo then
			break
		end
	end
	local recommendList = i3k_get_recommend_server_list(serverList)
	local newList = i3k_get_new_server_list(serverList)
	local rnd
	if #recommendList > 0 then
		rnd = i3k_engine_get_rnd_u(1, #recommendList)
		--i3k_log("The num is:"..rnd)
	end
	return serverInfo or (rnd and recommendList[rnd] or newList[#newList] or serverList[#serverList])
end

function i3k_get_recent_server_data()
	local cfg = g_i3k_game_context:GetUserCfg();
	local recentServerList = cfg:GetRecentServerList()
	local recentServerData = {}
	local serverList = g_i3k_server_list
	for i, e in ipairs(recentServerList) do
		for k, v in ipairs(serverList) do
			if e == v.serverId then
				table.insert(recentServerData, v)
			end
		end
	end
	return recentServerData
end

function i3k_get_announcement()
	if g_i3k_os_type == eOS_TYPE_WIN32 then
		local announcement = i3k_announcement.new()
		return announcement:Load()
	else
		return g_i3k_game_handler:GetAnnouncement()
	end
end

function i3k_get_announcement_content(index)
	local text = i3k_get_announcement()
	local content = string.split(text, "@@@")
	return content[index] or ""
end

local function insertSkinInfo(skin, skinid, heroguid, partid, k)
	local scfg = i3k_db_skins[skinid];
	if scfg then
		local tmpskin = {
			path = scfg.path,
			name = string.format("ui_hero_skin_%s_%d_%d", heroguid, partid, k),
			effectID = scfg.effectID,
		};
		table.insert(skin[partid], tmpskin);
	end
end

function SkinByFashionID(fashionID, data, hero, usefashion, isEffectFashion)--isEffectFashion 是时装界面和购买时装界面用来显示不同模型的
	local cfg = i3k_db_fashion_dress[fashionID]
	local cfgReflect = cfg.fashionReflect
	if isEffectFashion and cfg.showModleId then
		cfgReflect = cfg.showModleId
	end
	for _, v in pairs(cfgReflect) do
		local argsname = "skin"..hero._id..hero._gender
		local skincfg = i3k_db_fashion_dress_skin[v][argsname]
		local partID = i3k_db_fashion_dress_skin[v].partid
		usefashion[partID] = {}
		for k1, v1 in ipairs(skincfg) do
			local scfg = i3k_db_skins[v1]
			local name = string.format("hero_Fashionskin_%s_%d_%d_%d_%d", hero._guid, data[cfg.fashionType], cfg.fashionType,partID, k1);
			local info = {name = name,path = scfg.path,effectID = scfg.effectID}
			table.insert(usefashion[partID], info)
		end
	end
end

local function get_hero_skin_info(hero, isEffectFashion)
	local defaultSkin = { [eFashion_Face] = { }, [eFashion_Hair] = { }, [eFashion_Body] = { }, [eFashion_Weapon] = { }, [eEquipFlying] = { }}

	local rcfgs = {{resid = hero._face, eID = eFashion_Face}, {resid = hero._hair, eID = eFashion_Hair}}
	for _, v in ipairs(rcfgs) do
		local rcfg = g_i3k_db.i3k_db_fashion_res[v.resid];
		if rcfg then
			insertSkinInfo(defaultSkin, rcfg.skinID, hero._guid, v.eID, 1)
		end
	end

	local rcfgs = {{dbfunc = g_i3k_db.i3k_db_get_general_fashion_body_res, eID = eFashion_Body}, {dbfunc = g_i3k_db.i3k_db_get_general_fashion_weapon_res, eID = eFashion_Weapon}, {dbfunc = g_i3k_db.i3k_db_get_general_fashion_weapon_res, eID = eEquipFlying}}
	for _, info in ipairs(rcfgs) do
		local rcfg = info.dbfunc(hero._fashion)
		if rcfg then
			for k, v in ipairs(rcfg) do
				insertSkinInfo(defaultSkin, v, hero._guid, info.eID, k)
			end
		end
	end

	local usefashion = {}
	for k, v in pairs(hero._Usefashion) do
		if not hero._TestfashionID[k] then
			for k1,v1 in pairs(v.dressInfo) do
				usefashion[k1] = {}
				for k2,v2 in pairs(v1) do
					local name = "ui_"..v2.name
					local info = {name = name,path = v2.path,effectID = v2.effectID}
					table.insert(usefashion[k1], info)
				end
			end
		end
	end


	if hero._cacheFashionData.valid then
		for k,v in pairs(hero._cacheFashionData.fashionID) do
			SkinByFashionID(v, hero._cacheFashionData.fashionID, hero, usefashion, isEffectFashion)
		end
	end

	for k, v in pairs(hero._TestfashionID) do
		SkinByFashionID(v, hero._TestfashionID, hero, usefashion, isEffectFashion)
	end


	return {defaultSkin = defaultSkin, usefashion = usefashion}
end

local function hero_set_effect(entity, effectid, heroguid, partid, linkEffectFunc, arg1, arg2)--arg1和arg2参数为true表示添加静态特效
	if effectid == 0 then
		return -1
	end
	local cfg = i3k_db_effects[effectid]
	if cfg == nil then
		return -1
	end
	if cfg.hs == '' or cfg.hs == 'default' then
		return linkEffectFunc(entity, cfg.path, string.format("ui_hero_equip_%s_effect_%d_%d", heroguid, partid, effectid), "", "", 0.0, cfg.radius, arg1, arg2)
	else
		return linkEffectFunc(entity, cfg.path, string.format("ui_hero_equip_%s_effect_%d_%d", heroguid, partid, effectid), cfg.hs, "", 0.0, cfg.radius, arg1, arg2)
	end
end

local function hero_set_skin(entity, heroguid, skin, partid, attachSkinFunc, linkEffectFunc)
	if not skin then
		return
	end
	for k, v in ipairs(skin) do
		attachSkinFunc(entity, v.path, v.name)
		if v.effectID and #v.effectID ~= 0 then
			for k1,v1 in pairs(v.effectID) do
				hero_set_effect(entity, v1, heroguid, partid, linkEffectFunc)
			end
		end
	end
end

--武魂相关
function hero_attach_weapon_Soul(id, node, showID)
	local martialSoul = i3k_db_martial_soul_display[showID];
	if martialSoul then
		local modelID = i3k_engine_check_is_use_stock_model(martialSoul.uiModelID);
		if modelID then
			local cfg = i3k_db_models[modelID]
			if cfg and node then
				local Link = i3k_db_martial_soul_cfg;
				local hosterLink = Link.hosterLink[id];
				if cfg.path then
					node:linkChild(cfg.path, string.format("hero_soul_%s_effect_%d", id, martialSoul.modelID), hosterLink, Link.sprLink, 0.0, cfg.scale);
				end
			end
		end
	end
end

function i3k_hero_set_skin(entity, hero, equipInfo, armor, isShowFashion, attachSkinFunc, linkEffectFunc, isLink, flyingWearID, isShowFlyClothes)
	local skininfo = get_hero_skin_info(hero, entity.isEffectFashion);
	local defaultSkin = skininfo.defaultSkin
	local usefashion = skininfo.usefashion
	local heirloom = g_i3k_game_context:getHeirloomData()
	local showFashionWeap = g_i3k_game_context:GetIsShowWeapon();
	local lvl = g_i3k_game_context:GetLevel()
	local Link = true;
	local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(hero._soaringDisplay)
	if isLink then
		Link = false;
	end
	if lvl >= i3k_db_martial_soul_cfg.openLvl and Link then
		local isPassUI = false;
		if g_i3k_ui_mgr:GetUI(eUIID_Under_Wear) or g_i3k_ui_mgr:GetUI(eUIID_Under_Wear_update) or g_i3k_ui_mgr:GetUI(eUIID_Under_Wear_upStage) or g_i3k_ui_mgr:GetUI(eUIID_Under_Wear_Rune) then
			isPassUI = true;
		end
		if not isPassUI then
			local showID = g_i3k_game_context:GetWeaponSoulCurShow(); 
			local isHide = g_i3k_game_context:GetWeaponSoulCurHide();
			if (showID and showID ~= 0 and hero._curWeaponSoul and isHide) or entity.martialSkinID then
				hero_attach_weapon_Soul(g_i3k_game_context:GetRoleType(), entity, entity.martialSkinID or showID)
			end
		end
	end
	local facehair = {eFashion_Face, eFashion_Hair}
	for _, id in ipairs(facehair) do
		local skin = defaultSkin[id];
		if usefashion[id] and skinDisplay == g_WEAR_FASHION_SHOW_TYPE then
			skin = usefashion[id]
		end
		hero_set_skin(entity, hero._guid, skin, id, attachSkinFunc, linkEffectFunc)
	end
	for k, v in pairs(i3k_db_equip_part) do
		local equip = hero._equips[v.partId];
		if v.partId == eEquipWeapon or v.partId == eEquipFlying then
			if (hero and hero.GetIsBeingHomeLandEquip) and hero:GetIsBeingHomeLandEquip() then
				local scfg = i3k_db_skins[hero:GetHomeLandEquipSkinID()];
				if scfg then
					hero_set_skin(entity, hero._guid, {{ path = scfg.path, name = hero._guid..scfg.id }}, v.partId, attachSkinFunc, linkEffectFunc)
				end
			elseif (usefashion[g_FashionType_Weapon] and showFashionWeap) or hero._TestfashionID[g_FashionType_Weapon] then
				hero_set_skin(entity, hero._guid, usefashion[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
			elseif heirloom.isOpen == 1 and g_i3k_game_context:getCurWeaponShowType() == g_HEIRHOOM_SHOW_TYPE then
				local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID()];
					if scfg then
						hero_set_skin(entity, hero._guid, {{ path = scfg.path, name = hero._guid..scfg.id }}, v.partId, attachSkinFunc, linkEffectFunc)
					end
			else
				if v.partId == eEquipFlying and weaponDisplay == g_FLYING_SHOW_TYPE then
					if equip and equip._model.valid then
						hero_attach_flying_equip(entity, equip._model.models)
				else
					hero_set_skin(entity, hero._guid, defaultSkin[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
					end
				elseif v.partId == eEquipWeapon and weaponDisplay ~= g_FLYING_SHOW_TYPE then
					if equip and equip._skin.valid then
						hero_set_skin(entity, hero._guid, equip._skin.skins, v.partId, attachSkinFunc, linkEffectFunc)
					else
						hero_set_skin(entity, hero._guid, defaultSkin[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
					end
				end
			end
		elseif flyingWearID then
			if v.partId == eEquipFlyClothes then
				local E = require("logic/battle/i3k_equip");
				local flyEquip = E.i3k_equip.new();
				flyEquip:Create(hero, flyingWearID, hero._gender) 
				hero_set_skin(entity, hero._guid, flyEquip._skin.skins, eEquipClothes, attachSkinFunc, linkEffectFunc)
			end
		elseif v.partId == eEquipClothes or v.partId == eEquipFlyClothes then 
			if (usefashion[v.partId] and skinDisplay == g_WEAR_FASHION_SHOW_TYPE and v.partId == eEquipClothes) or hero._TestfashionID[g_FashionType_Dress] then
				hero_set_skin(entity, hero._guid, usefashion[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
			elseif v.partId == eEquipClothes and skinDisplay == g_WEAR_NORMAL_SHOW_TYPE  then
				if equip and equip._skin.valid then
					hero_set_skin(entity, hero._guid, equip._skin.skins, v.partId, attachSkinFunc, linkEffectFunc)
			else
					hero_set_skin(entity, hero._guid, defaultSkin[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
				end
			elseif skinDisplay == g_WEAR_FLYING_SHOW_TYPE and v.partId == eEquipFlyClothes then
				if equip and equip._skin.valid then
					hero_set_skin(entity, hero._guid, equip._skin.skins, v.partId, attachSkinFunc, linkEffectFunc)
				else
					hero_set_skin(entity, hero._guid, defaultSkin[eEquipClothes], v.partId, attachSkinFunc, linkEffectFunc)
				end
			end
		elseif v.partId == eEquipFlyClothes and  isShowFlyClothes then
			hero_set_skin(entity, hero._guid, defaultSkin[v.partId], v.partId, attachSkinFunc, linkEffectFunc)
		end
	end

	if equipInfo and not hero:GetIsBeingHomeLandEquip() and weaponDisplay ~= g_FLYING_SHOW_TYPE and i3k_game_get_map_type() ~= g_BIOGIAPHY_CAREER then
		for k, v in pairs(equipInfo) do
			local equipId = hero._equips[k] and hero._equips[k].equipId or nil
			if not equipId then 
				equipId = v.equip and v.equip.equip_id
			end 
			local effectids = g_i3k_db.i3k_db_get_equip_effect_id_show(equipId, hero._id, k, v.eqGrowLvl, v.eqEvoLvl, v.effectInfo)
			if effectids then
				for effectID, v2 in pairs(effectids) do
					hero_set_effect(entity, effectID, hero._guid, k, linkEffectFunc)
				end
			end
		end
	end
	if i3k_game_get_map_type() == g_BIOGIAPHY_CAREER then
		local careerData = g_i3k_game_context:getBiographyCareerInfo()
		if careerData and careerData[hero._id] then
			local taskId = careerData[hero._id].taskId
			if taskId > 0 then
				local effectids = i3k_db_wzClassLand_prop[i3k_db_wzClassLand_task[hero._id][taskId].changeClassID].weaponEffect
				if next(effectids) then
					for k, v in ipairs(effectids) do
						hero_set_effect(entity, v, hero._guid, 1, linkEffectFunc)
					end
				end
			end
		end
	end
	if hero._soaringDisplay.footEffect ~= 0 then
		local effectid = 0
		if hero._bwType == 1 then
			effectid = i3k_db_feet_effect[hero._soaringDisplay.footEffect].justiceEffect
		else
			effectid = i3k_db_feet_effect[hero._soaringDisplay.footEffect].evilEffect
		end
		hero_change_foot_effect(entity, effectid)
	end
	if armor == false then  --如果armor设为false 不挂载特效
		return true
	elseif armor == true then	--如果是true 设为nil不影响下面的  如果是表 则不处理
		armor = nil
	end

	local armorData = armor or (hero._armor.id~=0 and hero._armor)
	if armorData then
		local stage = armorData.stage
		local effectid = i3k_db_under_wear_upStage[armorData.id][stage].specialEffId
		for _,v in ipairs(effectid) do
			local effect = hero_set_effect(entity, v, armorData.id, stage, linkEffectFunc)
			if entity.isSprite3d and effect~=-1 then
				if not entity.effectId then
					entity.effectId = {}
				end
				table.insert(entity.effectId, effect)
			end
		end
	end
	return true
end

local function link_hero_effect(entity, path, name, hs, cs, offsetY, scale)
	local id = entity:LinkHosterChild(path, name, hs, cs, offsetY, scale)
	if id > 0 then
		entity:LinkChildPlay(id, -1, true)
	end

	return id
end

local function create_hero_scene_entity(entity_name)
	local hero = i3k_game_get_player_hero()
	local fashion = hero._fashion
	if fashion then
		local mcfg = i3k_db_models[fashion.modelID];
		if mcfg then
			local entity = Engine.MEntity(entity_name);
			if entity:CreateHosterModel(mcfg.path, entity_name) then
				entity:SetScale(mcfg.scale);
				local equipInfo = g_i3k_game_context:GetWearEquips()
				local hidefashion = g_i3k_game_context:GetIsShwoFashion()
				if i3k_hero_set_skin(entity, hero, equipInfo, nil, hidefashion, entity.AttachHosterSkin, link_hero_effect, true) then
					entity:EnterWorld(false);
					return entity
				end 
			end
		end
	end
	return nil
end

local function create_a_scene_entity(entity_name, entity_type)
	if entity_type ~= 1 then
		error("now entity_type must be 1")
	end
	return create_hero_scene_entity(entity_name)
end

local function releaseSceneEntitys()
	if g_i3k_SceneEntitys then
		for _, v in ipairs(g_i3k_SceneEntitys) do
			v:Release()
		end
		g_i3k_SceneEntitys = nil
	end
end

local function createSceneEntitys(replaceModel)
	releaseSceneEntitys()
	if replaceModel ~= nil and next(replaceModel) ~= nil then
		g_i3k_SceneEntitys = {}
		for k, v in pairs(replaceModel) do
			local entity = create_a_scene_entity(k, v)
			if entity then
				table.insert(g_i3k_SceneEntitys, entity)
			end
		end
	end
end

--breakType: 0 不显示上黑边和跳过按钮 1显示上黑边和跳过按钮 2 只显示跳过按钮
function i3k_game_play_scene_ani(flashId, callback)
	if i3k_db_sceneFlash[flashId] then
		g_i3k_scene_ani_state = true
		g_i3k_ui_mgr:HideNormalUI()
		g_i3k_game_context:DetachWeaponSoul()
		local breakType = i3k_db_sceneFlash[flashId].showType
		g_i3k_ui_mgr:OpenUI(eUIID_BreakSceneAni)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BreakSceneAni, "setBreakType", breakType)

		createSceneEntitys(i3k_db_sceneFlash[flashId].replaceModel)

		local path = i3k_db_sceneFlash[flashId].path
		if g_i3k_mmengine:EnableFog(false) then
			g_i3k_enableFogBeforeScene = true
		end

		if i3k_db_sceneFlash[flashId].stopBGM == 1 then
			i3k_game_stop_bgm()
			g_i3k_StopBGMForScene = true
		end

		g_i3k_mmengine:StopSFX(-1, false)
		g_i3k_mmengine:SetDistanceClipFactor(64)
		g_i3k_mmengine:PlaySceneAni(path)
		g_i3k_game_context:setPlaySceneAnisCallback(callback)
	end
end

function i3k_game_stop_scene_ani()
	g_i3k_mmengine:StopSceneAni()
	i3k_game_scene_ani_stopped()
end

function i3k_game_scene_ani_stopped()
	g_i3k_scene_ani_state = false
	if g_i3k_enableFogBeforeScene then
		g_i3k_mmengine:EnableFog(true)
		g_i3k_enableFogBeforeScene = nil
	end
	releaseSceneEntitys()
	i3k_game_resume()
	g_i3k_mmengine:SetDistanceClipFactor(8);
	g_i3k_ui_mgr:ShowNormalUI()
	g_i3k_ui_mgr:CloseUI(eUIID_BreakSceneAni)
	local world = i3k_game_get_world()
	if world and g_i3k_StopBGMForScene then
		world:PlayBGM()
	end
	g_i3k_StopBGMForScene = nil
	g_i3k_game_context:callPlaySceneAnisCallback()
end

function i3k_game_get_scene_ani_is_playing()
	return g_i3k_scene_ani_state
end


local versionTbl =
{
	[15035]	= 15050,	--渠道测试包
	[15051] = 15050,
	[15052] = 15050,	--android小包
	[15053] = 15050,	--android大包
	[15054] = 15050,	--Ob2, iOS
	[15055] = 15050,	--Ob2, 安卓大包
	[15056] = 15050,	--Ob2, 安卓小包
	[15057] = 15050,	--Ob2, iOS for iOS8
	[15058] = 15050,	--Ob2, iOS for iOS8
	[15059] = 15050,	--占坑
	[15060] = 15050,	--占坑
	[15061] = 15050,	--占坑
	[15062] = 15050,	--占坑
	[15063] = 15050,	--占坑
	[15064] = 15050,	--占坑
	[15065] = 15050,	--占坑
	[15066] = 15050,	--占坑
	[15067] = 15050,	--占坑
	[15068] = 15050,	--占坑
	[15069] = 15050,	--占坑
	[15070] = 15050,	--占坑
	[15071] = 15050,	--占坑
	[15072] = 15050,	--占坑
	[15073] = 15050,	--占坑
	[15074] = 15050,	--占坑
	[15075] = 15050,	--占坑
	[15076] = 15050,	--占坑
	[15077] = 15050,	--占坑
	[15078] = 15050,	--占坑
	[15079] = 15050,	--占坑
	[15080] = 15050,	--占坑
	[15081] = 15050,	--占坑
	[15082] = 15050,	--占坑
	[15083] = 15050,	--占坑
	[15084] = 15050,	--占坑
	[15085] = 15050,	--占坑
	[15086] = 15050,	--占坑
	[15087] = 15050,	--占坑
	[15088] = 15050,	--占坑
	[15089] = 15050,	--占坑
	[15090] = 15050,	--占坑
	[15091] = 15050,	--占坑
}

function i3k_game_get_client_version()
	if g_i3k_os_type == eOS_TYPE_WIN32 then
		return 0
	else
		local ver = g_i3k_game_handler:GetVersion()
		return versionTbl[ver] or ver
	end
end

function i3k_game_get_client_res_version()
	return g_i3k_os_type == eOS_TYPE_WIN32 and 0 or i3k_db_cfg_res_version.resourceVersion
end

function i3k_game_get_username()
	local userName = g_i3k_game_handler:GetLoginUserName()
	if userName == "" then
		local cfg = g_i3k_game_context:GetUserCfg()
		userName = cfg:GetUserName()
	end
	return userName
end

function i3k_game_get_channel_name()
	local cfg = g_i3k_game_context:GetUserCfg()
	local channelName = cfg:GetChannelName()
	if channelName == "" then
		channelName = "2001"
	end
	return g_i3k_os_type == eOS_TYPE_WIN32 and channelName or g_i3k_game_handler:GetChannelName()
end

function i3k_get_userkey()
	return g_i3k_os_type == eOS_TYPE_WIN32 and "" or g_i3k_game_handler:GetLoginUserSID()
end

function i3k_get_msdk()
	return g_i3k_msdk
end

function i3k_report_role_info()
	if g_i3k_os_type ~= eOS_TYPE_WIN32 then
	end
end

function i3k_do_pay()
	if g_i3k_os_type ~= eOS_TYPE_WIN32 then
	end
end

function i3k_game_data_eye_valid()
	return false --g_i3k_os_type ~= eOS_TYPE_WIN32;
end

function i3k_game_set_invite_code(keyCode)
	g_i3k_invite_code = keyCode
end





function i3k_game_set_server_id(id)
	g_i3k_server_id = id
end

function i3k_game_get_server_id()
	return g_i3k_server_id
end

function i3k_game_set_login_server_id(id)
	g_i3k_login_data.server_id = id
end

function i3k_game_get_login_server_id()
	return g_i3k_login_data.server_id
end

function i3k_game_get_server_name(serverId)
	local serverList = g_i3k_server_list
	for i, e in ipairs(serverList) do
		if e.serverId == serverId then
			return e.name
		end
	end
	return "unknow"
end

-- 开服天数
function i3k_game_set_server_open_day(day)
	g_i3k_server_open_day = day
end

function i3k_game_get_server_open_day()
	return g_i3k_server_open_day
end

-- 获取服务器已经开启了多少天
function i3k_game_get_server_opened_days()
	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time())
	return nowDay - openDay + 1
end
-- 设置开服时间
function i3k_game_set_server_open_time(time)
	g_i3k_server_open_time = time
end
function i3k_game_get_server_open_time()
	return g_i3k_server_open_time
end

function i3k_game_get_zone_id_from_roleID(roleID)
	return i3k_integer(roleID / 1000000)
end

function i3k_game_get_server_group_id()
	return i3k_integer(i3k_game_get_login_server_id() / 1000)
end

function i3k_game_get_server_name_from_role_id(roleID)
	local zoneID = i3k_game_get_zone_id_from_roleID(roleID)
	local serverGroupID = i3k_game_get_server_group_id()
	local serverID = serverGroupID * 1000 + zoneID
	return i3k_game_get_server_name(serverID)
end

function i3k_game_get_logic()
	return g_i3k_game_logic;
end

function i3k_game_get_world()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetWorld();
	end
	return nil;
end

-- 获取当前野外地图的PK类型
function i3k_game_get_field_map_pk_type()
	if g_i3k_game_logic then
		local world = g_i3k_game_logic:GetWorld()
		if world then
			local fieldID = world._cfg.id
			return i3k_db_field_map[fieldID] and i3k_db_field_map[fieldID].worldMapType or nil
		end
	end
	return nil
end

function i3k_game_get_player()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetPlayer();
	end
	return nil;
end

function i3k_game_get_player_hero()
	if g_i3k_game_logic then
		local player = g_i3k_game_logic:GetPlayer();
		if player then
			return player:GetHero();
		end
	end
	return nil;
end

function i3k_game_get_player_real_hero()
	if g_i3k_game_logic then
		local player = g_i3k_game_logic:GetPlayer();
		if player then
			return player:GetRealHero();
		end
	end
	return nil;
end

--返回指定id的出战佣兵实例
function i3k_game_get_mercenary_entity(id)
	local player = g_i3k_game_logic:GetPlayer()
	for k = 1, player:GetMercenaryCount() do
		local mercenary = player:GetMercenary(k);
		if mercenary._cfg.id == id then
			return mercenary
		end
	end
	return nil
end

function i3k_game_get_map_type()
	if g_i3k_game_logic then
		local world = g_i3k_game_logic:GetWorld()
		if world then
			return world._mapType
		end
	end
	return nil
end

function i3k_game_get_select_entity()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetSelectEntity()
	end
	return nil
end

function i3k_game_get_role_id()
	return 1;
end

function i3k_game_get_exe_path()
	return g_i3k_exe_path;
end

function i3k_game_get_os_type()
	return g_i3k_os_type;
end

function i3k_game_share_SnapShotWithQRCode(share_withUI)
	local share_qrCodeSize = 150
	local share_offsetX = 0.04
	local share_offsetY = 0.05
	local share_taskID
	if i3k_game_get_os_type() == eOS_TYPE_IOS then
		share_taskID = "5"
	else
		if i3k_get_gameAppID() == "1920005" then
			share_taskID = "1"
		else
			share_taskID = "3"
		end
	end
	local share_qrCodeColor = 0X00000000
	local share_isShowBg = true
	--local share_withUI = false
	--local qr_parameter = {qrCodeSize = share_qrCodeSize, offsetX = share_offsetX, offsetY = share_offsetY, taskID = share_taskID, qrCodeColor = share_qrCodeColor, isShowBg = share_isShowBg, withUI = share_withUI}
	g_i3k_game_handler:ShareScreenSnapshotWithQRCode(share_taskID, share_qrCodeSize, share_offsetX, share_offsetY, share_qrCodeColor, share_isShowBg, share_withUI)
end

function i3k_game_unload_script(name, script)
	local _script	= script or name;
	_G[name]			= nil;
	package.loaded[_script]	= nil;
	--collectgarbage("collect");
end

function i3k_game_reload_script(name, script)
	local _name		= name;
	local _script	= script or name;

	local oldmodule = _G[_name];
	if oldmodule then
		for k, v in pairs(oldmodule) do
			oldmodule[k] = nil;
		end
		_G[_name]			= nil;
	end
	package.loaded[_script]	= nil;

	require(_script);
	local newmodule = _G[_name];
	if newmodule then
		for k, v in pairs(newmodule) do
			oldmodule[k] = v;
		end
		oldmodule._M = oldmodule;

		_G[_name]			= oldmodule;
	end
	package.loaded[_script]	= oldmodule;

	collectgarbage("collect");
end

function i3k_game_register_entity(guid, entity)
	--i3k_warn(string.format("un reg %s", guid))
	g_i3k_entity_map[guid] = entity;
end

function i3k_game_register_entity_RoleID(roleID, guid)
	g_i3k_entity_map_roleID[tostring(roleID)] = guid
end

function i3k_game_get_all_entity_RoleID()
	return g_i3k_entity_map_roleID;
end

function i3k_game_get_all_entity()
	return g_i3k_entity_map;
end

function i3k_game_get_systime()
	return os.time();
end

function i3k_game_get_logic_time()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetTickTime();
	end

	return 0;
end

function i3k_game_get_logic_tick()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetLogicTick();
	end

	return 0;
end

function i3k_game_set_logic_tick(ticks)
	if g_i3k_game_logic then
		g_i3k_game_logic:SetLogicTick(ticks);
	end
end

function i3k_game_get_logic_tick_line()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetTickLine();
	end

	return 0;
end

function i3k_game_set_logic_tick_line(tickLine)
	if g_i3k_game_logic then
		g_i3k_game_logic:SetTickLine(tickLine);

		if g_i3k_game_context:GetMapEnter() then
			local cmd = i3k_sbean.sync_server_ping.new();
			cmd.ping = i3k_game_get_server_ping();

			i3k_game_send_str_cmd(cmd);
		end
	end
end

function i3k_game_get_delta_tick()
	if g_i3k_game_logic then
		return g_i3k_game_logic:GetDeltaTick();
	end

	return 0;
end

function i3k_game_set_delta_tick(tick)
	if g_i3k_game_logic then
		g_i3k_game_logic:SetDeltaTick(tick);
	end
end

local l_i3k_server_ping = 0;
function i3k_game_set_server_ping(ping)
	l_i3k_server_ping = ping;
end

function i3k_game_get_server_ping()
	return l_i3k_server_ping;
end

function i3k_game_on_entity_guid(roleID)
	local guid = g_i3k_entity_map_roleID[tostring(roleID)];
	if guid then
		return guid;
	else
		return false;
	end
end

-- 攻击事件回调
function i3k_game_on_attack_action(guid, id)
	local entity = g_i3k_entity_map[guid];
	if entity then
		entity:OnAttackAction(id);
	end
end

function i3k_game_on_stop_action(guid, action)
	local entity = g_i3k_entity_map[guid];
	if entity then
		entity:OnStopAction(action);
	end
end

function i3k_game_on_stop_child(guid, id)
	local entity = g_i3k_entity_map[guid];
	if entity then
		entity:OnStopChild(id);
	end
end

function i3k_game_on_entity_async_loaded(guid)
	--[[
	frame_task_mgr.addNormalTask({
					taskType = "async_entity",
					run = function()
						local entity = g_i3k_entity_map[guid];
						if entity then
							entity:OnAsyncLoaded();
						end
					end})
	]]
	local entity = g_i3k_entity_map[guid];
	if entity then
		entity:OnAsyncLoaded();
	end
end

function i3k_game_on_entity_async_model_changed(guid)
	local entity = g_i3k_entity_map[guid];
	if entity then
		entity:OnAsyncModelChanged();
	end
end

-- 消息回调
function i3k_game_on_key_down(handled, down, key)
	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic and (handled == 0) then
		if down == 1 then
			return g_i3k_game_logic:OnKeyDown(handled, key);
		else
			return g_i3k_game_logic:OnKeyUp(handled, key);
		end
	end

	return 0;
end

function i3k_game_on_touch_down(handled, x, y)
	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic then
		return g_i3k_game_logic:OnTouchDown(handled, x, y);
	end

	return 0;
end

function i3k_game_on_touch_up(handled, x, y)
	if g_i3k_download_mgr then
		g_i3k_download_mgr:clearAutoPowerSaveTimer()
	end

	if g_i3k_logic then
		if g_i3k_ui_mgr and g_i3k_ui_mgr:GetUI(eUIID_BattleTask) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "clearTaskGuideTimer")
		else
			g_i3k_logic:CloseTaskGuideUI()
		end
	end

	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic then
		return g_i3k_game_logic:OnTouchUp(handled, x, y);
	end

	return 0;
end

function i3k_game_on_drag(handled, touchDown, x, y)
	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic then
		return g_i3k_game_logic:OnDrag(handled, touchDown, x, y);
	end

	return 0;
end

function i3k_game_on_zoom(handled, delta)
	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic then
		return g_i3k_game_logic:OnZoom(handled, delta);
	end

	return 0;
end

function i3k_game_on_hit_obj(handled, guids)
	if g_i3k_game_pause then return 0; end

	local empty = true;

	local entities = { };
	for k, v in ipairs(guids) do
		local entity = g_i3k_entity_map[v];
		if entity then
			empty = false;
			table.insert(entities, entity);
		end
	end

	if g_i3k_game_logic and not empty then
		return g_i3k_game_logic:OnHitObject(handled, entities);
	end

	return 0;
end

function i3k_game_on_hit_ground(handled, x, y, z)
	if g_i3k_game_pause then return 0; end

	if g_i3k_game_logic then
		return g_i3k_game_logic:OnHitGround(handled, x, y, z);
	end

	return 0;
end

function i3k_game_play_bgm(file, volume)
	g_i3k_bgm_volume = volume * gAudio_BGMFalloff;

	g_i3k_mmengine:PlayBGM(file, g_i3k_bgm_volume);
end

function i3k_game_stop_bgm()
	g_i3k_mmengine:StopBGM(true);
end

function i3k_game_play_sound(path, volume, isClean)
	if path and not i3k_game_get_scene_ani_is_playing() then
		--g_i3k_mmengine:StopSFX(isClean or false)
		g_i3k_mmengine:PlaySFX(path, volume or 1)
	end
end

function i3k_load_cfg()
	g_i3k_user_cfg = i3k_usercfg.new()
	g_i3k_user_cfg:Load()
	g_i3k_user_cfg:SetSpecialActionPlay()
	--初始化音效相关
	local bgVol, effVol = g_i3k_user_cfg:GetVolume();
	g_i3k_mmengine:SetVolume(gAudioType_BGM, (bgVol / 100) * gAudio_BGMFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_Action, (effVol/100) * gAudio_ActionFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_Effect, (effVol/100) * gAudio_EffectFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_UI, (effVol/100) * gAudio_UIFalloff);

	-- 触屏操作
	--g_i3k_game_handler:EnableObjHitTest(true, true)

	-- 初始化特效过滤等级相关
	local LvlTX = g_i3k_user_cfg:GetFilterTXLvl()
	if not LvlTX then
		LvlTX = LvlTX or i3k_get_txLvl_form_deviceInfo()
		g_i3k_user_cfg:SetFilterTXLvl(LvlTX)
	end
	g_i3k_game_context:SetEffectFilter(LvlTX)
	-- 初始化游戏的时候，调用此函数
	g_i3k_game_context:initFPSLimitValue()
	g_i3k_game_context:initAutoFightRadius()
	g_i3k_game_context:InitCameraShake()
end

function i3k_get_load_cfg()
	if g_i3k_user_cfg == nil then
		i3k_load_cfg()
	end
	return g_i3k_user_cfg
end

function i3k_get_net_log()
	if g_i3k_net_log == nil then
		g_i3k_net_log = i3k_net_log.new()
	end
	return g_i3k_net_log
end


function i3k_update_server_list()
	local serverList = {}
	local serverGoup = {}
	local serverCount = g_i3k_game_handler:GetServerListCount()
	--i3k_log("####android serverCount:"..serverCount)
	for i = 1, serverCount do
		local name = g_i3k_game_handler:GetServerName(i-1)
		local host = g_i3k_game_handler:GetServerAddr(i-1)
		local port = g_i3k_game_handler:GetServerPort(i-1)
		local state = g_i3k_game_handler:GetServerState(i-1)
		local group = g_i3k_game_handler:GetServerGroup(i-1)
		local serverId = g_i3k_game_handler:GetServerId(i-1)
		local addr = string.format("%s:%s", host, port)
		serverList[i] = {id = i, name = name, addr = addr, state = state, serverId = serverId}
		if not serverGoup[group] then
			serverGoup[group] = {}
			table.insert(serverGoup[group], {id = i, name = name, addr = addr, state = state, serverId = serverId})
		else
			table.insert(serverGoup[group], {id = i, name = name, addr = addr, state = state, serverId = serverId})
		end
	end
	g_i3k_server_list = serverList
	g_i3k_server_group = serverGoup
end

function i3k_update_msdk()
	if g_i3k_os_type ~= eOS_TYPE_WIN32 then
		local info = g_i3k_game_handler:GetDeviceInfo()
		i3k_log("msdk----:"..info)
		local list = string.split(info, "|")
		for i, e in pairs(list) do
			local s = string.split(e, "=")
			local k = s[1]
			local v = s[2]
			if k and v then
				if  k == "screenWidth" or k == "screenHeight" or k == "density" or k == "network" then
					local v = tonumber(v)
					if v and k ~= "density" then
						g_i3k_msdk[k] = math.floor(v)
					elseif v and k == "density" then
						g_i3k_msdk[k] = v
					end
				else
					g_i3k_msdk[k] = v
				end
			end
		end
		local UIUtil = require("ui/common/UIUtil")
		--if g_i3k_msdk.systemHardware == "iPhone10,3" or g_i3k_msdk.systemHardware == "iPhone10,6" then
		if g_i3k_ui_mgr:JudgeIsIphoneX() then
			UIUtil.isIphoneX = true
		else
			UIUtil.isIphoneX = false
		end
		
		-- 如果屏幕宽高比大，并且大于Android P版本，并且没有刘海的情况下
		if g_i3k_ui_mgr:JudgeIsIphoneX() and g_i3k_msdk.hasNotchAndroidP == 0 then
			UIUtil.isIphoneX = false
		end
	end
end

function i3k_get_gameAppID()
	return g_i3k_msdk.gameAppID
end


-- 安卓初始特效等级配置
local androidCfg = {
	{memoryNum = 8192, effectLvl = EPP_2},
	{memoryNum = 4096, effectLvl = EPP_1},
	{memoryNum = 2048, effectLvl = EPP_0},
}
function i3k_get_android_txLvl_form_deviceInfo(memory)
	for _, e in ipairs(androidCfg) do
		if memory >= e.memoryNum then
			return e.effectLvl
		end
	end
	return EPP_0
end

-- ios初始特效等级配置，注意这里的key并不是对应的手机型号，对应手机型号请参阅下面链接
-- https://stackoverflow.com/questions/46291920/ios-device-platform-string-internal-model-for-iphone-8-8-plus-and-iphone-x/46291942
local iosSystemSoftwareCfg = {
	["iPhone"] = {
		{versionNum = 11, effectLvl = EPP_2},
		{versionNum = 9, effectLvl = EPP_1},
		{versionNum = 7, effectLvl = EPP_0},
    },
	["iPad"] = {
		{versionNum = 6, effectLvl = EPP_2},
		{versionNum = 4, effectLvl = EPP_1},
		{versionNum = 2, effectLvl = EPP_0},
    }
}
function i3k_get_ios_txLvl_form_deviceInfo(systemSoftware)
	local matchingStr = string.split(systemSoftware, ",")
	local systemEdition = matchingStr[1]
	if matchingStr and systemEdition then
	    for findType, cfg in pairs(iosSystemSoftwareCfg) do
			local startIdx, endIdx = string.find(systemEdition, findType)
			if startIdx then
				local version = tonumber(string.sub(systemEdition, endIdx + 1, -1))
				if version then
					for _, e in ipairs(cfg) do
						if version >= e.versionNum then
							return e.effectLvl
						end
					end
				end
			end
	    end
	end

	return EPP_0
end
function i3k_get_txLvl_form_deviceInfo()
	if g_i3k_os_type == eOS_TYPE_WIN32 or g_i3k_os_type == eOS_TYPE_OTHER then
		local memory = tonumber(g_i3k_msdk.memory)
		local lvl = i3k_get_android_txLvl_form_deviceInfo(memory)
		return lvl
		else
		local lvl = i3k_get_ios_txLvl_form_deviceInfo(g_i3k_msdk.systemHardware)
		return lvl
		end
end

function i3k_open_url(url)
	local ver = g_i3k_game_handler:GetVersion() -- 更新界面的版本号
	if i3k_game_get_os_type() == eOS_TYPE_OTHER then
		if ver == 18099 or ver == 18089 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1835))
			return
	end
end


	if i3k_game_get_os_type() == eOS_TYPE_OTHER then
		g_ignore_next_pause_resume = true
	end
	g_i3k_game_handler:OpenUrl(url)
end

----------------------------------------------------------------------
function i3k_get_login_channel()
	return g_i3k_login_data.channel
end

function i3k_get_login_username()
	return g_i3k_login_data.uid
end

function i3k_get_login_unique_username()
	return g_i3k_login_data.channel .. "_" .. g_i3k_login_data.uid
end

function i3k_is_role_logined()
	return g_i3k_login_data.role_login_state == g_i3k_login_state.LOGINED
end

function i3k_is_role_logining()
	return g_i3k_login_data.role_login_state == g_i3k_login_state.LOGINING
end

function i3k_is_longtu_channel()
	return g_i3k_login_data.channel == "2001" or g_i3k_login_data.channel == "1002"
end
---------------------------------------------------------------------
function i3k_on_connection_open_success()
	g_i3k_ui_mgr:CloseUI(eUIID_Wait)
	g_i3k_net_state.connected = true
end

function i3k_on_connection_open_failed()
	g_i3k_net_state.state:notifyConnectOpenFailed()
	g_i3k_net_state.connected = false
	--[[if i3k_get_is_use_short_cut() then
		local logic = i3k_game_get_logic();
		i3k_set_short_cut_type(0)
		logic:OnShortCutToLogin()
	end--]]
end

function i3k_on_connection_closed()
	g_i3k_login_data.role_login_state = g_i3k_login_state.NOTLOGIN
	if g_i3k_net_state.connected then
		g_i3k_net_state.state:notifyConnectClosed()
	end
	g_i3k_net_state.connected = false
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePingInfoDisableStatus")
end

function i3k_on_connection_challenge_ok()
	i3k_do_user_login()
end

--登录认证成功
function i3k_on_authed_success()
	g_i3k_login_data.has_authed = true
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_on_authed_success")
	g_i3k_net_state.state:notifyAuthSuccess()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updatePingInfo", 5)
end

--账号登录成功
function i3k_on_user_login_ok()
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_on_user_login_ok")
	local logic = i3k_game_get_logic()
	if logic then
		g_i3k_game_handler:RoleBreakPoint("Game_User_Login", "")
		logic:OnLogin()
	end
end

function i3k_on_role_begin_login()
	g_i3k_game_context:Reset()
	g_i3k_game_context:StopMove()
	g_i3k_ui_mgr:CloseAllOpenedUI(eUIID_Wait)
	g_i3k_download_mgr:Clear()
	if g_i3k_coroutine_mgr then
		if not g_i3k_game_context:isOnSprog() then -- 新手关不能清掉协程
			g_i3k_coroutine_mgr:Release()
		end
	end
	g_i3k_login_data.role_login_state = g_i3k_login_state.LOGINING
end

--角色登录成功
function i3k_on_role_login_ok(newRole)
	g_i3k_login_data.role_login_state = g_i3k_login_state.LOGINED
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_on_role_login_ok")
	local logic = i3k_game_get_logic()
	if logic then
		logic:OnPlay()
	end
	if g_i3k_game_context then
		g_i3k_game_context:OnLogined(newRole)
	end
end

function i3k_on_role_logout_ok()
	g_i3k_login_data.role_login_state = g_i3k_login_state.NOTLOGIN
end

function i3k_on_connection_force_close(errCode)
	g_i3k_login_data.role_login_state = g_i3k_login_state.NOTLOGIN
	g_i3k_net_state.force_close_error_code = errCode
	g_i3k_net_state.state:notifyForceClose()
end

function i3k_on_send_sync_request()
	g_i3k_net_state.state:trySetWait()
end

function i3k_on_recv_sync_response()
	g_i3k_net_state.state:clearWait()
end

function i3k_on_update_connect_state(dtTime)
	g_i3k_net_state.state:onTick(dtTime)
end

function i3k_get_last_force_close_error_code()
	return g_i3k_net_state.force_close_error_code
end

--------------------------------------------------------------------------------------------------------------
function i3k_start_login(host, port, uid, channel)
	local net_log = i3k_get_net_log()
	net_log:Add("i3k_start_login")
	i3k_game_network_reset()
	g_i3k_login_data.has_authed = false
	g_i3k_login_data.server_addr.host = host
	g_i3k_login_data.server_addr.port = port
	g_i3k_login_data.uid = uid
	g_i3k_login_data.channel = channel
	g_i3k_login_data.ukey = i3k_get_userkey()
	i3k_connect_to_server()
end


function i3k_connect_to_server()
	i3k_game_network_connect(g_i3k_login_data.server_addr.host, g_i3k_login_data.server_addr.port)
end

function i3k_reconnect_to_server()
	g_i3k_auto_fight_flag.isAuto = g_i3k_game_context:IsAutoFight()
	g_i3k_auto_fight_flag.mapType = i3k_game_get_map_type()
	i3k_game_network_disconnect()
	i3k_connect_to_server()
end

function i3k_do_user_login()
	i3k_game_send_str_cmd(i3k_create_user_login_request(), i3k_sbean.user_login_res.getName())
end

function i3k_do_role_login(roleId)
	i3k_game_send_str_cmd(i3k_create_role_login_request(roleId), i3k_sbean.user_login_res.getName())
end

function i3k_do_create_role(name, gender, face, hair, charType)
	i3k_game_send_str_cmd(i3k_create_new_role_request(name, gender, face, hair, charType), i3k_sbean.user_login_res.getName())
end
---------------------------------------------------------------------------------=======
local eLOGIN_TYPE_NORMAL		= 0;
local eLOGIN_TYPE_RECONNECT		= 1;
local eLOGIN_TYPE_GOD			= 2;
function i3k_get_login_info()
	local loginInfo = i3k_sbean.UserLoginInfo.new()

	local arg = i3k_sbean.UserLoginParam.new()
	arg.loginType = (g_i3k_login_data.has_authed and eLOGIN_TYPE_RECONNECT or eLOGIN_TYPE_NORMAL) + (g_i3k_os_type == eOS_TYPE_WIN32 and eLOGIN_TYPE_GOD or 0)
	arg.loginKey = g_i3k_login_data.ukey
	arg.exParam = g_i3k_invite_code
	loginInfo.arg = arg

	local client = i3k_sbean.UserClientinfo.new()
	client.gameAppID = g_i3k_msdk.gameAppID
	client.clientVerPacket = i3k_game_get_client_version()
	client.clientVerResource = i3k_game_get_client_res_version()
	--client.clientChannel = g_i3k_msdk.clientChannel
	client.patchPackets = g_i3k_db.i3k_db_get_ext_pack_states_new()
	loginInfo.client = client

	local system = i3k_sbean.UserSysteminfo.new()
	system.deviceID = g_i3k_msdk.deviceID
	system.systemHardware = g_i3k_msdk.systemHardware
	system.systemSoftware = g_i3k_msdk.systemSoftware
	system.cpuHardware = g_i3k_msdk.cpuHardware
	system.screenWidth = g_i3k_msdk.screenWidth
	system.screenHeight = g_i3k_msdk.screenHeight
	system.density = g_i3k_msdk.density
	system.network = g_i3k_msdk.network
	system.loginIP = g_i3k_msdk.loginIP
	system.locale = g_i3k_msdk.locale
	system.macAddr = g_i3k_msdk.macAddr
	loginInfo.system = system

	loginInfo.serverID = g_i3k_login_data.server_id

	return loginInfo
end

function i3k_create_user_login_request()
	local req = i3k_sbean.user_login_req.new()
	req.openId = g_i3k_login_data.uid
	req.channel = g_i3k_login_data.channel
	req.loginInfo = i3k_get_login_info()
	req.roleId = 0
	req.createParam = nil
	req.gsId = i3k_game_get_login_server_id()
	return req
end

function i3k_create_new_role_request(name, gender, face, hair, charType)
	local req = i3k_sbean.user_login_req.new()
	req.openId = g_i3k_login_data.uid
	req.channel = g_i3k_login_data.channel
	req.loginInfo = i3k_get_login_info()
	req.roleId = 0
	req.createParam = i3k_new_create_role_param(name, gender, face, hair, charType)
	req.gsId = i3k_game_get_login_server_id()
	return req
end

function i3k_create_role_login_request(roleId)
	local req = i3k_sbean.user_login_req.new()
	req.openId = g_i3k_login_data.uid
	req.channel = g_i3k_login_data.channel
	req.loginInfo = i3k_get_login_info()
	req.roleId = roleId
	req.createParam = nil
	req.gsId = i3k_game_get_login_server_id()
	return req
end

function i3k_new_create_role_param(name, gender, face, hair, charType)
	local createParam = i3k_sbean.CreateRoleParam.new()
	createParam.name = name
	createParam.gender = gender
	createParam.face = face
	createParam.hair = hair
	createParam.classType = charType
	return createParam
end
-------------------------------------------------------------------------------------

function i3k_game_filter_packet(packet)
	if g_i3k_game_logic then
		return g_i3k_game_logic:FilterNetPacket(packet);
	end

	return false;
end

local function getChatUI()
	local chatUI = nil
	if g_i3k_game_context:GetChatUIOpenState() then
		chatUI = eUIID_Chat
	elseif g_i3k_game_context:GetPrivateChatUIOpenState() then
		chatUI = eUIID_PriviteChat
	end
	return chatUI
end

local function i3k_setLogicVolume(mute, onlyBGM)
	local bgVol = 0
	local effVol = 0
	if not mute then
		bgVol, effVol = g_i3k_game_context:GetUserCfg():GetVolume();
		bgVol = bgVol / 100
		effVol = effVol / 100
	end
	g_i3k_mmengine:SetVolume(gAudioType_BGM, (bgVol) * gAudio_BGMFalloff);
	if not onlyBGM then
		g_i3k_mmengine:SetVolume(gAudioType_Action, (effVol) * gAudio_ActionFalloff);
		g_i3k_mmengine:SetVolume(gAudioType_Effect, (effVol) * gAudio_EffectFalloff);
		g_i3k_mmengine:SetVolume(gAudioType_UI, (effVol) * gAudio_UIFalloff);
	end
end

function i3k_game_set_voice_state(state)
	if state == g_VOICE_RECORDING_NIL or state == g_VOICE_PLAYING_NIL then
		return false
	end
	if state > g_VOICE_PLAYING_NIL then
		if i3k_voice_playing_state ~= g_VOICE_PLAYING_NIL then
			return false
		end
		i3k_voice_playing_state = state
	else
		if i3k_voice_recording_state ~= g_VOICE_RECORDING_NIL then
			return false
		end
		i3k_voice_recording_state = state
	end
	i3k_setLogicVolume(true, state == g_VOICE_RECORDING_ONLINE_VOICE)
	return true
end

function i3k_game_cancel_voice_state(state)
	if state == g_VOICE_RECORDING_NIL or state == g_VOICE_PLAYING_NIL then
		return false
	end
	if state > g_VOICE_PLAYING_NIL then
		if i3k_voice_playing_state ~= state then
			return false
		end
		i3k_voice_playing_state = g_VOICE_PLAYING_NIL
	else
		if i3k_voice_recording_state ~= state then
			return false
		end
		i3k_voice_recording_state = g_VOICE_RECORDING_NIL
	end
	if i3k_voice_recording_state == g_VOICE_RECORDING_NIL and i3k_voice_playing_state == g_VOICE_PLAYING_NIL then
		i3k_setLogicVolume(false, false)
	end
	return true
end

function i3k_game_on_voice_record_created(url, length)
	-- TODO
	local chatUI = getChatUI()
	sec = string.format("%.1f",length/1000)
	if chatUI then
		g_i3k_ui_mgr:InvokeUIFunction(chatUI, "sendVoiceUrl",url,sec)
	end
end

function i3k_game_on_voice_volume_changed(volume)
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Volume, "changeVolume", volume)
end


function i3k_game_on_voice_record_start_play()
	local chatUI = getChatUI()
	if chatUI then
		g_i3k_ui_mgr:InvokeUIFunction(chatUI, "playVoiceAnis")
	end
end

function i3k_game_on_voice_record_finish_play()
	local chatUI = getChatUI()
	if chatUI then
		g_i3k_ui_mgr:InvokeUIFunction(chatUI, "finishPlay")
	end
end

function i3k_onYayaStartSpeak(result)
	-- if result == 0 then
	-- 	i3k_game_set_voice_state(g_VOICE_RECORDING_ONLINE_VOICE)
	-- 	g_i3k_ui_mgr:InvokeUIFunction(eUIID_OnlineVoice, "startSpeakCallback")
	-- elseif result == 13 then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3057))
	-- elseif result == 113 then
	-- 	--重复上麦而已，不用管
	-- elseif result then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3056) .. " " .. result)
	-- end
end

function i3k_onYayaStopSpeak()
	-- i3k_game_cancel_voice_state(g_VOICE_RECORDING_ONLINE_VOICE)
	-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_OnlineVoice, "stopSpeakCallback")
end

function i3k_game_on_device_battery_changed(battery)
	g_DEVICE_BATTERY = battery
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattery")
end

function i3k_game_on_device_battery_state_changed(isConnected)
	g_DEVICE_BATTERY_CONNECT_STATE = isConnected
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattery")
end

function i3k_onReplayKitStartBroadcast()
	g_i3k_ui_mgr:OpenUI(eUIID_Broadcast)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Broadcast, "startBroadcast")
end

function i3k_onReplayKitStopBroadcast()
	g_i3k_ui_mgr:CloseUI(eUIID_Broadcast)
end

function i3k_onReplayKitError(errorCode)
	if errorCode == -5801 then
		g_i3k_ui_mgr:PopupTipMessage("請選擇直播App併且按提示操作")
	else
		g_i3k_ui_mgr:PopupTipMessage("發生未知錯誤，錯誤碼：" .. errorCode)
	end
end

function i3k_onReplayKitSystemNotSupport()
	g_i3k_ui_mgr:PopupTipMessage("您的iOS版本不支援直播，請升級到iOS10，謝謝")
end

function i3k_SetResumeShortcutItemType(shortcutItemType)
	--i3k_log("i3k_SetResumeShortcutItemType " .. shortcutItemType)
	i3k_set_short_cut_type(shortcutItemType)
	local cfg = g_i3k_game_context:GetUserCfg()
	local roleInfo = g_i3k_game_context:GetRoleList()
	local lastRoleIdx =  cfg:GetSelectRole()
	if roleInfo[lastRoleIdx] then
		i3k_do_role_login(roleInfo[lastRoleIdx]._id)
	end
end

--shortcutItemType: 0：默认，1：福利，2：活动，3：排行榜
function i3k_set_short_cut_type(shortcutItemType)
	g_i3k_short_cut_type = shortcutItemType
end

function i3k_get_short_cut_type()
	return g_i3k_short_cut_type
end

function i3k_get_is_use_short_cut()
	return g_i3k_short_cut_type ~= 0
end

-----------------------------
-- for lua call
-- 检测游戏分包是否资源完整

function i3k_getExtPackFileList(extPackId)
	if g_i3k_extpack_filelist[extPackId] ~= nil then
		return g_i3k_extpack_filelist[extPackId]
	end
	--根据不同的平台加载不同的lua文件
	if g_i3k_os_type == eOS_TYPE_OTHER then
		require("i3k_dd_android")
	elseif g_i3k_os_type == eOS_TYPE_IOS then
		require("i3k_dd_ios")
	elseif g_i3k_os_type == eOS_TYPE_WIN32 then
		require("i3k_dd_win32")
	else
		return nil
	end
	if i3k_obb_dd_info == nil then
		return nil
	end
	if i3k_obb_dd_info[extPackId] == nil then
		return nil
	end
	local filelist = {}
	table.insert(filelist, i3k_obb_dd_info[extPackId].blockcount)
	table.insert(filelist, i3k_obb_dd_info[extPackId].size)
	for _, v in ipairs(i3k_obb_dd_info[extPackId].blocks) do
		table.insert(filelist, v.digest)
	end
	g_i3k_extpack_filelist[extPackId] = filelist
	return filelist
end

function i3k_getExtPackSize(extPackId)
	if g_i3k_extpack_size[extPackId] then
		return g_i3k_extpack_size[extPackId]
	end
	local size = 0
	if g_i3k_os_type == eOS_TYPE_OTHER then
		require("i3k_dd_android")
	elseif g_i3k_os_type == eOS_TYPE_IOS then
		require("i3k_dd_ios")
	elseif g_i3k_os_type == eOS_TYPE_WIN32 then
		require("i3k_dd_win32")
	else
		return size
	end
	if not i3k_obb_dd_info then
		return size
	end
	if not i3k_obb_dd_info[extPackId] then
		return size
	end
	g_i3k_extpack_size[extPackId] = i3k_obb_dd_info[extPackId].size
	size = i3k_obb_dd_info[extPackId].size
	return size
end

function i3k_check_resources_downloaded(mapID)
	-- TODO 测试直接 return true
	if not g_i3k_download_mode then -- 如果不是下载分包
		return true
	end
	local state = g_i3k_download_mgr:checkResouceState(mapID)
	if not state then
		g_i3k_ui_mgr:CloseUI(eUIID_transportProcessBar)
	end
	return state
end

function i3k_check_resources_byID(mapID)
	if not g_i3k_download_mode then
		return true
	end
	local packID = i3k_db_combat_maps[mapID].package-- 对应战役地图表的id
	return g_i3k_download_mgr:checkResouceStateByPackID(packID)
end

function i3k_back()
	if not g_newUIOpened then
		return 0
	elseif g_i3k_ui_mgr:GetUI(eUIID_GameNotice) then
		g_i3k_ui_mgr:CloseUI(eUIID_GameNotice)
		return 1
	elseif g_i3k_ui_mgr:GetUI(eUIID_SelectServer) then
		g_i3k_ui_mgr:CloseUI(eUIID_SelectServer)
		return 1
	elseif g_i3k_ui_mgr:GetUI(eUIID_Loading)
		or g_i3k_ui_mgr:GetUI(eUIID_Login)
		or g_i3k_ui_mgr:GetUI(eUIID_CSelectChar)
		or g_i3k_ui_mgr:GetUI(eUIID_CCreateChar)
		or g_i3k_ui_mgr:GetUI(eUIID_SelChar)
		then
		return 0
	else
		g_i3k_ui_mgr:CloseAllOpenedUI(eUIID_Wait)
		g_i3k_logic:OpenBattleUI()
		g_newUIOpened = false
	end
	return 1
end
--------------------------

function i3k_onRefreshServerlist()
end

function i3k_onRefreshAnnouncement()
end

function i3k_onShareResult(code)
	--g_i3k_ui_mgr:PopupTipMessage("i3k_onShareResult" .. code)
	if code == 0 then
		g_i3k_game_context:setShareSdkState(true)
	elseif code == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15391))
	end
end

local Joy_Task_UIID = eUIID_BattleTask
function i3k_onJoy_ChangeTaskUIID(uiid)
	--g_i3k_ui_mgr:PopupTipMessage("i3k_onKeyEvent " .. uiid)
	Joy_Task_UIID = uiid
end
function i3k_game_get_auto_fight_flag()
	return g_i3k_auto_fight_flag.isAuto, g_i3k_auto_fight_flag.mapType
end

function i3k_onJoyKeyEvent(action, keyCode)
	if action == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("i3k_onKeyEvent " .. action .. " code: " .. keyCode)
	else
		return
	end
	if g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
		return
	end

	if keyCode == 96 then --普攻
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onAttackClick")
	elseif keyCode == 99 then --技能一
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "sendJoySkillTouchClick",1)
	elseif keyCode == 100 then --技能2
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "sendJoySkillTouchClick",2)
	elseif keyCode == 97 then --技能3
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "sendJoySkillTouchClick",3)
	elseif keyCode == 105 then --技能4
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "sendJoySkillTouchClick",4)
	elseif keyCode == 104 then --绝技
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "joyUseUniqueSkill")
	elseif keyCode == 102 then --神兵
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "joyWeaponSkill")
	elseif keyCode == 19 then --主线任务
		g_i3k_ui_mgr:InvokeUIFunction(Joy_Task_UIID, "joyTodoMainTask")
	elseif keyCode == 20 then --采矿弹出来的，装备弹出来的
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEquip, "onJoySendClick")
	elseif keyCode == 22 then --轻功
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "joyUseDodgeSkill")
	elseif keyCode == 21 then --托管
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onAutoFightClick")
	end
end

function i3k_onJoyStickEvent(x, y)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Yg, "setControlDirect", x, y)
end


-- 只针对android层，限帧接口
function i3k_fps_limit(maxFps)
	i3k_log("maxFPS = "..maxFps)
	if g_i3k_game_handler.SetFPSControl then
	    if i3k_game_get_os_type() == eOS_TYPE_OTHER then
	    	g_i3k_game_handler:SetFPSControl(1, maxFps) -- android层只用到了最后面这个参数
	    end
	end
end


-- 返回屏幕是否是自动亮度  ios一直未false
function i3k_get_is_screen_auto_brightness()
	if g_i3k_game_handler.IsScreenAutoBrightness then
		return g_i3k_game_handler:IsScreenAutoBrightness()
	end
end
-- 设置屏幕自动亮度
function i3k_set_screen_auto_birghtness(auto)
	if g_i3k_game_handler.SetScreenAutoBrightness then
		g_i3k_game_handler:SetScreenAutoBrightness(auto)
	end
end
-- 获取屏幕亮度 0..1 浮点数
function i3k_get_screen_brightness()
	if g_i3k_game_handler.GetScreenBrightness then
		local value = g_i3k_game_handler:GetScreenBrightness() * 100 -- 0~1浮点数不太好用，这里*100
		-- g_i3k_ui_mgr:PopupTipMessage("亮度獲取"..value/100)
		return value
	else
		return 100
	end
end
-- 设置屏幕亮度
function i3k_set_screen_brightness(brightness)
	if g_i3k_game_handler.SetScreenBrightness then
		-- g_i3k_ui_mgr:PopupTipMessage("亮度set"..brightness/100)
		g_i3k_game_handler:SetScreenBrightness(brightness / 100)
	end
end

-- 封装一层全局接口，设置游戏音量
function i3k_set_game_music(bgVol, effVol)
	local gAudioType_Action	= 1
	local gAudioType_Effect	= 2
	local gAudioType_Scene	= 3
	local gAudioType_BGM	= 4
	local gAudioType_UI		= 5

	g_i3k_mmengine:SetVolume(gAudioType_BGM, (bgVol / 100) * gAudio_BGMFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_Action, (effVol / 100) * gAudio_ActionFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_Effect, (effVol / 100) * gAudio_EffectFalloff);
	g_i3k_mmengine:SetVolume(gAudioType_UI, (effVol / 100) * gAudio_UIFalloff);
end


function i3k_game_reset_auto_fight_flag()
	g_i3k_auto_fight_flag.isAuto = false
	g_i3k_auto_fight_flag.mapType = -1
end

function i3k_star_pos_to_num(pos, v)
	if pos and v then
		return (pos.x * v + pos.y)
	end
end

function i3k_star_num_to_Pos(num, v)
	if num and v then
		return (num / v), (num % v);
	end
end

function i3k_game_get_role_name_invalid_flag()
	return g_i3k_is_roleNameInvalid
end

function i3k_game_set_role_name_invalid_flag(value)
	g_i3k_is_roleNameInvalid = value
end

-- 复制文字到剪贴板
function i3k_copy_to_clipboard(text)
	if g_i3k_game_handler.CopyToClipboard then
		g_i3k_game_handler:CopyToClipboard(text)
	end
end

-- 从剪贴板获取文字
function i3k_paste_from_clipboard()
	if g_i3k_game_handler.PasteFromClipboard then
		return g_i3k_game_handler:PasteFromClipboard() or ""
	end
	return ""
end
-- 统计按钮同一位置点击次数
function i3k_game_set_click_pos()
	local channel = i3k_game_get_channel_name()
	if g_i3k_db.i3k_db_check_ignore_channel(channel) then
		return
	end
	local cfg = i3k_db_common.trainingCfg
	local lvl = g_i3k_game_context:GetLevel()
	if lvl > cfg.limitLvl then
		return false
	end
	local pos = g_i3k_ui_mgr:GetMousePos()
	if pos and (pos.x ~= 0 and pos.y ~= 0) then
		local key = string.format("%s_%s", math.modf(pos.x), math.modf(pos.y))
		if not g_i3k_click_data[key] then
			g_i3k_click_data[key] = 0
		else
			local validCount = g_i3k_os_type == eOS_TYPE_WIN32 and 5 or 3 --window下触发计数次数为5
			g_i3k_click_data[key] = g_i3k_click_data[key] + 1
			if g_i3k_click_data[key] > validCount then
				g_i3k_click_total_num = g_i3k_click_total_num + 1
			end
		end
		if g_i3k_click_total_num >= cfg.needClickNum then
			i3k_sbean.script_role_mark(g_i3k_click_total_num)
			i3k_game_reset_click_data()
		end
	end
end

-- 清空统计数据
function i3k_game_reset_click_data()
	g_i3k_click_data = {}
	g_i3k_click_total_num = 0
end
function hero_attach_flying_equip(node, models)
	for k, v in ipairs(models) do
		local modelID = i3k_engine_check_is_use_stock_model(v.id);
		if modelID then
			local cfg = i3k_db_models[modelID]
			if cfg and node then
				if cfg.path then
					node:linkChild(cfg.path, v.name, cfg.heroHangPoint, cfg.weaponHangPoint, 0.0, cfg.scale);
				end
			end
		end
	end
end
function hero_change_foot_effect(node, effectId)
	if node.footEffectId then
		for _,v in ipairs(node.footEffectId) do
			node:unlinkChild(v)
		end
		node.footEffectId = {}
	end
	local cfg = i3k_db_effects[effectId]
	if cfg then
		local effect = 0
		local hero = i3k_game_get_player_hero()
		if cfg.hs == '' or cfg.hs == 'default' then
			effect = node:linkChild(cfg.path, string.format("hero_%s_foot_effect_%d", hero._guid, effectId), "", "", 0.0, cfg.radius)
		else
			effect = node:linkChild(cfg.path, string.format("hero_%s_foot_effect_%d", hero._guid, effectId), cfg.hs, "", 0.0, cfg.radius)
		end
		if effect~=0 then
			if not node.footEffectId then
				node.footEffectId = {}
			end
			table.insert(node.footEffectId, effect)
		end
	end
end
function i3k_game_unpack_video()
	local kpkName = "packages/video.kpk"
	if g_i3k_game_handler.CheckFileModifiedTime then -- android only
		local shouldUnpack = g_i3k_game_handler:CheckFileModifiedTime(kpkName) -- 如果kpk有更新，那么就解压
		if shouldUnpack then
			if g_i3k_game_handler.UnpackFile then
				for k, v in pairs(i3k_db_video_data) do
					local suc = g_i3k_game_handler:UnpackFile("video/"..v.fileName, "")--arg2 path暂时设空
				end
			end
		end
	end
end
function i3k_game_on_video_play_start(path)
	if g_i3k_game_handler.PlayCGVideo then
		i3k_game_set_ignore_next_pause_resume_state(true)
		g_i3k_game_handler:PlayCGVideo(path)
	else
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(18087))
	end
end
function i3k_game_on_video_play_finish(playState)
	if playState == g_VIDEO_FINISHED then
		i3k_sbean.role_revive_cpr()
	elseif playState == g_VIDEO_INTERRUPT then
	end
end
--oppo--
function i3k_game_get_oppo_info()
	if g_i3k_game_handler.RequestIsOppoGameCenter then
		local isGameCenter = g_i3k_game_handler:RequestIsOppoGameCenter()
		g_i3k_game_context:SetIsOppoGameCenter(isGameCenter)
	end
end
-----------------------------合照--------------------------------
function i3k_game_take_photo_faction(info, mapInfo)
	if i3k_get_engine_version() < g_ENGINE_VERSION_1001 then
		return;
	end
	local world = i3k_game_get_world()
	if not world then return end
	world:CreateTakePhotoScene(mapInfo)
	g_i3k_coroutine_mgr:StartCoroutine(function()
		local posCfg = g_i3k_db.i3k_db_get_faction_photo_positions(#info)
		for k, v in ipairs(info) do
			local postionCfg = posCfg[k]
			if postionCfg then
				--local id = 9999 + i * 5 + k
				local pos = postionCfg.position --{ x = 28 + i * 1.5, y = 18, z = -140 + k * 3.5 }
				local scale = postionCfg.scale
				world:CreateTakePhotoInfo(v, pos, scale);
			end
			g_i3k_coroutine_mgr.WaitForNextFrame();
		end
		g_i3k_coroutine_mgr.WaitForNextFrame();
		world:CapturePlayersRunAction()
		g_i3k_coroutine_mgr.WaitForNextFrame();
		world:CapturePlayersPause()
		local cfgInfo = i3k_db_faction_photo.cfgBase
		local sceneSize = g_i3k_db.get_take_photo_scene_size(#info)
		local cfg = Engine.MCaptureConfig();
		local height, width = g_i3k_db.get_take_photo_width_height()
--[[	
		cfg.mWidth		= 1920; -- 越大 精度越高  最大不超过2048
		cfg.mHeight		= 1080; -- 最终图片的高度（2000左右就会出现摄像机视角不够了）
		cfg.mViewSize	= 16; -- （渲染一块多少米）越小越窄 精度越高   调节视角距离，摄像机距离第一排的距离
		cfg.mSceneSize	= 60; -- 场景宽度，如果每个人宽3米，50个人一排，那么估算一下需要150多一点，这个值控制两边留白多少，小于30就不好使了
		cfg.mAngle		= -10; -- 俯仰角，根据mY 对应微调
		cfg.mX			= 28;  -- 摄像机左右移动距离，28为中心
		cfg.mY			= 1023; -- 这三个参数是摄像机的坐标（上下平移摄像机，21为中心）
		cfg.mZ			= -145; -- 140为中心位置--]]
		cfg.mWidth		= width--cfgInfo.photoWidth; 
		cfg.mHeight		= height--cfgInfo.photoHeight;
		cfg.mViewSize	= cfgInfo.viewSize 
		cfg.mSceneSize	= sceneSize --cfgInfo.sceneSize;
		cfg.mAngle		= cfgInfo.angle;
		cfg.mX			= cfgInfo.cameraPos.x;
		cfg.mY			= cfgInfo.cameraPos.y;
		cfg.mZ			= cfgInfo.cameraPos.z;
		local view = Engine.MCaptureView();
		view:Capture("capture", cfg);
		if g_i3k_game_handler.CopyCapture then
		local fileName = view:GetFileName()
			if g_i3k_os_type == eOS_TYPE_IOS then
				g_i3k_game_handler:CopyCapture(fileName, "rxjh")
			else
				g_i3k_game_handler:CopyCapture(string.sub(fileName, 3), "rxjh")
			end
		end
		view:Cleanup();
		world:ReleaseCapturePlayers();
		g_i3k_logic:OpenTaskPhotoEnd()
	end)
end
