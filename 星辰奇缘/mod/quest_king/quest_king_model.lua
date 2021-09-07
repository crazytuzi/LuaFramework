-- @author 黄耀聪
-- @date 2017年6月12日, 星期一

QuestKingModel = QuestKingModel or BaseClass(BaseModel)

function QuestKingModel:__init()
    self.stageTimesCostTab = {}
    self:Prehandling()
end

function QuestKingModel:__delete()
end

function QuestKingModel:OpenWindow(args)
    if self.mainWin == nil then
    end
    self.mainWin:Open(args)
end

function QuestKingModel:CloseWindow()
end

function QuestKingModel:OpenScrollMark(args)
    if self.scrollMark == nil then
        self.scrollMark = QuestKingScrollMarked.New(self)
    end
    self.scrollMark:Open(args)
end

function QuestKingModel:OpenProgress(args)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart] ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.QuestKing] ~= nil then
        self.campId = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WarmHeart][CampaignEumn.WarmHeart.QuestKing].sub[1].id
    end

    if self.progressWin == nil then
        self.progressWin = QuestKingProgress.New(self)
    end
    self.progressWin:Open(args)
end

function QuestKingModel:Prehandling()
    for _,v in ipairs(DataQuestKing.data_refresh_cost) do
        self.stageTimesCostTab[v.stage] = self.stageTimesCostTab[v.stage] or {}
        table.insert(self.stageTimesCostTab[v.stage], v)
    end
    for stage,tab in pairs(self.stageTimesCostTab) do
        table.sort(tab, function(a,b) return a.min_times < b.min_times end)
    end
end


