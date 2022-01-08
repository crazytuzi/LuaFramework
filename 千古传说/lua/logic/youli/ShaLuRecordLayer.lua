--[[
******杀戮记录层*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local ShaLuRecordLayer = class("ShaLuRecordLayer", BaseLayer)

function ShaLuRecordLayer:ctor(data)
    self.super.ctor(self, data)
    self.dataList = {}
    self:init("lua.uiconfig_mango_new.youli.ShaLuRecord")
end

function ShaLuRecordLayer:initUI(ui)
    self.super.initUI(self, ui)
    self.Panel_list = TFDirector:getChildByPath(ui, "panel_list")
    self.btn_help   = TFDirector:getChildByPath(ui, "btn_help")
    self.btn_close  = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_close.logic = self
    self.btn_help:setVisible(false)
    self:initTableView()
end

function ShaLuRecordLayer:onShow()
    self.super.onShow(self)
end

function ShaLuRecordLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(ShaLuRecordLayer.OnRuleClick,self)))
end

function ShaLuRecordLayer:OnRuleClick( sender )
    CommonManager:showRuleLyaer('shalurecord')
end

function ShaLuRecordLayer:initTableData()
    self.dataList = self.dataList or {}
end

function ShaLuRecordLayer:SetData(data)
    self.dataList = data
    if self.tableView then
        self.tableView:reloadData()
    end
end

function ShaLuRecordLayer:initTableView()
    self:initTableData()
    local  tableView =  TFTableView:create()

    self.tableView = tableView
    tableView:setTableViewSize(self.Panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, handler(ShaLuRecordLayer.cellSizeForTable,self))
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, handler(ShaLuRecordLayer.tableCellAtIndex,self))
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, handler(ShaLuRecordLayer.numberOfCellsInTableView,self))
    --self.tableView:addMEListener(TFTABLEVIEW_SCROLL, handler(ShaLuRecordLayer.tableScroll,self))
    self.Panel_list:addChild(tableView)
    self.tableView:reloadData()
end

function ShaLuRecordLayer:cellSizeForTable(table,idx)
    return 146,750
end

function ShaLuRecordLayer:tableCellAtIndex(table, idx)
    idx = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
        local node = createUIByLuaNew("lua.uiconfig_mango_new.youli.RecordCell")
        cell:addChild(node,1,101)

        --[[local img_bg = TFDirector:getChildByPath(node, "bg")
        img_bg:setScale9Enabled(true)
        img_bg:setImageSizeType(1)
        img_bg:setCapInsets(CCRectMake(25,20,20,45))
        img_bg:setContentSize(node:getSize())]]
    end
    self:setCellInfo(cell,idx)
    return cell
end

function ShaLuRecordLayer:numberOfCellsInTableView(table)
    local num = #(self.dataList)
    if num < 0 then num = 0 end
    return num
end

function ShaLuRecordLayer:removeEvents()
    self.super.removeEvents(self)
end

function ShaLuRecordLayer:dispose()
    self.super.dispose(self)
end

function ShaLuRecordLayer:setCellInfo(cell,idx)
    local info = self.dataList[idx]
    if info == nil then
        cell:getChildByTag(101):setVisible(false)
        return
    end
    cell:getChildByTag(101):setVisible(true)
    local headIcon = TFDirector:getChildByPath(cell, "Img_icon")
    local fightTag = TFDirector:getChildByPath(cell, "tag")
    local txt_time = TFDirector:getChildByPath(cell, "txt_time")
    local txt_shalu = TFDirector:getChildByPath(cell, "txt_shalu")
    local txt_tongbi = TFDirector:getChildByPath(cell, "txt_tongbi")
    local txt_yueli = TFDirector:getChildByPath(cell, "txt_yueli")
    local txt_name = TFDirector:getChildByPath(cell, "txt_name")
    local btnReport = TFDirector:getChildByPath(cell, "btn_report")

    btnReport.reProtIndex = idx
    btnReport:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onReportBtnClick))

    local role = RoleData:objectByID(info.icon)
    if role then
        headIcon:setTexture(role:getIconPath())
    end
    Public:addFrameImg(headIcon,info.headPicFrame)
    
    if info.name == "" then
        info.name = localizable.shalu_nearby_txt1
    else
        Public:addInfoListen(headIcon,true,2,info.id)
    end
    txt_name:setText(info.name)

    local tagID = info.type
    if tagID == 6 or tagID == 10 then
        tagID = 2
    end
    tagID = tagID + 1
    fightTag:setTexture("ui_new/youli/img_event"..tagID..".png")
    local time = (MainPlayer:getNowtime() - info.battleTime/1000)/60
    local timeType = localizable.time_minute_txt..localizable.shalurecord_txt2
    if time < 0 then time = 1 end
    if time > 60 then 
        timeType = localizable.time_hour_txt..localizable.shalurecord_txt2
        time = time / 60
        if time > 24 then
            timeType = localizable.time_day_txt..localizable.shalurecord_txt2
            time = time / 24
        end
    end
    
    txt_time:setText(math.floor(time)..timeType)
    local str = "+"
    if tagID-1 == 3 or tagID-1 == 11 or tagID-1 == 7 then
        info.massacreValue = 0 - info.massacreValue
        info.coin = 0 - info.coin
        info.experience = 0 - info.experience
        str = "-"
    end
    local str0 = str
    if info.massacreValue < 0 then
        str0 = ""
    end
    txt_shalu:setText(str0..info.massacreValue)

    str0 = str
    if info.coin < 0 then
        str0 = ""
    end
    txt_tongbi:setText(str0..info.coin)

    str0 = str
    if info.experience < 0 then
        str0 = ""
    end
    txt_yueli:setText(str0..info.experience)
end

function ShaLuRecordLayer.onReportBtnClick(btn)
    local reProtIndex = btn.reProtIndex
    AdventureManager:openFightRecordByIndex( reProtIndex )
end
return ShaLuRecordLayer