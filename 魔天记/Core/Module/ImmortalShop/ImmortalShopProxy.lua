require "Core.Module.Pattern.Proxy"

ImmortalShopProxy = Proxy:New();
ImmortalShopProxy.data = nil
local timer = nil
local endTime = 0
function ImmortalShopProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalShopList, ImmortalShopProxy.ImmortalShopList)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalShopBuy, ImmortalShopProxy.ImmortalShopList)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalShopRefresh, ImmortalShopProxy.ImmortalShopRefresh)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalShopRank, ImmortalShopProxy.ImmortalShopRank)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalRevelry, ImmortalShopProxy.ImmortalRevelry)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalRevelryGet, ImmortalShopProxy.ImmortalRevelryGet)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ImmortalRevelryChange, ImmortalShopProxy.ImmortalRevelryChange)
end

function ImmortalShopProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalShopList, ImmortalShopProxy.ImmortalShopList)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalShopBuy, ImmortalShopProxy.ImmortalShopList)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalShopRefresh, ImmortalShopProxy.ImmortalShopRefresh)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalShopRank, ImmortalShopProxy.ImmortalShopRank)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalRevelry, ImmortalShopProxy.ImmortalRevelry)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalRevelryGet, ImmortalShopProxy.ImmortalRevelryGet)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ImmortalRevelryChange, ImmortalShopProxy.ImmortalRevelryChange)
end

function ImmortalShopProxy.SendImmortalShopList()
    SocketClientLua.Get_ins():SendMessage(CmdType.ImmortalShopList);
    --ImmortalShopProxy.test3() ImmortalShopProxy.test()
end
function ImmortalShopProxy.SendImmortalShopBuy(id, cost, na)
    local buyfunc = function()
        SocketClientLua.Get_ins():SendMessage(CmdType.ImmortalShopBuy, { id = id });
    end
    MsgUtils.UseGoldConfirm(cost, self, "common/bgoldBuy"
            , { num = cost, pn = na }, buyfunc, nil, nil,nil,nil,nil,2)
	--ImmortalShopProxy.test(id)
end
function ImmortalShopProxy.test(id)
    local d = { }
    for i = 1, 8 do table.insert(d, { id = i, t = i * 100, n = id == i and (i-1) or i }) end
    ImmortalShopProxy.ImmortalShopList(cmd, { l = d })
end
function ImmortalShopProxy.SendImmortalShopRank()
    SocketClientLua.Get_ins():SendMessage(CmdType.ImmortalShopRank);
--ImmortalShopProxy.test2()
end
function ImmortalShopProxy.test2()
    local d = { l = {}, idx = 0, v = 33333, f = 'aaa' }
    for i = 1, 20 do table.insert(d.l, { idx = i, v = i * 99999 }) end
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_INFO, d)
end
-- l:{id:限购ID,t:剩余总数,n:当前购买次数}
function ImmortalShopProxy.ImmortalShopList(cmd, data)
    if data.errCode then return end
    local d = data.l
    if not d or #d == 0 then
        if timer then timer:Stop() timer = nil end
        return
    end
    endTime = ImmortalShopProxy.GetProductEndTime(d[1].id)
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_LIST, d)
    ImmortalShopProxy.SetRefreshStoreTime()
end
function ImmortalShopProxy.ImmortalShopRefresh(cmd, data)
    if data.errCode then return end
    ImmortalShopProxy.SetRedPoint(true)
end
--[[l:[{idx:排行,v:金额}]排行版数据
idx:排名（-1:标示没上榜）
v:金额
f:第一名名字--]]
function ImmortalShopProxy.ImmortalShopRank(cmd, data)
    if data.errCode then return end
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_SHOP_RANK_INFO, data)
end
function ImmortalShopProxy.GetEndTime()
    return endTime
end


function ImmortalShopProxy.SendImmortalRevelry()
    SocketClientLua.Get_ins():SendMessage(CmdType.ImmortalRevelry);
--ImmortalShopProxy.test3()
end
function ImmortalShopProxy.test3()
    local d = { l = {}, l2 = {}, v = math.random(1,2000 ) }
    for i = 1, 10 do if math.random(1,2) > 1 then table.insert(d.l, i) end end
    for i = 1, 10 do table.insert(d.l2, {id=i,v=math.random(0,200)}) end
    ImmortalShopProxy.data = d
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_INFO, d)
end
function ImmortalShopProxy.SendImmortalRevelryGet(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.ImmortalRevelryGet, { id = id })
--ImmortalShopProxy.data.v = math.random(1,1000)
--ImmortalShopProxy.ImmortalRevelryGet(cmd, {id = id})
end
-- v:我的狂欢点
function ImmortalShopProxy.ImmortalRevelryChange(cmd, data)
    if not data or data.errCode then return end
    if not ImmortalShopProxy.data then ImmortalShopProxy.data = {} end
    ImmortalShopProxy.data.v = data.v
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_CHANGE, ImmortalShopProxy.data)
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE)
end
--l:[id1,id2...] 已领取狂欢奖励配置项 id列表
--l2:[{id:id列表,v:狂欢点}] 狂欢记录
--v:我的狂欢点
function ImmortalShopProxy.ImmortalRevelry(cmd, data)
    if data.errCode then return end
    ImmortalShopProxy.data = data
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_INFO, data)
end
function ImmortalShopProxy.ImmortalRevelryGet(cmd, data)
    if data.errCode then return end
    table.insert(ImmortalShopProxy.data.l, data.id)
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_REVELRY_CHANGE, ImmortalShopProxy.data )
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE)
end



local cfProducts
local cfConsume
local cfAll
local cfPoint
function ImmortalShopProxy._GetProductConfigs()
    if not cfProducts then cfProducts = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_IMMORTAL_SHOP_LIST) end
    return cfProducts
end
function ImmortalShopProxy._GetConsumeConfigs()
    if not cfConsume then cfConsume = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_IMMORTAL_SHOP_CONSUME) end
    return cfConsume
end
function ImmortalShopProxy.GetAllConfigs()
    if not cfAll then cfAll = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_IMMORTAL_SHOP_ALL) end
    return cfAll
end
function ImmortalShopProxy.GetPointConfigs()
    if not cfPoint then cfPoint = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_IMMORTAL_SHOP_POINT) end
    return cfPoint
end
function ImmortalShopProxy.GetProductConfig(id)
    return ImmortalShopProxy._GetProductConfigs()[id]
end
function ImmortalShopProxy.GetProductEndTime(id)
    local c = ImmortalShopProxy.GetProductConfig(id)
    local endTime = GetTimestamp2(c.end_time)
   
    return endTime;
end
function ImmortalShopProxy.GetRankMinConsume()
    return ImmortalShopProxy._GetConsumeConfigs()[1].minconsume
end
function ImmortalShopProxy.GetRankSpriteName(rank)
    local c = ImmortalShopProxy._GetConsumeConfigs()[rank]
    return c and c.icon or ''
end
function ImmortalShopProxy.GetRankAward(rank)
    local c = ImmortalShopProxy._GetConsumeConfigs()[rank]
    local rs = c and c.item_id or {}
    return ProductInfo.GetProductInfos(rs)
end

local redPoint = true
function ImmortalShopProxy.GetRedPoint()
    --Warning(tostring(redPoint) .. '--ImmortalShopProxy--' .. tostring(ImmortalShopProxy.GetRevelryRedPoint()))
    return redPoint or ImmortalShopProxy.GetRevelryRedPoint()
end
function ImmortalShopProxy.GetBuyRedPoint()
    return redPoint
end
function ImmortalShopProxy.GetRevelryRedPoint()
    local f = false
    if ImmortalShopProxy.data then
        local v = ImmortalShopProxy.data.v
        local l = ImmortalShopProxy.data.l
        local cs = ImmortalShopProxy.GetAllConfigs()
        for k, c in pairs(cs) do
            --Warning(c.need_point .."-".. v ..'--'..tostring(table.contains(l, c.id)))
            if c.need_point <= v then
                if not table.contains(l, c.id) then 
                    f = true
                    break
                end
            end
        end
    end
    return f
end
function ImmortalShopProxy.SetRedPoint(v)
    redPoint = v
    MessageManager.Dispatch(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE)
end

function ImmortalShopProxy.SetRefreshStoreTime()
    if timer then timer:Stop() timer = nil end
    if endTime - GetTime() > 0 then
        timer = Timer.New(function() ImmortalShopProxy._RefreshStore() end, 1, -1, true)
        timer:Start()
    end
end
function ImmortalShopProxy._RefreshStore()
    --Warning( os.date('%c', endTime) .. '_____' .. os.date('%c', GetTime()))
    if endTime - GetTime() > 0 then return end
    timer = nil 
    ImmortalShopProxy.SendImmortalShopList()
    ImmortalShopProxy.SetRedPoint(true)
end
