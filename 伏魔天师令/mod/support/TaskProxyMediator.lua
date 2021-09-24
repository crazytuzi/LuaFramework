local TaskProxyMediator = classGc(mediator,function(self,_view)
	self.name="TaskProxyMediator"
	self.view=_view
    self:regSelfLong()
end)

TaskProxyMediator.protocolsList={
    _G.Msg.ACK_TASK_DATA,
    _G.Msg.ACK_TASK_REMOVE
}

--3265 从列表中移除任务
function TaskProxyMediator.ACK_TASK_REMOVE( self, _ackMsg)
    CCLOG("\n[移除任务 3265] id=%d, reason=%d", _ackMsg.id,_ackMsg.reason)
    self.view:removeTaskByData( _ackMsg )
end

---3220 返回任务数据
function TaskProxyMediator.ACK_TASK_DATA( self, _ackMsg )
    CCLOG("\n[返回任务数据 3220] id=%d, state=%d, target_type=%d", _ackMsg.id, _ackMsg.state, _ackMsg.target_type)
    self.view:setInitialized( true )
    self.view:updateOneTaskData( _ackMsg )
end

return TaskProxyMediator

