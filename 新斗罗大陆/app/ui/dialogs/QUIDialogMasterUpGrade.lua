local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMasterUpGrade = class("QUIDialogMasterUpGrade", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

QUIDialogMasterUpGrade.EVENT_CLOSE = "EVENT_CLOSE"

function QUIDialogMasterUpGrade:ctor(options)
    local ccbFile = "ccb/Dialog_HeroGradeSuccess_Master.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogMasterUpGrade.super.ctor(self, ccbFile, callBack, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self.isAnimation = true

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

    if options then
        self._upLevel = options.upLevel or 1
        self._masterLevel = options.level - self._upLevel
        self._masterType = options.masterType
        self._actorId = options.actorId
        self._currMasterInfo = options.oldCurObj
        self._oldLevel = options.oldLevel
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

function QUIDialogMasterUpGrade:viewWillDisappear()
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end
end 

function QUIDialogMasterUpGrade:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogMasterUpGrade:_initIcon()
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

function QUIDialogMasterUpGrade:createSpriteIcon(node, iconPath)
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
function QUIDialogMasterUpGrade:_initProp()
    if self._masterType == QUIHeroModel.HERO_TRAIN_MASTER then
        local config = QStaticDatabase:sharedDatabase():getTrainingBonus(self._actorId)
        local forceChanged = app.master:getForceChanges(self._actorId)
        for _, obj in ipairs(config) do
            if obj.standard <= forceChanged then
                self._nextMasterInfo = obj
            end
        end 
        self._isMax = self._masterLevel >= 20 and true or false
        self._nextMasterInfo = app.master:countCurrentTrainMasterProp(self._nextMasterInfo, self._actorId)
        self._currMasterInfo = app.master:countCurrentTrainMasterProp(self._currMasterInfo, self._actorId)
    else
        local masterType = self._masterType
        local heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
        if heroUIModel then
            masterType = heroUIModel:getSuperMasterTypeByType(masterType)
        end
        self._currMasterInfo, self._nextMasterInfo, self._isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(masterType, self._masterLevel, self._upLevel)
    end

    if self._currMasterInfo == nil then
        self._currMasterInfo = {}
    end

    self._ccbOwner.old_master_level:setString("LV"..self._masterLevel or 0)
    self._ccbOwner.new_master_level:setString("LV"..(self._masterLevel or 0)+self._upLevel)
  
    self._newIndex = 1
    self:setNewTFValue("攻    击：", self._currMasterInfo.attack_value or 0, self._nextMasterInfo.attack_value or 0)
    self:setNewTFValue("生    命：", self._currMasterInfo.hp_value or 0, self._nextMasterInfo.hp_value or 0)
    self:setNewTFValue("物理防御：", self._currMasterInfo.armor_physical or 0, self._nextMasterInfo.armor_physical or 0)
    self:setNewTFValue("法术防御：", self._currMasterInfo.armor_magic or 0, self._nextMasterInfo.armor_magic or 0)

end

function QUIDialogMasterUpGrade:setNewTFValue(name, oldValue, newValue)
    if self._newIndex > 4 then return end
    if newValue ~= nil then
        if newValue > 0 then
            if newValue < 1 and newValue > 0 then
                self._ccbOwner["old_prop_"..self._newIndex]:setString((oldValue * 100).."%")
                self._ccbOwner["new_prop_"..self._newIndex]:setString((newValue * 100).."%")
            else
                self._ccbOwner["old_prop_"..self._newIndex]:setString(oldValue)
                self._ccbOwner["new_prop_"..self._newIndex]:setString(newValue)
            end
      -- self._ccbOwner["node_"..self._newIndex]:setVisible(true)
            self._ccbOwner["name_"..self._newIndex]:setString(name)
            self._newIndex = self._newIndex + 1
        end
    end
end

function QUIDialogMasterUpGrade:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogMasterUpGrade:_backClickHandler()
    if self._animationIsFinishend == false then return end 
    self:_onTriggerClose()
end

function QUIDialogMasterUpGrade:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogMasterUpGrade:viewAnimationOutHandler()
    self:popSelf()
    if self._isSelected == true then
        app.master:setMasterShowState(self._masterType)
    end
    self:dispatchEvent({name = QUIDialogMasterUpGrade.EVENT_CLOSE})
end

return QUIDialogMasterUpGrade