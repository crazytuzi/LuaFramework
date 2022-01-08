local TFUIBase 					= TFUIBase
local TFUIBase_setFuncs 		= TFUIBase_setFuncs
local TFUIBase_setFuncs_new 	= TFUIBase_setFuncs_new
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local ccp 						= ccp
local bit_and 					= bit_and
local bit_rshift				= bit_rshift
local CCSizeMake 				= CCSizeMake
local CCRectMake 				= CCRectMake
local string 					= string

function TFUIBase:initMELabel(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMELabel_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMELabel_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMELabel_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMELabel_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMELabel_MEEDITOR(pval, parent)
	local val = pval

	if val['touchScaleEnable'] and self.setTouchScaleChangeAble then 
		local bIsTouchScaleEnable = val['touchScaleEnable'] == "True"
		self:setTouchScaleChangeEnabled(bIsTouchScaleEnable)
	end	
	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	if val['fontName'] and self.setFontName then 
		self:setFontName(val['fontName'])
	end
	if val['text'] and val['text'] ~= '' and self.setText then 
		self:setText(val['text'])
	end
	--[[

		fontStroke = {
				IsStroke = true,
				StrokeColor = "#FFE6E6E6",
				StrokeSize = 2,
		},
	  ]]
	if val['fontStroke'] and type(val['fontStroke']) == 'table' and val['fontStroke']['IsStroke'] then
		local color = val['fontStroke']['StrokeColor']
		local r = ('0x' .. color['4:5']) + 0
		local g = ('0x' .. color['6:7']) + 0
		local b = ('0x' .. color['8:9']) + 0
		self:enableStroke(ccc3(r, g, b), val['fontStroke']['StrokeSize'])
	end

	if val['fontShadow'] and type(val['fontShadow']) == 'table' and val['fontShadow']['IsShadow'] then
		local color = val['fontShadow']['ShadowColor']
		local r = ('0x' .. color['4:5']) + 0
		local g = ('0x' .. color['6:7']) + 0
		local b = ('0x' .. color['8:9']) + 0
		self:enableShadow(ccc3(r, g, b), CCSizeMake(val['fontShadow']['OffsetX'], val['fontShadow']['OffsetY']), val['fontShadow']['ShadowAlpha'] / 255)
	end
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)

	-- if text color and mixing color is not the same use textcolor
	if val['FontColor'] and self.setFontColor then 
		local color = val['FontColor']
		local r = ('0x' .. color['4:5']) + 0
		local g = ('0x' .. color['6:7']) + 0
		local b = ('0x' .. color['8:9']) + 0
		local pColor = self:getColor()
		self:setFontColor(ccc3(r, g, b))
		if me.platform == me.platforms[me.PLATFORM_WIN32] then
			self:setColor(ccc3(r * pColor.r / 255, g * pColor.g / 255, b * pColor.b / 255))
		end
	end	

	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabel_NEWMEEDITOR(pval, parent)
	local val = pval.tLabelProperty

	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]
	setFuncs['TextBase'](self, pval.tTextBase)

	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)

	if me.platform == me.platforms[me.PLATFORM_WIN32] then
		local color = self:getColor()
		local fontColor = pval.tTextBase.tFontColor
		if fontColor then
			color = ccc3(color.r * fontColor.r / 255, color.g * fontColor.g / 255, color.b * fontColor.b / 255)
			self:setColor(color)
		end
	end

	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabel_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)
	if val['touchScaleEnable'] and self.setTouchScaleChangeAble then 
		self:setTouchScaleChangeAble(val['touchScaleEnable'])
	end	
	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	
	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	if val['fontName'] and self.setFontName then 
		self:setFontName(val['fontName'])
	end	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabel_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	
	if val['gravity'] and self.setGravity then
		self:setGravity(val.gravity)
	end

	if val['isTouchScale'] and self.setTouchScaleChangeEnabled then
		self:setTouchScaleChangeEnabled(val.isTouchScale)
	end

	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	if val['fontName'] and self.setFontName then 
		self:setFontName(val['fontName'])
	end	
	if val['fontColor'] and self.setColor then
		if type(val.fontColor) == 'string' then
			local color = val.fontColor
			local sidx = 3
			local head = string.lower(color['1:2'])
			if head ~= '0x' then sidx = 2 end
			local r = ('0x' .. color[{sidx, sidx+1}]) + 0
			local g = ('0x' .. color[{sidx+2, sidx+3}]) + 0
			local b = ('0x' .. color[{sidx+4, sidx+5}]) + 0
			self:setColor(ccc3(r, g, b))
		else
			local r, g, b, color = 0, 0, 0, val.fontColor
			r = bit_and(color, 0x00FF0000)
			r = bit_rshift(r, 16)
			g = bit_and(color, 0x0000FF00)
			g = bit_rshift(g, 8)
			b = bit_and(color, 0x000000FF)
			self:setColor(ccc3(r, g, b))
		end
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
