SuperBabyObj = SuperBabyObj or BaseClass(FollowObj)

function SuperBabyObj:__init(vo)
	self.obj_type = SceneObjType.SuperBabyObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(vo.obj_id)
	self.is_visible = true

	self.super_baby_res_id = 0

	self.follow_offset = 1
	self.is_wander = true
	self.mass = 0.5
	self.wander_cd = 5
end

function SuperBabyObj:__delete()
end

function SuperBabyObj:ChangeVisible(is_visible)
	self.is_visible = is_visible

	local draw_obj = self:GetDrawObj()
	if draw_obj then
		draw_obj:SetVisible(is_visible)

		if is_visible then
			self:UpdateResId()
			self:ChangeMainModel()
		end
	end

	self:UpdateFollowUi()
end

function SuperBabyObj:InitShow()
	FollowObj.InitShow(self)

	self:UpdateFollowUi()

	self:UpdateResId()
	self:ChangeMainModel()
end

function SuperBabyObj:UpdateResId()
	self.super_baby_res_id = BaobaoData.Instance:GetSuperBabyResId(self.vo.sup_baby_id)
end

function SuperBabyObj:SetAttr(key, value)
	Character.SetAttr(self, key, value)

	if key == "sup_baby_name" then
		local name = value
		if name == "" then
			local cfg_info = BaobaoData.Instance:GetSuperBabyCfgInfo(self.vo.sup_baby_id)
			if cfg_info then
				name = cfg_info.name
			end
		end

		name = string.format(Language.Marriage.SceneSuperBabyName, self.vo.owner_name, name)
		if self.vo.lover_name ~= "" then
			name = self.vo.lover_name .. "♥" .. name
		end

		self.vo.name = name
		self:ReloadUIName()

	elseif key == "sup_baby_id" then
		self.super_baby_res_id = BaobaoData.Instance:GetSuperBabyResId(value)
		self:ChangeMainModel()
	end
end

function SuperBabyObj:UpdateFollowUi()
	local follow_ui = self:GetFollowUi()
	if follow_ui then
		follow_ui:SetHpVisiable(false)
		if self.is_visible then
			follow_ui:Show()
		else
			follow_ui:Hide()
		end
	end
end

function SuperBabyObj:ChangeMainModel()
	if self.super_baby_res_id <= 0 or not self.is_visible then
		self:RemoveModel(SceneObjPart.Main)
		return
	end

	local bundle, asset = ResPath.GetSpiritModel(self.super_baby_res_id)
	self:ChangeModel(SceneObjPart.Main, bundle, asset)
end

--是否自己的超级宝宝
function SuperBabyObj:IsMainRolSuperBaby()
	return self.vo.owner_is_mainrole
end

--是否超级宝宝
function SuperBabyObj:IsSuperBaby()
	return true
end