--
-- Author: wkwang
-- Date: 2014-08-18 20:51:58
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetMonsterHead = class("QUIWidgetMonsterHead", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroHeadStar = import(".QUIWidgetHeroHeadStar")

QUIWidgetMonsterHead.EVENT_BEGAIN = "MONSTER_EVENT_BEGAIN"
QUIWidgetMonsterHead.EVENT_END = "MONSTER_EVENT_END"

function QUIWidgetMonsterHead:ctor(options)
    local ccbFile = "ccb/Widget_HeroHeadBox.ccbi"
    local callBacks = {
        -- {ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetMonsterHead._onTriggerTouch)},
      }
    QUIWidgetMonsterHead.super.ctor(self,ccbFile,callBacks,options)
    self.config = options
    self:resetAll()
    self._ccbOwner.btn_touch:setVisible(false)
    self._ccbOwner.node_pingzhi:setVisible(false)
end 

function QUIWidgetMonsterHead:resetAll()
    self._ccbOwner.node_hero_image:setVisible(false)
    self._ccbOwner.node_hero_star:setVisible(false)
    self._ccbOwner.tf_hero_level:setString("")
    self._ccbOwner.blue_plus:setVisible(false)
    self._ccbOwner.node_dead:setVisible(false)
    self._ccbOwner.sp_soul_frame:setVisible(false)
    self._ccbOwner.node_god_skill:setVisible(false)
    self._ccbOwner.head_effect:setVisible(false)
    self._ccbOwner.node_team:setVisible(false)
    self._ccbOwner.node_hp:setVisible(false)
    self._ccbOwner.node_mp:setVisible(false)
    
    self:setLevelVisible(false)
    self:setIsBoss(false)
end

function QUIWidgetMonsterHead:onEnter()
    self._ccbOwner.node_hero_image:setTouchEnabled(true)
    self._ccbOwner.node_hero_image:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.node_hero_image:setTouchSwallowEnabled(false)
    self._ccbOwner.node_hero_image:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetMonsterHead._onTouch))
end

function QUIWidgetMonsterHead:setHero(actorId)
    self._actorId = actorId
    local displayConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
    self.info = displayConfig
    local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
    -- 设置魂师头像
    local characherDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)

    if characherDisplay.icon ~= nil then
        local headImageTexture =CCTextureCache:sharedTextureCache():addImage(characherDisplay.icon)
        self._ccbOwner.node_hero_image:setTexture(headImageTexture)
        self._size = headImageTexture:getContentSize()
        local rect = CCRectMake(0, 0, self._size.width, self._size.height)
        self._ccbOwner.node_hero_image:setTextureRect(rect)
        self._ccbOwner.node_hero_image:setVisible(true)
    end
end

function QUIWidgetMonsterHead:getMonsterHeadInfo()
    return self.info,self._actorId
end
--[[
    设置进阶显示
]]
function QUIWidgetMonsterHead:setStar(grade)
    if self._star == nil then
        self._star = QUIWidgetHeroHeadStar.new({})
        self._ccbOwner.node_hero_star:addChild(self._star:getView())
    end
    self._star:setStar(grade + 1)
    self._star:setScale(0.7, 0.6)
    self._ccbOwner.node_hero_star:setVisible(true)
end

--[[
    设置突破显示
]]
function QUIWidgetMonsterHead:setBreakthrough(breakthrough)
    local i = 1
    while true do
        local node = self._ccbOwner["break_"..i]
        if node ~= nil then
            node:setVisible(false)
        else
            break
        end
        i = i + 1
    end
    if self._ccbOwner["break_"..(breakthrough)] ~= nil then
        self._ccbOwner["break_"..(breakthrough)]:setVisible(true)
    end
end

function QUIWidgetMonsterHead:_onTouch(event) 
    if event.name == "began" then
        self._startPosX = event.x
        self._startPosY = event.y
        self._isPatch = true
        -- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMonsterHead.EVENT_BEGAIN , eventTarget = self, info = self.info, config = self.config})
        return true
    elseif event.name == "moved" then   
        if self._isPatch == true then
            if self._startPosX ~= nil and math.abs(event.x - self._startPosX) > 10 then
                self._isPatch = false
            elseif self._startPosY ~= nil and math.abs(event.y - self._startPosY) > 10 then
                self._isPatch = false
            end
        end
    elseif event.name == "ended" or event.name == "cancel" then
        -- QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMonsterHead.EVENT_END , eventTarget = self})
        if self._isPatch then
            app.sound:playSound("common_small")
            app.tip:monsterTip(self.info, self.config)
        end
        self._startPosX = nil
        self._startPosY = nil
        self._isPatch = nil
    end
end

--[[
    是否是BOSS
]]
function QUIWidgetMonsterHead:setIsBoss(b)
    self._ccbOwner.sp_boss:setVisible(b)
end

--设置等级是否显示
function QUIWidgetMonsterHead:setLevelVisible(b)
    self._ccbOwner.node_level:setVisible(b)
end 

return QUIWidgetMonsterHead
