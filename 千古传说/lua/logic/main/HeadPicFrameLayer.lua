--[[
******更换头像框层*******

	-- by ChiKui Peng
	-- 2016/3/7
]]
local HeadPicFrameLayer = class("HeadPicFrameLayer", BaseLayer)

function HeadPicFrameLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.main.HeadPorait")
end

function HeadPicFrameLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.Panel_list = TFDirector:getChildByPath(ui, 'Panel_list')
    self.img_di1 = TFDirector:getChildByPath(ui, 'img_di1')
    self.img_di2 = TFDirector:getChildByPath(ui, 'img_di2')
    self:initTableView()

end

function HeadPicFrameLayer:initTableData()
    local unlockedList = HeadPicFrameManager:getUnlockedList() or {}
    local lockedList = HeadPicFrameManager:getLockedList() or {}

    local sortFunc1 = function (data1,data2)
        local FrameData1 = HeadPicFrameData:objectByID(data1.id)
        local FrameData2 = HeadPicFrameData:objectByID(data2.id)
        if FrameData1.weight_1 <= FrameData2.weight_1 then
            return true
        end
        return false
    end

    local sortFunc2 = function (data1,data2)
        local FrameData1 = HeadPicFrameData:objectByID(data1.id)
        local FrameData2 = HeadPicFrameData:objectByID(data2.id)
        if FrameData1.weight_2 <= FrameData2.weight_2 then
            return true
        end
        return false
    end
    table.sort( unlockedList, sortFunc1 )
    table.sort( lockedList, sortFunc2 )

    local tList = {}
    --tList[1] = {t = 0,value = {txt="已解锁头像框"}};
    tList[1] = {t = 0,value = {txt=localizable.HeadPicFrame_text1}};
    for i=1,#unlockedList do
        local frameData = HeadPicFrameData:objectByID(unlockedList[i].id)
        if frameData.visible == 1 then
            tList[ 1 + #tList ] = {t = 1,value = unlockedList[i]}
        end
    end
    --tList[ 1 + #tList ] = {t = 0,value = {txt="未解锁头像框"}};
    tList[ 1 + #tList ] = {t = 0,value = {txt=localizable.HeadPicFrame_text2}};
    for i=1,#lockedList do
        local frameData = HeadPicFrameData:objectByID(lockedList[i].id)
        if frameData.visible == 1 then
            tList[ 1 + #tList ] = {t = 2,value = lockedList[i]}
        end
    end
    tList[ 1 + #tList ] = {t = -1,value = {}};
    self.dataList = tList
end

function HeadPicFrameLayer:initTableView()
    self:initTableData()
    local  tableView =  TFTableView:create()

    self.tableView = tableView
    tableView:setTableViewSize(self.Panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

    self.tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, handler(HeadPicFrameLayer.cellSizeForTable,self))
    self.tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, handler(HeadPicFrameLayer.tableCellAtIndex,self))
    self.tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, handler(HeadPicFrameLayer.numberOfCellsInTableView,self))
    self.tableView:addMEListener(TFTABLEVIEW_SCROLL, handler(HeadPicFrameLayer.tableScroll,self))
    self.Panel_list:addChild(tableView)
    self.tableView:reloadData()
    local index = 0
    for i=1,#self.dataList do
        local data = self.dataList[i]
        if data.t == 1 then
            if data.value.firstGet == true then
                index = i;
                break;
            end
        end
        if data.t == 2 then
            break;
        end
    end
    if index == 0 then
        return
    end
    local height = 60 + 30 + (#self.dataList - index + 1 - 2)*120
    local offSet = self.Panel_list:getContentSize().height - height
    if offSet > 0 then offSet = 0 end
    self.tableView:setContentOffset(ccp(0,offSet))
end

function HeadPicFrameLayer:cellSizeForTable(table,idx)
    if self.dataList[idx+1].t == 0 then
        return 60,460
    elseif self.dataList[idx+1].t == -1 then
        return 30,460
    end
    return 120,460
end

function HeadPicFrameLayer:tableCellAtIndex(table, idx)
    idx = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
    end
    self:setCellInfo(cell,idx)
    return cell
end

function HeadPicFrameLayer:numberOfCellsInTableView(table)
    return #self.dataList
end

function HeadPicFrameLayer:tableScroll(table)
    local size = self.tableView:getTableViewSize()
    local size2 = self.tableView:getContentSize()
    local pos = self.tableView:getContentOffset()
    if pos.y == size.height - size2.height then
        self.img_di2:setVisible(false)
    else
        self.img_di2:setVisible(true)
    end
    if pos.y == 0 then
        self.img_di1:setVisible(false)
    else
        self.img_di1:setVisible(true)
    end
end

function HeadPicFrameLayer:removeUI()
    if HeadPicFrameManager:isClearRed() == true then
        HeadPicFrameManager:ClearRed()
    end
    if self.bCheck == true then
        HeadPicFrameManager:checkValidity()
    end
    self.super.removeUI(self)
end

function HeadPicFrameLayer:setCellInfo(cell,idx)
    data = self.dataList[idx]
    if data.t == 0 then
        self:setTitleCellInfo(cell,data)
    elseif data.t == 1 then
        self:setUnlockedCellInfo(cell,data,idx)
    elseif data.t == 2 then
        self:setLockedCellInfo(cell,data,idx)
    elseif data.t == -1 then
        self:setBottomEmptyInfo(cell)
    end
end

function HeadPicFrameLayer:setBottomEmptyInfo(cell)
    local frameNode = cell:getChildByTag(101)
    local titleNode = cell:getChildByTag(100)
    if nil ~= titleNode then
        titleNode:setVisible(false)
    end
    if nil ~= frameNode then
        frameNode:setVisible(false)
    end
end

function HeadPicFrameLayer:setTitleCellInfo(cell,data)
    local frameNode = cell:getChildByTag(101)
    local titleNode = cell:getChildByTag(100)
    if nil == titleNode then
        titleNode = createUIByLuaNew("lua.uiconfig_mango_new.main.TitleCell")
        titleNode:setTag(100)
        cell:addChild(titleNode)
    end
    titleNode:setVisible(true)
    local txt_title = TFDirector:getChildByPath(titleNode, "txt_yongyou")
    txt_title:setText(data.value.txt)
    if nil ~= frameNode then
        frameNode:setVisible(false)
    end
end

function HeadPicFrameLayer:setUnlockedCellInfo(cell,data,idx)
    local frameNode = cell:getChildByTag(101)
    local titleNode = cell:getChildByTag(100)
    if nil ~= titleNode then
        titleNode:setVisible(false)
    end
    if nil == frameNode then
        frameNode = createUIByLuaNew("lua.uiconfig_mango_new.main.FrameCell")
        frameNode:setTag(101)
        cell:addChild(frameNode)
    end
    frameNode:setVisible(true)
    frameNode:stopAllActions()
    local img_lock = TFDirector:getChildByPath(frameNode, "img_suo")
    local img_frame = TFDirector:getChildByPath(frameNode, "img_kuang")
    local txt_time = TFDirector:getChildByPath(frameNode, "txt_time")
    local txt_num = TFDirector:getChildByPath(frameNode, "txt_numb")
    local txt_name = TFDirector:getChildByPath(frameNode, "txt_mingcheng")
    local btn_Node = TFDirector:getChildByPath(frameNode, "icon_cell")
    local btn_info = TFDirector:getChildByPath(frameNode, "btn_info")
    btn_Node.idx = idx
    btn_info.idx = idx
    local frameId = data.value.id
    
    local frameData = HeadPicFrameData:objectByID(frameId)
    img_lock:setVisible(false)
    Public:addFrameImg(img_frame,frameId)
    txt_time:setText(self:getFrameTime(data))
    txt_num:setText("")
    txt_name:setText(frameData.name)
    local callFunc = function()
        txt_time:setText(self:getFrameTime(data))
    end
    local seq = CCSequence:createWithTwoActions(CCDelayTime:create(1),CCCallFunc:create(callFunc))
    frameNode:runAction(CCRepeatForever:create(seq))
    btn_info:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(HeadPicFrameLayer.OnLockedFrameClick,self)),1)
    btn_Node:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(HeadPicFrameLayer.OnUnlockedFrameClick,self)),1)
    if frameId == 1 then
        btn_info:setVisible(false)
    else
        btn_info:setVisible(true)
    end
    CommonManager:setRedPoint(img_frame, data.value.firstGet,"isFirstGet",ccp(14,11))
end

function HeadPicFrameLayer:setLockedCellInfo(cell,data,idx)
    local frameNode = cell:getChildByTag(101)
    local titleNode = cell:getChildByTag(100)
    if nil ~= titleNode then
        titleNode:setVisible(false)
    end
    if nil == frameNode then
        frameNode = createUIByLuaNew("lua.uiconfig_mango_new.main.FrameCell")
        frameNode:setTag(101)
        cell:addChild(frameNode)
    end
    frameNode:setVisible(true)
    frameNode:stopAllActions()
    local img_lock = TFDirector:getChildByPath(frameNode, "img_suo")
    local img_frame = TFDirector:getChildByPath(frameNode, "img_kuang")
    local txt_time = TFDirector:getChildByPath(frameNode, "txt_time")
    local txt_num = TFDirector:getChildByPath(frameNode, "txt_numb")
    local txt_name = TFDirector:getChildByPath(frameNode, "txt_mingcheng")
    local btn_Node = TFDirector:getChildByPath(frameNode, "icon_cell")
    local btn_info = TFDirector:getChildByPath(frameNode, "btn_info")
    btn_Node.idx = idx
    btn_info.idx = idx
    local frameId = data.value.id
    btn_info:setVisible(true)
    
    local frameData = HeadPicFrameData:objectByID(frameId)
    img_lock:setVisible(true)
    Public:addFrameImg(img_frame,frameId)
    txt_time:setText("")
    txt_num:setText(self:getCurFrameInfo(data))
    txt_name:setText(frameData.name)
    btn_info:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(HeadPicFrameLayer.OnLockedFrameClick,self)),1)
    btn_Node:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(HeadPicFrameLayer.OnLockedFrameClick,self)),1)
    CommonManager:setRedPoint(img_frame, false,"isFirstGet",ccp(0,0))
end

function HeadPicFrameLayer:getCurFrameInfo(data)
    local frameData = HeadPicFrameData:objectByID(data.value.id)
    if frameData == nil then
        return ""
    end
    if frameData.show_type == 2 then                    --服务器回发进度
        local txt = frameData.prefix.."(%d/%d)"
        txt = string.format(txt,data.value.currentNum,frameData.gain_way_num)
        return txt
    elseif frameData.show_type == 1 then                --不需要显示数量
        return ""
    elseif frameData.show_type == 3 then                --道具 自己获取当前进度
        local txt = frameData.prefix.."(%d/%d)"
        local num = BagManager:getItemNumById(frameData.gain_way_id)
        txt = string.format(txt,num,frameData.gain_way_num)
        return txt
    end
end

function HeadPicFrameLayer:OnUnlockedFrameClick(sender)
    print("OnUnlockedFrameClick")
    local data = self.dataList[sender.idx]
    local frameData = HeadPicFrameData:objectByID(data.value.id)
    if frameData == nil then
        return
    end
    local validityTime = frameData.validity_hour
    if validityTime > 0 then
        local leftTime =  data.value.expireTime / 1000 - MainPlayer:getNowtime()
        if leftTime <= 0 then
            --toastMessage("该头像框已过期")
            toastMessage(localizable.HeadPicFrame_text3)
            return
        end
    end
    HeadPicFrameManager:requestChangeHeadPicFrame(data.value.id)
end

function HeadPicFrameLayer:OnLockedFrameClick(sender)
    local frameId = self.dataList[sender.idx].value.id
    local frameData = HeadPicFrameData:objectByID(frameId)
    if frameData == nil then
        return
    end
    toastMessage(frameData.desc)
end

function HeadPicFrameLayer:getFrameTime( data )
    local frameData = HeadPicFrameData:objectByID(data.value.id)
    if frameData == nil then
        return ""
    end
    local validityTime = frameData.validity_hour
    if validityTime <= 0 then
        return ""
    end
    --local txt = "剩余时间：%02d:%02d"
    local txt = localizable.HeadPicFrame_text4
    
    local leftTime =  data.value.expireTime / 1000 - MainPlayer:getNowtime()
    if leftTime <= 0 then
        self.bCheck = true
        print("leftTime  "..leftTime.."  expireTime  "..data.value.expireTime.."  getNowtime  "..MainPlayer:getNowtime())
        --return "已超过有效期"
        return localizable.HeadPicFrame_text6
    end
    local nH = math.floor(leftTime / 3600)
    local nM = math.floor((leftTime - nH * 3600) / 60)
    local nS = math.floor(leftTime - nH * 3600 - nM * 60)
    local value = {[1] = nH,[2] = nM}
    if nH <= 0 then
        value = {[1] = nM,[2] = nS}
    end
    return string.format(txt,value[1],value[2])
end

function HeadPicFrameLayer:registerEvents()
    self.super.registerEvents(self)
    self.setFrameHandler = function ( data )
        self:handleClose()
    end
    TFDirector:addMEGlobalListener(HeadPicFrameManager.Change_Frame ,self.setFrameHandler)
end

function HeadPicFrameLayer:removeEvents()
    TFDirector:removeMEGlobalListener(HeadPicFrameManager.Change_Frame ,self.setFrameHandler)
    self.super.removeEvents(self)
end

function HeadPicFrameLayer:dispose()
    self.super.dispose(self)
end

function HeadPicFrameLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

-----断线重连支持方法
function HeadPicFrameLayer:onShow()
    self.super.onShow(self)
end

function HeadPicFrameLayer:refreshUI()

end

return HeadPicFrameLayer
