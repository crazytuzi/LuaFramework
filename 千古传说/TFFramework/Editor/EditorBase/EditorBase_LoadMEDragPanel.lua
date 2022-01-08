local tMEDragPanel = {}
tMEDragPanel.__index = tMEDragPanel
setmetatable(tMEDragPanel, require('TFFramework.Editor.EditorBase.EditorBase_LoadMEScrollView'))
function EditLua:createDragPanel(szId, tParams)
	print("create dragPanel")
	if targets[szId] ~= nil then
		return
	end
	dragPanel = TFDragPanel:create()
	dragPanel:setBounceEnabled(true)
	dragPanel:setSize(CCSizeMake(350, 300))
	dragPanel:setPosition(VisibleRect:center())
	dragPanel:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
	dragPanel:setBackGroundColor(ccc3(230,230,230))
	dragPanel:setClippingEnabled(false)
	dragPanel:setBackGroundColorOpacity(50)
	dragPanel:getInnerContainer():setPosition(ccp(0, 0))
	dragPanel:setTouchEnabled(true)
	-- tTouchEventManager:registerEvents(dragPanel)
	targets[szId] = dragPanel

	EditLua:addToParent(szId, tParams)
	
	print("create success")
end

return tMEDragPanel