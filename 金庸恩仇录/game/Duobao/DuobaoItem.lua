local DuobaoItem = class("DuobaoItem", function()
	return display.newNode()
end)

function DuobaoItem:getCanTouchSize()
	return cc.size(250, 250)
end

function DuobaoItem:getContentSize()
	if self._CntSize == nil then
		local proxy = CCBProxy:create()
		local rootnode = {}
		local node = CCBuilderReaderLoad("duobao/duobao_item.ccbi", proxy, rootnode)
		self._CntSize = node:getContentSize()
		self:addChild(node)
		node:removeSelf()
	end
	return self._CntSize
end

function DuobaoItem:updateItem()
	local itemData = self._itemData
	local debris = self._itemData.debris
	local resType = ResMgr.getResType(itemData.type)
	self._iconImg:setDisplayFrame(ResMgr.getLargeFrame(resType, itemData.id))
	local posX = self._rootnode.tag_dipan:getContentSize().width / 2 + itemData.posX
	local posY = self._rootnode.tag_dipan:getContentSize().height / 2 + itemData.posY
	self._iconImg:setPosition(posX, posY)
	local nameColor = ResMgr.getItemNameColor(itemData.id)
	
	if not self._iconName then
		self._iconName = ui.newTTFLabelWithShadow({
		text = itemData.name,
		size = 24,
		font = FONTS_NAME.font_haibao,
		align = ui.TEXT_ALIGN_LEFT,
		color = nameColor,
		shadowColor = FONT_COLOR.BLACK,
		})
		ResMgr.replaceKeyLableEx(self._iconName, self._rootnode, "name", 0, 0)
		self._iconName:align(display.CENTER)
	else
		self._iconName:setString(itemData.name)
		self._iconName:setColor(nameColor)
	end
	
	for _, v in ipairs(self._debrisType) do
		local typeItem = self._rootnode["debrisType_" .. tostring(v)]
		if #debris == v then
			typeItem:setVisible(true)
		else
			typeItem:setVisible(false)
		end
	end
	if #debris < 3 or #debris > 7 then
		CCMessageBox(common:getLanguageString("@ServerBackError"), "Tip")
		return
	end
	local iconKey = "debrisType_" .. #debris .. "_icon_"
	local numKey = "debrisType_" .. #debris .. "_num_"
	local canShowMixAll = true
	dump(debris)
	for i, v in ipairs(debris) do
		local resType = ResMgr.getResType(v.type)
		local itemIcon = self._rootnode[iconKey .. i]
		ResMgr.refreshIcon({
		itemBg = itemIcon,
		id = v.id,
		resType = resType,
		itemType = v.type
		})
		itemIcon:setScale(0.75)
		local IMAGE_TAG = 1
		if v.num <= 0 then
			itemIcon:setColor(cc.c3b(60, 60, 60))
			itemIcon:getChildByTag(IMAGE_TAG):setColor(cc.c3b(60, 60, 60))
		else
			itemIcon:setColor(FONT_COLOR.WHITE)
			itemIcon:getChildByTag(IMAGE_TAG):setColor(FONT_COLOR.WHITE)
		end
		
		local numLbl = self._rootnode[numKey .. i]
		if not numLbl.update then
			numLbl = ui.newTTFLabelWithOutline({
			text = tostring(v.num),
			size = 22,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_LEFT,
			color = FONT_COLOR.WHITE,
			outlineColor = FONT_COLOR.BLACK,
			})
			ResMgr.replaceKeyLableEx(numLbl, self._rootnode, numKey .. i, -numLbl:getContentSize().width, numLbl:getContentSize().height / 2)
			numLbl:align(display.CENTER)
			numLbl.update = true
		else
			numLbl:setString(tostring(v.num))
			numLbl:setColor(FONT_COLOR.WHITE)
		end
		
		if 2 > v.num then
			canShowMixAll = false
		end
	end
	self._updateMixAllBtn(canShowMixAll)
end

function DuobaoItem:onClickIcon(tag, v, touchNode)
	local debris = self._itemData.debris
	local getIndex = function(idx)
		if idx == 1 then
			return common:getLanguageString("@OneTxt")
		elseif idx == 2 then
			return common:getLanguageString("@TwoTxt")
		elseif idx == 3 then
			return common:getLanguageString("@ThreeTxt")
		elseif idx == 4 then
			return common:getLanguageString("@FourTxt")
		elseif idx == 5 then
			return common:getLanguageString("@FiveTxt")
		elseif idx == 6 then
			return common:getLanguageString("@SixTxt")
		end
	end
	local item = debris[tag]
	local itemInfo = require("game.Duobao.DuobaoDebrisInfo").new({
	id = item.id,
	type = item.type,
	name = item.name,
	title = common:getLanguageString("@Fragment", self._itemData.name, getIndex(tag)),
	describe = item.describe,
	num = item.num,
	getMianzhanTime = self._getMianzhanTime,
	closeListener = function(...)
		touchNode:setTouchEnabled(true)
	end
	})
	game.runningScene:addChild(itemInfo, 10)
end

function DuobaoItem:initIconListen()
	
	if self.touchs then
		for _, v in ipairs(self.touchs) do
			v:removeSelf()
		end
	end
	self.touchs = {}
	local count = #self._itemData.debris
	local iconKey = "debrisType_" .. count .. "_icon_"
	for i = 1, count do
		local itemIcon = self._rootnode[iconKey .. i]
		touchNode = require("utility.MyLayer").new({
		size = itemIcon:getContentSize(),
		parent = itemIcon,
		touchHandler = function(event)
			if event.name == "ended" then
				if self._bItemCanTouch ~= nil and self._bItemCanTouch == true then
					touchNode:setTouchEnabled(false)
					PostNotice(NoticeKey.REMOVE_TUTOLAYER)
					self:onClickIcon(i, v, touchNode)
				end
			end
		end
		})
		table.insert(self.touchs, touchNode)
	end
end

function DuobaoItem:getTutoBtn()
	return self._rootnode.debrisType_3_icon_2
end

function DuobaoItem:getWaiGongTutoBtn1()
	return self._rootnode.debrisType_3_1
end

function DuobaoItem:getWaiGongTutoBtn2()
	return self._rootnode.debrisType_3_2
end

function DuobaoItem:getWaiGongTutoBtn3()
	return self._rootnode.debrisType_3_3
end

function DuobaoItem:onExit()
end

function DuobaoItem:getAnimEffectNode(...)
	return self._rootnode.tag_anim_node
end

function DuobaoItem:ctor(param)
	self._index = param.index
	self._viewSize = param.viewSize
	self._itemData = param.itemData
	self._updateMixAllBtn = param.updateMixAllBtn
	self._getMianzhanTime = param.getMianzhanTime
	self._debrisType = {
	3,
	4,
	5,
	6
	}
	self._bItemCanTouch = true
	self:setNodeEventEnabled(true)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("duobao/duobao_item.ccbi", proxy, self._rootnode)
	node:setPosition(self._viewSize.width * 0.5, self._viewSize.height * 0.5)
	self:addChild(node)
	self._iconImg = self._rootnode.icon
	self:updateItem()
	self:initIconListen()
end

function DuobaoItem:refreshItem(param)
	self._index = param.index
	self._itemData = param.itemData
	self:updateItem()
	self:initIconListen()
end

function DuobaoItem:setItemTouchEnabled(bEnabled)
	self._bItemCanTouch = bEnabled
end

return DuobaoItem