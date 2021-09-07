-- --------------------------------
-- 功能开启
-- hosr
-- --------------------------------
OpensysManager = OpensysManager or BaseClass(BaseManager)

function OpensysManager:__init()
    if OpensysManager.Instance ~= nil then
        return
    end
    OpensysManager.Instance = self
    self.model = OpensysModel.New()
end

function OpensysManager:Show(args)
    self.model:Show(args)
end