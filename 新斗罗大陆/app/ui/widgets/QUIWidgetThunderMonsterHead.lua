--
-- Author: xurui
-- Date: 2015-08-12 15:53:52
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetThunderMonsterHead = class("QUIWidgetThunderMonsterHead", QUIWidget)
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetThunderMonsterHead.CLICK_MONSTER_HEAD = "MONSTER_EVENT_END"

function QUIWidgetThunderMonsterHead:ctor(options)
	local ccbFile = "ccb/Widget_EliteInfo_MonsterHead.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
	QUIWidgetThunderMonsterHead.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isLock = false
    self._isSelect = false
    self._ccbOwner.title_node:setVisible(false)
end

function QUIWidgetThunderMonsterHead:getSize()
	return self._ccbOwner.head_size:getContentSize()
end

function QUIWidgetThunderMonsterHead:getScale()
    return self._ccbOwner.head_size:getScale()
end

function QUIWidgetThunderMonsterHead:onEnter()
end

function QUIWidgetThunderMonsterHead:onExit()
end

function QUIWidgetThunderMonsterHead:setInfo(param)
    self.config = param.config
    self._currentLevel = param.currentLevel
    self._openElite = param.openElite
    self._index = param.index
    self._hisLevel = param.hisLevel

    local displayConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self.config.npc_id)
    if displayConfig and displayConfig.icon then
        self._ccbOwner.content:setVisible(true)
        if self._iconSprite == nil then
            self._iconSprite = CCSprite:create()
            self._ccbOwner.content:addChild(self._iconSprite)
        end
        self._iconSprite:setDisplayFrame(QSpriteFrameByPath(displayConfig.icon))
        self._iconSprite:setScale(self._ccbOwner.head_size:getScale())
    end

    if self._index <= self._hisLevel or (self._index == self._hisLevel+1 and self._index <= self._openElite) then
        self:setGray(false)
        self:setLocked(false)
    else
        if self._index <= self._openElite then
            self:setGray(true)
        else
            self:setTitle((self._index * 3).."关解锁")
            self:setLocked(true)
        end
    end
end

function QUIWidgetThunderMonsterHead:setTitle(content)
    self._ccbOwner.tf_lock:setString(content)
end 

function QUIWidgetThunderMonsterHead:setLocked(state)
  	self._isLock = state
    self._ccbOwner.title_node:setVisible(state)
end 

function QUIWidgetThunderMonsterHead:setSelected(state)
    self._ccbOwner.node_select:setVisible(state)
  	self._isSelect = state
end 

function QUIWidgetThunderMonsterHead:removeSelect()
    self._ccbOwner.node_select:setVisible(false)
    self._isSelect = false
end 

function QUIWidgetThunderMonsterHead:setGray(state)
	if state then
        self._ccbOwner.tf_lock:setString("")
  	    self._isLock = state
        self._ccbOwner.title_node:setVisible(state)
	end
end 

function QUIWidgetThunderMonsterHead:_onTriggerClick(event)
    self:dispatchEvent({name = QUIWidgetThunderMonsterHead.CLICK_MONSTER_HEAD, index = self._index, isLock = self._isLock})
end

function QUIWidgetThunderMonsterHead:getContentSize()
    return self._ccbOwner.btn_click:getContentSize()
end

return QUIWidgetThunderMonsterHead