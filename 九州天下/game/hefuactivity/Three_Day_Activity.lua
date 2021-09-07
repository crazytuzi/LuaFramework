ThreeDayActivity = ThreeDayActivity or BaseClass(BaseRender)

function ThreeDayActivity:__init()

end

function ThreeDayActivity:__delete()
	for i=1,3 do
		if self["reward_item"..i] ~= nil then
			self["reward_item"..i]:DeleteMe()
			self["reward_item"..i] = nil
		end
	end

	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self.gray_button = nil
	self.time_text = nil
	self.describe = nil
	self.describe = nil
	self.btn_text = nil
	self.red_point = nil
	self.display = nil
	self.get_flag = nil
end

function ThreeDayActivity:LoadCallBack()
	self.gray_button = self:FindVariable("Btngray")
	self.time_text = self:FindVariable("TimeText")
	self.describe = self:FindVariable("describe")
	self.btn_text = self:FindVariable("Btntext")
	self.red_point = self:FindVariable("RedPoint")
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("three_day_activity_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self:ListenEvent("GetRewardClick", BindTool.Bind(self.GetRewardClick, self))
	self.get_flag = false
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SANRIKUANGHUAN)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
		self:SetTime(rest_time)
		end)
	self:SetItemDate()
	self:UpAttr()
	self:FlushModel()
end

function ThreeDayActivity:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
end

function ThreeDayActivity:SetCurTyoe(cur_type)

end

function ThreeDayActivity:OnFlush()
	self:UpAttr()
end

function ThreeDayActivity:UpAttr()
	local cur_gold_num = HefuActivityData.Instance:GetThreeDayGoldNum() or 0
	local all_gold_num = HefuActivityData.Instance:GetThreeDayNeedGold()
	local need_gold_num = all_gold_num > cur_gold_num and all_gold_num - cur_gold_num or 0
	self.describe:SetValue(string.format(Language.HefuActivity.ThreeDayText,cur_gold_num,need_gold_num))
	self.get_flag = need_gold_num > 0 and true or false
	local flag = HefuActivityData.Instance:GetThreeDayReward()
	self.btn_text:SetValue(flag and string.format(Language.HefuActivity.BtnText[3]) or 
		need_gold_num > 0 and string.format(Language.HefuActivity.BtnText[1]) or string.format(Language.HefuActivity.BtnText[2]))
	self.gray_button:SetValue(not flag)
	self.red_point:SetValue(HefuActivityData.Instance:ThreeDayRedPoint())
end

function ThreeDayActivity:GetRewardClick()
	if self.get_flag then
		ViewManager.Instance:Open(ViewName.RechargeView)
	else
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SANRIKUANGHUAN)
	end
end

function ThreeDayActivity:SetItemDate()
	local gift_id = HefuActivityData.Instance:GetRewardItem().item_id
	local item_list = ItemData.Instance:GetGiftItemList(gift_id)
	for i=1,3 do
		self["reward_item"..i] = ItemCell.New()
		self["reward_item"..i]:SetInstanceParent(self:FindObj("Itemcell"..i))
		self["reward_item"..i]:SetData(item_list[i])
	end
end

function ThreeDayActivity:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = temp.day >0 and string.format(Language.HefuActivity.RestTime, temp.day, temp.hour, temp.min)
	or string.format(Language.HefuActivity.RestTime2, temp.hour, temp.min , temp.s)
	self.time_text:SetValue(str)
end

function ThreeDayActivity:FlushModel()
	if self.model then
		local bundle, asset = HefuActivityData.Instance:GetModel()
		-- local bundle, asset = ResPath.GetWingModel(8130001)
		print(bundle, asset)
		self.model:SetMainAsset(bundle, asset, function ()
		end)
		self.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
		self.model:SetLayer(1, 1.0)
	end
end