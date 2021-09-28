-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedEquipSale = i3k_class("wnd_steedEquipSale", ui.wnd_base)

local default_select = false -- 默认选中
local RowitemCount = 5
function wnd_steedEquipSale:ctor()
	self._chooseStep = 0
	self._chooseRank = 0
	self._selectItems = {} -- 选中的装备
	self._check = false  -- 是否选中已激活的套装部件
	self._selectAllFlag = false
end

function wnd_steedEquipSale:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.ronglian:onClick(self, self.onRonglian)
	widgets.select_all:onClick(self, self.onSeleceAll)
	widgets.check:onClick(self, self.onCheck)
	widgets.blue_icon:setVisible(default_select)
	widgets.stepBtn:onClick(self, function()
		widgets.levelRoot2:setVisible(not widgets.levelRoot2:isVisible())
	end)
	widgets.gradeBtn:onClick(self, function()
		widgets.levelRoot:setVisible(not widgets.levelRoot:isVisible())
	end)
	widgets.type_desc:hide()
end

function wnd_steedEquipSale:refresh()
	self:setChoseScroll()
	self:updateBagUI()
	self:setUseItem()
end


--设置分组下拉框
function wnd_steedEquipSale:setChoseScroll()
	local widgets = self._layout.vars
	widgets.filterScroll:removeAllChildren()
	widgets.filterScroll2:removeAllChildren()

	local step = self:getChooseStep()
	local rank = self:getChooseRank()
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].name)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].name)

	--阶位
	for i = 0, #i3k_db_steed_equip_step do
		local item = require("ui/widgets/qizhanzhuangbeit2")()
		item.vars.name:setText(i3k_db_steed_equip_step[i].selectName)
		item.vars.btn:onClick(self, function()
			self:choseSteedStep(i)
		end)
		widgets.filterScroll2:addItem(item)
	end

	--品质
	local rankVector = {}
	for k, v in pairs(i3k_db_steed_equip_quality) do
		table.insert(rankVector, {rank = k, data = v})
	end
	table.sort(rankVector, function(a, b)
		return a.rank < b.rank
	end)

	for _, v in ipairs(rankVector) do
		local item = require("ui/widgets/qizhanzhuangbeit2")()
		local rank = v.rank
		item.vars.name:setText(i3k_db_steed_equip_quality[rank].selectName)
		item.vars.btn:onClick(self, function()
			self:choseSteedRank(rank)
		end)
		widgets.filterScroll:addItem(item)
	end
end

function wnd_steedEquipSale:choseSteedStep(step)
	local widgets = self._layout.vars
	if self._chooseStep == step then
		return
	end
	self._chooseStep = step
	widgets.levelRoot2:setVisible(false)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].selectName)
	-- self:updateBagUI()
	self:clearCheck()
end

function wnd_steedEquipSale:choseSteedRank(rank)
	local widgets = self._layout.vars
	if self._chooseRank == rank then
		return
	end
	self._chooseRank = rank
	widgets.levelRoot:setVisible(false)
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].selectName)
	-- self:updateBagUI()
	self:clearCheck()
end

function wnd_steedEquipSale:getChooseStep()
	return self._chooseStep
end

function wnd_steedEquipSale:getChooseRank()
	return self._chooseRank
end


function wnd_steedEquipSale:updateBagUI()
	local widgets = self._layout.vars
	local step = self:getChooseStep()
	local rank = self:getChooseRank()

	local equipData = {}
	local equips = g_i3k_game_context:GetSteedBagEquipsData()
	local suits = g_i3k_game_context:GetSteedAllSuitsData()

	for _, v in ipairs(equips) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(v.id)
		local cfgStep = equipCfg.stepID
		local cfgrank = equipCfg.rank
		if (cfgStep <= step or step == 0) and (cfgrank <= rank or rank == 0) then
			table.insert(equipData, v)
		end
	end
	local allBars = widgets.scroll2:addChildWithCount("ui/widgets/qizhanzhuangbeiplrlt1", 1, #equipData)
	for i, v in ipairs(allBars) do
		local id = equipData[i].id
		local count = equipData[i].count
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(id)
		local widget = v.vars
		local name = g_i3k_make_color_string(equipCfg.name, g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
		local Xcount = string.format("x%s", count)
		local countStr = g_i3k_make_color_string(Xcount, g_i3k_get_white_color())
		local str = string.format("%s %s", name, countStr)
		widget.item_name:setText(str)
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
		local power = g_i3k_db.i3k_db_get_steed_equip_power(id)
		widget.power_value:setText(power)
		widget.item_suo:setVisible(id > 0)
		widget.money:setText(equipCfg.stoveValue)
		widget.item_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.suo:setVisible(false)
		local RONG_LIAN_ZHI = g_BASE_ITEM_STEED_EQUIP_SPIRIT -- TODO 设置熔炼值的图标
		widget.little_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(RONG_LIAN_ZHI))
		widget.itemTips_btn:onClick(self, self.onSelectEquip, {partID = equipCfg.partID, equipID = id, isBag = true})
		widget.id = id
		widget.count = count
		widget.isCanSelect = true -- true为未选中
		widget.select_icon2:hide()
		widget.select:onClick(self, self.isSelectItem, widget)
		if self._check and suits[equipCfg.suitID] then -- 已经激活了
			widget.select_icon2:show()
			self:addSelectItems({id = widget.id, count = widget.count})
			widget.isCanSelect = false
		end
	end
	widgets.noItemTips:setText(i3k_get_string(1522))
	widgets.noItemTips:setVisible(table.nums(equipData) == 0)
end

function wnd_steedEquipSale:isSelectItem(sender, widget)
	local weights = self._layout.vars
	widget.select_icon2:setVisible(widget.isCanSelect)
	widget.isCanSelect = not widget.isCanSelect
	self:handleSelectItem(not widget.isCanSelect, {id = widget.id, count = widget.count})
end

function wnd_steedEquipSale:getSelectItems()
	return self._selectItems -- {id = , count = }
end
-- 封装的艺术
function wnd_steedEquipSale:handleSelectItem(isAdd, data)
	if isAdd then
		self:addSelectItems(data)
	else
		self:removeSelectItem(data)
	end
	self:updateSelectUI() -- 这里只调用一次
end

function wnd_steedEquipSale:addSelectItems(data)
	table.insert(self._selectItems, data)
end
function wnd_steedEquipSale:removeSelectItem(data)
	local index = nil
	for k, v in ipairs(self._selectItems) do
		if v.id == data.id then
			index = k
		end
	end
	table.remove(self._selectItems, index)
end

function wnd_steedEquipSale:clearSelectItem()
	self._selectItems = {}
	self:updateSelectUI()
end

function wnd_steedEquipSale:onSeleceAll(sender)
	local widgets = self._layout.vars
	if self._check then
		self:clearSelectItem()
		widgets.blue_icon:setVisible(false)
		self._check = false
		self:updateBagUI()
	end

	local children = widgets.scroll2:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.select_icon2:setVisible(not self._selectAllFlag)
		v.vars.isCanSelect = self._selectAllFlag
		if not self._selectAllFlag then
			self:addSelectItems({id = v.vars.id, count = v.vars.count})
		end
	end

	if self._selectAllFlag then
		self:clearSelectItem()
	end
	self:updateSelectUI()
	self._selectAllFlag = not self._selectAllFlag
end

--设置右侧选中的道具信息
function wnd_steedEquipSale:updateSelectUI()
	self:setUseItem()
	local widgets = self._layout.vars
	local step = self:getChooseStep()
	local rank = self:getChooseRank()

	local equipData = {}
	local equips = self:getSelectItems()
	for _, v in ipairs(equips) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(v.id)
		local cfgStep = equipCfg.stepID
		local cfgrank = equipCfg.rank
		if (cfgStep <= step or step == 0) and (cfgrank <= rank or rank == 0) then
			table.insert(equipData, v)
		end
	end
	widgets.scroll:removeAllChildren()
	local allBars = widgets.scroll:addChildWithCount("ui/widgets/qizhanzhuangbeit1", RowitemCount, #equipData)
	for i, v in ipairs(allBars) do
		local id = equipData[i].id
		local count = equipData[i].count
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(id)

		v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		v.vars.item_count:setText(count)
		v.vars.suo:setVisible(id > 0)
		v.vars.bt:onClick(self, self.onSelectEquip, {partID = equipCfg.partID, equipID = id, isBag = true})
		v.vars.is_show:setVisible(false)

		local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
		local equipID = wEquip[equipCfg.partID]
		if equipID then
			local power = math.modf(g_i3k_game_context:GetOneSteedEquipPower(id))
			local wPower = math.modf(g_i3k_game_context:GetOneSteedEquipPower(equipID))
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
	end
end

function wnd_steedEquipSale:onSelectEquip(sender, data)
	if not data.isBag then
		for i, v in ipairs(self.steed_equip) do
			v.is_select:setVisible(i == data.partID)
		end
	end
	--打开装备tips
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, data.equipID )
end

function wnd_steedEquipSale:getSelectEquipRonglianValue()
	local list = self:getSelectItems()
	local value = 0
	for k, v in ipairs(list) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(v.id)
		value = value + equipCfg.stoveValue * v.count
	end
	return value
end

function wnd_steedEquipSale:setUseItem()
	local widgets = self._layout.vars
	local id = g_BASE_ITEM_STEED_EQUIP_SPIRIT
	widgets.diamond_lable:setText(self:getSelectEquipRonglianValue())
	widgets.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.suo:setVisible(false)
	widgets.get_desc:setText(i3k_get_string(1633))
	widgets.ingotRoot:onTouchEvent(self, self.onTipsRoot)
end

function wnd_steedEquipSale:onTipsRoot(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		local widgets = self._layout.vars
		widgets.type_desc:show()
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			local widgets = self._layout.vars
			widgets.type_desc:hide()
		end
	end
end

function wnd_steedEquipSale:onRonglian(sender)
	local list = self:getSelectItems()
	local equips = {}
	for k, v in ipairs(list) do
		equips[v.id] = v.count
	end
	i3k_sbean.steed_equip_destory(equips)
end

function wnd_steedEquipSale:clearCheck()
	local widgets = self._layout.vars
	widgets.blue_icon:setVisible(false)
	self._check = false
	self:updateBagUI()
	self:clearSelectItem()
end

-- 选择已激活的套件
function wnd_steedEquipSale:onCheck(sender)
	local widgets = self._layout.vars
	local curIsVisible = widgets.blue_icon:isVisible()
	widgets.blue_icon:setVisible(not curIsVisible)

	self._check = not curIsVisible
	if curIsVisible then
		self:clearCheck()
	else
		self._selectAllFlag = not self._selectAllFlag
		self:clearSelectItem()
	end

	self:updateBagUI()
	-- 选中
	self:updateSelectUI()

end


function wnd_create(layout)
	local wnd = wnd_steedEquipSale.new();
		wnd:create(layout);
	return wnd;
end
