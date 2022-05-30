local COMMON_VIEW = 1
local SALE_VIEW = 2
local data_cheats_cheats = require("data.data_miji_miji")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_talent_talent = require("data.data_talent_talent")
local data_shentong_shentong = require("data.data_shentong_shentong")
display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")

local CheatsListCell = class("CheatsListCell", function(param)
	return CCTableViewCell:new()
end)

function CheatsListCell:getContentSize()
	return cc.size(display.width, 165)
end

function CheatsListCell:getJinjieBtn()
	return self._rootnode.jinjieBtn
end

function CheatsListCell:create(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._showCheatsInfoLayer = param.showCheatsInfoLayer
	self._showCheatsJinJieLayer = param.showCheatsJinJieLayer
	local node = CCBuilderReaderLoad("cheats/cheats_list_item.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	self._rootnode.touchNode:setTouchEnabled(true)
	self.heroName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 22,
	align = ui.TEXT_ALIGN_LEFT,
	shadowColor = FONT_COLOR.BLACK
	})
	self.heroName:setAnchorPoint(cc.p(0, 0.5))
	self._rootnode.itemNameLabel:addChild(self.heroName)
	self.headIcon = self._rootnode.headIcon
	self._rootnode.yanxiBtn:setVisible(true)
	self._rootnode.upgradeBtn:setVisible(false)
	self:refresh(param.index)
	return self
end

local CheatsType = {
"cheats_xinfa_tab.png",
"cheats_juexue_tab.png"
}

function CheatsListCell:refresh(index)
	self.index = index
	local itemData = CheatsModel.totalTable[index]
	local id = itemData.resId
	local starsNum = data_cheats_cheats[id].quality
	local ceng = itemData.floor
	local bTouch = false
	local offsetX = 0
	local localItemData = ResMgr.getRefreshIconItem(id, ITEM_TYPE.cheats)
	self.heroName:setString(localItemData.name)
	self.heroName:setPosition(self.heroName:getContentSize().width / 2, 0)
	self.heroName:setColor(NAME_COLOR[starsNum])
	ResMgr.refreshIcon({
	id = id,
	itemBg = self.headIcon,
	resType = ResMgr.CHEATS,
	star = starsNum
	})
	self._rootnode.lvNum:setString(common:getLanguageString("@CheatsCeng", ceng))
	self._rootnode.flagSprite:setDisplayFrame(display.newSpriteFrame(CheatsType[data_cheats_cheats[id].type]))
	if data_cheats_cheats[id].type == 1 then
		local skillId = data_cheats_cheats[id].skill[1]
		local shentong = data_shentong_shentong[skillId]
		local skillData = data_talent_talent[shentong.arr_talent[ceng]]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.type)
	else
		local skillId = data_cheats_cheats[id].skill[ceng]
		local skillData = data_battleskill_battleskill[skillId]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.desc)
	end
	
	self._rootnode.cheats_skill_icon:setDisplayFrame(display.newSpriteFrame(string.format("heroinfo_cheats_%d.png", data_cheats_cheats[id].type)))
	self._rootnode.qualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", starsNum)))
	local cid = itemData.cid
	if cid > 0 then
		local card = ResMgr.getCardData(cid)
		if card.id == 1 or card.id == 2 then
			self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", game.player:getPlayerName()))
		else
			self._rootnode.equipHeroName:setString(common:getLanguageString("@EquipAt", card.name))
		end
	else
		self._rootnode.equipHeroName:setString("")
	end
	
	ResMgr.setControlBtnEvent(self._rootnode.yanxiBtn, function()
		if data_cheats_cheats[itemData.resId].height * data_cheats_cheats[itemData.resId].number == itemData.level then
			ResMgr.showErr(2200003)
			return
		end
		if self._showCheatsJinJieLayer ~= nil then
			self._showCheatsJinJieLayer(index)
		end
	end)
end

function CheatsListCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(cc.p(self:getContentSize().width / 2 + display.width / 2, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, cc.p(-(self:getContentSize().width / 2 + display.width / 2), 0))
	})
	self:runAction(sequence)
end

function CheatsListCell:tableCellTouched(x, y)
	local icon = self._rootnode.touchNode
	if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height),icon:convertToNodeSpace(cc.p(x, y))) then
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		--√ÿºÆœÍ«È
		if self._showCheatsInfoLayer ~= nil then
			self._showCheatsInfoLayer(self.index)
		end
	end
end

return CheatsListCell