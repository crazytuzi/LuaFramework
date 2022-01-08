require('TFFramework.Editor.EditorBase.EditorBase_LoadMEButton')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMECheckBox')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEDragPanel')
-- require('TFFramework.Editor.EditorBase.EditorBase_LoadMEEditBox')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEImage')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMELabel')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEIconLabel')
-- require('TFFramework.Editor.EditorBase.EditorBase_LoadMELabelAtlas')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMELabelBMFont')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMELayout')
-- require('TFFramework.Editor.EditorBase.EditorBase_LoadMEListView')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMELoadingBar')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEMovieClip')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMENPC')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPageView')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEScrollView')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMESlider')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMETableView')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMETextArea')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMETextButton')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMETextField')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEParticle')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMERichText')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEButtonGroup')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEGroupButton')

-- require('TFFramework.Editor.EditorBase.EditorBase_LoadMEStoneMap')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEBigMap')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEArmature')
require('TFFramework.Editor.EditorBase.EditorBase_LoadMEAction')

require('TFFramework.Editor.EditorBase.EditorBase_LoadMEWidget')

require('TFFramework.Editor.EditBigMap')
require('TFFramework.Editor.EditMapData')
require('TFFramework.Editor.EditVirtualBase')
require('TFFramework.Editor.EditUtils')

function EditLua:addToParent(szId, tParams)
	local szParentID
	targets[szId]:setPosition(ccp(0, 0))
	if tTouchEventManager.bIsCreate then
		tParams = tTouchEventManager:setMoveCreate(targets[szId], tParams)
	end
	if not tParams or tParams.szParent == nil or targets[tParams.szParent] == nil then
		targets["root"]:addChild(targets[szId])
		szParentID = "root"
		targets["root"].children:push(szId)
		szCurRootPanelID = szId
		print("root add children")
	else
		szParentID = tParams.szParent
		EditVirtualBase:addChild(szParentID, szId)
		targets[szParentID].children:push(szId)
	end
	
	tLuaDataManager:addObjLuaData(szId, szParentID)
end

function EditLua:getTargetMarginOrPosition_CmdGet(szId)
	local szRes = ""
	local touchObj = targets[szId]
	local parentID = touchObj.szParentID
	szRes = string.format("ID=%s;positionX=%f,positionY=%f,nXPer=%.2f, nYPer=%.2f|", 
		touchObj.szId, touchObj:getPosition().x, touchObj:getPosition().y,touchObj:getPositionPercentX()*100, touchObj:getPositionPercentY()*100)
	local pParent = targets[parentID]
	if EditorUtils:TargetIsContainer(pParent) then
		local lp
		if EditorUtils:TargetIsLinearLayout(pParent) then
			lp = touchObj:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
		elseif EditorUtils:TargetIsRelativeLayout(pParent) then
			lp = touchObj:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		elseif EditorUtils:TargetIsGridLayout(pParent) then
			lp = touchObj:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
		end
		if lp then
			local objMargin = lp:getMargin()
			szRes = string.format("ID=%s;nLeft=%f,nTop=%f,nRight=%f,nBottom=%f,positionX=%f,positionY=%f,nXPer=%.2f, nYPer=%.2f|", 
				touchObj.szId or "root", objMargin.left, objMargin.top, objMargin.right, objMargin.bottom, touchObj:getPosition().x, touchObj:getPosition().y,touchObj:getPositionPercentX()*100, touchObj:getPositionPercentY()*100)
		end
	end
	return szRes
end
