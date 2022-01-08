
local ActivityLayer = class("ActivityLayer", BaseLayer)

function ActivityLayer:ctor(data)
    self.super.ctor(self,data)
    self.choice = 1
    self:init("lua.uiconfig_mango_new.activity.ActivityLayer")

    self:initTableView()
end

function ActivityLayer:loadData(data)

    if data ~= nil then
        local index  = ActivityManager:getIndexById(data)
        self.choice = index or 1
    end

    local list  = ActivityManager:getlist()
    if list and list:objectAt(self.choice) then
        self.showlayer = require(list:objectAt(self.choice).layer):new()
        self.showlayer:setPosition(self.layer_activity:getPosition())
        self.showlayer:setTag(10)
        self.layer_activity:getParent():addChild(self.showlayer,1)
    end
    self.tableView:reloadData()
end

function ActivityLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.layer_list			= TFDirector:getChildByPath(ui, 'layer_list')
	self.layer_activity 	= TFDirector:getChildByPath(ui, 'layer_activity')

    self.img_zhezhao1       = TFDirector:getChildByPath(ui, 'img_zhezhao1')
    self.img_zhezhao2       = TFDirector:getChildByPath(ui, 'img_zhezhao2')

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.PVP,{HeadResType.COIN,HeadResType.SYCEE})
end

function ActivityLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    if self.tableView then
        self.tableView:reloadData()
    end
end

function ActivityLayer:removeUI()
    self.super.removeUI(self)
end

function ActivityLayer:dispose()
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

function ActivityLayer:registerEvents()
    self.super.registerEvents(self)
    
    if self.tableView then
        self.tableView:reloadData()
    end

    self.activityLayerTouchCallBack = function(event)
        self:AddLayerbyindex(event.data[1])
    end

    TFDirector:addMEGlobalListener("ActivityLayer_touch",self.activityLayerTouchCallBack)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
    if  self.showlayer then
        self.showlayer:registerEvents();
    end
end

function ActivityLayer:removeEvents()
    TFDirector:removeMEGlobalListener("ActivityLayer_touch",self.activityLayerTouchCallBack)
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

function ActivityLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setName("btnTableView")
    local tableViewSize = self.layer_list:getContentSize()
    tableView:setTableViewSize(CCSizeMake(tableViewSize.width, tableViewSize.height))
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setPosition(self.layer_list:getPosition())
    self.tableView = tableView
     
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_TOUCHED, ActivityLayer.tableCellTouched)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ActivityLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ActivityLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ActivityLayer.numberOfCellsInTableView)


    tableView:addMEListener(TFTABLEVIEW_CELLISBEGIN, ActivityLayer.cellBegin)
    tableView:addMEListener(TFTABLEVIEW_CELLISEND, ActivityLayer.cellEnd)


    self.layer_list:getParent():addChild(self.tableView,10)
end


ActivityLayer.caonimabi = localizable.activityLayer_text
ActivityLayer.nimabi_type = {301,401,501,601,1101,2101}
function ActivityLayer:isCaonimabiNengdian(idx )
    for i=1,#ActivityLayer.caonimabi do
        if i ~= idx then
            if PlayerGuideManager:isGuideNowByName(ActivityLayer.caonimabi[i]) then
                return false
            end
        end
    end
    return true
end

function ActivityLayer.tableCellTouched(table,cell)
    play_press()

    local self = cell.logic

    local idx = cell:getIdx() + 1
    if idx == table.logic.choice then
        return
    end

    if self:isCaonimabiNengdian(idx) == false then
        return
    end

    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(ActivityLayer.nimabi_type[idx])
    if teamLev < openLev then
        local str = stringUtils.format(localizable.common_function_openlevel, openLev)
        toastMessage(str)
        return
    end
    TFDirector:dispatchGlobalEventWith("ActivityLayer_touch", idx)
    table.logic.choice = idx  
    if self.tableView then
        self.tableView:reloadData()
    end


    PlayerGuideManager:showNextGuideStep()
end

function ActivityLayer.cellSizeForTable(table,idx)
	return 114+100,150-5
end

function ActivityLayer.tableCellAtIndex(table, idx)
    local self = table.logic

    local cell = table:dequeueCell()
    local label = nil
    local activity = ActivityManager:getlist():objectAt(idx+1)
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

    	local sprite = TFImage:create(activity.path..".png")
            if sprite ~= nil then
            sprite:setAnchorPoint(CCPointMake(0,0))
            sprite:setPosition(CCPointMake(0, 0))
            sprite:setTag(123)
            cell:addChild(sprite)
            cell.sprite = sprite
        end
    end

        -- if cell.arrow then
        --     cell.arrow:removeFromParentAndCleanup(true)
        --     cell.arrow = nil
        -- end

    if idx == table.logic.choice - 1 then
        cell.sprite:setTexture(activity.path.."_h.png")
        table.logic.choiceCell = cell

        -- local hiImage = TFImage:create("ui_new/Zhenbashai/icon_select.png")
        -- if hiImage then
        --     hiImage:setPosition(ccp(75.5, 150))
        --     cell.sprite:addChild(hiImage)
        --     cell.arrow = hiImage
        -- end
    else
        cell.sprite:setTexture(activity.path..".png")
    end
    -- cell:setName("cell"..(idx+1))
    -- local nimabi_type = {301,401,501,601,1101,2101}
    -- local openLev = {FunctionOpenConfigure:getOpenLevel(301), FunctionOpenConfigure:getOpenLevel(401), FunctionOpenConfigure:getOpenLevel(501), FunctionOpenConfigure:getOpenLevel(601), FunctionOpenConfigure:getOpenLevel(1101), FunctionOpenConfigure:getOpenLevel(2101)}
    
    -- local teamLev = MainPlayer:getLevel()
    -- if teamLev < FunctionOpenConfigure:getOpenLevel(ActivityLayer.nimabi_type[idx+1]) then --openLev[idx+1] then
    --     if cell.lock == nil then
    --         local lockIcon = TFImage:create("ui_new/guide/lock.png")
    --         lockIcon:setPosition(ccp(75, 100))
    --         cell.sprite:addChild(lockIcon)
    --         cell.lock = lockIcon
    --     end
    -- else
    --     if cell.lock then
    --         cell.lock:removeFromParentAndCleanup(true)
    --         cell.lock = nil
    --     end
    -- end

    cell.logic = table.logic

    CommonManager:setRedPoint(cell.sprite, self:redPoint(idx + 1), "qiuyu"..idx, ccp(80, 80))

    return cell
end

function ActivityLayer.numberOfCellsInTableView(table)
	return ActivityManager:getlist():length()
end

function ActivityLayer.cellBegin(table)

end

function ActivityLayer.cellEnd(table)

end

function ActivityLayer:AddLayerbyindex(idx)
    if  idx == self.choice then
        return false
    end

    if  self.showlayer then
        self.showlayer:dispose();
        self.showlayer:removeFromParentAndCleanup(true)
        self.showlayer = nil
    end

    self.showlayer = require(ActivityManager:getlist():objectAt(idx).layer):new()
    self.showlayer:setPosition(self.layer_activity:getPosition())
    self.showlayer:setTag(10)
    self.layer_activity:getParent():addChild(self.showlayer,1)
    return true
end

function ActivityLayer:redPoint(index)
    if index ~= 6 then
        return false
    end

    return MiningManager:redPoint()
end

return ActivityLayer