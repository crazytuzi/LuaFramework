
local Model = {}


function Model.getRedPacketListRequest(cb)
	Pomelo.RedPacketHandler.getRedPacketListRequest(function(ex,sjson)
		if not ex then
			local param = sjson:ToData()
			cb(param)
		end
	end)
end

function Model.getRedPacketDetailRequest(id,cb)
	Pomelo.RedPacketHandler.getRedPacketDetailRequest(id,function(ex,sjson)
		if not ex then
			local param = sjson:ToData()
			cb(param)
		end
	end)
end

function Model.dispatchRedPacketRequest(count,totalNum,channelType,fetchType,benifitType,msg,cb)
	Pomelo.RedPacketHandler.dispatchRedPacketRequest(count,totalNum,channelType,fetchType,benifitType,msg,function(ex,sjson)
		if not ex then
			local param = sjson:ToData()
			cb(param)
		end
	end)
end

function Model.fetchRedPacketRequest(id,cb)
	Pomelo.RedPacketHandler.fetchRedPacketRequest(id,function(ex,sjson)
		if not ex then
			local param = sjson:ToData()
			cb(param)
		end
	end)
end

function Model.OnRedPacketDispatchPush(ex, sjson)
    EventManager.Fire("Event.redPacketHandler.onRedPacketDispatchPush", sjson:ToData())
end

function Model.InitNetWork()
    Pomelo.RedPacketHandler.onRedPacketDispatchPush(Model.OnRedPacketDispatchPush)
end


return Model
