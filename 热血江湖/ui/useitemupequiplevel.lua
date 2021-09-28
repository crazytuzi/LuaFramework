-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_useItemUpEquipLevel = i3k_class("wnd_useItemUpEquipLevel",ui.wnd_profile)
local LEVELICON = {109,110,111,112,113,114,115,116,117,118}
local LAYER_ZBQHT	= "ui/widgets/zbqht"
local WIDGET_JZSJT	="ui/widgets/zbsjt"
local threshold = i3k_db_common.equip.durability.Threshold

function wnd_useItemUpEquipLevel:ctor()
	self.partID = 0
	self.selectID = 0
	self.widgets = nil
	self.itemCfg = nil
end

function wnd_useItemUpEquipLevel:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.help_btn:onClick(self,self.onHelpBtn)
	self._layout.vars.itemBtn:onClick(self, self.showItemInfo)
	local widgets = self._layout.vars
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型

	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	self.bg_redPoint = widgets.bg_redPoint
	self.sz_redPoint = widgets.sz_redPoint
	self:initWearEquipWidget(widgets)

end

function wnd_useItemUpEquipLevel:onHelpBtn()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18538))
end

function wnd_useItemUpEquipLevel:refresh(item, partID, equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	self.itemCfg = item	
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	if self.partID == 0 then
		if partID then
			self.partID = partID;
			self:selectEquip(partID, equip_id) --强化跳转
		end
	else
		self:selectEquip(self.partID, wEquips[self.partID].equip.equip_id) --刷新右边信息
	end
	local widget = require(WIDGET_JZSJT)()
	widget.vars.text:setText(i3k_get_string(18536))
	self._layout.vars.textScroll:addItem(widget)
end

function wnd_useItemUpEquipLevel:updateWearEquipsLevl(partID)
	self.wear_equip[partID].level_label:setVisible(g_i3k_game_context:GetEquipStrengLevel(partID) ~= 0)
	if g_i3k_game_context:GetEquipStrengLevel(partID) ~= 0 then
		self.wear_equip[partID].level_label:setText("+"..g_i3k_game_context:GetEquipStrengLevel(partID))
	end
end

function wnd_useItemUpEquipLevel:selectEquip(partID, equip_id)
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == partID)
	end
	self.selectID = partID
	self:setRightView(equip_id, partID)
end

--初始化穿着装备控件
function wnd_useItemUpEquipLevel:initWearEquipWidget(widgets)
	for i=1, eEquipCount do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i

		self.wear_equip[i] = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end


function wnd_useItemUpEquipLevel:updateWearEquipsData(ctype, level, fightpower, wEquips)--左侧已穿装备的信息
	self:updateProfile(ctype, level, fightpower, wEquips)
	-- self.wear_equip[eEquipSymbol].equip_btn:setVisible(g_i3k_game_context:GetLevel() >= 79)
	-- self.wear_equip[eEquipArmor].equip_btn:setVisible(g_i3k_game_context:GetLevel() >= 85)

	for i=1,eEquipNumber do
		if not g_i3k_game_context:checkEquipFacility(i, g_FACILITY_EQUIP_UPGRADE) then
			self.wear_equip[i].equip_btn:setVisible(false)
			self:showTopBtn(false)
		else
			local equip = wEquips[i].equip
			if equip then
				self.wear_equip[i].equip_btn:onClick(self, self.onSelectEquip, {equip_id = equip.equip_id, partID = i})
				--self.wear_equip[i].red_tips:show()				
				self.wear_equip[i].level_label:setVisible(wEquips[i].eqGrowLvl ~= 0)
				self:updateWearEquipsLevl(i)
				if g_i3k_game_context:GetEquipStrengLevel(i) >= self.itemCfg.args1 then
					self.wear_equip[i].equip_btn:disableWithChildren()

				end
			else
				self.wear_equip[i].equip_btn:enable()
				self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
			end
		end
	end
end                                                                                 

function wnd_useItemUpEquipLevel:notwearingEquipTips(sender, data)
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

function wnd_useItemUpEquipLevel:onSelectEquip(sender, data)
	if self.selectID == data.partID then
		return
	end
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == data.partID)
	end
	self.selectID = data.partID
	self:setRightView(data.equip_id, data.partID)
end


function wnd_useItemUpEquipLevel:playStrengEffect()
	self._layout.anis.c_zdqh.play()
end

function wnd_useItemUpEquipLevel:setRightView(equip_id, partID)
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local euqipInfo = wEquips[euqipCfg.partID]
	local qh_level = euqipInfo.eqGrowLvl--装备当前等级
	local tp_level = euqipInfo.breakLvl--装备突破等级
	local naijiu = euqipInfo.equip.naijiu
	local attribute = euqipInfo.equip.attribute
	local now_power = g_i3k_game_context:GetBodyEquipPower(equip_id, attribute, naijiu, qh_level, euqipInfo.eqEvoLvl, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)
	local next_power = g_i3k_game_context:GetBodyEquipPower(equip_id, attribute, naijiu, self.itemCfg.args1, euqipInfo.eqEvoLvl, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID)
	local widgets = self._layout.vars
	local isShouldBreak = i3k_db_streng_equip_break[strengGroup][tp_level+1] and i3k_db_streng_equip_break[strengGroup][tp_level+1].level < self.itemCfg.args1 --是否应该突破
	self._layout.vars.increease:onClick(self, self.onIncreaseBtn,isShouldBreak)
	self:setItemIcon(partID)
	self:setEquipDetail(euqipInfo, equip_id, widgets)
	widgets.qh_equip_score1:setText("战力："..math.modf(now_power))
	widgets.qh_equip_score2:setText("战力："..math.modf(next_power))
	widgets.scroll1:removeAllChildren()
	widgets.scroll2:removeAllChildren()
	
	local equip = euqipInfo.equip
	local addRate = 0
	
	local temp = {}
	local max_data = {}
	local cur_data = {}--当前等级属性
	for k,v in pairs(euqipCfg.properties) do
		if v.type ~= 0 then
			local _temp = i3k_db_prop_id[v.type]
			local value = v.value
			if naijiu ~= -1 and naijiu > threshold then
				value = v.value * (addRate + 1)
				value = math.modf(value)
			end
			local temp_value = value
			local add_value = i3k_db_streng_equip[strengGroup][qh_level].props[v.type] or 0
			value = value + add_value
			local layer1 = require(LAYER_ZBQHT)()
			local widget = layer1.vars
			widget.label:setText(_temp.desc..":")
			widget.value:setText(value)
			cur_data[k]={ name = _temp.desc, value = value}

			local value2 = temp_value
			local add_value2 = i3k_db_streng_equip[strengGroup][self.itemCfg.args1].props[v.type] or i3k_db_streng_equip[strengGroup][qh_level].props[v.type] or 0
			value2 = value2 + add_value2
			local layer2 = require(LAYER_ZBQHT)()
			local widget2 = layer2.vars
			widget2.label:setText(_temp.desc..":")
			widget2.value:setText(value2)
			if not i3k_db_streng_equip[strengGroup][qh_level +1] then
				max_data = {id = equip_id, lvl = qh_level, colour1 = _temp.textColor, colour2 = _temp.valuColor, power = math.modf(next_power),}
				if k == 1 then
					temp.name = _temp.desc
					temp.value = value2
				elseif k == 2 then
					max_data.name1 = temp.name
					max_data.value1 = temp.value
					max_data.name2 = _temp.desc
					max_data.value2 = value2
				end
		    end
			
		widgets.scroll1:addItem(layer1)
		widgets.scroll2:addItem(layer2)
		
		end
	end
end

function wnd_useItemUpEquipLevel:setEquipDetail(euqipInfo, equip_id, widgets)
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local qh_level = euqipInfo.eqGrowLvl
	self:setNowLvlIcon(qh_level, widgets)
	self:setNextLvlIcon(self.itemCfg.args1, widgets)
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	widgets.qh_equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id,i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id,i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_name1:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	widgets.qh_equip_name2:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	widgets.qh_equip_name1:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))--根据道具品级设置颜色
	widgets.qh_equip_name2:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
end

function wnd_useItemUpEquipLevel:setNextLvlIcon(level, widgets)
	widgets.lv_icon3:setVisible(true)
	widgets.lv_icon4:setVisible(level >= 10)
	widgets.lv_icon6:setVisible(level >= 100)
	if level < 10 then
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level]))
	elseif level <100 then
		local tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		widgets.lv_icon4:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	else
		widgets.lv_icon6:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/100)]))
		local tag = math.modf(level/10)%10 == 0 and 10 or math.modf(level/10)%10
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
		tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon4:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	end
end

function wnd_useItemUpEquipLevel:setNowLvlIcon(level, widgets)
	widgets.lv_icon1:setVisible(true)
	widgets.lv_icon2:setVisible(level >= 10)
	widgets.lv_icon5:setVisible(level >= 100)
	if level < 10 then
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level == 0 and 10 or level]))
	elseif level <100 then
		local tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		widgets.lv_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	else
		widgets.lv_icon5:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/100)]))
		local tag = math.modf(level/10)%10 == 0 and 10 or math.modf(level/10)%10
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
		tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	end
end

function wnd_useItemUpEquipLevel:onIncreaseBtn(sender,isShouldBreak)
	if isShouldBreak then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18537))
	elseif  g_i3k_game_context:GetLevel() < self.itemCfg.args1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(40))
	elseif  g_i3k_game_context:GetCommonItemCanUseCount(self.itemCfg.id) < 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18555))
	else
		i3k_sbean.bag_useitem_equip_up_to_level(self.selectID, self.itemCfg.id)
	end
end

function wnd_useItemUpEquipLevel:removeText()
	self._layout.vars.textScroll:removeAllChildren()
end

function wnd_useItemUpEquipLevel:showItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(self.itemCfg.id)
end

function wnd_useItemUpEquipLevel:setItemIcon()
	self._layout.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.itemCfg.id))
	self._layout.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.itemCfg.id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.jklh:setText(self.itemCfg.name)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self.itemCfg.id)
	self._layout.vars.jklh:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self._layout.vars.hjkhkj:setText(g_i3k_game_context:GetCommonItemCanUseCount(self.itemCfg.id).."/"..1)
	self._layout.vars.hjkhkj:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(self.itemCfg.id) >= 1))
end


function wnd_create(layout)
	local wnd = wnd_useItemUpEquipLevel.new()
	wnd:create(layout)
	return wnd
end
