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

function TFUIBase:initMETextField(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMETextField_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMETextField_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMETextField_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMETextField_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMETextField_MEEDITOR(pval, parent)
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
	if val['fontName'] and self.setFontName then 
		self:setFontName(val['fontName'])
	end	
	if val['placeHolder'] and self.setPlaceHolder then 
		self:setPlaceHolder(val['placeHolder'])
	end	

	if val['maxLengthEnable'] and self.setMaxLengthEnabled then 
		local bIsNotMaxLengthEnable = val['maxLengthEnable']['1:5'] == "False"
		if not bIsNotMaxLengthEnable then
			local tParam = {}
			string.gsub(val['maxLengthEnable'], '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
				if szKey then 
					tParam[szKey] = szVal
				end
			end)
			self:setMaxLengthEnabled(true)
			self:setMaxLength(tParam['maxLength'] + 0)
		end
	end	
	if val['passwordEnable'] and self.setPasswordEnabled then 
		local bIsNotPasswordEnable = val['passwordEnable']['1:5'] == "False"
		if not bIsNotPasswordEnable then
			local tParam = {}
			string.gsub(val['passwordEnable'], '(%w*):(.*)', function(szKey, szVal)
				if szKey then 
					tParam[szKey] = szVal
				end
			end)
			self:setPasswordEnabled(true)
			self:setPasswordStyleText(tParam['passwordStyleText'])
		end
	end	
	
	if val['setTouchSize'] and self.setTouchSize then 
		--self:setTouchSize(size)
	end	

	if val['text'] and self.setText then 
		self:setText(val['text'])
	end	
	if val['CursorEnabled'] and self.setCursorEnabled then 
		self:setCursorEnabled(val['CursorEnabled'] == "True")
	end	

	if val['KeyBoradType'] and self.setCursorEnabled then 
		self:setKeyBoardType(val['KeyBoradType'] + 0)
	end	

	if val['hAlignment'] and self.setTextHorizontalAlignment then 
		self:setTextHorizontalAlignment(val['hAlignment'] + 0)
	end	

	if val['vAlignment'] and self.setTextVerticalAlignment then 
		self:setTextVerticalAlignment(val['vAlignment'] + 0)
	end


	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMETextField_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)

	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]
	setFuncs['TextBase'](self, pval.tTextBase)

	local val = pval.tTextFieldProperty

	if val.szPlaceHolder and self.setPlaceHolder then 
		self:setPlaceHolder(val.szPlaceHolder)
	end	

	if val.nMaxLength and val.nMaxLength ~= -1 and self.setMaxLengthEnabled then 
			self:setMaxLengthEnabled(true)
			self:setMaxLength(val.nMaxLength)
	end	
	if val.bPasswordEnabled and self.setPasswordEnabled then 
			self:setPasswordEnabled(true)
			self:setPasswordStyleText(val.szPasswordChar)
	end	

	if val.nKeyBoardType then
		self:setKeyBoardType(val.nKeyBoardType)
	end
	
	if val['setTouchSize'] and self.setTouchSize then 
		--self:setTouchSize(size)
	end	

	if val.bCursorEnabled and self.setCursorEnabled then 
		self:setCursorEnabled(val.bCursorEnabled)
	end

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

function TFUIBase:initMETextField_COCOSTUDIO(pval, parent)
	local val = pval.options
	self:initMEWidget(pval, parent)

	if val['placeHolder'] and self.setPlaceHolder then
		self:setPlaceHolder(val['placeHolder'])
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

	if val['touchSizeWidth'] and val['touchSizeHeight'] and self.setTouchSize then
		self:setTouchSize(CCSizeMake(val['touchSizeWidth'], val['touchSizeHeight']))
	end

	if val['maxLengthEnable'] ~= nil and self.setMaxLengthEnable then
		self:setMaxLengthEnable(val['maxLengthEnable'])
	end

	if val['maxLength'] and self.setMaxLength then
		self:setMaxLength(val['maxLength'])
	end

	if val['passwordEnable'] ~= nil and self.setPasswordEnable then
		self:setPasswordEnable(val['passwordEnable'])
		if val['passwordEnable'] then
			if val['passwordStyleText'] and self.setPasswordStyleText then
				self:setPasswordStyleText(val['passwordStyleText'])
			end
		end
	end

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMETextField_ALPHA(pval, parent)
	local val = pval
	self:initMEWidget(pval, parent)
	if val['isPassword'] and self.setIsPassWord then
		self:setIsPassWord(true)
	end

	if val['placeHolder'] and self.setPlaceHolder then
		self:setPlaceHolder(val['placeHolder'])
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

	if val['touchSizeWidth'] and val['touchSizeHeight'] and self.setTouchSize then
		self:setTouchSize(CCSizeMake(val['touchSizeWidth'], val['touchSizeHeight']))
	end

	if val['maxLengthEnable'] ~= nil and self.setMaxLengthEnabled then
		self:setMaxLengthEnable(val['maxLengthEnable'])
	end

	if val['maxLength'] and self.setMaxLength then
		self:setMaxLengthEnabled(true)
		self:setMaxLength(val.maxLength)
	end

	if val['passwordEnable'] ~= nil and self.setPasswordEnable then
		self:setPasswordEnabled(val['passwordEnable'])
		if val['passwordEnable'] then
			if val['passwordStyleText'] and self.setPasswordStyleText then
				self:setPasswordStyleText(val['passwordStyleText'])
			end
		end
	end

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end