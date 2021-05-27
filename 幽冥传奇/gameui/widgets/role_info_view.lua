----------------------------------------------------
-- 角色信息展示带装备，带展示。如人物面板上的
----------------------------------------------------
RoleInfoView = RoleInfoView or BaseClass()
require("scripts/gameui/widgets/role_info_ui_comment")

function RoleInfoView:__init()
	RoleInfoView.EquipPos = RoleInfoView.EquipPos or {
		{equip_slot = EquipData.EquipSlot.itWeaponPos, cell_col = 1, cell_row = 6, cell_img = {ResPath.EquipImg.WuQi, ResPath.EquipWord.WuQi}},	-- 武器
		{equip_slot = EquipData.EquipSlot.itHelmetPos, cell_col = 6, cell_row = 6, cell_img = {ResPath.EquipImg.TouKui, ResPath.EquipWord.TouKui}},	-- 头盔
		{equip_slot = EquipData.EquipSlot.itDressPos, cell_col = 1, cell_row = 5, cell_img = {ResPath.EquipImg.KuiJia, ResPath.EquipWord.KuiJia}},	-- 衣服
		{equip_slot = EquipData.EquipSlot.itNecklacePos, cell_col = 6, cell_row = 5, cell_img = {ResPath.EquipImg.XiangLian, ResPath.EquipWord.XiangLian}},	-- 项链
		{equip_slot = EquipData.EquipSlot.itLeftBraceletPos, cell_col = 1, cell_row = 4, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯左
		{equip_slot = EquipData.EquipSlot.itRightBraceletPos, cell_col = 6, cell_row = 4, cell_img = {ResPath.EquipImg.ShouZhuo, ResPath.EquipWord.ShouZhuo}},	-- 手镯右
		{equip_slot = EquipData.EquipSlot.itLeftRingPos, cell_col = 1, cell_row = 3, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指左
		{equip_slot = EquipData.EquipSlot.itRightRingPos, cell_col = 6, cell_row = 3, cell_img = {ResPath.EquipImg.JieZhi, ResPath.EquipWord.JieZhi}},	-- 戒指右
		{equip_slot = EquipData.EquipSlot.itGirdlePos, cell_col = 1, cell_row = 2, cell_img = {ResPath.EquipImg.YaoDai, ResPath.EquipWord.YaoDai}},	-- 腰带
		{equip_slot = EquipData.EquipSlot.itShoesPos, cell_col = 6, cell_row = 2, cell_img = {ResPath.EquipImg.XieZi, ResPath.EquipWord.XieZi}},	-- 鞋子
		
		{equip_slot = EquipData.EquipSlot.itSpecialRingLeftPos, cell_col = 2, cell_row = 2, cell_img2 = {ResPath.EquipImg.TeJieLeft, ResPath.EquipWord.TeJieLeft}, cell_bg = ResPath.GetCommon("cell_119"),is_add = true, open_view = ViewDef.SpecialRing},	-- 特戒左
		{equip_slot = EquipData.EquipSlot.itSpecialRingRightPos, cell_col = 5, cell_row = 2, cell_img2 = {ResPath.EquipImg.TeJieRight, ResPath.EquipWord.TeJieRight}, cell_bg = ResPath.GetCommon("cell_119"), is_add = true, open_view = ViewDef.SpecialRing},	-- 特戒右
		{gf_equip_slot = GodFurnaceData.Slot.TheDragonPos, cell_col = 1, cell_row = 1, cell_img2 = {ResPath.EquipImg.LongFu, ResPath.EquipWord.LongFu},cell_bg = ResPath.GetCommon("cell_119")},	-- 龙符
		{gf_equip_slot = GodFurnaceData.Slot.ShieldPos, cell_col = 2, cell_row = 1, cell_img2 = {ResPath.EquipImg.DunPai, ResPath.EquipWord.DunPai},cell_bg = ResPath.GetCommon("cell_119")},	-- 盾牌
		{gf_equip_slot = GodFurnaceData.Slot.GemStonePos, cell_col = 5, cell_row = 1, cell_img2 = {ResPath.EquipImg.BaoShi, ResPath.EquipWord.BaoShi}, cell_bg = ResPath.GetCommon("cell_119")},	-- 宝石
		{gf_equip_slot = GodFurnaceData.Slot.DragonSpiritPos, cell_col = 6, cell_row = 1, cell_img2 = {ResPath.EquipImg.LongHun, ResPath.EquipWord.LongHun}, cell_bg = ResPath.GetCommon("cell_119")},	-- 龙魂
		-- {gf_equip_slot = GodFurnaceData.Slot.DragonSpiritPos, cell_col = 5, cell_row = 3, cell_img2 = {ResPath.EquipImg.LongHun, ResPath.EquipWord.LongHun}},	-- 神器
	}
		
	self.size = cc.size(541, 543)
	self.view = XUI.CreateLayout(0, 0, self.size.width, self.size.height)
	self.is_create = false
	self.equip_list = {}
	self.equip_grid = nil
	self.get_equip_data_func = nil
	self.vo = nil
	self.role_display = nil
	self.role_display_offset_pos = cc.p(0, 0)
	self.special_cell  = nil
end

function RoleInfoView:SetFormView( fromView)
	self.fromView = fromView
end

function RoleInfoView:__delete()
	self.is_create = false
	self.equip_grid = nil
	
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
	
	if nil ~= self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end
	
	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
	end
	self.equip_list = {}
	
	self.mb_hand_cell:DeleteMe()

	if self.special_cell then
		self.special_cell:DeleteMe()
		self.special_cell = nil
	end
	
	self.vo = nil
end

function RoleInfoView:GetView()
	return self.view
end

function RoleInfoView:CreateView()
	self:CreateRoleDisplay()
	self:CreateEquipGrid()
	self:CreateViewCallBack()

	--添加神器组件
	--self.shenqi_cell = self.CreateShenQiCell(self.equip_grid)
	self.mb_hand_cell = self.CreateMBHandCell(self.equip_grid, self.fromView)
	-- print(">>>>>>>>","++++")
	self.is_create = true
	
	return self.view
end

function RoleInfoView:CreateViewCallBack()
end

function RoleInfoView:SetRoleVo(vo)
	if vo == nil then return end
	
	self.vo = vo
	
	self:UpdateApperance()
end

-- 创建人物模型
function RoleInfoView:CreateRoleDisplay()
	self.role_display = RoleDisplay.New(self.view, - 1, false, false, true, true)
	self.role_display:SetPosition(self.size.width / 2 + self.role_display_offset_pos.x, self.size.height / 2  + 30 + self.role_display_offset_pos.y)
	self.role_display:SetScale(0.8)
end

function RoleInfoView:FlushEquipGrid()
	for k, v in pairs(self.equip_list) do
		v:Flush()
	end

	self.mb_hand_cell:Update()
end

function RoleInfoView:CreateEquipGrid()
	local cell_bg = ResPath.GetCommon("cell_100")
	
	local cell_size = RoleInfoView.EquipCell.size
	local col_interval = 10
	local row_interval = -12
	local begin_x = 10
	local begin_y = 10
	
	self.equip_grid = XUI.CreateLayout(self.size.width / 2, 2, 0, 0)
	self.equip_grid:setAnchorPoint(0.5, 0)
	self.view:addChild(self.equip_grid, 99, 99)
	for k, v in pairs(RoleInfoView.EquipPos) do
		local x = (v.cell_col - 1) * (cell_size.width + col_interval)
		local y = (v.cell_row - 1) * (cell_size.height + row_interval)
		
		local equip = RoleInfoView.EquipCell.New()
		equip:SetIsUseStepCalc(true)
		equip:SetPosition(x, y)
		if v.cell_img then
			local bg_ta = ResPath.GetEquipImg(v.cell_img[1])
			local bg_ta2 = ResPath.GetEquipWord(v.cell_img[2])
			equip:SetSkinStyle({bg_ta = bg_ta, bg_ta2 = bg_ta2})
		end
		equip:SetGetEquipDataFunc(BindTool.Bind(self.GetEquipData, self))
		equip:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		equip:SetData(v)
		self.equip_grid:addChild(equip:GetView())
		self.equip_list[k] = equip
	end

	-- if nil == self.special_cell then
	-- 	self.special_cell = SpecailCell.New()
	-- 	local x = 4 * (cell_size.width + col_interval)
	-- 	local y = 12
	-- 	self.special_cell:GetView():setPosition(x,y)
	-- 	self.equip_grid:addChild(self.special_cell:GetView())
	-- 	XUI.AddClickEventListener(self.special_cell:GetView(), BindTool.Bind(self.OpenTips, self))
	-- end
	
	local gird_size = cc.size(6 * cell_size.width +(6 - 1) * col_interval, 6 * cell_size.height +(6 - 1) * row_interval)
	self.equip_grid:setContentSize(gird_size)
end

-- function RoleInfoView:SetValueShow(value, level)
-- 	local virtual_item_id = PrestigeData.Instance:GetCurVirtualItemIdByValue(value)

-- 	if self.special_cell then
-- 		local item_id = 10000
-- 		if virtual_item_id then
-- 			item_id = virtual_item_id
-- 		end
-- 		self.data = {item_id = item_id, num = 1, is_bind = 0}
-- 		self.special_cell:SetData(self.data)
-- 		self.special_cell:MakeGray(virtual_item_id == nil)
-- 		self.cell_callback = virtual_item_id ~= nil and level >= PrestigeSysConfig.OpenLimit.level
-- 		self.special_cell:SetCellBg(ResPath.GetCommon("cell_119"))
-- 	end
-- end

--更新外观变化
function RoleInfoView:UpdateApperance()
	if nil ~= self.role_display then
		self.role_display:SetRoleVo(self.vo)
	end
	local value = self.vo[OBJ_ATTR.ACTOR_PRESTIGE_VALUE]
	local level = self.vo[OBJ_ATTR.CREATURE_LEVEL]
	
	--self:SetValueShow(value, level)
end

function RoleInfoView:OpenTips(  )
	if self.cell_callback  then
		TipCtrl.Instance:OpenItem(self.data, EquipTip.FROM_NORMAL)
	end
end

function RoleInfoView:SetRoleDisplayOffsetPos(pos)
	self.role_display_offset_pos = pos
end

function RoleInfoView:SetGetEquipData(func)
	self.get_equip_data_func = func
end

function RoleInfoView:GetEquipData(slot)
	return self.get_equip_data_func and self.get_equip_data_func(slot)
end

--选择格子
function RoleInfoView:SelectCellCallBack(cell)
	local equip_data = self:GetEquipData(cell:GetData())
	if equip_data then
		equip_data.pro = self.vo[OBJ_ATTR.ACTOR_PROF]
	end
	TipCtrl.Instance:OpenItem(equip_data, EquipTip.FROM_NORMAL)
end

function RoleInfoView:GetNormalEquip(slot)
	for k, v in pairs(RoleInfoView.EquipPos) do
		if v.equip_slot and v.equip_slot == slot then
			return self.equip_list[k]
		end
	end
end

------------------------------------------------------------
-- 展示装备格子
local EquipCell = BaseClass(BaseRender)
RoleInfoView.EquipCell = EquipCell
EquipCell.size = cc.size(80, 92)
function EquipCell:__init()
	self.view:setContentSize(EquipCell.size)
	
	self.cell = BaseCell.New()
	self.cell:SetPosition(EquipCell.size.width / 2, EquipCell.size.height - BaseCell.SIZE / 2)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
	
	self.get_equip_data_func = nil
end

function EquipCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function EquipCell:CreateChild()
	EquipCell.super.CreateChild(self)
	
	self.text = XUI.CreateText(EquipCell.size.width / 2, 0, 100, 16, nil, "", nil, 16, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.text:setAnchorPoint(0.5, 0)
	self.view:addChild(self.text, 10)
end

function EquipCell:OnFlush()
	local equip_data = self.get_equip_data_func and self.get_equip_data_func(self.data)
	self.cell:SetData(equip_data)
	self.cell:MakeGray(false)
	self.cell:SetRightTopNumText("")
	if self.data.cell_bg then
		self.cell:SetCellBg(self.data.cell_bg)
	end
	self.cell:SetAddIconPath(false)
	if nil == equip_data then
		self.text:setString("")

		-- 显示未激活的初级神炉装备
		if self.data.gf_equip_slot then
			local res_info = GodFurnaceData.Instance:GetSlotResInfo(self.data.gf_equip_slot, 1)
			self.cell:SetItemEffect(res_info.eff_res_id,0.35)
			self.cell:MakeGray(true)
			
		elseif self.data.equip_slot == EquipData.EquipSlot.itSpecialRingLeftPos then
			local eff_id = SpecialRingData.Instance:GetSpecialRingEffectId(EquipData.EquipSlot.itSpecialRingLeftPos)
			eff_id = (eff_id == 1 and 90 or eff_id)
			self.cell:SetItemEffect(eff_id,0.35)
			self.cell:MakeGray(true)
		elseif self.data.equip_slot == EquipData.EquipSlot.itSpecialRingRightPos then
			local eff_id = SpecialRingData.Instance:GetSpecialRingEffectId(EquipData.EquipSlot.itSpecialRingRightPos) or 57
			eff_id = (eff_id == 1 and 57 or eff_id)
			self.cell:SetItemEffect(eff_id, 0.35)
			self.cell:MakeGray(true)
		end
		if self.data.is_add then
			self.cell:SetAddIconPath(self.data.is_add)
		end
	else
		local ji, zhuan = ItemData.GetItemLevel(equip_data.item_id)
		local text = ""
		if zhuan > 0 then
			text = zhuan .. Language.Common.Zhuan
		else
			text = ji .. Language.Common.Ji
		end
		--self.text:setString(self.data.equip_slot and text or "")

		-- 强化等级
		if equip_data.strengthen_level and equip_data.strengthen_level > 0 then
			local text = "+" .. equip_data.strengthen_level
			self.cell:SetRightTopNumText(text, COLOR3B.GREEN, true)
		end
	end
end

function EquipCell:SetGetEquipDataFunc(func)
	self.get_equip_data_func = func
end

function EquipCell:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function EquipCell:GetCellData()
	return self.cell:GetData()
end

function EquipCell:SetRemind(...)
	self.cell:SetRemind(...)
end

function EquipCell:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end


SpecailCell = SpecailCell or BaseClass(BaseCell)

function SpecailCell:SetAddClickEventListener()
	-- body
end