-- 翅膀
-- @author huangyq
-- @date   160726
GoWingPool = GoWingPool or BaseClass(GoBasePool)

function GoWingPool:__init(parent)
    self.name = "wing_node"
    self.maxSize = 30
    self.checkCount = 44
    self.parent = parent
    self.Type = GoPoolType.Wing

    self.checkerList = {
        GoNodeChecker.New(GoPoolType.Wing, 10033, {"wing_tpose/bp_l_wing1", "wing_tpose/bp_r_wing1"})
        , GoNodeChecker.New(GoPoolType.Wing, 10034, {"wing_tpose/bp_l_wing1", "wing_tpose/bp_r_wing1"})
    }
    self:SetIgnoreFlag()
end

function GoWingPool:__delete()
end

function GoWingPool:Reset(poolObj, path)
    for _, checker in ipairs(self.checkerList) do
        checker:Check(path, poolObj)
    end

    local node = poolObj.transform:FindChild("wing_tpose/bp_wing")
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

    self:ClearMesh(poolObj)
    self:ResetModel(poolObj)
end
