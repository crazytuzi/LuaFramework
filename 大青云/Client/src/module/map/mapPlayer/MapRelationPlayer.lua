--[[
relation player
]]

_G.MapRelationPlayer = {}

MapRelationPlayer.relations = {}

function MapRelationPlayer:new()
	return setmetatable( {}, { __index = self } )
end

function MapRelationPlayer:Init( id, name, level, x, y )
	self.id    = id
	self.name  = name
	self.level = level
	self.x     = x
	self.y     = y
	self:ClearRelation()
end

function MapRelationPlayer:GetClass()
	return MapRelationPlayer
end

function MapRelationPlayer:GetId()
	return self.id
end

function MapRelationPlayer:GetName()
	return self.name
end

function MapRelationPlayer:GetLevel()
	return self.level
end

function MapRelationPlayer:SetLevel( value )
	self.level = value
end

function MapRelationPlayer:GetPos()
	return { x = self.x, y = self.y }
end

function MapRelationPlayer:Move( x, y )
	self.x = x
	self.y = y
end

function MapRelationPlayer:AddRelation( relationType, relationParam )
	for _, oRelation in pairs( self.relations ) do
		if oRelation:GetType() == relationType then
			oRelation:Init( relationType, relationParam )
			return false
		end
	end
	local relation = MapObjectPool:GetObject( MapRelation )
	relation:Init( relationType, relationParam )
	table.push( self.relations, relation )
	return true
end

-- ... relationType
function MapRelationPlayer:RemoveRelationByType( ... )
	local relationMap = {}
	for _, relationType in pairs( {...} ) do
		relationMap[relationType] = true
	end
	for i = #self.relations, 1, -1 do
		local relation = self.relations[i]
		local rType = relation:GetType()
		if relationMap[rType] then
			table.remove( self.relations, i )
			MapObjectPool:ReturnObject( relation )
		end
	end
end

function MapRelationPlayer:ClearRelation()
	for _, relation in pairs( self.relations ) do
		MapObjectPool:ReturnObject( relation )
	end
	self.relations = {}
end

function MapRelationPlayer:HasRelation()
	return #self.relations > 0
end

function MapRelationPlayer:GetRelation()
	table.sort( self.relations, function(A, B) return A:GetPriority() > B:GetPriority() end )
	return self.relations[1]
end

function MapRelationPlayer:Dispose()
	self:ClearRelation()
end
