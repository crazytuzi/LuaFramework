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

function TFUIBase:initMETableView(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMETableView_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMETableView_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMETableView_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMETableView_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMETableView_MEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMETableView_NEWMEEDITOR(pval, parent)
	self:initMEPanel(pval, parent)
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMETableView_COCOSTUDIO(pval, parent)
	self:initMEPanel(pval, parent)
	self:initMEColorProps(pval, parent)
end

function TFUIBase:initMETableView_ALPHA(pval, parent)
	self:initMEPanel(pval, parent)
    if val['direction'] and self.setDirection then 
        if val.direction == 'vertical' then
            self:setDirection(TFTableViewe.SCROLLVERTICAL)
            self:setVerticalFillOrder(TFTableViewe.FILLTOPDOWN)
        elseif val.direction == 'horizontal' then
            self:setDirection(TFTableViewe.SCROLLHORIZONTAL)
        elseif val.direction == 'none' then
            self:setDirection(TFTableViewe.SCROLLNONE)
        end
    else
        self:setSize(CCSizeMake(60,200))
        self:setDirection(TFTableViewe.SCROLLVERTICAL)
    end 
	self:initMEColorProps(pval, parent)
end