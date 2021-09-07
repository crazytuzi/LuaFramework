-- 模型包围体
-- @author huangyq
-- @date   160726
GoBoundPool = GoBoundPool or BaseClass(GoBasePool)

function GoBoundPool:__init(parent)
    self.name = "bound_node"
    self.assetType = AssetType.Dep
    self.maxSize = 20
    self.checkCount = 30
    self.parent = parent
    self.Type = GoPoolType.BoundRole

    self.roleNodes = {"RoleName", "RoleNameShadow", "Shadow", "GuildNameShadow", "GuildName", "Honor"}
    self.npcNodes = {"RoleName", "RoleNameShadow", "Shadow", "GuildNameShadow", "GuildName", "Honor", "State"}

    -- self.showNodes = {"RoleName", "RoleNameShadow", "Shadow", "GuildNameShadow"}
    self:SetIgnoreFlag()
end

function GoBoundPool:__delete()
end

function GoBoundPool:Reset(poolObj, path)
    self:ResetModel(poolObj)
end

function GoBoundPool:ReturnRole(poolObj, path)
    local count = poolObj.transform.childCount
    -- if count > 6 then
        self:CheckChild(self.roleNodes, poolObj)
    -- end
    local cp = poolObj:GetComponent(RoleController)
    if not BaseUtils.is_null(cp) then
        GameObject.Destroy(cp)
    end
    self:Return(poolObj, path)
end

function GoBoundPool:ReturnNpc(poolObj, path)
    local count = poolObj.transform.childCount
    -- if count > 7 then
        self:CheckChild(self.npcNodes, poolObj)
    -- end
    local cp = poolObj:GetComponent(UnitController)
    if not BaseUtils.is_null(cp) then
        GameObject.Destroy(cp)
    end
    self:Return(poolObj, path)
end

function GoBoundPool:CheckChild(nodes, poolObj)
    local count = poolObj.transform.childCount
    local list = {}
    if count > 0 then
        for i = 1, count do
            local child = poolObj.transform:GetChild(i-1)
            if not BaseUtils.ContainValueTable(nodes, child.name) then
                table.insert(list, child)
            end
            -- if BaseUtils.ContainValueTable(self.showNodes, child.name) then
            --     child.transform:SetActive(true)
            -- end
            if child.name == "Shadow" then
                child.transform.localPosition = Vector3(0, 0, 0)
            end
        end
    end
    for _, data in ipairs(list) do
        GameObject.Destroy(data.gameObject)
    end
end
