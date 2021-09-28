JumpPoint = JumpPoint or BaseClass(SceneObj)

function JumpPoint:__init(vo)
	self.obj_type = SceneObjType.JumpPoint
	self.draw_obj:SetObjType(self.obj_type)
end

function JumpPoint:__delete()
	self.vo.target_vo = nil
	self.target_vo = nil
end

function JumpPoint:OnEnterScene()
	self:UpdateJumppointRotate()
end

function JumpPoint:InitShow()
	SceneObj.InitShow(self)
	local root = self.draw_obj:GetRoot()
	local trans = root.transform
	if self.vo.offset ~= nil then
		local offset = self.vo.offset
		self.draw_obj:SetOffset(Vector3(offset[1], offset[2], offset[3]))
	end
	if self.vo.target_id ~= 0 and self.vo.is_show == 1 then
		local bundle_name, prefab_name = ResPath.GetMiscEffect("tiaoyuedian")
		self:ChangeModel(SceneObjPart.Main, bundle_name, prefab_name)
	else
		self:ChangeModel(SceneObjPart.Main, nil, nil)
	end
end

function JumpPoint:GetObjKey()
	return self.vo.id
end

function JumpPoint:IsJumpPoint()
	return true
end

function JumpPoint:UpdateJumppointRotate()
	if self.vo.target_id and self.vo.target_id > 0 then
		local target_point = Scene.Instance:GetObjByTypeAndKey(SceneObjType.JumpPoint, self.vo.target_id)
		if target_point then
			self:LookAt(target_point:GetRoot())
		end
	end

	local jump_point_list = Scene.Instance:GetObjListByType(SceneObjType.JumpPoint)
	if jump_point_list then
		for k,v in pairs(jump_point_list) do
			if self.vo.id ~= v.vo.id and v.vo.target_id == self.vo.id then
				v:LookAt(self.draw_obj.root)
			end
		end
	end
end

function JumpPoint:LookAt(target)
	if target and not IsNil(target.gameObject) then
		self.draw_obj.root.transform:LookAt(target.transform)
	end
end