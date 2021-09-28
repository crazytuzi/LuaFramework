local RichText = class("RichText", function() return cc.Node:create() end)
require("src/utf8")

local imagePath = "res/chat/face/"

function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
	self.fontSize = fontSize
	self.fontColor = fontColor
	self.lineHeight = lineHeight
	self.x = 0
	self.y = -self.lineHeight
	self.width = size.width
	self.maxWidth = 0
	self.height = size.height
	self.contentHeight = self.lineHeight
	self.data = {}
	self.dataLine = {}
	self.anchor = anchor
	self.pos = pos
	self.isIgnoreHeight = isIgnoreHeight
	self.isAutoWidth = false



	self.baseNode = cc.Node:create()
	self.baseNode:setCascadeOpacityEnabled(true)
	self:addChild(self.baseNode)
	pos = pos or cc.p(0, 0)
	anchor = anchor or cc.p(0, 0)

	self:setContentSize(size)
	self:setAnchorPoint(anchor)
	self:setPosition(pos)
	if tag then
		self:setTag(tag)
	end

	if zOrder then
		self:setLocalZOrder(zOrder)
	end
    
    self.baseLableNode = LoginUtils.createBatchRootNode(self.baseNode,fontSize)
	self.baseLableNode:setCascadeOpacityEnabled(true)
	if parent then
		parent:addChild(self)
	end
end

function RichText:setFont(fontSize, fontColor, outline, outcolor)
	local lab_ttf = {}
	lab_ttf.fontFilePath = g_font_path
	if fontSize then
		self.fontSize = fontSize
	end
	lab_ttf.fontSize = self.fontSize
	if fontColor then
		self.fontColor = fontColor
	end
	if outline then
		lab_ttf.outlineSize = outline
	end
	if self.baseLableNode then
		self.baseLableNode:setTTFConfig(lab_ttf)
		if outcolor then self.baseLableNode:setEffectColor(outcolor) end
	end
end

function RichText:addText(str, defaultFontColor, isOutLine)
	--dump(str)
	if str == nil then
		return
	end

	local imageTab = require("src/config/MsgImage")

	local fontName = fontName or g_font_path
	defaultFontColor = defaultFontColor or self.fontColor

	if isOutLine == nil then
		isOutLine = false
	end

	local flag = "%^"
	local flagText = "^c"
	local flagImage = "^i"
	local flagNode = "^d"
	local flagLink = "^l"
	local flagAdress = "^a"
	local flagUrl = "^u"
	local flagParamBegin = "%("
	local flagParamEnd = "%)"
	local strFound
	local strLeft = str
	local strAdd
	local param
	local strBegin,strEnd
	local tag = 1
	local strflag
	local fontColor

	local addTextItem = function(str,fontColor)
		self:addTextItem(str, fontColor, isOutLine, isUnbreak, isHyperlink, callback)
	end

	local addImageItem = function(id)
		self:addImageItem(id)
	end

	local addLinkItem = function(linkInfoStr)
		self:addLinkItem(linkInfoStr)
	end

	local addAdressItem = function(adressInfoStr)
		self:addAdressItem(adressInfoStr)
	end

	while true do
		strBegin = string.find(strLeft, flag)
		if strBegin == nil then
			addTextItem(strLeft, defaultFontColor)
			break
		else
			--log("strBegin:"..strBegin)
			if strBegin > 1 then
				strAdd = string.sub(strLeft, 1, strBegin-1)
				--log("strAdd:"..strAdd)
				addTextItem(strAdd, defaultFontColor)
			end
			strEnd = string.find(strLeft, flag, strBegin+1)
			if strEnd then
				--log("strEnd:"..strEnd)
				strFound = string.sub(strLeft, strBegin, strEnd)
				--log("strFound:"..strFound)
				strFlag = string.sub(strFound, 1, 2)
				--log("strFlag:"..strFlag)
				if strFlag then
					local paramBegin
					local paramEnd
					if strFlag == flagText or strFlag == flagImage or strFlag == flagNode or strFlag == flagLink or strFlag == flagAdress or strFlag == flagUrl then
						paramBegin = string.find(strFound, flagParamBegin)
						--log("paramBegin:"..paramBegin)
						paramEnd = string.find(strFound, flagParamEnd)
						--log("paramEnd:"..paramEnd)
						if paramBegin and paramEnd then
							param = string.sub(strFound, paramBegin+1, paramEnd-1)
							--log("param:"..param)
							if strFlag == flagText or strFlag == flagUrl then
								if MColor[param] then
									--log("MColor.param")
									if isIgnoreFlags then
										fontColor = defaultFontColor
									else
										fontColor = MColor[param]
									end
								else
									--log("defaultFontColor")
									fontColor = defaultFontColor
								end
								strAdd = string.sub(strFound, paramEnd+1, -2)
								--print("strAdd:", strAdd)

								if strFlag == flagText then
									addTextItem(strAdd, fontColor)
								else
									self:addUrlItem(strAdd, fontColor)
								end
							elseif strFlag == flagImage then
								local imageId = param
								addImageItem(imageId)
							elseif strFlag == flagLink then
								--log("link ~~~~~~~~~~~~~~~~~")
								local linkInfoStr = param
								addLinkItem(linkInfoStr)
							elseif strFlag == flagAdress then
								log("adress ~~~~~~~~~~~~~~~~~")
								local adressInfoStr = param
								addAdressItem(adressInfoStr)
							end
						end
					else
						break
					end
				else
					break
				end
				strLeft = string.sub(strLeft, strEnd+1, -1)
				--log("strLeft:"..strLeft)
			else
				break
			end
		end
	end
	--log("createRichTextItem analyse end")
	--dump(self.data)
end
--isOutLine没有被使用,可参照 src/login/LoginUtils.lua:  function createBatchLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
function RichText:addTextItem(str, fontColor, isOutLine, isUnbreak, isHyperlink, callback, underLineColor)
	local strTab = string.split(str, "\n")
	--dump(strTab)

	for i,v in pairs(strTab) do
		table.insert(self.data, {item="text", str=v, color=fontColor, isOutLine=isOutLine, isUnbreak=isUnbreak, isHyperlink=isHyperlink, callback=callback, underLineColor = underLineColor})
		if i ~= #strTab then
			table.insert(self.data, {item="text", str="\n"})
		end
	end
	--table.insert(self.data, {str=str, color=fontColor, isOutLine=isOutLine, isUnbreak=isUnbreak, isHyperlink=isHyperlink, callback=callback})
end

function RichText:addImageItem(id)
	table.insert(self.data, {item="image", str=" ", id=id})
end

function RichText:addNodeItem(node, isAutoScale)
	table.insert(self.data, {item="node", node=node, isAutoScale=isAutoScale})
end

function RichText:addLinkItem(linkInfoStr)
	--dump(linkInfoStr)
	local parseData = self:parseLink(linkInfoStr)
	--dump(parseData)
	if parseData then
		local propOp = require("src/config/propOp")
		local tNameColor = {
			[0] = MColor.red,
			[1] = MColor.white,
			[2] = MColor.green,
			[3] = MColor.blue,
			[4] = MColor.purple,
			[5] = MColor.orange,
		}

		local func = function()
			if self.checkFunc then
				if self.checkFunc() == false then
					return
				end
			end

			if parseData.isSpecial == "false" then
				local Mtips = require "src/layers/bag/tips"
				Mtips.new(
				{ 
					protoId = tonumber(parseData.protoId),
					--grid = gird,
					pos = cc.p(0, 0),
					--actions = actions,
				})
			else
                if G_ROLE_MAIN and G_ROLE_MAIN.obj_id then
					--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_CLICKANCHOR, "iiisci", G_ROLE_MAIN.obj_id, tonumber(parseData.ownerId), tonumber(parseData.protoId), tonumber(parseData.posIndex), tonumber(parseData.bagId), tonumber(parseData.time))
					local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
                    if tonumber(parseData.protoId) == wsysCommFunc.qingJianId then
                        -- special logic for qingjian
                        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_INVITATION_INFO, "MarriageCSWeddingInvitationInfo", {roleID=parseData.ownerId} )
                        print("MarriageCSWeddingInvitationInfo send ........................................................")
					else
					    local t = {}
					    t.targetRoleSID = parseData.ownerId
					    t.itemID = parseData.protoId
					    t.slot = parseData.posIndex
					    t.bagIndex = parseData.bagId
					    t.timeTick = parseData.time
					    dump(t)
					    g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CLICKANCHOR, "ClickAnchorProtocol", t)
                    end
				end
			end
		end
		self:addTextItem("【"..parseData.name.."】", tNameColor[tonumber(parseData.qualityId)], true, true, true, func)
	end
end

function RichText:addCheckFunc(func)
	self.checkFunc = func
end

function RichText:addAdressItem(adressInfoStr)
	local infoTab = string.split(adressInfoStr, ",")
	dump(infoTab)

	if infoTab[1] then
		infoTab[1] = tonumber(infoTab[1])
	end

	if infoTab[1] and infoTab[2] and infoTab[3] and infoTab[4] then
		local mapName = getConfigItemByKey("MapInfo", "q_map_id", infoTab[1], "q_map_name")
		if mapName then
			local temp_line = tonumber(infoTab[2])
			local qu =  math.floor(temp_line/10000)
			if qu >= 1 and qu<=3 then
				 mapName = require("src/layers/buff/ChangeLineLayer"):getMapName(qu)
			end
			infoTab[2] = temp_line%100
			local str = string.format(game.getStrByKey("my_map_pos"), mapName, infoTab[2], infoTab[3], infoTab[4])
			infoTab[3] = tonumber(infoTab[3])
			infoTab[4] = tonumber(infoTab[4])
			local func = function()
				local detailMapNode = require("src/layers/map/DetailMapNode")
      			detailMapNode:goToMapPos(infoTab[1], cc.p(infoTab[3], infoTab[4]), false)
			end
			self:addTextItem(str, MColor.green, true, false, true, func)
		end
	end
end

function RichText:addUrlItem(str, fontColor)
	local infoTab = string.split(str, "|")
	if #infoTab ~= 2 then
		print(str)
		return
	end

	local func = function()
		sdkOpenUrl(infoTab[2])
	end

	self:addTextItem(infoTab[1], fontColor, false, false, true, func)
end

function RichText:parseLink(text)
	log(tostring(text))
	
	local isLink = false
	local ret={}
    local qualityId,name,isSpecial,protoId,posIndex,bagId,ownerId,time
    --cclog(tostring(string.sub(text,1,2)))
      
	qualityId = tostring(string.sub(text,1,1))
	      
	local subStr = string.sub(text,3,-1)         
	local splitSymbol = string.find(subStr,"~")
	if splitSymbol == nil then
		return
	end

	name = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	splitSymbol = string.find(subStr,"~")
	isSpecial = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	splitSymbol = string.find(subStr,"~")
	protoId = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	splitSymbol = string.find(subStr,"~")
	posIndex = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	splitSymbol = string.find(subStr,"~")
	ownerId = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	splitSymbol = string.find(subStr,"~")
	time = string.sub(subStr,1,splitSymbol-1)

	subStr = string.sub(subStr,splitSymbol+1,-1)
	--dump(subStr)
	bagId = string.sub(subStr,1,1)
	--cclog("^^^^*&"..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(posIndex).."~"..ownerId.."~"..bagId.."*&")
	if name and qualityId and protoId and posIndex and ownerId and bagId then
		isLink = true
	end 
    
    ret.isLink = isLink
    ret.qualityId = qualityId
    ret.name = name
    ret.isSpecial = isSpecial
    ret.protoId = protoId
    ret.posIndex = posIndex
    ret.ownerId = ownerId
    ret.bagId = bagId
    ret.time = time

    if isLink then
    	return ret
    else
    	return nil
    end
end

function RichText:format()
	--dump(self.data)
	self.lineCount = 1 

	local getTempLableWidth = function(parent, str, pos, anchor, fontSize)
		local label = LoginUtils.createLabel(parent,str,pos, anchor, fontSize)
		--local label = cc.Label:createWithSystemFont(str, g_font_path, fontSize)
		local width = label:getContentSize().width
		return width
	end

	local addCallBack = function (node, func)
		--print("registerInsideFunc")
		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:registerScriptHandler(function(touch, event) 
												return true 
	    								end, cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
		    local pt = node:getParent():convertTouchToNodeSpace(touch)
	    	--dump(pt)
	    	--dump(node:getBoundingBox())
			if cc.rectContainsPoint(node:getBoundingBox(), pt) and self:isVisible() and node:isVisible() then
				if self.checkFunc then
					if self.checkFunc() == false then
						return
					end
				end
				--print("test 2")
				func()
			end	
		end, cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = node:getParent():getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node:getParent())
	end

	local subStringByWidth = function(str, width)
		--log("str = "..str)
		--log("width = "..width)
		local strTab = {}
		local strLeft = str
		local tempNode = nil
		local index = 1
		local length = string.utf8len(strLeft)

		local index = math.floor(width / (self.fontSize))
		--log("index = "..index)
		local tempStr = string.utf8sub(strLeft, 1, index)
		--log("tempStr = "..tempStr)
		local tempLabel_width = getTempLableWidth(tempNode, tempStr, cc.p(0, 0), cc.p(0, 0), self.fontSize)
		--dump(tempLabel:getContentSize().width)

		if tempLabel_width > width then 
			for i=index,1,-1 do
				local strTest = string.utf8sub(strLeft,1,i)
				--log("strTest = "..strTest)
				local labelTest_width = getTempLableWidth(tempNode, strTest, cc.p(0, 0), cc.p(0, 0), self.fontSize)
				if labelTest_width <= width then
					--log("labelTest:getContentSize().width = "..labelTest:getContentSize().width)
					index = i
					break
				end
			end
		else
			for i=index,length do
				local strTest = string.utf8sub(strLeft,1,i)
				--log("strTest = "..strTest)
				local labelTest_width = getTempLableWidth(tempNode, strTest, cc.p(0, 0), cc.p(0, 0), self.fontSize)
				if labelTest_width > width then
					--log("labelTest:getContentSize().width = "..labelTest:getContentSize().width)
					index = i - 1
					break
				end
			end
		end

		--log("index = "..index)
		strL = string.utf8sub(strLeft, 1, index)
		strR = string.utf8sub(strLeft, index + 1)
		--log("strL = "..strL)
		--log("strR = "..strR)
		table.insert(strTab, strL) 
		strLeft = strR
		--log("strLeft = "..strLeft)

		table.insert(strTab, strLeft) 
		--dump(strTab)
		return strTab
	end

	local index = 1
	while index <= #self.data do
		local record = self.data[index]
		--log("test index = "..tostring(index))
		--处理文字
		if record.item == "text" then
			if record.str == "\n" then
				if self:addNewLine(false) == false then
					return
				end
			else
				local label = LoginUtils.createBatchLabel(self.baseLableNode, record.str, cc.p(0, 0), cc.p(0, 0), self.fontSize, record.isOutLine, nil, nil, record.color)
				if label then
					local widthLeft = self.width - self.x
					if	widthLeft <= 0 then
						if self:addNewLine() == false then
							if label then
								removeFromParent(label)
								label = nil
							end
							return
						end
						widthLeft = self.width
					end

					if label:getContentSize().width > widthLeft then
						--log("space not enough")
						if record.isUnbreak then
							--log("isUnbreak")
							if self:addNewLine(false) == false then
								if label then
									removeFromParent(label)
									label = nil
								end
								return
							end
							label:setPosition(cc.p(self.x, self.y))
							self.x = self.x + label:getContentSize().width
						else
							--log("not isUnbreak"..widthLeft)
							local strTab = subStringByWidth(record.str, widthLeft)
							--local strTab = {}
							local deleteRecord = record
							table.remove(self.data, index)
							local inertIndex = index
							for i,v in pairs(strTab) do
								if i == 1 then
									label:setString(v)
									label:setPosition(cc.p(self.x, self.y))
									if self:addNewLine() == false then
										return
									end
								else
									local newRecord = {item="text", str=v, color=deleteRecord.color, isOutLine=deleteRecord.isOutLine, isUnbreak=deleteRecord.isUnbreak}
									table.insert(self.data, inertIndex, newRecord)
									inertIndex = inertIndex + 1
								end
							end
							index = index - 1
							--dump(self.data)
						end
					else
						--log("space enough")
						label:setPosition(cc.p(self.x, self.y))
						self.x = self.x + label:getContentSize().width
					end

					if record.isHyperlink and record.callback then
						addCallBack(label, record.callback)
                        
                        if record.underLineColor then
                            local underLine = drawUnderLine(label, record.underLineColor)
                        end
					end
				end
			end
		--处理表情
		elseif record.item == "image" then
			local imageSpr = LoginUtils.createSprite(self.baseNode, imagePath..record.id..".png", cc.p(0, 0), cc.p(0, 0))
			if not imageSpr then return end
			local imageSize = imageSpr:getContentSize()
			local scale = 1
			--dump(imageSize)

			if imageSize.width > self.fontSize then
				scale = (self.fontSize / imageSize.width) * 1.4
				imageSpr:setScale(scale)
			end

			local widthLeft = self.width - self.x
			if	widthLeft <= 0 then
				if self:addNewLine() == false then
					if imageSpr then
						removeFromParent(imageSpr)
						imageSpr = nil
					end
					return
				end
				widthLeft = self.width
			end

			if imageSpr:getContentSize().width > widthLeft then
				if self:addNewLine() == false then
					if imageSpr then
						removeFromParent(imageSpr)
						imageSpr = nil
					end
					return
				end
				imageSpr:setPosition(cc.p(self.x, self.y))
				self.x = self.x + imageSpr:getContentSize().width * scale
				--dump(imageSpr:getContentSize().width)
			else
				imageSpr:setPosition(cc.p(self.x, self.y))
				self.x = self.x + imageSpr:getContentSize().width * scale
				--dump(imageSpr:getContentSize().width)
			end
		--处理node
		elseif record.item == "node" then
			local node = record.node
			self.baseNode:addChild(node)
			node:setPosition(cc.p(0, 0))
			node:setAnchorPoint(cc.p(0, 0))
			local nodeSize = node:getContentSize()
			local scale = 1

			if isAutoScale then
				scale = self.fontSize / nodeSize.height
				node:setScale(scale)
			end

			local widthLeft = self.width - self.x
			if	widthLeft <= 0 then
				if self:addNewLine() == false then
					if node then
						removeFromParent(node)
						node = nil
					end
					return
				end
				widthLeft = self.width
			end

			if node:getContentSize().width > widthLeft then
				if self:addNewLine() == false then
					if node then
						removeFromParent(node)
						node = nil
					end
					return
				end
				node:setPosition(cc.p(self.x, self.y))
				self.x = self.x + node:getContentSize().width * scale
			else
				node:setPosition(cc.p(self.x, self.y))
				self.x = self.x + node:getContentSize().width * scale
			end
		end
		index = index + 1
	end
	self:setContentSize(cc.size(self.width, self.contentHeight))

	if self.isAutoWidth then
		if self.lineCount == 1 then
			self:setContentSize(cc.size(self.x, self.contentHeight))
		else
			if self.maxWidth > self.x then
				self:setContentSize(cc.size(self.maxWidth, self.contentHeight))
			else
				self:setContentSize(cc.size(self.x, self.contentHeight))
			end
		end
	end
	
	self:setAnchorPoint(self.anchor)
	self:setPosition(self.pos)
	self.baseNode:setPosition(0, self.contentHeight)

	--createScale9Sprite(self, "res/common/scalable/selected.png", cc.p(0, 0), self:getContentSize(), cc.p(0, 0))
	--createScale9Sprite(self.baseNode, "res/common/scalable/selected.png", cc.p(0, 0), self:getContentSize(), cc.p(0, 0))
end

function RichText:addNewLine(isFull)
	self.lineCount = self.lineCount + 1
	if isFull == false then
		if self.x > self.maxWidth then
			self.maxWidth = self.x
		end
	else
		self.maxWidth = self.width
	end

	self.x = 0
	self.y = self.y - self.lineHeight
	self.contentHeight = self.contentHeight + self.lineHeight

	if self.isIgnoreHeight == false then
		if self.contentHeight > self.height then
			self.contentHeight = self.contentHeight - self.lineHeight

			self:setAnchorPoint(self.anchor)
			self:setPosition(self.pos)
			self.baseNode:setPosition(0, self.contentHeight)
			return false
		end
	end

	return true
end

function RichText:getNowContentPos()
	return cc.p(self.x, self.y)
end

function RichText:setAutoWidth()
    --作用是自动把宽度缩小为恰好能够装下文字的程度，是用来自动缩小contengSize的
	self.isAutoWidth = true
end

return RichText