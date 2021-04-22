
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHead = class("QUIWidgetHead", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIDialogChooseHead = import("..dialogs.QUIDialogChooseHead")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRectUiMask = import("...ui.battle.QRectUiMask")

QUIWidgetHead.EVENT_HERO_HEAD_CLICK = "EVENT_HERO_HEAD_CLICK"

function QUIWidgetHead:ctor(options)
    local ccbFile = "ccb/Widget_head.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetHead._onTriggerClick)},
        {ccbCallbackName = "onTriggerClickVip", callback = handler(self, QUIWidgetHead._onTriggerClickVip)},
        {ccbCallbackName = "onTriggerClickMonthCard", callback = handler(self, QUIWidgetHead._onTriggerClickMonthCard)},
    }
    QUIWidgetHead.super.ctor(self,ccbFile,callBacks,options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._oldBattleForce = 0
    self._scaleTo = 1
    self._ccbOwner.vip_level:setString(QVIPUtil:VIPLevel())

    self._avatar = QUIWidgetAvatar.new(remote.user.avatar)
    self._avatar:setSilvesArenaPeak(remote.user.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)
end

function QUIWidgetHead:onEnter()
    self._ccbOwner.sprite_head_force:setTouchEnabled(true)
    self._ccbOwner.sprite_head_force:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.sprite_head_force:setTouchSwallowEnabled(true)
    self._ccbOwner.sprite_head_force:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetHead._onBattleForceTouch))

    self._headPropProxy = cc.EventProxy.new(remote.headProp)
    self._headPropProxy:addEventListener(remote.headProp.AVATAR_CHANGE, handler(self, self.onAvatarChange))
end

function QUIWidgetHead:onExit( ... )
    self._ccbOwner.sprite_head_force:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    if self._headPropProxy then
        self._headPropProxy:removeAllEventListeners()
    end

    if self._numEffect ~= nil then
        self._numEffect:disappear()
        self._numEffect = nil
    end
end

function QUIWidgetHead:getTitleName(code)
    local rankConfig = db:getRankConfigByCode(code)
    return rankConfig.name
end

function QUIWidgetHead:setInfo(user)
    self._ccbOwner.tf_name:setString(user.nickname or "")
    self._ccbOwner.tf_level:setString("LV" .. user.level)
    self._ccbOwner.vip_level:setString(QVIPUtil:VIPLevel())

    local exp = remote.user.exp
    local exp_total = db:getExperienceByTeamLevel(remote.user.level)
    local sprite = self._ccbOwner.sprite_exp
    setNodeShaderProgram(sprite, qShader.Q_ProgramPositionTextureColorBar)
    sprite:setOpacityModifyRGB(false)
    sprite:setColor(ccc3(255 * math.min(exp/exp_total, 1.0), 255, 255))
    sprite:setVisible(exp/exp_total ~= 0)

    local sp = remote.soulTrial:getSoulTrialTitleSpAndFrame(remote.user.soulTrial)
    if remote.user.soulTrial and remote.user.soulTrial > 0 and sp then
        self._ccbOwner.node_headPicture:setScale(0.60)
        self._ccbOwner.node_headPicture:setPosition(-124, 51)
        self._ccbOwner.node_soulTrial:removeAllChildren()
        self._ccbOwner.node_soulTrial:addChild(sp)
        self._ccbOwner.node_soulTrial:setVisible(true)
        self._ccbOwner.node_head:setPositionX(-20)
        self._ccbOwner.sp_bg_1:setVisible(false)
        self._ccbOwner.sp_bg_2:setVisible(true)
    else
        self._ccbOwner.node_headPicture:setScale(0.72)
        self._ccbOwner.node_headPicture:setPosition(-130, 41)
        self._ccbOwner.node_soulTrial:setVisible(false)
        self._ccbOwner.node_head:setPositionX(0)
        self._ccbOwner.sp_bg_1:setVisible(true)
        self._ccbOwner.sp_bg_2:setVisible(false)
    end

    -- 月卡激活状态
    local monthCard1 = remote.activity:checkMonthCardActive(1)
    local monthCard2 = remote.activity:checkMonthCardActive(2)
    if monthCard1 then
        makeNodeFromGrayToNormal(self._ccbOwner.sp_month_card1)
    else
        makeNodeFromNormalToGray(self._ccbOwner.sp_month_card1)
    end
    if monthCard2 then
        makeNodeFromGrayToNormal(self._ccbOwner.sp_month_card2)
    else
        makeNodeFromNormalToGray(self._ccbOwner.sp_month_card2)
    end
end

function QUIWidgetHead:setBattleForce()
    local battleForce = remote.herosUtil:getMostHeroBattleForce()
    self._newBattle = battleForce
    self:setTextInfo(battleForce)

    if self._textUpdate == nil then
        self._textUpdate = QTextFiledScrollUtils.new()
    end
    if self._oldBattleForce == 0 then
        self._oldBattleForce = battleForce
        return
    end
    local changeBattle = battleForce - self._oldBattleForce
    if changeBattle == 0 then return end
    if changeBattle > 0 then
        app.sound:playSound("force_add")
    end

    local change = math.floor(changeBattle)
    if self._oldBattleForce >= 1000000 then
        changeBattle = math.floor(battleForce/10000) - math.floor(self._oldBattleForce/10000)
    end


    if math.abs(changeBattle) ~= 0 then
        self._ccbOwner.battle_force:runAction(CCScaleTo:create(0.2, self._scaleTo))
        self._textUpdate:addUpdate(self._oldBattleForce, battleForce, handler(self, self.setBattleForceText), 1)
    else
        local array = CCArray:create()
        array:addObject(CCScaleTo:create(0.3, self._scaleTo))
        array:addObject(CCScaleTo:create(0.3, self._scaleTo))
        self._ccbOwner.battle_force:runAction(CCSequence:create(array))
        self._oldBattleForce = battleForce
    end

    if change ~= 0 then 
        local effectName
        if change > 0 then
            effectName = "effects/Tips_add.ccbi"
        elseif change < 0 then 
            effectName = "effects/Tips_Decrease.ccbi"
        end

        if self._numEffect ~= nil then
            self._numEffect:disappear()
            self._numEffect = nil
        end
        self._numEffect = QUIWidgetAnimationPlayer.new()
        self._ccbOwner.battle_node:addChild(self._numEffect)
        self._numEffect:playAnimation(effectName, function(ccbOwner)
            if change < 0 then
                ccbOwner.content:setString(" -" .. math.floor(-change))
            else
                ccbOwner.content:setString(" +" .. math.floor(change))
            end
        end)
    end
end

function QUIWidgetHead:setBattleForceText(battleForce)
    if self.class == nil then return end
    self:setTextInfo(battleForce)
    if battleForce == self._newBattle then
        self._ccbOwner.battle_force:runAction(CCScaleTo:create(0.2, self._scaleTo))
    end
    self._oldBattleForce = battleForce
end

function QUIWidgetHead:setTextInfo(battleForce)
    local num, unit = q.convertLargerNumber(battleForce)
    self._ccbOwner.battle_force:setString(math.floor(num)..unit)
    
    local fontInfo = db:getForceColorByForce(battleForce,true)
    if fontInfo ~= nil then
        local color = string.split(fontInfo.force_color, ";")
        self._ccbOwner.battle_force:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIWidgetHead:checkRedTips()
    self._ccbOwner.sp_user_tip:setVisible(false)

    if remote.bindingPhone then
        local bindingPhoneTip = remote.bindingPhone:checkRedTips()
        self._ccbOwner.sp_user_tip:setVisible(bindingPhoneTip)
    end
end

-- Listen to QUIDialogChooseHead.AVATAR_CHANGE, when avatar is changed, my information dialog needs update
function QUIWidgetHead:onAvatarChange(event)
    self._avatar:setInfo(event.avatar)
end

function QUIWidgetHead:_onTriggerClickVip()
    app.sound:playSound("common_small")
    -- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip"})
end

function QUIWidgetHead:_onTriggerClickMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege", options = {isShowGo = true}})
end

function QUIWidgetHead:_onTriggerClick()
    app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetHead.EVENT_HERO_HEAD_CLICK , target = self})
end

function QUIWidgetHead:_onBattleForceTouch(event)
    app.tip:floatTip(string.format(global.battle_force_explain, remote.herosUtil:getUnlockTeamNum())) 
end

return QUIWidgetHead