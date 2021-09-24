local FriendProxyMediator = classGc(mediator,function(self,_view)
	self.name="FriendProxyMediator"
	self.view=_view
	self:regSelfLong()
end)

FriendProxyMediator.protocolsList={
	_G.Msg.ACK_FRIEND_INFO,
	_G.Msg.ACK_FRIEND_DEL_OK,
	_G.Msg.ACK_FRIEND_ADD_SUCCESS,
	_G.Msg.ACK_FRIEND_ADD_NOTICE,
	_G.Msg.ACK_FRIEND_SYS_FRIEND,
	_G.Msg.ACK_TEAM_INVITE_NOTICE, -- (手动) -- [3700]邀请好友返回 -- 组队系统
}

FriendProxyMediator.commandsList=nil

function FriendProxyMediator.ACK_FRIEND_INFO( self, _ackMsg)
    self:getView():setFriendAllList(_ackMsg.data,_ackMsg.type)
end

function FriendProxyMediator.ACK_FRIEND_ADD_SUCCESS(self,_ackMsg)
	print("add success -->",_ackMsg.uid,_ackMsg.type)

	if _ackMsg.type==_G.Const.CONST_FRIEND_FRIEND then
		self.view:removeThisBlackFriend(_ackMsg.uid)
	elseif _ackMsg.type==_G.Const.CONST_FRIEND_BLACKLIST then
		self.view:removeThisFriend(_ackMsg.uid)
	end
	local msg=REQ_FRIEND_REQUES()
    msg:setArgs(_ackMsg.type)
    _G.Network:send(msg)

    local command=CErrorBoxCommand("添加成功!")
	controller:sendCommand(command)
end

function FriendProxyMediator.ACK_FRIEND_DEL_OK(self, _ackMsg)
	print("del friend ok -->",_ackMsg.uid)
	local itemList=self.view:getDatalList(_ackMsg.type)
	print("del friend ok -->",#itemList)
	for i,v in ipairs(itemList) do
		print(i,v.id)
		if _ackMsg.uid==v.id then
			table.remove(itemList,i)
			break
		end
	end
	print("del friend ok -->",#itemList)
	self:getView():setFriendAllList(itemList,_ackMsg.type)

	if _ackMsg.type==5 then
		local command=CErrorBoxCommand("解除成功!")
		controller:sendCommand(command)
	else
		local command=CErrorBoxCommand("删除成功!")
		controller:sendCommand(command)
	end

end

-- test here
function FriendProxyMediator.ACK_FRIEND_SYS_FRIEND( self, _ackMsg)
	if _G.GLayerManager==nil then return end
	print("ACK_FRIEND_SYS_FRIEND ---->",_ackMsg.count)
	_G.GLayerManager:addSubView(_G.GLayerManager.type_recommendFriend,_ackMsg.msg_role_xxx)
end

function FriendProxyMediator.ACK_FRIEND_ADD_NOTICE(self,_ackMsg)
	print("4090 -->",_ackMsg.uid,_ackMsg.name)
	-- local msg=REQ_FRIEND_REQUES
end

function FriendProxyMediator.ACK_TEAM_INVITE_NOTICE( self, _ackMsg )
    print("在主界面的CMainUIMediator 收到了好友邀请协议")
    self.view:addInviteTeamData(_ackMsg)
end

return FriendProxyMediator
