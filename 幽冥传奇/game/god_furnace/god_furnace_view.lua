
-- 神炉
GodFurnaceView = GodFurnaceView or BaseClass(BaseView)

function GodFurnaceView:__init()
	self.title_img_path = ResPath.GetWord("word_godfurnace")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.door = DoorModal.New()
	self.door:BindClickActBtnFunc(BindTool.Bind(self.OnClickAck, self))

	self.btn_info = {
		ViewDef.GodFurnace.TheDragon,
		ViewDef.GodFurnace.Shield,
		ViewDef.GodFurnace.GemStone,
		ViewDef.GodFurnace.DragonSpirit,
		--ViewDef.GodFurnace.ShenDing,
	}

	self.remind_list = {}
	for k, v in pairs(self.btn_info) do
		if v.remind_group_name then
			self.remind_list[v.remind_group_name] = k
		end
	end

	self.select_slot = nil
end

function GodFurnaceView:__delete()
end

function GodFurnaceView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.door:Release()
end

function GodFurnaceView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	-- self.tabbar:SetTabbtnTxtOffset(-10, 0)
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, function(index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, true, ResPath.GetCommon("toggle_110"), 25, true)

	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	EventProxy.New(GodFurnaceData.Instance, self):AddEventListener(GodFurnaceData.SLOT_DATA_CHANGE, BindTool.Bind(self.OnSlotDataChange, self))
end

function GodFurnaceView:OpenCallBack()
	self:FlushDoor()
end

function GodFurnaceView:CloseCallBack(is_all)
end

function GodFurnaceView:ShowIndexCallBack(index)
	self:FlushDoor()
	self:FlushBtns()
end

function GodFurnaceView:OnFlush(param_t, index)
	self:FlushDoor()
end

function GodFurnaceView:OnGetUiNode(node_name)
	if node_name == NodeName.GodFurnaceActBtn then
		return self.door:GetActBtnNode(), true
	end

	return GodFurnaceView.super.OnGetUiNode(self, node_name)
end
------------------------------------------------------
function GodFurnaceView:FlushDoor()
	local show_door = false
	self.select_slot = nil
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.select_slot = ViewManager.Instance:GetViewObj(v).select_slot
		end
	end
	if nil ~= self.select_slot
		and (self.select_slot ~= GodFurnaceData.Slot.LeftSpecialRingPos and self.select_slot ~= GodFurnaceData.Slot.RightSpecialRingPos)
		and not GodFurnaceData.Instance:IsActSlot(self.select_slot)
	then
		show_door = true
	end

	self.door:SetVis(show_door, self:GetRootNode())
	if show_door then
		self.door:CloseTheDoor()
	end
end

function GodFurnaceView:OnClickAck()
	if nil ~= self.select_slot then
		GodFurnaceCtrl.SendGodFurnaceUpReq(self.select_slot)
	end
end

function GodFurnaceView:OnSlotDataChange(slot)
	if nil ~= self.select_slot and self.select_slot == slot then
		if 1 == GodFurnaceData.Instance:GetSlotData(self.select_slot).level then
			self.door:OpenTheDoor()
		end
	end
end

function GodFurnaceView:OnGameCondChange(cond_def)
	self:FlushBtns()
end

function GodFurnaceView:OnRemindGroupChange(group_name, num)
	if self.remind_list[group_name] then
		self:FlushBtnRemind(self.remind_list[group_name])
	end
end

function GodFurnaceView:FlushBtns()
	local auto_select_index
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		self:FlushBtnRemind(k)
		local vis = ViewManager.Instance:CanOpen(v)
		self.tabbar:SetToggleVisible(k, vis)
		if nil == auto_select_index and vis then
			auto_select_index = k
		end
	end

	if auto_select_index and not ViewManager.Instance:CanOpen(self.btn_info[self.tabbar:GetCurSelectIndex()]) then
		self.tabbar:SelectIndex(auto_select_index)
	end
end

function GodFurnaceView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		self.tabbar:SetRemindByIndex(index, RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0)
	end
end
