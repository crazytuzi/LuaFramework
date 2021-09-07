JumpPoint = JumpPoint or BaseClass(SceneObj)

function JumpPoint:__init(vo)
	self.obj_type = SceneObjType.JumpPoint
	self.draw_obj:SetObjType(self.obj_type)
end

function JumpPoint:InitShow()
	SceneObj.InitShow(self)
	if self.vo.target_id ~= 0 and self.vo.is_show == 1 then
		local bundle_name, prefab_name = ResPath.GetEffect("tiaoyuedian")
		self:ChangeModel(SceneObjPart.Main, bundle_name, prefab_name)
	else
		self:ChangeModel(SceneObjPart.Main, nil, nil)
	end
end

function JumpPoint:__delete()
end

function JumpPoint:GetObjKey()
	return self.vo.id
end

function JumpPoint:IsJumpPoint()
	return true
end