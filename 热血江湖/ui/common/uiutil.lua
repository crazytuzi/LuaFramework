local UIDefault = require "ui/common/DefaultValue"
local UIFactory = require "ui/common/UIFactory"
local NodeFactory = require "ui/common/NodeFactory"
local UIUtil = { }

UIUtil.isIphoneX = false

local function setNode(ele, vars, nodesMap, propsMap, parent)
	local prop = ele.prop
	prop._ccParent = parent
	local nodeCreate = NodeFactory.createNode(prop)
	if (nodeCreate == nil) then
		return
	end
	if nodeCreate and prop.varName and vars then
		--vars[prop.varName] = nodeCreate
		
		vars[prop.varName] = UIFactory.createUI(nodeCreate, prop)
		if prop.etype == "RichText" then -- TODO
			vars[prop.varName]:doFormat()
		end
	end
	
	if nodeCreate == 1 then
		return
	end

	nodeCreate:setName(prop.name)
	nodesMap[prop.name] = nodeCreate
	propsMap[prop.name] = prop
	if prop.anchorX and prop.anchorY then
		nodeCreate:setAnchorPoint(cc.p(prop.anchorX, prop.anchorY))
	end
	nodeCreate:initSizeAndPosition(prop)
	nodeCreate:initialize(prop)
	if vars[prop.varName] then
		vars[prop.varName].propScale9Rect = prop.scale9Rect
	end
	
	local visible = prop.visible == nil or prop.visible ~= false
	nodeCreate:setVisible(visible)
	local disable = prop.disable ~= nil and prop.disable == true
	if disable then
		nodeCreate:setEnabled(false)
		nodeCreate:setEnableControl(false)
	end
	if ele.children then
		for _, ce in ipairs(ele.children) do
			local nodeCreateC = setNode(ce, vars, nodesMap, propsMap, nodeCreate)
			if nodeCreateC then
				nodeCreate:addChild(nodeCreateC)
			end
		end
	end
	return nodeCreate
end

local function parseAction(propName, frames)
	local actions = { }
	if propName == "scale" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local scaleX = frame[2][1]
			local scaleY = frame[2][2]
			--TODO
			local act = cc.ScaleTo:create((ktime - lastTime)/1000, scaleX, scaleY)  
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "move" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local posX = frame[2][1]
			local posY = frame[2][2]
			--TODO
			local act = cc.MoveTo:create((ktime - lastTime)/1000, cc.p(posX, posY))  
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "moveP" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local posX = frame[2][1]
			local posY = frame[2][2]
			--TODO
			local act = cc.MovePTo:create((ktime - lastTime)/1000, cc.p(posX, posY))  
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "bezier" then
		local lastTime = 0
		for i, frame in ipairs(frames) do
			local ktime = frame[1]
			local posX = frame[2][1]
			local posY = frame[2][2]
			local cp1X = frame[2][3]
			local cp1Y = frame[2][4]
			local cp2X = frame[2][5]
			local cp2Y = frame[2][6]
			--TODO
			if i == 1 then
				local act = cc.MoveTo:create((ktime - lastTime)/1000, cc.p(posX, posY))  
				table.insert(actions, act)
			else
				table.insert(actions, cc.BezierTo:create((ktime - lastTime)/1000, {
					cc.p(cp1X, cp1Y),
					cc.p(cp2X, cp2Y),
					cc.p(posX, posY)
				}))
			end

			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "circle" then
		local lastTime = 0
		local posStartX = 0
		local posStartY = 0
		for i, frame in ipairs(frames) do
			local ktime = frame[1]
			local posX = frame[2][1]
			local posY = frame[2][2]
			if i == 1 then
				posStartX = posX
				posStartY = posY
			else
				--TODO start from posStartX, posStartY, center is posX, posY, time = (ktime - lastTime)/1000
				--local act = cc.MoveTo:create((ktime - lastTime)/1000, cc.p(posX, posY))  
				------ circle counter wise
				local magic = 0.551784
				local radius = math.sqrt((posStartX-posX)*(posStartX-posX) + (posStartY-posY)*(posStartY-posY))

				local p0 = cc.p(posX + radius, posY)
				local p90 = cc.p(posX, posY - radius)
				local p180 = cc.p(posX - radius, posY)
				local p270 = cc.p(posX, posY + radius)

				------0 ~ 90
				table.insert(actions, cc.BezierTo:create((ktime - lastTime)/4000, {
					cc.p(posX + radius, posY - radius * magic),
					cc.p(posX + radius * magic, posY - radius),
					p90
				}))
				------90 ~ 180
				table.insert(actions, cc.BezierTo:create((ktime - lastTime)/4000, {
					cc.p(posX - radius * magic, posY - radius),
					cc.p(posX - radius, posY - radius * magic),
					p180
				}))
				------180 ~ 270
				table.insert(actions, cc.BezierTo:create((ktime - lastTime)/4000, {
					cc.p(posX - radius, posY + radius * magic),
					cc.p(posX - radius * magic, posY + radius),
					p270
				}))
				------270 ~ 360
				table.insert(actions, cc.BezierTo:create((ktime - lastTime)/4000, {
					cc.p(posX + radius * magic, posY + radius),
					cc.p(posX + radius, posY + radius * magic),
					p0
				}))
				---
			end
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "alpha" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local alpha = frame[2][1]
			--TODO
			local act = cc.FadeTo:create((ktime - lastTime)/1000, alpha*255)  
			--print("FadeTo: " .. (alpha*255))
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "rotate" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local angle = frame[2][1]
			--TODO
			local act = cc.RotateTo:create((ktime - lastTime)/1000, angle)  
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	elseif propName == "skew" then
		local lastTime = 0
		for _, frame in ipairs(frames) do
			local ktime = frame[1]
			local angleX = frame[2][1]
			local angleY = frame[2][2]
			--TODO
			local act = cc.SkewTo:create((ktime - lastTime)/1000, angleX, angleY)  
			table.insert(actions, act)
			lastTime = ktime
		end
		return cc.Sequence:create(actions), lastTime
	end
end

local function parseActionToTime(propName, frames, timeTo, node)

	local frameA = 0
	local frameB = 1
	if #frames == 0 then
		return
	end
	local i = 1
	for _, frame in ipairs(frames) do
		local ktime = frame[1]
		if ktime <= timeTo then
			frameA = i
			frameB = i
		end
		if ktime >= timeTo then
			frameB = i
			break
		end
		i = i + 1
	end
	local timeA = frames[frameA][1]
	local timeB = frames[frameB][1]

	if propName == "scale" then
		
		local scaleXA = frames[frameA][2][1]
		local scaleYA = frames[frameA][2][2]
		
		local scaleXB = frames[frameB][2][1]
		local scaleYB = frames[frameB][2][2]
		
		local scaleX = scaleXA
		local scaleY = scaleYA
		if timeB > timeA then
			scaleX = scaleXA + (scaleXB - scaleXA) * (timeTo - timeA) / (timeB - timeA)
			scaleY = scaleYA + (scaleYB - scaleYA) * (timeTo - timeA) / (timeB - timeA)
		end
		node:setScale(scaleX, scaleY)
	elseif propName == "move" then
		local posXA = frames[frameA][2][1]
		local posYA = frames[frameA][2][2]
		
		local posXB = frames[frameB][2][1]
		local posYB = frames[frameB][2][2]
		
		local posX = posXA
		local posY = posYA
		if timeB > timeA then
			posX = posXA + (posXB - posXA) * (timeTo - timeA) / (timeB - timeA)
			posY = posYA + (posYB - posYA) * (timeTo - timeA) / (timeB - timeA)
		end
		node:setPositionType(0)
		node:setPosition(cc.p(posX, posY))
	elseif propName == "moveP" then
		local posXA = frames[frameA][2][1]
		local posYA = frames[frameA][2][2]
		
		local posXB = frames[frameB][2][1]
		local posYB = frames[frameB][2][2]
		
		local posX = posXA
		local posY = posYA
		if timeB > timeA then
			posX = posXA + (posXB - posXA) * (timeTo - timeA) / (timeB - timeA)
			posY = posYA + (posYB - posYA) * (timeTo - timeA) / (timeB - timeA)
		end
		node:setPositionType(1)
		node:setPosition(cc.p(posX, posY))
	elseif propName == "alpha" then

		local alphaA = frames[frameA][2][1]
		
		local alphaB = frames[frameB][2][1]
		
		local alpha = alphaA

		if timeB > timeA then
			alpha = alphaA + (alphaB - alphaA) * (timeTo - timeA) / (timeB - timeA)
		end

		node:setOpacity(alpha * 255)

	elseif propName == "rotate" then

		local rotateA = frames[frameA][2][1]
		
		local rotateB = frames[frameB][2][1]
		
		local rotate = rotateA

		if timeB > timeA then
			rotate = rotateA + (rotateB - rotateA) * (timeTo - timeA) / (timeB - timeA)
		end

		node:setRotation(rotate) -- rotation3d by z
	elseif propName == "skew" then
		local skewXA = frames[frameA][2][1]
		local skewYA = frames[frameA][2][2]
		
		local skewXB = frames[frameB][2][1]
		local skewYB = frames[frameB][2][2]
		
		local skewX = skewXA
		local skewY = skewYA
		if timeB > timeA then
			skewX = skewXA + (skewXB - skewXA) * (timeTo - timeA) / (timeB - timeA)
			skewY = skewYA + (skewYB - skewYA) * (timeTo - timeA) / (timeB - timeA)
		end
		--node:setRotation3D(cc.vec3(skewX, 0, skewY))
		node:setSkewX(skewX)
		node:setSkewY(skewY)
	end
end

local eLayoutStretch = 0
local eLayoutBottomLeft = 1
local eLayoutBottomCenter = 2
local eLayoutBottomRight = 3
local eLayoutCenterLeft = 4
local eLayoutCenterCenter = 5
local eLayoutCenterRight = 6
local eLayoutTopLeft = 7
local eLayoutTopCenter = 8
local eLayoutTopRight = 9

local eLayoutStretchLeft = 10
local eLayoutStretchRight = 11
local eLayoutStretchTop = 12
local eLayoutStretchBottom = 13
		
local eLayoutLeft = 1
local eLayoutCenter = 2
local eLayoutRight = 3
		
local eLayoutBottom = 1
local eLayoutCenter = 2
local eLayoutTop = 3
		
local lTable = {
	{ h = eLayoutLeft, v = eLayoutBottom },
	{ h = eLayoutCenter, v = eLayoutBottom },
	{ h = eLayoutRight, v = eLayoutBottom },
	{ h = eLayoutLeft, v = eLayoutCenter },
	{ h = eLayoutCenter, v = eLayoutCenter },
	{ h = eLayoutRight, v = eLayoutCenter },
	{ h = eLayoutLeft, v = eLayoutTop },
	{ h = eLayoutCenter, v = eLayoutTop },
	{ h = eLayoutRight, v = eLayoutTop },
}
local function visitNode(node, visitor)
	visitor(node)
	if node.children then
		for _, child in ipairs(node.children) do
			visitNode(child, visitor)
		end
	end
end
local function layoutRoots(root, aniData, modFontSize, modSize, modSizeAB, modAni)
	if not root or root.layoutDone then
		return
	end
	root.layoutDone = true	
	local director = cc.Director:getInstance()
	local glView = director:getOpenGLView();
	local winSize = director:getWinSize()
	--print(winSize.width)
	--print(winSize.height)
	--printf("win size = %f, %f", winSize.width, winSize.height)
	local visibleSize = director:getVisibleSize()
	--print(visibleSize.width)
	--print(visibleSize.height)
	--printf("visible size = %f, %f", visibleSize.width, visibleSize.height)
	
	local doLayout = ( winSize.width * visibleSize.height ~= winSize.height * visibleSize.width )
	if doLayout then
		local rDesign = winSize.width / winSize.height
		local rVisible = visibleSize.width / visibleSize.height
		
		if rVisible < rDesign then -- TODO

			local rLayout = rVisible / rDesign
			local vWidth = rLayout
			local vLeft = (1 - vWidth) / 2

			if modFontSize then
				-- update font size of label and richtext and editbox
				local fontSizeDiff = 0
				if rVisible <= 1.34 then
					fontSizeDiff = -4
				elseif rVisible <= 1.51 then
					fontSizeDiff = -2
				elseif rVisible >= 2 then
					fontSizeDiff = -4
				end
				--
				if fontSizeDiff ~= 0 then
					visitNode(root, 
						function(node)
							local prop = node.prop
							if prop.etype == "Label" or prop.etype == "RichText" then
								prop.fontSize = (prop.fontSize or 20) + fontSizeDiff
							elseif prop.etype == "EditBox" then
								prop.fontSize = (prop.fontSize or 20) + fontSizeDiff
								--printf("update font size to %d", prop.fontSize)
								prop.phFontSize = (prop.phFontSize or 20) + fontSizeDiff
								--printf("update ph font size to %d", prop.phFontSize)
							end
						end
					)
				end
				--
			end
			--

			if modSize then
				--TODO prepare ani
				local moveNodes = { }
				if modAni and aniData then
					for aniName, aniNodes in pairs(aniData) do
						if string.sub(aniName, 1, 2) ~= "c_" then
							for nodeName, nodeProps in pairs(aniNodes) do
								local moveProp = nodeProps.move
								if moveProp then
									local cache = moveNodes[nodeName]
									if not cache then
										cache = { }
										moveNodes[nodeName] = cache
									end
									table.insert(cache, moveProp)
								end
								local circleProp = nodeProps.circle
								if circleProp then
									local cache = moveNodes[nodeName]
									if not cache then
										cache = { }
										moveNodes[nodeName] = cache
									end
									table.insert(cache, circleProp)
								end
							end
						end
					end
				end
				--
				for _, w in ipairs(root.children) do
					local prop = w.prop
					--printf( "name=%s", prop.name)
					--printf( "pos:(%d, %d)", prop.posX, prop.posY)
					--printf( "size:(%d, %d)", prop.sizeX, prop.sizeY)
					--printf( "anchor:(%d, %d)", prop.anchorX, prop.anchorY)
						
					local left = prop.posX - prop.sizeX * prop.anchorX
					local right = left + prop.sizeX
					local bottom = prop.posY - prop.sizeY * prop.anchorY
					local top = bottom + prop.sizeY
					--printf( "left=%f, right=%f, bottom=%f, top=%f\n", left, right, bottom, top)
						
					local layoutType = prop.layoutType or eLayoutStretch
					--TODO for zx
					if prop.name == "ddd" then
						layoutType = eLayoutStretch
					elseif prop.name == "ysjm" then
						layoutType = eLayoutCenterLeft
					end
					
					local rOld = prop.sizeX / prop.sizeY
					local sizeXNew = prop.sizeX
					local sizeYNew = prop.sizeY
					
					local leftNew = left
					local bottomNew = bottom
				
					if layoutType == eLayoutStretch then					
						sizeXNew = prop.sizeX * rLayout
						sizeYNew = prop.sizeY
					
						leftNew = vLeft + left * vWidth
					else	
						sizeXNew = prop.sizeX * rLayout				
						sizeYNew = sizeXNew / rOld										
					
						leftNew = vLeft + left * vWidth
					
						local lType = lTable[layoutType]
						if lType then
							if lType.v == eLayoutBottom then
								bottomNew = bottom
							elseif lType.v == eLayoutTop then
								bottomNew = bottom + ( prop.sizeY - sizeYNew)
							else --vCenter
								bottomNew = bottom + ( prop.sizeY - sizeYNew) / 2
							end
						end										
					end
					
					local xScale = sizeXNew / prop.sizeX
					local yScale = sizeYNew / prop.sizeY
					if modSizeAB then
						visitNode(w, 
							function(node)
								local nprop = node.prop
								if nprop.etype == "FrameAni" then
									nprop.sizeXAB = nprop.sizeXAB * xScale
									nprop.sizeYAB = nprop.sizeYAB * yScale
								elseif nprop.etype == "Particle" then
									if nprop.maxRadius then
										nprop.maxRadius = nprop.maxRadius * xScale
									end
									if nprop.minRadius then
										nprop.minRadius = nprop.minRadius * xScale
									end
								end
							end
						)
					end

					if modAni and aniData then
						visitNode(w, 
							function(node)
								local moveNode = moveNodes[node.prop.name]
								if moveNode then
									moveNodes[node.prop.name] = nil
									--TODO
									for _, aniProps in ipairs(moveNode) do
										for _, moveProp in ipairs(aniProps) do
											local pos = moveProp[2]
											if pos then
												pos[1] = pos[1] * xScale
												pos[2] = pos[2] * yScale
											end
										end
									end
								end
							end
						)
					end

					prop.sizeX = sizeXNew
					prop.sizeY = sizeYNew
					prop.posX = leftNew + sizeXNew * prop.anchorX
					prop.posY = bottomNew + sizeYNew * prop.anchorY
				end
			end
		end

		if rVisible > rDesign then -- TODO

			local rLayout = rDesign / rVisible
			local vHeight = rLayout
			local vBottom = (1 - vHeight) / 2

			if modFontSize then
				-- update font size of label and richtext and editbox
				local fontSizeDiff = 0
				if rVisible <= 1.34 then --TODO
					fontSizeDiff = -4
				elseif rVisible <= 1.51 then --TODO
					fontSizeDiff = -2
				elseif rVisible >= 2 then --TODO
					fontSizeDiff = -4
				end
				--
				if fontSizeDiff ~= 0 then
					visitNode(root, 
						function(node)
							local prop = node.prop
							if prop.etype == "Label" or prop.etype == "RichText" then
								prop.fontSize = (prop.fontSize or 20) + fontSizeDiff
							elseif prop.etype == "EditBox" then
								prop.fontSize = (prop.fontSize or 20) + fontSizeDiff
								--printf("update font size to %d", prop.fontSize)
								prop.phFontSize = (prop.phFontSize or 20) + fontSizeDiff
								--printf("update ph font size to %d", prop.phFontSize)
							end
						end
					)
				end
				--
			end
			--

			if modSize then
				--TODO prepare ani
				local moveNodes = { }
				if modAni and aniData then
					for aniName, aniNodes in pairs(aniData) do
						if string.sub(aniName, 1, 2) ~= "c_" then
							for nodeName, nodeProps in pairs(aniNodes) do
								local moveProp = nodeProps.move
								if moveProp then
									local cache = moveNodes[nodeName]
									if not cache then
										cache = { }
										moveNodes[nodeName] = cache
									end
									table.insert(cache, moveProp)
								end
								local circleProp = nodeProps.circle
								if circleProp then
									local cache = moveNodes[nodeName]
									if not cache then
										cache = { }
										moveNodes[nodeName] = cache
									end
									table.insert(cache, circleProp)
								end
							end
						end
					end
				end
				--
				for _, w in ipairs(root.children) do
					local prop = w.prop
					--printf( "name=%s", prop.name)
					--printf( "pos:(%d, %d)", prop.posX, prop.posY)
					--printf( "size:(%d, %d)", prop.sizeX, prop.sizeY)
					--printf( "anchor:(%d, %d)", prop.anchorX, prop.anchorY)
						
					local left = prop.posX - prop.sizeX * prop.anchorX
					local right = left + prop.sizeX
					local bottom = prop.posY - prop.sizeY * prop.anchorY
					local top = bottom + prop.sizeY
					--printf( "left=%f, right=%f, bottom=%f, top=%f\n", left, right, bottom, top)
						
					local layoutTypeW = prop.layoutTypeW or eLayoutStretch
					--TODO for zx
					if prop.name == "ddd" then
						layoutTypeW = eLayoutStretch
					elseif prop.name == "ysjm" then
						layoutTypeW = eLayoutCenterCenter
					end
					
					local rOld = prop.sizeY / prop.sizeX
					local sizeXNew = prop.sizeX
					local sizeYNew = prop.sizeY
					
					local leftNew = left
					local bottomNew = bottom
				
					if layoutTypeW == eLayoutStretch 
						or layoutTypeW == eLayoutStretchBottom 
						or layoutTypeW == eLayoutStretchLeft 
						or layoutTypeW == eLayoutStretchRight
						or layoutTypeW == eLayoutStretchTop then					
						sizeYNew = prop.sizeY * rLayout
						sizeXNew = prop.sizeX
					
						bottomNew = vBottom + bottom * vHeight
					else	
						sizeYNew = prop.sizeY * rLayout
						sizeXNew = sizeYNew / rOld										
					
						bottomNew = vBottom + bottom * vHeight
					
						local lType = lTable[layoutTypeW]
						if lType then
							if lType.h == eLayoutLeft then
								leftNew = left
							elseif lType.h == eLayoutRight then
								leftNew = left + ( prop.sizeX - sizeXNew)
							else --vCenter
								leftNew = left + ( prop.sizeX - sizeXNew) / 2
							end
						end										
					end
					
					--处理iPhone X
					if UIUtil.isIphoneX then
						local fixType = {h = layoutTypeW,v = layoutTypeW}
						local lType = lTable[layoutTypeW]
						if lType then
							if lType.h == eLayoutLeft then
								fixType.h =  eLayoutStretchLeft
							end
							if lType.h == eLayoutRight then
								fixType.h = eLayoutStretchRight
							end
							if lType.v == eLayoutBottom then
								fixType.v = eLayoutStretchBottom
							end
							if lType.v == eLayoutTop then
								fixType.v = eLayoutStretchTop
							end
						end
						
						if fixType.h == eLayoutStretchLeft then
							leftNew = leftNew + (44/visibleSize.width)
						end
						if fixType.h == eLayoutStretchRight then
							leftNew = leftNew - (44/visibleSize.width)
						end
						if fixType.v == eLayoutStretchBottom then
							bottomNew = bottomNew + (10/visibleSize.height)
						end
					end
					
					local xScale = sizeXNew / prop.sizeX
					local yScale = sizeYNew / prop.sizeY
					if modSizeAB then
						visitNode(w, 
							function(node)
								local nprop = node.prop
								if nprop.etype == "FrameAni" then
									nprop.sizeXAB = nprop.sizeXAB * xScale
									nprop.sizeYAB = nprop.sizeYAB * yScale
								elseif nprop.etype == "Particle" then
									if nprop.maxRadius then
										nprop.maxRadius = nprop.maxRadius * xScale
									end
									if nprop.minRadius then
										nprop.minRadius = nprop.minRadius * xScale
									end
								end
							end
						)
					end

					if modAni and aniData then
						visitNode(w, 
							function(node)
								local moveNode = moveNodes[node.prop.name]
								if moveNode then
									moveNodes[node.prop.name] = nil
									--TODO
									for _, aniProps in ipairs(moveNode) do
										for _, moveProp in ipairs(aniProps) do
											local pos = moveProp[2]
											if pos then
												pos[1] = pos[1] * xScale
												pos[2] = pos[2] * yScale
											end
										end
									end
								end
							end
						)
					end

					prop.sizeX = sizeXNew
					prop.sizeY = sizeYNew
					prop.posX = leftNew + sizeXNew * prop.anchorX
					prop.posY = bottomNew + sizeYNew * prop.anchorY
				end
			end
		end
	end	
end

local function createNode(fileType, root, anidata)	
	
	local bLayer = fileType ~= "node"
	if not bLayer then
		root = root.children[1]
	end

	layoutRoots(root, anidata, true, bLayer, true, bLayer)
	
	local vars = { }		
	local nodesMap = { }
	local propsMap = { }
	local nodeCreate = setNode(root, vars, nodesMap, propsMap, nil)

	--TODO ani
	if not anidata then anidata = { } end
	local anis = { }
	for aniName, aniNodes in pairs(anidata) do
		if string.sub(aniName, 1, 2) == "c_" then
			local scheduling = { }
			local playingNodeAnis = { }
			local playingParticleAnis = { }
			local playingFrameAnis = { }
			local cani = { }
				cani.quit = function()
					for sid, _ in pairs(scheduling) do
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
					end
					scheduling = { }
					playingNodeAnis = { }
					playingParticleAnis = { }
					playingFrameAnis = { }
				end
				cani.stop = function()
					--TODO stop all playing ani
					for _, e in pairs(playingNodeAnis) do
						e.stop()
					end
					for _, e in pairs(playingParticleAnis) do
						e._stop()
					end
					for _, e in pairs(playingFrameAnis) do
						if e._ani and e._sprite then
							e._sprite:setVisible(false)
							e._sprite:stopAllActions()
						end
					end
					--
					cani.quit()
				end
				cani.play = 
					function(callback)
						cani.stop()
						local funcs = { }
						local maxTime = 0
						local infinite = false
						for _, ele in ipairs(aniNodes) do
							if ele[1] == 0 then -- transform
								local ani = anis[ele[2]]
								local times = ele[3]
								local delay = ele[4]
								local sid = 0
								sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
									function()
										--print("times=" .. times .. ", delay=" .. delay)
										ani.play(times)
										cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
										scheduling[sid] = nil
									end, delay/1000, false)
								scheduling[sid] = true
								playingNodeAnis[ele[2]] = ani
								if times > 0 then
									local timeEnd = delay/1000 + times * ani.getMaxTime()
									if timeEnd > maxTime then
										maxTime = timeEnd
									end
								elseif times < 0 then
									infinite = true
								end
							elseif ele[1] == 1 then -- frame
								local node = nodesMap[ele[2]]
								if node and node._ani then
									local ani = node._ani
									local times = ele[3]
									local delay = ele[4]
									
									local sid = 0
									sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
										function()
											--print("times=" .. times .. ", delay=" .. delay)
											if ani then
												--print("ani: " .. tostring(ani) .. ", times: " .. times)
												
												local action = times < 0 and cc.RepeatForever:create(ani) or cc.Repeat:create(ani, times)
												if action then
													--print("action:" .. tostring(action))
												end
												node._sprite:setVisible(true)
												node._sprite:runAction(action)	
											end
											cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
											scheduling[sid] = nil
										end, delay/1000, false)
									scheduling[sid] = true
									playingFrameAnis[ele[2]] = node
									if times > 0 then
										local timeEnd = delay/1000 + times * node._aniTime
										if timeEnd > maxTime then
											maxTime = timeEnd
										end
									elseif times < 0 then
										infinite = true
									end
								end
							elseif ele[1] == 2 then -- particle
								local node = nodesMap[ele[2]]
								if node and node._effCreator and node._duration and node._duration > 0 then
									local times = ele[3]
									if times < 0 then times = 1 end
									local delay = ele[4]
		
									for ka = 1, times do							
										local sid = 0
										sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
											function()
												--print("times=" .. times .. ", delay=" .. delay .. ", duration=" .. node._duration)
												--如果这里再出问题，请找zhongli
												node._play()
												cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
												scheduling[sid] = nil
											end, delay/1000 + (ka-1) * node._duration, false)	
										scheduling[sid] = true
									end
									playingParticleAnis[ele[2]] = node
									if times > 0 then
										local timeEnd = delay/1000 + times * node._duration
										if timeEnd > maxTime then
											maxTime = timeEnd
										end
									end
								end
							elseif ele[1] == 3 then -- sound effects
								local sound = ele[2]
								local delay = ele[4]
								local sid = 0
								sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
									function()
										--TODO play sound file
										if i3k_game_play_sound then
											i3k_game_play_sound(sound)
										end
										cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
										scheduling[sid] = nil
									end, delay/1000, false)
								scheduling[sid] = true
							end
						end
						if not infinite and callback then
							local sid = 0
							sid = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
								function()
									callback()
									cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sid)
									scheduling[sid] = nil
								end, maxTime, false)
							scheduling[sid] = true
						end
					end
			--}
			anis[aniName] = cani
		else
			if g_i3k_ui_mgr and ( aniName == "dk" or aniName == "tc" ) then -- TODO
				for aniNodeName, aniProps in pairs(aniNodes) do
					local theNode = nodesMap[aniNodeName]
					if theNode then
						local scaleProp = aniProps.scale
						if scaleProp then
							local firstFrame = scaleProp[1]
							if firstFrame then
								if firstFrame[1] and firstFrame[1] == 0 then
									local scaleX = firstFrame[2][1]
									local scaleY = firstFrame[2][2]
									theNode:setScale(scaleX, scaleY)
								end
							end
						end
					end
				end
			end
			anis[aniName] = { 
				getMaxTime =
					function()
						local maxTime = 0
						for nodeName, props in pairs(aniNodes) do
							local node = nodesMap[nodeName]
							if node then
								for propName, frames in pairs(props) do
									local tempMax = 0
									for _, frame in ipairs(frames) do
										local ktime = frame[1]/1000
										if ktime > maxTime then
											maxTime = ktime
										end
									end
								end
							end
						end
						return maxTime
					end,
				play = 
					function(times)
						local actions = { }
						if not times or times == 1 then
							for nodeName, props in pairs(aniNodes) do
								local node = nodesMap[nodeName]
								if node then
									for propName, frames in pairs(props) do
										local action = parseAction(propName, frames)
										if action then
											table.insert(actions, { node = node, action = action })
										end
									end
								end
							end
						else
							local theLastTime = 0
							for nodeName, props in pairs(aniNodes) do
								local node = nodesMap[nodeName]
								if node then
									for propName, frames in pairs(props) do
										local action, lastTime = parseAction(propName, frames)
										if action then
											table.insert(actions, { node = node, action = action, lastTime = lastTime })
											if lastTime > theLastTime then
												theLastTime = lastTime
											end
										end
									end
								end
							end
							for _, e in ipairs(actions) do
								if e.lastTime < theLastTime then
									e.action = cc.Sequence:create(e.action, cc.DelayTime:create((theLastTime - e.lastTime)/1000))
								end
							end
						end
						if not times or times == 1 then
							for _, e in ipairs(actions) do
								e.node:runAction(e.action)
							end
						elseif times <= 0 then
							for _, e in ipairs(actions) do
								e.node:runAction(cc.RepeatForever:create(e.action))
							end
						else
							for _, e in ipairs(actions) do
								e.node:runAction(cc.Repeat:create(e.action, times))
							end
						end
					end,
					
				stop = 
					function ()
						for nodeName, props in pairs(aniNodes) do
							local node = nodesMap[nodeName]
							if node then
								node:stopAllActions()  -- TODO stop all ?
								--TODO reset all prop?
								local initProp = propsMap[nodeName]
								if initProp then
									for propName, frames in pairs(props) do
										if propName == "alpha" then
											local initAlpha = initProp.alpha or 1
											local opacity = initAlpha * 255
											if opacity > 255 then opacity = 255 end
											if opacity < 0 then opacity = 0 end
											node:setOpacity(opacity)
										end
									end
								end
							end
						end
					end,
					
				playToTime = 
					function(timeTo)
						for nodeName, props in pairs(aniNodes) do
							local node = nodesMap[nodeName]
							if node then
								for propName, frames in pairs(props) do
									parseActionToTime(propName, frames, timeTo, node)
								end
							end
						end
					end,
			}
		end
	end
	if next(anis) ~= nil then	--有动画
		--每个ccNode只能registerScriptHandler一个函数，所以不要轻易调用，防止把别的地方的函数给覆盖了
		--现在就只有layer和widget的root会在这里register
		--别的控件会在UIBase里面的enableScriptHandler里面register
		nodeCreate:registerScriptHandler(function(state)
			if state == "enter" then
            
			elseif state == "exit" then
				for i,v in pairs(anis) do
					if v.stop then
						v.stop()
					elseif v.quit then
						v.quit()
					end
				end
			elseif state == "enterTransitionFinish" then
            
			elseif state == "exitTransitionStart" then
            
			elseif state == "cleanup" then
            
			end
		end)
		if nodeCreate._scriptHandlerBy ~= nil then
			error ("nodeCreate registerScriptHandler already at UIUtil!")
		end
		nodeCreate._scriptHandlerBy = "UIUtil"
	end
	--
	local rootVar = root.prop.varName == nil and UIFactory.createUI(nodeCreate, root.prop) or vars[root.prop.varName]
	return { root = nodeCreate, rootVar = rootVar, layer = nodeCreate , vars = vars, anis = anis }
end

UIUtil.createNode = createNode

return UIUtil

