local DaoJieMediator = classGc(mediator,function(self, _view)
	self.name = "DaoJieMediator"
	self.view = _view
	self:regSelf() 
end)


DaoJieMediator.protocolsList={
    _G.Msg.ACK_HOOK_RETURN,       --返回解锁章节
    _G.Msg.ACK_HOOK_CHAP_DATA,    --章节信息
    --_G.Msg.ACK_HOOK_ENTER,
    _G.Msg.ACK_HOOK_MSG_BACK  , -- 求副本信息返回
    _G.Msg.ACK_THOUSAND_WAR_REPLY,
    _G.Msg.ACK_COPY_COPY_OPEN_REPLY,



   --[[
	_G.Msg.ACK_THOUSAND_REPLY, 
	_G.Msg.ACK_THOUSAND_REPLY_BUY,
	_G.Msg.ACK_THOUSAND_BUY_SUCCESS,
	_G.Msg.ACK_THOUSAND_WAR_REPLY,
	_G.Msg.ACK_THOUSAND_REPLY_RANK,
	_G.Msg.ACK_COPY_THROUGH,
 -- ]]
}

DaoJieMediator.commandsList = nil

function DaoJieMediator.ACK_HOOK_MSG_BACK(self,_ackMsg)
    print("ACK_HOOK_MSG_BACK--->",_ackMsg.flag)
    self : getView() : pushCopyData(_ackMsg.flag,_ackMsg.value)
end 
function DaoJieMediator.ACK_HOOK_RETURN(self,_ackMsg)
  print("ACK_HOOK_RETURN-->解锁章节",_ackMsg.alltimes,_ackMsg.times,_ackMsg.chap_id,_ackMsg.count,_ackMsg.chaps,#_ackMsg.chaps)
  print("通关副本id-->",_ackMsg.count2,_ackMsg.copys,#_ackMsg.copys)
  self : getView() : pushDada (_ackMsg)
end


--[[
function DaoJieMediator.ACK_HOOK_CHAP_DATA(self,_ackMsg)
   print("ACK_HOOK_CHAP_DATA-->章节信息",_ackMsg.chap_id,_ackMsg.count)	
  -- self : getView() : pushData(_ackMsg)
end

function DaoJieMediator.ACK_HOOK_COPY_DATA(self,_ackMsg)
   --print("ACK_HOOK_COPY_DATA-->副本信息",_ackMsg.id,_ackMsg.flag)	
   
end 
--]]
return DaoJieMediator