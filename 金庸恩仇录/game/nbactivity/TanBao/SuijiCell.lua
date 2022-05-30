local SuijiCell = class("SuijiCell", function()
	return display.newLayer()
end)

function SuijiCell:getContentSize()
	return cc.size(105, 120)
end

function SuijiCell:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	if itemData.type == ITEM_TYPE.zhenqi then
		self._rootnode.reward_icon:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
		self._rootnode.reward_icon:removeAllChildrenWithCleanup(true)
		self._rootnode.reward_icon:addChild(require("game.Spirit.SpiritIcon").new({
		resId = itemData.id
		}))
		require("game.Spirit.SpiritCtrl").clear()
	else
		ResMgr.refreshIcon({
		id = itemData.id,
		resType = itemData.iconType,
		itemBg = rewardIcon,
		iconNum = itemData.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0),
		itemType = itemData.type
		})
		if itemData.hideCorner then
			local cornerNode = rewardIcon:getChildByTag(ResMgr.cornerTag)
			if cornerNode then
				cornerNode:setVisible(false)
			end
		end
	end
	
	rewardIcon:setTouchEnabled(true)
	rewardIcon:setTouchSwallowEnabled(false)
	--czy
	rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
			self.touchIcon = true
			self.touchIconPx = event.x
			self.touchIconPy = event.y
			return true
		elseif event.name == "moved" then
			local x = event.x - self.touchIconPx
			local y = event.y - self.touchIconPy
			if x * x + y * y > 30 then
				self.touchIcon = false
			end
		elseif event.name == "ended" and self.touchIcon then
			self.touchIcon = false
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = itemData.id,
			type = itemData.type,
			name = itemData.name,
			describe = require("data.data_item_item")[itemData.id].dis
			})
			CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
		end
	end)
	
	local nameKey = "reward_name"
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 20,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(100, 60),
	valign = ui.TEXT_ALIGN_CENTER
	})
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 0)
	nameLbl:align(display.CENTER)
	
	
end

function SuijiCell:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_item.ccbi", proxy, self._rootnode)
	local contentSize = self._rootnode.reward:getContentSize()
	node:setPosition(self:getContentSize().width * 0.5, _viewSize.height * 0.5)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function SuijiCell:refresh(param)
	self:refreshItem(param)
end

return SuijiCell