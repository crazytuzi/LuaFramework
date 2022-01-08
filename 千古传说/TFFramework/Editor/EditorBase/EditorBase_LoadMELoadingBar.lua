local tMELoadingBar = {}
-- tMELoadingBar.__index = tMELoadingBar
-- setmetatable(tMELoadingBar, EditLua)
function EditLua:createLoadingBar(szId, tParams)
	print("createLoadingBar")
	if targets[szId] ~= nil then
		return
	end
	local loadindBar = TFLoadingBar:create()
	loadindBar:setPercent(100)
	loadindBar:setDirection(TFLOADINGBAR_LEFT)
	loadindBar:setTexture("test/textBg.png")

	tTouchEventManager:registerEvents(loadindBar)
	targets[szId] = loadindBar

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMELoadingBar:loadTexture(szId, tParams)
	print("loadTexture")
	if targets[szId].setTexture and tParams.szName ~= nil then
		local per = -1
		if targets[szId].getPercent then
			per = targets[szId]:getPercent()
		end
		targets[szId]:setTexture(tParams.szName)
		if tParams.szName == "" then
			targets[szId]:setTexture("test/textBg.png")
		end
		if per ~= -1 then
			targets[szId]:setPercent(per)
		end
		print("loadTexture success")
	end
end

function tMELoadingBar:setDirection(szId, tParams)
	print("setDirection")
	if tParams.nDirection ~= nil and targets[szId] ~= nil and targets[szId].setDirection then
		local dir = TFLOADINGBAR_LEFT
		if tParams.nDirection == 1 then
			dir = TFLOADINGBAR_RIGHT
		elseif tParams.nDirection == 2 then
			dir = TFLOADINGBAR_TOP
		elseif tParams.nDirection == 3 then
			dir = TFLOADINGBAR_BOTTOM
		elseif tParams.nDirection == 4 then
			dir = TFLOADINGBAR_CIRCLE_LEFT
		elseif tParams.nDirection == 5 then
			dir = TFLOADINGBAR_CIRCLE_RIGHT
		end
			
		targets[szId]:setDirection(dir)
		print("setDirection run success")
	end
end

function tMELoadingBar:setPercent(szId, tParams)
	print("setPercent")
	if tParams.nPercent ~= nil and targets[szId] ~= nil and targets[szId].setPercent then
		targets[szId]:setPercent(tParams.nPercent)
		print("setPercent run success")
	end
end

function tMELoadingBar:setMidPoint(szId, tParams)
	print("setMidPoint")
	if tParams.nX and tParams.nY and targets[szId].setMidPoint then
		targets[szId]:setMidPoint(ccp(tParams.nX, tParams.nY))
		print("setMidPoint run success")
	end
end

function tMELoadingBar:setBeginPoint(szId, tParams)
	print("setBeginPoint")
	if tParams.nX and tParams.nY and targets[szId].setBeginPoint then
		targets[szId]:setBeginPoint(ccp(tParams.nX, tParams.nY))
		print("setBeginPoint run success")
	end
end

return tMELoadingBar