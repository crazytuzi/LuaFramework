-- 联赛场景水晶塔管理
-- 2016年09月24日
-- hzf

GuildLeagueTowerControl = GuildLeagueTowerControl or BaseClass()

function GuildLeagueTowerControl:__init(model)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.timer = LuaTimer.Add(0, 1000, function()
        self:Update()
    end)
    self.selfEffectPath = "prefabs/effect/30139.unity3d"
    self.otherEffectPath = "prefabs/effect/30141.unity3d"
    self.selfDestroyEffectPath = "prefabs/effect/30143.unity3d"
    self.otherDestroyEffectPath = "prefabs/effect/30144.unity3d"
    self.selfEffect_id = 30139
    self.otherEffect_id = 30141
    self.selfDestroyEffect_id = 30143
    self.otherDestroyEffect_id = 30144
    self.unitEffectList = {}
    self.unitBlood = {}
    self.brokenEffectList = {}
    self.on_role_event_change = function()
        self:OnEventChange()
    end
    EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)
end

function GuildLeagueTowerControl:__delete()
    for k,v in pairs(self.unitBlood) do
        if not BaseUtils.isnull(v) then
            GameObject.Destroy(v)
        end
    end
    self.unitBlood = {}
    for k,v in pairs(self.unitEffectList) do
        if v ~= nil and v ~= true and v ~= false then
            v:DeleteMe()
        end
    end
    for k,v in pairs(self.brokenEffectList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end

function GuildLeagueTowerControl:Update()
    -- print("水晶塔控制器")
    if self.Mgr.towerData == nil then
        return
    end
    -- print("水晶塔更新："..tostring(self.Mgr.towerData))
    for _,tower in pairs(self.Mgr.towerData) do
        for _,unit in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
            if unit.data.unittype == 1 and unit.data.id < 7 and tower.unit_id == unit.data.id then
                if tower.duration > 0 and self.unitEffectList[tower.unit_id] == nil then
                    self.unitEffectList[tower.unit_id] = true
                    LuaTimer.Add(tower.unit_id*700, function() self:InitTowerEffect(unit, tower.unit_id) end)
                elseif tower.duration <= 0 and self.unitEffectList[tower.unit_id] ~= nil then
                    self:ShowDestroy(unit, tower.unit_id)
                end
                if self.unitBlood[tower.unit_id] == nil then
                    if not BaseUtils.isnull(SceneTalk.Instance.bloodprefab) then
                        if not BaseUtils.isnull(unit.gameObject) then
                            self.unitBlood[tower.unit_id] = GameObject.Instantiate(SceneTalk.Instance.bloodprefab)
                            self.unitBlood[tower.unit_id].transform:SetParent(unit.gameObject.transform)
                            self.unitBlood[tower.unit_id].transform.localPosition = Vector3(0,1.3,-1)
                            self.unitBlood[tower.unit_id].transform.localScale = Vector3.one*0.004
                            self.unitBlood[tower.unit_id]:SetActive(true)
                            self:SetBlood(tower.unit_id, tower.duration)
                        end
                    end
                else
                    self:SetBlood(tower.unit_id, tower.duration)
                end
            end
        end
    end
end

function GuildLeagueTowerControl:InitTowerEffect(unit, unit_id)
    if BaseUtils.isnull(unit.gameObject) then
        self.unitEffectList[unit_id] = nil
        return
    end
    -- print("塔："..tostring(unit_id).." 初始化特效")
    local effect_id = self.selfEffect_id
    if unit_id > 3 then
        effect_id = self.otherEffect_id
    end
    if unit_id == 3 then
        effect_id = 30140
    elseif unit_id == 6 then
        effect_id = 30142
    end
    local callback = function(effectview)
        if BaseUtils.isnull(unit.gameObject) then
            self.unitEffectList[unit_id]:DeleteMe()
            self.unitEffectList[unit_id] = nil
            return
        end
        local trans = unit:GetCachedTransform()
        effectview.transform:SetParent(trans)
        effectview.transform.localScale = Vector3.one
        if unit_id%3 == 0 then
            effectview.transform.localPosition = Vector3.zero
            effectview.transform.rotation = Quaternion.identity
            effectview.transform:Rotate(Vector3(340, 0, 0))
        else
            effectview.transform.localPosition = Vector3(0, 0.3, 0)
            effectview.transform.rotation = Quaternion.identity
            effectview.transform:Rotate(Vector3(320, 0, 0))
        end
        Utils.ChangeLayersRecursively(effectview.transform, "Model")
    end
    self.unitEffectList[unit_id] = BaseEffectView.New({ effectId = effect_id, callback = callback })
end

function GuildLeagueTowerControl:ShowDestroy(unit,unit_id)
    if BaseUtils.isnull(unit.gameObject) or unit_id%3 == 0 then
        return
    end
    if self.brokenEffectList[unit_id] ~= nil then
        self.brokenEffectList[unit_id]:DeleteMe()
    end
    local effect_id = self.selfDestroyEffect_id
    if unit_id > 3 then
        effect_id = self.otherDestroyEffect_id
    end
    -- self.unitEffectList[unit_id]:DeleteMe()
    local callback = function(effectview)
        if self.unitEffectList[unit_id] ~= nil then
            self.unitEffectList[unit_id]:DeleteMe()
            self.unitEffectList[unit_id] = nil
        end
        local trans = unit:GetCachedTransform()
        effectview.transform:SetParent(trans)
        effectview.transform.localScale = Vector3.one
        effectview.transform.localPosition = Vector3(0, 0.3, 0)
        effectview.transform.rotation = Quaternion.identity
        effectview.transform:Rotate(Vector3(320, 0, 0))
        Utils.ChangeLayersRecursively(effectview.transform, "Model")
        -- LuaTimer.Add(1500, function()
        -- end)
        LuaTimer.Add(3500, function()
            if self.brokenEffectList[unit_id] ~= nil then
                self.brokenEffectList[unit_id]:DeleteMe()
                self.brokenEffectList[unit_id] = nil
            end
        end)
    end
    self.brokenEffectList[unit_id] = BaseEffectView.New({ effectId = effect_id, callback = callback })
end


function GuildLeagueTowerControl:OnEventChange()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Guildleague then
        self.model:StopTowerControll()
    end
end

function GuildLeagueTowerControl:SetBlood(unit_id, duration)
    if self.unitBlood[unit_id] == nil then
        return
    end
    local go = self.unitBlood[unit_id]
    if unit_id > 3 then
        local bar = go.transform:Find("originitem/rblood")
        bar.gameObject:SetActive(true)
        bar.sizeDelta = Vector2(151*duration/DataGuildLeague.data_tower_info[unit_id].duration, 14.4)
        if duration > 0 then
            go.transform:Find("originitem/Text"):GetComponent(Text).text = string.format("%s%%", math.ceil(duration/DataGuildLeague.data_tower_info[unit_id].duration*100))
        else
            go:SetActive(false)
            go.transform:Find("originitem/Text"):GetComponent(Text).text = ""
        end
    else
        local bar = go.transform:Find("originitem/bblood")
        bar.gameObject:SetActive(true)
        bar.sizeDelta = Vector2(151*duration/DataGuildLeague.data_tower_info[unit_id].duration, 14.4)
        if duration > 0 then
            go.transform:Find("originitem/Text"):GetComponent(Text).text = string.format("%s%%", math.ceil(duration/DataGuildLeague.data_tower_info[unit_id].duration*100))
        else
            go:SetActive(false)
            go.transform:Find("originitem/Text"):GetComponent(Text).text = ""
        end
    end
end