-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")

local ui = require("ui/profile")

-------------------------------------------------------
wnd_role_property = i3k_class("wnd_role_property", ui.wnd_profile)

--属性ID
local Suck_Blood = 1020 --吸血
local Watch_Box = 1021 --护体
local Treat_Effect = 1041 --治疗效果
local Treat_Crit = 1019 --治疗暴击

--scroll文字颜色
local COLOR1 = "fff45481"  --粉色
local COLOR2 = "ff714e40"    --棕色

function wnd_role_property:ctor()
	self._equip_t = {}
	self._spr_update = 0
end

function wnd_role_property:configure()
	local widgets = self._layout.vars
	--widgets.add_diamond:onClick(self, self.addDiamondBtn)
	--widgets.add_coin:onClick(self, self.addCoinBtn)
	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	self.red_point = widgets.red_point
	self:initWearEquipWidget(widgets)

	--飞升部分修改
	self:initEquipBtnState(widgets, true)
	widgets.role_btn:stateToPressed()


	--widgets.btn1:onClick(self, self.onQhTips)
	--widgets.btn2:onClick(self, self.onSXTips)
	if widgets.roleTitle_btn then
		widgets.roleTitle_btn:onClick(self, self.onRoleTitleBtn)
	end
	if widgets.reqBtn then
		widgets.reqBtn:onClick(self, self.OpenReputationUI)
	end
	if widgets.xinjueBtn then
		widgets.xinjueBtn:onClick(self,self.onXinjueBtnClick)
	end
	self.roleId = widgets.roleId
	self.zhuanzhi = widgets.zhuanzhi
	self.faction_name = widgets.faction_name
	self.pk_value = widgets.pk_value
	self.transfer = widgets.transfer
	self.charm_value = widgets.charm_value
	self.charm_value2 = widgets.charm_value2 --武勋
	self.sz_redPoint = widgets.sz_redPoint
	--widgets.suit_btn:onClick(self, self.onSuitEquip)

	widgets.sealBtn:onClick(self, self.wearingSevenEquipTips)--龙印系统
	widgets.sealTips:hide()
	widgets.sealLevel:hide()
	widgets.heirloomLevel:hide()
	self:updateHeirloomIcon()
	widgets.heirloomBtn:onClick(self, self.onClickArtifact)--传家宝系统

	self.propertyScroll = widgets.item_scroll
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	self.strengthen = widgets.strengthen_btn
	self.strengthen:onClick(self,self.OnStrengthen)

	widgets.expDescBtn:onClick(self, self.onExpDesc)
	if widgets.bag_btn then
		widgets.bg_redPoint:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2())
		widgets.sz_redPoint:setVisible(g_i3k_game_context:getFashionRedPoint()or  g_i3k_game_context:getMetamorphosisRedPoint())
		widgets.fashion_btn:onClick(self, self.onFashionBtn)
		widgets.bag_btn:onClick(self, self.onOpenbag)
		widgets.warehouse_btn:onClick(self, self.onWarehouseBtn)
		widgets.add_diamond:onClick(self, self.addDiamondBtn)
		widgets.add_coin:onClick(self , self.addCoinBtn)
	end
	self._layout.vars.chooseTypeBtn1:onClick(self, self.onChangeWeaponShowBtn)
end

--[[function wnd_role_property:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
end--]]

function wnd_role_property:initWearEquipWidget(widgets)
	for i=1, eEquipCount do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local repair_icon = "repair"..i
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i

		self.wear_equip[i] = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			repair_icon	= widgets[repair_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end

function wnd_role_property:refresh()
	if self._layout.vars.bag_btn then
		self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	end
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updateProperty()
	self:updatePropertyLabel()
	self:refreshLongYinRedPoint()
	if self._layout.vars.xj_red then
		self._layout.vars.xj_red:setVisible(g_i3k_game_context:checkXinjueRedpoint())
	end
	self:setPropertyScroll()
	self:setChangeWeaponShow()
	self:initShowType(g_i3k_game_context:GetWearEquips())
end

function wnd_role_property:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_role_property:OnStrengthen(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_StrengthenSelf)
	g_i3k_ui_mgr:RefreshUI(eUIID_StrengthenSelf)
end

function wnd_role_property:updatePropertyLabel()
	self.roleId:setText(g_i3k_game_context:GetRoleId())
	self.zhuanzhi:setText(g_i3k_game_context:GetTransformLvl().."转")
	local factionName = g_i3k_game_context:GetSectName() ~= "" and g_i3k_game_context:GetSectName() or "无"
	self.faction_name:setText(factionName)
	local desc, color = g_i3k_db.i3k_db_get_transfer_desc()
	self.transfer:setText(desc)
	self.transfer:setTextColor(color)
	self.pk_value:setText(g_i3k_game_context:GetCurrentPKValue())
	self.charm_value:setText(g_i3k_game_context:GetCharm())
	local forceWarCfgInfo = g_i3k_game_context:getForceWarAddFeat()
	self.charm_value2:setText(forceWarCfgInfo)
	self._layout.vars.marryName:setText(g_i3k_game_context:getMarryRoleName())
end

function wnd_role_property:updateWearEquipsData(ctype, level, fightpower, wEquips)
	self:updateProfile(ctype, level, fightpower, wEquips)
	for i=1,eEquipCount do
		local equip = wEquips[i].equip
		self._layout.vars["an"..i.."1"]:hide()
		self._layout.vars["an"..i.."2"]:hide()
		if equip then
			local equip = wEquips[i].equip
			self.wear_equip[i].repair_icon:hide()
			self.wear_equip[i].equip_btn:onClick(self, self.wearingEquipTips, {partID = i, equip = equip})
			local now_value = equip.naijiu
			if now_value ~= -1 then
				local MaxVlaue = i3k_db_common.equip.durability.durabilityMax
				local repairMark = i3k_db_common.equip.durability.repairMark
				self.wear_equip[i].repair_icon:show()
				self.wear_equip[i].repair_icon:setVisible(now_value/MaxVlaue <= repairMark)
			end
			local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(equip.equip_id, equip.naijiu)
			if rankIndex ~= 0 then
				local index = rankIndex == 1 and 2 or 1
				self._layout.vars["an"..i..index]:show()
			end
		else
			self.wear_equip[i].equip_btn:enable()
			self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
		end
		self.wear_equip[i].red_tips:hide()
		self.wear_equip[i].level_label:hide()
	end
	local widgets = self._layout.vars
	local argData = g_i3k_db.i3k_db_LongYin_arg
	local isOpenImage
	local isOpen = g_i3k_game_context:GetIsHeChengLongYin()
	if isOpen ~= 0 then
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		isOpenImage = argData.args.openItemIronID
		widgets.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:GetLongYinIronForGrade(isOpen)))
		widgets.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	else
		isOpenImage = argData.args.closeItemIronID
		widgets.sealIcon:setImage(g_i3k_db.i3k_db_get_icon_path(isOpenImage))
		widgets.sealBg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
	end
	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.isOpen == 1 then
		widgets.heirloomIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:getHeirloomIconID()))
		widgets.heirloomBg:setImage(g_i3k_get_icon_frame_path_by_rank(5))
	end
	if widgets.xinjueBtn then
		widgets.xinjueBtn:setVisible(level >= i3k_db_xinjue.showLevel)
	end
end

function wnd_role_property:updateHeirloomIcon()
	if g_i3k_game_context:heirloomRedPoint() then
		self._layout.vars.heirloomTips:show()
	else
		self._layout.vars.heirloomTips:hide()
	end
end

function wnd_role_property:wearingEquipTips(sender, data)
	for i, e in ipairs(self.wear_equip) do
		e.is_select:setVisible(i == data.partID)
	end
	if g_i3k_game_context:isFlyEquip(data.partID) then
		g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateWearEquipInfo", data.equip)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateWearEquipInfo", data.equip)
	end
end

function wnd_role_property:notwearingEquipTips(sender, data)
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

--[[function wnd_role_property:onSuitEquip(sender)
	g_i3k_logic:OpenSuitUI()
end

function wnd_role_property:onQhTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RoleTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleTips, g_i3k_db.i3k_db_get_streng_reward_info_for_type())
end

function wnd_role_property:onSXTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Danyao)
	g_i3k_ui_mgr:RefreshUI(eUIID_Danyao)
end--]]

function wnd_role_property:onStrengBtn(sender)
	if g_i3k_game_context:isCanOpenEquipStreng() then
		g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
		g_i3k_logic:OpenStrengEquipUI()
	end
end

function wnd_role_property:onOpenbag(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleLy2)
	g_i3k_logic:OpenBagUI()
end

function wnd_role_property:onFashionBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
	g_i3k_logic:OpenFashionDressUI(nil, eUIID_RoleLy2)
	end
end

function wnd_role_property:onRoleTitleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
	g_i3k_logic:OpenRoleTitleUI()
end

function wnd_role_property:OpenReputationUI(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local openLevel = g_i3k_db.i3k_db_power_rep_get_open_min_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < openLevel then
		g_i3k_ui_mgr:PopupTipMessage("势力声望在"..openLevel.."级开启")
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
	g_i3k_logic:OpenReputationUI()
end

function wnd_role_property:onXinjueBtnClick()
	local _,level = g_i3k_game_context:GetRoleDetail()
	if level < i3k_db_xinjue.openLevel then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s级解锁心决",i3k_db_xinjue.openLevel))
	else
		g_i3k_ui_mgr:CloseUI(eUIID_RoleLy)
		g_i3k_logic:OpenXinJueUI()
	end
end

function wnd_role_property:onWarehouseBtn(sender)
	g_i3k_logic:OpenWarehouseUI(eUIID_RoleLy2)
end

function wnd_role_property:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_role_property:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_role_property:onUpdate(dTime) --模型旋转
	--[[self._spr_update = self._spr_update + dTime
	self.hero_module:setRotation(-self._spr_update * 0.25)--]]
end

local propertyValueTable = {
	ePropID_maxHP,
	ePropID_atkN,
	ePropID_defN,
	ePropID_atr,
	ePropID_ctr,
	ePropID_acrN,
	ePropID_tou,
	ePropID_atkC,
	ePropID_defC,
	ePropID_masterC,
	ePropID_atkW,
	ePropID_defW,
	ePropID_masterW,
	ePropID_atkH,
	ePropID_internalForces,
	ePropID_dex,
	ePropID_atkA,
	ePropID_defA,
	}
local propertyID = {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1013, 1014, 1017, 1015, 1016, 1018, 1012, 1046, 1047, 1008, 1009}
function wnd_role_property:updateProperty()
	self.propertyScroll:removeAllChildren()
	local decentValueTable = {ePropID_shell, ePropID_sbd}
	local useKnifeID = {1010, 1011}
	local useKnifeValueTable = {ePropID_deflect, ePropID_atkD}
	local useKnifeIcon = {1027,1029}

	local doctorValue = ePropID_healA
	local hero = i3k_game_get_player_hero()
	for i=1,#propertyID do
		if i==15 or i==16 then
			if g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.openLevel then
				local heroProperty = require("ui/widgets/yxt1")()
				local widget = heroProperty.vars
				local icon = g_i3k_db.i3k_db_get_property_icon(propertyID[i])
				widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
				widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propertyID[i]))
				widget.btn:onTouchEvent(self,self.showTips,propertyID[i])
				widget.propertyValue:setText(hero:GetPropertyValue(propertyValueTable[i]))
				self.propertyScroll:addItem(heroProperty)
			end
		else
			local heroProperty = require("ui/widgets/yxt1")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(propertyID[i])
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,propertyID[i])
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propertyID[i]))
			if i==17 or i==18 then
				local x = tonumber(hero:GetPropertyValue(propertyValueTable[i]))*100
				if x-math.floor(x)>0 then
					widget.propertyValue:setText(string.format("%.2f",x).."%")
				else
					widget.propertyValue:setText(string.format("%d",x).."%")
				end
			else
				widget.propertyValue:setText(hero:GetPropertyValue(propertyValueTable[i]))
			end
			self.propertyScroll:addItem(heroProperty)
		end

	end

	-----------正派反派分别
	if g_i3k_game_context:GetTransformLvl() >= 2 then
		local heroProperty = require("ui/widgets/yxt1")()
		local widget = heroProperty.vars
		if g_i3k_game_context:GetTransformBWtype()==1 then
			local icon = g_i3k_db.i3k_db_get_property_icon(Watch_Box)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,Watch_Box)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Watch_Box))
			widget.propertyValue:setText(hero:GetPropertyValue(decentValueTable[1]))
		else
			local icon = g_i3k_db.i3k_db_get_property_icon(Suck_Blood)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,Suck_Blood)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Suck_Blood))
			widget.propertyValue:setText(hero:GetPropertyValue(decentValueTable[2]))
		end
		self.propertyScroll:addItem(heroProperty)
	end

	----------人物职业分别
	if hero._id == 1 then
		for i=1,2 do
			local heroProperty = require("ui/widgets/yxt1")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(useKnifeID[i])
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(useKnifeID[i]))
			widget.btn:onTouchEvent(self,self.showTips,useKnifeID[i])
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(useKnifeIcon[i]))
			local x = tonumber(hero:GetPropertyValue(useKnifeValueTable[i]))*100
			if x-math.floor(x)>0 then
				widget.propertyValue:setText(string.format("%.2f",x).."%")
			else
				widget.propertyValue:setText(string.format("%d",x).."%")
			end
			self.propertyScroll:addItem(heroProperty)
		end
	elseif hero._id == 5 then
		local heroProperty = require("ui/widgets/yxt1")()
		local widget = heroProperty.vars
		local icon = g_i3k_db.i3k_db_get_property_icon(Treat_Crit)
		widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.btn:onTouchEvent(self,self.showTips,Treat_Crit)
		widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(Treat_Crit))
		widget.propertyValue:setText(hero:GetPropertyValue(doctorValue) / 100 .. "%");
		self.propertyScroll:addItem(heroProperty)
	end
	----------骑战伤害&骑战防御
	self:updateSteedFightProperty()
	----------内甲属性
	self:updateUnderWearProperty()
	----------星耀属性
	self:updateStarProperty()
	----------抗性相关
	self:updateBuffMasterProperty()
	self:updateExpBarPercent()
	self:updateWidgetBg()
end

function wnd_role_property:showTips(sender,eventType, showId)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_RolePropertyTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_RolePropertyTips, showId)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_RolePropertyTips)
		end
	end
end
function wnd_role_property:updateUnderWearProperty()
	local index = g_i3k_game_context:getUnderWearData()
	if index ~= 0 then
		local rank = g_i3k_game_context:getAnyUnderWearAnyData(index,"rank")
		local level = g_i3k_game_context:getAnyUnderWearAnyData(index,"level")
		local propMulti = i3k_db_under_wear_upStage[index][rank].attrUpPro / 10000 + 1
		local hero = i3k_game_get_player_hero()
		for i=1 ,10 do
			local attrId = string.format("attrId%s",i)
			local curAttr= i3k_db_under_wear_update[index][level][attrId]
			if curAttr ~= 0 then
				local heroProperty = require("ui/widgets/yxt1")()
				local widget = heroProperty.vars
				local icon = g_i3k_db.i3k_db_get_property_icon(curAttr)
				widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
				widget.btn:onTouchEvent(self,self.showTips,curAttr)
				widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(curAttr))
				widget.propertyValue:setText(hero:GetPropertyValue(curAttr));
				self.propertyScroll:addItem(heroProperty)
			end
		end
	end
end
local starPropertyList = {1084,1085,1086,1087,1088,1089,1090,1091};
function wnd_role_property:updateStarProperty()
	if g_i3k_game_context:GetLevel() >= i3k_db_LongYin_arg.fuling.openLevel then
		local hero = i3k_game_get_player_hero()
		for _,propID in pairs(starPropertyList) do
			local value = hero:GetPropertyValue(propID);
			local heroProperty = require("ui/widgets/yxt1")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,propID)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propID))
			widget.propertyValue:setText(value);
			self.propertyScroll:addItem(heroProperty)
		end
	end
end
local buffMasterPropertyList = {1077,1032,1078,1033,1079,1034};
function wnd_role_property:updateBuffMasterProperty()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.masterOpenLvl then
		local hero = i3k_game_get_player_hero()
		for _,propID in pairs(buffMasterPropertyList) do
			local heroProperty = require("ui/widgets/yxt1")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,propID)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propID))
			local value = hero:GetPropertyValue(propID);
			local value_str = i3k_get_prop_show(propID,value*10000)
			widget.propertyValue:setText(value_str);
			self.propertyScroll:addItem(heroProperty)
		end
	end
end
local steedFightPropertyList = {1106,1107}
function wnd_role_property:updateSteedFightProperty()
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.spiritOpenLvl then
		local hero = i3k_game_get_player_hero()
		for _,propID in pairs(steedFightPropertyList) do
			local value = hero:GetPropertyValue(propID);
			local heroProperty = require("ui/widgets/yxt1")()
			local widget = heroProperty.vars
			local icon = g_i3k_db.i3k_db_get_property_icon(propID)
			widget.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			widget.btn:onTouchEvent(self,self.showTips,propID)
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(propID))
			widget.propertyValue:setText(value);
			self.propertyScroll:addItem(heroProperty)
		end
	end
end
function wnd_role_property:updateExpBarPercent()
	local percent = 0
	local level, exp = g_i3k_game_context:GetLevelExp()
	local outExp = g_i3k_game_context:GetOutExp()
	local value = 0
	if level+1 <= #i3k_db_exp then
		value = i3k_db_exp[level+1].value
		percent = exp / value * 1000
	else
		if not i3k_db_exp[level] then
			error(string.format(" level = %s, exp = %s", level, exp))
		end
		value = i3k_db_exp[level].value
		exp = value
		percent = exp / value * 1000
	end
	if g_i3k_game_context:getRoleExpFull() then
		self._layout.vars.expbar:setImage(g_i3k_db.i3k_db_get_icon_path(8512))
		self._layout.vars.expbarCount:setTextColor("fff9ffc2")
		self._layout.vars.expbarCount:enableOutline("ffb67725")
	else
		self._layout.vars.expbar:setImage(g_i3k_db.i3k_db_get_icon_path(8510))
		self._layout.vars.expbarCount:setTextColor("ffffffff")
		self._layout.vars.expbarCount:enableOutline("ff5b7838")
	end
	self._layout.vars.expbar:setPercent(math.floor(percent) / 10)
	self._layout.vars.expbarCount:setText(exp + outExp .. "/" .. value)
end

function wnd_role_property:updateWidgetBg()
	local all_child = self.propertyScroll:getAllChildren()
	for i, e in pairs(all_child) do
		local widget = e.vars
		widget.propertyBg2:setVisible(i%2 ~= 0)
		-- widget.propertyValue:setTextColor(COLOR2)
		-- widget.propertyName:setTextColor(COLOR2)
	end
end

function wnd_role_property:refreshLongYinRedPoint()
	self._layout.vars.sealTips:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2() or g_i3k_game_context:getFulingRedPoint())
end

-- 打开经验系统介绍
function wnd_role_property:onExpDesc(sender)
	g_i3k_logic:OpenExpDescUI()
end

function wnd_create(layout)
	local wnd = wnd_role_property.new()
	wnd:create(layout)
	return wnd
end
