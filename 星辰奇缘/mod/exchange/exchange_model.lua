ExchangeModel = ExchangeModel or BaseClass(BaseModel)


function ExchangeModel:__init()
    self.panel = nil
    self.win = nil
    self.exchangeMgr = ExchangeManager.Instance
end

function ExchangeModel:__delete()
    self.panel = nil
    self.win = nil
end

function ExchangeModel:OpenPanel(args)
    if self.panel == nil then
        self.panel = ExchangePanel.New(self)
        self.panel:Show(args)
        -- Inserted by 嘉俊 加入对是否正在自动历练和自动职业任务的检测
        if AutoQuestManager.Instance.model.isOpen then
            print("银币不足导致自动停止") -- 输出信息找bug
            AutoQuestManager.Instance.disabledAutoQuest:Fire()
        end
        -- end by 嘉俊
    end
end

function ExchangeModel:ClosePanel()
    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end
end

function ExchangeModel:OpenWindow(args)
    if self.win == nil then
        self.win = ExchangeWindow.New(self)
    end
    self.win:Open(args)
end

function ExchangeModel:CloseWindow()
    if self.win ~= nil then
        WindowManager.Instance:CloseWindow(self.win)
    end
end
