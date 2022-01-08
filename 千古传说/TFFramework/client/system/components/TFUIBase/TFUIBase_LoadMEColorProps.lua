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

function TFUIBase:initMEColorProps(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEColorProps_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEColorProps_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEColorProps_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEColorProps_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEColorProps_MEEDITOR(val, parent)
	local setFuncs = TFUIBase_setFuncs[self:getDescription()]

	setFuncs['opacity'](self, val['opacity'])
	setFuncs['ColorMixing'](self, val['ColorMixing'])
	setFuncs['anchorPoint'](self, val['anchorPointX'], val['anchorPointY'])
	setFuncs['flipX'](self, val['flipX'])
	setFuncs['flipY'](self, val['flipY'])
	setFuncs['ignoreSize'](self, val['ignoreSize'])
	setFuncs['PanelRelativeSizeModel'](self, val['PanelRelativeSizeModel'])
	setFuncs['srcBlendFunc'](self, val['srcBlendFunc'])
	setFuncs['dstBlendFunc'](self, val['dstBlendFunc'])
end

function TFUIBase:initMEColorProps_NEWMEEDITOR(val, parent)
	local setFuncs = TFUIBase_setFuncs_new[self:getDescription()]

	setFuncs['ColorMixing']			(self, val.tBaseData.tColor)
	-- setFuncs['opacity']			(self, val.tBaseData.nOpacity)
	-- setFuncs['anchorPoint']			(self, val.tBaseData.tAnchorPoint)
	-- setFuncs['Size']			(self, val.tSizeBase)
	-- setFuncs['PanelRelativeSizeModel'](self, val['PanelRelativeSizeModel'])
	setFuncs['flipX']				(self, val.tBaseData.bFlipX)
	setFuncs['flipY']				(self, val.tBaseData.bFlipY)
	setFuncs['BlendFunc']			(self, val.tBaseData.tBlend)
end

function TFUIBase:initMEColorProps_COCOSTUDIO(val, parent)
	if val.options then
		val = val.options
	end
	if val['alpha'] and self.setOpacity then 
		self:setOpacity(val['alpha'] * 255)
	end	

	if val['opacity'] and self.setOpacity then 
		self:setOpacity(val['opacity'])
	end	

	if val['ax'] or val['ay'] then 
		local ax = val['ax'] or 0.5
		local ay = val['ay'] or 0.5
		self:setAnchorPoint(ccp(ax, ay))
	end	

	if val['color'] and self.setColor then
		local color = val.color
		if type(color) == 'string' then
			local sidx = 3
			local head = string.lower(color['1:2'])
			if head ~= '0x' then sidx = 2 end
			local r = ('0x' .. color[{sidx, sidx+1}]) + 0
			local g = ('0x' .. color[{sidx+2, sidx+3}]) + 0
			local b = ('0x' .. color[{sidx+4, sidx+5}]) + 0
			self:setColor(ccc3(r, g, b))
		else
			local r, g, b = 0, 0, 0
			r = bit_and(color, 0x00FF0000)
			r = bit_rshift(r, 16)
			g = bit_and(color, 0x0000FF00)
			g = bit_rshift(g, 8)
			b = bit_and(color, 0x000000FF)
			self:setColor(ccc3(r, g, b))
		end
	end

	if val['anchorPointX'] or val['anchorPointY'] then 
		local ax = val['anchorPointX'] or 0.5
		local ay = val['anchorPointY'] or 0.5
		self:setAnchorPoint(ccp(ax, ay))
	end	

	if val['flipX'] and self.setFlipX then 
		local fx = val['flipX'] 
		self:setFlipX(fx)
	end	

	if val['flipY'] and self.setFlipY then 
		local fy = val['flipY'] 
		self:setFlipY(fy)
	end	

	if val['colorR'] or val['colorG'] or val['colorB'] then
		local cr = val['colorR'] or 255
		local cg = val['colorG'] or 255
		local cb = val['colorB'] or 255
		self:setColor(ccc3(cr, cg, cb))
	end
end

function TFUIBase:initMEColorProps_ALPHA(val, parent)
	self:initMEColorProps_COCOSTUDIO(val, parent)
end