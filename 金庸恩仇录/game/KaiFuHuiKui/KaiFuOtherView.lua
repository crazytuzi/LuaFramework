local data_item_item = require("data.data_item_item")
local KaiFuOtherView = class("KaiFuOtherView", function ()
	return display.newLayer()
end)
function KaiFuOtherView:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/kaifukuanghuan_item_detail.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0, 0))
	self:addChild(node)
	self._type = param.type
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:removeAllChildrenWithCleanup(true)
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
	addTouchListener(rewardIcon, function (sender, eventType)
		if eventType == EventType.ended then
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = itemData.id,
			type = itemData.shop_type,
			name = itemData.name,
			describe = data_item_item[itemData.id].describe
			})
			CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
		end
	end)
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 20,
	color = nameColor,
	shadowColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	nameLbl:setPosition(-nameLbl:getContentSize().width / 2, nameLbl:getContentSize().height / 2)
	self._rootnode.reward_name:removeAllChildren()
	self._rootnode.reward_name:addChild(nameLbl)
	dump(itemData)
	self._rootnode.price_old:setString(itemData.shop_price)
	self._rootnode.price_now:setString(itemData.shop_sale)
	self._rootnode.total_num:setString(common:getLanguageString("@Buylimit", itemData.limit_cnt))
	self._rootnode.left_num:setString(common:getLanguageString("@LeftPlayers", param.getLeftNumFuc()))
	alignNodesOneByOne(self._rootnode.total_num, self._rootnode.left_num)
	self._rootnode.price_nil:setContentSize(self._rootnode.price_old:getContentSize())
	local function update(data)
		if data.checkBag and #data.checkBag > 0 then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.checkBag
			})
			CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
			return
		end
		if data.result == 1 then
			show_tip_label(data_error_error[3500005].prompt)
			return
		end
		if data.result == 0 then
			self._rootnode.rewardBtn:setEnabled(false)
			local dataTemp = {}
			local temp = {}
			temp.id = data.getItem.id
			temp.num = data.getItem.n
			temp.type = data.getItem.t
			temp.iconType = ResMgr.getResType(data.getItem.t)
			temp.name = require("data.data_item_item")[data.getItem.id].name
			table.insert(dataTemp, temp)
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = common:getLanguageString("@RewardList"),
			cellDatas = dataTemp
			})
			CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
			self._rootnode.left_num:setString(common:getLanguageString("@LeftPlayers", data.halfShopItemNum))
			param.updateNumFuc(data.halfShopItemNum)
			if param.confirm then
				param.confirm(itemData.achieve_id, itemData.type)
			end
			game.player:updateMainMenu({
			silver = data.silverNum,
			gold = data.goldNum
			})
			PostNotice(NoticeKey.MainMenuScene_Update)
			alignNodesOneByOne(self._rootnode.total_num, self._rootnode.left_num)
		end
	end
	local function func()
		RequestHelper.kaifukuanghuan.halfBuy({
		callback = function (data)
			dump(data)
			if data["0"] ~= "" then
				dump(data["0"])
			else
				update(data.rtnObj)
			end
		end,
		dayIndex = itemData.dayIndex,
		type = self._type
		})
	end
	self._rootnode.rewardBtn:addHandleOfControlEvent(function (eventName, sender)
		local popup = require("game.KaiFuHuiKui.KaiFuOkPopup").new({
		cost = itemData.shop_sale,
		disStr = common:getLanguageString("@Buy") .. itemData.name .. "?",
		confirmFunc = func
		})
		CCDirector:sharedDirector():getRunningScene():addChild(popup, 100000)
	end,
	CCControlEventTouchUpInside)
	if itemData.hasBuy then
		self._rootnode.rewardBtn:setEnabled(false)
	end
end

return KaiFuOtherView