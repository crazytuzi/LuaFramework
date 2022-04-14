---
--- Created by  Administrator
--- DateTime: 2020/5/18 17:00
---
FactionSerWarRewardRankItem = FactionSerWarRewardRankItem or class("FactionSerWarRewardRankItem", BaseCloneItem)
local this = FactionSerWarRewardRankItem

function FactionSerWarRewardRankItem:ctor(obj, parent_node, parent_panel)
    FactionSerWarRewardRankItem.super.Load(self)
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    self.itemicon1 = {}
    self.itemicon2 = {}
end

function FactionSerWarRewardRankItem:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}

    for i, v in pairs(self.itemicon1) do
        v:destroy()
    end
    self.itemicon1 = {}

    for i, v in pairs(self.itemicon2) do
        v:destroy()
    end
    self.itemicon2 = {}
end

function FactionSerWarRewardRankItem:LoadCallBack()
    self.nodes = {
        "rankImg","scroe","name","winIconParent","rankTextBg/rankText",
        "loseIconParent","IconParent","bg"
    }
    self:GetChildren(self.nodes)
    self.rankText = GetText(self.rankText)
    self.scroe = GetText(self.scroe)
    self.name = GetText(self.name)
    self.bgImg = GetImage(self.bg)
    self.rankImg = GetImage(self.rankImg)
    self:InitUI()
    self:AddEvent()
end

function FactionSerWarRewardRankItem:InitUI()

end

function FactionSerWarRewardRankItem:AddEvent()

end

function FactionSerWarRewardRankItem:SetData(data,type)
    self.type = type
    self.data = data
    self.name.text = self.data.name
    self.scroe.text = self.data.score
    SetVisible(self.winIconParent,self.type == 2)
    SetVisible(self.loseIconParent,self.type == 2)
    SetVisible(self.IconParent,self.type == 1)

    if self.data.rank <= 3 then
        SetVisible(self.rankImg.transform,true)
        SetVisible(self.rank,false)
        SetVisible(self.bg,true)
        SetVisible(self.titleBg,false)
        SetVisible(self.rankText,false)

        lua_resMgr:SetImageTexture(self, self.bgImg, "faction_image", "FactionSerWar_rankbg"..self.data.rank, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.rankImg, "faction_image", "faction_r_"..self.data.rank, true, nil, false)
       -- SetVisible(self.rankTextBg.transform,false)
    else
        --SetVisible(self.rankTextBg.transform,true)
        SetVisible(self.rankText,true)
        SetVisible(self.rankImg.transform,false)
        SetVisible(self.titleBg,true)
        SetVisible(self.rank,true)
        if  self.data.rank % 2 == 0 then
            lua_resMgr:SetImageTexture(self, self.bgImg, "faction_image", "FactionSerWar_rankbg4", true, nil, false)
            self.bgImg.color = Color(1,1,1,1)
        else
            self.bgImg.color = Color(1,1,1,1/255)
        end
        -- SetVisible(self.bg,self.data.rank % 2 == 0)
        --self.bgImg.color = Color(1,1,1,1/255)
        self.rankText.text = self.data.rank
    end

    self:CreateWinIcon()
    self:CreateRankIcon()
end

function FactionSerWarRewardRankItem:CreateWinIcon()
    local tab = self.model:GetRewardCfg(self.data.rank)
    local winTab = String2Table(tab.win_reward)
    local loseTab = String2Table(tab.lose_reward)
    local winScore = tab.win_score
    local loseScore = tab.lose_score
    for i = 1, #winTab + 1 do
        if i == #winTab + 1 then
            if self.itemicon[i + 1] == nil then
                self.itemicon[i+ 1] = GoodsIconSettorTwo(self.winIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = 90010036
            param["num"] = winScore
            param["bind"] = 1
            param["can_click"] = true
            self.itemicon[i + 1]:SetIcon(param)
        else
            if self.itemicon[i] == nil then
                self.itemicon[i] = GoodsIconSettorTwo(self.winIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = winTab[i][1]
            param["num"] = winTab[i][2]
            param["bind"] = winTab[i][3]
            param["can_click"] = true
            -- param["size"] = {x=70,y=70}
            --  param["size"] = {x = 72,y = 72}
            self.itemicon[i]:SetIcon(param)
        end



    end

    for i = 1, #loseTab + 1 do
        if i == #loseTab + 1 then
            if self.itemicon1[i + 1] == nil then
                self.itemicon1[i+ 1] = GoodsIconSettorTwo(self.loseIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = 90010036
            param["num"] = loseScore
            param["bind"] = 1
            param["can_click"] = true
            self.itemicon1[i + 1]:SetIcon(param)
        else
            if self.itemicon1[i] == nil then
                self.itemicon1[i] = GoodsIconSettorTwo(self.loseIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = loseTab[i][1]
            param["num"] = loseTab[i][2]
            param["bind"] = loseTab[i][3]
            param["can_click"] = true
            -- param["size"] = {x=70,y=70}
            --  param["size"] = {x = 72,y = 72}
            self.itemicon1[i]:SetIcon(param)
        end
    end
end

function FactionSerWarRewardRankItem:CreateRankIcon()
    local tab = self.model:GetRankReward(self.data.rank)
    local rewardTab = String2Table(tab.reward)
    for i = 1, #rewardTab do
        if self.itemicon2[i] == nil then
            self.itemicon2[i] = GoodsIconSettorTwo(self.IconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["bind"] = rewardTab[i][3]
        param["can_click"] = true
        -- param["size"] = {x=70,y=70}
        --  param["size"] = {x = 72,y = 72}
        self.itemicon2[i]:SetIcon(param)
    end
end


