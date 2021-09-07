-- 国家战事（大臣界面）
DaChenView = DaChenView or BaseClass(BaseRender)

function DaChenView:__init()
	DaChenView.Instance = self
end

function DaChenView:LoadCallBack(instance)
	self.recharge_item = {}
	self.recharge_itemcell = {}
	self.display = {}
	self.model = {}
	self.model_effect = {}
	self.show_cell = {}
	for i=1,CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self["show_dachen_icon"..i] = self:FindVariable("Show_DaChen_Icon"..i)
		self:ListenEvent("DaChenClick"..i,
		BindTool.Bind(self.OnDaChenClick, self,i))
		self.recharge_item[i] = ItemCell.New()
		self.recharge_item[i]:SetInstanceParent(self:FindObj("Recharge_Item"..i))
		self.recharge_itemcell[i] = ItemCell.New()
		self.recharge_itemcell[i]:SetInstanceParent(self:FindObj("Recharge_ItemCell"..i))
		self.display[i] = self:FindObj("Display"..i)
		self.model[i] = RoleModel.New()
		self.model[i]:SetDisplay(self.display[i].ui3d_display)
		self.model[i]:SetMainAsset(ResPath.GetMonsterModel(2129001))
		self.model_effect[i] = self:FindObj("Model_Effect"..i)
		self.show_cell[i] = self:FindVariable("Show_Cell"..i)
	end
	-- self.model_effect = self:FindObj("Model_Effect")
	self.show_recharge_task = self:FindVariable("Show_Recharge_Task")
	self.show_dachen_recharge = self:FindVariable("Show_DaChen_Recharge")
	self.task_time = self:FindVariable("Task_Time")
	-- self:DaChenModle()
	-- self:RechargeTaskData()
end

function DaChenView:__delete()
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

function DaChenView:CloseCallBack()

end

function DaChenView:OnFlush()
	self:DaChenModle()
	self:RechargeTaskData()
end

-- 显示大臣模型和任务面板
function DaChenView:DaChenModle()
	local dachen_info = NationalWarfareData.Instance:GetCampDachenActStatus()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local act_camp = NationalWarfareData.Instance:GetCampDachen()
	local dachen_other_cfg = NationalWarfareData.Instance:GetDachenOtherInfo()
	for i = 1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self["show_dachen_icon"..i]:SetValue(dachen_info[i].act_status >= 1)
	end

	self:ShowRechargeTask(dachen_info[1].act_status <= 0 and dachen_info[2].act_status <= 0 and dachen_info[3].act_status <= 0)
	self.show_dachen_recharge:SetValue(dachen_info[1].act_status >= 1 or dachen_info[2].act_status >= 1 or dachen_info[3].act_status >= 1)
end

-- 活动没开启时显示的活动任务面板
function DaChenView:ShowRechargeTask(Value)
	self.show_recharge_task:SetValue(Value)
end

-- 活动任务面板内容
function DaChenView:RechargeTaskData()
	local dachen_other_info = NationalWarfareData.Instance:GetDachenOtherInfo()
	for i = 1, #dachen_other_info[1].show_reward + 1 do
		self.recharge_item[i]:SetData(dachen_other_info[1].show_reward[i - 1])
		self.recharge_itemcell[i]:SetData(dachen_other_info[1].show_reward[i - 1])
	end
	for i=1,3 do
		self.show_cell[i]:SetValue(i <= #dachen_other_info[1].show_reward + 1)
	end
	local task_time = NationalWarfareData.Instance:GetDachenTaskTime()
	self.task_time:SetValue(task_time)
end

-- 点击大臣
function DaChenView:OnDaChenClick(index)
	local camp_scene_id = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other
	local dachen_other_info = NationalWarfareData.Instance:GetDachenOtherInfo()
	if dachen_other_info[1].camp_1_dachen_monster_pos and dachen_other_info[1].camp_2_dachen_monster_pos and dachen_other_info[1].camp_3_dachen_monster_pos then
		local camp = {}
		for i =1, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
			camp[i] = Split(dachen_other_info[1]["camp_" .. i .. "_dachen_monster_pos"], ",")
		end
		GuajiCtrl.Instance:MoveToPos(camp_scene_id[1]["scene_id_"..index], camp[index][1], camp[index][2], 1, 1, nil, nil, true)
		ViewManager.Instance:CloseAll(ViewName.NationalWarfare)
	end
end