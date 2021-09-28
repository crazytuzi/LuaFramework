require("game/player/player_view")
require("game/player/player_data")
require("game/player/check_equip_view")

PlayerCtrl = PlayerCtrl or  BaseClass(BaseController)

function PlayerCtrl:__init()
	if PlayerCtrl.Instance ~= nil then
		ErrorLog("[PlayerCtrl] attempt to create singleton twice!")
		return
	end
	PlayerCtrl.Instance = self

	self:RegisterAllProtocols()
	self:RegisterAllEvents()
	self.money_info = {
		bind_coin = 0,
		coin = 0,
		gold = 0,
		bind_gold = 0
	}

	self.data = PlayerData.New()
	self.view = PlayerView.New(ViewName.Player, TabIndex.role_bag)
	self.check_equip_view = CheckEquipView.New(ViewName.CheckEquipView)
end

function PlayerCtrl:__delete()
	if self.check_equip_view ~= nil then
		self.check_equip_view:DeleteMe()
		self.check_equip_view = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	PlayerCtrl.Instance = nil
end

-- 协议注册
function PlayerCtrl:RegisterAllProtocols()
	--人物属性
	self:RegisterProtocol(CSFindRoleByName)
	self:RegisterProtocol(SCFindRoleByNameRet, "OnFindRoleByNameRet")
	self:RegisterProtocol(SCRoleSexChange, "OnRoleSexChange")
	self:RegisterProtocol(SCLevelChange, "OnLevelChange")
	self:RegisterProtocol(SCRoleChengJiu, "OnAchieveChange")
	self:RegisterProtocol(SCCrossHonorChange, "OnCrossHonorChange")
	self:RegisterProtocol(SCMarryResult, "OnMarryChange")
	self:RegisterProtocol(SCChaExpChange, "OnChaExpChange")
	self:RegisterProtocol(SCRoleNuqi, "OnRoleNuqiChange")
	self:RegisterProtocol(SCRoleInfoAck, "OnRoleInfoAck")
	self:RegisterProtocol(SCRoleAttributeValue, "OnRoleAttributeValue")
	self:RegisterProtocol(SCNvWaShi, "OnNvWaShi")
	self:RegisterProtocol(SCMoneyChange, "OnMoneyChange")
	self:RegisterProtocol(SCCapabilityChange, "OnCapabilityChange")
	self:RegisterProtocol(SCRoleAddCamp, "OnRoleAddCamp")
	self:RegisterProtocol(SCOtherUserOnlineStatus, "OnOtherUserOnlineStatus")
	self:RegisterProtocol(SCRoleResetName, "OnRoleNameChange")
	self:RegisterProtocol(SCRoleEvilChange, "OnRoleEvilChange")
	self:RegisterProtocol(SCRoleNameColorChange, "OnRoleNameColorChange")

	--人物装备列表
	self:RegisterProtocol(SCEquipList, "OnEquipList")
	self:RegisterProtocol(SCEquipChange,"OnEquipChange")
	self:RegisterProtocol(CSTakeOffEquip)
	self:RegisterProtocol(SCRoleExpExtraPer, "OnRoleExpExtraPer")
	--强化和神铸信息
	self:RegisterProtocol(SCEquipmentGridInfo, "OnEquipmentGridInfo")

	-- 改名
	self:RegisterProtocol(CSRoleResetName)

	--追踪令
	self:RegisterProtocol(CSSeekRoleWhere)
	-- self:RegisterProtocol(SCSeekRoleInfo, "OnSeekRoleInfo")

	self:RegisterProtocol(SCRoleLingJing, "OnRoleLingJingChange")

	-- 魂力改变
	self:RegisterProtocol(SCRoleHunli, "OnRoleHunliChange")

	--声望改变
	self:RegisterProtocol(SCRoleShengwang, "OnRoleShengwangChange")
	--第一次换头像
	self:RegisterProtocol(SCAvatarTimeStampInfo, "OnAvatarTimeStampInfo")
	--角色结婚信息改变
	self:RegisterProtocol(SCRoleMarryInfoChange, "OnRoleMarryInfoChange")
	-- 角色神力值改变
	self:RegisterProtocol(SCZhuanShengXiuweiNotice, "OnZhuanShengXiuweiNotice")

	-- 随机活动表
	self:RegisterProtocol(SCCommonInfo, "OnSCCommonInfo")

	--小天使小恶魔
	self:RegisterProtocol(CSImpGuardOperaReq)
	self:RegisterProtocol(SCImpGuardInfo, "OnImpGuardInfo")
end

function PlayerCtrl:RegisterAllEvents()
end

function PlayerCtrl:GetTitleView()
	return self.view:GetTitleView()
end

function PlayerCtrl:GetView()
	return self.view
end

-- 神力值改变
function PlayerCtrl:OnZhuanShengXiuweiNotice(protocol)
	TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.Common.ShenLiChange, protocol.add_xiuwei))
	-- self.view:Flush()
end

--强化和神铸信息
function PlayerCtrl:OnEquipmentGridInfo(protocol)
	EquipData.Instance:SetEquipmentGridInfo(protocol.equip_list)
	EquipData.Instance:SetMinEternityLevel(protocol.min_eternity_level)
	EquipData.Instance:SetMinLianhunLevel(protocol.min_lianhun_level)
	EquipData.Instance:SetUseEternityLevel(protocol.use_eternity_level)
	ForgeCtrl.Instance:FlyShenZhuEffect()
	RemindManager.Instance:Fire(RemindName.Lianhun)
end

--装备列表
function PlayerCtrl:OnEquipList(protocol)
	EquipData.Instance:SetDataList(protocol.equip_list, protocol.fabao_info)

	-- if ItemData.Instance:IsSetBagInfo() then  ---??
		PackageCtrl.Instance:ShowQuickEquipVieww()
	-- end

	local weapon_info = protocol.equip_list[GameEnum.EQUIP_INDEX_WUQI]
	if weapon_info then
		local item_id = weapon_info.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg then
			Scene.Instance:GetMainRole():SetAttr("wuqi_color", item_cfg.color)
		end
	end
end

--单个装备改变
function PlayerCtrl:OnEquipChange(protocol)
	EquipData.Instance:ChangeDataInGrid(protocol.equip_data)

	PackageCtrl.Instance:ShowQuickEquipVieww()

	if protocol.index == GameEnum.EQUIP_INDEX_WUQI then
		local item_id = protocol.equip_data.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg then
			Scene.Instance:GetMainRole():SetAttr("wuqi_color", item_cfg.color)
		end
	end
	if EquipData.Instance:GetTakeOffFlag() then
		PackageData.Instance:AutoRecyclEquip()
		EquipData.Instance:SetTakeOffFlag(false)
	end

	-- 播放合成成功特效
	if protocol.reason == GameEnum.SEND_REASON_COMPOUND then
		ForgeCtrl.Instance:PlaySuccedEffet()
	end
end

--通过角色名查询角色信息
function PlayerCtrl:CSFindRoleByName(gamename)
	local cmd = ProtocolPool.Instance:GetProtocol(CSFindRoleByName)
	cmd.gamename = gamename or ""
	cmd:EncodeAndSend()
end

--接受角色名查询后返回信息
function PlayerCtrl:OnFindRoleByNameRet(protocol)
	GlobalEventSystem:Fire(OtherEventType.ROLE_NAME_INFO, protocol)
end

-- 请求主角全部信息
function PlayerCtrl:SendReqAllInfo()
	--print_log("PlayerCtrl:SendReqAllInfo")
	local protocol = CSAllInfoReq.New()
	protocol:EncodeAndSend()
end

function PlayerCtrl:OnRoleNameChange(protocol)
	print_log("收到改名协议 ############  PlayerCtrl:OnRoleNameChange", protocol)
	local role = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= role then
		role:ChangeFollowUiName(protocol.game_name)
		if role:IsMainRole() then
			print("是主角，更新面板名字", role:IsMainRole())
			PlayerData.Instance:SetAttr("name", protocol.game_name)
		end
	end
end

-- 主角信息返回
function PlayerCtrl:OnRoleInfoAck(protocol)
	--print_log("PlayerCtrl:OnRoleInfoAck #########", protocol.attr_t)

	for k, v in pairs(protocol.attr_t) do
		PlayerData.Instance:SetAttr(k, v)
	end

	if protocol.attr_t.guanghui then
		ExchangeData.Instance:SetGuangHuiInfo(protocol.attr_t.guanghui)
	end

	PlayerData.Instance:RoleInfoOk()
	local main_role = Scene.Instance:CreateMainRole()
	RemindManager.Instance:Fire(RemindName.PlayerInfo)
	--打开主界面
	if not ViewManager.Instance:IsOpen(ViewName.Main) or not MainUICtrl.Instance:IsLoaded() then
		ViewManager.Instance:Open(ViewName.Main)
		AvatarManager.Instance:SetAvatarKey(GameVoManager.Instance:GetMainRoleVo().role_id, protocol.attr_t.avatar_key_big, protocol.attr_t.avatar_key_small)
	end

	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)

	GlobalEventSystem:Fire(LoginEventType.RECV_MAIN_ROLE_INFO)

	MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.Show_Reincarnation,ReincarnationData.Instance:GetIsCanZs())

	-- 设置首充提示监听事件
	TipsCtrl.Instance:SetFirstChargeDataEventView()

	-- 七天比拼
	CompetitionActivityCtrl.Instance:SetPlayDataEvent()
end

function PlayerCtrl:OnRoleAttributeValue(protocol)
	local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil ~= scene_obj then
		for k, v in pairs(protocol.attr_pair_list) do
			local can_sync = true

			if scene_obj:IsMainRole() then
				if v.attr_type == GameEnum.FIGHT_CHARINTATTR_TYPE_HP then
					can_sync = not RobertManager.Instance:IsMainRoleUseingRobertAttr("hp", v.attr_value)
				end

				if v.attr_type == GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP then
					can_sync = not RobertManager.Instance:IsMainRoleUseingRobertAttr("max_hp", v.attr_value)
				end
			end

			if can_sync then
				scene_obj:SetAttr(PlayerData.GetRoleAttrNameByType(v.attr_type), v.attr_value)
				if v.attr_type == GameEnum.FIGHT_CHARINTATTR_TYPE_HP and scene_obj:IsCharacter() then
					scene_obj:SyncShowHp()
				end
			end
		end
	end
end

--脱下装备
function PlayerCtrl:CSTakeOffEquip(index)
	local cmd = ProtocolPool.Instance:GetProtocol(CSTakeOffEquip)
	cmd.index = index
	cmd:EncodeAndSend()
end

-- 角色改名请求
function PlayerCtrl:SendRoleResetName(is_item_reset, new_name)
	local cmd = ProtocolPool.Instance:GetProtocol(CSRoleResetName)
	cmd.is_item_reset = is_item_reset
	cmd.new_name = new_name
	cmd:EncodeAndSend()
end

-- 修改头像
function PlayerCtrl:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetAvatarTimeStamp)
	protocol.avatar_key_big = avatar_key_big
	protocol.avatar_key_small = avatar_key_small
	protocol:EncodeAndSend()
end

function PlayerCtrl:ReqRoleExpExtraPer()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetExpExtraPer)
	protocol:EncodeAndSend()
end

--经验加成
function PlayerCtrl:OnRoleExpExtraPer(protocol)
	self.data:SetExpExtraPer(protocol.exp_extra_per)
	self.role_view:Flush("exp_extra", {protocol.exp_extra_per})
end

function PlayerCtrl:OnNvWaShi(protocol)
	local delta_nvwashi = protocol.nv_wa_shi - GameVoManager.Instance:GetMainRoleVo().nv_wa_shi
	if delta_nvwashi > 0 then
		-- 文字上漂
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddNvWaShi, delta_nvwashi))
	end
	PlayerData.Instance:SetAttr("nv_wa_shi", protocol.nv_wa_shi)
end

--金钱改变
function PlayerCtrl:OnMoneyChange(protocol)
	self.money_info.coin = protocol.coin
	self.money_info.bind_coin = protocol.bind_coin
	self.money_info.bind_gold = protocol.bind_gold
	self.money_info.gold = protocol.gold
	if self.delay_show_money then
		if self.money_show_delay == nil then
			self.money_show_delay = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.SetMoneyChange,self), 5)
		end
	else
		self:SetMoneyChange()
	end
end

-- 追踪令
function PlayerCtrl:SendSeekRoleWhere(name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSeekRoleWhere)
	protocol.seek_name = name
	protocol:EncodeAndSend()
end

-- 追踪令返回
function PlayerCtrl:OnSeekRoleInfo(protocol)
	print("追踪令返回")
	if protocol.scene_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.TraceOutLine)
		return
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.scene_id)
	local scene_type = scene_cfg and scene_cfg.scene_type or nil

	if nil == scene_type or 0 ~= scene_type then
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.TraceOnFb)
		return
	end

	local scene_name = scene_cfg and scene_cfg.name or ""
	local function ok_callback()
		ViewManager.Instance:CloseAll()
		MoveCache.end_type = MoveEndType.Normal
		GuajiCtrl.Instance:MoveToPos(protocol.scene_id, protocol.pos_x, protocol.pos_y, 0, 0)
	end
	local str = string.format(Language.Role.TraceReturnTxt, scene_name)
	local yes_button_text = Language.Common.Confirm
	local no_button_text = Language.Common.Cancel
	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback)
end

function PlayerCtrl:SetMoneyChange()
	local role_vo = PlayerData.Instance:GetRoleVo()
	if self.money_info.coin > role_vo.coin then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddCoin, self.money_info.coin - role_vo.coin))
	end
	if self.money_info.bind_coin > role_vo.bind_coin then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddCoinBind, self.money_info.bind_coin - role_vo.bind_coin))
	end
	if self.money_info.bind_gold > role_vo.bind_gold then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddGoldBind, self.money_info.bind_gold - role_vo.bind_gold))
	end
	if self.money_info.gold > role_vo.gold then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddGold, self.money_info.gold - role_vo.gold))
	end

	PlayerData.Instance:SetAttr("gold", self.money_info.gold)
	PlayerData.Instance:SetAttr("bind_gold", self.money_info.bind_gold)
	PlayerData.Instance:SetAttr("coin", self.money_info.coin)
	PlayerData.Instance:SetAttr("bind_coin", self.money_info.bind_coin)
end

--经验改变
function PlayerCtrl:OnChaExpChange(protocol)
	PlayerData.Instance:SetAttr("exp", protocol.exp)
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_EXP_CHANGE, protocol.reason, protocol.delta)
	local main_role_vo_level = GameVoManager.Instance:GetMainRoleVo().level or 0

	if main_role_vo_level > GameEnum.POPUP_EXP then
		TipsCtrl.Instance:ShowFloatingLabel(ToColorStr(string.format(Language.SysRemind.AddExp, protocol.delta, protocol.add_percent + 100), TEXT_COLOR.GREEN))
	end
end

--怒气改变
function PlayerCtrl:OnRoleNuqiChange(protocol)
	PlayerData.Instance:SetAttr("nuqi", protocol.nuqi)
end

--等级改变
function PlayerCtrl:OnLevelChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	local lv = protocol.level
	local old_lv = PlayerData.Instance:GetAttr("level")

	obj:SetAttr("level", protocol.level)
	obj:SetAttr("exp", protocol.exp)
	obj:SetAttr("max_exp", protocol.max_exp)
	if obj:IsMainRole() then
		if lv > old_lv then
			GlobalEventSystem:Fire(OtherEventType.ROLE_LEVEL_UP)
		end

		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
		-- 请求开服活动信息
		if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ROLE_UPLEVEL, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
		-- GlobalEventSystem:Fire(MainUIEventType.MAIN_RED_POINT_CHANGE)
		MainUICtrl.Instance:GetView():CheckMenuRedPoint()
	end
	FuBenCtrl.Instance:FlushFbView()

	MainUICtrl.Instance:SetButtonVisible(MainUIData.RemindingName.Show_Reincarnation,ReincarnationData.Instance:GetIsCanZs())

	if self.view:IsOpen() then
		self.view:Flush("reincarnation")
	end

end

--成就改变
function PlayerCtrl:OnAchieveChange(protocol)
	local role_vo = PlayerData.Instance:GetRoleVo()
	if role_vo.chengjiu > 0 and protocol.chengjiu > role_vo.chengjiu then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddChengJiu, protocol.chengjiu - role_vo.chengjiu))
	end

	PlayerData.Instance:SetAttr("chengjiu", protocol.chengjiu)
end

--跨服荣耀改变
function PlayerCtrl:OnCrossHonorChange(protocol)
	print(ToColorStr("跨服荣耀改变", TEXT_COLOR.GREEN))
	for k,v in pairs(protocol) do
		print(k,v)
	end
	print(ToColorStr("跨服荣耀改变", TEXT_COLOR.GREEN))
	PlayerData.Instance:SetAttr("cross_honor", protocol.honor)
	if protocol.delta_honor > 0 then
        TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddCrossHonor, protocol.delta_honor))
    end
end

--性别改变
function PlayerCtrl:OnRoleSexChange(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	obj:SetAttr("sex", protocol.sex)
end

--结婚改变
function PlayerCtrl:OnMarryChange(protocol)
	for k,v in pairs(protocol) do
		PlayerData.Instance:SetAttr(k, v)
	end
end

--战斗力变更
function PlayerCtrl:OnCapabilityChange(protocol)
	PlayerData.Instance:SetAttr("capability", protocol.capability)
	PlayerData.Instance:SetAttr("other_capability", protocol.other_capability)
	PlayerData.Instance:SetAllCapList(protocol)
	self.rank_view = RankCtrl.Instance:GetRankView()
	if RankCtrl.Instance:GetRankView():IsOpen() then
		RankCtrl.Instance:GetRankView():Flush("flush_rank")  -- 刷新排行榜个人战力显示
	end
end

--加入阵营
function PlayerCtrl:OnRoleAddCamp(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj ~= nil and obj:IsRole() then
		obj:SetAttr("camp", protocol.camp)
	end
end

--其它玩家在线信息改变
function PlayerCtrl:OnOtherUserOnlineStatus(protocol)
	GlobalEventSystem:Fire(OtherEventType.ROLE_ONLINE_CHANGE, protocol.role_id, protocol.is_online)
end

-- 灵晶改变
function PlayerCtrl:OnRoleLingJingChange(protocol)
	local delta_lingjing = protocol.lingjing - GameVoManager.Instance:GetMainRoleVo().lingjing
	if delta_lingjing > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddLingJing, delta_lingjing))
	end
	PlayerData.Instance:SetAttr("lingjing", protocol.lingjing)
end

-- 罪恶值改变
function PlayerCtrl:OnRoleEvilChange(protocol)
	local old_evil = PlayerData.Instance:GetAttr("evil")
	local msg = ""
	if protocol.evil > old_evil then
		msg = string.format("增加%d罪恶值", protocol.evil - old_evil)
	elseif protocol.evil < old_evil then
		msg = string.format("减少%d罪恶值", old_evil - protocol.evil)
	end
	TipsCtrl.Instance:ShowFloatingLabel(msg)
	PlayerData.Instance:SetAttr("evil", protocol.evil)
	if protocol.evil >= 100 and old_evil < 100 then 	--如果刚从白名变成红名
		RedNameCtrl.Instance:SetNoMoreOpen(false) 		--显示红名面板图标
	end
	ViewManager.Instance:FlushView(ViewName.Main, "red_name") --刷新主界面的红名面板图标
end

--角色名字颜色改变
function PlayerCtrl:OnRoleNameColorChange(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		if obj:IsMainRole() then
			PlayerData.Instance:SetAttr("name_color", protocol.name_color)
		end
		obj:SetAttr("name_color", protocol.name_color)
		-- obj:ReloadUIName()
	end
end

-- 魂力改变
function PlayerCtrl:OnRoleHunliChange(protocol)
	local delta_hunli = protocol.hunli - GameVoManager.Instance:GetMainRoleVo().hunli
	if delta_hunli > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddHunLi, delta_hunli))
	end
	PlayerData.Instance:SetAttr("hunli", protocol.hunli)
end

-- 声望改变
function PlayerCtrl:OnRoleShengwangChange(protocol)
	local delta_shengwang = protocol.shengwang - GameVoManager.Instance:GetMainRoleVo().shengwang
	if delta_shengwang > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddShengWang, delta_shengwang))
	end
	PlayerData.Instance:SetAttr("shengwang", protocol.shengwang)
end

function PlayerCtrl:OnAvatarTimeStampInfo(protocol)
	Scene.Instance:GetMainRole():SetAttr("is_change_avatar", protocol.is_change_avatar)
end

function PlayerCtrl:OnRoleMarryInfoChange(protocol)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.obj_id ~= protocol.obj_id then
		return
	end
	Scene.Instance:GetMainRole():SetAttr("lover_uid", protocol.lover_uid)
	Scene.Instance:GetMainRole():SetAttr("lover_name", protocol.lover_name)
	Scene.Instance:GetMainRole():SetAttr("last_marry_time", protocol.last_marry_time)

	--处理结婚红点
	MarriageCtrl.Instance:UpDataLoverTreeRedPoint()
	MarriageCtrl.Instance:MarryStateChange()
end

function PlayerCtrl:FlushPlayerView(...)
	if self.view:IsOpen() then
		self.view:Flush(...)
	end
end

function PlayerCtrl:FlushPlayerSkillView()
	if self.view:IsOpen() then
		self.view:FlushSkillView()
	end
end

function PlayerCtrl:FlushMieShiSkillView()
	if self.view:IsOpen() then
		self.view:FlushMieShiSkillView()
	end
end

function PlayerCtrl:HandleItemTipCallBack(data, handle_type, handle_param_t, item_cfg)
	if self.view:IsOpen() then
		self.view:HandleItemTipCallBack(data, handle_type, handle_param_t, item_cfg)
	end
end

function PlayerCtrl:OnSCCommonInfo(protocol)
	if protocol.info_type == SC_COMMON_INFO_TYPE.SCIT_JINGHUA_HUSONG_INFO then
		JingHuaHuSongCtrl.Instance:SetJingHuaHuSongInfo(protocol)
	elseif protocol.info_type == SC_COMMON_INFO_TYPE.SCIT_RAND_ACT_ZHUANFU_INFO then
		ServerActivityData.Instance:SetServerSystemInfo(protocol)
		GlobalEventSystem:Fire(OtherEventType.RANDOW_ACTIVITY)
	elseif protocol.info_type == SC_COMMON_INFO_TYPE.SCIT_TODAY_FREE_RELIVE_NUM then
		ReviveData.Instance:SetReviveFreeTime(protocol)
		ViewManager.Instance:FlushView(ViewName.ReviveView)
	end
end

--小天使小恶魔操作请求
function PlayerCtrl:ReqImpGuardOpera(opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSImpGuardOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function PlayerCtrl:OnImpGuardInfo(protocol)
	self.data:SetImpGuardInfo(protocol)

	if self.view:IsOpen() then
		self.view:Flush("imp_guard")
	end

	if protocol.tianshi_info.is_pop_up == 1 then
		TipsCtrl.Instance:UpDateImpGuardTimeOutData(IMP_GUARD_TYPE.TIANSHI, protocol.tianshi_info)
	elseif protocol.emo_info.is_pop_up == 1 then
		TipsCtrl.Instance:UpDateImpGuardTimeOutData(IMP_GUARD_TYPE.EMO, protocol.emo_info)
	end
	TipsCtrl.Instance:CheckImpGuardTimeOutTips()
end

function PlayerCtrl:OpenCheckEquipView()
	if self.check_equip_view then
		self.check_equip_view:Open()
	end
end

function PlayerCtrl:FlushFashionRes(role_res_id, weapon_res_id)
	self.view:FlushFashion(role_res_id, weapon_res_id)
end

function PlayerCtrl:SetTitleRemindTime(remind_time)
	if self.view.title_view then
		self.view.title_view:SetRemindTime(remind_time)
	end
end