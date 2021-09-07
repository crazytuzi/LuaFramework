CheckDisplayView = CheckDisplayView or BaseClass(BaseRender)

function CheckDisplayView:__init(instance)
	self.timer = FIX_SHOW_TIME
end

function CheckDisplayView:__delete()
	if self.ming_model ~= nil then
		self.ming_model:DeleteMe()
		self.ming_model = nil
	end

	if self.beauty_model ~= nil then
		self.beauty_model:DeleteMe()
		self.beauty_model = nil
	end

	if self.role_model ~= nil then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	for i = 1, 2 do
		if self["foot_model_" .. i] ~= nil then
			self["foot_model_" .. i]:DeleteMe()
			self["foot_model_" .. i] = nil
		end

		self["display_foot_" .. i] = nil
	end

	self.attr_list = nil
	self.display_ming = nil
	self.display_beauty = nil
	self.display_role = nil
	self.show_foot_1 = nil
	self.show_foot_2 = nil
	self.show_foot_3 = nil
	self.show_title = nil
	self.title_res = nil
	self.no_mount_role = nil
	self.no_mount_title = nil
	self.title_obj = nil
end

function CheckDisplayView:LoadCallBack()
	self.attr_list = {}
	for i = 1, GameEnum.CHECK_DIS_ATTR_TYPE_NUM do
		local attr = self:FindVariable("AttrValue" .. i)
		if attr ~= nil then
			table.insert(self.attr_list, attr)
		end
	end

	self.display_ming = self:FindObj("DisplayMing")
	self.display_beauty = self:FindObj("DisplayBeauty")
	self.display_role = self:FindObj("DisplayRole")

	self.display_foot_1 = self:FindObj("DisplayFoot1")
	self.display_foot_2 = self:FindObj("DisplayFoot2")

	self.show_ming = self:FindVariable("ShowMing")
	self.show_beauty = self:FindVariable("ShowBeauty")
	self.show_role = self:FindVariable("ShowRole")
	self.show_foot_1 = self:FindVariable("ShowFoot1")
	self.show_foot_2 = self:FindVariable("ShowFoot2")

	self.show_title = self:FindVariable("ShowTitle")
	self.title_res = self:FindVariable("TitleRes")

	self.no_mount_role = self:FindObj("NoMountRole")
	self.no_mount_title = self:FindObj("NoMountTitle")
	self.title_obj = self:FindObj("Title")

	self.title_pos = TableCopy(self.title_obj.transform.localPosition)
	self.role_pos = TableCopy(self.display_role.transform.localPosition)
end

function CheckDisplayView:OnFlush()
	self:FlushModel()
	self:FlushAttr()
end

function CheckDisplayView:FlushModel()
	local image_list, _ = CheckData.Instance:GetDisplayInfo()
	local is_show_ming = image_list.ming_image_id ~= nil and image_list.ming_image_id > 0
	if self.show_ming ~= nil then
		self.show_ming:SetValue(is_show_ming)
	end

	if is_show_ming then
		if self.ming_model == nil and self.display_ming ~= nil then
			self.ming_model = RoleModel.New("check_display_view_ming")
			self.ming_model:SetDisplay(self.display_ming.ui3d_display)
		end

		local bundle, asset = ResPath.GetMingJiangRes(image_list.ming_image_id)
		self.ming_model:SetMainAsset(bundle, asset, function()
			--self.ming_model:SetTrigger("rest")
		 end)
	end

	local is_show_beauty = image_list.beauty_image_id ~= nil and image_list.beauty_image_id > 0
	if self.show_beauty ~= nil then
		self.show_beauty:SetValue(is_show_beauty)
	end
	
	if is_show_beauty then
		if self.beauty_model == nil and self.display_beauty ~= nil then
			self.beauty_model = RoleModel.New()
			self.beauty_model:SetDisplay(self.display_beauty.ui3d_display)
		end
		local bundle, asset = ResPath.GetGoddessModel(image_list.beauty_image_id)
		self.beauty_model:SetMainAsset(bundle, asset, function ()
			self.beauty_model:SetHaloResid(image_list.beauty_halo_image_id, true)
			self.beauty_model:SetTrigger(SceneObjAnimator.Atk3)
		end)
		--self.beauty_model:SetGoddessResid(image_list.beauty_image_id)
	end

	if self.role_model == nil and self.display_role ~= nil then
		self.role_model = RoleModel.New("check_display_view_role")
		self.role_model:SetDisplay(self.display_role.ui3d_display)
	end

	--self.role_model:SetRoleResid(image_list.role_image_id)
	local bundle, asset = ResPath.GetRoleModel(image_list.role_image_id or 0)
		self.role_model:SetMainAsset(bundle, asset, function () 
		if image_list.mount_image_id > 0 then
			self.role_model:SetMountResid(image_list.mount_image_id or 0)
		end
		self.role_model:SetWingResid(image_list.wing_image_id or 0)
		self.role_model:SetMantleResid(image_list.mantle_image_id or 0)
		self.role_model:SetFaZhenResid(image_list.fazhen_image_id or 0)
		if image_list.mount_image_id == 7116001 then
			self.role_model:SetFaZhenOffY(1.5)
		end
		-- self.role_model:SetZhiBaoResid(image_list.fabao_image_id or 0)
		self.role_model:SetWeaponResid(image_list.wuqi_image_id or 0)

		if image_list.title_image_id ~= nil then
			if self.show_title ~= nil then
				self.show_title:SetValue(image_list.title_image_id > 0)
				if image_list.title_image_id > 0 and self.title_res ~= nil then
					self.title_res:SetAsset(ResPath.GetTitleIcon(image_list.title_image_id))
					self.title_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
				end
			end
		end
	end)

	-- local rotate = Vector3(0, 0, 0)
	-- local scale = Vector3(0.8, 0.8, 0.8)
	-- if image_list.mount_image_id > 0 then
	-- 	-- rotate = Vector3(0, 60, 0)
	-- 	-- scale = Vector3(0.5, 0.5, 0.5)
	-- 	if self.display_role ~= nil then
	-- 		self.display_role.transform.localPosition = self.role_pos
	-- 	end

	-- 	if self.title_obj ~= nil then
	-- 		self.title_obj.transform.localPosition = self.title_pos
	-- 	end	

	-- 	-- self.role_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_list.mount_image_id, DISPLAY_PANEL.CHECK_DISPLAY_VIE)
	-- else
	-- 	-- self.role_model:SetRotation(rotate)
	-- 	self.role_model:SetModelScale(scale)

	-- 	if self.no_mount_role ~= nil and self.display_role ~= nil then
	-- 		self.display_role.transform.localPosition = self.no_mount_role.transform.localPosition
	-- 	end

	-- 	if self.no_mount_title ~= nil and self.title_obj ~= nil then
	-- 		self.title_obj.transform.localPosition = self.no_mount_title.transform.localPosition
	-- 	end
	-- end

	-- local rotate = Vector3(0, 0, 0)
	-- local scale = Vector3(0.8, 0.8, 0.8)
	-- self.role_model:SetRotation(rotate)
	-- self.role_model:SetModelScale(scale)

	self:FlushFoot(image_list.foot_image_id)
end

function CheckDisplayView:InitFoot()
	if self.foot_model_1 == nil and self.display_foot_1 then
		self.foot_model_1 = RoleModel.New()
		self.foot_model_1:SetDisplay(self.display_foot_1.ui3d_display)
	end

	if self.foot_model_2 == nil and self.display_foot_2 then
		self.foot_model_2 = RoleModel.New()
		self.foot_model_2:SetDisplay(self.display_foot_2.ui3d_display)
	end
end

-- function CheckDisplayView:CalToShowAnim()
-- 	local part = nil
-- 	-- if UIScene.role_model then
-- 	-- 	part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
-- 	-- end
-- 	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
-- 		self.timer = self.timer - UnityEngine.Time.deltaTime
-- 		if self.timer <= 0 then
-- 			if part then
-- 				-- part:SetTrigger("attack1")
-- 			end
-- 			self.timer = FIX_SHOW_TIME
-- 		end
-- 	end, 0)
-- end

function CheckDisplayView:FlushFoot(cur_select_grade)
	-- if self.time_quest ~= nil then
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- end
	if cur_select_grade > 0 then
		self:InitFoot()
	end

	local asset = "Foot_" .. cur_select_grade

	for i = 1, 2 do
		if self["foot_model_" .. i] ~= nil then
			if self["show_foot_" .. i] ~= nil then
				self["show_foot_" .. i]:SetValue(cur_select_grade > 0)
			end

			if cur_select_grade > 0 then
				self["foot_model_" .. i]:SetMainAsset("effects2/prefab/footprint_prefab", asset)
			end
		end

		if self["display_foot_" .. i] ~= nil and cur_select_grade > 0 then
			self["display_foot_" .. i].ui3d_display:ResetRotation()
		end
	end
end

function CheckDisplayView:FlushAttr()
	local _, attr_list = CheckData.Instance:GetDisplayInfo()

	if self.attr_list ~= nil then
		for k,v in pairs(self.attr_list) do
			if v ~= nil and attr_list[k] ~= nil then
				v:SetValue(attr_list[k])
			end
		end
	end
end

function CheckDisplayView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.fight_attr then
		self.mount_attr = check_attr.fight_attr
		self:Flush()
	end
end
