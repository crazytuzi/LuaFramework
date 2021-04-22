-- @Author: liaoxianbo
-- @Date:   2019-05-27 17:26:18
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-05-28 11:30:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossQuickFightAwrds = class("QUIDialogWorldBossQuickFightAwrds", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogWorldBossQuickFightAwrds:ctor(options)
	local ccbFile = "ccb/Dialog_zhandoujs_xy.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogWorldBossQuickFightAwrds.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end
end

function QUIDialogWorldBossQuickFightAwrds:viewDidAppear()
	QUIDialogWorldBossQuickFightAwrds.super.viewDidAppear(self)
	self:addBackEvent(true)

	self:fightEndHandler()
end

function QUIDialogWorldBossQuickFightAwrds:viewWillDisappear()
  	QUIDialogWorldBossQuickFightAwrds.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogWorldBossQuickFightAwrds:fightEndHandler()

	self._ccbOwner.sp_zdjs_title:setVisible(true)
    local contentText = "魂师大人，这次战斗您总共对邪魔虎鲸造成了##s%s##j伤害，以下是您的奖励哟～"
    local worldBoss = remote.worldBoss:getWorldBossInfo()
    local index = 1
    local awards = {}
    if worldBoss.fightHurtReward ~= nil then
        awards[index] = string.split(worldBoss.fightHurtReward, "^")
        awards[index].title = "基础奖励"
        index = index + 1
    end
    if worldBoss.fightLuckyReward ~= nil then
        awards[index] = string.split(worldBoss.fightLuckyReward, "^")
        awards[index].title = "幸运一击"
        self._ccbOwner.sp_zdjs_title:setVisible(false)
        self._ccbOwner.sp_xyyj_title:setVisible(true)
        contentText = "魂师大人，这次战斗您总共对邪魔虎鲸造成了##s%s##j伤害并触发了##s幸运一击##j，以下是您的奖励哟～"
        index = index + 1
    end
    if worldBoss.fightKillReward ~= nil then
        awards[index] = string.split(worldBoss.fightKillReward, "^")
        awards[index].title = "击杀奖励"
        index = index + 1
    end
    local damage = worldBoss.curHurt or 0
    local num, unit = q.convertLargerNumber(damage)
	local itemBoxs = {}
	local index = 1
	local width = 0
	local gap = 30
	local contentSize
	local posx,posy = self._ccbOwner.node_item:getPosition()
	for _, award in pairs(awards) do
		itemBoxs[index] = self:_createItemBox(self._ccbOwner.node_item,award)

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end
	if #awards >= 2 then
		self._ccbOwner.node_item:setPositionX(posx-25*(#awards))
	end
	local str = string.format(contentText,num..(unit or ""))
	self._richText = QRichText.new(str, 480, {stringType = 1, autoCenter = false, defaultSize = 24, defaultColor = COLORS.a})
	self._richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_text:addChild(self._richText)
end

function QUIDialogWorldBossQuickFightAwrds:_createItemBox(node, itemInfo)
    local itemId = itemInfo[1]
    local itemType = ITEM_TYPE.ITEM
    local itemNum = tonumber(itemInfo[2])
    if tonumber(itemInfo[1]) == nil then
        itemType = remote.items:getItemType(itemInfo[1])
    end

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(itemId, itemType, itemNum)
    if itemInfo.title == "幸运一击" then
    	itemBox:showBoxEffect("effects/award_light.ccbi", true)
    end
    itemBox:setPromptIsOpen(true)
    -- itemBox:resetAll()
    node:addChild(itemBox)
    node:setVisible(true)

    return itemBox
end

function QUIDialogWorldBossQuickFightAwrds:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogWorldBossQuickFightAwrds:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogWorldBossQuickFightAwrds:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogWorldBossQuickFightAwrds
