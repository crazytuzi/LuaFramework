-- 国家战事（国旗界面）
GuoQiView = GuoQiView or BaseClass(BaseRender)

GuoQiView.GuoQiModelRes = {
	7028001,
	7029001,
	7030001
}

function GuoQiView:__init()
	GuoQiView.Instance = self
end

function GuoQiView:LoadCallBack(instance)
	self.recharge_item = {}
	self.recharge_itemcell = {}
	self.display = {}
	self.model = {}
	self.model_effect = {}
	self.show_cell = {}
	for i=1,CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self["show_guoqi_icon"..i] = self:FindVariable("Show_GuoQi_Icon"..i)
		self.show_cell[i] = self:FindVariable("Show_Cell"..i)
		self.recharge_item[i] = ItemCell.New()
		self.recharge_item[i]:SetInstanceParent(self:FindObj("Recharge_Item"..i))
		self.recharge_itemcell[i] = ItemCell.New()
		self.recharge_itemcell[i]:SetInstanceParent(self:FindObj("Recharge_ItemCell"..i))
		self.model[i] = RoleModel.New()
		self.display[i] = self:FindObj("Display"..i)
		self.model[i]:SetDisplay(self.display[i].ui3d_display)	

		local bundle, asset = ResPath.GetMonsterModel(GuoQiView.GuoQiModelRes[i])
		self.model[i]:SetMainAsset(bundle, asset)

		self.model_effect[i] = self:FindObj("Model_Effect"..i)

		self:ListenEvent("GuoQiClick"..i,
		BindTool.Bind(self.OnGuoQiClick, self,i))
	end
	self.show_recharge_task = self:FindVariable("show_recharge_task")
	self.show_guoqi_recharge = self:FindVariable("Show_GuoQi_Recharge")
	self.task_time = self:FindVariable("Task_Time")
end

function GuoQiView:__delete()
	if self.recharge_item then
		for k, v in pairs(self.recharge_item) do
			v:DeleteMe()
		end
	end
	if self.recharge_itemcell then
		for k, v in pairs(self.recharge_itemcell) do
			v:DeleteMe()
		end
	end
	if self.model then
		for k, v in pairs(self.model) do
			v:DeleteMe()
		end
	end

	self.recharge_item = {}
	self.recharge_itemcell = {}
	self.model = {}
end

function GuoQiView:CloseCallBack()

end

function GuoQiView:OnFlush()
	self:GuoQiModle()
	self:RechargeTaskData()
end

-- 显示大臣模型和任务面板
function GuoQiView:GuoQiModle()
	local guoqi_info = NationalWarfareData.Instance:GetCampGuoQiActStatus()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local act_camp = NationalWarfareData.Instance:GetCampGuoQi()
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self["show_guoqi_icon"..i]:SetValue(guoqi_info[i].act_status >= 1)
	end

	self:ShowRechargeTask(guoqi_info[1].act_status <= 0 and guoqi_info[2].act_status <= 0 and guoqi_info[3].act_status <= 0)
	self.show_guoqi_recharge:SetValue(guoqi_info[1].act_status >= 1 or guoqi_info[2].act_status >= 1 or guoqi_info[3].act_status >= 1)
end

-- 活动没开启时显示的活动任务面板
function GuoQiView:ShowRechargeTask(Value)
	self.show_recharge_task:SetValue(Value)
end

-- 活动任务面板内容
function GuoQiView:RechargeTaskData()
	local guoqi_other_info = NationalWarfareData.Instance:GetGuoQiOtherInfo()
	for i = 1, #guoqi_other_info[1].show_reward + 1 do
		self.recharge_item[i]:SetData(guoqi_other_info[1].show_reward[i - 1])
		self.recharge_itemcell[i]:SetData(guoqi_other_info[1].show_reward[i - 1])
	end
	for i=1,3 do
		self.show_cell[i]:SetValue(i <= #guoqi_other_info[1].show_reward + 1)
	end
	local task_time = NationalWarfareData.Instance:GetGuoQiTaskTime()
	self.task_time:SetValue(task_time)
end

-- 点击大臣
function GuoQiView:OnGuoQiClick(index)
	local camp_scene_id = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other
	local guoqi_other_info = NationalWarfareData.Instance:GetGuoQiOtherInfo()
	if guoqi_other_info[1].camp_1_flag_monster_id and guoqi_other_info[1].camp_2_flag_monster_id and guoqi_other_info[1].camp_3_flag_monster_id then
		local camp = {}
		for i =1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			camp[i] = Split(guoqi_other_info[1]["camp_" .. i .. "_flag_monster_pos"], ",")
		end
		GuajiCtrl.Instance:MoveToPos(camp_scene_id[1]["scene_id_"..index], camp[index][1], camp[index][2], 1, 1, nil, nil, true)
		ViewManager.Instance:CloseAll(ViewName.NationalWarfare)
	end
end
