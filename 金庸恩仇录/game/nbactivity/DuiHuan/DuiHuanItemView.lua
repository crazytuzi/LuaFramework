local COLOR_GREEN = ccc3(0, 255, 0)
local data_item_item = require("data.data_item_item")

local DuiHuanItemView = class("DuiHuanItemView", function()
	return CCTableViewCell:new()
end)

function DuiHuanItemView:create(param)
	self:setUpView(param)
	return self
end

function DuiHuanItemView:setUpView(param)
	self:refresh(param)
end

function DuiHuanItemView:refresh(param)
	self.isEnough = true
	self:removeAllChildren()
	local data = param.data
	local type = #data.exchExp.exchItem
	local mainFrameBng = display.newScale9Sprite("#month_item_bg.png", 0, 0, cc.size(param.viewSize.width * 0.96, param.viewSize.height * 0.93))
	mainFrameBng:setAnchorPoint(cc.p(0.5, 0.5))
	mainFrameBng:setPosition(cc.p(param.viewSize.width / 2, param.viewSize.height / 2 - 10))
	self:addChild(mainFrameBng)
	local mainFrameBngSize = mainFrameBng:getContentSize()
	local titleBng = display.newSprite("#month_item_titleBg.png")
	titleBng:setAnchorPoint(cc.p(0.5, 0.5))
	titleBng:setPosition(cc.p(mainFrameBngSize.width * 0.24, mainFrameBngSize.height))
	mainFrameBng:addChild(titleBng)
	local nameLabel = ui.newTTFLabelWithShadow({
	text = data.tagName,
	size = 22,
	color = cc.c3b(255, 210, 0),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	nameLabel:align(display.CENTER, titleBng:getContentSize().width/2, titleBng:getContentSize().height - 25)
	nameLabel:addTo(titleBng)
	
	local disLabel = ui.newTTFLabel({
	text = common:getLanguageString("@ExchangnableTime"),
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(99, 47, 8)
	})
	disLabel:setAnchorPoint(cc.p(0, 0.5))
	disLabel:setPosition(cc.p(mainFrameBngSize.width * 0.065, mainFrameBngSize.height - 45))
	mainFrameBng:addChild(disLabel)
	if data.exchType ~= 1 or not common:getLanguageString("@ExchangnableTodayTime") then
	end
	disLabel:setString((common:getLanguageString("@ExchangnableTime")))
	local disValueLabel = ui.newTTFLabel({
	text = "(" .. data.totalNum - data.exchNum .. "/" .. data.totalNum .. ")",
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(6, 129, 18)
	})
	disValueLabel:setAnchorPoint(cc.p(0, 0.5))
	disValueLabel:setPosition(cc.p(disLabel:getPositionX() + disLabel:getContentSize().width + 10, mainFrameBngSize.height - 45))
	mainFrameBng:addChild(disValueLabel)
	
	--¶Ò»»/Ë¢ÐÂ
	local shuaxinBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#shuaxin_n.png",
	handle = function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if data.isRefresh == 0 then
			show_tip_label(common:getLanguageString("@UnResetable"))
			return
		end
		if param.refreshFunc then
			param.refreshFunc(param.index, data.id)
		end
	end
	})
	shuaxinBtn:align(display.CENTER, mainFrameBng:getContentSize().width * 0.2, 50)
	shuaxinBtn:addTo(mainFrameBng)
	
	local priceLabel = ui.newTTFLabelWithShadow({
	text = data.refGold,
	size = 22,
	color = cc.c3b(255, 210, 0),
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	priceLabel:setPosition(cc.p(shuaxinBtn:getContentSize().width * 0.65, shuaxinBtn:getContentSize().height * 0.5))
	priceLabel:setAnchorPoint(cc.p(0, 0.5))
	shuaxinBtn:bgAddChild(priceLabel)
	if data.isRefresh == 0 then
		priceLabel:setVisible(false)
		shuaxinBtn:setVisible(false)
	end
	--shuaxinBtn:setVisible(false)
	
	local duihuanBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#duihuan_n.png",
	handle = function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		dump(tostring(self.isEnough))
		if not self.isEnough then
			show_tip_label(common:getLanguageString("@LackRes"))
			return
		end
		if param.exChangeFunc then
			param.exChangeFunc(param.index, data.id)
		end
	end
	})
	duihuanBtn:align(display.CENTER, mainFrameBng:getContentSize().width * 0.8, 50)
	duihuanBtn:addTo(mainFrameBng)
	
	if data.exchNum == 0 then
		duihuanBtn:replaceNormalButton("#duihuan_p.png")
		shuaxinBtn:replaceNormalButton("#shuaxin_p.png")
		duihuanBtn:setTouchEnabled(false)
		shuaxinBtn:setTouchEnabled(false)
	else
		duihuanBtn:replaceNormalButton("#duihuan_n.png")
		shuaxinBtn:replaceNormalButton("#shuaxin_n.png")
		duihuanBtn:setTouchEnabled(true)
		shuaxinBtn:setTouchEnabled(true)
	end
	if data.refFreeNum ~= 0 then
		shuaxinBtn:replaceNormalButton("#refresh_free.png")
		priceLabel:setVisible(false)
		shuaxinBtn:setTouchEnabled(true)
	else
		priceLabel:setVisible(true)
	end
	local innerFrame = display.newScale9Sprite("#month_item_innerBg.png", 0, 0, cc.size(mainFrameBng:getContentSize().width * 0.9, mainFrameBng:getContentSize().height * 0.6))
	innerFrame:setAnchorPoint(cc.p(0.5, 0))
	innerFrame:setPosition(cc.p(mainFrameBng:getContentSize().width * 0.5, 90))
	mainFrameBng:addChild(innerFrame)
	if type == 3 then
		innerFrame:setContentSize(cc.size(mainFrameBng:getContentSize().width * 0.9, 160))
	else
		innerFrame:setContentSize(cc.size(mainFrameBng:getContentSize().width * 0.9, 280))
	end
	local innerFrameSize = innerFrame:getContentSize()
	local addIcon = display.newSprite("#add.png")
	addIcon:setPosition(cc.p(innerFrameSize.width * 0.245, innerFrameSize.height * 0.55))
	innerFrame:addChild(addIcon)
	if type == 4 then
		addIcon:setVisible(false)
	end
	local addIcon = display.newSprite("#add.png")
	addIcon:setPosition(cc.p(innerFrameSize.width * 0.495, innerFrameSize.height * 0.55))
	innerFrame:addChild(addIcon)
	local equireIcon = display.newSprite("#denghao.png")
	equireIcon:setPosition(cc.p(innerFrameSize.width * 0.745, innerFrameSize.height * 0.55))
	innerFrame:addChild(equireIcon)
	self.constPos = {
	{
	x = innerFrameSize.width * 0.12,
	y = innerFrameSize.height * 0.8
	},
	{
	x = innerFrameSize.width * 0.12,
	y = innerFrameSize.height * 0.55
	},
	{
	x = innerFrameSize.width * 0.12,
	y = innerFrameSize.height * 0.3
	},
	{
	x = innerFrameSize.width * 0.37,
	y = innerFrameSize.height * 0.8
	},
	{
	x = innerFrameSize.width * 0.37,
	y = innerFrameSize.height * 0.55
	},
	{
	x = innerFrameSize.width * 0.37,
	y = innerFrameSize.height * 0.3
	},
	{
	x = innerFrameSize.width * 0.62,
	y = innerFrameSize.height * 0.8
	},
	{
	x = innerFrameSize.width * 0.62,
	y = innerFrameSize.height * 0.55
	},
	{
	x = innerFrameSize.width * 0.62,
	y = innerFrameSize.height * 0.3
	},
	{
	x = innerFrameSize.width * 0.87,
	y = innerFrameSize.height * 0.55
	}
	}
	self.type3 = {
	2,
	5,
	8,
	10
	}
	self.type4 = {
	2,
	4,
	6,
	8,
	10
	}
	self.type5 = {
	1,
	3,
	5,
	7,
	9,
	10
	}
	self._icons = {}
	for k, v in pairs(self["type" .. type]) do
		if k == #self["type" .. type] then
			table.insert(self._icons, self:createItemView(v, innerFrame, data.exchExp.exchRst[1], true))
		else
			table.insert(self._icons, self:createItemView(v, innerFrame, data.exchExp.exchItem[k],false))
		end
	end
	self._typedata = self["type" .. type]
	self._dataTemp = data
end

function DuiHuanItemView:getItemData(index)
	if index == #self:getData() then
		return self._dataTemp.exchExp.exchRst[1]
	else
		return self._dataTemp.exchExp.exchItem[index]
	end
end

function DuiHuanItemView:getData()
	return self._typedata
end

function DuiHuanItemView:getIcon(index)
	return self._icons[index]
end

function DuiHuanItemView:createItemView(index, node, data, result)
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon
	if data.type == ITEM_TYPE.zhenqi then
		icon = require("game.Spirit.SpiritIcon").new({
		resId = data.id,
		bShowName = false
		})
		node:addChild(icon)
		icon:setAnchorPoint(cc.p(0, 0.5))
		icon:setPosition(cc.p(self.constPos[index].x - 50, self.constPos[index].y))
	else
		if result == true then
			icon = ResMgr.refreshIcon({
			id = data.id,
			resType = ResMgr.getResType(data.type),
			itemType = data.type,
			iconNum = data.num,
			})
		else
			icon = ResMgr.refreshIcon({
			id = data.id,
			resType = ResMgr.getResType(data.type),
			itemType = data.type,
			})
		end
		icon:setAnchorPoint(cc.p(0, 0.5))
		icon:setPosition(cc.p(self.constPos[index].x, self.constPos[index].y))
		icon:setAnchorPoint(cc.p(0.5, 0.5))
		node:addChild(icon)
	end
	
	local nameColor = ResMgr.getItemNameColorByType(tonumber(data.id), ResMgr.getResType(data.type))
	local nameLabel = ui.newTTFLabelWithShadow({
	text = data_item_item[data.id].name,
	size = 20,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER
	})
	
	nameLabel:align(display.CENTER, icon:getContentSize().width / 2, -15)
	nameLabel:addTo(icon)
	
	
	local hasNum = CCLabelTTF:create(data.had, FONTS_NAME.font_fzcy, 20, cc.size(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	local need = CCLabelTTF:create("/" .. data.num, FONTS_NAME.font_fzcy, 20, cc.size(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	hasNum:setColor(COLOR_GREEN)
	need:setColor(COLOR_GREEN)
	if data.had >= data.num then
		hasNum:setColor(COLOR_GREEN)
	else
		hasNum:setColor(FONT_COLOR.RED)
		if index ~= 10 then
			self.isEnough = false
		end
	end
	need:setPosition(icon:getContentSize().width - 5 - need:getContentSize().width / 2, need:getContentSize().height / 2 + 7)
	hasNum:setPosition(need:getPositionX() - need:getContentSize().width / 2 - hasNum:getContentSize().width / 2, need:getPositionY())
	if data.type ~= ITEM_TYPE.zhenqi then
		if index ~= 10 then
			icon:addChild(need, 10)
			icon:addChild(hasNum, 10)
			if data.id <= 8 then
				need:setString(data.num)
				hasNum:setVisible(false)
			end
		end
	else
		icon:setScale(0.95)
		nameLabel:setPositionY(-10)
		if 1 < data.num then
			nameLabel:setString(data_item_item[data.id].name .. "x" .. data.num)
		end
	end
	return icon
end

return DuiHuanItemView