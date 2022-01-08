EditMapData = class("EditMapData")
local bIsOpenGrid = false
local target
local tData -- = {
	-- [1] = {nValue = 1, szColor = "0xff00ff00"},
	-- [2] = {nValue = 2, szColor = "0xffff0000"},
	-- [3] = {nValue = 3, szColor = "0xff0000ff"},}	-- nAction, nValue, szColor
--advance
local tDrawIndexs
local tObjArrayOfColor
local tDrawNode = {}

local tGridMapData = {}
local szCurMap = ""
local bHadLoad = false
local bIsSaving = false


function EditMapData:onTouchBegan( ... )
	-- print("touch begin")
	self.startPos = self:getTouchStartPos()
end

function EditMapData:onTouchMoved( ... )
	print("touch move")
	local movePos = self:getTouchMovePos()
	if TFDirector.bCTRLDown then 	--移动地图
		print("move map")
		local curPos = targets["root"]:getPosition()
		local convertPos = ccpSub(movePos, self.startPos)
		targets["root"]:setPosition(ccpAdd(curPos, convertPos))
		target:setPosition(targets["root"]:getPosition())
	else 	--刷格子
		print("move Brush", target, target.nGridMode)
		if target.nGridMode == 0 then
			EditMapData.setSelfGridColor(nil, movePos, target.nGridValue)
		elseif target.nGridMode == 1 then
			EditMapData.removeGridColor(nil, movePos, target.nGridValue)
		elseif target.nGridMode == 2 then
			EditMapData.removeGridAllColor(nil, movePos)
		elseif target.nGridMode == 3 then
			EditMapData.removeAllGridColor(nil, movePos)
		end
	end
	self.startPos = movePos
end

function EditMapData:onTouchEnded( ... )
	-- print("touch end")
	-- local endPos = self:getTouchEndPos()
end

function EditMapData:onTouchCancelled( ... )
	local szRes = ""
end

function EditMapData:registerEvents()
	self:addMEListener(TFWIDGET_TOUCHBEGAN, EditMapData.onTouchBegan)
	self:addMEListener(TFWIDGET_TOUCHMOVED, EditMapData.onTouchMoved)
	self:addMEListener(TFWIDGET_TOUCHENDED, EditMapData.onTouchEnded)
	self:addMEListener(TFWIDGET_TOUCHCANCELLED, EditMapData.onTouchEnded)
end

function EditMapData:addGrid( ... )
	-- setGridLine
	local point = {}
	point.x = target:getAnchorPoint().x * target:getSize().width * -1
	point.y = target:getAnchorPoint().y * target:getSize().height * -1

	-- target.tColorTotle = {}
	-- for i = 1, target.nRow do
	-- 	for j = 1, target.nCol do
	-- 		target.tColorTotle[(j-1)+(i-1)*target.nCol] = 0
	-- 	end
	-- end
	-- target.nBrushNum = 1  
	target.tLines = TFArray:new()
	for i = 0, target:getSize().height / target.nGridHeight do
	-- 	local image = TFImage:create("test/imageGrid.png")
	-- 	image:setScale9Enabled(true)
	-- 	image:setAnchorPoint(ccp(0, 0))
	-- 	image:setColor(ccc3(255, 0, 0))
	-- 	image:setSize(CCSize(target:getSize().width, 2))
	-- 	image:setPosition(ccpAdd(ccp(point.x, point.y), ccp(0, target.nGridHeight * i)))
	-- 	image:setZOrder(100)
	-- 	image:setOpacity(30)
		-- local image = TFDrawNode:create()
		-- image:drawSegment(ccp(0, 0), ccp(target.nGridWidth*target.nCol, 0), 1.0, ccc4f(0, 0, 1.0, 0.3))
		-- image:setPosition(ccpAdd(ccp(point.x, point.y), ccp(0, target.nGridHeight * i)))
		-- target:addChild(image)
		-- target.tLines:push(image)
	end
	for j = 0, target:getSize().width / target.nGridWidth do	
	-- 	image = TFImage:create("test/imageGrid.png")
	-- 	image:setScale9Enabled(true)
	-- 	image:setAnchorPoint(ccp(0, 0))
	-- 	image:setColor(ccc3(255, 0, 0))
	-- 	image:setSize(CCSize(2, target:getSize().height))
	-- 	image:setPosition(ccpAdd(ccp(point.x, point.y), ccp(target.nGridWidth * j, 0)))
	-- 	image:setZOrder(100)
	-- 	image:setOpacity(30)
		-- local image = TFDrawNode:create()
		-- image:drawSegment(ccp(0, 0), ccp(0, target.nGridHeight*target.nRow), 1.0, ccc4f(0, 0, 1.0, 0.3))
		-- image:setPosition(ccpAdd(ccp(point.x, point.y), ccp(target.nGridWidth * j, 0)))
		-- target:addChild(image)
		-- target.tLines:push(image)
	end
	-- set Grid
	local image = TFImage:create("test/imageGrid.png")
	image:setOpacity(30)
		image:setImageSizeType(TF_SIZE_CORRDS)
		image:setSize(CCSizeMake(target:getSize().width, target:getSize().height))
	-- image:setCoordsSize(target:getSize().width, target:getSize().height, 0, 0)
	image:setAnchorPoint(ccp(0, 0))
	target.objBgImg = image
	target:addChild(image)
end

function EditMapData:setMoveMode(szId, tParams)
	print("setMoveMode")
	if tParams.bRet ~= nil then
		target.bIsMoveMap = tParams.bRet
		print("setMoveMode success")
	end
end

function EditMapData:saveData(szId, tParams)
	if bIsSaving then
		print("=================== isSaving ===================");
		return
	end
	bIsSaving = true
	print("saveData", tParams.szSavePath)
	if tParams.szSavePath and target then
		local objMap = TFMapBlock:create()
		objMap:setSize(target.nGridWidth * target.nCol, target.nGridHeight * target.nRow)
		-- save row and col
		objMap:addShort(target.nGridWidth)
		objMap:addShort(target.nGridHeight)
		objMap:addShort(target:getSize().width)
		objMap:addShort(target:getSize().height)

		--方式2
		local nX, nY
		-- for i = 0, target.nGridNum - 1 do
		for i in tDrawIndexs:iterator() do
			if target.tColorTotle[i] and target.tColorTotle[i] ~= 0 then
				nX = i % target.nCol * target.nGridWidth
				nY = EditorUtils:GetIntPart(i/target.nCol) * target.nGridHeight
				objMap:addShort(nX, nY, target.tColorTotle[i])
			end
		end
		objMap:save(tParams.szSavePath)
		print("saveData success")
	end
	bIsSaving = false
end

function EditMapData:getKeyandValue(obj , uIndex)
	local nIndex , nValue = obj:getKeyandValue(uIndex , 0 , 0)
	local nReal = (nIndex - 8)/2
	return nReal , nValue , nIndex+2;
end

function EditMapData:getXYandValue(obj, uIndex)
	local nX, nY, nValue = obj:getKeyandValue(uIndex , 0 , 0, 0)
	local nTag = EditorUtils:GetIntPart(nX/target.nGridWidth) + EditorUtils:GetIntPart(nY/target.nGridHeight)*target.nCol
	return nX, nY, nValue , uIndex+6, nTag;
end

function EditMapData:getXYbyTag(nTag, nRow, nColumn)
	local x, y = nTag % nColumn * target.nGridWidth, nTag / nColumn * target.nGridHeight
	return x, y
end

function EditMapData:setMapInfo()
end

function EditMapData:loadData(szId, tParams)
	print("EditMapData loadData")
	if tParams.szSavePath ~= "" and szCurMap ~= tParams.szSceneID then
		local objMap = TFMapBlock:create()
		local bIsOpen = objMap:open(tParams.szSavePath)
		szCurMap = tParams.szSceneID
		print("try Open file", bIsOpen)
		if bIsOpen then
			tGridMapData[tParams.szSceneID] = {}
			local tMapData = tGridMapData[tParams.szSceneID]
			local width, height = objMap:getShort(0), objMap:getShort(1)
			print("openFile success", width, height)
			if width == 0 then width = 20 end
			if height == 0 then height = 20 end
			target.nGridWidth = width
			target.nGridHeight = height
			tMapData.nGridWidth, tMapData.nGridHeight = width, height
			tMapData.nWidth, tMapData.nHeight = objMap:getShort(2), objMap:getShort(3)
			target.nGridNum = EditorUtils:GetIntPart(tMapData.nWidth / target.nGridWidth) * EditorUtils:GetIntPart(tMapData.nHeight / target.nGridHeight)
			print(target.nGridNum)
			if target.nGridWidth ~= 0 then
				local tmpParams = {}
				-- 方式3
				local nX, nY, nValue, i =0, 0, 0, 8
				local nTag
				local time = os.time()
				while true do
					nX, nY, nValue, i, nTag = EditMapData.getXYandValue(nil, objMap, i)
					if nValue == 0 then
						break
					end
					target.tColorTotle[nTag] = nValue
					if tDrawIndexs:indexOf(nTag) == -1 then
						tDrawIndexs:push(nTag)
					end
					for j, k in pairs(tData) do
						if bit_and(bit_lshift(1, k.nValue), target.tColorTotle[nTag]) ~= 0 then
							local r, g, b = ('0x'..k.szColor['4:5'])+0, ('0x'..k.szColor['6:7'])+0, ('0x'..k.szColor['8:9'])+0
							local objRectColor = ccc4f(r/255, g/255, b/255 , 1.0)
							local objLineColor = ccc4f(1 , 0 , 0 , 0.5)
							tObjArrayOfColor[k.nValue][nTag] = nTag
							tDrawNode[k.nValue]:addRect(ccp(nX, nY), target.nGridWidth, target.nGridHeight, objRectColor, objLineColor, 2.0)
							------------------------------
						end
					end					
				end
				print("loadTime:", os.time() - time)
			end
		else
			print("open File failed!!!!!!!!!!!!!")
		end
		--save mapData
	elseif szCurMap == tParams.szSceneID then
		bHadLoad = false
		do return end
	else
		print("new data")
		szCurMap = tParams.szSceneID
	end
	bHadLoad = false
	EditMapData.addGrid(nil)
end

function EditMapData:init( ... )
	tDrawIndexs = TFArray:new()
	tObjArrayOfColor = {}
	tData = {}
end

function EditMapData:dispose( ... )
	EditMapData:removeAllGridColor()
	targets["UILayer"]:removeChild(target)
	targets["root"].objGridLayer = nil
	tData = nil
	szCurMap = ""
	bIsOpenGrid = false
	bHadLoad = false
	tCurState = EditLua
	target = nil
end

function EditMapData:setGridEnabled(szId, tParams)
	print("EditMapData setGridEnabled")
	if tParams.bRet ~= nil and tParams.nWidth ~= nil and tParams.nHeight ~= nil then
		local szSceneID = tParams.szSavePath
		if tParams.bRet then
			if bIsOpenGrid then return end
			bIsOpenGrid = true
			if szSceneID == szCurMap and szCurMap ~= "" then
				if targets["root"].objGridLayer then
					targets["root"].objGridLayer:setVisible(true)
				end
				bHadLoad = true
				tCurState = EditMapData
				return
			end

			target = TFPanel:create()
			target:setZOrder(9999)
			target:setPosition(targets["root"]:getPosition())
			target:setSize(CCSize(5000, 5000))
			target:setAnchorPoint(ccp(0, 0))
			target:setTouchEnabled(true)
			target:setClippingEnabled(false)
			target:setTag(-1)
			target:setScale(targets["root"]:getScale())
			target.bGridEnabled = true
			EditMapData.registerEvents(target)
			targets["UILayer"]:addChild(target)
			targets["root"].objGridLayer = target

			-- set target attribute
			target.bIsMoveMap = false
			target.nGridWidth = tParams.nWidth
			target.nGridHeight = tParams.nHeight
			target.nRow = EditorUtils:GetIntPart(target:getSize().height / target.nGridHeight)
			target.nCol = EditorUtils:GetIntPart(target:getSize().width / target.nGridWidth)
			target.nGridNum = target.nRow*target.nCol
			target.nBrushNum = 1

			target.tColorTotle = {}
			for i = 1, target.nRow do
				for j = 1, target.nCol do
					target.tColorTotle[(j-1)+(i-1)*target.nCol] = 0
				end
			end


			EditMapData.init(nil)

			tCurState = EditMapData
			tSelectedRectManager:setSelectedRectVisible(nil, false)
			-- targets["root"].selected:setVisible(false)
			-- targets["root"].scrollRect:setVisible(false)
		elseif bIsOpenGrid then
			print("setGridEnabled false", szSceneID, szCurMap)
			bIsOpenGrid = false
			tCurState = EditLua
			-- if szSceneID == szCurMap then
				if targets["root"].objGridLayer then
					targets["root"].objGridLayer:setVisible(false)
				end
			-- end
		end
		print("setGridEnabled success")
	end
end

function EditMapData:setGridSize(szId, tParams)
	print("setGridSize")
	if tParams.nWidth ~= nil and tParams.nHeight ~= nil then
		if tParams.nWidth == 0 or tParams.nHeight == 0 then
			print("!!!!!!!!!!!!!!!!!!! grid width or grid height can not be 0 !!!!!!!!!!!!!!!!!!!!!")
			return
		end
		if tParams.nWidth == target.nGridWidth and tParams.nHeight == target.nGridHeight then
			print("!!!!!!!!!!!!!!!!!!!! this is same size of grid !!!!!!!!!!!!!!!!!")
			return
		end
		EditMapData.removeAllGridColor(nil)
		-- set target attribute
		target.nGridWidth = tParams.nWidth
		target.nGridHeight = tParams.nHeight
		target.nRow = EditorUtils:GetIntPart(target:getSize().height / target.nGridHeight)
		target.nCol = EditorUtils:GetIntPart(target:getSize().width / target.nGridWidth)
		target.nGridNum = target.nRow*target.nCol

		for i = 1, target.nRow do
			for j = 1, target.nCol do
				target.tColorTotle[(j-1)+(i-1)*target.nCol] = 0
			end
		end
	end
	print("setGridSize success")
end

function EditMapData:setDataFormat(szId, tParams)
	print("setDataFormat")
	if tParams.nAction and tParams.szColor then

		if tData[tParams.nAction] then 	--the color is exist
			print("data is exist")
			if bHadLoad then
				print("is loading data ")
				return
			end
			-- change exist data
			local newR, newG, newB = ('0x'..tParams.szColor['4:5'])+0, ('0x'..tParams.szColor['6:7'])+0, ('0x'..tParams.szColor['8:9'])+0
			local objRectColor = ccc4f(newR/255, newG/255, newB/255 , 1.0)
			local objLineColor = ccc4f(1 , 0 , 0 , 0.5)
			local nTestNum = bit_lshift(1, tParams.nAction)
			if target.nGridNum then
				for j in tDrawIndexs:iterator() do
					if bit_and(nTestNum, target.tColorTotle[j]) ~= 0 then
						-- set color
						local  beginPos = ccp(EditorUtils:GetIntPart(j%target.nCol)*target.nGridWidth, EditorUtils:GetIntPart(j/target.nCol)*target.nGridHeight)
						tDrawNode[tParams.nAction]:removeRect(beginPos, target.nGridWidth, target.nGridHeight)
						tDrawNode[tParams.nAction]:addRect(beginPos, target.nGridWidth, target.nGridHeight, objRectColor, objLineColor, 2.0)
						-----------------------
					end
				end
				tDrawNode[tParams.nAction]:reDrawAfterRemovePoint()
			end
			tData[tParams.nAction].szColor = tParams.szColor
		else
			local t = {nValue = tParams.nAction, szColor = tParams.szColor}
			tData[tParams.nAction] = t
			tObjArrayOfColor[tParams.nAction] = {}
			local drawNode = TFDrawNode:create()
			target:addChild(drawNode)
			tDrawNode[tParams.nAction] = drawNode
		end
		print("setDataFormat success")
	end
end

function EditMapData:removeDataFormat(szId, tParams)
	if tParams.nAction then
		if tData[tParams.nAction] then
			if target.nGridNum then
				for j in tDrawIndexs:iterator() do
					if bit_and(bit_lshift(1, tParams.nAction), target.tColorTotle[j]) ~= 0 then
						local beginPos = ccp(EditorUtils:GetIntPart(j%target.nCol)*target.nGridWidth, EditorUtils:GetIntPart(j/target.nCol)*target.nGridHeight)
						tDrawNode[tParams.nAction]:removeRect(beginPos, target.nGridWidth, target.nGridHeight)						
						tObjArrayOfColor[tParams.nAction][j] = nil
						target.tColorTotle[j] = target.tColorTotle[j] - bit_lshift(1, tParams.nAction)
						-----------------------
					end
				end	
			end			
		end
	end
end

function EditMapData:setGridMode(szId, tParams)
	print("EditMapData setGridMode")
	if tParams.nGridMode ~= nil then
		if tParams.nGridMode == 3 then
			EditMapData.removeAllGridColor()
			return
		end
		target.nGridMode = tParams.nGridMode
		if tParams.szColor ~= nil and tParams.szColor ~= "" then
			local R = ('0x' .. tParams.szColor['4:5']) + 0
			local G = ('0x' .. tParams.szColor['6:7']) + 0
			local B = ('0x' .. tParams.szColor['8:9']) + 0
			target.tGridColor = {r=R, g=G, b=B}
			target.nGridValue = tParams.nAction
			print(target.nGridValue, tParams.nAction)
		end
		print("setGridMode success")
	end
end

function EditMapData:setColorVisible(szId, tParams)
	print("setColorVisible")
	if tParams.nAction and tParams.bIsVisible ~= nil then
		tDrawNode[tParams.nAction]:setVisible(tParams.bIsVisible)
	end
	print("setColorVisible success")
end

function EditMapData:setBrushNum(szId, tParams)
	print("setBrushNum")
	if tParams and tParams.nBrushNum then
		target.nBrushNum = tParams.nBrushNum
		print("setBrushNum success")
	end
end

function EditMapData:setSelfGridColor(pos, colorIndex)
	print("EditMapData setGridColor")
	if tData[colorIndex] == nil then
		print("brush data is null")
		return 
	end
	local color = tData[colorIndex].szColor
	local r = ('0x' .. color['4:5']) + 0
	local g = ('0x' .. color['6:7']) + 0
	local b = ('0x' .. color['8:9']) + 0

	local nodePos = target:convertToNodeSpace(pos)
	local tag = EditorUtils:GetIntPart(nodePos.x/target.nGridWidth) + EditorUtils:GetIntPart(nodePos.y/target.nGridHeight)*target.nCol
	local n = target.nCol
	for i = 1, target.nBrushNum do
		local nMinTag = EditorUtils:GetIntPart(tag/n)*n + (i-1)*n
		local nMaxTag = EditorUtils:GetIntPart(tag/n)*n + n-1 + (i-1)*n
		for j = 1, target.nBrushNum do
			local nTag = tag + (i-1)*n + j-1
			if nTag < nMinTag or nTag > nMaxTag or nTag < 0 or nTag > target.nGridNum-1
				or nodePos.x < 0 or nodePos.x > 5000 or nodePos.y < 0 or nodePos.y > 5000 then
				break
			end
			-- is not draw this color
			if bit_and(bit_lshift(1, target.nGridValue), target.tColorTotle[nTag]) == 0 then
				target.tColorTotle[nTag] = target.tColorTotle[nTag] + 2^target.nGridValue
				-- set color
				local objRectColor = ccc4f(r/255, g/255, b/255 , 1.0)
				local objLineColor = ccc4f(1 , 0 , 0 , 0.5)
				local  beginPos = ccp(EditorUtils:GetIntPart(nTag%target.nCol)*target.nGridWidth, EditorUtils:GetIntPart(nTag/target.nCol)*target.nGridHeight)
				tObjArrayOfColor[colorIndex][nTag] = nTag
				tDrawNode[colorIndex]:addRect(beginPos, target.nGridWidth, target.nGridHeight, objRectColor, objLineColor, 2.0)

				if tDrawIndexs:indexOf(nTag) == -1 then
					tDrawIndexs:push(nTag)	-- mayby add more than once
				end
			end
			---------------
		end
	end
	print("setGridColor success")
end

function EditMapData:removeGridColor(pos, colorIndex)
	print("EditMapData removeGridColor", colorIndex)
	local color = tData[colorIndex].szColor
	local r = ('0x' .. color['4:5']) + 0
	local g = ('0x' .. color['6:7']) + 0
	local b = ('0x' .. color['8:9']) + 0

	local nodePos = target:convertToNodeSpace(pos)
	local tag = EditorUtils:GetIntPart(nodePos.x/target.nGridWidth) + EditorUtils:GetIntPart(nodePos.y/target.nGridHeight)*target.nCol
	local n = target.nCol
	for i = 1, target.nBrushNum do
		local nMinTag = EditorUtils:GetIntPart(tag/n)*n + (i-1)*n
		local nMaxTag = EditorUtils:GetIntPart(tag/n)*n + n-1 + (i-1)*n
		for j = 1, target.nBrushNum do
			local nTag = tag + (i-1)*n + j-1
			if nTag < nMinTag or nTag > nMaxTag or nTag < 0 or nTag > target.nGridNum-1
				or nodePos.x < 0 or nodePos.x > 5000 or nodePos.y < 0 or nodePos.y > 5000 then
				break
			end
			print(nTag, target.tColorTotle[nTag])
			if bit_and(bit_lshift(1, target.nGridValue), target.tColorTotle[nTag]) ~= 0 then
				target.tColorTotle[nTag] = target.tColorTotle[nTag] - 2^target.nGridValue
				local beginPos = ccp(EditorUtils:GetIntPart(nTag%target.nCol)*target.nGridWidth, EditorUtils:GetIntPart(nTag/target.nCol)*target.nGridHeight)
				tDrawNode[colorIndex]:removeRect(beginPos, target.nGridWidth, target.nGridHeight)
				tObjArrayOfColor[colorIndex][nTag] = nil
				-- set color
				if target.tColorTotle[nTag] == 0 then
					tDrawIndexs:removeObject(nTag)
				end
			end
			---------------
		end
	end
	tDrawNode[colorIndex]:reDrawAfterRemovePoint()
	print("setGridColor removeGridColor success")
end

function EditMapData:removeAllGridColor()
	print("EditMapData removeAllGridColor")
	for i, v in pairs(tObjArrayOfColor) do
		for j, k in pairs(tObjArrayOfColor[i]) do
			tDrawNode[i]:clear()
			tObjArrayOfColor[i][j] = nil
			target.tColorTotle[j] = 0
		end
	end
	tDrawIndexs:clear()
	print("EditMapData removeAllGridColor success")
end

return EditMapData