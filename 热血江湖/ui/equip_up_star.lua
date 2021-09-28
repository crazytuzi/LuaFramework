-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_equip_up_star = i3k_class("wnd_equip_up_star",ui.wnd_profile)

local LAYER_ZBQHT	= "ui/widgets/zbsxt"
local LAYER_ZBQHT2	= "ui/widgets/zbqht2"
local UP_STAR = "ui/widgets/zhuangbeishengxing"
local UP_STAR_MAX = "ui/widgets/zhuangbeishengxingm"
local LAYER_STAR_PROP = "ui/widgets/zhuangbeishengxingt"

--星级等级图标
local starID = 34
local threshold = i3k_db_common.equip.durability.Threshold

function wnd_equip_up_star:ctor()
	self.partID = 0
	self.selectID = 0
	self.widgets = nil
end

function wnd_equip_up_star:configure()
	local widgets = self._layout.vars
	self:initRedPoint(widgets)
	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	
	self:initWearEquipWidget(widgets)
	
	self.qhRedPoint = widgets.strengRedPoint
	self.starRedPoint = widgets.starRedPoint
	self.inlayRedPoint = widgets.inlayRedPoint
	self.temperRedPoint = widgets.temperRedPoint
	
	self.increase_lv = widgets.increase_lv
	widgets.check:onClick(self, self.strengTips)
	
	widgets.qh_bt:stateToNormal()
	widgets.xq_bt:stateToNormal()
	widgets.cl_bt:stateToNormal()
	widgets.sx_bt:stateToPressed()
	widgets.qh_bt:onClick(self, self.qhBtn)
	widgets.weapon_effect:onClick(self, self.showWeaponEffectPanel)
	
	--飞升部分修改
	self:initEquipBtnState(widgets)
	self.new_root = widgets.new_root
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

--初始化穿着装备控件
function wnd_equip_up_star:initWearEquipWidget(widgets)
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

function wnd_equip_up_star:refresh()
	local wEquips = g_i3k_game_context:GetWearEquips()
	if self.partID == 0 then
		self:initShowType(wEquips)
	else
		self:selectEquip(self.partID, wEquips[self.partID].equip.equip_id) --刷新右边信息（购买铜钱）
		if g_i3k_game_context:isFlyEquip(self.partID) then
			self:setEquipBtnType(self.Show_Feisheng)
		end
	end
	--self:setTopBtnWidgets(self._layout.vars)
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updatePageRedPoint(g_i3k_game_context.starRedPoint)
	self:onShowBtn()
end

function wnd_equip_up_star:onShowBtn()
	self._layout.vars.xq_bt:setVisible(false)
	self._layout.vars.cl_bt:setVisible(false)
	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionHide.inlayHideLvl then
		self._layout.vars.xq_bt:setVisible(true)
		self._layout.vars.xq_bt:onClick(self, self.xqBtn)
	end
	if g_i3k_db.i3k_db_get_equip_temper_show() then
		self._layout.vars.cl_bt:setVisible(true)
		self._layout.vars.cl_bt:onClick(self, self.clBtn)
	end
end

function wnd_equip_up_star:selectEquip(partID, equip_id)
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == partID)
	end
	self.selectID = partID
	self:setRightView(equip_id, partID)
end

function wnd_equip_up_star:RemoveRightUI()
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
end

function wnd_equip_up_star:addNewNode(layer)
	self:RemoveRightUI()
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(self.new_root:getContentSize().width, self.new_root:getContentSize().height)
end

function wnd_equip_up_star:playStrengEffect(level)
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		local c_zdsx = old_layer[1].anis.c_zdsx
		local index = self:getPlayEffectPos(old_layer[1], level)
		local tmp_star = string.format("star%s", index)
		local star = old_layer[1].vars[tmp_star]
		local pos = star:getPosition()
		local worldPos = old_layer[1].vars.bao:getParent():convertToNodeSpace(star:getParent():convertToWorldSpace(pos))
		old_layer[1].vars.bao:setPosition(worldPos)
		c_zdsx.play()
	end
end

function wnd_equip_up_star:playFailedEffect(level)
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		local c_shibai = old_layer[1].anis.c_shibai
		c_shibai.play()
	end
end

function wnd_equip_up_star:getPlayEffectPos(_layer, level)
	local star = _layer.vars
	local index = 0
	if level >= 1 and level <= 3 then
		index = level + 3
	elseif level >= 4 and level <= 8 then
		index = level -1
	elseif level >= 9 and level <= 15 then
		index = level - 7
	elseif level >= 16 and level <= 24 then
		index = level - 15
	end
	return index
end


function wnd_equip_up_star:updateWearEquipsData(ctype, level, fightpower, wEquips)
	self:updateProfile(ctype, level, fightpower, wEquips)
	for i=1,eEquipNumber do
		if not g_i3k_game_context:checkEquipFacility(i, g_FACILITY_EQUIP_ENHANCEMENT) then
			self.wear_equip[i].equip_btn:setVisible(false)
			self:showTopBtn(false)
		else
		local equip = wEquips[i].equip
		if equip then
			self.wear_equip[i].equip_btn:onClick(self, self.onSelectEquip, {equip_id = equip.equip_id, partID = i})
			self.wear_equip[i].level_label:setVisible(wEquips[i].eqEvoLvl ~= 0)
			self:updateWearEquipsLevl(i)
		else
			self.wear_equip[i].equip_btn:enable()
			self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
			end
		end
	end
end

function wnd_equip_up_star:updateWearEquipsLevl(partID)
	self.wear_equip[partID].level_label:setVisible(g_i3k_game_context:GetEquipUpStarLevel(partID) ~= 0)
	if g_i3k_game_context:GetEquipUpStarLevel(partID) ~= 0 then
		self.wear_equip[partID].level_label:setText("+"..g_i3k_game_context:GetEquipUpStarLevel(partID))
	end
	self:updatePartRedPoint()
end

function wnd_equip_up_star:onSelectEquip(sender, data)
	if self.selectID == data.partID then
		return
	end
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == data.partID)
	end
	self.selectID = data.partID
	self:setRightView(data.equip_id, data.partID)
end

function wnd_equip_up_star:notwearingEquipTips(sender, data)
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

function wnd_equip_up_star:setRightView(equip_id, partID)
	self.widgets = nil
	
	local _increase_desc = g_i3k_db.i3k_db_get_streng_reward_info_for_type(2)
	local colorStr = _increase_desc[2].count < i3k_db_common.equip.equipPropCount and "[<c=red>" or "[<c=green>"
	self.increase_lv:setText(_increase_desc[2].desc.." 额外奖励属性"..colorStr.._increase_desc[2].count.."/"..i3k_db_common.equip.equipPropCount.."</c>]")
	
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local euqipInfo = wEquips[euqipCfg.partID]
	local equip = euqipInfo.equip
	local star_lv = euqipInfo.eqEvoLvl
	local now_power = g_i3k_game_context:GetBodyEquipPower(equip_id, equip.attribute, equip.naijiu, euqipInfo.eqGrowLvl, star_lv, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)
	local next_power = g_i3k_game_context:GetBodyEquipPower(equip_id, equip.attribute, equip.naijiu, euqipInfo.eqGrowLvl, star_lv+1, euqipInfo.slot,euqipInfo.equip.refine, euqipInfo.equip.legends, euqipInfo.gemBless)

	local max_data = {}
	local temp = {}
	local count = 0
	local group = g_i3k_db.i3k_db_get_equip_upStar_group(partID);
	local isMaxStar = not i3k_db_up_star[group][star_lv +1]
	local widgets
	if not isMaxStar then
		local _layer = require(UP_STAR)()
		self:addNewNode(_layer)
		widgets = _layer.vars
	end

	for k, v in pairs(euqipCfg.properties) do
		if v.type ~= 0 then
			count = count + 1
			local _temp = i3k_db_prop_id[v.type]
			local _desc = _temp.desc
			-- _desc = _desc..":"
			local colour1 = _temp.textColor
			local colour2 = _temp.valuColor
			local lv = 0;
			if star_lv < #i3k_db_up_star[group] then
				lv = star_lv + 1
			else
				lv = star_lv
			end
			local propertyValue2 = self:getPropertyValue(v, lv);
			if isMaxStar then
				if k == 1 then
					max_data = {id = equip_id, lvl = star_lv, colour1 = colour1, colour2 = colour2, power = math.modf(next_power),}
					temp.name = _desc
					temp.value = propertyValue2
				elseif k == 2 then
					if v.rankFactor ~= 0 then
						max_data.name1 = temp.name
						max_data.value1 = temp.value					
						max_data.name2 = _desc
						max_data.value2 = propertyValue2
					else
						max_data.name1 = temp.name
						max_data.value1 = temp.value
					end
				end
			end
			if widgets then
				local layer1 = require(LAYER_ZBQHT)()
				local widget = layer1.vars
				local propertyValue = self:getPropertyValue(v, star_lv)
				widget.label:setText(_desc)
				widget.value:setText(propertyValue)
				
				local layer2 = require(LAYER_ZBQHT)()
				local widget2 = layer2.vars
				widget2.label:setText(_desc)
				widget2.value:setText(propertyValue2)
				if v.rankFactor ~= 0 then
					widgets.scroll1:addItem(layer1)
					widgets.scroll2:addItem(layer2)
				end
			end
		end
	end	
	if isMaxStar then
		self:showMaxStar(max_data,partID)
		return
	end	

	self:setNeedItem(partID, widgets)
	self:setEquipDetail(euqipInfo, equip_id, widgets)

	widgets.qh_equip_score1:setText("战力："..math.modf(now_power))
	widgets.qh_equip_score2:setText("战力："..math.modf(next_power))
	widgets.tips:hide()
	if i3k_db_up_star[group][star_lv].showTips == 1 then
		widgets.tips:show()
		local upCount = wEquips[partID].upCount
		local maxCount = i3k_db_up_star[group][star_lv].succeedSount
		local str = string.format("%s次后必定成功", maxCount - upCount)
		widgets.tips:setText(str)
	end
	local width = widgets.scroll1:getContentSize().width
	local height = widgets.scroll1:getContentSize().height
	local scrollContainerSize = widgets.scroll1:getContainerSize()

	widgets.label:setText("成功率：" .. i3k_db_up_star[group][star_lv].showPresent / 100 .. "%")
	widgets.nScroll:removeAllChildren()
	for _,e in ipairs(i3k_db_upStar_attribute[partID]) do
		local layer = require(LAYER_STAR_PROP)()
		local widget = layer.vars
		widget.pre_name:setText(e.desc)
		if star_lv >= e.needStar then
			widget.pre_name:setTextColor(g_COLOR_VALUE_GREEN)
		else
			widget.pre_name:setTextColor("ff634624")
		end
		widgets.nScroll:addItem(layer)
	end
	widgets.nScroll:stateToNoSlip()
end

function wnd_equip_up_star:getPropertyValue(v, star_lv)
	local percent = 0
	local count = 0
	if v.type and v.type ~= 0 and v.rankFactor == 1 then
		percent = i3k_db_up_star_percent[v.type].upPercent[star_lv + 1]
		count = i3k_db_up_star_percent[v.type].upValue[star_lv + 1]
	end
	percent = math.modf(percent/10000 * 100)
	percent = count == 0 and "+"..percent.."%" or "+"..percent.."%" .. " +" .. count
	return percent
end

function wnd_equip_up_star:setEquipDetail(euqipInfo, equip_id, widgets)
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip_id)
	local star_lvl = euqipInfo.eqEvoLvl
	widgets.star_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(star_lvl+starID))
	widgets.star_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(star_lvl+starID+1))
	--widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	--widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip_id))
	--widgets.qh_equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id))
	--widgets.qh_equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip_id))
	--widgets.qh_equip_name1:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	--widgets.qh_equip_name2:setText(g_i3k_db.i3k_db_get_common_item_name(equip_id))
	--widgets.qh_equip_name1:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
	--widgets.qh_equip_name2:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
end

function wnd_equip_up_star:showMaxStar(data,partID)
	local _layer = require(UP_STAR_MAX)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	
	--widgets.grade_icon9:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(data.id))
	--widgets.equip_icon9:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(data.id))
	--widgets.qh_level9:setText("+"..#i3k_db_up_star)
	--widgets.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(data.id))
	local euqipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(data.id)
	--widgets.equip_name:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
	widgets.lv_icon8:setImage(g_i3k_db.i3k_db_get_icon_path(data.lvl+starID))
	widgets.maxlabel1:setText("战力：")
	widgets.maxlabel2:setText(data.power)
	--widgets.maxlabel1:setTextColor(g_i3k_get_red_color())
	--widgets.maxlabel2:setTextColor(g_i3k_get_red_color())
	widgets.maxlabel3:setText(data.name1)
	--widgets.maxlabel3:setTextColor(data.colour1)
	widgets.maxlabel4:setText(data.value1)
	--widgets.maxlabel4:setTextColor(data.colour2)
	if data.name2 then
		widgets.max_desc4:show()
		widgets.maxlabel5:setText(data.name2)
		widgets.maxlabel6:setText(data.value2)
		--widgets.maxlabel5:setTextColor(data.colour1)
		--widgets.maxlabel6:setTextColor(data.colour2)
	else
		widgets.max_desc4:hide()
	end
	widgets.nScroll:removeAllChildren()
	local group = g_i3k_db.i3k_db_get_equip_upStar_group(partID);
	local star_lv = #i3k_db_up_star[group]
	for _,e in ipairs(i3k_db_upStar_attribute[partID]) do
		local layer = require(LAYER_STAR_PROP)()
		local widget = layer.vars
		widget.pre_name:setText(e.desc)
		if star_lv >= e.needStar then
			widget.pre_name:setTextColor(g_COLOR_VALUE_GREEN)
		else
			widget.pre_name:setTextColor("ff634624")
		end
		widgets.nScroll:addItem(layer)
	end
	widgets.nScroll:stateToNoSlip()
end

function wnd_equip_up_star:setNeedItem(partID, widgets)
	widgets.item_scroll:removeAllChildren()
	self.partID = partID
	self.widgets = widgets
	self:setItemScrollData()
	widgets.increease:onClick(self, self.onUpStarBtn, partID)
	--widgets.autoincrease:onClick(self, self.onAutoUpStarBtn, partID)
end

function wnd_equip_up_star:getNeedItem(lvl, part)
	local partID = self.partID;
	if part then
		partID = part;
	end
	local group = g_i3k_db.i3k_db_get_equip_upStar_group(partID);
	local _data = i3k_db_up_star[group][lvl] or i3k_db_up_star[group][lvl-1]
	local need_item = {}
	for i=1,4 do
		local item_id = string.format("item%sID", i)
		local item_count = string.format("item%sCount", i)
		if _data[item_id] ~= 0 then
			table.insert(need_item, {itemId = _data[item_id], itemCount =  _data[item_count]})
		end
	end
	return need_item
end

function wnd_equip_up_star:setItemScrollData()
	if not self.widgets then
		return
	end
	self.widgets.item_scroll:removeAllChildren()
	local lvl = g_i3k_game_context:GetEquipUpStarLevel(self.partID) + 1
	local use_item = self:getNeedItem(lvl)
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
			widget.item_count:setText(e.itemCount)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId).."/"..e.itemCount)
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId) >= e.itemCount))
		widget.bt:onClick(self, self.onItemTips, e.itemId)
		self.widgets.item_scroll:addItem(_layer)
	end
	self:updatePageRedPoint(g_i3k_game_context.starRedPoint)
	self:updatePartRedPoint()
end

function wnd_equip_up_star:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_equip_up_star:onUpStarBtn(sender, partID)
	if self:isEnough(partID) then
		i3k_sbean.equip_starup(partID, g_i3k_game_context:GetEquipUpStarLevel(partID)+1)
		self:updatePartRedPoint()
	end
end

function wnd_equip_up_star:onAutoUpStarBtn(sender, partID)
	self:autoUpStarMax(partID)
end

function wnd_equip_up_star:autoUpStarMax(partID)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local star_lvl = wEquips[partID].eqEvoLvl
	local old_lv = star_lvl
	local use_item = {}
	local group = g_i3k_db.i3k_db_get_equip_upStar_group(self.partID);
	while i3k_db_up_star[group][old_lv +1] do
		local _data = i3k_db_up_star[group][old_lv+1]
		for i=1, 4 do
			local item_id = string.format("item%sID",i)
			local item_count = string.format("item%sCount",i)
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
			break
		end
		old_lv = old_lv + 1
	end
	
	if old_lv  == star_lvl then
		g_i3k_ui_mgr:PopupTipMessage("您的材料不足")
	else
		i3k_sbean.equip_starup(partID, old_lv)
		self:updatePartRedPoint()
	end
end

function wnd_equip_up_star:isEnough(partID)	
	local group = g_i3k_db.i3k_db_get_equip_upStar_group(partID);
	local _data = i3k_db_up_star[group][g_i3k_game_context:GetEquipUpStarLevel(partID) + 1]
	local is_enough = {is_ok1 = true, is_ok2 = true, is_ok3 = true, is_ok4 = true}
	for i=1,4 do
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
	if is_enough.is_ok1 and is_enough.is_ok2 and is_enough.is_ok3 and is_enough.is_ok4 then
		return true
	else
		g_i3k_ui_mgr:PopupTipMessage("您的材料不足")
		return false
	end
end

function wnd_equip_up_star:updatePartRedPoint()
	local wEquips = g_i3k_game_context:GetWearEquips()
	for i=1, eEquipNumber do
		if wEquips[i] then
			self.wear_equip[i].red_tips:hide()
			if wEquips[i].equip then
				local star_lv = wEquips[i].eqEvoLvl
				if g_i3k_game_context:GetLevel() > star_lv then
					local temp = {is_ok1 = true, is_ok2 = true, is_ok3 = true, is_ok4 = true}
					local need_item = self:getNeedItem(star_lv +1, i)
					for j=1, 4 do
						local is_ok = string.format("is_ok%s",j)
						if need_item[j] and need_item[j].itemCount > g_i3k_game_context:GetCommonItemCanUseCount(need_item[j].itemId) then
							temp[is_ok] = false
						end
					end
					local group = g_i3k_db.i3k_db_get_equip_upStar_group(i);
					if temp.is_ok1 and temp.is_ok2 and temp.is_ok3 and temp.is_ok4 and i3k_db_up_star[group][star_lv+1] then
						self.wear_equip[i].red_tips:show()
					end
				end
			end
		end
	end
end


function wnd_equip_up_star:strengTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_StrengTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_StrengTips, 2)
end

function wnd_equip_up_star:qhBtn(sender)
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_EquipUpStar)
	g_i3k_logic:OpenStrengEquipUI()
end

function wnd_equip_up_star:xqBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.inlayLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.inlayLvl))
		return
	end
	self:RemoveRightUI()
	g_i3k_ui_mgr:CloseUI(eUIID_EquipUpStar)
	g_i3k_logic:OpenEquipGemInlayUI()
end

function wnd_equip_up_star:clBtn(sender)
	if not g_i3k_db.i3k_db_get_equip_temper_open() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17410, i3k_db_equip_temper_base.openLevel))
		return
	end
	g_i3k_logic:OpenEquipTemperUI(eUIID_EquipUpStar)
end

function wnd_equip_up_star:showWeaponEffectPanel(sender)
	local weaponEquip = g_i3k_game_context:getWeaponEquip()
	if not weaponEquip then 
    
    elseif weaponEquip.eqEvoLvl < i3k_db_common.equip.weaponEffectEnterLvl then  
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17167, i3k_db_common.equip.weaponEffectEnterLvl))
	else 
		g_i3k_ui_mgr:OpenUI(eUIID_WeaponEffect)
		g_i3k_ui_mgr:RefreshUI(eUIID_WeaponEffect) 
	end
end 

function wnd_create(layout)
	local wnd = wnd_equip_up_star.new()
	wnd:create(layout)
	return wnd
end
