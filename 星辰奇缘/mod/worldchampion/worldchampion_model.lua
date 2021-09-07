-- @author huangzefeng
-- @date 2016年6月21日,星期二

WorldChampionModel = WorldChampionModel or BaseClass(BaseModel)

function WorldChampionModel:__init(mgr)
    self.mgr = mgr
    self.chatExtPanel = nil

    self.mainPanel2V2 = nil

end

function WorldChampionModel:__delete()
end

function WorldChampionModel:OpenMainWindow(args)
    if self.mainwindow == nil then
        self.mainwindow = WorldChampionMainWindow.New(self)
    end
    self.mainwindow:Open(args)
end

function WorldChampionModel:CloseMainWindow()
    if self.mainwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mainwindow)
    end
end

function WorldChampionModel:OpenShareWindow(args)
    if self.sharewindow == nil then
        self.sharewindow = WorldChampionShareWindow.New(self)
    end
    local openArgs = args
    if openArgs == nil then
        openArgs = {[2] = RoleManager.Instance.RoleData.id, [3] = RoleManager.Instance.RoleData.platform, [4] = RoleManager.Instance.RoleData.zone_id}
    end
    self.sharewindow:Open(openArgs)
end

function WorldChampionModel:CloseShareWindow()
    if self.sharewindow ~= nil then
        WindowManager.Instance:CloseWindow(self.sharewindow)
    end
end

function WorldChampionModel:UpdateShareWin(data)
    if self.sharewindow ~= nil then
        self.sharewindow:UpdateInfo(data)
    end
end

function WorldChampionModel:OpenFightHonorWindow(args)
    if self.fightHonorwindow == nil then
        self.fightHonorwindow = WorldChampionFightHonorWindow.New(self)
    end
    self.fightHonorwindow:Open(args)
end

function WorldChampionModel:CloseFightHonorWindow()
    if self.fightHonorwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.fightHonorwindow)
    end
end

function WorldChampionModel:UpdateFightScore(data)
    if self.fightHonorwindow ~= nil then
        self.fightHonorwindow:UpdateFightScorePanel(data)
    end
end

function WorldChampionModel:OpenMainPanel(args)
    if self.mainPanel == nil then
        self.mainPanel = WorldChampionMainPanel.New(self)
    end
    self.mainPanel:Show(args)
end

function WorldChampionModel:CloseMainPanel()
    if MainUIManager.Instance.MainUIIconView ~= nil and self.mainPanel ~= nil then
        -- MainUIManager.Instance.MainUIIconView:showbaseicon3()
        MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        MainUIManager.Instance.MainUIIconView:ShowCanvas(true)
        MainUIManager.Instance.mainuitracepanel:TweenShow()
    end
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
end

function WorldChampionModel:OpenMainPanel2V2(args)
    if self.mainPanel2V2 == nil then
        self.mainPanel2V2 = WorldChampionMainPanel2V2.New(self)
    end
    self.mainPanel2V2:Show(args)
end

function WorldChampionModel:CloseMainPanel2V2()
    if MainUIManager.Instance.MainUIIconView ~= nil and self.mainPanel2V2 ~= nil then
        -- MainUIManager.Instance.MainUIIconView:showbaseicon3()
        MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        MainUIManager.Instance.MainUIIconView:ShowCanvas(true)
        MainUIManager.Instance.mainuitracepanel:TweenShow()
    end
    if self.mainPanel2V2 ~= nil then
        self.mainPanel2V2:DeleteMe()
        self.mainPanel2V2 = nil
    end
end

function WorldChampionModel:SetLevInfo(data)
    if self.pk_type == 1 then
        if self.mainPanel ~= nil then
            self.mainPanel:SetLevInfo(data)
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 ~= nil then
            self.mainPanel2V2:SetLevInfo(data)
        end
    end
end

function WorldChampionModel:SetBadgeInfo(data)
    if self.mainPanel ~= nil then
        self.mainPanel:SetBadgeInfo(data)
    end
    if self.mainPanel2V2 ~= nil then
        self.mainPanel2V2:SetBadgeInfo(data)
    end
end


function WorldChampionModel:doMatchResult(result)
    if self.pk_type == 1 then
        if self.mainPanel == nil then
            self:OpenMainPanel()
            LuaTimer.Add(1000, function()
                if result then
                    self.mainPanel:MatchSuccess()
                else
                    self.mainPanel:CancleMatchSuccess()
                end
            end)
        else
            if result then
                self.mainPanel:MatchSuccess()
            else
                self.mainPanel:CancleMatchSuccess()
            end
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 == nil then
            self:OpenMainPanel2V2()
            LuaTimer.Add(1000, function()
                if result then
                    self.mainPanel2V2:MatchSuccess()
                else
                    self.mainPanel2V2:CancleMatchSuccess()
                end
            end)
        else
            if result then
                self.mainPanel2V2:MatchSuccess()
            else
                self.mainPanel2V2:CancleMatchSuccess()
            end
        end
    end
end

--显示匹配结果
function WorldChampionModel:GetMatchResult(data)
    if self.pk_type == 1 then
        if self.mainPanel ~= nil then
            self.mainPanel:ShowMainCon()
            self.mainPanel:MatchResult(data)
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 ~= nil then
            self.mainPanel2V2:ShowMainCon()
            self.mainPanel2V2:MatchResult(data)
        end
    end
end

function WorldChampionModel:OnEndFight()
    if self.pk_type == 1 then
        if self.mainPanel ~= nil then
            self.mainPanel:OnUpdate()
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 ~= nil then
            self.mainPanel2V2:OnUpdate()
        end
    end
end

function WorldChampionModel:OnMatchingStatus()
    if self.pk_type == 1 then
        if self.mainPanel ~= nil then
            self.mainPanel:ChangeMatchStatus()
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 ~= nil then
            self.mainPanel2V2:ChangeMatchStatus()
        end
    end
end

function WorldChampionModel:ShowMemberMsg(id, platform, zone_id, msg, BubbleID)
    if self.pk_type == 1 then
        if self.mainPanel ~= nil then
            self.mainPanel:ShowMsg(id, platform, zone_id, msg, BubbleID)
        end
    elseif self.pk_type == 2 then
        if self.mainPanel2V2 ~= nil then
            self.mainPanel2V2:ShowMsg(id, platform, zone_id, msg, BubbleID)
        end
    end
end

function WorldChampionModel:GetCircleTipsList(tipType)
    local list = {}
    for i=1, #DataTournament.data_tips_list do
        local cfg_data = DataTournament.data_tips_list[i]
        if cfg_data.tips_time == 0 or cfg_data.tips_time == tipType then
            table.insert(list, cfg_data)
        end
    end
    return list
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
function WorldChampionModel:OpenSuccessWindow(args)
    if self.successwin == nil then
        self.successwin = WorldChampionSuccessWindow.New(self)
    end
    self.successwin:Open(args)
end

function WorldChampionModel:CloseSuccessWindow()
    if self.successwin ~= nil then
        WindowManager.Instance:CloseWindow(self.successwin)
    end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
function WorldChampionModel:OpenLvupWindow(args)
    if self.lvupwin == nil then
        self.lvupwin = WorldChampionLvupWindow.New(self)
    end
    self.lvupwin:Open(args)
end

function WorldChampionModel:CloseLvupWindow()
    if self.lvupwin ~= nil then
        WindowManager.Instance:CloseWindow(self.lvupwin)
    end
end

function WorldChampionModel:OpenLvlUpWindow(args)
    if self.lvlupwin == nil then
        self.lvlupwin = WorldChampionLvlupWindow.New(self)
    end
    self.lvlupwin:Open(args)
end

function WorldChampionModel:CloseLvlUpWindow()
    if self.lvlupwin ~= nil then
        WindowManager.Instance:CloseWindow(self.lvlupwin)
    end
end


function WorldChampionModel:ShowLevUpBox()
    if self.lvupwin ~= nil then
        self.lvupwin:ShowBox()
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
function WorldChampionModel:OpenQuarterPanel(args)
    if self.quarterPanel == nil then
        self.quarterPanel = WorldChampionQuarterPanel.New(self)
    end
    self.quarterPanel:Show(args)
end

function WorldChampionModel:CloseQuarterPanel()
    if self.quarterPanel ~= nil then
        self.quarterPanel:DeleteMe()
        self.quarterPanel = nil
    end
end

function WorldChampionModel:OpenQuarterPanelBox()
    if self.quarterPanel ~= nil then
        self.quarterPanel:ShowBox()
    end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- function WorldChampionModel:OpenQuarterBoxPanel(args)
--     if self.quarterboxPanel == nil then
--         self.quarterboxPanel = WorldChampionQuarterBoxPanel.New(self)
--     end
--     self.quarterboxPanel:Show(args)
-- end

-- function WorldChampionModel:CloseQuarterBoxPanel()
--     if self.quarterboxPanel ~= nil then
--         self.quarterboxPanel:DeleteMe()
--         self.quarterboxPanel = nil
--     end
-- end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function WorldChampionModel:ShowRankPanel(bo)
    if bo == true then
        if self.srp == nil then
            self.srp = NoOneInWorldRankPanel.New(self)
        end
        -- print("GuildfightEliteModel:ShowEliteLookWindow(bo)"..debug.traceback())
        self.srp:Show()
    else
        if self.srp ~= nil then
            self.srp:Hiden()
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
function WorldChampionModel:OpenCountInfoWindow(args)
    if self.countwin == nil then
        self.countwin = WorldChampionCountInfo.New(self)
    end
    self.countwin:Show(args)
end

function WorldChampionModel:CloseCountInfowindow()
    if self.countwin ~= nil then
        self.countwin:DeleteMe()
        self.countwin = nil
        -- WindowManager.Instance:CloseWindow(self.countwin)
    end
end

function WorldChampionModel:GoodSucc(rid, platform, zone_id)
    if self.countwin ~= nil then
        self.countwin:GoodSuccess(rid, platform, zone_id)
    end
end

--分享战绩到聊天
function WorldChampionModel:OnShareFightScore()
    -- local name = TI18N("[武道战绩]")
    -- local str = name
    -- local element = {}
    -- element.type = MsgEumn.CacheType.WorldChampion
    -- element.showString = name
    -- element.sendString = string.format("{honor_3,%s,%s}", RoleManager.Instance.RoleData.name, ChatManager.Instance:CurrentChannel())
    -- element.matchString = ""
    -- ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat)
    WindowManager.Instance:CloseCurrentWindow()
    ChatManager.Instance.model:ShowChatWindow()

    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Chat,{showWorldChampionGuide = true}, 10)
    end
    self.chatExtPanel:Show({otherOption = {showWorldChampionGuide = true}, tab = 10})
end

--分享诸神荣誉到聊天
function WorldChampionModel:OnShareGodsWar()
    -- local name = TI18N("[武道战绩]")
    -- local str = name
    -- local element = {}
    -- element.type = MsgEumn.CacheType.WorldChampion
    -- element.showString = name
    -- element.sendString = string.format("{honor_3,%s,%s}", RoleManager.Instance.RoleData.name, ChatManager.Instance:CurrentChannel())
    -- element.matchString = ""
    -- ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat)
    WindowManager.Instance:CloseCurrentWindow()
    ChatManager.Instance.model:ShowChatWindow()

    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Chat,{showWorldGodsWarGuide = true}, 10)
    end
    self.chatExtPanel:Show({otherOption = {showWorldGodsWarGuide = true}, tab = 10})
end

--检查武道战绩分享是否显示
function WorldChampionModel:CheckShowLev()
    if RoleManager.Instance.RoleData.lev >= 70 then
        return true
    else
        return false
    end
end

function WorldChampionModel:OpenBadgeRewardWindow(args)
    if self.badgeReward_win == nil then
        self.badgeReward_win = BadgeRewardWindow.New(self)
    end
    self.badgeReward_win:Open(args)
end

function WorldChampionModel:CloseBadgeRewardWindow()
    if self.badgeReward_win ~= nil then
        WindowManager.Instance:CloseWindow(self.badgeReward_win)
    end
end


function WorldChampionModel:OpenBadgeWindow(args)
    if self.badge_win == nil then
        self.badge_win = WorldChampionBadgeWindow.New(self)
    end
    self.badge_win:Open(args)
end

function WorldChampionModel:CloseBadgeWindow()
    if self.badge_win ~= nil then
        WindowManager.Instance:CloseWindow(self.badge_win)
    end
end

function WorldChampionModel:GetBadgeData(data)
    self.badgeData = {}
    self.combinationData = {}
    for k,v in pairs(data.badgelist) do
        table.insert(self.badgeData,v.badge_id)
    end
    for k,v in pairs(data.setlist) do
        table.insert(self.combinationData,v.set_id)
    end
    self:UnlockCombination()
end

function WorldChampionModel:UnlockCombination()
    self.unlockCombination = {}
    for k,v in pairs(DataTournament.data_get_badge_group) do
        if table.containValue(self.badgeData, v.group_list[1]) or table.containValue(self.badgeData, v.group_list[2]) then
            table.insert(self.unlockCombination,v.set_id)
        end
    end
    -- BaseUtils.dump(self.unlockCombination,"已解锁徽章组合")
end

function WorldChampionModel:OpenBadgeShowWindow(args)
    if self.badge_show_win == nil then
        self.badge_show_win = WorldChampionBadgeShowWindow.New(self)
    end
    self.badge_show_win:Open(args)
end

function WorldChampionModel:CloseBadgeShowWindow()
    if self.badge_show_win ~= nil then
        WindowManager.Instance:CloseWindow(self.badge_show_win)
    end
end


function WorldChampionModel:OnShareBadge()

    WindowManager.Instance:CloseCurrentWindow()
    ChatManager.Instance.model:ShowChatWindow()
    self:CloseMainWindow()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Chat,{showWorldChampionBadge = true}, 10)
    end
    self.chatExtPanel:Show({otherOption = {showWorldChampionBadge = true}, tab = 10})
end

function WorldChampionModel:CheckShowBadge()
    if  #self.badgeData > 0  then
        return true
    else
        return false
    end
end

function WorldChampionModel:OpenBadgeLookWindow(args)
    if self.badge_look_win == nil then
        self.badge_look_win = WorldChampionBadgeLookWindow.New(self)
    end
    self.badge_look_win:Open(args)
end

function WorldChampionModel:CloseBadgeLookWindow()
    if self.badge_look_win ~= nil then
        WindowManager.Instance:CloseWindow(self.badge_look_win)
    end
end