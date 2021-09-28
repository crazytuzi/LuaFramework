
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_baguaSaleBat = i3k_class("wnd_baguaSaleBat",ui.wnd_base)

local WIDGETS_PLCST	= "ui/widgets/plcst"
local WIDGETS_DJ	= "ui/widgets/dj1"

local RowitemCount = 5
local DEFAULT_COUNT = 25 --默认格子数
local SHOW_TIME = 3 --tips显示时间
local RANK_OFFSET = 1 --品质大于1时表示有词缀

function wnd_baguaSaleBat:ctor()
	self._total = 0
	self._equips = {}  --map
	self._selectItems = {}  --map

	self._isSelectAll = false
	self._isSelectNoAffix = false
end

function wnd_baguaSaleBat:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets
	widgets.sale:onClick(self, self.onSaleButton)
	widgets.select_blue:onClick(self, self.onSelectNoAffix)
	widgets.select_all:onClick(self, self.onSelectAllButton)
end

function wnd_baguaSaleBat:refresh()
	self._total = 0
	self._equips = {}
	self._selectItems = {}

	self._isSelectAll = false
	self._isSelectNoAffix = false

	self:updateGetDesc()
	self:updateLeftScroll()
	self:updateRightScroll()
end

function wnd_baguaSaleBat:updateLeftScroll()
	self.ui.scroll:removeAllChildren()
	self.ui.scroll:setContainerSize(0, 0)

	local equips = g_i3k_game_context:GetBagDiagrams()
	self._equips = equips

	local items = g_i3k_game_context:sortBaguaItems(equips)

	for _, v in ipairs(items) do
		local ui = require(WIDGETS_PLCST)()
		self:updateScrollWidget(ui.vars, v)
		self.ui.scroll:addItem(ui)
	end
	local all_widget = self.ui.scroll:getAllChildren()
	self.ui.no_item:setVisible(all_widget[1] == nil)
end

function wnd_baguaSaleBat:updateScrollWidget(widget, equip)
	widget.select_icon2:hide()

	local id = equip.id
	local part = equip.part
	local rank = g_i3k_db.i3k_db_get_bagua_rank(equip.additionProp) --品质
	local countStr = string.format("词缀数量x%s", #equip.additionProp)
	widget.item_name:setText(string.format("%s %s", g_i3k_db.i3k_db_get_bagua_info(part).name, countStr))
	widget.item_name:setTextColor(g_i3k_get_color_by_rank(rank + 1))
	widget.item_grade:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))
	widget.item_suo:setVisible(id > 0)
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(part).icon))

	local power_desc = g_i3k_make_color_string(string.format("战力:"), g_i3k_get_red_color())
	widget.item_level:setText(power_desc)
	widget.power_value:setText(string.format("%s", g_i3k_game_context:getBaGuaBasePower(equip)))

	widget.suo:hide()
	widget.money:setText(i3k_db_bagua_cfg.baguaEnergy[rank])
	widget.little_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_BAGUA_ENERGY, g_i3k_game_context:IsFemaleRole()))

	widget.rank = rank
	widget.id = id

	widget.select:onClick(self, self.onSelectItem, widget)
	widget.itemTips_btn:onClick(self, self.onSelectLeftEquip, equip)
end

function wnd_baguaSaleBat:onSelectItem(sender, widget)
	local equipId = widget.id
	local rank = widget.rank
	local isVisible = widget.select_icon2:isVisible()

	local equipInfo = self._equips[equipId]

	widget.select_icon2:setVisible(not isVisible)
	if isVisible then
		self:cancleSelectItem(equipId, rank)
	else
		self:addSelectItem(equipId, rank)
	end

	self:updateRightScroll()
	self.ui.diamond_lable:setText(self._total)
end

function wnd_baguaSaleBat:cancleSelectItem(id, rank)
	self._selectItems[id] = nil
	self._total = self._total - i3k_db_bagua_cfg.baguaEnergy[rank]
end

function wnd_baguaSaleBat:addSelectItem(id, rank)
	self._selectItems[id] = self._equips[id]
	self._total = self._total + i3k_db_bagua_cfg.baguaEnergy[rank]
end

function wnd_baguaSaleBat:updateRightScroll()
	self.ui.item_scroll:jumpToListPercent(0)

	local items = g_i3k_game_context:sortBaguaItems(self._selectItems)
	local cellCount = #items < DEFAULT_COUNT and DEFAULT_COUNT or #items
	local allBars = self.ui.item_scroll:addChildWithCount(WIDGETS_DJ, RowitemCount, cellCount)
	for i, v in ipairs(allBars) do
		if items[i] then
			local id = items[i].id
			local rank = g_i3k_db.i3k_db_get_bagua_rank(items[i].additionProp)
			v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))
			v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(items[i].part).icon))
			v.vars.item_count:hide()
			v.vars.suo:setVisible(id > 0)
			v.vars.bt:onClick(self, self.onSelectRightEquip, {is_select = v.vars.is_select, equip = items[i]})

			local curEquip = g_i3k_game_context:getEquipDiagrams()[items[i].part]
			if curEquip then
				local power = g_i3k_game_context:getBaGuaBasePower(items[i])
				local wPower = g_i3k_game_context:getBaGuaBasePower(curEquip)
				v.vars.isUp:show()
				if wPower > power then
					v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				elseif wPower < power then
					v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				else
					v.vars.isUp:hide()
				end
			else
				v.vars.isUp:show()
                v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			end
		else
			v.vars.item_count:hide()
		end
	end
end

--查看左侧装备详情
function wnd_baguaSaleBat:onSelectLeftEquip(sender, data)
	--打开八卦比较面板
	g_i3k_ui_mgr:OpenUI(eUIID_BaguaTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaguaTips, {equip = data, isOut = true})
end

--查看右侧装备详情
function wnd_baguaSaleBat:onSelectRightEquip(sender, data)
	for _, e in ipairs(self.ui.item_scroll:getAllChildren()) do
		e.vars.is_select:hide()
	end
	data.is_select:show()
	--打开八卦比较面板
	g_i3k_ui_mgr:OpenUI(eUIID_BaguaTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaguaTips, {equip = data.equip, isOut = true})
end

--选择无词缀的八卦
function wnd_baguaSaleBat:onSelectNoAffix(sender)
	self._total = 0
	self._selectItems = {}
	self._isSelectNoAffix = not self._isSelectNoAffix

	self._isSelectAll = false

	self.ui.blue_icon:setVisible(self._isSelectNoAffix)
	for _, v in ipairs(self.ui.scroll:getAllChildren()) do
		local isHaveAffix = v.vars.rank > RANK_OFFSET --是否有词缀
		local isSelect = not isHaveAffix and self._isSelectNoAffix
		if isSelect then
			self:addSelectItem(v.vars.id, v.vars.rank)
		end
		v.vars.select_icon2:setVisible(isSelect)
	end

	self:updateRightScroll()
	self.ui.diamond_lable:setText(self._total)
end

--选择所有八卦
function wnd_baguaSaleBat:onSelectAllButton(sender)
	self._total = 0
	self._selectItems = {}
	self._isSelectAll = not self._isSelectAll

	self._isSelectNoAffix = false
	self.ui.blue_icon:hide()

	for _, v in ipairs(self.ui.scroll:getAllChildren()) do
		if self._isSelectAll then
			self:addSelectItem(v.vars.id, v.vars.rank)
		end
		v.vars.select_icon2:setVisible(self._isSelectAll)
	end

	self:updateRightScroll()
	self.ui.diamond_lable:setText(self._total)
end

--一键出售
function wnd_baguaSaleBat:onSaleButton(sender)
	local equips = {}
	local isHaveHighQuality = false
	for _, v in pairs(self._selectItems) do
		if g_i3k_db.i3k_db_get_bagua_rank(v.additionProp) >= i3k_db_bagua_cfg.splitMinRank then
			isHaveHighQuality = true
		end
		equips[v.id] = true
	end
	if next(equips) == nil then
		return
	end

	local getItems = {}
	table.insert(getItems, {id = g_BASE_ITEM_BAGUA_ENERGY, count = self._total})

	if isHaveHighQuality then
		g_i3k_ui_mgr:OpenUI(eUIID_BaguaSplitSure)
		g_i3k_ui_mgr:RefreshUI(eUIID_BaguaSplitSure, equips, getItems)
	else
		i3k_sbean.request_eightdiagram_splite_req(equips, getItems)
	end
end

function wnd_baguaSaleBat:updateGetDesc()
	self.ui.diamond_lable:setText(self._total)
	self.ui.suo:hide()
	self.ui.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_BAGUA_ENERGY, g_i3k_game_context:IsFemaleRole()))

	if self.ui.type_desc:isVisible() then
		local co = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(SHOW_TIME)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BaguaSaleBat, "hideGetDesc")
			g_i3k_coroutine_mgr:StopCoroutine(co)
			co = nil
		end)
	end
end

function wnd_baguaSaleBat:hideGetDesc()
	self.ui.type_desc:hide()
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaSaleBat.new()
	wnd:create(layout, ...)
	return wnd;
end

