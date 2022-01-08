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

function TFUIBase:initMELabelBMFont(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMELabelBMFont_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMELabelBMFont_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMELabelBMFont_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMELabelBMFont_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMELabelBMFont_MEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)	
	local val = pval

	if val['fileNameData'] and self.setFntFile then
		local str = val['fileNameData']
		if string.sub(str, -4, #str) == '.fnt' then
			self:setFntFile(val['fileNameData'])
		end
	end

	if val['text'] and self.setText then
		self:setText(val['text'])
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabelBMFont_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)	
	local val = pval.tLabelBMFontProperty

	if val.szFileName and self.setFntFile then
		self:setFntFile(val.szFileName)
	end

	if val.szText and self.setText then
    	self:convertSpecialChar(val)
		self:setText(val.szText)
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabelBMFont_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)	
	local fileNameDic = val['fileNameData']	
	if fileNameDic and fileNameDic.path then
		local fileNameType = fileNameDic.resourceType
		if fileNameType == 0 then
			local path = fileNameDic.path
			self:setFntFile(path)
		else
			print("Wrong res type of LabelBMFont!")
		end
	end

	if val['text'] and self.setText then
		self:setText(val['text'])
	end

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELabelBMFont_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)	
	if val['fntPath'] then
		self:setFntFile(val['fntPath'])
	end
	if val['text'] and self.setText then
		self:setText(val['text'])
	end
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end