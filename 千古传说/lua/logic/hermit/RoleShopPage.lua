--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local RoleShopPage = class("RoleShopPage", BaseLayer)
local columnNumber = 4
function RoleShopPage:ctor(data)
    self.super.ctor(self,data)
    if data then
        self.type = data
    else
        self.type = RandomStoreType.Role
    end
    self.costType = EnumDropType.SYCEE
    self:init("lua.uiconfig_mango_new.shop.NormalShopPage")
end

function RoleShopPage:initUI(ui)
	self.super.initUI(self,ui)

    --根节点
	self.panel_content          = TFDirector:getChildByPath(ui, 'panel_content')

	--刷新按钮
	self.btn_refresh 		= TFDirector:getChildByPath(ui, 'btn_refresh')
    self.btn_refresh.logic  = self
    --刷新文字
    self.txt_refresh_time   = TFDirector:getChildByPath(ui, 'txt_refresh_time')

	--右侧tableView
    self.panel_list       = TFDirector:getChildByPath(ui, 'panel_list')

    self.img_title        = TFDirector:getChildByPath(ui, 'biaoti')
    --self.img_title:setTexture("")
    --构建tableView
	self:initTableView()
    self.mall_refresh_tip = CCUserDefault:sharedUserDefault():getBoolForKey("mall_refresh_tip");

end

function RoleShopPage:removeUI()
    self.super.removeUI(self)
end

function RoleShopPage:onclear()
end

function RoleShopPage:registerEvents()
    self.super.registerEvents(self)

    --按钮事件
    self.btn_refresh:addMEListener(TFWIDGET_CLICK, audioClickfun(self.refreshButtonClickHandle),1)

    --table view 事件
    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleShopPage.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleShopPage.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleShopPage.numberOfCellsInTableView)

    --单个随机商店刷新通知
    self.refreshSingleCallback = function (event)
        local data = event.data[1]
        if data.type ~= self.type then
            return
        end

        self:refreshCallback()
     end

     --所有随机商店刷新通知
     self.refreshAllCallback = function (event)
         local data = event.data[1]
         self:refreshCallback()
     end

     --购买成功通知
     self.buySuccessCallback = function (event)
         self:refreshCallback()
     end

    --逻辑事件
    TFDirector:addMEGlobalListener(MallManager.RefreshSingleRandomStore, self.refreshSingleCallback)
    TFDirector:addMEGlobalListener(MallManager.RefreshAllRandomStore, self.refreshAllCallback)
    TFDirector:addMEGlobalListener(MallManager.BuySuccessFromRandomStore, self.buySuccessCallback)

    self.tableView:reloadData()
    self:addTimer()
end

function RoleShopPage:removeEvents()
    --TableView事件
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end

    --按钮事件
    self.btn_refresh:removeMEListener(TFWIDGET_CLICK)

    --逻辑事件
    TFDirector:removeMEGlobalListener(MallManager.RefreshSingleRandomStore, self.refreshSingleCallback)
    TFDirector:removeMEGlobalListener(MallManager.RefreshAllRandomStore, self.refreshAllCallback)
    TFDirector:removeMEGlobalListener(MallManager.BuySuccessFromRandomStore, self.buySuccessCallback)
    
    self.super.removeEvents(self)
end

function RoleShopPage:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

--销毁方法
function RoleShopPage:dispose()
    self:disposeAllPanels()

    self.super.dispose(self)

    self.panel_content = nil
    self.btn_refresh = nil
    self.tableView = nil
    self.panel_list = nil
    self.txt_refresh_time = nil
    self.createNewHoldGoodsCallback = nil
    self.holdGoodsNumberChangedCallback = nil
    self.deleteHoldGoodsCallback = nil
end

--初始化TableView
function RoleShopPage:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    --tableView:setPosition(self.panel_list:getPosition())

    self.tableView = tableView
    self.tableView.logic = self

    self:updateTableSource()
    self.panel_list:addChild(tableView)
end

--刷新回调
function RoleShopPage:refreshCallback()
    --print("RoleShopPage:refreshCallback()")
    self:refreshUI()
end

--显示充值提示框
function RoleShopPage:showRechargeDialog()
    CommonManager:showOperateSureLayer(
        function()
            PayManager:showPayLayer()
        end,
        nil,
        {
            --msg = "您没有足够的元宝购买物品，是否进入充值界面？",
            msg = localizable.common_pay_tips_1,
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end

--刷新按钮点击事件处理方法
function RoleShopPage.refreshButtonClickHandle(sender)
    local self = sender.logic

    if MallManager:isEnoughRefrshTool(
            function()
                MallManager:requestRefreshRandomStoreByType(self.type)
            end
        , 1) == true then
        return
    end

    local enough = MainPlayer:isEnough(self.costType,self.store:getRefreshCost())
    if not enough then
        --self:showRechargeDialog()
        return
    end
    if self.mall_refresh_tip then
        MallManager:requestRefreshRandomStoreByType(self.type)
        return
    end
    CommonManager:showOperateSureTipLayer(
        function(data, widget)
            MallManager:requestRefreshRandomStoreByType(self.type)
            self:getHasTip(widget)
        end,
        function(data, widget)
            AlertManager:close()
            self:getHasTip(widget)
        end,
        {
            --title="扣费提示",
            --msg="您已经手动刷新过【" .. self.store:getManualRefreshCount() .. "】次，此次手动刷新需要消耗【" .. self.store:getRefreshCost() .. "】" .. GetResourceName(self.costType) .."，是否确认刷新？",
            title=localizable.common_pay_tips_2,
            msg=stringUtils.format(localizable.common_pay_tips_3,self.store:getManualRefreshCount(),self.store:getRefreshCost() ,GetResourceName(self.costType)),
            
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )

end

function RoleShopPage:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.mall_refresh_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("mall_refresh_tip",self.mall_refresh_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end

function RoleShopPage:addTimer()
    self.txt_refresh_time:setText(self.store:getAutoRefreshTimeAsString())
    self.onUpdated = function(event)
        self.txt_refresh_time:setText(self.store:getAutoRefreshTimeAsString())
    end

    if not self.nTimerId then
         self.nTimerId = TFDirector:addTimer(1000, -1, nil, self.onUpdated); 
    end
end

--销毁所有TableView的Cell中的Panel
function RoleShopPage:disposeAllPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if panel then
            panel:dispose()
        end
    end
end

--[[
    更新TableView显示的内容
]]
function RoleShopPage:updateTableSource()
    self.store = MallManager:getRandomStoreByType(self.type)
    if self.store == nil then
        print("找不到随机商店信息 : ",self.type)
    end

    self.itemlist = self.store:getCommodityList()
end

function RoleShopPage:refreshUI()
    self:refreshTableView()
end

function RoleShopPage:refreshTableView()
    self:updateTableSource()
    
    if self.tableView then
        --local currentOffset = self.tableView:getContentOffset()
        self.tableView:reloadData()
        --self.tableView:setContentOffset(currentOffset)
    end
end

function RoleShopPage.cellSizeForTable(table,idx)
    return 180,537
end

function RoleShopPage.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    local startOffset = 10
    local columnSpace = 10
    self.allPanels = self.allPanels or {}
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,columnNumber do
    	    local bagItem_panel = require('lua.logic.mall.ShopItemCell'):new()
	    	local size = bagItem_panel:getSize()
	    	local x = size.width*(i-1)
	    	if i > 1 then
	    	    x = x + (i-1)*columnSpace
	    	end
            x = x + startOffset
	    	bagItem_panel:setPosition(ccp(x,0))
	    	bagItem_panel:setLogic(self)
	    	cell:addChild(bagItem_panel)
			

            local img_title = TFImage:create()
            img_title:setTexture("ui_new/shop/img_tuijian.png")
            img_title:setAnchorPoint(ccp(0.5,0.5))
            img_title:setPosition(ccp(35,140))
            img_title:setZOrder(100)
            bagItem_panel:addChild(img_title)


            local img_chuzhan = TFImage:create()
            img_chuzhan:setTexture("ui_new/shop/img_chuzhan.png")
            img_chuzhan:setAnchorPoint(ccp(0.5,0.5))
            img_chuzhan:setPosition(ccp(100,140))
            img_chuzhan:setZOrder(100)
            bagItem_panel:addChild(img_chuzhan)

    	    cell.bagItem_panel = cell.bagItem_panel or {}
    	    cell.bagItem_panel[i] = bagItem_panel
            cell.bagItem_panel[i].img_title = img_title
            cell.bagItem_panel[i].img_chuzhan = img_chuzhan
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = bagItem_panel
    	end
        
    end
    for i=1,columnNumber do
        local _index = idx * columnNumber + i
        if _index <= #self.itemlist then
            local _item = self.itemlist[_index]
            cell.bagItem_panel[i]:setVisible(true)
            cell.bagItem_panel[i]:setData(_item)
            if _index >= 1 and _index <= 4 then
                -- cell.bagItem_panel[i].img_title:setTexture("ui_new/shop/img_tuijian.png")
                cell.bagItem_panel[i].img_title:setVisible(true)
            -- elseif  _index == 5 then
            --     cell.bagItem_panel[i].img_title:setVisible(true)
            else
                cell.bagItem_panel[i].img_title:setVisible(false)
            end
            cell.bagItem_panel[i].img_chuzhan:setVisible(self:isRoleUseByItem(_item:getShopEntry().goods_id))

        else
            cell.bagItem_panel[i]:setVisible(false)
        end
    end

    return cell
end

function RoleShopPage:isRoleUseByItem( itemId )
    print("itemId == ",itemId)
    local item = ItemData:objectByID(itemId)
    if item == nil then
        print("道具表没有此道具 id== ",itemId)
        return false
    end
    local role = RoleData:objectByID(item.usable)
    if role == nil and itemId ~= 2000  then
        print("无法找到该角色  id =="..itemId)
        return false
    end
    if itemId == 2000 then
        role = RoleData:objectByID(MainPlayer:getProfession())
    end
    local roleInfo = CardRoleManager:getRoleById(role.id)
    if roleInfo and roleInfo.pos ~= nil and roleInfo.pos ~= 0 then
        return true
    end
    return false
end

function RoleShopPage.numberOfCellsInTableView(table)
    local self = table.logic
    local num = math.ceil(#self.itemlist/columnNumber)
    return num
end

--table cell 被选中时在对应的Cell中触发此回调函数
function RoleShopPage:tableCellClick(cell)

end

function RoleShopPage:setType(type)
    self.type = type
    self:refreshTableView()
end

function RoleShopPage:setCostType(costType)
    self.costType = costType
end

--[[
设置刷新按钮是否点击
]]
function RoleShopPage:setRefreshButtonEnabled(enabled)
    self.btn_refresh:setTouchEnabled(enabled)
    self.btn_refresh:setGrayEnabled(not enabled)
end

--[[
设置刷新按钮是否可见
]]
function RoleShopPage:setRefreshButtonVisiable(visiable)
    self.btn_refresh:setVisible(visiable)
end

return RoleShopPage
