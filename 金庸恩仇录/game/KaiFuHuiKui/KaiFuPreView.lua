local data_kaifushuoming_sheet1 = require("data.data_kaifushuoming_sheet1")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local KaiFuPreView = class("KaiFuPreView", function ()
	return require("utility.ShadeLayer").new()
end)
function KaiFuPreView:ctor(param)
	self._type = param.type
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/kaifukuanghuan_seven_prepopup.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.closeBtn:addHandleOfControlEvent(function (eventName, sender)
		self:removeFromParent()
	end,
	CCControlEventTouchUpInside)
	if self._type == KUANGHUAN_TYPE.KAIFU then
		self._rootnode.huodong_title_2:setVisible(false)
	else
		self._rootnode.huodong_title_0:setVisible(false)
		self._rootnode.huodong_title_2:setVisible(true)
		local jieriType = 1
		if self._type ~= KUANGHUAN_TYPE.HEFU then
			jieriType = game.player:getAppOpenData().seven_day
		end
		local titleSprite = display.newSprite("ui/ui_jieri7tian/" .. JieRi_head_name[jieriType] .. "_7day_title.png")
		self._rootnode.huodong_title_2:setDisplayFrame(titleSprite:getDisplayFrame())
	end
	alignNodesOneByOne(self._rootnode.lable_1, self._rootnode.lable_2, 1)
	self:setUpView()
end
function KaiFuPreView:setUpView()
	local boardWidth = self._rootnode.itemview:getContentSize().width
	local boardHeight = self._rootnode.itemview:getContentSize().height
	for index = 1, 4 do
		local dataTemp = {}
		dataTemp.id = data_kaifushuoming_sheet1[self._type + 1].card_id[index]
		dataTemp.iconType = ResMgr.HERO
		dataTemp.type = nil
		dataTemp.name = data_card_card[dataTemp.id].name
		dataTemp.cls = data_card_card[dataTemp.id].cls
		local item = require("game.KaiFuHuiKui.KaiFuCell").new()
		local itemView = item:create({
		index = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = dataTemp,
		confirmFunc = showBuyBox
		})
		itemView:setPositionX((boardWidth / 4 - 10) * (index - 1) + 25)
		self._rootnode.itemview:addChild(itemView)
		local icon = item:getIcon()
		addTouchListener(icon, function (sender, eventType)
			if eventType == EventType.began then
				sender:setScale(0.9)
			elseif eventType == EventType.ended then
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = dataTemp.id,
				type = data_item_item[dataTemp.id].type,
				name = dataTemp.name,
				describe = data_card_card[dataTemp.id].describe
				})
				CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			elseif eventType == EventType.cancel then
				sender:setScale(1)
			end
		end)
		
	end
	local contentSize = self._rootnode.content:getContentSize()
	local scrollView = CCScrollView:create()
	scrollView:setViewSize(contentSize)
	scrollView:setPosition(cc.p(0, 0))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(true)
	self._rootnode.content:addChild(scrollView)
	scrollView:setAnchorPoint(cc.p(0, 0))
	local innnerlayout = CCNode:create()
	scrollView:setContainer(innnerlayout)
	local height = 0
	local totalNum = 3
	local sizeHeight = 25
	for index = 1, #data_kaifushuoming_sheet1[self._type + 1].shop_des do
		local labelNode = self:createDisLabel(index, data_kaifushuoming_sheet1[self._type + 1].shop_des[index], data_kaifushuoming_sheet1[self._type + 1].shop_limit[index])
		labelNode:setPosition(2, (totalNum + 1 - index) * sizeHeight)
		innnerlayout:addChild(labelNode)
		height = labelNode:getPositionY() + labelNode:getContentSize().height
	end
	innnerlayout:setContentSize(cc.size(contentSize.width, (totalNum + 1) * sizeHeight))
	scrollView:setContentOffset(ccp(0, contentSize.height - (totalNum + 1) * sizeHeight), false)
end
function KaiFuPreView:createDisLabel(index, dis, num)
	local node = display.newNode()
	local label_01 = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@DI") .. index .. common:getLanguageString("@Day"),
	size = 24,
	align = ui.TEXT_ALIGN_CENTE,
	color = FONT_COLOR.WHITE,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local label_02 = ui.newTTFLabelWithOutline({
	text = dis,
	size = 24,
	align = ui.TEXT_ALIGN_CENTE,
	color = FONT_COLOR.PURPLE,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	local label_03 = ui.newTTFLabelWithOutline({
	text = common:getLanguageString("@limit") .. num .. common:getLanguageString("@limitNum"),
	size = 24,
	align = ui.TEXT_ALIGN_CENTE,
	color = FONT_COLOR.WHITE,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	label_02:setPositionX(label_01:getPositionX() + label_01:getContentSize().width)
	label_03:setPositionX(label_02:getPositionX() + label_02:getContentSize().width)
	label_01:setScale(0.85)
	label_02:setScale(0.85)
	label_03:setScale(0.85)
	node:addChild(label_01)
	node:addChild(label_02)
	node:addChild(label_03)
	return node
end

return KaiFuPreView