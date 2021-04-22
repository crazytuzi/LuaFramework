


local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroBattleArrayNew = class("QUIWidgetHeroBattleArrayNew", QUIWidget)
local QListView = import("...views.QListView")
local QUIWidgetHeroSmallFrame = import(".QUIWidgetHeroSmallFrame")
local QUIWidgetHeroSmallFrameHasState = import(".QUIWidgetHeroSmallFrameHasState")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")


QUIWidgetHeroBattleArrayNew.HERO_CHANGED = "HERO_CHANGED"
QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB = "EVENT_SELECT_TAB"


function QUIWidgetHeroBattleArrayNew:ctor(options)
	local ccbFile = "ccb/Widget_HeroBattleArray.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerAll", callback = handler(self, self._onTriggerAll)},
		{ccbCallbackName = "onTriggerTank", callback = handler(self, self._onTriggerTank)},
		{ccbCallbackName = "onTriggerHeal", callback = handler(self, self._onTriggerHeal)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerPAttack", callback = handler(self, self._onTriggerPAttack)},
		{ccbCallbackName = "onTriggerMAttack", callback = handler(self, self._onTriggerMAttack)},
		{ccbCallbackName = "onTriggerSoul", callback = handler(self, self._onTriggerSoul)},
		{ccbCallbackName = "onTriggerHelper", callback = handler(self, self._onTriggerHelper)},
		{ccbCallbackName = "onTriggerHelper2", callback = handler(self, self._onTriggerHelper2)},
		{ccbCallbackName = "onTriggerHelper3", callback = handler(self, self._onTriggerHelper3)},
		{ccbCallbackName = "onTriggerGodarm", callback = handler(self, self._onTriggerGodarm)},
		{ccbCallbackName = "onTriggerMain", callback = handler(self, self._onTriggerMain)},
		{ccbCallbackName = "onTriggerAlternate", callback = handler(self, self._onTriggerAlternate)},
	}
	QUIWidgetHeroBattleArrayNew.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._isAlternate = options.isAlternate or false

    self._state = options.state
    self._ccbOwner.tips:setString(options.tips or "")
	self._width = self._ccbOwner.sheet_layout:getContentSize().width
	self._items = {}
    self._lastItemNum =0
end

function QUIWidgetHeroBattleArrayNew:onEnter()
 

    self._ccbOwner.node_btn:setVisible(app.unlock:getUnlockHelperDisplay())


    self._ccbOwner.pAttack:setVisible(false)
    self._ccbOwner.mAttack:setVisible(false)


 --    if app.unlock:getUnlockTeamHelp4() then
 --    	self._ccbOwner.btn_helper:setVisible(false)
 --    	self._ccbOwner.btn_helper1:setVisible(true)
 --    else
 --    	self._ccbOwner.btn_helper:setVisible(true)
 --    	self._ccbOwner.btn_helper1:setVisible(false)
 --    end

 --    local isUnlock = app.unlock:getUnlockHelper()
	-- self._ccbOwner.node_helper:setVisible(isUnlock)
	-- self._ccbOwner.helperLock1:setVisible(not isUnlock)
	-- self._ccbOwner.helperLock2:setVisible(false)
	-- self._ccbOwner.helperLock3:setVisible(false)

	-- if app.unlock:getUnlockTeamHelp4() then
	-- 	if app.unlock:getUnlockTeamHelp5() == false then
	-- 		self._ccbOwner.helperLock2:setVisible(true)
	-- 	end
	-- 	self._ccbOwner.node_helper2:setVisible(true)
	-- else
	-- 	self._ccbOwner.node_helper2:setVisible(false)
	-- end
	-- if app.unlock:getUnlockTeamHelp8() then
	-- 	if app.unlock:getUnlockTeamHelp9() == false then
	-- 		self._ccbOwner.helperLock3:setVisible(true)
	-- 	end
	-- 	self._ccbOwner.node_helper3:setVisible(true)
	-- else
	-- 	self._ccbOwner.node_helper3:setVisible(false)
	-- end

	-- -- 替补战队按钮修改
	-- if self._isAlternate then
	-- 	self._ccbOwner.node_alternate:setVisible(true)
	-- 	self._ccbOwner.node_helper:setPositionX(self._ccbOwner.node_helper2:getPositionX())
	-- 	self._ccbOwner.node_helper2:setPositionX(self._ccbOwner.node_helper3:getPositionX())
	-- 	self._ccbOwner.node_helper3:setVisible(false)
	-- 	if not app.unlock:getUnlockTeamAlternateHelp5() then
	-- 		self._ccbOwner.node_helper2:setVisible(false)
	-- 	end
	-- end
	-- if app.unlock:getUnlockGodarm(false) then
	-- 	if self._isAlternate then
	-- 		if not self._ccbOwner.node_helper2:isVisible() then
	-- 			self._ccbOwner.node_godarm:setPositionX(self._ccbOwner.node_helper2:getPositionX())
	-- 		end			
	-- 	else
	-- 		if not self._ccbOwner.node_helper3:isVisible() then
	-- 			self._ccbOwner.node_godarm:setPositionX(self._ccbOwner.node_helper3:getPositionX())
	-- 		end
	-- 	end
	-- end
end

function QUIWidgetHeroBattleArrayNew:onExit()
 
    if self._schdulerHandler ~= nil then
    	scheduler.unscheduleGlobal(self._schdulerHandler)
    	self._schdulerHandler = nil
    end
end


function QUIWidgetHeroBattleArrayNew:initButtonByTeamIndexIds(TeamKeys)
	local btnTable = {}
	table.insert( btnTable , self._ccbOwner.node_btn )
	table.insert( btnTable , self._ccbOwner.node_helper )
	table.insert( btnTable , self._ccbOwner.node_helper2 )
	table.insert( btnTable , self._ccbOwner.node_helper3 )
	table.insert( btnTable , self._ccbOwner.node_godarm )
	self._ccbOwner.node_alternate:setVisible(false)
	local posTbl = {}
	for i,v in ipairs(btnTable) do
		v:setVisible(false)
		table.insert(posTbl,v:getPositionX())
	end

	for i,v in ipairs(TeamKeys) do
		btnTable[v]:setVisible(true)
		btnTable[v]:setPositionX(posTbl[i])
	end


end



function QUIWidgetHeroBattleArrayNew:refreshListData( data )
	self._items = data
	self:initListView()
end

function QUIWidgetHeroBattleArrayNew:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	-- if not self._state then
            			item = QUIWidgetHeroSmallFrame.new()
            			item:addEventListener(QUIWidgetHeroSmallFrame.EVENT_FORMATION_CLICK, handler(self, self._onHeroClick))
            		-- else
            		-- 	item = QUIWidgetHeroSmallFrameHasState.new()
            		-- end
	            	isCacheNode = false
	            end
	            item:setFormationInfo(itemData)
	            item:initGLLayer()
	            info.item = item
	            info.size = item:getContentSize()
	            info.tag = itemData.oType
                list:registerBtnHandler(index,"btn_team", "_onTriggerHeroOverview")
	            return isCacheNode
	        end,
	        isVertical = false,
	        curOriginOffset = 10,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 10,
	        totalNumber = #self._items,
		}
		self._lastItemNum = #self._items
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		if self._lastItemNum == #self._items then
			self._listViewLayout:refreshData() 
		else
			self._listViewLayout:reload({totalNumber = #self._items}) 
			self._lastItemNum = #self._items
		end
		-- self._listViewLayout:reload({totalNumber = #self._items})
	end
end



function QUIWidgetHeroBattleArrayNew:resetButtons()
	self._ccbOwner.btn_main:setEnabled(true)
	self._ccbOwner.btn_main:setHighlighted(false)
	self._ccbOwner.btn_alternate:setEnabled(true)
	self._ccbOwner.btn_alternate:setHighlighted(false)
	self._ccbOwner.btn_helper:setEnabled(true)
	self._ccbOwner.btn_helper:setHighlighted(false)
	self._ccbOwner.btn_helper1:setVisible(false)
	self._ccbOwner.btn_helper1:setEnabled(false)
	self._ccbOwner.btn_helper1:setHighlighted(false)
	self._ccbOwner.btn_helper2:setEnabled(true)
	self._ccbOwner.btn_helper2:setHighlighted(false)
	self._ccbOwner.btn_helper3:setEnabled(true)
	self._ccbOwner.btn_helper3:setHighlighted(false)
	self._ccbOwner.btn_godarm:setEnabled(true)
	self._ccbOwner.btn_godarm:setHighlighted(false)	

	self._ccbOwner.all:setEnabled(true)
	self._ccbOwner.all:setHighlighted(false)	
	self._ccbOwner.tank:setEnabled(true)
	self._ccbOwner.tank:setHighlighted(false)	
	self._ccbOwner.heal:setEnabled(true)
	self._ccbOwner.heal:setHighlighted(false)	
	self._ccbOwner.attack:setEnabled(true)
	self._ccbOwner.attack:setHighlighted(false)	
	self._ccbOwner.pAttack:setEnabled(true)
	self._ccbOwner.pAttack:setHighlighted(false)	
	self._ccbOwner.mAttack:setEnabled(true)
	self._ccbOwner.mAttack:setHighlighted(false)	
	self._ccbOwner.soul:setEnabled(true)
	self._ccbOwner.soul:setHighlighted(false)		
end

function QUIWidgetHeroBattleArrayNew:refreshButtonRedTips( tbl )

	self._ccbOwner.tip_main:setVisible(tbl[remote.teamManager.TEAM_INDEX_MAIN] ~= nil)
	self._ccbOwner.tip_helper1:setVisible(tbl[remote.teamManager.TEAM_INDEX_HELP] ~= nil)
	self._ccbOwner.tip_helper2:setVisible(tbl[remote.teamManager.TEAM_INDEX_HELP2] ~= nil)
	self._ccbOwner.tip_helper3:setVisible(tbl[remote.teamManager.TEAM_INDEX_HELP3] ~= nil)
	self._ccbOwner.tip_godarm:setVisible(tbl[remote.teamManager.TEAM_INDEX_GODARM] ~= nil)
end


function QUIWidgetHeroBattleArrayNew:refreshButtonDisplay( tbl )
	self:resetButtons()
	-- QPrintTable(tbl)
	if tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ALL then
		self._ccbOwner.all:setEnabled(false)
		self._ccbOwner.all:setHighlighted(true)		
	elseif tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_TANK then
		self._ccbOwner.tank:setEnabled(false)
		self._ccbOwner.tank:setHighlighted(true)		
	elseif tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_HEAL then
		self._ccbOwner.heal:setEnabled(false)
		self._ccbOwner.heal:setHighlighted(true)		
	elseif tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ATTACK then
		self._ccbOwner.attack:setEnabled(false)
		self._ccbOwner.attack:setHighlighted(true)		
	elseif tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_PATTACK then
		self._ccbOwner.pAttack:setEnabled(false)
		self._ccbOwner.pAttack:setHighlighted(true)		
	elseif tbl.jobType == QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_MATTACK then
		self._ccbOwner.mAttack:setEnabled(false)
		self._ccbOwner.mAttack:setHighlighted(true)		
	end

	if tbl.teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		self._ccbOwner.btn_main:setEnabled(false)
		self._ccbOwner.btn_main:setHighlighted(true)		
	elseif tbl.teamIndex == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.btn_helper:setEnabled(false)
		self._ccbOwner.btn_helper:setHighlighted(true)
	elseif tbl.teamIndex == remote.teamManager.TEAM_INDEX_HELP2 then
		self._ccbOwner.btn_helper2:setEnabled(false)
		self._ccbOwner.btn_helper2:setHighlighted(true)		
	elseif tbl.teamIndex == remote.teamManager.TEAM_INDEX_HELP3 then
		self._ccbOwner.btn_helper3:setEnabled(false)
		self._ccbOwner.btn_helper3:setHighlighted(true)		
	elseif tbl.teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.btn_godarm:setEnabled(false)
		self._ccbOwner.btn_godarm:setHighlighted(true)		
	end

	if tbl.elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self._ccbOwner.soul:setEnabled(false)
		self._ccbOwner.soul:setHighlighted(true)	
		self._ccbOwner.all:setEnabled(true)
		self._ccbOwner.all:setHighlighted(false)	
	end

end



function QUIWidgetHeroBattleArrayNew:_onHeroClick( event )
	local info = event.info
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.HERO_CHANGED, info = info})
end
	-- tbl.elementType = self._elementType
	-- tbl.trialNum = self._trialNum
	-- tbl.jobType = self._jobType
	-- tbl.teamIndex = self._teamIndex
function QUIWidgetHeroBattleArrayNew:_onTriggerAll(eventType)
   self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ALL})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerTank(eventType)
   self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_TANK})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerHeal(eventType)
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB,jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_HEAL})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerAttack(eventType)
   self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB,jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ATTACK})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerPAttack(eventType)
  self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_PATTACK})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerMAttack(eventType)
self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, jobType = QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_MATTACK})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerSoul(eventType)
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerHelper()
	app.sound:playSound("common_menu")
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = remote.teamManager.TEAM_INDEX_HELP})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerHelper2()
	app.sound:playSound("common_menu")
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = remote.teamManager.TEAM_INDEX_HELP2})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerHelper3()
	app.sound:playSound("common_menu")
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = remote.teamManager.TEAM_INDEX_HELP3})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerGodarm( )
	app.sound:playSound("common_menu")
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = remote.teamManager.TEAM_INDEX_GODARM})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerMain()
	app.sound:playSound("common_menu")
    self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = remote.teamManager.TEAM_INDEX_MAIN})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerAlternate()
	app.sound:playSound("common_menu")
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayNew.EVENT_SELECT_TAB, teamIndex = self._selectTeamIndex, isAlternate = isAlternate})
end

function QUIWidgetHeroBattleArrayNew:_onTriggerLeft( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(self._width*0.8, 0.8, false, nil, true)
	end
end

function QUIWidgetHeroBattleArrayNew:_onTriggerRight( ... )
	if self._listViewLayout then
		self._listViewLayout:startScrollToPosScheduler(-self._width*0.8, 0.8, false, nil, true)
	end
end

return QUIWidgetHeroBattleArrayNew