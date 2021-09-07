
Baby = Baby or BaseClass(SceneObj)

-- 宝宝
function Baby:__init(vo)
	self.obj_type = SceneObjType.Baby
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(vo.baby_res_id)
	self.vo = vo
	self.baby_res_id = self.vo.baby_res_id or -1
end

function Baby:__delete()
	self.obj_type = nil
end

function Baby:InitShow()
	SceneObj.InitShow(self)

	local obj = self.parent_scene:GetObjectByObjId(self.vo.owner_obj_id)
	if nil ~= obj and obj:IsRole() and obj:GetRoleId() == self.vo.owner_role_id then
		local target_x, target_y = math.random(-5,5), math.random(-5,5)
		local obj_x, obj_y = obj:GetLogicPos()
		target_x = obj_x + target_x
		target_y = obj_y + target_y
		if not AStarFindWay:IsBlock(target_x, target_y) then
			self:SetLogicPos(target_x, target_y)
		end
	else
		self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)
	end

	self:UpdateModelResId()
end

function Baby:UpdateModelResId()
	if self.baby_res_id ~= nil and self.baby_res_id ~= -1 then
		local bundle, asset = ResPath.GetBabyModel(BaobaoData.Instance:GetBabyResId(self.baby_res_id))
		self:ChangeModel(SceneObjPart.Main, bundle, asset)
	end
end

function Baby:SetAttr(key, value)
	Character.SetAttr(self, key, value)
	if key == "set_baby_id" then
		self.baby_res_id = value
		self:UpdateModelResId()
	end
end

function Baby:SetBabyVisible(is_visible)
	self.is_visible = is_visible
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)
	end
end