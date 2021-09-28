
local UIBase = require "ui/common/UIBase"

local UICommon = require "ui/common/UICommon"

local UIDefault = require "ui/common/DefaultValue"

local UIRichText = class("UIRichText", UIBase)

function UIRichText:ctor(ccNode, propConfig)
    UIRichText.super.ctor(self, ccNode, propConfig)
	self._text = propConfig.text
	self._color = propConfig.color or UIDefault.DefLabelRichText.color
	self._fontName = propConfig.fontName or UIDefault.DefLabelRichText.fontName
	self._fontSize = propConfig.fontSize or UIDefault.DefLabelRichText.fontSize
	self._nElement = 0
	self._textColor = propConfig.color or UIDefault.DefLabelRichText.color
	self._outlineColor = propConfig.fontOutlineColor or UIDefault.DefLabelRichText.fontOutlineColor
	self._outlineSize = propConfig.fontOutlineSize or UIDefault.DefLabelRichText.fontOutlineSize
end

local function parseToken(txt)

	local tokens = { }
	local n = string.len(txt)
	local start = 1
	while start <= n do
		local i = string.find(txt, "<", start)
		if not i then
			local e = { type = "text", text = string.sub(txt, start, n) }
			table.insert(tokens, e)
			break
		else
			if i > start then
				local e = { type = "text", text = string.sub(txt, start, i-1) }
				table.insert(tokens, e)
			end
			local j = string.find(txt, ">", i + 1)
			if not j then
				break
			end
			local e = { type = "label", text = string.sub(txt, i, j) }
			table.insert(tokens, e)
			start = j + 1
		end
	end
	--[[
	for _, e in pairs(tokens) do
		print ("token: type=" .. e.type .. ", text=" .. e.text)
	end
	]]
	return tokens
end

--TODO lannan
local l_colorTable =
{
	--以下是标准颜色码
	white   = "FFFFFFFF",
	black   = "FF000000",
	red     = "FFCA0D0D",
	green   = "FF029133",
	blue    = "FF0000FF",
	yellow  = "FFFFFF00",
	purple  = "FF86229F",
	cyan    = "FF8069D5",
	grey    = "FF909090",
	--hl代表高亮色，任务追踪栏、TIPS中使用
	hlgreen = "FF00FF00",
	hlred   = "FFFF0000",
	--q开头的，是白绿蓝紫橙5个品质的颜色码
	qwhite  = "FF707069",
	qgreen  = "FF029133",
	qblue   = "FF092DAE",
	qpurple = "FF86229F",
	qorange = "FFBB8400",
	
	diyskilltitle = 'FF911D02', -- 自创武功界面，标题文字
	diyskilldata  = 'FF1F9400', -- 自创武功界面，数值文字
}

--[[local l_colorTable =
{
	red = "FFFF0000",
	green = "FF00FF00",
	blue = "FF0000FF",
}--]]

local function parseText(txt)
	local elements = { }

	--[[
	local e = { type = "text", text = txt }
	table.insert(elements, e)
	]]
    --[[
        一个字符串有可能是这样的
        <c=red>红色字符串</c><t=1>带Tag<c=green>有Tag的绿色串</c>又只有Tag了<u>下划线</u><d>删除线</d><e=imgurl1/></t><e=imgurl2/>
    --]]
	local tokens = parseToken(txt)
	--这几个声明完全没有必要，写在这里只是给程序看用到了这些而已
	local color = nil
    local tag = nil
	local delline = nil
	local underline = nil
	---------------
	for _, t in ipairs(tokens) do
		if t.type == "text" then
			local sign = 0
			if underline == 1 then
				--下划线的标志位是0x1
				sign = sign + 1
			end
			if delline == 1 then
				--删除线的标志位是0x2
				sign = sign + 2
			end
            local e = { type = "text", text = t.text, color = color, tag = tag, sign = sign }
            table.insert(elements, e)
		elseif t.type == "label" then
            if string.len(t.text) > 4 then
                local substr = string.sub(t.text, 1, 3)
                if substr == "<c=" then
                    color = string.sub(t.text, 4, -2)
					if l_colorTable[color] then
						color = l_colorTable[color]
					elseif string.len(color) == 8 and string.sub(color, 1, 2) == "0x" then
						color = "FF" .. string.sub(color, 3, 8)
					end
                elseif substr == "<e=" then
                    local emoji = string.sub(t.text, 4, -3)
					if emoji then
						table.insert(elements, { type = "emoji", url = emoji, size = 32 })
					end
                elseif substr == "<t=" then
					tag = tonumber(string.sub(t.text, 4, -2))
                end
            else
                if t.text == "</c>" then
                    color = nil
                elseif t.text == "</t>" then
                    tag = nil
				elseif t.text == "<u>" then
					underline = 1
				elseif t.text == "</u>" then
					underline = nil
				elseif t.text == "<d>" then
					delline = 1
				elseif t.text == "</d>" then
					delline = nil
                end
            end
		end
	end

	return elements
end

function UIRichText:onRichTextClick(hoster, cb, arg)
	local function touchEvent(tag)
		if cb then
			cb(hoster, self, tag, arg);
		end
	end
	self.ccNode_:setRichTextTouchEventListener(touchEvent);
end

function UIRichText:doFormat()
	--TODO
	for k = 1, self._nElement do
		self.ccNode_:removeElement(0)
	end
	self._nElement = 0
	--

	if self._text and self._text ~= "" then
		local elements = parseText(self._text)
		for _, e in ipairs(elements) do
			if e.type == "text" then
				local text = e.text or ""
				local color = e.color or self._color
				local fontName = e.fontName or self._fontName
				local fontSize = e.fontSize or self._fontSize
				if text ~= "" then
					local t = ccui.RichElementText:create(e.tag or 0, e.sign or 0, UICommon.getColorC3BByStr(color), 255, text, fontName, fontSize)
					if t then
						self.ccNode_:pushBackElement(t)
						self._nElement = self._nElement + 1
					end
				end
			elseif e.type == "emoji" then
				if e.url then
					--print("emoji: ", e.url)
					local img, imgt = i3k_checkPList(e.url)
					if img and img ~= "" then
						local t = ccui.RichElementImage:create(e.tag or 0, UICommon.getColorC3BByStr("FFFFFFFF"), 255, img, imgt)
						if t then
							self.ccNode_:pushBackElement(t)
							self._nElement = self._nElement + 1
						end
					end
				end
			end
		end
	end
end

--取出 {0, 0} 时忽略
function UIRichText:getInnerSize()
	return self.ccNode_:getInnerSize()
end

function UIRichText:setText(txt)
	self._text = txt
	self:doFormat()
	return self
end

function UIRichText:getText()
	return self._text
end

function UIRichText:setTextColor(color)
	self._color = color
	self:doFormat()
	return self
end

function UIRichText:getTextColor()
	return self._color
end

function UIRichText:stateToNormal(textColor, outLineColor, outLineSize)--toNormal方法一般不用传参数，除非有特殊需求
	if not textColor then
		if self._textColor then
			self:setTextColor(self._textColor)
		end
	else
		self._textColor = textColor
		self:setTextColor(textColor)
		
		if not outLineColor then
			if self._outlineColor then
				self:enableOutline(self._outlineColor)
			end
		else
			self._outlineColor = outLineColor
			local size = outLineSize or self._outlineSize
			self:enableOutline(outLineColor, size)
		end
	end
end

function UIRichText:stateToPressed(textColor, outLineColor, outLineSize)
	if textColor then
		self:setTextColor(textColor)
		if outLineColor then
			if outLineSize then
				self:enableOutline(outLineColor, outLineSize)
			else
				self:enableOutline(outLineColor)
			end
		end
	else
		
	end
end

function UIRichText:enableOutline(color, size)
	if color and size then
		self.ccNode_:enableOutline(UICommon.getColorC4BByStr(color), size)
	elseif color and not size then
		self.ccNode_:enableOutline(UICommon.getColorC4BByStr(color), self._outlineSize)
	else
		
	end
end

function UIRichText:setRichTextFormatedEventListener(cb)
	self.ccNode_:setRichTextFormatedEventListener(cb)
end
return UIRichText
