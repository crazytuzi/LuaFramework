-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_breakSeal = i3k_class("wnd_breakSeal", ui.wnd_base)

local BREAKCFG = i3k_db_server_limit.breakSealCfg
local ITEMINFO = i3k_db_server_limit.breakSealCfg.iteminfo

function wnd_breakSeal:ctor()
	
end

function wnd_breakSeal:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.shop_btn:onClick(self, self.openShop)
	widgets.help_btn:onClick(self, self.showHelp)
	widgets.description:setText(i3k_get_string(16879))
	widgets.talk:setText(i3k_get_string(16882))
end

function wnd_breakSeal:refresh(info)
	self:setCountInfo(info.dayAddFame)
	self:showProgress(info.exp)
	self:setItemInfo(info.npcId)
	self:showNpcInfo(info.npcId)
end

function wnd_breakSeal:setItemInfo(npcId) 
	local allItemId = self:getSortItems()
	local scroll = self._layout.vars.item_scroll
	scroll:removeAllChildren()
	for i, v in ipairs(allItemId) do
		local count = 0
		if g_i3k_game_context:isSealBreak() then
			count = ITEMINFO[i].count[2]
		else
		    count = ITEMINFO[i].count[1]
		end	 
		local info = {dayLeftFame = self.dayLeftFame, id = v, NpcId = npcId, itemPoint = count}
		local widget = require("ui/widgets/fengyint")()
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, g_i3k_game_context:IsFemaleRole()))
		widget.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		widget.vars.lock:setVisible(v > 0)
		widget.vars.num:setText("x" .. g_i3k_game_context:GetCommonItemCanUseCount(v))
		widget.vars.btn:onClick(self, self.donateItem, info)
		widget.vars.point:setText(count .. "点/个")
		scroll:addItem(widget)
	end
end

function wnd_breakSeal:showProgress(point)
	self._layout.vars.point_bar:setPercent(point * 100/BREAKCFG.totalBreakPoint)
    local nTemp = math.floor((point * 100 / BREAKCFG.totalBreakPoint) * 10);
    local nRet = nTemp / 10;
	self._layout.vars.bar_value:setText(nRet .."%")
	if point >= BREAKCFG.totalBreakPoint then
		self._layout.vars.jindu:setText("破解成功")
		self._layout.vars.bar_value:setText(100 .."%")
	end
end

function wnd_breakSeal:getSortItems()
	local allId = {}
	for i, v in ipairs(ITEMINFO) do
		table.insert(allId, ITEMINFO[i].Itemid)
	end
	return allId
end

function wnd_breakSeal:donateItem(sender, info)
	--local tbl = {}
	--if g_i3k_game_context:GetCommonItemCanUseCount(info.id) == 1 then
	--	tbl.id = info.id
	--	tbl.count = 1
	--	if g_i3k_game_context:IsExcNeedShowTip(g_DONATE_GETFAME_TYPE) then
	--		g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
	--		g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_DONATE_GETFAME_TYPE, tbl)
	--	else 
	--		i3k_sbean.breakSeal_donate(tbl)
	if info.dayLeftFame <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("您今日已达到上限")
	elseif g_i3k_game_context:GetCommonItemCanUseCount(info.id) > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ExchangeFame)
		g_i3k_ui_mgr:RefreshUI(eUIID_ExchangeFame, info)
	else 
		g_i3k_ui_mgr:ShowCommonItemInfo(info.id)
	end
end

function wnd_breakSeal:setCountInfo(count)
	local totalCount = 0
	if g_i3k_game_context:isSealBreak() then
		totalCount = BREAKCFG.afterMaxBreakPoint
	else
		totalCount = BREAKCFG.beforeMaxBreakPoint
	end 
	self._layout.vars.count_info:setText(i3k_get_string(16881, totalCount, count))
	self.dayLeftFame = totalCount - count
end

function wnd_breakSeal:openShop()
	local syncShop = i3k_sbean.fame_shopsync_req.new()
	i3k_game_send_str_cmd(syncShop, i3k_sbean.fame_shopsync_res.getName())
end

function wnd_breakSeal:showHelp()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16874, BREAKCFG.donationBreakPoint, i3k_db_server_limit.sealLevel))
end

function wnd_breakSeal:showNpcInfo(npcId)
--	local npcModule = self._layout.vars.wizardModel
	local name = i3k_db_npc[npcId].remarkName
--	local modelId = g_i3k_db.i3k_db_get_npc_modelID(npcId) 
--	ui_set_hero_model(npcModule, modelId)
	self._layout.vars.npc_name:setText(i3k_get_string(16880, name))
end

function wnd_create(layout)
	local wnd = wnd_breakSeal.new()
	wnd:create(layout)
	return wnd
end
