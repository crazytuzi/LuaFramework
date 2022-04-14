---
--- Created by  Administrator
--- DateTime: 2019/7/15 10:26
---
WeddingShopPanel = WeddingShopPanel or class("WeddingShopPanel", BasePanel)
local this = WeddingShopPanel

function WeddingShopPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "WeddingShopPanel"
    self.layer = LayerManager.LayerNameList.UI
    self.use_background = true
    self.change_scene_close = true
    self.events = {}
    self.gevents = {}
    self.items = {}
    self.model = MarryModel:GetInstance()
end

function WeddingShopPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    if self.itemicon then
        self.itemicon:destroy()
    end
end

function WeddingShopPanel:Open(id)
    self.itemId = id
    WeddingShopPanel.super.Open(self)
end

function WeddingShopPanel:LoadCallBack()
    self.nodes = {
        "WeddingShopItem","leftScrollView/Viewport/leftContent",
        "closeBtn","rechargeBtn",
        "RightContainer/sum_Price/sumprice","RightContainer/sum_Price/sumIcon","RightContainer/have_diamond/HDiamond",
        "RightContainer/have_diamond/haveIcon","RightContainer/have_diamond/getDiamond_btn",
        "RightContainer/Count_Group/num","RightContainer/Count_Group/minus_btn/minus_Grey",
        "RightContainer/Count_Group/minus_btn","RightContainer/Count_Group/plus_btn",
        "RightContainer/Count_Group/keypad","RightContainer/Count_Group/keypad_btn",
        "RightContainer/desTitlePos/itemName","RightContainer/desTitlePos/level",
        "RightContainer/desTitlePos/icon","RightContainer/desTitlePos/des","RightContainer/buy_btn",
    }
    self:GetChildren(self.nodes)
    self.itemName = GetText(self.itemName)
    self.level = GetText(self.level)
    self.des = GetText(self.des)
    self.input = GetText(self.num)
    self.sumprice = GetText(self.sumprice)
    self.HDiamond = GetText(self.HDiamond)
    self.haveIcon = GetImage(self.haveIcon)

    self.num_plus_Img = GetImage(self.plus_btn)
    self.num_reduce_img = GetImage(self.minus_btn)
    self:InitUI()
    self:AddEvent()

    self:SetCurPrice()
end

function WeddingShopPanel:InitUI()
    local items = self.model:GetShopItems()
    for i = 1, #items do
        local item = self.items[i]
        if not item then
            item = WeddingShopItem(self.WeddingShopItem.gameObject,self.leftContent,"UI")
            self.items[i] = item
        end
        item:SetData(items[i])
    end

    if self.itemId then
        self:WeddingShopClick(self.itemId)
    else
        self:WeddingShopClick(self.items[1].data.id)
    end

end


function WeddingShopPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)

    local function call_back()
        OpenLink(401,2)
    end
    AddClickEvent(self.getDiamond_btn.gameObject,call_back)




    local function call_back()  --减

        local curNum = tonumber(self.input.text)
        curNum = curNum - 1
        if curNum <= 1 then
            curNum = 1
          --  ShaderManager.GetInstance():SetImageGray(self.num_reduce_img)
        else
           -- ShaderManager.GetInstance():SetImageNormal(self.num_plus_Img)
        end
        self.input.text = curNum

        self:SetCurPrice()
    end
    AddButtonEvent(self.minus_btn.gameObject, call_back)



    local function call_back() --加

        local curNum = tonumber(self.input.text)
        curNum = curNum + 1
        if curNum * self.curPrice > self.allPrice then
           -- ShaderManager.GetInstance():SetImageGray(self.num_plus_Img)
            curNum = curNum - 1
        else
            --ShaderManager.GetInstance():SetImageNormal(self.num_reduce_img)
        end
        self.input.text = curNum

        self:SetCurPrice()
    end
    AddButtonEvent(self.plus_btn.gameObject, call_back)



    local function call_back() --小键盘
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.num, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 2)
        self.numKeyPad:Open()
    end
    AddButtonEvent(self.keypad_btn.gameObject, call_back)


    local function call_back()
        local curP = tonumber(self.sumprice.text)
        if curP > self.allPrice then
            local function callback()
                OpenLink(401,2)
            end
            Dialog.ShowTwo("Tip", string.format("Insufficient %s, recharge now?",Config.db_item[self.curPriceId].name), "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false);
        else
            ShopController:GetInstance():RequestBuyGoods(self.goodsId,tonumber(self.input.text))
        end
    end
    AddButtonEvent(self.buy_btn.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.WeddingShopClick,handler(self,self.WeddingShopClick))
    self.gevents[#self.gevents] = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop,handler(self,self.SuccessToBuyGoodsInShop))

end

function WeddingShopPanel:WeddingShopClick(id)
    for i, v in pairs(self.items) do
        if id == v.data.id then
            v:SetShow(true)
            self:SetLeftInfo(v.data)
        else
            v:SetShow(false)
        end
    end
end

function WeddingShopPanel:SetLeftInfo(data)
    self.input.text = 1
    self.goodsId = data.id
    local itemId = String2Table(data.item)[1]
    local itemCfg = Config.db_item[itemId]
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(itemCfg.color), itemCfg.name)
    self.itemName.text = str
    self.des.text = itemCfg.desc
    self.level.text = itemCfg.level

    local itemTab = String2Table(data.item)
    local itemId = itemTab[1]
    local num = itemTab[2]
    local bind = itemTab[3]
    self:CreateIcon(itemId,num,bind)



    local priceTab = String2Table(data.price)
    self.curPriceId = priceTab[1]
    self.curPrice = priceTab[2]
    self.sumprice.text = self.curPrice * tonumber(self.input.text)
    GoodIconUtil:CreateIcon(self, self.haveIcon, self.curPriceId, true)
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.curPriceId)
    if not roleBalance then
        roleBalance = 0
    end
    self.allPrice = roleBalance
    if self.HDiamond then
        self.HDiamond.text = tostring(roleBalance)
    end
    self:SetCurPrice()



end

function WeddingShopPanel:CreateIcon(id,num,bind)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.icon)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = id
    param["num"] = num
    param["bind"] = bind
    param["can_click"] = true
    --  param["size"] = {x = 72,y = 72}

    self.itemicon:SetIcon(param)
end

function WeddingShopPanel:ClickCheckInput(num)
    if self.curPrice * tonumber(self.input.text) > self.allPrice  then
        self.input.text = self:GetBuyMaxNum()
    end
    self:SetCurPrice()
end

function WeddingShopPanel:SetCurPrice()
    if self.curPrice * tonumber(self.input.text) > self.allPrice  then
        self.input.text = self:GetBuyMaxNum()
    end
   -- print2(self.curPrice,tonumber(self.input.text) ,self.curPrice * tonumber(self.input.text) + 1,self.allPrice)
    if self.curPrice * (tonumber(self.input.text) + 1) > self.allPrice then
        ShaderManager.GetInstance():SetImageGray(self.num_plus_Img)
    else
        ShaderManager.GetInstance():SetImageNormal(self.num_plus_Img)
    end

    if tonumber(self.input.text) == 1 then
        ShaderManager.GetInstance():SetImageGray(self.num_reduce_img)
    else
        ShaderManager.GetInstance():SetImageNormal(self.num_reduce_img)
    end
    self.sumprice.text = self.curPrice * tonumber(self.input.text)
end

function WeddingShopPanel:GetBuyMaxNum()
    local num = math.floor(self.allPrice/self.curPrice)
    if num == 0 then
        num = 1
    end
    return num
end
--购买成功
function WeddingShopPanel:SuccessToBuyGoodsInShop()
    print2("购买成功")
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(self.curPriceId)
    if not roleBalance then
        roleBalance = 0
    end
    self.allPrice = roleBalance
    self.HDiamond.text = tostring(roleBalance)
    self:SetCurPrice()
end

