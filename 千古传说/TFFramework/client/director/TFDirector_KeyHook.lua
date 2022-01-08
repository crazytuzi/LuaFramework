--
-- Author: MiYu
-- Date: 2014-02-08 10:32:49
--

function TFDirector:description(...)

	-- key params
	TFDirector.bShowKey					= nil
	TFDirector.tUpKeys	 				= nil
	TFDirector.tHandles 				= nil
	TFDirector.tDownKeys 				= nil
	TFDirector.bCTRLDown 				= nil	

	-- key functions
	TFDirector:registerKeyUp(key, tParam, func, objTarget, ...)
	TFDirector:unRegisterKeyUp(key, func)
	TFDirector:registerKeyDown(key, tParam, func, objTarget, ...)
	TFDirector:unRegisterKeyDown(key, func)
	TFDirector:onKeyUpFunc()
	TFDirector:onKeyDownFunc()

end

function TFDirector:registerKeyUp(key, tParam, func, objTarget, ...)
	TFDirector.tUpKeys = TFDirector.tUpKeys or {}
	TFDirector.tHandles = TFDirector.tHandles or {}
	TFDirector.tUpKeys[key] = TFDirector.tUpKeys[key] or TFArray:new()
	local nIdx = TFDirector.tUpKeys[key]:indexOf(func)
	if nIdx == -1 then
		TFDirector.tUpKeys[key]:push(func)
		TFDirector.tHandles[func] = TFDirector.tHandles[func] or {}
		TFDirector.tHandles[func].objTarget = objTarget
		TFDirector.tHandles[func].tParam = tParam or {}
		TFDirector.tHandles[func].nLastTime = 0
		TFDirector.tHandles[func].tHandleParams = {...}
	end
end

function TFDirector:unRegisterKeyUp(key, func)
	TFDirector.tUpKeys = TFDirector.tUpKeys or {}
	TFDirector.tHandles = TFDirector.tHandles or {}
	TFDirector.tUpKeys[key] = TFDirector.tUpKeys[key] or TFArray:new()
	local nIdx = TFDirector.tUpKeys[key]:indexOf(func)
	if nIdx ~= -1 then
		TFDirector.tUpKeys[key]:removeObject(func)
		TFDirector.tHandles[func] = nil
	end
end

function TFDirector:registerKeyDown(key, tParam, func, objTarget, ...)
	TFDirector.tDownKeys = TFDirector.tDownKeys or {}
	TFDirector.tHandles = TFDirector.tHandles or {}
	TFDirector.tDownKeys[key] = TFDirector.tDownKeys[key] or TFArray:new()
	local nIdx = TFDirector.tDownKeys[key]:indexOf(func)
	if nIdx == -1 then
		TFDirector.tDownKeys[key]:push(func)
		TFDirector.tHandles[func] = TFDirector.tHandles[func] or {}
		TFDirector.tHandles[func].objTarget = objTarget
		TFDirector.tHandles[func].tParam = tParam or {}
		TFDirector.tHandles[func].nLastTime = 0
		TFDirector.tHandles[func].tHandleParams = {...}
	end
end

function TFDirector:unRegisterKeyDown(key, func)
	TFDirector.tDownKeys = TFDirector.tDownKeys or {}
	TFDirector.tHandles = TFDirector.tHandles or {}
	TFDirector.tDownKeys[key] = TFDirector.tDownKeys[key] or TFArray:new()
	local nIdx = TFDirector.tDownKeys[key]:indexOf(func)
	if nIdx ~= -1 then
		TFDirector.tDownKeys[key]:removeObject(func)
		TFDirector.tHandles[func] = nil
	end
end

function TFDirector:onKeyUpFunc(key)
	if key == 17 then -- ctrl
		TFDirector.bCTRLDown = false
	end

	TFDirector.tUpKeys = TFDirector.tUpKeys or {}
	TFDirector.tUpKeys[key] = TFDirector.tUpKeys[key] or TFArray:new()

	for func in TFDirector.tUpKeys[key]:iterator() do
		local nTm = TFDirector.tHandles[func].nLastTime or 0
		local nCurTime = os.clock() * 1000

		if nCurTime > nTm then
			local bCanRun = true
			if TFDirector.tHandles[func].tParam.bEnableCtrl and not TFDirector.bCTRLDown then
				bCanRun = false
			end
			if TFDirector.tHandles[func].tParam.bEnableAlt and not TFDirector.bALTDown then
				bCanRun = false
			end
			if bCanRun then
				TFFunction.call(func, TFDirector.tHandles[func].objTarget, unpack(TFDirector.tHandles[func].tHandleParams))
				TFDirector.tHandles[func].nLastTime = nCurTime + TFDirector.tHandles[func].tParam.nGap
			end
		end
	end

	if TFDirector.bShowKey then
		print('==> key[ ', key, ' ] up.')
	end
end

function TFDirector:onKeyDownFunc(key)
	if key == 101 then -- numpad_5
	elseif key == 37 then --left
	elseif key == 38 then -- up
	elseif key == 39 then -- right
	elseif key == 40 then -- down
	elseif key == 110 and TFDirector.bCTRLDown then -- num_del
	end

	if key == 17 then -- ctrl
		TFDirector.bCTRLDown = true
	end

	TFDirector.tDownKeys = TFDirector.tDownKeys or {}
	TFDirector.tDownKeys[key] = TFDirector.tDownKeys[key] or TFArray:new()

	for func in TFDirector.tDownKeys[key]:iterator() do
		local nTm = TFDirector.tHandles[func].nLastTime or 0
		local nCurTime = os.clock() * 1000

		if nCurTime > nTm then
			TFFunction.call(func, TFDirector.tHandles[func].objTarget, unpack(TFDirector.tHandles[func].tHandleParams))
			TFDirector.tHandles[func].nLastTime = nCurTime + (TFDirector.tHandles[func].tParam.nGap or 0)
		end
	end

	if TFDirector.bShowKey then
		print('==> key[ ', key, ' ] down.')
	end
end

return TFDirector