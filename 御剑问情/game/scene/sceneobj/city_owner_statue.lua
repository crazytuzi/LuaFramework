CityOwnerStatue = CityOwnerStatue or BaseClass(SceneObj)

function CityOwnerStatue:__init(vo)
	self.res_id = 0
	self.obj_type = SceneObjType.CityOwnerStatue
	self.draw_obj:SetObjType(self.obj_type)

	self.city_owner_obj = nil
	self.city_owner_lover_obj = nil
	self.center_obj = nil
	self.ownergameobj = nil
	self.ownerlovergameobj = nil
	self.centergameobj = nil
	self.model_gameobj = nil
end

function CityOwnerStatue:__delete()
	self.city_owner_obj = nil
	self.city_owner_lover_obj = nil
	self.center_obj = nil
	self.ownergameobj = nil
	self.ownerlovergameobj = nil
	self.centergameobj = nil
	self.model_gameobj = nil
	Scene.Instance:DeleteObjsByType(SceneObjType.CityOwnerObj)
end

function CityOwnerStatue:InitInfo()
	SceneObj.InitInfo(self)
end

function CityOwnerStatue:InitShow()
	SceneObj.InitShow(self)
	
	self.res_id = "6088001"	-- 台子资源
	self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.res_id))
end

function CityOwnerStatue:OnClick()
	if SceneObj.select_obj then
		SceneObj.select_obj:CancelSelect()
		SceneObj.select_obj = nil
	end
	self.is_select = true
	SceneObj.select_obj = self
end

function CityOwnerStatue:OnModelLoaded(part, obj)
	if part ~= SceneObjPart.Main and nil ~= obj then
		return
	end

	self.model_gameobj = obj
	self.ownergameobj = obj.transform:FindByName("Owner")
	self.ownerlovergameobj = obj.transform:FindByName("OwnerLover")
	self.centergameobj = obj.transform:FindByName("Center")

	self:RefreshCityOwnerStatue()
end

function CityOwnerStatue:RefreshCityOwnerStatue()
	self:RemoveAllRoleStatueObject()
	self:CreateCityOwnerObj()
	self:CreateCityOwnerLoverObj()
	self:CreateCenterObj()
	self:CreateOwnerName()
end

function CityOwnerStatue:CreateCityOwnerObj()
	local owner_role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	local lover_role_info = CityCombatData.Instance:GetLoverRoleInfo()
	if nil == owner_role_info or nil == self.ownergameobj or nil ~= self.city_owner_obj then	
		return
	end

	local vo = self:GetObjectVoByInfo(owner_role_info)
	self.city_owner_obj = Scene.Instance:CreateObj(vo, SceneObjType.CityOwnerObj)
	if nil ~= self.city_owner_obj then
		local gameobj = (nil ~= lover_role_info) and self.ownergameobj or self.centergameobj
		if nil ~= gameobj then
			self.city_owner_obj.draw_obj:GetRoot().transform:SetParent(gameobj.transform)
			self.city_owner_obj.draw_obj:GetRoot().transform.localPosition = Vector3(0, 0, 0)
		end
	end
end

function CityOwnerStatue:CreateCityOwnerLoverObj()
	local lover_role_info = CityCombatData.Instance:GetLoverRoleInfo()
	if nil == lover_role_info or nil == self.ownerlovergameobj or nil ~= self.city_owner_lover_obj then
		return
	end

	local vo = self:GetObjectVoByInfo(lover_role_info)
	self.city_owner_lover_obj = Scene.Instance:CreateObj(vo, SceneObjType.CityOwnerObj)
	if nil ~= self.city_owner_lover_obj then		self.city_owner_lover_obj.draw_obj:GetRoot().transform:SetParent(self.ownerlovergameobj.transform)
		self.city_owner_lover_obj.draw_obj:GetRoot().transform.localPosition = Vector3(0, 0, 0)
	end
end

function CityOwnerStatue:CreateCenterObj()
	local lover_role_info = CityCombatData.Instance:GetLoverRoleInfo()
	local owner_role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()

	if nil == owner_role_info and nil == lover_role_info and nil ~= self.centergameobj and nil == self.center_obj then
		local vo = self:GetObjectVoByInfo()
		self.center_obj = Scene.Instance:CreateObj(vo, SceneObjType.CityOwnerObj)
		if nil ~= self.center_obj then
			self.center_obj.draw_obj:GetRoot().transform:SetParent(self.centergameobj.transform)
			self.center_obj.draw_obj:GetRoot().transform.localPosition = Vector3(0, 0, 0)
		end
	else
		if nil ~= self.center_obj then
			Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.CityOwnerObj, self.center_obj:GetObjKey())
			self.center_obj = nil
		end
	end
end

function CityOwnerStatue:CreateOwnerName()
	if nil == self.model_gameobj then
		return
	end

	local model = self.model_gameobj.transform:FindByName("3DText")
	if nil == model then
		return
	end

	if nil == UnityEngine.TextMesh then
		return
	end

	local text_mesh = model:GetComponent(typeof(UnityEngine.TextMesh))
	if nil == text_mesh then
		return
	end

	local owner_role_info = CityCombatData.Instance:GetCityOwnerRoleInfo()
	local str = owner_role_info and owner_role_info.role_name or Language.Common.XuWeiYiDai
	text_mesh.text = str
end

function CityOwnerStatue:GetObjectVoByInfo(info)
	local info = info or {}

	local vo = GameVoManager.Instance:CreateVo(CityOwnerObjVo)
	vo.obj_id = COMMON_CONSTS.INVALID_OBJID
	vo.name = info.role_name or ""
	vo.sex = info.sex or GameEnum.MALE
	vo.prof = info.prof or GameEnum.ROLE_PROF_1
	if nil ~= info.shizhuang_part_list then
		vo.appearance = {}
		local appearance_t = PlayerData.Instance:GetRoleVo().appearance
		for k, v in pairs(appearance_t) do
			vo.appearance[k] = 0
		end

		local weapon_use_index = info.shizhuang_part_list[1] and info.shizhuang_part_list[1].use_index or 0
		vo.appearance.fashion_wuqi = weapon_use_index
		local body_use_index = info.shizhuang_part_list[2] and info.shizhuang_part_list[2].use_index or 0
		vo.appearance.fashion_body = body_use_index
		vo.appearance.wing_used_imageid = info.wing_info and info.wing_info.used_imageid or 0
		local fashion = CityCombatData.Instance:GetCityCombatFashion()
		vo.appearance.fashion_body = fashion
	end
	
	return vo
end

function CityOwnerStatue:RemoveAllRoleStatueObject()
	self.city_owner_obj = nil
	self.city_owner_lover_obj = nil	
	self.center_obj = nil
	Scene.Instance:DeleteObjsByType(SceneObjType.CityOwnerObj)
end