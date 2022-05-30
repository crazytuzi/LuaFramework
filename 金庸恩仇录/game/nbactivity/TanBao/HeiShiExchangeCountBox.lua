local HeiShiExchangeCountBox = class("HeiShiExchangeCountBox", function()
	return require("utility.ShadeLayer").new()
end)

function HeiShiExchangeCountBox:ctor(param)
	dump(param)
	self.shopType = param.shopType or ARENA_SHOP_TYPE
	local itemData = param.itemData
	local havenum = itemData.had
	local remainnum = itemData.limitNum
	local price = itemData.price
	local name = itemData.name
	local id = itemData.id
	self.listener = param.listener
	local closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/heishi_exchange_item_count.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local function onClose()
		if closeFunc ~= nil then
			closeFunc()
		end
		self:removeFromParentAndCleanup(true)
	end
	ResMgr.setControlBtnEvent(rootnode.cancelBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	ResMgr.setControlBtnEvent(rootnode.closeBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end)
	local haveColor = cc.c3b(255, 255, 255)
	local haveLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@ArenaExchange", havenum),
	size = 24,
	color = haveColor,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	haveLabel:setPosition(0, 0)
	rootnode.haveLabel:removeAllChildren()
	rootnode.haveLabel:addChild(haveLabel)
	local nameColor = cc.c3b(255, 243, 0)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@ExchangeNumber", name),
	size = 24,
	color = nameColor,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	nameLbl:setPosition(0, 0)
	rootnode.nameLabel:removeAllChildren()
	rootnode.nameLabel:addChild(nameLbl)
	local needColor = cc.c3b(255, 243, 0)
	local needLbl = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@tbcontentexchange", price),
	size = 24,
	color = needColor,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER
	})
	needLbl:setPosition(0, 0)
	rootnode.needLabel:removeAllChildren()
	rootnode.needLabel:addChild(needLbl)
	self.needLabel = needLbl
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
		self.needLabel:setString(common:getLanguageString("@tbcontentexchange", tonumber(num) * tonumber(price)))
	end
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn,_)
	ResMgr.setControlBtnEvent(rootnode.confirmBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			self:exchange(id, num)
		else
			show_tip_label(common:getLanguageString("@SelectExchangeNumber"))
		end
	end)
end

function HeiShiExchangeCountBox:exchange(id, num)
	local function _callback(data)
		self.listener(num, data[2], data[3], data[4], data[5])
		self:removeSelf()
	end
	local function _error(err)
		self.listener()
		self:removeSelf()
	end
	local msg = {
	m = "activity",
	a = "buyBlackShopGoods",
	id = id,
	num = num
	}
	RequestHelper.request(msg, _callback, _error)
end

return HeiShiExchangeCountBox