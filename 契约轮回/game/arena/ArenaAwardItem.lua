---
--- Created by  Administrator
--- DateTime: 2019/5/10 16:04
---
ArenaAwardItem = ArenaAwardItem or class("ArenaAwardItem", BaseCloneItem)
local this = ArenaAwardItem

function ArenaAwardItem:ctor(obj, parent_node, parent_panel)
    ArenaAwardItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
    self.isCanReward = false
    self.model = ArenaModel:GetInstance()
end

function ArenaAwardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function ArenaAwardItem:LoadCallBack()
    self.nodes = {
        "rankBg","rank","iconParent","ylqImg","btn/lqBtn","btn",
    }
    self:GetChildren(self.nodes)
    self.rank = GetText(self.rank)
    self.rankBg = GetImage(self.rankBg)
    self.lqBtnImg = GetImage(self.lqBtn)
    self:InitUI()
    self:AddEvent()
end

function ArenaAwardItem:InitUI()

end

function ArenaAwardItem:AddEvent()

    local function call_back()
        ArenaController:GetInstance():RequstHighestRankFetch(self.data.id)
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)
end

function ArenaAwardItem:SetData(data,type,index)
    self.data = data
    self.type = type
    self.index = index
    self:SetInfo()
end

function ArenaAwardItem:SetInfo()
    if self.type == 1 then  --突破
       -- self.rank.text = self.data.rank
        if self.data.min == self.data.max then
            self.rank.text = self.data.min
        else
            self.rank.text = self.data.min.."f"..self.data.max
        end

        SetVisible(self.btn,true)
        SetVisible(self.ylqImg,true)
      --  self.model.highestRank
        self:SetBtnState()


    elseif self.type == 2 then --日常
        if self.data.min == self.data.max then
            self.rank.text = self.data.min
        else
            self.rank.text = self.data.min.."f"..self.data.max
        end
        SetVisible(self.btn,false)
        SetVisible(self.ylqImg,false)
    else --大神
        SetVisible(self.btn,false)
        SetVisible(self.ylqImg,false)
        if self.data.min == self.data.max then
            self.rank.text = self.data.min
        else
            self.rank.text = self.data.min.."f"..self.data.max
        end
    end

    if self.index == 1 then
        lua_resMgr:SetImageTexture(self, self.rankBg, "arena_image", "arene_di2", true, nil, false)
    elseif self.index == 2 then
        lua_resMgr:SetImageTexture(self, self.rankBg, "arena_image", "arene_di3", true, nil, false)
    end
    self:CreateIcon()
end

function ArenaAwardItem:CreateIcon()
    local rewardTab = String2Table(self.data.reward)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if rewardTab then
        for i = 1, #rewardTab do
            --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
            if self.itemicon[i] == nil then
                self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = rewardTab[i][1]
            param["num"] = rewardTab[i][2]
            param["can_click"] = true
           -- param["size"] = {x=70,y=70}
            --  param["size"] = {x = 72,y = 72}
            self.itemicon[i]:SetIcon(param)
        end
    end
end

function ArenaAwardItem:SetBtnState()
    --if self.model.highestRank == 0 then  --未上榜
        --SetVisible(self.ylqImg,false)
        --SetVisible(self.btn,true)
        --ShaderManager:GetInstance():SetImageGray(self.lqBtnImg)
    --else
        --if self.model:isHighestById(self.data.id) then
            --SetVisible(self.btn,false)
            --SetVisible(self.ylqImg,true)
            --return
        --end
        --SetVisible(self.ylqImg,false)
        --if self.model.highestRank <= self.data.max then  --历史最高排名
            --ShaderManager:GetInstance():SetImageNormal(self.lqBtnImg)
        --else
            --ShaderManager:GetInstance():SetImageGray(self.lqBtnImg)
        --end
    --end
	local isReward = self.model:GetRewardState(self.data)
	if isReward == 0 then --已经领取
		SetVisible(self.btn,false)
		SetVisible(self.ylqImg,true)
	elseif isReward == 1 then --不能领取
		SetVisible(self.ylqImg,false)
		SetVisible(self.btn,true)
		ShaderManager:GetInstance():SetImageGray(self.lqBtnImg)
	else --可领取
		SetVisible(self.btn,true)
		SetVisible(self.ylqImg,false)
		ShaderManager:GetInstance():SetImageNormal(self.lqBtnImg)
	end
end




function ArenaAwardItem:SetLqState()
    SetVisible(self.btn,false)
    SetVisible(self.ylqImg,true)
end
