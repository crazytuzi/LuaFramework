--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 极北之地宗门物资发放弹框
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderInvest = class("QUIDialogPlunderInvest", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

function QUIDialogPlunderInvest:ctor(options)
 	local ccbFile = "ccb/Dialog_plunder_zmwz.ccbi"
    local callBacks = {}
    QUIDialogPlunderInvest.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    app:getUserOperateRecord():recordeInPlunder()
    remote.plunder.needInvestClock = false
    
    self:_init()
end

function QUIDialogPlunderInvest:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogPlunderInvest:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogPlunderInvest:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderInvest:viewWillDisappear()
	QUIDialogPlunderInvest.super.viewWillDisappear(self)
end

function QUIDialogPlunderInvest:_init()
	local curIndex, investInfo = remote.plunder:getCurInvestIndex()
	print("QUIDialogPlunderInvest:_init() ", curIndex)
	if curIndex < 1 then return end

	local richText = QRichText.new(nil, 400, {stringType = 1, defaultColor = COLORS.a, size = 22})
	richText:setAnchorPoint(0.5, 1)
	self._ccbOwner.content:addChild(richText)

	-- local stringFormat = "##a%s %s ##w%s（战力%s,%s）##j击败了 ##b%s（战力%s,%s）##j%s"
	local stringFormat = "##j    宗门因念及魂师大人的贡献，特此支援一批物资给大人使用，愿魂师大人武运昌荣！"
	stringFormat = string.format(stringFormat)
	richText:setString(stringFormat)

	-- gonghui_kuangshi
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(nil, "gonghui_kuangshi", tonumber(investInfo[curIndex][2]))
	itemBox:setPromptIsOpen(true)
	itemBox:setVisible(true)
	self._ccbOwner.node_icon:addChild(itemBox)
end

return QUIDialogPlunderInvest