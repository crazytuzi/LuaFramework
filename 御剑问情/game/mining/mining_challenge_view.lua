MiningChallengeView = MiningChallengeView or BaseClass(BaseRender)

local MAX_ROLE_NUM = 4
local REFEESH_ROLE_NEED_BIND_GOLD = 5

function MiningChallengeView:__init(instance)
	self:InitView()
end

function MiningChallengeView:InitView()
	self.text_left_times = self:FindVariable("text_left_times")
	self.text_jewel_num = self:FindVariable("text_jewel_num")
	self.is_show_red_point = self:FindVariable("is_show_red_point")
	self.text_add_time = self:FindVariable("text_add_time")
	self.is_show_time = self:FindVariable("is_show_time")
	self.text_my_rank = self:FindVariable("text_my_rank")
	self.text_my_score = self:FindVariable("text_my_score")
	self.text_count_desc = self:FindVariable("text_count_desc")
	self.text_count_desc:SetValue(Language.Mining.CountDownDesc)
	self.text_flsuh_count_down = self:FindVariable("text_flsuh_count_down")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end

	local item_cell_data = MiningData.Instance:GetOtherCfg()
	self.item_cell_list[1]:SetData(item_cell_data.cf_win_item[0])

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	self.item_cell_list[2]:SetData({item_id = ResPath.CurrencyToIconId.exp or 0,num=item_cell_data.cf_win_add_exp * math.floor(1 + role_level / 100), is_bind = 0})

	self.model_list = {}
	self.display_list = {}
	self.text_role_name_list = {}
	self.text_role_fighting_list = {}
	self.is_show_img_list = {}
	self.is_gray_list = {}

	for i = 0, MAX_ROLE_NUM - 1 do
		self.text_role_name_list[i] = self:FindVariable("text_role_name" .. i)
		self.text_role_fighting_list[i] = self:FindVariable("text_role_fighting" .. i)
		self.is_show_img_list[i] = self:FindVariable("is_show_img" .. i)
		self.is_gray_list[i] = self:FindVariable("is_gray" .. i)

		self.model_list[i] = RoleModel.New("mining_challenge_panel")
		local display = self:FindObj("Display" .. i)
		self.display_list[i] = display
		self.model_list[i]:SetDisplay(display.ui3d_display)

		self:ListenEvent("BtnChallenge" .. i,BindTool.Bind2(self.OnClickBtnChallenge, self, i))
	end

	--引导用按钮
	self.mining_btn_challenge = self:FindObj("BtnChallenge")

	self:ListenEvent("BtnRefreshRole",BindTool.Bind1(self.RefreshChallengeRole, self))
	self:ListenEvent("OpenHelp",BindTool.Bind1(self.OpenHelp, self))
	self:ListenEvent("OpenRank",BindTool.Bind1(self.OnClickOpenRank, self))
	self:ListenEvent("OnAddTimes",BindTool.Bind(self.OnAddTimes, self))

	self.last_challenge_times = 0
end

function MiningChallengeView:__delete()
	self.text_left_times = nil
	self.text_jewel_num = nil
	self.is_show_red_point = nil
	self.text_add_time = nil
	self.is_show_time = nil
	self.my_rank = nil
	self.my_score = nil
	self.text_count_desc = nil
	self.text_flsuh_count_down = nil

	for k,v in pairs(self.model_list) do
		v:DeleteMe()
	end
	self.model_list = {}
	self.display_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.item_cell_obj_list = {}

	self.text_role_name_list = {}
	self.text_role_fighting_list = {}
	self.is_show_img_list = {}
	self.is_gray_list = {}

	self:RemoveCountDown()
	self:RemoveFlushCountDown()
	self.last_challenge_times = 0
end

function MiningChallengeView:GetMiningBtnChallenge()
	return self.mining_btn_challenge
end

function MiningChallengeView:ShowIndexCallBack()
	self:Flsuh()
end

function MiningChallengeView:OnFlush()
	local role_info_list = MiningData.Instance:GetChallengeRoleInfo()
	if nil == role_info_list or nil == role_info_list[1] then
		return
	end

	local base_info = MiningData.Instance:GetFightingChallengeBaseInfo()
	-- 剩余次数
	local left_times = base_info.challenge_day_times
	-- local color = left_times > 0 and "#0000f1FF" or "#e40000FF"
	self.text_left_times:SetValue(left_times)
	-- 剩余次数有增加的话给加个提示
	if left_times > self.last_challenge_times then
		local left_buy_times = MiningData.Instance:GetChallengeLeftBuyTimes()
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Mining.LeftBuyTimes, left_buy_times))

		self.last_challenge_times = left_times
	end
	-- 花费
	local oter_config = MiningData.Instance:GetOtherCfg()
	self.text_jewel_num:SetValue(oter_config.cf_reflush_need_bind_gold)

	-- 小红点
	-- self.is_show_red_point:SetValue(MiningData.Instance:GetChallengeRedPoint() > 0)

	local main_role_server_id = GameVoManager.Instance:GetMainRoleVo().server_id
	
	local server_name = Language.Mining.Server
	for i = 0, MAX_ROLE_NUM - 1 do
		-- 模型刷新
		local role_info = role_info_list[i + 1]
		self.model_list[i]:SetModelResInfo(role_info, nil, self.is_show_hook, true)
		-- 战力显示
		self.text_role_fighting_list[i]:SetValue(role_info.capability)


		-- 名字刷新
		local name = role_info.random_name_num == -1 and role_info.name or MiningData.Instance:GetRandomNameByRandNum(role_info.random_name_num)
		MiningData.Instance:SetCapabilityList(name, role_info.capability)	--初始化战力表

		name = name .. server_name
		self.text_role_name_list[i]:SetValue(name)

		local is_win = role_info.is_win == 1
		self.is_show_img_list[i]:SetValue(is_win)
		self.is_gray_list[i]:SetValue(not is_win)
	end

	self:RemoveCountDown()
	if left_times < 6 then
		self.is_show_time:SetValue(true)
		local all_left_time = base_info.next_add_challenge_timestamp - TimeCtrl.Instance:GetServerTime()
		self.count_down = CountDown.Instance:AddCountDown(all_left_time, 1, BindTool.Bind(self.CountDown, self))
		self:CountDown(0, all_left_time)
	else
		self:RemoveCountDown()
		self.is_show_time:SetValue(false)
	end

	-- 刷新玩家倒计时
	self:RemoveFlushCountDown()
	local flush_left_time = base_info.next_auto_reflush_time - TimeCtrl.Instance:GetServerTime()
	self.flush_count_down = CountDown.Instance:AddCountDown(flush_left_time, 1, BindTool.Bind(self.FlsuhCountDown, self))
	self:FlsuhCountDown(0, flush_left_time)

	local my_rank = RankData.Instance:GetMyInfoList()
	my_rank = my_rank >= 1 and my_rank or Language.Mining.NoRank
	self.text_my_rank:SetValue(ToColorStr(my_rank, TEXT_COLOR.GREEN))
	local challenge_base_info = MiningData.Instance:GetFightingChallengeBaseInfo()
	local my_score = challenge_base_info.challenge_score
	self.text_my_score:SetValue(ToColorStr(my_score, TEXT_COLOR.GREEN))
end

function MiningChallengeView:FlsuhCountDown(elapse_time, total_time)
	local left_time = total_time - elapse_time
	if left_time < 0 then
		self:RemoveFlushCountDown()
	end
	local str_time = TimeUtil.FormatSecond2MS(left_time)
	local n_str = string.format(Language.Mining.FlushDownCount,str_time)
	self.text_flsuh_count_down:SetValue(n_str)
end

function MiningChallengeView:RemoveFlushCountDown()
	if self.flush_count_down then
		CountDown.Instance:RemoveCountDown(self.flush_count_down)
		self.flush_count_down = nil
	end
end

function MiningChallengeView:OpenCallBack()
	local base_info = MiningData.Instance:GetFightingChallengeBaseInfo()
	self.last_challenge_times = base_info.challenge_day_times
	MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_INFO)
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHTING_CHALLENGE)
end

function MiningChallengeView:RefreshChallengeRole()
	local function ok_callback()
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_REFLUSH)
	end
	local cur_bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local cost = REFEESH_ROLE_NEED_BIND_GOLD
	local gold_des = cur_bind_gold >= cost and Language.Mining.GoldType[0] or Language.Mining.GoldType[1]
	local des = string.format(Language.Mining.RefreshRoleDesc, cost, gold_des)
	TipsCtrl.Instance:ShowCommonAutoView("is_auto_buy__challenge_times", des, ok_callback)
	--MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_REFLUSH)
end

function MiningChallengeView:OpenHelp()
	local tips_id = 197
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MiningChallengeView:OnClickBtnChallenge(index)
	local left_times = MiningData.Instance:GetChallengeLeftTimes()
	if left_times <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Mining.TimesNoEnough)
		return
	end

	MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_FIGHTING, index)
end

function MiningChallengeView:OnClickOpenRank(index)
	MiningController.Instance:OpenChallengeRankView()
end

function MiningChallengeView:OnAddTimes()
	if TipsCommonAutoView.AUTO_VIEW_STR_T["is_auto_buy__challenge_times"] then
		MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_BUY_FIGHTING_TIMES)
	else
		local function ok_callback(is_auto)
			-- 挑衅-VIP购买挑战次数
			MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_C_BUY_FIGHTING_TIMES)
		end
		--是否提示vip不足面板
		local left_can_buy_times = MiningData.Instance:GetChallengeLeftBuyTimes()
		if left_can_buy_times == 0 then
			local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
			local cur_vip_max_times = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.MINING_CHALLENGE] or 0
			local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.MINING_CHALLENGE, cur_vip_max_times + 1) or 0
			if limit_level == -1 then
				TipsCtrl.Instance:ShowSystemMsg(Language.Mining.RestTimesLimitChallenge)
			elseif PlayerData.Instance.role_vo.vip_level < limit_level then
				TipsCtrl.Instance:ShowLockVipView(VIPPOWER.MINING_CHALLENGE)
			end
		else
			local cost = MiningData.Instance:GetBuyChallengeTimesCost()
			local des = string.format(Language.Mining.BuyTimesDesc, cost)
			TipsCtrl.Instance:ShowCommonAutoView("is_auto_buy__challenge_times", des, ok_callback)
		end

	end
end

function MiningChallengeView:CloseCallBack()
	TipsCommonAutoView.AUTO_VIEW_STR_T["is_auto_buy__challenge_times"] = nil
end

function MiningChallengeView:CountDown(elapse_time, total_time)
	local left_time = total_time - elapse_time
	if left_time < 0 then
		self:RemoveCountDown()
		if nil ~= self.is_show_time then
			self.is_show_time:SetValue(false)
		end
	end
	self.text_add_time:SetValue(TimeUtil.FormatSecond2MS(left_time))
end

function MiningChallengeView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end