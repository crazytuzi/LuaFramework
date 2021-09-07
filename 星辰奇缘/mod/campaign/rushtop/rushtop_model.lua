RushTopModel = RushTopModel or BaseClass(BaseModel)

function RushTopModel:__init()
    self.myanswer = {}
    self.rightanswer = {}
    self.answershow = {}
    self.lost = false
end

function RushTopModel:__delete()
end

function RushTopModel:OpenWindow(args)
end

function RushTopModel:CloseWindow()
end

function RushTopModel:OpenSignUp(args)
    if self.signUpWin == nil then
        self.signUpWin = RushTopSignUp.New(self)
    end
    self.signUpWin:Open(args)
end

function RushTopModel:OpenMain(args)
    if self.mainWin == nil then
        self.mainWin = RushTopMain.New(self)
    end
    self.mainWin:Open(args)
end

function RushTopModel:OpenMainPanel(args)
    if self.mainPanel == nil then
        self.mainPanel = RushTopPanel.New(self)
    end
    self.mainPanel:Show(args)
end

function RushTopModel:CloseMainPanel()
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
end


function RushTopModel:OpenDescPanel(args)
    if self.descPanel == nil then
        self.descPanel = RushTopDescPanel.New(self)
    end
    self.descPanel:Show(args)
end

function RushTopModel:CloseDescPanel()
    if self.descPanel ~= nil then
        self.descPanel:DeleteMe()
        self.descPanel = nil
    end
end





function RushTopModel:OpenDamakuSetting()
    if self.damakuSetting == nil then
        self.damakuSetting = RushTopCloseDamaku.New(self, TipsManager.Instance.model.tipsCanvas)
    end
    self.damakuSetting:Show()
end

function RushTopModel:CloseDamakuSetting()
    if self.damakuSetting ~= nil then
        self.damakuSetting:DeleteMe()
        self.damakuSetting = nil
    end
end