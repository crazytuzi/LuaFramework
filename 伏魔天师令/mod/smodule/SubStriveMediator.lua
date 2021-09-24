local SubStriveMediator = classGc(mediator, function(self, _view)
    self.name = "SubStriveMediator"
    self.view = _view

    self:regSelf()
end)

SubStriveMediator.protocolsList={
    _G.Msg["ACK_WRESTLE_REPLY_GUESS"],	 --欢乐竞猜界面返回
    _G.Msg["ACK_WRESTLE_GUESS_TOTAL"],   --欢乐竞猜总竞猜金额
    _G.Msg["ACK_WRESTLE_GROUP_XXX"],     --其他小组信息
    _G.Msg["ACK_WRESTLE_REPLY_MY_GAME"], --我的比赛
    _G.Msg["ACK_WRESTLE_REPLY_KING"],    --巅峰对决
    _G.Msg["ACK_WRESTLE_TIME"],          --时间倒计时
    _G.Msg["ACK_WRESTLE_REPLY"],--报名成功

}

SubStriveMediator.commandsList=nil

function SubStriveMediator.processCommand(self, _command)
end

function SubStriveMediator.ACK_WRESTLE_REPLY_GUESS(self, _ackMsg)
	print("ACK_WRESTLE_REPLY_GUESS")
	self.view : __initGuessView(_ackMsg)
end

function SubStriveMediator.ACK_WRESTLE_GUESS_TOTAL(self, _ackMsg)
	print("ACK_WRESTLE_GUESS_TOTAL")
	self.view : updateAllRMB(_ackMsg.rmb)
end

function SubStriveMediator.ACK_WRESTLE_GROUP_XXX(self, _ackMsg)
	print("ACK_WRESTLE_GROUP_XXX")
	self.view : __initRankLayer(_ackMsg.group_id,_ackMsg.data)
end

function SubStriveMediator.ACK_WRESTLE_REPLY_MY_GAME(self, _ackMsg)
	print("ACK_WRESTLE_REPLY_MY_GAME")
	print("uid",_ackMsg.uid)
	print("name",_ackMsg.name)
	print("powerful",_ackMsg.powerful)
	print("pro",_ackMsg.pro)
	print("lv",_ackMsg.lv)
	print("turn",_ackMsg.turn)
	self.view : initGameView(_ackMsg)
end

function SubStriveMediator.ACK_WRESTLE_REPLY_KING(self, _ackMsg)
	print("ACK_WRESTLE_REPLY_KING")
	print("pos",_ackMsg.pos)
	print("name",_ackMsg.name)
	print("powerful",_ackMsg.powerful)
	print("pro",_ackMsg.pro)
	print("lv",_ackMsg.lv)
	print("turn",_ackMsg.count)
	for k,v in pairs(_ackMsg.result) do
		print(k,v)
	end

	if self.msg==nil then
		self.msg = {}
	end
	
	self.msg[_ackMsg.pos] = _ackMsg

	if #self.msg >1 then
		print("创建巅峰对决面板")
		self.view : initGameView(self.msg)
		self.msg=nil
	end
end

function SubStriveMediator.ACK_WRESTLE_TIME(self, _ackMsg)
	print("ACK_WRESTLE_TIME")
	print("state_time",_ackMsg.state)
	print("time",_ackMsg.time)
	print("state2_time",_ackMsg.state2)
	print("round",_ackMsg.round)
	self.view : updateTime(_ackMsg)
end

function SubStriveMediator.ACK_WRESTLE_REPLY(self, _ackMsg)
    print( "-- ACK_WRESTLE_REPLY","   type: ",_ackMsg.type,_ackMsg.turn,_ackMsg.count)

    if _ackMsg.type == 1 then
    	self.view : initSignUp(_ackMsg)
    else
    	self.view : __closeWindow()
    	cc.Director : getInstance() : popScene()
    	_G.GLayerManager : startOpenLayer(_G.Cfg.UI_SubStriveView,nil,_ackMsg,nil,nil)
    end
end
return SubStriveMediator