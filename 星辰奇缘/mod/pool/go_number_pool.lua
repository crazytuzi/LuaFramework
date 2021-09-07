-- 数字，战斗专用
-- @author huangyq
-- @date   160726
GoNumberPool = GoNumberPool or BaseClass(GoBasePool)

function GoNumberPool:__init(parent)
    self.name = "number_node"
    self.maxSize = 80
    self.checkCount = 40
    self.assetType = AssetType.Dep
    self.parent = parent
    self.Type = GoPoolType.Number
    self:SetIgnoreFlag()
end

function GoNumberPool:__delete()
end

function GoNumberPool:Reset(poolObj, path)
    self:ResetModel(poolObj)
end

function GoNumberPool:OnTickNum(now, OnTickCtx)
    if self.poolIndex == OnTickCtx.poolIndex and OnTickCtx.done == false then
        if not CombatManager.Instance.isFighting then
            local res = self:ClearPoolData(self.timeout, now, 5)
            if res then
                OnTickCtx.done = true
            end
        end
        OnTickCtx.poolIndex = OnTickCtx.poolIndex + 1
        if OnTickCtx.poolIndex >= GoPoolManager.Instance.poolIndex then
            OnTickCtx.poolIndex = 1
        end
    end
end
