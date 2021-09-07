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
	self.variables.guild_power = self:FindVariable("GuildPower")
	self.variables.guild_notice = self:FindVariable("GuildNotice")
	self.variables.red_point_apply = self:FindVariable("PointRedApply")
	self.variables.red_point_operation = self:FindVariable("PointRedOperation")
	self.variables.red_point_fuli = self:FindVariable("PointRedFuLi")
	self.variables.exit_guild = self:FindVariable("ExitGuild")
	self.variables.show_notice_button = self:FindVariable("ShowNoticeButton")
	self.variables.show_invite_btn = self:FindVariable("ShowInviteBtn")
	self.variables.show_delate_btn = self:FindVariable("ShowDelateBtn")
	self.variables.show_icon = self:FindVariable("ShowIcon")
	self.variables.guild_exp = self:FindVariable("GuildExp")
	self.variables.red_point_donate = self:FindVariable("PointRedDonate")
	self.variables.portrait = self:FindVariable("Portrait")
	self.variables.portrait_image = self:FindObj("PortraitImage")
	self.variables.portrait_raw = self:FindObj("PortraitRaw")
	self.reward_btn_enble = self:FindVariable("BtnEnble")

	self.notice_window = self:FindObj("NoticeWindow")
	self.operation_window = self:FindObj("OperationWindow")
	self.role_display = self:FindObj("RoleDisplay")

	self:ListenEvent("OnNoticeChange", BindTool.Bind(self.OnNoticeChange, self))
	self:ListenEvent("OpenNotice", BindTool.Bind(self.HandleOpenNotice, self))
	self:ListenEvent("OnQuitGuild", BindTool.Bind(self.QuitGuild, self))
	self:ListenEvent("OnGuildCheckCanDelate", BindTool.Bind(self.SendGuildCheckCanDelate, self))
	self:ListenEvent("OpenInvite", BindTool.Bind(self.OpenInvite, self))
	self:ListenEvent("OnOpenApplyWindow", BindTool.Bind(self.OnOpenApplyWindow, self))
	self:ListenEvent("OnOpenOperation", BindTool.Bind(self.OnOpenOperation, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickGuildFight", BindTool.Bind(self.OnClickGuildFight, self))
	self:ListenEvent("OnClickEnterStation", BindTool.Bind(self.EnterStation, self))
	self:ListenEvent("OnClickChat", BindTool.Bind(self.OnClickChat, self))
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickRename", BindTool.Bind(self.OnClickRename, self))
	self:ListenEvent("OnClickInvite", BindTool.Bind(self.OnClickInvite, self))
	-- self:ListenEvent("OnClickPlus", BindTool.Bind(self.OnClickPlus, self))
	self:ListenEvent("OnClickChangePortrait", BindTool.Bind(self.OnClickChangePortrait, self))
	self.is_first = true

	self.input_field = self:FindObj("InputField"):GetComponent("InputField")
	self.input_field.onValueChanged:AddListener(function(a)
		local length = StringUtil.GetCharacterCount(a)
		if length >= 128 and not self.is_first then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InputDes)
		end

		self.is_first = false
	end)
	self.current_setting_model = 1
	self.last_flush_time = 0
	self.apply_click = false
	self:initInviteWindow()
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

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.is_first = false
end

function GuildInfoView:OnFlush()
	self.variables.role_name:SetValue(GuildDataConst.GUILDVO.tuanzhang_name)
	--self.variables.guild_name:SetValue(CampData.Instance:GetCampNameByCampType(GuildDataConst.GUILDVO.camp, true) .. GuildDataConst.GUILDVO.guild_name)
	self.variables.guild_name:SetValue(GuildDataConst.GUILDVO.guild_name)
	self.variables.guild_rank:SetValue(GuildDataConst.GUILDVO.rank)
	self.variables.guild_level:SetValue(GuildDataConst.GUILDVO.guild_level)
	self.variables.guild_count:SetValue(GuildDataConst.GUILDVO.cur_member_count .. "/" .. GuildDataConst.GUILDVO.max_member_count)
	self.variables.guild_power:SetValue(CommonDataManager.ConverNum(GuildDataConst.GUILDVO.total_capability))

	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.variables.show_notice_button:SetValue(true)
	else
		self.variables.show_notice_button:SetValue(false)
	end

	local info = GuildData.Instance:GetGuildMemberInfo()
	if info then
		if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
			self.variables.exit_guild:SetValue(Language.Guild.JieSanXianMeng)
		else
			self.variables.exit_guild:SetValue(Language.Guild.TuiChuGuild)
		end
	end
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
	-- if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
	-- 	self.variables.red_point_operation:SetValue(true)
	-- else
	-- 	self.variables.red_point_operation:SetValue(false)
	-- end

	self.variables.show_icon:SetValue(false)
	local fuli_count = GuildData.Instance:GetGuildFuLiCount() or 0
	if fuli_count < 1 and not GuildData.Instance:IsGuildCD() then
		self.variables.red_point_fuli:SetValue(true)
	else
		self.variables.red_point_fuli:SetValue(false)
		self.variables.show_icon:SetValue(true)
	end

	self.variables.show_delate_btn:SetValue(false)
	self.variables.show_invite_btn:SetValue(true)
	post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		self.variables.show_delate_btn:SetValue(false)
	elseif post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.variables.show_invite_btn:SetValue(false)
	end

	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.variables.red_point_apply:SetValue(true)
	else
		self.variables.red_point_apply:SetValue(false)
	end
	RemindManager.Instance:Fire(RemindName.GuildRoleInfoDonate)

	self.variables.red_point_donate:SetValue(GuildData.Instance:GetGuildNewFuLiCount() ~= 1)

	self:FlushNotice()
	self.reward_btn_enble:SetValue(GuildData.Instance:GetGuildNewFuLiCount() ~= 1)
	self:OnHeadChange()
end

function GuildInfoView:LoadCallBack()
	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
	self.red_point_list = {
		[RemindName.GuildRoleInfoDonate] = self:FindVariable("PointRedDonate"),
		[RemindName.GuildOperation]      = self:FindVariable("PointRedOperation"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
 
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function GuildInfoView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
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
			self.role_model:SetModelResInfo(info, false, false, true, nil ,true)
			self.role_model:SetModelScale(Vector3(0.86, 0.86, 0.86))
		end
	end
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
	local fuli_count = GuildData.Instance:GetGuildFuLiCount() or 0
	if fuli_count < 1 and not GuildData.Instance:IsGuildCD() then
		AudioService.Instance:PlayRewardAudio()
	end
	GuildCtrl.Instance:SendGuildFetchRewardReq()
	self.reward_btn_enble:SetValue(GuildData.Instance:GetGuildNewFuLiCount() ~= 1)
end

-- 关闭所有弹窗
function GuildInfoView:CloseAllWindow()
	self.notice_window:SetActive(false)
	self.operation_window:SetActive(false)
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
			local yes_func = function(new_name) 
				GuildCtrl.Instance:SendResetNameReq(guild_id, new_name)
			end
			TipsCtrl.Instance:ShowRename(yes_func, nil, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, describe, 4)
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
	-- ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_donate)
end

function GuildInfoView:OnClickChangePortrait()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		TipsCtrl.Instance:ShowGuildPortraitView()
	else
		local str = Language.Guild.NoChangePortrait
		TipsCtrl.Instance:ShowSystemMsg(str)
	end
end

------------------------------------------------------------ 公告面板 -------------------------------------------------------------------------

-- 更改公告
function GuildInfoView:OnNoticeChange()
	local notice = self.input_field.text
	if(notice == "") then
		local guild_notice = GuildDataConst.GUILDVO.guild_notice
		if(guild_notice == "") then
			guild_notice = Language.Guild.EmptyNotice
		end
		notice = guild_notice
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEmptyContent)
		-- return
	end
	local length = StringUtil.GetCharacterCount(notice)
	if length > 128 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InputDes)
		return
	end
	if ChatFilter.Instance:IsIllegal(notice, false) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
		return
	end
	GuildCtrl.Instance:SendGuildChangeNoticeReq(notice)
	GuildCtrl.Instance:SendGuildInfoReq()
end

--打开公告面板
function GuildInfoView:HandleOpenNotice()
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.notice_window:SetActive(true)		
		self:FlushNotice()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

--刷新公告面板
function GuildInfoView:FlushNotice()	
	self.input_field.text = GuildDataConst.GUILDVO.guild_notice	
	if(self.input_field.text == "") then			
		self.input_field.text = Language.Guild.EmptyNotice
	end
end

-------------------------------------------------------------------- 操作面板 -----------------------------------------------------------------------

-- 打开操作面板
function GuildInfoView:OnOpenOperation()
	self.operation_window:SetActive(true)
	local post = GuildData.Instance:GetGuildPost()
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then
		self.variables.red_point_apply:SetValue(true)
	else
		self.variables.red_point_apply:SetValue(false)
	end
end

function GuildInfoView:QuitGuild()
	local describe = ""
	local yes_func = nil

	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 1)
			describe = Language.Guild.ConfirmDismissGuildTip
		else
			yes_func = BindTool.Bind(self.SendQuitGuildReq, self, 0)
			describe = Language.Guild.QuitGuildTip
		end
	end

	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 请求退出公会 flag = 1 解散公会
function GuildInfoView:SendQuitGuildReq(flag)
	if flag == 1 then
		local guild_id = GuildData.Instance.guild_id
		if guild_id then
			GuildCtrl.Instance:SendDismissGuildReq(guild_id)
			Scene.Instance:GetMainRole():GetFollowUi():SetRoleGuildIconValue()
		end
	else
		GuildCtrl.Instance:SendQuitGuildReq()
	end
end

-- 检查能否弹劾会长
function GuildInfoView:SendGuildCheckCanDelate()
	local describe = Language.Guild.ConfirmTanHeMengZhuTip
	local yes_func = function() GuildCtrl.Instance:SendGuildCheckCanDelateReq() end
	local delete_id = GuildData.Instance:GetGuildDeleteId()
	if not delete_id then return end
	local number = ItemData.Instance:GetItemNumInBagById(delete_id)
	if number < 1 then
		local func = function(item_id, num, is_bind, is_tip_use) ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) end
		TipsCtrl.Instance:ShowCommonBuyView(func, delete_id, nil, 1)
	else
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

--打开申请列表
function GuildInfoView:OnOpenApplyWindow()
	ViewManager.Instance:Open(ViewName.GuildApply)
end

-------------------------------------------------------------------- 招人面板 -----------------------------------------------------------------------
function GuildInfoView:initInviteWindow()
	self.invite_window = self:FindObj("InviteWindow")
	local event_table = self.invite_window:GetComponent("UIEventTable")
	event_table:ListenEvent("ClickLevelInput",
		BindTool.Bind(self.ClickLevelInput, self))
	event_table:ListenEvent("ClickFPInput",
		BindTool.Bind(self.ClickFPInput, self))
	event_table:ListenEvent("OnSaveSetting",
		BindTool.Bind(self.OnSaveSetting, self))
	event_table:ListenEvent("ClickNoLimit",
		BindTool.Bind(self.ClickNoLimit, self))

	local name_table = self.invite_window:GetComponent("UINameTable")
	self.toggle_forbid = U3DObject(name_table:Find("ToggleForbid")).toggle
	self.toggle_approver = U3DObject(name_table:Find("ToggleApprover")).toggle
	self.toggle_unlimited = U3DObject(name_table:Find("ToggleUnlimited")).toggle
	self.level_input = U3DObject(name_table:Find("LevelInput")):GetComponent("InputField")
	self.fp_input = U3DObject(name_table:Find("FpInput")):GetComponent("InputField")

	self.gray = self.invite_window:GetComponent("UIVariableTable"):FindVariable("Gray")
end

function GuildInfoView:OpenInvite()
	local post = GuildData.Instance:GetGuildPost()
	if post then
		if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
			return
		end
	end
	self.invite_window:SetActive(true)

	self.gray:SetValue(true)
	self.level_input.text = Language.Daily.CapNoLimmit
	self.fp_input.text = Language.Daily.CapNoLimmit
	if GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
		self.toggle_approver.isOn = true
	elseif GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.FORBID then
		self.toggle_forbid.isOn = true
	else
		self.toggle_unlimited.isOn = true
		self.gray:SetValue(false)
		self.level_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_level)
		self.fp_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_capability)
	end
end

function GuildInfoView:OnSaveSetting()
	local need_capability = 0
	local need_level = 0
	local model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
	if self.toggle_unlimited.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
		need_capability = tonumber(self.fp_input.text) or 0
		need_level = tonumber(self.level_input.text) or 0
	elseif self.toggle_forbid.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.FORBID
	else
		model = GuildDataConst.GUILD_SETTING_MODEL.APPROVAL
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		GuildCtrl.Instance:SendSettingGuildReq(guild_id, model, need_capability, need_level)
		 GuildDataConst.GUILDVO.applyfor_setup = model
		 GuildDataConst.GUILDVO.applyfor_need_level = need_level
		 GuildDataConst.GUILDVO.applyfor_need_capability = need_capability
	end
	self.invite_window:SetActive(false)
end

function GuildInfoView:ClickLevelInput()
	TipsCtrl.Instance:OpenCommonInputView(self.level_input.text, function(num) self.level_input.text = num end, nil, 1000)
end

function GuildInfoView:ClickFPInput()
	TipsCtrl.Instance:OpenCommonInputView(self.fp_input.text, function(num) self.fp_input.text = num end, nil, 999999)
end

function GuildInfoView:ClickNoLimit(switch)
	if not switch then
		self.level_input.text = Language.Daily.CapNoLimmit
		self.fp_input.text = Language.Daily.CapNoLimmit
	else
		self.level_input.text = "0"
		self.fp_input.text = "0"
	end
	self.gray:SetValue(not switch)
end

function GuildInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Guild) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- self.variables.portrait_image.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id) == 0)
	-- self.variables.portrait_raw.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id) ~= 0)
	if AvatarManager.Instance:isDefaultImg(vo.guild_id) == 0 then
		local bundle, asset = ResPath.GetGuildBadgeIcon(vo.camp)
		self.variables.portrait:SetAsset(bundle, asset)
		self.variables.portrait_image.gameObject:SetActive(true)
		self.variables.portrait_raw.gameObject:SetActive(false)
		return
	end
	local callback = function (path)
		self.avatar_path_big = path or AvatarManager.GetFilePath(vo.guild_id, true)
		self.variables.portrait_raw.raw_image:LoadSprite(self.avatar_path_big, function()
			self.variables.portrait_image.gameObject:SetActive(false)
			self.variables.portrait_raw.gameObject:SetActive(true)
		end)
	end

	AvatarManager.Instance:GetGuildAvatar(vo.role_id, vo.guild_id, true, callback)
	-- self.portrait_raw.raw_image:LoadSprite(path, function()
	-- 	end)
end
