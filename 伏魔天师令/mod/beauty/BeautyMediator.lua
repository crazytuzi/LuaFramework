local BeautyMediator = classGc(mediator,function ( self,_view )
	self.name = "BeautyMediator"
	self.view = _view

	self:regSelf()
end)

BeautyMediator.protocolsList={
    _G.Msg["ACK_MEIREN_MAIN_ATTR"],	     --面板回复
    _G.Msg["ACK_MEIREN_MID"],
    _G.Msg["ACK_MEIREN_GENSUI_MEIREN"],		 
}

BeautyMediator.commandsList=nil
function BeautyMediator.processCommand(self, _command)
end

function BeautyMediator.ACK_MEIREN_MAIN_ATTR(self, _ackMsg)
	print("怒气：",_ackMsg.sp)
	print("气血：",_ackMsg.hp)
	print("攻击：",_ackMsg.att)
	print("防御：",_ackMsg.def)
	print("破甲：",_ackMsg.wreck)
	print("命中：",_ackMsg.hit)
	print("闪避：",_ackMsg.dod)
	print("暴击：",_ackMsg.crit)
	print("抗暴：",_ackMsg.crit_res)
	print("伤害率：",_ackMsg.bonus)
	print("免伤率：",_ackMsg.reduction)
	self.view : updateAttr(_ackMsg)
end

function BeautyMediator.ACK_MEIREN_MID(self, _ackMsg)
	print("==========asdfasdfas==========")
	print("count",_ackMsg.count)
	for k,v in pairs(_ackMsg.msg) do
		print("激活的",k,v)
	end
	self.view:updateActivate(_ackMsg)
end

function BeautyMediator.ACK_MEIREN_GENSUI_MEIREN(self, _ackMsg)
	print("==========ACK_MEIREN_GENSUI_MEIREN==========")
	print("跟随ID",_ackMsg.id)
	self.view:updateFollow(_ackMsg.id)
end

return BeautyMediator