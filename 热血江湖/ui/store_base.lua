-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_store_base = i3k_class("wnd_store_base", ui.wnd_base)

local LAYER_BPSDT = "ui/widgets/bpsdt"
--帮贡id

local TOTAL_STORE = 7

local gotoStore =
{
	[0] = function(uiid)				--押镖
		--	当玩家级别不满足运镖等级时，不会切换到赏金分页
		--进入帮派
		local factionID = g_i3k_game_context:GetFactionSectId()
		if factionID and factionID~=0 then
			local need_faction_lvl = i3k_db_escort.escort_args.open_lvl
			local now_level = g_i3k_game_context:getSectFactionLevel()
			if g_i3k_game_context:GetLevel() >= i3k_db_escort.escort_args.join_lvl and now_level >= need_faction_lvl then
				i3k_sbean.sect_escort_store_sync()
				g_i3k_ui_mgr:CloseUI(uiid)
			else
				g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
			end
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end ,

	[1] = function(uiid)				--竞技场
		local syncShop = i3k_sbean.arena_shopsync_req.new()
		i3k_game_send_str_cmd(syncShop, i3k_sbean.arena_shopsync_res.getName())
		g_i3k_ui_mgr:CloseUI(uiid)
	end ,

	[2] = function(uiid)				--帮派
		--进入帮派
		local factionID = g_i3k_game_context:GetFactionSectId()
		if factionID and factionID~=0 then
				local data = i3k_sbean.sect_shopsync_req.new()
				i3k_game_send_str_cmd(data,i3k_sbean.sect_shopsync_res.getName())
				g_i3k_ui_mgr:CloseUI(uiid)
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end ,

	[3] = function(uiid)				--会武
		--当玩家的你不满足会武等级时，不会切换到会武分页
		local hero = i3k_game_get_player_hero()
		if hero._lvl>=i3k_db_tournament_base.needLvl then
			i3k_sbean.sync_team_arena_store()
			g_i3k_ui_mgr:CloseUI(uiid)
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end ,
	[4] = function(uiid)
		--TODO: 师徒商店，需不需要显示条件
		if g_i3k_game_context:GetLevel() >=i3k_db_master_cfg.cfg.apptc_min_lvl then
			g_i3k_ui_mgr:CloseUI(uiid) --关闭当前商店
			i3k_sbean.master_send_store_sync()
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end ,

	[5] = function (uiid)
		local openLevel = i3k_db_common.petRace.startLevel
		local roleLevel = g_i3k_game_context:GetLevel()
		if roleLevel >= openLevel then
			g_i3k_ui_mgr:CloseUI(uiid) --关闭当前商店
			i3k_sbean.syncPetRaceShop()
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end,
	
	[6] = function (uiid)
		local openLevel = i3k_db_server_limit.breakSealCfg.limitLevel
		local roleLevel = g_i3k_game_context:GetLevel()
		if roleLevel >= openLevel then
			g_i3k_ui_mgr:CloseUI(uiid) --关闭当前商店
			local data = i3k_sbean.fame_shopsync_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.fame_shopsync_res.getName())
		else
			g_i3k_ui_mgr:InvokeUIFunction(uiid, "goNextPage")
		end
	end,
	
}

function wnd_store_base:ctor()

end

function wnd_store_base:configure(...)

end

function wnd_store_base:onSubPage(sender)
	self._curState =1
	self._curPage = self._curPage -1
	self:gotoPage(self._curPage)
end

function wnd_store_base:onAddPage(sender)
	self._curState =2
	self._curPage = self._curPage +1
	self:gotoPage(self._curPage)
end

function wnd_store_base:goNextPage()
	if self._curState ==1 then
		self._curPage = self._curPage -1
	elseif self._curState ==2 then
		self._curPage = self._curPage +1
	end
	self:gotoPage(self._curPage)
end

function wnd_store_base:gotoPage(index)
	--1,押镖 2,竞技场 3,帮派，4 会武  5 师徒  6龟龟商城 7武林声望商城
	index = index + TOTAL_STORE
	local page = (index%TOTAL_STORE)
	if gotoStore[page] then
		gotoStore[page](self.__uiid)

	else
		g_i3k_ui_mgr:PopupTipMessage("这个商城好奇怪--vv")
	end
end

function wnd_store_base:enoughDiamond(diaCnt)
	local bindDia = g_i3k_game_context:GetDiamond(false)
	local freeDia = g_i3k_game_context:GetDiamond(true)

	local isEnough = (freeDia + bindDia) >= diaCnt
	local sub = bindDia - diaCnt
	return isEnough, sub
end

function wnd_store_base:openRefreshItemUI(specCoin, specCoinCnt, specCoinEnough, diamond, diamondSub,refreshTimes)
	g_i3k_ui_mgr:OpenUI(eUIID_StoreRefresh)
	g_i3k_ui_mgr:RefreshUI(eUIID_StoreRefresh,specCoin, specCoinCnt, specCoinEnough, diamond, diamondSub,refreshTimes)
end

function wnd_create(layout, ...)
	local wnd = wnd_store_base.new()
	wnd:create(layout, ...);

	return wnd
end
