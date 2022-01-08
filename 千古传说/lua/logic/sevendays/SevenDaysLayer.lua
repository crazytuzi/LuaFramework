--[[
******帮助列表*******

    -- by King
    -- 2015/9/8
]]
local SevenDaysLayer = class("SevenDaysLayer", BaseLayer)

CREATE_SCENE_FUN(SevenDaysLayer)
CREATE_PANEL_FUN(SevenDaysLayer)



local halfPrizeShopData = SevenDaysManager.SevenDayShopConfig --require("lua.table.t_s_7_days_discount")

function SevenDaysLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.sevendays.sevenDaysLayer")
end

function SevenDaysLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close')
    self.list_title  = TFDirector:getChildByPath(ui, 'Panel_title')
    self.Panel_Area  = TFDirector:getChildByPath(ui, 'Panel_Area')

    self.btn_title   = TFDirector:getChildByPath(ui, 'btn_title')
    local img_yuzhui  = TFDirector:getChildByPath(self.btn_title, 'img_yuzhui')
    self.btn_title:setVisible(false)
    img_yuzhui:setVisible(false)

    self.daysButton = {}
    for i=1,7 do
        self.daysButton[i] = TFDirector:getChildByPath(ui, 'btn_day'..i)
        self.daysButton[i].dayIndex = i
    end

    self.dayIndex = 1

    -- 对应按钮的索引
    self.curChooseDayIndex  = 0
    self:drawDefault(self.dayIndex)

    self.txt_timedesc  = TFDirector:getChildByPath(ui, 'txt_timedesc')
    self.txt_timecount = TFDirector:getChildByPath(ui, 'txt_timecount')

    self.txt_timedesc:setVisible(false)
    self.txt_timecount:setVisible(false)
    -- print("该玩家注册的天数：",MainPlayer:getRegisterDay())
    print("已经开服的天数：",MainPlayer:getRegisterDay())
end

function SevenDaysLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
end

function SevenDaysLayer:refreshBaseUI()

    self:refreshButton()
end


function SevenDaysLayer:removeUI()
   self.super.removeUI(self)
end

--注册事件
function SevenDaysLayer:registerEvents()
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    for i=1,7 do
        self.daysButton[i].index = i
        self.daysButton[i].logic = self
        self.daysButton[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DayBtnClickHandle),1)
    end

    self.updateTask = function(event)
        local taskid = event.data[1].id

        local task = SevenDaysManager.sevenTaskList:objectByID(taskid)
        if task then
            -- 半价商店
            if task.type == 9999 then
                self:drawHalfPrizeShop()
            -- 月卡
            elseif task.type == 1010 or task.type == 1011 then
                self:drawMonthCard()
            -- 其他七日任务
            else
                if self.taskTableView and self.taskTableView:isVisible() then
                    local titleType = self.titleList[self.titleIndex]

                    self.taskList = SevenDaysManager:getTasksWithDayIndex(self.curChooseDayIndex , titleType)
                    self:drawTaskList()
                end
            end

        else
            self:drawTaskList()
        end

        -- 重绘标题
        self:drawTitleList()
        self:refreshButton()    
    end

    TFDirector:addMEGlobalListener(SevenDaysManager.UPDATETASK ,self.updateTask);


    local function sevenDayTimerEvent(sender)
        -- print("sender = ", sender)
        -- v.status    = status
        -- v.desc1     = timedesc1
        -- v.desc2     = timedesc2
        if sender == nil then
            return
        end

        local status = sender.status

        print("七日状态 = ", status)
        -- 0 关闭 ； 1 七天内 ； 2 过了七天 3天内
        if status == 1 then
            --self.txt_timedesc:setText("离活动结束:")
            self.txt_timedesc:setText(localizable.sevendays_activity_over)

        elseif status == 2 then
            --self.txt_timedesc:setText("离领奖结束:")
            self.txt_timedesc:setText(localizable.sevendays_getaward_over)
        end

        if self.txt_timecount then
            self.txt_timecount:setText(sender.desc1)
        end
        self.txt_timedesc:setVisible(true)
        self.txt_timecount:setVisible(true)
    end

    SevenDaysManager:addSevenDaysEvent(self, 2002, sevenDayTimerEvent)
end

function SevenDaysLayer:removeEvents()

    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(SevenDaysManager.UPDATETASK ,self.updateTask)
    self.updateTask = nil


    SevenDaysManager:removeOnlineRewardTimer(2002)
end

function SevenDaysLayer:refreshButton()
    for i=1,7 do
        local dayIndex = self.daysButton[i].dayIndex
        CommonManager:setRedPoint(self.daysButton[i], SevenDaysManager:checkRedPointWithDayIndex(dayIndex),"sevendyRed",ccp(0,-5))
    end
end

function SevenDaysLayer:drawDefault(index)
    if self.curChooseDayIndex == index then
        return
    end

    local btn = nil
    -- 绘制上面的按钮
    if self.btnLastIndex ~= nil then
        btn = self.daysButton[self.btnLastIndex]
        btn:setTextureNormal("ui_new/sevendays/tab"..self.btnLastIndex..".png")
    end

    self.btnLastIndex = index
    self.curChooseDayIndex  = index

    btn = self.daysButton[self.curChooseDayIndex]
    btn:setTextureNormal("ui_new/sevendays/tab"..self.btnLastIndex.."b.png")


    self:onClickDay(index)

end

function SevenDaysLayer:onClickDay(index)
    print("点击了第"..index.."天")

    SevenDaysManager:filterTaskData(index)

    self.titleIndex = 1
    self.titleList  = SevenDaysManager:getTitleWithDayIndex(index)

    self:drawTitleList()
    -- 
    local titleType = self.titleList[self.titleIndex]
    self.taskList = SevenDaysManager:getTasksWithDayIndex(self.curChooseDayIndex , titleType)
    self:drawTaskList()
end

function SevenDaysLayer.DayBtnClickHandle(sender)
    local self  = sender.logic
    local index = sender.index

    if self.curChooseDayIndex == index then
        return
    end

    if SevenDaysManager:getSevenDaysStatus(index) == false then
        --toastMessage("大侠请明天也要登录哦")
        toastMessage(localizable.sevendays_tomorrow_login)
        return
    end

    self:drawDefault(index)
end


function SevenDaysLayer:drawTitleList()
    if self.titleTableView ~= nil then
        self.titleTableView:reloadData()
        return
    end

    local  titleTableView =  TFTableView:create()
    titleTableView:setTableViewSize(self.list_title:getContentSize())
    -- titleTableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    titleTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    titleTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    titleTableView:setPosition(self.list_title:getPosition())
    self.titleTableView = titleTableView
    self.titleTableView.logic = self

    titleTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_title)
    titleTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_title)
    titleTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_title)
    titleTableView:reloadData()

    self.list_title:getParent():addChild(self.titleTableView,1)
end


function SevenDaysLayer.numberOfCellsInTableView_title(table)
    local self  = table.logic
    local num   = #self.titleList

    return num
end

function SevenDaysLayer.cellSizeForTable_title(table,idx)
    local self  = table.logic
    if idx + 1 == #self.titleList then return 110,114 end
    return 65, 114
end

function SevenDaysLayer.tableCellAtIndex_title(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        node = self.btn_title:clone()
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTitle))
    end

    node = cell:getChildByTag(617)

    local img_yuzhui  = TFDirector:getChildByPath(node, 'img_yuzhui')
    local isLast = idx + 1 == #self.titleList
    img_yuzhui:setVisible(isLast)
    if isLast then 
        node:setPosition(ccp(84, 75))
    else
        node:setPosition(ccp(84, 30))
    end
    node.index = idx + 1
    self:drawTitle(node)

    node:setVisible(true)
    cell:setZOrder(idx)
    return cell
end

function SevenDaysLayer:drawTitle(node)
    local index = node.index

    local titleType = self.titleList[index]
    local txt_title = TFDirector:getChildByPath(node, 'txt_title')
    
    txt_title:setText(SevenDaysManager:getTitleName(titleType))
    
    local normalPic = "ui_new/sevendays/stab1.png"
    local selectPic = "ui_new/sevendays/stab1b.png"

    if self.titleIndex == index then
        node:setTextureNormal(selectPic)
        node:setTexturePressed(selectPic)

        txt_title:setColor(ccc3(255, 255, 255))
    else
        node:setTextureNormal(normalPic)
        node:setTexturePressed(selectPic)

        txt_title:setColor(ccc3(61, 61, 61))
    end

    local dayIndex = self.curChooseDayIndex
    local bTitleHaveRedPoint = SevenDaysManager:checkRedPointWithTitle(dayIndex,titleType)

    -- print("dayIndex = ", dayIndex)
    -- print("titleType = ", titleType)
    -- print("bTitleHaveRedPoint = ", bTitleHaveRedPoint)
    CommonManager:setRedPoint(node, bTitleHaveRedPoint,"sevendyRed",ccp(2,-15))

end

function SevenDaysLayer.onClickTitle(sender)
    local self  = sender.logic
    local index = sender.index

    if self.titleIndex == index then
        return
    end

    self.titleIndex = index
    self:drawTitleList()

    local titleType = self.titleList[index]

    self.taskList = SevenDaysManager:getTasksWithDayIndex(self.curChooseDayIndex , titleType)

    if titleType == 16 then
        -- 每日半价
        self:drawHalfPrizeShop()
        if self.monthCardLayer then
            self.monthCardLayer:setVisible(false)
        end
        self.taskTableView:setVisible(false)
        self.shopLayer:setVisible(true)
    elseif titleType == 17 then
        -- 月卡
        self:drawMonthCard()
        if self.shopLayer then
            self.shopLayer:setVisible(false)
        end
        self.taskTableView:setVisible(false)
        self.monthCardLayer:setVisible(true)
    else
        self:drawTaskList()
        
        self.taskTableView:setVisible(true)
        if self.shopLayer then
            self.shopLayer:setVisible(false)
        end
        if self.monthCardLayer then
            self.monthCardLayer:setVisible(false)
        end
    end
end


function SevenDaysLayer:drawTaskList()
    if self.shopLayer then
        self.shopLayer:setVisible(false)
    end
    if self.monthCardLayer then
        self.monthCardLayer:setVisible(false)
    end
    if self.taskTableView ~= nil then
        self.taskTableView:reloadData()
        self.taskTableView:setScrollToBegin(false)


        self.taskTableView:setVisible(true)
        return
    end

    local  taskTableView =  TFTableView:create()
    taskTableView:setTableViewSize(self.Panel_Area:getContentSize())
    taskTableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    taskTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    taskTableView:setPosition(self.Panel_Area:getPosition())
    self.taskTableView = taskTableView
    self.taskTableView.logic = self

    taskTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable_task)
    taskTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex_task)
    taskTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView_task)
    taskTableView:reloadData()

    self.list_title:getParent():addChild(self.taskTableView,1)
end


function SevenDaysLayer.numberOfCellsInTableView_task(table)
    local self = table.logic

    return self.taskList:length()
end

function SevenDaysLayer.cellSizeForTable_task(table,idx)
    return 131, 729
end

function SevenDaysLayer.tableCellAtIndex_task(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = createUIByLuaNew("lua.uiconfig_mango_new.sevendays.sevenDaysCell")

        node:setPosition(ccp(5, 0))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        -- node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTask))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawTaskNode(node)

    node:setVisible(true)
    return cell
end

function SevenDaysLayer:drawTaskNode(node) 
    -- Public:ShowItemTipLayer(signData.reward_id, signData.reward_type)

    -- self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close')

    -- node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTask))

    local btn_get           = TFDirector:getChildByPath(node, 'btn_get')
    local btn_qianwang      = TFDirector:getChildByPath(node, 'btn_go')
    local img_lingqu        = TFDirector:getChildByPath(node, 'img_lingqu')
    local txt_title         = TFDirector:getChildByPath(node, 'lbl_task')
    local txt_progress      = TFDirector:getChildByPath(node, 'lbl_progress')

    btn_get:setVisible(false)
    btn_qianwang:setVisible(false)
    img_lingqu:setVisible(false)


    local taskConfig = self.taskList:objectAt(node.index)

    -- print("taskConfig.title = ", taskConfig.title)

    txt_title:setText(taskConfig.title)
    txt_title:setVisible(true)

    local task = SevenDaysManager:getTaskStauts(taskConfig.id)
    if task == nil then
        print("找不到该任务 taskid = ", taskConfig.id)
        return
    end
     -- required int32 taskid = 1    //成就id
    -- required int32 state = 2     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    -- required int32 currstep = 3  //当前进度
    -- required int32 totalstep = 4 //总进度    
    if task.state == 0 then
        btn_qianwang:setVisible(true)
        -- 群豪任务
        if taskConfig.tab == 7 then
            --txt_progress:setText("未完成(0/1)")
            txt_progress:setText(stringUtils.format(localizable.sevendays_task_radio,0,1))
        else
            --txt_progress:setText("未完成(".. task.currstep .."/".. task.totalstep ..")")
            txt_progress:setText(stringUtils.format(localizable.sevendays_task_radio, task.currstep , task.totalstep))
        end

    elseif task.state == 1 then
        btn_get:setVisible(true)
        --txt_progress:setText("已完成")
        txt_progress:setText(localizable.sevendays_over)

    elseif task.state == 2 then
        img_lingqu:setVisible(true)
        --txt_progress:setText("已完成")
        txt_progress:setText(localizable.sevendays_over)
    end


    btn_get.logic       = self
    btn_get.taskid      = taskConfig.id
    btn_qianwang.logic  = self
    btn_qianwang.taskConfig = taskConfig
    btn_qianwang.taskid = taskConfig.id

    -- btn_get:setVisible(false)
    btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTaskReward))
    btn_qianwang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTaskGoto))


    local reward_id = taskConfig.reward_id

    local itemList = RewardConfigureData:GetRewardItemListById(reward_id)


    local img_goods     = {}
    local txt_reward    = {}
    local img_quality    = {}
    for i=1,2 do
        img_quality[i] = TFDirector:getChildByPath(node, 'img_goods'..i)
        img_goods[i] = TFDirector:getChildByPath(img_quality[i], 'img_icon')
        txt_reward[i] = TFDirector:getChildByPath(img_quality[i], 'txt_num')

        img_quality[i]:setVisible(false)
    end

    -- 绘制奖励
    if itemList then
        for index=1,2 do
            local rewardItem = itemList:objectAt(index)
            if rewardItem == nil then
                return
            end

            img_quality[index]:setVisible(true)

            local itemInfo  = BaseDataManager:getReward(rewardItem)

            -- print("rewardItem.itemid = ", rewardItem.itemid)
            -- print("rewardItem.name = ", rewardItem.name)

            if itemInfo.type == EnumDropType.ROLE then
                local role      = RoleData:objectByID(itemInfo.itemid)
                local headIcon  = role:getIconPath()
                img_goods[index]:setTexture(headIcon)
            else
                img_goods[index]:setTexture(itemInfo.path)
                -- print("headIcon = ", itemInfo.path)
            end



            local path = GetColorIconByQuality(itemInfo.quality)
           
            if itemInfo.type == EnumDropType.GOODS then
                local itemDetail = ItemData:objectByID(itemInfo.itemid)
                if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
                    path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
                else
                    path =  GetColorIconByQuality(itemInfo.quality)
                end
            end

            txt_reward[index]:setText(string.format("%d", itemInfo.number))

            img_quality[index]:setTexture(path)

            
            Public:addPieceImg(img_goods[index],{type = itemInfo.type, itemid = itemInfo.itemid})

            img_quality[index].itemid = rewardItem.itemid
            img_quality[index].type   = rewardItem.type
            img_quality[index]:addMEListener(TFWIDGET_CLICK,
                audioClickfun(function(sender)
                    Public:ShowItemTipLayer(sender.itemid, sender.type)
            end),1)
            
        end

    end

end


-- function BloodReward.onlickPrize(sender)
--     local prizeIndex = sender.index
--     local self       = sender.logic
   
--     local prizeData = self.boxData[prizeIndex]
    
--     print("prizeData = ", prizeData)
--     Public:ShowItemTipLayer(prizeData.itemId, prizeData.type)
--     -- Public:ShowItemTipLayer(signData.reward_id, signData.reward_type)
-- end

function SevenDaysLayer.onClickTaskReward(sender)
    local self   = sender.logic
    local taskid = sender.taskid

    SevenDaysManager:getSevenDaysReward(taskid)
end

function SevenDaysLayer.onClickTaskGoto(sender)
    local self = sender.logic
    local taskData = sender.taskConfig

    TaskManager:CanGoToLayer(taskData, true)
end

function SevenDaysLayer:drawMonthCard()
    if self.monthCardLayer == nil then
        self.monthCardLayer = createUIByLuaNew("lua.uiconfig_mango_new.sevendays.sevenDaysyueka")
        self.monthCardLayer:setPosition(ccp(200, 0))
        self.list_title:getParent():addChild(self.monthCardLayer,1)
    end

    local btn_get           = TFDirector:getChildByPath(self.monthCardLayer, 'btn_get')
    local btn_qianwang      = TFDirector:getChildByPath(self.monthCardLayer, 'btn_go')
    local img_lingqu        = TFDirector:getChildByPath(self.monthCardLayer, 'img_lingqu')
    local txt_title         = TFDirector:getChildByPath(self.monthCardLayer, 'lbl_task')
    local txt_progress      = TFDirector:getChildByPath(self.monthCardLayer, 'lbl_progress')

    btn_get:setVisible(false)
    btn_qianwang:setVisible(false)
    img_lingqu:setVisible(false)


    local taskConfig = self.taskList:objectAt(1)

    -- print("taskConfig.title = ", taskConfig.title)

    txt_title:setText(taskConfig.title)
    txt_title:setVisible(true)

    local task = SevenDaysManager:getTaskStauts(taskConfig.id)
    if task == nil then
        print("找不到该任务 taskid = ", taskConfig.id)
        return
    end
     -- required int32 taskid = 1    //成就id
    -- required int32 state = 2     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    -- required int32 currstep = 3  //当前进度
    -- required int32 totalstep = 4 //总进度    
    if task.state == 0 then
        btn_qianwang:setVisible(true)
        -- 群豪任务
        if taskConfig.tab == 7 then
            --txt_progress:setText("未完成(0/1)")
            txt_progress:setText(stringUtils.format(localizable.sevendays_task_radio,0,1))

        else
            --txt_progress:setText("未完成(".. task.currstep .."/".. task.totalstep ..")")
            txt_progress:setText(stringUtils.format(localizable.sevendays_task_radio, task.currstep , task.totalstep))

        end

    elseif task.state == 1 then
        btn_get:setVisible(true)
        --txt_progress:setText("已完成")
        txt_progress:setText(localizable.sevendays_over)

    elseif task.state == 2 then
        img_lingqu:setVisible(true)
        --txt_progress:setText("已完成")
        txt_progress:setText(localizable.sevendays_over)
        
    end


    btn_get.logic       = self
    btn_get.taskid      = taskConfig.id
    btn_qianwang.logic  = self
    btn_qianwang.taskConfig = taskConfig
    btn_qianwang.taskid = taskConfig.id

    -- btn_get:setVisible(false)
    btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTaskReward))
    btn_qianwang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTaskGoto))


    local reward_id = taskConfig.reward_id

    local itemList = RewardConfigureData:GetRewardItemListById(reward_id)


    local img_goods     = {}
    local txt_reward    = {}
    local img_quality    = {}
    for i=1,2 do
        img_quality[i] = TFDirector:getChildByPath(self.monthCardLayer, 'img_goods'..i)
        img_goods[i] = TFDirector:getChildByPath(img_quality[i], 'img_icon')
        txt_reward[i] = TFDirector:getChildByPath(img_quality[i], 'txt_num')

        img_quality[i]:setVisible(false)
    end

    -- 绘制奖励
    if itemList then
        for index=1,2 do
            local rewardItem = itemList:objectAt(index)
            if rewardItem == nil then
                return
            end

            img_quality[index]:setVisible(true)

            local itemInfo  = BaseDataManager:getReward(rewardItem)

            -- print("rewardItem.itemid = ", rewardItem.itemid)
            -- print("rewardItem.name = ", rewardItem.name)

            if itemInfo.type == EnumDropType.ROLE then
                local role      = RoleData:objectByID(itemInfo.itemid)
                local headIcon  = role:getIconPath()
                img_goods[index]:setTexture(headIcon)
            else
                img_goods[index]:setTexture(itemInfo.path)
                -- print("headIcon = ", itemInfo.path)
            end



            local path = GetColorIconByQuality(itemInfo.quality)
           
            if itemInfo.type == EnumDropType.GOODS then
                local itemDetail = ItemData:objectByID(itemInfo.itemid)
                if itemDetail ~= nil and itemDetail.type == EnumGameItemType.Piece then
                    path =  GetBackgroundForFragmentByQuality(itemInfo.quality)
                else
                    path =  GetColorIconByQuality(itemInfo.quality)
                end
            end

            txt_reward[index]:setText(string.format("%d", itemInfo.number))

            img_quality[index]:setTexture(path)

            
            Public:addPieceImg(img_goods[index],{type = itemInfo.type, itemid = itemInfo.itemid})

            img_quality[index].itemid = rewardItem.itemid
            img_quality[index].type   = rewardItem.type
            img_quality[index]:addMEListener(TFWIDGET_CLICK,
                audioClickfun(function(sender)
                    Public:ShowItemTipLayer(sender.itemid, sender.type)
            end),1)
            
        end

    end
end

function SevenDaysLayer:drawHalfPrizeShop()
    if self.shopLayer == nil then
        self.shopLayer = createUIByLuaNew("lua.uiconfig_mango_new.sevendays.sevenDaysShop")
        self.shopLayer:setPosition(ccp(200, 0))
        self.list_title:getParent():addChild(self.shopLayer,1)
    end

    -- 按钮
    local btn_buy       = TFDirector:getChildByPath(self.shopLayer, 'btn_buy')
    local img_buy       = TFDirector:getChildByPath(self.shopLayer, 'img_buy')
    
    -- 物品信息
    local img_quality   = TFDirector:getChildByPath(self.shopLayer, 'btn_icon')
    local img_icon      = TFDirector:getChildByPath(self.shopLayer, 'img_icon')
    local txt_number    = TFDirector:getChildByPath(self.shopLayer, 'txt_number')
    local txt_name      = TFDirector:getChildByPath(self.shopLayer, 'txt_name')

    -- 原价
    local img_cost1     = TFDirector:getChildByPath(self.shopLayer, 'img_price1')
    local img_res1      = TFDirector:getChildByPath(img_cost1, 'img_res_icon')
    local txt_cost1     = TFDirector:getChildByPath(img_cost1, 'txt_price')

    -- 现价
    local img_cost2     = TFDirector:getChildByPath(self.shopLayer, 'img_price2')
    local img_res2      = TFDirector:getChildByPath(img_cost2, 'img_res_icon')
    local txt_cost2     = TFDirector:getChildByPath(img_cost2, 'txt_price')
    
    -- 最下面的描述
    local txt_content   = TFDirector:getChildByPath(self.shopLayer, 'txt_content')

    local task      = self.taskList:objectAt(1)
    local taskid    = task.id
    local rewardid  = task.reward_id

    local taskStatus = SevenDaysManager:getTaskStauts(taskid)
    if taskStatus == nil then
        print("找不到该任务 taskid = ", taskid)
        return
    end
     -- required int32 taskid = 1    //成就id
    -- required int32 state = 2     //状态 0：未完成 1:已完成但未领取奖励  2:已完成并领取过奖励
    -- required int32 currstep = 3  //当前进度
    -- required int32 totalstep = 4 //总进度



    local rewardData = halfPrizeShopData:objectByID(rewardid)

    img_res1:setTexture(GetResourceIcon(rewardData.consume_type))
    img_res2:setTexture(GetResourceIcon(rewardData.consume_type))
    txt_cost1:setText(rewardData.old_price)
    txt_cost2:setText(rewardData.price)

    self.halfPrize = rewardData.price

    txt_number:setText(rewardData.res_num)
    
    local item = {itemid = rewardData.res_id, type = rewardData.res_type, number = rewardData.res_num}

    local info = BaseDataManager:getReward(item)
    if item.type == EnumDropType.GOODS then
        local goodsData = ItemData:objectByID(item.itemid)
        img_quality:setTextureNormal(GetBackgroundForGoods(goodsData))
    else
        img_quality:setTextureNormal(GetColorIconByQuality(info.quality))
    end
        

    txt_name:setText(info.name)
    img_icon:setTexture(info.path)

    if item.number > 1 then
        txt_number:setVisible(true)
        if item.number < 10000 then
            txt_number:setText("X" .. item.number)
        else
            --txt_number:setText("X" .. math.ceil(item.number/10000).."万")
            local floatValue = string.format("%.0f", math.ceil(item.number/10000))
            txt_number:setText("X" ..  stringUtils.format(localizable.rewardItemcommmon_wan, floatValue))

        end

        -- txt_number:setText("X" .. item.number)
    else
        txt_number:setVisible(false)
    end

    if item.type == EnumDropType.GOODS then
        local rewardItem = {itemid = item.itemid}

        local itemData   = ItemData:objectByID(item.itemid)

        if itemData.type == EnumGameItemType.Piece or itemData.type == EnumGameItemType.Soul then
            Public:addPieceImg(img_icon,rewardItem,true)
        else
            Public:addPieceImg(img_icon,rewardItem,false)
        end
    end

    

    local btn_node = TFDirector:getChildByPath(self.shopLayer, 'btn_node')
    btn_node.logic = self
    btn_node.reward_id = rewardData.res_id
    btn_node.reward_type = rewardData.res_type
    btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickItem))


    local sellNum = 0
    local itemSellInfo = SevenDaysManager:getShopItemInfo(rewardid)
    
    if itemSellInfo == nil then
        print("TMD 找不到半价商品id = ", rewardid)
    else
        sellNum = itemSellInfo.number
    end

    local itemCanBeBuyNum = rewardData.max_num - sellNum
    --local content = string.format("仅限前%d人购买(剩余%d件)", rewardData.max_num, itemCanBeBuyNum)
    local content = stringUtils.format(localizable.sevendays_buy, rewardData.max_num, itemCanBeBuyNum)
    
    txt_content:setText(content)



    btn_buy.logic = self
    btn_buy.taskid = taskid
    btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickBuyHalfShop))

    print("半价商品的状态",taskStatus.state)
        -- 未买
    if taskStatus.state == 2 then
        -- btn_buy:setGrayEnabled(false)        
        btn_buy:setVisible(false)
        img_buy:setVisible(true)

    -- 已买
    -- elseif taskStatus.state == 2 then
    else
        -- btn_buy:setGrayEnabled(true)
        btn_buy:setVisible(true)
        img_buy:setVisible(false)

        if itemCanBeBuyNum > 0 then
            btn_buy:setGrayEnabled(false)
            btn_buy:setTouchEnabled(true)
        else
            btn_buy:setGrayEnabled(true)
            btn_buy:setTouchEnabled(false)
        end
    end 
end

function SevenDaysLayer.onClickItem(sender)
    local self = sender.logic

    Public:ShowItemTipLayer(sender.reward_id, sender.reward_type)
end

function SevenDaysLayer.onClickBuyHalfShop(sender)
    local self   = sender.logic
    local taskid = sender.taskid


    if MainPlayer:isEnoughSycee(self.halfPrize, true) then
            
        SevenDaysManager:getSevenDaysReward(taskid)
    end
    -- if self.halfPrize 
    -- SevenDaysManager:getSevenDaysReward(taskid)
end


return SevenDaysLayer