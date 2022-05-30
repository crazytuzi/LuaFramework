local data_item_item = require("data.data_item_item")
local BuyCountBox = class("BuyCountBox", function()
	return require("utility.ShadeLayer").new()
end)
function BuyCountBox:ctor(param, callback, errorCB)
	dump(param)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("shop/buy_item_count.ccbi", proxy, rootnode)
	node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	self:addChild(node)
	
	local function onClose()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end
	
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	if data_item_item[param.itemId].type == 7 and data_item_item[param.itemId].effecttype == 0 and data_item_item[param.itemId].auto == 1 then
		rootnode.haveLabel:setVisible(false)
	end
	rootnode.haveLabel:setString(common:getLanguageString("@gongyongyou", param.havenum))
	local itemNameLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 24,
	color = cc.c3b(255, 243, 0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER
	})
	itemNameLabel:setString(common:getLanguageString("@xuanzegm", param.name))
	itemNameLabel:setPosition(rootnode.nameLabel:getContentSize().width / 2, rootnode.nameLabel:getContentSize().height / 2)
	rootnode.nameLabel:addChild(itemNameLabel)
	rootnode.costLabel:setString("0")
	local num = 1
	local remainnum = param.remainnum - 1
	local function getCost()
		local tmpNum = param.hadBuy + num
		local costNum = 0
		if param.hadBuy > param.maxN - 1 then
			costNum = (param.baseprice + param.maxN * param.addPrice) * num
			printf("%d = (%d + %d * %d) * %d = %d", costNum, param.baseprice, param.maxN, param.addPrice, num, costNum)
		elseif tmpNum < param.maxN + 2 then
			costNum = num * param.price + num * (num - 1) * param.addPrice / 2
			printf("%d * %d + %d * (%d - 1) * %d / 2", num, param.baseprice, num, num, param.addPrice)
		else
			costNum = (param.maxN - param.hadBuy + 1) * (param.baseprice + param.hadBuy * param.addPrice) + (param.maxN - param.hadBuy + 1) * (param.maxN - param.hadBuy) * param.addPrice / 2 + (tmpNum - param.maxN - 1) * (param.baseprice + param.maxN * param.addPrice)
		end
		return costNum
	end
	rootnode.costLabel:setString(tostring(getCost()))
	local function onNumBtn(sender, event)
		if event ~= false then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end
		if event == nil then
			return
		end
		local tag = sender:getTag()
		if 1 == tag then
			if -1 == param.maxnum or remainnum > 0 then
				num = num + 1
				remainnum = remainnum - 1
			else
				show_tip_label(common:getLanguageString("@MaxBuyNumber"))
			end
		elseif 2 == tag then
			if -1 == param.maxnum or remainnum >= 10 then
				num = num + 10
				remainnum = remainnum - 10
			elseif remainnum > 0 and remainnum < 10 then
				num = num + remainnum
				remainnum = 0
			else
				show_tip_label(common:getLanguageString("@MaxBuyNumber"))
			end
		elseif 3 == tag then
			if num > 1 then
				num = num - 1
				remainnum = remainnum + 1
			end
		elseif 4 == tag then
			dump("-10:" .. num .. "," .. remainnum)
			if num > 1 and num < 10 then
				remainnum = remainnum + num - 1
				num = 1
			elseif num > 10 then
				num = num - 10
				remainnum = remainnum + 10
			elseif num == 10 then
				num = num - 10 + 1
				remainnum = remainnum + 10 - 1
			end
		end
		rootnode.buyCountLabel:setString(tostring(num))
		rootnode.costLabel:setString(tostring(getCost()))
	end
	
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn, false)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			RequestHelper.buy({
			callback = function(data)
				dump(data)
				if string.len(data["0"]) > 0 then
					CCMessageBox(data["0"], "Tip")
				else
					local price = math.min(param.baseprice + param.addPrice * data["1"].hadBuy, param.baseprice + param.maxN * param.addPrice)
					printf("======== %d", remainnum)
					param.remainnum = remainnum
					param.hadBuy = param.hadBuy + num
					param.havenum = param.havenum + num
					param.price = price
					game.player:setGold(data["2"])
					game.player:setSilver(data["3"])
					if callback then
						callback()
					end
					PostNotice(NoticeKey.CommonUpdate_Label_Gold)
					PostNotice(NoticeKey.CommonUpdate_Label_Silver)
					num = 0
				end
				onClose()
			end,
			errback = function()
				errorCB()
				onClose()
			end,
			id = tostring(param.id),
			n = tostring(num),
			coinType = tostring(param.coinType),
			coin = tostring(getCost())
			})
		end
	end,
	CCControlEventTouchUpInside)
end

return BuyCountBox