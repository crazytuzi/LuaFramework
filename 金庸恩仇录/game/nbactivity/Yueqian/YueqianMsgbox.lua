local YueqianMsgbox = class("YueqianMsgbox", function ()
	return require("utility.ShadeLayer").new()
end)
function YueqianMsgbox:ctor(param)
	local confirmFunc = param.confirmFunc
	local cancleFunc = param.cancleFunc
	local itemData = param.itemData
	local isCanGet = param.isCanGet
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/yueqian_msgbox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(common:getLanguageString("@Hint"))
	rootnode.AccumulateSignInRewards:setString(common:getLanguageString("@AccumulateSignInRewards", itemData.day))
	rootnode.UpgradeDoubleRewards:setString(common:getLanguageString("UpgradeDoubleRewards", "VIP" .. itemData.vip))
	if itemData.vip > 0 then
		rootnode.vip_node:setVisible(true)
	else
		rootnode.vip_node:setVisible(false)
	end
	if isCanGet == true then
		rootnode.getRewardBtn:setVisible(true)
		rootnode.confirmBtn:setVisible(false)
	else
		rootnode.confirmBtn:setVisible(true)
		rootnode.getRewardBtn:setVisible(false)
	end
	rootnode.itemDesLbl:setString(itemData.describe)
	local rewardIcon = rootnode.itemIcon
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
	id = itemData.id,
	resType = itemData.iconType,
	itemBg = rewardIcon,
	itemType = itemData.type
	})
	local canhunIcon = rootnode.reward_canhun
	local suipianIcon = rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameKey = "name_lbl"
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 22,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	--align = ui.TEXT_ALIGN_LEFT
	})
	--nameLbl:setPosition(0, nameLbl:getContentSize().height / 2)
	--rootnode[nameKey]:removeAllChildren()
	--rootnode[nameKey]:addChild(nameLbl)
	ResMgr.replaceKeyLableEx(nameLbl, rootnode, nameKey, 0, nameLbl:getContentSize().height / 2)
	nameLbl:align(display.LEFT_CENTER)
	
	
	local numLbl = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@Quantity") .. tostring(itemData.num),
	size = 22,
	color = display.COLOR_WHITE,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	--align = ui.TEXT_ALIGN_LEFT
	})
	--numLbl:setPosition(0, numLbl:getContentSize().height / 2)
	--rootnode.num_lbl:removeAllChildren()
	--rootnode.num_lbl:addChild(numLbl)
	ResMgr.replaceKeyLableEx(numLbl, rootnode, "num_lbl", 0, numLbl:getContentSize().height / 2)
	numLbl:align(display.LEFT_CENTER)
	
	local function closeFunc()
		if cancleFunc ~= nil then
			cancleFunc()
		end
		self:removeFromParentAndCleanup(true)
	end
	rootnode.tag_close:addHandleOfControlEvent(function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	rootnode.confirmBtn:addHandleOfControlEvent(function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	rootnode.getRewardBtn:addHandleOfControlEvent(function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if confirmFunc ~= nil then
			confirmFunc()
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
end

return YueqianMsgbox