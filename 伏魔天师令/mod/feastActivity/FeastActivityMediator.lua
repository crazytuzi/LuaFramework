local FeastActivityMediator = classGc(mediator,function(self, _view)
	self.name = "FeastActivityMediator"
	self.view = _view
	self:regSelf() 
end)

FeastActivityMediator.protocolsList = {
   	_G.Msg.ACK_GALATURN_FUN_CB,       -- 节日活动返回（22311）
   	_G.Msg.ACK_GALATURN_IN,           -- 大转盘面板（22312） 
   	_G.Msg.ACK_GALATURN_LOT_SUCCESS,  -- 抽奖（22322）
   	_G.Msg.ACK_GALATURN_RANK_IN,  	  -- 排名（22332）
   	_G.Msg.ACK_FESTIVAL_OK,			      -- 领取成功（16022）
   	_G.Msg.ACK_FESTIVAL_OPEN,		      -- 购买成功（16032）
   	_G.Msg.ACK_FESTIVAL_COLLECT_REP,  -- 收集返回（16012）
    _G.Msg.ACK_REWARD_LOGIN_REPLY,    -- 登录送礼数据 (23660) 
    _G.Msg.ACK_REWARD_LOGIN_SUCCESS,  -- 登录送礼 (23645)
    _G.Msg.ACK_GALATURN_ICON_CB,      -- 角标返回
    _G.Msg.ACK_COPY_MONEY_REPLY,      -- 铜兽来袭挑战次数
}

function FeastActivityMediator.ACK_GALATURN_FUN_CB( self, _askMsg )
	print("活动类型:",_askMsg.count)
	self:getView():LeftBtnView(_askMsg.count,_askMsg.msg)
end

function FeastActivityMediator.ACK_GALATURN_IN( self, _askMsg )
	print("ACK_GALATURN_IN",_askMsg.times,_askMsg.selfrank,_askMsg.point,_askMsg.count)
    self:getView():setDZPData(_askMsg)
end

function FeastActivityMediator.ACK_GALATURN_LOT_SUCCESS( self, _askMsg )
	print("ACK_GALATURN_LOT_SUCCESS",_askMsg.id_sub,_askMsg.type,_askMsg.id)
    self:getView():DZPRewardData(_askMsg.id_sub,_askMsg.type,_askMsg.id)
end

function FeastActivityMediator.ACK_GALATURN_RANK_IN( self, _askMsg )
	print("ACK_GALATURN_RANK_IN",_askMsg.selfrank,_askMsg.count,_askMsg.count2)
    self:getView():DZPRankData(_askMsg)
end

function FeastActivityMediator.ACK_FESTIVAL_OK( self, _askMsg )
	print("ACK_FESTIVAL_OK",_askMsg.id)
    self:getView():FESTIVALOK(_askMsg.id)
end

function FeastActivityMediator.ACK_FESTIVAL_OPEN( self, _askMsg )
	print("ACK_FESTIVAL_OPEN",_askMsg.id)
    self:getView():FESTIVALOPEN(_askMsg.id)
end

function FeastActivityMediator.ACK_FESTIVAL_COLLECT_REP( self, _askMsg )
	print("ACK_FESTIVAL_COLLECT_REP",_askMsg.count)
    self:getView():YZQJCOLLECT(_askMsg.count,_askMsg.packslist)
end

function FeastActivityMediator.ACK_REWARD_LOGIN_REPLY( self,_askMsg )
  print("ACK_REWARD_LOGIN_REPLY",_askMsg.time_end,_askMsg.state)
    self:getView():LoginReply(_askMsg)
end

function FeastActivityMediator.ACK_REWARD_LOGIN_SUCCESS( self )
  print("ACK_REWARD_LOGIN_SUCCESS")
    self:getView():LoginReward()
end

function FeastActivityMediator.ACK_GALATURN_ICON_CB( self,_ackMsg )
  print("ACK_GALATURN_ICON_CB",_ackMsg.count,_ackMsg.msg)
  self:getView():ReturnTimes(_ackMsg.count,_ackMsg.msg)
end

function FeastActivityMediator.ACK_COPY_MONEY_REPLY( self, _askMsg )
    self:getView():COPY_TIME(_askMsg)
end

return FeastActivityMediator