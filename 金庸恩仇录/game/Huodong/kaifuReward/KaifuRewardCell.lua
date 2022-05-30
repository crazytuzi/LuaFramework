local data_item_item = require("data.data_item_item")

local KaifuRewardCell = class("KaifuRewardCell", function()
	return CCTableViewCell:new()
end)

function KaifuRewardCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("reward/kaifu_reward_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function KaifuRewardCell:setTitle(index)
	self._rootnode.index:setString(common:getLanguageString("DI") .. index .. common:getLanguageString("@Day"))
end

function KaifuRewardCell:getRewardBtn()
	return self._rootnode.rewardBtn
end

function KaifuRewardCell:checkEnabled()
	local rewardBtn = self._rootnode.rewardBtn
	local rewarded = 0
	rewardBtn:setVisible(true)
	self._rootnode.tag_has_get:setVisible(false)
	if self._hasRewardDays ~= nil then
		for i, v in ipairs(self._hasRewardDays) do
			if v == self._day then
				rewarded = 1
				break
			end
		end
	end
	if self._day > self._curDay then
		rewardBtn:setEnabled(false)
	elseif rewarded == 1 then
		rewardBtn:setVisible(false)
		self._rootnode.tag_has_get:setVisible(true)
	else
		rewardBtn:setEnabled(true)
	end
end

function KaifuRewardCell:updateItem(itemData)
	for i, v in ipairs(itemData) do
		local reward = self._rootnode["reward_" .. tostring(i)]
		reward:setVisible(true)
		local rewardIcon = self._rootnode["reward_icon_" .. tostring(i)]
		rewardIcon:removeAllChildrenWithCleanup(true)
		ResMgr.refreshIcon({
		id = v.id,
		resType = v.iconType,
		itemBg = rewardIcon,
		iconNum = v.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = ccc3(0, 255, 0),
		numLblOutColor = ccc3(0, 0, 0),
		itemType = v.type
		})
		local isShowEffect = false
		if v.iconType == ResMgr.EQUIP and data_item_item[v.id].quality == 5 then
			isShowEffect = true
		elseif v.iconType == ResMgr.HERO then
			local cardData = ResMgr.getCardData(v.id)
			local itemStar = cardData.star[1]
			if itemStar == 5 then
				isShowEffect = true
			end
		end
		if isShowEffect == true then
			local suitArma = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "pinzhikuangliuguang_jin",
			isRetain = true
			})
			suitArma:setPosition(rewardIcon:getContentSize().width / 2, rewardIcon:getContentSize().height / 2)
			suitArma:setTouchEnabled(false)
			rewardIcon:addChild(suitArma)
		end
		local sz = rewardIcon:getContentSize()
		local h
		local canhunIcon = self._rootnode["reward_canhun_" .. i]
		local suipianIcon = self._rootnode["reward_suipian_" .. i]
		canhunIcon:setVisible(false)
		suipianIcon:setVisible(false)
		local nameKey = "reward_name_" .. tostring(i)
		local nameColor = ResMgr.getItemNameColorByType(v.id, v.iconType)
		
		local nameLbl = ui.newTTFLabelWithShadow({
		text = v.name,
		size = 20,
		color = nameColor,
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER,
		valign = ui.TEXT_VALIGN_BOTTOM,
		dimensions = cc.size(100, 0),
		})
		
		ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 0)
		nameLbl:align(display.CENTER)
		
	end
	local count = #itemData
	while count < 4 do
		self._rootnode["reward_" .. tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end

function KaifuRewardCell:refreshItem(param)
	local itemData = param.itemData
	self._day = param.day
	self:setTitle(self._day)
	self:checkEnabled()
	self:updateItem(itemData)
end

function KaifuRewardCell:getIcon(index)
	return self._rootnode["reward_icon_" .. tostring(index)]
end

function KaifuRewardCell:setRewardEnabled(bEnable)
	self._rootnode.rewardBtn:setEnabled(bEnable)
end

function KaifuRewardCell:create(param)
	self._curDay = param.curDay
	self._hasRewardDays = param.hasRewardDays
	local viewSize = param.viewSize
	local cellData = param.cellData
	local rewardListener = param.rewardListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/kaifu_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if rewardListener then
			self:setRewardEnabled(false)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			rewardListener(self)
		end
	end,
	CCControlEventTouchUpInside)
	
	self:refreshItem({
	day = cellData.day,
	itemData = cellData.itemData
	})
	return self
end

function KaifuRewardCell:getDay()
	return self._day
end

function KaifuRewardCell:refresh(param)
	self:refreshItem(param)
end

function KaifuRewardCell:getReward(hasRewardDays)
	self._hasRewardDays = hasRewardDays
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:setVisible(false)
	self._rootnode.tag_has_get:setVisible(true)
end

return KaifuRewardCell