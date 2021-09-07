-- -------------------------
-- 角色宠物加点管理
-- hosr
-- -------------------------
AddPointManager = AddPointManager or BaseClass(BaseManager)

function AddPointManager:__init()
    if AddPointManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    AddPointManager.Instance = self

    self.model = nil
end

function AddPointManager:Open(args)
    if self.model == nil then
        self.model = AddPointModel.New()
    end
    self.model:Open(args)
    --self:Send10026()
end

-- 获取人物装备加成点数
function AddPointManager:Send10026()
    self:Send(10026, {})
end
