CheckShenGongView = CheckShenGongView or BaseClass(BaseRender)
function CheckShenGongView:__init(instance)
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.mingzhong = self:FindVariable("mingzhong")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji = self:FindVariable("baoji")
	self.kangbao = self:FindVariable("kangbao")
	self.zengshang = self:FindVariable("zengshang")
	self.mianshang = self:FindVariable("mianshang")
	self.grade = self:FindVariable("step")
	self.zhan_li = self:FindVariable("zhan_li")
	self.show_name = self:FindVariable("show_name")
	self.name_text = self:FindVariable("name_text")
	self.name = self:FindVariable("name")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_check_shengong_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckShenGongView:__delete()
	self.attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function CheckShenGongView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.attr = check_attr
		self:Flush()
	end
end

function CheckShenGongView:OnFlush()
	if self.attr then
		self.gongji:SetValue(self.attr.shengong_attr.gong_ji)
		self.fangyu:SetValue(self.attr.shengong_attr.fang_yu)
		self.shengming:SetValue(self.attr.shengong_attr.max_hp)
		self.mingzhong:SetValue(self.attr.shengong_attr.ming_zhong)
		self.shanbi:SetValue(self.attr.shengong_attr.shan_bi)
		self.baoji:SetValue(self.attr.shengong_attr.bao_ji)
		self.kangbao:SetValue(self.attr.shengong_attr.jian_ren)
		self.zengshang:SetValue(self.attr.shengong_attr.per_pofang)
		self.mianshang:SetValue(self.attr.shengong_attr.per_mianshang)
		self.grade:SetValue(CheckData.Instance:GetGradeName(self.attr.shengong_attr.client_grade))
		self.zhan_li:SetValue(self.attr.shengong_attr.capability)
		local grade = self.attr.shengong_attr.client_grade + 1
		self.show_name:SetValue(true)

		if ShengongData.Instance:GetShengongGradeCfg(grade) == nil then return end

		local image_id = ShengongData.Instance:GetShengongGradeCfg(grade).image_id
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)

		--设置伙伴光环名字
		local name_str = ""
		if self.attr.shengong_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			--说明使用的是特殊形象
			local cfg_info = ShengongData.Instance:GetSpecialImagesCfg()[self.attr.shengong_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if nil ~= cfg_info then
				local item_cfg = ItemData.Instance:GetItemConfig(cfg_info.item_id)
				if nil ~= item_cfg then
					local color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
					name_str = ToColorStr(cfg_info.image_name, color)
				end
			end

		elseif ShengongData.Instance:GetShengongImageCfg()[image_id] then
			name_str = "<color="..SOUL_NAME_COLOR[color]..">" .. ShengongData.Instance:GetShengongImageCfg()[image_id].image_name .. "</color>"
		end
		self.name_text:SetValue(name_str)

		self.show_grade:SetValue(true)
		local bundle, asset = nil, nil
		if math.floor(grade / 3 + 1) >= 5 then
			 bundle, asset = ResPath.GetShengongGradeQualityBG(5)
		else
			 bundle, asset = ResPath.GetShengongGradeQualityBG(math.floor(grade / 3 + 1))
		end
		self.quality:SetAsset(bundle, asset)
		self:SetModle()
	end
end

function CheckShenGongView:SetModle()
	if self.attr.shengong_attr.used_imageid == 0 then
		return
	end
	if self.attr and self.attr.shengong_attr.client_grade + 1 ~= 0 then
		local info = {}
		local goddess_data = GoddessData.Instance

		info.role_res_id = -1
		local goddess_huanhua_id = self.attr.xiannv_attr.huanhua_id
		
		if goddess_huanhua_id > 0 and goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id) then
			info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
		else
			local goddess_id = self.attr.xiannv_attr.pos_list[1]
			if goddess_id == -1 then
				goddess_id = 0
			end
			info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
		end

		if self.attr.shengong_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShengongData.Instance:GetSpecialImagesCfg()[self.attr.shengong_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShengongData.Instance:GetShengongImageCfg()[self.attr.shengong_attr.used_imageid].res_id
		end

		info.weapon_res_id = res_id

		-- local call_back = function(model, obj)
		-- 	local cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").shengong_model[001001][DISPLAY_PANEL.RANK]
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
		-- local bundle1, asset1 = ResPath.GetGoddessModel(info.role_res_id)
		-- local bundle2, asset2 = ResPath.GetGoddessWeaponModel(info.weapon_res_id)

		-- local bundle_list = {[SceneObjPart.Main] = bundle1, [SceneObjPart.Weapon] = bundle2}
		-- local asset_list = {[SceneObjPart.Main] = asset1, [SceneObjPart.Weapon] = asset2}
		-- UIScene:ModelBundle(bundle_list, asset_list)

		-- if self.time_quest ~= nil then
		-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
		-- end

		self.model:SetGoddessModelResInfo(info)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], asset, DISPLAY_PANEL.RANK)
		local bundle, asset = ResPath.GetGoddessModel(info.role_res_id)
		self.model:SetMainAsset(bundle, asset)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], asset, DISPLAY_PANEL.RANK)
	else
		--UIScene:IsNotCreateRoleModel(false)
	end
end

function CheckShenGongView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

-- function CheckShenGongView:CalToShowAnim()
-- 	self:CancelTheQuest()
-- 	local part = nil
-- 	if UIScene.role_model then
-- 		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
-- 	end
-- 	self.timer = FIX_SHOW_TIME
-- 	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
-- 		self.timer = self.timer - UnityEngine.Time.deltaTime
-- 		if self.timer <= 0 then
-- 			if part then
-- 				part:SetTrigger("attack1")
-- 			end
-- 			self.timer = FIX_SHOW_TIME
-- 		end
-- 	end, 0)
-- end
