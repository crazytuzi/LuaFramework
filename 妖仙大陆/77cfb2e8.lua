


local Util = require "Zeus.Logic.Util"
local ShopAPI = require "Zeus.Model.Shop"
local Item = require "Zeus.Model.Item"
local ShopUtil = require "Zeus.UI.XmasterShop.ShopUtil"
local _M = {
    parent = nil,mainTabs = nil,mainTabIdx = nil,selectItem = nil,itemShowIcons = nil,buyCount = nil,itemNodes = nil,selectTitleIndex = nil,
    canChange = nil,tiplimitGoodsMax=nil,OK=nil,Cancel=nil,Send=nil,notEnoughGoods=nil,CannotExchange=nil,Diamond=nil,Ticket=nil,noLimit=nil,
}
_M.__index = _M

local Conf_Script = {
    HOT = -1,
    NEW = -2,
    NONE = 0
}

local ui_names = {
    {name = "tbt_rmby"},
    {name = "tbt_bind_rmby"},
    {name = "btn_exchange",click = function(self)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore, 0)
    end},
    {name = "lb_gift_num"},
    {name = "ib_gift_integral"},
    {name = "sp_sort_deatil"},
    {name = "cvs_sort_single"},
    {name = "cvs_sort_change"},
    {name = "tb_props_describe"},
    {name = "lb_stack_max"},
    {name = "lb_use_level"},
    {name = "tbt_change"},
    {name = "cvs_props_detail"},
    {name = "cvs_props_change"},
    
    {name = "btn_less",click = function(self)
        if self.selectItem then
            self.buyCount = self.buyCount - 1
            if self.buyCount < 1 then
                self.buyCount = 1
            end
            self:changeMoney()
        end
    end},
    {name = "btn_plus",click = function(self)
        if self.selectItem then
            local playerMoney = 0
            if self.mainTabIdx == 1 then
                playerMoney = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)
            elseif self.mainTabIdx == 2 then
                playerMoney = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.TICKET)
            elseif self.mainTabIdx == 3 then
                playerMoney = self.canChange
            end
            local maxCount = 999
            local count = 999
            if self.selectItem.remainNum > 0 then
                count = self.selectItem.remainNum
            else
                count = 999
            end

            local canCount = 1
            if self.mainTabIdx == 3 then
                canCount = playerMoney
            else
                canCount = math.floor(playerMoney / self.selectItem.nowPrice)
            end
            maxCount = count > canCount and canCount or count
            

            if self.buyCount >= maxCount then
                self.buyCount = maxCount
                GameAlertManager.Instance:ShowNotify(self.tiplimitGoodsMax)
            else
                self.buyCount = self.buyCount + 1
            end
            self.buyCount = self.buyCount < 1 and 1 or self.buyCount
            self:changeMoney()
        end
    end},
    {name = "btn_max",click = function(self)
        if self.selectItem then             
            local playerMoney = 0
            if self.mainTabIdx == 1 then
                playerMoney = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)
            elseif self.mainTabIdx == 2 then
                playerMoney = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.TICKET)
            elseif self.mainTabIdx == 3 then
                playerMoney = self.canChange
            end
            local maxCount = 999
            local count = 0
            if self.selectItem.remainNum > 0 then
                count = self.selectItem.remainNum
            else
                count = 999
            end
            local canCount = 1
            if self.mainTabIdx == 3 then
                canCount = playerMoney
            else
                canCount = math.floor(playerMoney / self.selectItem.nowPrice)
            end
            maxCount = count > canCount and canCount or count
            self.buyCount = maxCount < 1 and 1 or maxCount
            self:changeMoney()
        end
    end},
    {name = "ti_number"},
    {name = "ib_price"},
    {name = "lb_price_num"},
    {name = "btn_give_friend",click = function(self)
        if self.selectItem then
            self:onSendBtnClick()
        end
    end},
    {name = "btn_buy",click = function(self)
         if self.selectItem then
            self:buyItem()
         end
    end},
    {name = "btn_buy1",click = function(self)
         if self.selectItem then
            self:buyItem()
         end
    end},
    {name = "btn_change",click = function(self)
         if self.selectItem then
            self:buyItem()
         end
    end},
    {name = "sp_sort"},
    {name = "tb_single"},
    {name = "lb_xiangou"},
    {name = "lb_xiangou_num"},
}




local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function updateMoney(self)
    local money = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.CONSUMEPOINT, 0)
    self.lb_gift_num.Text = Util.NumFormat(money, 3, ',')
    local moneyEnum = nil
    local moneyType = 0
    if self.mainTabIdx == 1 then
        moneyEnum = UserData.NotiFyStatus.CONSUMEPOINT
        moneyType = 1
    elseif self.mainTabIdx == 2 then
        moneyEnum = UserData.NotiFyStatus.CONSUMEPOINT
        moneyType = 2
    end
    self.moneyType = moneyType

end

local function onSubTabSelected(self,sender)
    local index = table.indexOf(self.subTbtBtns,sender)
    local datas = self.tabDatasList[self.mainTabIdx]
    local info = datas[index]
    self.selectTitleIndex = index
    self:requestItemList(info)
end

local function checkSubParam(self, datas)
    local index = 1
    if self.subParam then
        for i = 1, #datas, 1 do
            if tonumber(datas[i].itemType) == tonumber(self.subParam) then
                index = i
                break
            end
        end
    end
    return index
end

local function setDiamondShopValue(self)
    local datas = self.tabDatasList[1]
    self.curShowDatas = datas
    self.subTbtBtns = {}
    self.subTbtData = {}
    if #datas > 0 then
        self.sp_sort.Scrollable:Reset(1,#datas)
        Util.InitMultiToggleButton( function(sender)
            onSubTabSelected(self, sender)
        end , nil, self.subTbtBtns)
        local index = checkSubParam(self,datas)
        Util.ChangeMultiToggleButtonSelect(self.subTbtBtns[index],self.subTbtBtns)
        self.subParam = nil
    end
end

local function setTicketShopValue(self)
    local datas = self.tabDatasList[2]
    self.curShowDatas = datas
    self.subTbtBtns = {}
    self.subTbtData = {}
    if #datas > 0 then
        self.sp_sort.Scrollable:Reset(1,#datas)
        Util.InitMultiToggleButton( function(sender)
            onSubTabSelected(self, sender)
        end , nil, self.subTbtBtns)
        local index = checkSubParam(self,datas)
        Util.ChangeMultiToggleButtonSelect(self.subTbtBtns[index],self.subTbtBtns)
        self.subParam = nil
    end
end

local function setChangeShopValue(self)
    local datas = self.tabDatasList[3]
    self.curShowDatas = datas
    self.subTbtBtns = {}
    self.subTbtData = {}
    if #datas > 0 then
        self.sp_sort.Scrollable:Reset(1,#datas)
        Util.InitMultiToggleButton( function(sender)
            onSubTabSelected(self, sender)
        end , nil, self.subTbtBtns)
        local index = checkSubParam(self,datas)
        Util.ChangeMultiToggleButtonSelect(self.subTbtBtns[index],self.subTbtBtns)
        self.subParam = nil
    end
end
local function onMainTabChange(self,sender)
    self.mainTabIdx = table.indexOf(self.mainTabs, sender)
    updateMoney(self)
    if self.mainTabIdx == 1 then
        setDiamondShopValue(self)
    elseif self.mainTabIdx == 2 then
        setTicketShopValue(self)
    elseif self.mainTabIdx == 3 then
        setChangeShopValue(self)
    end
end

local function setTitleNodeValue(self,index,node)
    local data = self.curShowDatas[index]
    node.Text = data.text
    self.subTbtData[node] = data
end

local function clearItemListSelect(self)
    for k,v in pairs(self.itemListNodes) do
         local ib_choose = v:FindChildByEditName("ib_choose",false)   
         ib_choose.Visible = false
    end
end

local function Clear3DAvatar(self)
    if self.avatar_show then    
        UnityEngine.Object.DestroyObject(self.avatar_show.obj)
        IconGenerator.instance:ReleaseTexture(self.avatar_show.key)
        self.avatar_show = nil
    end
end





























function _M:changeMoney()
    self.ti_number.Text = self.buyCount
    self.lb_price_num.Text = self.buyCount*self.selectItem.nowPrice
end


local function InitChangeUI(ui, node)
    local UIName = {
        "cvs_item1",
        "cvs_item2",
        "cvs_item3",
        "ib_plus1",
        "ib_plus2",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end


function _M:setItemDetail()
    if self.selectItem then
        local detail = self.selectItem.detail
        local lb_name = nil
        local lb_desc = nil

        if tonumber(self.selectItem.id) >= 301001 then
            self.cvs_props_detail.Visible = false
            lb_name = self.cvs_props_change:FindChildByEditName("lb_props_name1",true)
            lb_desc = self.cvs_props_change:FindChildByEditName("tb_props_describe",true)
            local ui={}
            local info = GlobalHooks.DB.Find("ExchangeMall", {ID = self.selectItem.id})[1]
            local infoList = string.split(info.ExchangeNeed,";")
            InitChangeUI(ui, self.cvs_props_change)
            for i=1,3 do
                ui["cvs_item" .. i].Visible = false
            end
            local minNum = 999
            for i = 1, #infoList do
                if infoList[i] ~= nil then
                    local detailList = string.split(infoList[i],":")
                    local detail = Item.GetItemDetailByCode(detailList[1]) 
                    local cvs_icon = ui["cvs_item" .. i]:FindChildByEditName("cvs_icon",true)
                    local cvs_num = ui["cvs_item" .. i]:FindChildByEditName("lb_num",true)  
                    local vItem = DataMgr.Instance.UserData.RoleBag:MergerTemplateItem(detailList[1])
                    local cur_num = (vItem and vItem.Num) or 0
                    if cur_num >= tonumber(detailList[2]) then
                        local num = math.floor(cur_num / tonumber(detailList[2]))
                         minNum = minNum > num and num or minNum
                        cvs_num.FontColor = Util.FontColorGreen
                    else
                        minNum = 0
                        cvs_num.FontColor = Util.FontColorRed
                    end
                    cvs_num.Text = cur_num .. "/" .. detailList[2]
        
                    local m_it = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,1)
                    Util.NormalItemShowTouchClick(m_it,detailList[1],cur_num < tonumber(detailList[2]))
                    ui["cvs_item" .. i].Visible = true
                else
                    ui["cvs_item" .. i].Visible = false
                end
            end
            self.canChange = minNum
            
            if #infoList < 2 then
                ui["ib_plus1"].Visible = false
                ui["ib_plus2"].Visible = false
                ui["cvs_item1"].X = 140
            elseif #infoList < 3 then 
                ui["ib_plus1"].X = 150
                ui["ib_plus1"].Visible = true
                ui["ib_plus2"].Visible = false
                for i=1,#infoList do
                    ui["cvs_item" .. i].X = 140*i-80
                end
            else
                ui["ib_plus1"].X = 91
                ui["ib_plus1"].Visible = true
                ui["ib_plus2"].Visible = true
                 for i=1,#infoList do
                    ui["cvs_item" .. i].X = 10 + 120*(i-1)
                end
            end
            self.cvs_props_change.Visible = true

        
            self.lb_price_num.Visible = false
            self.ib_price.Visible = false
            self.lb_xiangou.Visible = true
            self.lb_xiangou_num.Text = self.selectItem.remainNum < 0 and self.noLimit or self.selectItem.remainNum
            self.lb_xiangou_num.Visible = true
            self.btn_change.Visible = true

        else
            self.cvs_props_change.Visible = false
            self.cvs_props_detail.Visible = true
            lb_name = self.cvs_props_detail:FindChildByEditName("lb_props_name1",true)
            lb_desc = self.cvs_props_detail:FindChildByEditName("tb_props_describe",true)
            
            local lb_stack_max = self.cvs_props_detail:FindChildByEditName("lb_stack_max",true)
            lb_stack_max.Text = Util.GetText(TextConfig.Type.ITEM,'maxCount')..detail.static.GroupCount
            local lb_use_level = self.cvs_props_detail:FindChildByEditName("lb_use_level",true)
            lb_use_level.Text = string.format(Util.GetText(TextConfig.Type.ITEM,'useLevel'),detail.static.LevelReq)
            self.lb_price_num.Visible = true
            self.ib_price.Visible = true
            self.lb_xiangou.Visible = false
            self.lb_xiangou_num.Visible = false
            self.btn_change.Visible = false
        end

         lb_name.Text = string.format("<color=#%s>%s</color>",Util.GetQualityColorRGBAStr(detail.static.Qcolor),detail.static.Name)
         lb_desc.UnityRichText = detail.static.Desc
        self.ti_number.Enable = true
        self.ti_number.IsInteractive = true
        self.ti_number.event_PointerClick = function()
            local view,numInput = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINumberInput,0)
            local x = self.ti_number.X + self.ti_number.Parent.X + self.ti_number.Parent.Parent.X + self.ti_number.Parent.Parent.Parent.X
            local y = self.ti_number.Y + self.ti_number.Parent.Y + self.ti_number.Parent.Parent.Y + self.ti_number.Parent.Parent.Parent.Y
            local pos = {X = x,Y = y - 200}
            numInput:SetPos(pos)
            local function funcClickCallback(value)
                self.buyCount = value
                self:changeMoney()
            end
            local canCount = 999
            local tip = nil
            if self.selectItem.remainNum > 0 then
                canCount = self.selectItem.remainNum
                tip = self.tiplimitGoodsMax
            end
            numInput:SetValue(1,canCount,self.buyCount,funcClickCallback,nil,tip)
        end
        ShopUtil.setMoneyIcon(self.ib_price, self.mainTabIdx)
        self:changeMoney()

        if self.selectItem.canSend == 1 then
            self.btn_give_friend.Visible = true
            self.btn_give_friend.Enable = true
            self.btn_buy.Visible = true
            self.btn_buy1.Visible = false
        else
            self.btn_give_friend.Visible = false
            self.btn_give_friend.Enable = false
            self.btn_buy.Visible = false
            self.btn_buy1.Visible = true
        end
        self.btn_less.Enable = true
        self.btn_plus.Enable = true
        self.btn_max.Enable = true
        if self.selectItem.remainNum == 0 then
            self.btn_give_friend.Visible = false
            self.btn_give_friend.Enable = false
            self.ti_number.Enable = false
            self.ti_number.IsInteractive = false
            self.btn_buy.Visible = false
            self.btn_buy1.Visible = true
            self.btn_less.Enable = false
            self.btn_plus.Enable = false
            self.btn_max.Enable = false
            self.buyCount = 0
            self:changeMoney()
        end
    else
        self.ti_number.Enable = false
        self.ti_number.IsInteractive = false
        self.btn_less.Enable = false
        self.btn_plus.Enable = false
        self.btn_max.Enable = false
    end
end

function _M:SelectItem(node,item)
    local ib_choose = node:FindChildByEditName("ib_choose",false)
    ib_choose.Visible = true
    if self.selectItem == item then
        return
    end
    
    self.selectItem = item
    self.canChange = 1
    self.buyCount = 1
    self:setItemDetail()
end

local function setItemNodeValue(self,index,node)

    local ib_choose = node:FindChildByEditName("ib_choose",false)
    local ib_props_icon = node:FindChildByEditName("ib_props_icon",false)
    local lb_props_name = node:FindChildByEditName("lb_props_name",false)
    local ib_cost_icon = node:FindChildByEditName("ib_cost_icon",false)
    local lb_cost_num = node:FindChildByEditName("lb_cost_num",false)
    local lb_lave = node:FindChildByEditName("lb_lave",false)
    local lb_lave_num = node:FindChildByEditName("lb_lave_num",false)
    local lb_gift = node:FindChildByEditName("lb_gift",false)
    local ib_gift_integral = node:FindChildByEditName("ib_gift_integral",false)
    local lb_gift_integral_num = node:FindChildByEditName("lb_gift_integral_num",false)
    local lb_lave_time = node:FindChildByEditName("lb_lave_time",false)
    local ib_discount = node:FindChildByEditName("ib_discount",false)
    
    local lb_change = node:FindChildByEditName("lb_change",false)
    local lb_change_num = node:FindChildByEditName("lb_change_num",false)
    local lb_change_time = node:FindChildByEditName("lb_change_time",false)
    local lb_changelave_time = node:FindChildByEditName("lb_changelave_time",false)
    lb_change_time.Visible = false
    lb_changelave_time.Visible = false

    local item = self.itemList[index]
    local datas = self.tabDatasList[self.mainTabIdx]
    local info = datas[self.selectTitleIndex]
    lb_lave.Text = info.lastNumText..":"
    lb_change.Text = info.lastNumText..":"

    node.Enable = true
    node.IsInteractive = true
    ib_choose.Visible = (self.selectItem == item)
    node.event_PointerClick = function()
        clearItemListSelect(self)
        self:SelectItem(node,item)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('xuanqu')
    end
    local detail = item.detail
    self.itemShowIcons[node] = Util.ShowItemShow(ib_props_icon, detail.static.Icon, detail.static.Qcolor, 0, false)
    lb_props_name.Text = string.format("<color=#%s>%s</color>",Util.GetQualityColorRGBAStr(detail.static.Qcolor),detail.static.Name)
    if item.endTime == 0 then
        lb_lave_time.Text = ""
        
    end
    ib_props_icon.Enable = true
    ib_props_icon.IsInteractive = true
    ib_props_icon.event_PointerClick = function()
        clearItemListSelect(self)
        self:SelectItem(node,item)
    end 
    lb_cost_num.Text = item.nowPrice
    ShopUtil.setMoneyIcon(ib_cost_icon, self.mainTabIdx)
    
    ib_discount.Visible = item.disCount ~= 0
    if item.disCount ~= 0 then
        local path = GlobalHooks.DB.Find("ShopMall_Icon", {Series = item.disCount})[1].SmallIcon
        Util.HZSetImage(ib_discount, path, false)
    end

    if self.mainTabIdx ~= 3 then
        lb_change.Visible = false
        lb_change_num.Visible = false
        
        
        if item.consumeScore > 0 then
            
            lb_gift.Visible = true
            ib_gift_integral.Visible = true
            lb_gift_integral_num.Visible = true
            lb_gift_integral_num.Text = item.consumeScore
        else
            lb_gift.Visible = false
            ib_gift_integral.Visible = false
            lb_gift_integral_num.Visible = false
        end
    
        if item.remainNum > 0 then
            lb_lave_num.Visible = true
            lb_lave.Visible = true
            lb_lave_num.Text = item.remainNum
        elseif item.remainNum == -1 then
            lb_lave_num.Visible = false
            lb_lave.Visible = false
        else 
            lb_lave_num.Visible = true
            lb_lave.Visible = true
            lb_lave_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5)) 
        end
    else
        lb_cost_num.Visible = false
        ib_cost_icon.Visible = false
        ib_gift_integral.Visible = false
        lb_gift_integral_num.Visible = false
        lb_gift.Visible = false
        lb_lave.Visible = false
        lb_lave_num.Visible = false
        lb_lave_time.Visible = false

        
        
        if item.remainNum > 0 then
            lb_change_num.Visible = true
            lb_change.Visible = true
            lb_change_num.Text = item.remainNum
        elseif item.remainNum < 0 then
            lb_change_num.Text = "不限"
            lb_change_num.Visible = true
            lb_change.Visible = true
        else 
            lb_change_num.Visible = true
            lb_change.Visible = true
            lb_change_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5))
            
        end
    end

    self.itemNodes[node] = item
end

function _M:onSendBtnClick(sender)
    local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopFriendSelect, 0)
    ui:setCallback(function(player)
        
        local item = self.selectItem
        local count = self.buyCount
        local money = item.nowPrice * count
        local function onBuySuccess(item,buyCount)
            local money = item.nowPrice * count
            updateMoney(self)
            for k,v in pairs(self.itemNodes) do
                if v == item then
                    local lb_lave = k:FindChildByEditName("lb_lave",false)
                    local lb_lave_num = k:FindChildByEditName("lb_lave_num",false)
                    local lb_change = k:FindChildByEditName("lb_change",false)
                    local lb_change_num = k:FindChildByEditName("lb_change_num",false)
                    if item.remainNum > 0 then
                        item.remainNum = item.remainNum - buyCount
                        lb_lave_num.Text = item.remainNum
                        lb_change_num.Text = item.remainNum
                        self.buyCount = 1
                        if item.remainNum <= 0 then
                            item.remainNum = 0
                            lb_lave_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5))
                            lb_change_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5))
                            self.buyCount = 0
                        end
                    end
                    self.selectItem = item
                    self:setItemDetail()
                    break
                end
            end
        end
        ShopUtil.checkMoney(self.moneyType, money, function(buyType)
            local itemName = ShopUtil.itemHtmlName(item)
            local playerName = ShopUtil.playerHtmlName(player)
            local text = Util.GetText(TextConfig.Type.SHOP,"confirmSendItem" .. self.moneyType, money, itemName, item.groupCount * count, player.name)
            GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, text, self.OK, self.Cancel, self.Send, nil,
            function(p)
                ShopUtil.confirmBuyItem(text, item, count, player.id, nil, onBuySuccess, buyType)
            end , function() end) 
        end)
    end)
end

function _M:buyItem()
    
    if  self.selectItem.remainNum == 0  then
        if tonumber(self.selectItem.id) < 301001 then
            GameAlertManager.Instance:ShowNotify(self.notEnoughGoods)
            return
        else
            GameAlertManager.Instance:ShowNotify(self.CannotExchange)
            return 
        end
    else
        if  self.canChange <= 0 then
           if tonumber(self.selectItem.id) >= 301001 then
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.SHOP, "cannotexchange"))
                return 
            end 
        end
    end

    local item = self.selectItem
    local count = self.buyCount
    local money = item.nowPrice * count
    local function onBuySuccess(item,buyCount,totalNum)
        local money = item.nowPrice * count
        updateMoney(self)
        for k,v in pairs(self.itemNodes) do
            if v == item then
                local lb_lave = k:FindChildByEditName("lb_lave",false)
                local lb_lave_num = k:FindChildByEditName("lb_lave_num",false)
                local lb_change = k:FindChildByEditName("lb_change",false)
                local lb_change_num = k:FindChildByEditName("lb_change_num",false)
                if item.remainNum > 0 then
                    item.remainNum = item.remainNum - buyCount
                    lb_lave_num.Text = item.remainNum
                    lb_change_num.Text = item.remainNum
                    self.buyCount = 1
                    if item.remainNum <= 0 then
                        item.remainNum = 0
                        lb_lave_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5))
                        lb_change_num.Text = string.format("<color=#%s>0</color>",Util.GetQualityColorRGBAStr(5))
                        self.buyCount = 0

                    end
                end
                self.selectItem = item
                self:setItemDetail()
                break
            end
        end
        EventManager.Fire("Event.ShopMall.BuySuccess",{itemCode = item.detail.static.Code,buyCount = buyCount,totalCount = totalNum})
    end
    if tonumber(self.selectItem.id) >= 301001 then
        ShopUtil.checkMoney(3, money, function(buyType)
            ShopUtil.confirmBuyItem(nil, item, count, nil, nil, onBuySuccess, buyType)
            end)
    else
        ShopUtil.checkMoney(self.moneyType, money, function(buyType)
            local name = ShopUtil.itemHtmlName(item)
            local text = Util.GetText(TextConfig.Type.SHOP, "confirmBuyItem" .. self.moneyType, money, name, item.groupCount * count)
            ShopUtil.confirmBuyItem(text, item, count, nil, nil, onBuySuccess, buyType)

        local counterStr = "PageMallBI"
        local valueStr = ""
        local kingdomStr =  ""
        
        local detail = Item.GetItemDetailByCode(item.detail.static.Code)
        local phylumStr = detail.static.Name.."("..item.detail.static.Code..")"..":"..count
        
        local classfieldStr = ""
        local familyStr = money
        local genusStr = ""
        if self.mainTabIdx == 1 then
            kingdomStr = "1"
            classfieldStr = self.Diamond
        else
            kingdomStr = "2"
            classfieldStr = self.Ticket
        end
        Util.SendBIData(counterStr,valueStr,kingdomStr,phylumStr,classfieldStr,familyStr,genusStr)
        end )
    end
end

local function InitWords(self)
    self.tiplimitGoodsMax = Util.GetText(TextConfig.Type.SHOP, "tiplimitGoodsMax")
    self.OK = Util.GetText(TextConfig.Type.SHOP, "OK")
    self.Cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
    self.Send = Util.GetText(TextConfig.Type.SHOP, "Send")
    self.notEnoughGoods = Util.GetText(TextConfig.Type.SHOP, "notEnoughGoods")
    self.CannotExchange = Util.GetText(TextConfig.Type.SHOP, "CannotExchange")
    self.Diamond = Util.GetText(TextConfig.Type.SHOP, "Diamond")
    self.Ticket = Util.GetText(TextConfig.Type.SHOP, "Ticket")
    self.noLimit = Util.GetText(TextConfig.Type.SHOP, "noLimit")
end

local function InitComponent(self,cvs)
    InitWords(self)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/mall/pageMall.gui.xml')
    self.menu.Enable = false
    initControls(self.menu, ui_names, self)
    cvs:AddChild(self.menu)
    self.mainTabs = {self.tbt_rmby,self.tbt_bind_rmby,self.tbt_change}
     Util.InitMultiToggleButton( function(sender)
       onMainTabChange(self, sender)
    end , nil, self.mainTabs)
    self.tb_single.Visible = false
    self.subTbtBtns = {}
    self.sp_sort:Initialize(self.tb_single.Width,self.tb_single.Height,1,0,self.tb_single,
        function(gx,gy,node)
            local index = gy + 1
            setTitleNodeValue(self,index,node)
            table.insert(self.subTbtBtns,node)
        end,
        function()

        end
    )
    self.cvs_sort_single.Visible = false
    self.sp_sort_deatil:Initialize(self.cvs_sort_single.Width,self.cvs_sort_single.Height,1,0,self.cvs_sort_single,
        function(gx,gy,node)
            local index = gy + 1
            setItemNodeValue(self,index,node)
            table.insert(self.itemListNodes,node)
            if self.needSelect ~= nil then
                if(self.needSelect(index,node)) then
                    self.needSelect = nil
                end
            end
        end,
        function()

        end
    )
end

function _M:responseTabs()
    if self.openParam == nil then
        self.openParam = "diamond"
    end
    self.menu.Visible = true
    if self.openParam == "ticket" then
        Util.ChangeMultiToggleButtonSelect(self.mainTabs[2], self.mainTabs)
    elseif self.openParam == "diamond" then
        Util.ChangeMultiToggleButtonSelect(self.mainTabs[1], self.mainTabs)
    else
        Util.ChangeMultiToggleButtonSelect(self.mainTabs[3], self.mainTabs)
    end
    self.openParam = nil
end

function _M:setParam(param,args)
    self.openParam = param
    if args then
        if #args > 1 then
            self.subParam = args[2]
            if #args > 2 then
                self.itemParam = args[3]
            end
        end
    end
end

function _M:request()
    ShopAPI.requestTabs(function(tabsData)
        self.tabDatasList = {
            {hasLimit=false, isLimitOpen=false},
            {hasLimit=false, isLimitOpen=false},
            {hasLimit=false, isLimitOpen=false},
        }
        for i,v in ipairs(tabsData) do
            local datas = self.tabDatasList[v.moneyType]
            if v.isLimit == 1 then
                datas.hasLimit = true
                datas.isLimitOpen = v.isOpen == 1
            end
            v.text = v.name
            table.insert(datas, v)
        end
        self:responseTabs()
    end,
    function()
        if self.menu and self.menu.IsRunning then
            self.menu:Close()
        end
    end)
end

local function shopItemSortComp(item1, item2)
    if item1.endTime ~= item2.endTime then
        if item1.endTime > 0 and item2.endTime > 0 then
            return item1.endTime < item2.endTime
        end
        if item1.endTime > 0 then return true end
        if item2.endTime > 0 then return false end
    end
    if item1.remainNum ~= item2.remainNum then
        if item1.remainNum > 0 and item2.remainNum < 0 then return true end
        if item2.remainNum > 0 and item1.remainNum < 0 then return false end
    end
    if item1.disCount ~= item2.disCount then
        if item1.disCount == -2 then return true end
        if item2.disCount == -2 then return false end
        if item1.disCount == -1 then return true end
        if item2.disCount == -1 then return false end
        if item1.disCount > 0 and item2.disCount > 0 then
            return item1.disCount < item2.disCount
        end
        if item1.disCount > 0 then return true end
        if item2.disCount > 0 then return false end
    end
    return item1.id < item2.id
end

function _M:requestItemList(data)
    ShopAPI.requestShopItemList(self.mainTabIdx, data.itemType,
        function(items, endTime)
            self.itemList = items or {}
   
            for i,v in ipairs(self.itemList) do
                v.detail = Item.GetItemDetailByCode(v.code)
                v.detail.bindType = v.bindType == 1 and 4 or v.bindType
            end
            local count = #self.itemList
            self.itemListNodes = {}
            self.itemShowIcons = {}
            self.itemNodes = {}
            self.sp_sort_deatil.Scrollable:Reset(1,count)
            clearItemListSelect(self)
            if count > 0 then
                if self.itemParam then
                    local index = 1
                    for i = 1,#self.itemList,1 do
                        if self.itemList[i].code == self.itemParam then
                            index = i
                            break
                        end 
                    end
                    local function setSelect(index,node)
                        if index == self.needSelectIndex then
                            self:SelectItem(node,self.itemList[index])
                            self.itemParam = nil
                            self.needSelectIndex = nil
                            return true
                        end
                        return false
                    end
                    if self.itemListNodes[index] then
                        self:SelectItem(self.itemListNodes[index],self.itemList[index])
                        self.itemParam = nil
                    else
                        self.needSelectIndex = index
                        self.needSelect = setSelect
                        self.sp_sort_deatil.Scrollable:LookAt(Vector2.New(0,self.cvs_sort_single.Height*(index-1)),true)    
                    end
                else
                    self:SelectItem(self.itemListNodes[1],self.itemList[1])
                end
                
            end
        end,
        function()
        end
    )
end

function _M:Open()
    self.menu.Visible = false
    self:request()
end

function _M:Close()
    self.menu.Visible = false
end

function _M.Create(parent,cvs)
    local self = {}
    setmetatable(self,_M)
    self.parent = parent
    InitComponent(self,cvs)
    return self
end

return _M

