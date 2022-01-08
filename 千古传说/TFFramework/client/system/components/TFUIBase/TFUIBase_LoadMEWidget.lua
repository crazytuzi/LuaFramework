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
local TFUIBase = TFUIBase

function TFUIBase:initMEWidget(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEWidget_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEWidget_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEWidget_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEWidget_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEWidget_MEEDITOR(val, parent)
	local setFuncs = TFUIBase_setFuncs[self:getDescription()]

	setFuncs['ignoreSize'](self, val['ignoreSize'])
	setFuncs['size'](self, val['ignoreSize'], val['width'], val['height'])
	setFuncs['sizeType'](self, val['sizeType'], val['sizepercentx'], val['sizepercenty'])
	setFuncs['position'](self, val['x'], val['y'])
	setFuncs['tag'](self, val['tag'])
	setFuncs['touchAble'](self, val['touchAble'])
	setFuncs['name'](self, val['name'])
	setFuncs['scaleX'](self, val['scaleX'])
	setFuncs['scaleY'](self, val['scaleY'])
	setFuncs['rotation'](self, val['rotation'])
	setFuncs['rotateX'](self, val['rotateX'])
	setFuncs['rotateY'](self, val['rotateY'])
	setFuncs['visible'](self, val['visible'])
	setFuncs['ZOrder'](self, val['ZOrder'])
	setFuncs['baseNum'](self, val['baseNum'])
	setFuncs['layoutType'](self, val['layoutType'])
	setFuncs['percentPosition'](self, val['percentPosition'])
	setFuncs['percentSize'](self, val['percentSize'])
	setFuncs['layout'](self, val['layout'])
	setFuncs['UILayoutViewModel'](self, val['UILayoutViewModel'])
	setFuncs['HitType'](self, val['HitType'])
	setFuncs['DiyPropertyViewModel'](self, val['DiyPropertyViewModel'])
end

function TFUIBase:initMEWidget_NEWMEEDITOR(val, parent)
	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]

	setFuncs['UIEditorData']		(self, val.tBaseData.UIEditorData)

	setFuncs['tag']				(self, val.tBaseData.nTag)
	setFuncs['touchAble']			(self, val.tBaseData.bTouchAble)
	setFuncs['name']			(self, val.tBaseData.szName)
	setFuncs['Scale']			(self, val.tBaseData.tScale)
	setFuncs['rotation']			(self, val.tBaseData.nRotation)
	setFuncs['visible']			(self, val.tBaseData.bVisible)
	setFuncs['ZOrder']			(self, val.tBaseData.ZOrder)
	setFuncs['opacity']			(self, val.tBaseData.nOpacity)
	setFuncs['anchorPoint']			(self, val.tBaseData.tAnchorPoint)
	setFuncs['HitType']			(self, val.tBaseData)
	setFuncs['BlendFunc']			(self, val.tBaseData.tBlend)
	setFuncs['Size']			(self, val.tSizeBase)
	setFuncs['UILayout']			(self, val.tLayoutBase)
	setFuncs['ColorMixing']			(self, val.tBaseData.tColor)
	setFuncs['Script']			(self, val.tBaseData.tScript)
	-- setFuncs['PanelRelativeSizeModel']	(self, val.tBaseData)
end

function TFUIBase:initMEWidget_COCOSTUDIO(val, parent)
	if val.options then
		val = val.options
	end
	if val['ignoreSize'] and self.ignoreContentAdaptWithSize then 
		self:ignoreContentAdaptWithSize(val['ignoreSize'])
	end
	
	if (val['width'] or val['height']) then 
		local cs = self:getSize()
		local width = val['width'] or cs.width
		local height = val['height'] or cs.height
		self:setSize(CCSizeMake(width, height))
	end	
	
	if val['tag'] and self.setTag then 
		self:setTag(val['tag'])
	end
	
	if val['actiontag'] and self.setActionTag then 
		--self:setActionTag(val['actiontag'])
	end
	
	if val['touchAble'] and self.setTouchEnabled then 
		self:setTouchEnabled(val['touchAble'])
	end

	if val['touchEnabled'] and self.setTouchEnabled then 
		self:setTouchEnabled(val['touchEnabled'])
	end

	if val['name'] and self.setName then 
		self:setName(val['name'])
	end

	if val['objectname'] and self.setName then 
		self:setName(val['objectname'])
	end

	if val['x'] or val['y'] then 
		local x = val['x'] or 0
		local y = val['y'] or 0
		self:setPosition(ccp(x, y))
	end	

	if val['scale'] and self.setScale then 
		self:setScale(val['scale'])
	end	

	if val['scaleX'] and self.setScaleX and val['scaleX'] ~= 1 then 
		self:setScaleX(val['scaleX'])
	end	

	if val['scaleY'] and self.setScaleY and val['scaleY'] ~= 1 then 
		self:setScaleY(val['scaleY'])
	end	

	if val['rotateX'] and self.setRotationX and val['rotateX'] ~= 0 then 
		self:setRotationX(val['rotateX'])
	end	

	if val['rotateY'] and self.setRotationY and val['rotateY'] ~= 0 then 
		self:setRotationY(val['rotateY'])
	end	

	if val['rotate'] and self.setRotation and val['rotate'] ~= 0 then 
		self:setRotation(val['rotate'])
	end	

	if val['rotation'] and self.setRotation and val['rotation'] ~= 0 then 
		self:setRotation(val['rotation'])
	end	

	if val.visible ~= nil and self.setVisible then 
		self:setVisible(val.visible)
	end

	if val['ZOrder'] and self.setZOrder then 
		self:setZOrder(val['ZOrder'])
	end

	if val['enabled'] and self.setEnabled then 
		self:setEnabled(val['enabled'])
	end
	
	if val['align'] and self.setAlign then 
		self:setAlign(val['align'])
	end
	
	if val['percentPosition'] and self.setPositionPercent then  --[[ "54%, 34%" or "0.54, 0.34" or "54%, 0.34"]]
		local tNums = string.split(val['percentPosition'], ',')
		string.gsub(tNums[1], '(.-)%%', function(num) tNums[1] = num / 100 end)
		string.gsub(tNums[2], '(.-)%%', function(num) tNums[2] = num / 100 end)
		self:setPositionType(TF_POSITION_PERCENT)
		self:setPositionPercent(ccp(tNums[1], tNums[2]))
	end
	
	if val['percentSize'] and self.setSizePercent then  --[[ "54%, 34%" or "0.54, 0.34" or "54%, 0.34"]]
		local tNums = string.split(val['percentSize'], ',')
		string.gsub(tNums[1], '(.-)%%', function(num) tNums[1] = num / 100 end)
		string.gsub(tNums[2], '(.-)%%', function(num) tNums[2] = num / 100 end)
   		self:setSizeType(TF_SIZE_PERCENT)
		self:setSizePercent(ccp(tNums[1], tNums[2]))
	end

	if val['layout'] and self.setLayoutParameter then 
		local tParam = val['layout']
		self:setLayoutByTable(tParam)
	end
	if val['UILayoutViewModel'] and self.setLayoutParameter then 
		local tParam = val['UILayoutViewModel']
		self:setLayoutByTable(tParam)
	end
end

function TFUIBase:initMEWidget_ALPHA(val, parent)
	self:initMEWidget_COCOSTUDIO(val, parent)
end
