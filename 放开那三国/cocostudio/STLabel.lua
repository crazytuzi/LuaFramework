-- Filename: STLabel.lua
-- Author: bzx
-- Date: 2015-04-25
-- Purpose: 文本

require "script/libs/LuaCCLabel"

STLabel = class("STLabel", function ()
	return STNode:create()
end)

STLabel._label = nil
STLabel._richInfo = nil
STLabel._renderType = nil
STLabel._horizontalAlignment = kCCTextAlignmentCenter
STLabel._fontName = nil
STLabel._fontSize = nil
STLabel._renderColor = nil
STLabel._color = nil
STLabel._text =  nil
STLabel._labelType = STLabelType.CCLABELTTF

function STLabel:create(text,  fontName, fontSize, renderSize, renderColor, renderType)
	text = text or ""
	fontName = fontName or g_sFontName
	fontSize = fontSize or 20
	local ret = STLabel.new()
	ret._fontName = fontName
	ret._fontSize = fontSize
	ret._renderType = renderType
	ret._text = text
	ret._renderColor = renderColor
	ret._color = ccc3(0xff, 0xff, 0xff)
	local label = nil
	if renderSize == nil then
		label = CCLabelTTF:create(text, fontName, fontSize)
		ret._labelType = STLabelType.CCLABELTTF
	else
		label = CCRenderLabel:create(text, fontName, fontSize, renderSize, renderColor, renderType)
		ret._labelType = STLabelType.CCRENDERLABEL
	end
	ret:setSubnode(label)
	-- for k, v in pairs(getmetatable(label)) do
	-- 	if not self[k] then
	-- 		self[k] = function ( ... )
	-- 			label[k](label, ...)
	-- 		end
	-- 	end
	-- end
	
	return ret
end

function STLabel:toNormal( ... )
	local label = CCLabelTTF:create(self._text, self._fontName, self._fontSize)
	label:setColor(self._color)
	self._labelType = STLabelType.CCLABELTTF
	self:setSubnode(label)
end

function STLabel:setRichInfo(richInfo)
	self._richInfo = richInfo
	self:refresh()
end

function STLabel:getRenderColor( ... )
	return self._renderColor
end

function STLabel:getRichInfo( ... )
	local richInfo = self._richInfo
	if richInfo == nil then
		richInfo = {
			alignment = self:getHorizontalAlignment() + 1,
			lineAlignment = 2,
			labelDefaultSize = self:getFontSize(),
			labelDefaultFont = self:getFontName(),
			labelDefaultColor = self:getColor(),
			defaultType = self:getLabelType(),
			defaultRenderType = self:getRenderType(),
			defaultStrokeSize = 1,
			defaultStrokeColor = self:getRenderColor(),
			elements = {
				{
					text = self:getString()
				}
			}
		}
	end
	return richInfo
end

function STLabel:setHorizontalAlignment( horizontalAlignment )
	self._horizontalAlignment = horizontalAlignment
	if self._subnode.setHorizontalAlignment ~= nil then
		self._subnode:setHorizontalAlignment(horizontalAlignment)
	end
end

function STLabel:getHorizontalAlignment( ... )
	return self._horizontalAlignment
end

function STLabel:getFontName( ... )
	return self._fontName
end

function STLabel:getColor( ... )
	return self._color
end

function STLabel:setColor( color )
	self._color = color
	self._subnode:setColor(color)
end

function STLabel:getFontSize( ... )
	return self._fontSize
end

function STLabel:getLabelType( ... )
	return self._labelType
end

function STLabel:refresh( ... )
	if self._richInfo == nil then
		return
	end
	local subnode = LuaCCLabel.createRichLabel(self._richInfo)
	self:setSubnode(subnode)
end

function STLabel:setString( text )
	self._text = text
	if self._richInfo ~= nil then
		self._richInfo.elements = {}
		self._richInfo.elements[1] = {} 
		self._richInfo.elements[1].text = text
		self:refresh()
	else
		self._subnode:setString(text)
	end
end

function STLabel:getString(  )
	return self._text
end

function STLabel:getRenderType( ... )
	return self._renderType
end

function STLabel:setDimensions(dim)
	if self._renderType ~= nil then
		local richInfo = {
			width = dim.width,
			alignment = self:getHorizontalAlignment() + 1,
			labelDefaultFont = self:getFontName(),
			labelDefaultColor = self:getColor(),
			labelDefaultSize = self:getFontSize(),
			defaultType = self:getLabelType(),
			defaultRenderType = self:getRenderType(),
			defaultStrokeSize = 1,
			defaultStrokeColor = ccc3(0x0, 0x0, 0x0),
			elements = {
				{
					text = self:getString()
				}
			}
		}
		self:setRichInfo(richInfo)
	else
		self._subnode:setDimensions(dim)
	end
end

function STLabel:setFontName( fontName )
	self._subnode:setFontName(fontName)
end

function STLabel:setFontSize( fontSize )
	self._fontSize = fontSize
	self._subnode:setFontSize(fontSize)
end

function STLabel:setColor(color)
	self._color = color
	if color.a == nil then
		self._subnode:setColor(color)
	else
		local newColor = ccc3(color.r, color.g, color4.b)
		local opacity = color.a
		self._subnode:setColor(newColor)
		self._subnode:setOpacity(opacity) 
	end
end

function STLabel:getColor( ... )
	return self._color
end


function STLabel:setNodeOpacity( opacity )
	self._label:setOpacity(opacity)
end