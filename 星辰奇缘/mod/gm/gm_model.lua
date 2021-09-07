GmModel = GmModel or BaseClass(BaseModel)

function GmModel:__init()
    self.gmWindow = nil
end

function GmModel:__delete()
end

function GmModel:OpenGmWindow()
    if self.gmWindow == nil then
        self.gmWindow = GmWindow.New(self)
        self.gmWindow:Open()
    else
        self.gmWindow:Open()
    end
end

function GmModel:CloseGmWindow()
    if self.gmWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.gmWindow)
    end
end

function GmModel:OpenHotFixWindow()
    if self.hotfixWindow == nil then
        self.hotfixWindow = HotFixWindow.New(self)
        self.hotfixWindow:Open()
    else
        self.hotfixWindow:Open()
    end
end

function GmModel:CloseHotFixWindow()
    if self.hotfixWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.hotfixWindow)
    end
end

function GmModel:DoCaton()  
    for i = 1, 10000 do
        --toTo  hze
        print("卡卡卡")
    end
end

