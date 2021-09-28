CheckShenyiView = CheckShenyiView or BaseClass(BaseRender)
function CheckShenyiView:__init(instance)
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
	self.name_text = self:FindVariable("name_text")
	self.show_name = self:FindVariable("show_name")
	self.name = self:FindVariable("name")
	self.show_grade = self:FindVariable("show_grade")
	self.quality = self:FindVariable("QualityBG")

	self.display = self:FindObj("display")
	self.model = RoleModel.New("player_check_shenyi_panel")
	self.model:SetDisplay(self.display.ui3d_display)
end

function CheckShenyiView:__delete()
	self.attr = nil

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self:CancelTheQuest()
	self:CancelTheQuestTwo()
end

function CheckShenyiView:OnFlush()
	if self.attr then
		self.gongji:SetValue(self.attr.shenyi_attr.gong_ji)
		self.fangyu:SetValue(self.attr.shenyi_attr.fang_yu)
		self.shengming:SetValue(self.attr.shenyi_attr.max_hp)
		self.mingzhong:SetValue(self.attr.shenyi_attr.ming_zhong)
		self.shanbi:SetValue(self.attr.shenyi_attr.shan_bi)
		self.baoji:SetValue(self.attr.shenyi_attr.bao_ji)
		self.kangbao:SetValue(self.attr.shenyi_attr.jian_ren)
		self.zengshang:SetValue(self.attr.shenyi_attr.per_pofang)
		self.mianshang:SetValue(self.attr.shenyi_attr.per_mianshang)
		self.grade:SetValue(CheckData.Instance:GetGradeName(self.attr.shenyi_attr.client_grade))
		self.zhan_li:SetValue(self.attr.shenyi_attr.capability)
		local grade = self.attr.shenyi_attr.client_grade + 1

		local name_str = ""
		if self.attr.shenyi_attr.used_imageid <= 0 then
			self.show_name:SetValue(false)
			self.show_grade:SetValue(false)
		elseif self.attr.shenyi_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			--说明使用的是特殊形象
			local cfg_info = ShenyiData.Instance:GetSpecialImagesCfg()[self.attr.shenyi_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID]
			if nil ~= cfg_info then
				local item_cfg = ItemData.Instance:GetItemConfig(cfg_info.item_id)
				if nil ~= item_cfg then
					local color = ITEM_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
					name_str = ToColorStr(cfg_info.image_name, color)
				end
			end

		else
			self.show_name:SetValue(true)
			local image_id = ShenyiData.Instance:GetShenyiGradeCfg(grade).image_id
			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetShenyiImageCfg()[image_id].image_name.."</color>"
		end
		self.name_text:SetValue(name_str)

		if self.attr.shenyi_attr.used_imageid > 0 then
			self.show_grade:SetValue(true)
			local bundle, asset = nil, nil
			if math.floor(grade / 3 + 1) >= 5 then
				 bundle, asset = ResPath.GetShengongGradeQualityBG(5)
			else
				 bundle, asset = ResPath.GetShengongGradeQualityBG(math.floor(grade / 3 + 1))
			end
			self.quality:SetAsset(bundle, asset)
		end

		self:SetModle()
	end
end

function CheckShenyiView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.attr = check_attr
		self:Flush()
	end
end

function CheckShenyiView:SetModle()
	UIScene:SetActionEnable(false)
	if self.attr.shenyi_attr.client_grade + 1 ~= 0 then
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

		if self.attr.shenyi_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShenyiData.Instance:GetSpecialImagesCfg()[self.attr.shenyi_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShenyiData.Instance:GetShenyiImageCfg()[self.attr.shenyi_attr.used_imageid].res_id
		end
		info.wing_res_id = res_id

		-- local call_back = function(model, obj)
		-- 	local cfg = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").shenyi_model[001001][DISPLAY_PANEL.RANK]
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
		-- local bundle2, asset2 = ResPath.GetGoddessWingModel(info.wing_res_id)

		-- local bundle_list = {[SceneObjPart.Main] = bundle1, [SceneObjPart.Wing] = bundle2}
		-- local asset_list = {[SceneObjPart.Main] = asset1, [SceneObjPart.Wing] = asset2}
		-- UIScene:ModelBundle(bundle_list, asset_list)

		-- if self.time_quest ~= nil then
		-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
		-- end

		self.model:SetGoddessModelResInfo(info)
		-- local bundle, asset = ResPath.GetGoddessModel(info.role_res_id)
		-- self.model:SetMainAsset(bundle, asset)
		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], asset, DISPLAY_PANEL.RANK)

		self:CalToShowAnim(true)
	else
		UIScene:IsNotCreateRoleModel(false)
	end
end

function CheckShenyiView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end
function CheckShenyiView:CalToShowAnim(is_change_tab)
	self:CancelTheQuest()
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if timer <= 6 then
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)

end

function CheckShenyiView:CancelTheQuestTwo()
	if self.time_quest_2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
	end
end

function CheckShenyiView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	self:CancelTheQuestTwo()
	local timer = GameEnum.GODDESS_ANIM_SHORT_TIME
	local count = 1
	self.time_quest_2 = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if UIScene.role_model then
				local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
					count = count + 1
				end
				timer = GameEnum.GODDESS_ANIM_SHORT_TIME
				is_change_tab = false
				if count == 5 then
					count = 1
					GlobalTimerQuest:CancelQuest(self.time_quest_2)
					self.time_quest_2 = nil
					self:CalToShowAnim()
				end
			end
		end
	end, 0)
end