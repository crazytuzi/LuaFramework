-- @Author: liaoxianbo
-- @Date:   2020-04-12 17:48:28
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-21 14:34:32
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerFloorMonsterView = class("QUIWidgetSoulTowerFloorMonsterView", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetMonsterHead = import(".QUIWidgetMonsterHead")

function QUIWidgetSoulTowerFloorMonsterView:ctor(options)
	local ccbFile = "ccb/Widget_SoulTower_monster.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulTowerFloorMonsterView.super.ctor(self, ccbFile, callBacks, options)
  	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSoulTowerFloorMonsterView:onEnter()
	self:initListView()
end

function QUIWidgetSoulTowerFloorMonsterView:onExit()
end

function QUIWidgetSoulTowerFloorMonsterView:initListView()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			local info,monsterId= itemBox:getMonsterHeadInfo()
			local monsterConfig = db:getMonstersById(self._waveMonsterInfo.dungeon_config_id)
			local monsetInfo = {npc_id = monsterId}
			app.tip:monsterTip(info,monsetInfo,true)
		end
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local bossId = self._monster[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetQlistviewItem.new()
	            	isCacheNode = false
	            end
	            self:setItemInfo(item,bossId,index)

	            info.item = item
	            info.size = item._ccbOwner.parentNode:getContentSize()

	            list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        enableShadow = false,
	        isVertical = false,
	        totalNumber = #self._monster,
	        autoCenter = true,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._monster})
	end	

end

function QUIWidgetSoulTowerFloorMonsterView:onTouchListView(event)
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._parentDialog:getContentListView()
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
		local contentListView = self._parentDialog:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetSoulTowerFloorMonsterView:setMonsterHead( waveInfo,parent)
	if q.isEmpty(waveInfo) then return end
	self._parentDialog = parent
	self._ccbOwner.tf_title:setString("第"..(waveInfo.index or 1).."组")	
	self._monster = {}
	self._waveMonsterInfo = remote.soultower:getMonsterInfoByWave(waveInfo.wave)
	if self._waveMonsterInfo and self._waveMonsterInfo.show_monster then
		self._monster = string.split(self._waveMonsterInfo.show_monster,",")
	end
	self:initListView()
end

function QUIWidgetSoulTowerFloorMonsterView:setItemInfo( item, data ,index)
	if not item._itemBox then
		item._itemBox = QUIWidgetMonsterHead.new()
		item._itemBox:setScale(0.8)
		item._itemBox:setPosition(ccp(50, 50))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(110, 110))

	end
    item._itemBox:setScale(0.8)
	item._itemBox:setHero(data)
	item._itemBox:setStar(0)
	item._itemBox:setBreakthrough(0)
	item._itemBox:setIsBoss(false)

end

function QUIWidgetSoulTowerFloorMonsterView:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetSoulTowerFloorMonsterView
