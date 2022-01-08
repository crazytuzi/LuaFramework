local tMEPanel = {}
tMEPanel.__index = tMEPanel
-- setmetatable(tMEPanel, EditLua)
function EditLua:createPanel(szId, tParams)
	print("create panel")
	if targets[szId] ~= nil then
		return
	end
	local panel = TFPanel:create()
	panel:setClippingEnabled(false)
	-- panel:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
	-- panel:setBackGroundColor(ccc3(230,230,230))
	-- panel:setPosition(VisibleRect:center())
	panel:setSize(CCSizeMake(400, 400))
	panel:setBackGroundColorOpacity(50)
	-- panel:setTouchEnabled(true)

	-- tTouchEventManager:registerEvents(panel)

	targets[szId] = panel

	targets[szId]._tDesignSize = CCSizeMake(0, 0)
	-- targets[szId].szId = szId
	-- targets[szId].children = TFArray:new()
	EditLua:addToParent(szId, tParams)
	
	print("create success")

	if tParams ~= nil and tParams.bIsRoot ~= nil and tParams.bIsRoot then
		targets[szId]:setSize(targets["root"]:getSize())
		targets[szId]._bIsRoot = true
		targets[szId]:setPosition(ccp(0, 0))
		-- targets[szId]._bIsSetPercentage = true
		-- targets[szId].visibleRectPercent = 100
		tRootPanel:push(szId)
		print("create rootPanel success")
	end
end

function tMEPanel:setBackGroundColor(szId, tParams)
	print("setBackGroundColor", tParams)
	if tParams.beginColor ~= nil and targets[szId] ~= nil and targets[szId].setBackGroundColor then
		if tParams.endColor ~= nil then
			targets[szId]:setBackGroundColor(ccc3(tParams.beginColor.nR, tParams.beginColor.nG, tParams.beginColor.nB), 
				ccc3(tParams.endColor.nR, tParams.endColor.nG, tParams.endColor.nB))
		else
			targets[szId]:setBackGroundColor(ccc3(tParams.beginColor.nR, tParams.beginColor.nG, tParams.beginColor.nB))
		end
		print("setBackGroundColor run success")
	elseif tParams.nR and tParams.nG and tParams.nB then
		targets[szId]:setBackGroundColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
		print("setBackGroundColor run success")
	end
end

function tMEPanel:setBackGroundColorType(szId, tParams)
	print("setBackGroundColorType")
	if tParams.nType ~= nil and targets[szId] ~= nil and targets[szId].setBackGroundColorType then
		targets[szId]:setBackGroundColorType(tParams.nType)
		print("setBackGroundColorType run success")
	end
end

function tMEPanel:setBackGroundColorVector(szId, tParams)
	print("setBackGroundColorVector")
	if tParams.nX ~= nil and tParams.nY ~= nil and targets[szId] ~= nil and targets[szId].setBackGroundColorVector then
		targets[szId]:setBackGroundColorVector(ccp(tParams.nX, tParams.nY))
		print("setBackGroundColorVector run success")
	end
end

function tMEPanel:setBackGroundColorOpacity(szId, tParams)
	print("setBackGroundColorOpacity")
	if targets[szId] ~= nil and targets[szId].setBackGroundColorOpacity ~= nil and tParams.nOpacity ~= nil then
		targets[szId]:setBackGroundColorOpacity(tParams.nOpacity)
		print("setBackGroundColorOpacity success")
	end
end

function tMEPanel:setClippingEnabled(szId, tParams)
	print("setClippingEnabled")
	if targets[szId] ~= nil and tParams.bRet ~= nil and targets[szId].setClippingEnabled then
		targets[szId]:setClippingEnabled(tParams.bRet)
		print("setClippingEnabled success")
	end
end

function tMEPanel:setBackGroundImage(szId, tParams)
	print("tMEPanel setBackGroundImage", tParams)
	if targets[szId] and targets[szId].setBackGroundImage and tParams.szName ~= nil then
		targets[szId]:setBackGroundImage(tParams.szName)
		print("tMEPanel setBackGroundImage success")
	end
end

function tMEPanel:removeBackGroundImage(szId, tParams)
	print("removeBackGroundImage")
	-- if targets[szId]:getBackGroundImage() then
	targets[szId]:setBackGroundImage("")
	-- end
	print("removeBackGroundImage success")
end

function tMEPanel:setBackGroundImageScale9Enabled(szId, tParams)
	print("setBackGroundImageScale9Enabled")
	if targets[szId] and targets[szId].setBackGroundImageScale9Enabled and tParams.bRet ~= nil then
		targets[szId]:setBackGroundImageScale9Enabled(tParams.bRet)
		print("setBackGroundImageScale9Enabled success")
	end
end

function tMEPanel:setBackGroundImageCapInsets(szId, tParams)
	print("setBackGroundImageCapInsets")
	if targets[szId] and targets[szId].setBackGroundImageCapInsets and tParams.nX ~= nil then
		targets[szId]:setBackGroundImageCapInsets(CCRectMake(tParams.nX, tParams.nY, tParams.nWidth, tParams.nHeight))
		print("setBackGroundImageCapInsets success")
	end
end

function tMEPanel:setScale9Enabled(szId, tParams)
	tMEPanel:setBackGroundImageScale9Enabled(szId, tParams)
end

function tMEPanel:setCapInsets(szId, tParams)
	tMEPanel:setBackGroundImageCapInsets(szId, tParams)
end

local szMsg = ""
function tMEPanel:returnAllWidgetMsg(szId, bBegin)
	if bBegin then
		szMsg = ""
	end
	local children = targets[szId].children
	if children:length() ~= 0 then
		for v in children:iterator() do
			tMEPanel:returnAllWidgetMsg(v, false)
		end
	end
	szMsg = szMsg .. string.format("ID=%s;positionX=%f,positionY=%f|", szId, targets[szId]:getPosition().x, targets[szId]:getPosition().y)
	if bBegin then
		setCmdGetString(szMsg)
	end
end

function tMEPanel:setLayoutType(szId, tParams)
	print("setLayoutType")
	if targets[szId] and tParams.nType then
		targets[szId]:setLayoutType(tParams.nType)
		-- targets[szId]:doLayout()
		local lp
		local szRes = ""
		if tParams.nType ~= TF_LAYOUT_ABSOLUTE then
			for v in targets[szId].children:iterator() do
				local objTarget = targets[v]
				if objTarget then
					if tParams.nType == TF_LAYOUT_LINEAR_VERTICAL or tParams.nType == TF_LAYOUT_LINEAR_HORIZONTAL then
						lp = objTarget:getLayoutParameter(TF_LAYOUT_PARAMETER_LINEAR)
						if tParams.nType == TF_LAYOUT_LINEAR_VERTICAL and targets[v].nVGravity then
							lp:setGravity(targets[v].nVGravity)
						elseif tParams.nType == TF_LAYOUT_LINEAR_HORIZONTAL and targets[v].nHGravity then
							lp:setGravity(targets[v].nHGravity)
						end
						local objMargin = lp:getMargin()
						print("linear margin:", objMargin.left, objMargin.top, objMargin.right, objMargin.bottom)
					elseif tParams.nType == TF_LAYOUT_RELATIVE then
						lp = objTarget:getLayoutParameter(TF_LAYOUT_PARAMETER_RELATIVE)
						local objMargin = lp:getMargin()
						print("relateive margin:", objMargin.left, objMargin.top, objMargin.right, objMargin.bottom)
					elseif tParams.nType == TF_LAYOUT_GRID then
						lp = objTarget:getLayoutParameter(TF_LAYOUT_PARAMETER_GRID)
						local objMargin = lp:getMargin()
						print("grid margin:", objMargin.left, objMargin.top, objMargin.right, objMargin.bottom)
					end
					local objMargin = lp:getMargin()
					local objPos = objTarget:getPosition()
					szRes = szRes .. string.format("ID=%s;nLeft=%f,nTop=%f,nRight=%f,nBottom=%f,positionX=%f,positionY=%f|", objTarget.szId, objMargin.left, objMargin.top, objMargin.right, objMargin.bottom, objPos.x, objPos.y)
				else
					targets[szId].children:removeObject(v)
					print("!!!!!this may not happent!!!!", v)
				end
			end
			if szRes ~= "" then
				szRes = szRes .. string.format("ID=%s;|", szId)
				setCmdGetString(szRes)
			end
		else
			tMEPanel:returnAllWidgetMsg(szId, true)
		end
		targets[szId]:doLayout()
		print("setLayoutType success")
	end
end

function tMEPanel:setRows(szId, tParams)
	print("setRows")
	targets[szId]:setRows(tParams.nRow)
	print("setRows success")
end

function tMEPanel:setRowPadding(szId, tParams)
	print("setRowPadding")
	targets[szId]:setRowPadding(tParams.nPadding)
	print("setRowPadding success")
end

function tMEPanel:setColumns(szId, tParams)
	print("setColumns")
	targets[szId]:setColumns(tParams.nColumn)
	print("setColumns success")
end

function tMEPanel:setColumnPadding(szId, tParams)
	print("setColumnPadding")
	targets[szId]:setColumnPadding(tParams.nPadding)
	print("setColumnPadding success")
end

function tMEPanel:setGridLayoutPriority(szId, tParams)
	print("setGridLayoutPriority", tParams.nType, targets[szId].setGridLayoutPriority)
	targets[szId]:setGridLayoutPriority(tParams.nType)
	print("setGridLayoutPriority success")
end

function tMEPanel:setDesignResolutionSize(szId, tParams)
	print("setDesignResolutionSize")
	if targets[szId]:getSizeType() == TF_SIZE_ADAPT then
		targets[szId]._tDesignSize = CCSizeMake(tParams.nWidth, tParams.nHeight)
		local frameSize = me.EGLView:getFrameSize()
		local bgSize = targets["root"].bgSize
		tParams.nWidth = frameSize.width / (bgSize.width / tParams.nWidth)
		tParams.nHeight = frameSize.height / (bgSize.height / tParams.nHeight)
		targets[szId]:setDesignResolutionSize(tParams.nWidth, tParams.nHeight, targets[szId]:getDesignResolutionPolicy())
		targets[szId]:setSize(targets[szId]._tDesignSize)
	end
	print("setDesignResolutionSize success")
end

function tMEPanel:setDesignResolutionPolicy(szId, tParams)
	print("setDesignResolutionPolicy")
	if targets[szId]:getSizeType() == TF_SIZE_ADAPT then
		local size = targets[szId]:getDesignResolutionSize()
		targets[szId]:setDesignResolutionSize(size.width, size.height, tParams.nType)
		tParams.nWidth = targets[szId]._tDesignSize.width
		tParams.nHeight = targets[szId]._tDesignSize.height
		tMEPanel:setDesignResolutionSize(szId, tParams)
	end
	print("setDesignResolutionPolicy success")
end

---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------


function tMEPanel:setBackGroundBeginColor(szId, tParams)
	print("setBackGroundBeginColor")
	targets[szId]:setBackGroundColor(ccc3(tParams.beginColor.nR, tParams.beginColor.nG, tParams.beginColor.nB), targets[szId]:getBackGroundStartColor())
	print("setBackGroundBeginColor run success")
end

function tMEPanel:setBackGroundEndColor(szId, tParams)
	print("setBackGroundEndColor")
	targets[szId]:setBackGroundColor(targets[szId]:getBackGroundEndColor(), ccc3(tParams.endColor.nR, tParams.endColor.nG, tParams.endColor.nB))
	print("setBackGroundEndColor run success")
end

function tMEPanel:setCapInsetsPos(szId, tParams)
	print("tMEPanel setCapInsetsPos")
	if targets[szId].setBackGroundImageCapInsets then 
		local rect = targets[szId]:getBackGroundImageCapInsets()
		targets[szId]:setBackGroundImageCapInsets(CCRectMake(tParams.nX, tParams.nY, rect.size.width, rect.size.height))
		print("setCapInsetsPos run success")
	end
end

function tMEPanel:setCapInsetsSize(szId, tParams)
	print("tMEPanel setCapInsetsSize")
	if targets[szId].setBackGroundImageCapInsets then 
		local rect = targets[szId]:getBackGroundImageCapInsets()
		targets[szId]:setBackGroundImageCapInsets(CCRectMake(rect.origin.x, rect.origin.y, tParams.nWidth, tParams.nHeight))
		print("setCapInsetsSize run success")
	end
end



return tMEPanel