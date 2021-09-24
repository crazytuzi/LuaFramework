mediator = classGc(function(self, _view)
    self.view=_view
    self:regSelf()
end)
function mediator.regSelf(self)
	self.__reg=0
    _G.controller:regMediator(self)
end
function mediator.regSelfLong(self)
	self.__reg=1
    _G.controller:regPMediator(self)
end
function mediator.destroy(self)
	if self.__reg==0 then
		_G.controller:unMediator(self)
	elseif self.__reg==1 then
		_G.controller:unPMediator(self)
	end
end
function mediator.getName(self)
    return self.name
end
function mediator.processCommand(self, _command)
    return false
end
function mediator.setView(self,_view)
    self.view=_view
end
function mediator.getView(self)
    return self.view
end