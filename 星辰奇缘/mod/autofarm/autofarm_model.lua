AutoFarmModel = AutoFarmModel or BaseClass(BaseModel)

function AutoFarmModel:__init()
    self.mainwin = nil
    self.buttonArea = nil
    self.autofarmMgr = AutoFarmManager.Instance
end

function AutoFarmModel:OpenMain()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支持挂机"))
        return
    end
    if self.mainwin == nil then
        self.mainwin = AutoFarmWindow.New(self)
    end
    self.mainwin:Open()
end

function AutoFarmModel:CloseMain()
    if self.mainwin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainwin)
    end
end

function AutoFarmModel:SetPoint()
     if self.mainwin ~= nil then
        self.mainwin:setPoint()
    end
end

function AutoFarmModel:DeleteMain()
    if self.mainwin ~= nil then
        self.mainwin:DeleteMe()
        self.mainwin = nil
    end
end

function AutoFarmModel:ShowButtonArea(args)
    if BaseUtils.IsVerify then
        return
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.MainUIIconView.gameObject) then
        if self.buttonArea == nil then
            self.buttonArea = AutoFarmButtonArea.New(self)
        end
        self.buttonArea:Show(args)
    end
end

function AutoFarmModel:CloseButtonArea()
    if self.buttonArea ~= nil then
        self.buttonArea:Hiden()
    end
end