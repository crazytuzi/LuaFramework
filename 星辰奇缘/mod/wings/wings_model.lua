-- @author 黄耀聪
-- @date 2017年5月15日

WingsModel = WingsModel or BaseClass(BaseModel)

function WingsModel:__init()
    self.cur_selected_option = 1
end

function WingsModel:__delete()
end

function WingsModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = WingsWindow.New(self)
    end
    self.mainWin:Open(args)
end

function WingsModel:OpenBook(args)
    if self.wingBook == nil then
        self.wingBook = WingsHandbookWindow.New(self)
    end
    self.wingBook:Open(args)
end

function WingsModel:OpenWingSkillPanel(args)
    if self.skillPanel == nil then
        self.skillPanel = WingSkillPanel.New(self, TipsManager.Instance.model.tipsCanvas) -- BackpackManager.Instance.mainModel.mainWindow.gameObject)
    end
    self.skillPanel:Show(args)
end

function WingsModel:CloseWingSkillPanel()
    if self.skillPanel ~= nil then
        self.skillPanel:Hiden()
    end
end


--打开翅膀技能方案切换确认
function WingsModel:OpenOptionConfirmPanel()
    if self.skillOptionConfirmPanel == nil then
        self.skillOptionConfirmPanel = WingOptionConfirmWindow.New(self)
        self.skillOptionConfirmPanel:Show()
    end
end

--关闭翅膀技能方案切换确认
function WingsModel:CloseOptionConfirmPanel()
    if self.skillOptionConfirmPanel ~= nil then
        self.skillOptionConfirmPanel:DeleteMe()
        self.skillOptionConfirmPanel = nil
    end
end

function WingsModel:OpenShow(args)
    if self.showWin == nil then
        self.showWin = ModelShowWindow.New(self)
    end
    self.showWin:Open(args)
end

function WingsModel:ShowIllusion(args)
    if self.illusionPanel == nil then
        self.illusionPanel = WingIllusionSuccess.New(self)
    end
    self.illusionPanel:Show(args)
end

function WingsModel:CloseIllusion()
    if self.illusionPanel ~= nil then
        self.illusionPanel:DeleteMe()
        self.illusionPanel = nil
    end
end

function WingsModel:OpenTurnplant(args)
    if self.turnplant == nil then
        self.turnplant = WingsTurnplant.New(self)
    end
    self.turnplant:Open(args)
end

function WingsModel:OpenEnergy()
    if self.energyPanel == nil then
        self.energyPanel = WingsEnergy.New(self)
    end
    self.energyPanel:Show()
end

function WingsModel:CloseEnergy()
    if self.energyPanel ~= nil then
        self.energyPanel:DeleteMe()
        self.energyPanel = nil
    end
end
