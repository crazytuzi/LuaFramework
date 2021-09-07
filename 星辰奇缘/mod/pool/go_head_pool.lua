-- 角色头模型对象池
-- @author huangyq
-- @date   160726
GoHeadPool = GoHeadPool or BaseClass(GoBasePool)

function GoHeadPool:__init(parent)
    self.name = "head_tpose"
    self.maxSize = 30
    self.checkCount = 36
    self.parent = parent
    self.Type = GoPoolType.Head
    self:SetIgnoreFlag()
end

function GoHeadPool:__delete()
end

function GoHeadPool:Reset(poolObj, path)
    self:ClearMesh(poolObj)
    self:ResetModel(poolObj)
end
