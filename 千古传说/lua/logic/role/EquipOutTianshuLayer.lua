--[[
    天书不足页面
]]

local EquipOutTianshuLayer = class("EquipOutTianshuLayer", BaseLayer)
--local TEXT_DESCRIBE = "藏书阁"
local TEXT_DESCRIBE = localizable.EquipOutTianshu_text1

function EquipOutTianshuLayer:ctor(data)
    self.super.ctor(self, data)
    self.isfirst = true

    self:init("lua.uiconfig_mango_new.role.EquipEmptyTianShu")
end

function EquipOutTianshuLayer:loadData(type)
    self.outputNum = 1
end

function EquipOutTianshuLayer:onShow()
    self.super.onShow(self)
    
    self:refreshBaseUI()
    self:refreshUI()
    if self.isfirst == true then
        self.isfirst = false
        self.ui:runAnimation("Action0", 1)
    end
end

function EquipOutTianshuLayer:refreshBaseUI()

end


function EquipOutTianshuLayer:refreshUI()
    self:refreshTable()
end

function EquipOutTianshuLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_outnode = TFDirector:getChildByPath(ui, "bg_cell")
    self.panel_outnode:setVisible(false)

    self.panel_outlist = TFDirector:getChildByPath(ui, 'panel_outlist')
end

function EquipOutTianshuLayer:refreshTable()
    local pannel_outList =  self.panel_outlist
    if self.panel_outlist == nil then
        return
    end
    
    if self.outputTableView ~= nil then
        self.outputTableView:setVisible(true)
        self.outputTableView:reloadData()
        self.outputTableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(pannel_outList:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.outputTableView = tableView
    self.outputTableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, EquipOutTianshuLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, EquipOutTianshuLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, EquipOutTianshuLayer.numberOfCellsInTableView)
    tableView:reloadData()

    pannel_outList:addChild(tableView,1)
end

function EquipOutTianshuLayer.cellSizeForTable(table, idx)
    return 70, 348
end

function EquipOutTianshuLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.panel_outnode:clone()

        node:setPosition(ccp(150, 30))
        cell:addChild(node)
        node:setTag(617)
    end

    node = cell:getChildByTag(617)
    node.logic   = self
    self:drawOutNode(node)

    node:setVisible(true)

    return cell
end

function EquipOutTianshuLayer.numberOfCellsInTableView(table)
    local self = table.logic
 
    return self.outputNum
end

function EquipOutTianshuLayer:drawOutNode(node)
    
    local txt_leveldesc  = TFDirector:getChildByPath(node, "txt_leveldesc")
    local txt_levelopen  = TFDirector:getChildByPath(node, "txt_levelopen")

    txt_leveldesc:setText(TEXT_DESCRIBE)

    node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOutClickHandle),1)

    local level = FunctionOpenConfigure:getOpenLevel(2203)
    if MainPlayer:getLevel() >= level then
        txt_leveldesc:setColor(ccc3(0,0,0))
        txt_levelopen:setColor(ccc3(0,0,0))
        node:setTexture("ui_new/rolebook/bg_cell.png")
    else
        txt_leveldesc:setColor(ccc3(141,141,141))
        txt_levelopen:setColor(ccc3(141,141,141))
        node:setTexture("ui_new/rolebook/bg_cell2.png")
    end

    txt_levelopen:setVisible(false)
end


function EquipOutTianshuLayer.onOutClickHandle(sender)
    local self = sender.logic

    local level = FunctionOpenConfigure:getOpenLevel(2203)
     local needLevel = level
    if MainPlayer:getLevel() < needLevel then
        --toastMessage(needLevel .. "级解锁")
        toastMessage(stringUtils.format(localizable.common_level_unlock,needLevel))
        return
    end

    AdventureManager:openAdventureMallLayer()
end

function EquipOutTianshuLayer:removeEvents()
    self.super.removeEvents(self)
    self.isfirst = true
end
return EquipOutTianshuLayer
