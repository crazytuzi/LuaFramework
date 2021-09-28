-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/steedBase");
local RowitemCount = 5
-------------------------------------------------------
wnd_steedStove = i3k_class("wnd_steedStove", ui.wnd_steedBase)

function wnd_steedStove:configure()

	self._chooseStep = 0
	self._chooseRank = 0
	-- 重写父类
	ui.wnd_steedBase.configure(self)

	local widgets = self._layout.vars
	widgets.stoveBtn:stateToPressed(true)

	widgets.stepBtn:onClick(self, function()
		widgets.levelRoot2:setVisible(not widgets.levelRoot2:isVisible())
	end)
	widgets.gradeBtn:onClick(self, function()
		widgets.levelRoot:setVisible(not widgets.levelRoot:isVisible())
	end)
	widgets.makeBtn:onClick(self, self.onMakeBtn) -- 锻造
	widgets.ronglian:onClick(self, self.onRonglian) -- 熔炼
	widgets.ronglian2:onClick(self, self.onRonglian2) -- 批量熔炼
end

function wnd_steedStove:refresh()
	self:setChoseScroll()
	self:updateBagUI()
	self:setBar()
end

function wnd_steedStove:setBar()
	local widgets = self._layout.vars
	local cfg = g_i3k_game_context:GetSteedForgeData()
	local textCfg = g_i3k_db.i3k_db_get_steed_equip_stove_value(cfg.lvl, cfg.exp)
	widgets.expbar:setPercent(textCfg.percent)
	widgets.expbarCount:setText(textCfg.barText)
	widgets.level:setText(i3k_get_string(1642, cfg.lvl))
	local id = g_BASE_ITEM_STEED_EQUIP_SPIRIT
	-- widgets.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local energy = g_i3k_game_context:GetSteedForgeEnergy()
	widgets.itemCount:setText(i3k_get_string(1625) .. energy)
end


function wnd_steedStove:onMakeBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipMake)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipMake)
end

function wnd_steedStove:onRonglian(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipSale)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipSale)
end

function wnd_steedStove:onRonglian2(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipSale2)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipSale2)
end

--设置分组下拉框
function wnd_steedStove:setChoseScroll()
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
		item.vars.name:setText(i3k_db_steed_equip_step[i].name)
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
		item.vars.name:setText(i3k_db_steed_equip_quality[rank].name)
		item.vars.btn:onClick(self, function()
			self:choseSteedRank(rank)
		end)
		widgets.filterScroll:addItem(item)
	end
end

function wnd_steedStove:choseSteedStep(step)
	local widgets = self._layout.vars
	if self._chooseStep == step then
		return
	end

	self._chooseStep = step

	widgets.levelRoot2:setVisible(false)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].name)

	self:updateBagUI()
end

function wnd_steedStove:choseSteedRank(rank)
	local widgets = self._layout.vars
	if self._chooseRank == rank then
		return
	end

	self._chooseRank = rank

	widgets.levelRoot:setVisible(false)
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].name)

	self:updateBagUI()
end
function wnd_steedStove:getChooseStep()
	return self._chooseStep
end

function wnd_steedStove:getChooseRank()
	return self._chooseRank
end

--设置背包信息
function wnd_steedStove:updateBagUI()
	local widgets = self._layout.vars
	local step = self:getChooseStep()
	local rank = self:getChooseRank()

	local equipData = {}
	local equips = g_i3k_game_context:GetSteedBagEquipsData()
	for _, v in ipairs(equips) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(v.id)
		local cfgStep = equipCfg.stepID
		local cfgrank = equipCfg.rank
		if (cfgStep == step or step == 0) and (cfgrank == rank or rank == 0) then
			table.insert(equipData, v)
		end
	end

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
	widgets.noItemTips:setText(i3k_get_string(1522))
	widgets.noItemTips:setVisible(table.nums(equipData) == 0)
end

function wnd_steedStove:onSelectEquip(sender, data)
	if not data.isBag then
		for i, v in ipairs(self.steed_equip) do
			v.is_select:setVisible(i == data.partID)
		end
	end
	--打开装备tips
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, data.equipID, g_STEED_EQUIP_TIPS_STOVE)
end


function wnd_steedStove:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1654))
end

function wnd_create(layout)
	local wnd = wnd_steedStove.new();
		wnd:create(layout);
	return wnd;
end
