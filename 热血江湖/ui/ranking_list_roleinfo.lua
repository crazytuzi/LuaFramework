-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
--local ui = require("ui/base");
local BaseUI = require("ui/queryRoleArmorRuneBase");
-------------------------------------------------------
-----好友信息
wnd_ranking_list_RoleInfo = i3k_class("wnd_ranking_list_RoleInfo", BaseUI.wnd_queryRoleArmorRuneBase)
local colllectData_icon = 1849
local propertyData_icon = 1848
local battlePowerData_icon = 1850
local colllectID2 = {"宠物收集", "武功等级", "神兵收集", "藏品收集"}
local battlePowerID2 = {"装备玩法战力", "帮派武功战力",  "武功综合战力", "神兵综合战力"}
local COLOR2 = "ff714e40"	--棕色
local COLOR3 = "ffff0000"	--红色
local COLOR4 = "ff008000"	--绿色
local proBase 	= {1001,1002,1003,1004,1005,1006,1007,1008,1009,1012,1013,1014,1015,1016,1017,1018};--基础部分
local proExp 	= {1046,1047}--历练部分
local proSteedFight = {1106,1107} --骑战伤害
local proArmor 	= {1048,1049,1051,1053,1054,1055}--内甲部分
local proStar 	= {1084,1085,1086,1087,1088,1089,1090,1091}--星耀元素属性
local proMaster = {1077,1032,1078,1033,1079,1034}--精通抗性
local rankDecoration = {{backGround = 5206, decoration = 5204}, {backGround = 5207, decoration = 5205}, {backGround = 5208, decoration = 5204}}--排行榜装饰
local titleDecoration =
{
	[1] = {5235, 5239, 5237},
	[2] = {5238, 5231, 5236},
	[5] = {5233, 5240, 5230},
	[13] = {5232, 5241, 5234},
}

function wnd_ranking_list_RoleInfo:ctor()
	self.select_content = {}
	self._spr_update = 0--旋转时间
	self._wEquips = nil
	self.overview = nil
	self.meridians = nil
	self._heirloom = nil
	self._isShowFeisheng = false -- 飞升开启
	self._rank = 0
end

function wnd_ranking_list_RoleInfo:configure()

	self._modelId = 30

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
	self.heirloomBg = widgets.heirloomBg
	self.heirloomIcon = widgets.heirloomIcon

	self.runeBtnBg = widgets.runeBtnBg
	self.equip8 = widgets.equip8


	self:initEquipRoot(widgets)

	self:initRuneBaseUI(widgets)
	self:initBaguaBaseUI(widgets)

	self:initWearEquipWidget(widgets)
	widgets.meridianBtn:onClick(self, self.openMeridian)
	self.meridianBtn = widgets.meridianBtn
end

function wnd_ranking_list_RoleInfo:refresh(Data, rank, index)

	local seal = Data.wear.seal
	local wearEquips = Data.wear.wearEquips
	local wearParts = Data.wear.wearParts
	local overview = Data.overview
	local sealAwaken = Data.wear.sealAwaken
	local fuling = Data.wear.sealGivenSpirit
	local roleType = Data.overview.type
	self.meridians = Data.meridians
	self.overview = Data.overview
	self._rank = rank

	if overview.level < i3k_db_meridians.common.openLvl then
		self.meridianBtn:hide()
	end

	self._wEquips = self:dealWearData(wearEquips, wearParts)

	self._heirloom = Data.heirloom
	self:initXinHunData(roleType, Data.wear.heirloom.perfectDegree, Data.heirloom, self._wEquips)

	self:initRuneData(Data.wear.armor.soltGroupData, Data.wear.armor.runeLangLvls, Data.wear.armor.castIngots)
	self:initBaguaData(Data.equipDiagrams, Data.diagramPartStrength, Data.diagramChangeSkill)

	self:updateTopBtnSate(Data)
	self:showLongyinData(seal, roleType, sealAwaken, fuling)
	self:updateBattlePowerData(Data.powerDetail)
	self:updateColllectData(Data)
	self:updateBaseProperty(Data.properties)
	self:createModule(Data)
	self:playAction(Data)
	self:showDecoration(rank, index)
	self:updateXinjue(Data.soulSpell and Data.soulSpell.grade or 0)


end

--初始化穿着装备控件
function wnd_ranking_list_RoleInfo:initWearEquipWidget(widgets)
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

function wnd_ranking_list_RoleInfo:dealWearData(wearEquips,wearParts)
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
		equip.refine = v.equip.refine
		equip.naijiu = v.equip.durability
		equip.legends = v.equip.legends
		equip.smeltingProps = v.equip.smeltingProps
		equip.hammerSkill = v.equip.hammerSkill
		wEquips[i].equip = equip
	end
	return wEquips
end

--物品收集 4个
function wnd_ranking_list_RoleInfo:updateColllectData(Data)
	local widgets = self._layout.vars
	local showColllect = require("ui/widgets/jsxxt4")()
	showColllect.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(colllectData_icon))
	self.item_scroll:addItem(showColllect)

	local weaponAllNum = g_i3k_db.i3k_db_get_weapon_count()
	local petAllNum =g_i3k_db.i3k_db_get_pet_count() --isOpen
	local playerType = Data.overview.type
	local count = g_i3k_db.i3k_db_get_skill_MaxLevel(playerType)
	local allNum = {petAllNum,count,weaponAllNum}
	local newtable={Data.achievement.petsActived,Data.achievement.skillLevels,Data.achievement.weaponsActived,Data.achievement.meadlsCollected}

	--self.weaponsActived:		int32 武器
	--self.petsActived:		int32	随从
	--self.meadlsCollected:		int32
	--self.skillLevels:		int32	武功
	--收集属性

	local hero = i3k_game_get_player_hero()
	for i,v in ipairs(newtable) do
		local heroProperty = require("ui/widgets/jsxxt2")()
		local widget = heroProperty.vars

		widget.propertyName:setText(colllectID2[i])--(g_i3k_db.i3k_db_get_property_name(v))--显示属性名
		if allNum[i] then
			widget.propertyValue:setText(v .. "/" .. allNum[i])--
		else
			widget.propertyValue:setText(v)--
		end


		self.item_scroll:addItem(heroProperty)
	end
end

--综合战力 6
function wnd_ranking_list_RoleInfo:updateBattlePowerData(battlePowerData)
	self.item_scroll:removeAllChildren()
	local showBattlePower = require("ui/widgets/jsxxt4")()
	showBattlePower.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(battlePowerData_icon))
	self.item_scroll:addItem(showBattlePower)
	local children = self.item_scroll:getAddChild()
	local newtable={battlePowerData.equipPower,battlePowerData.sectAurasPower,battlePowerData.skillPower,battlePowerData.weaponPower}
	local i =1
	--装备玩法战力', '帮派武功战力',  '武功综合战力', '神兵综合战力'
	--self.equipPower:		int32	 装备
	--self.sectAurasPower:	int32
	--self.skillPower:		int32	 武功
	--self.weaponPower:		int32	 神兵
	--综合战力属性
	local hero = i3k_game_get_player_hero()
	for i,v in ipairs(newtable) do
		local heroProperty = require("ui/widgets/jsxxt3")()
		local widget = heroProperty.vars
		widget.propertyName:setText(battlePowerID2[i])
		widget.propertyValue:setText(v)
		self.item_scroll:addItem(heroProperty)
	end
end

function wnd_ranking_list_RoleInfo:updateWearEquipsData()
	local playerData = self.overview
	local wearEquips = self._wEquips
	local level_str = string.format("%s级",playerData.level)
	self.role_lv:setText(level_str)--等级
	local class_text=""
	if playerData.tLvl == 0 then
		class_text = i3k_db_generals[playerData.type].name
	else
		class_text = i3k_db_zhuanzhi[playerData.type][playerData.tLvl][playerData.bwType].name
	end
	self.class_type:setText(class_text)--类型工作
	local gcfg = g_i3k_db.i3k_db_get_general(playerData.type)
	self.class_icon:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))--工作对应的图
	self.battle_power:setText(playerData.fightPower)--战力
	self.transferlvl:setText(string.format("%s转",playerData.tLvl))---转职
	for i,e in ipairs(wearEquips) do
		local equip = e.equip
		if equip then
			local Widget = self.wear_equip[i]
			Widget.equip_btn:onClick(self, self.onSelectEquip, {wEquips = wearEquips,id = i, rank = self.rank})
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

function wnd_ranking_list_RoleInfo:updateBaseProperty(propertyData)
	local showProperty = require("ui/widgets/jsxxt4")()
	showProperty.vars.image:setImage(g_i3k_db.i3k_db_get_icon_path(propertyData_icon))
	self.item_scroll:addItem(showProperty)
	local children = self.item_scroll:getAddChild()
	local level = g_i3k_game_context:GetLevel();
	local propertable = {}
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

	--self.item_scroll:removeAllChildren()
	local decentValueTable = {ePropID_shell, ePropID_sbd}
	local useKnifeID = {1010, 1011}
	local useKnifeValueTable = {ePropID_deflect, ePropID_atkD}
	local useKnifeIcon = {1027,1029}

	local doctorValue = ePropID_healA
	local hero = i3k_game_get_player_hero()
	local index = 1
	for i,v in ipairs(propertable) do
		local heroProperty = require("ui/widgets/jsxxt1")()
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
			if chazhi-math.floor(chazhi)>0 then
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
			local chazhi = provalue - value
			text = i3k_get_num_to_show(math.abs(tonumber(chazhi)))
			if chazhi > 0 then
				num = 174
				text = string.format("+%s",text)
			elseif chazhi < 0 then
				num =175
				text=string.format("-%s",text)
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
		if index%2 == 0 then
			widget.propertyBg1:show()
			widget.propertyBg2:hide()
		else
			widget.propertyBg1:hide()
			widget.propertyBg2:show()
		end
		widget.imgflag:setImage(g_i3k_db.i3k_db_get_icon_path(num))
		widget.chazhi:setText(text)
		self.item_scroll:addItem(heroProperty)
		index = index + 1
	end
end

function wnd_ranking_list_RoleInfo:getOtherPlayerProp(propId, propertyData)
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
		propValue = propValue + (propertyData[1103] or 0)
	end
	if propId == xuanDef then
		propValue = propValue + (propertyData[1104] or 0)
	end
	return propValue
end

function wnd_ranking_list_RoleInfo:showLongyinData(seal, roleType, sealAwaken, fuling)
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

function wnd_ranking_list_RoleInfo:wearingSevenEquipTips(sender, info)
	if info.grade ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_OtherLongYinInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_OtherLongYinInfo, info)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(428))
	end

end

function wnd_ranking_list_RoleInfo:onSelectEquip(sender,data)
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

function wnd_ranking_list_RoleInfo:onUpdate(dTime)
	self._spr_update = self._spr_update + dTime
	if not self.isEffectFashion then
		self.hero_module:setRotation(self._spr_update * 0.25)
	end
end

function wnd_ranking_list_RoleInfo:setSomeNodeVisible(visib)
	self.sealBtn:setVisible(visib)
	self.heirloomBtn:setVisible(visib)
	self.equip8:setVisible(visib)
end

function wnd_ranking_list_RoleInfo:openMeridian()
	g_i3k_ui_mgr:OpenUI(eUIID_otherMeridian)
	g_i3k_ui_mgr:RefreshUI(eUIID_otherMeridian, self.meridians)
end

function wnd_ranking_list_RoleInfo:initXinHunData(roleType, perfectDegree, heirloomData, wearEquips)
	if roleType and perfectDegree >= i3k_db_chuanjiabao.cfg.leastcount then
		self.heirloomBg:setImage(g_i3k_get_icon_frame_path_by_rank(5))
		self.heirloomIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_chuanjiabao.cfg["iconid"..roleType]))
	end
	self.heirloomBtn:onClick(self, self.onSelectHeirloom, {roleType = roleType, perfectDegree = perfectDegree, heirloom = heirloomData, wearEquips = wearEquips})
end

function wnd_ranking_list_RoleInfo:onSelectHeirloom(sender, data)
	if data.heirloom and data.perfectDegree >= i3k_db_chuanjiabao.cfg.leastcount then
		g_i3k_ui_mgr:OpenUI(eUIID_XingHunOtherInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_XingHunOtherInfo, data)
	else
		g_i3k_ui_mgr:PopupTipMessage("对方尚未装备传家宝")
	end
end

function wnd_ranking_list_RoleInfo:showDecoration(rank, index)
	self._layout.vars.decorationIcon:hide()
	self._layout.vars.titleBg:hide()
	self._layout.vars.titleIcon:hide()
	self._layout.vars.topIcon:show()
	if rank and index then
		if rank <= 3 then
			local decorate = rankDecoration[rank]
			local rankType = i3k_db_rank_list[index].rankType
			if titleDecoration[rankType] then
				local title = titleDecoration[rankType][rank]
				self._layout.vars.decorationIcon:show()
				self._layout.vars.decorationIcon:setImage(g_i3k_db.i3k_db_get_icon_path(decorate.decoration))
				self._layout.vars.titleBg:show()
				self._layout.vars.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(decorate.backGround))
				self._layout.vars.titleIcon:show()
				self._layout.vars.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(title))
				self._layout.vars.topIcon:hide()
			end
		end
	else
		local decorate = rankDecoration[1]
		local rankType = i3k_db_rank_list[1].rankType
		local title = titleDecoration[rankType][1]
		self._layout.vars.decorationIcon:show()
		self._layout.vars.decorationIcon:setImage(g_i3k_db.i3k_db_get_icon_path(decorate.decoration))
		self._layout.vars.titleBg:show()
		self._layout.vars.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(decorate.backGround))
		self._layout.vars.titleIcon:show()
		self._layout.vars.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(title))
		self._layout.vars.topIcon:hide()
	end
end
--更新心决信息
function wnd_ranking_list_RoleInfo:updateXinjue(grade)
	local widgets = self._layout.vars
	widgets.xinjue_icon:setVisible(grade ~= 0)
	widgets.xinjue_lv:setVisible(grade ~= 0)
	if grade ~= 0 then
		widgets.xinjue_lv:setText(i3k_db_xinjue_level[grade].des)
	end
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleInfo.new()
		wnd:create(layout)
	return wnd;
end
