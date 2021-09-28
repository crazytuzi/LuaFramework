require "Core.Module.Pattern.Proxy"

FestivalProxy = Proxy:New()
function FestivalProxy:OnRegister()
    local sc = SocketClientLua.Get_ins()
    sc:AddDataPacketListener(CmdType.YYGetActvityInfo, FestivalProxy.YYGetActvityInfo)
    sc:AddDataPacketListener(CmdType.YYExChange, FestivalProxy.YYExChange)
    sc:AddDataPacketListener(CmdType.YYLoginGet, FestivalProxy.YYLoginGet)
    sc:AddDataPacketListener(CmdType.YYRechargeGet, FestivalProxy.YYRechargeGet)
    sc:AddDataPacketListener(CmdType.GetTotalRechageAward, FestivalProxy.GetTotalRechageAward)
    sc:AddDataPacketListener(CmdType.YYRechargeChange, FestivalProxy.YYRechargeChange)
end
function FestivalProxy:OnRemove()
    local sc = SocketClientLua.Get_ins()
    sc:RemoveDataPacketListener(CmdType.YYGetActvityInfo, FestivalProxy.YYGetActvityInfo)
    sc:RemoveDataPacketListener(CmdType.YYExChange, FestivalProxy.YYExChange)
    sc:RemoveDataPacketListener(CmdType.YYLoginGet, FestivalProxy.YYLoginGet)
    sc:RemoveDataPacketListener(CmdType.YYRechargeGet, FestivalProxy.YYRechargeGet)
    sc:RemoveDataPacketListener(CmdType.GetTotalRechageAward, FestivalProxy.GetTotalRechageAward)
    sc:RemoveDataPacketListener(CmdType.YYRechargeChange, FestivalProxy.YYRechargeChange)
end
function FestivalProxy.YYGetActvityInfo(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetData(data)
end
function FestivalProxy.YYExChange(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetExchangeData(data)
end
function FestivalProxy.YYLoginGet(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetLoginData(data)
end
function FestivalProxy.YYRechargeGet(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetRechargeData(data)
end
function FestivalProxy.GetTotalRechageAward(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetGetRecharge(data)
end
function FestivalProxy.YYRechargeChange(cmd, data)
    if data.errCode then return end
    FestivalMgr.SetRechargeSum(data)
end

function FestivalProxy.SendYYGetActvityInfo()
    --FestivalMgr.Test()
    SocketClientLua.Get_ins():SendMessage(CmdType.YYGetActvityInfo)
end
function FestivalProxy.SendYYExChange(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.YYExChange, { id = id })
end
function FestivalProxy.SendYYLoginGet(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.YYLoginGet, { id = id })
end
function FestivalProxy.SendYYRechargeGet(id)
    --SocketClientLua.Get_ins():SendMessage(CmdType.YYRechargeGet, { id = id })
    SocketClientLua.Get_ins():SendMessage(CmdType.GetTotalRechageAward, { id = id })
end

