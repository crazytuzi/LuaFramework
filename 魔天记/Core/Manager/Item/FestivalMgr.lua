FestivalMgr = { } --运营活动
FestivalMgr.Type_Mid_Autumn = 4 -- 中秋活动充值类型

local d
--t:累计登陆天数（中秋活动期间）
--l：{[idx:领取记录]} 1开始 登陆奖励
--l2:{[id:换取项,num:换取次数]}收集道具
--sum：累计充值
--l3:{[id:礼包ID，s:状态（1：获得2：已领取）]}累计充值礼包记录 
function FestivalMgr.SetData(dt)
    d = dt
    PrintTable(d,'--FestivalMgr--',Warning)
    --FestivalMgr.Test()
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.Test()
    d = ({
        t = 6, sum = 5000
        ,l = {1,3,4}
        ,l2 = {{id=1,num=10},{id=5,num=1}}
        ,l3 = {{id=352,s=1},{id=353,s=1},{id=356,s=2}}
    })
end
function FestivalMgr.SetRechargeSum(dt)
    if not d then return end
    d.sum = dt.sum
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.SetRechargeData(dt)
    d.l3 = dt.l
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.SetGetRecharge(dt)
    if not d then return end
    local ds = d.l3
    local id = dt.id
    for i = #ds, 1, -1 do if ds[i].id == id then
        table.remove(ds, i)
        break
    end end
    table.insert(ds, { id = id, s = 1 })
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.SetExchangeData(dt)
    d.l2 = dt.l
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.SetLoginData(dt)
    d.l = dt.l
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.AddLoginDay()
    if not d then return end
    d.t = d.t + 1
    MessageManager.Dispatch(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE)
end
function FestivalMgr.GetRechargeSum()
    if not d then return 0 end
    return d.sum
end
function FestivalMgr.GetLoginDay()
    if not d then return 0 end
    return d.t
end
function FestivalMgr.GetExchangeTime(id)
    if not d then return 0 end
    local ds = d.l2
    for i = #ds, 1, -1 do if ds[i].id == id then return ds[i].num end end
    return 0
end
function FestivalMgr.GetChargeState(id, cost) --0未完成, 1未领取,2已领取
    if not d then return 0 end
    local ds = d.l3
    for i = #ds, 1, -1 do if ds[i].id == id then
        local s = ds[i].s --0：未领取1：已领取2：邮件发送)
        return s == 0 and 1 or 2
    end end
    if d.sum >= cost then return 1 end
    return 0
end
function FestivalMgr.GetLoginState(id) --0未完成, 1未领取,2已领取
    if not d then return 0 end
    return d.t < id and 0 or (table.contains(d.l, id) and 2 or 1)
end
function FestivalMgr.GetScollviewV()
    if not d then return 0 end
    local l = #FestivalMgr.GetConfigs()
    --d.t = math.random(1, 10) Warning(d.t .. '----' .. l)
    return (d.t == 1 and 0 or (d.t == l and d.t  + 1 or d.t - 1)) / l
end
function FestivalMgr.GetDefSelect()
    if not d then return 1 end
    return d.t == 0 and 1 or d.t
end

local cfs -- mid_autumn
local cfsExchange -- item_exchange 
local cfsRecharge -- recharge_reward 
local cfsMidRecharge 
function FestivalMgr.GetConfigs()
    if not cfs then cfs = ConfigManager.GetConfig(ConfigManager.CONFIG_MID_AUTUMN) end
    return cfs
end
function FestivalMgr.GetConfigById(id)
    return FestivalMgr.GetConfigs()[id]
end
function FestivalMgr.GetExchangeConfigs()
    if not cfsExchange then cfsExchange = ConfigManager.GetConfig(ConfigManager.CONFIG_MID_EXCHANGE) end
    return cfsExchange
end
function FestivalMgr.GetExchangeConfigById(id)
    return FestivalMgr.GetExchangeConfigs()[id]
end
function FestivalMgr.GetRechargeConfigs(t)
    if not cfsRecharge then
        cfsRecharge = ConfigManager.GetConfig(ConfigManager.CONFIG_MID_RECHARGE) 
    end
    local res = cfsRecharge
    if t then
        res = {}
        for k, v in pairs(cfsRecharge) do
            if v .type == t then table.insert(res, v) end
        end
        table.sort(res, function(a,b) return a.id < b.id end)
    end
    return res
end
function FestivalMgr.GetRechargeConfigById(id)
    return FestivalMgr.GetRechargeConfigs()[id]
end
function FestivalMgr.GetMidRechargeConfigs()
    if not cfsMidRecharge then
        cfsMidRecharge = FestivalMgr.GetRechargeConfigs(FestivalMgr.Type_Mid_Autumn)
    end
    return cfsMidRecharge
end

function FestivalMgr.HasTips()
    if not d then return false end
    --Warning(tostring(FestivalMgr.HasLoginTips())..tostring(FestivalMgr.HasRechargeTips())..tostring(FestivalMgr.HasExchangeTips()))
    return FestivalMgr.HasLoginTips() or FestivalMgr.HasRechargeTips() or FestivalMgr.HasExchangeTips()
end
--t:累计登陆天数（中秋活动期间）
--l：{[idx:领取记录]} 1开始 登陆奖励
--l2:{[id:换取项,num:换取次数]}收集道具
--sum：累计充值
--l3:{[id:礼包ID，s:状态（1：获得2：已领取）]}累计充值礼包记录 
function FestivalMgr.HasLoginTips()
   -- Warning(d.t .. '---' .. table.getCount(d.l))
    return d and d.t > table.getCount(d.l) or false
end
function FestivalMgr.HasExchangeTips()
    local cs = FestivalMgr.GetExchangeConfigs()
    local l = d.l2
    for i = #cs, 1, -1 do
        local c = cs[i]
        local exchangOver = false
        if c.exchange_time > 0 then
            for j = #l, 1, -1 do
                if l[j].id == c.id and l[j].num >= c.exchange_time then
                    exchangOver = true
                    break 
                end
            end
        end
        if not exchangOver then --没兑换完
            local its = c.req_item
            local hasit = true
            for k = #its, 1, -1 do
                local it = string.split(its[k], '_')
                local hn = BackpackDataManager.GetProductTotalNumBySpid(it[1])
                if hn < tonumber(it[2]) then --道具不足
                    hasit = false
                    break
                end
            end
            if hasit then return true end
        end
    end    
    return false
end
function FestivalMgr.HasRechargeTips()
    --local l = d.l3
    --for i = #l, 1, -1 do if l[i].s == 1 then return true end end
    --for i = #l, 1, -1 do if l[i].s == 0 then return true end end
    local listData = FestivalMgr.GetMidRechargeConfigs()
    for i = #listData, 1, -1 do
        local c = listData[i]
        if FestivalMgr.GetChargeState(c.id, c.param2) == 1 then return true end
    end
    return false
end

