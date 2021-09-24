local LingYaoMediator = classGc(mediator, function(self, _view)
    self.name = "LingYaoMediator"
    self.view = _view

    self:regSelf()
    --self:regSelfLong()
end)

LingYaoMediator.protocolsList={
    _G.Msg["ACK_LINGYAO_ARENA_DEKARON"],     --挑战玩家的列表
    _G.Msg["ACK_LINGYAO_ARENA_TIMES"], --挑战玩家的列表 新
    _G.Msg["ACK_LINGYAO_ARENA_RANK_REPLY"], --排名奖励列表
    _G.Msg["ACK_LINGYAO_ARENA_REPORT_REPLY"],    --战报信息列表
    _G.Msg["ACK_LINGYAO_ARENA_BUY_REPLY"],     --剩余购买次数
    _G.Msg["ACK_LINGYAO_ARENA_TIMES"],      --剩余挑战次数
    _G.Msg["ACK_LINGYAO_ARENA_REWARD_DATA"],--领取奖励倒计时
    _G.Msg["ACK_LINGYAO_ARENA_CD_SEC"],      --战斗cd和挑战次数
    _G.Msg["ACK_LINGYAO_ARENA_CD_CLEAN_OK"],    --冷却时间清除成功
    _G.Msg["ACK_ART_HOLIDAY"],      --[16725]精彩活动节日奖励翻倍  
    _G.Msg["ACK_LINGYAO_ARENA_DEF_REPLY"],      --[25115]防守阵容 
    _G.Msg["ACK_LINGYAO_REPLY"],      --[31120]灵妖列表 
    _G.Msg["ACK_LINGYAO_ARENA_RIVAL_REPLY"],      --[25045]敌方阵容 
}

LingYaoMediator.commandsList=nil
function LingYaoMediator.processCommand(self, _command)
end

function LingYaoMediator.ACK_ART_HOLIDAY( self,_ackMsg)
    self.view:isDouble(_ackMsg.value)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_DEKARON(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_DEKARON")
    self.view : updateData(_ackMsg)
    self.view : updateSelfCoolTime(_ackMsg.time)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_TIMES(self,_ackMsg)
    print( "-- ACK_LINGYAO_ARENA_TIMES",_ackMsg.times)
    self.view : updateSelfChallengeCount(_ackMsg.times)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_RANK_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_RANK_REPLY")
    self.view : updateRankMsg(_ackMsg)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_REPORT_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_REPORT_REPLY")
    self.view : updateCombatMsg(_ackMsg)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_BUY_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_BUY_REPLY")
    self.view : updateBuyMsg(_ackMsg.times)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_TIMES(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_TIMES")
    self.view : updateSelfChallengeCount(_ackMsg.times)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_REWARD_DATA(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_REWARD_DATA")
    self.view : updateCountdown(_ackMsg.goods_id,_ackMsg.count_all,_ackMsg.count,_ackMsg.time)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_CD_SEC(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_CD_SEC")
    self.view : getCoolState(_ackMsg)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_CD_CLEAN_OK(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_CD_CLEAN_OK")
    self.view : updateSelfCoolTime(0)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_DEF_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_DEF_REPLY",_ackMsg.count)
    self.view : updateDefend(_ackMsg.def_data,1)
end

function LingYaoMediator.ACK_LINGYAO_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_REPLY",_ackMsg.count)
    self.view : createScrollView(_ackMsg)
end

function LingYaoMediator.ACK_LINGYAO_ARENA_RIVAL_REPLY(self, _ackMsg)
    print( "-- ACK_LINGYAO_ARENA_RIVAL_REPLY",_ackMsg.uid,_ackMsg.count)
    if _ackMsg.uid==0 then
        self.view : updateDefend(_ackMsg.reval_data)
    else
        self.view : updateDiFang(_ackMsg.reval_data)
    end
end

return LingYaoMediator