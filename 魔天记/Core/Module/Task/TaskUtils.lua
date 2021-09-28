TaskUtils = {};
local insert = table.insert

function TaskUtils.GetTaskDesc(task, config)
    local param = {
            a = config.a;
            b = config.b;
            c = config.c;
        };
    local content = LanguageMgr.ApplyFormat(config.descLabel, param, true);
    if config.showXY > 0 then
        local taskX = task.param1;
        if task.tType == TaskConst.Target.COLLECT_ITEM then
            if task.status == TaskConst.Status.FINISH then
                taskX = config.target_num;
            else
                --未完成计算背包物品数量
                local spId = tonumber(config.target[1]);
                taskX = math.min(BackpackDataManager.GetProductTotalNumBySpid(spId), config.target_num);
            end
        end
        local xy = {
            x = taskX;
            y = config.target_num;
        };


        if taskX >= config.target_num then
            content = content .. LanguageMgr.Get("task/p/1", xy);
        else
            content = content .. LanguageMgr.Get("task/p/0", xy);
        end
    end
    return content;
end

function TaskUtils.GetTaskAward(task)
    
    local a = {};
    local cfg =  task:GetConfig();
    if cfg then
        for i,v in ipairs(cfg.reward) do
            if v ~= "" then
                local tmp = string.split(v, "_");
                --新增物品概率, 非100% 不显示在列表里.
                if tonumber(tmp[3]) >= 100 then
                    local o = ProductInfo:New();
                    o:Init({spId = tonumber(tmp[1]), am = tonumber(tmp[2])});
                    insert(a, o);
                end
            end
        end
        local item = TaskUtils.GetTaskCareerAwrad(task);
        if item then
            insert(a, item);
        end
    end
    
    return a;
end

function TaskUtils.GetTaskCareerAwrad(task)
    local cfg = task:GetConfig();        
    return TaskUtils.GetCareerAward(cfg.career_reward);
end

function TaskUtils.GetCareerAward(awards)
    local item = nil;
    if awards and #awards > 0 then
        local kind = PlayerManager.GetPlayerKind();
        for i,v in ipairs(awards) do
            if v ~= "" then
                local tmp = string.split(v, "_");
                if tonumber(tmp[2]) == kind then
                    item = ProductInfo:New();
                    item:Init({spId = tonumber(tmp[1]), am = 1});
                    return item;
                end
            end
        end
    end
    return item;
end


function TaskUtils.InCircle(pos1, pos2, radius)
    local offset = (pos1 - pos2);
    offset.y = 0;
    local dis = offset:Magnitude();
    return dis <= radius; 
end

--判断是否在某个区域
function TaskUtils.InArea(mapId, pos, r)
    if mapId and TaskUtils.InMap(mapId) == false then
        return false;
    end

    local role = HeroController.GetInstance();
    if pos and r then
        if role ~= nil then
            local myPos = role.transform.position;
            return TaskUtils.InCircle(myPos, pos, r);
        end
    else
        --不检查位置 半径
        return true;
    end
    return false;
end

function TaskUtils.InMap(mapId)
    if not TaskUtils.SceneReady() then
        return false;
    end
    if tonumber(GameSceneManager.id) ~= mapId then
        return false;
    end
    return true;
end

--判断是否在副本里.
--副本id 跟场景id是唯一对应的.
function TaskUtils.InInst(fid)
    local cfg = InstanceDataManager.GetMapCfById(fid);
    return TaskUtils.InMap(cfg.map_id);
end

function TaskUtils.IsInInst()
    local cfg = ConfigManager.GetMapById(tonumber(GameSceneManager.id));
    if cfg and (cfg.type == InstanceDataManager.MapType.Field or cfg.type == InstanceDataManager.MapType.Main or cfg.type == InstanceDataManager.MapType.Guild) then
        return false;
    end
    return true;
end

function TaskUtils.SceneReady()
    if GameSceneManager.map == nil or GameSceneManager.map._ready == false then
        return false;
    end
    return true;
end

function TaskUtils.GetMonster(monId, owner)
    if GameSceneManager.map then
        local roles = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
        if roles then
            for id, value in pairs(roles) do
                if (value and value.info and value.info.kind == monId) then
                    if owner == nil or value.info.owner == owner then
                        return value;    
                    end
                end
            end
        end
    end
    return nil;
end

--判断场景里是否有某个怪物.
function TaskUtils.CheckMonster(monId, owner)
    if GameSceneManager.map then
        local roles = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
        if roles then
            for id, value in pairs(roles) do
                if (value and value.info and value.info.kind == monId) then
                    if owner == nil then
                        return true;    
                    end
                    return value.info.owner == owner;
                end
            end
        end
    end
    return false;
end

--判断跟某个怪物的距离.
function TaskUtils.InMonsterCircle(monId, owner, r)
    local roles = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
    local myRole = HeroController.GetInstance();
    local myPos = myRole.transform.position;
    if roles then
        for id, value in pairs(roles) do
            if (value and value.info and value.info.kind == monId) then
                if owner == nil or value.info.owner == owner then
                    local pos = value.transform.position;
                    if TaskUtils.InCircle(myPos, pos, r) then
                        return true;
                    end 
                end
            end
        end
    end
    return false;
end

--判断是否在某个NPC身边.
function TaskUtils.CheckPosToNpc(npcId)
    local npcCfg = ConfigManager.GetNpcById(npcId);
    return TaskUtils.InArea(npcCfg.map, TaskUtils.ConvertPoint(npcCfg.x, npcCfg.z), 2.5);
end

function TaskUtils.ConvertPoint(x,y)
    return Convert.PointFromServer(x, 0, y);
end

function TaskUtils.GetItemsByStrArr(strArr)
    local tmp = {};
    for i,v in ipairs(strArr) do
        if v ~= "" then
            local spArr = string.split(v, "_");
            local o = ProductInfo:New();
            o:Init({spId = tonumber(spArr[1]), am = tonumber(spArr[2])});
            insert(tmp, o);
        end
    end
    return tmp;
end