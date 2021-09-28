TianshenGraveInfoView = TianshenGraveInfoView or BaseClass(BaseView)

function TianshenGraveInfoView:__init()
	self.ui_config = {"uis/views/tianshengrave_prefab", "TianShenGraveInfoView"}
end

function TianshenGraveInfoView:__delete()

end

function TianshenGraveInfoView:LoadCallBack()
	self.shrink_button_toggle = self:FindObj("ShrinkButton").toggle
	self.task_parent = self:FindObj("TaskParent")
	self.least_time = self:FindVariable("least_time")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.item_list = {}
	for i = 1, 4 do
		local item = TianshenGraveItem.New(self:FindObj("item" .. i))
		table.insert(self.item_list, item)
	end
end

function TianshenGraveInfoView:ReleaseCallBack()
	self.task_parent = nil
	self.shrink_button_toggle = nil
	self.least_time = nil
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

end

function TianshenGraveInfoView:OpenCallBack()

end

function TianshenGraveInfoView:CloseCallBack()

end

function TianshenGraveInfoView:OnFlush()
	for i,v in ipairs(self.item_list) do
		local data = TianShenGraveData.Instance:GetItemData(i)
		if data == nil then
			print_error(i)
		end
		v:SetData(data)
	end
	local least_time = TianShenGraveData.Instance:GetLeastTimes()
	self.least_time:SetValue(least_time)
end

function TianshenGraveInfoView:SwitchButtonState(enable)
	self.task_parent:SetActive(enable)
end


TianshenGraveItem = TianshenGraveItem or BaseClass(BaseRender)

function TianshenGraveItem:__init()
	self.num = self:FindVariable("num")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
	
end

function TianshenGraveItem:__delete()
	
end

function TianshenGraveItem:SetData(data)
	self.data = data
	self:Flush()
end

function TianshenGraveItem:OnFlush()
	self.num:SetValue(self.data.num)
end

function TianshenGraveItem:OnClick()
	local pos_x, pos_y = TianShenGraveData.Instance:GetMinPos(self.data)
	if pos_x ~= nil and pos_y ~= nil then
		MoveCache.param1 = self.data.gather_id
		MoveCache.end_type = MoveEndType.GatherById
		local scene_id = Scene.Instance:GetSceneId()
		GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y)
	end
end