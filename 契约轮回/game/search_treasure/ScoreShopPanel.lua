---
---Author: HongYun
---Date: 2019/9/17 19:04:21
---

ScoreShopPanel = ScoreShopPanel or class('ScoreShopPanel', BaseItem)
local ScoreShopPanel = ScoreShopPanel

function ScoreShopPanel:ctor(parent_node, layer)
    self.abName = "search_treasure"
    self.assetName = "ScoreShopPanel"
    self.layer = layer
    self.global_events = {}
    self.model = ScoreShopModel:GetInstance()
    self.stModel = SearchTreasureModel:GetInstance()
    self.mallDataList = {}  --达到兑换等级的商品数据列表

    local playerLv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    for i,v in ipairs(self.model.mallDataList) do
        if playerLv >= v.limit_level then
            table.insert(self.mallDataList, v)  --将达到兑换等级的商品加入列表
        end
    end

    self.mallItemList = {}
    
    BaseItem.Load(self)
end

function ScoreShopPanel:dctor()

    for i, v in pairs(self.mallItemList) do
        v:destroy()
    end

    self.mallItemList = {}
    if self.global_events or #self.global_events ~= 0 then
        GlobalEvent:RemoveTabListener(self.global_events)
        self.global_events = nil
    end
end


function ScoreShopPanel:LoadCallBack()
    self.nodes = {
        "img_Score",
        "txt_ScoreNum",
        "ItemContent/Viewport/SlotContent",
    }
    self:GetChildren(self.nodes)

    self.img_Score = GetImage(self.img_Score)
    self.txt_ScoreNum = GetText(self.txt_ScoreNum)
    self.SlotContent = GetRectTransform(self.SlotContent)

    self:AddEvent()
    self:UpdateScoreNum()
    self:InitMallItems()
end


function ScoreShopPanel:OnEnable()
    self:UpdateScoreNum()
    self:UpdateAllItemPriceColor()
end

function ScoreShopPanel:AddEvent()
    function call_back(id)
        --兑换成功
        self:UpdateScoreNum()
        self:UpdateAllItemPriceColor()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop, call_back)
end

--刷新积分数量
function ScoreShopPanel:UpdateScoreNum()
    local scoreNum = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.STScore)
    self.txt_ScoreNum.text = tostring(scoreNum)
    local icon = Config.db_item[self.stModel.score_key_id].icon
    GoodIconUtil.GetInstance():CreateIcon(self,self.img_Score, icon,true)
end

--初始化商品列表UI
function ScoreShopPanel:InitMallItems(  )
    for i=1,#self.mallDataList do
        local item = self:CreatMallItem(self.SlotContent,i)
        self.mallItemList[i] = item
    end

   
end

--创建商品列表项UI
function ScoreShopPanel:CreatMallItem(p_node, mall_id)
    local item = ScoreShopItem(p_node,"UI")
    item:SetData(self.mallDataList[mall_id])
    return item
end 

--刷新所有商品列表项的价格颜色
function ScoreShopPanel:UpdateAllItemPriceColor()
    for i,v in ipairs(self.mallItemList) do
        v:UpdatePriceColor()
    end
end

