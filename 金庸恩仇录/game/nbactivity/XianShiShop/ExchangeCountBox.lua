local ExchangeCountBox = class("ExchangeCountBox", function()
	return require("utility.ShadeLayer").new()
end)

function ExchangeCountBox:ctor(param)
	dump(param)
	self.shopType = param.shopType or ARENA_SHOP_TYPE
	local reputation = param.reputation
	local itemData = param.itemData
	local havenum = itemData.had
	local remainnum = itemData.limitNum
	local listener = param.listener
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("arena/xianshishop_exchange_item_count.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if self.shopType == HUASHAN_SHOP_TYPE then
		rootnode.lingshi_node:setVisible(true)
		rootnode.shengwang_node:setVisible(false)
	elseif self.shopType == CREDIT_SHOP_TYPE then
		rootnode.rongyu_node:setVisible(false)
		rootnode.needcoin:setString(common:getLanguageString("@needPoint"))
	end
	
	local function onClose()
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeSelf()
	end
	
	ResMgr.setControlBtnEvent(rootnode.cancelBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	
	ResMgr.setControlBtnEvent(rootnode.closeBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	
	rootnode.haveLabel:setString(common:getLanguageString("@gongyongyou1") .. tostring(havenum) .. common:getLanguageString("@GuildShopItemUnit"))
	local nameColor = cc.c3b(255, 243, 0)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@qingxuanzedh") .. itemData.name .. common:getLanguageString("@decishu"),
	size = 24,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_haibao,
	})
	--nameLbl:setPosition(0, 0)
	--rootnode.nameLabel:removeAllChildren()
	--rootnode.nameLabel:addChild(nameLbl)
	ResMgr.replaceKeyLableEx(nameLbl, rootnode, "nameLabel", 0, 0)
	nameLbl:align(display.CENTER)
	
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
		rootnode.costLabel:setString(tostring(num * itemData.needReputation))
	end
	
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn, _)
	
	ResMgr.setControlBtnEvent(rootnode.confirmBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			if num * itemData.needReputation > reputation then
				if self.shopType == CREDIT_SHOP_TYPE then
					show_tip_label(data_error_error[100018].prompt)
				else
					show_tip_label(data_error_error[400004].prompt)
				end
			else
				listener(num)
				onClose()
			end
		else
			show_tip_label(common:getLanguageString("@qingxuanzegmcs"))
		end
	end)
end

return ExchangeCountBox