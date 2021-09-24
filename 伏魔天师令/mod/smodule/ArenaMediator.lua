local ArenaMediator = classGc(mediator, function(self, _view)
    self.name = "ArenaMediator"
    self.view = _view

    self:regSelf()
    --self:regSelfLong()
end)

ArenaMediator.protocolsList={
    _G.Msg["ACK_ARENA_DEKARON"],     --挑战玩家的列表
    _G.Msg["ACK_ARENA_DEKARON_NEW"], --挑战玩家的列表 新
    _G.Msg["ACK_ARENA_KILLER_DATA"], --排名奖励列表
    _G.Msg["ACK_ARENA_MAX_DATA"],    --战报信息列表
    _G.Msg["ACK_ARENA_RESULT2"],     --剩余购买次数
    _G.Msg["ACK_ARENA_BUY_OK"],      --剩余挑战次数
    _G.Msg["ACK_ARENA_REWARD_TIMES"],--领取奖励倒计时
    _G.Msg["ACK_ARENA_CD_SEC"],      --战斗cd和挑战次数
    _G.Msg["ACK_ARENA_CLEAN_OK"],    --冷却时间清除成功
    _G.Msg["ACK_ART_HOLIDAY"],      --[16725]精彩活动节日奖励翻倍  
}

ArenaMediator.commandsList=nil
function ArenaMediator.processCommand(self, _command)
end

function ArenaMediator.ACK_ART_HOLIDAY( self,_ackMsg)
    self.view:isDouble(_ackMsg.value)
end

function ArenaMediator.ACK_ARENA_DEKARON(self, _ackMsg)
    print( "-- ACK_ARENA_DEKARON")
    self.view : updateData(_ackMsg)
    self.view : updateSelfCoolTime(_ackMsg.time)
end

function ArenaMediator.ACK_ARENA_DEKARON_NEW(self,_ackMsg)
    print( "-- ACK_ARENA_DEKARON_NEW")
    self.view : updateData(_ackMsg)
    self.view : updateSelfCoolTime(_ackMsg.time)
end

function ArenaMediator.ACK_ARENA_KILLER_DATA(self, _ackMsg)
    print( "-- ACK_ARENA_KILLER_DATA")
    self.view : updateRankMsg(_ackMsg)
end

function ArenaMediator.ACK_ARENA_MAX_DATA(self, _ackMsg)
    print( "-- ACK_ARENA_MAX_DATA")
    self.view : updateCombatMsg(_ackMsg)
end

function ArenaMediator.ACK_ARENA_RESULT2(self, _ackMsg)
    print( "-- ACK_ARENA_RESULT2")
    self.view : updateBuyMsg(_ackMsg)
end

function ArenaMediator.ACK_ARENA_BUY_OK(self, _ackMsg)
    print( "-- ACK_ARENA_BUY_OK")
    self.view : updateSelfChallengeCount(_ackMsg.scount)
end

function ArenaMediator.ACK_ARENA_REWARD_TIMES(self, _ackMsg)
    print( "-- ACK_ARENA_REWARD_TIMES")
    self.view : updateCountdown(_ackMsg.renown,_ackMsg.gold,_ackMsg.times)
end

function ArenaMediator.ACK_ARENA_CD_SEC(self, _ackMsg)
    print( "-- ACK_ARENA_CD_SEC")
    self.view : getCoolState(_ackMsg)
end

function ArenaMediator.ACK_ARENA_CLEAN_OK(self, _ackMsg)
    print( "-- ACK_ARENA_CLEAN_OK")
    self.view : updateSelfCoolTime(0)
end

return ArenaMediator