EffectBrocastManager = EffectBrocastManager or BaseClass(BaseManager)

function EffectBrocastManager:__init()
    if EffectBrocastManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    EffectBrocastManager.Instance = self
    self.init = false
    self:InitHandler()
    self.EffectGO = {}
    self.tick = 0
    --{go = effectgameobject, timer = LuaTimer, ctime = creattime}

end


function EffectBrocastManager:InitHandler()
    self:AddNetHandler(9907, self.On9907)
end

-- {uint32, id, "特效id：1:999鲜花效果"}
-- ,{uint16, type, "0::ui播放;1::场景"}
-- ,{uint32, map, "地图"}
-- ,{uint32, x, "x"}
-- ,{uint32, y, "y"}
function EffectBrocastManager:On9907(data)
    -- BaseUtils.dump(data, "On9907")
    if data.type < 10000 and data.map ~= 0 and data.map ~= SceneManager.Instance:CurrentMapId() then
        return
    end
    if not SettingManager.Instance:GetResult(SettingManager.Instance.THidePersonRide) then
        return
    end
    if data.id < 10000 then
        if EffectBrocastEumn[data.id] == nil then
            if data.time == nil then
                data.time = 10
            end
            self:ShowEffect(data.id, data.time, data)
        else
            if EffectBrocastEumn[data.id].soundId ~= nil then
                SoundManager.Instance:Play(EffectBrocastEumn[data.id].soundId)
            end
            self:ShowEffect(EffectBrocastEumn[data.id].effectid, EffectBrocastEumn[data.id].time, data)
        end
    else
        if EffectBrocastEumn[data.id] == nil then
            if data.time == nil then
                data.time = 10
            end
            self:ShowEffect(data.id, data.time, data)
        else
            if EffectBrocastEumn[data.id].soundId ~= nil then
                SoundManager.Instance:Play(EffectBrocastEumn[data.id].soundId)
            end
            self:ShowEffect(data.id, 10, data)
        end
    end
end

function EffectBrocastManager:ShowEffect(effectid, showtime, data)
    local filepath = string.format("prefabs/effect/%s.unity3d", tostring(effectid))
    self.resList = {
        {file = filepath, type = AssetType.Main},
    }
    local assetWrapper = nil
    if self.EffectGO[effectid] == nil or BaseUtils.isnull(self.EffectGO[effectid].go) then
        assetWrapper = AssetBatchWrapper.New()
    end
    -- BaseUtils.dump(resources)
    if assetWrapper ~= nil then
        assetWrapper:LoadAssetBundle(self.resList, function () self:OnEffectLoaded(assetWrapper, effectid, showtime, data) end)
    else
        self:OnEffectLoaded(assetWrapper, effectid, showtime,data)
    end
end

function EffectBrocastManager:OnEffectLoaded(assetWrapper, effectid, showtime, data)
    local filepath = string.format("prefabs/effect/%s.unity3d", tostring(effectid))
    if self.EffectGO[effectid] == nil or BaseUtils.isnull(self.EffectGO[effectid].go) then --特效未创建
        if data.type == 0 then
            self.EffectGO[effectid] = {}
            local prefab = assetWrapper:GetMainAsset(filepath)
            local EffectgameObject = GameObject.Instantiate(prefab)
            self.EffectGO[effectid].stime = showtime
            self.EffectGO[effectid].ctime = Time.time
            self.EffectGO[effectid].go = EffectgameObject.gameObject
            local hide = function()
                if self.EffectGO[effectid] ~= nil and self.EffectGO[effectid].go ~= nil then
                    self.EffectGO[effectid].go:SetActive(false)
                end
            end

            if self.EffectGO[effectid].timer ~= nil then
                LuaTimer.Delete(self.EffectGO[effectid].timer)
                self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
            else
                self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
            end
            Utils.ChangeLayersRecursively(EffectgameObject.gameObject.transform, "UI")
            self:AddToCanvas(self.EffectGO[effectid].go, effectid)
            if data.scale ~= nil then
                EffectgameObject.gameObject.transform.localScale = Vector3.one * tonumber(data.scale)
            end
            self.EffectGO[effectid].go:SetActive(true)
        else
            self:CreaSceneEffect(assetWrapper, effectid, showtime, data)
        end
    else
        if data.type == 0 then
            local hide = function()
                if self.EffectGO[effectid] ~= nil and self.EffectGO[effectid].go ~= nil then
                    self.EffectGO[effectid].go:SetActive(false)
                end
            end
            self.EffectGO[effectid].go:SetActive(false)
            self.EffectGO[effectid].stime = showtime
            self.EffectGO[effectid].ctime = Time.time
            if self.EffectGO[effectid].timer ~= nil then
                LuaTimer.Delete(self.EffectGO[effectid].timer)
                self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
            else
                self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
            end
            self:AddToCanvas(self.EffectGO[effectid].go, effectid)
            if data.scale ~= nil then
                EffectgameObject.gameObject.transform.localScale = Vector3.one * tonumber(data.scale)
            end
            self.EffectGO[effectid].go:SetActive(true)
        else
            self:UpdateSceneEffect(assetWrapper, effectid, showtime, data)
        end
    end

    if assetWrapper ~= nil then
        assetWrapper:DeleteMe()
    end
end

function EffectBrocastManager:AddToCanvas(go, effectid)
    go.transform:SetParent(NoticeManager.Instance.model.noticeCanvas.transform)
    if effectid == 20257 then
        go.transform.localScale = Vector3.one
    end
    if effectid == 30067 then
        go.transform.localPosition = Vector3(0, 0, 1700)
    else
        go.transform.localPosition = Vector3.zero
    end

    if effectid == 30224 then
        go.transform.localPosition = Vector3(-59, -68, 0)
    else
        go.transform.localPosition = Vector3.zero
    end

    go:SetActive(false)
    LuaTimer.Add(50, function()
        go:SetActive(true)
    end)
    -- go.transform:SetParent(ctx.CanvasContainer.transform)
end

function EffectBrocastManager:AddToScene(go)
    go.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
end

function EffectBrocastManager:CheckoutEffect()
    if self.tick >20 then
        local currtime = Time.time
        local DeleteList = {}
        for k,v in pairs(self.EffectGO) do
            if v.ctime ~= nil and v.stime ~= nil and currtime - v.ctime > v.stime and currtime - v.ctime > 30 then
                table.insert(DeleteList, k)
            elseif v.stime == nil or v.ctime == nil then
                table.insert(DeleteList, k)
            end
        end

        for i,v in ipairs(DeleteList) do
            if self.EffectGO[v] ~= nil then
                if not BaseUtils.isnull(self.EffectGO[v].go) then
                    GameObject.DestroyImmediate(self.EffectGO[v].go)
                end
                if self.EffectGO[v].timer ~= nil then
                    LuaTimer.Delete(self.EffectGO[v].timer)
                end
            end
            self.EffectGO[v] = nil
        end
        self.tick = 0
    else
        self.tick = self.tick +1
    end
end

function EffectBrocastManager:CreaSceneEffect(assetWrapper, effectid, showtime, data)
    local filepath = string.format("prefabs/effect/%s.unity3d", tostring(effectid))
    self.EffectGO[effectid] = {}
    local prefab = assetWrapper:GetMainAsset(filepath)
    local EffectgameObject = GameObject.Instantiate(prefab)
    self.EffectGO[effectid].stime = showtime
    self.EffectGO[effectid].ctime = Time.time
    self.EffectGO[effectid].go = EffectgameObject.gameObject
    local hide = function()
        if self.EffectGO[effectid] ~= nil and self.EffectGO[effectid].go ~= nil then
            self.EffectGO[effectid].go:SetActive(false)
        end
    end

    if self.EffectGO[effectid].timer ~= nil then
        LuaTimer.Delete(self.EffectGO[effectid].timer)
        self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
    else
        self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
    end
    Utils.ChangeLayersRecursively(EffectgameObject.gameObject.transform, "Model")
    -- self:AddToCanvas(self.EffectGO[effectid].go)
    local posi = SceneManager.Instance.sceneModel:transport_small_pos(data.x,  data.y)
    self.EffectGO[effectid].go.transform.position = Vector3(posi.x, posi.y, -9)
    self:AddToScene(self.EffectGO[effectid].go)
    self.EffectGO[effectid].go:SetActive(true)
end

function EffectBrocastManager:UpdateSceneEffect(assetWrapper, effectid, showtime, data)
    local hide = function()
        if self.EffectGO[effectid] ~= nil and self.EffectGO[effectid].go ~= nil then
            self.EffectGO[effectid].go:SetActive(false)
        end
    end
    self.EffectGO[effectid].go:SetActive(false)
    self.EffectGO[effectid].stime = showtime
    self.EffectGO[effectid].ctime = Time.time
    if self.EffectGO[effectid].timer ~= nil then
        LuaTimer.Delete(self.EffectGO[effectid].timer)
        self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
    else
        self.EffectGO[effectid].timer = LuaTimer.Add(showtime*1000, hide)
    end
    local posi = SceneManager.Instance.sceneModel:transport_small_pos(data.x,  data.y)
    self.EffectGO[effectid].go.transform.position = Vector3(posi.x, posi.y, -9)
    self.EffectGO[effectid].go:SetActive(true)
end

EffectBrocastEumn = {
    [1] = {effectid = 30065, time = 10, soundId = 262},
    [2] = {effectid = 30153, time = 10, soundId = 262},
    [3] = {effectid = 30154, time = 10, soundId = 262},
    [4] = {effectid = 30164, time = 10, soundId = 262},
    [5] = {effectid = 30165, time = 10, soundId = 262},
    [6] = {effectid = 30166, time = 10, soundId = 262},
    [30074] = {effectid = 30074, time = 10, soundId = 248},
    [30075] = {effectid = 30075, time = 10, soundId = 248},
}