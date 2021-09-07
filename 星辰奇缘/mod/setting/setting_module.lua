-- @author zgs
SettingModel = SettingModel or BaseClass(BaseModel)

function SettingModel:__init()
    self.gaWin = nil
    self.boardList = {}
    self.funcTab = {}
    self.isNeedShowRedPointUpdateNotice = false
    self.isFirstShow = true

    self.isLowerFrame = false -- 当前是否降帧状态
end

function SettingModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
end

function SettingModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = SettingWindow.New(self)
    end
    self.gaWin:Open(args)
end

function SettingModel:SetUpdateNoticeRedPoint(bo)
    self.isNeedShowRedPointUpdateNotice = bo
    if self.gaWin ~= nil then
        self.gaWin:SetUpdateNoticeRedPoint(bo)
    end
    self:CheckMainUIIconRedPoint()
end

function SettingModel:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(8, self.isNeedShowRedPointUpdateNotice)
    end
end

function SettingModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)

    self:DoAfterClose()
end

function SettingModel:DoAfterClose()
    for k,v in pairs(self.funcTab) do
        if v ~= nil then
            v()
            self.funcTab[k] = nil
        end
    end
end

