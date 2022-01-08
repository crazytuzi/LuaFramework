local tMEAramture = {}
-- tMEAramture.__index = tMEAramture
-- setmetatable(tMEAramture, EditLua)
function tMEAramture:getArmatureName(szPath)
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

	local szNames = ""
	local firstName = ""
	local ccarr --= me.ArmatureDataManager:getAnimationNames(szPath[":-6"] .. 'xml')
	if string.find(szPath, ".plist") then
		print("plist craete")
		ccarr = me.ArmatureDataManager:getAnimationNames(szPath[":-6"] .. 'xml')
	else
		print("xml craete")
		ccarr = me.ArmatureDataManager:getAnimationNames(szPath)
	end
	if ccarr then
		local nLen = ccarr:count()
		for i = 0, nLen - 1 do
			local name = ccarr:objectAtIndex(i):getCString()
			szNames = szNames .. name .. ";"
			if i == 0 then
				firstName = name
			end
		end
	else
		print("=================================== armature is error file or file is not exit")
	end
	szNames = szNames["1:-1"]
	return szNames, firstName
end

function EditLua:createArmature(szId, tParams)
	if targets[szId] ~= nil then
		return
	end

	local szNames, szArmatureName = tMEAramture:getArmatureName("test/armature/10001.xml")
	if not szArmatureName then return end

	local armature = TFArmature:create(szArmatureName)

	targets[szId] = armature

	EditLua:addToParent(szId, tParams)

	-- 某一个的动作列表
	szGlobleResult = "armatureNames =" .. szNames
	szGlobleResult = szGlobleResult .. ",nX = " .. armature:getPosition().x
	szGlobleResult = szGlobleResult .. ",nY = " .. armature:getPosition().y
	szGlobleResult = szGlobleResult .. ",nWidth = " .. armature:getSize().width
	szGlobleResult = szGlobleResult .. ",nHeight = " .. armature:getSize().height
	szGlobleResult = szGlobleResult .. ",MovementNames=" .. armature:getMovementNameStrings()
	setGlobleString(szGlobleResult)

	targets[szId].bIsReturnStringSetted = true

	print("create success")
end

function tMEAramture:setAnimationScale(szId, tParams)
	print("setAnimationScale", tParams.nScale)
	if targets[szId] == nil then
		return
	end
	tParams.nScale = tParams.nScale or 1
	targets[szId]:setAnimationScale(tParams.nScale)
	targets[szId].nAnimationScale = tParams.nScale
	print("setAnimationScale success")
end

function tMEAramture:playerArmatureByName(szId, tParams)
	print("play", tParams.szName)
	if targets[szId] == nil then
		return
	end
	tParams.nTween = tParams.nTween or -1
	tParams.nDuration = tParams.nDuration or -1
	tParams.nLoop = tParams.nLoop or -1
	TFFunction.call(targets[szId].play, targets[szId], tParams.szName, tParams.nDuration, tParams.nTween, tParams.nLoop)
	print("play success")
end

function tMEAramture:setArmaturePath(szId, tParams)
	print("setArmaturePath")
	if targets[szId] == nil then
		return
	end
	if tParams.szPath == "" then
		tParams.szPath = "test/armature/10001.xml"
	end
	local szNames, szArmatureName = tMEAramture:getArmatureName(tParams.szPath)
	if not szArmatureName then return end
	targets[szId]:setArmature(szArmatureName)


	szGlobleResult = "armatureNames =" .. szNames
	szGlobleResult = szGlobleResult .. ",nX = " .. targets[szId]:getPosition().x
	szGlobleResult = szGlobleResult .. ",nY = " .. targets[szId]:getPosition().y
	szGlobleResult = szGlobleResult .. ",nWidth = " .. targets[szId]:getSize().width
	szGlobleResult = szGlobleResult .. ",nHeight = " .. targets[szId]:getSize().height
	szGlobleResult = szGlobleResult .. ",MovementNames=" .. targets[szId]:getMovementNameStrings()
	setGlobleString(szGlobleResult)

	print("setArmaturePath success", szGlobleResult)
end

function tMEAramture:setArmatureName(szId, tParams)
	print("setArmatureName")
	tParams.szName = tParams.szName or "default"
	targets[szId]:setArmature(tParams.szName)
	szGlobleResult = "MovementNames=" .. targets[szId]:getMovementNameStrings()
	setGlobleString(szGlobleResult)
	print("setArmatureName success")
end

return tMEAramture