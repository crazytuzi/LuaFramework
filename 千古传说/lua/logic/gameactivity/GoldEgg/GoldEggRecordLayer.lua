
local GoldEggRecordLayer = class("GoldEggRecordLayer", BaseLayer)

function GoldEggRecordLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zadan.ZaDanHistory")
end


function GoldEggRecordLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close          = TFDirector:getChildByPath(self, 'btn_close')
    self.btn_myRecord       = TFDirector:getChildByPath(self, 'tab1')
    self.btn_otherRecord    = TFDirector:getChildByPath(self, 'tab2')    
    self.btn_myRecord.logic         = self
    self.btn_otherRecord.logic      = self


    self.panel_cell1    = TFDirector:getChildByPath(self, 'panel_cell1')
    self.panel_cell2    = TFDirector:getChildByPath(self, 'panel_cell2')
    self.panel_cell3    = TFDirector:getChildByPath(self, 'panel_cell3')
    self.panel_list     = TFDirector:getChildByPath(self, 'panel_player')

    self.panel_celllist = {}
    self.panel_celllist[1] = self.panel_cell1
    self.panel_celllist[2] = self.panel_cell2
    self.panel_celllist[3] = self.panel_cell3

    for i=1,3 do
        if self.panel_celllist[i] then
            self.panel_celllist[i]:setVisible(false)
            self.panel_celllist[i].type = i
        end
    end
 
    self.typeButton = {}
    for i=1,2 do
        self.typeButton[i]       = TFDirector:getChildByPath(ui, 'tab'..i)
        self.typeButton[i].index = i
    end
    self.btnIndex = 1

    self.bFistDraw = true

    self.EggRecordList = GoldEggManager.EggRecordList[self.btnIndex]

    -- 对应按钮的索引
    self.curBtnIndex  = 0
    self:drawDefault(self.btnIndex)
end



function GoldEggRecordLayer:registerEvents()
    self.super.registerEvents(self)


    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)


    self.btn_myRecord:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTpye),1)
    self.btn_otherRecord:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTpye),1)



    self.receiveRecordResult = function(event)
        print(" EggRecordList = ", event.data)

        if self.curBtnIndex == 2 then
            if event.data[1].newcount < 1 then
                --toastMessage("没有更多的砸蛋历史了")
                toastMessage(localizable.goldEggRecord_history)
            end
        else
            if event.data[1].newcount < 1 and self.bFistDraw == false then
               -- toastMessage("没有更多的砸蛋历史了")
                toastMessage(localizable.goldEggRecord_history)

            end
        end
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(GoldEggManager.GET_RECORD_EGG_EVENT, self.receiveRecordResult)

end

function GoldEggRecordLayer:removeEvents()

    TFDirector:removeMEGlobalListener(GoldEggManager.GET_RECORD_EGG_EVENT, self.receiveRecordResult)
    self.receiveRecordResult = nil


    self.super.removeEvents(self)
end


function GoldEggRecordLayer:removeUI()
    self.super.removeUI(self)
end

function GoldEggRecordLayer:onShow()
    self.super.onShow(self)

    -- self:refreshUI()
end

function GoldEggRecordLayer:dispose()
    self.super.dispose(self)
end

function GoldEggRecordLayer:refreshUI()

    self:drawMyResultLayer()
end

function GoldEggRecordLayer.OnclikMyHistory(sender)
    local self = sender.logic

end

function GoldEggRecordLayer.OnclikOtherHistory(sender)
    local self = sender.logic

end


function GoldEggRecordLayer:drawDefault(index)
    if self.curBtnIndex == index then
        return
    end

    local btn = nil
    -- 绘制上面的按钮
    if self.btnLastIndex ~= nil then
        btn = self.typeButton[self.btnLastIndex]
        btn:setTextureNormal("ui_new/zadan/tab_"..self.btnLastIndex..".png")
    end

    self.btnLastIndex = index
    self.curBtnIndex  = index

    btn = self.typeButton[self.curBtnIndex]
    btn:setTextureNormal("ui_new/zadan/tab_"..self.btnLastIndex.."h.png")


    self:onClickDay(index)

end

function GoldEggRecordLayer:onClickDay(index)
    --local desc = {"个人历史", "玩家历史"}
    local desc = localizable.goldEggRecord_player_history
    print("点击了 ---- ", desc[index])
    self.bFistDraw = true

    self.EggRecordList:clear()
    local nowCount = self.EggRecordList:length()
    GoldEggManager:RequestGoldEggRecord(nowCount, 2, index)


end

function GoldEggRecordLayer.onClickTpye(sender)
    local self  = sender.logic
    local index = sender.index

    if self.curBtnIndex == index then
        local offsetPos = self.myResultTableView:getContentOffset()
        print("offsetPos = ", offsetPos)
        return
    end

    self.EggRecordList = GoldEggManager.EggRecordList[index]

    self:drawDefault(index)
end


function GoldEggRecordLayer:drawMyResultLayer()
    if self.myResultTableView ~= nil then
        local offsetSize1 = self.myResultTableView:getContentSize()
        print("offsetSize1 = ", offsetSize1)
        self.myResultTableView:reloadData()
        if self.bFistDraw == false then
            -- self.myResultTableView:setScrollToEnd(false)

            local offsetSize2 = self.myResultTableView:getContentSize()
            print("offsetSize2 = ", offsetSize2)
            if self.EggRecordList:length() > 1 then 
                self.myResultTableView:setContentOffset(ccp(0, offsetSize1.height - offsetSize2.height))
            end

        else
            self.myResultTableView:setScrollToBegin(false)
            self.bFistDraw = false
        end
        return
    end

    local  myResultTableView =  TFTableView:create()
    myResultTableView:setTableViewSize(self.panel_list:getContentSize())
    myResultTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    myResultTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    myResultTableView:setPosition(self.panel_list:getPosition())
    self.myResultTableView = myResultTableView
    self.myResultTableView.logic = self

    myResultTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    myResultTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    myResultTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    myResultTableView:reloadData()

    self.panel_list:getParent():addChild(self.myResultTableView,1)
    self.bFistDraw = false
end

function GoldEggRecordLayer.numberOfCellsInTableView(table)
    local self = table.logic

    return self.EggRecordList:length() + 1
end

function GoldEggRecordLayer.cellSizeForTable(table,idx)
    local self = table.logic
    local height , width =   137, 718
    local index = idx + 1

    local totalCount = self.EggRecordList:length()

    if index  == (totalCount + 1) then
        width  = 730
        height = 100

    else
        local rewardData = self.EggRecordList:objectAt(index)
        local countOfReward = #rewardData.rewardList

        if countOfReward > 5 then
            width  = 730
            height = 400
        else
            width  = 730
            height = 240
        end
    end

    return height , width
end

function GoldEggRecordLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        self:createCellNode(cell, 1)
        self:createCellNode(cell, 2)
        self:createCellNode(cell, 3)
    end

    cell.index = idx + 1

    self:drawResultNode(cell, idx + 1)
    return cell
end

function GoldEggRecordLayer:createCellNode(cell, index)
    local node = self.panel_celllist[index]:clone()

    node:setPosition(ccp(20-4, 0))
    cell:addChild(node)
    node:setTag(100 + index)
    node.logic = self
end

function GoldEggRecordLayer:drawResultNode(cell, index)

    for i=1,3 do
        local node = cell:getChildByTag(100 + i)
        -- if node then
            node:setVisible(false)
        -- end
    end

    -- print("index = ", index)
    local totalCount = self.EggRecordList:length()

    if index  == (totalCount + 1) then
        local node = cell:getChildByTag(100 + 3)
        node:setVisible(true)

        local btn_more = TFDirector:getChildByPath(node, 'btn_more')

        btn_more:addMEListener(TFWIDGET_CLICK, audioClickfun(
            function ( )
                self:loadMore()
            end
        ),1)

        if btn_more then
            if self.curBtnIndex == 1 then
                btn_more:setTextureNormal("ui_new/zadan/btn_ckgd.png")
            else
                btn_more:setTextureNormal("ui_new/zadan/btn_ckzx.png")
            end
        end
        return
    end

    local rewardData = self.EggRecordList:objectAt(index)

    -- required int32 playerId = 1;            //玩家ID
    -- required string playerName = 2;         //玩家名
    -- repeated GoldEggReward rewardList = 3;  //奖励资源
    -- required int64 createTime = 4;      //记录时间
    local countOfReward = #rewardData.rewardList

    print("countOfReward = ", countOfReward)
    local node = nil
    if countOfReward > 5 then
        node = cell:getChildByTag(100 + 2)
        node:setVisible(true)
    else
        node = cell:getChildByTag(100 + 1)
        node:setVisible(true)
    end

    local txt_time = TFDirector:getChildByPath(node, 'txt_time')
    local txt_name = TFDirector:getChildByPath(node, 'txt_name')
    local txt_date = TFDirector:getChildByPath(node, 'txt_date')
    local bg_icon  = TFDirector:getChildByPath(node, 'bg_icon')
    -- bg_icon:setVisible(false)
    txt_name:setText(rewardData.playerName)

    local timestamp = math.floor(rewardData.createTime/1000)

    local date   = os.date("*t", timestamp)

    local timeDesc = date.year.."-"..date.month.."-"..date.day

    local timeDesc = string.format("%s", timeDesc)

    txt_date:setText(timeDesc)

    local timeDesc2 = os.date("%X", timestamp)
    txt_time:setText(timeDesc2)

    -- print(".type = ", node.type)
    -- print("rewardData.playerName = ", rewardData.playerName)

    for i=200,211 do
        local x = node:getChildByTag(i)
        if x then
            x:removeFromParentAndCleanup(true)
        end
    end
    for i=1,countOfReward do
        self:ShowRoleIcon(node, i, rewardData.rewardList)
    end

    txt_name:setVisible(true)
    if self.curBtnIndex == 1 then
        txt_name:setVisible(false)
    end
end

function GoldEggRecordLayer:ShowRoleIcon(node, itemIndex, rewardList)

    self.itemIndex = itemIndex

    local Gapx = 70 + 10
    local Gapy = 90

    if rewardList and #rewardList > 5 then
        Gapy = 250
    end
    
    local posX = Gapx + math.mod(itemIndex-1,5) * 140
    local posY = Gapy
    if itemIndex > 5 then
        posY = 0-Gapy
    end

    if rewardList and #rewardList > 5 and itemIndex > 5 then
        posY = 100
    end

    local item = rewardList[itemIndex]
    local roleTypeId = item.resId
    local newCardRoleData = nil
    local path = nil
    if item.resType == EnumDropType.ROLE then
        newCardRoleData = RoleData:objectByID(roleTypeId)
        if newCardRoleData == nil then
            print('roleTypeId = ', roleTypeId)
        end
        path = newCardRoleData:getIconPath()
    else
        local data = {}
        data.type   = item.resType
        data.itemId = item.resId
        data.number = item.number

        newCardRoleData = BaseDataManager:getReward(data)
        path = newCardRoleData.path
    end

    -- print("newCardRoleData = ", newCardRoleData)

    if newCardRoleData ~= nil then
        local roleQualityImg = TFImage:create()
        roleQualityImg:setTexture(GetColorIconByQuality(newCardRoleData.quality))
        roleQualityImg:setPosition(ccp(posX, posY))
        roleQualityImg:setScale(1.0)
        roleQualityImg:setOpacity(255)
        roleQualityImg:setTag(200 + itemIndex)
        node:addChild(roleQualityImg,100)
    -- if 1 then
    --     -- local taskIconImage = TFImage:create("icon/task/1.png")
    --     -- if taskIconImage then
    --     --     taskIconImage:setPosition(ccp(60, 50))
    --     --     taskIconImage:setScale(0.8)
    --     --     node:addChild(taskIconImage,100)
    --     -- end
    --     print("GetColorIconByQuality(newCardRoleData.quality) = ", GetColorIconByQuality(newCardRoleData.quality))
    --     return
    -- end

        local roleIcon = TFImage:create()
        roleQualityImg:addChild(roleIcon)
        roleIcon:setTexture(path)
        roleIcon:setTouchEnabled(true)
        roleIcon:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            Public:ShowItemTipLayer(roleTypeId, item.resType)
        end))


        if item.resType == EnumDropType.GOODS then

            newCardRoleData = ItemData:objectByID(roleTypeId)
            
            newCardRoleData.itemid = newCardRoleData.id

            if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            elseif newCardRoleData.type == EnumGameItemType.Piece then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            else
                Public:addPieceImg(roleIcon,newCardRoleData,false)
            end

        end

        -- local txt_num = TFLabel:create()
        local txt_num = TFLabelBMFont:create()
        txt_num:setFntFile("font/num_212.fnt")

        txt_num:setAnchorPoint(ccp(1, 0))
        txt_num:setPosition(ccp(52, -60))
        txt_num:setText(item.number)
        -- txt_num:setFontSize(20)
        roleQualityImg:addChild(txt_num)
    end
end

function GoldEggRecordLayer:loadMore()
    local nowCount = self.EggRecordList:length()

    if self.curBtnIndex == 2 then
        self.EggRecordList:clear()
        self.bFistDraw = true
    end

    GoldEggManager:RequestGoldEggRecord(nowCount, 2, self.curBtnIndex)
end

return GoldEggRecordLayer