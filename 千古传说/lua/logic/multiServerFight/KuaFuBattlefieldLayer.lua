
local KuaFuBattlefieldLayer = class("KuaFuBattlefieldLayer", BaseLayer)

function KuaFuBattlefieldLayer:ctor()
    self.super.ctor(self)
    
    self.personGrandList = TFArray:new()
    self.personGrandList:clear()
    
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiBattlefield")
    self.selectedIndex = 1
    
end

function KuaFuBattlefieldLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
    self.reportLayer = {}
    self.reportLayer[1]     = TFDirector:getChildByPath(ui, 'panel_person')
    self.reportLayer[2]     = TFDirector:getChildByPath(ui, 'panel_public')
    self:initButtonGroup(ui)
end

function KuaFuBattlefieldLayer:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);

end

function KuaFuBattlefieldLayer:removeEvents()
    self.super.removeEvents(self)

end


function KuaFuBattlefieldLayer:refreshReportLayer(index)
    self.tableViewList =  self.tableViewList or {}
    if self.tableViewList[index] == nil then
        local panel_scroll = TFDirector:getChildByPath(self.reportLayer[index], "panel_scroll")
        local  tableView =  TFTableView:create()
        tableView:setTableViewSize(panel_scroll:getContentSize())
        tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
        tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)


        tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, KuaFuBattlefieldLayer.cellSizeForTable)
        tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, KuaFuBattlefieldLayer.tableCellAtIndex)
        tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, KuaFuBattlefieldLayer.numberOfCellsInTableView)

        self.tableViewList[index] = tableView
        self.tableViewList[index].logic = self

        panel_scroll:addChild(tableView)
    end
    self.tableViewList[index]:reloadData()
    self.tableViewList[index]:setScrollToEnd()
end

function KuaFuBattlefieldLayer.cellSizeForTable(table,idx)
    return 30,630
end

function KuaFuBattlefieldLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    self.allPanels = self.allPanels or {}

    if nil == cell then
        cell = TFTableViewCell:create()
        local zhenbashaiCell = require('lua.logic.zhengba.ZhenbashaiCell'):new()
        cell.panel = zhenbashaiCell
        cell:addChild(zhenbashaiCell)
    end
    -- local reportList = MultiServerFightManager:getReport( self.selectedIndex )
    cell.panel:setData(self.personGrandList:objectAt(idx + 1))
    return cell
end

function KuaFuBattlefieldLayer.numberOfCellsInTableView(table)
    local self = table.logic
    -- local reportList = MultiServerFightManager:getReport( self.selectedIndex )
    return self.personGrandList:length()
end
function KuaFuBattlefieldLayer:selectSideButton(index)
    self.selectedIndex = index
    local text_name = {"tab_tab3" , "tab_dhzb"}
    for i = 1, #self.sideButtons do
        if i ~= index then
            self.sideButtons[i]:setTextureNormal("ui_new/spectrum/"..text_name[i]..".png")
            self.reportLayer[i]:setVisible(false)
        end
    end

    self.personGrandList:clear()
    local dataRecord = MultiServerFightManager:getReport( self.selectedIndex )
    for i=1,dataRecord:length() do
        local item = dataRecord:objectAt(i)
        self.personGrandList:pushBack(item)
    end
    
    self.sideButtons[index]:setTextureNormal("ui_new/spectrum/"..text_name[index].."h.png")
    self.reportLayer[index]:setVisible(true)
    self:refreshReportLayer(index)
end

--初始化buttongroup
function KuaFuBattlefieldLayer:initButtonGroup(ui)
   
    --频道按钮点击事件处理方法
    local function onSelectChangeHandle(target)
        if target.tag == self.selectedIndex then
            return
        end
        self:selectSideButton(target.tag)
    end

    local channelGroup = TFButtonGroup:create()
    self.channelGroup = channelGroup
    self.sideButtons = {}
    for i = 1,2 do
        local channelButton = TFDirector:getChildByPath(self.ui, "tab" .. i)
        channelButton:addMEListener(TFWIDGET_CLICK, audioClickfun(onSelectChangeHandle))
        channelButton.tag = i
        self.sideButtons[i] = channelButton
    end
    self:selectSideButton(1)
end

--获取当前选中的频道
function KuaFuBattlefieldLayer:getSelectedChannelIndex()
    return self.selectedIndex
end

--选中某个分类，一般在其他地方调用。如：打开界面时默认选中某个界面的时候
function KuaFuBattlefieldLayer:changeGroupChoice( index )
    if self.selectedIndex == index then
        return
    end

    self:selectSideButton(index)
end
return KuaFuBattlefieldLayer