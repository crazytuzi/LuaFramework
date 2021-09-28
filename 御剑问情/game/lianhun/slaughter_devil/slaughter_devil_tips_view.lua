SlaughterDevilTipsView = SlaughterDevilTipsView or BaseClass(BaseView)

function SlaughterDevilTipsView:__init()
	self.ui_config = {"uis/views/lianhun_prefab", "SlaughterDevilTipsView"}
end

function SlaughterDevilTipsView:__delete()

end

function SlaughterDevilTipsView:SetDataAndOpen(data)
	self.data = data
	self:Open()
end

function SlaughterDevilTipsView:LoadCallBack()
	self.name = self:FindVariable("name")
	self.cap = self:FindVariable("cap")
	self.reward_text = self:FindVariable("reward_text")
	self.star_num = self:FindVariable("star_num")
	self.show_first_reward = self:FindVariable("show_first_reward")

	self.item_list = self:FindObj("item_list")
	-- for i=1,3 do
	-- 	self.item_list[i] = self:FindObj("item" .. i)
	-- end

	self.item_obj_list = {}

	self:ListenEvent("CloseBtn", BindTool.Bind(self.CloseBtn, self))

	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))
	
	self:ListenEvent("OnClickClear", BindTool.Bind(self.OnClickClear, self))
	
end

function SlaughterDevilTipsView:ReleaseCallBack()
	self.data = nil
	for k, v in pairs(self.item_obj_list) do
		v:DeleteMe()
	end
	self.item_obj_list = nil

	self.name = nil
	self.cap = nil
	self.reward_text = nil
	self.item_list = nil
	self.show_first_reward = nil
	self.star_num = nil
end

function SlaughterDevilTipsView:OpenCallBack()
	if self.data == nil then
		return
	end
	local reward_list = {}
	local flag = self.data.star == 0
	if flag then
		reward_list = self.data.first_pass_reward
	else
		reward_list = self.data.normal_reward_item
	end
	for k,v in pairs(reward_list) do
		local item = ItemCell.New()
		item:SetInstanceParent(self.item_list)
		item:SetData(v)
		table.insert(self.item_obj_list, item)
	end
	self.name:SetValue(self.data.Checkpoint_name)
	self.cap:SetValue(self.data.capability)
	self.star_num:SetValue(self.data.star)
	self.show_first_reward:SetValue(flag)
end

function SlaughterDevilTipsView:CloseCallBack()
	self.data = nil
	for k, v in pairs(self.item_obj_list) do
		v:DeleteMe()
	end
	self.item_obj_list = {}
end

function SlaughterDevilTipsView:OnFlush()

end

function SlaughterDevilTipsView:CloseBtn()
	self:Close()
end

function SlaughterDevilTipsView:OnClickEnter()
	SlaughterDevilCtrl.Instance:SendEnterFb(self.data.chapter, self.data.level)
end

function SlaughterDevilTipsView:OnClickClear()
	SlaughterDevilCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_SAODANG, 0, self.data.chapter, self.data.level)
end