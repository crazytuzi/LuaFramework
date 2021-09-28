GuildSigninView = GuildSigninView or BaseClass(BaseView)

function GuildSigninView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildSigninView"}
	self.play_audio = true
	self.title_id = 4004
end

function GuildSigninView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickSignin",
		BindTool.Bind(self.OnClickSignin, self))


	self.progress = self:FindObj("progress")
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self:FindObj("reward_cell"))

	self.text_signin_pro = self:FindVariable("text_signin_pro")
	self.text_total_day = self:FindVariable("text_total_day")
	self.text_title = self:FindVariable("text_title")
	self.is_can_click = self:FindVariable("is_can_click")
	self.text_signin = self:FindVariable("text_signin")
	self.img_title = self:FindVariable("img_title")
	self.text_title_cap = self:FindVariable("text_title_cap")
	self.prog_value = self:FindVariable("prog_value")

	-- 格子创建
	--获取组件
	self.item_list = {}
	self.text_limit_list = {}
	self.red_list = {}
	for i = 1, GuildData.SigninRewardNum do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("item_cell_" .. i))
		item:SetData(nil)
		table.insert(self.item_list, item)
		item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		self.red_list[i] = self:FindVariable("show_red_" .. i)
	end

	for i = 1, GuildData.SigninRewardNum + 1 do
		self.text_limit_list[i] = self:FindVariable("text_limit_count_" .. i)
	end
end

function GuildSigninView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
	self.text_limit_list = nil

	self.red_list = nil

	self.progress = nil

	self.text_signin_pro = nil
	self.text_total_day = nil
	self.text_title = nil
	self.reward_cell = nil
	self.is_can_click = nil
	self.text_signin = nil
	self.img_title = nil
	self.text_title_cap = nil
	self.prog_value = nil
end

function GuildSigninView:CloseCallBack()

end

function GuildSigninView:OpenCallBack()
	GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_ALL_INFO)
	self.is_first = true
	self:Flush()
end

function GuildSigninView:OnFlush()
	-- 格子数据刷新
	local signin_cfg = GuildData.Instance:GetSigninCfg()
	local last_data_cfg = signin_cfg[#signin_cfg] or {}
	local signin_data = GuildData.Instance:GetSigninData()
	local signin_title_cfg = GuildData.Instance:GetSigninTitleOneCfg(signin_data.signin_count_month)
	for i = 1, GuildData.SigninRewardNum + 1 do
		local data_index = i - 1
		local data = signin_cfg[data_index]
		self.text_limit_list[i]:SetValue(data.need_count)

		local cell = self.item_list[i]
		if cell then
			cell:SetData(data.reward_item)
			-- 格子根据状态不同做不同的显示
			cell:ShowGetEffect(false)
			cell:ShowHaseGet(false)
			local get_reward_state = GuildData.Instance:GetSigninRewardState(data.index)
			if get_reward_state == GuildData.SinginRewardState.CanGetReward then
				cell:ShowGetEffect(true)
			elseif get_reward_state == GuildData.SinginRewardState.HasGetReward then
				cell:ShowHaseGet(true)
			end
			self.red_list[i]:SetValue(get_reward_state == GuildData.SinginRewardState.CanGetReward)
		end
	end

	-- 当前签到进度
	local max_limit = last_data_cfg.need_count
	self.text_signin_pro:SetValue(signin_data.guild_signin_count_today .. " / " .. max_limit)

	--累计签到
	self.text_total_day:SetValue(signin_data.signin_count_month)

	-- 称号显示
	self.text_title:SetValue(signin_title_cfg.name)

	local percent = signin_data.guild_signin_count_today / max_limit

	if self.is_first then
		self.is_first = false
		self.prog_value:InitValue(percent)
	else
		self.prog_value:SetValue(percent)
	end

	-- 签到奖励格子
	local personal_reward = GuildData.Instance:GetPersonalSigninReward()
	self.reward_cell:SetData(personal_reward)
	self.is_can_click:SetValue(signin_data.is_signin_today == 0)

	local text = signin_data.is_signin_today == 0 and Language.Guild.Signin or Language.Guild.HasSignin
	self.text_signin:SetValue(text)

	-- 称号展示
	local bundle, asset = ResPath.GetTitleIcon(self.title_id)
	self.img_title:SetAsset(bundle, asset)

	local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
	self.text_title_cap:SetValue(CommonDataManager.GetCapability(title_cfg))
end

function GuildSigninView:OnClickSignin()
	GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_TYPE_SIGNIN)
end

function GuildSigninView:ItemClick(cell_index)
	local data_index = cell_index - 1

	local get_reward_state = GuildData.Instance:GetSigninRewardState(data_index)
	if get_reward_state == GuildData.SinginRewardState.CanGetReward then
		GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_TYPE_FETCH_REWARD, data_index)
	else
		local cell = self.item_list[cell_index]
		ItemCell.OnClickItemCell(cell)
	end
end