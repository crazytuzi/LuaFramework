--
-- Author: Kumo.Wang
-- 大富翁炼药炉主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyRefineMedicine = class("QUIDialogMonopolyRefineMedicine", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogMonopolyRefineMedicine:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_lianyao.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerMaterial", callback = handler(self, self._onTriggerMaterial)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMonopolyRefineMedicine.super.ctor(self, ccbFile, callBack, options)

    self._ccbOwner.frame_tf_title:setString("炼药炉")

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    self._standGridId = options.standGridId
	self._colour = options.colour

    self:_resetAll()
end

function QUIDialogMonopolyRefineMedicine:viewDidAppear()
	QUIDialogMonopolyRefineMedicine.super.viewDidAppear(self)
end

function QUIDialogMonopolyRefineMedicine:viewWillDisappear()
	QUIDialogMonopolyRefineMedicine.super.viewWillDisappear(self)
end

function QUIDialogMonopolyRefineMedicine:_resetAll()
	local removePoisonCount = remote.monopoly.monopolyInfo.removePoisonCount or 0
	self._ccbOwner.node_curPoison:removeAllChildren()
    local curPoisonImg = remote.monopoly:getPoisonImgById(removePoisonCount + 1)
    self._ccbOwner.node_curPoison:addChild(curPoisonImg)

    local curPoisonConfig = remote.monopoly:getCurPoisonConfig()
    self._poisonName = curPoisonConfig and (curPoisonConfig.poison or "") or ""
    self._ccbOwner.tf_poisonName:setString(self._poisonName)
    self._ccbOwner.tf_poisonDesc:setString(curPoisonConfig and (curPoisonConfig.description or "") or "")
    self._ccbOwner.tf_refineMedicineProportion:setString(remote.monopoly:getCurRefineMedicineRate().."%")

    for index, itemId in pairs(remote.monopoly.materialTbl) do
        local node = self._ccbOwner["node_material_"..index]
        local config = remote.monopoly:getItemConfigByID(itemId)
        if node then
            if config and config.icon then
                local sp = CCSprite:create(config.icon)
                node:removeAllChildren()
                node:addChild(sp)
                node:setVisible(true)
            else
                node:setVisible(false)
            end
        end

        local tf = self._ccbOwner["tf_material_"..index]
        if tf then
            local itemNum = remote.monopoly.tmpMaterialNumTbl[itemId] or remote.items:getItemsNumByID(itemId)
            if remote.monopoly.tmpMaterialNumTbl[itemId] and index == self._colour then
                itemNum = itemNum + 1
            end
            tf:setString(itemNum)
            tf:setVisible(true)
        end
    end

    if remote.monopoly:getCurRefineMedicineRate() == 0 then
    	self._ccbOwner.tf_btnOK:setString("关闭")
    else
    	self._ccbOwner.tf_btnOK:setString("开始炼药")
    end

    self._facEffect = tolua.cast(self._ccbOwner.fca_effect, "QFcaSkeletonView_cpp")
    self._facEffect:stopAnimation()
    self._facEffect:setVisible(false)
    self._ccbOwner.node_effect:setVisible(true)
end

function QUIDialogMonopolyRefineMedicine:_onTriggerMaterial(event, target)
    for index, _ in pairs(remote.monopoly.materialTbl) do
        if target == self._ccbOwner["btn_material_"..index] then
            local config = remote.monopoly:getGridColorConfig(index)
            if config and config.text then
                app.tip:floatTip(config.text)
            end
        end
    end
end

function QUIDialogMonopolyRefineMedicine:_onTriggerOK()
    app.sound:playSound("common_small")
    if remote.monopoly:getCurRefineMedicineRate() == 0 then
        remote.monopoly.tmpMaterialNumTbl = {}
    	remote.monopoly:monopolyRefineMedicineRequest(false, self._standGridId)
    	self:_onTriggerClose()
    else
        self._facEffect:setVisible(true)
        self._facEffect:resumeAnimation()
        self._facEffect:connectAnimationEventSignal(handler(self, self._fcaHandler))
        self._facEffect:playAnimation("animation", false)
    end
end

function QUIDialogMonopolyRefineMedicine:_fcaHandler(eventType)
    print("QUIDialogMonopolyRefineMedicine:_fcaHandler(eventType)", eventType)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
        remote.monopoly.tmpMaterialNumTbl = {}
        remote.monopoly:monopolyRefineMedicineRequest(true, self._standGridId, self:safeHandler(function(data)
                self:_onTriggerClose()
                if data.monopolyResponse.removePoisonCount then
                    -- app.tip:floatTip("炼药成功，"..self._poisonName.."被成功解除")
                    remote.monopoly:showRefineMedicineSuccessForDialog()
                else
                    app.tip:floatTip("炼药失败，请继续采集药材")
                end
            end))
        self._facEffect:stopAnimation()
        self._facEffect:setVisible(false)
    end
end

function QUIDialogMonopolyRefineMedicine:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
        remote.monopoly.tmpMaterialNumTbl = {}
		remote.monopoly:monopolyRefineMedicineRequest(false, self._standGridId, self:safeHandler(function(data)
                remote.monopoly:showRewardForTips(data.prizes, "放弃炼药，获得：")
                self:_onTriggerClose()
            end))
        return
	end
	self:popSelf()
end

return QUIDialogMonopolyRefineMedicine