-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_factionWareHouse = i3k_class("wnd_factionWareHouse",ui.wnd_base)

local WIDGETBPCKT = "ui/widgets/bpckt"
local WIDGETBPCKT2 = "ui/widgets/bpckt2"
local WIDGETBPCKSXT = "ui/widgets/bpcksxt"

local ALLEVENT = 1
local APPLEEVENT = 2 
local PERSONALEVENT = {
	[eFactionWhPeaceAward] = true,
	[eFactionWhAllotAward] = true,
	[eFactionWhPirceChange] = true,
	[eFactionWhFactionDonate] = true,
}

local INCOMETYPE =
{
	[eFactionWhPeaceAward] = true,
	[eFactionWhBattleBossAward] = true,			
	[eFactionWhBattleSuperBossAward] = true,			
	[eFactionWhFactionDonate] = true,					
}

function wnd_factionWareHouse:ctor()
	self._showType = 0 -- 1 全部 2 申请
	self._filterType = 1 -- 1 全部 2 收入 3 分配 4 个人记录
	self._applyState = 1 -- 1 全部申请 2 自己申请记录
	self._shareScore = 0 -- 共享积分
end

function wnd_factionWareHouse:configure()
	local widgets = self._layout.vars
	self.itemScroll = widgets.itemScroll
	self.recordScroll = widgets.recordScroll
	self.applyRecordBtn = widgets.applyRecordBtn
	self.filterBtn = widgets.filterBtn
	self.shareScore = widgets.shareScore
	widgets.ruleBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(1340))
	end)

	self.typeButton = {widgets.gradeBtn, widgets.applyRecordBtn}
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
	end
	-- 筛选
	widgets.gradeLabel:setText(i3k_get_string(1336))
	widgets.filterBtn:onClick(self,function ()
		if widgets.levelRoot:isVisible() then
			widgets.levelRoot:setVisible(false)
		else
			widgets.levelRoot:setVisible(true)
			widgets.filterScroll:removeAllChildren();
			for i = 1, 4 do
				local _item = require(WIDGETBPCKSXT)()
				_item.id = i
				_item.vars.levelLabel:setText(i3k_get_string(1335 + i));
				_item.vars.levelBtn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)
					widgets.gradeLabel:setText(_item.vars.levelLabel:getText())
					self._filterType = _item.id 
					self:setHouseShowType(ALLEVENT, true)
				end)
				widgets.filterScroll:addItem(_item);
			end
		end
	end)
	self.applyDesc = widgets.applyDesc
	self.personalFilterBtn = widgets.personalFilterBtn
	self.personalFilterDesc = widgets.personalFilterDesc
	widgets.personalFilterBtn:onClick(self, self.onPersonalFilter)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_factionWareHouse:refresh(sharItems, itemsPirce, score)
	self._info = {sharItems = sharItems, itemsPrice = itemsPirce, selfScore = score} 
	self:loadItemScroll(sharItems, itemsPirce)
	self:laodShareScore(score)
end

function wnd_factionWareHouse:laodShareScore(score, isAdd)
	self._shareScore = isAdd and self._shareScore + score or score
	self.shareScore:setText(i3k_get_string(1341, self._shareScore))
end

-- InvokeUIFunction
function wnd_factionWareHouse:updateShwoType(showType)
	self:setHouseShowType(self._showType == 0 and ALLEVENT or (showType or self._showType))
end

function wnd_factionWareHouse:loadItemScroll(items, itemsPirce)
	self.itemScroll:removeAllChildren()
	local showItems = self:itemSort(items)
	local allWidget = self.itemScroll:addChildWithCount(WIDGETBPCKT, 5, #showItems)
	for i, e in ipairs(allWidget) do
		local itemInfo = showItems[i]
		local price = itemsPirce[itemInfo.id]
		local widget = e.vars
		widget.count:setText("x"..itemInfo.count)
		if price then
			widget.price:setText(price)
		else
			local score = i3k_db_new_item[itemInfo.id].defaultScore
			
			if score == 0 then
				widget.price:setText(i3k_get_string(1449))
			else
				widget.price:setText(score)
			end		
		end
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemInfo.id, g_i3k_game_context:IsFemaleRole()))
		widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemInfo.id))
		widget.isShareIcon:setVisible(false)
		widget.bt:onClick(self, self.handleItem, itemInfo.id)
	end
end

--物品排序
function wnd_factionWareHouse:itemSort(items)
	local sort_items = {}
	for id, count in pairs(items) do
		table.insert(sort_items, {sortid = g_i3k_db.i3k_db_get_bag_item_order(id), id = id, count = count} )
	end
	table.sort(sort_items, function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items
end

function wnd_factionWareHouse:setHouseShowType(showType, force)
	if force or self._showType ~= showType then
		self._showType = showType
		local applyTimes = self:loadRecordScroll()
		self.applyDesc:setVisible(self._showType == APPLEEVENT)
		self.applyDesc:setText(i3k_get_string(1342, applyTimes, i3k_db_crossRealmPVE_shareCfg.maxApplyTimes))
		self.personalFilterBtn:setVisible(self._showType == APPLEEVENT)
		self.personalFilterDesc:setText(self._applyState == 1 and i3k_get_string(1343) or i3k_get_string(1344))
		for i, e in ipairs(self.typeButton) do
			e:stateToNormal(true)
		end
		self.typeButton[showType]:stateToPressed(true)
		self.recordScroll:jumpToListPercent(0)
	end
end

function wnd_factionWareHouse:onShowTypeChanged(sender, tag)
	if tag == ALLEVENT then
		i3k_sbean.sectshare_event_sync_request(tag)
	else
		i3k_sbean.sectshare_apply_sync_reqest(tag)
	end
end

function wnd_factionWareHouse:loadRecordScroll()
	local count = 0
	self.recordScroll:removeAllChildren()
	local recordInfo = self:getFilterRecord()
	local roleID = g_i3k_game_context:GetRoleId()
	for _, e in ipairs(recordInfo) do
		local info = e.eventInfo
		local isAdd = false
		if self._showType == ALLEVENT then
			if self._filterType == 1 then
				isAdd = true
			elseif self._filterType == 2 and INCOMETYPE[info.eventID] then
				isAdd = true			
			elseif self._filterType == 3 and info.eventID >= eFactionWhAllotAward and  info.eventID <= eFactionWhPirceChange then
				isAdd = true
			elseif self._filterType == 4 and PERSONALEVENT[info.eventID] and info.iArg == roleID then
				isAdd = true
			end
		elseif self._showType == APPLEEVENT then
			if info.roleID == roleID then
				count = count + 1
			end
			if self._applyState == 1 then
				isAdd = true
			elseif self._applyState == 2 and info.roleID == roleID then
				isAdd = true
			end
		end
		if isAdd then
			local node = require(WIDGETBPCKT2)()
			node.vars.desc:setText(e.desc)
			self.recordScroll:addItem(node)
		end
	end
	return count
end

function wnd_factionWareHouse:getFilterRecord()
	local info = {}
	local events = {}
	local roleId = g_i3k_game_context:GetRoleId()
	
	if self._showType == ALLEVENT then
		local sharEvents = g_i3k_game_context:getFactionWareHouseShareEvent()
		for i=#sharEvents, 1, -1 do
			local desc = g_i3k_db.i3k_db_get_faction_warehouse_event_desc(sharEvents[i])
			table.insert(events, {eventInfo = sharEvents[i], desc = desc})
		end
	else
		local shareApply = g_i3k_game_context:getFactionWareHouseShareApply()
		for i=#shareApply, 1, -1 do
			local info = shareApply[i]
			local id = info.itemID
			local desc
			
			if i3k_db_new_item[id].defaultScore == 0 and roleId ~= info.roleID then
				desc = i3k_get_string(1345, i3k_get_string(1450), g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_db.i3k_db_get_common_item_apply_count(id))
			else
				desc = i3k_get_string(1345, info.roleName, g_i3k_db.i3k_db_get_common_item_name(id), g_i3k_db.i3k_db_get_common_item_apply_count(id))
			end
			
			table.insert(events, {eventInfo = info, desc = desc})
		end
	end
	return events
end

function wnd_factionWareHouse:onPersonalFilter(sender)
	self._applyState = self._applyState == 1 and 2 or 1
	self:setHouseShowType(APPLEEVENT, true)
end

function wnd_factionWareHouse:handleItem(sender,id)
	g_i3k_ui_mgr:OpenUI(eUIID_WareHouseItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_WareHouseItem, id, self._info)
end	

function wnd_create(layout)
	local wnd = wnd_factionWareHouse.new()
	wnd:create(layout)
	return wnd
end
