local titles = {
common:getLanguageString("@Intensify"),
common:getLanguageString("@Baptize"),
common:getLanguageString("@Refinement")
}
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")
local data_equipquench_equipquench = require("data.data_equipquench_equipquench")

local CommonEquipInfoLayer = class("CommonEquipInfoLayer", function()
	return require("utility.ShadeLayer").new()
end)

function CommonEquipInfoLayer:getEquipAtrrs(pos, index)
	local equip = self._info
	local itemData = {}
	local dataTemp = {}
	for k2, v2 in pairs(data_item_item[equip.resId].arr_nature) do
		local dataT = {}
		dataT.name = data_item_nature[v2].nature
		dataT.value = data_item_item[equip.resId].arr_addition[k2] * equip.level
		dataTemp[#dataTemp + 1] = dataT
	end
	itemData.title = titles[1]
	itemData.data = dataTemp
	itemData.type = 1
	itemData.level = equip.level
	itemData.baselevel = self._info.role.level * 2
	if #itemData.data == 0 or equip.level == 0 then
		return nil
	else
		return itemData
	end
	return false
end

function CommonEquipInfoLayer:getCulianAttrs(index, pos)
	local baseData = self._info.cuilian
	if baseData and baseData.cls ~= 0 then
		local keys = {
		"arr_hp",
		"arr_attack",
		"arr_defense",
		"arr_defenseM"
		}
		local name = {
		common:getLanguageString("@life2"),
		common:getLanguageString("@Attack2"),
		common:getLanguageString("@ThingDefense2"),
		common:getLanguageString("@LawDefense2")
		}
		local cls = baseData.cls
		local itemdataT = {}
		local itemData = {}
		for k, v in pairs(keys) do
			if data_equipquench_equipquench[pos][v][cls] ~= 0 then
				local dataTemp = {}
				dataTemp.name = name[k]
				dataTemp.value = data_equipquench_equipquench[pos][v][cls] / 100 .. "%"
				itemdataT[#itemdataT + 1] = dataTemp
			end
		end
		itemData.title = titles[3]
		itemData.data = itemdataT
		itemData.type = 3
		itemData.level = cls
		self._cls = cls
		itemData.baselevel = data_equipquench_equipquench[pos].limit
		if #itemData.data == 0 then
			return nil
		else
			return itemData
		end
	else
		return false
	end
end

function CommonEquipInfoLayer:getXlianAttrs(pos, index)
	local xilianAttr = self._info.props
	if xilianAttr and _G.next(xilianAttr) ~= nil then
		local itemData = {}
		local dataTemp = {}
		for k2, v2 in pairs(xilianAttr) do
			local dataT = {}
			dataT.name = data_item_nature[v2.idx].nature
			dataT.idx = v2.idx
			dataT.value = v2.val
			dataTemp[#dataTemp + 1] = dataT
		end
		itemData.title = titles[2]
		itemData.data = dataTemp
		itemData.type = 2
		if #itemData.data == 0 then
			return nil
		else
			return itemData
		end
	else
		return false
	end
	return false
end

function CommonEquipInfoLayer:initSuit(_info)
	self.scrollBg:setTouchEnabled(true)
	self.suitInfo = require("game.Equip.EquipSuitInfo").new({
	curId = self.resId
	})
	self.suitInfo:setAnchorPoint(0.5, 1)
	self._rootnode.taozhuang_node:addChild(self.suitInfo)
	local maxOff = 470 + self.suitInfo:getHeight()
	self.scrollBg:setContentSize(cc.size(display.width, maxOff))
	self.scrollBg:setContentOffset(cc.p(0, -150), false)
	self.contentContainer:setPosition(display.cx, maxOff)
	local index = 0
	local lastHeight = self.suitInfo:getHeight()
	local offset = -220
	if self:getEquipAtrrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getEquipAtrrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(self.suitInfo:getHeight() - lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	if self:getCulianAttrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getCulianAttrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(self.suitInfo:getHeight() - lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	if self:getXlianAttrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getXlianAttrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(self.suitInfo:getHeight() - lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	self.suitInfo:setPositionY(self.suitInfo:getHeight() - lastHeight)
end

function CommonEquipInfoLayer:initBase()
	local index = 0
	local lastHeight = 0
	local offset = -220
	if self:getEquipAtrrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getEquipAtrrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(-lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	if self:getCulianAttrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getCulianAttrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(-lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	if self:getXlianAttrs(self._subIndex, self._index) then
		index = index + 1
		local equipInfo = require("game.Equip.EquipCommonItem").new({
		data = self:getXlianAttrs(self._subIndex, self._index)
		})
		equipInfo:setAnchorPoint(0.5, 1)
		self._rootnode.taozhuang_node:addChild(equipInfo)
		local maxOff = 470 + lastHeight + equipInfo:getHeight()
		equipInfo:setPositionY(-lastHeight)
		self.scrollBg:setContentSize(cc.size(display.width, maxOff))
		self.contentContainer:setPosition(display.width / 2, maxOff)
		lastHeight = equipInfo:getHeight() + lastHeight
		self.scrollBg:setContentOffset(cc.p(0, -lastHeight - offset), false)
	end
	if index == 0 then
		self.scrollBg:setTouchEnabled(false)
	end
end

function CommonEquipInfoLayer:ctor(param, infoType)
	self:setNodeEventEnabled(true)
	self._info = clone(param.info)
	self._bak_info = param.info
	local _subIndex = param.subIndex
	local _index = param.index
	local _listener = param.listener
	local _bEnemy = param.bEnemy
	dump("====================_subIndex" .. _subIndex)
	dump("====================_index" .. _index)
	self._hasAdd = param.hasAdd or false
	self._index = _subIndex
	self._subIndex = _index
	local _closeListener = param.closeListener
	local _baseInfo = data_item_item[self._info.resId]
	local boardSize
	if _baseInfo.Suit == nil then
		if not self:getEquipAtrrs(self._subIndex, self._index) and not self:getCulianAttrs(self._subIndex, self._index) and not self:getXlianAttrs(self._subIndex, self._index) then
			boardSize = cc.size(display.width, 620)
		else
			boardSize = cc.size(display.width, 850)
		end
	else
		boardSize = cc.size(display.width, 850)
	end
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgNode = CCBuilderReaderLoad("equip/equip_comon_info.ccbi", self._proxy, self._rootnode, self, boardSize)
	bgNode:setPosition(display.cx, display.cy - bgNode:getContentSize().height / 2)
	self:addChild(bgNode, 1, 2222)
	local coProxy = CCBProxy:create()
	self.contentContainer = CCBuilderReaderLoad("equip/equip_comon_content.ccbi", coProxy, self._rootnode, self, cc.size(640, 620))
	self.contentNode = display.newNode()
	self.contentNode:addChild(self.contentContainer)
	self.contentNode:setPosition(display.cx, 0)
	self.scrollBg = CCScrollView:create()
	bgNode:addChild(self.scrollBg)
	self.scrollBg:setContainer(self.contentNode)
	self.scrollBg:setPosition(0, 80)
	self.scrollBg:setViewSize(cc.size(display.width, boardSize.height - 150))
	local maxOff = 800
	self.scrollBg:setContentSize(cc.size(display.width, maxOff))
	self.scrollBg:setDirection(kCCScrollViewDirectionVertical)
	self.scrollBg:setContentOffset(cc.p(0, -maxOff / 2 + 55), false)
	self.scrollBg:ignoreAnchorPointForPosition(true)
	self.scrollBg:updateInset()
	self.contentContainer:setPosition(display.width / 2, maxOff)
	self._rootnode.titleLabel:setString(common:getLanguageString("@EquitInfo"))
	self.resId = self._info.resId
	self.baseInfo = _baseInfo
	local isSuit = _baseInfo.Suit
	if isSuit == nil then
		self:initBase()
	else
		self:initSuit()
	end
	
	if self._info.star > 5 then
		self._info.star = 5
	end
	
	for i = 1, self._info.star do
		local starnode = self._rootnode[string.format("star%d", i)]
		if starnode ~= nil then
			starnode:setVisible(true)
		end
	end
	
	local path = ResMgr.getLargeImage(_baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	if infoType == 2 then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
	end
	
	self._rootnode.closeBtn:setVisible(true)
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		if _closeListener then
			_closeListener()
		end
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	local function change()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		CCDirector:sharedDirector():popToRootScene()
		push_scene(require("game.form.EquipChooseScene").new({
		index = _index,
		subIndex = _subIndex,
		cid = self._info.cid,
		callback = function(data)
			_listener(data)
			self:removeSelf()
		end
		}))
	end
	local function takeOff()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelper.formation.putOnEquip({
		pos = _index,
		subpos = _subIndex,
		callback = function(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
			else
				self._bak_info.pos = 0
				self._bak_info.cid = 0
				if _listener then
					_listener(data)
				end
				self:removeSelf()
			end
		end
		})
	end
	local function addCulianAttr(index, pos)
		local baseData = self._info.cuilian
		if baseData and baseData.cls ~= 0 then
			local keys = {
			"arr_hp",
			"arr_attack",
			"arr_defense",
			"arr_defenseM"
			}
			local name = {
			common:getLanguageString("@life2"),
			common:getLanguageString("@Attack2"),
			common:getLanguageString("@ThingDefense2"),
			common:getLanguageString("@LawDefense2")
			}
			local cls = baseData.cls
			local itemdataT = {}
			local itemData = {}
			for k, v in pairs(keys) do
				if data_equipquench_equipquench[pos][v][cls] ~= 0 then
					self._info.base[k] = math.ceil(self._info.base[k] * (1 + data_equipquench_equipquench[self._index][v][cls] / 10000))
				end
			end
		end
	end
	local function refresh()
		self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#item_card_bg_" .. _baseInfo.quality .. ".png"):getDisplayFrame())
		local index = 1
		local hasAttr = {}
		local keys = {
		21,
		22,
		23,
		24
		}
		for k, v in ipairs(self._info.base) do
			if self._rootnode["basePropLabel_" .. tostring(k)] then
				self._rootnode["basePropLabel_" .. tostring(k)]:setString("")
			end
			local nature = data_item_nature[EQUIP_BASE_PROP_MAPPPING[k]]
			if v > 0 then
				local str = nature.nature
				if nature.type == 1 then
					str = str .. string.format(": +%d", v)
				else
					str = str .. string.format(": +%d%%", v / 10)
				end
				self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
				hasAttr[index] = EQUIP_BASE_PROP_MAPPPING[k]
				index = index + 1
			end
		end
		local function checkIsExit(id)
			for k2, v2 in pairs(hasAttr) do
				if id == v2 then
					return true
				end
			end
			return false
		end
		local xilianData = self:getXlianAttrs(self._subIndex, self._index)
		local function getExtraAttr()
			dump(xilianData.data)
			dump(hasAttr)
			for k1, v1 in pairs(xilianData.data) do
				if not checkIsExit(v1.idx) then
					local nature = data_item_nature[v1.idx]
					if v1.value > 0 then
						local str = nature.nature
						if nature.type == 1 then
							str = str .. string.format(": +%d", v1.value)
						else
							str = str .. string.format(": +%d%%", v1.value / 10)
						end
						self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
						hasAttr[index] = EQUIP_BASE_PROP_MAPPPING[k]
						index = index + 1
					end
				end
			end
		end
		if xilianData and xilianData.data then
			getExtraAttr()
		end
		self._rootnode.curLvLabel:setString(self._info.level)
	end
	local function qiangHua()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhuangBei_QiangHua, game.player:getLevel(), game.player:getVip())
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		if not bHasOpen then
			show_tip_label(prompt)
		else
			self._rootnode.qiangHuBtn:setEnabled(false)
			local layer = require("game.Equip.FormEquipQHLayer").new({
			info = self._info,
			listener = function()
				refresh()
				_listener()
				self:removeSelf()
			end
			})
			self:setVisible(false)
			game.runningScene:addChild(layer, 11)
		end
	end
	local function xiLian()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiLian, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(prompt)
		else
			local layer = require("game.Equip.FormEquipXiLianLayer").new({
			info = self._info,
			listener = function()
				refresh()
				_listener()
				self:removeSelf()
			end
			})
			self:setVisible(false)
			game.runningScene:addChild(layer, 11)
		end
	end
	if not self._hasAdd then
		addCulianAttr(self._subIndex, self._index)
	end
	local str
	if self._cls then
		str = " +" .. self._cls
	else
		str = ""
	end
	local nameLabel = ui.newTTFLabelWithShadow({
	text = _baseInfo.name .. str,
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[_baseInfo.quality],
	shadowColor = display.COLOR_BLACK,
	})
	
	--self._rootnode.itemNameLabel:addChild(nameLabel)
	ResMgr.replaceKeyLableEx(nameLabel, self._rootnode, "itemNameLabel", 0, 0)
	nameLabel:align(display.CENTER)
	
	
	
	self._rootnode.descLabel:setString(_baseInfo.describe)
	self._rootnode.cardName:setString(_baseInfo.name)
	self._rootnode.changeBtn:addHandleOfControlEvent(change, CCControlEventTouchDown)
	self._rootnode.takeOffBtn:addHandleOfControlEvent(takeOff, CCControlEventTouchDown)
	self._rootnode.qiangHuBtn:addHandleOfControlEvent(qiangHua, CCControlEventTouchUpInside)
	if _baseInfo.polish == 1 then
		self._rootnode.xiLianBtn:addHandleOfControlEvent(xiLian, CCControlEventTouchUpInside)
	else
		self._rootnode.xiLianBtn:setVisible(false)
	end
	if _bEnemy then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.xiLianBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
		self._rootnode.qiangHuBtn:setVisible(false)
	end
	refresh()
end

function CommonEquipInfoLayer:onEnter()
	TutoMgr.addBtn("equip_info_qianghua_btn", self._rootnode.qiangHuBtn)
	TutoMgr.active()
end

function CommonEquipInfoLayer:onExit()
	TutoMgr.removeBtn("equip_info_qianghua_btn")
end

return CommonEquipInfoLayer