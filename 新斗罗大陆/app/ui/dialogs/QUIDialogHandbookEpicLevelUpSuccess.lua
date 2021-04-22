--
-- Kumo.Wang
-- 新版魂师图鉴，图鉴等级升级展示界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandbookEpicLevelUpSuccess = class("QUIDialogHandbookEpicLevelUpSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")
local QUIWidgetPropShowCell = import("..widgets.QUIWidgetPropShowCell")
local QActorProp = import("...models.QActorProp")

function QUIDialogHandbookEpicLevelUpSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Handbook_Epic_LevelUp.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
    QUIDialogHandbookEpicLevelUpSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    if options then
        self._callback = options.callback
        self._oldEpicConfig = options.oldEpicConfig
    end

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    local curEpicPropConfig, oldEpicPropConfig = remote.handBook:getCurAndOldEpicPropConfig()
    if not q.isEmpty(self._oldEpicConfig) then
        oldEpicPropConfig = self._oldEpicConfig
    end

    self._ccbOwner.tf_name:setString("LV."..curEpicPropConfig.epic_level.." 图鉴等级属性")

    self._totalPropCount = 0 -- 要显示的总属性数量
    self._curIndex = 0 -- 当前已经显示的属性数量
    self._addPropDic = {} -- 需要显示的属性map
    self._isShowEnd = false -- 是否显示完全部属性

    self._showPropList = {
        "team_attack_percent",
        "team_hp_percent",
        "team_armor_physical_percent",
        "team_armor_magic_percent",
        "physical_damage_percent_attack",
        "magic_damage_percent_attack",
        "physical_damage_percent_beattack_reduce",
        "magic_damage_percent_beattack_reduce",
        "soul_damage_percent_beattack_reduce",
    }

    local propFields = QActorProp:getPropFields()
    for key, value in pairs(curEpicPropConfig) do
        if propFields[key] then
            local isFind = false
            for _, v in ipairs(self._showPropList) do
                if v == key then
                    isFind = true
                    break
                end
            end
            if not isFind then
                table.insert(self._showPropList, key)
            end
            
            local addValue = value - (oldEpicPropConfig[key] or 0)
            if addValue > 0 then
                local nameStr = propFields[key].handbookName or propFields[key].uiName or propFields[key].name
                if remote.handBook.battlePropKey[key] then
                    nameStr = remote.handBook.battlePropKey[key].preName..nameStr
                end
                local oldValue = q.getFilteredNumberToString((oldEpicPropConfig[key] or 0), propFields[key].isPercent, 1)
                local newValue = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
                self._addPropDic[key] = {name = nameStr..":", old = oldValue, new = newValue}
                self._totalPropCount = self._totalPropCount + 1
            end
        end
    end

    self._ccbOwner.node_prop:removeAllChildren()
    self._propWidget = QUIWidgetPropShowCell.new()
    self._propWidget:setVisible(false)
    self._ccbOwner.node_prop:addChild(self._propWidget)
    self._oncePropCount = self._propWidget:getMaxPropCount()
    
    for _, key in ipairs(self._showPropList) do
        if self._addPropDic[key] and propFields[key] then
            self._propWidget:setProp(self._addPropDic[key])
            local showCount = self._propWidget:getShowCount()
            if showCount >= self._totalPropCount then
                self._isShowEnd = true
            end
            if showCount >= self._oncePropCount then
                break
            end
        end
    end
    local showCount = self._propWidget:getShowCount()
    self._curIndex = self._curIndex + showCount
    print("self._curIndex = ", self._curIndex, "  self._totalPropCount = ", self._totalPropCount)
    self._propWidget:setPositionY(-(self._oncePropCount - showCount) * 20)

    self._isPlaying = true
    self._animationManager = tolua.cast(self._propWidget:getCCBView():getUserObject(), "CCBAnimationManager")
    self._animationStage = "enter"
    self._propWidget:setVisible(true)
    self._animationManager:runAnimationsForSequenceNamed(self._animationStage)
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    QKumo(self._addPropDic)
end

function QUIDialogHandbookEpicLevelUpSuccess:animationEndHandler(name)
    if name == "enter" then
        self._isPlaying = false
        self._animationStage = "stand"
        self._animationManager:runAnimationsForSequenceNamed(self._animationStage)
    elseif name == "stand" then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIDialogHandbookEpicLevelUpSuccess:viewDidAppear()
	QUIDialogHandbookEpicLevelUpSuccess.super.viewDidAppear(self)
end

function QUIDialogHandbookEpicLevelUpSuccess:viewWillDisappear()
  	QUIDialogHandbookEpicLevelUpSuccess.super.viewWillDisappear(self)
end

function QUIDialogHandbookEpicLevelUpSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogHandbookEpicLevelUpSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogHandbookEpicLevelUpSuccess:_backClickHandler()
    print("QUIDialogHandbookEpicLevelUpSuccess:_backClickHandler()", self._animationStage, self._curIndex, self._totalPropCount, self._isShowEnd, self._isPlaying)
	if self._isShowEnd and not self._isPlaying then
        self:playEffectOut()
    else
        if self._animationStage == "enter" then
            self._isPlaying = false
            self._animationStage = "stand"
            self._animationManager:runAnimationsForSequenceNamed(self._animationStage)
        else
            if not self._isPlaying and self._curIndex <= self._totalPropCount then
                self:_changePropShow()
            end
        end
	end
end

function QUIDialogHandbookEpicLevelUpSuccess:_changePropShow()
    if self._isShowEnd and self._isPlaying then return end

    if self._curIndex < self._totalPropCount then
        self._isPlaying = true

        local propFields = QActorProp:getPropFields()
        local newPropWidget = QUIWidgetPropShowCell.new()
        newPropWidget:setVisible(false)
        self._ccbOwner.node_prop:addChild(newPropWidget)
        newPropWidget:setPositionX(self._propWidget:getPositionX() - self._propWidget:getContentSize().width)

        local index = 0
        for _, key in ipairs(self._showPropList) do
            if self._addPropDic[key] and propFields[key] then
                index = index + 1
                if index > self._curIndex then
                    newPropWidget:setProp(self._addPropDic[key])
                    local showCount = newPropWidget:getShowCount()
                    if (showCount + self._curIndex) >= self._totalPropCount then
                        self._isShowEnd = true
                    end
                    if showCount >= self._oncePropCount then
                        break
                    end
                end
            end
        end
        local showCount = newPropWidget:getShowCount()
        self._curIndex = self._curIndex + showCount
        print("self._curIndex = ", self._curIndex, "  self._totalPropCount = ", self._totalPropCount)
        local widgetY = -(self._oncePropCount - showCount) * 20
        newPropWidget:setPositionY(widgetY)

        local animationManager = tolua.cast(newPropWidget:getCCBView():getUserObject(), "CCBAnimationManager")
        animationManager:runAnimationsForSequenceNamed("stand")

        local time = 0.5
        local newActions = CCArray:create()
        newActions:addObject(CCMoveTo:create(time, ccp(0, widgetY)))
        newActions:addObject(CCCallFunc:create(function() 
                newPropWidget:FadeIn(time)
            end))
        
        scheduler.performWithDelayGlobal(function()
                newPropWidget:setVisible(true)
            end, 0)
        newPropWidget:runAction(CCSpawn:create(newActions))

        local oldActions = CCArray:create()
        oldActions:addObject(CCMoveTo:create(time, ccp(self._propWidget:getContentSize().width - self._propWidget:getPositionX(), 0)))
        oldActions:addObject(CCCallFunc:create(function() 
                self._propWidget:FadeOut(time)
            end))
        self._propWidget:runAction(CCSpawn:create(oldActions))

        scheduler.performWithDelayGlobal(function()
                if self:safeCheck() then
                    self._propWidget = newPropWidget
                    self._animationManager = animationManager
                    animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
                    self._isPlaying = false
                end
            end, time)
    else
        self._isShowEnd = true
    end
end

function QUIDialogHandbookEpicLevelUpSuccess:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback ~= nil then
		callback()
	end
end

return QUIDialogHandbookEpicLevelUpSuccess
