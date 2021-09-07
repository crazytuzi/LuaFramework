-- 依赖信息
PrefabdepManager = PrefabdepManager or BaseClass()

function PrefabdepManager:__init()
    if PrefabdepManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PrefabdepManager.Instance = self;
    self.list = DataPrefabsDep.data_list
end

function PrefabdepManager:__delete()
end

function PrefabdepManager:GetPrefabDep(prefabFile)
    local dep = self.list[prefabFile]
    if dep == nil then
        return {}
    else
        return dep
    end
end

function PrefabdepManager:AppendDep(resList)
    local result = {}
    for _, data in ipairs(resList) do
        if data.appendDep then
            local depList = self:GetPrefabDep(data.file)
            for _, depPath in ipairs(depList) do
                if not self:Contain(resList, depPath) then
                    table.insert(result, {file = depPath, type = AssetType.Dep, holdTime = data.holdTime})
                end
            end
            table.insert(result, data)
        else
            table.insert(result, data)
        end
    end
    return result
end

function PrefabdepManager:Contain(list, file)
    for _, data in ipairs(list) do
        if data.file == file then
            return true
        end
    end
    return false
end
