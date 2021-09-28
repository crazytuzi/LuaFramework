Door = Door or BaseClass(SceneObj)

function Door:__init(vo)
	self.obj_type = SceneObjType.Door
end

function Door:__delete()
	if nil ~= self.model_effect then
		self.model_effect:DeleteMe()
		self.model_effect = nil
	end
end

function Door:InitShow()
	SceneObj.InitShow(self)

	local root = self.draw_obj:GetRoot()
	local trans = root.transform
	if self.vo.offset ~= nil then
		local offset = self.vo.offset
		self.draw_obj:SetOffset(Vector3(offset[1], offset[2], offset[3]))
	end

	if self.vo.rotation ~= nil then
		local rotation = self.vo.rotation
		trans.localEulerAngles = Vector3(rotation[1], rotation[2], rotation[3])
	end

	local bundle_name, prefab_name = ResPath.GetMiscEffect("portal_01")
	if Scene.Instance:GetSceneId() == 102 and self.vo.door_id == 103 then
		bundle_name, prefab_name = ResPath.GetMiscEffect("fazhen_02")
		self.draw_obj:Rotate(0, 81.53, 0)
		local transform = self.draw_obj:GetRoot().transform
		transform:SetLocalScale(0.6, 0.6, 0.6)
		transform:SetLocalPosition(transform.localPosition.x, 20, transform.localPosition.z)
	end
	self:ChangeModel(SceneObjPart.Main, bundle_name, prefab_name)
end

function Door:OnEnterScene()
	--SceneObj.OnEnterScene(self)
	if self.vo.target_name then
		local ui = self:GetFollowUi()
		ui:SetName(self.vo.target_name)
	end
end

function Door:GetObjKey()
	return self.vo.door_id
end

function Door:GetDoorId()
	return self.vo.door_id
end

function Door:GetDoorType()
	return self.vo.type
end
