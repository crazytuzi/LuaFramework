local BiwuByTimesCountBox = class("BiwuByTimesCountBox", function()
	return require("utility.ShadeLayer").new()
end)

function BiwuByTimesCountBox:ctor(param, successCallBack)
	dump(param)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("shop/biwu_buy_item_count.ccbi", proxy, rootnode)
	node:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	self:addChild(node)
	
	local function onClose()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
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
	
	rootnode.haveLabel:setVisible(false)
	local itemNameLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 24,
	color = cc.c3b(255, 243, 0),
	align = ui.TEXT_ALIGN_CENTER,
	})
	itemNameLabel:setString(common:getLanguageString("@SelectBuyNumber", string.format(" %s ", param.name)))
	itemNameLabel:setPosition(rootnode.nameLabel:getContentSize().width / 2, rootnode.nameLabel:getContentSize().height / 2)
	rootnode.nameLabel:addChild(itemNameLabel)
	rootnode.costLabel:setString("0")
	local num = 1
	local remainnum = param.remainnum - 1
	local function getCost()
		local tmpNum = param.hadBuy + num
		local costNum = 0
		if param.addPrice == 0 then
			costNum = num * param.price
		else
			costNum = num * param.price + (tmpNum * (tmpNum - 1) - param.hadBuy * (param.hadBuy - 1)) * param.addPrice / 2
		end
		return costNum
	end
	rootnode.tag_bug_time:setString(tostring(param.maxnum))
	rootnode.tag_bug_time:setVisible(true)
	rootnode.costLabel:setString(tostring(getCost()))
	local function onNumBtn(sender, event)
		if event == nil then
			return
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
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
	onNumBtn(rootnode.add1Btn,_)
	ResMgr.setControlBtnEvent(rootnode.confirmBtn, function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			costNum = getCost()
			successCallBack(num, costNum)
			self:removeSelf()
		end
	end)
	alignNodesOneByOne(rootnode.alsobuylabel, rootnode.tag_bug_time)
end

return BiwuByTimesCountBox