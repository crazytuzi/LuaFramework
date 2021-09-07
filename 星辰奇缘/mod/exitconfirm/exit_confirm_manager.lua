-- 退出确认

ExitConfirmManager = ExitConfirmManager or BaseClass()

function ExitConfirmManager:__init()
    if ExitConfirmManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    ExitConfirmManager.Instance = self;

    self.model = ExitConfirmModel.New()
end

function ExitConfirmManager:__delete()
end

function ExitConfirmManager:OpenWindow()
    self.model:OpenWindow()
end
