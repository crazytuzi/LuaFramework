-- @Author: xurui
-- @Date:   2016-12-14 18:44:12
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-24 15:56:36
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInvasionKillAwardClient = class("QUIWidgetInvasionKillAwardClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSilverMineBox = import("..widgets.QUIWidgetSilverMineBox")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView")

QUIWidgetInvasionKillAwardClient.KILL_AWARD_TYPE = "KILL_TYPE"
QUIWidgetInvasionKillAwardClient.SHARE_AWARD_TYPE = "SHARE_TYPE"

QUIWidgetInvasionKillAwardClient.GET_AWARD = "GET_AWARD"

function QUIWidgetInvasionKillAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_panjun_jishajiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
	}
	QUIWidgetInvasionKillAwardClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:showAwardsState(true)
end


function QUIWidgetInvasionKillAwardClient:showAwardsState(flag)
	self._ccbOwner.sp_canget:setVisible(flag)
	self._ccbOwner.sp_title_normal:setVisible(not flag)
	self._ccbOwner.sp_title_done:setVisible(flag)	
end
function QUIWidgetInvasionKillAwardClient:onEnter()
end

function QUIWidgetInvasionKillAwardClient:onExit()
end

function QUIWidgetInvasionKillAwardClient:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.reandFunHandler),
	        isVertical = false,
	        totalNumber = #self.awardsInfo,
	        spaceX = 5,
	        curOffset = 10,
	        enableShadow = false,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self.awardsInfo})
	end

end

function QUIWidgetInvasionKillAwardClient:reandFunHandler( list, index, info )
    local isCacheNode = true
    local item = list:getItemFromCache()
    local isGoldPickaxe = false

    if not item then
        item = QUIWidgetSilverMineBox.new()
        isCacheNode = false
    end

	local data = string.split(self.awardsInfo[index], "^")
	local itemType = ITEM_TYPE.ITEM
	if tonumber(data[1]) == nil then
		itemType = data[1]
	end

    item:update(tonumber(data[1]), itemType, tonumber(data[2]))
    -- item:setScale(0.7)
    info.item = item
    info.size = item:getContentSize()
    info.size.width = info.size.width + 10
    list:registerItemBoxPrompt(index, 1, item:getItemBox(), nil, nil)

	table.insert(self._awards, {id = tonumber(data[1]), typeName = itemType, count = tonumber(data[2])})
    return isCacheNode
end

function QUIWidgetInvasionKillAwardClient:setInfo(param)
	self._parent = param.parent
	self._awardInfo = param.award
	self._index = param.index
	if self._awardInfo == nil then return end
	
	self._awards = {}
	if self._awardInfo.awardType == self.KILL_AWARD_TYPE then
		self._ccbOwner.tf_award_type:setString("击杀奖励")
		self._title = "成功击杀入侵boss，攻击获得击杀奖励"
	else
		self._ccbOwner.tf_award_type:setString("发现奖励")
		self._title = "你发现的入侵boss已被击杀，恭喜获得发现奖励"
	end

	self._ccbOwner.tf_kill_name:setString("")
	self._ccbOwner.tf_share_name:setString("")
	if self._awardInfo.killed_user_name then
		self._ccbOwner.tf_kill_name:setString(self._awardInfo.killed_user_name)
	end
	if self._awardInfo.shared_user_name then
		self._ccbOwner.tf_share_name:setString(self._awardInfo.shared_user_name)
	end

	local awardStr = self._awardInfo.awardStr
	self.awardsInfo = string.split(awardStr, ";")
	self:_initListView()
end

function QUIWidgetInvasionKillAwardClient:onTouchListView( event )
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._parent:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._parent:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetInvasionKillAwardClient:_onTriggerGet(event)
   	self:dispatchEvent({name = QUIWidgetInvasionKillAwardClient.GET_AWARD, awardId = self._awardInfo.awardId, award = self._awards, title = self._title})
end

function QUIWidgetInvasionKillAwardClient:getContentSize()
	return self._ccbOwner.sp_cell_size:getContentSize()
end

return QUIWidgetInvasionKillAwardClient