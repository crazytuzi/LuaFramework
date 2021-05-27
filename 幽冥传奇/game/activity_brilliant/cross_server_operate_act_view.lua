
-- 跨服运营活动
CrossServerOperateActView = CrossServerOperateActView or BaseClass(GameBaseView)

function CrossServerOperateActView:__init()
	-- self:SetModal(true)

	self.texture_path_list = {
		"res/xui/activity_brilliant.png",
		"res/xui/cs_opearate_act.png",
		"res/xui/rankinglist.png",
	}
	self.config_tab = {
		{"cs_opearate_act_ui_cfg", 1, {0}},
		{"cs_opearate_act_ui_cfg", 3, {0}},
		{"cs_opearate_act_ui_cfg", 2, {0}},
	}

	self.sub_view_act_id = nil
	self.activity_list = nil
	self.act_sub_view_list = {}
end

function CrossServerOperateActView:__delete()
end

function CrossServerOperateActView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CrossServerOperateActView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.sub_view_act_id and self.act_sub_view_list[self.sub_view_act_id] then
		self.act_sub_view_list[self.sub_view_act_id]:CloseCallback()
	end
	self.sub_view_act_id = nil
end

function CrossServerOperateActView:ReleaseCallBack()
	if nil ~= self.activity_list then
		self.activity_list:DeleteMe()
		self.activity_list = nil
	end

	for k, v in pairs(self.act_sub_view_list) do
		v:DeleteMe()
	end
	self.act_sub_view_list = {}

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end

	self.sub_view_act_id = nil
end

function CrossServerOperateActView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateActivityList()
	end
end

function CrossServerOperateActView:ShowIndexCallBack(index)
	self:SelectActByActId(self.sub_view_act_id)
end

function CrossServerOperateActView:OnFlush(param_list, index)
	self.activity_list:SetDataList(ActivityBrilliantData.Instance:GetCSActModelList())
	self:SelectActByActId(self.sub_view_act_id)
end

function CrossServerOperateActView:CreateActivityList()
	if nil == self.activity_list then
		local ph = self.ph_list.ph_list_view
		self.activity_list = ListView.New()
		self.activity_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, CSOperationActItem, nil, nil, self.ph_list.ph_activity_item)
		self.activity_list:SetItemsInterval(15)
		self.activity_list:SetMargin(30)
		-- self.activity_list:SetJumpDirection(ListView.Top)
		self.activity_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityListCallback, self))
		self.node_t_list.layout_common.node:addChild(self.activity_list:GetView(), 20)
		self.activity_list:SetDataList(ActivityBrilliantData.Instance:GetCSActModelList())
	end
end

function CrossServerOperateActView:SelectActivityListCallback(render)
	if nil ~= render then
		local act_id = render:GetData().act_id
		self:SelectActByActId(act_id)
	end
end

function CrossServerOperateActView:SelectActByActId(act_id)
	if nil == act_id then
		self.activity_list:SelectIndex(1)
		return
	end

	if nil ~= self.sub_view_act_id and act_id == self.sub_view_act_id then
		return
	end

	if nil ~= self.sub_view_act_id then
		self.act_sub_view_list[self.sub_view_act_id]:SwitchIndexView()
	end

	self.sub_view_act_id = act_id
	for k, v in pairs(self.act_sub_view_list) do
		v:SetVisible(false)
	end

	local act_model = ActivityBrilliantData.Instance:GetCSActModel(act_id)
	if nil == self.act_sub_view_list[act_id] then
		if nil ~= act_model and nil ~= act_model.client_cfg.view_class_path then
			local class = require(act_model.client_cfg.view_class_path)
			self.act_sub_view_list[act_id] = class.New(self, self.node_t_list.layout_act_panel.node, act_model)
		else
		end
	else
	end
	self.act_sub_view_list[act_id]:SetVisible(true)
	self.act_sub_view_list[act_id]:ShowIndexView()
end

----------------------------------------------------
-- 跨服运营活动列表CSOperationActItem
----------------------------------------------------
CSOperationActItem = CSOperationActItem or BaseClass(BaseRender)
function CSOperationActItem:__init(list_w, list_h)
	local w, h = 105, 40
	local toggle_normal_node = XUI.CreateImageView(w / 2, h / 2, ResPath.GetCommon("toggle_104_normal"), true)
	local toggle_select_node = XUI.CreateImageView(w / 2, h / 2, ResPath.GetCommon("toggle_104_select"), true)
	self.view:addChild(toggle_normal_node, 10, 10)
	self.view:addChild(toggle_select_node, 10, 11)
	self:FlushToggle()

	local lbl_name = XUI.CreateText(w / 2, h / 2, w, h, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.OLIVE, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	lbl_name:setName("lbl_name")
	self.view:addChild(lbl_name, 20)
	self.view:setContentSize(cc.size(w, list_h))
end

function CSOperationActItem:__delete()
	if self.data:IsValid() then
		self.data:RemoveEventListener(self.remind_event_handle)
	end
	self.data = nil
	self.last_data = nil
end

function CSOperationActItem:OnFlush()
	if nil == self.data then
		return
	else
		if nil == self.last_data or self.data ~= self.last_data then
			if nil ~= self.remind_event_handle and self.data:IsValid() and self.data:HasRemind() then
				self.data:RemoveEventListener(self.remind_event_handle)
			end
			self.remind_event_handle = self.data:AddEventListener("REMIND_CHANGE", BindTool.Bind(self.RefreshRemind, self))
		end

		self.last_data = self.data
	end

	self.view:getChildByName("lbl_name"):setString(self.data.act_name)
	self:RefreshRemind()
end

function CSOperationActItem:CreateSelectEffect()
end

function CSOperationActItem:RefreshRemind()
	self:SetRemind(self.data:GetRemindNum() > 0)
end

function CSOperationActItem:SetRemind(bool)
	if bool and nil == self.remind_img and self.view then
		self.remind_img = XUI.CreateImageView(100, 34, ResPath.GetMainui("remind_flag"), true)
		self.view:addChild(self.remind_img, 999)
	elseif self.remind_img then 
		self.remind_img:setVisible(bool)
	end
end

function CSOperationActItem:FlushToggle()
	self.view:getChildByTag(10):setVisible(not self.is_select)
	self.view:getChildByTag(11):setVisible(self.is_select)
end

function CSOperationActItem:OnSelectChange(is_select)
	self:FlushToggle()
end
