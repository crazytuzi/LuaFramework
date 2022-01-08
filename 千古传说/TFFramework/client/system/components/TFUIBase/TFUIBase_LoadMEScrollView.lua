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

function TFUIBase:initMEScrollView(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEScrollView_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEScrollView_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEScrollView_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEScrollView_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEScrollView_MEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	local val = pval
	
	if val['innerWidth'] or val['innerHeight'] and self.setInnerContainerSize then
		local innerWidth = val['innerWidth'] + 0
		local innerHeight = val['innerHeight'] + 0
		self:setInnerContainerSize(CCSizeMake(innerWidth, innerHeight))
	end	
	
	if val['direction'] and self.setDirection then 
		local nDir = val['direction'] + 0
		self:setDirection(nDir)
	elseif self.setDirection then
		self:setDirection(SCROLLVIEW_DIR_VERTICAL)
	end	

	if val['autoMoveDuration'] and self.setAutoMoveDuration then
		self:setAutoMoveDuration(val['autoMoveDuration'] + 0)
	end	
	if val['autoMoveEaseRate'] and self.setAutoMoveEaseRate then
		self:setAutoMoveEaseRate(val['autoMoveEaseRate'] + 0)
	end	

	if val['bounceEnable'] ~= nil and self.setBounceEnabled then
		local bIsBotBounceEnable = val['bounceEnable']['1:5'] == "False"
		if not bIsBotBounceEnable then 
			-- local tParam = {}
			-- string.gsub(val['bounceEnable'], '(%w*):([#A-Za-z0-9]*)', function(szKey, szVal)
			-- 	if szKey then 
			-- 		tParam[szKey] = szVal
			-- 	end
			-- end)
			-- local nDuration = tParam['bounceDuration'] + 0
			-- local nRate = tParam['bounceEaseRate'] + 0
			self:setBounceEnabled(true)
		    --self:setBounceDuratoin(nDuration)
		    --self:setBounceEaseRate(nRate)
		else
			self:setBounceEnabled(false)
		end
	end	

	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMEScrollView_NEWMEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	local val = pval.tScrollViewProperty
	if val.tInnerSize and self.setInnerContainerSize then
		self:setInnerContainerSize(val.tInnerSize)
	end	
	
	if val.nDirection and self.setDirection then
		self:setDirection(val.nDirection)
	end

	if val.bBounceEnabel ~= nil and self.setBounceEnabled then
		self:setBounceEnabled(val.bBounceEnabel)
	end	
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMEScrollView_COCOSTUDIO(pval, parent)	
	local val = pval.options
	self:initMEPanel(pval, parent)
	if val['innerWidth'] or val['innerHeight'] then
		local size = self:getSize()
		local iw = val['innerWidth'] or size.width
		local ih = val['innerHeight'] or size.height
		self:setInnerContainerSize(CCSizeMake(iw, ih))
	end
	if val['direction'] and type(val['direction']) == 'number' then
		self:setDirection(val['direction'])
	end
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMEScrollView_ALPHA(pval, parent)
	local val = pval
	self:initMEPanel(pval, parent)
	if val['direction'] and self.setDirection then 
		if val.direction == 'vertical' then
			self:setDirection(SCROLLVIEW_DIR_VERTICAL)
		elseif val.direction == 'horizontal' then
			self:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
		elseif val.direction == 'none' then
			self:setDirection(SCROLLVIEW_DIR_NONE)
		end
	else
		self:setDirection(SCROLLVIEW_DIR_VERTICAL)
	end	
	if val['innerWidth'] or val['innerHeight'] then
		local size = self:getSize()
		local iw = val['innerWidth'] or size.width
		local ih = val['innerHeight'] or size.height
		self:setInnerContainerSize(CCSizeMake(iw, ih))
	end
	if val['direction'] and type(val['direction']) == 'number' then
		self:setDirection(val['direction'])
	end
	self:initMEColorProps(pval, parent)
end