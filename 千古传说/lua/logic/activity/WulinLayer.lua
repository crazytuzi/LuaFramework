
local WulinLayer = class("WulinLayer", BaseLayer)

function WulinLayer:ctor(data)
    self.super.ctor(self,data)
    self.choice = 1
    self:init("lua.uiconfig_mango_new.activity.ActivityLayer")

    self:initTableView()
end

function WulinLayer:loadData(data)

    if data ~= nil then
        local index  = WulinManager:getIndexById(data)
        self.choice = index or 1
    end

    local list  = WulinManager:getlist()
    if list and list:objectAt(self.choice) then
        self.showlayer = require(list:objectAt(self.choice).layer):new()
        self.showlayer:setPosition(self.layer_activity:getPosition())
        self.showlayer:setTag(10)
        self.layer_activity:getParent():addChild(self.showlayer,1)
    end
    self.tableView:reloadData()
end

function WulinLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.layer_list			= TFDirector:getChildByPath(ui, 'layer_list')
	self.layer_activity 	= TFDirector:getChildByPath(ui, 'layer_activity')

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Wulin,{HeadResType.COIN,HeadResType.SYCEE})
end

function WulinLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    if self.tableView then
        self.tableView:reloadData()
    end
end

function WulinLayer:removeUI()
    self.super.removeUI(self)
end

function WulinLayer:dispose()
     if self.showlayer then
        self.showlayer:dispose();
        self.showlayer:removeFromParentAndCleanup(true)
        self.showlayer = nil
    end
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function WulinLayer:registerEvents()
    self.super.registerEvents(self)
    
    if self.tableView then
        self.tableView:reloadData()
    end

    self.WulinLayerTouchCallBack = function(event)
        self:AddLayerbyindex(event.data[1])
    end

    TFDirector:addMEGlobalListener("WulinLayer_touch",self.WulinLayerTouchCallBack)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
    if  self.showlayer then
        self.showlayer:registerEvents();
    end
end

function WulinLayer:removeEvents()
    TFDirector:removeMEGlobalListener("WulinLayer_touch",self.WulinLayerTouchCallBack)
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    --没办法只能销毁
    if self.showlayer then
        self.showlayer:dispose();
        self.showlayer:removeFromParentAndCleanup(true)
        self.showlayer = nil
    end
    self.super.removeEvents(self)
end

function WulinLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setName("btnTableView")
    tableView:setTableViewSize(self.layer_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setPosition(self.layer_list:getPosition())
    self.tableView = tableView
     
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_TOUCHED, WulinLayer.tableCellTouched)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, WulinLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, WulinLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, WulinLayer.numberOfCellsInTableView)


    self.layer_list:getParent():addChild(self.tableView,10)
end

function WulinLayer.tableCellTouched(table,cell)
    play_press()

    local idx = cell:getIdx() + 1
    if idx == table.logic.choice then
        return
    end
    TFDirector:dispatchGlobalEventWith("WulinLayer_touch", idx)
    
    if table.logic.choiceCell then
        local oldCell = table.logic.choiceCell
        local oldidx = table.logic.choice
        local old_activity = WulinManager:getlist():objectAt(oldidx)
        oldCell.sprite:setTexture(old_activity.path..".png")
        oldCell.icon_select:setVisible(false)
    end

    local activity = WulinManager:getlist():objectAt(idx)
    cell.sprite:setTexture(activity.path.."_h.png")
    cell.icon_select:setVisible(true)

    table.logic.choiceCell = cell
    table.logic.choice = idx  

    PlayerGuideManager:showNextGuideStep()
    -- if PlayerGuideManager:isGuideNowByName("无量山") or PlayerGuideManager:isGuideNowByName("摩诃崖") or PlayerGuideManager:isGuideNowByName("雁门关") then
    --     PlayerGuideManager:ShowNextGuideStep()
    -- end
end

function WulinLayer.cellSizeForTable(table,idx)
	return 162,150
end

function WulinLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    local activity = WulinManager:getlist():objectAt(idx+1)
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        local sprite = TFImage:create(activity.path..".png")
        sprite:setAnchorPoint(CCPointMake(0,0))
        sprite:setPosition(CCPointMake(0, 0))
        sprite:setTag(123)
        cell:addChild(sprite)
        cell.sprite = sprite

        local icon_select = TFImage:create("ui_new/Zhenbashai/icon_select.png")
        icon_select:setAnchorPoint(CCPointMake(0.5,0))
        icon_select:setPosition(CCPointMake(sprite:getContentSize().width/2, 130))
        icon_select:setTag(124)

        sprite:addChild(icon_select)
        cell.icon_select = icon_select
    end

    if idx == table.logic.choice - 1 then
        cell.sprite:setTexture(activity.path.."_h.png")
        cell.icon_select:setVisible(true)
        table.logic.choiceCell = cell
    else
        cell.sprite:setTexture(activity.path..".png")
        cell.icon_select:setVisible(false)
    end
    -- -- cell:setName("cell"..(idx+1))
    -- local openLev = {0}
    -- local teamLev = MainPlayer:getLevel()
    -- if teamLev < openLev[idx+1] then
    --     if cell.lock == nil then
    --         local lockIcon = TFImage:create("ui_new/guide/lock.png")
    --         lockIcon:setPosition(ccp(90, 100))
    --         cell.sprite:addChild(lockIcon)
    --         cell.lock = lockIcon
    --     end
    -- else
    --     if cell.lock then
    --         cell.lock:removeFromParentAndCleanup(true)
    --         cell.lock = nil
    --     end
    -- end

    return cell
end

function WulinLayer.numberOfCellsInTableView(table)
	return WulinManager:getlist():length()
end

function WulinLayer:AddLayerbyindex(idx)
    if  idx == self.choice then
        return false
    end

    if  self.showlayer then
        self.showlayer:dispose();
        self.showlayer:removeFromParentAndCleanup(true)
        self.showlayer = nil
    end

    self.showlayer = require(WulinManager:getlist():objectAt(idx).layer):new()
    self.showlayer:setPosition(self.layer_activity:getPosition())
    self.showlayer:setTag(10)
    self.layer_activity:getParent():addChild(self.showlayer,5)
    return true
end

return WulinLayer