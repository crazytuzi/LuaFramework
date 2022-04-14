---
--- Created by  Administrator
--- DateTime: 2019/6/10 20:35
---
MarryPropItem = MarryPropItem or class("MarryPropItem", BaseCloneItem)
local this = MarryPropItem

function MarryPropItem:ctor(obj, parent_node, parent_panel)
    MarryPropItem.super.Load(self)
    self.model = MarryModel:GetInstance()
    self.events = {}
    self.itemicon = {}
end

function MarryPropItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function MarryPropItem:LoadCallBack()
    self.nodes = {
        "title/price/priceNum","itemScrollView/Viewport/iconParent","title/titleName","titleImg","times","title/price/priceImg",
        "MarryPropItem/nikeNameObj/nikeName1","MarryPropItem/nikeNameObj/nikeName2","select","bg"
    }
    self:GetChildren(self.nodes)
    self.titleName = GetText(self.titleName)
    self.titleImg = GetImage(self.titleImg)
    self.bg = GetImage(self.bg)
    self.times = GetText(self.times)
    self.priceNum = GetText(self.priceNum)
    self.priceImg = GetImage(self.priceImg)
    self:InitUI()
    self:AddEvent()
end

function MarryPropItem:InitUI()

end

function MarryPropItem:AddEvent()

    local function call_back()
        self.model:Brocast(MarryEvent.ClickMarryPropItem,self.data.type)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end
function MarryPropItem:SetData(data)
    self.data = data
    self:SetInfo()
    self:SetTimes()
end

function MarryPropItem:SetInfo()
    self.titleName.text = self.data.name
    --暂时写死称号
    lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, self.data.title, true, nil, false)
    self:CreateIcon()
    self:SetBg()
    self:SetPrice()
end

function MarryPropItem:SetPrice()
    local priTab = String2Table(self.data.cost)
  --  dump(priTab)
    local money = priTab[1][1]
    local num = priTab[1][2]
    self.priceNum.text = num
   -- self.priceImg
    GoodIconUtil:CreateIcon(self, self.priceImg, money, true)
end

function MarryPropItem:SetBg()
    lua_resMgr:SetImageTexture(self, self.bg, "marry_image", "marry_wed"..self.data.type, false, nil, false)
end

function MarryPropItem:CreateIcon()
    local  tab = String2Table(self.data.reward)
    for i = 1, #tab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        else
            return
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["can_click"] = true
        --  param["size"] = {x = 72,y = 72}
        self.itemicon[i]:SetIcon(param)
    end
end

function MarryPropItem:SetTimes(times)
    --self.times.text = "婚礼次数："..times
    self.times.text = "Married:"..self.data.wcount
end

function MarryPropItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end