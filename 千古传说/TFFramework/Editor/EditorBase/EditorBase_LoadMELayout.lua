function EditLua:CalculateTheDeltPos(objTarget)
	if not objTarget:getParent() and not EditorUtils:TargetIsContainer(objTarget:getParent()) then return end
	print("--------------------------------- CalculateTheDeltPos ------------------------------------")
	local lp = objTarget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
	if lp then
		local nAlign = lp:getAlign()
		local ap = objTarget:getAnchorPoint()
		local cs = objTarget:getSize()
		cs.width = cs.width * objTarget:getScaleX()
		cs.height = cs.height * objTarget:getScaleY()
		local relativeWidget, relativeWidgetLP
		local finalPosX, finalPosY
		local layoutSize = objTarget:getParent():getSize()
		local rbs
		-- layoutSize.width = layoutSize.width * objTarget:getParent():getScaleX()
		-- layoutSize.height = layoutSize.height * objTarget:getParent():getScaleY()
		local relativeName = lp:getRelativeToWidgetName()
		if relativeName ~= "" then
			relativeWidget = objTarget:getParent():seekWidgetByRelativeName(objTarget:getParent(), relativeName)
			if relativeWidget then
				relativeWidgetLP = relativeWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
				rbs = CCSize(relativeWidget:getSize().width * relativeWidget:getScaleX(), relativeWidget:getSize().height * relativeWidget:getScaleY())
			end
		end
		print("TargetName, nAlign, x, y:", objTarget:getName(), nAlign, objTarget:getPosition().x, objTarget:getPosition().y)
		print("layoutSize: width, height:", layoutSize.width, layoutSize.height)
		print("targetSize: width, height:", cs.width, cs.height)
		print("relativeToWidget:", relativeName, relativeWidget, relativeWidgetLP)
		if nAlign <= TF_R_A_PARENT_TOP_LEFT then
			finalPosX = ap.x * cs.width
			finalPosY = layoutSize.height - ((1.0 - ap.y) * cs.height)
		elseif nAlign == TF_R_A_PARENT_TOP_CENTER_HORIZONTAL then
			finalPosX = layoutSize.width * 0.5 - cs.width * (0.5 - ap.x)
			finalPosY = layoutSize.height - ((1.0 - ap.y) * cs.height)
		elseif nAlign == TF_R_A_PARENT_TOP_RIGHT then
			finalPosX = layoutSize.width - ((1.0 - ap.x) * cs.width)
			finalPosY = layoutSize.height - ((1.0 - ap.y) * cs.height)
		elseif nAlign == TF_R_A_PARENT_LEFT_CENTER_VERTICAL then
			finalPosX = ap.x * cs.width
			finalPosY = layoutSize.height * 0.5 - cs.height * (0.5 - ap.y)
		elseif nAlign == TF_R_A_CENTER_IN_PARENT then
			finalPosX = layoutSize.width * 0.5 - cs.width * (0.5 - ap.x)
			finalPosY = layoutSize.height * 0.5 - cs.height * (0.5 - ap.y)
		elseif nAlign == TF_R_A_PARENT_RIGHT_CENTER_VERTICAL then
			finalPosX = layoutSize.width - ((1.0 - ap.x) * cs.width)
			finalPosY = layoutSize.height * 0.5 - cs.height * (0.5 - ap.y)
		elseif nAlign == TF_R_A_PARENT_LEFT_BOTTOM then
			finalPosX = ap.x * cs.width
			finalPosY = ap.y * cs.height
		elseif nAlign == TF_R_A_PARENT_BOTTOM_CENTER_HORIZONTAL then
			finalPosX = layoutSize.width * 0.5 - cs.width * (0.5 - ap.x)
			finalPosY = ap.y * cs.height
		elseif nAlign == TF_R_A_PARENT_RIGHT_BOTTOM then
			finalPosX = layoutSize.width - ((1.0 - ap.x) * cs.width)
			finalPosY = ap.y * cs.height

		elseif nAlign == TF_R_LOCATION_ABOVE_LEFTALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationBottom = relativeWidget:getTopInParent()
					local locationLeft = relativeWidget:getLeftInParent()
					finalPosY = locationBottom + ap.y * cs.height
					finalPosX = locationLeft + ap.x * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_ABOVE_CENTER then
			if relativeWidget then
				if relativeWidgetLP then
					-- local rbs = relativeWidget:getSize()
					local locationBottom = relativeWidget:getTopInParent()
					finalPosY = locationBottom + ap.y * cs.height
					finalPosX = relativeWidget:getLeftInParent() + rbs.width * 0.5 + ap.x * cs.width - cs.width * 0.5
				end
			end
		elseif nAlign == TF_R_LOCATION_ABOVE_RIGHTALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationBottom = relativeWidget:getTopInParent()
					local locationRight = relativeWidget:getRightInParent()
					finalPosY = locationBottom + ap.y * cs.height
					finalPosX = locationRight - (1.0 - ap.x) * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_LEFT_OF_TOPALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationTop = relativeWidget:getTopInParent()
					local locationRight = relativeWidget:getLeftInParent()
					finalPosY = locationTop - (1.0 - ap.y) * cs.height
					finalPosX = locationRight - (1.0 - ap.x) * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_LEFT_OF_CENTER then
			if relativeWidget then
				if relativeWidgetLP then
					-- local rbs = relativeWidget:getSize()
					local locationRight = relativeWidget:getLeftInParent()
					finalPosX = locationRight - (1.0 - ap.x) * cs.width
					finalPosY = relativeWidget:getBottomInParent() + rbs.height * 0.5 + ap.y * cs.height - cs.height * 0.5
				end
			end
		elseif nAlign == TF_R_LOCATION_LEFT_OF_BOTTOMALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationBottom = relativeWidget:getBottomInParent()
					local locationRight = relativeWidget:getLeftInParent()
					finalPosY = locationBottom + ap.y * cs.height
					finalPosX = locationRight - (1.0 - ap.x) * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_RIGHT_OF_TOPALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationTop = relativeWidget:getTopInParent()
					local locationLeft = relativeWidget:getRightInParent()
					finalPosY = locationTop - (1.0 - ap.y) * cs.height
					finalPosX = locationLeft + ap.x * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_RIGHT_OF_CENTER then
			if relativeWidget then
				if relativeWidgetLP then
					-- local rbs = relativeWidget:getSize()
					local locationLeft = relativeWidget:getRightInParent()
					finalPosX = locationLeft + ap.x * cs.width
					finalPosY = relativeWidget:getBottomInParent() + rbs.height * 0.5 + ap.y * cs.height - cs.height * 0.5
				end
			end
		elseif nAlign == TF_R_LOCATION_RIGHT_OF_BOTTOMALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationBottom = relativeWidget:getBottomInParent()
					local locationLeft = relativeWidget:getRightInParent()
					finalPosY = locationBottom + ap.y * cs.height
					finalPosX = locationLeft + ap.x * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_BELOW_LEFTALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationTop = relativeWidget:getBottomInParent()
					local locationLeft = relativeWidget:getLeftInParent()
					finalPosY = locationTop - (1.0 - ap.y) * cs.height
					finalPosX = locationLeft + ap.x * cs.width
				end
			end
		elseif nAlign == TF_R_LOCATION_BELOW_CENTER then
			if relativeWidget then
				if relativeWidgetLP then
					-- local rbs = relativeWidget:getSize()
					local locationTop = relativeWidget:getBottomInParent()
					finalPosY = locationTop - (1.0 - ap.y) * cs.height
					finalPosX = relativeWidget:getLeftInParent() + rbs.width * 0.5 + ap.x * cs.width - cs.width * 0.5
				end
			end
		elseif nAlign == TF_R_LOCATION_BELOW_RIGHTALIGN then
			if relativeWidget then
				if relativeWidgetLP then
					local locationTop = relativeWidget:getBottomInParent()
					local locationRight = relativeWidget:getRightInParent()
					finalPosY = locationTop - (1.0 - ap.y) * cs.height
					finalPosX = locationRight - (1.0 - ap.x) * cs.width
				end
			end
		end
		if finalPosX == nil then
		print("--------------------------------- CalculateTheDeltPos End ------------------------------------")
			return nil 
		end
		print("first pos:", finalPosX, finalPosY)
		finalPosX = objTarget:getPosition().x - (finalPosX - layoutSize.width * objTarget:getParent():getAnchorPoint().x)
		finalPosY = objTarget:getPosition().y - (finalPosY - layoutSize.height * objTarget:getParent():getAnchorPoint().y)
		print("finalPos:", finalPosX, finalPosY)
		print("--------------------------------- CalculateTheDeltPos End ------------------------------------")
		return ccp(finalPosX, finalPosY)
	end
	print("--------------------------------- CalculateTheDeltPos End ------------------------------------")
	return ccp(0, 0)
end

-- linear
function EditLua:setGravity(szId, tParams)
	print("setGravity")
	if targets[szId] and tParams.nGravity then
		--1:左, 2:上, 3:右, 4:下, 5:垂直中, 6:水平中
		local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
		if lp == nil then
			lp = TFLinearLayoutParameter:create()
			targets[szId]:setLayoutParameter(lp)
		end
		if lp then
			lp:setGravity(tParams.nGravity)
			if tParams.nGravity == 2 or tParams.nGravity == 4 or tParams.nGravity == 5 then
				targets[szId].nHGravity = tParams.nGravity
			else
				targets[szId].nVGravity = tParams.nGravity
			end
			print("setGravity success")
			if targets[targets[szId].szParentID]:getNodeType() == TFWIDGET_TYPE_CONTAINER then
				targets[targets[szId].szParentID]:doLayout()
			end
		else
			print("setGravity failed")
		end
	end
end

-- relative
function EditLua:setAlign(szId, tParams)
	print("setAlign nAlign:", tParams.nAlign)
	if targets[szId] and tParams.nAlign ~= nil then
		local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		if lp == nil then
			lp = TFRelativeLayoutParameter:create()
			targets[szId]:setLayoutParameter(lp)
		end
		if lp then
			lp:setRelativeName(targets[szId]:getName())
			lp:setAlign(tParams.nAlign)
			local pos = EditLua:CalculateTheDeltPos(targets[szId])
			if pos and EditorUtils:TargetIsContainer( targets[targets[szId].szParentID] ) then
				local relativeControl = targets[szId]:getParent():seekWidgetByRelativeName(targets[szId]:getParent(), lp:getRelativeToWidgetName())
				-- 不是相对兄弟节点，或者相对兄弟节点且相对控件已经创建，则把位置转换为margin
				if tParams.nAlign <= TF_R_A_PARENT_RIGHT_BOTTOM or relativeControl then
					-- main logic for auto change margin to pos!!!!!!!!!!!!!!!
					lp:setMargin(TFMargin(0, 0, 0, 0))
					local margin = lp:convertToMargin(pos)
					lp:setMargin(margin)
				end
			end
			if EditorUtils:TargetIsContainer( targets[targets[szId].szParentID] )then
				targets[targets[szId].szParentID]:doLayout()
			end
			for v in targets[targets[szId].szParentID].children:iterator() do
				tRetureMsgTarget:push(v)
			end
			tRetureMsgTarget:push(szId)
			bIsNeedToSetCmdGet = true
			print("setAlign success")
		else
			print("setAlign failed")
		end
	end
end

-- relative
function EditLua:setRelativeToWidgetName(szId, tParams)
	print("---setRelativeToWidgetName---")
	if targets[szId] and tParams.szName ~= nil then
		local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		if lp then
			-- if lp:getRelativeToWidgetName() ~= tParams.szName then
				-- change relative to parent , align should be less then 10, otherwise should be more then 9
				print("old relative name:", lp:getRelativeToWidgetName(), lp:getAlign())
				lp:setRelativeToWidgetName(tParams.szName)
				if tParams.nAlign then EditLua:setAlign(szId, tParams) end
				
				local parentID = targets[szId].szParentID
				if tParams.szName == targets[parentID]:getName() then
					if not tParams.nAlign then tParams.nAlign = 1 end
					EditLua:setAlign(szId, tParams)
				else
					local relativeWidget = targets[parentID]:getChildByName(tParams.szName)
					if relativeWidget then
						local relativeLp = relativeWidget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
						if relativeLp then
							relativeLp:setRelativeName(tParams.szName)
							if not tParams.nAlign then tParams.nAlign = 10 end
							EditLua:setAlign(szId, tParams)
						else
							print("didn't set name")
						end
					end
				end

				print("---setRelativeToWidgetName success---")

			-- else
			-- 	print("success, relativeName is :", tParams.szName)
			-- end
		end
	end
end

-- linear
function EditLua:setMargin(szId, tParams)
	print("setMargin")
	if targets[szId] and tParams.nLeft ~= nil and tParams.nRight ~= nil and tParams.nTop ~= nil and tParams.nBottom ~= nil then
		local objParent = targets[targets[szId].szParentID]
		local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
		if lp and EditorUtils:TargetIsLinearLayout(objParent) then
			lp:setMargin(TFMargin(tParams.nLeft, tParams.nTop, tParams.nRight, tParams.nBottom))
			print("setMargin Linear success")
		end
		lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
		if lp and EditorUtils:TargetIsRelativeLayout(objParent) then
			lp:setMargin(TFMargin(tParams.nLeft, tParams.nTop, tParams.nRight, tParams.nBottom))
			print("setMargin Relative success")
		end
		lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
		if lp and EditorUtils:TargetIsGridLayout(objParent) then
			lp:setMargin(TFMargin(tParams.nLeft, tParams.nTop, tParams.nRight, tParams.nBottom))
			print("setMargin Grid success")
		end
		if EditorUtils:TargetIsContainer(objParent) then
			targets[targets[szId].szParentID]:doLayout()
		end
	end
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------
--[[ WPF:

	public enum VisualHorizontalAlignment
	{
		Left = 0,
		Center = 1,
		Right = 2,
		Stretch = 3
	}

	public enum VisualVerticalAlignment
	{
		Top = 0,
		Center = 1,
		Bottom = 2,
		Stretch = 3
	}

	public enum VisualMarginAlignment
	{
		Left = 0,
		Top = 1,
		Right = 2,
		Bottom = 3
	}
]]

-- relative:
local function convertToRelativeEnum(nVertical, nHorizontal, nPadding)
	print("convertToRelativeEnum:", nVertical, nHorizontal, nPadding)
	if nVertical == nil then nVertical = 0 end
	if nHorizontal == nil then nHorizontal = 0 end
	local nAlign = 0
	if nPadding == nil then
		nAlign = nVertical * 3 + nHorizontal + 1
		-- TF_R_A_NONE,
		-- TF_R_A_PARENT_TOP_LEFT
		-- TF_R_A_PARENT_TOP_CENTER_HORIZONTAL
		-- TF_R_A_PARENT_TOP_RIGHT
		-- TF_R_A_PARENT_LEFT_CENTER_VERTICAL
		-- TF_R_A_CENTER_IN_PARENT
		-- TF_R_A_PARENT_RIGHT_CENTER_VERTICAL
		-- TF_R_A_PARENT_LEFT_BOTTOM
		-- TF_R_A_PARENT_BOTTOM_CENTER_HORIZONTAL
		-- TF_R_A_PARENT_RIGHT_BOTTOM			9
	else
		-- todo change the C++ enum order
		if nPadding == 0 or nPadding == 2 then
			if nPadding == 0 then
				nAlign = 3 + nVertical + 10
			else
				nAlign = nPadding * 3 + nVertical + 10
			end
		else
			if nPadding == 3 then
				nAlign = nPadding * 3 + nHorizontal + 10
			else
				nAlign = 0 + nHorizontal + 10
			end
		end
		-- TF_R_LOCATION_ABOVE_LEFTALIGN,		10
		-- TF_R_LOCATION_ABOVE_CENTER,
		-- TF_R_LOCATION_ABOVE_RIGHTALIGN,
		-- TF_R_LOCATION_LEFT_OF_TOPALIGN,		13
		-- TF_R_LOCATION_LEFT_OF_CENTER,
		-- TF_R_LOCATION_LEFT_OF_BOTTOMALIGN,
		-- TF_R_LOCATION_RIGHT_OF_TOPALIGN,		16
		-- TF_R_LOCATION_RIGHT_OF_CENTER,
		-- TF_R_LOCATION_RIGHT_OF_BOTTOMALIGN,
		-- TF_R_LOCATION_BELOW_LEFTALIGN,		19
		-- TF_R_LOCATION_BELOW_CENTER,
		-- TF_R_LOCATION_BELOW_RIGHTALIGN
	end
	print("convert align:", nAlign)
	return nAlign
end

local function updateAlign(szId)
	local lp = targets[szId]:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
	local parent = targets[szId]:getParent()
	local relativeToWidgetName = lp:getRelativeToWidgetName()
	if relativeToWidgetName ~= parent:getName() and relativeToWidgetName ~= "" then
		if parent:getParent() and parent:getParent():getDescription() == "TFScrollView" and parent:getParent():getName() == relativeToWidgetName then
			--align to parent
			EditLua:setAlign(szId, {nAlign = convertToRelativeEnum(targets[szId]._RelativeVertical, targets[szId]._RelativeHorizontal, nil)})
			return
		end
		--align to brother
		EditLua:setAlign(szId, {nAlign = convertToRelativeEnum(targets[szId]._RelativeVertical, targets[szId]._RelativeHorizontal, targets[szId]._RelativePadding)})
	else
		--align to parent
		EditLua:setAlign(szId, {nAlign = convertToRelativeEnum(targets[szId]._RelativeVertical, targets[szId]._RelativeHorizontal, nil)})
	end
end

function EditLua:setRelativeHorizontal(szId, tParams)
	print("---setRelativeHorizontal---")
	targets[szId]._RelativeHorizontal = tParams.nHorizontal
	updateAlign(szId)
	print("---setRelativeHorizontal success---")
end

function EditLua:setRelativeVertical(szId, tParams)
	print("---setRelativeVertical---")
	targets[szId]._RelativeVertical = tParams.nVertical
	updateAlign(szId)
	print("---setRelativeVertical success---")
end

function EditLua:setRelativePadding(szId, tParams)
	print("---setRelativePadding---")
	targets[szId]._RelativePadding = tParams.nPadding
	EditLua:setAlign(szId, {nAlign = convertToRelativeEnum(targets[szId]._RelativeVertical, targets[szId]._RelativeHorizontal, targets[szId]._RelativePadding)})
	print("---setRelativePadding success---")
end

-- linear:
		--1:左, 2:上, 3:右, 4:下, 5:垂直中, 6:水平中
--[[
	TF_L_GRAVITY_NONE,
	TF_L_GRAVITY_LEFT,
	TF_L_GRAVITY_TOP,
	TF_L_GRAVITY_RIGHT,
	TF_L_GRAVITY_BOTTOM,
	TF_L_GRAVITY_CENTER_VERTICAL,
	TF_L_GRAVITY_CENTER_HORIZONTAL
]]
local function convertToLinearEnum(num, bIsVertical)
	local eNum = 0
	if bIsVertical then
		if num == 0 then eNum = TF_L_GRAVITY_TOP end
		if num == 1 then eNum = TF_L_GRAVITY_CENTER_VERTICAL end
		if num == 2 then eNum = TF_L_GRAVITY_BOTTOM end
	else
		if num == 0 then eNum = TF_L_GRAVITY_LEFT end
		if num == 1 then eNum = TF_L_GRAVITY_CENTER_HORIZONTAL end
		if num == 2 then eNum = TF_L_GRAVITY_RIGHT end
	end
	print("convert enum:", eNum)
	return eNum
end

function EditLua:setLinearHorizontal(szId, tParams)
	if targets[szId]:getParent():getLayoutType() ~= TF_LAYOUT_LINEAR_VERTICAL then
		print("parent layout type is wrong!!!", targets[szId]:getParent():getLayoutType())
		return
	end
	print("setLinearHorizontal")
	targets[szId]._LinearHorizontal = tParams.nHorizontal
	EditLua:setGravity(szId, {nGravity = convertToLinearEnum(targets[szId]._LinearHorizontal)})
	print("setLinearHorizontal success")
end

function EditLua:setLinearVertical(szId, tParams)
	if targets[szId]:getParent():getLayoutType() ~= TF_LAYOUT_LINEAR_HORIZONTAL then
		print("parent layout type is wrong!!!", targets[szId]:getParent():getLayoutType())
		return
	end
	print("setLinearVertical")
	targets[szId]._LinearVertical = tParams.nVertical
	EditLua:setGravity(szId, {nGravity = convertToLinearEnum(targets[szId]._LinearVertical, true)})
	print("setLinearVertical success")
end
