CheckPresentView = CheckPresentView or BaseClass(BaseRender)

local Defult_Icon_List = {
	100, 1100, 3100, 4100, 5100, 6100, {8100, 8200, 8300}, 9100, 2100, 9100
	}

function CheckPresentView:__init(instance)
	CheckPresentView.Instance = self
	self.zhanli = self:FindVariable("zhanli")
	self.dengji = self:FindVariable("dengji")
	self.meili = self:FindVariable("meili")
	self.zhiye = self:FindVariable("zhiye")
	self.lover_name = self:FindVariable("banlv")
	self.guild_name = self:FindVariable("gonghui")
	self.name_text = self:FindVariable("name_text")
	self.spec_cells = {}

	self:ListenEvent("OpenPortraitBg",BindTool.Bind(self.OpenPortraitBg,self))

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
	self.role_display = self:FindObj("role_display")
	self.bing_jingtong = self:FindVariable("bing_jingtong")
	self.huo_jingtong = self:FindVariable("huo_jingtong")
	self.lei_jingtong = self:FindVariable("lei_jingtong")
	self.du_jingtong = self:FindVariable("du_jingtong")
	self.pvp_shanghai = self:FindVariable("PVPShanghai")
	self.pvp_jiacheng = self:FindVariable("PVPJiacheng")
	self.gongji_xixue = self:FindVariable("GongjiXixue")
	self.shang_hai_jia_cheng = self:FindVariable("ShangHaiJiaCheng")
	self.shang_hai_jian_mian = self:FindVariable("ShangHaiJianMian")
	self.ji_yun = self:FindVariable("JiYun")
	self.camp = self:FindVariable("camp")
	self.role_model_view = RoleModel.New("check_panel", 400)
	self.role_model_view:SetDisplay(self.role_display.ui3d_display)

	local bunble, asset = ResPath.GetImages("bg_cell_equip")
	self.item_list = {}
	for i=1, 10 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetItemCellBg(bunble, asset)
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
		self.item_list[i]:SetIsCheckItem(true)
	end
	for i = 1, MOJIE_MAX_TYPE do
			local item = ItemCell.New()
            item:SetItemCellBg(bunble, asset)
			item:SetInstanceParent(self:FindObj("SpecItem"..i))
			self.spec_cells[i] = item
	end
	-- self:UpdateMojieData()
end

function CheckPresentView:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.spec_cells) do
		v:DeleteMe()
	end
	self.spec_cells = {}
	self.role_model_view:DeleteMe()
	self.role_model_view = nil
	self.item_list = {}
	self.attr = nil
end

function CheckPresentView:OpenPortraitBg()
	TipsCtrl.Instance:ShowOtherPortraitView()
end

function CheckPresentView:OnFlush()
	if self.attr then
		self.zhanli:SetValue(self.attr.info_attr.capability or 0)
		local lv, zhuan = PlayerData.GetLevelAndRebirth(self.attr.level)
		self.dengji:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
		self.meili:SetValue(self.attr.all_charm or 0)
		self.gongji:SetValue(self.attr.info_attr.gongji or 0)
		self.fangyu:SetValue(self.attr.info_attr.fangyu or 0)
		self.shengming:SetValue(self.attr.info_attr.shengming or 0)
		self.mingzhong:SetValue(self.attr.info_attr.mingzhong or 0)
		self.shanbi:SetValue(self.attr.info_attr.shanbi or 0)
		self.baoji:SetValue(self.attr.info_attr.baoji or 0)
		self.kangbao:SetValue(self.attr.info_attr.kangbao or 0)
		self.zengshang:SetValue(self.attr.info_attr.per_pofang or 0)
		self.mianshang:SetValue(self.attr.info_attr.per_mianshang or 0)
		self.per_pojia_text:SetValue(self.attr.info_attr.ignore_fangyu or 0)
		self.per_baoji_text:SetValue(self.attr.info_attr.per_baoji or 0)
		self.evil_val:SetValue(self.attr.info_attr.evil_val or 0)
		self.bing_jingtong:SetValue(self.attr.info_attr.ice_master or 0)
		self.huo_jingtong:SetValue(self.attr.info_attr.fire_master or 0)
		self.lei_jingtong:SetValue(self.attr.info_attr.thunder_master or 0)
		self.du_jingtong:SetValue(self.attr.info_attr.poison_master or 0)
		self.pvp_shanghai:SetValue(MojieData.Instance:GetAttrRate(self.attr.info_attr.per_pvp_hurt_reduce or 0))
		self.pvp_jiacheng:SetValue(MojieData.Instance:GetAttrRate(self.attr.info_attr.per_pvp_hurt_increase or 0))

		local l_per_xixue = self.attr.info_attr.per_xixue or 0
		local l_per_stun = self.attr.info_attr.per_stun or 0
		self.gongji_xixue:SetValue(l_per_xixue * 0.01 .." %")
		self.ji_yun:SetValue(l_per_stun * 0.01 .. " %")
		self.camp:SetValue(self.attr.info_attr.camp_id or 0)
		self.shang_hai_jia_cheng:SetValue(self.attr.info_attr.hurt_increase or 0)
		self.shang_hai_jian_mian:SetValue(self.attr.info_attr.hurt_reduce or 0)
		local jiezhi_level = CheckData.Instance:GetJieZhiLevel() or 0
		local guazhui_level = CheckData.Instance:GetGuaZhuiLevel() or 0
		for i=1, 10 do
			if self.attr.equip_attr ~= nil and self.attr.equip_attr[i] ~= nil and self.attr.equip_attr[i].equip_id ~= 0 and ItemData.Instance:GetItemConfig(self.attr.equip_attr[i].equip_id or 0) then
				self.item_list[i]:SetIconGrayVisible(false)
				local data = {}
				data.index = i - 1
				data.item_id = self.attr.equip_attr[i].equip_id
				data.param = self.attr.equip_attr[i]
				data.num = 1
				data.from_view = TipsFormDef.FROM_CHECK_OTHER
				self.item_list[i]:SetData(data)
				self.item_list[i]:ShowQuality(true)
				self.item_list[i]:SetIconGrayVisible(false)
				self.item_list[i]:SetInteractable(true)
				self.item_list[i]:SetShowUpArrow(false)
				self.item_list[i]:SetShowDownArrow(false)
				self.item_list[i]:SetIconGrayScale(false)
				self.item_list[i]:SetIsShowGrade(true)
			elseif (i == 8 and guazhui_level > 0) or (i == 10 and jiezhi_level > 0) then
				self.item_list[i]:SetIconGrayVisible(false)
				local data = {}
				if i == 8 then
					data.item_id = CheckData.Instance:GetGuaZhuiSkillID()
				elseif i == 10 then
					data.item_id = CheckData.Instance:GetJieZhiSkillID()
				end
				data.num = 1
				data.from_view = TipsFormDef.FROM_CHECK_OTHER
				self.item_list[i]:SetData(data)
				self.item_list[i]:ShowQuality(true)
				self.item_list[i]:SetIconGrayVisible(false)
				self.item_list[i]:SetInteractable(true)
				self.item_list[i]:SetShowUpArrow(false)
				self.item_list[i]:SetShowDownArrow(false)
				self.item_list[i]:SetIconGrayScale(false)
				self.item_list[i]:SetIsShowGrade(true)
				if i == 8 then
					self.item_list[i]:SetIsShowGrade(false)
					self.item_list[i]:ShowStrengthLable(true)
					self.item_list[i]:SetStrength(guazhui_level)
				elseif i == 10 then
					self.item_list[i]:SetIsShowGrade(false)
					self.item_list[i]:ShowStrengthLable(true)
					self.item_list[i]:SetStrength(jiezhi_level)
				end
 			else
				local equip_id = 0
				if type(Defult_Icon_List[i]) == "table" then
					local prof = GameVoManager.Instance:GetMainRoleVo().prof
					equip_id = Defult_Icon_List[i][prof]
				else
					equip_id= Defult_Icon_List[i]
				end
				local data = {}
				data.item_id = equip_id
				-- self.item_list[i]:SetData(data)
				local bundle, asset = ResPath.GetPlayerImage("equip_bg" .. i)
				self.item_list[i]:SetAsset(bundle, asset )
				self.item_list[i]:ShowQuality(false)
				self.item_list[i]:SetInteractable(false)
				self.item_list[i]:SetShowUpArrow(false)
				self.item_list[i]:SetShowDownArrow(false)
				self.item_list[i]:SetHighLight(false)
				self.item_list[i]:SetIconGrayScale(false)
				self.item_list[i]:SetIsShowGrade(false)
				self.item_list[i]:SetBind(false)
				self.item_list[i]:SetStars(false)
				self.item_list[i]:ShowStrengthLable(false)
			end
		end
		local bunble, asset = ResPath.GetImages("bg_cell_equip")

		if self.attr.prof == 1 then
			self.zhiye:SetValue(Language.Common.ProfName[1])
		elseif self.attr.prof == 2 then
			self.zhiye:SetValue(Language.Common.ProfName[2])
		else
			self.zhiye:SetValue(Language.Common.ProfName[3])
		end
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
		-- self:SetPlayerData()
		AvatarManager.Instance:SetAvatarKey(info.role_id, info.avatar_key_big, info.avatar_key_small)
		local avatar_path_small = AvatarManager.Instance:GetAvatarKey(info.role_id)
		if AvatarManager.Instance:isDefaultImg(info.role_id) == 0 or avatar_path_small == 0 then
			self.image_obj.gameObject:SetActive(true)
			self.raw_image_obj.gameObject:SetActive(false)
			local bundle, asset = AvatarManager.GetDefAvatar(info.prof, false, info.sex)
			self.image_obj.image:LoadSprite(bundle, asset)
		else
			local function callback(path)
				if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
					return
				end
				if path == nil then
					path = AvatarManager.GetFilePath(info.role_id, false)
				end
				self.raw_image_obj.raw_image:LoadSprite(path, function ()
					self.image_obj.gameObject:SetActive(false)
					self.raw_image_obj.gameObject:SetActive(true)
				end)
			end
			AvatarManager.Instance:GetAvatar(info.role_id, true, callback)
		end
		self:SetModle()
	end
	self:UpdateMojieData()
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

function CheckPresentView:SetPlayerData(t)
	local equiplist = EquipData.Instance:GetDataList()
	self:SetData(equiplist)
end

function CheckPresentView:UpdateMojieData()
	local role_info = CheckData.Instance:GetRoleInfo()
	for i=1,4 do
		local mojie_id = {}
		mojie_id = CheckData.Instance:GetMoJieList(i-1)
		local mojie_level_info = CheckData.Instance:GetRoleInfo().mojie_level_list
		if mojie_level_info[i] > 0 then
			self.spec_cells[i]:SetData({item_id = mojie_id[i]})
			self.spec_cells[i]:SetIconGrayScale(role_info.mojie_level_list[i] <= 0)
			self.spec_cells[i]:ShowQuality(role_info.mojie_level_list[i] > 0)
			self.spec_cells[i]:ShowStrengthLable(role_info.mojie_level_list[i] > 0)
			self.spec_cells[i]:SetStrength(role_info.mojie_level_list[i])	
		else
			local bundle, asset = ResPath.GetPlayerImage("mojie_bg" .. i)
			--self.spec_cells[i]:ClearItemEvent()
			self.spec_cells[i]:SetAsset(bundle, asset )
			self.spec_cells[i]:SetIconGrayScale(false)
			self.spec_cells[i]:ShowQuality(role_info.mojie_level_list[i] > 0)
			self.spec_cells[i]:ShowStrengthLable(role_info.mojie_level_list[i] > 0)
			self.spec_cells[i]:SetStrength(role_info.mojie_level_list[i])
		end
	end
end

function CheckPresentView:OnClickMojieItem(index, data, cell)
	data.index = index
	local close_callback = function ()
		cell:SetHighLight(false)
	end
	if data.mojie_level <= 0 then
		ViewManager.Instance:Open(ViewName.Mojie, TabIndex.role_mojie)
	else
		TipsCtrl.Instance:OpenItem(data, self.from_view, nil, close_callback)
	end
	cell:SetHighLight(false)
end

function CheckPresentView:SetModle()
	-- local call_back = function(model, obj)
	-- 	local cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").role_model[001001][DISPLAY_PANEL.RANK]
	-- 	if obj then
	-- 		if cfg then
	-- 			obj.transform.localPosition = cfg.position
	-- 			obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
	-- 			obj.transform.localScale = cfg.scale
	-- 		else
	-- 			obj.transform.localPosition = Vector3(0, 0, 0)
	-- 			obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	-- 			obj.transform.localScale = Vector3(1, 1, 1)
	-- 		end
	-- 	end
	-- end
	-- UIScene:SetModelLoadCallBack(call_back)
	-- UIScene:SetActionEnable(true)
	-- local role_info = CheckData.Instance:GetRoleInfo()
	-- UIScene:SetRoleModelResInfo(role_info)
	local role_info = CheckData.Instance:GetRoleInfo()
	self.role_model_view:SetModelResInfo(role_info, false, false, false, false, true)
	self.role_model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE], tonumber(120 ..role_info.prof .. "001"), DISPLAY_PANEL.RANK)
end