-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-- 骑战装备打造 锻造
-------------------------------------------------------
wnd_steedEquipMake = i3k_class("wnd_steedEquipMake", ui.wnd_base)

local default_select = false -- 默认选中锻造5次
local FIVE_TIMES = 5


function wnd_steedEquipMake:ctor()
	self._part = 0
end

function wnd_steedEquipMake:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.doit:onClick(self, self.onMake)
	widgets.check:onClick(self, self.onCheck)
	widgets.img:setVisible(default_select)
	self._fiveTimes = default_select
	self._itemEnough = true
	self:setDefault()
end

function wnd_steedEquipMake:refresh()
	self:setScrollSelect()
	self:setConsume()
end

function wnd_steedEquipMake:setDefault()
	local stoveCfg = g_i3k_game_context:GetSteedForgeData()
	local args = g_i3k_game_context:getSteedEquipMakeArgs()
	local tab = g_i3k_db.i3k_db_map_to_array2(i3k_db_steed_equip_step)
	for k, v in ipairs(tab) do
		if stoveCfg.lvl >= v.needLevel then
			self._step = v.id
		end
	end
	local tab = g_i3k_db.i3k_db_map_to_array2(i3k_db_steed_equip_quality)
	self._quality = tab[1].id
	local tab = g_i3k_db.i3k_db_map_to_array(i3k_db_steed_equip_part)
	self._part = tab[1].id

	if args then
		self._step = args.step
		self._quality = args.quality
		self._part = args.part
	end
end


-- 设置3个选择的滚动条
function wnd_steedEquipMake:setScrollSelect()
	local widgets = self._layout.vars
	local scroll1 = widgets.scroll1
	local scroll2 = widgets.scroll2
	local scroll3 = widgets.scroll3
	scroll1:removeAllChildren()
	scroll2:removeAllChildren()
	scroll3:removeAllChildren()
	local stoveCfg = g_i3k_game_context:GetSteedForgeData()
	local tab = g_i3k_db.i3k_db_map_to_array2(i3k_db_steed_equip_step)

	for k, v in ipairs(tab) do
		local item = require("ui/widgets/qizhanzhuangbeidzt4")()
		item.vars.name:setText(v.name)
		item.vars.name:setTextColor("fffde8cd")
		if stoveCfg.lvl < v.needLevel then
			item.vars.need:setText(i3k_get_string(1615)..stoveCfg.lvl.."/"..v.needLevel)
			item.vars.btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1616, v.needLevel))
			end)
		else
			item.vars.needRoot:hide()
			item.vars.btn:onClick(self, self.onBtn1, v.id)
		end
		if v.id == self._step then
			item.vars.btn:stateToPressed()
			item.vars.name:setTextColor("ffd04818")
		end
		scroll1:addItem(item)
	end

	local tab = g_i3k_db.i3k_db_map_to_array2(i3k_db_steed_equip_quality)
	for k, v in ipairs(tab) do
		local item = require("ui/widgets/qizhanzhuangbeidzt2")()
		item.vars.btn:onClick(self, self.onBtn2, {id = v.id, index = k})
		item.vars.name:setText(v.name)
		item.vars.name:setTextColor("fffde8cd")
		item.vars.img:setImage(g_i3k_db.i3k_db_get_icon_path(v.imageID))
		if v.id == self._quality then
			item.vars.btn:stateToPressed()
			item.vars.name:setTextColor("ffd04818")
		end
		scroll2:addItem(item)
	end

	local tab = g_i3k_db.i3k_db_map_to_array(i3k_db_steed_equip_part)
	for k, v in ipairs(tab) do
		local item = require("ui/widgets/qizhanzhuangbeidzt1")()
		item.vars.btn:onClick(self, self.onBtn3, {id = v.id, index = k})
		item.vars.name:setText(v.name)
		item.vars.name:setTextColor("fffde8cd")
		if v.id == self._part then
			item.vars.btn:stateToPressed()
			item.vars.name:setTextColor("ffd04818")
		end
		scroll3:addItem(item)
	end
end

function wnd_steedEquipMake:onBtn1(sender, id)
	local scroll = self._layout.vars.scroll1
	self:updateSelectScroll(scroll, id)
	self._step = id
	self:setConsume()
	g_i3k_game_context:setSteedEquipMakeArgs(self._step, self._quality, self._part)
end

function wnd_steedEquipMake:onBtn2(sender, info)
	local scroll = self._layout.vars.scroll2
	self:updateSelectScroll(scroll, info.index)
	self._quality = info.id
	self:setConsume()
	g_i3k_game_context:setSteedEquipMakeArgs(self._step, self._quality, self._part)
end

function wnd_steedEquipMake:onBtn3(sender, info)
	local scroll = self._layout.vars.scroll3
	self:updateSelectScroll(scroll, info.index)
	self._part = info.id
	self:setConsume()
	g_i3k_game_context:setSteedEquipMakeArgs(self._step, self._quality, self._part)
end

function wnd_steedEquipMake:updateSelectScroll(scroll, id)
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if k == id then
			v.vars.btn:stateToPressed()
			v.vars.name:setTextColor("ffd04818")
		else
			v.vars.btn:stateToNormal()
			v.vars.name:setTextColor("fffde8cd")
		end
	end
end

-- 刷新，设置  消耗
function wnd_steedEquipMake:setConsume()
	self._itemEnough = true
	local step, quality = self._step, self._quality
	if not step or not quality then
		return
	end
	local cfg = g_i3k_db.i3k_db_get_steed_equip_duanzao_cfg(step, quality)
	self:setConsumeScroll(cfg.needItems)
	if self._part and self._part ~= 0 then
		self:setExtConsumeScroll(cfg.externItem)
	else
		self:setExtConsumeScroll({})
	end
	local widgets = self._layout.vars
	local times = self._fiveTimes and FIVE_TIMES or 1
	widgets.desc:setText(i3k_get_string(1658, cfg.exp * times))
end

function wnd_steedEquipMake:getScrollItem(id, needCount)
	local item = require("ui/widgets/qizhanzhuangbeidzt3")()
	item.vars.btn:onClick(self, self.onItemTips, id)
	item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
	item.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	item.vars.suo:setVisible(id > 0)
	item.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	item.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	local text = g_i3k_game_context:GetCommonItemCanUseCount(id) .."/".. needCount
	if math.abs(id) == g_BASE_ITEM_COIN then
		text = needCount
	end
	item.vars.item_count:setText(text)
	item.vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(id) >= needCount))
	if g_i3k_game_context:GetCommonItemCanUseCount(id) < needCount then
		self._itemEnough = false
	end
	return item
end

-- 锻造消耗
function wnd_steedEquipMake:setConsumeScroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.consume
	scroll:removeAllChildren()
	local times = self._fiveTimes and FIVE_TIMES or 1
	for k, v in ipairs(list) do
		local item = self:getScrollItem(v.id, v.count * times)
		scroll:addItem(item)
	end
end

-- 额外消耗
function wnd_steedEquipMake:setExtConsumeScroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.extern
	scroll:removeAllChildren()
	local times = self._fiveTimes and FIVE_TIMES or 1
	for k, v in ipairs(list) do
		local item = self:getScrollItem(v.id, v.count * times)
		scroll:addItem(item)
	end
end

function wnd_steedEquipMake:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

-- 锻造5次
function wnd_steedEquipMake:onCheck(sender)
	local widgets = self._layout.vars
	local isVisible = widgets.img:isVisible()
	widgets.img:setVisible(not isVisible)
	self._fiveTimes = not isVisible
	self:setConsume()
end


-- 锻造
function wnd_steedEquipMake:onMake(sender)
	local widgets = self._layout.vars
	local isVisible = widgets.img:isVisible()
	local step = self._step
	local quality = self._quality
	local part = self._part
	local times = isVisible and FIVE_TIMES or 1
	if not step or not quality then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1617))
		return
	end

	if not self._itemEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1618))
		return
	end

	local stoveCfg = g_i3k_game_context:GetSteedForgeData()
	local stoveLevel = stoveCfg.lvl
	local needLevel = i3k_db_steed_equip_step[step].needLevel
	if stoveLevel < needLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1619))
		return
	end

	g_i3k_game_context:setSteedEquipMakeArgs(self._step, self._quality, self._part)
	i3k_sbean.steed_equip_create(step, quality, part, times)
end



function wnd_create(layout)
	local wnd = wnd_steedEquipMake.new();
		wnd:create(layout);
	return wnd;
end
