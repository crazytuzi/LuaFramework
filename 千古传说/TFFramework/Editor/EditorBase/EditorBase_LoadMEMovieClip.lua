local tMEMovieClip = {}
-- tMEMovieClip.__index = tMEMovieClip
-- setmetatable(tMEMovieClip, EditLua)

function EditLua:createMovieClip(szId, tParams)
	print("createMovieClip")
	if targets[szId] ~= nil then
		return
	end
	local path = "test/movieclip/1_0.mp"
	if tParams.szFileName and tParam.szFileName ~= "" then
		path = tParams.szFileName
	end

	local objMovie = TFMovieClip:create(path)
	targets[szId] = objMovie
	targets[szId]._szMCPath = path

	EditLua:addToParent(szId, tParams)

	targets[szId]:play("default", 0, 0, 0, 1)
	-- local size = objMovie:getMovieSize()
	-- objMovie:setSize(size)
	
	szGlobleResult = "movieNames = " .. objMovie:getMovementNameStrings()
	szGlobleResult = szGlobleResult .. ",nX = " .. objMovie:getPosition().x
	szGlobleResult = szGlobleResult .. ",nY = " .. objMovie:getPosition().y
	szGlobleResult = szGlobleResult .. ",nWidth = " .. objMovie:getSize().width
	szGlobleResult = szGlobleResult .. ",nHeight = " .. objMovie:getSize().height
	setGlobleString(szGlobleResult)

	print("create success")
end

function tMEMovieClip:stop(szId, tParams)
	print("tMEMovieClip stop")
	targets[szId]:stop()
	print("tMEMovieClip stop success")
end

function tMEMovieClip:playMovieClipByName(szId, tParams)
	print("play", tParams.szName)
	if targets[szId] == nil then
		return
	end
	tParams.szName 	= tParams.szName or "default"
	tParams.nCount 	= tParams.nCount or -1
	tParams.fDelay 	= tParams.fDelay or 0
	tParams.nStart 		= tParams.nStart or 0
	tParams.nEnd 		= tParams.nEnd or -1
	
	TFFunction.call(targets[szId].play, targets[szId], tParams.szName, tParams.nCount, tParams.fDelay, tParams.nStart, tParams.nEnd)
	print("play success", tParams.szName)
end

function EditLua:setMovieClipPath(szId, tParams)
	if targets[szId] == nil then
		print("target is nil")
		return
	end
	if tParams.szPath == "" then
		tParams.szPath = "test/movieclip/1_0.mp"
	end
	if targets[szId]._szMCPath == tParams.szPath then
		print("is same movie", tParams.szPath)
		return
	end

	print("setMovieClipPath", tParams.szPath, targets[szId]:getPlayMovieName())
	-- local objMovie = targets[szId]:copyWithFile(tParams.szPath)
	-- TFUIBase:extends(objMovie)
	-- objMovie.szParentID = targets[szId].szParentID
	-- objMovie.children = targets[szId].children
	-- for szChildID in targets[szId].children:iterator() do
	-- 	local obj = targets[szChildID]
	-- 	if obj then
	-- 		obj:retain()
	-- 		obj:removeFromParent()
	-- 		objMovie:addChild(obj)
	-- 		obj:release()
	-- 	end
	-- end
	-- objMovie.rect = targets[szId].rect

	-- targets[szId]:removeFromParent()
	-- targets[objMovie.szParentID]:addChild(objMovie)
	-- targets[szId] = objMovie
	-- targets[szId].szId = szId
	-- targets[szId]._szMCPath = tParams.szPath
	-- targets[szId]:play("default", -1, 0, 0, -1)

	targets[szId]:setMovieClipFile(tParams.szPath)

	szGlobleResult = "movieNames = " .. targets[szId]:getMovementNameStrings()
	szGlobleResult = szGlobleResult .. ",nX = " .. targets[szId]:getPosition().x
	szGlobleResult = szGlobleResult .. ",nY = " .. targets[szId]:getPosition().y
	setGlobleString(szGlobleResult)

	print("setMovieClipPath success", szNameStrings)
end

function tMEMovieClip:setFrameFps(szId, tParams)
	print("setFrameFps")
	targets[szId]:setFrameFps(tParams.nFPS)
	print("setFrameFps success")
end

return tMEMovieClip