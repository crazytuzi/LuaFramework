local TaskDialogMediator = classGc( mediator, function( self, _view)
    self.name  = "TaskDialogMediator"
    self.view  = _view

    self:regSelf()
end)

TaskDialogMediator.protocolsList=nil

TaskDialogMediator.commandsList={
    CTaskDataUpdataCommand.TYPE,
    -- CTaskEffectsCommand.TYPE,
    CloseWindowCommand.TYPE,
}

function TaskDialogMediator.processCommand( self, _command )
    local commamdType = _command:getType()
    if commamdType == CTaskDataUpdataCommand.TYPE then
        print("TaskDialogMediator.processCommand", _command:getData(),_command.id)
        local commamdData = _command :getData()
        if commamdData == _G.Msg.ACK_TASK_DATA then
            local taskId    = _command.id
            local taskState = _command.state
            self.view:setUpdateView( taskId, taskState )
        elseif commamdData == _G.Msg.ACK_TASK_REMOVE then
            --移除任务
            local taskId   = _command.id
            self.view:removeTaskCallBack( taskId )
        end
    -- elseif commamdType == CTaskEffectsCommand.TYPE then
    --     local taskId    = _command.taskId
    --     local taskState = _command:getData()

        -- self.view:showTaskSound(taskId,taskState)
    elseif commamdType == CloseWindowCommand.TYPE then
        if _command:getData()==_G.Cfg.UI_CTaskDialogView then
            self.view:closeWindow()
        end
    end
end

return TaskDialogMediator