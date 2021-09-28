DB = {}
local strDbPath = "src/config/"
function DB.get( sDBName, sKeyName, nValue )
	-- body
	sDBName = strDbPath..sDBName
	if not DB[sDBName] then
		DB[sDBName] = require(sDBName)
	end
	local t = DB[sDBName]
	for k,v in pairs(t) do
		if v[sKeyName] == nValue then
			return v
		end
	end
end

function DB.getDB( sDBName )
	-- body
	sDBName = strDbPath..sDBName
	if not DB[sDBName] then
		DB[sDBName] = require(sDBName)
	end
	return DB[sDBName]
end