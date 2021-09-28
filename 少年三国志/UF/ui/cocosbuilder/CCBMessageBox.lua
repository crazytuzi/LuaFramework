--CCBMessageBox.lua

local CCBMessageBox = class ("CCBMessageBox", UFCCBModelLayer)



function CCBMessageBox:onLayerLoad( )
	self._handlerOk = nil
	self._okTarget = nil
	self._handlerYes = nil
	self._yesTarget = nil
	self._handlerNo = nil
	self._noTarget = nil
	self._handlerClose = nil
	self._handlerClose = nil
	self._titleLabel = nil
	self._contentLabel = nil
	self:setViewLevel(ModelViewLevel_MessageBox)
end

function CCBMessageBox:onLayerUnload( )
	
end


function CCBMessageBox:setOkCallback( handler, target )
	self._okTarget = target
	self._handlerOk = handler
end

function CCBMessageBox:registerOkBtn( okBtn )
	if type(okBtn) ~= "string" then 
		return 
	end

	local onOkHandler = function ( )
		if self._handlerOk ~= nil and self._okTarget ~= nil then 
			self._handlerOk(self._okTarget)
		elseif self._handlerOk ~= nil then
			self:_handlerOk()
		end
		self:close()
	end

    self:registerMenuHandler(okBtn, onOkHandler)
end

function CCBMessageBox:setYesCallback( handler, target )
	self._yesTarget = target
	self._handlerYes = handler
end

function CCBMessageBox:registerYesBtn( yesBtn )
	if type(yesBtn) ~= "string" then 
		return 
	end

	local onYesHandler = function ( )
		if self._handlerYes ~= nil and self._yesTarget ~= nil then 
			self._handlerYes(self._yesTarget)
		elseif self._handlerYes ~= nil then
			self:_handlerYes()
		end
		self:close()
	end

    self:registerMenuHandler(yesBtn, onYesHandler)
end

function CCBMessageBox:setNoCallback( handler, target )
	self._noTarget = target
	self._handlerNo = handler
end

function CCBMessageBox:registerNoBtn( noBtn )
	if type(noBtn) ~= "string" then 
		return 
	end

	local onNoHandler = function ( )
		if self._handlerNo ~= nil and self._noTarget ~= nil then 
			self._handlerNo(self._noTarget)
		elseif self._handlerNo ~= nil then
			self:_handlerNo()
		end
		self:close()
	end

    self:registerMenuHandler(noBtn, onNoHandler)
end

function CCBMessageBox:setCloseCallback( handler, target )
	self.closeTarget_ = target
	self._handlerClose = handler
end

function CCBMessageBox:registerCloseBtn( closeBtn )
	if type(closeBtn) ~= "string" then 
		return 
	end

	local onCloseHandler = function ( )
		if self._handlerClose ~= nil and self.closeTarget_ ~= nil then 
			self._handlerClose(self.closeTarget_)
		elseif self._handlerClose ~= nil then
			self:_handlerClose()
		end
		self:close()
	end

    self:registerMenuHandler(closeBtn, onCloseHandler)
end

function CCBMessageBox:setTitle( title )
	if self._titleLabel ~= nil then
		self._titleLabel:setString(title)
	end
end

function CCBMessageBox:registerTitleLabel( titleName )
	if type(titleName) ~= "string" then 
		return 
	end
	local label = self:getNode(titleName)
	self._titleLabel = tolua.cast(label, "CCLabelTTF")
end

function CCBMessageBox:setContent( content )
	if self._contentLabel ~= nil then
		self._contentLabel:setString(content)
	end
end

function CCBMessageBox:registerContentLabel( contentName )
	if type(contentName) ~= "string" then 
		return 
	end
	local label = self:getNode(contentName)
	self._contentLabel = tolua.cast(label, "CCLabelTTF")
end

function CCBMessageBox:show(  )
	local node = uf_notifyLayer:getPopupNode( )
	if node == nil then
		__Error("getPopupNode:node = nil")
		return 
	end

	node:addChild(self)
end


return CCBMessageBox