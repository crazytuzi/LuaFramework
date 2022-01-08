--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagGiftsDetailsLayer = class("BagGiftsDetailsLayer", BaseLayer)

function BagGiftsDetailsLayer:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagGiftDetails")
end

function BagGiftsDetailsLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_root             = TFDirector:getChildByPath(ui, 'panel_root')
    self.panel_details_bg       = TFDirector:getChildByPath(ui, 'panel_details_bg')

	--左侧详情
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_icon')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_Num			= TFDirector:getChildByPath(ui, 'txt_number')
	self.txt_Name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality 		= TFDirector:getChildByPath(ui, 'img_quality')
	self.txt_description    = TFDirector:getChildByPath(ui, 'txt_description')


	--招募按钮
	self.btn_use 		= TFDirector:getChildByPath(ui, 'btn_use')
    self.btn_use.logic  = self

	--右侧tableView
	self.panel_table        = TFDirector:getChildByPath(ui, 'panel_table')
    self.panel_reward       = TFDirector:getChildByPath(ui, 'panel_reward')

    --打开可获得的物品
    self.btn_reward         = {}
    self.img_reward         = {}
    self.txt_reward_num     = {}
    for i=1,8 do
        self.btn_reward[i]        = TFDirector:getChildByPath(self.panel_reward, 'btn_reward_'..i)
        self.btn_reward[i].logic  = self
        self.img_reward[i]        = TFDirector:getChildByPath(self.panel_reward, 'img_reward_'..i)
        self.txt_reward_num[i]    = TFDirector:getChildByPath(self.panel_reward, 'txt_reward_num_'..i)
    end

	self:initTableView()

end

function BagGiftsDetailsLayer:removeUI()
	self.super.removeUI(self)

	self.panel_root = nil
	self.btn_icon = nil
	self.img_icon = nil
	self.txt_Num = nil
	self.txt_Name = nil
	self.img_quality = nil
	self.txt_description = nil
	self.btn_use = nil
	self.tableView = nil
	self.panel_table = nil
    self.panel_details_bg = nil
	
    self.panel_reward = nil

    for i=1,8 do
        self.btn_reward[i].logic = nil
        self.btn_reward[i] = nil
        self.img_reward[i] = nil
        self.txt_reward_num[i] = nil
    end
    self.btn_reward = nil
    self.img_reward = nil
    self.txt_reward_num = nil

    self.createNewHoldGoodsCallback = nil
    self.holdGoodsNumberChangedCallback = nil
    self.deleteHoldGoodsCallback = nil
end

function BagGiftsDetailsLayer:setHomeLayer(homeLayer)
    self.homeLayer = homeLayer
end

--初始化TableView
function BagGiftsDetailsLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_table:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    --tableView:setPosition(self.panel_table:getPosition())

    self.tableView = tableView
    self.tableView.logic = self

    self:updateTableSource()
    self:selectDefault()
    self.panel_table:addChild(tableView)

    if self.itemlist == nil or self.itemlist:length() < 1 then
        self.panel_details_bg:setVisible(false)
        --self.tableView:setVisible(false)
        return
    else
        self.panel_details_bg:setVisible(true)
        --self.tableView:setVisible(true)
    end
end

--设置物品数据
function BagGiftsDetailsLayer:setData(data)
	if data == nil  then
		return false
	end

	self.id = data.id
	self.txt_Name:setText(data.name)
	-- self.txt_Name:setColor(GetColorByQuality(data.quality))
	self.img_icon:setTexture(data:GetTextrue())
	self.btn_icon:setTextureNormal(GetColorIconByQuality(data.quality))
	self.txt_Num:setText(data.num)
	self.txt_description:setText(data.itemdata.details)
    self:checkAllRewardItemEnabled()
end

function BagGiftsDetailsLayer:checkAllRewardItemEnabled()
    local gift_pack = GiftPackData:objectByID(self.id)
    if gift_pack == nil then
        print("礼包表无此礼包 id== "..self.id)
        self:setAllRewardItemEnabled(false)
        return
    end
    
    --没有任何物品奖励
    self.reward_list = gift_pack:getGiftList()
    if self.reward_list == nil or self.reward_list:length() < 1 then
        self:setAllRewardItemEnabled(false)
        return
    end

    --有物品奖励
    local length = self.reward_list:length()
    for i=1,8 do
        if i <= length then
            self:setRewardItemEnabled(i,true)
        else
            self:setRewardItemEnabled(i,false)
        end
    end
end

function BagGiftsDetailsLayer:setRewardItemEnabled(index,enabled)
    --print("index : ",index,enabled)
    self.btn_reward[index]:setTouchEnabled(enabled)
    self.btn_reward[index]:setGrayEnabled(not enabled)
    if self.img_reward[index] ~= nil then
        if enabled then
            local reward_item = self.reward_list:objectAt(index)
            local rewardInfo = BaseDataManager:getReward(reward_item)
            self.txt_reward_num[index]:setText(reward_item.number)
            if reward_item.number >= 100000 then
                self.txt_reward_num[index]:setScale(0.8)
            else
                self.txt_reward_num[index]:setScale(1.2)
            end
            if rewardInfo == nil then
                print("策划配置数据出了问题，找不到奖励的物品")
                self.img_reward[index]:setTexture("icon/notfound.png")
            else
                self.img_reward[index]:setTexture(rewardInfo.path)
            end
            self.btn_reward[index]:setTextureNormal(GetColorIconByQuality(rewardInfo.quality))
        else
            self.btn_reward[index]:setTextureNormal(GetColorIconByQuality(1))
        end
        self.img_reward[index]:setVisible(enabled)
        self.txt_reward_num[index]:setVisible(enabled)
    end
end

function BagGiftsDetailsLayer:setAllRewardItemEnabled(enabled)
    for i=1,8 do
        self:setRewardItemEnabled(i,enabled)
    end
end

--使用按钮点击事件处理方法
function BagGiftsDetailsLayer.useButtonClickHandle(sender)
    local self = sender.logic
    showLoading()
    -- print("BagGiftsDetailsLayer:useButtonClickHandle(sender)")
    self:requestOpen()
end

--点击奖励图标预览
function BagGiftsDetailsLayer.rewardIconButtonClickHandle(sender)
    local self = sender.logic
    local length = self.reward_list:length()
    local index = 0
    for i = 1,length do
        if self.btn_reward[i] == sender then
            index = i
            break
        end
    end
    --print("index : ",index)
    local reward_item = self.reward_list:objectAt(index)
    Public:ShowItemTipLayer(reward_item.itemId, reward_item.type)
end

function BagGiftsDetailsLayer:registerEvents()
    self.super.registerEvents(self)

    --按钮事件
    self.btn_use:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useButtonClickHandle),1)
    for i=1,8 do
        self.btn_reward[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.rewardIconButtonClickHandle))
    end

    --table view 事件
    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, BagGiftsDetailsLayer.cellSizeForTable)
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, BagGiftsDetailsLayer.tableCellAtIndex)
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, BagGiftsDetailsLayer.numberOfCellsInTableView)

    self.createNewHoldGoodsCallback = function(event)
        local holdGoods = event.data[1]
        if not holdGoods then
            return
        end
        if holdGoods.itemdata.type ==  EnumGameItemType.Box then
            self:refreshUI()
            if self.homeLayer then
                self.homeLayer:refreshRedPointState()
            end
        end
    end

    self.holdGoodsNumberChangedCallback = function(event)
        local holdGoods = event.data[1].item
        if holdGoods.itemdata.type ~=  EnumGameItemType.Box then
            return
        end

        self:refreshUI()
        if self.homeLayer then
            self.homeLayer:refreshRedPointState()
        end
        if holdGoods.itemdata.id == self.selectId then
            hideLoading()
            if holdGoods then
                self:setData(holdGoods)
            else
                self.panel_details_bg:setVisible(false)
            end
        end
    end

    self.deleteHoldGoodsCallback = function(event)
        local holdGoods = event.data[1]
        if not holdGoods then
            return
        end
        if holdGoods.itemdata.type ==  EnumGameItemType.Box then
            self:refreshUI()
            if self.homeLayer then
                self.homeLayer:refreshRedPointState()
            end
        end

        if holdGoods.itemdata.id ==  self.selectId then
            self:selectDefault()
            hideLoading()
        end
    end

    --背包物品更改事件
    TFDirector:addMEGlobalListener(BagManager.ItemAdd,self.createNewHoldGoodsCallback)
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.holdGoodsNumberChangedCallback)
    TFDirector:addMEGlobalListener(BagManager.ItemDel,self.deleteHoldGoodsCallback)

    --self.tableView:reloadData()
    --self:selectDefault()
end

--销毁方法
function BagGiftsDetailsLayer:dispose()
    self:disposeAllPanels()
    self.super.dispose(self)
end

--销毁所有TableView的Cell中的Panel
function BagGiftsDetailsLayer:disposeAllPanels()
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
    全部cell都重置为未选中
]]
function BagGiftsDetailsLayer:unselectedAllCellPanels()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        if self.selectId and panel.id == self.selectId then
            panel:setChoice(false)
        end
    end
end

function BagGiftsDetailsLayer:updateSelectCell()
    if self.allPanels == nil then
        return
    end

    for r=1,#self.allPanels do
        local panel = self.allPanels[r]
        panel:refreshUI()
    end
end

function BagGiftsDetailsLayer:selectDefault()
    --if self.allPanels == nil then
    --    self.selectId = nil
    --    return
    --end

    if self.itemlist and self.itemlist:length() > 0 then
        self:select(self.itemlist:objectAt(1).id)
    else
        self.selectId = nil
    end
end

function BagGiftsDetailsLayer:removeEvents()
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tableView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)

    --按钮事件
    self.btn_use:removeMEListener(TFWIDGET_CLICK)
    for i=1,8 do
        self.btn_reward[i]:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(BagManager.ItemAdd,self.createNewHoldGoodsCallback)
    TFDirector:removeMEGlobalListener(BagManager.ItemDel,self.deleteHoldGoodsCallback)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.holdGoodsNumberChangedCallback)

    self.super.removeEvents(self)
end

--[[
    更新TableView显示的内容
]]
function BagGiftsDetailsLayer:updateTableSource()
    self.itemlist = BagManager:getItemByType(EnumGameItemType.Box)

    --当其他提交都相等时使用的最简单的比较方法
    local function simpleSort(src,target)
        if src.itemdata.quality < target.itemdata.quality then
            return false
        elseif src.itemdata.quality == target.itemdata.quality and src.itemdata.id > target.itemdata.id then
            return false
        else
            return true
        end
    end

    self.itemlist:sort(simpleSort)
end

function BagGiftsDetailsLayer:refreshUI()
    self:refreshTableView()
end

function BagGiftsDetailsLayer:refreshTableView()
    --print("BagGiftsDetailsLayer:refreshTableView()")
    self:updateTableSource()
    if self.itemlist == nil or self.itemlist:length() < 1 then
        self.panel_details_bg:setVisible(false)
        --self.tableView:setVisible(false)
    else
        self.panel_details_bg:setVisible(true)
        --self.tableView:setVisible(true)
    end
    --local currentOffset = self.tableView:getContentOffset()
    --print("current offset : ",currentOffset)
    self.tableView:reloadData()
    --self.tableView:setContentOffset(currentOffset)
    self:updateSelectCell()
end

function BagGiftsDetailsLayer.cellSizeForTable(table,idx)
    return 160,430
end

function BagGiftsDetailsLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}
    if nil == cell then
        --table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        --table.cells[cell] = true
        for i=1,3 do
            local bagItem_panel = require('lua.logic.bag.BagGiftsCell'):new()
            local size = bagItem_panel:getSize()
            local x = size.width*(i-1)
            if i > 1 then
                x = x + (i-1)*5
            end
            bagItem_panel:setPosition(ccp(x,0))
            bagItem_panel:setLogic(self)
            cell:addChild(bagItem_panel)
            
            cell.bagItem_panel = cell.bagItem_panel or {}
            cell.bagItem_panel[i] = bagItem_panel
            local newIndex = #self.allPanels + 1
            self.allPanels[newIndex] = bagItem_panel
        end
        
    end

    for i=1,3 do
        if (idx * 3 + i) <= self.itemlist:length() then
            local _item = self.itemlist:objectAt(idx * 3 + i)
            --cell.bagItem_panel[i]:setVisible(true)
            cell.bagItem_panel[i]:setData(_item.id)
        else
            cell.bagItem_panel[i]:setData(nil)
            --cell.bagItem_panel[i]:setVisible(false)
        end
    end

    return cell
end

function BagGiftsDetailsLayer.numberOfCellsInTableView(table)
    local self = table.logic
    if self.itemlist and self.itemlist:length() > 0 then
        local num = math.ceil(self.itemlist:length()/3)
        if num < 3 then
            return 3
        end
        return num
    end
    return 3
end

--[[
    选中
]]
function BagGiftsDetailsLayer:select(id)
    --选中的Cell如果重复选中则不处理
    if self.selectId then
        if self.selectId == id then
            return
        end

        self:unselectedAllCellPanels()
    end
    
    self.selectId = id
    self:updateSelectCell()

    --详细信息控件
    local item = BagManager:getItemById(id)

    self:setData(item)
end

--table cell 被选中时在对应的Cell中触发此回调函数
function BagGiftsDetailsLayer:tableCellClick(cell)
    self:select(cell.id)
end

--------------------------------网络相关处理---------------------------------------
--请求服务器打开礼包
function BagGiftsDetailsLayer:requestOpen()
    BagManager:item_Server_Use(self.id)
end

return BagGiftsDetailsLayer
