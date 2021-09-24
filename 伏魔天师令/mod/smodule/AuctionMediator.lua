local AuctionMediator = classGc(mediator, function(self, _view)
    self.name = "AuctionMediator"
    self.view = _view

    self:regSelf()
end)

AuctionMediator.protocolsList={
    _G.Msg["ACK_AUCTION_REPLY"],	     --面板回复
}

AuctionMediator.commandsList=nil
function AuctionMediator.processCommand(self, _command)
end

function AuctionMediator.ACK_AUCTION_REPLY(self, _ackMsg)
    print( "-- ACK_AUCTION_REPLY")
    print("count",_ackMsg.count)
    -- for i=1,5 do
    -- 	print("id",_ackMsg.data[i].id)
    -- 	print("rmb",_ackMsg.data[i].rmb)
    -- 	print("flag",_ackMsg.data[i].flag)
    -- 	if _ackMsg.data[i].flag == 1 then
    -- 		print("next_rmb",_ackMsg.data[i].next_rmb)
    -- 	elseif _ackMsg.data[i].flag == 2 then
    -- 		print("time",_ackMsg.data[i].time)
    -- 		print("next_rmb",_ackMsg.data[i].next_rmb)
    -- 		print("name",_ackMsg.data[i].name)
    --         print("expend_bind",_ackMsg.data[i].expend_bind)
    --         print("expend_rmb",_ackMsg.data[i].expend_rmb)
    -- 	elseif _ackMsg.data[i].flag == 3 then
    -- 		print("name",_ackMsg.data[i].name)
    -- 	elseif _ackMsg.data[i].flag == 4 then
    -- 		print("next_rmb",_ackMsg.data[i].next_rmb)
    -- 	end
    -- end
    self.view : updateData(_ackMsg)
end

return AuctionMediator