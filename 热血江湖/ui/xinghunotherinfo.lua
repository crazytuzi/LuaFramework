-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_xinghun_other_info = i3k_class("wnd_xinghun_other_info", ui.wnd_base)

local LAYER_CJB1T1 = "ui/widgets/cjb1t1"
local LAYER_CJB1T2 = "ui/widgets/cjb1t2"

local mainStarBgID = 5350

function wnd_xinghun_other_info:ctor()
	self._data = {}
end

function wnd_xinghun_other_info:configure()
	local widgets = self._layout.vars
	self.coloseBtn = widgets.close
	self.curpurcent = widgets.curpurcent
	self.model = widgets.modle
	self.scroll = widgets.scroll
	self.fightPower = widgets.fightPower

	self.mainStar = widgets.mainStar
	self.mainStarIcon = widgets.mainStarIcon
	self.mainStarBg = widgets.mainStarBg
	self.mainStarBtn = widgets.mainStarBtn
	self.mainStarBtn:onClick(self, self.onClickMainStar)

	self.coloseBtn:onClick(self, self.onCloseUI)
end

function wnd_xinghun_other_info:refresh(data)
	self._data = data
	self.curpurcent:setText("当前完美度："..data.perfectDegree)
	self.mainStar:setVisible(data.heirloom.starSpiritRank >= i3k_db_chuanjiabao.cfg.unlockNeedStage)
	local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(data.roleType, data.heirloom.mainStarLvl)
	if cfg then
		self.mainStarIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
		self.mainStarBg:setImage(g_i3k_db.i3k_db_get_icon_path(mainStarBgID))
	end

	self:updateModelState()

	self.scroll:removeAllChildren()  --添加属性前清除scroll内容
	self:setBasePropScroll()
	self:setStrengthPropScroll()
	self:setStarPropScroll()

	self.fightPower:setText(self:GetOtherHeirloomFightPower())
end

function wnd_xinghun_other_info:onClickMainStar(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_XingHunMainStarLock)
	g_i3k_ui_mgr:RefreshUI(eUIID_XingHunMainStarLock, {roleType = self._data.roleType, heirloom = self._data.heirloom})
end

--基础属性
function wnd_xinghun_other_info:setBasePropScroll()
	local baseProp = self:getOtherHeirloomProps()

	local isMax = true
	for i = #i3k_db_chuanjiabao.props, 1, -1 do
		if self._data.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu then
			if i3k_db_chuanjiabao.props[i + 1] then
				isMax = false
			end
			break
		end
	end

	if next(baseProp) then
		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("基础属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(baseProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, baseProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			des.vars.max:setVisible(isMax)
			self.scroll:addItem(des)
		end
	end
end

--强化属性
function wnd_xinghun_other_info:setStrengthPropScroll()
	local strengthProp = self:getOtherHeirloomStrengthProps()
	local Strength = g_i3k_game_context:getHeirloomStrengthData()

	local layer = self._data.heirloom.strengthRank
	local StrengthPro = self._data.heirloom.strengthProps

	local strengthData = nil
	local isMax = false
	local propIsMax = {[ePropID_maxHP] = false, [ePropID_defN] = false, [ePropID_atkN] = false}
	if layer > #i3k_db_chuanjiabao_strength.strength then
		isMax = true
	end
	if isMax then
		strengthData = i3k_db_chuanjiabao_strength.strength[layer - 1]
	else
		strengthData = i3k_db_chuanjiabao_strength.strength[layer]
	end
	if layer == 5 then
		if StrengthPro[ePropID_maxHP] and StrengthPro[ePropID_maxHP] >= strengthData.pro3 then
			propIsMax[ePropID_maxHP] = true
		end
		if StrengthPro[ePropID_defN] and StrengthPro[ePropID_defN] >= strengthData.pro2 then
			propIsMax[ePropID_defN] = true
		end 
		if StrengthPro[ePropID_atkN] and StrengthPro[ePropID_atkN] >= strengthData.pro1 then
			propIsMax[ePropID_atkN] = true
		end
	end

	if next(strengthProp) then
		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("强化属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(strengthProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, strengthProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			if isMax then
				des.vars.max:setVisible(true)
			else
				des.vars.max:setVisible(propIsMax[e])
			end
			self.scroll:addItem(des)
		end
	end
end

--星魂属性
function wnd_xinghun_other_info:setStarPropScroll()
	local starProp = self:getOtherXingHunProps()

	if next(starProp) then
		--不显示主星属性
		local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(self._data.roleType, self._data.heirloom.mainStarLvl)
		for _, v in ipairs(cfg and cfg.propIds or {}) do
			if starProp[v] then
				starProp[v] = nil
			end
		end
		local header = require(LAYER_CJB1T1)()
		header.vars.name:setText("星魂属性")
		self.scroll:addItem(header)

		local prop = self:sortProp(starProp)
		for _, e in ipairs(prop) do
			local des = require(LAYER_CJB1T2)()
			local _t = i3k_db_prop_id[e]
			des.vars.propertyName:setText(_t.desc)
			des.vars.propertyValue:setText(i3k_get_prop_show(e, starProp[e]))
			des.vars.propIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(e)))
			des.vars.max:setVisible(false)
			self.scroll:addItem(des)
		end
	end
end

-- 参数为Key value形式，返回一个排序好的key数组
function wnd_xinghun_other_info:sortProp(prop)
	local temp = {}
	for k, v in pairs(prop) do
		table.insert(temp, k)
	end
	table.sort(temp)
	return temp
end

function wnd_xinghun_other_info:updateModelState()
	local cfg = i3k_db_seven_keep_activity[3]
	local showId = cfg.rewardShow[self._data.roleType]
	if cfg.rewardType == 1 then
		ui_set_hero_model(self.model, showId)
		local path = i3k_db_models[showId].path
		local uiscale = i3k_db_models[showId].uiscale
		self.model:setSprite(path)
		self.model:setSprSize(uiscale)
	end
	for k,v in pairs(cfg.effectList) do
		self.model:pushActionList(v, 1)
	end
	self.model:pushActionList("stand", -1)
	self.model:playActionList()
	if cfg.modelRotation ~= 0 then
		self.model:setRotation(cfg.modelRotation)
	else
		self.model:setRotation(math.pi/2,-0.2)
	end
end

--获取他人传家宝总战力（基础属性+强化属性+星魂属性）
function wnd_xinghun_other_info:GetOtherHeirloomFightPower()
	local baseProp = self:getOtherHeirloomProps()
	local strengthProp = self:getOtherHeirloomStrengthProps()
	local starProp = self:getOtherXingHunProps()

	local tmp = {}
	for k, v in pairs(baseProp) do
		tmp[k] = (tmp[k] or 0) + v
	end
	for k, v in pairs(strengthProp) do
		tmp[k] = (tmp[k] or 0) + v
	end
	for k, v in pairs(starProp) do
		tmp[k] = (tmp[k] or 0) + v
	end

	return g_i3k_db.i3k_db_get_battle_power(tmp, true)
end

--基础属性
function wnd_xinghun_other_info:getOtherHeirloomProps()
	local cfg = {}
	local props = {}
	for i = #i3k_db_chuanjiabao.props, 1, -1 do
		if self._data.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu then
			cfg = i3k_db_chuanjiabao.props[i]
			break
		end
	end
	if cfg then
		for i = 1, 5 do
			local id = cfg["property"..i.."id"]
			local value = cfg["property"..i.."value"]

			if id and id > 0 and value > 0 then
				if not props[id] then
					props[id] = value
				else
					props[id] = props[id] + value
				end
			end
		end
	end
	return props
end

--强化属性
function wnd_xinghun_other_info:getOtherHeirloomStrengthProps()
	local layer = self._data.heirloom.strengthRank
	local StrengthPro = self._data.heirloom.strengthProps

	local StrengthProTotal = {}

	local function CheckHeirloomStrengMax()
		local strengthData = i3k_db_chuanjiabao_strength.strength[layer]
		if StrengthPro and StrengthPro[ePropID_atkN] and StrengthPro[ePropID_defN] and StrengthPro[ePropID_maxHP] then
			if layer <= #i3k_db_chuanjiabao_strength.strength then
				if StrengthPro[ePropID_atkN] >= strengthData.pro1 and StrengthPro[ePropID_defN] >= strengthData.pro2 and StrengthPro[ePropID_maxHP] >= strengthData.pro3 then
					return true;
				end
			end
		end
		return false;
	end

	local function HeirloomStrengthTotal()
		local hpPro = 0
		local defPro = 0
		local atkPro = 0
		local strengthData = nil
		local isMax = false
		local isLayer = false
		if not i3k_db_chuanjiabao_strength then
			return
		end
		if layer > #i3k_db_chuanjiabao_strength.strength  then
			isMax = true;
		end

		if layer == #i3k_db_chuanjiabao_strength.strength then
			if CheckHeirloomStrengMax() then
				isLayer = true
			end
		end

		if isMax then
			strengthData = i3k_db_chuanjiabao_strength.strength[layer - 1]
		else
			strengthData = i3k_db_chuanjiabao_strength.strength[layer]
		end

		for k,v in ipairs(i3k_db_chuanjiabao_strength.strength) do
			if k == layer then
				break;
			end
			atkPro = atkPro + v.pro1
			defPro = defPro + v.pro2
			hpPro = hpPro + v.pro3
		end

		if (not isMax and StrengthPro[ePropID_atkN]) or isLayer  then
			atkPro = atkPro + StrengthPro[ePropID_atkN]
		end

		if (not isMax and StrengthPro[ePropID_defN]) or isLayer then
			defPro = defPro + StrengthPro[ePropID_defN]
		end

		if (not isMax and StrengthPro[ePropID_maxHP]) or isLayer  then
			hpPro = hpPro + StrengthPro[ePropID_maxHP]
		end
		for k,v in pairs(i3k_db_chuanjiabao_strength.pros) do
			if ePropID_atkN == v.proID then
				StrengthProTotal[v.proID] = atkPro
			end
			if ePropID_defN == v.proID then
				StrengthProTotal[v.proID] = defPro
			end
			if ePropID_maxHP == v.proID then
				StrengthProTotal[v.proID] = hpPro
			end
		end
	end

	HeirloomStrengthTotal()
	local props = {}
	for k,v in pairs(i3k_db_chuanjiabao_strength.pros) do
		for k1,v1 in pairs(StrengthProTotal) do
			if v.proID == k1 then
				if v.proID and v.proID > 0 and v1 > 0 then
					if not props[v.proID] then
						props[v.proID] = v1
					else
						props[v.proID] = props[v.proID] + v1
					end
				end
			end
		end
	end
	return props
end

--星魂属性
function wnd_xinghun_other_info:getOtherXingHunProps()
	local function getLingFuType()
		local equips = self._data.wearEquips
		if equips[7] and equips[7].equip then
			local equipId = equips[7].equip.equip_id
			local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
			return equip_t.properties[1].type, equip_t.properties[2].type
		end
		return 1084,1085
	end

	local function dealXingHunPropId(id)
		local propId = id
		local damageId,defenseId = getLingFuType()
		if id == 1103 then
			propId = damageId
		end
		if id == 1104 then
			propId = defenseId
		end
		return propId
	end

	local _props = {}
	for k, v in pairs(self._data.heirloom.miniStarLvls or {}) do
		local props = g_i3k_db.xinghun_getSubStarConfig(k, v).props
		for _, e in ipairs(props) do
			if e.value > 0 then
				local propId = dealXingHunPropId(e.id)

				if not _props[propId] then
					_props[propId] = e.value
				else
					_props[propId] = _props[propId] + e.value
				end
			end
		end
	end

	local roleType = self._data.roleType
	local mainStarLvl = self._data.heirloom.mainStarLvl
	local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(roleType, mainStarLvl)
	if cfg then
		for k,_ in pairs(self._data.heirloom.mainStarProps or {}) do
			if k > 0 then
				if not _props[k] then
					_props[k] = cfg.propValue
				else
					_props[k] = _props[k] + cfg.propValue
				end
			end
		end
	end
	return _props
end

function wnd_create(layout)
	local wnd = wnd_xinghun_other_info.new()
	wnd:create(layout)
	return wnd
end
