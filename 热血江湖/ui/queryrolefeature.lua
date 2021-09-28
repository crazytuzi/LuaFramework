-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
--ocal ui = require("ui/base")
local BaseUI = require("ui/queryRoleArmorRuneBase");
-------------------------------------------------------
wnd_query_role_feature = i3k_class("wnd_query_role_feature", BaseUI.wnd_queryRoleArmorRuneBase)
local COLOR1 = "fff45481"	--粉色
local COLOR2 = "ff714e40"	--棕色
local COLOR3 = "ffff0000"	--红色
local COLOR4 = "ff008000"	--绿色
local proBase 	= {1001,1002,1003,1004,1005,1006,1007,1008,1009,1012,1013,1014,1015,1016,1017,1018};--基础部分
local proExp 	= {1046,1047}--历练部分
local proSteedFight = {1106,1107} --骑战伤害
local proArmor 	= {1048,1049,1051,1053,1054,1055}--内甲部分
local proStar 	= {1084,1085,1086,1087,1088,1089,1090,1091}--星耀元素属性
local proMaster = {1077,1032,1078,1033,1079,1034}--精通抗性

function wnd_query_role_feature:ctor()
	self._spr_update = 0--旋转时间
	self.overview = nil
	self._wEquips = nil
	self.meridians = nil
	self._heirloom = nil
	self._isShowFeisheng = false
end

function wnd_query_role_feature:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.transferlvl = widgets.transferlvl
	--模型
	self.item_scroll = widgets.item_scroll
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	self.sealBtn = widgets.sealBtn
	self.sealBg = widgets.sealBg
	self.sealIcon = widgets.sealIcon
	self.heirloomBtn = widgets.heirloomBtn
	self.runeBtnBg = widgets.runeBtnBg
	self.meridianBtn = widgets.meridianBtn
	self.equip8 = widgets.equip8

	self.topTabScroll = widgets.topTabScroll

	widgets.meridianBtn:onClick(self, self.openMeridian)

	self.heirloomBg = widgets.heirloomBg
	self.heirloomIcon = widgets.heirloomIcon

	self:initRuneBaseUI(widgets)
	self:initBaguaBaseUI(widgets)
	self:initEquipRoot(widgets)

	self:initWearEquipWidget(widgets)
end
--初始化穿着装备控件
function wnd_query_role_feature:initWearEquipWidget(widgets)
	self.wear_equip={}
	for i=1, eEquipCount do
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local is_select	 = "is_select"..i
		local equip_btn  = "equip"..i
		local lizi     	 = "lizi" .. i
		local sjtx1     	 = "sjtx" .. i .. "_1"
		local sjtx2     	 = "sjtx" .. i .. "_2"
		self.wear_equip[i]  = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			lizi		= widgets[lizi],
			sjtx1		= widgets[sjtx1],
			sjtx2		= widgets[sjtx2],
		}
	end
end

function wnd_query_role_feature:dealWearData(wearEquips,wearParts)
	local wEquips = {}
	for i,v in pairs(wearParts) do
		local partid = wearParts[i].id
		wEquips[partid] = {}
		wEquips[partid].eqGrowLvl = wearParts[i].eqGrowLvl
		wEquips[partid].eqEvoLvl = wearParts[i].eqEvoLvl

		local slots = wearParts[i].eqSlots
		local _count = #slots
		local _tmp = {}
		for i=1,_count do
			_tmp[i] = slots[i]
		end
		wEquips[partid].slot = _tmp
		wEquips[partid].gemBless = v.gemBless
	end
	for i,v in pairs(wearEquips) do
		local equip = {}
		equip.equip_id = v.equip.id
		equip.equip_guid = v.equip.guid
		local temp = {}
		for j=1, #v.equip.addValues do
			temp[j] = v.equip.addValues[j]
		end
		equip.attribute = temp
		equip.naijiu = v.equip.durability
		equip.refine = v.equip.refine
		equip.legends = v.equip.legends
		equip.smeltingProps = v.equip.smeltingProps
		equip.hammerSkill = v.equip.hammerSkill
		wEquips[i].equip = equip
	end
	return wEquips
end

function wnd_query_role_feature:refresh(Data)
	local seal = Data.wear.seal
	local wearEquips = Data.wear.wearEquips
	local wearParts = Data.wear.wearParts
	self.overview = Data.overview
	local sealAwaken = Data.wear.sealAwaken
	local fuling = Data.wear.sealGivenSpirit
	local properties = Data.properties
	local roleType = Data.overview.type
	self.meridians = Data.meridians
	

	if self.overview.level < i3k_db_meridians.common.openLvl then
		self.meridianBtn:hide()
	end

	self:initRuneData(Data.wear.armor.soltGroupData, Data.wear.armor.runeLangLvls, Data.wear.armor.castIngots)
	self:initBaguaData(Data.equipDiagrams, Data.diagramPartStrength, Data.diagramChangeSkill)

	self:showLongyinData(seal, roleType, sealAwaken, fuling)
	self._wEquips = self:dealWearData(wearEquips, wearParts)

	self:updateTopBtnSate(Data)
	self._heirloom = Data.heirloom
	self:initXinHunData(roleType, Data.wear.heirloom.perfectDegree, Data.heirloom, self._wEquips)
	self:updateXinjue(Data.soulSpell.grade)
	self:updateColllectData(Data)
	self:updateBaseProperty(properties)
	self:createModule(Data)
	self:playAction(Data)


end

function wnd_query_role_feature:updateColllectData(Data)--物品收集
	local roleAchievement = Data.achievement
	local weaponAllNum = g_i3k_db.i3k_db_get_weapon_count()
	local petAllNum =g_i3k_db.i3k_db_get_pet_count()
	local skillAllLvl = g_i3k_game_context:GetRoleSkills()
	local playerType = Data.overview.type
	local count = g_i3k_db.i3k_db_get_skill_MaxLevel(playerType)
	self._layout.vars.shenbNum:setText(roleAchievement.weaponsActived .. "/" .. weaponAllNum)
	self._layout.vars.suicongNum:setText(roleAchievement.petsActived .. "/" .. petAllNum)
	self._layout.vars.cangpinNum:setText(roleAchievement.meadlsCollected)
	self._layout.vars.skillLvl:setText(roleAchievement.skillLevels .. "/" .. count)
	self._layout.vars.name:setText(Data.overview.name)
	self._layout.vars.bookLevels:setText(roleAchievement.bookLevels)
	self._layout.vars.partnerName:setText(Data.relationship.partnerName == "" and "无" or Data.relationship.partnerName)
	self._layout.vars.uskillLevels:setText(roleAchievement.uskillLevels)
	self._layout.vars.sectName:setText(Data.relationship.sectName == "" and "无" or Data.relationship.sectName)
end

function wnd_query_role_feature:updateWearEquipsData()--穿戴
	local playerData = self.overview
	local wearEquips = self._wEquips

	local level_str = string.format("%s级",playerData.level)
	self.role_lv:setText(level_str)
	local class_text=""
	if playerData.tLvl == 0 then
		class_text = i3k_db_generals[playerData.type].name
	else
		class_text = i3k_db_zhuanzhi[playerData.type][playerData.tLvl][playerData.bwType].name
	end
	self.class_type:setText(class_text)
	local gcfg = g_i3k_db.i3k_db_get_general(playerData.type)
	self.class_icon:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	self.battle_power:setText(playerData.fightPower)
	self.transferlvl:setText(string.format("%s转",playerData.tLvl))
	for i,e in ipairs(wearEquips) do
		local equip = e.equip
		if equip then
			local Widget = self.wear_equip[i]
			Widget.equip_btn:onClick(self, self.onSelectEquip, {wEquips = wearEquips,id = i})
			Widget.equip_icon:show()
			Widget.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip.equip_id, playerData.gender == eGENDER_FEMALE))
			Widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip.equip_id))
			local rank = g_i3k_db.i3k_db_get_common_item_rank(equip.equip_id)
			Widget.sjtx1:setVisible(false)
			Widget.sjtx2:setVisible(false)
			if rank == 5 then
				Widget.sjtx1:setVisible(equip.naijiu~=-1)
			end
			if rank == 4 then
				Widget.sjtx2:setVisible(equip.naijiu~=-1)
			end
		end
	end
end

function wnd_query_role_feature:updateBaseProperty(propertyData)--基础属性
	local level = g_i3k_game_context:GetLevel();
	local propertable = {};
	for k,v in pairs(proBase) do
		if propertyData[v] then
			table.insert(propertable,v)
		end
	end

	if level >=  i3k_db_experience_args.args.openLevel then
		for k,v in pairs(proExp) do
			if propertyData[v] then
				table.insert(propertable,v)
			end
		end
	end
	if level >=  i3k_db_steed_fight_base.spiritOpenLvl then
		for k,v in pairs(proSteedFight) do
			if propertyData[v] then
				table.insert(propertable,v)
			end
		end
	end
	if level >= i3k_db_under_wear_alone.underWearOpenLvl then
		for k,v in pairs(proArmor) do
			if propertyData[v] then
				table.insert(propertable,v)
			end
		end
	end

	if level >= i3k_db_LongYin_arg.fuling.openLevel then
		for k,v in pairs(proStar) do
			if propertyData[v] then
				table.insert(propertable,v)
			end
		end
	end

	if level >= i3k_db_common.functionOpen.masterOpenLvl then
		for k,v in pairs(proMaster) do
			if propertyData[v] then
				table.insert(propertable,v)
			end
		end
	end

	self.item_scroll:removeAllChildren()
	local hero = i3k_game_get_player_hero()
	local index = 1
	for i,v in ipairs(propertable) do
		local heroProperty = require("ui/widgets/hyxxt")()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(v)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v))
		local provalue = hero:GetPropertyValue(v)
		local text = 0
		local num = 0
		local value = self:getOtherPlayerProp(v, propertyData)

		if i3k_db_prop_id[v].txtFormat == 1 then
			local x1 = tonumber(provalue)*100
			local x = tonumber(value)/100
			local chazhi = x1 - x
			if chazhi > 0 then
				num = 174
			elseif chazhi < 0 then
				num =175
			else
				num = 176
			end
			if chazhi - math.floor(chazhi) > 0 then
				widget.propertyValue:setText(string.format("%.2f",x).."%")
				if chazhi > 0 then
					text = string.format("+%.2f",chazhi) .. "%"
				else
					text = string.format("%.2f",chazhi) .. "%"
				end
			else
				if chazhi > 0 then
					text = string.format("+%d",chazhi) .. "%"
				else
					text=string.format("%d",chazhi) .. "%"
				end
				widget.propertyValue:setText(string.format("%d",x).."%")
			end
		else
			local chazhi = provalue-value
			text = i3k_get_num_to_show(math.abs(tonumber(chazhi)))
			if chazhi > 0 then
				num = 174
				text = string.format("+%s",text)
			elseif chazhi < 0 then
				num =175
				text = string.format("-%s",text)
			else
				num = 176
			end
			local propertyValue = i3k_get_num_to_show(tonumber(value))
			widget.propertyValue:setText(propertyValue)
		end
		if num == 174 then
			widget.chazhi:setTextColor(COLOR4)
		elseif num == 175 then
			widget.chazhi:setTextColor(COLOR3)
		elseif num == 176 then
			widget.chazhi:setTextColor(COLOR2)
		end

		widget.imgflag:setImage(g_i3k_db.i3k_db_get_icon_path(num))
		widget.chazhi:setText(text)
		self.item_scroll:addItem(heroProperty)
		index = index +1
	end
	self:updateWidgetBg()
	--[[	-----------正派反派分别
	local decentValueTable = {ePropID_shell, ePropID_sbd}
	local useKnifeID = {1010, 1011}
	local useKnifeValueTable = {ePropID_deflect, ePropID_atkD}
	local useKnifeIcon = {1027,1029}
	local doctorValue = ePropID_healA
	if info.tLvl>= 2 then
		local heroProperty = require("ui/widgets/hyxxt")()
		local widget = heroProperty.vars
		if info.bwType==1 then
			local icon = g_i3k_db.i3k_db_get_property_icon(Watch_Box)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Watch_Box))
			widget.propertyValue:setText(hero:GetPropertyValue(decentValueTable[1]))
		else
			local icon = g_i3k_db.i3k_db_get_property_icon(Suck_Blood)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Suck_Blood))
			widget.propertyValue:setText(hero:GetPropertyValue(decentValueTable[2]))
		end
		self.item_scroll:addItem(heroProperty)
	end

	----------人物职业分别
	if info.type == 1 then
		for i=1,2 do
			local heroProperty = require("ui/widgets/hyxxt")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(useKnifeID[i])
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(useKnifeID[i]))
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(useKnifeIcon[i]))
			local x = tonumber(hero:GetPropertyValue(useKnifeValueTable[i]))*100
			if x-math.floor(x)>0 then
				widget.propertyValue:setText(string.format("%.2f",x).."%")
			else
				widget.propertyValue:setText(string.format("%d",x).."%")
			end
			self.item_scroll:addItem(heroProperty)
		end
	elseif info.type == 5 then
		local heroProperty = require("ui/widgets/hyxxt")()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(Treat_Crit)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Treat_Crit))
		widget.propertyValue:setText(hero:GetPropertyValue(doctorValue))
		self.item_scroll:addItem(heroProperty)
	end--]]
end

function wnd_query_role_feature:getOtherPlayerProp(propId, propertyData)
	local function getLingFuType()
		local equips = self._wEquips
		if equips[7] and equips[7].equip then
			local equipId = equips[7].equip.equip_id
			local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(equipId)
			return equip_t.properties[1].type, equip_t.properties[2].type
		end
		return 1084,1085
	end
	local xuanDmg,xuanDef = getLingFuType(propId)
	local propValue = propertyData[propId]
	if propId == xuanDmg then
		propValue = propValue + propertyData[1103]
	end
	if propId == xuanDef then
		propValue = propValue + propertyData[1104]
	end
	return propValue
end

function wnd_query_role_feature:updateWidgetBg()
	local all_child = self.item_scroll:getAllChildren()
	for i, e in pairs(all_child) do
		local widget = e.vars
		widget.propertyBg2:hide()
		widget.propertyBg1:hide()
		if i%2 == 0 then
			widget.propertyBg1:show()
		else
			widget.propertyBg2:show()
		end
	end
end

function wnd_query_role_feature:showLongyinData(seal, roleType, sealAwaken, fuling)
	local grade = seal.grade
	local skills = seal.skills
	local argData = g_i3k_db.i3k_db_LongYin_arg
	local isOpenImage
	if grade ~= 0 then
		local quality = g_i3k_game_context:GetLongYinQuality(grade)
		isOpenImage = argData.args.openItemIronID
		self.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:GetLongYinIronForGrade(grade)))
		self.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	else
		isOpenImage = argData.args.closeItemIronID
		self.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(isOpenImage))
		self.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
	end
	self.sealBtn:onClick(self, self.wearingSevenEquipTips, {grade = grade, skills = skills, roleType = roleType, sealAwaken = sealAwaken, fuling = fuling})--他人龙印信息

end

function wnd_query_role_feature:wearingSevenEquipTips(sender, info)
	if info.grade ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_OtherLongYinInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_OtherLongYinInfo, info)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(428))
	end
end

function wnd_query_role_feature:onSelectEquip(sender,data)
	for i, e in ipairs(self.wear_equip) do
		e.is_select:setVisible(i == data.id)
	end
	if g_i3k_game_context:isFlyEquip(data.id) then
		g_i3k_ui_mgr:OpenUI(eUIID_FriendsFlyingEquipTips)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FriendsFlyingEquipTips, "refresh", data)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_ShowFriendsEquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShowFriendsEquipTips, "refresh", data)
	end
end

function wnd_query_role_feature:onUpdate(dTime)
	self._spr_update = self._spr_update + dTime
	if not self.isEffectFashion then
		self.hero_module:setRotation(self._spr_update * 0.25)
	end
end

function wnd_query_role_feature:setSomeNodeVisible(visib)
	self.sealBtn:setVisible(visib)
	self.heirloomBtn:setVisible(visib)
	self.equip8:setVisible(visib)
end

function wnd_query_role_feature:openMeridian()
	g_i3k_ui_mgr:OpenUI(eUIID_otherMeridian)
	g_i3k_ui_mgr:RefreshUI(eUIID_otherMeridian, self.meridians)
end

function wnd_query_role_feature:initXinHunData(roleType, perfectDegree, heirloomData, wearEquips)
	if roleType and perfectDegree >= i3k_db_chuanjiabao.cfg.leastcount then
		self.heirloomBg:setImage(g_i3k_get_icon_frame_path_by_rank(5))
		self.heirloomIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_chuanjiabao.cfg["iconid"..roleType]))
	end
	self.heirloomBtn:onClick(self, self.onSelectHeirloom, {roleType = roleType, perfectDegree = perfectDegree, heirloom = heirloomData, wearEquips = wearEquips})
end

function wnd_query_role_feature:onSelectHeirloom(sender, data)
	if data.heirloom and data.perfectDegree >= i3k_db_chuanjiabao.cfg.leastcount then
		g_i3k_ui_mgr:OpenUI(eUIID_XingHunOtherInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_XingHunOtherInfo, data)
	else
		g_i3k_ui_mgr:PopupTipMessage("对方尚未装备传家宝")
	end
end
--更新心决信息
function wnd_query_role_feature:updateXinjue(grade)
	local widgets = self._layout.vars
	widgets.xinjue_icon:setVisible(grade ~= 0)
	widgets.xinjue_lv:setVisible(grade ~= 0)
	if grade ~= 0 then
		widgets.xinjue_lv:setText(i3k_db_xinjue_level[grade].des)
	end
end

function wnd_create(layout)
	local wnd = wnd_query_role_feature.new()
		wnd:create(layout)
	return wnd;
end
