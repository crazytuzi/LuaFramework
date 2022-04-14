UpShelfTowPanel = UpShelfTowPanel or class("UpShelfTowPanel",WindowPanel)
local UpShelfTowPanel = UpShelfTowPanel

function UpShelfTowPanel:ctor()
    self.abName = "market";
    self.assetName = "UpShelfTowPanel"
    self.layer = "UI"
    self.model = MarketModel:GetInstance()
    self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
    self.show_sidebar = false		--是否显示侧边栏
    self.curItem = nil
    self.Events = {} --事件

    self.leftItems = {}
    self.model.isOpenUpShelfMarketTwo = true
end

function UpShelfTowPanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)
    self.model.isOpenUpShelfMarketTwo = false
    for i, v in pairs(self.leftItems) do
        v:destroy()
        v = nil
    end
    self.leftItems = nil
    if self.curItem then
        self.curItem:destroy()
    end
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
end
function UpShelfTowPanel:Open(data)
    self.panelType = data
    UpShelfTowPanel.super.Open(self)
end

function UpShelfTowPanel:LoadCallBack()


    self.nodes =
    {
        "itemParent",
        "Num_Count_Group",
        "Num_Count_Group/num_num",
        "Num_Count_Group/num_keypad",
        "Num_Count_Group/num_plus_btn",
        "Num_Count_Group/num_reduce_btn",
        "Num_Count_Group/num_numBg",
        "price_Count_Group",
        "price_Count_Group/price_num",
        "price_Count_Group/price_keypad",
        "price_Count_Group/price_plus_btn",
        "price_Count_Group/price_reduce_btn",
        "price_Count_Group/price_numBg",
        "Text/AllPricNum",
        "Text/isVipTips",
        "btns/upBtn",
        "btns/upBtn/UpText",
        "btns/payBtn",
        "btns/modifyBtn",
        "Friend/obj",
        "Friend/obj/friendIcon",
        "Friend/obj/role_icon",
        "Friend/obj/friendName",
        "Friend/obj/friendVip",
        "Friend/NoFriend",
        "Friend/click",
        "itemScrollView/Viewport/itemContent",
        "leftNull","Text/Image",


    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self:SetTileTextImage("market_image", "market_title_2");
    self:SetPanelSize(660, 482)
    self.minPrice , self.maxPrice  = self.model:GetCanUpShelfItemMaxPrice(self.model.selectItem.id)

    self.num_num = GetText(self.num_num)
    self.num_num.text = 1
    self.price_num = GetText(self.price_num)
    self.price_num.text = self.minPrice
    self.num_plus_btn = GetButton(self.num_plus_btn)
    self.num_plus_Img = GetImage(self.num_plus_btn)
    self.num_reduce_btn = GetButton(self.num_reduce_btn)
    self.num_reduce_img = GetImage(self.num_reduce_btn)
    self.price_plus_btn = GetButton(self.price_plus_btn)
    self.price_plus_img = GetImage(self.price_plus_btn)
    self.price_reduce_btn = GetButton(self.price_reduce_btn)
    self.price_reduce_img = GetImage(self.price_reduce_btn)
    self.modifyBtn = GetButton(self.modifyBtn)
    self.payBtn = GetButton(self.payBtn)
    self.numBtn = GetButton(self.num_numBg)
    self.priceBtn = GetButton(self.price_numBg)
    self.friendName = GetText(self.friendName)
    self.friendVip = GetText(self.friendVip)
    --self.role_icon = GetImage(self.role_icon)
    self.upBtn = GetButton(self.upBtn)
    self.UpText = GetText(self.UpText)
    self.isVipTips = GetText(self.isVipTips)
    self.Image = GetImage(self.Image)
    self.num_num.text = "1"
    ShaderManager.GetInstance():SetImageGray(self.num_reduce_img)
    ShaderManager.GetInstance():SetImageGray(self.price_reduce_img)
    self.AllPricNum = GetText(self.AllPricNum)

    self:InitUI()
    self:AddEvent()
    self:UpdateAllPrice()

    local itemsID = {}
    table.insert(itemsID,self.model.selectItem.id)
    MarketController:GetInstance():RequeseSearchInfo(itemsID)

    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.Image, iconName, true)

end

function UpShelfTowPanel:InitUI()
    self.curItem = UpShelfTowItem(self.itemParent,"UI")
    self.curItem:SetData(self.model.selectItem,1)

    if self.model.selectItem.num <= 1 then
        ShaderManager.GetInstance():SetImageGray(self.num_plus_Img)
    end


   -- self.isVipTips.text = self.model:GetVipTax()
    self.isVipTips.text = string.format("You are VIP%s, tax is %s",RoleInfoModel:GetInstance():GetMainRoleVipLevel(),self.model:GetVipTax().."%")
    --if tonumber(RoleInfoModel.GetInstance():GetMainRoleData().viplv) <= 0 then
    --    self.isVipTips.text = "您还不是贵族，交易税为20%。"
    --else
    --    self.isVipTips.text = "您已经是贵族，无交易税。"
    --end

    if self.panelType == 1 then --上架
        self.UpText.text = string.format("Add to shelf (%s/%s)",#self.model.saleList,self.model:GetVipTimes())
        SetVisible(self.modifyBtn,false)
    else --修改
       -- SetVisible(self.click,false)
        SetVisible(self.payBtn,false)
        SetVisible(self.upBtn,false)
       -- SetVisible(self.Num_Count_Group,false)
        if self.model.seletAppointInfo ~= nil then
            dump(self.model.seletAppointInfo)
            self:UpdateRole(self.model.seletAppointInfo.to_id)
        end
    end

   -- dump(FriendModel:GetInstance():GetFriendList() )

end

function UpShelfTowPanel:AddEvent()
    local function num_plus_call_back()   --加数量
        if self.panelType == 2 then
            Notify.ShowText("If you want to modify the amounts, please remove the items from the shelf")
            return
        end
        local curNum = tonumber(self.num_num.text)
        local ItemNum = self.model.selectItem.num
        curNum = curNum + 1
        if curNum >= ItemNum then
            ShaderManager.GetInstance():SetImageGray(self.num_plus_Img)
            curNum = ItemNum
        else
            ShaderManager.GetInstance():SetImageNormal(self.num_reduce_img)
        end
        self.num_num.text = curNum
        self:UpdateAllPrice()
    end
    AddButtonEvent(self.num_plus_btn.gameObject, num_plus_call_back)
    local function num_reduce_call_back() --减数量
        if self.panelType == 2 then
            Notify.ShowText("If you want to modify the amounts, please remove the items from the shelf")
            return
        end
        local curNum = tonumber(self.num_num.text)
        curNum = curNum - 1
        if curNum <= 1 then
            curNum = 1

            ShaderManager.GetInstance():SetImageGray(self.num_reduce_img)
        else
            ShaderManager.GetInstance():SetImageNormal(self.num_plus_Img)
        end
        self.num_num.text = curNum
        self:UpdateAllPrice()
    end
    AddButtonEvent(self.num_reduce_btn.gameObject, num_reduce_call_back)

    local function price_reduce_call_back() --减价钱
        local curPrice = tonumber(self.price_num.text)
        curPrice = curPrice - 1
        if curPrice <= self.minPrice then
            curPrice = self.minPrice
            Notify.ShowText(string.format('The lowest price of the item is <color=#%s>%s</color> diamonds',"f2f23f",self.minPrice))
            ShaderManager.GetInstance():SetImageGray(self.price_reduce_img)
        else
            ShaderManager.GetInstance():SetImageNormal(self.price_plus_img)
        end
        self.price_num.text = curPrice
        self:UpdateAllPrice()
    end
    AddButtonEvent(self.price_reduce_btn.gameObject, price_reduce_call_back)
    local function price_plus_call_back() --加价钱
        local curPrice = tonumber(self.price_num.text)
        curPrice = curPrice + 1
        if curPrice >= self.maxPrice then
            curPrice = self.maxPrice
            ShaderManager.GetInstance():SetImageGray(self.price_plus_img)
        else
            ShaderManager.GetInstance():SetImageNormal(self.price_reduce_img)
        end
        self.price_num.text = curPrice
        self:UpdateAllPrice()
    end


    AddButtonEvent(self.price_plus_btn.gameObject, price_plus_call_back)

    local function numBtn_call_back() --数量小键盘
        if self.panelType == 2 then
            Notify.ShowText("If you want to modify the amounts, please remove the items from the shelf")
            return
        end
        if self.model.selectItem.num <= 1 then
            return
        end
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.num_num, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 2)
        self.numKeyPad:Open()
    end

    AddButtonEvent(self.numBtn.gameObject, numBtn_call_back)

    local function priceBtn_call_back() --价钱小键盘
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.price_num, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 2)
        self.numKeyPad:Open()
    end

    AddButtonEvent(self.priceBtn.gameObject, priceBtn_call_back)

    local function upBtn_call_back()  --上架
        if self.roleID then
            local roleID = self.roleID
            local uid = self.model.selectItem.uid
            local num = tonumber(self.num_num.text)
            local price = tonumber(self.price_num.text)

            -- print2(roleID,uid,num,price)
            MarketController:GetInstance():RequeseDeal(roleID,uid,num,price)
            return
        end

        local price = tonumber(self.price_num.text)
        if price < self.minPrice  then
            Notify.ShowText("The lowest price:"..self.minPrice)
            return
        end
        if price > self.maxPrice then
            Notify.ShowText("The highest price:"..self.maxPrice)
            return
        end
        MarketController:GetInstance():RequeseSaleInfo(self.model.selectItem.uid,tonumber(self.num_num.text),tonumber(self.price_num.text))
    end
    AddButtonEvent(self.upBtn.gameObject, upBtn_call_back)



    local function payBtn_call_back()  --指定交易
        if self.roleID == nil then
            Notify.ShowText("Please select the friend you are going to initiate the trade")
            return
        end
        local roleID = self.roleID
        local uid = self.model.selectItem.uid
       local num = tonumber(self.num_num.text)
        local price = tonumber(self.price_num.text)

       -- print2(roleID,uid,num,price)
        MarketController:GetInstance():RequeseDeal(roleID,uid,num,price)
    end
    AddButtonEvent(self.payBtn.gameObject, payBtn_call_back)

    local function modifyBtn_call_back()  --修改
      --  print2(self.model.selectGoodItem.uid)
        local uid = self.model.selectGoodItem.uid
        MarketController:GetInstance():RequeseAlter(uid,tonumber(self.price_num.text))
    end
    AddButtonEvent(self.modifyBtn.gameObject, modifyBtn_call_back)


    local function friendClick_call_back()
        if self.panelType == 2 then
            Notify.ShowText("If you need a designated trade, please remove the items from the shelf")
            return
        end
        lua_panelMgr:GetPanelOrCreate(UpShelfThreePanel):Open()
    end
    AddButtonEvent(self.click.gameObject,friendClick_call_back)


    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketSaleInfo, handler(self, self.UpShelfMarketSaleInfo))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketClickSelectRole, handler(self, self.UpdateRole))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketDeal, handler(self, self.UpShelfMarketDeal))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketAlter, handler(self, self.UpShelfMarketAlter))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateSearchItemData, handler(self, self.UpdateSearchItem))


end

--检查数量
function UpShelfTowPanel:GetNumCount(type)
   return self.model:GetGetCanUpShelfItemNumInBag(type,self.model.selectItem.id)
end


--刷新总价
function UpShelfTowPanel:UpdateAllPrice()
    local price  = tonumber(self.price_num.text)
    local num = tonumber(self.num_num.text)
   self.AllPricNum.text = tostring(price * num)
end


function UpShelfTowPanel:ClickCheckInput(target)
    print2(self.price_num.text,self.num_num.text)
    local price  = tonumber(self.price_num.text)
    local num = tonumber(self.num_num.text)
    if num > self.model.selectItem.num then
        self.num_num.text = self.model.selectItem.num
        Notify.ShowText("Max amount exceeded")
    end

    if price > self.maxPrice then
        self.price_num.text = self.maxPrice
        Notify.ShowText("Max price exceeded")
    --else
    --    self.price_num.text = self.minPrice
    --    Notify.ShowText("超过最低价格")
    end

    --local ItemNum = self:GetNumCount(1)  --数量
    self:UpdateAllPrice()
end

function UpShelfTowPanel:UpShelfMarketSaleInfo(data)
    self:Close()
end

function UpShelfTowPanel:UpdateRole(roleID)
    self.roleID = roleID
    SetVisible(self.obj,true)
    SetVisible(self.NoFriend,false)
    self:UpdateItem()
end


function UpShelfTowPanel:UpdateItem()
    local friend = FriendModel:GetInstance():GetPFriend(self.roleID)
    if friend then
        local role = friend.base
        self:UpdateRoleInfo(role)
    end
end

function UpShelfTowPanel:UpdateRoleInfo(role)
    self.friendName.text = role.name
    --if role.gender == 1 then
    --    lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', 'img_role_head_1',true)
    --else
    --    lua_resMgr:SetImageTexture(self,self.role_icon, 'main_image', 'img_role_head_2',true)
    --end
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    --param["is_squared"] = true
    --param["is_hide_frame"] = true
    param["size"] = 65
    param["uploading_cb"] = uploading_cb
    param["role_data"] = role
    self.role_icon1 = RoleIcon(self.role_icon)
    self.role_icon1:SetData(param)
    self.friendVip.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
end


function UpShelfTowPanel:UpdateSearchItem(data)
    if data.items == nil or data.items == {} or #data.items <= 0 then
        SetVisible(self.leftNull,true)
    else
        for i, v in pairs(data.items) do
            self.leftItems[i] = UpShelfTowItem(self.itemContent,"UI")
            self.leftItems[i]:SetData(v,2)
        end
    end

end



function UpShelfTowPanel:UpShelfMarketDeal(data)
    self:Close()
end

function UpShelfTowPanel:UpShelfMarketAlter()
    self:Close()
end

