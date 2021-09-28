CheckFightMountView = CheckFightMountView or BaseClass(BaseRender)

local DISPLAYNAME = {
	[7109001] = "player_fight_mount_panel_1",
	[7103001] = "player_fight_mount_panel_2",
	[7106001] = "player_fight_mount_panel_3",
	[7108001] = "player_fight_mount_panel_4",
	[7005001] = "player_fight_mount_panel_5",
}
function CheckFightMountView:__init(instance)
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.kangbao = self:FindVariable("kangbao")
	-- self.zengshang = self:FindVariable("zengshang")
	-- self.mianshang = self:FindVariable("mianshang")
	self.show_name = self:FindVariable("show_name")
	self.name = self:FindVariable("name")
	self.step = self:FindVariable("step")
	self.level = self:FindVariable("level")
	self.zhan_li = self:FindVariable("zhan_li")
	self.name_text = self:FindVariable("name_text")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_fight_mount_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckFightMountView:__delete()
	self.fight_attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function CheckFightMountView:OnFlush()
 	if self.fight_attr then
 		self.gongji:SetValue(self.fight_attr.gong_ji)
		self.fangyu:SetValue(self.fight_attr.fang_yu)
		self.shengming:SetValue(self.fight_attr.max_hp)
		self.mingzhong:SetValue(self.fight_attr.ming_zhong)
		self.shanbi:SetValue(self.fight_attr.shan_bi)
		self.baoji:SetValue(self.fight_attr.bao_ji)
		self.kangbao:SetValue(self.fight_attr.jian_ren)
		-- self.zengshang:SetValue(self.fight_attr.per_pofang)
		-- self.mianshang:SetValue(self.fight_attr.per_mianshang)
		self.step:SetValue(CheckData.Instance:GetGradeName(self.fight_attr.client_grade))
		self.zhan_li:SetValue(self.fight_attr.capability)
		local grade = self.fight_attr.client_grade + 1
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local used_imageid = self.fight_attr.used_imageid
		local name_str = ""
		if self.fight_attr.used_imageid == 0 then
			self.show_name:SetValue(false)
			-- self.name_text:SetValue("零阶")
		else
			self.show_name:SetValue(true)
			if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
				used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
				name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FightMountData.Instance:GetSpecialImagesCfg()[used_imageid].image_name.."</color>"
			else
				name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FightMountData.Instance:GetMountImageCfg()[used_imageid].image_name.."</color>"
			end
			self.name_text:SetValue(name_str)
		end

		if self.fight_attr.client_grade == 0 then
			self.show_grade:SetValue(false)
		else
			self.show_grade:SetValue(true)
			local bundle, asset = nil, nil
			if math.floor(grade / 3 + 1) >= 5 then
				 bundle, asset = ResPath.GetMountGradeQualityBG(5)
			else
				 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(grade / 3 + 1))
			end
			self.quality:SetAsset(bundle, asset)
		end
		self:SetModle()
 	end
end

function CheckFightMountView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.fight_attr then
		self.fight_attr = check_attr.fight_attr
		self:Flush()
	end
end

function CheckFightMountView:SetModle()
	local mount_res_id = 0
	if self.fight_attr.client_grade + 1 ~= 0 then
		if self.fight_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			mount_res_id = FightMountData.Instance:GetSpecialImagesCfg()[self.fight_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			if self.fight_attr.used_imageid == 0 then
				mount_res_id = 0
			else
				mount_res_id = FightMountData.Instance:GetMountImageCfg()[self.fight_attr.used_imageid].res_id
			end
		end
		-- local call_back = function(model, obj)
		-- 	local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], mount_res_id, DISPLAY_PANEL.RANK)
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
		-- 	model:SetTrigger("rest")
		-- end
		-- UIScene:SetModelLoadCallBack(call_back)
		-- bundle, asset = ResPath.GetFightMountModel(mount_res_id)
		-- local bundle_list = {[SceneObjPart.Main] = bundle}
		-- local asset_list = {[SceneObjPart.Main] = asset}
		-- UIScene:ModelBundle(bundle_list, asset_list)
		local display_name = "player_fight_mount_panel"
		for k,v in pairs(DISPLAYNAME) do
			if k == mount_res_id then
				display_name = v
				break
			end
		end
		self.model:SetPanelName(display_name)
		local bundle, asset = ResPath.GetFightMountModel(mount_res_id)
		self.model:SetMainAsset(bundle, asset)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], asset, DISPLAY_PANEL.RANK)
	end
end