Robot = Robot or BaseClass(HumanMonster)

function Robot:__init()
	self.obj_type = SceneObjType.Robot
end

function Robot:__delete()
end	

function Robot:LoadInfoFromVo()
	HumanMonster.LoadInfoFromVo(self)
	self:SetIsNotMaskModel(not Scene.Instance.is_pingbi_other_role)
	self:SetNameLayerShow(true)
	self:SetIsPingbiChibang(Scene.Instance.is_pinbi_wing)
end	

function Robot:CanClick()
    return  not self:IsDead() 
    		and SceneObj.CanClick(self)
end