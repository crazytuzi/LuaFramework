-- @Author: lwj
-- @Date:   2018-10-22 21:23:49
-- @Last Modified time: 2018-10-25 11:43:54
SkillRecommendPanel = SkillRecommendPanel or class("SkillRecommendPanel", WindowPanel)
local SkillRecommendPanel = SkillRecommendPanel

function SkillRecommendPanel:ctor()
    self.abName = "skill"
    self.assetName = "SkillRecommendPanel"
    self.layer = "UI"

    self.panel_type = 3
    self.itemList = {}
    self.model = SkillUIModel.GetInstance()

    self.use_background = true
    self.click_bg_close = true
    -- SkillRecommendPanel.super.Load(self)
end

function SkillRecommendPanel:dctor()

    if self.globalEvents then
        for i, v in pairs(self.globalEvents) do
            GlobalEvent:RemoveListener(v)
        end
        self.globalEvents = {}
    end

    
    if self.recomItemList then
        for i, v in ipairs(self.recomItemList) do
            if v then
                v:destroy()
            end
        end
    end

    
end

function SkillRecommendPanel:Open()
    WindowPanel.Open(self)
end

function SkillRecommendPanel:LoadCallBack()
    self.nodes = {
        "ItemContainer",
        "windowCloseBtn",
    }
    self:GetChildren(self.nodes)
    self:SetTileTextImage("skill_image", "Recommend_Title")
    self:SetPanelSize(880, 530)

    self:AddEvent()
    self:LoadRecomItem()
end

function SkillRecommendPanel:AddEvent()
    self.globalEvents = self.globalEvents or {}
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(SkillUIEvent.SetRecommendInfo, handler(self, self.Close))
end

function SkillRecommendPanel:OpenCallBack()
end

function SkillRecommendPanel:CloseCallBack()
end

function SkillRecommendPanel:LoadRecomItem()
    self.recomItemList = self.recomItemList or {}
    local gender = RoleInfoModel.GetInstance():GetSex()
    for i = 1, 2 do
        local cfg = Config.db_skill_recommend[i + 1]
        local recommenItem = RecomItem(self.ItemContainer, self.layer)
        local data = {}
        data.id = cfg.id
        data.recommend = String2Table(cfg.recommend)[gender]
        recommenItem:SetData(data)
        table.insert(self.recomItemList, recommenItem)
    end
end

