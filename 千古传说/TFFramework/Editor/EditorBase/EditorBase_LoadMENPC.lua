local tMENPC = {}

function EditLua:createNPC(szId, tParams)
	print("create NPC")
	if targets[szId] ~= nil then
		return
	end
	local texture = "test/node.png"
	if tParams.szFileName then
		texture = tParams.szFileName
	end
	
	local img = TFNPC:create()
	img:setTexture(texture)
	img:setPosition(VisibleRect:center())
	-- tTouchEventManager:registerEvents(img)
	targets[szId] = img
	
	EditLua:addToParent(szId, tParams)

	print("create success")
end

function tMENPC:loadTexture(szId, tParams)
	print("loadTexture NPC")
	if targets[szId].setTexture and tParams.szName ~= nil then
		if tParams.szName == "" then
			tParams.szName = "test/node.png"
		end
		targets[szId]:setTexture(tParams.szName)
		print("loadTexture success", tParams.szName)
	end
end

return tMENPC