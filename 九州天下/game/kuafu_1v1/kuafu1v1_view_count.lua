KuaFu1v1ViewCount = KuaFu1v1ViewCount or BaseClass(BaseRender)

function KuaFu1v1ViewCount:__init(instance)
	if instance == nil then
		return
	end

	self.reminding = self:FindVariable("Reminding")
	self.count = self:FindVariable("Count")
	self.show_button = self:FindVariable("ShowButton")
	self.show_button2 = self:FindVariable("ShowButton2")
	self.show_reminding = self:FindVariable("ShowReminding")
	self.num_ten = self:FindVariable("NumTen")
	self.num_pos = self:FindVariable("NumPos")

	self:ListenEvent("GoBack",
		BindTool.Bind(self.GoBack, self))
	self.show_reminding:SetValue(false)
end

function KuaFu1v1ViewCount:__delete()
	self:RemoveCountDown()
	self:RemoveDelayTime()
end

function KuaFu1v1ViewCount:StartCountDown()
	if self.count_down then
		return
	end
	local result, match_end_left_time = KuaFu1v1Data.Instance:GetMatchAck()
	--self.count:SetValue("1")
	local bundle, asset = ResPath.GetKuaFu1v1Image("img_num_0")
	self.num_ten:SetAsset(bundle,asset)
	bundle, asset = ResPath.GetKuaFu1v1Image("img_num_1")
	self.num_pos:SetAsset(bundle, asset)
	self.show_reminding:SetValue(false)
	self.show_button:SetValue(false)
	self.show_button2:SetValue(true)
	self.count_down = CountDown.Instance:AddCountDown(999, 1, function(elapse_time, total_time)  
		--self.count:SetValue(math.ceil(elapse_time))
		local num = math.ceil(elapse_time)
		local bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.floor(num / 10))
		self.num_ten:SetAsset(bundle,asset)
		bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.ceil(num % 10))
		self.num_pos:SetAsset(bundle, asset)
	end)
end

function KuaFu1v1ViewCount:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KuaFu1v1ViewCount:CountDown(callback, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end

	local bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.floor(time / 10))
	if self.num_ten then
		self.num_ten:SetAsset(bundle,asset)
	end

	bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.ceil(time % 10))
	if self.num_pos then
		self.num_pos:SetAsset(bundle, asset)
	end
	--self.count:SetValue(time)
end

function KuaFu1v1ViewCount:MatchFaild()
	self.show_reminding:SetValue(true)
	self.reminding:SetValue(Language.Kuafu1V1.PiPeiFailed)
	self.show_button:SetValue(true)
	self.show_button2:SetValue(false)
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:GoBack() end, 5)
end

function KuaFu1v1ViewCount:MatchSucceed()
	self.show_reminding:SetValue(true)
	self.show_button2:SetValue(false)
	self:RemoveCountDown()
	self.reminding:SetValue(Language.Kuafu1V1.PiPeiSucc)
	--self.count:SetValue(3)
	local num = 3
	local bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.floor(num / 10))
	self.num_ten:SetAsset(bundle,asset)
	bundle, asset = ResPath.GetKuaFu1v1Image("img_num_" .. math.ceil(num % 10))
	self.num_pos:SetAsset(bundle, asset)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, BindTool.Bind(self.EnterCross, self)))
end

function KuaFu1v1ViewCount:EnterCross()
	self:RemoveCountDown()
	self:RemoveDelayTime()
	ViewManager.Instance:Close(ViewName.KuaFu1v1)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_ONEVONE)
end

function KuaFu1v1ViewCount:GoBack()
	self:RemoveDelayTime()
	KuaFu1v1Ctrl.Instance.view:OpenMainView()
end

function KuaFu1v1ViewCount:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "match_result" == k then
			local info = KuaFu1v1Data.Instance:GetMatchResult()
			if not info then return end
			self:RemoveCountDown()
			if info.result == 1 then
				self:MatchFaild()
			else
				self:MatchSucceed(info)
			end
		end
	end
end

function KuaFu1v1ViewCount:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end