TipsDoubleHitView = TipsDoubleHitView or BaseClass(BaseView)

function TipsDoubleHitView:__init()
	self.ui_config = {"uis/views/tips/doublehittips_prefab", "DoubleHitTips"}
	self.view_layer = UiLayer.MainUI

	self.kill_count = 0
	self.invalid_timestamp = 0
	self.close_timer = nil
	self.trigger_continue_kill_interval_max = ConfigManager.Instance:GetAutoConfig("role_auto").common_cfg[1].trigger_continue_kill_interval_max
end

function TipsDoubleHitView:__delete()
	if self.close_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.close_timer)
		self.close_timer = nil
	end
end

function TipsDoubleHitView:LoadCallBack()
	self.flag = false

	self.num_list = {}
	self.old_num_list = {}
	self.num_obj_list = {}
	for i=1,5 do
		self.num_list[i] = self:FindVariable("num_" .. i)
		self.num_obj_list[i] = self:FindObj("num_obj_" .. i)
		self.num_obj_list[i].transform:SetLocalScale(1, 1, 1)
	end
	self.hit_progress = self:FindVariable("HitProgress")
	self.show_effect_1 = self:FindVariable("ShowEffect_L")
	self.show_effect_2 = self:FindVariable("ShowEffect_R")
	self.double_hit = self:FindObj("DoubleHit")
end

function TipsDoubleHitView:ReleaseCallBack()
	-- 清理变量和对象
	self.show_effect_1 = nil
	self.show_effect_2 = nil
	self.double_hit = nil
	self.hit_progress =nil

	self.flag = false
	self.kill_count = 0
	self.num_list = {}
	self.old_num_list = {}
	self.num_obj_list = {}
	if self.close_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.close_timer)
		self.close_timer = nil
	end
end

function TipsDoubleHitView:OpenCallBack()
	if self.num_list then
		for k,v in ipairs(self.num_list) do
			v:SetValue("")
		end
	end
end

function TipsDoubleHitView:CloseCallBack()

end

function TipsDoubleHitView:SetDoubleHitData(data)
	if self.flag == false then
		self.flag = true
		return
	end
	self.sever_kill_count = data.kill_count
	self.invalid_timestamp = data.trigger_continue_kill_invalid_timestamp
	-- self:Show()
end

function TipsDoubleHitView:UpdateLuckyDead()
	self.kill_count = self.kill_count + 1
	self.invalid_timestamp = TimeCtrl.Instance:GetServerTime() + self.trigger_continue_kill_interval_max
	self:Show()
end

function TipsDoubleHitView:Show()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local last_time = self.invalid_timestamp - now_time

	if self.close_timer ~= nil then
		CountDown.Instance:RemoveCountDown(self.close_timer)
		self.close_timer = nil
	end
	if last_time <= 0 or self.kill_count <= 0 then
		if self:IsOpen() then
			self:Close()
		end
		return
	end
	self:Open()
	self.close_timer = CountDown.Instance:AddCountDown(last_time, 0.05, BindTool.Bind(self.CountDown, self))
	self:Flush()
end

-- 倒计时函数
function TipsDoubleHitView:CountDown(elapse_time, total_time)
	if self:IsLoaded() then
		self.hit_progress:InitValue((total_time - elapse_time) / self.trigger_continue_kill_interval_max)
	end
	if elapse_time >= total_time then
		self.kill_count = 0
		self:CloseTips()
	end
end

function TipsDoubleHitView:CloseTips()
	self:Close()
end

function TipsDoubleHitView:OnFlush(param_list)
	self:SetNum(self.kill_count)
end

function TipsDoubleHitView:SetNum(kill_count)
	if nil == kill_count then return end
	if kill_count > 99999 then
		for i=1,5 do
			self.num_list[i]:SetValue(9)
		end
		return
	end
	local kill_count = kill_count
	local index = string.len(kill_count) + 1
	for i=1,index - 1 do
		local vector = {y = 1, x = 1, z = 1}
		if self.num_obj_list[index - i].transform.localScale.x ~= vector.x then
			return
		end
		self.num_list[index - i]:SetValue(math.floor(kill_count % 10))
		if self.old_num_list[index - i] ~= math.floor(kill_count % 10) then
			self.old_num_list[index - i] = math.floor(kill_count % 10)
			self.num_obj_list[index - i].transform:SetLocalScale(3, 3, 3)
			local target_scale = Vector3(1, 1, 1)
			self.num_obj_list[index - i].transform:DOScale(target_scale, 0.3)
		end
		kill_count = kill_count / 10
	end

	local num = math.random(1, 2)
	local other_num = num == 1 and 2 or 1
	self["show_effect_" .. num]:SetValue(false)
	self["show_effect_" .. other_num]:SetValue(false)
	self["show_effect_" .. num]:SetValue(true)
end
