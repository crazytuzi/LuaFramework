-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_equip_streng = i3k_class("wnd_equip_streng",ui.wnd_profile)

--等级图片1~9/0
local LEVELICON = {109,110,111,112,113,114,115,116,117,118}
local LAYER_ZBQHT	= "ui/widgets/zbqht"
local LAYER_ZBQHT2	= "ui/widgets/zbqht2"
local STRENG_EQUIP = "ui/widgets/zhuangbeiqianghua"
local STRENG_EQUIP_MAX = "ui/widgets/zhuangbeiqianghuam"
local STRENG_EQUIP_BREAK = "ui/widgets/zhuangbeitupo"
local threshold = i3k_db_common.equip.durability.Threshold

function wnd_equip_streng:ctor()
	--self.showType = 1
	self.partID = 0
	self.selectID = 0
	self.widgets = nil
end

function wnd_equip_streng:configure()
	local widgets = self._layout.vars
	
	self:initRedPoint(widgets)
	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	
	self:initWearEquipWidget(widgets)
	
	widgets.check:onClick(self, self.strengTips)
	self.increase_lv = widgets.increase_lv
	
	widgets.qh_bt:stateToPressed()
	widgets.sx_bt:stateToNormal()
	widgets.xq_bt:stateToNormal()
	widgets.cl_bt:stateToNormal()

	--飞升部分修改
	self:initEquipBtnState(widgets)
	self.new_root = widgets.new_root
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

--初始化穿着装备控件
function wnd_equip_streng:initWearEquipWidget(widgets)
	for i=1, eEquipNumber do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i
		
		self.wear_equip[i]  = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end

function wnd_equip_streng:refresh(partID, equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	if self.partID == 0 then
		if partID then
			self.partID = partID;
			local equipType = g_i3k_game_context:getEquipType(self.partID)
		    self:setEquipBtnType(equipType)
			self:selectEquip(partID, equip_id) --强化跳转
		else
			self:initShowType(g_i3k_game_context:GetWearEquips())
		end
	else
		self:selectEquip(self.partID, wEquips[self.partID].equip.equip_id) --刷新右边信息（购买铜钱）
	end
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updatePageRedPoint(g_i3k_game_context.qhRedPoint)
	self:onShowBtn()
end

function wnd_equip_streng:onShowBtn()
	self._layout.vars.xq_bt:setVisible(false)
	self._layout.vars.sx_bt:setVisible(false)
	self._layout.vars.cl_bt:setVisible(false)
	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionHide.starUpHideLvl then
		self._layout.vars.sx_bt:setVisible(true)
		self._layout.vars.sx_bt:onClick(self, self.sxBtn)
	end
	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionHide.inlayHideLvl then
		self._layout.vars.xq_bt:setVisible(true)
		self._layout.vars.xq_bt:onClick(self, self.xqBtn)
	end
	if g_i3k_db.i3k_db_get_equip_temper_show() then
		self._layout.vars.cl_bt:setVisible(true)
		self._layout.vars.cl_bt:onClick(self, self.clBtn)
	end
end

function wnd_equip_streng:RemoveRightUI()
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
end

function wnd_equip_streng:addNewNode(layer)
	self:RemoveRightUI()
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(self.new_root:getContentSize().width, self.new_root:getContentSize().height)
end

function wnd_equip_streng:playStrengEffect(equip_id, partID)
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		local delay = cc.DelayTime:create(1.2)--序列动作 动画播了1.2秒后刷新界面
		local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
			local c_zdqh = old_layer[1].anis.c_zdqh
			c_zdqh.play()
		end), delay, cc.CallFunc:create(function ()
			self:setRightView(equip_id, partID)
		end))
		local root = old_layer[1].vars.qh_view
		root:runAction(seq)
	end
end
--[[
function wnd_equip_streng:defaultSelectEquip(wEquips, startId, endId)
	local startPos = startId and startId or 1
	local endPos = endId and endId or eEquipNumber
	for i=1, eEquipNumber do
		local equip = wEquips[i].equip
		if equip then
			self.wear_equip[i].is_select:show()
			self.selectID = i;
			self.partID = i;
			self:setRightView(equip.equip_id, i)
			break
		end
	end
end
]]
function wnd_equip_streng:selectEquip(partID, equip_id)
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == partID)
	end
	self.selectID = partID
	self:setRightView(equip_id, partID)
end

function wnd_equip_streng:updateWearEquipsData(ctype, level, fightpower, wEquips)
	self:updateProfile(ctype, level, fightpower, wEquips)
	for i=1,eEquipNumber do
		if not g_i3k_game_context:checkEquipFacility(i, g_FACILITY_EQUIP_UPGRADE) then
			self.wear_equip[i].equip_btn:setVisible(false)
			self:showTopBtn(false)
		else
		local equip = wEquips[i].equip
		if equip then
			self.wear_equip[i].equip_btn:onClick(self, self.onSelectEquip, {equip_id = equip.equip_id, partID = i})
			self.wear_equip[i].red_tips:show()				
			self.wear_equip[i].level_label:setVisible(wEquips[i].eqGrowLvl ~= 0)
			self:updateWearEquipsLevl(i)
		else
			self.wear_equip[i].equip_btn:enable()
			self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
			end
		end
	end
end

function wnd_equip_streng:updateWearEquipsLevl(partID)
	self.wear_equip[partID].level_label:setVisible(g_i3k_game_context:GetEquipStrengLevel(partID) ~= 0)
	if g_i3k_game_context:GetEquipStrengLevel(partID) ~= 0 then
		self.wear_equip[partID].level_label:setText("+"..g_i3k_game_context:GetEquipStrengLevel(partID))
	end
	self:updatePartRedPoint()
end

function wnd_equip_streng:onSelectEquip(sender, data)
	if self.selectID == data.partID then
		return
	end
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == data.partID)
	end
	self.selectID = data.partID
	self:setRightView(data.equip_id, data.partID)
end

function wnd_equip_streng:notwearingEquipTips(sender, data)
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

function wnd_equip_streng:setRightView(equip_id, partID)
	self.widgets = nil
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local euqipInfo = wEquips[euqipCfg.partID]
	local qh_level = euqipInfo.eqGrowLvl--装备当前等级
	local tp_level = euqipInfo.breakLvl--装备突破等级
	local naijiu = euqipInfo.equip.naijiu
	local attribute = euqipInfo.equip.attribute--当前等级装备的属性加成情况
	local now_power = g_i3k_game_context:GetBodyEquipPower(equip_id, attribute, naijiu, qh_level, euqipInfo.eqEvoLvl, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)
	local next_power = g_i3k_game_context:GetBodyEquipPower(equip_id, attribute, naijiu, qh_level+1, euqipInfo.eqEvoLvl, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	local _increase_desc = g_i3k_db.i3k_db_get_streng_reward_info_for_type(1)
	local str = _increase_desc[1].count < i3k_db_common.equip.equipPropCount and "[<c=red>" or "[<c=green>"
	self.increase_lv:setText(_increase_desc[1].desc.." 额外奖励属性"..str.._increase_desc[1].count.."/"..i3k_db_common.equip.equipPropCount.."</c>]")
	local isShouldBreak = i3k_db_streng_equip_break[strengGroup][tp_level+1] and i3k_db_streng_equip_break[strengGroup][tp_level+1].level == qh_level --是否应该突破了
	local widgets
	local isMax
	if not i3k_db_streng_equip[strengGroup][qh_level+1] then
		isMax = true
	elseif not isShouldBreak then	--如果不该突破 显示升级widget
		local _layer = require(STRENG_EQUIP)()
		widgets = _layer.vars
		self:addNewNode(_layer)
		self.widgets = widgets
		self:setNeedItem(partID, widgets)
	else 			--否则显示突破widgets
		local _layer = require(STRENG_EQUIP_BREAK)()
		self:addNewNode(_layer)
		widgets = _layer.vars
		self.widgets = widgets
		self:setBreakNeedItem(partID, widgets)
	end
	if widgets then
		if not isShouldBreak then--升级界面
			self:setEquipDetail(euqipInfo, equip_id, widgets)
			widgets.qh_equip_score1:setText("战力："..math.modf(now_power))
			widgets.qh_equip_score2:setText("战力："..math.modf(next_power))
			widgets.scroll1:removeAllChildren()
			widgets.scroll2:removeAllChildren()
		else--突破界面
			g_i3k_ui_mgr:CloseUI(eUIID_ChooseAutoStreng)
			self:setBreakEquipDetail(euqipInfo, equip_id, widgets, strengGroup, partID)
			widgets.propValue1:setText(math.modf(now_power))
		end
	end
	local equip = euqipInfo.equip
	local addRate = 0
	if naijiu ~= -1 and naijiu > threshold and equip.legends and equip.legends[1] and equip.legends[1]~=0 then
		addRate = i3k_db_equips_legends_1[equip.legends[1]].count/10000
	end
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
			local add_value2 = i3k_db_streng_equip[strengGroup][qh_level+1].props[v.type] or i3k_db_streng_equip[strengGroup][qh_level].props[v.type] or 0
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
			if widgets and not isShouldBreak then
				widgets.scroll1:addItem(layer1)
				widgets.scroll2:addItem(layer2)
			end
		end
	end
	if isShouldBreak then
        --设置突破界面的两条属性
		if cur_data[1] then
			widgets.propName2:setText(cur_data[1].name..":")
			widgets.propValue2:setText(cur_data[1].value)
		end
		if cur_data[2] then
			widgets.prop2:show()
			widgets.propName3:setText(cur_data[2].name..":")
			widgets.propValue3:setText(cur_data[2].value)
		else
			widgets.prop2:hide()
		end
	end
	if isMax then
		self:showMaxStreng(max_data)
	end
end

function wnd_equip_streng:setEquipDetail(euqipInfo, equip_id, widgets)
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local qh_level = euqipInfo.eqGrowLvl
	self:setNowLvlIcon(qh_level, widgets)
	self:setNextLvlIcon(qh_level+1, widgets)
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	widgets.qh_equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id,i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id,i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_name1:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	widgets.qh_equip_name2:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	widgets.qh_equip_name1:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))--根据道具品级设置颜色
	widgets.qh_equip_name2:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
end

function wnd_equip_streng:setBreakEquipDetail(equipInfo, equip_id, widgets, strengGroup, partID)
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local qh_level = equipInfo.eqGrowLvl
	self:setNowLvlIcon(qh_level, widgets)
	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	widgets.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id,i3k_game_context:IsFemaleRole()))
	widgets.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	widgets.equip_name:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))--根据道具品级设置颜色
	widgets.qh_level:setText("+"..qh_level)
	widgets.breakBtn:onClick(self,function()
		if i3k_db.i3k_db_can_equip_break(strengGroup, equipInfo.breakLvl + 1) then
			i3k_sbean.equip_levelup_break(partID)
		else
		   	g_i3k_ui_mgr:PopupTipMessage("材料不足")
		end
	end)
end

function wnd_equip_streng:showMaxStreng(data)
	local _layer = require(STRENG_EQUIP_MAX)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(self.partID);
	local level = data.lvl
	widgets.lv_icon6:setVisible(level >= 10)
	widgets.lv_icon7:setVisible(level >= 100)
	if level < 10 then
		widgets.lv_icon5:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level]))
	elseif level < 100 then
		local tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon5:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		widgets.lv_icon6:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	else
		widgets.lv_icon7:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/100)]))
	end
	widgets.grade_icon9:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(data.id))
	widgets.equip_icon9:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(data.id,i3k_game_context:IsFemaleRole()))
	widgets.qh_level9:setText("+"..#i3k_db_streng_equip[strengGroup])
	widgets.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(data.id))
	local rank = g_i3k_db.i3k_db_get_common_item_rank(data.id)
	widgets.equip_name:setTextColor(g_i3k_get_color_by_rank(rank))
	widgets.maxlabel1:setText("战力：")
	widgets.maxlabel2:setText(data.power)
	--widgets.maxlabel1:setTextColor(g_i3k_get_red_color())
	--widgets.maxlabel2:setTextColor(g_i3k_get_red_color())
	if data.name1 then
		widgets.maxlabel3:setText(data.name1..":")
		-- widgets.maxlabel3:setTextColor(data.colour1)
		widgets.maxlabel4:setText(data.value1)
		-- widgets.maxlabel4:setTextColor(data.colour2)
	end
	if data.name2 then
		widgets.max_desc4:show()
		widgets.maxlabel5:setText(data.name2..":")
		widgets.maxlabel6:setText(data.value2)
		-- widgets.maxlabel5:setTextColor(data.colour1)
		-- widgets.maxlabel6:setTextColor(data.colour2)
	else
		widgets.max_desc4:hide()
	end
end

function wnd_equip_streng:setNowLvlIcon(level, widgets)
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

function wnd_equip_streng:setNextLvlIcon(level, widgets)
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

function wnd_equip_streng:setNeedItem(partID, widgets)
	local size = 1
	widgets.item_scroll:removeAllChildren()
	self.partID = partID
	self.widgets = widgets
	self:setItemScrollData(widgets)
	widgets.increease:onClick(self, self.onIncreaseBtn, partID)
	widgets.autoincrease:onClick(self, self.onAutoIncreaseBtn, partID)
end
--设置突破所需材料
function wnd_equip_streng:setBreakNeedItem(partID, widgets)
	local size = 1
	widgets.item_scroll:removeAllChildren()
	self.partID = partID
	self.widgets = widgets
	local lvl = g_i3k_game_context:GetEquipStrengLevel(self.partID)
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	local consume
	for i,v in ipairs(i3k_db_streng_equip_break[strengGroup]) do
		if v.level == lvl then
			consume = v.consume
			break
		end
	end
	widgets.item_scroll:removeAllChildren()
	if consume then
		for i, e in ipairs(consume) do
				local _layer = require(LAYER_ZBQHT2)()
				local widget = _layer.vars
				local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemId))
				widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemId))
				widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId,i3k_game_context:IsFemaleRole()))
				widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemId))
				widget.item_name:setTextColor(name_colour)
				widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
				if e.itemId == g_BASE_ITEM_DIAMOND or e.itemId == g_BASE_ITEM_COIN then
					widget.item_count:setText(e.count)
				else
					widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) .."/".. e.count)
				end
				widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= e.count))
				widget.bt:onClick(self, self.onItemTips, e.itemId)
				widgets.item_scroll:addItem(_layer)
		end
	end
	self:updatePageRedPoint(g_i3k_game_context.qhRedPoint)
	self:updatePartRedPoint()
end

function wnd_equip_streng:getNeedItem(lvl, part)
	local partID = self.partID;
	if part then
		partID = part;
	end
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	if not i3k_db_streng_equip[strengGroup][lvl-1] then
		error(string.format("Error equip_streng:getNeedItem the lvl is: %s", lvl))
	end 
	local _data = i3k_db_streng_equip[strengGroup][lvl] or i3k_db_streng_equip[strengGroup][lvl-1]

	local need_item = {}
	table.insert(need_item, {itemId = g_BASE_ITEM_EQUIP_ENERGY, itemCount = _data.energy,})
	for i=1,3 do
		local item_id = string.format("item%sID", i)
		local item_count = string.format("item%sCount", i)
		if _data[item_id] ~= 0 then
			table.insert(need_item, {itemId = _data[item_id], itemCount =  _data[item_count]})
		end
	end
	return need_item
end

function wnd_equip_streng:setItemScrollData(widgets)
	local lWidget = widgets or self.widgets
	if lWidget then
		lWidget.item_scroll:removeAllChildren()
		local breakLvl = g_i3k_game_context:GetEquipBreakLevel(self.partID)
		local qh_level = g_i3k_game_context:GetEquipStrengLevel(self.partID)
		local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(self.partID);
		local breakCfg = i3k_db_streng_equip_break[strengGroup][breakLvl + 1]
		local isShouldBreak = (breakCfg and breakCfg.level) == qh_level
		local use_item
		if isShouldBreak then
			use_item = breakCfg.consume
		else
			use_item = self:getNeedItem(qh_level + 1)
		end
		for i, e in ipairs(use_item) do
			local _layer = require(LAYER_ZBQHT2)()
			local widget = _layer.vars
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemId))
			widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemId))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId,i3k_game_context:IsFemaleRole()))
			widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemId))
			widget.item_name:setTextColor(name_colour)
			widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
			if e.itemId == g_BASE_ITEM_DIAMOND or e.itemId == g_BASE_ITEM_COIN then
				widget.item_count:setText(e.itemCount or e.count)
			else
				widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) .."/".. (e.itemCount or e.count))
			end
			widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= (e.itemCount or e.count)))
			widget.bt:onClick(self, self.onItemTips, e.itemId)
			lWidget.item_scroll:addItem(_layer)
		end
		self:updatePageRedPoint(g_i3k_game_context.qhRedPoint)
		self:updatePartRedPoint()
	end
end

function wnd_equip_streng:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_equip_streng:onIncreaseBtn(sender, partID)
	if self:isEnough(partID) then
		i3k_sbean.equip_levelup(partID, g_i3k_game_context:GetEquipStrengLevel(partID) + 1)
		self:updatePartRedPoint()
	end
end

function wnd_equip_streng:onAutoIncreaseBtn(sender, partID)
	--self:autoStrengMax(partID)
	g_i3k_ui_mgr:OpenUI(eUIID_ChooseAutoStreng)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChooseAutoStreng, partID)
end

function wnd_equip_streng:autoStrengMax(partID)
	local qh_lvl = g_i3k_game_context:GetEquipStrengLevel(partID)
	if qh_lvl == g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(40))
		return false
	end
	local can_up_lv = 0
	local use_item = {}
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	local breakLvl = g_i3k_game_context:GetEquipBreakLevel(partID) + 1
	local breakCfg = i3k_db_streng_equip_break[strengGroup][breakLvl]
	for i=qh_lvl+1, math.min(g_i3k_game_context:GetLevel(), breakCfg and breakCfg.level or g_i3k_game_context:GetLevel()) do
		local _data = i3k_db_streng_equip[strengGroup][i]
		if _data then
			local energy = _data.energy
			if use_item[g_BASE_ITEM_EQUIP_ENERGY] then
				use_item[g_BASE_ITEM_EQUIP_ENERGY] = use_item[g_BASE_ITEM_EQUIP_ENERGY]  + _data.energy
			else
				use_item[g_BASE_ITEM_EQUIP_ENERGY] = _data.energy
			end
			for j=1,3 do
				local item_id = string.format("item%sID",j)
				local item_count = string.format("item%sCount",j)
				local itemId = _data[item_id]
				local itemCount = _data[item_count]
				if itemId ~= 0 then
					if use_item[itemId] then
						use_item[itemId] = use_item[itemId] + itemCount
					else
						use_item[itemId] = itemCount
					end
				end
			end
			local is_enough = true
			for k,v in pairs(use_item) do
				if g_i3k_game_context:GetCommonItemCanUseCount(k) < v then
					is_enough = false
					break
				end
			end
			if not is_enough then
				can_up_lv = i - 1
				break
			end
			can_up_lv = i
		end
	end
	if can_up_lv <= qh_lvl then
		g_i3k_ui_mgr:PopupTipMessage("您的材料不足")
	elseif can_up_lv > qh_lvl then
		i3k_sbean.equip_levelup(partID, can_up_lv)
		self:updatePartRedPoint()
	end
end

function wnd_equip_streng:isEnough(partID)
	local role_lvl = g_i3k_game_context:GetLevel() 
	if g_i3k_game_context:GetEquipStrengLevel(partID) == role_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(40))
		return false
	end
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	local _data = i3k_db_streng_equip[strengGroup][g_i3k_game_context:GetEquipStrengLevel(partID) + 1]
	if not _data then
		g_i3k_ui_mgr:PopupTipMessage("您的材料不足")
		return false
	end
	local is_enough = {isOk = true, is_ok1 = true, is_ok2 = true, is_ok3 = true}
	local value = g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_EQUIP_ENERGY)
	if _data then
		if value < _data.energy then
			is_enough.isOk = false
		end
		for i=1,3 do
			local item_id = string.format("item%sID",i)
			local item_count = string.format("item%sCount",i)
			local is_ok = string.format("is_ok%s",i)
			if _data[item_id] ~= 0 then
				local value = g_i3k_game_context:GetCommonItemCanUseCount(_data[item_id])
				if value < _data[item_count] then
					is_enough[is_ok] = false
				end
			end
		end
	end
	if is_enough.isOk and is_enough.is_ok1 and is_enough.is_ok2 and is_enough.is_ok3 then
		return true
	else
		g_i3k_ui_mgr:PopupTipMessage("您的材料不足")
		return false
	end
end

function wnd_equip_streng:updatePartRedPoint()
	local wEquips = g_i3k_game_context:GetWearEquips()
	for i=1, eEquipNumber do
		if wEquips[i] then
			self.wear_equip[i].red_tips:hide()
			if wEquips[i].equip then
				local qh_lv = wEquips[i].eqGrowLvl
				local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(i);
				local breakLvl = wEquips[i].breakLvl
				if g_i3k_game_context:GetLevel() > qh_lv and i3k_db_streng_equip[strengGroup][qh_lv+1] then
					local temp = {is_ok1 = true, is_ok2 = true, is_ok3 = true, is_ok4 = true}
					local breakCfg = i3k_db_streng_equip_break[strengGroup][breakLvl+1]
					local need_item
					if qh_lv == (breakCfg and breakCfg.level or -1) then--如果应该突破了
						need_item = breakCfg.consume
					else
						need_item = self:getNeedItem(qh_lv +1, i)
					end
					for j=1, 4 do
						local is_ok = string.format("is_ok%s",j)
						if need_item[j] and (need_item[j].itemCount or need_item[j].count)> g_i3k_game_context:GetCommonItemCanUseCount(need_item[j].itemId) then
							temp[is_ok] = false
						end
					end
					if temp.is_ok1 and temp.is_ok2 and temp.is_ok3 and temp.is_ok4 then
						self.wear_equip[i].red_tips:show()
					end
				end
			end
		end
	end
end


function wnd_equip_streng:strengTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_StrengTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_StrengTips, 1)
end

function wnd_equip_streng:sxBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.starUpLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(126, i3k_db_common.functionOpen.starUpLvl))
		return
	end
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_StrengEquip)
	g_i3k_logic:OpenEquipStarUpUI()
end

function wnd_equip_streng:xqBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.inlayLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.inlayLvl))
		return
	end
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_StrengEquip)
	g_i3k_logic:OpenEquipGemInlayUI()
end

function wnd_equip_streng:clBtn(sender)
	if not g_i3k_db.i3k_db_get_equip_temper_open() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17410, i3k_db_equip_temper_base.openLevel))
		return
	end
	g_i3k_logic:OpenEquipTemperUI(eUIID_StrengEquip)
end

function wnd_create(layout)
	local wnd = wnd_equip_streng.new()
	wnd:create(layout)
	return wnd
end
