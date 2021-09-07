local ATTR_INDEX = {
	MingZhong = 1,
	ShanBi = 2,
	BaoJi = 3,
	KangBao = 4,
	BingJingTong = 5,
	HuoJingTong = 6,
	LeiJingTong = 7,
	DuJingTong = 8,
}
PlayerInfoView = PlayerInfoView or BaseClass(BaseRender)

function PlayerInfoView:__init()
	
end

function PlayerInfoView:__delete()
	if self.data_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.data_change_callback)
	end
	if self.head_change ~= nil then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.remind_change ~= nil and RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.red_point = {}
end

function PlayerInfoView:LoadCallBack(instance)
	-- 监听UI事件
	self:ListenEvent("ChangeName", BindTool.Bind(self.HandleChangeName, self))
	self:ListenEvent("ChangePortrait", BindTool.Bind(self.HandleChangePortrait, self))
	self:ListenEvent("AttributeTip", BindTool.Bind(self.HandleAttributeTip, self))
	self:ListenEvent("CloseAttributeTip", BindTool.Bind(self.CloseAttributeTip, self))
	self:ListenEvent("World", BindTool.Bind(self.HandleWorld, self))
	self:ListenEvent("CloseDesTip", BindTool.Bind(self.HandleCloseDesTip, self))
	self:ListenEvent("UpClick", BindTool.Bind(self.OnUpClick, self))
	self:ListenEvent("CloseWorldLevelTip", BindTool.Bind(self.OnCloseWorldLevelTip, self))
	self:ListenEvent("PkTip", BindTool.Bind(self.PkTip, self))
	self:ListenEvent("OpenTouXianView", BindTool.Bind(self.OpenTouXianView, self))
	self:ListenEvent("OpenHonourView", BindTool.Bind(self.OpenHonourView, self))

	-- 获取变量
	self.fight_power = self:FindVariable("FightPower")
	self.portrait = self:FindVariable("Portrait")
	self.role_prof = self:FindVariable("RoleProf")
	self.name = self:FindVariable("Name")
	self.prof = self:FindVariable("Prof")
	self.guild = self:FindVariable("Guild")
	self.charm_value = self:FindVariable("CharmValue")
	self.pk_value = self:FindVariable("PKValue")
	self.level = self:FindVariable("Level")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.hp_value = self:FindVariable("HPValue")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.kang_bao = self:FindVariable("KangBao")
	self.po_jia = self:FindVariable("PoJia")
	self.bao_ji_shang_hai = self:FindVariable("BaoJiShangHai")
	self.shang_hai_jia_cheng = self:FindVariable("ShangHaiJiaCheng")
	self.shang_hai_jian_mian = self:FindVariable("ShangHaiJianMian")
	self.bing_jingtong = self:FindVariable("BingJingTong")
	self.huo_jingtong = self:FindVariable("HuoJingTong")
	self.lei_jingtong = self:FindVariable("LeiJingTong")
	self.du_jingtong = self:FindVariable("DuJingTong")
	self.gongji_xixue = self:FindVariable("GongjiXixue")
	self.jiyun = self:FindVariable("JiYun")
	self.pvp_jiacheng = self:FindVariable("PVPJiacheng")
	self.pvp_shanghai = self:FindVariable("PVPShanghai")
	self.exp = self:FindVariable("CurExp")
	self.max_exp = self:FindVariable("MaxExp")
	self.world_level = self:FindVariable("WorldLevel")
	self.world_level_exp_percent = self:FindVariable("ExpPercent")
	self.sever_level = self:FindVariable("SeverLevel")
	self.role_num = self:FindVariable("RoleNum")
	self.open_tips = self:FindVariable("OpenTips")
	self.world_open_content = self:FindVariable("WorldOpenContent")
	self.show_world_level = self:FindVariable("ShowWorldLevel")
	self.show_attribute_tip = self:FindVariable("ShowAttributeTip")

	self.attr_des = self:FindObj("AttrDes")
	self.display = self:FindObj("Display")
	self.attr_scroll = self:FindObj("AttrScroll").scroll_rect
	self.portrait_image = self:FindObj("PortraitImage")
	self.portrait_raw = self:FindObj("PortraitRaw")

	-- 功能引导按钮
	self.open_touxian = self:FindObj("BtnOpenTouXian")

	self.tips_ming_zhong = self:FindVariable("TipsMingZhong")
	self.tips_shan_bi = self:FindVariable("TipsShanBi")
	self.tips_bao_ji = self:FindVariable("TipsBaoJi")
	self.tips_kang_bao = self:FindVariable("TipsKangBao")
	self.tips_jia_chen = self:FindVariable("TipsJiaChen")
	self.tips_jian_mian = self:FindVariable("TipsJianMian")
	self.tips_remain = self:FindVariable("RemTips")
	self.show_touxian = self:FindVariable("ShowTouxian")
	self.show_honour = self:FindVariable("ShowHonour")

	self.tips_text_list = {}
	for i=1,8 do
		self.tips_text_list[i] = self:FindVariable("TipsText" .. i)
	end

	self.head_change = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE, BindTool.Bind(self.OnHeadChange, self))

	-- 属性事件处理
	self.attr_handlers = {
		capability = BindTool.Bind(self.OnFightPowerChanged, self),
		avatar_key_big = BindTool.Bind(self.OnPortraitChanged, self),
		name = BindTool.Bind(self.OnNameChanged, self),
		prof = BindTool.Bind(self.OnProfChanged, self),
		all_charm = BindTool.Bind(self.OnCharmChanged, self),
		evil = BindTool.Bind(self.OnEvilChanged, self),
		guild_name = BindTool.Bind(self.OnGuildChanged, self),
		level = BindTool.Bind(self.OnLevelChanged, self),
		exp = BindTool.Bind(self.OnExpChanged, self),
		max_exp = BindTool.Bind(self.OnExpChanged, self),
		max_hp = BindTool.Bind(self.OnHPChanged, self),
		gong_ji = BindTool.Bind(self.OnGongJiChanged, self),
		fang_yu = BindTool.Bind(self.OnFangYuChanged, self),
		ming_zhong = BindTool.Bind(self.OnMingZhongChanged, self),
		shan_bi = BindTool.Bind(self.OnShanBiChanged, self),
		bao_ji = BindTool.Bind(self.OnBaoJiChanged, self),
		jian_ren = BindTool.Bind(self.OnKaoBaoChanged, self),
		ignore_fangyu = BindTool.Bind(self.OnPoJiaChanged, self),
		per_baoji = BindTool.Bind(self.OnBaoJiShangHaiChanged, self),
		hurt_increase = BindTool.Bind(self.OnShangHaiJiaChengChanged, self),
		hurt_reduce = BindTool.Bind(self.OnShangHaiJianMianChanged, self),
		ice_master = BindTool.Bind(self.OnBingJingtongChanged, self),
		fire_master = BindTool.Bind(self.OnHuoJingtongChanged, self),
		thunder_master = BindTool.Bind(self.OnLeiJingtongChanged, self),
		poison_master = BindTool.Bind(self.OnDuJingtongChanged, self),
		per_xixue = BindTool.Bind(self.OnGongjiXixueChanged, self),
		per_stun = BindTool.Bind(self.OnJiYunChanged, self),
		per_mingzhong = BindTool.Bind(self.OnPerMingzhongChanged, self),
		per_shanbi = BindTool.Bind(self.OnPerShanbiChanged, self),
		per_kangbao = BindTool.Bind(self.OnPerKangbaoChanged, self),

		per_pofang = BindTool.Bind(self.OnPofangChanged, self),
		per_pvp_hurt_increase = BindTool.Bind(self.OnPVPJiachengChanged, self),

		per_mianshang = BindTool.Bind(self.OnMianshangChanged, self),
		per_pvp_hurt_reduce = BindTool.Bind(self.OnPVPShanghaiChanged, self),
	}

	-- 监听系统事件
	self.data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_change_callback)

	-- 首次刷新数据
	for k, v in pairs(self.attr_handlers) do
		if k ~= "exp" and k ~= "max_exp" then
			v()
		end
	end
	self:OnExpInitialized()
	self:OnHeadChange()

	self.red_point = {
		[RemindName.AvatarChange] = self:FindVariable("ShowRedPoint"),
		[RemindName.TouXian] = self:FindVariable("ShowTouXianRed"),
		[RemindName.Honour] = self:FindVariable("ShowHonourRed"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k,v in pairs(self.red_point) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	self:FlushModel()
	self:CheckTouXianBtn()
	self:CheckHonourBtn()
end

function PlayerInfoView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
		self.role_model:SetIsNeedListenRoleChange(true)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:RemoveMount()
		self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, true)
	end
end

function PlayerInfoView:OnFlush(key)
	if key == "info_view_close" then
		self:CloseCallBack()
	end
	self:CheckTouXianBtn()
	self:CheckHonourBtn()
end

function PlayerInfoView:CloseCallBack()
	self.attr_des:SetActive(false)
	self.show_world_level:SetValue(false)
end

function PlayerInfoView:HandleChangeName()
	local callback = function (new_name)
		PlayerCtrl.Instance:SendRoleResetName(1, new_name)
	end
	TipsCtrl.Instance:ShowRename(callback, nil, nil, string.format(Language.Role.SpendGold, PlayerData.Instance:GetResetNameNeedGold()))
end

function PlayerInfoView:HandleChangePortrait()
	TipsCtrl.Instance:ShowPortraitView()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:isDefaultImg(vo.role_id)
end

function PlayerInfoView:HandleAttributeTip()
	-- TipsCtrl.Instance:ShowOtherHelpTipView(1)
	self.show_attribute_tip:SetValue(true)
end

function PlayerInfoView:CloseAttributeTip()
	self.show_attribute_tip:SetValue(false)
end

function PlayerInfoView:PkTip()
	TipsCtrl.Instance:ShowHelpTipView(155)
	-- self.attr_des:SetActive(true)
	-- self.attr_scroll.normalizedPosition = Vector2(0, 1.0)
end

function PlayerInfoView:HandleWorld()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = PlayerData.Instance:GetWorldLevel() or 0
	local exp_add = 0
	if role_level < world_level and role_level >= COMMON_CONSTS.WORLD_LEVEL_OPEN then
		exp_add = COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT_BASE + (world_level - role_level) * COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT
		exp_add = (exp_add > COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT) and COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT * 1 or exp_add
	end
	self.show_world_level:SetValue(true)
	-- local world_level_befor = math.floor(world_level % 100) ~= 0 and math.floor(world_level % 100) or 100
	-- local world_level_behind = math.floor(world_level % 100) ~= 0 and math.floor(world_level / 100) or math.floor(world_level / 100) - 1
	local world_level_str = string.format(Language.Common.Zhuan_Level, world_level)
	self.world_level:SetValue(world_level_str)

	local exp_color = exp_add > 0 and "00931f" or "ff0000"
	self.world_level_exp_percent:SetValue(string.format("<color=#%s>%s%%</color>", exp_color, exp_add))

	self.world_open_content:SetValue(Language.Common.WorldOpenContent)

	local sever_level_seq, role_num, last_days = PlayerData.Instance:GetServerLevelInfo()
	local sever_level_cfg = PlayerData.Instance:GetSeverLevelCfg(sever_level_seq)
	if sever_level_cfg then
		--self.sever_level:SetValue(string.format(Language.Common.Zhuan_Level, sever_level_cfg.server_level))
		self.sever_level:SetValue(string.format(Language.Common.Zhuan_Level, PlayerData.Instance:GetServerLevel()))

		local max_cfg = PlayerData.Instance:GetSeverMaxLevelCfg()
		if max_cfg and sever_level_cfg.server_level >= max_cfg.server_level then
			self.role_num:SetValue(Language.Guild.GuildLevelMax)
		else
			local num = math.floor((role_num/sever_level_cfg.level_up_need_role_cnt) * 100)
			-- self.role_num:SetValue(math.floor((role_num/sever_level_cfg.level_up_need_role_cnt) * 100) .. "%")

			
			self.role_num:SetValue(string.format("<color=#%s>%s</color>%%", color, num))
		end
	end
	self.tips_remain:SetValue(last_days)
	self.open_tips:SetValue(Language.Common.WorldLevelContent)
end

function PlayerInfoView:OnCloseWorldLevelTip()
	self.show_world_level:SetValue(false)
end

function PlayerInfoView:HandleCloseDesTip()
	self.attr_des:SetActive(false)
end

function PlayerInfoView:OnUpClick()
	ViewManager.Instance:Open(ViewName.HelperView)
end

function PlayerInfoView:PlayerDataChangeCallback(attr_name, value, old_value)
	-- if attr_name == "name" then
	-- 	local role = Scene.Instance:GetRoleByObjId(value.obj_id)
	-- 	if role ~= nil then
	-- 		self.name:SetValue(value.game_name)
	-- 		role:ChangeFollowUiName(value.game_name)
	-- 	end
	-- end
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end

function PlayerInfoView:OnFightPowerChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fight_power:SetValue(vo.capability)
end

function PlayerInfoView:OnPortraitChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = AvatarManager.Instance.GetDefAvatar(vo.prof, true, vo.sex)
	self.portrait:SetAsset(bundle, asset)
end

function PlayerInfoView:OnNameChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local str = ToColorStr(Language.Common.ScnenCampNameAbbr[vo.camp], COLOR[CAMP_BY_STR[vo.camp]])
	str = str .. "·" .. vo.name
	self.name:SetValue(str)
end

function PlayerInfoView:OnProfChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.prof:SetValue(PlayerData.GetProfNameByType(vo.prof))
end

function PlayerInfoView:OnCharmChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.charm_value:SetValue(vo.all_charm)
end

function PlayerInfoView:OnEvilChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.pk_value:SetValue(vo.evil)
end

function PlayerInfoView:OnGuildChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_name == ""	then
		self.guild:SetValue(Language.Guild.NoGuild)
	else
		self.guild:SetValue(vo.guild_name)
	end
end

function PlayerInfoView:OnLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local lv, zhuan = PlayerData.GetLevelAndRebirth(vo.level)
	self.level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))	
end

function PlayerInfoView:OnExpInitialized()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_exp = vo.exp
	if vo.exp >= vo.max_exp then
		cup_exp = vo.exp - vo.max_exp
	else
		cup_exp = vo.exp
	end

	self.exp:SetValue(tostring(cup_exp))
	self.max_exp:SetValue(tostring(vo.max_exp))
	self.exp_radio:InitValue(cup_exp / vo.max_exp)

	local bundle, asset = ResPath.GetPlayerImage("role_prof_" .. vo.prof)
	self.role_prof:SetAsset(bundle, asset)
end

function PlayerInfoView:OnExpChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.exp:SetValue(tostring(vo.exp))
	self.max_exp:SetValue(tostring(vo.max_exp))
	self.exp_radio:SetValue(vo.exp / vo.max_exp)
end

function PlayerInfoView:OnHPChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.hp_value:SetValue(vo.max_hp)
end

function PlayerInfoView:OnGongJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.gong_ji:SetValue(vo.gong_ji)
end

function PlayerInfoView:OnFangYuChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fang_yu:SetValue(vo.fang_yu)
end

function PlayerInfoView:OnMingZhongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.ming_zhong:SetValue(vo.ming_zhong)
	if self.tips_text_list[ATTR_INDEX.ShanBi] then
		self.tips_text_list[ATTR_INDEX.ShanBi]:SetValue(string.format(Language.Role.MasterText2, vo.ming_zhong))
	end
end

function PlayerInfoView:OnShanBiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shan_bi:SetValue(vo.shan_bi)
	if self.tips_text_list[ATTR_INDEX.MingZhong] then
		self.tips_text_list[ATTR_INDEX.MingZhong]:SetValue(string.format(Language.Role.MasterText1, vo.shan_bi))
	end
end

function PlayerInfoView:OnBaoJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.bao_ji:SetValue(vo.bao_ji)
	if self.tips_text_list[ATTR_INDEX.KangBao] then
		self.tips_text_list[ATTR_INDEX.KangBao]:SetValue(string.format(Language.Role.MasterText4, vo.bao_ji))
	end
end

function PlayerInfoView:OnKaoBaoChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.kang_bao:SetValue(vo.jian_ren)
	if self.tips_text_list[ATTR_INDEX.BaoJi] then
		self.tips_text_list[ATTR_INDEX.BaoJi]:SetValue(string.format(Language.Role.MasterText3, vo.jian_ren))
	end
end

function PlayerInfoView:OnPoJiaChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.po_jia:SetValue(vo.ignore_fangyu)
end

function PlayerInfoView:OnBaoJiShangHaiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_bao_ji:SetValue(MojieData.Instance:GetAttrRate(vo.per_baoji))
end

function PlayerInfoView:OnShangHaiJiaChengChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shang_hai_jia_cheng:SetValue(vo.hurt_increase)
	-- self.tips_jia_chen:SetValue(vo.base_hurt_increase)
end

function PlayerInfoView:OnShangHaiJianMianChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shang_hai_jian_mian:SetValue(vo.hurt_reduce)
	-- self.tips_jian_mian:SetValue(vo.base_hurt_reduce)
end

function PlayerInfoView:OnBingJingtongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.bing_jingtong:SetValue(vo.ice_master)
	if self.tips_text_list[ATTR_INDEX.BingJingTong] then
		self.tips_text_list[ATTR_INDEX.BingJingTong]:SetValue(string.format(Language.Role.MasterText5, vo.ice_master))
	end
end

function PlayerInfoView:OnHuoJingtongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.huo_jingtong:SetValue(vo.fire_master)
	if self.tips_text_list[ATTR_INDEX.HuoJingTong] then
		self.tips_text_list[ATTR_INDEX.HuoJingTong]:SetValue(string.format(Language.Role.MasterText6, vo.fire_master))
	end
end

function PlayerInfoView:OnLeiJingtongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.lei_jingtong:SetValue(vo.thunder_master)
	if self.tips_text_list[ATTR_INDEX.LeiJingTong] then
		self.tips_text_list[ATTR_INDEX.LeiJingTong]:SetValue(string.format(Language.Role.MasterText7, vo.thunder_master))
	end
end

function PlayerInfoView:OnDuJingtongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.du_jingtong:SetValue(vo.poison_master)
	if self.tips_text_list[ATTR_INDEX.DuJingTong] then
		self.tips_text_list[ATTR_INDEX.DuJingTong]:SetValue(string.format(Language.Role.MasterText8, vo.poison_master))
	end
end

function PlayerInfoView:OnGongjiXixueChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.gongji_xixue:SetValue(MojieData.Instance:GetAttrRate(vo.per_xixue))
end

function PlayerInfoView:OnJiYunChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.jiyun:SetValue(MojieData.Instance:GetAttrRate(vo.per_stun))
end
function PlayerInfoView:OnPerMingzhongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_ming_zhong:SetValue(MojieData.Instance:GetAttrRate(vo.per_mingzhong))
end
function PlayerInfoView:OnPerShanbiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_shan_bi:SetValue(MojieData.Instance:GetAttrRate(vo.per_shanbi))
end
function PlayerInfoView:OnPerKangbaoChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_kang_bao:SetValue(MojieData.Instance:GetAttrRate(vo.per_kangbao))
end

function PlayerInfoView:OnPVPJiachengChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.pvp_jiacheng:SetValue(MojieData.Instance:GetAttrRate(vo.per_pvp_hurt_increase))
end

function PlayerInfoView:OnPofangChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_jia_chen:SetValue(MojieData.Instance:GetAttrRate(vo.per_pofang))
end

function PlayerInfoView:OnPVPShanghaiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.pvp_shanghai:SetValue(MojieData.Instance:GetAttrRate(vo.per_pvp_hurt_reduce))
end

function PlayerInfoView:OnMianshangChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.tips_jian_mian:SetValue(MojieData.Instance:GetAttrRate(vo.per_mianshang))
end

function PlayerInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Player) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.portrait_image.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.role_id) == 0)
	self.portrait_raw.gameObject:SetActive(AvatarManager.Instance:isDefaultImg(vo.role_id) ~= 0)
	if AvatarManager.Instance:isDefaultImg(vo.role_id) == 0 then
		local bundle, asset = AvatarManager.GetDefAvatar(vo.prof, true, vo.sex)
		self.portrait:SetAsset(bundle, asset)
		return
	end
	local callback = function (path)
		self.avatar_path_big = path or AvatarManager.GetFilePath(vo.role_id, true)
		self.portrait_raw.raw_image:LoadSprite(self.avatar_path_big, function()
		end)
	end
	AvatarManager.Instance:GetAvatar(vo.role_id, true, callback)
	-- self.portrait_raw.raw_image:LoadSprite(path, function()
	-- 	end)
end
function PlayerInfoView:RemindChangeCallBack(remind_name, num)
	if num == nil then return end
	if self.red_point[remind_name] then
		self.red_point[remind_name]:SetValue(num > 0)
	end
end

function PlayerInfoView:OpenTouXianView()
	ViewManager.Instance:Open(ViewName.TouXianView)
end

function PlayerInfoView:OpenHonourView()
	ViewManager.Instance:Open(ViewName.HonourView)
end

function PlayerInfoView:CheckTouXianBtn()
	local other_config = TouXianData.Instance:GetOtherConfig()
	if not other_config then return end
	local role_level = PlayerData.Instance:GetRoleLevel()
	self.show_touxian:SetValue(role_level >= other_config.open_level)
end

function PlayerInfoView:CheckHonourBtn()
	local role_level = PlayerData.Instance:GetRoleLevel()
	self.show_honour:SetValue(role_level >= 100)
end