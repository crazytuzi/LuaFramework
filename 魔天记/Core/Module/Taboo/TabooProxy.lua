require "Core.Module.Pattern.Proxy"

TabooProxy = Proxy:New();
TabooProxy.MAP_ID = 714000
TabooProxy.MOZHU_ID = 1
local mozhuData = nil
local mozhuDtime = 0
local mozhuTimes
local maxCollectNum = 10
local collectNum = 0
local awards
local collectId
local tabooing = false
function TabooProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TabooInfo, TabooProxy._GetInfo)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TabooChangeMine, TabooProxy._ChangeMine)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TabooHoldMine, TabooProxy._HoldMine)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TabooCollectNum, TabooProxy._CollectNum)
end

function TabooProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TabooInfo, TabooProxy._GetInfo)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TabooChangeMine, TabooProxy._ChangeMine)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TabooHoldMine, TabooProxy._HoldMine)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TabooCollectNum, TabooProxy._CollectNum)
end
function TabooProxy.GetTabooInfo()
    SocketClientLua.Get_ins():SendMessage(CmdType.TabooInfo)
end
function TabooProxy.GetTabooHoldMine(id, f) -- 0 发起，1 取消
    SocketClientLua.Get_ins():SendMessage(CmdType.TabooHoldMine, { id = id , f = f })
end
function  TabooProxy.StartCollect(mid)
    collectId = TabooProxy.GetIdByPointId(mid)
    if not collectId then return end
    TabooProxy.GetTabooHoldMine(collectId, 0)
    return TabooProxy.GetConfigById(collectId).collect_time
end
function TabooProxy.CancelCollect()
    if not collectId then return end
    TabooProxy.GetTabooHoldMine(collectId, 1)
    collectId = nil
end

function TabooProxy.GetTabooCollectNum()
    SocketClientLua.Get_ins():SendMessage(CmdType.TabooCollectNum)
end
function TabooProxy.GameStart()
    GameSceneManager.GotoScene(TabooProxy.MAP_ID)
end

function TabooProxy._GetInfo(cmd, data)
	if data.errCode then return end
    TabooProxy.SetCollectNum(data.t)
    for k,v in ipairs(data.l) do
        local id = v.id
        local spid = TabooProxy.GetPointIdById(id)
        --Warning(tostring(id) .. "__" .. tostring(spid).. "__" .. tostring(v.s))
        if v.s == 0 then GameSceneManager.map:AddSceneProp(spid)
        else GameSceneManager.map:RemoveSceneProp(spid) end
        if id == TabooProxy.MOZHU_ID then TabooProxy._SetMozhuData(v) end
    end
    MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_INFO)
end
function TabooProxy._ChangeMine(cmd, data)
	if data.errCode then return end
    local id = data.id
    local spid = TabooProxy.GetPointIdById(id)
    --PrintTable(data,"___",Warning)
    if data.s == 0 then GameSceneManager.map:AddSceneProp(spid)
    else GameSceneManager.map:RemoveSceneProp(spid) end
    if data.s == 1 then
        if data.pid == PlayerManager.playerId then
            collectId = nil
            TabooProxy.SetCollectNum(collectNum + 1)
        elseif id == collectId then
            collectId = nil
            MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_MINE_COLLECTED)
        end
    end
    if id == TabooProxy.MOZHU_ID then TabooProxy._SetMozhuData(data) end
end
function TabooProxy._SetMozhuData(d)
    mozhuData = {}
    mozhuData.s = d.s
    mozhuData.ct = (d.ct and d.ct ~= 0) and d.ct / 1000 or GetTime()
end
function TabooProxy.GetMozhuDes()
    local ss = ''
	if mozhuData == nil then
        return ss
    end
    local s = mozhuData.s
    if s == 0 then
        ss = LanguageMgr.Get("TabooPanel/mozhuDes1")
    else
        local t = GetTime()
        local d = os.date('%H:%M', t )
        --local d = ({'01:55','12:31','13:31','21:55','23:33'})[math.random(1,5)]
        --Warning(d)
        if (d > mozhuTimes[1] and d < mozhuTimes[2])
            or (d > mozhuTimes[3] and d < mozhuTimes[4]) then
            local gt = (mozhuData.ct + mozhuDtime)  - t
            --Warning(mozhuDtime .. '--' .. gt .. '---' .. mozhuData.ct)
            ss = LanguageMgr.Get("TabooPanel/mozhuDes2", { t = GetTimeByStr1(gt) })
        else 
            ss = LanguageMgr.Get("TabooPanel/mozhuDes3")
            --Warning(d..'-----'..table.concat(mozhuTimes,'-'))
        end
    end
    return ss
end


function TabooProxy._HoldMine(cmd, data)
	if data.errCode then return end
    --if data.f == 1 then return end --取消
    if data.id ~= collectId then return end
    MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_HOLD_MINE, data)
end
function TabooProxy._CollectNum(cmd, data)
	if data.errCode then return end
    if data.t then TabooProxy.SetCollectNum(data.t) end
end

function TabooProxy.SetInTaboo(val)
    tabooing = val
end
function TabooProxy.InTaboo()
    return tabooing
end
function TabooProxy.CanAttack(r) --禁忌之地攻击模式
    local rType = r.roleType
    --Warning(rType .."_" ..r.info.name .. tostring(r.info.pid))
    if (rType == ControllerType.MONSTER) then
        return true
    elseif (rType == ControllerType.PLAYER) then
        return not PartData.IsMyTeammate(r.id)
    --elseif rType == ControllerType.PET or rType == ControllerType.PUPPET then
    --    return not PartData.IsMyTeammate(r.info.pid)
    elseif rType == ControllerType.PUPPET then
        local rp = r:GetMaster()
        return rp and not PartData.IsMyTeammate(rp.id)
    end
    return false
end
function TabooProxy.SetCollectNum(num)
    collectNum = num
    MessageManager.Dispatch(TabooNotes, TabooNotes.TABOO_COLLECT_NUM)
end
function TabooProxy.SetActiveData(data)
    maxCollectNum = data.activity_times
    awards = data.reward_icon
end
function TabooProxy.SetMaxCollectNum(num)
    maxCollectNum = num
end
function TabooProxy.GetNumShow()
    return collectNum < maxCollectNum and collectNum .. "/" .. maxCollectNum
        or "[ff0000]" .. collectNum .. "/" .. maxCollectNum
end
function TabooProxy.GetCollectInfoShow()
    return LanguageMgr.Get("TabooPanel/desTime", { t = TabooProxy.GetTime() })
end
function TabooProxy.GetAwards()
    return awards
end

local configs
function TabooProxy.InitConfig()
	if not configs then
        configs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TABOO)
        mozhuDtime = configs[TabooProxy.MOZHU_ID].re_time
        local ts = configs[1].re_time_per
        local t1 = string.split(ts[1], '-')
        local t2 = string.split(ts[2], '-')
        table.AddRange(t1, t2)
        mozhuTimes = t1
    end
end
function TabooProxy.GetTime()
    local ts = configs[1].re_time_per
	return table.concat(ts,"/")
end
function TabooProxy.GetPointIdById(id)
    for i = #configs, 1, -1 do
        if configs[i].id == id then return configs[i].s_id end
    end
    return -1
end
function TabooProxy.GetIdByPointId(pid)
    for i = #configs, 1, -1 do
        if configs[i].s_id == pid then return configs[i].id end
    end
    return -1
end
function TabooProxy.GetConfigById(id)
    for i = #configs, 1, -1 do
        if configs[i].id == id then return configs[i] end
    end
    return -1
end
