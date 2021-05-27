--------------------------------------------------------
-- 行会弹劾  配置 
--------------------------------------------------------

GuildImpeachView = GuildImpeachView or BaseClass(BaseView)

function GuildImpeachView:__init()
	self.texture_path_list[1] = 'res/xui/worship.png'
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"guild_ui_cfg", 21, {0}},
	}

	self.left_times = 0
end

function GuildImpeachView:__delete()
end

--释放回调
function GuildImpeachView:ReleaseCallBack()
	self.left_times = 0

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

--加载回调
function GuildImpeachView:LoadCallBack(index, loaded_times)
	self:CreateProg()
	self:CreateTimer()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_agree_with"].node, BindTool.Bind(self.OnVote, self, 1))
	XUI.AddClickEventListener(self.node_t_list["btn_despise"].node, BindTool.Bind(self.OnVote, self, 2))

	-- 数据监听
	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.GUILD_IMPEACH, BindTool.Bind(self.OnGuildImpeach, self))
end

function GuildImpeachView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildImpeachView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function GuildImpeachView:ShowIndexCallBack(index)
	self:Flush()
	self:CreateTimer()
end

function GuildImpeachView:OnFlush()
	self:FlushAllShow()
end

----------视图函数----------

function GuildImpeachView:FlushAllShow()
	-- key = 0-会长本次的登录时间 1-会长上次的下线时间 2-弹劾开始时间  3-上次弹劾结束时间  4-发起弹劾玩家id  5-赞成票数  6-反对票数 7-发起弹劾玩家名称
	local impeach_info = GuildData.Instance:GetGuildImpeachInfo()

	local guild_info = GuildData.Instance:GetGuildInfo()

	local president_name = guild_info.leader_name ~= "" and guild_info.leader_name or ""
	self.node_t_list["lbl_president_name"].node:setString(president_name)

	local candidate_name = impeach_info[7] or ""
	self.node_t_list["lbl_candidate_name"].node:setString(candidate_name)

	-- 可参与的人数,会长不可参于投票
	local max_num = math.max((guild_info.cur_member_num - 1), 1)

	-- 例: "赞同票：10"
	local agree_with_count = impeach_info[5] or 0
	self.node_t_list["lbl_agree_with_count"].node:setString(Language.Guild.ImpeachText1 .. agree_with_count)
	local per = (agree_with_count / max_num) * 100
	self.agree_with_progressbar:SetPercent(per)

	-- 例: "反对票：10"
	local despise_count = impeach_info[6] or 0
	self.node_t_list["lbl_despise_count"].node:setString(Language.Guild.ImpeachText2 .. despise_count)
	local per = (despise_count / max_num) * 100
	self.despise_progressbar:SetPercent(per)

	-- 0=未投票(灰色 COLOR3B.GRAY) 1=赞同(绿色 COLOR3B.GREEN) 2=反对(红色 COLOR3B.RED)
	local impeach_vote = GuildData.Instance:GetGuildImpeachVote()
	local state = impeach_vote
	local my_vote_state = Language.Guild.ImpeachText3 and Language.Guild.ImpeachText3[state] or ""
	local color = ({[0] = COLOR3B.GRAY, COLOR3B.GREEN, COLOR3B.RED})[state] or COLOR3B.GREEN
	self.node_t_list["lbl_my_vote_state"].node:setString(my_vote_state)
	self.node_t_list["lbl_my_vote_state"].node:setColor(color)
end

function GuildImpeachView:CreateProg()
	local agree_with_prog = XUI.CreateLoadingBar(116, 236, ResPath.GetWorship("prog_worship_progress"), XUI.IS_PLIST, nil, true, 105, 10, cc.rect(3, 3, 5, 5))
	agree_with_prog:setRotation(- 90)
	self.node_t_list["layout_guild_impeac"].node:addChild(agree_with_prog, 99)
	self.agree_with_progressbar = ProgressBar.New()
	self.agree_with_progressbar:SetView(agree_with_prog)
	self.agree_with_progressbar:SetPercent(0)
	self:AddObj("agree_with_progressbar")

	local despise_prog = XUI.CreateLoadingBar(271, 236, ResPath.GetWorship("prog_despise_progress"), XUI.IS_PLIST, nil, true, 105, 10, cc.rect(3, 3, 5, 5))
	despise_prog:setRotation(- 90)
	self.node_t_list["layout_guild_impeac"].node:addChild(despise_prog, 99)
	self.despise_progressbar = ProgressBar.New()
	self.despise_progressbar:SetView(despise_prog)
	self.despise_progressbar:SetPercent(0)
	self:AddObj("despise_progressbar")
end

-- 刷新结束倒计时
function GuildImpeachView:FlushLeftTimes()
	if self:IsOpen() and self.node_t_list["lbl_left_times"] then
		self.left_times = math.max(self.left_times - 1, 0)
		-- 例: "结束倒计时：23时59分59秒"
		local left_times_str = Language.Guild.ImpeachText4 .. TimeUtil.FormatSecond2Str(self.left_times)
		self.node_t_list["lbl_left_times"].node:setString(left_times_str)
	end

	if not self:IsOpen() or not self.node_t_list["lbl_left_times"] or self.left_times <= 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end
end

-- 创建计时器
function GuildImpeachView:CreateTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	local server_time_offset = COMMON_CONSTS.SERVER_TIME_OFFSET
	local global = GuildConfig and GuildConfig.global or {}

	 -- key = 0-会长本次的登录时间 1-会长上次的下线时间 2-弹劾开始时间  3-上次弹劾结束时间  4-发起弹劾玩家id  5-赞成票数  6-反对票数
	local impeach_info = GuildData.Instance:GetGuildImpeachInfo()
	local left_times = (impeach_info[2] or 0) + server_time_offset + global.uImpeachmentTime - os.time()
	self.left_times = math.max(left_times, 0)
	self:FlushLeftTimes()

	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushLeftTimes, self), 1)
end

----------end----------

-- 投票 index = 1赞同, 2反对
function GuildImpeachView:OnVote(index)
	GuildCtrl.SendGuildImpeachVoteReq(index)
end

-- "行会弹劾"信息改变回调
function GuildImpeachView:OnGuildImpeach()
	self:Flush()
	self:CreateTimer()
end

--------------------
