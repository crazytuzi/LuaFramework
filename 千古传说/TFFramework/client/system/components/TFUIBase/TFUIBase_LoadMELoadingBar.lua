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

function TFUIBase:initMELoadingBar(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMELoadingBar_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMELoadingBar_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMELoadingBar_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMELoadingBar_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMELoadingBar_MEEDITOR(pval, parent)
	local val = pval
	if val['backGroundScale9Enable'] and self.setScale9Enabled then
		local bIsNotScale9Enable = val['backGroundScale9Enable'] == "False"
		if not bIsNotScale9Enable then 
			self:setScale9Enabled(true)
			local t9Param = {}
			string.gsub(val['backGroundScale9Enable'], '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
				if szKey then 
					t9Param[szKey] = szVal
				end
			end)
			local cx = t9Param['capInsetsX'] + 0
			local cy = t9Param['capInsetsY'] + 0
			local cw = t9Param['capInsetsWidth'] + 0
			local ch = t9Param['capInsetsHeight'] + 0
			local rect = CCRectMake(cx, cy, cw, ch)
			self:setCapInsets(rect)
		end
	end

	if val['direction'] and self.setDirection then
		self:setDirection(val['direction'] + 0)
	end

	if val['texture'] and val['texture'] ~= "" and self.setTexture then
		local textureType = TF_TEX_TYPE_LOCAL
		if val['texture_plist'] and val['texture_plist'] ~= "" then
			TFUIBase:loadPlistOrPvrTexture( val['texture_plist'] )
			textureType = TF_TEX_TYPE_PLIST
		end

		self:setTexture(val['texture'], textureType)
	end
	if val['percent'] and self.setPercent then
		self:setPercent(val['percent'])
	end
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELoadingBar_NEWMEEDITOR(pval, parent)
	local val = pval.tLoadingBarProperty
	
	if val.nDirection and self.setDirection then
		self:setDirection(val.nDirection)
	end

	if val.szTexture and val.szTexture ~= "" and self.setTexture then
		self:setTexture(val.szTexture)
	end
	if val.nPercent and self.setPercent then
		self:setPercent(val.nPercent)
	end

	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELoadingBar_COCOSTUDIO(pval, parent)
	local val = pval.options
	
	local textureDic = val['textureData']	
	if textureDic and textureDic.path then
		local textureType = textureDic.resourceType
		if textureType == 0 then
			local path = textureDic.path
			self:setTexture(path)
		else
			me.FrameCache:addSpriteFramesWithFile(textureDic.plistFile)
			self:setTexture(textureDic.path, TF_TEX_TYPE_PLIST)
		end
	end

	if val['scale9Enable'] and self.setScale9Enabled then
		self:setScale9Enabled(val['scale9Enable'])
	end
	if val['scale9Enabled'] and self.setScale9Enabled then
		self:setScale9Enabled(val['scale9Enabled'])
	end	

	if (val['scale9Enable'] or val['scale9Enabled']) and val['capInsetsX'] then
		local cx = val['capInsetsX']
		local cy = val['capInsetsY']
		local cw = val['capInsetsWidth']
		local ch = val['capInsetsHeight']
		self:setCapInsets(CCRectMake(cx, cy, cw, ch))

		if val['width'] or val['height'] then 
			local cs = self:getSize()
			local width = val['width'] or cs.width
			local height = val['height'] or cs.height
			self:setSize(CCSizeMake(width, height))
		end	
	end
	
	if val['direction'] and self.setDirection then
		self:setDirection(val['direction'])
	end	
	
	if val['percent'] and self.setPercent then
		self:setPercent(val['percent'])
	end	
	self:initMEWidget(pval, parent)
	
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMELoadingBar_ALPHA(pval, parent)
	local val = pval
	
	if val['texture'] then 
		self:setTexture(val['texture'])
	end
	if val['scale9Enable'] and self.setScale9Enabled then
		self:setScale9Enabled(val['scale9Enable'])
	end
	if val['scale9Enabled'] and self.setScale9Enabled then
		self:setScale9Enabled(val['scale9Enabled'])
	end	

	if val['direction'] and self.setDirection then
		self:setDirection(val['direction'])
	end	
	
	if val['percent'] and self.setPercent then
		self:setPercent(val['percent'])
	end	
	self:initMEWidget(pval, parent)
	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end
