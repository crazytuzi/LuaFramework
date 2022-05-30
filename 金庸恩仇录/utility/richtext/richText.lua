require("utility.richtext.globalFunction")
local nodeType = {
startTag = 0,
text = 1,
endTag = 2
}
local signTable = {
["#8260;"] = "/"
}
local function parseHtml(htmlText)
	local nodeList = {}
	local char, charByte
	local isParseTaging = true
	node = {
	type = nodeType.text,
	text = nil
	}
	local l = string.len(htmlText)
	for i = 1, l do
		char = string.sub(htmlText, i, i)
		charByte = string.byte(char)
		if charByte == 60 then
			isParseTaging = true
			if node.type and node.text ~= nil then
				nodeList[#nodeList + 1] = node
				node = {}
			end
			if string.byte(string.sub(htmlText, i + 1, i + 1)) == 47 then
				node = {
				type = nodeType.endTag,
				text = ""
				}
			else
				node = {
				type = nodeType.startTag,
				text = ""
				}
			end
		elseif charByte == 62 then
			isParseTaging = false
			if node.type then
				nodeList[#nodeList + 1] = node
				node = {}
			end
		elseif charByte ~= 47 then
			if not node.type or not node.text then
				node.type = nodeType.text
				node.text = ""
			end
			node.text = node.text .. char
		end
		if i == l and node.type == nodeType.text then
			nodeList[#nodeList + 1] = node
		end
	end
	for i, v in ipairs(nodeList) do
		if v.type == nodeType.startTag then
			local ary = string.split(v.text, " ")
			v.tag = ary[1]
			v.props = {}
			for i = 2, #ary do
				v.props[#v.props + 1] = string.split(ary[i], "=")
			end
			v.text = nil
		elseif v.type == nodeType.endTag then
			v.tag = string.split(v.text, " ")[1]
			v.text = nil
		end
		if v.text ~= nil then
			for code, content in pairs(signTable) do
				v.text = v.text:gsub(code, content)
			end
		end
	end
	return nodeList
end
function getRichText(htmlText, lineWidth, hrefHandler, spaceHeight, ALIGN, ignoreWidth)
	function createLabel(props, node, x, y, a)
		local label = ui.newTTFLabel(props):addTo(node):pos(x, y)
		label:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
		if a.href then
			label._href = a.href
			local str = "_"
			props.text = str
			local t = ui.newTTFLabel(props)
			for i = 1, checkint(label:getContentSize().width / t:getContentSize().width) - 1 do
				str = str .. "_"
			end
			t:setString(str)
			t:pos(x, y):addTo(node)
			t:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_BOTTOM])
			label:setTouchEnabled(true)
			label:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					return true
				elseif event.name == "ended" and type(hrefHandler) == "function" then
					hrefHandler(label._href)
				end
			end)
		end
		return label
	end
	spaceHeight = spaceHeight or 0
	lineWidth = lineWidth or 400
	local node = display.newNode()
	node.offset = 0
	local nodeList = parseHtml(htmlText)
	local fontProps = {
	x = 0,
	y = 0,
	size = ui.DEFAULT_TTF_FONT_SIZE,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	}
	local a = {}
	local label
	local leftWidth, leftStr, lineHeight = lineWidth, nil, 0
	local x, y = 0, 0
	local curLine = 1
	local labelList = {}
	local totalHeight = lineHeight
	for i, v in ipairs(nodeList) do
		if v.type == nodeType.startTag then
			local props = v.props
			if v.tag == "font" then
				fontProps.size = ui.DEFAULT_TTF_FONT_SIZE
				fontProps.font = FONTS_NAME.font_fzcy
				fontProps.color = display.COLOR_WHITE
				for ii, vv in ipairs(props) do
					if vv[1] == "size" then
						fontProps.size = checkint(string.gsub(vv[2], "\"", ""))
					elseif vv[1] == "color" then
						local colorStr = string.sub(vv[2], 3)
						fontProps.color = cc.c3b(checkint(string.format("%d", "0x" .. string.sub(colorStr, 1, 2))), checkint(string.format("%d", "0x" .. string.sub(colorStr, 3, 4))), checkint(string.format("%d", "0x" .. string.sub(colorStr, 5, 6))))
					end
				end
			elseif v.tag == "a" then
				for ii, vv in ipairs(props) do
					if vv[1] == "href" then
						a.href = vv[2]
					end
				end
			elseif v.tag == "u" then
			elseif v.tag == "p" then
				x = 0
				y = y - lineHeight - spaceHeight
				leftWidth = lineWidth
				curLine = curLine + 1
				totalHeight = totalHeight + lineHeight + spaceHeight
			end
		elseif v.type == nodeType.endTag then
			fontProps.color = display.COLOR_WHITE
			fontProps.size = ui.DEFAULT_TTF_FONT_SIZE
			fontProps.font = FONTS_NAME.font_fzcy
			fontProps.color = display.COLOR_WHITE
			if v.tag == "a" then
				a.href = nil
			elseif v.tag == "br" then
				x = 0
				y = y - lineHeight - spaceHeight
				leftWidth = lineWidth
				curLine = curLine + 1
				totalHeight = totalHeight + lineHeight + spaceHeight
			end
		else
			fontProps.text, leftStr, lineHeight = getSubStrByWidth(v.text, fontProps.font, fontProps.size, leftWidth)
			if curLine == 1 and node.offset == 0 then
				node.offset = lineHeight
			end
			if fontProps.text then
				label = createLabel(fontProps, node, x, y, a)
				label._line = curLine
				labelList[#labelList + 1] = label
			end
			y = y - lineHeight - spaceHeight
			curLine = curLine + 1
			leftWidth = leftWidth - label:getContentSize().width
			if totalHeight == 0 then
				totalHeight = lineHeight + spaceHeight
			end
			while leftStr and leftStr ~= "" do
				x = 0
				fontProps.text, leftStr, lineHeight = getSubStrByWidth(leftStr, fontProps.font, fontProps.size, lineWidth)
				if fontProps.text then
					label = createLabel(fontProps, node, x, y, a)
					label._line = curLine
					labelList[#labelList + 1] = label
				end
				y = y - lineHeight - spaceHeight
				curLine = curLine + 1
				totalHeight = totalHeight + lineHeight + spaceHeight
			end
			local totalWidth = 0
			for i, v in ipairs(labelList) do
				if v._line == curLine - 1 then
					totalWidth = totalWidth + v:getContentSize().width
				end
			end
			leftWidth = lineWidth - totalWidth
			if leftWidth < fontProps.size then
				leftWidth = lineWidth
			end
			if lineWidth > leftWidth then
				x = x + label:getContentSize().width
				y = y + lineHeight + spaceHeight
				curLine = curLine - 1
			else
				x = 0
				totalHeight = totalHeight + lineHeight + spaceHeight
			end
		end
	end
	if (ignoreWidth == nil or ignoreWidth == false) and curLine == 1 then
		local tmepWidth = 0
		for i, v in ipairs(labelList) do
			tmepWidth = tmepWidth + v:getContentSize().width
		end
		lineWidth = tmepWidth
	end
	if x == 0 then
		totalHeight = totalHeight - lineHeight - spaceHeight
	end
	totalHeight = totalHeight - spaceHeight
	node:setContentSize(cc.size(lineWidth, totalHeight))
	if ALIGN and ALIGN == ui.TEXT_ALIGN_CENTER then
		local tempWidth = 0
		local index = 1
		local tempTable = {}
		for i, v in ipairs(labelList) do
			if tempTable[v._line] == nil then
				tempTable[v._line] = {}
			end
			table.insert(tempTable[v._line], v)
		end
		for k, v in pairs(tempTable) do
			alignNodesOneByAllCenterX(node, v, 5)
		end
	end
	return node
end
