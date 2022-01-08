--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local ItemDetails = class("ItemDetails", BaseLayer)

function ItemDetails:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.bag.ItemDetails")
end

function ItemDetails:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root          = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details       = TFDirector:getChildByPath(ui, 'panel_details')
    self.panel_elements      = TFDirector:getChildByPath(ui, 'panel_elements')

	--左侧详情
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_Name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')
    self.lbl_tips           = TFDirector:getChildByPath(ui, 'lbl_tips')

	--招募按钮
	self.btn_use 		= TFDirector:getChildByPath(ui, 'btn_use')
    self.btn_use.logic  = self

    --书属性
    self.panel_book = TFDirector:getChildByPath(ui, 'panel_book')
    -- 属性描述
    self.node_AttributeList     = {}
    self.txt_AttributeNameList  = {}
    self.txt_AttributeValueList = {}
    for i=1,5 do
        self.node_AttributeList[i]          =  TFDirector:getChildByPath(self.panel_book, "panel_att" .. i)
        self.txt_AttributeNameList[i]       =  TFDirector:getChildByPath(self.node_AttributeList[i],"name")
        self.txt_AttributeValueList[i]      =  TFDirector:getChildByPath(self.node_AttributeList[i],"value")

        self.node_AttributeList[i]:setVisible(false)
    end


    self:initTableView()
end

--初始化TableView
function ItemDetails:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_elements:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView = tableView
    self.tableView.logic = self
    self.panel_elements:addChild(tableView)
end

--[[
    更新TableView显示的内容
]]
function ItemDetails:updateTableSource()
    local gift_pack = GiftPackData:objectByID(self.id)
    if gift_pack == nil then
        print("礼包表无此礼包 id== ",self.id)
        self.itemlist = nil
        return
    end
    
    self.itemlist = gift_pack:getGiftList()
end

function ItemDetails:refreshTableView()
    self:updateTableSource()
    if self.itemlist == nil or self.itemlist:length() < 1 then
        self.tableView:setVisible(false)
    else
        self.tableView:setVisible(true)
    end
    self.tableView:reloadData()
end

function ItemDetails.cellSizeForTable(table,idx)
    return 55,50
end

function ItemDetails.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    local column = 0
    if self.itemlist then
        column = self.itemlist:length()
    end

    if column < 5 then
        column = 5
    end

    if nil == cell then
        cell = TFTableViewCell:create()
        local bagItem_panel = require('lua.logic.bag.GiftCell'):new()
        cell.panel = bagItem_panel
        cell:addChild(bagItem_panel)
    end
    cell.panel:setData(self.itemlist:objectAt(idx + 1))
    return cell
end

function ItemDetails.numberOfCellsInTableView(table)
    local self = table.logic
    if not self.itemlist then
        return 0
    end
    return self.itemlist:length()
end

function ItemDetails:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

function ItemDetails:removeUI()
	self.super.removeUI(self)

	self.panel_root = nil
	self.btn_icon = nil
	self.img_icon = nil
	self.txt_Num = nil
	self.txt_Name = nil
	self.img_quality = nil
	self.txt_description = nil
	self.btn_use = nil
    self.panel_details = nil
    self.panel_elements = nil
    self.lbl_tips = nil
end

function ItemDetails:refreshUI()
    if not self.id then
        return
    end

    local data = BagManager:getItemById(self.id)
    if not data then
        return
    end
    self.txt_Name:setText(data.name)
    self.img_icon:setTexture(data:GetTextrue())
    self.btn_icon:setTextureNormal(GetColorIconByQuality(data.quality))
    self.txt_Num:setText(data.num)
    self.txt_description:setText(data.itemdata.details)

    if data.itemdata.usable == 0 then
        self.type = 0
    else
        self.type = 1
    end

    if data.itemdata.type == EnumGameItemType.Box then
        self.tableView:setVisible(true)
        self:refreshTableView()
    else
        self.tableView:setVisible(false)
    end

    if data.itemdata.type == EnumGameItemType.Box or (data.itemdata.type == EnumGameItemType.Item and data.itemdata.kind ~= 47) or data.itemdata.type == EnumGameItemType.RandomPack then
        self.btn_use:setVisible(true)
        self.lbl_tips:setVisible(true)
    elseif data.itemdata.type == EnumGameItemType.HeadPicFrame then
        if HeadPicFrameManager:isEnough(data.itemdata.usable) == true then
            self.btn_use:setVisible(true)
            self.lbl_tips:setVisible(true)
        else
            self.btn_use:setVisible(false)
            self.lbl_tips:setVisible(false)
        end
    else
        self.btn_use:setVisible(false)
        self.lbl_tips:setVisible(false)
    end

    -- 去掉长安
    self.lbl_tips:setVisible(false)


    self.panel_book:setVisible(false)
    if data.type == EnumGameItemType.Book then
        self.panel_book:setVisible(true)

        for i=1,5 do
            self.node_AttributeList[i]:setVisible(false)
        end

        local bookInfo     = MartialData:objectByID(data.id)
        local Attribute = bookInfo:getAttributeTable()
        local count = 0
        for i=1,EnumAttributeType.Max do

            if Attribute[i] then
                count = count + 1
                
                local attName  = AttributeTypeStr[i]
                local attValue = Attribute[i]

                self.txt_AttributeNameList[count]:setText(attName.."  +"..attValue)
                self.txt_AttributeValueList[count]:setVisible(false)

                self.node_AttributeList[count]:setVisible(true)
            end
        end
    end

end

--设置物品数据
function ItemDetails:setData(data)
	if data == nil  then
        self.panel_details:setVisible(false)
		return false
	end

    self.toolNum = data.num

    self.panel_details:setVisible(true)
    -- print(" ItemDetails data.id : ",data.id)
	self.id = data.id
	self:refreshUI()
end

--使用按钮点击事件处理方法
function ItemDetails.useButtonClickHandle(sender)
    local self = sender.logic
    -- if self.id == 50000 then
    --     BagManager:useItem(self.id)-----------------------------------------
    -- end
    self:requestUse()
end

function ItemDetails:registerEvents()
    self.super.registerEvents(self)

    --按钮事件
    self.btn_use:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useButtonClickHandle),1)

    -- 增加长按住事件
    self.btn_use:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle)
    self.btn_use:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle)
    self.btn_use:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ItemDetails.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ItemDetails.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ItemDetails.numberOfCellsInTableView)
end

--销毁方法
function ItemDetails:dispose()
    self.super.dispose(self)
end

function ItemDetails:removeEvents()
    self.btn_use:removeMEListener(TFWIDGET_CLICK)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.super.removeEvents(self)
end

--------------------------------网络相关处理---------------------------------------
--请求服务器打开礼包
function ItemDetails:requestUse()
    -- -- 小喇叭
    -- if 30002 == self.id then
    --     AlertManager:close()
    --     ChatManager:showChatLayer()

    -- -- 精炼石
    -- elseif 30021 == self.id then
    --     AlertManager:close()
    --     EquipmentManager:OpenSmithyMainLaye()

    -- -- 招财神符
    -- elseif 30003 == self.id then
    --     self:showExchange(self.id)

    -- -- 真气丹
    -- -- 初级
    -- elseif 30022 == self.id then
    --     self:showExchange(self.id)

    -- -- 中级
    -- elseif 30023 == self.id then
    --     self:showExchange(self.id)

    -- -- 高级
    -- elseif 30024 == self.id then
    --     self:showExchange(self.id)

    -- else
    --     -- showLoading()
    BagManager:useItem(self.id)
    -- end
end


function ItemDetails.IconBtnTouchBeganHandle(sender)

    local self = sender.logic

    local ItemId = self.id
    if 30022 == ItemId or 30023 == ItemId or 30024 == ItemId or 30003 == ItemId then
        return
    end
    
        
    -- 20150526 暂时取消长安
    if 1 then
        return
    end

    if self.type == 1 then
        local times = 1;
        local function onLongTouch()
            if self.toolNum <= 0 then
                return;
            end

            self.isAdd = true;

            self.useButtonClickHandle(sender)

            TFDirector:removeTimer(self.longAddTouchTimerId);

            self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch);

            times = times + 1;
        end
        self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch); 
    end
end

function ItemDetails.IconBtnTouchMovedHandle(sender, pos, seekPos)
    local self = sender.logic
    local rect = sender:boundingBox()
    local size = rect.size
    local point = rect.origin
    local anPos = sender:getAnchorPoint()
    point = self:getParent():convertToWorldSpace(point)

    local minx = point.x 
    local maxx = point.x + size.width
    local miny = point.y
    local maxy = point.y + size.height
    if pos.x < minx or pos.x > maxx or pos.y < miny or pos.y > maxy then
        if self.longAddTouchTimerId then
            TFDirector:removeTimer(self.longAddTouchTimerId);
            self.longAddTouchTimerId = nil;
        end
    end

end

function ItemDetails.IconBtnTouchEndedHandle(sender)
    local self = sender.logic;
    if self.longAddTouchTimerId then
        TFDirector:removeTimer(self.longAddTouchTimerId);
        self.longAddTouchTimerId = nil;
    end

    if self.isAdd then
        self.useButtonClickHandle(sender)
    end

    self.isAdd = false;
end

-- 物品从被使用完
function ItemDetails:endLongPressUseGoods()
    if self.longAddTouchTimerId then
        TFDirector:removeTimer(self.longAddTouchTimerId);
        self.longAddTouchTimerId = nil;
    end
end

function ItemDetails:showExchange(ItemId)

    -- 招财神符
    if 30003 == ItemId then
        local item = ItemData:objectByID( ItemId );
        local num = BagManager:getItemNumById( ItemId );
        if num > 0 then
            local layer = CommonManager:showOperateSureLayer(
                    function()
                        BagManager:useBatchItem( item.id,num )
                    end,
                    nil,
                    {
                    uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                    title = item.name .. stringUtils.format(localizable.bagPropDetailsLayer_number,num),
                    msg = stringUtils.format(localizable.bagPropDetailsLayer_exchange ,item.usable * num)

                    }
            )
            local img1 = TFDirector:getChildByPath(layer, 'img1');
            local img2 = TFDirector:getChildByPath(layer, 'img2');
  
            img1:setTexture(item:GetPath());
            img2:setTexture(GetResourceIconForGeneralHead(HeadResType.COIN))
            return;
        end
        
    -- 真气丹
    -- 初级 -- 中级 -- 高级
    elseif 30022 == ItemId or 30023 == ItemId or 30024 == ItemId then

        local item = ItemData:objectByID( ItemId );
        local num = BagManager:getItemNumById( ItemId );
        if num > 0 then
            local layer = CommonManager:showOperateSureLayer(
                    function()
                        BagManager:useBatchItem( item.id,num )
                    end,
                    nil,
                    {
                    uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
                   
                    title = item.name .. stringUtils.format(localizable.bagPropDetailsLayer_number,num),
                    msg = stringUtils.format(localizable.bagPropDetailsLayer_exchange ,item.usable * num)

                    }
            )
            local img1 = TFDirector:getChildByPath(layer, 'img1');
            local img2 = TFDirector:getChildByPath(layer, 'img2');
  
            img1:setTexture(item:GetPath());
            img2:setTexture(GetResourceIconForGeneralHead(EnumDropType.GENUINE_QI))
            return;
        end
    end
end

return ItemDetails
