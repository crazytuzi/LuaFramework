--
-- zxs
-- 武魂战排行奖励
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarRankAwards = class("QUIDialogUnionDragonWarRankAwards", QUIDialog)
local QUIWidgetUnionDragonWarUnionAward = import("..widgets.dragon.QUIWidgetUnionDragonWarUnionAward")
local QUIWidgetUnionDragonWarUnionRank = import("..widgets.dragon.QUIWidgetUnionDragonWarUnionRank")
local QUIWidgetUnionDragonWarPersonalRank = import("..widgets.dragon.QUIWidgetUnionDragonWarPersonalRank")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QListView = import("...views.QListView")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIDialogUnionDragonWarRankAwards.TAB_UNION_RANK = "TAB_UNION_RANK"
QUIDialogUnionDragonWarRankAwards.TAB_UNION_AWARD = "TAB_UNION_AWARD"
QUIDialogUnionDragonWarRankAwards.TAB_PERSONAL_RANK = "TAB_PERSONAL_RANK"
QUIDialogUnionDragonWarRankAwards.TAB_SERVER_RANK = "TAB_SERVER_RANK"

local gap = 6

function QUIDialogUnionDragonWarRankAwards:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_paihang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerUnionRank", callback = handler(self, self._onTriggerUnionRank)},
		{ccbCallbackName = "onTriggerUnionAwards", callback = handler(self, self._onTriggerUnionAwards)},
		{ccbCallbackName = "onTriggerPersonalRank", callback = handler(self, self._onTriggerPersonalRank)},
		{ccbCallbackName = "onTriggerServerRank", callback = handler(self, self._onTriggerServerRank)},
	}
	QUIDialogUnionDragonWarRankAwards.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._tab = options.tab or self.TAB_UNION_AWARD

	self._data = {}
	self:selectTab(self._tab)

	self._ccbOwner.sp_union_award_tips:setVisible(false)
end

--初始化滑动区域
function QUIDialogUnionDragonWarRankAwards:initListView()
	local layoutSize = self._ccbOwner.sheet_layout:getContentSize()
	self._ccbOwner.sheet_layout:setPositionY(-layoutSize.height-gap/2)
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = true,
	     	enableShadow = false,
	        spaceX = 3,
	        spaceY = -3,
	        contentOffsetX = -3,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:resetTouchRect()
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogUnionDragonWarRankAwards:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]

    local item = list:getItemFromCache(self._tab)
    if not item then    
		if self._tab == self.TAB_UNION_AWARD then
			item = QUIWidgetUnionDragonWarUnionAward.new()
		elseif self._tab == self.TAB_UNION_RANK then
			item = QUIWidgetUnionDragonWarUnionRank.new()
		elseif self._tab == self.TAB_PERSONAL_RANK then
			item = QUIWidgetUnionDragonWarPersonalRank.new()
		elseif self._tab == self.TAB_SERVER_RANK then
			item = QUIWidgetUnionDragonWarPersonalRank.new()
    	end
    	item.tag = self._tab
        isCacheNode = false
    end

    if self._tab == self.TAB_UNION_AWARD then
    	item:setInfo(data, self._unionFloorConfig)
    	item:registerItemBoxPrompt(index,list)
    else
    	item:setInfo(data, self._tab == self.TAB_PERSONAL_RANK)
    end
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

function QUIDialogUnionDragonWarRankAwards:resetUI(tab)
	self._ccbOwner.btn_union_award:setEnabled(not (tab == self.TAB_UNION_AWARD))
	self._ccbOwner.btn_union_award:setHighlighted(tab == self.TAB_UNION_AWARD)

	self._ccbOwner.btn_union_rank:setEnabled(not (tab == self.TAB_UNION_RANK))
	self._ccbOwner.btn_union_rank:setHighlighted(tab == self.TAB_UNION_RANK)

	self._ccbOwner.btn_personal_rank:setEnabled(not (tab == self.TAB_PERSONAL_RANK))
	self._ccbOwner.btn_personal_rank:setHighlighted(tab == self.TAB_PERSONAL_RANK)

	self._ccbOwner.btn_server_rank:setEnabled(not (tab == self.TAB_SERVER_RANK))
	self._ccbOwner.btn_server_rank:setHighlighted(tab == self.TAB_SERVER_RANK)

	self._ccbOwner.node_rank:setVisible(false)
end

function QUIDialogUnionDragonWarRankAwards:selectTab(tab)
	self._tab = tab
	self:resetUI(tab)
	if self._listView ~= nil then
		self._listView:clear()
	end

	self._ccbOwner.tf_tip:setVisible(false)
	if tab == QUIDialogUnionDragonWarRankAwards.TAB_UNION_AWARD then
		self:selectUnionAward()
	elseif tab == QUIDialogUnionDragonWarRankAwards.TAB_UNION_RANK then
		self:selectUnionRank()
	elseif tab == QUIDialogUnionDragonWarRankAwards.TAB_PERSONAL_RANK then
		self:selectPersonalRank()
	elseif tab == QUIDialogUnionDragonWarRankAwards.TAB_SERVER_RANK then
		self:selectServerRank()
	end
end

--选中宗门奖励
function QUIDialogUnionDragonWarRankAwards:selectUnionAward()
	local floor = remote.unionDragonWar:getDragonFloor()
	self._unionFloorConfig = db:getUnionDragonFloorInfoByFloor(floor)
	if self._unionAwardsConfigs == nil then
		local configs = db:getDragonFloorAwardsByLevel(remote.user.level)
		table.sort(configs, function (a,b)
			return a.dan < b.dan
		end)
		self._unionAwardsConfigs = {}
		for _,v in ipairs(configs) do
			if floor <= v.dan and v.dan <= floor+7 then
				table.insert(self._unionAwardsConfigs, v)
			end
		end
	end
	self._data = self._unionAwardsConfigs
	self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 434)) 
	self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 440)) 
	self:initListView()
end

--选中宗门排行
function QUIDialogUnionDragonWarRankAwards:selectUnionRank()
	local callback = function ()
		self._data = self._unionRankData
		self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 360))
		self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 366)) 
		self._ccbOwner.node_rank:setVisible(true)
		self:initListView()

		local unionScore = 0
		local awards = {}
		local rank = 0
		if self._myselfUnionRankData ~= nil then
			rank = self._myselfUnionRankData.rank or 0
			unionScore = self._myselfUnionRankData.consortiaScore or 0
		end
		if rank > 0 then
			self._ccbOwner.myRank:setVisible(true)
			self._ccbOwner.tf_no_rank:setVisible(false)
			self._ccbOwner.myRank:setString(self._myselfUnionRankData.rank)
		else
			self._ccbOwner.myRank:setVisible(false)
			self._ccbOwner.tf_no_rank:setVisible(true)
		end

		local floor = self._myselfUnionRankData.consortiaFloor
		if floor then
			-- 段位icon
			if self._floorIcon == nil then
				self._floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
				self._ccbOwner.node_floor:removeAllChildren()
				self._ccbOwner.node_floor:setScale(0.6)
		 		self._ccbOwner.node_floor:addChild(self._floorIcon)
		 	end
			self._floorIcon:setInfo(floor, "unionDragonWar")
			self._ccbOwner.node_floor:setVisible(true)
		else
			self._ccbOwner.node_floor:setVisible(false)
		end

		self._ccbOwner.tf_level:setString("LV."..(remote.union.consortia.level or ""))
		self._ccbOwner.node_empty:setVisible(#self._data == 0)
		self._ccbOwner.tf_name:setString(remote.union.consortia.name or "")		
		self._ccbOwner.tf_desc:setString("宗门积分："..unionScore)
		self._ccbOwner.tf_vip:setVisible(false)
		
		local unionAvatar = QUnionAvatar.new(self._myselfUnionRankData.icon)
		self._ccbOwner.node_head:removeAllChildren()
		self._ccbOwner.node_head:addChild(unionAvatar)
	end

	if self._unionRankData == nil then
		app:getClient():top50RankRequest("DRAGON_WAR_CONSORTIA_SCORE_TOP_10", remote.user.userId, function (data)
			if data.consortiaRankings ~= nil then
				self._unionRankData = data.consortiaRankings.top50 or {}
			end
			self._myselfUnionRankData = data.consortiaRankings.myself
			callback()
		end)
	else
		callback()
	end
end

--选中个人奖励
function QUIDialogUnionDragonWarRankAwards:selectPersonalRank()
	local callback = function ()
		self._data = {}
		for i, v in pairs(self._personalRankData) do
			self._data[i] = v
		end
		-- self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 410)) 
		-- self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 440)) 
		-- self._ccbOwner.tf_tip:setPositionY(-250)


		self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 336))
		self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 366)) 
		self._ccbOwner.tf_tip:setPositionY(-177)


		self:initListView()
		self._ccbOwner.node_rank:setVisible(true)

		local awards = {}
		local rank = 0
		if self._myselfRankData ~= nil then
			rank = self._myselfRankData.rank or 0
		end
		if rank == 0 then
			self._ccbOwner.myRank:setVisible(false)
			self._ccbOwner.tf_no_rank:setVisible(true)
		else
			self._ccbOwner.myRank:setVisible(true)
			self._ccbOwner.tf_no_rank:setVisible(false)
			self._ccbOwner.myRank:setString(rank)
		end
		self._ccbOwner.tf_level:setString("LV."..(self._myselfRankData.level or ""))
		self._ccbOwner.tf_name:setString(self._myselfRankData.name or "")
		local hurt, unit = q.convertLargerNumber((self._myselfRankData.todayHurt or 0))
		local str = "今日累计伤害："..hurt..unit
		if self._myselfRankData.fightCount and self._myselfRankData.fightCount ~= 0 then
			str = str.." (共"..self._myselfRankData.fightCount.."次)"
		end
		self._ccbOwner.tf_desc:setString(str)
		local isEmpty = #self._data == 0
		self._ccbOwner.node_empty:setVisible(isEmpty)
		self._ccbOwner.node_floor:setVisible(false)
		if isEmpty == false then
			self._ccbOwner.tf_tip:setVisible(true)
		end
		self._ccbOwner.tf_vip:setVisible(true)
		self._ccbOwner.tf_vip:setString("VIP"..(self._myselfRankData.vip or ""))
		local avatar = QUIWidgetAvatar.new()
		avatar:setInfo(self._myselfRankData.avatar)
		avatar:setSilvesArenaPeak(self._myselfRankData.championCount)
		self._ccbOwner.node_head:removeAllChildren()
		self._ccbOwner.node_head:addChild(avatar)
	end

	if self._personalRankData == nil then
		self._myselfRankData = {}
		app:getClient():top50RankRequest("DRAGON_WAR_USER_TODAY_HURT_TOP_10", remote.user.userId, function (data)
			if data.rankings ~= nil then
				self._personalRankData = data.rankings.top50 or {}
			end
			self._myselfRankData = data.rankings.myself
			callback()
		end)
	else
		callback()
	end
end

--选中本服排行
function QUIDialogUnionDragonWarRankAwards:selectServerRank()
	local callback = function ()
		self._data = {}
		for i, v in pairs(self._serverRankData) do
			self._data[i] = v
		end
		-- self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 336))
		-- self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 366)) 
		-- self._ccbOwner.tf_tip:setPositionY(-177)


		self._ccbOwner.sheet_layout:setContentSize(CCSize(680, 410)) 
		self._ccbOwner.s9s_bg:setContentSize(CCSize(684, 440)) 
		self._ccbOwner.tf_tip:setPositionY(-250)


		self._ccbOwner.node_rank:setVisible(false)
		self:initListView()

		local awards = {}
		local rank = 0
		if self._myselfServerRankData ~= nil then
			rank = self._myselfServerRankData.rank or 0
		end
		if rank == 0 then
			self._ccbOwner.myRank:setVisible(false)
			self._ccbOwner.tf_no_rank:setVisible(true)
		else
			self._ccbOwner.myRank:setVisible(true)
			self._ccbOwner.tf_no_rank:setVisible(false)
			self._ccbOwner.myRank:setString(rank)
		end
		self._ccbOwner.tf_level:setString("LV."..(self._myselfServerRankData.level or "1"))
		local hurt, unit = q.convertLargerNumber((self._myselfServerRankData.todayHurt or 0))
		self._ccbOwner.tf_name:setString(self._myselfServerRankData.name or "")
		self._ccbOwner.tf_desc:setString("今日累计伤害："..hurt..unit)

		local isEmpty = #self._data == 0
		self._ccbOwner.node_empty:setVisible(isEmpty)
		self._ccbOwner.node_floor:setVisible(false)
		if isEmpty == false then
			self._ccbOwner.tf_tip:setVisible(true)
		end
		--添加个人信息vip显示并进行缩进
		self._ccbOwner.tf_vip:setString("VIP"..(self._myselfServerRankData.vip or ""))
		local nodes = {}
		table.insert(nodes, self._ccbOwner.tf_level)
		table.insert(nodes, self._ccbOwner.tf_name)
		table.insert(nodes, self._ccbOwner.tf_vip)
		q.autoLayerNode(nodes, "x", 5)


		local avatar = QUIWidgetAvatar.new()
		avatar:setInfo(self._myselfServerRankData.avatar)
		avatar:setSilvesArenaPeak(self._myselfServerRankData.championCount)
		self._ccbOwner.node_head:removeAllChildren()
		self._ccbOwner.node_head:addChild(avatar)
	end

	if self._serverRankData == nil then
		app:getClient():top50RankRequest("DRAGON_WAR_USER_TODAY_HURT_THIS_SERVER", remote.user.userId, function (data)
			if data.rankings ~= nil then
				self._serverRankData = data.rankings.top50 or {}
			end
			self._myselfServerRankData = data.rankings.myself
			callback()
		end)
	else
		callback()
	end
end


function QUIDialogUnionDragonWarRankAwards:_onTriggerUnionAwards()
    app.sound:playSound("common_switch")
	self:selectTab(QUIDialogUnionDragonWarRankAwards.TAB_UNION_AWARD)
end

function QUIDialogUnionDragonWarRankAwards:_onTriggerUnionRank()
    app.sound:playSound("common_switch")
	self:selectTab(QUIDialogUnionDragonWarRankAwards.TAB_UNION_RANK)
end

function QUIDialogUnionDragonWarRankAwards:_onTriggerPersonalRank()
    app.sound:playSound("common_switch")
	self:selectTab(QUIDialogUnionDragonWarRankAwards.TAB_PERSONAL_RANK)
end

function QUIDialogUnionDragonWarRankAwards:_onTriggerServerRank()
    app.sound:playSound("common_switch")
	self:selectTab(QUIDialogUnionDragonWarRankAwards.TAB_SERVER_RANK)
end

function QUIDialogUnionDragonWarRankAwards:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
    self:_close()
end

function QUIDialogUnionDragonWarRankAwards:_backClickHandler()
    app.sound:playSound("common_close")
    self:_close()
end

function QUIDialogUnionDragonWarRankAwards:_close()
	self:playEffectOut()
end

return QUIDialogUnionDragonWarRankAwards