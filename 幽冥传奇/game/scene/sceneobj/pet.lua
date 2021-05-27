Pet = Pet or BaseClass(Monster)

function Pet:__init()
	self.obj_type = SceneObjType.Pet
end	


function Pet:__delete()
end	

function Pet:LoadInfoFromVo()
	Monster.LoadInfoFromVo(self)
	self:SetIsNotMaskModel(not Scene.Instance:IsPingbiPet())
	self:SetScale(Scene.Instance.is_little_pet and 0.66 or 1.2,false)
end	


function Pet:CanClick()
	local ower_id = Scene.Instance:GetMainRole():GetObjId()
    return self.vo.owner_obj_id ~= ower_id and Monster.CanClick(self)
end

function Pet:GetMoveActionFilterSpeed(speed)
	return speed * 2
end	

function Pet:Say()
end	