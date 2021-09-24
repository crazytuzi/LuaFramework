local NpcMediator = classGc(mediator, function(self, _view)
    self.name = "NpcMediator"
    self.view = _view
    self:regSelf()
end)

NpcMediator.protocolsList=nil

NpcMediator.commandsList={
    CNpcUpdateCommand.TYPE
}

function NpcMediator.processCommand(self, _command)
    --更新图标
    local taskData    = _command.taskData
    local commamdData = _command :getData()
    if commamdData == CNpcUpdateCommand.ADD then
        self :taskAdd( taskData )
    elseif commamdData == CNpcUpdateCommand.UPDATE then
        self :taskUpdate( taskData )
    elseif commamdData == CNpcUpdateCommand.DELETE then
        self :taskDelete( taskData )
    elseif commamdData == CNpcUpdateCommand.MAIN_TASK then
        local taskId    = _command.taskId
        local searchNpc = _command.npcId
        self :searchThisTask( searchNpc, taskId )
    end
end

function NpcMediator.taskAdd( self, _data )
    CCLOG( "NpcMediator.taskAdd id->".._data.id.."  state->".._data.state )
    local npcArr       = _G.CharacterManager : getNpc()
    local _nState      = _data.state
    local taskBeginNpc = _data.sNpc
    local taskEndNpc   = _data.eNpc

    --不可接及以下的都没有icon
    if _nState < _G.Const.CONST_TASK_STATE_ACCEPTABLE then return end

    print("taskAdd------>>>>  ",taskBeginNpc,taskEndNpc)

    for key, value in pairs( npcArr ) do

        if taskBeginNpc == taskEndNpc and taskBeginNpc == value.npcId then
            value :addOneNpcIconState(_data)
            break
        elseif taskBeginNpc == value.npcId and _nState <= _G.Const.CONST_TASK_STATE_UNFINISHED then
            value :addOneNpcIconState(_data)
            break
        elseif taskEndNpc == value.npcId and _nState > _G.Const.CONST_TASK_STATE_UNFINISHED then
            value :addOneNpcIconState(_data)
            break
        end
    end
end

function NpcMediator.taskUpdate( self, _data )
    CCLOG( "NpcMediator.taskUpdate id->".._data.id.."  state->".._data.state )

    local npcArr       = _G.CharacterManager : getNpc()
    local _nState      = _data.state
    local taskBeginNpc = _data.sNpc
    local taskEndNpc   = _data.eNpc

    --不可接及以下的都没有icon
    if _nState < _G.Const.CONST_TASK_STATE_ACCEPTABLE then return end

    print("taskUpdate------>>>>  ",taskBeginNpc,taskEndNpc)

    for key, value in pairs( npcArr ) do

        if taskBeginNpc == taskEndNpc and taskBeginNpc == value.npcId then
            value :updateNpcIconState( _data.id, _nState )
            break
        elseif taskBeginNpc == value.npcId then
            if _nState <= _G.Const.CONST_TASK_STATE_UNFINISHED then
                value :updateNpcIconState( _data.id, _nState )
            else
                print("--------asdadasdasdasdasdas------------>>",_data.id,taskBeginNpc)
                value :updateNpcIconState( _data.id, nil )
            end
        elseif taskEndNpc == value.npcId then
            if _nState > _G.Const.CONST_TASK_STATE_UNFINISHED then
                value :updateNpcIconState( _data.id, _nState )
            end
        end
    end
end

function NpcMediator.taskDelete( self, _data )
    CCLOG("NpcMediator.taskDelete-------------->".._data.id)
    local npcArr     = _G.CharacterManager : getNpc()
    local taskEndNpc = _data.eNpc
    for key, value in pairs( npcArr ) do
        print("compari----?>>",taskEndNpc,"====",value.npcId)
        if value.npcId == taskEndNpc then
            value :updateNpcIconState( _data.id, nil )
            break
        end
    end
end

function NpcMediator.searchThisTask( self, _npcId, _taskId )
    print("NpcMediator.searchThisTask---------->",_npcId,_taskId)
    local npcArr = _G.CharacterManager : getNpc()
    for key, value in pairs( npcArr ) do
        if value.npcId == _npcId then
            value :searchThisTaskNow( _taskId )
            break
        end
    end
end

return NpcMediator
