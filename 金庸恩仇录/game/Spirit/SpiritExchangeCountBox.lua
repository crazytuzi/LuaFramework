local SpiritExchangeCountBox = class("SpiritExchangeCountBox", function ()
	return require("utility.ShadeLayer").new()
end)

function SpiritExchangeCountBox:ctor(param)
	self.shopType = param.shopType or ARENA_SHOP_TYPE
	local itemData = param.itemData
	local havenum = itemData.had
	local remainnum = itemData.limitNum
	local listener = param.listener
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_exchange_item_count.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local function onClose()
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeSelf()
	end
	
	ResMgr.setControlBtnEvent(rootnode.cancelBtn, function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	
	ResMgr.setControlBtnEvent(rootnode.closeBtn, function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	
	local haveLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@popcontentExpremain", havenum),
	size = 24,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	haveLabel:setPosition(0, 0)
	rootnode.haveLabel:removeAllChildren()
	rootnode.haveLabel:addChild(haveLabel)
	
	
	local nameLbl = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@popcontentExptoItem"),
	size = 24,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	color = cc.c3b(255, 243, 0),
	shadowColor = FONT_COLOR.BLACK,
	})
	nameLbl:setPosition(0, 0)
	rootnode.nameLabel:removeAllChildren()
	rootnode.nameLabel:addChild(nameLbl)
	local num = 0
	
	local function onNumBtn(sender, event)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local tag = sender:getTag()
		if 1 == tag then
			if remainnum < 1 then
				show_tip_label(common:getLanguageString("@MaxExchange"))
			else
				num = num + 1
				remainnum = remainnum - 1
			end
		elseif 2 == tag then
			if remainnum < 1 then
				show_tip_label(common:getLanguageString("@MaxExchange"))
			elseif remainnum < 10 then
				num = num + remainnum
				remainnum = 0
			else
				num = num + 10
				remainnum = remainnum - 10
			end
		elseif 3 == tag then
			if num > 1 then
				num = num - 1
				remainnum = remainnum + 1
			end
		elseif 4 == tag then
			if num > 1 and num <= 10 then
				remainnum = remainnum + num - 1
				num = 1
			elseif num > 10 then
				num = num - 10
				remainnum = remainnum + 10
			end
		end
		rootnode.exchangeCountLabel:setString(tostring(num))
	end
	
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn, _)
	ResMgr.setControlBtnEvent(rootnode.confirmBtn, function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			listener(num)
			onClose()
		else
			show_tip_label(common:getLanguageString("@popcontentExptoItem"))
		end
	end)
end

return SpiritExchangeCountBox