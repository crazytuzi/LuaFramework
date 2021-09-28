require "Core.Module.Pattern.Proxy"

RechargeAwardProxy = Proxy:New();
local configs = nil
local datas = {}
local yunyingId = nil

--CmdType.RAChange = 0x1B07 --运营充值礼包发生改变
--CmdType.RAGet = 0x1B08--领取运营充值礼包
--CmdType.RAInfo = 0x1B09--查询运营充值礼包
function RechargeAwardProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RAChange, RechargeAwardProxy._RAChange)	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.RAGet, RechargeAwardProxy._RAChange)	
end

function RechargeAwardProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RAChange, RechargeAwardProxy._RAChange)	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.RAGet, RechargeAwardProxy._RAChange)	
end

function RechargeAwardProxy.SetData(d)
    --yyl:[{id:充值礼包id,s状态(0:可领取 1:已领取)}]
    --PrintTable(d, "___", Warning)
--    if not d then return end
--    for k,v in pairs(d) do
--        local finded 
--        for k1,v1 in pairs(datas) do
--            if v.id == v1.id then
--                v1.s = v.s
--                finded = true
--            end
--        end
--        if not finded then table.insert(datas, v) end
--    end
    datas = d
    if not d then datas = {} end
    MessageManager.Dispatch(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE, d)
end
function RechargeAwardProxy._RAChange(cmd, d)
    if d.errCode then return end
    for i = #datas, 1, -1 do
        local v = datas[i]
        if v.id == d.id then
            table.remove(datas, i)
            break
        end
    end
    table.insert(datas, d)
    --PrintTable(datas, '', Warning)
    MessageManager.Dispatch(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE, d)
    MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS)
end
function RechargeAwardProxy.GetRechargeState(id)
    for k,v in pairs(datas) do
        if v.id == id then
            return v.s
        end
    end
    return nil
end
function RechargeAwardProxy.IsRechargeOver()
    local s = 0
    for k,v in pairs(datas) do s = s + v.s end
    return s == 2
end
function RechargeAwardProxy.HasTip()
    --PrintTable(datas, '', Warning)
    for k,v in pairs(datas) do
        if v.s == 0 then
            return true
        end
    end
    return false
end
function RechargeAwardProxy.GetAward(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.RAGet, { id = id })
end


--返回活动信息,倒计时,活动id
function RechargeAwardProxy.GetActiveInfo()
    local c = TimeLimitActManager.GetAct(SystemConst.Id.RechargeAward)
    local t = TimeLimitActManager.GetDownTime(c)
    yunyingId = TimeLimitActManager.GetActiveId(c)
    return t, yunyingId
end
--返回当前充值奖励列表
function RechargeAwardProxy.GetRechargeInfo(aid)
    if not configs then configs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRIZE) end
    local t = {}
    for k,v in pairs(configs) do
        if v.yunying_id == aid then table.insert(t, v) end
    end
    return t
end
--返回当前充值奖励列表
function RechargeAwardProxy.GetRewards(c)
    local rs = ConfigManager.Clone(c.reward)
    local k = PlayerManager.GetPlayerKind()
    local cas = c.career_award
    for i, v in ipairs(cas) do
        local ss = string.split(v, '_')
        --Warning(k .. '----' .. ss[1] .. ss[2])
        if tonumber(ss[2]) == k then
            local cs = ss[1] .. '_' .. 1
            table.insert(rs, 1, cs)
            break
        end
    end
    return ProductInfo.GetProductInfos(rs)
end

