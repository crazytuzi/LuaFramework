local Defult_Icon_List =
	{
		[1] = "icon_toukui",
		[2] = "icon_yifu",
		[3] = "icon_kuzi",
		[4] = "icon_xiezi",
		[5] = "icon_hushou",
		[6] = "icon_xianglian",
		[7] = "icon_wuqi",
		[8] = "icon_jiezhi",
		[9] = "icon_yaodai",
		[10] = "icon_jiezhi"
	}

CheckPresentView = CheckPresentView or BaseClass(BaseRender)

function CheckPresentView:__init(instance)
	CheckPresentView.Instance = self
	self.zhanli = self:FindVariable("zhanli")
	self.dengji = self:FindVariable("dengji")
	self.meili = self:FindVariable("meili")
	self.zhiye = self:FindVariable("zhiye")
	self.lover_name = self:FindVariable("banlv")
	self.guild_name = self:FindVariable("gonghui")
	self.name_text = self:FindVariable("name_text")

	self:ListenEvent("OpenPortraitBg", BindTool.Bind(self.OpenPortraitBg, self))
	self:ListenEvent("OnSendFlower", BindTool.Bind(self.OnSendFlower,self))

	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.kangbao = self:FindVariable("kangbao")
	self.zengshang = self:FindVariable("zengshang")
	self.mianshang = self:FindVariable("mianshang")
	self.per_pojia_text = self:FindVariable("per_pojia_text")
	self.per_baoji_text = self:FindVariable("per_baoji_text")
	self.evil_val = self:FindVariable("evil_val")
	self.show_blue_bg = self:FindVariable("show_blue_bg")
	self.image_obj = self:FindObj("image_obj")
	self.raw_image_obj = self:FindObj("raw_image_obj")
	self.image_res = self:FindVariable("ImageRes")
	self.item_list = {}
	for i=1, 10 do
		self.item_list[i] = EquipItemCell.New(self:FindObj("item_"..i))
		self.item_list[i]:ListenClick(BindTool.Bind(self.ItemClick, self, i))
	end

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_check_player_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckPresentView:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.image_res = nil
end

function CheckPresentView:OpenPortraitBg()
	local role_info = CheckData.Instance:GetRoleInfo()
	local data = CommonStruct.PortraitInfo()
	data.role_id = role_info.role_id
	data.prof = role_info.prof
	data.sex = role_info.sex
	data.avatar_key_big = role_info.avatar_key_big
	data.avatar_key_small = role_info.avatar_key_small

	TipsCtrl.Instance:ShowOtherPortraitView(data)
end

function CheckPresentView:OnSendFlower()
	local role_info = CheckData.Instance:GetRoleInfo()
	FlowersCtrl.Instance:SetFriendInfo(role_info)
	ViewManager.Instance:Open(ViewName.Flowers)
end

function CheckPresentView:ItemClick(index)
    if self.attr.equip_attr == nil or not next(self.attr.equip_attr[index]) then return end

	if 0 == self.attr.equip_attr[index].equip_id then
		self.item_list[index]:SetHightLight(false)
		return
	end

	local data = {}
	data.index = index - 1
	data.item_id = self.attr.equip_attr[index].equip_id
	data.param = self.attr.equip_attr[index]
	data.num = 1
	data.use_eternity_level = self.attr.info_attr and self.attr.info_attr.use_eternity_level or 0

	local close_callback = function ()
		self.item_list[index]:SetHightLight(false)
	end

	TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROME_BROWSE_ROLE, nil, close_callback)
end

function CheckPresentView:OnFlush()
	if self.attr and self.attr.info_attr and self.attr.info_attr.capability then
		self.zhanli:SetValue(self.attr.info_attr.capability or 0)
		local lv = PlayerData.GetLevelString(self.attr.level)
		self.dengji:SetValue(lv)
		self.meili:SetValue(self.attr.all_charm)
		self.gongji:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.gongji))
		self.fangyu:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.fangyu))
		self.shengming:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.shengming))
		self.mingzhong:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.mingzhong))
		self.shanbi:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.shanbi))
		self.baoji:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.baoji))
		self.kangbao:SetValue(CommonDataManager.ConverTenNum(self.attr.info_attr.kangbao))
		self.zengshang:SetValue(self.attr.info_attr.per_pofang)
		self.mianshang:SetValue(self.attr.info_attr.per_mianshang)
		self.per_pojia_text:SetValue(self.attr.info_attr.per_jingzhun)
		self.per_baoji_text:SetValue(self.attr.info_attr.per_baoji)
		self.evil_val:SetValue(self.attr.info_attr.evil_val)
		for i=1, 10 do
			if self.attr.equip_attr[i].equip_id ~= 0 and ItemData.Instance:GetItemConfig(self.attr.equip_attr[i].equip_id) then
				local data = {}
				data.index = i - 1
				data.item_id = self.attr.equip_attr[i].equip_id
				data.param = self.attr.equip_attr[i]
				data.num = 1
				self.item_list[i]:SetData(data)
			else
				self.item_list[i]:SetData(nil)
				self.item_list[i]:SetIcon(ResPath.GetEquipShadowDefualtIcon(Defult_Icon_List[i]))
			end
		end

		local prof_name = Language.Common.ProfName[self.attr.prof] or ""
		self.zhiye:SetValue(prof_name)

		if self.attr.lover_name == "" then
			self.lover_name:SetValue(Language.Marriage.NoPartner)
		else
			self.lover_name:SetValue(self.attr.lover_name)
		end

		if self.attr.guild_name == "" then
			self.guild_name:SetValue(Language.Guild.NoGuild)
		else
			self.guild_name:SetValue(self.attr.guild_name)
		end
		self.name_text:SetValue(self.attr.role_name)

		local info = CheckData.Instance:GetRoleInfo()
		AvatarManager.Instance:SetAvatarKey(info.role_id, info.avatar_key_big, info.avatar_key_small)
		local avatar_path_small = AvatarManager.Instance:GetAvatarKey(info.role_id)
		CommonDataManager.SetAvatar(info.role_id, self.raw_image_obj, self.image_obj, self.image_res, info.sex, info.prof, true)
		self:SetModle()
	end
end

function CheckPresentView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.present_attr then
		self.attr = check_attr.present_attr
		self.attr.used_imageid = check_attr.wing_attr.used_imageid
		self.attr.info_attr = check_attr.info_attr
		self.attr.equip_attr = check_attr.equip_attr
		self.attr.halo_attr = check_attr.halo_attr
		self:Flush()
	end
end

function CheckPresentView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	self.model:SetModelResInfo(role_info, false, false, true)
	self:SetWaistModel()
	self:SetHeadModel()
	self:SetArmModel()
	self:SetMaskResid()
	-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE], 001001, DISPLAY_PANEL.RANK)
end

function CheckPresentView:SetWaistModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.waist_info then
		if role_info.waist_info.capability > 0 then
			local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(role_info.waist_info.grade)
			if nil == grade_info then
				return
			end

			--对应资源数据
			local image_info = WaistData.Instance:GetWaistImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetWaistResid(image_info.res_id)
		end
	end
end

function CheckPresentView:SetHeadModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.head_info then
		if role_info.head_info.capability > 0 then
			local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(role_info.head_info.grade)
			if nil == grade_info then
				return
			end

			--对应资源数据
			local image_info = TouShiData.Instance:GetTouShiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetTouShiResid(image_info.res_id)
		end
	end
end

function CheckPresentView:SetArmModel()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.arm_info then
		if role_info.arm_info.capability > 0 then
			local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(role_info.arm_info.grade)
			if nil == grade_info then
				return
			end
			--对应资源数据
			local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_info then
				return
			end
			self.model:SetQilinBiResid(image_info["res_id" .. role_info.sex], role_info.sex)
		end
	end
end

function CheckPresentView:SetMaskResid()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info.mask_info then
		if role_info.mask_info.capability > 0 then
			local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(role_info.mask_info.grade)
			if nil == grade_info then
				return
			end
			--对应资源数据
			-- local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
			-- if nil == image_info then
			-- 	return
			-- end
			local res_id = MaskData.Instance:GetResIdByImageId(grade_info.image_id)
			self.model:SetMaskResid(res_id)
		end
	end
end