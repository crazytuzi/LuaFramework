--
-- Author: Your Name
-- Date: 2014-11-28 17:33:14
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityInstance = class("QUIWidgetActivityInstance", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

QUIWidgetActivityInstance.EVENT_END = "EVENT_END"

function QUIWidgetActivityInstance:ctor()
	local ccbFile = "ccb/Widget_TimeMachine_choose.ccbi"
	local callBacks = {
			-- {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetActivityInstance._onTriggerClick)},
		}
	QUIWidgetActivityInstance.super.ctor(self,ccbFile,callBacks,options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetActivityInstance:setInfo(info, index)
  	self._info = info
    local headImageTexture =CCTextureCache:sharedTextureCache():addImage(self._info.dungeon_icon)
    self._imgSp = CCSprite:createWithTexture(headImageTexture)
    local size = self._ccbOwner.head_cricle_di:getContentSize()
    self._imgSp:setScale(size.width/self._imgSp:getContentSize().width)
    self._ccbOwner.content:removeAllChildren()
    self._ccbOwner.content:addChild(self._imgSp)

    self.dungeonInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._info.dungeon_id)
    for i=1,13,1 do
        if self._ccbOwner["node_"..i] ~= nil then self._ccbOwner["node_"..i]:setVisible(false) end
        self._ccbOwner["node_name_"..i]:setVisible(false)
    end
    local unlockLevel = self._info.unlock_team_level or 0
    local perPassInfo,perDungeon = remote.activityInstance:getPerPassInfoById(self._info.dungeon_id)
    self._perDungeon = perDungeon
    self._isPass = false
    if perDungeon == nil or (perPassInfo ~= nil and perPassInfo.star == 3) then
      self._isPass = true
    end
    local _node = nil
    if index < 4 then
      -- self._ccbOwner.node_1:setVisible(true)
      -- _node = self._ccbOwner.node_1
    elseif index < 7 then
      _node = self._ccbOwner.node_4
      _node:setVisible(true)
    else
      _node = self._ccbOwner.node_6
      _node:setVisible(true)
    end

    if self._ccbOwner["node_name_"..index] ~= nil then self._ccbOwner["node_name_"..index]:setVisible(true) end
    if unlockLevel <= remote.user.level and self._isPass == true then
        self._ccbOwner.sp_lock:setVisible(false)
        makeNodeFromGrayToNormal(self)
        if self._ccbOwner.node_jiesuo ~= nil then self._ccbOwner.node_jiesuo:setVisible(false) end
    else 
        makeNodeFromNormalToGray(self)
        if unlockLevel <= remote.user.level then
          self._ccbOwner.sp_lock:setVisible(false)
          local dungeonInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._perDungeon.dungeon_id)
          if self._ccbOwner.node_jiesuo ~= nil then self._ccbOwner.node_jiesuo:setVisible(false) end
        else
          self._ccbOwner.sp_lock:setVisible(true)
          if self._ccbOwner["node_name_"..index] ~= nil then self._ccbOwner["node_name_"..index]:setVisible(false) end
          if self._ccbOwner.node_jiesuo ~= nil then self._ccbOwner.node_jiesuo:setVisible(true) end
          setShadow5(self._ccbOwner.tf_jiesuo, ccc3(41, 0, 0))
          setShadow5(self._ccbOwner.tf_kaiqi, ccc3(41, 0, 0))
          if self._ccbOwner.tf_jiesuo ~= nil then self._ccbOwner.tf_jiesuo:setString(unlockLevel.."级") end
          -- if _node ~= nil then
          --   -- _node:setVisible(false)
          --   if self._ccbOwner["node_name_"..index] ~= nil then self._ccbOwner["node_name_"..index]:setVisible(false) end
          -- end
        end
    end
end

function QUIWidgetActivityInstance:getIsPass(isTips)
  if isTips == true then
      local unlockLevel = self._info.unlock_team_level or 0
      if unlockLevel <= remote.user.level then
        if self._isPass ~= true then
          local dungeonInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._perDungeon.dungeon_id)
          app.tip:floatTip(string.format("通关%s可进入",dungeonInfo.name))
       end
      else
        app.tip:floatTip("战队"..unlockLevel.."级解锁")
      end
  end
  return ((self._info.unlock_team_level or 0) <= remote.user.level and self._isPass == true)
end

function QUIWidgetActivityInstance:onEnter()
    self._ccbOwner.head_cricle_di:setTouchEnabled(true)
    self._ccbOwner.head_cricle_di:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.head_cricle_di:setTouchSwallowEnabled(false)
    self._ccbOwner.head_cricle_di:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetActivityInstance._onTouch))
end

function QUIWidgetActivityInstance:onExit()
  self._ccbOwner.head_cricle_di:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
end

function QUIWidgetActivityInstance:_onTouch(event)
  	if event.name == "began" then
    	-- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetActivityInstance.EVENT_BEGAIN , eventTarget = self, info = self.info, config = self.config})
    	return true
  	elseif event.name == "ended" or event.name == "cancel" then
      self:dispatchEvent({name = QUIWidgetActivityInstance.EVENT_END , info = self._info, cell = self})
  	end
end

return QUIWidgetActivityInstance