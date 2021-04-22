local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbMasterUp = class("QUIDialogMagicHerbMasterUp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIHeroModel = import("...models.QUIHeroModel")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

QUIDialogMagicHerbMasterUp.EVENT_CLOSE = "EVENT_CLOSE"

function QUIDialogMagicHerbMasterUp:ctor(options)
    local ccbFile = "ccb/Dialog_HeroGradeSuccess_Master.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogMagicHerbMasterUp.super.ctor(self, ccbFile, callBack, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self.isAnimation = true

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

    if options then
        self._masterType = options.masterType
        self._actorId = options.actorId
        self._upLevel = options.upLevel
    end
    self._animationIsFinishend = false

    self:_initIcon()
    self:_initProp()

    self._scheduler = scheduler.performWithDelayGlobal(function()
        self._animationIsFinishend = true
      end, 2.5)

    self._isSelected = false
    self:showSelectState()

    app.sound:playSound("hero_grow_breakthrough")
end

function QUIDialogMagicHerbMasterUp:viewWillDisappear()
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end 

function QUIDialogMagicHerbMasterUp:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogMagicHerbMasterUp:_initIcon()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._masterType))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())

    local iconPath = QResPath(self._masterType.."icon")
    local wordPath = QResPath(self._masterType.."word")
    iconPath = iconPath[1]
    wordPath = wordPath[1]
    if iconPath then
        self:createSpriteIcon(self._ccbOwner.old_master_icon, iconPath)
        self:createSpriteIcon(self._ccbOwner.new_master_icon, iconPath)
    end
    if wordPath then
        self:createSpriteIcon(self._ccbOwner.old_master_word, wordPath)
        self:createSpriteIcon(self._ccbOwner.new_master_word, wordPath)
    end
end

function QUIDialogMagicHerbMasterUp:createSpriteIcon(node, iconPath)
    node:removeAllChildren()
    local ccsprite3 = nil
    local pos1,pos2 = string.find(iconPath,"%.plist")
    if pos1 ~= nil and pos2 ~= nil then
        ccsprite3 = CCSprite:createWithSpriteFrame(QSpriteFrameByPath(iconPath))
    else
        ccsprite3 = CCSprite:create(iconPath) 
    end
    node:addChild(ccsprite3)
end

--初始化浮动框
function QUIDialogMagicHerbMasterUp:_initProp()
    local index = 1
    while true do
        local node = self._ccbOwner["node_prop_"..index]
        if node then
            node:setVisible(false)
            index = index + 1
        else
            break
        end
    end
    self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
    self._currMasterInfo, _, self._preMasterInfo, self._isMax = self._heroUIModel:getMasterInfo(self._upLevel)
    self._ccbOwner.old_master_level:setString("LV"..(self._preMasterInfo and self._preMasterInfo.master_level or 0 or 0))
    self._ccbOwner.new_master_level:setString("LV"..(self._currMasterInfo and self._currMasterInfo.master_level or 0 or 0))
  
    self:_setProp(self._preMasterInfo, self._currMasterInfo)
end

function QUIDialogMagicHerbMasterUp:_setProp(oldConfig, curConfig)
    local index = 1
    for key, value in pairs(curConfig) do
        if QActorProp._field[key] then
            local node = self._ccbOwner["node_prop_"..index]
            if node then
                node:setVisible(true)
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                local nextNum = q.getFilteredNumberToString(value, QActorProp._field[key].isPercent, 2)     
                local oldNum = q.getFilteredNumberToString(oldConfig[key] or 0, QActorProp._field[key].isPercent, 2)     
                self._ccbOwner["name_"..index]:setString(name..":")
                self._ccbOwner["old_prop_"..index]:setString(oldNum)
                self._ccbOwner["new_prop_"..index]:setString(nextNum)
                index = index + 1
            else
                return
            end
        end
    end
end

function QUIDialogMagicHerbMasterUp:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogMagicHerbMasterUp:_backClickHandler()
    if self._animationIsFinishend == false then return end 
    self:_onTriggerClose()
end

function QUIDialogMagicHerbMasterUp:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogMagicHerbMasterUp:viewAnimationOutHandler()
    self:popSelf()
    if self._isSelected == true then
        app.master:setMasterShowState(self._masterType)
    end
    self:dispatchEvent({name = QUIDialogMagicHerbMasterUp.EVENT_CLOSE})
end

return QUIDialogMagicHerbMasterUp