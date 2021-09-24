local GuideMediator=classGc(mediator,function(self,_view)
	self.name = "GuideMediator"
	self.view = _view
    self:regSelfLong()
end)

GuideMediator.protocolsList={

}

GuideMediator.commandsList={
    CGuideTouchCammand.TYPE,
}

function GuideMediator.processCommand( self, _command )
    local commandType=_command:getType()
    local commamdData=_command:getData()

    if commandType==CGuideTouchCammand.TYPE then
        if commamdData==CGuideTouchCammand.TASK_RECEIVE then
            self.view:checkGuide(_command.touchId)
        elseif commamdData==CGuideTouchCammand.TASK_FINISH then
            self.view:deleteThisGuide(_command.touchId)
        end
    end
end

return GuideMediator