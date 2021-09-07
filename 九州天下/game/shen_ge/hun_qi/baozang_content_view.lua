BaoZangContentView = BaoZangContentView or BaseClass(BaseRender)


function BaoZangContentView:__init()
	self.stand_list = self:FindObj("StandList")					--站台列表
	self.baoxiang_display = self:FindObj("BaoXiangModel")		--宝箱模型
	self.stand_role_list = {}
	for i = 0, HunQiData.SHENZHOU_WEAPON_BOX_HELP_MAX_CONUT - 1 do
		local obj = self.stand_list.transform:GetChild(i).gameObject
		local cell = StandRoleItemCell.New(obj)
		cell:SetIndex(i+1)
		cell:SetClickCallBack(BindTool.Bind(self.ClickRoleHelpCallBack, self))
		table.insert(self.stand_role_list, cell)
	end

	self.gold_res = self:FindVariable("GoldRes")			--钻石图标
	self.cost_text = self:FindVariable("CostText")			--消耗文字
	self.show_cost = self:FindVariable("ShowCost")			--展示消耗
	self.have_box = self:FindVariable("HaveBox")			--展示宝箱
	self.button_text = self:FindVariable("ButtonText")		--按钮文本
	self.count_text = self:FindVariable("CountText")		--宝箱个数
	self.box_res = self:FindVariable("BoxRes")				--宝箱资源
	self.help_count = self:FindVariable("HelpCount")		--今日可协助次数
	self.remind_text = self:FindVariable("RemindText")		--提醒文本
	self.free_time_des = self:FindVariable("FreeTimeDes")	--免费时间文本
	self.is_free = self:FindVariable("IsFree")				--是否免费
	self.cost_text_ten = self:FindVariable("CostTextTen")	--花费十次文本

	self:ListenEvent("ClickOne", BindTool.Bind(self.ClickOpenBox, self, 1))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("PreReward", BindTool.Bind(self.PreReward, self))
	self:ListenEvent("ClickTen", BindTool.Bind(self.ClickOpenBox, self, 10))
end

function BaoZangContentView:__delete()
	for _, v in ipairs(self.stand_role_list) do
		v:DeleteMe()
	end
	self.stand_role_list = {}

	if self.baoxiang_model then
		self.baoxiang_model:DeleteMe()
		self.baoxiang_model = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function BaoZangContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(172)
end

function BaoZangContentView:PreReward()
	local box_reward_list = HunQiData.Instance:GetBoxRewardCfg()
	if nil == box_reward_list then
		return
	end
	local reward_list = {}
	for _, v in ipairs(box_reward_list) do
		table.insert(reward_list, v.reward_item)
	end
	TipsCtrl.Instance:ShowPreRewardView(reward_list)
end

function BaoZangContentView:ClickOpenBox(open_times)
	local box_cfg = HunQiData.Instance:GetBoxCfg()
	if nil == box_cfg then
		return
	end
	local box_id = HunQiData.Instance:GetBoxId()
	if box_id <= 0 then
		local baoxiang_id = box_cfg.box_id
		local baoxiang_num = ItemData.Instance:GetItemNumInBagById(baoxiang_id)
		if baoxiang_num <= 0 then
			TipsCtrl.Instance:ShowItemGetWayView(baoxiang_id)	
		else
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_PUT_BOX)
		end
	else
		local function ok_callback()
			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_OPEN_BOX, open_times)
		end

		local is_free = false
		if HunQiData.Instance:GetTodayOpenFreeBoxNum() < HunQiData.Instance:GetMaxFreeBoxTimes() then
			local server_time = TimeCtrl.Instance:GetServerTime()
			local times = server_time - HunQiData.Instance:GetLastOpenFreeBoxTimeStamp()
			if times >= HunQiData.Instance:GetFreeBoxCD() then
				is_free = true
			end
		end

		local role_list_data = HunQiData.Instance:GetBoxHelpList()
		if nil == role_list_data then
			return
		end
		local is_max_help = true
		for k, v in ipairs(role_list_data) do
			if v <= 0 then
				is_max_help = false
				break
			end
		end

		--协助人数不足提示
		if not is_max_help then
			local des = ""
			local auto_des = ""
			if is_free then
				auto_des = "not_max_baozang_free"
				des = string.format(Language.HunQi.NoEnoughHelpRoleDes2, #role_list_data)
			else
				auto_des = "not_max_baozang"
				des = string.format(Language.HunQi.NoEnoughHelpRoleDes1, #role_list_data, box_cfg.cousume_diamond * open_times)
			end
			TipsCtrl.Instance:ShowCommonAutoView(auto_des, des, ok_callback)
		elseif not is_free then
			local des = string.format(Language.HunQi.EnoughHelpRoleDes, box_cfg.cousume_diamond * open_times)
			TipsCtrl.Instance:ShowCommonAutoView("max_baozang", des, ok_callback)
		else
			ok_callback()
		end
	end
end

--刷新人物列表
function BaoZangContentView:FlushRoleList()
	local role_list_data = HunQiData.Instance:GetBoxHelpList()
	if nil == role_list_data then
		return
	end

	for k, v in ipairs(self.stand_role_list) do
		v:SetData(role_list_data[k])
	end
end

function BaoZangContentView:FlushBaoXiangModel()
	if nil == self.baoxiang_model then
		self.baoxiang_model = RoleModel.New()
		self.baoxiang_model:SetDisplay(self.baoxiang_display.ui3d_display)
	end
end

--刷新宝箱
function BaoZangContentView:FlushBaoXiang()
	local box_id = HunQiData.Instance:GetBoxId()
	if box_id <= 0 then
		self.have_box:SetValue(false)
		return
	end
	self.have_box:SetValue(true)
	local count = HunQiData.Instance:GetHelpCount()
	self.box_res:SetAsset(ResPath.GetGuildBoxIcon(count))
	-- self:FlushBaoXiangModel()
end

function BaoZangContentView:StopCountDown()
	if self.free_count_down then
		CountDown.Instance:RemoveCountDown(self.free_count_down)
		self.free_count_down = nil
	end
end

function BaoZangContentView:FlushBaoZangCountDown()
	self:StopCountDown()
	local today_open_free_times = HunQiData.Instance:GetTodayOpenFreeBoxNum()
	local max_open_free_times = HunQiData.Instance:GetMaxFreeBoxTimes()
	if today_open_free_times < max_open_free_times then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local times = server_time - HunQiData.Instance:GetLastOpenFreeBoxTimeStamp()
		local diff_time = HunQiData.Instance:GetFreeBoxCD() - times
		diff_time = math.ceil(diff_time)
		if diff_time <= 0 then
			self.free_time_des:SetValue("")
			self.is_free:SetValue(true)
		else
			local function timer_func(elapse_time, total_time)
				if elapse_time >= total_time then
					self.free_time_des:SetValue("")
					self.is_free:SetValue(true)
					self.cost_text:SetValue(Language.Common.Free)
					self:StopCountDown()
					return
				end
				local temp_diff_time = math.ceil(total_time - elapse_time)
				local time_str = TimeUtil.FormatSecond(temp_diff_time)
				time_str = string.format(Language.HunQi.FreeText, time_str)
				self.free_time_des:SetValue(time_str)
				self.is_free:SetValue(false)
			end
			local time_str = TimeUtil.FormatSecond(diff_time)
			time_str = string.format(Language.HunQi.FreeText, time_str)
			self.free_time_des:SetValue(time_str)
			self.is_free:SetValue(false)
			self.free_count_down = CountDown.Instance:AddCountDown(diff_time, 1, timer_func)
		end
	else
		self.free_time_des:SetValue("")
		self.is_free:SetValue(false)
	end
end

--刷新相关文本
function BaoZangContentView:FlushContent()
	local box_cfg = HunQiData.Instance:GetBoxCfg()
	if nil == box_cfg then
		return
	end

	--设置剩余协助次数
	local times = HunQiData.Instance:GetTodayCanHelpBoxNum()
	local help_times_str = ToColorStr(times, TEXT_COLOR.GREEN)
	if times <= 0 then
		help_times_str = ToColorStr(times, TEXT_COLOR.RED)
	end
	self.help_count:SetValue(help_times_str)

	--展示宝箱个数
	self:FlushBoxCount()

	local box_id = HunQiData.Instance:GetBoxId()
	if box_id <= 0 then
		self.show_cost:SetValue(false)
		self.button_text:SetValue(Language.HunQi.PutInBox)
		return
	end
	self.show_cost:SetValue(true)
	self.button_text:SetValue(Language.HunQi.OpenBox)

	local cost = box_cfg.cousume_diamond
	self.cost_text:SetValue(cost)
	self.cost_text_ten:SetValue(cost * 10)
	self:FlushBaoZangCountDown()

	--刷新提醒文本
	local box_reward_count_cfg = HunQiData.Instance:GetBoxRewardCountCfg()
	if nil == box_reward_count_cfg then
		return
	end

	local count = HunQiData.Instance:GetHelpCount()
	local temp_count = count
	local reward_num = box_reward_count_cfg["open_reward"..(temp_count+1)]
	if count < 4 then
		local num_1 = box_reward_count_cfg["open_reward"..(count+1)]
		for i = count, 3 do
			local num_2 = box_reward_count_cfg["open_reward"..(i+2)]
			if num_2 and num_2 > num_1 then
				temp_count = i+1
				reward_num = num_2
				break
			end
		end
	end

	local remind_des = string.format(Language.HunQi.RemindDes, temp_count, reward_num - 1)
	self.remind_text:SetValue(remind_des)
end

function BaoZangContentView:FlushBoxCount()
	local box_cfg = HunQiData.Instance:GetBoxCfg()
	if nil == box_cfg then
		return
	end
	local baoxiang_id = box_cfg.box_id
	local baoxiang_num = ItemData.Instance:GetItemNumInBagById(baoxiang_id)
	local count_text = ToColorStr(baoxiang_num, TEXT_COLOR.GREEN)
	if baoxiang_num <= 0 then
		count_text = ToColorStr(baoxiang_num, TEXT_COLOR.RED)
	end
	self.count_text:SetValue(count_text)
end

function BaoZangContentView:InitView()
	self:FlushRoleList()
	self:FlushBaoXiang()
	self:FlushContent()
end

function BaoZangContentView:FlushView()
	self:FlushRoleList()
	self:FlushBaoXiang()
	self:FlushContent()
end


function BaoZangContentView:ClickRoleHelpCallBack(cell)
	if nil == cell then
		return
	end
	HunQiCtrl.Instance:CheckToSendHelpBox()
end

-----------------------------------------------------------------
-----------------------StandRoleItemCell-------------------------
-----------------------------------------------------------------
StandRoleItemCell = StandRoleItemCell or BaseClass(BaseCell)

function StandRoleItemCell:__init()
	self.role_display = self:FindObj("RoleDisPlay")

	self.have_role = self:FindVariable("HaveRole")				--是否有人协助
	self.name = self:FindVariable("Name")						--玩家名字

	self:ListenEvent("ClickHelp", BindTool.Bind(self.OnClick, self))
end

function StandRoleItemCell:__delete()
	self:UnBindQuery()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function StandRoleItemCell:UnBindQuery()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function StandRoleItemCell:RoleInfoReturn(role_id, info)
	if role_id == 0 or role_id ~= self.data then
		return
	end
	self:FlushRole(info)
end

function StandRoleItemCell:FlushRole(role_info)
	self:UnBindQuery()
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.role_display.ui3d_display)
	end
	if role_info then
		self.model:SetModelResInfo(role_info)
		self.name:SetValue(role_info.role_name)
	else
		self.role_event_system = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoReturn, self))
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.data)
	end
end

function StandRoleItemCell:OnFlush()
	if nil == self.data then
		return
	end
	if self.data > 0 then
		local old_have_role_value = self.have_role:GetBoolean()
		--之前有模型就不再刷新了
		if not old_have_role_value then
			--表明该位置上处于没有模型状态
			self.have_role:SetValue(true)
			self:FlushRole()
		end
	else
		self.name:SetValue("")
		self.have_role:SetValue(false)
		if self.model then
			self.model:ClearModel()
		end
	end
end