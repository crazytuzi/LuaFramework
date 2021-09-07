-- 国家战事（运镖界面）
YunBiaoView = YunBiaoView or BaseClass(BaseRender)

YunBiaoView.CampPost = {true, false, false, false, false, false, false}

function YunBiaoView:__init()
	
end

function YunBiaoView:__delete()
	if self.model then
		for k, v in pairs(self.model) do
			v:DeleteMe()
		end
	end
	self.model = {}
	if self.camp_role_info_change then
		GlobalEventSystem:UnBind(self.camp_role_info_change)
		self.camp_role_info_change = nil
	end
end

function YunBiaoView:LoadCallBack(instance)
	self.yunbiao_state = self:FindVariable("yunbiao_state")
	self.can_yunbiao = self:FindVariable("can_yunbiao")
	self.show_flag = self:FindVariable("show_flag")
	self.show_yunbiao_info = self:FindVariable("show_yunbiao_info")
	self.start_task_panel = self:FindObj("StartTaskPanel")
	self.is_yunbiao_click = self:FindVariable("IsYunBiaoClick")

	self:ListenEvent("OnClickStartTask", BindTool.Bind(self.OnClickStartTask, self))
	self:ListenEvent("OnBtnYunBiao", BindTool.Bind(self.OnClickYuBiao, self))

	self.camp_role_info_change = GlobalEventSystem:Bind(OtherEventType.CAMP_ROLE_INFO, BindTool.Bind(self.CampRoleInfoChange, self))

	self.display = {}
	self.model = {}
	self.show_mache = {}
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self.show_mache[i] = self:FindVariable("show_mache" .. i)
		self:ListenEvent("OnClickMaChe" .. i, BindTool.Bind(self.OnClickMaChe, self, i))

		self.display[i] = self:FindObj("Display" .. i)
		self.model[i] = RoleModel.New()
		self.model[i]:SetDisplay(self.display[i].ui3d_display)
	end 

	self.reward_cell = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("cell" .. i))
		item:SetData(nil)
		table.insert(self.reward_cell, item)
	end

	self:FlushRewardData()
	self:FlushYunBiaoInfo()
end

function YunBiaoView:CloseCallBack()

end

function YunBiaoView:OnClickStartTask()
	YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
	ViewManager.Instance:Close(ViewName.NationalWarfare)
end

function YunBiaoView:OnClickMaChe(index)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if index == vo.camp then return end
	ViewManager.Instance:Open(ViewName.NationalWarfareYunBiao)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_GET_YUNBIAO_USERS, index)
end

function YunBiaoView:FlushRewardData()
	local item_data = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_list
	for i = 1, 3 do
		if nil == item_data[1].reward_item[i - 1] or nil == next(item_data[1].reward_item[i - 1]) then return end
		self.reward_cell[i]:SetData({item_id = item_data[1].reward_item[i - 1].item_id, num = item_data[1].reward_item[i - 1].num, is_bind = item_data[1].reward_item[i - 1].is_bind})
	end
end

function YunBiaoView:FlushYunBiaoInfo()
	-- self.show_yunbiao_info:SetValue(not YunbiaoData.Instance:GetIsHuShong())
end

function YunBiaoView:OnFlush(param_t)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local color = YunbiaoData.Instance:GetTaskColor()
	for i = 1, 3 do
		if vo.camp == i then
			self.model[i]:SetMainAsset(ResPath.GetMonsterModel(1000000 + color))
		else
			self.model[i]:SetMainAsset(ResPath.GetMonsterModel(1000005))
		end
		self.model[i]:SetRotation(Vector3(0, -90, 0))
		self.model[i]:SetInteger("status", ActionStatus.Run)
	end

	local state = NationalWarfareData.Instance:GetYunBiaoState()
	self.yunbiao_state:SetValue(Language.NationalWarfare.YunBiaoState[state])

	local yunbiao_num = YunbiaoData.Instance:GetHusongRemainTimes()
	self.can_yunbiao:SetValue(yunbiao_num > 0 or (yunbiao_num == 0 and YunbiaoData.Instance:GetIsHuShong()))

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local pos_list = NationalWarfareData.Instance:GetCampObjPos()
	self.start_task_panel.transform.localPosition = Vector3(pos_list[vo.camp].x, pos_list[vo.camp].y + 50, pos_list[vo.camp].z)

	local can_yunbiao = YunbiaoData.Instance:GetIsHuShong()
	self.show_flag:SetValue(can_yunbiao)

	if not ViewManager.Instance:IsOpen(ViewName.NationalWarfareYunBiao) then
		local show_mache_list = NationalWarfareData.Instance:GetYunBiaoMaCheShowList()
		for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			self.show_mache[i]:SetValue(show_mache_list[i])
		end
	end
	self:CampRoleInfoChange()
end

function YunBiaoView:OnClickYuBiao()
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Camp.IsOpenYunBiao, function ()
		CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_YUNBIAO)
	end)
end

function YunBiaoView:CampRoleInfoChange()
	local camp_post = PlayerData.Instance.role_vo.camp_post
	if YunBiaoView.CampPost then
		local day_counter_num = CampData.Instance:GetDayCounterList(2)
		self.is_yunbiao_click:SetValue(YunBiaoView.CampPost[camp_post] and day_counter_num > 0)
	end
end