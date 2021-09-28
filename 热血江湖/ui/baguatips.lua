-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/base")
-------------------------------------------------------
wnd_baguaTips = i3k_class("wnd_baguaTips", ui.wnd_base)

local LAYER_BAGUATIPST = "ui/widgets/baguatipst"    --属性
local LAYER_BAGUATIPST2 = "ui/widgets/baguatipst2"  --标题
local LAYER_BAGUATIPST3 = "ui/widgets/baguatipst3"  --词缀
local LAYER_BAGUATIPST4 = "ui/widgets/baguatipst4"  --套装
local LAYER_BAGUATIPST5 = "ui/widgets/zbtipstys"  --套装

local compare_icon = {
	174,
	175,
	176,
}

function wnd_baguaTips:ctor()
	self.equipId = 0
	self.partId = 0
	self.isWear = false
	self.isOut = false  --外部点开不显示按钮
	self.equipDiagrams = {}
	self.diagramPartStrength = {}
	self.changeSkills = nil
	self.isFriend = false

	self.rank = 0

	self.leftPower = 0
	self.isBijiao = false
end

function wnd_baguaTips:configure()
	local widgets = self._layout.vars
	widgets.globel_bt:onClick(self, self.onCloseUI)

	self.ui = widgets

	self.ui.btn1:onClick(self, self.onSplit)    --分解
	self.ui.btn2:onClick(self, self.onWear)     --装备或卸下
	self.ui.btn3:onClick(self, self.onExtract)  --萃取
end

--isBag == true表示是点击背包中的八卦
function wnd_baguaTips:refresh(data)
	local equipInfo = data.equip
	if equipInfo.yilue then
		self.changeSkills = equipInfo.yilue.changeSkills
	end
	if equipInfo then
		self.equipId = equipInfo.id
		self.partId = equipInfo.part
		self.isOut = data.isOut

		if data.equipDiagrams and data.diagramPartStrength then
			self.equipDiagrams = data.equipDiagrams
			for partId, level in pairs(data.diagramPartStrength) do
				self.diagramPartStrength[partId] = {level = level}
			end
			self.isFriend = true
			self.ui.layer2:hide()
		else
			local bagDiagrams = g_i3k_game_context:GetBagDiagrams()
			local equipDiagrams = g_i3k_game_context:getEquipDiagrams()
			local diagramPartStrength = g_i3k_game_context:getPartStrength()

			self.equipDiagrams = equipDiagrams
			self.diagramPartStrength = diagramPartStrength
			self.isFriend = false

			if bagDiagrams[self.equipId] then
				self.isWear = false
				local data = equipDiagrams[self.partId]
				if data then
					data.yilue.changeSkills = g_i3k_game_context:GetBaguaYilue().changeSkills
					self.isBijiao = true
					data.showYilue = true
					self:setEquipTips(data)
					self.ui.layer2:show()
					self.ui.label2:setText("更换")
				else
					self.ui.layer2:hide()
					self.ui.label2:setText("装备")
				end
			else
				self.isWear = true
				self.ui.layer2:hide()
				self.ui.label2:setText("卸下")
			end
		end
		if self.isBijiao then
			equipInfo.showYilue = false
		end
		self:setBagTips(equipInfo)
		self:updateBtnState(equipInfo)
	end
end

function wnd_baguaTips:updateBtnState(equipInfo)
	if self.isOut then
		self.ui.btn1:hide()
		self.ui.btn2:hide()
		self.ui.btn3:hide()
	else
		self.ui.btn2:show()
		self.ui.btn1:setVisible(not self.isWear)

		local extractID = g_i3k_db.i3k_db_get_bagua_extractID(equipInfo.additionProp)
		self.ui.btn3:setVisible((not self.isWear) and (extractID ~= 0))
	end
end

--已装备
function wnd_baguaTips:setEquipTips(data)
	local rank = g_i3k_db.i3k_db_get_bagua_rank(data.additionProp)
	self.ui.equip_name2:setText(g_i3k_db.i3k_db_get_bagua_info(data.part).name)
	self.ui.equip_name2:setTextColor(g_i3k_get_color_by_rank(rank + 1))
	self.ui.equip_bg2:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))
	self.ui.equip_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(data.part).icon))

	local basePower = g_i3k_game_context:getBaGuaBasePower(data)
	local addPower = g_i3k_game_context:getBaGuaPower(data, self.diagramPartStrength, self.equipDiagrams) - basePower
	if addPower == 0 then
		self.ui.power_value2:setText(basePower)
	else
		self.ui.power_value2:setText(string.format("%s+%s", basePower, addPower))
	end
	
	self.leftPower = basePower

	self.ui.level2:hide()
	self.ui.scroll2:removeAllChildren()

	self:setPropScroll(self.ui.scroll2, data)
end

function wnd_baguaTips:setBagTips(data)
	local rank = g_i3k_db.i3k_db_get_bagua_rank(data.additionProp)
	self.rank = rank

	self.ui.equip_name1:setText(g_i3k_db.i3k_db_get_bagua_info(data.part).name)
	self.ui.equip_name1:setTextColor(g_i3k_get_color_by_rank(rank + 1))
	self.ui.equip_bg1:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))
	self.ui.equip_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(data.part).icon))

	local basePower = g_i3k_game_context:getBaGuaBasePower(data)
	if self.isFriend or (self.isWear and not self.isOut) then
		local addPower = g_i3k_game_context:getBaGuaPower(data, self.diagramPartStrength, self.equipDiagrams) - basePower
		if addPower == 0 then
			self.ui.power_value1:setText(basePower)
		else
			self.ui.power_value1:setText(string.format("%s+%s", basePower, addPower))
		end
	else
		self.ui.power_value1:setText(basePower)
	end

	if self.leftPower > 0 then
		if self.leftPower > basePower then
			self.ui.mark_icon:setImage(i3k_db_icons[compare_icon[2]].path)
		elseif self.leftPower < basePower then
			self.ui.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
		else
			self.ui.mark_icon:setImage(i3k_db_icons[compare_icon[3]].path)
		end
	else
		self.ui.mark_icon:hide()
	end

	self.ui.level1:hide()
	self.ui.scroll:removeAllChildren()

	self:setPropScroll(self.ui.scroll, data)
end

function wnd_baguaTips:setPropScroll(scroll, data)
	self:setBasePropScroll(scroll, data)
	if self.isBijiao and data.showYilue then
		self:setYiluePropScroll(scroll, data)
	else
		if self.isWear and g_i3k_game_context:isYilueOpen() then
			self:setYiluePropScroll(scroll, data)
		elseif self.isOut then
			self:setYiluePropScroll(scroll, data)
		end
	end
	self:setAffixPropScroll(scroll, data)

	if self:isHaveSuitProp(data) then
		self:setSuitPropScroll(scroll, data)
	end
end

function wnd_baguaTips:isHaveSuitProp(data)
	for _,additionPropId in ipairs(data.additionProp) do
		local additionPropData = i3k_db_bagua_affix[additionPropId]
		if additionPropData.affixType == 3 then
			return true
		end
	end
	return false
end

function wnd_baguaTips:setBasePropScroll(scroll, data)
	if next(data.baseProp) then
		local header = require(LAYER_BAGUATIPST2)()
		header.vars.desc:setText("基础属性")
		scroll:addItem(header)

		for _, v in ipairs(data.baseProp) do
	        local ui = require(LAYER_BAGUATIPST)()
	        local _t = i3k_db_prop_id[v.id]
	        ui.vars.desc:setText(_t.desc)
	        ui.vars.value:setText(i3k_get_prop_show(v.id, v.value))
	        scroll:addItem(ui)
	    end
	end
end

function wnd_baguaTips:setAffixPropScroll(scroll, data)
	if next(data.additionProp) then
		local header = require(LAYER_BAGUATIPST2)()
		header.vars.desc:setText("词缀属性")
		scroll:addItem(header)

		for _, v in ipairs(data.additionProp) do
	        local ui = require(LAYER_BAGUATIPST3)()
	        local desc = i3k_db_bagua_affix[v].desc
	        ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_affix[v].icon))
	        ui.vars.desc:setText(desc)
	        scroll:addItem(ui)
	    end
	end
end

function wnd_baguaTips:setSuitPropScroll(scroll, data)
	local header = require(LAYER_BAGUATIPST2)()
	header.vars.desc:setText("套装属性")
	scroll:addItem(header)

	local function getAffixData()
		local suitID = 0
		local suitTotal = 0
		local haveSuitCnt = 0
		local suitName = ""

		for _, v in ipairs(data.additionProp) do
			local data = i3k_db_bagua_affix[v]
			if data.affixType == 3 then
				 suitID = data.args1
				 break
			end
		end
		for k, v in pairs(i3k_db_bagua_affix) do
			if v.args1 == suitID then
				suitTotal = suitTotal + 1
			end
		end
		for partID, bagDiagram in pairs(self.equipDiagrams) do
			for _, v in ipairs(bagDiagram.additionProp) do
				local data = i3k_db_bagua_affix[v]
				if suitID == data.args1 then
					haveSuitCnt = haveSuitCnt + 1
				end
			end
		end
		for _, v in pairs(i3k_db_bagua_suit_prop) do
			if v.id == suitID  then
				suitName = v.name
				break
			end
		end
		return suitID, suitName, suitTotal, haveSuitCnt
	end

	local suitID, suitName, suitTotal, haveSuitCnt = getAffixData()
	
	--套装数量显示
	local ui = require(LAYER_BAGUATIPST4)()
	local changeSkills = data.yilue and data.yilue.changeSkills or self.changeSkills
	local skillCount = g_i3k_game_context:getYilueUpTaoZhuangCount(suitID, changeSkills, self.equipDiagrams)
    ui.vars.daw:setText(string.format("%s(%s/%s)", suitName, haveSuitCnt, suitTotal))
    haveSuitCnt = haveSuitCnt + skillCount
    if haveSuitCnt >= suitTotal then --由于技能加成数量，导致拥有数量可能会大于最大数量，这里将“==”改为">="
    	ui.vars.daw:setTextColor(g_i3k_get_green_color())
    end
    scroll:addItem(ui)

    --套装颜色显示
    local suitData = {}
    for k, v in pairs(i3k_db_bagua_affix) do
    	if suitID == v.args1 then
    		table.insert(suitData, k)
    	end
    end

    table.sort(suitData, function(a, b)
    	return a < b
    end)


    local function getSuitColorStr(part)
		local data = i3k_db_bagua_affix[suitData[part]]
		if data then
			for _,bagDiagram in pairs(self.equipDiagrams) do
				for _,additionPropId in ipairs(bagDiagram.additionProp) do
					if suitData[part] == additionPropId then
						return g_i3k_make_color_string(data.name, g_i3k_get_green_color())
					end
				end
			end
			return data.name
		end
		return ""
    end

    local row = math.ceil(suitTotal/2)
    for i = 1, row do
    	local ui = require(LAYER_BAGUATIPST4)()
    	local part1 = 2 * i - 1
    	local part2 = 2 * i

    	local str1 = getSuitColorStr(part1)
    	local str2 = getSuitColorStr(part2)

    	local str = string.format("%s          %s", str1, str2)
		ui.vars.daw:setText(str)
    	scroll:addItem(ui)
    end

    --套装效果显示
    for _, v in ipairs(i3k_db_bagua_suit_prop) do
    	if v.id == suitID then
    		for i = 1, 3 do
    			if v["desc" .. i] ~= "" then
    				local ui = require(LAYER_BAGUATIPST4)()
    				if i == 1 then
    					ui.vars.daw:setText(string.format("%s件：", v.needCnt))
    					ui.vars.des2:setText(v["desc" .. i])
    				else
    					ui.vars.des2:setText(v["desc" .. i])
    				end
    				if haveSuitCnt >= v.needCnt then
	    				ui.vars.daw:setTextColor(g_i3k_get_green_color())
	    				ui.vars.des2:setTextColor(g_i3k_get_green_color())
	    			end
	    			scroll:addItem(ui)
    			end
    		end
    	end
    end
end

function wnd_baguaTips:setYiluePropScroll(scroll, data)
	if data.yilue and next(data.yilue.propPoints) then
		local header = require(LAYER_BAGUATIPST2)()
		header.vars.desc:setText("易略属性")
		scroll:addItem(header)
		local prop = {}
		g_i3k_game_context:updateBaguaYilueInfo(self.partId, data.yilue, prop, {}, data.yilue.changeSkills)
		for i,v in pairs(prop) do
			local ui = require(LAYER_BAGUATIPST)()
	        local _t = i3k_db_prop_id[i]
	        ui.vars.desc:setText(_t.desc)
	        ui.vars.value:setText(i3k_get_prop_show(i, v))
	        scroll:addItem(ui)
		end
		if data.yilue.equipSkill ~= 0 then
			local ui = require(LAYER_BAGUATIPST5)()
			ui.vars.name:setText(i3k_db_bagua_yilue_skill[data.yilue.equipSkill].skillName)
			local skillLevel = data.yilue.changeSkills[data.yilue.equipSkill]
			ui.vars.desc:setText(i3k_db_bagua_yilue_skill[data.yilue.equipSkill].skillJie[skillLevel].jieText)
			local skillType = i3k_db_bagua_yilue_skill[data.yilue.equipSkill].skillType
			ui.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[skillType].skillKuangID))
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_yilue_skill[data.yilue.equipSkill].iconID))
			scroll:addItem(ui)
		end
	end
end
function wnd_baguaTips:onWear(sender)
	if self.isWear then
		i3k_sbean.request_eightdiagram_unequip_req(self.partId)
	else
		i3k_sbean.request_eightdiagram_equip_req(self.equipId, self.partId)
	end
end

function wnd_baguaTips:onSplit(sender)
	local rank = self.rank

	local equips = {}
	equips[self.equipId] = true

	local getItems = {}
	table.insert(getItems, {id = g_BASE_ITEM_BAGUA_ENERGY, count = i3k_db_bagua_cfg.baguaEnergy[rank]})

	local isHaveHighQuality = rank >= i3k_db_bagua_cfg.splitMinRank

	local desc = i3k_get_string(17068,i3k_db_bagua_cfg.baguaEnergy[rank])
	local fun = (function(ok)
		if ok then
			if isHaveHighQuality then
				g_i3k_ui_mgr:OpenUI(eUIID_BaguaSplitSure)
				g_i3k_ui_mgr:RefreshUI(eUIID_BaguaSplitSure, equips, getItems)
			else
				i3k_sbean.request_eightdiagram_splite_req(equips, getItems)
			end
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
end

function wnd_baguaTips:onExtract(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BaguaExtract)
    g_i3k_ui_mgr:RefreshUI(eUIID_BaguaExtract, self.equipId)
    g_i3k_ui_mgr:CloseUI(eUIID_BaguaTips)
end

function wnd_create(layout, ...)
    local wnd = wnd_baguaTips.new()
    wnd:create(layout, ...)
    return wnd
end
