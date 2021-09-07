BoatObj = BoatObj or BaseClass(SceneObj)

-- 温泉皮艇
function BoatObj:__init(boat_vo)
	self.obj_type = SceneObjType.BoatObj
	self:SetObjId(boat_vo.obj_id)
	self.vo = boat_vo

	self.res_id = 7201001

	self.mount_point_r = nil
	self.mount_point_l = nil
end

function BoatObj:__delete()
	local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
	local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)

	if nil ~= boy_obj and nil ~= boy_obj:GetRoot() and not IsNil(boy_obj:GetRoot().gameObject) then
		local boy_main_part_obj = boy_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if nil ~= boy_main_part_obj then
			boy_main_part_obj.transform:SetParent(boy_obj.draw_obj.root.transform)
			self:ResetTransform(boy_main_part_obj.transform)
		end

		local boy_main_part = boy_obj.draw_obj:GetPart(SceneObjPart.Main)
		if boy_obj:IsWaterWay() then
			boy_main_part:SetInteger("status", 4)
			local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
			boy_main_part:SetOffsetY(offset)
		else
			boy_main_part:SetInteger("status", 0)
			boy_main_part:ReSetOffsetY()
		end
	end

	if nil ~= girl_obj and nil ~= girl_obj:GetRoot() and not IsNil(girl_obj:GetRoot().gameObject) then
		local girl_main_part_obj = girl_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
		if nil ~= girl_main_part_obj then
			girl_main_part_obj.transform:SetParent(girl_obj.draw_obj.root.transform)
			self:ResetTransform(girl_main_part_obj.transform)
		end

		local girl_main_part = girl_obj.draw_obj:GetPart(SceneObjPart.Main)
		if girl_obj:IsWaterWay() then
			girl_main_part:SetInteger("status", 4)
			local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
			girl_main_part:SetOffsetY(offset)
		else
			girl_main_part:SetInteger("status", 0)
			girl_main_part:ReSetOffsetY()
		end
	end
	self.mount_point_r = nil
	self.mount_point_l = nil
end

function BoatObj:InitShow()
	Character.InitShow(self)

	self.name = self.vo.name

	if self.res_id ~= nil and self.res_id ~= 0 then
		self:ChangeModel(SceneObjPart.Main, ResPath.GetMountModel(self.res_id))
	end
end

function BoatObj:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		self.mount_point_l = obj.transform:Find("mount_point")
		self.mount_point_r = obj.transform:Find("mount_point01")

		local boy_obj = Scene.Instance:GetObjectByObjId(self.vo.boy_obj_id)
		local girl_obj = Scene.Instance:GetObjectByObjId(self.vo.girl_obj_id)

		if nil ~= boy_obj and nil ~= boy_obj:GetRoot() and not IsNil(boy_obj:GetRoot().gameObject) then
			local obj = boy_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if nil ~= obj then
				obj.gameObject.transform:SetParent(self.mount_point_r)
				self:ResetTransform(obj.gameObject.transform)
				local boy_main_part = boy_obj.draw_obj:GetPart(SceneObjPart.Main)
				if boy_main_part then
					boy_main_part:SetInteger("status", 2)
				end
			end
		end

		if nil ~= girl_obj and nil ~= girl_obj:GetRoot() and not IsNil(girl_obj:GetRoot().gameObject) then
			local obj = girl_obj.draw_obj:_TryGetPartObj(SceneObjPart.Main)
			if nil ~= obj then
				obj.gameObject.transform:SetParent(self.mount_point_l)
				self:ResetTransform(obj.gameObject.transform)
				local girl_main_part = girl_obj.draw_obj:GetPart(SceneObjPart.Main)
				if nil ~= girl_main_part then
					girl_main_part:SetInteger("status", 2)
				end
			end
		end

		local piting_part = self.draw_obj:GetPart(SceneObjPart.Main)
		if boy_obj:IsWaterWay() then
			piting_part:SetInteger("Status", 1)
			local offset = Scene.Instance:GetSceneLogic():GetWaterWayOffset() or 0
			piting_part:SetOffsetY(offset)
		else
			piting_part:SetInteger("Status", 0)
			piting_part:ReSetOffsetY()
		end
	end
end

function BoatObj:ResetTransform(transform)
	transform:SetLocalPosition(0,0,0)
	transform.rotation = Vector3(0,0,0)
	transform:SetLocalScale(1,1,1)
end

function BoatObj:GetBoatAttachPoint(obj_id)
	if obj_id == self.vo.boy_obj_id then
		return self.mount_point_r
	else
		return self.mount_point_l
	end
end

function BoatObj:IsCharacter()
	return false
end

function BoatObj:IsBoat()
	return true
end