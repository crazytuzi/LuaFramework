local data_item_item = require("data.data_item_item")

local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
local CreditItemView = class("CreditItemView", function()
	return CCTableViewCell:new()
end)

function CreditItemView:getContentSize()
	return cc.size(620, 230)
end

function CreditItemView:refreshItem(param)
	self:removeAllChildren()
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/integral_item.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0, 0))
	self:addChild(node)
	local itemData = {
	iconType = ResMgr.getResType(data_item_item[param.itemData.itemid].type),
	type = data_item_item[param.itemData.itemid].type,
	num = param.itemData.itemnum,
	id = param.itemData.itemid
	}
	
	--[[
	addTouchListener(self._rootnode.reward_icon, function(sender, eventType)
		if eventType == EventType.began then
			if tonumber(itemData.type) == 6 then
				local endFunc = function()
					CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
				end
				if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
					local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {
					resId = tonumber(itemData.id)
					}, nil, endFunc)
					CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 1000, 1111)
					GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				end
			end
		elseif eventType == EventType.ended then
			if tonumber(itemData.type) ~= 6 then
				local endFunc = function()
					CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
				end
				if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
					local itemInfo = require("game.Huodong.ItemInformation").new({
					id = itemData.id,
					type = itemData.type,
					name = data_item_item[tonumber(itemData.id)].name,
					describe = data_item_item[tonumber(itemData.id)].describe,
					endFunc = endFunc
					})
					CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 10000, 1111)
				end
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		elseif eventType == EventType.cancel then
		end
	end)
	]]
	
	local itemData = param.itemData
	local confirmFunc = param.confirmFunc
	local title01 = {
	common:getLanguageString("@TotalLeftNum"),
	common:getLanguageString("@TodayTotalLeftNum")
	}
	local title02 = {
	common:getLanguageString("@TotalBuyNum"),
	common:getLanguageString("@TodayBuyNum")
	}
	local titleDes = ""
	if itemData.sale == 1 then
		self._rootnode.leftNum1:setString(common:getLanguageString("@TotalLeftNum"))
		self._rootnode.leftNum2:setString(common:getLanguageString("@ExchangnableTime"))
	else
		self._rootnode.leftNum1:setString(common:getLanguageString("@TodayTotalLeftNum"))
		self._rootnode.leftNum2:setString(common:getLanguageString("@ExchangnableTodayTime"))
	end
	if itemData.sale == 1 then
		titleDes = common:getLanguageString("@Act_ServerAllItemLeft")
	else
		titleDes = common:getLanguageString("@Act_ServerDayItemLeft")
	end
	local titleName = ui.newTTFLabelWithOutline({
	text = titleDes,
	size = 22,
	color = cc.c3b(255, 210, 0),
	outlineColor = cc.c3b(0, 0, 0),
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy
	})
	
	titleName:align(display.LEFT_BOTTOM)
	ResMgr.replaceKeyLableEx(titleName, self._rootnode, "titlename", 0, 0)
	
	self._rootnode.reward_name1:setString(itemData.needPoint)
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
		numLblColor = ccc3(0, 255, 0),
		numLblOutColor = ccc3(0, 0, 0),
		itemType = itemData.type
		})
		local nameKey = "reward_name"
		local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
		local nameLbl = ui.newTTFLabelWithShadow({
		text = require("data.data_item_item")[itemData.id].name,
		size = 20,
		color = nameColor,
		shadowColor = cc.c3b(0, 0, 0),
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER,
		dimensions = cc.size(100, 60),
		valign = ui.TEXT_ALIGN_TOP
		})
		
		nameLbl:align(display.CENTER)
		nameLbl:setPosition(rewardIcon:getContentSize().width / 2, -30)
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
	self._rootnode.mName1:setVisible(false)
	local function closeFun()
		if confirmFunc then
			confirmFunc(param.index, self)
		end
	end
	self._rootnode.rewardBtn1:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	local vip = game.player:getVip()
	local numTotal
	if vip < param.itemData.vip then
		numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[param.itemData.vip + 1]
	else
		numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[vip + 1]
	end
	self._rootnode.reward_na1:setString(param.itemData.leftNum)
	self._rootnode.reward_na2:setString("/" .. data_xianshishangdian_xianshishangdian[param.itemData.id].sum1)
	self._rootnode.reward1:setString(tostring(numTotal - param.itemData.canBuyNum))
	self._rootnode.leftNum3:setString("/" .. numTotal)
	if param.itemData.canBuyNum == 0 or param.itemData.leftNum == 0 then
		self._rootnode.rewardBtn1:setEnabled(false)
	end
	self._rootnode.rewardBtn1:setZOrder(10000)
	local allLeftNode = {}
	table.insert(allLeftNode, self._rootnode.leftNum1)
	table.insert(allLeftNode, self._rootnode.reward_na1)
	table.insert(allLeftNode, self._rootnode.reward_na2)
	alignNodesOneByAll(allLeftNode)
	local allNode = {}
	table.insert(allNode, self._rootnode.leftNum2)
	table.insert(allNode, self._rootnode.reward1)
	table.insert(allNode, self._rootnode.leftNum3)
	alignNodesOneByAll(allNode)
end

function CreditItemView:create(param)
	self:refreshItem(param)
	return self
end

function CreditItemView:refresh(param)
	self:refreshItem(param)
end

return CreditItemView