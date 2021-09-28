require("game/guild/guild_info_operation_view")
require("game/guild/guild_info_notice_view")

GuildInfoView = GuildInfoView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate

function GuildInfoView:__init(instance)
	if instance == nil then
		return
	end

	self.variables = {}
	self.variables.role_name = self:FindVariable("RoleName")
	self.variables.guild_name = self:FindVariable("GuildName")
	self.variables.guild_rank = self:FindVariable("GuildRank")
	self.variables.guild_level = self:FindVariable("GuildLevel")
	self.variables.guild_count = self:FindVariable("GuildCount")
	self.variables.guild_gold = self:FindVariable("GuildGold")
	self.variables.guild_notice = self:FindVariable("GuildNotice")
	-- self.variables.red_point_apply = self:FindVariable("PointRedApply")
	self.variables.red_point_operation = self:FindVariable("PointRedOperation")
	self.variables.red_point_fuli = self:FindVariable("PointRedFuLi")
	-- self.variables.red_point_hongbao = self:FindVariable("PointRedHongbao")
	-- self.variables.exit_guild = self:FindVariable("ExitGuild")
	self.variables.show_notice_button = self:FindVariable("ShowNoticeButton")
	self.variables.show_invite_btn = self:FindVariable("ShowInviteBtn")
	-- self.variables.show_delate_btn = self:FindVariable("ShowDelateBtn")
	self.variables.show_icon = self:FindVariable("ShowIcon")
	self.variables.guild_exp = self:FindVariable("GuildExp")
	self.variables.red_point_donate = self:FindVariable("PointRedDonate")
	self.variables.show_auto_kick = self:FindVariable("ShowAutoKick")
	self.variables.has_guild = self:FindVariable("has_guild")
	self.variables.portrait = self:FindVariable("Portrait")
	self.variables.portrait_image = self:FindObj("PortraitImage")
	self.variables.portrait_raw = self:FindObj("PortraitRaw")

	-- self.input_field = self:FindObj("InputField"):GetComponent("InputField")
	self.notice_window = GuildInfoNoticeView.New()
	-- self.operation_window = self:FindObj("OperationWindow")
	self.auto_kick_toggle = self:FindObj("AutoKickToggle").toggle
	--self.auto_kick_toggle.isOn = GuildDataConst.GUILDVO.is_auto_clear == 1
	self.auto_kick_toggle.isOn = false
	self.role_display = self:FindObj("RoleDisplay")

	self.operation_window = GuildInfoOperationView.New()

	self.show_signin_red_point = self:FindVariable("ShowSigninRedPoint")	-- 签到小红点
	self.show_guild_head_red_point = self:FindVariable("ShowGuildHeadRedPoint") --公会头像小红点

	-- self:ListenEvent("OnNoticeChange",
	-- 	BindTool.Bind(self.OnNoticeChange, self))
	self:ListenEvent("OpenNotice",
		BindTool.Bind(self.HandleOpenNotice, self))
	-- self:ListenEvent("OnQuitGuild",
	-- 	BindTool.Bind(self.QuitGuild, self))
	-- self:ListenEvent("OnGuildCheckCanDelate",
	-- 	BindTool.Bind(self.SendGuildCheckCanDelate, self))
	-- self:ListenEvent("OpenInvite",
	-- 	BindTool.Bind(self.OpenInvite, self))
	-- self:ListenEvent("OnOpenApplyWindow",
	-- 	BindTool.Bind(self.OnOpenApplyWindow, self))
	self:ListenEvent("OnOpenOperation",
		BindTool.Bind(self.OnOpenOperation, self))
	self:ListenEvent("OnClose",
		BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickGuildFight",
		BindTool.Bind(self.OnClickGuildFight, self))
	self:ListenEvent("OnClickEnterStation",
		BindTool.Bind(self.EnterStation, self))
	self:ListenEvent("OnClickChat",
		BindTool.Bind(self.OnClickChat, self))
	self:ListenEvent("OnClickReward",
		BindTool.Bind(self.OnClickReward, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickRename",
		BindTool.Bind(self.OnClickRename, self))
	self:ListenEvent("OnClickInvite",
		BindTool.Bind(self.OnClickInvite, self))
	self:ListenEvent("OnClickDonate",
		BindTool.Bind(self.OnClickDonate, self))
	self:ListenEvent("OnClickPlus",
		BindTool.Bind(self.OnClickPlus, self))
	-- self:ListenEvent("OpenHongBaoView",
	-- 	BindTool.Bind(self.OpenHongBaoView, self))
	self:ListenEvent("OnClickAutoKickOut",
		BindTool.Bind(self.OnClickAutoKickOut, self))
	self:ListenEvent("OnClickList",
		BindTool.Bind(self.OnClickList, self))
	self:ListenEvent("OnClickMeber",
		BindTool.Bind(self.OnClickMeber, self))
	self:ListenEvent("OnClickChangePortrait",
		BindTool.Bind(self.OnClickChangePortrait, self))
	self.guild_head_change = GlobalEventSystem:Bind(ObjectEventType.GUILD_HEAD_CHANGE,
		BindTool.Bind(self.Flush, self))


	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))

	self.current_setting_model = 1
	self.apply_click = false
	self.last_flush_time = 0
	-- self:initInviteWindow()
end

function GuildInfoView:__delete()
	if(self.cell_list ~= nil) then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if nil ~= self.notice_window then
		self.notice_window:DeleteMe()
		self.notice_window = nil
	end

	if nil ~= self.operation_window then
		self.operation_window:DeleteMe()
		self.operation_window = nil
	end

	if nil ~= self.guild_head_change then
		GlobalEventSystem:UnBind(self.guild_head_change)
		self.guild_head_change = nil
	end

	self.show_signin_red_point = nil
	self.show_guild_head_red_point = nil
end

function GuildInfoView:Flush()
	self.variables.role_name:SetValue(GuildDataConst.GUILDVO.tuanzhang_name)
	self.variables.guild_name:SetValue(GuildDataConst.GUILDVO.guild_name)
	self.variables.guild_rank:SetValue(GuildDataConst.GUILDVO.rank)
	self.variables.guild_level:SetValue(GuildDataConst.GUILDVO.guild_level)
	self.variables.guild_count:SetValue(GuildDataConst.GUILDVO.cur_member_count .. " / " .. GuildDataConst.GUILDVO.max_member_count)

	local post = GuildData.Instance:GetGuildPost()
	-- if post == GuildDataConst.GUILD_POST.TUANGZHANG then
	-- 	self.variables.show_auto_kick:SetValue(true)
	-- else
	-- 	self.variables.show_auto_kick:SetValue(false)
	-- end
	self.variables.show_auto_kick:SetValue(true)
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.variables.show_notice_button:SetValue(true)
	else
		self.variables.show_notice_button:SetValue(false)
	end

	-- local info = GuildData.Instance:GetGuildMemberInfo()
	-- if info then
	-- 	if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
	-- 		self.variables.exit_guild:SetValue(Language.Guild.JieSanXianMeng)
	-- 	else
	-- 		self.variables.exit_guild:SetValue(Language.Guild.TuiChuGuild)
	-- 	end
	-- end
	local guild_config = GuildData.Instance:GetGuildConfig()
	if guild_config then
		local level_config = guild_config.level_config
		if level_config then
			local max_level = #level_config
			local config = level_config[GuildDataConst.GUILDVO.guild_level or 0]
			if config then
				 -- 公会资金
				local exp = CommonDataManager.ConverMoney(GuildDataConst.GUILDVO.guild_exp)
				if max_level <= GuildDataConst.GUILDVO.guild_level then
					self.variables.guild_exp:SetValue(exp .. "/" .. Language.Common.YiMan)
				else
					self.variables.guild_exp:SetValue(exp .. "/" .. config.max_exp)
				end
				self.variables.guild_gold:SetValue(GuildDataConst.GUILDVO.guild_exp)
			end
		end
	end

	local guild_notice = GuildDataConst.GUILDVO.guild_notice
	if(guild_notice == "") then
		guild_notice = Language.Guild.EmptyNotice
	end
	self.variables.guild_notice:SetValue(guild_notice)
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.variables.red_point_operation:SetValue(true)
	else
		self.variables.red_point_operation:SetValue(false)
	end

	self.variables.show_icon:SetValue(false)
	local fuli_count = GuildData.Instance:GetGuildFuLiCount() or 0
	if fuli_count < 1 and not GuildData.Instance:IsGuildCD() then
		self.variables.red_point_fuli:SetValue(true)
	else
		self.variables.red_point_fuli:SetValue(false)
		self.variables.show_icon:SetValue(true)
	end

	-- self.variables.red_point_hongbao:SetValue(GuildData.Instance:GetRedPacketRemindNum() == 1)

	-- self.variables.show_delate_btn:SetValue(true)
	self.variables.show_invite_btn:SetValue(false)
	post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.variables.show_invite_btn:SetValue(true)
	end

	if GuildData.Instance.guild_id ~= 0 then
		if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			self.variables.has_guild:SetValue(true)
		else
			self.variables.has_guild:SetValue(false)
		end
	end

	-- if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
	-- 	self.variables.red_point_apply:SetValue(true)
	-- else
	-- 	self.variables.red_point_apply:SetValue(false)
	-- end

	local card_id = GuildData.Instance:GetGuildJianSheId()
	self.variables.red_point_donate:SetValue(false)
	if card_id then
		local card_count = ItemData.Instance:GetItemNumInBagById(card_id)
		if card_count > 0 then
			self.variables.red_point_donate:SetValue(true)
		end
	end

	-- 签到小红点
	local remind_num = GuildData.Instance:GetSigninRemind()
	self.show_signin_red_point:SetValue(remind_num >= 1)

	local guild_head_remind_num = GuildData.Instance:GetGuildHeadRemind()
	self.show_guild_head_red_point:SetValue(guild_head_remind_num >= 1)

	--self.auto_kick_toggle.isOn = GuildDataConst.GUILDVO.is_auto_clear == 1
	-- self.notice_window:FlushNotice()
	self:OnHeadChange()


end

function GuildInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Guild) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.variables.portrait_image.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0)
	self.variables.portrait_raw.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) ~= 0)
	if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		self.variables.portrait:SetAsset(bundle, asset)
		return
	end
	local raw_image = self.variables.portrait_raw.raw_image
	local callback = function (path)
		if nil ~= raw_image and nil ~= raw_image.gameObject and not IsNil(raw_image.gameObject) then
			self.avatar_path_big = path or AvatarManager.GetFilePath(vo.guild_id, true, true)
			raw_image:LoadSprite(self.avatar_path_big, function()
			end)
		end
	end
	AvatarManager.Instance:GetAvatar(vo.guild_id, true, callback, vo.guild_id)
end

function GuildInfoView:OnClickList()
	GuildCtrl.Instance:SendAllGuildInfoReq()
	GuildCtrl.Instance:OpenListView()
end
function GuildInfoView:OnClickMeber()
	GuildCtrl.Instance:SendGuildInfoReq(GuildDataConst.GUILDVO.guild_id)
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
	GuildCtrl.Instance:OpenMeberView()
end


-- 进入驻地
function GuildInfoView:EnterStation()
	local guild_id = GuildData.Instance.guild_id
	if guild_id and guild_id > 0 then
		GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
	end
end

function GuildInfoView:OnClickChat()
	ViewManager.Instance:Close(ViewName.Guild)
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function GuildInfoView:OnClickReward()
	GuildCtrl.Instance:OpenSigninView()
end

-- 关闭所有弹窗
function GuildInfoView:CloseAllWindow()
	self.notice_window:Close()
	self.operation_window:Close()
end

-- 关闭所有弹窗
function GuildInfoView:OnClose()
	self:CloseAllWindow()
	self:Flush()
end

function GuildInfoView:OnClickGuildFight()
	-- ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.GUILDBATTLE)
	ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
end

function GuildInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(152)
end

function GuildInfoView:OnClickRename()
	local post = GuildData.Instance:GetGuildPost()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		local number = ItemData.Instance:GetItemNumInBagById(COMMON_CONSTS.GUILD_CHANGE_NAME)
		if number < 1 then
			local func = function(item_id, num, is_bind, is_tip_use) ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) end
			TipsCtrl.Instance:ShowCommonBuyView(func, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, 1)
		else
			local describe = Language.Role.RenameGuildTxt
			local yes_func = function(new_name) GuildCtrl.Instance:SendResetNameReq(guild_id, new_name) end
			TipsCtrl.Instance:ShowRename(yes_func, nil, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, describe)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

-- 增加公会人数上限
function GuildInfoView:OnClickPlus()
	local post = GuildData.Instance:GetGuildPost()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if GuildDataConst.GUILDVO.max_member_count >= GuildData.Instance:GetMaxGuildMemberCount() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxMemberCount)
			return
		end
		local extend_member_item_id = GuildData.Instance:GetGuildExtendId() or 0
		local need_num = GuildData.Instance:GetGuildExtendCountByNum() or 0
		local has_num = ItemData.Instance:GetItemNumInBagById(extend_member_item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(extend_member_item_id) or {}
		local item_name = item_cfg.name or ""
		local describe = string.format(Language.Guild.AddMemberCount, need_num, item_name)
		if has_num < need_num then
			local shop_cfg = ShopData.Instance:GetShopItemCfg(extend_member_item_id) or {}
			local price = shop_cfg.gold or 0
			local cost = price * (need_num - has_num) or 0
			describe = string.format(Language.Guild.AddMemberCount2, need_num, item_name, has_num, need_num - has_num, cost)
		end
		local yes_func = function() GuildCtrl.Instance:SendGuildExtendMemberReq(GUILD_EXTEND_OPERATE_TYPE.EXTEND_MEMBER, 1, 1) end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

function GuildInfoView:OnClickInvite()
	local last_callin_time = GuildData.Instance:GetLastCallinTime()
	if last_callin_time + 10 <= Status.NowTime then
		local yes_func = function()
			GuildCtrl.Instance:SendGuildCallInReq()
		end
		if GuildData.Instance:GetCanCallinFree() then
			yes_func()
		else
			local describe = string.format(Language.Guild.ZhaoMuCost, GuildData.Instance:GetCallinPrice())
			TipsCtrl.Instance:ShowCommonAutoView("guild_callin", describe, yes_func)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteCD)
	end
end

function GuildInfoView:OnClickDonate()
	GuildCtrl.Instance.view:HandleOpenDonate()
end

-- function GuildInfoView:OpenHongBaoView()
-- 	ViewManager.Instance:Open(ViewName.GuildRedPacket)
-- end

function GuildInfoView:OnClickAutoKickOut(switch)
	GuildCtrl.Instance:SendGuildSetAutoClearReq(switch and 1 or 0)
end

-- 获得会长模型
function GuildInfoView:FlushTuanZhangModel(uid, info)
	local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
	if tuanzhang_uid == uid then
		if self.last_flush_time + 1 > Status.NowTime then return end
		self.last_flush_time = Status.NowTime
		if not self.role_model then
			self.role_model = RoleModel.New("guild_info_panel")
			self.role_model:SetDisplay(self.role_display.ui3d_display)
		end
		if self.role_model then
			local temp_info = {}
			temp_info.prof = info.prof
			temp_info.sex = info.sex
			temp_info.appearance = {}
			temp_info.appearance.fashion_wuqi = info.shizhuang_part_list[1].use_index
			temp_info.appearance.fashion_body = info.shizhuang_part_list[2].use_index
			temp_info.appearance.wing_used_imageid = info.wing_info.used_imageid
			temp_info.appearance.halo_used_imageid = info.halo_info.used_imageid
			temp_info.appearance.yaoshi_used_imageid = info.waist_info.used_imageid
			temp_info.appearance.toushi_used_imageid = info.head_info.used_imageid
			temp_info.appearance.qilinbi_used_imageid = info.arm_info.used_imageid
			temp_info.appearance.mask_used_imageid = info.mask_info.used_imageid
			self.role_model:SetModelResInfo(temp_info, false, false, true)
		end
	end
end

function GuildInfoView:OnClickChangePortrait()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if vo.level < COMMON_CONSTS.GUILD_ICON_CHANGE_LV then
			local str = string.format(Language.Guild.NoChangePortraitLv, PlayerData.GetLevelString(COMMON_CONSTS.GUILD_ICON_CHANGE_LV))
			TipsCtrl.Instance:ShowSystemMsg(str)
		else
			GuildCtrl.Instance:ShowGuildPortraitView()
		end
	else
		local str = Language.Guild.NoChangePortrait
		TipsCtrl.Instance:ShowSystemMsg(str)
	end
end
------------------------------------------------------------ 公告面板 -------------------------------------------------------------------------

-- -- 更改公告
-- function GuildInfoView:OnNoticeChange()
-- 	local notice = self.input_field.text
-- 	if(notice == "") then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEmptyContent)
-- 		return
-- 	end
-- 	if ChatFilter.Instance:IsIllegal(notice, false) then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
-- 		return
-- 	end
-- 	GuildCtrl.Instance:SendGuildChangeNoticeReq(notice)
-- 	GuildCtrl.Instance:SendGuildInfoReq()
-- end

--打开公告面板
function GuildInfoView:HandleOpenNotice()
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.notice_window:Open()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

-- --刷新公告面板
-- function GuildInfoView:FlushNotice()
-- 	self.input_field.text = GuildDataConst.GUILDVO.guild_notice
-- end

-------------------------------------------------------------------- 操作面板 -----------------------------------------------------------------------

-- 打开操作面板
function GuildInfoView:OnOpenOperation()
	self.operation_window:Open()
end

-- function GuildInfoView:QuitGuild()
-- 	local describe = ""
-- 	local yes_func = nil

-- 	local post = GuildData.Instance:GetGuildPost()
-- 	if post then
-- 		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
-- 			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 1)
-- 			describe = Language.Guild.ConfirmDismissGuildTip
-- 		else
-- 			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 0)
-- 			describe = Language.Guild.QuitGuildTip
-- 		end
-- 	end

-- 	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
-- end

-- -- 请求退出公会 flag = 1 解散公会
-- function GuildInfoView:SendQuitGuildReq(flag)
-- 	if flag == 1 then
-- 		local guild_id = GuildData.Instance.guild_id
-- 		if guild_id then
-- 			GuildCtrl.Instance:SendDismissGuildReq(guild_id)
-- 		end
-- 	else
-- 		GuildCtrl.Instance:SendQuitGuildReq()
-- 	end
-- end

-- -- 检查能否弹劾会长
-- function GuildInfoView:SendGuildCheckCanDelate()
-- 	local describe = Language.Guild.ConfirmTanHeMengZhuTip
-- 	local yes_func = function() GuildCtrl.Instance:SendGuildCheckCanDelateReq() end
-- 	local delete_id = GuildData.Instance:GetGuildDeleteId()
-- 	if not delete_id then return end
-- 	local number = ItemData.Instance:GetItemNumInBagById(delete_id)
-- 	if number < 1 then
-- 		local func = function(item_id, num, is_bind, is_tip_use) ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) end
-- 		TipsCtrl.Instance:ShowCommonBuyView(func, delete_id, nil, 1)
-- 	else
-- 		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
-- 	end
-- end

-- --打开申请列表
-- function GuildInfoView:OnOpenApplyWindow()
-- 	ViewManager.Instance:Open(ViewName.GuildApply)
-- end
