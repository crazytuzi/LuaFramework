local tMETextButton = {}
tMETextButton.__index = tMETextButton
setmetatable(tMETextButton, require("TFFramework.Editor.EditorBase.EditorBase_LoadMEButton"))

function EditLua:createTextButton(szId, tParams)
	print("createTextButton")
	if targets[szId] ~= nil then
		return
	end
	local createBtn = TFTextButton:create()
	createBtn:setTextureNormal("test/button/com_btn3_n.png")
	createBtn:setText("Text Button")
	createBtn:setFontName("宋体")
	createBtn:setFontSize(10)
	createBtn:setPosition(VisibleRect:center())
	-- tTouchEventManager:registerEvents(createBtn)
	targets[szId] = createBtn
	
	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

return tMETextButton