CampTeamView = CampTeamView or BaseClass(BaseView)

function CampTeamView:__init()
	self.ui_config = {"uis/views/camp", "CampTeamView"}

	self.play_audio = true								-- 播放音效
	self:SetMaskBg()									-- 使用蒙板
end

function CampTeamView:__delete()
end

function CampTeamView:ReleaseCallBack()
	for i = 1, 5 do
		if self.rank_list[i] and self.rank_list[i].cell then
			self.rank_list[i].cell:DeleteMe()
		end
		if self.other_rank_list[i] and self.other_rank_list[i].cell then
			self.other_rank_list[i].cell:DeleteMe()
		end
	end

	for i = 1, 3 do
		if self.login_item_list[i] and self.login_item_list[i].cell then
			self.login_item_list[i].cell:DeleteMe()
		end
		if self.zhanshi_item_list[i] and self.zhanshi_item_list[i].cell then
			self.zhanshi_item_list[i].cell:DeleteMe()
		end
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.login_item_list = {}
	self.zhanshi_item_list = {}
	self.rank_list = {}
	self.other_rank_list = {}
	self.camp_qiyun_list = {}
	self.is_on_team = nil
	self.can_reward_login = nil
	self.can_reward_zhanshi = nil
	self.zhanshi_count = nil
	self.login_btn_str = nil
	self.zhanshi_btn_str = nil
end

function CampTeamView:OpenCallBack()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_CAMP_ALLIANCE_RANK_INFO)
end

function CampTeamView:LoadCallBack()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.login_item_list = {}
	self.zhanshi_item_list = {}
	self.rank_list = {}
	self.other_rank_list = {}
	self.camp_qiyun_list = {}

	for i = 1, 3 do
		self.login_item_list[i] = {}
		self.login_item_list[i].obj = self:FindObj("LoginItem" .. i)
		self.login_item_list[i].cell = ItemCell.New()
		self.login_item_list[i].cell:SetInstanceParent(self.login_item_list[i].obj)

		self.zhanshi_item_list[i] = {}
		self.zhanshi_item_list[i].obj = self:FindObj("ZhanShiItem" .. i)
		self.zhanshi_item_list[i].cell = ItemCell.New()
		self.zhanshi_item_list[i].cell:SetInstanceParent(self.zhanshi_item_list[i].obj)

		self.login_item_list[i].obj:SetActive(false)
		self.zhanshi_item_list[i].obj:SetActive(false)

		self.camp_qiyun_list[i] = self:FindVariable("CampQiYun" .. i)
	end

	for i = 1, 5 do
		self.rank_list[i] = {}
		self.rank_list[i].obj = self:FindObj("Rank" .. i)
		self.rank_list[i].cell = RankItem.New(self.rank_list[i].obj)

		self.other_rank_list[i] = {}
		self.other_rank_list[i].obj = self:FindObj("OtherRank" .. i)
		self.other_rank_list[i].cell = RankItem.New(self.other_rank_list[i].obj)
	end

	self.is_on_team = self:FindVariable("IsOnTeam")
	self.can_reward_login = self:FindVariable("CanRewardLogin")
	self.can_reward_zhanshi = self:FindVariable("CanRewardZhanshi")
	self.zhanshi_count = self:FindVariable("ZhanShiCount")
	self.login_btn_str = self:FindVariable("LoginBtnStr")
	self.zhanshi_btn_str = self:FindVariable("ZhanshiBtnStr")

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnRewardLogin", BindTool.Bind(self.OnRewardLogin, self))
	self:ListenEvent("OnRewardZhanshi", BindTool.Bind(self.OnRewardZhanshi, self))
end

function CampTeamView:OnRewardLogin()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_QIYUN_RANK_LOGIN_REWARD_ITEM)
end

function CampTeamView:OnRewardZhanshi()
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_QIYUN_RANK_ZHANSHI_REWARD_ITEM)
end

function CampTeamView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "rank" then
			self:FlushRankInfo()
		elseif k == "reward" then
			self:FlushRewardInfo()
		end
	end
end

function CampTeamView:FlushRankInfo()
	local rank_info_list = CampData.Instance:GetSortCampQiYunRankList()
	local main_role_vo = PlayerData.Instance:GetRoleVo()
	if rank_info_list and next(rank_info_list) and main_role_vo then
		local role_camp = main_role_vo.camp
		local is_on_team = false
		for i = 1, 3 do
			local rank_info = rank_info_list[i]
			local camp_name = CampData.Instance:GetCampNameByCampType(rank_info.camp_type, true, true, true)
			self.camp_qiyun_list[i]:SetValue(string.format(Language.Camp.YesterdayQiYun, ToColorStr(camp_name, CAMP_COLOR[rank_info.camp_type]), ToColorStr(rank_info.qiyun_value, TEXT_COLOR.YELLOW)))

			if role_camp == rank_info.camp_type then
				local soldier_list, other_soldier_list = CampData.Instance:GetCampTeamSoldierList(role_camp, rank_info.alliance_camp)
				self:SetRankData(soldier_list, other_soldier_list)
			end
			if rank_info.alliance_camp ~= 0 then
				is_on_team = true
			end
		end
		self.is_on_team:SetValue(is_on_team)
	end
end

function CampTeamView:FlushRewardInfo()
	local reward_info = CampData.Instance:GetYesterdayQiyunRankInfo()
	local camp_other_cfg = CampData.Instance:GetCampOtherCfg()
	local reward_cfg = CampData.Instance:GetQiYunRankRewardByCamp()
	if reward_info and camp_other_cfg and reward_cfg then
		self.can_reward_login:SetValue(reward_info.login_reward ~= 1)
		self.can_reward_zhanshi:SetValue(reward_info.zhanshi_reward ~= 1 and reward_info.zhanshi_count >= camp_other_cfg.need_zhanshi_count)
		self.zhanshi_count:SetValue(string.format(Language.Camp.ZhanshiNeedDo, camp_other_cfg.need_zhanshi_count, reward_info.zhanshi_count < camp_other_cfg.need_zhanshi_count and reward_info.zhanshi_count or camp_other_cfg.need_zhanshi_count, camp_other_cfg.need_zhanshi_count))
		
		self.login_btn_str:SetValue(reward_info.login_reward ~= 1 and Language.Common.LingQu or Language.Common.YiLingQu)
		self.zhanshi_btn_str:SetValue(reward_info.zhanshi_reward ~= 1 and Language.Common.LingQu or Language.Common.YiLingQu)

		local login_rewarditem_list = ItemData.Instance:GetGiftItemList(reward_cfg.login_rewarditem.item_id)
		local zhanshi_reward_item_list = ItemData.Instance:GetGiftItemList(reward_cfg.zhanshi_reward_item.item_id)
		for i = 1, 3 do
			if login_rewarditem_list[i] then
				self.login_item_list[i].obj:SetActive(true)
				self.login_item_list[i].cell:SetData(login_rewarditem_list[i])
			end
			if zhanshi_reward_item_list[i] then
				self.zhanshi_item_list[i].obj:SetActive(true)
				self.zhanshi_item_list[i].cell:SetData(zhanshi_reward_item_list[i])
			end
		end
	end
end

function CampTeamView:SetRankData(soldier_list, other_soldier_list)
	for i = 1, 5 do
		if soldier_list[i] then
			self.rank_list[i].obj:SetActive(true)
			self.rank_list[i].cell:SetIndex(i)
			self.rank_list[i].cell:SetData(soldier_list[i])
		else
			self.rank_list[i].cell:SetData(nil)
			self.rank_list[i].obj:SetActive(false)
		end
		if other_soldier_list[i] then
			self.other_rank_list[i].obj:SetActive(true)
			self.other_rank_list[i].cell:SetIndex(i)
			self.other_rank_list[i].cell:SetData(other_soldier_list[i])
		else
			self.other_rank_list[i].cell:SetData(nil)
			self.other_rank_list[i].obj:SetActive(false)
		end
	end
end


--------------------RankItem------------------
RankItem = RankItem or BaseClass(BaseCell)
function RankItem:__init()
	self.portrait_raw = self:FindObj("PortraitRaw")
	self.camp_name = self:FindVariable("Camp")
	self.name_kill = self:FindVariable("NameKill")
	self.show_head_img = self:FindVariable("ShowHeadImg")
	self.head_img = self:FindVariable("HeadImg")
	self.rank = self:FindVariable("Rank")
end

function RankItem:OnFlush()
	if self.data then
		self.rank:SetValue(self.index)
		self.name_kill:SetValue(string.format(Language.Camp.CampTeamKill, self.data.user_name, self.data.kill_role_num))
		local camp_name = CampData.Instance:GetCampNameByCampType(self.data.camp_type, true, true, true)
		self.camp_name:SetValue(ToColorStr(camp_name, CAMP_COLOR[self.data.camp_type]))

		local is_default_img = AvatarManager.Instance:isDefaultImg(self.data.user_id) == 0
		self.show_head_img:SetValue(is_default_img)

		AvatarManager.Instance:SetAvatarKey(self.data.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
		if is_default_img then
			local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
			self.head_img:SetAsset(bundle, asset)
		else
			local callback = function (path)
				local avatar_path = path or AvatarManager.GetFilePath(self.data.user_id, false)
				self.portrait_raw.raw_image:LoadSprite(avatar_path, function()
			 	end)
			end
			AvatarManager.Instance:GetAvatar(self.data.user_id, false, callback)
		end
	end
end