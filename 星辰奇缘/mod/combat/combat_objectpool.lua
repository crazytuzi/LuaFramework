-- 战斗对象池
CombatObjectPool = CombatObjectPool or BaseClass()

local GameObject = UnityEngine.GameObject
local Time = UnityEngine.Time

function CombatObjectPool:__init()
    self.num = 0
    -- self.real = 0
    self.tick = 0
    self.obj_list = {}
    self.obj_info = {}
    self.unit_list = {}
    self.unit_info = {}
    self.parent = GameObject("GameObjectPool")
    GameObject.DontDestroyOnLoad(self.parent)
    self.parent.transform.position = Vector3.one * -100
    self.specialSet = {
        ["AttrChange"] = 50,
        ["Blood"] = 10,
    }
end

function CombatObjectPool:__delete()
    -- print(string.format("@@特效共计请求创建%s次@@,实际创建%s次", tostring(self.num), tostring(self.real)))
    GameObject.DestroyImmediate(self.parent)
    self.obj_list = nil
end

function CombatObjectPool:Pop(id)
    -- self.num = self.num + 1
    local index = 1
    if self.obj_list[id] ~= nil and #self.obj_list[id] > 0 then
        self.obj_info[id] = Time.time
        index = #self.obj_list[id]
        local go = self.obj_list[id][index]
        table.remove(self.obj_list[id])
        -- print(string.format("<color='#ffff00'>出池：\"%s\"</color>", tostring(id)))
        if BaseUtils.isnull(go) then
            return nil
        else
            go:SetActive(true)
        -- print(string.format("<color='#ffff00'>出池：\"%s\"</color>", tostring(id)))
            return go
        end
    end
    -- print(string.format("<color='#ff0000'>创建：\"%s\"</color>", tostring(id)))
    -- self.real = self.real + 1
    return nil
end

function CombatObjectPool:Push(go, id)
    -- print(string.format("<color='#00ff00'>入池：\"%s\"</color>", tostring(id)))
    if BaseUtils.isnull(go) then
        return
    end
    go:SetActive(false)
    go.transform:SetParent(self.parent.transform)
    go.transform.localPosition = Vector3(0, 0, 0)
    if self.obj_list[id] == nil then
        self.obj_list[id] = {}
        table.insert( self.obj_list[id], go)
        self.obj_info[id] = Time.time
    else
        if (self.specialSet[id] ~= nil and #self.obj_list[id] > self.specialSet[id]) or #self.obj_list[id] > 9 then
            GameObject.DestroyImmediate(go)
        else
            table.insert( self.obj_list[id], go)
        end
        self.obj_info[id] = Time.time
    end
end

function CombatObjectPool:OnTick()
    self.tick = self.tick + 1
    if self.tick > 20 then
        -- print("<color='#ffff00'>清除</color>")
        local info_List = BaseUtils.copytab(self.obj_info)
        local unit_List = BaseUtils.copytab(self.unit_info)
        local currtime = Time.time
        self.tick = 0
        for id , last in pairs(info_List) do
            if currtime - last > 180 then
                self.obj_info[id] = nil
                self:KillObj(id)
            end
        end
        for id , last in pairs(unit_List) do
            if currtime - last > 200 then
                self.unit_info[id] = nil
                self:KillUnit(id)
            end
        end
    end
end

function CombatObjectPool:KillObj(id)
    for i,go in ipairs(self.obj_list[id]) do
        GameObject.Destroy(go)
    end
    self.obj_list[id] = nil
end


function CombatObjectPool:KillUnit(id)
    for i,go in ipairs(self.unit_list[id]) do
        GameObject.Destroy(go)
    end
    self.unit_list[id] = nil
end


function CombatObjectPool:PopUnit(id)
    local index = 1
    if self.unit_list[id] ~= nil and #self.unit_list[id] > 0 then
        self.unit_info[id] = Time.time
        index = #self.unit_list[id]
        local go = self.unit_list[id][index]
        -- BaseUtils.dump(self.unit_list, id)
        table.remove(self.unit_list[id], index)
        if BaseUtils.isnull(go) then
            return nil
        else
            go:SetActive(true)
        -- print(string.format("<color='#ffff00'>出池：\"%s\"</color>", tostring(id)))
            return go
        end
    end
    -- print(string.format("<color='#ff0000'>创建：\"%s\"</color>", tostring(id)))
    return nil
end

function CombatObjectPool:PushUnit(go, id)
    -- print(string.format("<color='#00ff00'>入池：\"%s\"</color>", tostring(id)))
    -- print(go)
    if BaseUtils.isnull(go) then
        return
    end
    if id == nil then
        Log.Error("Path is nill while PushUnit:".. debug.traceback())
        GameObject.DestroyImmediate(go)
        return
    end
    -- local call = function() self:ClearMesh(go) end
    -- xpcall(call, function(errorinfo) Log.Error(errorinfo) end)

    self.num = self.num + 1
    go:SetActive(false)
    go.transform:SetParent(self.parent.transform)
    go.transform.localPosition = Vector3(0, 0, 0)
    go.transform.localRotation = Quaternion.identity
    CombatUtil.SetAlpha(go, 1)
    local lastObj_num = go.transform.childCount
    if lastObj_num > 2 then
        for i = 1, lastObj_num do
            local child = go.transform:GetChild(i-1)
            if string.find(child.gameObject.name, "(Clone)") ~= nil or string.find(child.gameObject.name, "Effect") ~= nil
                or string.find(child.gameObject.name, "effect_") ~= nil then
                GameObject.Destroy(child.gameObject)
                -- GameObject.Destroy(go)
            end
        end
    end
    if self.unit_list[id] == nil then
        self.unit_list[id] = {}
        table.insert( self.unit_list[id], go)
        self.unit_info[id] = Time.time
    else
        if #self.unit_list[id] > 9 then
            GameObject.DestroyImmediate(go)
        else
            table.insert( self.unit_list[id], go)
        end
        self.unit_info[id] = Time.time
    end
end

function CombatObjectPool:ClearMesh(go)
    if go == nil then
        return
    end
    if go.name ~= "Mesh_Weapon" and go.name ~= "Mesh_Belt" and string.find(go.name, "Mesh_") ~= nil then
        go.renderer.material.mainTexture = nil
    end
    local count = go.transform.childCount
    if count > 0 then
        for i = 1, count do
            local child = go.transform:GetChild(i-1)
            if string.find(child.name, "tpose") ~= nil or string.find(child.name, "Mesh_") ~= nil then
                if string.find(child.name, "wing") == nil then
                    self:ClearMesh(child)
                end
            end
        end
    end
end



function CombatObjectPool:EnoughGo(id, num)
    if self.unit_list[id] ~= nil and #self.unit_list[id] >= num then
        return true
    else
        return false
    end
end
