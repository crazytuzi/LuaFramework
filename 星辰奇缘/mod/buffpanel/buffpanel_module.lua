BuffPanelModel = BuffPanelModel or BaseClass(BaseModel)

function BuffPanelModel:__init()
    self.buffPanelWin = nil
    self.prewarPanelWin = nil
    self.glyphsQuickBackpackWindow = nil
    
    self.buffDic = {}
end

function BuffPanelModel:__delete()
    if self.buffPanelWin then
        self.buffPanelWin = nil
    end
end

function BuffPanelModel:OpenWindow(args)
    if self.buffPanelWin == nil then
        self.buffPanelWin = BuffPanelWindow.New(self)
    end
    self.buffPanelWin:Show(args)
end

function BuffPanelModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.buffPanelWin, true)
end

function BuffPanelModel:UpdateFreezBtn()
    if self.buffPanelWin ~= nil then
        self.buffPanelWin:UpdateFreezBtn()
    end
end

function BuffPanelModel:OpenPrewarPanel(args)
    if self.prewarPanelWin == nil then
        self.prewarPanelWin = PrewarPanel.New(self)
    end
    self.prewarPanelWin:Show(args)
end

function BuffPanelModel:ClosePrewarPanel()
    -- WindowManager.Instance:CloseWindow(self.prewarPanelWin, true)
    if self.prewarPanelWin ~= nil then
        self.prewarPanelWin:DeleteMe()
        self.prewarPanelWin = nil
    end
end

function BuffPanelModel:OpenGlyphsQuickBackpackWindow(args)
    if self.glyphsQuickBackpackWindow == nil then
        self.glyphsQuickBackpackWindow = GlyphsQuickBackpackWindow.New(self)
    end
    self.glyphsQuickBackpackWindow:Show(args)
end

function BuffPanelModel:CloseGlyphsQuickBackpackWindow()
    if self.glyphsQuickBackpackWindow ~= nil then
        self.glyphsQuickBackpackWindow:DeleteMe()
        self.glyphsQuickBackpackWindow = nil
    end
end