--[[
relation
]]

_G.MapRelation = {}

function MapRelation:new()
	return setmetatable( {}, { __index = self } )
end

function MapRelation:Init( relationType, param )
	self.relationType = relationType
	self.param        = param
end

function MapRelation:Imitate(relation)
	self.relationType = relation:GetType()
	self.param        = relation:GetParam()
end

function MapRelation:GetClass()
	return MapRelation
end

function MapRelation:GetType()
	return self.relationType
end

function MapRelation:GetParam()
	return self.param
end

function MapRelation:GetPriority()
	return MapRelationConsts.Priority[ self.relationType ]
end