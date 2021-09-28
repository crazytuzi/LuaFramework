-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_retrieve_activity = i3k_class("wnd_retrieve_activity", ui.wnd_base)

-- 按钮三种状态 普通，选中，未解锁
local NORMAL_ICON = i3k_db_common.activity.normalIcon
local SELECT_ICON = i3k_db_common.activity.selectIcon
local DISABLE_ICON = i3k_db_common.activity.disableIcon

function wnd_retrieve_activity:ctor()
	self._dungeonTable = {}
	self.cfg = nil
	self.cost = 0
	self.buyTimes = 0
end

function wnd_retrieve_activity:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_retrieve_activity:refresh(groupId, name, icon)
	self.groupId = groupId

	local rdb= g_i3k_game_context:GetRetrieveActData()
	local vars = self._layout.vars
	local totalCnt = rdb.lastTimes[groupId]

	vars.descTxt:setText(i3k_get_string(15187))
	vars.actIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
	vars.name:setText(name)
	vars.name2:setText(name)

	vars.okBtn:onClick(self, self.enterSweep)

	for i,v in pairs(i3k_db_activity_cfg) do
		if v.groupId==groupId then
			table.insert(self._dungeonTable, v)
		end
	end
	table.sort(self._dungeonTable, function (a, b)
		return a.difficulty<b.difficulty
	end)
	local index = 0
	local hoster = nil
	vars.scroll:removeAllChildren()
	for i,dungeon in ipairs(self._dungeonTable) do
		local node = require("ui/widgets/hdlx2t")()
		local widgets = node.vars
		
		local record = g_i3k_game_context:getActMapRecord(groupId, dungeon.id)
		if (dungeon.groupId <= 2 and record > 0) or record / 10000 >= 1 then
			widgets.difficultyBtn:onClick(self, self.selectDifficulty, dungeon)
			widgets.lock:hide()
			widgets.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON[dungeon.difficulty]))
			index = i
			hoster = widgets.difficultyBtn
		else
			widgets.lock:show()
			widgets.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(DISABLE_ICON[dungeon.difficulty]))
			widgets.difficultyBtn:setTouchEnabled(false)
		end
		vars.scroll:addItem(node)
	end

	self.cfg = nil
	if index ~= 0 then
		self:selectDifficulty(hoster, self._dungeonTable[index])
	else
		vars.okBtn:disable()
	end
	self:GetCost(groupId)
end

function wnd_retrieve_activity:GetCost(groupId)
	local rdb= g_i3k_game_context:GetRetrieveActData()

	local dbretAct = i3k_db_retrieve_act
	local buyTimes = rdb.dayBuyTimes[groupId] and rdb.dayBuyTimes[groupId] + 1 or 1
	buyTimes = buyTimes > #dbretAct[groupId] and #dbretAct[groupId] or buyTimes

	self.cost, self.buyTimes = dbretAct[groupId][buyTimes], buyTimes
	self._layout.vars.costTxt:setText(self.cost)
	self._layout.vars.remainCnt:setText(rdb.lastTimes[groupId])
end

function wnd_retrieve_activity:enterSweep(sender)
	if not self.cfg then
		return
	end 
	local roleLevel = g_i3k_game_context:GetLevel()
	local cfg = self.cfg
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local retrieveAct = i3k_db_kungfu_vip[vipLvl].retrieveAct
	local rdb= g_i3k_game_context:GetRetrieveActData()
	
	if roleLevel < cfg.needLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15460))
	end

	if retrieveAct[cfg.groupId] <= 0 then
		return g_i3k_ui_mgr:PopupTipMessage("该VIP等级不能补做")
	elseif rdb.dayBuyTimes[cfg.groupId] and rdb.dayBuyTimes[cfg.groupId]+1 > retrieveAct[cfg.groupId] then
		return g_i3k_ui_mgr:PopupTipMessage("补做次数已用完")
	elseif g_i3k_game_context:GetDiamondCanUse(false) < i3k_db_retrieve_act[cfg.groupId][self.buyTimes] then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(612))
	else
		i3k_sbean.activity_last_quick_doneReq(cfg.id,self.buyTimes,self.cost,cfg.groupId)
	end
end

function wnd_retrieve_activity:selectDifficulty(sender, cfg)
	if self.cfg == cfg then
		return
	end
	local scroll = self._layout.vars.scroll
	sender:setImage(g_i3k_db.i3k_db_get_icon_path(SELECT_ICON[cfg.difficulty]))
	local nodeItem = scroll:getChildAtIndex(cfg.difficulty)
	nodeItem.vars.isSelect:show()
	if self.cfg then	
		local nodeItem = scroll:getChildAtIndex(self.cfg.difficulty)
		nodeItem.vars.isSelect:hide()
		nodeItem.vars.difficultyBtn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON[self.cfg.difficulty]))
	end
	self.cfg = cfg
end

function wnd_retrieve_activity:onHide( )
	if  g_i3k_game_context:IsRetrieveActExist() then
		g_i3k_ui_mgr:OpenUI(eUIID_RetrieveChoose)
		g_i3k_ui_mgr:RefreshUI(eUIID_RetrieveChoose)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_retrieve_activity.new()
	wnd:create(layout, ...)
	return wnd;
end
