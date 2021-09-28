-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------

wnd_steedEquipPropCmp = i3k_class("wnd_steedEquipPropCmp", ui.wnd_base)

local LEFT_VIEW = 2
local RIGHT_VIEW = 1

local compare_icon = {
	174,
	175,
	176,
}

function wnd_steedEquipPropCmp:ctor()
	self._state = { -- 需要将这个table保存到 self 中，否则监听器无法绑定
		[g_STEED_EQUIP_TIPS_EQUIP] = {cmp = false, btns = {{txt = i3k_get_string(1620), sender = wnd_steedEquipPropCmp.putOff}, {txt = i3k_get_string(1623), sender = wnd_steedEquipPropCmp.putOnAllEquip}, } }, -- 在部位上点击, 无对比
		[g_STEED_EQUIP_TIPS_BAG  ] = {cmp = false, btns = {{txt = i3k_get_string(1621), sender = wnd_steedEquipPropCmp.putOn}, {txt = i3k_get_string(1623), sender = wnd_steedEquipPropCmp.putOnAllEquip}, } }, -- 背包内点击，（此部位没装备）无对比形态
		[g_STEED_EQUIP_TIPS_BAG2]  = {cmp = true, btns = {{txt = i3k_get_string(1621), sender = wnd_steedEquipPropCmp.putOn}, {txt = i3k_get_string(1623), sender = wnd_steedEquipPropCmp.putOnAllEquip},} }, -- 背包内点击，此部位已经有别的装备了，有对比
		[g_STEED_EQUIP_TIPS_STOVE] = {cmp = false, btns = {{txt = i3k_get_string(1622), sender = wnd_steedEquipPropCmp.toStove},} }, -- 熔炉界面
		[g_STEED_EQUIP_TIPS_NONE] = {cmp = false, btns = {}} -- 空，没有按钮
 	}
end

function wnd_steedEquipPropCmp:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_steedEquipPropCmp:refresh(equipID, type)
	self._equipID = equipID
	type = type or g_STEED_EQUIP_TIPS_BAG
	local widgets = self._layout.vars
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(equipID)
	local partID = cfg.partID
	local wareEquips = g_i3k_game_context:GetSteedWearEquipsData()
	local curWareEquip = wareEquips[partID]

	self:setCommonArgs(RIGHT_VIEW, equipID) -- 右边必有数据
	if curWareEquip and self._state[type].cmp then -- 如果当前部位有装备
		self:setCommonArgs(LEFT_VIEW, curWareEquip)
		self:setDiffArgs(equipID, curWareEquip)
	else
		widgets.layer2:hide()
		widgets.mark_icon:hide()
	end
	self:setType(type)
end

function wnd_steedEquipPropCmp:setType(type1)
	local cfg = self._state[type1]
	local widgets = self._layout.vars
	local btnCount = 3
	for i = 1, btnCount do
		local btn = widgets["btn"..i]
		local label = widgets["label"..i]
		local btnCfg = cfg.btns[i]
		if btnCfg then
			btn:onClick(self, btnCfg.sender)
			label:setText(btnCfg.txt)
		else
			btn:hide()
		end
	end
end

-- 设置左右两边，相同部分的通用接口
function wnd_steedEquipPropCmp:setCommonArgs(viewID, equipID)
	local widgets = self._layout.vars
	local equipName = widgets["equip_name"..viewID]
	local equipBg = widgets["equip_bg"..viewID]
	local equipIcon = widgets["equip_icon"..viewID]
	local an1 = widgets["an"..viewID.."1"] -- 没有耐久度，所以不用显示
	local an2 = widgets["an"..viewID.."2"]
	local label1 = widgets["role"..viewID] -- 限制文本
	local label2 = widgets["part"..viewID] -- 武器 武器
	local label3 = widgets["type"..viewID] -- 武器 熔炼值
	label1:setText(i3k_get_string(1624))
	label3:setText(g_i3k_db.i3k_db_get_steed_step_name(equipID))
	label2:setText(g_i3k_db.i3k_db_get_steed_equip_part_name(equipID))


	local powerValue = widgets["power_value"..viewID]
	self:setPowerLabel(powerValue, equipID)

	local scroll = widgets["scroll"..viewID]
	local getWay = widgets["get_label"..viewID] -- 获取途径
	-- TODO
	equipName:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	equipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(equipID)))
	equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID))
	getWay:setText(g_i3k_db.i3k_db_get_common_item_source(equipID))


	scroll:removeAllChildren()
	self:scrollAddTitle(scroll, equipID)
	self:scrollAddProp(scroll, equipID)
	self:scrollAddSuit(scroll, equipID)

end

function wnd_steedEquipPropCmp:setPowerLabel(label, equipID)
	local power = g_i3k_db.i3k_db_get_steed_equip_power(equipID)
	label:setText(power)
end

function wnd_steedEquipPropCmp:scrollAddTitle(scroll, equipID)
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local node = require("ui/widgets/qizhanzhuangbeitips2t4")() -- 只有一行文本
	node.vars.desc:setText(i3k_get_string(1625)..cfg.stoveValue)
	node.vars.desc:setTextColor(g_COLOR_VALUE_PURPLE)
	scroll:addItem(node)
end

function wnd_steedEquipPropCmp:scrollAddProp(scroll, equipID)
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local node2 = require("ui/widgets/qizhanzhuangbeitips2t2")() -- 基础属性
	scroll:addItem(node2)

	local props = cfg.props
	-- TODO sort
	for k, v in ipairs(props) do
		local node = require("ui/widgets/qizhanzhuangbeitips2t1")() -- 属性列表
		local id = v.id
		local value = v.count
		local cfg = i3k_db_prop_id[id]
		local icon = g_i3k_db.i3k_db_get_property_icon(id)
		node.vars.desc:setText(cfg.desc)
		node.vars.value:setText(i3k_get_prop_show(id, value))
		scroll:addItem(node)
	end
end

function wnd_steedEquipPropCmp:scrollAddSuit(scroll, equipID)
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local node = require("ui/widgets/qizhanzhuangbeitips2t3")() -- xx套装
	local suitCfg = i3k_db_steed_equip_suit[cfg.suitID]
	node.vars.desc:setText(suitCfg.name)
	node.vars.desc:setTextColor(g_COLOR_VALUE_PURPLE)
	scroll:addItem(node)


	local node2 = require("ui/widgets/qizhanzhuangbeitips2t3")() -- <已激活>
	local allSuit = g_i3k_game_context:GetSteedAllSuitsData()
	local isActive = allSuit[cfg.suitID] -- TODO 根据id来获取套装是否激活
	local text = isActive and i3k_get_string(1626) or i3k_get_string(1627)
	node2.vars.desc:setText(text)
	node2.vars.desc:setTextColor(g_i3k_get_cond_color(isActive))
	scroll:addItem(node2)

	local allParts = g_i3k_db.i3k_db_get_steed_equip_all(equipID)
	for k, v in ipairs(allParts) do
		local node = self:getSuitEquipStatus(v)
		scroll:addItem(node)
	end

	local node = require("ui/widgets/qizhanzhuangbeitips2t3")()
	node.vars.desc:setText(i3k_get_string(1628))
	node.vars.desc:setTextColor(g_COLOR_VALUE_PURPLE)
	scroll:addItem(node)

	local activeProps = suitCfg.props
	-- TODO sort
	for k, v in ipairs(activeProps) do
		local node = require("ui/widgets/qizhanzhuangbeitips2t1")() -- 属性列表
		local id = v.id
		local value = v.count
		local cfg = i3k_db_prop_id[id]
		local icon = g_i3k_db.i3k_db_get_property_icon(id)
		node.vars.desc:setText(cfg.desc)
		node.vars.value:setText(i3k_get_prop_show(id, value))
		scroll:addItem(node)
	end

end

function wnd_steedEquipPropCmp:getSuitEquipStatus(equipID)
	local node = require("ui/widgets/qizhanzhuangbeitips2t3")() -- <已激活>
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local count = g_i3k_game_context:getSteedEquipCount(equipID)
	local countText = count > 0 and i3k_get_string(1629, count)  or i3k_get_string(1630)
	local text = cfg.name .. " " .. countText
	node.vars.desc:setText(text)
	node.vars.desc:setTextColor(g_i3k_get_cond_color(count > 0))
	return node
end



function wnd_steedEquipPropCmp:setDiffArgs(equipID, curWareEquipID)
	local widgets = self._layout.vars
	local power1 = g_i3k_db.i3k_db_get_steed_equip_power(equipID)
	local power2 = g_i3k_db.i3k_db_get_steed_equip_power(curWareEquipID)
	widgets.alreadyWearImg:setVisible(true) -- 已装备
	-- widgets.mark_icon:setVisible(power2 < power1) -- 向上箭头

	if power2 > power1 then
		widgets.mark_icon:setImage(i3k_db_icons[compare_icon[2]].path)
	elseif power2 < power1 then
		widgets.mark_icon:setImage(i3k_db_icons[compare_icon[1]].path)
	elseif power2 == power1 then
		widgets.mark_icon:setImage(i3k_db_icons[compare_icon[3]].path)
	end
end


-----------------------------------------
function wnd_steedEquipPropCmp:putOnAllEquip(sender)
	local equipID = self._equipID
	local cfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(equipID)
	local bestEquip = g_i3k_game_context:getAllSteedEquipPerSuit(cfg.suitID)
	if next(bestEquip) then
		i3k_sbean.dress_steed_equip(bestEquip)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1523))
	end
end

function wnd_steedEquipPropCmp:putOff(sender)
	local equipID = self._equipID
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(equipID)
	local parts = {}
	parts[cfg.partID] = true
	i3k_sbean.takeoff_steed_equip(parts)
end

function wnd_steedEquipPropCmp:putOn(sender)
	local equipID = self._equipID
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(equipID)
	local equips =
	{
		[cfg.partID] = equipID
	}
	i3k_sbean.dress_steed_equip(equips)
end

function wnd_steedEquipPropCmp:toStove(sender)
	local equipID = self._equipID
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(equipID)

	local equips = {}
	equips[equipID] = 1
	local callback = function(ok)
		if ok then
			i3k_sbean.steed_equip_destory(equips)
			g_i3k_ui_mgr:CloseUI(eUIID_steedEquipPropCmp)
		end
	end
	if cfg.rank >= 4 then -- 橙色品质以上
		local msg = i3k_get_string(1631)
		g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
	else
		callback(true)
	end
end


function wnd_create(layout)
	local wnd = wnd_steedEquipPropCmp.new();
		wnd:create(layout);
	return wnd;
end
