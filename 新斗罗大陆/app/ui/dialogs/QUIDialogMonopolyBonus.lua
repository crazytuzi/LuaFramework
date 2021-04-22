--
-- Author: Kumo.Wang
-- 大富翁Bonus获奖界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyBonus = class("QUIDialogMonopolyBonus", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

function QUIDialogMonopolyBonus:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_reward2.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogMonopolyBonus.super.ctor(self, ccbFile, callBack, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	self._callback = options.callback
    self:resetAll()
end

function QUIDialogMonopolyBonus:viewDidAppear()
	QUIDialogMonopolyBonus.super.viewDidAppear(self)
end

function QUIDialogMonopolyBonus:viewWillDisappear()
	QUIDialogMonopolyBonus.super.viewWillDisappear(self)
end

function QUIDialogMonopolyBonus:resetAll()
	local config = remote.monopoly:getMonopolyEventConfigByEventId(remote.monopoly.bonusEventId)
	QPrintTable(config)
	local luckyDrawKey = config.prize
	local luckyDrawConfig = remote.monopoly:getLuckyDrawByKey(luckyDrawKey)
	QPrintTable(luckyDrawConfig)
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(luckyDrawConfig.id_1, luckyDrawConfig.type_1, luckyDrawConfig.num_1)
	itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(itemBox)
	self._ccbOwner.node_icon:setVisible(true)

	local tbl = string.split(remote.monopoly.monopolyInfo.randomFootGroup, "_")
	local str = "##j恭喜您，您走出了##w"
	for i, s in ipairs(tbl) do
		if i == 1 then
			str = str..s.."步"
		else
			str = str.."+"..s.."步"
		end
	end
	str = str.."##j的组合，破解了今日此迷阵中的奥秘，获得："
   	local richText = QRichText.new(str, 500, {autoCenter = true, stringType = 1, defaultSize = 22})
   	richText:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_word:addChild(richText)
end

function QUIDialogMonopolyBonus:_onTriggerOK()
    app.sound:playSound("common_small")
    self:_onTriggerClose()
end

function QUIDialogMonopolyBonus:_onTriggerClose()
	if self._callback then
		self._callback()
	end
	self:popSelf()
end

return QUIDialogMonopolyBonus