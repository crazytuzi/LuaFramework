ShenGeBlessView = ShenGeBlessView or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	[1] = -270,
	[2] = -270,
	[3] = -225,
	[4] = -180,
	[5] = -135,
	[6] = -90,
	[10] = -315,
	[11] = -45,
	[12] = 0,
}

function ShenGeBlessView:__init(instance)
	self.count = 0
	self.quality = 0
	self.types = 0
	self.is_click_once = true
	self.is_rolling = false

	self.center_pointer = self:FindObj("CenterPointer")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))

	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickTence, self))
	self:ListenEvent("OpenOverView", BindTool.Bind(self.OpenOverView, self))

	for i = 1, 8 do
		self:ListenEvent("OnClickItem"..i, BindTool.Bind(self.OnClickItem, self, i))
	end

	self.show_time = self:FindVariable("ShowTime")
	self.show_free = self:FindVariable("ShowFree")

	self.show_hight_light_10 = self:FindVariable("ShowHightLight10")
	self.show_hight_light_11 = self:FindVariable("ShowHightLight11")
	self.show_hight_light_12 = self:FindVariable("ShowHightLight12")
	self.show_hight_light_5 = self:FindVariable("ShowHightLight5")
	self.show_hight_light_0 = self:FindVariable("ShowHightLight0")

	self.show_hight_light_1 = self:FindVariable("ShowHightLight1")
	self.show_hight_light_2 = self:FindVariable("ShowHightLight2")
	self.show_hight_light_3 = self:FindVariable("ShowHightLight3")
	self.show_hight_light_4 = self:FindVariable("ShowHightLight4")

	self.hour = self:FindVariable("Hour")
	self.min = self:FindVariable("Min")
	self.sec = self:FindVariable("Sec")

	self.once_cost = self:FindVariable("OnceCost")
	self.tence_cost = self:FindVariable("TenceCost")

	self:Flush()
end

function ShenGeBlessView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ShenGeBlessView:OnClickOnce()
	if self.is_rolling then
		return
	end
	self.is_click_once = true

	self:ResetVariable()
	self:ResetHighLight()

	ShenGeData.Instance:SetBlessAniState(self.play_ani_toggle.isOn)
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 1)
end

--打开符文总览界面
function ShenGeBlessView:OpenOverView()
	ViewManager.Instance:Open(ViewName.ShenGePreview)
end

function ShenGeBlessView:OnClickTence()
	if self.is_rolling then
		return
	end
	self.is_click_once = false

	self:ResetVariable()
	self:ResetHighLight()

	ShenGeData.Instance:SetBlessAniState(self.play_ani_toggle.isOn)
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, 10)

end

function ShenGeBlessView:OnClickItem(index)
	-- local data = ShenGeData.Instance:GetShenGeBlessShowData(index - 1)
	-- ShenGeCtrl.Instance:ShowBlessPropTip(data)
	local item_id_list = {23528, 23501, 23502, 23503, 23511, 23512, 23513, 23527} --写死
	local item_data = ItemData.Instance:GetItemConfig(item_id_list[index])
	if nil == item_data then return end
	TipsCtrl.Instance:OpenItem({item_id = item_data.id})
end

function ShenGeBlessView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then
		self:ResetVariable()
		self:ResetHighLight()

		self:SetButtonData(param1, param3, bag_list)
		self:SetRestTime(param3, param1)

		self:SaveVariable(param2, bag_list)
		self:TrunPointer()

		-- if self.play_ani_toggle.isOn then
		-- 	self:ShowRawardTip()
		-- 	self:ShowHightLight()
		-- end
	end
end

function ShenGeBlessView:OnToggleChange(is_on)
	ShenGeData.Instance:SetBlessAniState(is_on)
end

function ShenGeBlessView:SetBlessCost()
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		self.once_cost:SetValue(0)
		self.tence_cost:SetValue(0)
		return
	end
	self.once_cost:SetValue(other_cfg.one_chou_need_gold)
	self.tence_cost:SetValue(other_cfg.ten_chou_need_gold)
end

function ShenGeBlessView:SetButtonData(use_count, next_free_time)
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		return
	end

	if nil ~= use_count then
		local diff_time = math.floor(next_free_time - TimeCtrl.Instance:GetServerTime())
		self.show_time:SetValue(use_count < other_cfg.free_choujiang_times and diff_time > 0)
		self.show_free:SetValue(use_count < other_cfg.free_choujiang_times)
		return
	end

	local info = ShenGeData.Instance:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO)
	local had_use_time = info and info.param1 or 0
	local free_time = info and info.param3 or 0
	local diff_time = math.floor(free_time - TimeCtrl.Instance:GetServerTime())

	self.show_time:SetValue(had_use_time < other_cfg.free_choujiang_times and diff_time > 0)
	self.show_free:SetValue(had_use_time < other_cfg.free_choujiang_times)
end

function ShenGeBlessView:SetRestTime(time, use_count)
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		return
	end

	local info = ShenGeData.Instance:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_CHOUJIANG_INFO)
	local next_free_time = info and info.param3 or 0
	local had_use_time = info and info.param1 or 0

	local diff_time = math.floor(next_free_time - TimeCtrl.Instance:GetServerTime())

	if had_use_time >= other_cfg.free_choujiang_times then
		return
	end

	if nil ~= use_count and use_count >= other_cfg.free_choujiang_times then
		return
	end

	if nil ~= time then
		diff_time = math.floor(time - TimeCtrl.Instance:GetServerTime())
	end

	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.hour:SetValue(0)
				self.min:SetValue(0)
				self.sec:SetValue(0)
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.show_time:SetValue(false)
				self.show_free:SetValue(true)
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.hour:SetValue(left_hour)
			self.min:SetValue(left_min)
			self.sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function ShenGeBlessView:TrunPointer()
	if self.is_rolling then
		return
	end
	local angle = 0
	if self.types >= 10 then
		angle = POINTER_ANGLE_LIST[self.types] and POINTER_ANGLE_LIST[self.types] or 0
	else
		angle = POINTER_ANGLE_LIST[self.quality + 1]
	end
	self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
	self:ShowHightLight()
	self:ShowRawardTip()
	-- self.is_rolling = true
	-- local time = 0
	-- local tween = self.center_pointer.transform:DORotate(
	-- 	Vector3(0, 0, -360 * 20),
	-- 	20,
	-- 	DG.Tweening.RotateMode.FastBeyond360)
	-- tween:SetEase(DG.Tweening.Ease.OutQuart)
	-- tween:OnUpdate(function ()
	-- 	time = time + UnityEngine.Time.deltaTime
	-- 	if time >= 1 and self.count > 0 then
	-- 		tween:Pause()
	-- 		local angle = 0
	-- 		if self.types >= 10 then
	-- 			angle = POINTER_ANGLE_LIST[self.types] and POINTER_ANGLE_LIST[self.types] or 0
	-- 		else
	-- 			angle = POINTER_ANGLE_LIST[self.quality + 1]
	-- 		end
	-- 		local tween1 = self.center_pointer.transform:DORotate(
	-- 				Vector3(0, 0, -360 * 3 + angle),
	-- 				2,
	-- 				DG.Tweening.RotateMode.FastBeyond360)
	-- 		tween1:OnComplete(function ()
	-- 			self.is_rolling = false
	-- 			self:ShowHightLight()
	-- 			self:ShowRawardTip()
	-- 		end)
	-- 	end
	-- end)
end

function ShenGeBlessView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
	self.types = self.types == 13 and 11 or self.types
	self.types = self.types == 14 and 12 or self.types
end

function ShenGeBlessView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function ShenGeBlessView:ResetHighLight()
	self.show_hight_light_10:SetValue(false)
	self.show_hight_light_11:SetValue(false)
	self.show_hight_light_12:SetValue(false)
	self.show_hight_light_5:SetValue(false)
	self.show_hight_light_0:SetValue(false)

	self.show_hight_light_1:SetValue(false)
	self.show_hight_light_2:SetValue(false)
	self.show_hight_light_3:SetValue(false)
	self.show_hight_light_4:SetValue(false)
end

function ShenGeBlessView:ShowRawardTip()
	if self.is_click_once then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1)
	else
		ShenGeData.Instance:GetIsNoAni(self.play_ani_toggle.isOn)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10)
	end
end

function ShenGeBlessView:ShowHightLight()
	-- local index = self.types or 0
	-- if index >= 10 then
	-- 	self["show_hight_light_"..index]:SetValue(true)
	-- else
	-- 	index = self.quality
	-- 	self["show_hight_light_"..index]:SetValue(true)
	-- end
end

function ShenGeBlessView:OnFlush(param_list)
	self:SetBlessCost()
	self:SetButtonData()
	self:SetRestTime()
	self:ResetHighLight()
end