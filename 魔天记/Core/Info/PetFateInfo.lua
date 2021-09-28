
PetFateInfo = class("PetFateInfo");

function PetFateInfo:ctor(data)
	self:_Init(data)
end

function PetFateInfo:_Init(data)
	self._attr = BaseAdvanceAttrInfo:New()
	self._attr:Init(data)
	self._id = data.id
	self._name = data.name
	self._pet_id = data.pet_id		
    self._desc = data.desc
    self._valid = false
end

function PetFateInfo:GetAttr()
    return self._attr
end
 

function  PetFateInfo:GetName()
   return self._name
end

function  PetFateInfo:GetPetList( )
    return self._pet_id
end

function  PetFateInfo:GetDes(   )
    return self._desc
end


function  PetFateInfo:SetValid( value )
    self._valid = value
end

--情缘是否符合
function  PetFateInfo:GetValid(  )
   return self._valid
end

function  PetFateInfo:GetId( )
    return self._id
end