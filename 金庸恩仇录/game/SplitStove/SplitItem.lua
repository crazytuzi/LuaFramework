local data_item_item = require("data.data_item_item")
local data_item_nature = require("data.data_item_nature")
local data_refine_refine = require("data.data_refine_refine")
local data_fashion_fashion = require("data.data_fashion_fashion")
local data_cheats_cheats = require("data.data_miji_miji")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_talent_talent = require("data.data_talent_talent")
local data_shentong_shentong = require("data.data_shentong_shentong")
local paramStrs = {
common:getLanguageString("@Physique"),
common:getLanguageString("@Strength"),
common:getLanguageString("@Comprehension"),
common:getLanguageString("@Life"),
common:getLanguageString("@Attack")
}

local SplitItem = class("SplitItem", function()
	return CCTableViewCell:new()
end)

function SplitItem:getContentSize()
	return cc.size(display.width, 152)
end

function SplitItem:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("lianhualu/choose_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	for i = 1, 4 do
		local nameLable = ui.newTTFLabelWithShadow({
		text = "",
		font = FONTS_NAME.font_fzcy,
		size = 24,
		color = display.COLOR_WHITE,
		shadowColor = display.COLOR_BLACK,
		})
		ResMgr.replaceKeyLableEx(nameLable, self._rootnode, string.format("itemNameLabel_%d", i), 0, 0)
		nameLable:align(display.LEFT_CENTER)
	end
	
	self.jlIconLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	self._rootnode.iconJLSprite:addChild(self.jlIconLabel)
	
	self.jlLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 24,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	ResMgr.replaceKeyLableEx(self.jlLabel, self._rootnode, "itemNameLabel_2", 0, 0)
	self.jlLabel:align(display.LEFT_CENTER)
	
	self.pjLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 20,
	color = FONT_COLOR.GREEN_1,
	shadowColor = display.COLOR_BLACK,
	})
	ResMgr.replaceKeyLableEx(self.pjLabel, self._rootnode, "pjLabel", 0, 0)
	self.pjLabel:align(display.LEFT_CENTER)
	
	self.hjLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	color = display.COLOR_WHITE,
	shadowColor = display.COLOR_BLACK,
	})
	self.hjLabel:setPosition(5, self._rootnode.hjSprite:getContentSize().height / 2)
	self._rootnode.hjSprite:addChild(self.hjLabel)
	self:refresh(param)
	return self
end

function SplitItem:refreshLabel(param)
	local _itemData = param.itemData
	local nameLabel
	if param.itemType == LIAN_HUA_TYEP.SKILL then
		nameLabel = self._rootnode[string.format("itemNameLabel_%d", 2)]
	elseif param.itemType == LIAN_HUA_TYEP.PET then
		nameLabel = self._rootnode[string.format("itemNameLabel_%d", 1)]
	elseif param.itemType == LIAN_HUA_TYEP.SHIZHUANG then
		nameLabel = self._rootnode[string.format("itemNameLabel_%d", 3)]
	elseif param.itemType == LIAN_HUA_TYEP.CHEATS then
		_itemData.star = data_cheats_cheats[_itemData.resId].quality
		nameLabel = self._rootnode[string.format("itemNameLabel_%d", 4)]
	else
		nameLabel = self._rootnode[string.format("itemNameLabel_%d", param.itemType)]
	end
	nameLabel:setString(tostring(_itemData.name))
	nameLabel:setColor(NAME_COLOR[_itemData.star])
	if param.itemType == LIAN_HUA_TYEP.CHEATS then
		self._rootnode.lvLabel:setString(common:getLanguageString("@CheatsCeng", _itemData.level))
	else
		self._rootnode.lvLabel:setString(tostring(string.format("LV.%d", _itemData.level)))
	end
end

function SplitItem:selected()
	self._rootnode.selectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
end

function SplitItem:unselected()
	self._rootnode.selectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
end

function SplitItem:touch()
	self:selected()
end

function SplitItem:changeState(sel)
	if sel then
		self:selected()
	else
		self:unselected()
	end
end

function SplitItem:refreshSkillAndEquip(itemData, itemType)
	self._rootnode.lvLabel:setPosition(cc.p(64, 17))
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = itemData.resId,
	resType = ResMgr.EQUIP
	})
	for i = 1, 3 do
		self._rootnode["propLabel_" .. tostring(i)]:setVisible(false)
	end
	self._rootnode.qualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", itemData.star)))
	self.pjLabel:setString(tostring(data_item_item[itemData.resId].equip_level))
	if itemType == LIAN_HUA_TYEP.SKILL then
		self:refreshSkill(itemData)
	elseif itemType == LIAN_HUA_TYEP.EQUIP then
		self:refreshEquip(itemData)
	end
end

function SplitItem:refreshEquip(itemData)
	--self.jlLabel:setString("")
	local equipType = {
	"equip_helment_tab.png",
	"equip_weapon_tab.png",
	"equip_ear_tab.png",
	"equip_armour_tab.png"
	}
	self._rootnode.tabIcon:setDisplayFrame(display.newSpriteFrame(equipType[data_item_item[itemData.resId].pos]))
	local index = 1
	for k, v in ipairs(itemData.base) do
		if v > 0 then
			local nature = data_item_nature[EQUIP_BASE_PROP_MAPPPING[k]]
			local str = nature.nature
			if nature.type == 1 then
				str = str .. string.format("+%d", v)
			else
				str = str .. string.format("+%d%%", v / 100)
			end
			self._rootnode["propLabel_" .. tostring(index)]:setString(str)
			self._rootnode["propLabel_" .. tostring(index)]:setVisible(true)
			index = index + 1
		end
	end
end

function SplitItem:refreshHero(itemData)
	for i = 1, 5 do
		if i <= itemData.star then
			self._rootnode[string.format("star_1_%d", i)]:setVisible(true)
		else
			self._rootnode[string.format("star_1_%d", i)]:setVisible(false)
		end
	end
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = itemData.resId,
	resType = ResMgr.HERO
	})
	local card = ResMgr.getCardData(itemData.resId)
	if itemData.cls > 0 then
		self._rootnode.clsLabel:setString(string.format("+%d", itemData.cls))
	else
		self._rootnode.clsLabel:setString("")
	end
	self.hjLabel:setString(common:getLanguageString("@zizhi", card.arr_zizhi[itemData.cls + 1]))
	self.hjLabel:setPositionX(10 + self.hjLabel:getContentSize().width / 2)
	self._rootnode.jobSprite:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", card.job)))
	self._rootnode.jobSprite:setVisible(true)
	self._rootnode.lvLabel:setPosition(cc.p(74, 17))
end

function SplitItem:refreshPet(itemData)
	for i = 1, 5 do
		if i <= itemData.star then
			self._rootnode[string.format("star_1_%d", i)]:setVisible(true)
		else
			self._rootnode[string.format("star_1_%d", i)]:setVisible(false)
		end
	end
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = itemData.resId,
	resType = ResMgr.PET
	})
	if itemData.cls > 0 then
		self._rootnode.clsLabel:setString(string.format("+%d", itemData.cls))
	else
		self._rootnode.clsLabel:setString("")
	end
	local petData = ResMgr.getPetData(itemData.resId)
	self.hjLabel:setString(common:getLanguageString("@zizhi", petData.arr_zizhi))
	self.hjLabel:setPositionX(10 + self.hjLabel:getContentSize().width / 2)
	self._rootnode.jobSprite:setVisible(false)
	self._rootnode.lvLabel:setPosition(cc.p(60, 17))
	self._rootnode.lvLabel:setString(tostring(string.format("LV.%d", itemData.level)))
end

function SplitItem:refreshSkill(itemData)
	--self.jlLabel:setString("")
	if data_item_item[itemData.resId].pos == 5 or data_item_item[itemData.resId].pos == 101 then
		self._rootnode.tabIcon:setDisplayFrame(display.newSpriteFrame("item_board_ng.png"))
	else
		self._rootnode.tabIcon:setDisplayFrame(display.newSpriteFrame("item_board_wg.png"))
	end
	if data_refine_refine[itemData.resId] and data_refine_refine[itemData.resId].Refine and data_refine_refine[itemData.resId].Refine > 0 then
		local refineInfo = data_refine_refine[itemData.resId]
		local propCount = #refineInfo.arr_nature2
		local num = math.floor(itemData.propsN / propCount)
		if num > 0 then
			self.jlLabel:setString(string.format("+%d", num))
			--self.jlLabel:setPositionX(self._rootnode.nameLabel_2:getContentSize().width + self.jlLabel:getContentSize().width / 2)
			self._rootnode.iconJLSprite:setVisible(true)
			self.jlIconLabel:setString(tostring(num))
			self.jlIconLabel:setPosition(self._rootnode.iconJLSprite:getContentSize().width + self.jlIconLabel:getContentSize().width / 2, self._rootnode.iconJLSprite:getContentSize().height / 2)
		end
	end
	local index = 1
	for i = 1, 4 do
		local prop = itemData.base[i]
		local str = ""
		if prop > 0 then
			local data_item_nature = require("data.data_item_nature")
			local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
			str = nature.nature
			if nature.type == 1 then
				str = str .. string.format("+%d", prop)
			else
				str = str .. string.format("+%.2f%%", prop / 100)
			end
			self._rootnode["propLabel_" .. tostring(index)]:setString(str)
			self._rootnode["propLabel_" .. tostring(index)]:setVisible(true)
			index = index + 1
		end
	end
end

function SplitItem:refreshShiZhuang(itemData)
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = itemData.resId,
	resType = ResMgr.FASHION
	})
	local staticdata = data_item_item[itemData.resId]
	self._rootnode.starNumSprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", staticdata.quality)))
	for k, v in ipairs(paramStrs) do
		self._rootnode["stateValue" .. k]:setString(paramStrs[k] .. itemData.base[k])
	end
end

function SplitItem:refreshCheats(itemData)
	local CheatsType = {
	"cheats_xinfa_tab.png",
	"cheats_juexue_tab.png"
	}
	ResMgr.refreshIcon({
	itemBg = self._rootnode.headIcon,
	id = itemData.resId,
	resType = ResMgr.CHEATS
	})
	local staticdata = data_cheats_cheats[itemData.resId]
	--心法品质
	self._rootnode.cheatsQualitySprite:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", staticdata.quality)))
	--心法图标
	self._rootnode.tabCheatsIcon:setDisplayFrame(display.newSpriteFrame(CheatsType[staticdata.type]))
	--神通
	self._rootnode.cheatsSkillIcon:setDisplayFrame(display.newSpriteFrame(string.format("heroinfo_cheats_%d.png", staticdata.type)))
	local ceng = itemData.level
	if staticdata.type == 1 then
		local skillId = staticdata.skill[1]
		local shentong = data_shentong_shentong[skillId]
		local skillData = data_talent_talent[shentong.arr_talent[ceng]]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.type)
	else
		local skillId = staticdata.skill[ceng]
		local skillData = data_battleskill_battleskill[skillId]
		self._rootnode.cheats_skill_name:setString(skillData.name)
		self._rootnode.cheats_skill_des:setString(skillData.desc)
	end
end

function SplitItem:refresh(param)
	local _itemData = param.itemData
	local _sel = param.sel
	self:changeState(_sel)
	self:refreshLabel(param)
	self._rootnode.iconJLSprite:setVisible(false)
	if LIAN_HUA_TYEP.SKILL == param.itemType or LIAN_HUA_TYEP.EQUIP == param.itemType then
		self._rootnode[string.format("typeNode_%d", 2)]:setVisible(true)
		self._rootnode[string.format("typeNode_%d", 1)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 3)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 4)]:setVisible(false)
		self:refreshSkillAndEquip(_itemData, param.itemType)
	elseif LIAN_HUA_TYEP.HERO == param.itemType then
		self._rootnode[string.format("typeNode_%d", 1)]:setVisible(true)
		self._rootnode[string.format("typeNode_%d", 2)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 3)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 4)]:setVisible(false)
		self:refreshHero(_itemData)
	elseif LIAN_HUA_TYEP.PET == param.itemType then
		self._rootnode[string.format("typeNode_%d", 1)]:setVisible(true)
		self._rootnode[string.format("typeNode_%d", 2)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 3)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 4)]:setVisible(false)
		self:refreshPet(_itemData)
	elseif LIAN_HUA_TYEP.SHIZHUANG == param.itemType then
		self._rootnode[string.format("typeNode_%d", 1)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 2)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 3)]:setVisible(true)
		self._rootnode[string.format("typeNode_%d", 4)]:setVisible(false)
		self:refreshShiZhuang(_itemData)
	elseif LIAN_HUA_TYEP.CHEATS == param.itemType then
		self._rootnode[string.format("typeNode_%d", 1)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 2)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 3)]:setVisible(false)
		self._rootnode[string.format("typeNode_%d", 4)]:setVisible(true)
		self:refreshCheats(_itemData)
	end
end

return SplitItem