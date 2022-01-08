
local OpenChoiceBox = class("OpenChoiceBox", BaseLayer);

CREATE_SCENE_FUN(OpenChoiceBox);
CREATE_PANEL_FUN(OpenChoiceBox);

OpenChoiceBox.LIST_ITEM_HEIGHT = 90; 

function OpenChoiceBox:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.bag.BagGiftChoose");
end

function OpenChoiceBox:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close  = TFDirector:getChildByPath(self, 'btn_close');
    self.btn_get    = TFDirector:getChildByPath(self, 'btn_get');
    self.layer_list = TFDirector:getChildByPath(self, 'Panel_Gift');
    self.choiceList = {}
    self.nodeList = {}
    self.cellNode = createUIByLuaNew("lua.uiconfig_mango_new.bag.BagGiftChooseCell");
    self.cellNode:retain()
end

function OpenChoiceBox:setData(itemid)
    self.id = itemid
    local giftPackData = GiftPackData:objectByID(itemid)

    self.choiceNum = giftPackData.select_count
    self.giftGoodsList = split(giftPackData.goods, "|")
    print("---self.giftGoodsList----",self.giftGoodsList)
    self:drawBoxItemList()
    if #self.giftGoodsList > 8 then
        self.tableView:setTouchEnabled(true)
    else
        self.tableView:setTouchEnabled(false)
    end
end

function OpenChoiceBox:onShow()
    self.super.onShow(self)
end


function OpenChoiceBox:removeUI()
    self.super.removeUI(self);
    if self.cellNode then
        self.cellNode:release()
        self.cellNode = nil
    end   
end


--注册事件
function OpenChoiceBox:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close);

    self.btn_get.logic = self
    self.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.getBtnClickHandle))
end


function OpenChoiceBox:drawBoxItemList()
    if self.tableView ~= nil then
        self.tableView:reloadData()
        -- self.tableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, OpenChoiceBox.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, OpenChoiceBox.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, OpenChoiceBox.numberOfCellsInOpenChoiceBox)
    tableView:reloadData()

    self.layer_list:addChild(self.tableView,1)
end

function OpenChoiceBox.cellSizeForTable(table, idx)
    return 175,660
end

function OpenChoiceBox.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        
        for i=1,4 do
            local node = self.cellNode:clone()
            node:setPosition(ccp(((i-1)*150+30), -5))
            cell:addChild(node);
            cell.nodeList = cell.nodeList or {}
            local btn_node      =  TFDirector:getChildByPath(node, 'btn_node')
            cell.nodeList[i] = btn_node
            self.nodeList[#self.nodeList+1] = btn_node
            btn_node.logic = self
            btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btn_nodeClickHandle),1)
        end

    end
    self:drawNode(cell,idx)
    return cell
end

function OpenChoiceBox.numberOfCellsInOpenChoiceBox(table)
    local self = table.logic
    return math.ceil(#self.giftGoodsList / 4)
  
end

function OpenChoiceBox:drawNode(node,index)
    for i =1, 4 do
        self:drawGift(node.nodeList[i], 4*index+i)
    end
end


function OpenChoiceBox:removeEvents()

end

function OpenChoiceBox:isChoice( index )
    for k,v in pairs(self.choiceList) do
        if v == index then
            return true
        end
    end
    return false
end

function OpenChoiceBox:getChoiceIndex( index )
    for k,v in pairs(self.choiceList) do
        if v == index then
            return k
        end
    end
    return 0
end

function OpenChoiceBox:drawGift(node, index)
    -- local btn_node      =  TFDirector:getChildByPath(node, 'btn_node')
    local btn_icon      =  TFDirector:getChildByPath(node, 'btn_icon')
    local img_icon      =  TFDirector:getChildByPath(node, 'img_icon')
    local txt_number    =  TFDirector:getChildByPath(node, 'txt_number')
    local txt_name      =  TFDirector:getChildByPath(node, 'txt_name')
    local img_xuanzhong =  TFDirector:getChildByPath(node, 'img_xuanzhong')
    
    if index > #self.giftGoodsList then
        node:setVisible(false)
        return
    end
    node:setVisible(true)
    if self:isChoice(index) then
        img_xuanzhong:setVisible(true)
    else
        img_xuanzhong:setVisible(false)
    end


    local giftData    = self.giftGoodsList[index]
    local giftDataInfo  = split(giftData, "_")
    local itemType    = tonumber(giftDataInfo[1])
    local itemId_     = tonumber(giftDataInfo[2])
    local itemNum     = tonumber(giftDataInfo[3])
    local item = {type = itemType, number = itemNum, itemId = itemId_}
    local reward = BaseDataManager:getReward(item)
    

    txt_number:setText(reward.number)
    txt_name:setText(reward.name)
    img_icon:setTexture(reward.path)
    btn_icon:setTextureNormal(GetColorIconByQuality(reward.quality))
    if itemType == EnumDropType.GOODS then
        local itemInfo = ItemData:objectByID(itemId_)
        if itemInfo.type == EnumGameItemType.Soul or itemInfo.type == EnumGameItemType.Piece then
            Public:addPieceImg(img_icon,reward,true)
        end
    end
    node.choiceId = index
end

function OpenChoiceBox.btn_nodeClickHandle(sender)
    local self = sender.logic
    local btn_node = sender
    local choiceId = sender.choiceId
    if self:isChoice(choiceId) then
        self:unChoiceBtn(sender)
        return
    end
    if #self.choiceList >= self.choiceNum then
        self:unChoiceFirstBtn()
    end
    self:choiceBtn(sender)
end


function OpenChoiceBox:choiceBtn(btn)
    self.choiceList[#self.choiceList+1] = btn.choiceId
    local img_xuanzhong =  TFDirector:getChildByPath(btn, 'img_xuanzhong')
    img_xuanzhong:setVisible(true)
end
function OpenChoiceBox:unChoiceBtn(btn)
    local pos = self:getChoiceIndex(btn.choiceId)
    table.remove(self.choiceList,pos)
    local img_xuanzhong =  TFDirector:getChildByPath(btn, 'img_xuanzhong')
    img_xuanzhong:setVisible(false)
end
function OpenChoiceBox:unChoiceFirstBtn()
    local index = self.choiceList[1]
    for i=1,#self.nodeList do
        local node = self.nodeList[i]
        if node.choiceId == index then
            local img_xuanzhong =  TFDirector:getChildByPath(node, 'img_xuanzhong')
            img_xuanzhong:setVisible(false)
            table.remove(self.choiceList,1)
            return
        end
    end
end

function OpenChoiceBox.getBtnClickHandle(sender)
    local self = sender.logic
    local choiceId = {}

    print("=============getBtnClickHandle===========")
    if self.choiceList ~= nil  and #self.choiceList > 0 then
      print("=============getBtnClickHandle--1111111111111===========")
        BagManager:goChoice(self.id, self.choiceList)
        AlertManager:close()
    else
        toastMessage(localizable.common_please_check_one)
    end
end

  
return OpenChoiceBox;


