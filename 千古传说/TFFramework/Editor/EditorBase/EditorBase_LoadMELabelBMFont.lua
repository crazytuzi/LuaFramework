local tMELabelBMFont = {}
tMELabelBMFont.__index = tMELabelBMFont
setmetatable(tMELabelBMFont, require("TFFramework.Editor.EditorBase.EditorBase_LoadMELabel"))

function EditLua:createLabelBMFont(szId, tParams)
	print("createLabelBMFont")
	if targets[szId] ~= nil then
		return
	end
	local label = TFLabelBMFont:create()
	label:setFntFile('test/missing-font.fnt')
	label:setText("TFLabelBMFont")
	label:setPosition(VisibleRect:center())
	-- tTouchEventManager:registerEvents(label)
	targets[szId] = label

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

function tMELabelBMFont:setFntFile(szId, tParams)
	print("setFntFile")
	if tParams.szFntName ~= nil and targets[szId].setFntFile then
		if tParams.szFntName == "" then
			tParams.szFntName = 'test/missing-font.fnt'
		end
		if string.find(tParams.szFntName, '.fnt') == nil then
			print("error: ============is not fnt file !==============")
			return
		end
		targets[szId]:setFntFile(tParams.szFntName)
		-- local label = targets[szId]:clone(false)
		-- label:setFntFile(tParams.szFntName)
		-- label:setText(targets[szId]:getText())

		-- label.szId = szId
		-- label.children = TFArray:new()
		-- label.szParentID = targets[szId].szParentID
		
		-- label.children = targets[szId].children
		-- for szChildID in targets[szId].children:iterator() do
		-- 	local obj = targets[szChildID]
		-- 	if obj then
		-- 		obj:retain()
		-- 		obj:removeFromParent()
		-- 		label:addChild(obj)
		-- 		obj:release()
		-- 	end
		-- end
		-- label.rect = targets[szId].rect

		-- targets[targets[szId].szParentID]:addChild(label)
		-- targets[szId]:removeFromParent()
		-- targets[szId] = label
		print("setFntFile run success")
	end
end

function tMELabelBMFont:setColor(szId, tParams)
	print("setColor")
	if tParams.nR ~= nil and tParams.nG ~= nil and tParams.nB ~= nil and targets[szId] ~= nil and targets[szId].setColor then
		targets[szId]:setColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setColor success")
	end
end

return tMELabelBMFont