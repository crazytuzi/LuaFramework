local COrgWarCtrl = class("COrgWarCtrl", CCtrlBase)

function COrgWarCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:ResetCtrl()
end

function COrgWarCtrl.ResetCtrl(self)
    self.m_WarStatus = define.Org.WarStatus.None
    self.m_WarInfo = {}
    self.m_StartTime = 0
    self.m_EndTime = 0
    self.m_CurrentTime = 0
    self.m_MyOrgInfo = nil
    self.m_EnemyInfo = nil
    self.m_ReviveTime = 0
    self.m_Scene = define.Org.OrgWarScene.None
    self.m_OrderStatus = define.Org.OrderType.Cancel
end

function COrgWarCtrl.IsPreParing(self)
    return self.m_WarStatus == define.Org.WarStatus.PreParing
end

function COrgWarCtrl.IsFighting(self)
    return self.m_WarStatus == define.Org.WarStatus.IsFighting
end

function COrgWarCtrl.IsInWar(self)
    return self.m_WarStatus ~= define.Org.WarStatus.None
end

function COrgWarCtrl.OnReceiveFightList(self, oInfoList)
    COrgFightListView:ShowView(function (oView)
        oView:SetData(oInfoList)
    end)
end

function COrgWarCtrl.OnUpdateBlood(self, oMyInfo, oEnemyInfo)
    self.m_MyOrgInfo = oMyInfo
    self.m_EnemyInfo = oEnemyInfo
    self:OnEvent(define.Org.Event.OnUpdateBlood)
end

function COrgWarCtrl.GetMyOrgInfo(self)
    return self.m_MyOrgInfo
end

function COrgWarCtrl.GetEnemyInfo(self)
    return self.m_EnemyInfo
end

function COrgWarCtrl.IsInOrgWarScene(self)
    return self.m_Scene ~= define.Org.OrgWarScene.None
end

function COrgWarCtrl.GetCurrentScene(self)
    return self.m_Scene
end

function COrgWarCtrl.EnterScene(self, iScene)
    self.m_OrderStatus = define.Org.OrderType.Cancel
    self.m_Scene = iScene
    self:CheckView()
    self:OnEvent(define.Org.Event.EnterOrgWarScene, iScene)
end

function COrgWarCtrl.CheckView(self)
    if self.m_Scene == define.Org.OrgWarScene.War and self.m_OrderStatus ~= define.Org.OrderType.Cancel and COrgWarView:GetView() == nil and not g_WarCtrl:IsWar() then
        COrgWarView:ShowView()
    end
end

function COrgWarCtrl.LeaveScene(self, iScene)
    self.m_OrderStatus = define.Org.OrderType.Cancel
    self.m_Scene = define.Org.OrgWarScene.None
    local oView = CDialogueMainView:GetView()
    if oView then
        oView:CloseView()
    end
    oView = COrgWarView:GetView()
    if oView then
        oView:CloseView()
    end
    self:OnEvent(define.Org.Event.LeaveOrgWarScene)
end

function COrgWarCtrl.UpdateTime(self, iStartTime, iEndTime)
    self.m_StartTime = iStartTime
    self.m_EndTime = iEndTime
    self.m_CurrentTime = g_TimeCtrl:GetTimeS()
    if self.m_Timer == nil then
        Utils.AddTimer(callback(self, "OnUpdateTime"), 1, 0)
    end
end

function COrgWarCtrl.GetPrepareTime(self)
    return self.m_StartTime - self.m_CurrentTime
end

function COrgWarCtrl.GetRestTime(self)
    return self.m_EndTime - self.m_CurrentTime
end

function COrgWarCtrl.OnUpdateTime(self)
    self.m_CurrentTime = self.m_CurrentTime + 1
    if self.m_CurrentTime < self.m_StartTime then
        self.m_WarStatus = define.Org.WarStatus.PreParing
    elseif self.m_CurrentTime < self.m_EndTime then
        self.m_WarStatus = define.Org.WarStatus.IsFighting
    else
        self.m_WarStatus = define.Org.WarStatus.None
        self:OnEvent(define.Org.Event.UpdateOrgWarTime, self.m_CurrentTime)
        return false
    end
    self:OnEvent(define.Org.Event.UpdateOrgWarTime, self.m_CurrentTime)
    return true
end

function COrgWarCtrl.DelTimer(self)
    if self.m_Timer then
        Utils.DelTimer(self.m_Timer)
        self.m_Timer = nil
    end
end

function COrgWarCtrl.UpdateStatus(self, iStatus)
    self.m_OrderStatus = iStatus
    self:CheckView()
    self:OnEvent(define.Org.Event.UpdateOrderStatus)
end

function COrgWarCtrl.CheckMove(self)
    if self.m_Scene == define.Org.OrgWarScene.War and g_TeamCtrl:IsLeader() and (self.m_OrderStatus == define.Org.OrderType.Attack or self.m_OrderStatus == define.Org.OrderType.Defense) then
        local msgStr = nil
        local tipsStr = nil
        local okStr = nil
        if self.m_OrderStatus == define.Org.OrderType.Attack then
            msgStr = "目前正在进攻敌方守护水晶无法走动，是否取消？"
            tipsStr = "继续进攻"
            okStr = "取消进攻"
        end
        if self.m_OrderStatus == define.Org.OrderType.Defense then
            msgStr = "目前正在防守我方守护水晶无法走动，是否取消？"
            tipsStr = "继续防守"
            okStr = "取消防守"
        end
        local t = {
            msg = msgStr,
            okStr = okStr,
            cancelStr = tipsStr,
            okCallback = callback(self, "CancelState"),
        }
        g_WindowTipCtrl:SetWindowConfirm(t)
        return true
    end
    return false
end

function COrgWarCtrl.CancelState(self)
    nethuodong.C2GSOrgWarCanCelState(self.m_OrderStatus)
end

function COrgWarCtrl.ShowWarResult(self, oCmd)
    CWarResultView:ShowView(function(oView)
        oView:SetWarID(oCmd.war_id)
        oView:SetWin(oCmd.win)
        oView:SetDelayCloseView()
    end)
end

function COrgWarCtrl.WalkToOrgWar(self)
    if g_WarCtrl:IsWar() then
        g_NotifyCtrl:FloatMsg("战斗中无法使用该功能")
        return
    end
    if g_ActivityCtrl:ActivityBlockContrl("orgwar") then 
        if g_OrgWarCtrl:IsInWar() then
            if g_OrgWarCtrl:IsInOrgWarScene() then
                g_NotifyCtrl:FloatMsg("您已在公会战场景中")
            else
                g_OrgCtrl:CloseAllOrgView()
                nethuodong.C2GSOrgWarGuide()
            end
        else
            g_NotifyCtrl:FloatMsg("公会战活动时间为每周日19:45~21:00")
        end
    end
end

function COrgWarCtrl.Test(self)
    g_OrgWarCtrl:UpdateTime(g_TimeCtrl:GetTimeS()+3, g_TimeCtrl:GetTimeS()+20000)
    g_OrgWarCtrl:EnterScene(define.Org.OrgWarScene.War)
    g_OrgWarCtrl:OnUpdateBlood({hp = 15, defend = 1},{hp = 52, defend = 2})
end

function COrgWarCtrl.OnGetOrgWarRank(self, oInfoList)
    
    self:OnEvent(define.Org.Event.UpdateOrgWarRank)
end

function COrgWarCtrl.UpdateReviveTime(self, endTime)
    self.m_ReviveTime = endTime
    self:OnEvent(define.Org.Event.UpdateReviveTime)
end

function COrgWarCtrl.GetReviveTime(self)
    local iTime = self.m_ReviveTime - g_TimeCtrl:GetTimeS()
    if iTime < 0 then
        return 0
    end
    return iTime
end

return COrgWarCtrl