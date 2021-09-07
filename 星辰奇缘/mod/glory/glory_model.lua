GloryModel = GloryModel or BaseClass(BaseModel)

function GloryModel:__init()
    self.gloryWin = nil
    self.level_id = 0
    self.tabList = {
        [1] = { name = TI18N("基础信息") },
        [2] = { name = TI18N("试炼排行") },
        [3] = { name = TI18N("最近挑战") },
    }

    self.currentData = { }
    self.videoData = { }

    self.levelDataList = { }
    self.title_id = 0

    self.buffTab = { }

    self:ReHandle()
end

function GloryModel:__delete()
    if self.gloryWin ~= nil then
        self.gloryWin:DeleteMe()
        self.gloryWin = nil
    end
end

function GloryModel:ReHandle()
    for i, v in ipairs(DataGlory.data_loss_buff) do
        self.buffTab[v.lost] = self.buffTab[v.lost] or { }
        table.insert(self.buffTab[v.lost], v)
    end
    for _, v in pairs(self.buffTab) do
        table.sort(v, function(a, b) return a.min < b.min end)
    end
end

function GloryModel:OpenWindow()
    if self.gloryWin == nil then
        self.gloryWin = GloryWindow.New(self)
    end
    self.gloryWin:Open()
end

function GloryModel:OpenConfirm(args)
    if self.gloryConfirm == nil then
        self.gloryConfirm = GloryConfirmWindow.New(self)
        self.gloryConfirm:Open(args)
    end
end

function GloryModel:CloseWindow()
    if self.gloryWin ~= nil then
        self:CloseBeforePanel()
        WindowManager.Instance:CloseWindow(self.gloryWin)
    end
end

function GloryModel:SetMyData(data)
    self.level_id = data.id
    self.end_time = data.end_time
    self.skillList = data.skill
    self.title_id = data.title_id
    self.attrList = data.attr

    -- if self.gloryWin ~= nil then
    --     self.gloryWin:ReloadLevelList()
    -- end
end

function GloryModel:newGlory()
    if self.level_id ~= nil and self.level_id < DataGlory.data_level_length and self.title_id ~= nil then
        local level = DataGlory.data_level[self.level_id + 1]
        if level.title_id > self.title_id and level.need_lev <= RoleManager.Instance.RoleData.lev then
            return true
        else
            return false
        end
    else
        return false
    end
end

function GloryModel:newLevel()
    if self.level_id ~= nil and self.level_id < DataGlory.data_level_length then
        local level = DataGlory.data_level[self.level_id + 1]

        return level.need_lev <= RoleManager.Instance.RoleData.lev
    else
        return false
    end
end

function GloryModel:OpenVideo(args)
    if self.videoWin == nil then
        self.videoWin = GloryVideo.New(self)
    end
    self.videoWin:Open(args)
end

function GloryModel:SetRankById(data)
    if self.levelDataList[data.id] == nil then
        self.levelDataList[data.id] = { }
    end

    -- BaseUtils.dump(data, "14405回调")

    self.levelDataList[data.id].rid = data.rid
    self.levelDataList[data.id].r_platform = data.r_platform
    self.levelDataList[data.id].r_zone_id = data.r_zone_id

    self.levelDataList[data.id].first_name = data.first_name
    self.levelDataList[data.id].first_level = data.first_level

    self.levelDataList[data.id].best_rank = data.best_rank
    if data.best_rank ~= nil then
        for k, v in pairs(self.levelDataList[data.id].best_rank) do
            if v ~= nil then
                v.lev_id = data.id
            end
        end
    end

    self.levelDataList[data.id].recent = data.recent
    if data.recent ~= nil then
        for k, v in pairs(self.levelDataList[data.id].recent) do
            if v ~= nil then
                v.lev_id = data.id
            end
        end
    end

    -- if self.gloryWin ~= nil then
    --     -- self.gloryWin:UpdateInfo(DataGlory.data_level[data.id])
    --     self.gloryWin:SelectItem(self.gloryWin.lastIndex)
    -- end
end

function GloryModel:ShowFightPanel()
    if self.fightPanel == nil then
        self.fightPanel = GloryFightPanel.New(self)
    end
    self.fightPanel:Show()
end

function GloryModel:GetMyCurID()
    return math.min(self.currentData.new_id + 1, DataGlory.data_level_length)
end

function GloryModel:OpenBeforePanel()
    if self.beforePanel == nil then
        self.beforePanel = GloryBeforeFightPanel.New(self)
    end
    self.beforePanel:Show()
end

function GloryModel:CloseBeforePanel()
    if self.beforePanel ~= nil then
        self.beforePanel:DeleteMe();
        self.beforePanel = nil;
    end
end

function GloryModel:OpenNewRecored(args)
     if self.newrecordWin == nil then
        self.newrecordWin = GloryNewRecordWindow.New(self)
    end
    self.newrecordWin:Open(args)
end

function GloryModel:OpenReward(args)
    if self.rewardWin == nil then
        self.rewardWin = GloryRewardWindow.New(self)
    end
    self.rewardWin:Open(args)
end
