local tMETextArea = {}
tMETextArea.__index = tMETextArea
setmetatable(tMETextArea, require("TFFramework.Editor.EditorBase.EditorBase_LoadMELabel"))

function EditLua:createTextArea(szId, tParams)
	print("createTextArea")
	if targets[szId] ~= nil then
		return
	end
	EditLua:createLabel(szId, tParams)
	targets[szId]:setText("TextArea")
	do return end
	local textArea = TFTextArea:create()
	textArea:setText("TextArea")
	textArea:setFontName("宋体")
	textArea:setFontSize(20)	
	-- tTouchEventManager:registerEvents(textArea)
	targets[szId] = textArea
	
	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

return tMETextArea