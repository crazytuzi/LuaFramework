-- 行会活动
local GuildActivityView = GuildActivityView or BaseClass(SubView)

local function GetGuildActListData()
	return {
		{
			act_name = Language.Guild.ActName[1],
			act_info_content = Language.Guild.GuildActTimeContents[1],
			img_act_path = ResPath.GetBigPainting("guild_activity_bg1"),
			reward_cfg = ActivityData.GetOneTypeActivityAwardCfg(DAILY_ACTIVITY_TYPE.GONG_CHENG),
			btn_enter_func = function()
				Scene.SendQuicklyTransportReqByNpcId(NPC_ID.GCZ)
			end,
			tip_content = nil,
			index = 1,
		},
		-- {
		-- 	act_name = Language.Guild.ActName[3],
		-- 	act_info_content = string.format(Language.Guild.GuildActTimeContents[3], FubenData.Instance:GetEnterHhjdMaxTimes(), FubenData.Instance:GetLeftHhjdTimes()),
		-- 	img_act_path = ResPath.GetBigPainting("guild_activity_bg3"),
		-- 	reward_cfg = FubenData.FubenCfg[FubenType.Hhjd][1].client_items,
		-- 	btn_enter_func = function()
		-- 		if FubenData.Instance:GetLeftHhjdTimes() > 0 then
		-- 			ViewManager.Instance:OpenViewByDef(ViewDef.HhjdTeam)
		-- 		else
		-- 			SysMsgCtrl.Instance:FloatingTopRightText(Language.Guild.HhjdNoTimes)
		-- 		end
		-- 	end,
		-- 	tip_content = FubenData.FubenCfg[FubenType.Hhjd][1].TipContent,
		-- index = 2,
		-- },
		{
			act_name = Language.Guild.ActName[2],
			act_info_content = Language.Guild.GuildActTimeContents[2],
			img_act_path = ResPath.GetBigPainting("guild_activity_bg2"),
			reward_cfg = ActivityData.GetOneTypeActivityAwardCfg(DAILY_ACTIVITY_TYPE.HANG_HUI),
			btn_enter_func = function()
				Scene.SendQuicklyTransportReqByNpcId(NPC_ID.HHCG)
			end,
			tip_content = nil,
			index = 3,
		},
	}
end

function GuildActivityView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
	{"guild_ui_cfg", 14, {0}},
	}
end

function GuildActivityView:LoadCallBack()
	local list_ph = self.ph_list.ph_guild_act_list
	self.guild_act_list = ListView.New()
	self.guild_act_list:CreateView({
		x = list_ph.x, y = list_ph.y,
		width = list_ph.w, height = list_ph.h,
		direction = ScrollDir.Horizontal,
		itemRender = GuildActItemRender,
		bounce = false,
		gravity = ListViewGravity.CenterHorizontal,
		ui_config = self.ph_list.ph_guild_act_render,
	})
	self.guild_act_list:SetItemsInterval(2)
	self.guild_act_list:SetMargin(1)
	self.node_t_list.layout_guild_activitys.node:addChild(self.guild_act_list:GetView(), 99)
end

function GuildActivityView:ReleaseCallBack()
	if nil ~= self.guild_act_list then
		self.guild_act_list:DeleteMe()
		self.guild_act_list = nil
	end
end

function GuildActivityView:ShowIndexCallBack()
	self:OnFlushActivityView()
end

function GuildActivityView:OnFlushActivityView()
	self.guild_act_list:SetDataList(GetGuildActListData())
end

GuildActItemRender = GuildActItemRender or BaseClass(BaseRender)

function GuildActItemRender:__init()
	self.cell_list = {}
end

function GuildActItemRender:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function GuildActItemRender:CreateChild()
	GuildActItemRender.super.CreateChild(self)

	local ph_start = self.ph_list.ph_act_cell_start
	local ph_end = self.ph_list.ph_act_cell_end
	local interval_w = (ph_end.x - ph_start.x) / 3
	for i = 1, 4 do
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph_start.x + (i - 1) * interval_w, ph_start.y)
		cell:GetView():setAnchorPoint(0.5, 0.5)
		self.view:addChild(cell:GetView(), 10)
		self.cell_list[#self.cell_list + 1] = cell
	end

	self.node_tree.btn_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree.btn_enter_act.node, BindTool.Bind(self.OnClickEnterBtn, self))
	XUI.AddClickEventListener(self.node_tree.btn_tip.node, BindTool.Bind(self.OnClickTip, self))
end

function GuildActItemRender:OnFlush()
	if nil == self.data then
		return
	end
	self.node_tree.btn_tip.node:setVisible(nil ~= self.data.tip_content)
	-- self.node_tree.lbl_act_name.node:setString(self.data.act_name)
	self.node_tree.lbl_act_name.node:loadTexture(ResPath.GetGuild("guild_act_" .. self.data.index))
	self.node_tree.img_act_pic.node:loadTexture(self.data.img_act_path)
	RichTextUtil.ParseRichText(self.node_tree.rich_act_info.node, self.data.act_info_content)
	for k, v in pairs(self.cell_list) do
		v:SetData(self.data.reward_cfg[k])
	end
end

function GuildActItemRender:OnClickEnterBtn()
	if self.data.btn_enter_func then
		self.data.btn_enter_func()
	end
end

function GuildActItemRender:OnClickTip()
	DescTip.Instance:SetContent(self.data.tip_content or "", Language.Fuben.CallBossTitle)
end

function GuildActItemRender:CreateSelectEffect()
end

return GuildActivityView