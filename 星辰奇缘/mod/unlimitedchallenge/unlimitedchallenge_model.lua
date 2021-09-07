UnlimitedChallengeModel = UnlimitedChallengeModel or BaseClass()


function UnlimitedChallengeModel:__init()
    self.Mgr = UnlimitedChallengeManager.Instance
end

function UnlimitedChallengeModel:__delete()

end

function UnlimitedChallengeModel:OpenMainPanel()
    if self.mainPanel == nil then
        self.mainPanel = UnlimitedChallengePanel.New(self)
    end
    self.mainPanel:Show()
end

function UnlimitedChallengeModel:CloseMainPanel()
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
end

function UnlimitedChallengeModel:UpdateMember()
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateMemberList()
    else
        self:OpenMainPanel()
    end
end

function UnlimitedChallengeModel:ShowMsg(rid, platform, zone_id, text, BubbleID)
    if self.mainPanel ~= nil then
        self.mainPanel:ShowMsg(rid, platform, zone_id, text, BubbleID)
    end
end

function UnlimitedChallengeModel:OpenFrightInfoPanel()
    if self.infoPanel == nil then
        self.infoPanel = UnlimitedChallengeFrightInfoPanel.New(self)
    end
    self.infoPanel:Show()
end

function UnlimitedChallengeModel:CloseFrightInfoPanel()
    if self.infoPanel ~= nil then
        self.infoPanel:DeleteMe()
        self.infoPanel = nil
    end
end


function UnlimitedChallengeModel:OpenRankPanel()
    if self.rankPanel == nil then
        self.rankPanel = UnlimitedChallengeRankpanel.New(self)
    end
    self.rankPanel:Show()
end

function UnlimitedChallengeModel:CloseRankPanel()
    if self.rankPanel ~= nil then
        self.rankPanel:DeleteMe()
        self.rankPanel = nil
    end
end


function UnlimitedChallengeModel:OpenSkillSetPanel(args)
    if self.skillSetPanel == nil then
        self.skillSetPanel = UnlimitedChallengeSkillSetPanel.New(self)
    end
    self.skillSetPanel:Show(args)
end

function UnlimitedChallengeModel:CloseSkillSetPanel()
    if self.skillSetPanel ~= nil then
        self.skillSetPanel:DeleteMe()
        self.skillSetPanel = nil
    end
end

function UnlimitedChallengeModel:OpenCardWindow(args)
    if self.cardwindow == nil then
        self.cardwindow = UnlimitedChallengeCardWindow.New(self)
    end
    self.cardwindow:Show(args)
end

function UnlimitedChallengeModel:CloseCardWindow()
    if self.cardwindow ~= nil then
        self.cardwindow:DeleteMe()
        self.cardwindow = nil
        -- WindowManager.Instance:CloseWindow(self.cardwindow)
    end
end