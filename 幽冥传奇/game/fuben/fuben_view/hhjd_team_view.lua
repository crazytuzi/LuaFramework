-- 行会禁地组队视图
HhjdTeamView = HhjdTeamView or BaseClass(BaseView)

function HhjdTeamView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.view_size = cc.size(0, 0)
end

function HhjdTeamView:__delete()
end

function HhjdTeamView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	FubenMutilCtrl.SendGetFubenTeamInfo(FubenMutilType.Hhjd, FubenMutilId.Hhjd1)
	FubenMutilCtrl.SendOpenFubenMutilView(1)
end

function HhjdTeamView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	FubenMutilCtrl.SendOpenFubenMutilView(2)
end

function HhjdTeamView:ReleaseCallBack()
end

local team_list_w = 0
function HhjdTeamView:LoadCallBack(index, loaded_times)
	if loaded_times > 1 then
		return
	end

	-- 背景
	local bg = XUI.CreateImageView(0, 0, ResPath.GetBigPainting("common_bg_135"), true)
	bg:setAnchorPoint(0, 0)
	self.root_node:addChild(bg, 1, 1)
	self.view_size = bg:getContentSize()
	self.root_node:setContentSize(self.view_size)

	-- 分割线
	local bg2 = XUI.CreateImageView(self.view_size.width / 2, 88, ResPath.GetCommon("line_07"), true)
	bg2:setScaleX(1.2)
	self.root_node:addChild(bg2, 3)

	-- 文字标题
	local title = RichTextUtil.ParseRichText(nil, Language.Fuben.HhjdTeamTitle, 24, COLOR3B.ORANGE,
		self.view_size.width / 2, self.view_size.height - 50, 200, 30)
	XUI.RichTextSetCenter(title)
	self.root_node:addChild(title, 3)

	-- 按钮
	-- 快速匹配
	local btn_1 = XUI.CreateButton(self.view_size.width / 2 - 100, 48, 0, 0, false,
		ResPath.GetCommon("btn_103"), ResPath.GetCommon("btn_103"), "", XUI.IS_PLIST)
	btn_1:setTitleText(Language.Fuben.QuickMatch)
	btn_1:setTitleFontSize(22)
	btn_1:setTitleFontName(COMMON_CONSTS.FONT)
	btn_1:setTitleColor(COLOR3B.WHITE)
	-- 创建队伍
	local btn_2 = XUI.CreateButton(self.view_size.width / 2 + 100, 48, 0, 0, false,
		ResPath.GetCommon("btn_103"), ResPath.GetCommon("btn_103"), "", XUI.IS_PLIST)
	btn_2:setTitleText(Language.Fuben.CreateTeam)
	btn_2:setTitleFontSize(22)
	btn_2:setTitleFontName(COMMON_CONSTS.FONT)
	btn_2:setTitleColor(COLOR3B.WHITE)
	-- 关闭
	local btn_close = XUI.CreateImageView(self.view_size.width + 24, self.view_size.height - 24, ResPath.GetCommon("btn_100"), true)

	self.root_node:addChild(btn_1, 3)
	self.root_node:addChild(btn_2, 3)
	self.root_node:addChild(btn_close, 3)
	XUI.AddClickEventListener(btn_1, BindTool.Bind(self.OnClickQuickMatch, self), true)
	XUI.AddClickEventListener(btn_2, BindTool.Bind(self.OnClickCreateTeam, self), true)
	XUI.AddClickEventListener(btn_close, BindTool.Bind(self.OnClickClose, self), true)

	-- 队伍列表
	team_list_w = self.view_size.width - 10
	self.team_list = ListView.New()
	self.team_list:CreateView({
		x = self.view_size.width / 2, y = self.view_size.height / 2 + 10,
		width = team_list_w, height = 150,
		direction = ScrollDir.Vertical,
		itemRender = HhjdTeamItemRender,
		-- bounce = false,
		-- gravity = ListViewGravity.CenterHorizontal,
		-- ui_config = self.ph_list.ph_guild_act_render,
	})
	self.team_list:SetItemsInterval(1)
	self.team_list:SetMargin(2)
	self.root_node:addChild(self.team_list:GetView(), 99)

	-- 队伍信息改变监听
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_HHJD_DATA, BindTool.Bind(self.OnFlushTeam, self))
end

function HhjdTeamView:ShowIndexCallBack(index)
	self:OnFlushTeam()
end

function HhjdTeamView:OnFlushTeam()
	self.team_list:SetDataList(FubenData.Instance:GetHhjdFbTeamListData())
end

function HhjdTeamView:OnClickClose()
	self:Close()
end

function HhjdTeamView:OnClickCreateTeam()
	FubenMutilCtrl.SendCreateTeam(FubenMutilType.Hhjd, FubenMutilId.Hhjd1)
end

function HhjdTeamView:OnClickQuickMatch()
	local max_num = FubenData.Instance:GetHhjdFbMaxNumber()
	local team_data = nil
	for _, v in pairs(FubenData.Instance:GetHhjdFbTeamListData()) do
		if v.state == 0 and v.menber_count < max_num then
			team_data = v
			break
		end
	end

	if team_data then
		FubenMutilCtrl.SendJoinTeamRequest(FubenMutilType.Hhjd, FubenMutilId.Hhjd1, team_data.team_id, FubenMutilLayer.Hhjd1)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Fuben.NoTeam)
	end
end

HhjdTeamItemRender = HhjdTeamItemRender or BaseClass(BaseRender)

function HhjdTeamItemRender:__init()
	self.render_size = cc.size(team_list_w - 4, 50)
	self.view:setContentSize(self.render_size)
end

function HhjdTeamItemRender:__delete()
end

function HhjdTeamItemRender:CreateChild()
	HhjdTeamItemRender.super.CreateChild(self)

	-- 队长名字
	self.leader_name = RichTextUtil.ParseRichText(nil, "", 20, COLOR3B.OLIVE, 110, self.render_size.height / 2, 10, 25)
	XUI.RichTextSetCenter(self.leader_name)
	self.view:addChild(self.leader_name, 9, 9)

	-- 队伍人数
	self.team_num = RichTextUtil.ParseRichText(nil, "0/0", 20, COLOR3B.OLIVE,
		self.render_size.width / 2 + 40, self.render_size.height / 2, 10, 25)
	XUI.RichTextSetCenter(self.team_num)
	self.view:addChild(self.team_num, 10, 10)

	-- 人数进度条
	self.loading_bar = XUI.CreateLoadingBar(self.render_size.width / 2 + 40, self.render_size.height / 2,
		ResPath.GetCommon("prog_hp"), XUI.IS_PLIST, ResPath.GetCommon("prog_bg"))
	self.loading_bar:setScaleX(0.6)
	self.view:addChild(self.loading_bar, 8, 8)

	-- 加入按钮
	local join_btn = XUI.CreateButton(self.render_size.width - 70, self.render_size.height / 2, 0, 0, false,
		ResPath.GetCommon("btn_118"), ResPath.GetCommon("btn_118"), "", XUI.IS_PLIST)
	join_btn:setScale(0.7)
	join_btn:setTitleText(Language.Fuben.JoinText)
	join_btn:setTitleFontSize(20)
	join_btn:setTitleFontName(COMMON_CONSTS.FONT)
	join_btn:setTitleColor(COLOR3B.WHITE)
	self.view:addChild(join_btn, 3, 3)
	XUI.AddClickEventListener(join_btn, BindTool.Bind(self.OnClickJoin, self), true)
	self.join_btn = join_btn
end

function HhjdTeamItemRender:OnFlush()
	if nil == self.data then
		return
	end

	local cur_num = self.data.menber_count
	local max_num = FubenData.Instance:GetHhjdFbMaxNumber()
	RichTextUtil.ParseRichText(self.leader_name, self.data.leader_name)
	RichTextUtil.ParseRichText(self.team_num, string.format("%d/%d", cur_num, max_num))
	self.loading_bar:setPercent( cur_num / max_num * 100)
	self.join_btn:setTitleText(self.data.state == 0 and Language.Fuben.JoinText or Language.Fuben.FightingText)
	XUI.SetButtonEnabled(self.join_btn, self.data.state == 0)
end

function HhjdTeamItemRender:OnClickJoin()
	FubenMutilCtrl.SendJoinTeamRequest(FubenMutilType.Hhjd, FubenMutilId.Hhjd1, self.data.team_id, FubenMutilLayer.Hhjd1)
end
