----------------------------------------------------------------
--module(..., package.seeall)

local require = require;

require("i3k_usercfg");
require("i3k_announcement")

require("i3k_state_machine");

require("logic/state/i3k_logic_state");
require("logic/state/i3k_logic_state_init");
require("logic/state/i3k_logic_state_login");
require("logic/state/i3k_logic_state_create_role");
require("logic/state/i3k_logic_state_sel_char");
require("logic/state/i3k_logic_state_main");
require("logic/state/i3k_logic_state_battle");
require("logic/state/i3k_logic_state_play_dlc");
require("logic/state/i3k_logic_state_battle_prepare");
require("logic/state/i3k_logic_state_exit");
require("logic/state/i3k_logic_state_lead");
require("logic/state/i3k_logic_state_shortcut");

local BASE = require("logic/i3k_base_logic").i3k_base_logic;

-- state
local eLogicEventInit 		= 100;
local eLogicEventLogin 		= 101;
local eLogicEventMain 		= 102;
local eLogicEventBattle 	= 103;
local eLogicEventBattlePre	= 104;
local eLogicEventExit		= 105;
local eLogicEventCreateRole	= 106;
local eLogicEventPlayDLC 	= 107;
local eLogicEventSelChar	= 108;
local eLogicEventLead       = 109;
local eLogicEventShortCut	= 110;

local eLogicStateInit		= "init";
local eLogicStateLogin		= "login";
local eLogicStateMain		= "main";
local eLogicStateBattle		= "battle";
local eLogicStateExit		= "exit";
local eLogicStateCreateRole	= "create role";
local eLogicStatePlayDLC	= "play DLC";
local eLogicStateSelChar	= "select character";
local eLogicStateLead       = "player lead";
local eLogicStateShortCut	= "shortcut";


------------------------------------------------------
i3k_game_logic = i3k_class("i3k_game_logic", BASE)
function i3k_game_logic:ctor()
	self._player	= nil;
--	self._net_tick	= 0;
end

function i3k_game_logic:Create()
	if not BASE.Create(self) then return false; end

	i3k_engine_init_rnd(tonumber(tostring(os.time()):reverse():sub(1, 6)));

	g_i3k_game_handler:EnableObjHitTest(true, true); -- object false, ground true

	-- logic state machine
	self._logic_sm = i3k_state_machine.new(eLogicStateInit);

	local login_state 		= i3k_logic_state_login.new();
	local exit_state		= i3k_logic_state_exit.new();
	local main_state		= i3k_logic_state_main.new();
	local crole_state		= i3k_logic_state_create_role.new();
	local battle_state		= i3k_logic_state_battle.new();
	local battle_pre_state	= i3k_logic_state_battle_prepare.new();
	local play_dlc_state	= i3k_dlc_mgr_create();
	local sel_char_state	= i3k_logic_state_sel_char.new();
	local lead_state        = i3k_logic_state_lead.new();
	local shortcut_state    = i3k_logic_state_shortcut.new();

	self._logic_sm:AddTransition(eLogicStateInit,		eLogicEventLogin,		eLogicStateLogin,		login_state);

	self._logic_sm:AddTransition(eLogicStateLogin,		eLogicEventMain,		eLogicStateMain,		main_state);
	self._logic_sm:AddTransition(eLogicStateLogin,		eLogicEventCreateRole,	eLogicStateCreateRole,	crole_state);
	self._logic_sm:AddTransition(eLogicStateLogin,		eLogicEventSelChar,		eLogicStateSelChar,		sel_char_state);
	self._logic_sm:AddTransition(eLogicStateLogin,		eLogicEventExit,		eLogicStateExit,		exit_state);
	self._logic_sm:AddTransition(eLogicStateLogin,		eLogicEventPlayDLC,		eLogicStatePlayDLC,		play_dlc_state);

	self._logic_sm:AddTransition(eLogicStateCreateRole,	eLogicEventLogin,		eLogicStateLogin,		login_state);
	self._logic_sm:AddTransition(eLogicStateCreateRole,	eLogicEventSelChar,		eLogicStateSelChar,		sel_char_state);
	self._logic_sm:AddTransition(eLogicStateCreateRole,	eLogicEventExit,		eLogicStateExit,		exit_state);
	self._logic_sm:AddTransition(eLogicStateCreateRole,	eLogicEventPlayDLC,		eLogicStatePlayDLC,		play_dlc_state);
	self._logic_sm:AddTransition(eLogicStateCreateRole, eLogicEventLead,  		eLogicStateLead, 		lead_state);

	self._logic_sm:AddTransition(eLogicStateSelChar,	eLogicEventMain,		eLogicStateMain,		main_state);
	self._logic_sm:AddTransition(eLogicStateSelChar,	eLogicEventExit,		eLogicStateExit,		exit_state);
	self._logic_sm:AddTransition(eLogicStateSelChar,	eLogicEventPlayDLC,		eLogicStatePlayDLC,		play_dlc_state);
	self._logic_sm:AddTransition(eLogicStateSelChar,	eLogicEventLead,		eLogicStateLead,		lead_state);

	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventLogin,		eLogicStateLogin,		login_state);
	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventSelChar,		eLogicStateSelChar,		sel_char_state);
	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventExit,		eLogicStateExit,		exit_state);
	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventBattle,		eLogicStateBattle,		battle_state);
	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventPlayDLC,		eLogicStatePlayDLC,		play_dlc_state);
	self._logic_sm:AddTransition(eLogicStateMain,		eLogicEventLead,  		eLogicStateLead, 		lead_state);

	self._logic_sm:AddTransition(eLogicStateBattle,		eLogicEventMain,		eLogicStateMain,		main_state);
	self._logic_sm:AddTransition(eLogicStateBattle,		eLogicEventSelChar,		eLogicStateSelChar,		sel_char_state);
	self._logic_sm:AddTransition(eLogicStateBattle,		eLogicEventExit,		eLogicStateExit,		exit_state);

	self._logic_sm:AddTransition(eLogicStatePlayDLC,	eLogicEventMain,		eLogicStateMain,		main_state);
	self._logic_sm:AddTransition(eLogicStatePlayDLC,	eLogicEventExit,		eLogicStateExit,		exit_state);

	self._logic_sm:AddTransition(eLogicStateLead,		eLogicEventBattle,		eLogicStateBattle,		battle_state);
	self._logic_sm:AddTransition(eLogicStateLead,		eLogicEventExit,		eLogicStateExit,		exit_state);
	
	self._logic_sm:AddTransition(eLogicStateInit,		eLogicEventShortCut,	eLogicStateShortCut,	shortcut_state);
	self._logic_sm:AddTransition(eLogicStateShortCut,	eLogicEventBattle,		eLogicStateBattle,		battle_state);
	self._logic_sm:AddTransition(eLogicStateShortCut,	eLogicEventLogin,		eLogicStateLogin,		login_state);
	self._logic_sm:AddTransition(eLogicStateShortCut,	eLogicEventSelChar,		eLogicStateSelChar,		sel_char_state);
	
	local cfg = i3k_get_load_cfg()
	local userName = cfg:GetUserName()
	if userName ~= "" and i3k_get_is_use_short_cut() then
		self._logic_sm:ProcessEvent(eLogicEventShortCut);
	else
		self._logic_sm:ProcessEvent(eLogicEventLogin);
	end

	g_i3k_game_handler:SetWindowTitle("rxjh");

	return true;
end

function i3k_game_logic:OnUpdate(dTime)
	local ret = BASE.OnUpdate(self, dTime);

	local state = self._logic_sm._cur_state_obj;
	if state then
		state:OnUpdate(dTime);
	end

	return true;
end

function i3k_game_logic:OnLogic(dTick)
	local ret = BASE.OnLogic(self, dTick);

--	self._net_tick = self._net_tick + dTick * i3k_engine_get_tick_step();
--	if self._net_tick > 1000 then
--		self._net_tick = 0;
--
--		if g_i3k_game_context and g_i3k_game_context:IsEnableAutoReconnect() then
--			g_i3k_game_context:ReconnectToServer();
--		end
--	end
	--i3k_on_update_connect_state(dTick * i3k_engine_get_tick_step())
	--g_i3k_game_context:updateConnectState(dTick * i3k_engine_get_tick_step())

	local state = self._logic_sm._cur_state_obj;
	if state then
		state:OnLogic(dTick);
	end

	return ret;
end

function i3k_game_logic:OnLogin()
	BASE.OnLogin(self);

	--[[
	if g_i3k_game_context then
		self:CreateCharacters();

		self._logic_sm:ProcessEvent(eLogicEventSelChar);
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
	]]
end

function i3k_game_logic:onFirstCreateRole()
	self._logic_sm:ProcessEvent(eLogicEventSelChar);
end

function i3k_game_logic:OnCharList()
	BASE.OnCharList(self);

	if g_i3k_game_context then
		--self:CreateCharacters();

		self._logic_sm:ProcessEvent(eLogicEventSelChar);
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
end

function i3k_game_logic:OnRelogin()
	BASE.OnRelogin(self);

	if g_i3k_game_context then
		--self:CreateCharacters();

		self._logic_sm:ProcessEvent(eLogicEventSelChar);
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
end

function i3k_game_logic:OnClearRole()
	BASE.OnClearRole(self);

	if g_i3k_game_context then
		--self:CreateCharacters();

		self._logic_sm:ProcessEvent(eLogicEventSelChar);
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
end

function i3k_game_logic:CheckLoaded()
	return g_i3k_game_context:GetMapEnter() == true;
end

function i3k_game_logic:OnPlay()
	if not g_i3k_game_context:isOnSprog() then
		BASE.OnPlay(self);

		self._logic_sm:ProcessEvent(eLogicEventMain);
	else
		g_i3k_game_context:SetMapEnter(true);
	end
end

function i3k_game_logic:OnQuitDungeon()
	self._logic_sm:ProcessEvent(eLogicEventMain);
end

function i3k_game_logic:OnPlayerLead()
	self._logic_sm:ProcessEvent(eLogicEventLead);
end

function i3k_game_logic:OnLeavePlayerLead()
	self._logic_sm:ProcessEvent(eLogicEventBattle)
end

function i3k_game_logic:OnShortCutToLogin()
	if g_i3k_game_context then
		self._logic_sm:ProcessEvent(eLogicEventLogin)
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
end

function i3k_game_logic:OnLeaveShortCut()
	if g_i3k_game_context then
		self._logic_sm:ProcessEvent(eLogicEventBattle)
	else
		self._logic_sm:ProcessEvent(eLogicEventExit);
	end
end

function i3k_game_logic:OnKeyDown(handled, key)
	local h = self._logic_sm._cur_state_obj:OnKeyDown(handled, key);
	if h == 1 then
		return 1;
	end

	return BASE.OnKeyDown(self, handled, key);
end

function i3k_game_logic:testAA(handled, key)
	g_i3k_ui_mgr:PopupTipMessage("testAA")
end

local bigTables = { }
local normalUIVisible = true;
local showRenderInfo = true;
function i3k_game_logic:OnKeyUp(handled, key)
	local h = 0;

	if key == 48 then -- B
		h = 1;

		g_i3k_logic:OpenBagUI()
	elseif key == 45 then -- x
		--[[g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskAccept)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskAccept)--]]
		--g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskThink)
		--g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskThink)
	elseif key == 49 then -- N
		h = 1
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRoomData")
		-- i3k_sbean.homeland_create("jiayuan", {itemID = 66723, itemCount = 2})
		i3k_sbean.world_msg_send_req(string.format("@#power"))
	elseif key == 50 then -- M
		local roleId = g_i3k_game_context:GetRoleId()
		i3k_sbean.homeland_enter(roleId)
	elseif key == 47 then --v 
		i3k_sbean.homeland_uplevel(g_i3k_game_context:GetHomeLandLevel() + 1)
	elseif key == 24 then --O
		i3k_sbean.world_msg_send_req("@#i3k")
	elseif key == 34 then --G
		-- i3k_sbean.world_msg_send_req("@#showtimeoffset")
		i3k_sbean.world_msg_send_req("@#rbjoinsuperarena 3")
	elseif key == 35 then --h 
		i3k_sbean.homeland_equip_wear(1, {id = 1, canUseTime = 99, padding1 = 0, padding2 = 0, confId = 3})
	elseif key == 59 then -- F1
		h = 1;

		if g_i3k_ui_mgr then
			local uisname = nil
			for i, e in ipairs(g_i3k_ui_mgr:GetCurrentOpenedUIs()) do
				if uisname then
					uisname = uisname .. "|"
				else
					uisname = ""
				end
				uisname = uisname .. e
			end
			g_i3k_ui_mgr:PopupTipMessage("opened uis: " .. uisname)
		end
	elseif key == 62 then -- F4
		local state = g_i3k_game_handler:GetRenderState();

		g_i3k_ui_mgr:PopupTipMessage(Engine.A2UTF8(state));
	elseif key == 63 then -- F5
		normalUIVisible = not normalUIVisible;
		if normalUIVisible then
			g_i3k_ui_mgr:ShowNormalUI();
		else
			g_i3k_ui_mgr:HideNormalUI();
		end
	elseif key == 64 then -- F6 whf
		showRenderInfo = not showRenderInfo;

		g_i3k_ui_mgr:ShowRenderInfo(showRenderInfo);

		--[[
		local cache = { }
		local getTableSize =
			function(t)
				local r = 0
				for k, v in pairs(t) do
					r = r + 1
				end
				return r
			end

		local newBigTables = { }
		searchBigTable =
			function(name, t, minSize)
				if cache[tostring(t)] then
					return
				end
				local s = getTableSize(t)
				cache[tostring(t)] = s
				if s >= minSize then
					table.insert(newBigTables, { name = name, t = t, size = s })
				end
				for k, v in pairs(t) do
					if type(v) == "table" then
						searchBigTable(name .. "." .. k, v, minSize)
					end
				end
		       end
		searchBigTable("", _G, 100)
		table.sort(bigTables, function(a, b) return a.size > b.size end)
		i3k_log("======bigTable count is " .. getTableSize(newBigTables))

		if #bigTables > 0 then
			local diffTable = { }
			local mapOld = { }
			for _, v in ipairs(bigTables) do
				mapOld[v.name] = v.size
			end
			for _, v in ipairs(newBigTables) do
				if mapOld[v.name] and v.size > mapOld[v.name] then
					table.insert(diffTable, { name = v.name, oldSize = mapOld[v.name], newSize = v.size })
				end
			end
			table.sort(diffTable, function(a, b) return a.newSize-a.oldSize > b.newSize - b.oldSize end)
			for _, v in ipairs(diffTable) do
				i3k_log("\t+++ " .. v.name .. " => " .. v.oldSize .. " => " .. v.newSize)
			end
			i3k_log("==========================")
		end

		for i, v in ipairs(newBigTables) do
			i3k_log("\t" .. v.name .. " => " .. v.size)
			if i >= 20 then
				break
			end
		end
		bigTables = newBigTables
		i3k_log("==========================")
		]]
	elseif key == 65 then -- F7
		g_i3k_game_handler:SnapshotScreen("screenshot.png", false);
	elseif key == 87 then -- F11
		i3k_log("-------------------before collectgarbage count : ", i3k_integer(collectgarbage("count")));
		collectgarbage("collect")
		i3k_log("-------------------after collectgarbage count : ", i3k_integer(collectgarbage("count")));
	elseif key == 88 then -- F12
		i3k_log("-------------------- collectgarbage count : ", i3k_integer(collectgarbage("count")));
	end

	if h == 0 then
		h = self._logic_sm._cur_state_obj:OnKeyUp(handled, key);
		if h == 1 then
			return 1;
		end
	end

	return BASE.OnKeyUp(self, handled, key);
end

function i3k_game_logic:OnHitObject(handled, entity)

	BASE.OnHitObject(self, handled, entity);
	self._logic_sm._cur_state_obj:OnHitObject(handled, entity);

	return 1;
end

function i3k_game_logic:OnHitGround(handled, x, y, z)
	local h = self._logic_sm._cur_state_obj:OnHitGround(handled, x, y, z);
	if h == 1 then
		return h;
	end

	return BASE.OnHitGround(self, handled, x, y, z);
end

function i3k_game_logic:OnTouchDown(handled, x, y)
	local h = self._logic_sm._cur_state_obj:OnTouchDown(handled, x, y);
	if h == 1 then
		return h;
	end

	return BASE.OnTouchDown(self, handled, x, y);
end

function i3k_game_logic:OnTouchUp(handled, x, y)
	local h = self._logic_sm._cur_state_obj:OnTouchUp(handled, x, y);
	if h == 1 then
		return h;
	end

	return BASE.OnTouchUp(self, handled, x, y);
end

function i3k_game_logic:OnDrag(handled, touchDown, x, y)
	local h = self._logic_sm._cur_state_obj:OnDrag(handled, touchDown, x, y);
	if h == 1 then
		return h;
	end

	return BASE.OnDrag(self, handled, touchDown, x, y);
end

function i3k_game_logic:NewDungeon(id)
	local _d = BASE.NewDungeon(self, id);
	if _d then
		_d = self._logic_sm:ProcessEvent(eLogicEventBattle);
	end

	return _d;
end

function i3k_game_logic:FilterNetPacket(packet)
	if not self:CheckLoaded() then
		if string.sub(packet, 1, 6) == "nearby" then
			return true;
		end
	end

	return false;
end
