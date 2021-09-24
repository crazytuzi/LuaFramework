local TaskViewMediator=classGc(mediator,function(self,_view)
    self.name  = "TaskViewMediator"
    self.view  = _view

    self:regSelf()
end)

TaskViewMediator.protocolsList={
    _G.Msg.ACK_REWARD_TASK_REPLAY,--[44620]任务返回 -- 悬赏任务
    _G.Msg.ACK_REWARD_TASK_ACCEPT_BACK,-- [44645]接受成功 -- 悬赏任务 
    _G.Msg.ACK_REWARD_TASK_FINISH,-- [44690]任务完成 -- 悬赏任务 
}

TaskViewMediator.commandsList=
{
    CFunctionOpenCommand.TYPE,
    CProxyUpdataCommand.TYPE,
}

function TaskViewMediator.processCommand( self, _command )
    if _command:getType()==CFunctionOpenCommand.TYPE then
        if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
            self.view:chuangIconNum(_command.sysId,_command.number)
        end
    elseif _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    end
end


function TaskViewMediator.ACK_REWARD_TASK_REPLAY(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    for k,v in pairs(_ackMsg.data) do
        print("======>>"..k)
        for kkkk,vvvv in pairs(v) do
            print(kkkk,vvvv)
        end
    end

    if #_ackMsg.data>1 then
        local function sort(v1,v2)
            return v1.idx<v2.idx
        end
        table.sort( _ackMsg.data, sort )
    end
    self.view:updateRewardTask(_ackMsg)
end

function TaskViewMediator.ACK_REWARD_TASK_ACCEPT_BACK(self,_ackMsg)
    self.view:acceptRewardTask(_ackMsg.idx)
end

function TaskViewMediator.ACK_REWARD_TASK_FINISH(self,_ackMsg)
    self.view:finishRewardTask(_ackMsg.idx)
end

return TaskViewMediator

