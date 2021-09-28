require "Core.Module.Pattern.Proxy"
local configs
MapProxy = Proxy:New();
MapProxy.showNpc = false
MapProxy.selectItem = nil
local fightFlg 
function MapProxy:OnRegister()
    MapProxy.showNpc = false
    MessageManager.AddListener(PlayerManager, PlayerManager.StopAutoRoad,MapProxy._OnMoveToed, self)
end

function MapProxy:OnRemove()
    MapProxy.showNpc = false
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StopAutoRoad,MapProxy._OnMoveToed)
end
--移动完成挂机
function MapProxy:_OnMoveToed() 
    local h = HeroController.GetInstance()
    if not h then return end
    --Warning(tostring(fightFlg) ..  '___' .. tostring(h:IsAutoFight()))
    if fightFlg then h:StartAutoFight(true) fightFlg = nil end
end
function MapProxy.SetFightFlg(val)
    fightFlg = val
end

--玩家当前推荐野外配置
function MapProxy.GetPlayerField()
    local lev = PlayerManager.GetPlayerLevel()
    if not configs then 
        configs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_AUTO_FIELD)
    end
    for i = #configs, 1, -1 do
        local c = configs[i]
        if lev >= c.level_lower then return GameSceneManager.GetMapInfo(c.map_name) end
    end
end
--当前野外怪物信息[{name,lev,position,att,def,exp,type}]
function MapProxy.GetFieldMonsters(mapid, configName)
    local bs = {}--大boss
	local bcs = ConfigManager.GetConfig(configName)
	for k, v in pairs(bcs) do
		if v.map_id == mapid then table.insert(bs, v) end
	end
    local bids = {}
    local bds = {}
    local bcLen = #bs
    if bcLen > 0 then 
        for i = 1, bcLen do
            local bc = bs[i]
            local bd = {}
            bd.name = bc.name
            local xy = string.split(bc.boss_guide_point,'|')
            bd.position = Convert.PointFromServer(tonumber(xy[1]), 0, tonumber(xy[2]))
            bd.isBoss = true
            table.insert(bids, bc.monster_id)
            table.insert(bds, bd)
        end
    end
    local mcs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER)
    local ms = {}
    for i, v in pairs(mcs) do
        local bd = nil
        for i = 1, bcLen do
            if bids[i] == v.id then bd = bds[i] break end
        end
        if bd then
            bd.lev = v.level
            bd.att = v.rec_fight
            bd.def = v.rec_def
            bd.exp = v.expect_exp
            bd.type = v.type
        elseif v.map_id == mapid then
            local md = {}
            md.name = v.name
            md.position = Convert.PointFromServer(tonumber(v.x), 0, tonumber(v.z))
            md.lev = v.level
            md.att = v.rec_fight
            md.def = v.rec_def
            md.exp = v.expect_exp
            md.type = v.type
            table.insert(ms, md)
        end
    end
    table.sort(ms,function(x,y)
        if x.type == y.type then return x.lev > y.lev end
        return x.type > y.type
    end)
    if bcLen > 0 then
        for i = 1, bcLen do table.insert(ms, i, bds[i]) end
    end
    return ms
end

