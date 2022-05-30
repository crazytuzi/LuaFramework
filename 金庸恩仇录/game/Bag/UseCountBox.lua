local data_item_item = require("data.data_item_item")
local UseCountBox = class("UseCountBox", function()
	return require("utility.ShadeLayer").new()
end)
function UseCountBox:ctor(param)
	dump(param)
	local havenum = param.havenum or 1
	local name = param.name
	local listener = param.listener
	local expend = param.expend
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("bag/use_item_count.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local function onClose()
		self:removeSelf()
	end
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.haveLabel:setString(common:getLanguageString("@HaveTxt", param.havenum))
	local textLabel = common:getLanguageString("@SelectNumber", tostring(param.name))
	
	local itemNameLabel = ui.newTTFLabelWithOutline({
	text = string.format("%s",param.name),
	font = FONTS_NAME.font_haibao,
	size = 24,
	color = cc.c3b(255,243,0),
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER
	})
	ResMgr.replaceKeyLableEx(itemNameLabel, rootnode, "nameLabel", 0, 0)
	
	
	local num = 0
	local remainnum = 50
	if havenum < remainnum then
		remainnum = havenum
	end
	local function onNumBtn(sender, event)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local tag = sender:getTag()
		if 1 == tag then
			if remainnum < 1 then
				show_tip_label(common:getLanguageString("@MaxNumber"))
			elseif expend.id and expend.num <= num then
				show_tip_label(common:getLanguageString("@NumberNotEnough", data_item_item[expend.id].name))
			else
				num = num + 1
				remainnum = remainnum - 1
			end
		elseif 2 == tag then
			if remainnum < 1 then
				show_tip_label(common:getLanguageString("@MaxNumber"))
			elseif remainnum < 10 then
				if expend.id and expend.num <= num then
					show_tip_label(common:getLanguageString("@NumberNotEnough", data_item_item[expend.id].name))
				elseif expend.id and expend.num < num + remainnum then
					num = num + (expend.num - num)
					remainnum = remainnum - (expend.num - num)
				else
					num = num + remainnum
					remainnum = 0
				end
			elseif expend.id and expend.num <= num then
				show_tip_label(common:getLanguageString("@NumberNotEnough", data_item_item[expend.id].name))
			elseif expend.id and expend.num < num + 10 then
				num = num + (expend.num - num)
				remainnum = remainnum - (expend.num - num)
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
		rootnode.useCountLabel:setString(tostring(num))
	end
	rootnode.add10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.add1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce10Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	rootnode.reduce1Btn:addHandleOfControlEvent(onNumBtn, CCControlEventTouchUpInside)
	onNumBtn(rootnode.add1Btn, _)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if num > 0 then
			listener(num)
			onClose()
		end
	end,
	CCControlEventTouchUpInside)
	
end

return UseCountBox