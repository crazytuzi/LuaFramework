CheckGoddessView = CheckGoddessView or BaseClass(BaseRender)
function CheckGoddessView:__init(instance)
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.xiannv_gongji_text = self:FindVariable("xiannv_gongji_text")
	self.camp_text_list = {}
	for i=1,4 do
		self.camp_text_list[i] = self:FindVariable("camp_text_" .. i)
	end
	self.zhan_li = self:FindVariable("zhan_li")
	self.name = self:FindVariable("name_text")
	self.show_name = self:FindVariable("show_name")
end

function CheckGoddessView:__delete()
	self.all_attr = nil
end

function CheckGoddessView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.all_attr = check_attr
		self:Flush()
	end
end

function CheckGoddessView:OnFlush()
	if self.all_attr then
		local goddess_data = GoddessData.Instance
		self.gongji:SetValue(goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.GONG_JI, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level))
		self.fangyu:SetValue(goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.FANG_YU, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level))
		self.shengming:SetValue(goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.SHENG_MING, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level))
		self.xiannv_gongji_text:SetValue(goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.XIANNV_GONGJI, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level))
		self.zhan_li:SetValue(goddess_data:GetAllPower(self.all_attr.xiannv_attr.pos_list, self.all_attr.present_attr.level, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.xiannv_attr.xiannv_huanhua_level))
		self.show_name:SetValue(true)
		if self.all_attr.xiannv_attr.xiannv_name ~= "" then
			self.name:SetValue(self.all_attr.xiannv_attr.xiannv_name)
		else
			local show_id = self.all_attr.xiannv_attr.pos_list[1]
			if show_id == -1 then
				local active_list = goddess_data:GetXiannvActiveList(self.all_attr.xiannv_attr.xiannv_item_list)
				if #active_list ~= 0 then
					show_id = active_list[1]
					self.name:SetValue(goddess_data:GetXianNvCfg(show_id).name)
				else
					self.show_name:SetValue(false)
				end
			else
				self.name:SetValue(goddess_data:GetXianNvCfg(show_id).name)
			end
		end

		for k,v in pairs(self.all_attr.xiannv_attr.pos_list) do
			if v == -1 then
				local tips_text = "阵位未开启"
				self.camp_text_list[k]:SetValue(tips_text)
			else
				self.camp_text_list[k]:SetValue(math.floor(goddess_data:GetSingleCampPower(k, v, self.all_attr.xiannv_attr.xiannv_item_list)))
			end
		end
		self:SetModle()
	end
end

function CheckGoddessView:SetModle()
	UIScene:SetActionEnable(false)
	local goddess_data = GoddessData.Instance
	local info = {}
	info.role_res_id = -1
	local goddess_data = GoddessData.Instance
	local goddess_huanhua_id = self.all_attr.xiannv_attr.huanhua_id

	if goddess_huanhua_id > 0 then
		info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
	else
		local goddess_id = self.all_attr.xiannv_attr.pos_list[1]
		if goddess_id == -1 then
			goddess_id = 0
		end
		info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
	end

	local call_back = function(model, obj)
		local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], info.role_res_id, DISPLAY_PANEL.RANK)
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
	end

	UIScene:SetModelLoadCallBack(call_back)
	local bundle1, asset1 = ResPath.GetGoddessModel(info.role_res_id)
	-- local bundle2, asset2 = ResPath.GetGoddessWeaponModel(info.weapon_res_id)

	local bundle_list = {[SceneObjPart.Main] = bundle1}
	local asset_list = {[SceneObjPart.Main] = asset1}
	UIScene:ModelBundle(bundle_list, asset_list)
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	self:CalToShowAnim(true)
end

function CheckGoddessView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			self:PlayAnim(is_change_tab)
			is_change_tab = false
			timer = GameEnum.GODDESS_ANIM_LONG_TIME
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end
	end, 0)

end

function CheckGoddessView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
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
				if count == 4 then
					count = 1
					GlobalTimerQuest:CancelQuest(self.time_quest_2)
					self.time_quest_2 = nil
					self:CalToShowAnim()
				end
			end
		end
	end, 0)
end