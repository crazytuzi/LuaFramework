-- 分包处理
-- @author huangyq
-- @date 20160517
SubpackageManager = SubpackageManager or BaseClass()

function SubpackageManager:__init()
    if SubpackageManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    SubpackageManager.Instance = self

    -- 是否为分包 主要存在没下载完的资源，都属于分包
    self.IsSubPackage = self:GetNeedDownload()

    self.roleSetting = SubpackageRoleSetting.New()
    self.wingSetting = SubpackageWingSetting.New()
    self.npcSetting = SubpackageNpcSetting.New()
    self.mapSetting = SubpackageMapSetting.New()
    self.homeSetting = SubpackageHomeSetting.New()
    self.rideSetting = SubpackageRideSetting.New()
    self.combatmapSetting = SubpackageCombatMapSetting.New()
    self.windowSetting = SubpackageWindowSetting.New()
    self.effectSetting = SubpackageEffectSetting.New()

    self.OnCompletedEvent = EventLib.New()

    local completeAction = function()
        self:OnDownloadCompleted()
    end
    if CSSubpackageManager then
        CSSubpackageManager.GetInstance():AddCompleteEvent(completeAction)
    end
end

function SubpackageManager:__delete()
end

function SubpackageManager:RoleResources(resData, replaceonly)
    return self.roleSetting:Resources(resData, replaceonly)
end

function SubpackageManager:WingResources(resData)
    return self.wingSetting:Resources(resData)
end

function SubpackageManager:NpcResources(resData, replaceonly)
    return self.npcSetting:Resources(resData, replaceonly)
end

function SubpackageManager:MapResources(resData)
    return self.mapSetting:Resources(resData)
end

function SubpackageManager:HomeResources(resData, replaceonly)
    return self.homeSetting:Resources(resData)
end

function SubpackageManager:RideResources(resData, replaceonly)
    return self.rideSetting:Resources(resData)
end

function SubpackageManager:RemoveByFile(resources, file)
    local index = -1
    for i, data in ipairs(resources) do
        if data.file == file then
            index = i
            break
        end
    end
    if index ~= -1 then
        table.remove(resources, index)
    end
end

function SubpackageManager:GetNeedDownload()
    if CSSubpackageManager then
        return CSSubpackageManager.GetInstance().NeedDownload
    else
        return false
    end
end

-- true 需要下载文件 false 不需要下载文件
function SubpackageManager:WindowCheckFile(resList)
    return self.windowSetting:CheckFile(resList)
end

-- 多个文件
function SubpackageManager:HaveSubpackageFile(resources)
    if CSSubpackageManager then
        return CSSubpackageManager.GetInstance():HaveSubpackageFile(requestRes)
    else
        return false
    end
end

-- 一个文件
function SubpackageManager:HaveSubpackageFileSingle(file)
    if CSSubpackageManager then
        return CSSubpackageManager.GetInstance():HaveSubpackageFileSingle(file)
    else
        return false
    end
end


-- 下载完成事件
function SubpackageManager:OnDownloadCompleted()
    SoundManager.Instance.BGM_Id = nil
    self.IsSubPackage = false
    self.OnCompletedEvent:Fire()
end
