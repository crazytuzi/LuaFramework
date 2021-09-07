CheckFightMountView = CheckFightMountView or BaseClass(BaseRender)

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
end

function CheckFightMountView:__delete()
	self.mount_attr = nil
end

function CheckFightMountView:OnFlush()
 	if self.mount_attr then
 		self.gongji:SetValue(self.mount_attr.gong_ji)
		self.fangyu:SetValue(self.mount_attr.fang_yu)
		self.shengming:SetValue(self.mount_attr.max_hp)
		self.mingzhong:SetValue(self.mount_attr.ming_zhong)
		self.shanbi:SetValue(self.mount_attr.shan_bi)
		self.baoji:SetValue(self.mount_attr.bao_ji)
		self.kangbao:SetValue(self.mount_attr.jian_ren)
		-- self.zengshang:SetValue(self.mount_attr.per_pofang)
		-- self.mianshang:SetValue(self.mount_attr.per_mianshang)
		self.step:SetValue(CheckData.Instance:GetGradeName(self.mount_attr.client_grade))
		self.zhan_li:SetValue(self.mount_attr.capability)
		local grade = self.mount_attr.client_grade + 1
		if self.mount_attr.used_imageid == 0 then
			self.show_name:SetValue(false)
			-- self.name_text:SetValue("零阶")
		else
			local image_name = ""
			local cfg = FightMountData.Instance:GetMountImageCfg(image_id)
			if cfg ~= nil then
				image_name = cfg.image_name
			end
			self.show_name:SetValue(true)
			local image_id = FightMountData.Instance:GetMountGradeCfg(grade).image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_name.."</color>"
			self.name_text:SetValue(name_str)
		end

		if self.mount_attr.client_grade == 0 then
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
		self.mount_attr = check_attr.fight_attr
		self:Flush()
	end
end

function CheckFightMountView:SetModle()
	if self.mount_attr.client_grade + 1 ~= 0 then
		if self.mount_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = FightMountData.Instance:GetSpecialImagesCfg()[self.mount_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			local res_id = 0
			if self.mount_attr.used_imageid == 0 then
				res_id = 0
			else
				local fight_mount_cfg = FightMountData.Instance:GetMountImageCfg(self.mount_attr.used_imageid)
				if fight_mount_cfg ~= nil then
					res_id = fight_mount_cfg.res_id
				end
			end
		end
		local mount_res_id = res_id
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], mount_res_id, DISPLAY_PANEL.RANK)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
			model:SetTrigger("rest")
		end
		UIScene:SetModelLoadCallBack(call_back)
		bundle, asset = ResPath.GetFightMountModel(mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end
end