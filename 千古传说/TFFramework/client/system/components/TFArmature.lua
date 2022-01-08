--[[--
	按钮控件:

	--By: yun.bo
	--2013/7/12
]]

local _bcreate = TFArmature.create
function TFArmature:create(armaturePath)
	local obj = _bcreate(TFArmature, armaturePath)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

-----------------------------------Editor
local function createByPlist(armaturePath)
	local name = TFArmature:getArmatureName(armaturePath)
	local obj = _bcreate(TFArmature, name)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj
	if val.armatureModel and val.armatureModel.armaturePath ~= "" then
		obj = createByPlist(val.armatureModel.armaturePath)
	elseif val.tArmatureProperty and val.tArmatureProperty.szArmaturePath and val.tArmatureProperty.szArmaturePath ~= "" then
		obj = createByPlist(val.tArmatureProperty.szArmaturePath)
	else
		obj = TFArmature:create()
	end
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	
	if obj then
		obj:initMEArmature(val, parent)
	end
	return true, obj
end
rawset(TFArmature, "initControl", initControl)

function TFArmature:getArmatureName(szPath)
	print("begin getArmatureName", szPath)
	-- armture	
	TFResourceHelper:instance():addArmatureFromJsonFile(szPath)
	local nIdx = #szPath
	while nIdx > 0 do
		if szPath[nIdx] == '.' then
			break
		end
		nIdx = nIdx - 1
	end 

	local szPre = szPath[{1, nIdx - 1}]
	nIdx = #szPre
	while nIdx > 0 do
		if szPre[nIdx] == '/' or szPre[nIdx] == '\\' then
			szPre = szPre[{nIdx+1}]
			break
		end
		nIdx = nIdx - 1
	end
	print("prefix", szPre)

	-- local animDict = me.ArmatureDataManager:getAllAnimationNames()
	local ccarr = me.ArmatureDataManager:getAllAnimationNames()
	local nLen = ccarr:count()
	for i = 0, nLen - 1 do
		local szName = ccarr:objectAtIndex(i):getCString()
		if string.find(szName, szPre) then
			return szName
		end
	end
end


return TFArmature