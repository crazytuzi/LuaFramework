local tMEImage = {}
-- tMEImage.__index = tMEImage
-- setmetatable(tMEImage, EditLua)

function EditLua:createImage(szId, tParams)
	print("create Image")
	if targets[szId] ~= nil then
		return
	end
	local texture = "test/blocks.png"
	if tParams.szFileName then
		texture = tParams.szFileName
	end
	
	local img = TFImage:create()
	img:setTexture(texture)
	img:setPosition(VisibleRect:center())
	-- tTouchEventManager:registerEvents(img)
	targets[szId] = img
	
	EditLua:addToParent(szId, tParams)

	print("create success")
end

function tMEImage:loadTexture(szId, tParams)
	print("loadTexture")
	if targets[szId].setTexture and tParams.szName ~= nil then
		if tParams.szName == "" then
			tParams.szName = "test/blocks.png"
		end
		targets[szId]:setTexture(tParams.szName)
		print("loadTexture success")
	end
end

function tMEImage:setImageSizeType(szId, tParams)
	print("setImageSizeType")
	targets[szId]:setImageSizeType(tParams.nType)
	print("setImageSizeType success")
end

function tMEImage:setBlendFunc(szId, tParams)
	print("setBlendFunc")
	targets[szId]:setBlendFunc(tParams.nSrc, tParams.nDst)
	print("setBlendFunc success")
end


function tMEImage:setMixColor(szId, tParams)
	print("setMixColor")
	targets[szId]:setMixColor(ccc4(tParams.nR, tParams.nG, tParams.nB, tParams.nA))
	print("setMixColor success")
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------

function tMEImage:setMixedValueColor(szId, tParams)
	print("setMixedValueColor", targets[szId].setMixColor)
	targets[szId]:setMixColor(ccc4(tParams.nR, tParams.nG, tParams.nB, 0))
	print("setMixedValueColor success")
end

function tMEImage:setCorrdsEnabled(szId, tParams)
	print("setCorrdsEnabled")
	if tParams.bEnabled then
		targets[szId]:setImageSizeType(2)
	else
		targets[szId]:setImageSizeType(0)
	end
	print("setCorrdsEnabled success")
end



return tMEImage