-- 子女系统
-- hzf
-- 2017年01月04日15:42:11

ChildrenModel = ChildrenModel or BaseClass()

function ChildrenModel:__init()

end

function ChildrenModel:__delete()

end

function ChildrenModel:OpenGetWindow(args)
    if self.getwindow == nil then
        self.getwindow = ChildrenGetWindow.New(self)
    end
    self.getwindow:Open(args)
end

function ChildrenModel:CloseGetWindow(args)
    if self.getwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.getwindow)
    end
end

function ChildrenModel:OpenWaterWindow()
    if self.waterwindow == nil then
        self.waterwindow = ChildrenWaterWindow.New(self)
    end
    self.waterwindow:Open(args)
end

function ChildrenModel:CloseWaterWindow(args)
    if self.waterwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.waterwindow)
    end
end


function ChildrenModel:OpenGetWayPanel()
    if self.getwatpanel == nil then
        self.getwatpanel = ChildrenGetWayPanel.New(self)
    end
    self.getwatpanel:Show(args)
end

function ChildrenModel:CloseGetWayPanel(args)
    if self.getwatpanel ~= nil then
        self.getwatpanel:DeleteMe()
        self.getwatpanel = nil
    end
end


function ChildrenModel:OpenContainerPanel()
    if self.containerpanel == nil then
        self.containerpanel = ChildrenContainerPanel.New(self)
    end
    self.containerpanel:Show(args)
end

function ChildrenModel:CloseContainerPanel(args)
    if self.containerpanel ~= nil then
        self.containerpanel:DeleteMe()
        self.containerpanel = nil
    end
end


function ChildrenModel:OpenEduWindow()
    if ChildrenManager.Instance:GetChildhood() == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("你当前没有可教育的幼年期孩子"))
        return
    end
    if self.eduwindow == nil then
        self.eduwindow = ChildrenEducationWindowv.New(self)
    end
    self.eduwindow:Open(args)
end

function ChildrenModel:CloseEduWindow(args)
    if self.eduwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.eduwindow)
    end
end


function ChildrenModel:OpenNoticePanel(args)
    if self.noticepanel == nil then
        self.noticepanel = ChidldrenNoticePanel.New(self)
    end
    self.noticepanel:Show(args)
end

function ChildrenModel:CloseNoticePanel(args)
    if self.noticepanel ~= nil then
        self.noticepanel:DeleteMe()
        self.noticepanel = nil
    end
end


function ChildrenModel:OpenNoticeTargetPanel(args)
    if self.noticetargetpanel == nil then
        self.noticetargetpanel = ChildrenNoticeTargetPanel.New(self)
    end
    self.noticetargetpanel:Show(args)
end

function ChildrenModel:CloseNoticeTargetPanel(args)
    if self.noticetargetpanel ~= nil then
        self.noticetargetpanel:DeleteMe()
        self.noticetargetpanel = nil
    end
end

function ChildrenModel:OpenChooseClasses()
    if self.chooseClasses == nil then
        self.chooseClasses = ChildrenChooseClassesPanel.New(self)
    end
    self.chooseClasses:Show()
end

function ChildrenModel:CloseChooseClasses()
    if self.chooseClasses ~= nil then
        self.chooseClasses:DeleteMe()
        self.chooseClasses = nil
    end
end

function ChildrenModel:OpenChangeType(args)
    if self.changeType == nil then
        self.changeType = ChildrenChangeTypePanel.New(self)
    end
    self.changeType:Show(args)
end

function ChildrenModel:CloseChangeType()
    if self.changeType ~= nil then
        self.changeType:DeleteMe()
        self.changeType = nil
    end
end

function ChildrenModel:OpenNoticeResultPanel(args)
    if self.noticeresultpanel == nil then
        self.noticeresultpanel = ChildrenNoticeResultPanel.New(self)
    end
    self.noticeresultpanel:Show(args)
end

function ChildrenModel:CloseNoticeResultPanel(args)
    if self.noticeresultpanel ~= nil then
        self.noticeresultpanel:DeleteMe()
        self.noticeresultpanel = nil
    end
end

function ChildrenModel:OpenChildQuickShow(args)
    if self.childQuickShowWindow == nil then
        self.childQuickShowWindow = ChildQuickShowView.New(self)
    end
    self.childQuickShowWindow:Open(args)
end

function ChildrenModel:CloseChildQuickShow()
    if self.childQuickShowWindow ~= nil then
        self.childQuickShowWindow:DeleteMe()
        self.childQuickShowWindow = nil
    end
end

function ChildrenModel:OpenChildGenWash(args)
    if self.childgemwashview == nil then
        self.childgemwashview = ChildGemWashView.New(self)
    end
    self.childgemwashview:Open(args)
end

function ChildrenModel:CloseChildGenWash()
    if self.childgemwashview ~= nil then
        self.childgemwashview:DeleteMe()
        self.childgemwashview = nil
    end
end

function ChildrenModel:OpenGetBoyPanel(args)
    if self.getboypanel == nil then
        self.getboypanel = ChildrenGetBoyPanel.New(self)
    end
    self.getboypanel:Show(args)
end

function ChildrenModel:CloseGetBoyPanel()
    if self.getboypanel ~= nil then
        self.getboypanel:DeleteMe()
        self.getboypanel = nil
    end
end

-- 开始打水
function ChildrenModel:StartGetWater()
    print("开始打水了")
    if self.waterwindow ~= nil then
        self.waterwindow:CountDown()
    end
end

function ChildrenModel:OpenRename(args)
    if self.childRename == nil then
        self.childRename = ChildRenamePanel.New(self)
    end
    self.childRename:Show(args)
end

function ChildrenModel:CloseRename()
    if self.childRename ~= nil then
        self.childRename:DeleteMe()
        self.childRename = nil
    end
end

-- 打开抛弃界面
function ChildrenModel:OpenGiveUpWindow(args)
    if self.giveupwin == nil then
        self.giveupwin = ChildrenGiveUpWindow.New(self)
    end
    self.giveupwin:Open(self)
end


function ChildrenModel:CloseGiveUpWindow(args)
    if self.giveupwin ~= nil then
        WindowManager.Instance:CloseWindow(self.giveupwin)
    end
end

-- 打开学习计划
function ChildrenModel:OpenStudyPlan(args)
    if self.studyPlan == nil then
        self.studyPlan = ChildrenStudyPlanPanel.New(self)
    end
    self.studyPlan:Open(args)
end

function ChildrenModel:CloseStudyPlan()
    if self.studyPlan ~= nil then
        WindowManager.Instance:CloseWindow(self.studyPlan)
    end
end