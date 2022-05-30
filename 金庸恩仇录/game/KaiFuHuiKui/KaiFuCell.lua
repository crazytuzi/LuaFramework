require("game.Biwu.BiwuFuc")
local data_item_item = require("data.data_item_item")
local data_pet_pet = require("data.data_pet_pet")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
local KaiFuCell = class("KaiFuCell", function ()
	return CCTableViewCell:new()
end)
function KaiFuCell:getIconNum()
	return 1
end
function KaiFuCell:getIcon(index)
	return self._icon
end
function KaiFuCell:getIconData()
	return self._iconData
end
function KaiFuCell:getContentSize()
	return cc.size(105, 120)
end
function KaiFuCell:refreshItem(param)
	local itemData = param.itemData
	local rewardIcon = self._rootnode.reward_icon
	rewardIcon:setPositionY(75)
	local nodeTemp = display.newNode()
	if itemData.type ~= ITEM_TYPE.zhenqi then
		ResMgr.refreshIcon({
		id = itemData.id,
		resType = itemData.iconType,
		itemBg = rewardIcon,
		iconNum = itemData.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = display.COLOR_BLACK,
		itemType = itemData.type
		})
		self:createParticalEff(rewardIcon, false)
		local itemStar = 1
		if itemData.iconType == ResMgr.HERO then
			local cardData = ResMgr.getCardData(itemData.id)
			itemStar = cardData.star[1]
		elseif itemData.type == ITEM_TYPE.wuxue then
			if itemData.id < 5300 and itemData.id > 5100 then
				itemStar = data_item_item[itemData.id].quality
			end
		elseif itemData.iconType == ResMgr.PET then
			itemStar = data_pet_pet[itemData.id].star
		elseif itemData.type == ITEM_TYPE.daoju then
			local data = data_item_item[itemData.id]
			if data.effecttype == 9 or data.effecttype == 10 then
				self:createParticalEff(rewardIcon, true)
			end
		end
		if itemStar == 5 then
			local suitArma = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "pinzhikuangliuguang_jin",
			isRetain = true
			})
			suitArma:setPosition(rewardIcon:getContentSize().width / 2, rewardIcon:getContentSize().height / 2)
			suitArma:setTouchEnabled(false)
			rewardIcon:addChild(suitArma)
		end
	else
		nodeTemp:setContentSize(cc.size(105, 120))
		rewardIcon:addChild(require("game.Spirit.SpiritIcon").new({
		resId = itemData.id,
		bShowName = false
		}))
		nodeTemp:setAnchorPoint(cc.p(0.5, 0.5))
		rewardIcon:addChild(nodeTemp, 0, 100)
	end
	local canhunIcon = self._rootnode.reward_canhun
	local suipianIcon = self._rootnode.reward_suipian
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)
	local nameColor = ResMgr.getItemNameColorByType(itemData.id, itemData.iconType)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = itemData.name,
	size = 20,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(100, 60),
	valign = ui.TEXT_VALIGN_BOTTOM
	})
	nameLbl.label:setAnchorPoint(0.5, 0)
	nameLbl.shadow1:setAnchorPoint(0.5, 0)
	self._rootnode.reward_name:removeAllChildren()
	self._rootnode.reward_name:addChild(nameLbl)
	self._icon = itemData.type == 6 and nodeTemp or rewardIcon
	self._iconData = itemData
end
function KaiFuCell:createParticalEff(effNode, isShow)
	effNode:stopAllActions()
	effNode:setRotation(0)
	effNode:removeChild(effNode.particle)
	if isShow then
		local function addParticel(node)
			local particle = CCParticleSystemQuad:create("ccs/particle/ui/p_zaixianlibao.plist")
			particle:setPosition(node:getContentSize().width / 2, node:getContentSize().height * 0.7)
			node:addChild(particle, 1000)
			effNode.particle = particle
		end
		local rotateSeq = transition.sequence({
		CCRotateTo:create(0.05, 10),
		CCRotateTo:create(0.05, 0),
		CCRotateTo:create(0.05, -10),
		CCRotateTo:create(0.05, 0)
		})
		local seq = transition.sequence({
		rotateSeq,
		rotateSeq,
		rotateSeq,
		rotateSeq,
		CCDelayTime:create(3)
		})
		local spawn = CCSpawn:createWithTwoActions(seq, CCCallFuncN:create(addParticel))
		effNode:runAction(CCRepeatForever:create(spawn))
	end
end

function KaiFuCell:create(param)
	local viewSize = param.viewSize
	local itemData = param.itemData
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_center_item_reward.ccbi", proxy, self._rootnode)
	node:setPosition(node:getContentSize().width * 0.5, viewSize.height * 0.5 - 10)
	self:addChild(node)
	self:refreshItem(param)
	return self
end

function KaiFuCell:refresh(param)
	self:refreshItem(param)
end

return KaiFuCell