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

function TFUIBase:initMETextArea(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMETextArea_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMETextArea_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMETextArea_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMETextArea_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMETextArea_MEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval
	
	local bIsIgnore = val['ignoreSize'] == "True"
	if self.ignoreContentAdaptWithSize then
		self:ignoreContentAdaptWithSize(bIsIgnore)
	end
	if not bIsIgnore then
		if (val['width'] or val['height']) then 
			local cs = self:getSize()
			local width = val['width'] + 0 or cs.width
			local height = val['height'] + 0 or cs.height
			self:setTextAreaSize(CCSizeMake(width, height))
		end
	end	

	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	
	if val['fontName'] and val['fontName'] ~= "" and self.setFontName then 
		self:setFontName(val['fontName'])
	end	

	if val['hAlignment'] and self.setTextHorizontalAlignment then 
		self:setTextHorizontalAlignment(val['hAlignment'] + 0)
	end	

	if val['vAlignment'] and self.setTextVerticalAlignment then 
		self:setTextVerticalAlignment(val['vAlignment'] + 0)
	end	

	if val['touchScaleEnable'] and self.setTouchScaleChangeEnabled then 
		local bIsTouchScaleEnable = val['touchScaleEnable'] == "True"
		self:setTouchScaleChangeAble(bIsTouchScaleEnable)
	end	

	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	

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
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMETextArea_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	local val = pval
	
	local bIsIgnore = val['ignoreSize'] == "True"
	if self.ignoreContentAdaptWithSize then
		self:ignoreContentAdaptWithSize(bIsIgnore)
	end
	if not bIsIgnore then
		if (val['width'] or val['height']) then 
			local cs = self:getSize()
			local width = val['width'] + 0 or cs.width
			local height = val['height'] + 0 or cs.height
			self:setTextAreaSize(CCSizeMake(width, height))
		end
	end	

	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	
	if val['fontName'] and val['fontName'] ~= "" and self.setFontName then 
		self:setFontName(val['fontName'])
	end	

	if val['hAlignment'] and self.setTextHorizontalAlignment then 
		self:setTextHorizontalAlignment(val['hAlignment'] + 0)
	end	

	if val['vAlignment'] and self.setTextVerticalAlignment then 
		self:setTextVerticalAlignment(val['vAlignment'] + 0)
	end	

	if val['touchScaleEnable'] and self.setTouchScaleChangeEnabled then 
		local bIsTouchScaleEnable = val['touchScaleEnable'] == "True"
		self:setTouchScaleChangeAble(bIsTouchScaleEnable)
	end	

	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMETextArea_COCOSTUDIO(pval, parent)
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMETextArea_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	
	if val['fontSize'] and self.setFontSize then 
		self:setFontSize(val['fontSize'])
	end	
	
	if val['fontName'] and self.setFontName then 
		self:setFontName(val['fontName'])
	end	

	if val['areaWidth'] and val['areaHeight'] and self.setFontName then 
		self:setTextAreaSize(CCSizeMake(val['areaWidth'], val['areaHeight']))
	end	

	if val['hAlignment'] and self.setTextHorizontalAlignment then 
		self:setTextHorizontalAlignment(val['hAlignment'])
		--self:setTextHorizontalAlignment(kCCTextAlignmentLeft)
	end	

	if val['vAlignment'] and self.setTextVerticalAlignment then 
		self:setTextVerticalAlignment(val['vAlignment'])
		--self:setTextVerticalAlignment(kCCVerticalTextAlignmentTop)
	end	

	if val['gravity'] and self.setGravity then
		self:setGravity(val.gravity)
	end

	if val['isTouchScale'] and self.setTouchScaleChangeEnabled then
		self:setTouchScaleChangeEnabled(val.isTouchScale)
	end

	if val['fontColor'] and self.setColor then
		if type(val.fontColor) == 'string' then
			local r = ('0x' .. string.sub(val.fontColor, 3, 4)) + 0
			local g = ('0x' .. string.sub(val.fontColor, 5, 6)) + 0
			local b = ('0x' .. string.sub(val.fontColor, 7, 8)) + 0
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
