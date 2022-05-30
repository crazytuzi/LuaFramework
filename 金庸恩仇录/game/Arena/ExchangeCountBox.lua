local ExchangeCountBox = class("ExchangeCountBox", function()
	return require("utility.ShadeLayer").new()
end)

function ExchangeCountBox:ctor(param)
	self.shopType = param.shopType or ARENA_SHOP_TYPE
	local reputation = param.reputation
	local itemData = param.itemData
	local havenum = itemData.had
	local remainnum = itemData.limitNum
	local listener = param.listener
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("arena/exchange_item_count.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if self.shopType == HUASHAN_SHOP_TYPE then
		rootnode.lingshi_node:setVisible(true)
		rootnode.shengwang_node:setVisible(false)
		rootnode.contribute_node:setVisible(false)
	elseif self.shopType == ENUM_GUILD_SHOP_TYPE then
		rootnode.contribute_node:setVisible(true)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(false)
	elseif self.shopType == ENUM_KUAFU_SHOP_TYPE then
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(true)
		rootnode.shengwang_node:setDisplayFrame(display.newSprite("#icon_weigwang.png"):getDisplayFrame())
		rootnode.title_label:setString(common:getLanguageString("@WeiWang"))
	elseif self.shopType == ENUM_GUILDBATTLE_SHOP_TYPE then
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(true)
		rootnode.shengwang_node:setDisplayFrame(display.newSprite("ui/ui_CommonResouces/ui_gongxun_icon.png"):getDisplayFrame())
		rootnode.title_label:setString("")
		local titleLabel = ui.newTTFLabelWithOutline({
		text = common:getLanguageString("@GuildBattleExploitNeed"),
		size = 26,
		color = cc.c3b(227, 227, 227),
		shadowColor = cc.c3b(0, 0, 0),
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER
		})
		rootnode.shengwang_node:addChild(titleLabel)
		local signSize = rootnode.shengwang_node:getContentSize()
		titleLabel:setPosition(0 - signSize.width * 0.1 - titleLabel:getContentSize().width * 0.5, signSize.height * 0.5)
	elseif self.shopType == BIWU_SHOP_TYPE then
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(true)
		rootnode.title_label:setString(common:getLanguageString("@Honor"))
		rootnode.shengwang_node:setDisplayFrame(display.newSprite("#icon_rongyu.png"):getDisplayFrame())
	elseif self.shopType == XIANSHI_SHOP_TYPE then
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(true)
		rootnode.title_label:setString(common:getLanguageString("@NeedVcoin"))
		rootnode.shengwang_node:setDisplayFrame(display.newSprite("#icon_gold.png"):getDisplayFrame())
	elseif self.shopType == ZHENQIDAN_EXCHANGE_TYPE then
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(false)
		rootnode.costLabel:setVisible(false)
	else
		rootnode.contribute_node:setVisible(false)
		rootnode.lingshi_node:setVisible(false)
		rootnode.shengwang_node:setVisible(true)
	end
	
	local function onClose()
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeSelf()
	end
	
	ResMgr.setControlBtnEvent(rootnode.cancelBtn, function()
		onClose()
	end,
	SFX_NAME.u_guanbi)
	
	ResMgr.setControlBtnEvent(rootnode.closeBtn, function()
		onClose()
	end,
	SFX_NAME.u_guanbi)
	
	rootnode.haveLabel:setString(common:getLanguageString("@HaveTxt", tostring(havenum)))
	
	local nameLbl = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@ExchangeNumber", itemData.name),
	font = FONTS_NAME.font_fzcy,
	size = 24,
	color = cc.c3b(255, 243, 0),
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER
	})
	nameLbl:align(display.CENTER)
	nameLbl:addTo(rootnode.nameLabel)
	--ResMgr.replaceKeyLableEx(nameLbl, rootnode, "nameLabel", 0, 0)
	
	local num = 0
	local function onNumBtn(sender, event, init)
		if not init then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end
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
		if self.shopType ~= ZHENQIDAN_EXCHANGE_TYPE then
			rootnode.costLabel:setString(tostring(num * itemData.needReputation))
		end
	end
	
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn,_, true)
	
	ResMgr.setControlBtnEvent(rootnode.confirmBtn, function()
		if num > 0 then
			if num * itemData.needReputation > reputation then
				if self.shopType == ARENA_SHOP_TYPE then
					show_tip_label(common:getLanguageString("@PrestigeNotEnough"))
				elseif self.shopType == ENUM_KUAFU_SHOP_TYPE then
					show_tip_label(common:getLanguageString("@NotEnoughWeiwang"))
				elseif self.shopType == ENUM_GUILDBATTLE_SHOP_TYPE then
					show_tip_label(common:getLanguageString("@GuildBattleNotEnoughGongxun"))
				elseif self.shopType == BIWU_SHOP_TYPE then
					show_tip_label(common:getLanguageString("@HonorNotEnough"))
				elseif self.shopType == ENUM_GUILD_SHOP_TYPE then
					ResMgr.showErr(2900030)
				else
					ResMgr.showErr(100015)
				end
			else
				listener(num)
				onClose()
			end
		else
			show_tip_label(common:getLanguageString("@SelectExchangeNumber"))
		end
	end)
end

return ExchangeCountBox