
local OpenServiceHomeLayer = class("OpenServiceHomeLayer", BaseLayer)

-- local activityList = {11,12,13,14,15,16,17,18,19,20,21}

local activityList = {
EnumActivitiesType.TEN_CARD,
EnumActivitiesType.HAPPY_TOGETHER,
EnumActivitiesType.PAY_FOR_REDBAG,
EnumActivitiesType.V8_PRIZE,
26,22,11,12,13,14,15,16,17,18,19,20,21}

-- DXCCC                       = 1,            --大侠冲冲冲
-- XZWLZZ                      = 2,            --寻找武林至尊
-- SSJHCGW                     = 3,            --谁是闯关王
-- LOGON_REWARD                = 4,            --登录奖励7日
-- ONLINE_REWARD               = 5,            --在线奖励
-- TEAM_LEVEL_UP_REWARD        = 6,            --团队等级升级奖励
-- JOIN_QQ_QUN                 = 7,            --加入QQ群
-- REPORT_BUG                  = 8,            --提交bug
-- VIP_GET                     = 9,            --送VIP
-- INVITE                      = 10,           --邀请好友

-- -- 新增活动 从11开始
-- LEIJICHONGZHI               = 11,           --累计充值
-- DANGRICHONGZHI              = 12,           --当日充值
-- DANBICHONGZHI               = 13,           --单笔充值
-- LEIJIXIAOFEI                = 14,           --累计消费
-- DANGRIXIAOFEI               = 15,           --当日消费
-- LIANXUDENGLU                = 16,           --连续登陆
-- ONLINE_REWARD_NEW           = 17,           --在线奖励
-- TUANDUIDENGJI               = 18,           --团队等级升级奖励
-- QIRIDENGLU                  = 19            --登录奖励7日
-- EXCHANGE

function OpenServiceHomeLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.HomeLayer")
end

function OpenServiceHomeLayer:initUI(ui)
	self.super.initUI(self,ui)

    -- self.activityIndex = {1,2,3,4,5,6,7,8,9,10}
    -- self.activityIndex = {4,6,1,2,3,5,7,8,9,10}
    -- local activityList = {11,12,13,14,15,16,17,18,19,8,10}
    -- local activityList = {11,12,13,14,15,16,17,18,19,20,21}

    -- local activityList = OperationActivitiesManager:getActivityList()

    self.activityNum   = 0
    self.activityIndex = {}

    for i=1,#activityList do
        local activityId = activityList[i]
        if activityId then
            -- local bOpen = QiyuManager:ActivityFuctionIsOpenByIndex(activityId)
            local bOpen = OperationActivitiesManager:ActivitgIsOpen(activityId)

            -- if activityId == EnumActivitiesType.DUCHANG then
            --     bOpen = true
            -- end


            local open = 0
            if bOpen then
                open = 1
            end
            print("activityId .. " .. activityId .. " status .. ".. open)

            if bOpen then
                table.insert(self.activityIndex, activityId)
                self.activityNum = self.activityNum + 1
            end
        end
    end

    
    print("当前开启的活动个数：", self.activityNum)
    print("当前开启的活动有：", self.activityIndex)

    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.YunYingHuoDong,{HeadResType.COIN,HeadResType.SYCEE})


	self.panel_buttons           = TFDirector:getChildByPath(ui, 'panel_buttons')
	self.panel_details 	         = TFDirector:getChildByPath(ui, 'panel_details')

    self.detailsLayerTable = {}     --详细内容图层
    self.currentDetailsLayer = nil  --当前显示的详细内容图层
    self:initActivitiesButtons()
    --选中第一个

end

function OpenServiceHomeLayer:initActivitiesButtons()
    local  tableView =  TFTableView:create()
    tableView:setName("btnTableView")
    tableView:setTableViewSize(self.panel_buttons:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    self.tableView = tableView
     
    self.tableView.logic = self

    tableView:addMEListener(TFTABLEVIEW_TOUCHED, OpenServiceHomeLayer.tableCellTouched)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, OpenServiceHomeLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, OpenServiceHomeLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, OpenServiceHomeLayer.numberOfCellsInTableView)

    self.panel_buttons:addChild(tableView)
    tableView:reloadData()
end

function OpenServiceHomeLayer:onShow()
    self.super.onShow(self)
    if self.currentDetailsLayer then
        self.currentDetailsLayer:onShow()
    end

    self.generalHead:onShow()


    self:reloadTableView()
end

function OpenServiceHomeLayer:removeUI()
	self.super.removeUI(self)
end

function OpenServiceHomeLayer:dispose()
    if self.detailsLayerTable then
        for _k,_v in pairs(self.detailsLayerTable) do
            _v:dispose();
        end
    end

    if generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function OpenServiceHomeLayer:registerEvents()
    self.super.registerEvents(self)
    
    self.OpenServiceHomeLayerTouchCallBack = function(event)
        self:AddLayerbyindex(event.data[1])
    end;

    TFDirector:addMEGlobalListener("OpenServiceHomeLayer_touch",self.OpenServiceHomeLayerTouchCallBack)

    if self.generalHead then
        self.generalHead:registerEvents()
    end
    if self.currentDetailsLayer then
        self.currentDetailsLayer:registerEvents();
    end


    self.activityUpdateCallBack = function(event)
        self:activityUpdate()
    end

    TFDirector:addMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_UPDATE, self.activityUpdateCallBack)
end

function OpenServiceHomeLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener("OpenServiceHomeLayer_touch",self.OpenServiceHomeLayerTouchCallBack)
    self.OpenServiceHomeLayerTouchCallBack = nil
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    if self.currentDetailsLayer then
        self.currentDetailsLayer:removeEvents();
    end


    TFDirector:removeMEGlobalListener(OperationActivitiesManager.MSG_ACTIVITY_UPDATE, self.activityUpdateCallBack)
    self.activityUpdateCallBack = nil

end

function OpenServiceHomeLayer.tableCellTouched(table,cell)
    local self = table.logic
    local idx = cell:getIdx() + 1
    play_press()
    self:select(idx)
end

function OpenServiceHomeLayer:select(index)
    if self.selectedIndex and index == self.selectedIndex then
        return
    end

    self.selectedIndex = index
    

    -- self:showDetailsLayer(self.selectedIndex)

    local activityIndex = self.activityIndex[self.selectedIndex]
    self.selectedtype = activityIndex

    self:showDetailsLayer(activityIndex)

    self.tableView:reloadData()

end

function OpenServiceHomeLayer:showDetailsLayer(type)
    -- print("type = ", type)
    local layer = self.detailsLayerTable[type]
    if layer then
        if layer == self.currentDetailsLayer then
            return
        end

        if self.currentDetailsLayer then
            self.currentDetailsLayer:setVisible(false)
            self.currentDetailsLayer:removeEvents()
        end
        layer:setVisible(true)
        self.currentDetailsLayer = layer
        self.currentDetailsLayer:registerEvents()
    else
        local layerFile = 'lua.logic.activity.operation.Activity_' .. type;

        if type > 10 then
            layerFile = 'lua.logic.activity.operation.Activity_common'

            if type ==  EnumActivitiesType.ONLINE_REWARD_NEW then
                layerFile = 'lua.logic.activity.operation.Activity_online'
            end

            if type == EnumActivitiesType.DUCHANG then
                layerFile = 'lua.logic.activity.operation.Activity_Casino'
            elseif type == EnumActivitiesType.EXCHANGE then
                layerFile = 'lua.logic.activity.operation.Activity_exchangegoods'
            end
        end
        layer = require(layerFile):new(type)
        if layer == nil then
            print("fuck you ,can not create layer instance for : ",layerFile)
            return
        end
        
        layer.logic = self

        self.detailsLayerTable[type] = layer
        if self.currentDetailsLayer then
            self.currentDetailsLayer:setVisible(false)
            self.currentDetailsLayer:removeEvents()
        end
        self.panel_details:addChild(layer)
        self.currentDetailsLayer = layer
        -- self.currentDetailsLayer:registerEvents()
    end
    self.currentDetailsLayer:onShow()
end

function OpenServiceHomeLayer.cellSizeForTable(table,idx)
	return 114,429
end

function OpenServiceHomeLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local activityIndex = self.activityIndex[idx+1]

    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        local equip_panel = require('lua.logic.activity.operation.ActivitiesButton'):new()
        equip_panel:setLogic(self)
        cell:addChild(equip_panel)
        cell.equip_panel = equip_panel
    end
    -- cell.equip_panel:setType(idx+1)

    if activityIndex  <= 10 then
        cell.equip_panel:setType(activityIndex)
    else

        
        local desc1, desc2, path  = OperationActivitiesManager:getRewardItemDesc(activityIndex)

        cell.equip_panel:setPath(path, activityIndex)
    end


    -- CommonManager:setRedPoint(cell.equip_panel, OperationActivitiesManager:isHaveRewardCanGetByType(activityIndex),"isHaveRewardCanGet",ccp(-180,60))

    CommonManager:setRedPoint(cell.equip_panel, OperationActivitiesManager:isHaveRewardCanGetByType_New(activityIndex),"isHaveRewardCanGet",ccp(-180,60))
    return cell
end

function OpenServiceHomeLayer.numberOfCellsInTableView(table)
    local self = table.logic
    -- return 10

    -- return #self.activityIndex
    return self.activityNum
end
function OpenServiceHomeLayer.refreshRwdPoint()

end



function OpenServiceHomeLayer:reloadTableView()
    print("OpenServiceHomeLayer:reloadTableView-----------")
    if not self.tableView then
        return
    end

    -- local activityList = {11,12,13,14,15,16,17,18,19,20,21}


    self.activityNum   = 0
    self.activityIndex = {}

    for i=1,#activityList do
        local activityId = activityList[i]
        if activityId then
            -- local bOpen = QiyuManager:ActivityFuctionIsOpenByIndex(activityId)
            local bOpen = OperationActivitiesManager:ActivitgIsOpen(activityId)

            -- if activityId == EnumActivitiesType.DUCHANG then
            --     bOpen = true
            -- end

            local open = 0
            if bOpen then
                open = 1
            end
            print("activityId .. " .. activityId .. " status .. ".. open)

            if bOpen then
                table.insert(self.activityIndex, activityId)
                self.activityNum = self.activityNum + 1
            end
        end
    end
    
    self.tableView:reloadData()
end

function OpenServiceHomeLayer:activityUpdate()
    -- 
    print("OpenServiceHomeLayer:activityUpdate-----------")
    self:reloadTableView()
    if self.activityNum > 0  then
        self.selectedIndex = -1
        self:select(1)
    end
end


return OpenServiceHomeLayer