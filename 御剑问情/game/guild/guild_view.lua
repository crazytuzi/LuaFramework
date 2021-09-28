require("game/guild/guild_altar_view")
require("game/guild/guild_activity_view")
require("game/guild/guild_box_view")
require("game/guild/guild_information_view")
require("game/guild/guild_list_view")
require("game/guild/guild_member_view")
require("game/guild/guild_territory_view")
require("game/guild/guild_totem_view")
require("game/guild/guild_storge_view")
require("game/guild/guild_request_view")
require("game/guild/guild_maze_view")
require("game/guild/guild_donate_view")
require("game/guild/guild_war_view")
require("game/guild/guild_member_content")


GuildView = GuildView or BaseClass(BaseView)

-- 功能开启判断
-- 1为迷宫
local GuildFunNum = 1

local FunName =
{
	[1] = "guild_maze"
}
function GuildView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.guild_info
	self.donate_gold = 0
	self.donate_card = 0

	self.red_points = nil
	self.close_window = false
end

function GuildView:__delete()

end

function GuildView:LoadCallBack()
	self.red_points = {}
	for i = 1, 12 do
		self.red_points[i] = self:FindVariable("RedPoint" .. i)
	end
	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenAltar",
		BindTool.Bind(self.HandleOpenAltar, self))
	self:ListenEvent("OpenActivity",
		BindTool.Bind(self.HandleOpenActivity, self))
	self:ListenEvent("OpenBox",
		BindTool.Bind(self.HandleOpenBox, self))
	self:ListenEvent("OpenInformation",
		BindTool.Bind(self.HandleOpenInformation, self))
	self:ListenEvent("OpenList",
		BindTool.Bind(self.HandleOpenList, self))
	self:ListenEvent("OpenMember",
		BindTool.Bind(self.HandleOpenMember, self))
	self:ListenEvent("OpenTerritory",
		BindTool.Bind(self.HandleOpenTerritory, self))
	self:ListenEvent("OpenTotem",
		BindTool.Bind(self.HandleOpenTotem, self))
	self:ListenEvent("OpenStorge",
		BindTool.Bind(self.HandleOpenStorge, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OpenWar",
		BindTool.Bind(self.HandleOpenWar, self))
	-- self:ListenEvent("OnCardPlus",
	-- 	BindTool.Bind(self.OnCardPlus, self))
	-- self:ListenEvent("OnCardReduce",
	-- 	BindTool.Bind(self.OnCardReduce, self))
	-- self:ListenEvent("OnCardMax",
	-- 	BindTool.Bind(self.OnCardMax, self))
	-- self:ListenEvent("OnGoldPlus",
	-- 	BindTool.Bind(self.OnGoldPlus, self))
	-- self:ListenEvent("OnGoldReduce",
	-- 	BindTool.Bind(self.OnGoldReduce, self))
	-- self:ListenEvent("OnGoldMax",
	-- 	BindTool.Bind(self.OnGoldMax, self))
	-- self:ListenEvent("OnCardDonate",
	-- 	BindTool.Bind(self.OnCardDonate, self))
	-- self:ListenEvent("OnGoldDonate",
	-- 	BindTool.Bind(self.OnGoldDonate, self))
	-- self:ListenEvent("OnClickGoldInput",
	-- 	BindTool.Bind(self.OnClickGoldInput, self))
	-- self:ListenEvent("OnClickCardInput",
	-- 	BindTool.Bind(self.OnClickCardInput, self))
	self:ListenEvent("OnClickWuZi",
		BindTool.Bind(self.OnClickWuZi, self))
	self:ListenEvent("OpenMaze",
		BindTool.Bind(self.HandleOpenMaze, self))
	self:ListenEvent("OpenMemberContent",
		BindTool.Bind(self.HandleOpenMemberContent, self))

	self.view_list = {}
	-- 子面板
	self.info_content = self:FindObj("InformationContent")
	self.box_content = self:FindObj("BoxContent")
	self.altar_content = self:FindObj("AltarContent")
	self.totem_content = self:FindObj("TotemContent")
	self.activity_content = self:FindObj("ActivityContent")
	self.storge_content = self:FindObj("StorgeContent")
	self.requset_content = self:FindObj("RequestContent")
	self.maze_content = self:FindObj("MazeContent")
	self.guildwar_content = self:FindObj("GuildWarContent")
	self.guild_menber_content = self:FindObj("GuildMemberContent")

	self.info_and_member_content = self:FindObj("InfoMember")

	-- 页签
	self.toggle_list = {}
	self.toggle_list[TabIndex.guild_info] = self:FindObj("TabInformation")
	-- self.toggle_list[2] = self:FindObj("TabMember")
	self.toggle_list[TabIndex.guild_box] = self:FindObj("TabBox")
	self.toggle_list[TabIndex.guild_altar] = self:FindObj("TabAltar")
	-- self.toggle_list[5] = self:FindObj("TabTotems")
	-- self.toggle_list[6] = self:FindObj("TabTerritory")
	self.toggle_list[TabIndex.guild_activity] = self:FindObj("TabActivity")
	-- self.toggle_list[8] = self:FindObj("TabGuildList")
	self.toggle_list[TabIndex.guild_storge] = self:FindObj("TabGuildStorge")
	self.toggle_list[TabIndex.guild_maze] = self:FindObj("TabMaze")
	self.toggle_list[TabIndex.guild_war] = self:FindObj("TabWar")
	self.toggle_list[TabIndex.guild_member] = self:FindObj("TabMemberList")

	for k, v in pairs(self.toggle_list) do
		v.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, k))
	end

	self.is_into_guild_show = self:FindVariable("IsIntoGulidShow")
	self.variable_gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.has_guild = self:FindVariable("HasGuild")

	self.donate_window = GuildDonateView.New()

	self.check_fun_open = {}
	for i=1,GuildFunNum do
		self.check_fun_open[i] = self:FindVariable("CheckFunOpen" .. i)
	end

	--需要引导的按钮
	self.btn_close = self:FindObj("BtnClose")

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Guild, BindTool.Bind(self.GetUiCallBack, self))

	self:OnOpen()

	self:Flush()

	GuildCtrl.Instance:GuildViewOpen()
	GuildData.HasOpenGuild = true
	RemindManager.Instance:Fire(RemindName.NoGuild)
end

function GuildView:OnToggleChange(index, ison)
	if ison and self.show_index ~= index then
		self:ShowIndex(index)
		if index ~= 3 then
			if self.box_view then
				self.box_view:CloseTips()
			end
		end
	end
end

function GuildView:OpenCallBack()
	self.open_trigger = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self.data_listen = BindTool.Bind(self.OnFlushGold, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
	if tuanzhang_uid and tuanzhang_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(tuanzhang_uid)
	end
	GuildCtrl.Instance:SendAllGuildInfoReq()
	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		ClashTerritoryCtrl.SendTerritoryWarQualification()
		GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
	end
	self:ShowOrHideTab()
end

function GuildView:CloseCallBack()
	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end
	GlobalTimerQuest:CancelQuest(self.open_create_timer)
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.maze_view then
		self.maze_view:ResetAnimatorState()
	end
end

function GuildView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Guild)
	end

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	if self.member_view then
		self.member_view:DeleteMe()
		self.member_view = nil
	end
	if self.box_view then
		self.box_view:DeleteMe()
		self.box_view = nil
	end
	if self.altar_view then
		self.altar_view:DeleteMe()
		self.altar_view = nil
	end
	if self.totem_view then
		self.totem_view:DeleteMe()
		self.totem_view = nil
	end
	if self.territory_view then
		self.territory_view:DeleteMe()
		self.territory_view = nil
	end
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	-- if self.boss_view then
	-- 	self.boss_view:DeleteMe()
	-- 	self.boss_view = nil
	-- end
	if self.storge_view then
		self.storge_view:DeleteMe()
		self.storge_view = nil
	end
	if self.request_view then
		self.request_view:DeleteMe()
		self.request_view = nil
	end
	if self.activity_view then
		self.activity_view:DeleteMe()
		self.activity_view = nil
	end
	if self.maze_view then
		self.maze_view:DeleteMe()
		self.maze_view = nil
	end
	if self.donate_window then
		self.donate_window:DeleteMe()
		self.donate_window = nil
	end
	if self.guildwar_view then
		self.guildwar_view:DeleteMe()
		self.guildwar_view = nil
	end
	if self.guild_member_view then
		self.guild_member_view:DeleteMe()
		self.guild_member_view = nil
	end

	-- 清理变量和对象
	self.red_points = nil
	self.info_content = nil
	self.box_content = nil
	self.altar_content = nil
	self.totem_content = nil
	-- self.territory_content = nil
	self.activity_content = nil
	self.storge_content = nil
	self.requset_content = nil
	self.info_and_member_content = nil
	self.toggle_list = nil
	self.variable_gold = nil
	self.bind_gold = nil
	self.has_guild = nil
	self.variables = nil
	self.btn_close = nil
	self.guild_auto_enter_btn = nil
	self.maze_content = nil
	self.guildwar_content = nil
	self.guild_menber_content = nil
	self.is_into_guild_show = nil
	self.check_fun_open = nil
end

function GuildView:ShowOrHideTab()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id < 1 then
		return
	end
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[TabIndex.guild_info] = open_fun_data:CheckIsHide("guild_info")
	-- show_list[2] = open_fun_data:CheckIsHide("guild_member")
	show_list[TabIndex.guild_box] = open_fun_data:CheckIsHide("guild_box")
	show_list[TabIndex.guild_altar] = open_fun_data:CheckIsHide("guild_altar")
	-- show_list[5] = open_fun_data:CheckIsHide("guild_totem")
	-- show_list[6] = open_fun_data:CheckIsHide("guild_territory")
	 show_list[TabIndex.guild_activity] = open_fun_data:CheckIsHide("guild_activity")
	-- show_list[8] = open_fun_data:CheckIsHide("guild_list")
	-- show_list[TabIndex.guild_storge] = open_fun_data:CheckIsHide("guild_storge")
	show_list[TabIndex.guild_maze] = open_fun_data:CheckIsHide("guild_maze")
	show_list[TabIndex.guild_war] = open_fun_data:CheckIsHide("guild_war")
	show_list[TabIndex.guild_member] = open_fun_data:CheckIsHide("guild_info")

	for k,v in pairs(show_list) do
		self.toggle_list[k]:SetActive(v)
	end
end

function GuildView:AsyncLoadView(index)
	if index == TabIndex.guild_info and not self.info_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "InformationContent",
			function(obj)
				obj.transform:SetParent(self.info_content.transform, false)
				obj = U3DObject(obj)
				self.info_view = GuildInfoView.New(obj)
				self.view_list[TabIndex.guild_info] = self.info_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_box and not self.box_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "BoxContent",
			function(obj)
				obj.transform:SetParent(self.box_content.transform, false)
				obj = U3DObject(obj)
				self.box_view = GuildBoxView.New(obj)
				self.view_list[TabIndex.guild_box] = self.box_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_altar and not self.altar_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "AltarContent",
			function(obj)
				obj.transform:SetParent(self.altar_content.transform, false)
				obj = U3DObject(obj)
				self.altar_view = GuildAltarView.New(obj)
				self.view_list[TabIndex.guild_altar] = self.altar_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_totem and not self.totem_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "TotemContent",
			function(obj)
				obj.transform:SetParent(self.totem_content.transform, false)
				obj = U3DObject(obj)
				self.totem_view = GuildTotemView.New(obj)
				self.view_list[TabIndex.guild_totem] = self.totem_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_activity and not self.activity_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "GuildActivity",
			function(obj)
				obj.transform:SetParent(self.activity_content.transform, false)
				obj = U3DObject(obj)
				self.activity_view = GuildActivityView.New(obj)
				self.view_list[TabIndex.guild_activity] = self.activity_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_storge and not self.storge_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "GuildsStorge",
			function(obj)
				obj.transform:SetParent(self.storge_content.transform, false)
				obj = U3DObject(obj)
				self.storge_view = GuildStorgeView.New(obj)
				self.view_list[TabIndex.guild_storge] = self.storge_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_request and not self.request_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "GuildRequest",
			function(obj)
				obj.transform:SetParent(self.requset_content.transform, false)
				obj = U3DObject(obj)
				self.request_view = GuildRequestView.New(obj)
				self.view_list[TabIndex.guild_request] = self.request_view
				self.guild_auto_enter_btn = self.request_view:GetAutoBtn()
				self:Flush()
			end)
	end
	if index == TabIndex.guild_maze and not self.maze_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "MazeContent",
			function(obj)
				obj.transform:SetParent(self.maze_content.transform, false)
				obj = U3DObject(obj)
				self.maze_view = GuildMazeView.New(obj)
				self.view_list[TabIndex.guild_maze] = self.maze_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_war and not self.guildwar_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "GuildWarContent",
			function(obj)
				obj.transform:SetParent(self.guildwar_content.transform, false)
				obj = U3DObject(obj)
				self.guildwar_view = GuildWarView.New(obj)
				self.view_list[TabIndex.guild_war] = self.guildwar_view
				self:Flush()
			end)
	end
	if index == TabIndex.guild_member and not self.guild_member_view then
		UtilU3d.PrefabLoad("uis/views/guildview_prefab", "MembersTabContent",
			function(obj)
				obj.transform:SetParent(self.guild_menber_content.transform, false)
				obj = U3DObject(obj)
				self.guild_member_view = GuildMemberContent.New(obj)
				self.view_list[TabIndex.guild_member] = self.guild_member_view
				self:Flush()
			end)
	end
end

function GuildView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id < 1 then
		return
	end

	for k,v in pairs(self.toggle_list) do
		v.toggle.isOn = false
	end

	if index == TabIndex.guild_info then
		self.toggle_list[TabIndex.guild_info].toggle.isOn = true
		self:HandleOpenInformation()
	elseif index == TabIndex.guild_box then
		self.toggle_list[TabIndex.guild_box].toggle.isOn = true
		self:HandleOpenBox()
	elseif index == TabIndex.guild_altar or  index == TabIndex.guild_totem then
		self.toggle_list[TabIndex.guild_altar].toggle.isOn = true
	elseif index == TabIndex.guild_territory then
		self.toggle_list[TabIndex.guild_territory].toggle.isOn = true
		self:HandleOpenTerritory()
	elseif index == TabIndex.guild_activity then
		self.toggle_list[TabIndex.guild_activity].toggle.isOn = true
		self:HandleOpenActivity()
	elseif index == TabIndex.guild_storge then
		self.toggle_list[TabIndex.guild_storge].toggle.isOn = true
		self:HandleOpenStorge()
	elseif index == TabIndex.guild_donate then
		self.toggle_list[TabIndex.guild_donate].toggle.isOn = true
		self:HandleOpenInformation()
		self:SetWindowSwitch(false)
		self:HandleOpenDonate()
	elseif index == TabIndex.guild_maze then
		self.toggle_list[TabIndex.guild_maze].toggle.isOn = true
		self:HandleOpenMaze()
	elseif index == TabIndex.guild_war then
		self.toggle_list[TabIndex.guild_war].toggle.isOn = true
		self:HandleOpenWar()
	elseif index == TabIndex.guild_member then
		self.toggle_list[TabIndex.guild_member].toggle.isOn = true
		self:HandleOpenMemberContent()
	else
		self:ShowIndex(TabIndex.guild_info)
	end
end

function GuildView:OnOpen()
	GuildCtrl.Instance:InitGuildView()
end

-- 当没有加入公会时VIew面板的初始化
function GuildView:InitViewCase1()
	for k,v in pairs(self.toggle_list) do
		v:SetActive(false)
	end
	self.is_into_guild_show:SetValue(true)
	if self:IsLoaded() then
		self:ShowOrHideTab()
		self:SetWindowSwitch(true)
		self.info_and_member_content:SetActive(false)
		self.box_content:SetActive(false)
		self.totem_content:SetActive(false)
		self.storge_content:SetActive(false)
		-- self.territory_content:SetActive(false)
		self.altar_content:SetActive(false)
		self.activity_content:SetActive(false)
		self.requset_content:SetActive(true)
		self.has_guild:SetValue(false)
		for i=1,GuildFunNum do
			local open_fun_data = OpenFunData.Instance
			local flag = open_fun_data:CheckIsHide(FunName[i])
			self.check_fun_open[i]:SetValue(flag)
		end
		self:CloseAllWindow()
		self:Flush()
	end
end

-- 当加入公会后VIew面板的初始化
function GuildView:InitViewCase2()
	if self:IsLoaded() then
		self:ShowOrHideTab()
		self:ShowIndex(TabIndex.guild_info)
		self:SetWindowSwitch(true)
		self.has_guild:SetValue(true)
		self.info_and_member_content:SetActive(true)
		self:CloseAllWindow()
		for i=1,GuildFunNum do
			local open_fun_data = OpenFunData.Instance
			local flag = open_fun_data:CheckIsHide(FunName[i])
			self.check_fun_open[i]:SetValue(flag)
		end
		self.is_into_guild_show:SetValue(false)
	end
end

--点击关闭按钮
function GuildView:HandleClose()
	self:CloseAllWindow()
	ViewManager.Instance:Close(ViewName.Guild)
end

--点击信息按钮
function GuildView:HandleOpenInformation()
	self:ShowIndex(TabIndex.guild_info)
	self:CloseAllWindow()
	GuildCtrl.Instance:SendGuildInfoReq()
end

--点击成员按钮
function GuildView:HandleOpenMember()
	self.show_index = TabIndex.guild_member
	self:CloseAllWindow()
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
end

--点击宝箱按钮
function GuildView:HandleOpenBox()
	self.show_index = TabIndex.guild_box
	self:CloseAllWindow()
	if self.box_view then
		self.box_view:CloseColorList()
		self.box_view:ShowColorList()
		self.box_view:Flush()
	end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
end

--点击技能按钮
function GuildView:HandleOpenAltar()
	self:CloseAllWindow()
	if self.altar_view then
		self.altar_view.show_effect:SetValue(false)
		self.altar_view:Flush()
	end
end

--点击旗帜按钮
function GuildView:HandleOpenTotem()
	self:ShowIndex(TabIndex.guild_totem)
	self.show_index = TabIndex.guild_totem
	self:CloseAllWindow()
	if self.totem_view then
		self.totem_view:Flush()
	end
end

function GuildView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击领地按钮
function GuildView:HandleOpenTerritory()
	self.show_index = TabIndex.guild_territory
	self:CloseAllWindow()
	ClashTerritoryCtrl.SendTerritoryWarQualification()
	if self.territory_view then
		self.territory_view:Flush()
	end
end

--点击列表按钮
function GuildView:HandleOpenList()
	self.show_index = TabIndex.guild_list
	self:CloseAllWindow()
	GuildCtrl.Instance:SendAllGuildInfoReq()
	GuildCtrl.Instance:SendGuildExchangeReq()
end

--点击活动按钮
function GuildView:HandleOpenActivity()
	self.show_index = TabIndex.guild_activity
	self:CloseAllWindow()
	if self.activity_view then
		self.activity_view:Flush()
	end
end

--点击仓库按钮
function GuildView:HandleOpenStorge()
	self.show_index = TabIndex.guild_storge
	self:CloseAllWindow()
	GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_REQ_INFO)
end

--点击成员按钮
function GuildView:HandleOpenMemberContent()
	self.show_index = TabIndex.guild_member
	self:CloseAllWindow()
	if self.guild_member_view then
		self.guild_member_view:Flush()
	end
end

--点击盟战按钮
function GuildView:HandleOpenWar()
	self.show_index = TabIndex.guild_war
	self:CloseAllWindow()
	if self.guildwar_view then
		self.guildwar_view:Flush()
		self.guildwar_view:SetAnimTime()
	end
	RankCtrl.Instance:SendGetGuildRankListReq(GUILD_RANK_TYPE.GUILD_RANK_TYPE_GUILDBATTLE)
	GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_INFO_REQ)
end

-- 点击迷宫
function GuildView:HandleOpenMaze()
	self.show_index = TabIndex.guild_maze
	self:CloseAllWindow()
	if self.maze_view then
		self.maze_view:Flush()
		self.maze_view:ResetAnimatorState()
	end
	GuildCtrl.Instance:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_GET_INFO)
	RemindManager.Instance:AddNextRemindTime(RemindName.GuildMaze, nil, RemindName.Guild)
end

function GuildView:OnClickWuZi()
	TipsCtrl.Instance:OpenItem({item_id = GuildData.Instance:GetGuildJianSheId() or 0, num = 1})
end

-- 设置弹窗状态
function GuildView:SetWindowSwitch(switch)
	self.close_window = switch or false
end

-- 刷新公会
function GuildView:OnFlush(param_t)
	if self.info_view and self.show_index == TabIndex.guild_info then
		local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
		if tuanzhang_uid and tuanzhang_uid > 0 then
			CheckCtrl:SendQueryRoleInfoReq(tuanzhang_uid)
		end
	end
	self:OnFlushGold()
	self:FlushRedPoint()
	self:FlushCurrentView()

	if self.donate_window then
		self.donate_window:Flush()
	end

	if self.close_window then
		self.close_window = false
		self:CloseAllWindow()
	end
	for k,v in pairs(param_t) do
		if k == "CreateGuild" and nil == self.open_create_timer then
			self.open_create_timer = GlobalTimerQuest:AddDelayTimer(function ()
				self.request_view:CreateGuildByItem()
				self.open_create_timer = nil
			end, 0.5)
		elseif k == "guild_maze" then
			if self.maze_view then
				self.maze_view:Flush()
			end
		elseif k == "guild_war" then
			if self.guildwar_view then
				self.guildwar_view:Flush()
			end
		end
	end
end

--打开捐赠面板
function GuildView:HandleOpenDonate()
	self.donate_window:Open()
	if self.donate_window then
		self.donate_window:Flush()
	end
end

-- 刷新列表
function GuildView:OnFlushListView()
	if not self.is_open then
		return
	end
	self.list_view:Flush()
end

-- 刷新成员
function GuildView:OnFlushMember()
	if not self.is_open then
		return
	end
	self.member_view:Flush()
end

-- 刷新信息
function GuildView:OnFlushInfo()
	if not self.is_open then
		return
	end
	self.info_view:Flush()
end

-- 关闭所有弹窗
function GuildView:CloseAllWindow()
	if self.is_open then
		if self.info_view then
			self.info_view:CloseAllWindow()
		end
		if self.member_view then
			self.member_view:CloseAllWindow()
		end
		if self.list_view then
			self.list_view:CloseAllWindow()
		end
		if self.totem_view then
			self.totem_view:CloseAllWindow()
		end
		if self.request_view then
			self.request_view:CloseAllWindow()
		end
		if self.donate_window then
			self.donate_window:Close()
		end
	end
end

-- 刷新钻石
function GuildView:OnFlushGold(attr_name)
	if not self.is_open then
		return
	end
	if not self.variable_gold or not self.bind_gold then
		return
	end
	if attr_name == nil or attr_name == "bind_gold" or attr_name == "gold" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if not vo then return end
		local count = vo.gold
		if not count or count == "" then count = 0 end
		self.variable_gold:SetValue(CommonDataManager.ConverMoney(count))

		bind_count = vo.bind_gold
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(bind_count))
	end
end

-- 刷新当前界面
function GuildView:FlushCurrentView()
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		self:ShowIndex(TabIndex.guild_request)
	end
	local now_view = self.view_list[self.show_index]
	if now_view then
		now_view:Flush()
	end
end

function GuildView:FlushRedPoint()
	local red_point_list = GuildData.Instance:GetReminder()
	for k,v in pairs(red_point_list) do
		self:SetRedPoint(k, v)
	end
	if self.red_points then
		if red_point_list[Guild_PANEL.altar] or red_point_list[Guild_PANEL.totem] then
			self.red_points[10]:SetValue(true)
		else
			self.red_points[10]:SetValue(false)
		end
	end
	if red_point_list[Guild_PANEL.maze] == false then
		GuildCtrl.Instance:StartGuildMazeTimeQuest() 		--十分钟后提醒
	end
end

function GuildView:SetRedPoint(index, switch)
	if not switch then
		switch = false
	end
	if self.red_points and self.red_points[index] then
		self.red_points[index]:SetValue(switch)
	end
end

function GuildView:FlushRequest()
	if self.request_view then
		self.request_view:FlushGuildDetails()
	end
end

-- ------------------------------------------------------------ 捐赠面板 ------------------------------------------------------------------------------

-- --刷新捐赠面板
-- function GuildView:FlushDonate()
-- 	self.card = 0
-- 	local card_id = GuildData.Instance:GetGuildJianSheId()
-- 	if card_id then
-- 		self.card = ItemData.Instance:GetItemNumInBagById(card_id)
-- 	end
-- 	self.variables.card:SetValue(self.card)

-- 	self.variables.gold_input:SetValue(0)
-- 	self.variables.card_input:SetValue(self.card)
-- 	self.donate_gold = 0
-- 	self.donate_card = self.card

-- 	local guild_gongxian = GuildData.Instance:GetGuildGongxian()
-- 	local guild_total_gongxian = GuildData.Instance:GetGuildTotalGongxian()
-- 	self.variables.contribution_self:SetValue(guild_gongxian)

-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
-- 	self.gold = vo.gold
-- 	self.variables.gold:SetValue(self.gold)

-- 	local exp = CommonDataManager.ConverMoney(GuildDataConst.GUILDVO.guild_exp)
-- 	self.variables.zi_jin:SetValue(exp)
-- end

-- --增加捐献令牌
-- function GuildView:OnCardPlus()
-- 	self.donate_card = self.donate_card + 1
-- 	if(self.donate_card > self.card) then
-- 		self.donate_card = self.card
-- 	end
-- 	self.variables.card_input:SetValue(self.donate_card)
-- end

-- --减少捐献令牌
-- function GuildView:OnCardReduce()
-- 	self.donate_card = self.donate_card - 1
-- 	if(self.donate_card < 0) then
-- 		self.donate_card = 0
-- 	end
-- 	self.variables.card_input:SetValue(self.donate_card)
-- end

-- --最大捐献令牌
-- function GuildView:OnCardMax()
-- 	self.donate_card = self.card
-- 	self.variables.card_input:SetValue(self.donate_card)
-- end

-- --捐献令牌
-- function GuildView:OnCardDonate()
-- 	if self.donate_card > 0 then
-- 		local card_id = GuildData.Instance:GetGuildJianSheId()
-- 		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_ITEM, 0, 0, {{item_id = card_id, item_num = self.donate_card}})
-- 	end
-- end

-- --增加捐献钻石
-- function GuildView:OnGoldPlus()
-- 	self.donate_gold = self.donate_gold + 10
-- 	if(self.donate_gold > self.gold) then
-- 		self.donate_gold = self.gold
-- 	end
-- 	self.variables.gold_input:SetValue(self.donate_gold)
-- end

-- --减少捐献钻石
-- function GuildView:OnGoldReduce()
-- 	self.donate_gold = self.donate_gold - 10
-- 	if(self.donate_gold < 0) then
-- 		self.donate_gold = 0
-- 	end
-- 	self.variables.gold_input:SetValue(self.donate_gold)
-- end

-- --最大捐献钻石
-- function GuildView:OnGoldMax()
-- 	self.donate_gold = self.gold
-- 	self.variables.gold_input:SetValue(self.donate_gold)
-- end

-- --捐献钻石
-- function GuildView:OnGoldDonate()
-- 	local num = self.donate_gold
-- 	if num > 0 then
-- 		GuildCtrl.Instance:SendAddGuildExpReq(ADD_GUILD_EXP_TYPE.ADD_GUILD_EXP_TYPE_GOLD, num, 1, {})
-- 	end
-- end

-- -- 点击钻石输入框
-- function GuildView:OnClickGoldInput()
-- 	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.GoldInputEnd, self), nil, self.gold)
-- end

-- function GuildView:GoldInputEnd(str)
-- 	local num = tonumber(str)
-- 	if(num < 0) then
-- 		num = 0
-- 	elseif(num > self.gold) then
-- 		num = self.gold
-- 	end
-- 	self.donate_gold = num
-- 	self.variables.gold_input:SetValue(num)
-- end

-- -- 点击令牌输入框
-- function GuildView:OnClickCardInput()
-- 	TipsCtrl.Instance:OpenCommonInputView(0, BindTool.Bind(self.CardInputEnd, self), nil, self.card)
-- end

-- function GuildView:CardInputEnd(str)
-- 	local num = tonumber(str)
-- 	if(num < 0) then
-- 		num = 0
-- 	elseif(num > self.card) then
-- 		num = self.card
-- 	end
-- 	self.donate_card = num
-- 	self.variables.card_input:SetValue(num)
-- end

function GuildView:CheckLevelUp()
	if self.show_index == TabIndex.guild_altar then
		self.altar_view:CheckLevelUp()
	end
end


function GuildView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end