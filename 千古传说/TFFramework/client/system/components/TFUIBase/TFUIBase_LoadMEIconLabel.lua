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

function TFUIBase:initMEIconLabel(pval, parent)
	if TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEIconLabel_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEIconLabel_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEIconLabel_MEEDITOR(val, parent)
	self:initMEWidget(val, parent)

	local nScaleX, nScaleY = self:getScaleX(), self:getScaleY()
	self:setScaleX(1.0)
	self:setScaleY(1.0)

	if val['touchScaleEnable'] and self.Label.setTouchScaleChangeAble then 
		local bIsTouchScaleEnable = val['touchScaleEnable'] == "True"
		self.Label:setTouchScaleChangeEnabled(bIsTouchScaleEnable)
		self.Label:setTouchEnabled(bIsTouchScaleEnable)
	end
	if val['szIconTexture'] and self.setIcon then
		self:setIcon(val['szIconTexture'])
	end
	
	if val['nGap'] and self.setGap then
		self:setGap(val['nGap'] + 0)
	end
	
	if val['nIconAlign'] and self.setIconVAlign then
		self:setIconVAlign(val['nIconAlign'] + 0)
	end
	
	if val['nTextAlign'] and self.setTextVAlign then
		self:setTextVAlign(val['nTextAlign'] + 0)
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
	if val['FontColor'] and self.setTextColor then 
		local color = val['FontColor']
		local r = ('0x' .. color['4:5']) + 0
		local g = ('0x' .. color['6:7']) + 0
		local b = ('0x' .. color['8:9']) + 0
		self:setTextColor(ccc3(r, g, b))
	end	
	if val['IconLayout'] and self.setIconDir then
		self:setIconDir(val['IconLayout'] + 0)
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

	self:setScaleX(nScaleX)
	self:setScaleY(nScaleY)
	
	self:initMEColorProps(val, parent)
	self:initBaseControl(val, parent)
end

function TFUIBase:initMEIconLabel_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)

	local nScaleX, nScaleY = self:getScaleX(), self:getScaleY()
	self:setScaleX(1.0)
	self:setScaleY(1.0)

	local val = pval.tIconLabelProperty

	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]
	setFuncs['TextBase'](self, pval.tTextBase)

	if val.szIcon and self.setIcon then
		self:setIcon(val.szIcon)
	end
	
	if val.nGap and self.setGap then
		self:setGap(val.nGap)
	end

	if val.nIconVerticalAlign and self.setIconVAlign then
		self:setIconVAlign(val.nIconVerticalAlign)
	end
	
	if val.nIconDir and self.setIconDir then
		self:setIconDir(val.nIconDir)
	end

	self:setScaleX(nScaleX)
	self:setScaleY(nScaleY)
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
