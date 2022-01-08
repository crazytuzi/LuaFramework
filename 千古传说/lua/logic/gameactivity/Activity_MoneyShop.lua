local Activity_MoneyShop = class("Activity_MoneyShop", BaseLayer)

--local desc = {"红铜通宝", "银制通宝", "金制通宝"}
local desc = localizable.activity_moneyshop_desc

function Activity_MoneyShop:ctor(type)
    self.super.ctor(self)
    self.id   = type
    self.type =OperationActivitiesManager.Type_Exchange
    self:init("lua.uiconfig_mango_new.operatingactivities.moneyShop")
end

function Activity_MoneyShop:initUI(ui)
    self.super.initUI(self,ui)
    self.img_award 				= TFDirector:getChildByPath(ui, 'img_award')

    self.panel_list 			= TFDirector:getChildByPath(ui, 'panel_list')
    self.txt_time               = TFDirector:getChildByPath(ui, 'txt_time')
    self.txt_content            = TFDirector:getChildByPath(ui, 'txt_content')

    self.txt_cost               = TFDirector:getChildByPath(ui, 'txt_cost')
    self.txt_weirubang          = TFDirector:getChildByPath(ui, 'txt_weirubang')

    self.btn_buy             = TFDirector:getChildByPath(ui, 'btn_buy')

    self.typeButton = {}
    for i=1,3 do
        self.typeButton[i]          = TFDirector:getChildByPath(ui, 'btn_type'..i)
        self.typeButton[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikShopType),1)
        self.typeButton[i].logic    = self
        self.typeButton[i].shopType = i
    end

    -- self.btnIndex = 1
    -- self.shopType = 1

    -- 对应按钮的索引
    self.curBtnIndex  = 0

    self.activity       = OperationActivitiesManager:getActivityInfo(self.id)
    self.shopType       = self.activity.shopType
    self.activityData   = self.activity.AllMoneyShopData
    
    print("------------- self.shopType = ", self.shopType)
    self.btnIndex = self.shopType
    if self.btnIndex == 0 then
        self.btnIndex = 1
    end

    self:drawDefault(self.btnIndex)
    self:drawShopTypeBtn()
end



function Activity_MoneyShop:removeUI()
    self.super.removeUI(self)
end

function Activity_MoneyShop:onShow()
    self.super.onShow(self)

    self:refreshUI()
end

function Activity_MoneyShop:dispose()
    self.super.dispose(self)
end

function Activity_MoneyShop:refreshUI()
    local activity =  self.activity
    print("self.btnIndex = ", self.btnIndex)
    self.activityData = activity.AllMoneyShopData
    self.rewardList = activity.AllMoneyShopData[self.btnIndex].rewardData
    self.cost       = activity.AllMoneyShopData[self.btnIndex].shopCost

    self.txt_cost:setText(self.cost)

    self:drawRewardList()

    if not activity then
        self.txt_time:setText("")
        self.txt_content:setText("")

    else
        -- os.date("%x", os.time()) <== 返回自定义格式化时间字符串（完整的格式化参数），这里是"11/28/08"
        local startTime = ""
        local endTime   = ""

        -- 0、活动强制无效，不显示该活动；1、长期显示该活动 2、自动检测，过期则不显示',
        local status = activity.status or 1

        if status == 1 then
            --self.txt_time:setText("永久有效")
            self.txt_time:setText(localizable.common_time_longlong)
        else
            if activity.startTime then
                startTime = self:getDateString(activity.startTime)
            end
            if activity.endTime then
                endTime   = self:getDateString(activity.endTime)
            end

            self.txt_time:setText(startTime .. " - " .. endTime)
        end

        self.txt_content:setText(activity.details)
    end

    if self.shopType == 0 then
        self.btn_buy:setTouchEnabled(true)
        self.btn_buy:setGrayEnabled(false)
    else
        self.btn_buy:setTouchEnabled(false)
        self.btn_buy:setGrayEnabled(true)
    end

end


function Activity_MoneyShop:setLogic(logic)
    self.logic = logic
end

function Activity_MoneyShop:registerEvents()
    print("Activity_MoneyShop:registerEvents()------------------")
    self.super.registerEvents(self)

    self.updateRewardCallback = function(event)
        -- local activity = OperationActivitiesManager:getActivityInfo(self.id)
        self.shopType = self.activity.shopType
        self:buyMoneyShopCallBack()
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)

    self.getRewardCallback = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD,self.getRewardCallback)

    self.btn_buy.logic = self
    self.btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.OnclikBuyMoneyShop),1)
end

function Activity_MoneyShop:removeEvents()
    print("Activity_MoneyShop:removeEvents()------------------")
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_PROGRESS_UPDATE,self.updateRewardCallback)
    self.updateRewardCallback = nil


    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_GET_REWARD,self.getRewardCallback)
    self.getRewardCallback = nil
end

function Activity_MoneyShop:getDateString(timestamp)

    if not timestamp then
        return
    end

    local date   = os.date("*t", timestamp)

    --return date.month.."月"..date.day.."日"..date.hour.."时"..date.min.."分"

    return stringUtils.format(localizable.common_time_4, date.month,date.day,date.hour,date.min)

end

function Activity_MoneyShop:drawRewardList()

    self:resortRewardList()
    -- self.txt_cost:setText(cost)
    if self.cost < MainPlayer:getSycee() then
        self.txt_cost:setColor(ccc3(0,0,0))
    else
        self.txt_cost:setColor(ccc3(255,0,0))
    end

    if self.fateTableView ~= nil then
        self.fateTableView:reloadData()
        self.fateTableView:setVisible(true)
        return
    end

    local  fateTableView =  TFTableView:create()
    fateTableView:setTableViewSize(self.panel_list:getContentSize())
    fateTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    fateTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    fateTableView:setPosition(self.panel_list:getPosition())
    self.fateTableView = fateTableView
    self.fateTableView.logic = self

    fateTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    fateTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    fateTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    fateTableView:reloadData()

    self.panel_list:getParent():addChild(self.fateTableView,1)
end

function Activity_MoneyShop.numberOfCellsInTableView(table)
    local self = table.logic

    return self.rewardList:length()
end

function Activity_MoneyShop.cellSizeForTable(table,idx)
    return 131, 553
end

function Activity_MoneyShop.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.operatingactivities.RewardItem004")

        node:setPosition(ccp(10, 130))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawCell(node)
    node:setVisible(true)
    return cell
end

function Activity_MoneyShop:drawCell(node)
    local itemList = {}
    for i=1,3 do
        itemList[i] = {}
        itemList[i].bg             = TFDirector:getChildByPath(node, 'img_bg_' .. i)
        itemList[i].icon           = TFDirector:getChildByPath(node, 'img_icon_' .. i)
        itemList[i].number         = TFDirector:getChildByPath(node, 'txt_number_' .. i)
    end

    local txt_title  =  TFDirector:getChildByPath(node, 'txt_title')
    local img_ylq    =  TFDirector:getChildByPath(node, 'img_ylq')
    local btn_get    =  TFDirector:getChildByPath(node, 'btn_get')

    local index = node.index
    -- if self.shopType ~= 

    local rewardInfo   = self.rewardList:objectAt(index)
    local rewardItems = rewardInfo.reward
    local rewardid    = rewardInfo.id
    local itemCount   = rewardItems:length()
    local btnStatus   = self:getItemCellStatus(index) -- 0 已领 1 不可领 2 可领

    txt_title:setText(rewardid)

    img_ylq:setVisible(false)
    btn_get:setVisible(false)    
    btn_get:setTouchEnabled(true)
    btn_get:setGrayEnabled(false)

    -- 已经购买了其中一种
    if self.shopType ~= 0 then
        -- 已领
        if btnStatus == 0 then
            img_ylq:setVisible(true)
            btn_get:setVisible(false)

            -- 1 不可领
        elseif btnStatus == 1 then
            img_ylq:setVisible(false)
            btn_get:setVisible(true)
            btn_get:setTouchEnabled(false)
            btn_get:setGrayEnabled(true)

        else
            img_ylq:setVisible(false)
            btn_get:setVisible(true)
        end
    end
    btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(
        function ()
            OperationActivitiesManager:sendMsgToGetActivityReward(self.id, rewardid)
        end
    ),1)


    for i=1,3 do
        if i <= itemCount then
            itemList[i].bg:setVisible(true)
            local item = rewardItems:objectAt(i)
            local info = BaseDataManager:getReward(item)
            if item.res_type == EnumDropType.GOODS then
                local goodsData = ItemData:objectByID(item.res_id)
                itemList[i].bg:setTexture(GetBackgroundForGoods(goodsData))
            else
                itemList[i].bg:setTexture(GetColorIconByQuality(info.quality))
            end
            
            itemList[i].icon:setTexture(info.path)
    
            if item.number > 1 then
                itemList[i].number:setVisible(true)
                itemList[i].number:setText("X" .. item.number)
            else
                itemList[i].number:setVisible(false)
            end


            if item.type == EnumDropType.GOODS then
                local rewardItem = {itemid = item.itemid}

                local itemData   = ItemData:objectByID(item.itemid)

                if itemData.type == EnumGameItemType.Piece or itemData.type == EnumGameItemType.Soul then
                    Public:addPieceImg(itemList[i].icon,rewardItem,true)
                else
                    Public:addPieceImg(itemList[i].icon,rewardItem,false)
                end
                -- adad  = dadaadad + 1
            end

            itemList[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(function ()
                Public:ShowItemTipLayer(item.itemid, item.type);
                -- body
            end))
        else
            itemList[i].bg:setVisible(false)
        end
    end
end


function Activity_MoneyShop:drawDefault(index)
    if self.curBtnIndex == index then
        return
    end

    local btn = nil
    -- 绘制上面的按钮
    if self.btnLastIndex ~= nil then
        btn = self.typeButton[self.btnLastIndex]
        btn:setTextureNormal("ui_new/operatingactivities/btnshop"..self.btnLastIndex..".png")
    end

    self.btnLastIndex = index
    self.curBtnIndex  = index

    self.btnIndex = index

    print("index = ", index)
    btn = self.typeButton[self.curBtnIndex]
    btn:setTextureNormal("ui_new/operatingactivities/btnshop"..self.btnLastIndex.."h.png")

    -- self.shopType = index

    local activity = OperationActivitiesManager:getActivityInfo(self.id)
    local activity  = self.activityData
    self.rewardList = activity[index].rewardData
    self.cost       = activity[index].shopCost

    self.txt_cost:setText(self.cost)
    self:drawRewardList()
end



function Activity_MoneyShop.OnclikShopType(sender)
    local self  = sender.logic
    local index = sender.shopType

    if self.shopType ~= 0 then
        -- toastMessage("你已经购买了")
        return
    end

    if self.curBtnIndex == index then
        return
    end

    self:drawDefault(index)
end

function Activity_MoneyShop.OnclikBuyMoneyShop(sender)
    local self  = sender.logic
    local shopType  = self.curBtnIndex

    -- self.
    -- print("Activity_MoneyShop.OnclikBuyMoneyShop = ", shopType)
    self.CurShopType = 0

    --local msg =  "是否消耗".. self.cost.. "元宝购买" .. desc[shopType] .. "？\n\n(活动期间只能购买一种通宝)";
    local msg =  stringUtils.format(localizable.activity_moneyshop_buy_tips, self.cost,desc[shopType]);
        CommonManager:showOperateSureLayer(
                function()
                    if MainPlayer:isEnoughSycee(self.cost , true) then
                        showLoading()
                        OperationActivitiesManager:sendMsgToBuyMoneyShop(self.id, shopType)
                    end
                end,
                nil,
                {
                    msg = msg,
                }
        )

    -- if MainPlayer:isEnoughSycee(self.cost , true) then
    --     showLoading()
    --     OperationActivitiesManager:sendMsgToBuyMoneyShop(self.id, shopType)
    -- end

end

function Activity_MoneyShop:buyMoneyShopCallBack()
    print("buyMoneyShopCallBack self.CurShopType = ", self.CurShopType)

    -- 购买成功
    if self.CurShopType ~= nil and self.shopType ~= self.CurShopType then
        
        self.CurShopType = self.shopType
        hideLoading()
        --toastMessage("购买"..desc[self.shopType].."成功")
        toastMessage(stringUtils.format(localizable.activity_moneyshop_buy_suc,desc[self.shopType]))
        self.shopType = self.activity.shopType
        self.btnIndex = self.shopType
        self:drawDefault(self.btnIndex)
        self:drawShopTypeBtn()
        return
    end 

    self.shopType = self.activity.shopType
    self.btnIndex = self.shopType
    if self.btnIndex == 0 then
        self.btnIndex = 1
    end
    self:drawDefault(self.btnIndex)
    self:drawShopTypeBtn()
end

-- 0 已领 1 不可领 2 可领
function Activity_MoneyShop:getItemCellStatus(index)
    local value         = self.activity.value
    local rewardInfo    = self.rewardList:objectAt(index)
    local status        = rewardInfo.status
    local targetid      = rewardInfo.id

    if targetid <= value and status > 0 then
        return 2

    elseif targetid <= value and status == 0 then
        return 0

    else
        return 1
    end
end


function Activity_MoneyShop:isStatusComplete( reward )
    local value         = self.activity.value
    local status        = reward.status
    local targetid      = reward.id
    -- print("value = ", value)
    -- print("status = ", status)
    -- print("targetid = ", targetid)
    -- print("reward = ", reward)

    if targetid <= value and status > 0 then
        return 2

    elseif targetid <= value and status == 0 then
        return 0

    else
        return 1
    end
end

function Activity_MoneyShop:resortRewardList()
    -- for v in self.rewardList:iterator() do
    --     print("resortRewardList id = ", v.id)
    --     print("resortRewardList status = ", v.status)

    --     print("-----------------")
    -- end

    local function cmpFun(reward1, reward2)
        local status1 = self:isStatusComplete(reward1)
        local status2 = self:isStatusComplete(reward2)
        if status1 > status2  then
            return true
        elseif status1 == status2 then
            if reward1.id <= reward2.id  then
                return true
            end
        end


        return false
    end

    self.rewardList:sort(cmpFun)
end

function Activity_MoneyShop:drawShopTypeBtn()
    if 0 == self.shopType then
        for i=1,3 do
            self.typeButton[i]:setTouchEnabled(true)
            self.typeButton[i]:setGrayEnabled(false)
        end
    else
        for i=1,3 do
            self.typeButton[i]:setTouchEnabled(false)

            
            if i == self.shopType then
                self.typeButton[i]:setGrayEnabled(false)
            else
                self.typeButton[i]:setGrayEnabled(true)
            end
        end
    end
end


return Activity_MoneyShop