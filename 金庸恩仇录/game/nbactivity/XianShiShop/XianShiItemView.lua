local data_item_item = require("data.data_item_item")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")

local XianShiItemView = class("JifenRewordItem", function()
	return CCTableViewCell:new()
end)

function XianShiItemView:getContentSize()
	return cc.size(620, 230)
end

function XianShiItemView:refreshItem(param)
	self:removeAllChildren()
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/xianshishop_item.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0, 0))
	self:addChild(node)
	local itemData = {
	iconType = ResMgr.getResType(data_item_item[param.itemData.itemid].type),
	type = data_item_item[param.itemData.itemid].type,
	num = param.itemData.itemnum,
	id = param.itemData.itemid
	}
	self._itemData = itemData
	
	local itemData = param.itemData
	local confirmFunc = param.confirmFunc
	local titleDis = {
	common:getLanguageString("@Act_ServerAllItemLeft"),
	common:getLanguageString("@Act_ServerDayItemLeft")
	}
	local title01 = {
	common:getLanguageString("@TotalLeftNum"),
	common:getLanguageString("@TodayTotalLeftNum")
	}
	local title02 = {
	common:getLanguageString("@TotalBuyNum"),
	common:getLanguageString("@TodayBuyNum")
	}
	self._rootnode.title_01:setString(title01[itemData.sale])
	self._rootnode.title_02:setString(title02[itemData.sale])
	--标题
	local titleName = ui.newTTFLabelWithOutline({
	text = titleDis[itemData.sale],
	size = 22,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	ResMgr.replaceKeyLableEx(titleName, self._rootnode, "titlename", 0, 0)
	titleName:align(display.LEFT_BOTTOM)
	
	--价格
	local priceLabel = ui.newTTFLabelWithOutline({
	text = "200",
	size = 20,
	color = cc.c3b(255, 210, 0),
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy
	})
	ResMgr.replaceKeyLableEx(priceLabel, self._rootnode, "price", -5, 0)
	priceLabel:align(display.LEFT_CENTER)
	
	--需要VIP等级
	local vipFont = ui.newBMFontLabel({
	text = "2",
	font = "fonts/font_vip.fnt",
	align = ui.TEXT_ALIGN_LEFT
	})
	self._rootnode.viptag:removeAllChildren()
	vipFont:align(display.LEFT_CENTER, 50, 2)
	self._rootnode.viptag:addChild(vipFont)
	
	local itemData = {
	iconType = ResMgr.getResType(param.itemData.type),
	type = param.itemData.type,
	num = param.itemData.itemnum,
	id = param.itemData.itemid
	}
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
	if itemData.type ~= ITEM_TYPE.zhenqi then
		ResMgr.refreshIcon({
		id = itemData.id,
		resType = itemData.iconType,
		itemBg = rewardIcon,
		iconNum = itemData.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = display.COLOR_GREEN,
		numLblOutColor = display.COLOR_BLACK,
		itemType = itemData.type
		})
		local nameKey = "reward_name"
		local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
		local nameLbl = ui.newTTFLabelWithShadow({
		text = require("data.data_item_item")[itemData.id].name,
		size = 20,
		color = nameColor,
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		nameLbl:align(display.CENTER, rewardIcon:getContentSize().width / 2, -15)
		rewardIcon:addChild(nameLbl)
	else
		self._rootnode.reward_icon:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
		self._rootnode.reward_icon:removeAllChildrenWithCleanup(true)
		self._rootnode.reward_icon:addChild(require("game.Spirit.SpiritIcon").new({
		resId = itemData.id,
		bShowName = true
		}))
		require("game.Spirit.SpiritCtrl").clear()
		self._rootnode.reward_icon:setPositionY(100)
	end
	local function closeFun()
		dump("click")
		if confirmFunc then
			confirmFunc(param.index, self)
		end
	end
	self._rootnode.rewardBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	local vip = game.player:getVip()
	local numTotal
	if vip < param.itemData.vip then
		numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[param.itemData.vip + 1]
	else
		numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[vip + 1]
	end
	self._rootnode.timeleft:setString(param.itemData.leftNum .. "/" .. data_xianshishangdian_xianshishangdian[param.itemData.id].sum1)
	self._rootnode.timeleft1:setString(numTotal - param.itemData.canBuyNum)
	self._rootnode.timeleftall:setString("/" .. numTotal)
	if param.itemData.sale == 1 then
		self._rootnode.timeleft:setPosition(cc.p(self._rootnode.timeleft:getPositionX() - 28, self._rootnode.timeleft:getPositionY() - 3))
		self._rootnode.timeleft1:setPositionX(self._rootnode.timeleft1:getPositionX() - 50)
		self._rootnode.timeleftall:setPositionX(self._rootnode.timeleftall:getPositionX() - 50)
	else
		self._rootnode.timeleft:setPosition(cc.p(self._rootnode.timeleft:getPositionX() + 20, self._rootnode.timeleft:getPositionY() - 3))
		self._rootnode.timeleft1:setPositionX(self._rootnode.timeleft1:getPositionX())
		self._rootnode.timeleftall:setPositionX(self._rootnode.timeleftall:getPositionX())
	end
	priceLabel:setString(param.itemData.price)
	vipFont:setString(data_xianshishangdian_xianshishangdian[param.itemData.id].vip)
	if vip >= data_xianshishangdian_xianshishangdian[param.itemData.id].vip then
		vipFont:setVisible(false)
		self._rootnode.viptag:setVisible(false)
		self._rootnode.buy_tag:setVisible(false)
	else
		self._rootnode.rewardBtn:setEnabled(false)
	end
	if param.itemData.canBuyNum == 0 or param.itemData.leftNum == 0 then
		self._rootnode.rewardBtn:setEnabled(false)
	end
	self._rootnode.rewardBtn:setZOrder(10000)
	local discount = data_xianshishangdian_xianshishangdian[param.itemData.id].discount
	if discount == 0 then
		self._rootnode.xianshi_tag:setVisible(false)
	else
		self._rootnode.xianshi_tag:setDisplayFrame(display.newSprite("#xianshishop_0" .. discount .. ".png"):getDisplayFrame())
	end
	alignNodesOneByOne(self._rootnode.title_01, self._rootnode.timeleft)
	alignNodesOneByOne(self._rootnode.title_02, self._rootnode.timeleft1)
	alignNodesOneByOne(self._rootnode.timeleft1, self._rootnode.timeleftall)
end

function XianShiItemView:tableCellTouched(x, y)
	local icon = self._rootnode.reward_icon
	if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height),icon:convertToNodeSpace(cc.p(x, y))) then
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if tonumber(self._itemData.type) == 6 then
			local endFunc = function()
				--CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
			end
			if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
				local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
				resId = tonumber(self._itemData.id)
				}, nil, endFunc)
				CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 1000, 1111)
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			end
		else
			local endFunc = function()
				--CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
			end
			if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = self._itemData.id,
				type = self._itemData.type,
				name = data_item_item[tonumber(self._itemData.id)].name,
				describe = data_item_item[tonumber(self._itemData.id)].describe,
				endFunc = endFunc
				})
				CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 10000, 1111)
			end
		end
	end
end

function XianShiItemView:create(param)
	self:refreshItem(param)
	return self
end

function XianShiItemView:refresh(param)
	self:refreshItem(param)
end

return XianShiItemView