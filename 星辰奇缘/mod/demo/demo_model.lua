DemoModel = DemoModel or BaseClass(BaseModel)

function DemoModel:__init()
    self.mainUIWin= nil
    self.demoWin = nil
    self.demoPoolWin = nil
    self.demoLayoutWin = nil
    self.pageWindow = nil
    self.previewWindow = nil
end

function DemoModel:__delete()
    if self.mainUIWin ~= nil then
        self.mainUIWin:DeleteMe()
        self.mainUIWin = nil
    end

    if self.demoWin ~= nil then
        self.demoWin:DeleteMe()
        self.demoWin = nil
    end
end

function DemoModel:InitMainUI()
    if self.mainUIWin == nil then
        self.mainUIWin= DemoMainUIWindow.New(self)
        self.mainUIWin:Open()
    end
end

function DemoModel:OpenWindow1()
    if self.demoWin == nil then
        self.demoWin = DemoWindow.New(self)
        self.demoWin:Open()
    else
        self.demoWin:Open()
    end
end

function DemoModel:CloseWindow()
    if self.demoWin ~= nil then
        self.demoWin:DeleteMe()
        self.demoWin = nil
    end
end

function DemoModel:OpenPoolWindow()
    if self.demoPoolWin == nil then
        self.demoPoolWin = DemoPoolWindow.New(self)
        self.demoPoolWin:Open()
    else
        self.demoPoolWin:Open()
    end
end

function DemoModel:ClosePoolWindow()
    if self.demoPoolWin~= nil then
        self.demoPoolWin:DeleteMe()
        self.demoPoolWin = nil
    end
end

function DemoModel:OpenLayoutWindow()
    if self.demoLayoutWin == nil then
        self.demoLayoutWin = DemoLayoutWindow.New(self)
        self.demoLayoutWin:Open()
    else
        self.demoLayoutWin:Open()
    end
end
function DemoModel:DestroyLayoutWindow()
    if self.demoLayoutWin ~= nil then
        self.demoLayoutWin:DeleteMe()
        self.demoLayoutWin = nil
    end
end

function DemoModel:CloseLayoutWindow()
    WindowManager.Instance:CloseWindow(self.demoLayoutWin)
end

function DemoModel:CloseLayoutWindowForCache()
    if self.demoLayoutWin ~= nil then
        self.demoLayoutWin:Hiden()
    end
end

function DemoModel:OpenPageWindow()
    if self.pageWindow == nil then
        self.pageWindow = DemoPageWindow.New(self)
        self.pageWindow:Open()
    else
        self.pageWindow:Open()
    end
end

function DemoModel:ClosePageWindow()
    WindowManager.Instance:CloseWindow(self.pageWindow)
end

function DemoModel:OpenPreviewWindow()
    if self.previewWindow == nil then
        self.previewWindow = DemoPreviewWindow.New(self)
        self.previewWindow:Open()
    else
        self.previewWindow:Open()
    end
end

function DemoModel:ClosePreviewWindow()
    WindowManager.Instance:CloseWindow(self.previewWindow)
end
