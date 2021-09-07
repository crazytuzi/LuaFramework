-- -------------------------------
-- 引导从日程那里入口的功能界面
-- hosr
-- ------------------------------

GuideAgendaFunc = GuideAgendaFunc or BaseClass()

function GuideAgendaFunc:__init()
    self.mgr = GuideManager.Instance
    self.funcButton = nil
    self.funcId = 14
    self.agendaPanelId = WindowConfig.WinID.agendamain
    self.agendaButton = nil
    self.soundId = nil
    self.agendaId = nil
    self.panelId = nil
    self.callback = nil

    self.open = function(a) self:OnOpen(a) end
    self.close = function(arg) self:OnClose(arg) end
end

function GuideAgendaFunc:Start(args, callback)
    self.callback = callback
    self.agendaId = tonumber(args[2])
    self.panelId = tonumber(args[3])
    self.soundId = tonumber(args[5])
    self.desc = args[6]

    self.funcButton = MainUIManager.Instance.MainUIIconView:getbuttonbyid(self.funcId)
    if self.funcButton ~= nil then
        self.mgr.effect:Show(self.funcButton, Vector2(0, 40), 1)
        TipsManager.Instance:ShowGuide({gameObject = self.agendaButton, data = self.desc})
        if self.soundId ~= 0 then
            SoundManager.Instance:Play(self.soundId)
        end
    end
end

function GuideAgendaFunc:OnOpen(arg)
    if arg == self.agendaPanelId then
        --打开日程，找到对应的功能按钮
        self.agendaButton = AgendaManager.Instance.controller.mainpanel:GetStartBtnByID(true, 1002)
        self.mgr.effect:Show(self.agendaButton)
        TipsManager.Instance:ShowGuide({gameObject = self.agendaButton, data = self.desc})
    elseif arg == self.panelId then
        self:Finish()
        self.mgr.effect:Hide()
        if self.callback ~= nil then
            self.callback()
        end
        self.callback = nil
    end
end

function GuideAgendaFunc:OnClose(arg)
    if arg == self.agendaPanelId then
        self.callback = nil
        self:Finish()
        self.mgr:Interupt()
    end
end

function GuideAgendaFunc:Finish()
end