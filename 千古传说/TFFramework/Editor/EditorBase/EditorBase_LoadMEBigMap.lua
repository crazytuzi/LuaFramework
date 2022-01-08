local tMEBigMap = {}
-- tMEBigMap.__index = tMEBigMap
-- setmetatable(tMEBigMap, require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel'))

function EditLua:createBigMap(szId, tParams)
	print("createBigMap")
	if targets[szId] ~= nil then
		return
	end
	local pBigMap = EditBigMap:create()
	pBigMap:setPosition(ccp(0, 0))
	pBigMap:setSize(CCSizeMake(100, 100))
	pBigMap:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
	pBigMap:setBackGroundColor(ccc3(100, 100, 100))
	pBigMap:setTouchEnabled(true)
	
	-- tTouchEventManager:registerEvents(pBigMap)
	targets[szId] = pBigMap
	
	EditLua:addToParent(szId, tParams)

	targets[szId].bIsBigMap = true
	print("create success")
end

function tMEBigMap:setBigMapTexture(szId, tParams)
	print("setBigMapTexture", tParams)
	if tParams.szPrefix and tParams.szSuffix and tParams.nColumn and tParams.nRow and targets[szId] ~= nil and targets[szId].setBigMapTexture then

		targets[szId]:setBigMapTexture(tParams.szPrefix, tParams.szSuffix, tParams.nColumn, tParams.nRow)

		print("setBigMapTexture run success")
	end
end

return tMEBigMap