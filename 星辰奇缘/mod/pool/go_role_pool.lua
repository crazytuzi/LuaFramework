-- 角色模型对象池
-- @author huangyq
-- @date   160726
GoRolePool = GoRolePool or BaseClass(GoBasePool)

function GoRolePool:__init(parent)
    self.name = "role_tpose"
    self.maxSize = 30
    self.checkCount = 41
    self.parent = parent
    self.Type = GoPoolType.Role
    self:SetIgnoreFlag()
end

function GoRolePool:__delete()
end

function GoRolePool:Reset(poolObj, path)
    local node = poolObj.transform:FindChild("Bip_L_Weapon")
    if node ~= nil then
        self:DeleteRoleChild(node)
    end
    node = poolObj.transform:FindChild("Bip_R_Weapon")
    if node ~= nil then
        self:DeleteRoleChild(node)
    end
    self:ClearMesh(poolObj)
    self:ClearBpObj(poolObj, 10)
    self:ResetModel(poolObj)
end

function GoRolePool:DeleteRoleChild(node)
    if node ~= nil then
        local count = node.transform.childCount
        if count > 0 then
            local list = {}
            for i = 1, count do
                local child = node.transform:GetChild(i-1)
                if string.find(child.name, "Weapon") == nil then
                    table.insert(list, child)
                end
            end
            for _, data in ipairs(list) do
                GameObject.Destroy(data.gameObject)
            end
        end
    end
end
