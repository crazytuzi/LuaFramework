-- 节点检查，针对挂特效的问题
-- @author huangyq
GoNodeChecker = GoNodeChecker or BaseClass()

function GoNodeChecker:__init(poolType, modelId, nodeList)
    self.poolType = poolType
    self.modelId = modelId
    self.nodeList = nodeList
    
    self.path = nil
    if poolType == GoPoolType.Role then
        self.path = "prefabs/roles/model/" .. self.modelId .. ".unity3d"
    elseif poolType == GoPoolType.Npc then
        self.path = "prefabs/npc/model/" .. self.modelId .. ".unity3d"
    elseif poolType == GoPoolType.Wing then
        self.path = "prefabs/wing/model/" .. self.modelId .. ".unity3d"
    elseif poolType == GoPoolType.Ride then
        self.path = "prefabs/ride/model/" .. self.modelId .. ".unity3d"
    end
end

function GoNodeChecker:__delete()
    self.poolType = nil
    self.modelId =  nil
    self.nodeList = nil
end

function GoNodeChecker:Check(path, poolObj)
    if self.path == nil then
        return 
    end

    if self.path == path then
        local node = nil
        for _, data in ipairs(self.nodeList) do
            node = poolObj.transform:FindChild(data)
            if node ~= nil then
                self:DeleteChild(node)
            end
        end
    end
end

function GoNodeChecker:DeleteChild(node)
    if node ~= nil then
        local count = node.transform.childCount
        if count > 0 then
            local list = {}
            for i = 1, count do
                local child = node.transform:GetChild(i-1)
                table.insert(list, child)
            end
            for _, data in ipairs(list) do
                GameObject.Destroy(data.gameObject)
            end
        end
    end
end

