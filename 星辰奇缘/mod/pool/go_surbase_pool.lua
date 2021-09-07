-- 腰饰模型对象池
-- @author huangyq
-- @date   160726
GoSurbasePool = GoSurbasePool or BaseClass(GoBasePool)

function GoSurbasePool:__init(parent)
    self.name = "belt_tpose"
    self.maxSize = 30
    self.checkCount = 42
    self.parent = parent
    self.Type = GoPoolType.Surbase
    self:SetIgnoreFlag()
end

function GoSurbasePool:__delete()
end

function GoSurbasePool:Reset(poolObj, path)
    self:ResetModel(poolObj)
end
