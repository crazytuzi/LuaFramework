SevenLoginGiftData = SevenLoginGiftData or BaseClass()

function SevenLoginGiftData:__init()
	if SevenLoginGiftData.Instance ~= nil then
		print_error("[SevenLoginGiftData] Attemp to create a singleton twice !")
		return
	end
	SevenLoginGiftData.Instance = self

	self.gift_info = {
		notify_reason = 0,
		account_total_login_daycount = 0,
		seven_day_login_fetch_reward_list = {},
	}
	self.login_day_list = {}
	for i=1,7 do
		self.login_day_list[i] = 0
	end
	self.is_all_receive = false
	self.is_show_redpt = true

	-- 配置表数据
	self.reward_list = ConfigManager.Instance:GetAutoConfig("sevendaylogincfg_auto").reward
	RemindManager.Instance:Register(RemindName.SevenLogin, BindTool.Bind(self.GetSevenLoginRemind, self))
end

function SevenLoginGiftData:__delete()
	RemindManager.Instance:UnRegister(RemindName.SevenLogin)

	if SevenLoginGiftData.Instance ~= nil then
		SevenLoginGiftData.Instance = nil
	end
end

function SevenLoginGiftData:GetGiftRewardCfg()
	return self.reward_list
end

--通过天数获取对应的配置信息
function SevenLoginGiftData:GetDataByDay(day)
	local data = {}
	for k,v in pairs(self.reward_list) do
		if day == v.login_daycount then
			table.insert(data,v)
		end
	end

	return data[1]
end

function SevenLoginGiftData:GetGiftRewardByDay(day)
	local get_num = 0
	for k,v in pairs(self:GetGiftRewardCfg()) do
		if v.login_daycount == day then
			get_num = v.show_money
		end
	end
	return get_num
end


function SevenLoginGiftData:GetRewardList(gift_id)
	if gift_id == 0 then
		gift_id = 1
	end

	if gift_id > 7 then
		gift_id = 7
	end
	local gift_cfg = ItemData.Instance:GetItemConfig(self:GetDataByDay(gift_id).reward_item.item_id)
	local reward_list = {}
	for i=1, 6 do
		local item_id = gift_cfg["item_" .. i .. "_id"]
		if nil ~= item_id and item_id > 0 then
			local t = {}
			t.item_id = item_id
			t.num = gift_cfg["item_" .. i .. "_num"]
			t.is_bind = gift_cfg["is_bind_"..i]

			local item_cfg, big_type = ItemData.Instance:GetItemConfig(t.item_id)
			local gamevo = GameVoManager.Instance:GetMainRoleVo()
			local flag = true
			if nil ~= item_cfg then
				if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
					flag = false
				end
			end

			if flag then
				table.insert(reward_list, t)
			end
		end
	end

	return reward_list
end

function SevenLoginGiftData:GetGiftInfo()
	return self.gift_info
end

function SevenLoginGiftData:OnFetchSevenDayLoginReward(protocol)
	self.gift_info.notify_reason = protocol.notify_reason
	self.gift_info.account_total_login_daycount = protocol.account_total_login_daycount
	self.gift_info.seven_day_login_fetch_reward_list = bit:d2b(protocol.seven_day_login_fetch_reward_mark)
	self:SetLoginDayList()
	self:ShowIcon()
end

function SevenLoginGiftData:GetLoginRewardFlag(fetch_day)
	local flag = self.gift_info.seven_day_login_fetch_reward_list[32 - fetch_day]

	if 0 == flag then
		return false
	else
		return true
	end
end

function SevenLoginGiftData:GetLoginAllReward()
	for i = 1, 7 do
		if not self:GetLoginRewardFlag(i) then
			return true
		end
	end
	return false
end

function SevenLoginGiftData:GetLoginDayList()
	return self.login_day_list
end

function SevenLoginGiftData:SetLoginDay(day,value)
	self.login_day_list[day] = value
end

function SevenLoginGiftData:SetLoginDayList()
	local day = self.gift_info.account_total_login_daycount
	if day > 7 then
		day = 7
	end

	for i=1,day do
		if not self:GetLoginRewardFlag(i) then
			self.login_day_list[i] = 1
		end
	end
end

function SevenLoginGiftData:SetIsAllReceive(is_all_receive)
	self.is_all_receive = is_all_receive
end

function SevenLoginGiftData:GetIsAllReceive()
	return self.is_all_receive
end

function SevenLoginGiftData:SetIsShowRedpt(is_show_redpt)
	self.is_show_redpt = is_show_redpt
end

function SevenLoginGiftData:GetIsShowRedpt()
	return self.is_show_redpt
end

function SevenLoginGiftData:GetSevenLoginRemind()
	self:ShowRedpt()
	if not OpenFunData.Instance:CheckIsHide("logingift7view") then
		return 0
	end
	return self:GetIsShowRedpt() and 1 or 0
end

function SevenLoginGiftData:ShowRedpt()
	local day = self.gift_info.account_total_login_daycount or 0
	if day > 7 then
		day = 7
	end

	for i=1,day do
		if not self:GetLoginRewardFlag(i) then
			self.is_show_redpt = true
			return
		end
	end
	self.is_show_redpt = false
end

function SevenLoginGiftData:ShowIcon()
	if self.gift_info.account_total_login_daycount < 7 then
		MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.Show_Seven_Login, true)
		return
	end

	local is_all_fetch_ed = true
	for i=1,7 do
		if not self:GetLoginRewardFlag(i) then
			is_all_fetch_ed = false
			break
		end
	end

	MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.Show_Seven_Login, not is_all_fetch_ed)
end

function SevenLoginGiftData:IsCanReceive(cur_day)
	if cur_day > self.gift_info.account_total_login_daycount then
		return false
	end

	if not self:GetLoginRewardFlag(cur_day) then
		return true
	else
		return false
	end
end

function SevenLoginGiftData:GetWeaponTransform()
	local reward = self.reward_list[7]
	if not reward then return end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local scale = reward["scale_"..prof]
	local cfg = {}
		cfg.position = Vector3(reward["position_x_" .. prof], reward["position_y_" .. prof], reward["position_z_" .. prof])
		cfg.rotation = Vector3(reward["rotate_x_" .. prof], reward["rotate_y_" .. prof], reward["rotate_z_" .. prof])
		cfg.scale = Vector3(scale, scale, scale)
	return cfg
end



