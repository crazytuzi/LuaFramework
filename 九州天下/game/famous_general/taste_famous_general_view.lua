TasteFamousGeneralView = TasteFamousGeneralView or BaseClass(BaseView)
function TasteFamousGeneralView:__init()
	self.ui_config = {"uis/views/famousgeneralview", "TasteFamousGeneralView"}
	self.toggle_list = {}
	self:SetMaskBg()
	self.cur_famous_general = 0			
	self.bs_id = 0
end

function TasteFamousGeneralView:LoadCallBack()
	self.famous_general_list = {}
	self.famous_general_model = {}
	self.famous_general_is_show = {}
	self.experience_cfg = {}
	for i = 1, 3 do
		self.famous_general_list[i] = self:FindObj("FamousGeneral" .. i)
		self.famous_general_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i))
		self.famous_general_model[i] = RoleModel.New("famous_general_panel")
		self.famous_general_model[i]:SetDisplay(self:FindObj("Display" .. i).ui3d_display)
	end

	self.is_active = {}
	for i = 1, 3 do
		self.famous_general_is_show[i] = self:FindVariable("IsActive_" .. i)
		self.famous_general_is_show[i]:SetValue(false)
	end

	self.famous_general_name = {}
	for i = 1, 3 do
		self.famous_general_name[i] = self:FindVariable("FamousGeneralName" .. i)
	end
	self.desc_text = self:FindVariable("desc_text")
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("FamousGenerBianShenBtn", BindTool.Bind(self.FamousGenerBianShenBtn, self))
	self:Flush()
	self.famous_general_list[1].toggle.isOn = true
end

function TasteFamousGeneralView:ReleaseCallBack()
	for i = 1, 3 do
		self.famous_general_list[i] = nil
		self.famous_general_is_show[i] = nil
		self.famous_general_name[i] = nil
		self.famous_general_model[i]:DeleteMe()
		self.famous_general_model[i] = nil
	end
	self.famous_general_model = {}
	self.famous_general_list = {}
	self.is_active = {}
	self.famous_general_name = {}
	self.desc_text = nil

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TasteFamousGeneralView:OpenCallBack()
	self:CalTime()
end

function TasteFamousGeneralView:CloseCallBack()	
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TasteFamousGeneralView:OnFlush()
	self.experience_cfg = FamousGeneralData.Instance:GetExperience(self.bs_id)
	if self.experience_cfg == nil then return end
	for i = 1, 3 do
		local famous_data = FamousGeneralData.Instance:GetSingleDataBySeq(self.experience_cfg["model_" .. i])
		if famous_data then
			local bundle, asset = ResPath.GetMingJiangRes(famous_data.image_id)
			self.famous_general_name[i]:SetValue(famous_data.name)
			--local bundle, asset = ResPath.GetMingJiangRes(experience_cfg["model_" .. i])
			self.famous_general_is_show[i]:SetValue(true)
			self.famous_general_model[i]:SetMainAsset(bundle, asset)
		end	
	end
end


function TasteFamousGeneralView:OnToggleChange(index, ison)
	if ison then
		self.cur_famous_general = index						--将位
		self.famous_general_model[index]:SetTrigger("attack10")
	end
end

function TasteFamousGeneralView:SetBianShenID(seq)
	if not seq then return end
	self.bs_id = seq
	self:Open()
end

function TasteFamousGeneralView:FamousGenerBianShenBtn()
	if self.cur_famous_general == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.FamousGeneral.PleseChooseGeneral)
	else
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GRAETE_SOLDIER_REQ_TYPE_BIANSHEN_TRIAL, self.experience_cfg["model_" .. self.cur_famous_general])
		self:Close()
	end 
end

function TasteFamousGeneralView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 20
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:FamousGenerBianShenBtn()
			self.cal_time_quest = nil
		else
			self.desc_text:SetValue(math.floor(timer_cal))
		end
	end, 0)
end