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

function TFUIBase:initMETextButton(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMETextButton_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMETextButton_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMETextButton_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMETextButton_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMETextButton_MEEDITOR(pval, parent)
	self:initMEButton(pval, parent)
	local val = pval
	if val['titletext'] ~= " " or val['titletext'] ~= "" then 
		if val['titletext'] and self.setText then
			self:setText(val['titletext'])
		end
		if val['titlefontSize'] and self.setFontSize then
			self:setFontSize(val['titlefontSize'])
		end
		if val['titlefontName'] and self.setFontName then
			self:setFontName(val['titlefontName'])
		end
		if val['titletextColor'] and self.setFontColor then
			local color = val['titletextColor']
			local r = ('0x' .. color['4:5']) + 0
			local g = ('0x' .. color['6:7']) + 0
			local b = ('0x' .. color['8:9']) + 0
			self:setFontColor(ccc3(r, g, b))
		end
		self:initMEColorProps(pval, parent)
	end
end

function TFUIBase:initMETextButton_NEWMEEDITOR(pval, parent)
	self:initMEButton(pval, parent)

	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]
	if pval.tTextBase.szText ~= " " or pval.tTextBase.szText ~= "" then 
		setFuncs['TextBase'](self, pval.tTextBase)
		self:initMEColorProps(pval, parent)
	end
end

function TFUIBase:initMETextButton_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEButton(pval, parent)
	
	if val['text'] and self.setText then
		self:setText(val['text'])
	end

	-- generator by cocostudio
	if val['textColorR'] then
	    cri = val["textColorR"] or 255
	    cgi = val["textColorG"] or 255
	    cbi = val["textColorB"] or 255
	    self:setFontColor(ccc3(cri, cgi, cbi))
	end

	if val['fontSize'] and self.setFontSize then
		self:setFontSize(val['fontSize'])
	end

	if val['fontName'] and self.setFontName then
		self:setFontName(val['fontName'])
	end

	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMETextButton_ALPHA(pval, parent)
	local val = pval
	self:initMEButton(pval, parent)
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
end
