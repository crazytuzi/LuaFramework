local data_viplimit_viplimit = require("data.data_viplimit_viplimit")
if game.player:getAppOpenData().appstore == APPOPEN_STATE.close then
	data_viplimit_viplimit = require("data.data_viplimit_viplimit_shen")
end

local ChongzhiVipDesInfoLayer = class("ChongzhiVipDesInfoLayer", function()
	return require("utility.ShadeLayer").new()
end)

local Item = class("Item", function(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local height = 0
	local node = display.newNode()
	node:setContentSize(cc.size(viewSize.width, 0))
	node:setAnchorPoint(0.5, 1)
	local bossLblNode = display.newNode()
	local bossLblHeight = 0
	bossLblNode:setContentSize(viewSize.width * 0.9, 0)
	bossLblNode:setAnchorPoint(0.5, 1)
	node:addChild(bossLblNode)
	for i, v in ipairs(itemData.limit) do
		local lbl = ui.newTTFLabel({
		text = "❀" .. v,
		font = FONTS_NAME.font_fzcy,
		color = cc.c3b(255, 255, 255),
		size = 22,
		align = ui.TEXT_ALIGN_LEFT,
		valign = ui.TEXT_VALIGN_TOP,
		dimensions = cc.size(bossLblNode:getContentSize().width, 0)
		})
		lbl:setAnchorPoint(0.5, 1)
		lbl:setPosition(bossLblNode:getContentSize().width / 2, -bossLblHeight)
		bossLblNode:addChild(lbl)
		bossLblHeight = bossLblHeight + lbl:getContentSize().height
	end
	height = height + bossLblHeight + 25
	local vipIcon = display.newSprite("#cz_vip.png")
	height = height + vipIcon:getContentSize().height
	vipIcon:setAnchorPoint(1, 1)
	vipIcon:setPosition(viewSize.width / 2, height - 5)
	node:addChild(vipIcon)
	local vipLbl = ui.newBMFontLabel({
	text = tostring(itemData.vip),
	font = "fonts/font_vip.fnt"
	})
	vipLbl:setAnchorPoint(0, 0.5)
	vipLbl:setPosition(vipIcon:getContentSize().width, vipIcon:getContentSize().height * 0.07)
	vipIcon:addChild(vipLbl)
	bossLblNode:setPosition(viewSize.width / 2, vipIcon:getPositionY() - vipIcon:getContentSize().height - 10)
	node:setContentSize(node:getContentSize().width, height)
	local bgSprite = display.newScale9Sprite("#win_base_inner_bg_dark.png", 0, 0, CCSizeMake(node:getContentSize().width, height))
	bgSprite:setAnchorPoint(0.5, 0.5)
	bgSprite:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	node:addChild(bgSprite, -1)
	return node
end)

function ChongzhiVipDesInfoLayer:ctor(param)
	local curVipLv = param.curVipLv
	local curVipExp = param.curVipExp
	local vipExpLimit = param.vipExpLimit
	local confirmFunc = param.confirmFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/shop/shop_vipDesInfo_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.tag_close:addHandleOfControlEvent(function()
		if confirmFunc ~= nil then
			confirmFunc()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@vipPrivilege"))
	self._rootnode.vip_curLevel_lbl:setString(tostring(curVipLv))
	self._rootnode.vip_exp_lbl:setString(tostring(curVipExp) .. "/" .. tostring(vipExpLimit))
	local percent = curVipExp / vipExpLimit
	local addBar = self._rootnode.addBar
	addBar:setTextureRect(CCRectMake(addBar:getTextureRect().x, addBar:getTextureRect().y, addBar:getContentSize().width * percent, addBar:getTextureRect().height))
	local vipNode = self._rootnode.vipInfo_node
	local bottomNode = self._rootnode.bottom_node
	local bottomPosY = 30
	local topPosY = 85
	local listHeight = node:getContentSize().height - bottomPosY - topPosY
	vipNode:setPositionY(node:getContentSize().height - topPosY)
	bottomNode:setPositionY(vipNode:getPositionY() - vipNode:getContentSize().height - 10)
	listHeight = listHeight - vipNode:getContentSize().height - 10
	local listViewSize = CCSizeMake(bottomNode:getContentSize().width, listHeight)
	scrollNode = CCBuilderReaderLoad("ccbi/shop/shop_vipDesInfo_scrollNode.ccbi", proxy, self._rootnode, self, listViewSize)
	scrollNode:setPosition(bottomNode:getContentSize().width / 2, 0)
	bottomNode:addChild(scrollNode)
	local height = 0
	local dis = 7
	local contentViewSize = self._rootnode.contentView:getContentSize()
	local curVipHeight = 0
	for i, v in ipairs(data_viplimit_viplimit) do
		local item = Item.new({viewSize = listViewSize, itemData = v})
		item:setPosition(contentViewSize.width / 2, -height)
		self._rootnode.contentView:addChild(item)
		height = height + item:getContentSize().height + dis
		if curVipLv == i then
			curVipHeight = height
		end
	end
	local sz = cc.size(contentViewSize.width, contentViewSize.height + height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	local scrollView = self._rootnode.scrollView
	scrollView:updateInset()
	scrollView:setContentOffset(CCPointMake(0, -sz.height + scrollView:getViewSize().height + curVipHeight), false)
end

return ChongzhiVipDesInfoLayer