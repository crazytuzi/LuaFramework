-- ------------------------------
-- 牛叉的数据转换器
-- 把剧情配置的剧本数据转换成标准处理数据DramaAction
-- hosr
-- ------------------------------
DramaDataTransform = DramaDataTransform or BaseClass()

function DramaDataTransform:__init()
    self.funcTab = {
        [DramaEumn.ActionType.Camerareset] = function(arg) return self:ResetCamera(arg) end
        ,[DramaEumn.ActionType.Cameramoveto] = function(arg) return self:MoveCamera(arg) end
        ,[DramaEumn.ActionType.Camerazoom] = function(arg) return self:ScaleCamera(arg) end
        ,[DramaEumn.ActionType.Camerashake] = function(arg) return self:ShakeCamera(arg) end
        ,[DramaEumn.ActionType.Animationplay] = function(arg) return self:SceneEffect(arg) end
        ,[DramaEumn.ActionType.Animationplaypoint] = function(arg) return self:SceneEffect(arg) end
        ,[DramaEumn.ActionType.Animationplayonrole] = function(arg) return self:RoleEffect(arg) end
        ,[DramaEumn.ActionType.Animationplayonunit] = function(arg) return self:UnitEffect(arg) end
        ,[DramaEumn.ActionType.Actrole] = function(arg) return self:ActRole(arg) end
        ,[DramaEumn.ActionType.Actunit] = function(arg) return self:ActUnit(arg) end
        ,[DramaEumn.ActionType.Unitdir] = function(arg) return self:DirUnit(arg) end
        ,[DramaEumn.ActionType.Roledir] = function(arg) return self:DirRole(arg) end
        ,[DramaEumn.ActionType.Soundplay] = function(arg) return self:PlaySound(arg) end
        ,[DramaEumn.ActionType.Unittalk] = function(arg) return self:DramaTalk(arg) end
        ,[DramaEumn.ActionType.Roletalk] = function(arg) return self:DramaTalk(arg) end
        ,[DramaEumn.ActionType.Plotunitcreate] = function(arg) return self:CreateUnit(arg) end
        ,[DramaEumn.ActionType.Plotunitmove] = function(arg) return self:MoveUnit(arg) end
        ,[DramaEumn.ActionType.Plotunitdel] = function(arg) return self:DeleteUnit(arg) end
        ,[DramaEumn.ActionType.Multiaction] = function(arg) return self:Mutil(arg) end
        ,[DramaEumn.ActionType.First_pet] = function(arg) return self:FirstPet(arg) end
        ,[DramaEumn.ActionType.Wait] = function(arg) return self:Wait(arg) end
        ,[DramaEumn.ActionType.Role_jump] = function(arg) return self:Jump(arg) end
        ,[DramaEumn.ActionType.Inter_monologue] = function(arg) return self:Feeling(arg) end
        ,[DramaEumn.ActionType.Unittalkbubble] = function(arg) return self:Bubble(arg) end
        ,[DramaEumn.ActionType.Roletalkbubble] = function(arg) return self:BubbleRole(arg) end
        ,[DramaEumn.ActionType.PetItemSkillGuide] = function(arg) return self:FirstBook(arg) end
        ,[DramaEumn.ActionType.Playeffect] = function(arg) return self:PlayUIEffect(arg) end
        ,[DramaEumn.ActionType.Openpanel] = function(arg) return self:Openpanel(arg) end
    }
end

-- ------------------------------------
-- 外部调用总接口
-- ------------------------------------
function DramaDataTransform:Format(data)
    return self.funcTab[tonumber(data.label)](data)
end

-- 剧情对话
function DramaDataTransform:DramaTalk(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.mode = val[1]
    action.name = val[2]
    action.unit_base_id = tonumber(val[3])
    action.msg = val[4]
    local faces = {}
    for faceId in string.gmatch(action.msg, "{(%d+)}") do
        table.insert(faces, faceId)
    end

    for _,faceId in ipairs(faces) do
        local src = string.format("{%s}", faceId)
        local rep = string.format("{face_1,%s}", faceId)
        action.msg = string.gsub(action.msg, src, rep, 1)
    end

    return action
end

-- 创建单位
function DramaDataTransform:CreateUnit(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = 0
    action.unit_id = tonumber(val[1])
    action.unit_base_id = tonumber(val[2])
    action.msg = val[3]
    action.mapid = tonumber(val[5])
    action.x = tonumber(val[6])
    local fy = string.gsub(val[7], "(.+)}", "%1")
    action.y = tonumber(fy)
    action.val = tonumber(val[8]) -- 朝向
    action.ext_msg = val[9] -- 动作
    action.mode = tonumber(val[10]) -- 模式

    local baseData = DataUnit.data_unit[action.unit_base_id]
    if baseData ~= nil then
        action.looks = BaseUtils.TransformBaseLooks(baseData.looks)
        action.sex = baseData.sex
        action.classes = baseData.classes
    end
    return action
end

-- 删除单位
function DramaDataTransform:DeleteUnit(data)
    local action = DramaAction.New()
    action.type = data.label
    action.unit_id = tonumber(data.val)
    return action
end

-- 单位移动
function DramaDataTransform:MoveUnit(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.unit_id = tonumber(val[1])
    action.x = tonumber(val[3])
    action.y = tonumber(val[4])
    return action
end

-- 单位动作
function DramaDataTransform:ActUnit(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = tonumber(val[1])
    action.unit_id = tonumber(val[2])
    action.msg = val[3] -- 动作名
    action.ext_val = tonumber(val[4]) -- 时间
    return action
end

function DramaDataTransform:ActRole(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = 0
    action.unit_id = 0
    action.msg = val[1] -- 动作名
    action.ext_val = tonumber(val[2]) -- 时间
    return action
end

-- 单位朝向
function DramaDataTransform:DirUnit(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = tonumber(val[1])
    action.unit_id = tonumber(val[2])
    action.val = tonumber(val[3]) -- 朝向
    return action
end

-- 单位朝向 -- 自己
function DramaDataTransform:DirRole(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = 0
    action.unit_id = 0
    action.val = tonumber(val[1]) -- 朝向
    return action
end

-- 移动镜头
function DramaDataTransform:MoveCamera(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.time = tonumber(val[1]) -- 时间
    action.x = tonumber(val[2])
    action.y = tonumber(val[3])
    return action
end

-- 镜头恢复
function DramaDataTransform:ResetCamera(data)
    local action = DramaAction.New()
    action.type = data.label
    action.time = tonumber(data.val) -- 时间
    return action
end

-- 镜头震动
function DramaDataTransform:ShakeCamera(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.mode = tonumber(val[1]) -- 强度模式
    action.time = tonumber(val[2]) -- 时间
    return action
end

-- 播放声音
function DramaDataTransform:PlaySound(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.res_id = tonumber(val[1]) -- 资源ID
    action.time = tonumber(val[2]) -- 时间
    return action
end

-- 播放场景特效
function DramaDataTransform:SceneEffect(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.res_id = tonumber(val[1])
    action.x = tonumber(val[2])
    action.y = tonumber(val[3])
    return action
end

-- 单位播放特效
function DramaDataTransform:RoleEffect(data)
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = 0
    action.unit_id = 0
    action.res_id = tonumber(data.val)
    return action
end

function DramaDataTransform:UnitEffect(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = tonumber(val[1])
    action.unit_id = tonumber(val[2])
    action.res_id = tonumber(val[3])
    return action
end

-- 镜头缩放
function DramaDataTransform:ScaleCamera(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.time = tonumber(val[1]) -- 时间
    action.val = tonumber(val[2]) -- 缩放比例
    return action
end

-- 组合播放
function DramaDataTransform:Mutil(data)
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(data.val)
    return action
end

-- 获得宠物
function DramaDataTransform:FirstPet(data)
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(data.val)
    return action
end

-- 等待
function DramaDataTransform:Wait(data)
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(data.val)
    return action
end

-- 跳跃
function DramaDataTransform:Jump(data)
    local points = {}
    local pointStrs = StringHelper.Split(data.val, ",")
    for _,str in ipairs(pointStrs) do
        local ps = StringHelper.Split(str, ":")
        table.insert(points, {x = ps[1], y = ps[2]})
    end
    local action = DramaAction.New()
    action.type = data.label
    action.val = points
    return action
end

function DramaDataTransform:Feeling(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(val[2]) -- id
    action.msg = val[3] -- 名称
    action.ext_msg = val[4] --说话内容
    action.time = tonumber(val[5]) -- 时间
    return action
end

-- 泡泡对话
function DramaDataTransform:Bubble(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = tonumber(val[1])
    action.unit_id = tonumber(val[2])
    action.msg = val[3]
    action.time = tonumber(val[4]) or 0

    local faces = {}
    for faceId in string.gmatch(action.msg, "{(%d+)}") do
        table.insert(faces, faceId)
    end

    for _,faceId in ipairs(faces) do
        local src = string.format("{%s}", faceId)
        local rep = string.format("{face_1,%s}", faceId)
        action.msg = string.gsub(action.msg, src, rep, 1)
    end
    action.msg = string.gsub(action.msg, "%[role%]", RoleManager.Instance.RoleData.name)
    return action
end

function DramaDataTransform:BubbleRole(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.battle_id = 0
    action.unit_id = 0
    action.msg = val[3]
    action.time = tonumber(val[4]) or 0

    local faces = {}
    for faceId in string.gmatch(action.msg, "{(%d+)}") do
        table.insert(faces, faceId)
    end

    for _,faceId in ipairs(faces) do
        local src = string.format("{%s}", faceId)
        local rep = string.format("{face_1,%s}", faceId)
        action.msg = string.gsub(action.msg, src, rep, 1)
    end

    action.msg = string.gsub(action.msg, "%[role%]", RoleManager.Instance.RoleData.name)
    return action
end

function DramaDataTransform:FirstBook(data)
    local action = DramaAction.New()
    action.type = data.label
    return action
end

function DramaDataTransform:PlayUIEffect(data)
    local val = StringHelper.Split(data.val, ",")
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(val[1])
    action.ext_val = tonumber(val[2]) or 3000
    return action
end

function DramaDataTransform:Openpanel(data)
    local action = DramaAction.New()
    action.type = data.label
    action.val = tonumber(data.val)
    return action
end