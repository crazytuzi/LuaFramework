SceneEntityMgr = {}
SceneEntityMgr.BAOXIAN_MAP_ID = 701001
local maxCollectNum = 10
local collectNum = 0
local collectId

function SceneEntityMgr.InitStatic()
	local d = ActivityDataManager.GetCfBy_id(34)
	if d then SceneEntityMgr.SetActiveData(d) end
end
function SceneEntityMgr.SetCollectId(id)
    collectId = id
end
function SceneEntityMgr.GetCollectId()
    return collectId
end
function SceneEntityMgr.SetSceneProps(data)
    SceneEntityMgr.SetCollectNum(data.t)
    for k,v in ipairs(data.l) do
        local id = v.id
        local spid = SceneEntityMgr.GetPointIdById(id)
        --Warning(tostring(id) .. "__" .. tostring(spid).. "__" .. tostring(v.s))
        if v.s == 0 then GameSceneManager.map:AddSceneProp(spid)
        else GameSceneManager.map:RemoveSceneProp(spid) end
    end
end
function SceneEntityMgr.ScenePropChange(data)
    local id = data.id
    local spid = SceneEntityMgr.GetPointIdById(id)
    --PrintTable(data,"___",Warning)
    if GameSceneManager.map then
        if data.s == 0 then GameSceneManager.map:AddSceneProp(spid)
        else GameSceneManager.map:RemoveSceneProp(spid) end
    end
    if data.s == 1 then
        if data.pid == PlayerManager.playerId then
            SceneEntityMgr.SetCollectNum(collectNum + 1)
            MsgUtils.ShowTips("SceneEntity/collectedComplete", {n = SceneEntityMgr.GetNumShow() })
            SceneEntityMgr.SetCollectId(nil)
            ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_AWAY)
        elseif id == collectId then
            MsgUtils.ShowTips("SceneEntity/collected")
            SceneEntityMgr.SetCollectId(nil)
            ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_AWAY)
            ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
        end
    end
end
function SceneEntityMgr.SetCollectNum(num)
    collectNum = num
end
function SceneEntityMgr.SetActiveData(data)
    maxCollectNum = data.activity_times
end
function SceneEntityMgr.SetMaxCollectNum(num)
    maxCollectNum = num
end
function SceneEntityMgr.GetNumShow()
    return collectNum < maxCollectNum and collectNum .. "/" .. maxCollectNum
        or "[ff0000]" .. collectNum .. "/" .. maxCollectNum
end
function SceneEntityMgr.HasCollectNum()
    return maxCollectNum > collectNum
end

local configs
function SceneEntityMgr.GetConfig()
	if not configs then
        configs = ConfigManager.GetConfig(ConfigManager.CONFIG_TREASURE_BOX)       
    end
    return configs
end
function SceneEntityMgr.GetPointIdById(id)
    local configs = SceneEntityMgr.GetConfig()
    for i = #configs, 1, -1 do
        if configs[i].id == id then return configs[i].map_id end
    end
    return -1
end
function SceneEntityMgr.GetIdByPointId(pid)
    local configs = SceneEntityMgr.GetConfig()
    for i = #configs, 1, -1 do
        if configs[i].map_id == pid then return configs[i].id end
    end
    return -1
end
function SceneEntityMgr.GetConfigById(id)
    local configs = SceneEntityMgr.GetConfig()
    for i = #configs, 1, -1 do
        if configs[i].id == id then return configs[i] end
    end
    return -1
end

function SceneEntityMgr.GameStart()
    GameSceneManager.GotoScene(SceneEntityMgr.BAOXIAN_MAP_ID)
end
