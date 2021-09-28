GodTempleShenQiView = GodTempleShenQiView or BaseClass(BaseRender)

function GodTempleShenQiView:__init()
	self.model = RoleModel.New("display_god_temple_shenqi")
	self.model:SetDisplay(self:FindObj("display").ui3d_display)

	self.is_max = self:FindVariable("is_max")
	self.now_add_exp_per = self:FindVariable("now_add_exp_per")
	self.next_add_exp_per = self:FindVariable("next_add_exp_per")
	self.max_hp = self:FindVariable("max_hp")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.next_add_hp = self:FindVariable("next_add_hp")
	self.next_add_gongji = self:FindVariable("next_add_gongji")
	self.next_add_fangyu = self:FindVariable("next_add_fangyu")
	self.now_exp_value = self:FindVariable("now_exp_value")
	self.max_exp_value = self:FindVariable("max_exp_value")
	self.add_exp_value = self:FindVariable("add_exp_value")
	self.level = self:FindVariable("level")
	self.title_name = self:FindVariable("title_name")
	self.power = self:FindVariable("power")
	self.exp_pro = self:FindVariable("exp_pro")
	self.next_active_layer = self:FindVariable("next_active_layer")

	self:ListenEvent("ClickFetch", BindTool.Bind(self.ClickFetch, self))
	self:ListenEvent("ClickGo", BindTool.Bind(self.ClickGo, self))
end

function GodTempleShenQiView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function GodTempleShenQiView:ClickFetch()
	GodTempleShenQiCtrl.Instance:ReqPataFbNewGetSheneqiExp()
end

function GodTempleShenQiView:ClickGo()
	ViewManager.Instance:Open(ViewName.GodTempleView, TabIndex.godtemple_pata)
	-- FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GOD_TEMPLE)
end

function GodTempleShenQiView:InitView()
	self.is_init = true
	self:FlushView()
end

function GodTempleShenQiView:CloseView()
end

function GodTempleShenQiView:FlushModel()
	local shenqi_cfg_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel()
	if shenqi_cfg_info == nil then
		return
	end

	local bundle, asset = ResPath.GetGodTempleShenQiModel(shenqi_cfg_info.res_id)
	self.model:SetMainAsset(bundle, asset)
end

function GodTempleShenQiView:FlushContent()
	local shenqi_level = GodTempleShenQiData.Instance:GetShenQiLevel()
	local shenqi_cfg_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel(shenqi_level)
	if shenqi_cfg_info == nil then
		return
	end

	self.level:SetValue(shenqi_level)
	self.title_name:SetValue(shenqi_cfg_info.res_name)
	local power = CommonDataManager.GetCapabilityCalculation(shenqi_cfg_info)
	self.power:SetValue(power)

	local now_exp = GodTempleShenQiData.Instance:GetShenQiExp()
	local max_exp = shenqi_cfg_info.exp_max
	local exp_pro = now_exp / max_exp
	self.now_exp_value:SetValue(CommonDataManager.ConverMoney(now_exp))
	self.max_exp_value:SetValue(CommonDataManager.ConverMoney(max_exp))
	if self.is_init then
		self.exp_pro:InitValue(exp_pro)
		self.is_init = false
	else
		self.exp_pro:SetValue(exp_pro)
	end

	self.add_exp_value:SetValue(shenqi_cfg_info.add_exp_per_min)

	local next_shenqi_cfg_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel(shenqi_level + 1)
	local is_max = next_shenqi_cfg_info == nil
	self.is_max:SetValue(is_max)

	if not is_max then
		self.next_active_layer:SetValue(next_shenqi_cfg_info.need_pata_level)

		self.next_add_exp_per:SetValue(next_shenqi_cfg_info.add_exp_per)

		local add_hp = next_shenqi_cfg_info.maxhp - shenqi_cfg_info.maxhp
		self.next_add_hp:SetValue(add_hp)

		local add_gongji = next_shenqi_cfg_info.gongji - shenqi_cfg_info.gongji
		self.next_add_gongji:SetValue(add_gongji)

		local add_fangyu = next_shenqi_cfg_info.fangyu - shenqi_cfg_info.fangyu
		self.next_add_fangyu:SetValue(add_fangyu)
	end

	self.now_add_exp_per:SetValue(shenqi_cfg_info.add_exp_per)
	self.max_hp:SetValue(shenqi_cfg_info.maxhp)
	self.gongji:SetValue(shenqi_cfg_info.gongji)
	self.fangyu:SetValue(shenqi_cfg_info.fangyu)
end

function GodTempleShenQiView:FlushView()
	self:FlushModel()
	self:FlushContent()
end

function GodTempleShenQiView:OnFlush()
	self:FlushView()
end