-- 资源池
-- 当资源类型为AssetType.Main时，可对AssetBundle.mainAsset进行缓存
AssetPool_ForScene = AssetPool_ForScene or BaseClass()

function AssetPool_ForScene:__init(name)
    self.name = name
    self.cache = {}
end

function AssetPool_ForScene:__delete()
    self.cache = nil
end

function AssetPool_ForScene:Add(key, poolObj, holdTime, extraData)
    if not BaseUtils.ContainKeyTable(self.cache, key) then
        if holdTime == nil then
            holdTime = BaseUtils.DefaultHoldTime()
        end
        if extraData == nil then
            self.cache[key] = {asset = poolObj, time = Time.time, holdTime = holdTime}
        else
            self.cache[key] = {asset = poolObj, time = Time.time, holdTime = holdTime
                , sceneAssetType = extraData.sceneAssetType, mapid = extraData.mapid}
        end
    else
        -- Log.Info(string.format("重复添加资源池元素:%s", key))
    end
end

function AssetPool_ForScene:Contain(key)
    local asset = self:Get(key)
    if asset == nil then
        return false
    else
        return true
    end
end

function AssetPool_ForScene:Get(key)
    if BaseUtils.ContainKeyTable(self.cache, key) then
        local asset = self.cache[key]
        asset.time = Time.time
        return asset
    else
        return nil
    end
end

function AssetPool_ForScene:CheckToRelease()
    local now = Time.time
    local dels = {}
    for key, data in pairs(self.cache) do
        if data.sceneAssetType == SceneConstData.MapCell then
            if data.can_del then 
                if data.del_now then 
                    table.insert(dels, key)
                elseif data.leavetime ~= nil and (now - data.leavetime) > data.holdTime then
                    table.insert(dels, key)
                end
            end
        elseif (now - data.time) > data.holdTime then
            table.insert(dels, key)
        end
    end
    for _, key in ipairs(dels) do
        -- print(string.format("释放场景资源 %s", key))
        self.cache[key] = nil
    end
end

------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
function AssetPool_ForScene:Get_MapCellAsset_Num()
    local count = 0
    for key, data in pairs(self.cache) do
        if data.sceneAssetType == SceneConstData.MapCell then
            count = count + 1
        end
    end
    return count
end

function AssetPool_ForScene:Set_MapCellAsset_DelNow(mapid, newMapId)
    local count = 0
    for key, data in pairs(self.cache) do
        if data.sceneAssetType == SceneConstData.MapCell and data.mapid == mapid and data.mapid ~= newMapId then
            data.del_now = true
            count = count + 1
        end
    end
    return count
end

function AssetPool_ForScene:Set_MapCellAsset_Leavetime(mapid)
    local now = Time.time
    for key, data in pairs(self.cache) do
        if data.sceneAssetType == SceneConstData.MapCell and data.mapid == mapid then
            data.leavetime = now
            data.can_del = true
        end
    end
end