PlayerInfoView = PlayerInfoView or BaseClass(BaseRender)

function PlayerInfoView:__init()
	-- 监听UI事件
	self:ListenEvent("ChangeName",
		BindTool.Bind(self.HandleChangeName, self))
	self:ListenEvent("ChangePortrait",
		BindTool.Bind(self.HandleChangePortrait, self))
	self:ListenEvent("AttributeTip",
		BindTool.Bind(self.HandleAttributeTip, self))
	self:ListenEvent("World",
		BindTool.Bind(self.HandleWorld, self))
	self:ListenEvent("CloseDesTip",
		BindTool.Bind(self.HandleCloseDesTip, self))
	self:ListenEvent("UpClick",
		BindTool.Bind(self.OnUpClick, self))
	self:ListenEvent("PkTip",
		BindTool.Bind(self.PkTip, self))
	self:ListenEvent("OpenTouxian",
		BindTool.Bind(self.OpenTouxian, self))


	-- 获取变量
	self.fight_power = self:FindVariable("FightPower")
	self.portrait = self:FindVariable("Portrait")
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
	self.exp = self:FindVariable("CurExp")
	self.max_exp = self:FindVariable("MaxExp")
	self.move_speed = self:FindVariable("Speed")
	self.touxian_can_up = self:FindVariable("TouxianCanUp")

	self.show_red_point = self:FindVariable("ShowRedPoint")

	self.attr_des = self:FindObj("AttrDes")
	self.attr_scroll = self:FindObj("AttrScroll").scroll_rect
	self.portrait_image = self:FindObj("PortraitImage")
	self.portrait_raw = self:FindObj("PortraitRaw")
	self.cur_touxian = self:FindObj("Touxian")
	self.next_touxian = self:FindObj("TouxianNext")
	self.cap_need = self:FindVariable("FightPercent")
	self.show_change_port_btn = self:FindVariable("ShowChangePortBtn")
	self.show_change_port_btn:SetValue(OtherData.Instance:CanChangePortrait())


	self.head_change = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE,
						BindTool.Bind(self.OnHeadChange, self))
	self.temp_head_change = GlobalEventSystem:Bind(ObjectEventType.TEMP_HEAD_CHANGE,
						BindTool.Bind(self.ChangeTempHead, self))

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
		base_max_hp = BindTool.Bind(self.OnHPChanged, self),
		base_gongji = BindTool.Bind(self.OnGongJiChanged, self),
		base_fangyu = BindTool.Bind(self.OnFangYuChanged, self),
		base_mingzhong = BindTool.Bind(self.OnMingZhongChanged, self),
		base_shanbi = BindTool.Bind(self.OnShanBiChanged, self),
		base_baoji = BindTool.Bind(self.OnBaoJiChanged, self),
		base_jianren = BindTool.Bind(self.OnKaoBaoChanged, self),
		base_per_jingzhun = BindTool.Bind(self.OnPoJiaChanged, self),
		base_per_baoji = BindTool.Bind(self.OnBaoJiShangHaiChanged, self),
		base_per_pofang = BindTool.Bind(self.OnShangHaiJiaChengChanged, self),
		base_per_mianshang = BindTool.Bind(self.OnShangHaiJianMianChanged, self),
		base_move_speed = BindTool.Bind(self.OnMoveSpeedChanged, self),
		touxian = BindTool.Bind(self.OnTouxianChanged, self),
	}

	-- 监听系统事件
	self.data_change_callback = BindTool.Bind1(
		self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_change_callback)

	-- 首次刷新数据
	for k, v in pairs(self.attr_handlers) do
		if k ~= "exp" and k ~= "max_exp" then
			v()
		end
	end
	self:OnExpInitialized()
	self:OnHeadChange()
	self:SetAttrFight()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.AvatarChange)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Touxian)

end

function PlayerInfoView:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.data_change_callback)
	if self.head_change ~= nil then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end
	if self.temp_head_change ~= nil then
		GlobalEventSystem:UnBind(self.temp_head_change)
		self.temp_head_change = nil
	end

	RemindManager.Instance:UnBind(self.remind_change)
end

function PlayerInfoView:CloseCallBack()
	self.attr_des:SetActive(false)
end

function PlayerInfoView:HandleChangeName()
	local callback = function (new_name)
		PlayerCtrl.Instance:SendRoleResetName(1, new_name)
	end
	TipsCtrl.Instance:ShowRename(callback, true, PlayerDataReNameItemId.ItemId)
end

function PlayerInfoView:HandleChangePortrait()
	ViewManager.Instance:Open(ViewName.TipsPortraitView)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:isDefaultImg(vo.role_id)
end

function PlayerInfoView:HandleAttributeTip()
	TipsCtrl.Instance:ShowOtherHelpTipView(1)
	-- self.attr_des:SetActive(true)
	-- self.attr_scroll.normalizedPosition = Vector2(0, 1.0)
end

function PlayerInfoView:PkTip()
	TipsCtrl.Instance:ShowHelpTipView(155)
	-- self.attr_des:SetActive(true)
	-- self.attr_scroll.normalizedPosition = Vector2(0, 1.0)
end

function PlayerInfoView:OpenTouxian()
	ViewManager.Instance:Open(ViewName.Touxian)
end

function PlayerInfoView:HandleWorld()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = RankData.Instance:GetWordLevel() or 0
	local exp_add = 0
	if role_level < world_level and role_level >= COMMON_CONSTS.WORLD_LEVEL_OPEN then
		exp_add = (world_level - role_level - COMMON_CONSTS.WORLD_LEVEL_LIMIT) * COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT
		if world_level - role_level - COMMON_CONSTS.WORLD_LEVEL_LIMIT < 0 then
			exp_add = 0
		end
		exp_add = (exp_add > COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT) and COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT * 1 or exp_add
	end
	-- local world_level_befor = math.floor(world_level % 100) ~= 0 and math.floor(world_level % 100) or 100
	-- local world_level_behind = math.floor(world_level % 100) ~= 0 and math.floor(world_level / 100) or math.floor(world_level / 100) - 1
	-- local world_level_str = string.format(Language.Common.Zhuan_Level, world_level_befor, world_level_behind)
	local world_level_str = PlayerData.GetLevelString(world_level)
	-- self.world_level:SetValue(world_level_str)
	-- self.world_level_exp_percent:SetValue(exp_add.."%")
	-- local open_level_befor = math.floor(COMMON_CONSTS.WORLD_LEVEL_OPEN % 100) ~= 0 and math.floor(COMMON_CONSTS.WORLD_LEVEL_OPEN % 100) or 100
	-- local open_level_behind = math.floor(COMMON_CONSTS.WORLD_LEVEL_OPEN % 100) ~= 0 and math.floor(COMMON_CONSTS.WORLD_LEVEL_OPEN / 100) or
	-- 							math.floor(COMMON_CONSTS.WORLD_LEVEL_OPEN / 100) - 1
	-- local open_level_str = string.format(Language.Common.Zhuan_Level, open_level_befor, open_level_behind)
	local open_level_str = PlayerData.GetLevelString(COMMON_CONSTS.WORLD_LEVEL_OPEN)
	-- self.world_open_level:SetValue(open_level_str)

	TipsCtrl.Instance:ShowWorldLevelView(open_level_str, world_level_str, exp_add.."%")
end

function PlayerInfoView:HandleCloseDesTip()
	self.attr_des:SetActive(false)
end

function PlayerInfoView:OnFlush(param_list)
	self:SetAttrFight()
end

function PlayerInfoView:SetAttrFight()
	local cur_touxian_level = TouxianData.Instance:GetTouxianLevel()
	local cur_touxian_cfg = TouxianData.Instance:GetTouxianCfg(cur_touxian_level)

	if cur_touxian_cfg then
		self.cur_touxian.text.text = cur_touxian_level > 0 and cur_touxian_cfg.name or Language.Role.NoTouxian
		self.cur_touxian.outline.effectColor = TouxianData.GetTouxianColor(cur_touxian_level)
	end

	local n_touxian_cfg = TouxianData.Instance:GetTouxianCfg(cur_touxian_level + 1)
	self.next_touxian:SetActive(n_touxian_cfg ~= nil)
	if n_touxian_cfg then
		self.next_touxian.text.text = n_touxian_cfg.name
		self.next_touxian.outline.effectColor = TouxianData.GetTouxianColor(cur_touxian_level + 1)
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		local str = "%d/%d"
		if role_cap < n_touxian_cfg.cap_limit then
			str = "<color=#fe3030>%d</color>/%d"
		else
			str = "<color=#00ff00>%d</color>/%d"
		end

		self.cap_need:SetValue(string.format(str, role_cap, n_touxian_cfg.cap_limit))
	else
		self.cap_need:SetValue(Language.Common.YiManJi)
	end
end

function PlayerInfoView:OpenCallBack()
	-- self:SetRoleData()
	self:Flush()

end

function PlayerInfoView:OnUpClick()
	ViewManager.Instance:Open(ViewName.HelperView)
end

function PlayerInfoView:PlayerDataChangeCallback(attr_name, value, old_value)
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end

function PlayerInfoView:OnFightPowerChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fight_power:SetValue(vo.capability)
	self:SetAttrFight()
end

function PlayerInfoView:OnPortraitChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = AvatarManager.Instance.GetDefAvatar(vo.prof, true, vo.sex)
	self.portrait:SetAsset(bundle, asset)
end

function PlayerInfoView:OnNameChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.name:SetValue(vo.name)
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
		self.guild:SetValue(Language.Role.NoGuild)
	else
		self.guild:SetValue(vo.guild_name)
	end
end

function PlayerInfoView:OnLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local lv = PlayerData.GetLevelString(vo.level)
	self.level:SetValue(lv)
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
end

function PlayerInfoView:OnExpChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.exp:SetValue(tostring(vo.exp))
	self.max_exp:SetValue(tostring(vo.max_exp))
	self.exp_radio:SetValue(vo.exp / vo.max_exp)
end

function PlayerInfoView:OnHPChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.hp_value:SetValue(CommonDataManager.ConverTenNum(vo.base_max_hp))
end

function PlayerInfoView:OnGongJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.gong_ji:SetValue(CommonDataManager.ConverTenNum(vo.base_gongji))
end

function PlayerInfoView:OnFangYuChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fang_yu:SetValue(CommonDataManager.ConverTenNum(vo.base_fangyu))
end

function PlayerInfoView:OnMingZhongChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.ming_zhong:SetValue(CommonDataManager.ConverTenNum(vo.base_mingzhong))
end

function PlayerInfoView:OnShanBiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shan_bi:SetValue(CommonDataManager.ConverTenNum(vo.base_shanbi))
end

function PlayerInfoView:OnBaoJiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.bao_ji:SetValue(CommonDataManager.ConverTenNum(vo.base_baoji))
end

function PlayerInfoView:OnKaoBaoChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.kang_bao:SetValue(CommonDataManager.ConverTenNum(vo.base_jianren))
end

function PlayerInfoView:OnPoJiaChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.po_jia:SetValue(CommonDataManager.ConverTenNum(vo.base_per_jingzhun))
end

function PlayerInfoView:OnBaoJiShangHaiChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.bao_ji_shang_hai:SetValue(CommonDataManager.ConverTenNum(vo.base_per_baoji))
end

function PlayerInfoView:OnShangHaiJiaChengChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shang_hai_jia_cheng:SetValue(CommonDataManager.ConverTenNum(vo.base_per_pofang))
end

function PlayerInfoView:OnShangHaiJianMianChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.shang_hai_jian_mian:SetValue(CommonDataManager.ConverTenNum(vo.base_per_mianshang))
end

function PlayerInfoView:OnMoveSpeedChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local percent_speed = vo.move_speed / GameEnum.BASE_SPEED * 100  --1400是基础速度

	self.move_speed:SetValue(math.ceil(percent_speed).."%")
end

function PlayerInfoView:OnTouxianChanged()
	self:SetAttrFight()
end

function PlayerInfoView:ChangeTouXianRemind()
	self.touxian_can_up:SetValue(RemindManager.Instance:GetRemind(RemindName.Touxian) > 0)
end

function PlayerInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Player) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	CommonDataManager.SetAvatar(vo.role_id, self.portrait_raw, self.portrait_image, self.portrait, vo.sex, vo.prof, true)
end

function PlayerInfoView:ChangeTempHead(path)
	if nil == path then
		return
	end

	self.portrait_raw.raw_image:LoadSprite(path, function()
		self.portrait_image.gameObject:SetActive(false)
		self.portrait_raw.gameObject:SetActive(true)
	end)
end

function PlayerInfoView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.AvatarChange then
		self.show_red_point:SetValue(num > 0)
	elseif remind_name == RemindName.Touxian then
		self:ChangeTouXianRemind()
	end
end

function PlayerInfoView:FlushForbidAvaterChange()
	if self.show_change_port_btn then
		self.show_change_port_btn:SetValue(OtherData.Instance:CanChangePortrait())
	end
end