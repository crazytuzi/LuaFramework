----------------------------------------------------
-- 角色信息展示带装备，带展示。如人物面板上的
----------------------------------------------------
MainRoleInfoView = MainRoleInfoView or BaseClass(RoleInfoView)

function MainRoleInfoView:__init()
	self:SetGetEquipData(function(data)
		if data.equip_slot then
			return EquipData.Instance:GetEquipDataBySolt(data.equip_slot)
		elseif data.gf_equip_slot then
			return GodFurnaceData.Instance:GetVirtualEquipData(data.gf_equip_slot)
		end
		return nil
	end)

	self.delay_timer = nil
end

function MainRoleInfoView:__delete()
	if EquipData.Instance and self.change_on_equip then
		EquipData.Instance:RemoveEventListener(self.change_on_equip)
	end
	self.change_on_equip = nil

	if RoleData.Instance and self.role_data_change then
		RoleData.Instance:RemoveEventListener(self.role_data_change)
	end
	self.role_data_change = nil

	if GodFurnaceData.Instance and self.gf_data_change then
		GodFurnaceData.Instance:RemoveEventListener(self.gf_data_change)
	end
	self.gf_data_change = nil

	if BagData.Instance and self.bag_item_change then
		BagData.Instance:RemoveEventListener(self.bag_item_change)
	end
	self.bag_item_change = nil

	if ShenqiData.Instance and self.shenqi_change then
		ShenqiData.Instance:RemoveEventListener(self.shenqi_change)
	end
	self.shenqi_change = nil

	GlobalTimerQuest:CancelQuest(self.delay_timer)
	self.delay_timer = nil

	self.btn_quick_equip = nil
end

function MainRoleInfoView:CreateViewCallBack()
	self.btn_quick_equip = XUI.CreateButton(self.size.width / 2, 142, 0, 0, false, ResPath.GetCommon("btn_103"), "", "", true)
	self.btn_quick_equip:setTitleFontName(COMMON_CONSTS.FONT)
	self.btn_quick_equip:setTitleText("一键换装")
	self.btn_quick_equip:setTitleColor(cc.c3b(250, 230, 191))
	self.btn_quick_equip:setTitleFontSize(20)
	self.btn_quick_equip.remind_eff = RenderUnit.CreateEffect(23, self.btn_quick_equip, 1)
	self.btn_quick_equip.remind_eff:setVisible(false)
	self.btn_quick_equip:setVisible(false)
	self.view:addChild(self.btn_quick_equip, 10)
	XUI.AddClickEventListener(self.btn_quick_equip, BindTool.Bind(self.OnClickQuickEquip, self))

	self:Flush()

	self.change_on_equip = EquipData.Instance:AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	self.role_data_change = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
	self.gf_data_change = GodFurnaceData.Instance:AddEventListener(GodFurnaceData.SLOT_DATA_CHANGE, BindTool.Bind(self.OnGodFuranceDataChange, self))
    self.bag_item_change = BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
    self.shenqi_change = ShenqiData.Instance:AddEventListener(ShenqiData.SHENQI_LEVEL_CHANGE, function ()
    	self.shenqi_cell:Update()
    end)
end

function MainRoleInfoView:OnClickQuickEquip()
	TaskCtrl.SendTriggerTaskEvent(TaskData.CLIENT_TRIGGER_EVENT.ONE_KEY_EQUIP)

	for equip_slot, v in pairs(EquipData.Instance:GetBestEquipList()) do
		if v.best_equip_data and v.now_equip_data ~= v.best_equip_data then
			EquipCtrl.SendFitOutEquip(v.best_equip_data.series, EquipData.GetEquipHandPos(equip_slot))
		end
	end
end

function MainRoleInfoView:SelectCellCallBack(cell)
	if nil == cell:GetData() then
		return
	end

	if nil ~= cell:GetData().equip_slot then
		local best_equip_list = EquipData.Instance:GetBestEquipList()
		local slot = cell:GetData().equip_slot
		local best_equip_info = best_equip_list[slot]
		if best_equip_info.best_equip_data and best_equip_info.now_equip_data ~= best_equip_info.best_equip_data then
			EquipCtrl.SendFitOutEquip(best_equip_info.best_equip_data.series, EquipData.GetEquipHandPos(slot))
			return
		end
	end
	if cell:GetCellData() == nil then
		if cell:GetData().open_view then
			if ViewManager.Instance:CanOpen(cell:GetData().open_view) then
				ViewManager.Instance:OpenViewByDef( cell:GetData().open_view)
			else
				SysMsgCtrl.Instance:FloatingTopRightText(GameCond[cell:GetData().open_view.v_open_cond].Tip or "策划需在cond配置")
			end
		end
	else
		TipCtrl.Instance:OpenItem(cell:GetCellData(), cell:GetData().equip_slot and EquipTip.FROM_BAG_EQUIP or EquipTip.FROM_EQUIP_GODFURANCE)
	end
end

function MainRoleInfoView:OnRoleDataChange(vo)
	if RoleData.IsAppearanceAttrKey(vo.key) then
		self:UpdateApperance()
	end

	if vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		self:Flush()
	end
end

function MainRoleInfoView:OnChangeOneEquip(vo)
	if vo.slot then
		local equip = self:GetNormalEquip(vo.slot)
		if nil ~= equip then
			equip:Flush()
		end
	end

	self:Flush()
end

function MainRoleInfoView:OnGodFuranceDataChange(slot)
	for k, v in pairs(RoleInfoView.EquipPos) do
		if v.gf_equip_slot and v.gf_equip_slot == slot and self.equip_list[k] then
			self.equip_list[k]:Flush()
			return
		end
	end
end

function MainRoleInfoView:Flush()
	if nil ~= self.delay_timer then
		return
	end

	self.delay_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnFlush, self), 0.1)
end

function MainRoleInfoView:OnFlush()
	GlobalTimerQuest:CancelQuest(self.delay_timer)
	self.delay_timer = nil

	self:FlushEquipRemind()
end

function MainRoleInfoView:OnBagItemChange()
	self:Flush()
end

-- 装备提醒
function MainRoleInfoView:FlushEquipRemind()
	if IS_ON_CROSSSERVER then return false end
	local best_equip_list = EquipData.Instance:GetBestEquipList()
	local btn_remind = false
	for equip_slot, v in pairs(best_equip_list) do
		local equip = self:GetNormalEquip(equip_slot)
		local have_best = v.best_equip_data and v.now_equip_data ~= v.best_equip_data
		if nil ~= equip then
			equip:SetRemind(have_best)
		end

		if have_best then
			btn_remind = true
		end
	end

	-- self.btn_quick_equip.remind_eff:setVisible(btn_remind)
	-- self.btn_quick_equip:setVisible(btn_remind)
end

function MainRoleInfoView:GetBtnQuickEquip()
	return self.btn_quick_equip
end
