---
--- Created by  Administrator
--- DateTime: 2019/11/21 19:35
---
CompeteRewardItem = CompeteRewardItem or class("CompeteRewardItem", BaseCloneItem)
local this = CompeteRewardItem

function CompeteRewardItem:ctor(obj, parent_node, parent_panel)
    CompeteRewardItem.super.Load(self)
    self.events = {}
    self.itemicon ={}
end

function CompeteRewardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end
end

function CompeteRewardItem:LoadCallBack()
    self.nodes = {
        "name","title","kuang","iconParent"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.title = GetImage(self.title)
    self:InitUI()
    self:AddEvent()
end

function CompeteRewardItem:InitUI()

end

function CompeteRewardItem:AddEvent()

end
--typeId 1 天榜胜利  2 地榜胜利  3小组赛  4 跨服
function CompeteRewardItem:SetData(data,index,typeId)
    self.data = data
    self.typeId = typeId
    self.index = index
    SetVisible(self.kuang,self.index == 1)
    if self.index == 1 then
        lua_resMgr:SetImageTexture(self, self.title, "compete_image", "compete_reward_bg1", true)
    elseif self.index == 2 then
        lua_resMgr:SetImageTexture(self, self.title, "compete_image", "compete_reward_bg2", true)
    else
        lua_resMgr:SetImageTexture(self, self.title, "compete_image", "compete_reward_bg3", true)
    end


    if self.typeId == 2 or self.typeId  == 3 then
        --local str = string.format("第%s名~第%s名",self.data.min_rank,self.data.max_rank)
        --if self.data.min_rank == self.data.max_rank then
        --    str = string.format("第%s名",self.data.min_rank)
        --end
        --local str = ""
        --if self.data.type == 3 then
        --    str = string.format("天榜第%s轮获胜奖励",self.data.round)
        --else
        --    str = string.format("地榜第%s轮获胜奖励",self.data.round)
        --end
        self.name.text = self.data.name
        self:CreateIcon(self.data.win)
    elseif self.typeId == 1   then
        self.name.text = self.data.name
        self:CreateIcon(self.data.reward)
    else
       -- dump(self.data)
        if self.index == 1 or self.index == 2 then
            self.name.text = self.data.desc
            local tab = String2Table(self.data.val)
            --dump(tab)
            self:CreateIcon(tab[1],true)
        elseif self.index == 3   then
            local round = self.data.round
            local str = "Knockout victory"
            self.name.text = str
            self:CreateIcon(self.data.win)
        else
            local round = self.data.round
            local str = "Knockout loss"
            self.name.text = str
            self:CreateIcon(self.data.lose)
        end

    end


end

function CompeteRewardItem:CreateIcon(reward,isTab)
    local rewardTab
    if isTab then
        rewardTab = reward
    else
        rewardTab = String2Table(reward)
    end

   -- dump(rewardTab)
    for i = 1, #rewardTab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        local item =  self.itemicon[i]
        if not item then
            item = GoodsIconSettorTwo(self.iconParent)
            self.itemicon[i] = item
        else
            item:SetVisible(true)
        end
        --if self.itemicon[i] == nil then
        --    self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        --end
        local param = {}
        param["model"] = BagModel
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["bind"] = rewardTab[i][3] or 2
        param["can_click"] = true
        param["size"] = {x = 78,y = 78}
        self.itemicon[i]:SetIcon(param)
    end
    for i = #rewardTab + 1,#self.itemicon do
        local buyItem = self.itemicon[i]
        buyItem:SetVisible(false)
    end
end