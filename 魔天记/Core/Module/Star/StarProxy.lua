require "Core.Module.Pattern.Proxy"

StarProxy = Proxy:New();

function StarProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpRefineZoneChange, StarProxy.OnUpgrade);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ProductChange, StarProxy.ProductChange);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpFunsion, StarProxy.OnDivination);
end

function StarProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpRefineZoneChange, StarProxy.OnUpgrade);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ProductChange, StarProxy.ProductChange);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpFunsion, StarProxy.OnDivination);
end

function StarProxy.SendUpdate(id)
    local d = {id = id }
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpRefineZoneChange, d)    
end
function StarProxy.SendChange(idx, sid, tid)
    local st = ProductManager.ST_TYPE_IN_TRUMPBAG
    local st2 = ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG
    local pid = PlayerManager.playerId
    local d = {st1 = st , st2 = st2, pt1 = pid, pt2 = pid
        ,idx = idx, id1 = sid, id2 = tid  }
    SocketClientLua.Get_ins():SendMessage(CmdType.Move_Product, d)
end
function StarProxy.SendSpite(ids)
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpGet, {ids = ids})
end
function StarProxy.SendExChange(id)
    local sid = TShopNotes.Shop_type_star
    SocketClientLua.Get_ins():SendMessage(CmdType.TShopExchange, { s = sid, id = id, n = 1 })
end
function StarProxy.SendDivination(f, free) --f：0 一次（缺省），1 十次
    if free then
        StarProxy._SendDivination(f)
        return 
    end
    local c = StarManager.currentDivinationConfig
    local pid = c.req_item
    local pn = BackpackDataManager.GetProductTotalNumBySpid(pid)
    local rn = c.req_num
    if pn >= rn then        
        StarProxy._SendDivination(f)
        return
    end
    local pr = c.item_price
    local pc = ProductManager.GetProductById(pid)
    local cost = (rn - pn) * pr
    MsgUtils.UseGoldConfirm(cost, self, "StarPanel/div/buy" 
        , { n = pc.name, m = cost }
        , function() StarProxy._SendDivination(f) end, nil, nil)
end
function StarProxy._SendDivination(f) --f：0 一次（缺省），1 十次
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpFunsion, {f = f})
end
function StarProxy.OnUpgrade(cmd, data)
    if data.errCode then return end
    StarManager.UpgradeEquip(data)
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_UPGRADE)
end
function StarProxy.ProductChange(cmd, data)
    if not data or data.errCode then return end
    StarManager.UpdateStars(data)
end
function StarProxy.OnDivination(cmd, data)
    if data.errCode then return end
    StarManager.SetDivinationDt(data.star_rt)
    ModuleManager.SendNotification(StarNotes.OPEN_STAR_GET_PANEL, data)
end

