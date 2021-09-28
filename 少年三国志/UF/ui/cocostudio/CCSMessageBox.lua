--CCSMessageBox.lua

local CCSMessageBox = class ("CCSMessageBox", UFCCSModelLayer)



function CCSMessageBox:onLayerLoad( )
	self._handlerOk = nil
	self._okTarget = nil
	self._handlerYes = nil
	self._yesTarget = nil
	self._handlerNo = nil
	self._noTarget = nil
	self._handlerClose = nil
	self._closeTarget = nil
	self._titleLabel = nil
	self._contentLabel = nil

	self._okBtn = nil
	self._yesBtn = nil
	self._noBtn = nil
	self._closeBtn = nil
	self:setModelViewLevel(ModelViewLevel_MessageBox)
end

function CCSMessageBox:onLayerUnload( )
	
end


function CCSMessageBox:setOkCallback( handler, target )
	self._okTarget = target
	self._handlerOk = handler
end

function CCSMessageBox:registerOkBtn( okBtn )
	if type(okBtn) ~= "string" then 
		return 
	end

	local onOkHandler = function ( )
		if self._handlerOk ~= nil and self._okTarget ~= nil then 
			self._handlerOk(self._okTarget)
		elseif self._handlerOk ~= nil then
			self:_handlerOk()
		end
		self:animationToClose()
		--self:close()
	end

	self._okBtn = self:getButtonByName(okBtn)
    self:registerBtnClickEvent(okBtn, onOkHandler)
end

function CCSMessageBox:setYesCallback( handler, target )
	self._yesTarget = target
	self._handlerYes = handler
end

function CCSMessageBox:registerYesBtn( yesBtn )
	if type(yesBtn) ~= "string" then 
		return 
	end

	local onYesHandler = function ( )
		if self._handlerYes ~= nil and self._yesTarget ~= nil then 
			self._handlerYes(self._yesTarget)
		elseif self._handlerYes ~= nil then
			self:_handlerYes()
		end
		self:animationToClose()
		--self:close()
	end

	self._yesBtn = self:getButtonByName(yesBtn)
    self:registerBtnClickEvent(yesBtn, onYesHandler)
end

function CCSMessageBox:setNoCallback( handler, target )
	self._noTarget = target
	self._handlerNo = handler
end

function CCSMessageBox:registerNoBtn( noBtn )
	if type(noBtn) ~= "string" then 
		return 
	end

	local onNoHandler = function ( )
		if self._handlerNo ~= nil and self._noTarget ~= nil then 
			self._handlerNo(self._noTarget)
		elseif self._handlerNo ~= nil then
			self:_handlerNo()
		end
		self:animationToClose()
		--self:close()
	end

	self._noBtn = self:getButtonByName(noBtn)
    self:registerBtnClickEvent(noBtn, onNoHandler)
end

function CCSMessageBox:setCloseCallback( handler, target )
	self._closeTarget = target
	self._handlerClose = handler
end

function CCSMessageBox:registerCloseBtn( closeBtn )
	if type(closeBtn) ~= "string" then 
		return 
	end

	local onCloseHandler = function ( )
		if self._handlerClose ~= nil and self._closeTarget ~= nil then 
			self._handlerClose(self.closeTarget_)
		elseif self._handlerClose ~= nil then
			self:_handlerClose()
		end
		self:animationToClose()
		--self:close()
	end

	self._closeBtn = self:getButtonByName(closeBtn)
    self:registerBtnClickEvent(closeBtn, onCloseHandler)
end

function CCSMessageBox:setTitle( title )
	if self._titleLabel ~= nil then
		self._titleLabel:setText(title)
	end
end

function CCSMessageBox:registerTitleLabel( titleName )
	if type(titleName) ~= "string" then 
		return 
	end
	self._titleLabel = self:getLabelByName(titleName)
end

function CCSMessageBox:setContent( content )
	if self._contentLabel ~= nil then
		self._contentLabel:setText(content)
	end
end

function CCSMessageBox:registerContentLabel( contentName )
	if type(contentName) ~= "string" then 
		return 
	end
	self._contentLabel = self:getLabelByName(contentName)
end

function CCSMessageBox:setShowModel( ok_model )
	local is_ok_model = ok_model and true or false
	
	if self._okBtn ~= nil then
		self._okBtn:setVisible(ok_model)
	end
	if self._yesBtn ~= nil then
		self._yesBtn:setVisible(not ok_model)
	end
	if self._noBtn ~= nil then
		self._noBtn:setVisible(not ok_model)
	end
end

function CCSMessageBox:show( ok_model, sysMsg )
	sysMsg = sysMsg or false
	local node = nil	
	if not sysMsg then
		node = uf_notifyLayer:getPopupNode( )
	else
		node = uf_notifyLayer:getSysNode()
	end

	if node == nil then
		__Error("CCSMessageBox:show node = nil")
		return 
	end

	self:setShowModel(ok_model)

	node:addChild(self)
end


return CCSMessageBox