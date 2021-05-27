--图腾怪实体
Totem = Totem or BaseClass(Monster)

function Totem:__init()
	self.obj_type = SceneObjType.Totem
end

function Totem:__delete()
	
end


function Totem:GetResDirNumAndFlipFlag()
	if self:IsDead() then
		return GameMath.DirUp, false
	end
	return GameMath.DirDown,false
end	