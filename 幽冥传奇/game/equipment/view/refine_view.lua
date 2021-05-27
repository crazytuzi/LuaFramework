-- require("scripts/game/equip_refine/refine_list_items")

local RefineView = BaseClass(SubView)

function RefineView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {
		{"equipment_ui_cfg", 5, {0}},
	}

end

function RefineView:__delete()
end

function RefineView:LoadCallBack(index, loaded_times)
	self:CreateUI()
	self:RegisterEvent()
	self:FlushEquipListView()
	EventProxy.New(RefineData.Instance, self):AddEventListener(RefineData.LOOK_CHANGE, BindTool.Bind(self.OnFlushLockChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function RefineView:ReleaseCallBack()
	for _, v in pairs(self.delete_list or {}) do
		v:DeleteMe()
	end
	self.delete_list = nil

	self:UnRegisterEvent()
	self.cur_equip_index = nil

	if self.refine_cell_item_list then
		for k, v in pairs(self.refine_cell_item_list) do
			v:DeleteMe()
		end
		self.refine_cell_item_list = {}
	end
end

function RefineView:RegisterEvent()
    self.equip_event_handler = BindTool.Bind(self.OnEquipDataChanged, self)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_event_handler)
	
	self.item_cfg_event_handler = BindTool.Bind(self.OnItemConfigChanged, self)
	ItemData.Instance:NotifyItemConfigCallBack(self.item_cfg_event_handler)

	self.role_data_event_handler = BindTool.Bind(self.OnRoleDataChanged, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event_handler)
end

function RefineView:UnRegisterEvent()

    if self.equip_event_handler then
        EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_event_handler)
        self.equip_event_handler = nil
	end
	
	if self.item_cfg_event_handler then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_cfg_event_handler)
		self.item_cfg_event_handler = nil
	end

	if self.role_data_event_handler then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event_handler)
		self.role_data_event_handler = nil
	end
end

function RefineView:CreateUI()
	self.delete_list = {}
	
	self.refine_cell_item_list = {}
	for i = 1, 10 do
		local cell = self:CreateOneRefineCell(self.ph_list["ph_refine_cell_" .. i])
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind(self.OnSelectRefineEquipItem, self), false)
		self.refine_cell_item_list[i] = cell
	end
	
	-- attr list
	ph = self.ph_list.ph_attr_list
	self.attr_list_view = ListView.New()
	self.attr_list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, RefineView.RefineAttrItem, ListViewGravity.CenterHorizontal, false, self.ph_list.ph_attr_item)
	self.attr_list_view:SetJumpDirection(ListView.Top)
	self.attr_list_view:SetAutoSupply(true)
	self.attr_list_view:SetDataList({})
	self.node_t_list.layout_refine.node:addChild(self.attr_list_view:GetView(), 100)
	table.insert(self.delete_list, self.attr_list_view)
	
	-- target equip
	ph = self.ph_list.ph_target_equip
	self.target_equip_cell = BaseCell.New()
	self.target_equip_cell:SetAnchorPoint(0.5, 0.5)
	self.target_equip_cell:SetPosition(ph.x, ph.y)
	self.target_equip_cell:SetCellBg(ResPath.GetCommon("cell_112"))
	self.node_t_list.layout_refine.node:addChild(self.target_equip_cell:GetView(), 100)
	table.insert(self.delete_list, self.target_equip_cell)
	
	self.node_t_list.btn_refine.node:setTitleFontSize(22)
	self.node_t_list.btn_refine.node:setTitleText(Language.EquipRefine.ShowBtnText[1])
	
	self.lbl_stuff_2 = RichTextUtil.CreateLinkText("", 20, COLOR3B.RED)
	self.lbl_stuff_2:setPosition(490, 105)
	self.node_t_list.layout_refine.node:addChild(self.lbl_stuff_2, 100)
	XUI.AddClickEventListener(self.lbl_stuff_2, BindTool.Bind(self.OnClickStuff, self), true)
    
    XUI.AddClickEventListener(self.node_t_list.btn_refine.node, BindTool.Bind(self.OnClickRefine, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind(self.OnClickTips, self))
end

function RefineView:CreateOneRefineCell(ph)
	if ph == nil then return end
	local cell = RefineView.EquipRefineItemRender.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetPosition(ph.x, ph.y)
	cell:SetUiConfig(ph, true)
	self.node_t_list.layout_refine.node:addChild(cell:GetView(), 300)
	return cell
end

function RefineView:OnFlush(param_list)
	self:FlushEquipListView()
end

function RefineView:OnFlushLockChange()
	self:FlushRefineConsume()
end

function RefineView:FlushRefineConsume()
	local item = self.refine_cell_item_list[self.cur_equip_index]

	local equip = item and item:GetData() and item:GetData().equip

	if not equip then return end

	local _, circle = ItemData.GetItemLevel(equip.item_id)
	
	local index = RefineData.GetCfgIndex(circle)

	if index == 0 then 
		XUI.SetButtonEnabled(self.node_t_list.btn_refine.node, false)
		return
	end

	local cfg = RefineData.GetRefineConsume(index)
	local lock_cfg = RefineData.GetLockConsume(index)
	
	local item_list = self.attr_list_view:GetAllItems()
	local refine_count, lock_count = 0, 0
	for k, v in pairs(item_list) do
		if v:CanRefine() and cfg[k] then
			refine_count = refine_count + cfg[k].count
		end
		if v:IsLock() and lock_cfg[k] then
			lock_count = lock_count + 1
		end
	end

	if lock_count >= #item_list then
		XUI.SetButtonEnabled(self.node_t_list.btn_refine.node, false)
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(cfg[1].id)
	local item_cfg_1 = ItemData.Instance:GetItemConfig(ItemData.GetVirtualItemId(lock_cfg[1].type))
	if not item_cfg or not item_cfg_1 then return end
	
	self.node_t_list.lbl_stuff_1.node:setVisible(lock_count > 0)
	self.node_t_list.rich_have_1.node:setVisible(lock_count > 0)
	local lock_cost = 0
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	if lock_count > 0 then
		lock_cost = lock_cfg[lock_count] and lock_cfg[lock_count].count or 0
		self.node_t_list.lbl_stuff_1.node:setString(string.format(Language.EquipRefine.ShowLabel[3] .. "%s：%d", item_cfg_1.name, lock_cost))
		RichTextUtil.ParseRichText(self.node_t_list.rich_have_1.node, 
			string.format(Language.EquipRefine.ShowRichText[3], gold >= lock_cost and "00ff00" or "ff0000", gold), 20)
	end
	
	self.lbl_stuff_2:setColor(UInt2C3b(item_cfg.color))
	self.lbl_stuff_2:setString(string.format("%sx%d", item_cfg.name, refine_count))
	local num = BagData.Instance:GetItemNumInBagById(cfg[1].id)
	RichTextUtil.ParseRichText(self.node_t_list.rich_have.node, 
		string.format(Language.EquipRefine.ShowRichText[2],  num >= refine_count and "00ff00" or "ff0000", num), 20)
	XUI.SetButtonEnabled(self.node_t_list.btn_refine.node, num >= refine_count and gold >= lock_cost)
end

function RefineView:FlushAttrListView()
	local data = self.refine_cell_item_list[self.cur_equip_index]:GetData()
	local equip = data and data.equip
	if not equip then return end

	local data_list = RefineData.Instance:GetShowAttrDataFromEquip(equip)
	self.attr_list_view:SetDataList(data_list)
end

function RefineView:FlushEquipListView()
	local equip_data = RefineData.Instance:GetShowNormalEquipData()
	for i,v in ipairs(equip_data) do
		if v.equip then
			self.refine_cell_item_list[i]:SetData(v)
		end
		self.refine_cell_item_list[i]:SetRemind(v.remind)
	end
	local cur_index = RefineData.Instance:GetCurSelectIndex()
	if cur_index > 0 then 
		self:OnSelectRefineEquipItem(self.refine_cell_item_list[cur_index])
	end
end

function RefineView:OnSelectRefineEquipItem(cell)
	if nil == cell then return end
	local data = cell and cell:GetData()
    if not data then return end
    
	self.cur_equip_index = cell:GetIndex()
	for k,v in pairs(self.refine_cell_item_list) do
		v:SetSelect(false)
	end
	cell:SetSelect(true)
	self.target_equip_cell:SetData(data.equip)
	self:FlushAttrListView()
	self:FlushRefineConsume()
end

function RefineView:OnEquipDataChanged(msg, change_item_id, change_item_index)
    if msg then
		self:FlushEquipListView()
    else
        if change_item_index >= EquipData.EquipIndex.Weapon and change_item_index <= EquipData.EquipIndex.Shoes then
			self:FlushEquipListView()
		end
    end
end

function RefineView:OnItemConfigChanged(item_cfg_list)
	self:FlushEquipListView()
end

function RefineView:OnBagItemChange(event)
	event.CheckAllItemDataByFunc(function (vo)
		if vo.item_id == 2541 and self.refine_cell_item_list then
			self:FlushRefineConsume()
		end
	end)
end

function RefineView:OnRoleDataChanged(key, value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self:FlushRefineConsume()
	end
end

function RefineView:OnClickRefine()
	local item = self.refine_cell_item_list[self.cur_equip_index]
	local data = item and item:GetData()
	if data and data.equip then
		local item_list = self.attr_list_view:GetAllItems()
		local lock = {0, 0, 0}
		local has_my_skill = {0, 0, 0}
		for k, v in pairs(item_list) do
			lock[k] = v:IsLock() and 1 or 0
			local atrr_data = v:GetData()
			if atrr_data and atrr_data.refine_attr and atrr_data.refine_attr.type == GAME_ATTRIBUTE_TYPE.ADD_SKILL_LEVEL then
				local skill_id = RefineData.GetSkillIdAndLevel(atrr_data.refine_attr.value)
				has_my_skill[k] = SkillData.IsMySkill(skill_id) and 1 or 0
			end
		end

		if (has_my_skill[2] == 1 and lock[2] ~= 1) or (has_my_skill[3] == 1 and lock[3] ~= 1) then
			if self.refine_alert == nil then
				self.refine_alert = Alert.New()
				self.refine_alert:SetLableString(Language.EquipRefine.ShowConfirmText[1])
				table.insert(self.delete_list, self.refine_alert)
			end
			self.refine_alert:SetOkFunc(function()
				RefineCtrl.SendEquipRefineReq(data.equip.series, lock[1], lock[2], lock[3])
			end)
			self.refine_alert:Open()
		else
			RefineCtrl.SendEquipRefineReq(data.equip.series, lock[1], lock[2], lock[3])
		end
	end
end

function RefineView:OnClickStuff()
	TipCtrl.Instance:OpenStuffTip(Language.Equipment.AdvanceStuffGetWay,
	{
		{stuff_way = Language.Equipment.WayTitles[10], open_view = ViewName.Boss},
		{stuff_way = Language.Equipment.WayTitles[3], open_view = ViewName.ChargeEveryDay, is_ignore_funopen = true},
	})
end

function RefineView:OnClickTips()
	DescTip.Instance:SetContent(Language.EquipRefine.TipsContent, Language.EquipRefine.TipsTitle)
end


RefineView.EquipRefineItemRender = BaseClass(BaseRender)
local EquipRefineItemRender = RefineView.EquipRefineItemRender
function EquipRefineItemRender:__init()
	self:AddClickEventListener()
end

function EquipRefineItemRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.stone_lv_text = nil
end

function EquipRefineItemRender:CreateChild()
	BaseRender.CreateChild(self)
	
	local size = self.view:getContentSize()
	self.cell = BaseCell.New()
	self.cell:SetEventEnabled(false)
	self.cell:SetRemind(false, false, BaseCell.SIZE - 20)
	self.view:addChild(self.cell:GetView())
	
	self.stone_lv_text = XUI.CreateText(35, -12, 0, 0, nil, "", nil, 18, COLOR3B.YELLOW)
	self.stone_lv_text:setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.stone_lv_text, 50)
end

function EquipRefineItemRender:SetRemind(vis)
	self.cell:SetRemind(vis)
end

function EquipRefineItemRender:OnFlush()
	if self.data == nil then return end
	self.cell:SetData(self.data.equip)
	self.cell:SetProfIconVisible(false)
	self.cell:SetRightTopNumText(0)
	if self.data.equip then 
		local limit_level, zhuan = ItemData.GetItemLevel(self.data.equip.item_id)
		local equip_level = limit_level .. Language.Common.Ji
		if 0 ~= zhuan then 
			equip_level = zhuan .. Language.Common.Zhuan
		end
		self.stone_lv_text:setString(equip_level)
	end
end


RefineView.RefineAttrItem = BaseClass(BaseRender)
local RefineAttrItem = RefineView.RefineAttrItem

function RefineAttrItem:__init()
end

function RefineAttrItem:__delete()
end

function RefineAttrItem:CreateChild()
    BaseRender.CreateChild(self)

    local ph = self.ph_list.ph_img_lock
    self.btn_lock = XUI.CreateToggleButton(ph.x, ph.y,0,0,false, ResPath.GetCommon("lock_open"), ResPath.GetCommon("lock_close"))
    self.btn_lock:setVisible(false)
    self.view:addChild(self.btn_lock)
    XUI.AddClickEventListener(self.btn_lock, BindTool.Bind(self.OnClickLock, self))

    self.node_tree.rich_attr.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function RefineAttrItem:OnFlush()
    if not self.data then return end

    self.node_tree.img_bg.node:loadTexture(self.data.is_open and ResPath.GetCommon("bg_116") or ResPath.GetCommon("bg_117"))
    if self.data.is_open then
        if not self.data.refine_attr or self.data.refine_attr.type == 0 then
            self.btn_lock:setVisible(false)
            RichTextUtil.ParseRichText(self.node_tree.rich_attr.node, Language.EquipRefine.ShowLabel[1], 20, COLOR3B.WHITE)
        else
            self.btn_lock:setVisible(true)
            if self.data.attr_str then
                local color = RefineData.GetAttrColor(self.data.refine_attr.type, self.data.refine_attr.value, self.data.max_value)
                color = C3b2Str(color)
                RichTextUtil.ParseRichText(self.node_tree.rich_attr.node,
                    string.format(Language.EquipRefine.ShowRichText[1], color, self.data.attr_str.type_str, self.data.attr_str.value_str, self.data.max_value), 
                    20)
            end
        end
    else
        self.btn_lock:setVisible(false)
        RichTextUtil.ParseRichText(self.node_tree.rich_attr.node, string.format(Language.EquipRefine.ShowLabel[2], self.data.open_circle), 20, COLOR3B.GRAY)
    end
	RefineData.Instance:SetConsumeData()
end

function RefineAttrItem:OnClickLock()
	RefineData.Instance:SetConsumeData()
end

function RefineAttrItem:CanRefine()
    return self.data and self.data.is_open
end

function RefineAttrItem:IsLock()
    if not self.btn_lock or not self.btn_lock:isVisible() then
        return false
    else
        return self.btn_lock:isTogglePressed()
    end
end

function RefineAttrItem:CreateSelectEffect()
end

return RefineView