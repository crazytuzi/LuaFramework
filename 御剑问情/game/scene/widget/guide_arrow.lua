GuideArrow = GuideArrow or BaseClass()

function GuideArrow:__init()
	if GuideArrow.Instance then
		print_error("[GuideArrow] Attempt to create singleton twice!")
		return
	end

	self.move_arrow_obj = nil
	self.arrow_to_pos = nil

	local asset_bundle, name = ResPath.GetEffect("Effect_jiantou")
	self.effect = AsyncLoader.New(GameObject.Find("GameRoot/SceneObjLayer").transform)
	self.effect:Load(asset_bundle, name, function (obj)
		self.move_arrow_obj = obj
	end)

	self.effect:SetActive(true)

	Runner.Instance:AddRunObj(self, 8)
end

function GuideArrow:__delete()
	Runner.Instance:RemoveRunObj(self)

	if nil ~= self.effect then
		self.effect:Destroy()
		self.effect:DeleteMe()
	end
end

function GuideArrow:Update(now_time, elapse_time)
	if nil == self.move_arrow_obj or nil == self.arrow_to_pos then
		return
	end
	
	local main_role = Scene.Instance:GetMainRole()
	local now_position = main_role:GetRoot().transform.position
	self.move_arrow_obj.transform.position = now_position
	self.move_arrow_obj.transform:LookAt(Vector3(self.arrow_to_pos.x, now_position.y, self.arrow_to_pos.y))
end

function GuideArrow:SetMoveArrowTo(x, y)
	self.arrow_to_pos = {x = x, y = y}
end