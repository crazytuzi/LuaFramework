
local TaskLayer = class("TaskLayer", BaseLayer)

function TaskLayer:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.task.TaskLayer")
end

function TaskLayer:loadData(data)
    self.taskType = data
    self:RefreshUI()
end

function TaskLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.listPanel = TFDirector:getChildByPath(ui, 'listPanel')
    self.titleImg = TFDirector:getChildByPath(ui, 'titleImg')
    self.closeBtn = TFDirector:getChildByPath(ui, 'closeBtn')
    self.img_done = TFDirector:getChildByPath(ui, 'img_done')
end

function TaskLayer:registerEvents(ui)
    self.super.registerEvents(self)

    self.closeBtn:setClickAreaLength(100)
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn)
end

function TaskLayer:removeUI()
    self.super.removeUI(self)
end

function TaskLayer:refreshBaseUI()
end

function TaskLayer:RefreshUI()
    TaskManager:sort()
    if self.taskType ~= 1 then
        self.titleImg:setTexture("ui_new/task/cj_jiangli.png")
    else
        self.titleImg:setTexture("ui_new/task/cj_cjjiangli.png")
    end

    if self.taskTableView == nil then
        self.taskTableView = TFTableView:create()
        self.taskTableView.logic = self
        self.taskTableView:setTableViewSize(self.listPanel:getSize())
        self.taskTableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
        self.taskTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)

        self.taskTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, TaskLayer.cellSizeForTable)
        self.taskTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, TaskLayer.tableCellAtIndex)
        self.taskTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, TaskLayer.numberOfCellsInTableView)

        self.listPanel:addChild(self.taskTableView)
    end
    
    self.taskTableView:reloadData()
    local taskNum = TaskManager:GetTaskNum(self.taskType)
    if taskNum == 0 then
        self.img_done:setVisible(true)
    else
        self.img_done:setVisible(false)
    end
end

function TaskLayer.cellSizeForTable(table,idx)
    return 347,170
end

function TaskLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        local node = createUIByLuaNew("lua.uiconfig_mango_new.task.TaskItem")
        cell:addChild(node)
        node.logic = self
        cell.node = node
        -- cell = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaZhanbaoCell1")
    -- else
    --     cell:removeAllChildren()
    end

    table.logic:SetTaskCell(cell, idx)

    return cell
end

function TaskLayer:SetTaskCell(cell, cellIndex)
    local taskInfo = TaskManager:GetTaskInfo(self.taskType, cellIndex+1)
    if taskInfo == nil then
        return
    end

    local taskData = TaskData:objectByID(taskInfo.taskid)
    if nil == taskData then
        return
    end

    local node = cell.node
    local taskNameLabel = TFDirector:getChildByPath(node, 'Label_Name')
    taskNameLabel:setText(taskData.name)

    local descLabel = TFDirector:getChildByPath(node, 'Text_Info')
    descLabel:setText(taskData.desc)

    local rewardList = RewardConfigureData:GetRewardItemListById(taskData.reward_id)
    if rewardList ~= nil then
        for i=1, 2 do
            local rewardData = rewardList:getObjectAt(i)
            local panelName = "Panel_Jiangli_" .. i
            local rewardPanel = TFDirector:getChildByPath(node, panelName)
            rewardPanel:setVisible(rewardData ~= nil)

            if rewardData then
                local rewardInfo = BaseDataManager:getReward(rewardData)
                local rewardItemBg = TFDirector:getChildByPath(rewardPanel, "Img_Jianglidi")
                rewardItemBg:removeAllChildren()
                rewardItemBg:setTexture(GetColorIconByQuality_58(rewardInfo.quality))

                local bMax = MainPlayer:bMaxLevel()
                local rewardItemImage
                if bMax and rewardInfo.type == EnumDropType.EXP then
                    rewardItemImage = TFImage:create("ui_new/common/qhp_tb_icon.png")
                    rewardItemImage:addMEListener(TFWIDGET_CLICK,
                    audioClickfun(function()
                        Public:ShowItemTipLayer(1, 3)
                    end))
                else
                    rewardItemImage = TFImage:create(rewardInfo.path)
                    rewardItemImage:addMEListener(TFWIDGET_CLICK,
                    audioClickfun(function()
                        Public:ShowItemTipLayer(rewardInfo.itemid, rewardInfo.type)
                    end))
                end
                rewardItemImage:setPosition(ccp(0, 0))
                rewardItemImage:setScale(0.5)
                rewardItemBg:addChild(rewardItemImage)
                rewardItemImage:setTouchEnabled(true)

                local rewardLabel = TFDirector:getChildByPath(rewardPanel, "Label_Jianglinum")
                if rewardInfo.type == EnumDropType.EXP then                               
                    local muilt = ConstantData:objectByID("Player.Exp.Power.Multiple")
                    local exp = MainPlayer:getLevel() * muilt.value *rewardInfo.number                
                    --
                    if bMax then
                        local muilt = ConstantData:objectByID("Experience.Change.Money").value
                        exp = exp * muilt
                    end
                    rewardLabel:setText("X".. exp)
                else
                    rewardLabel:setText("X"..rewardInfo.number)
                end

                local itemDetail = ItemData:objectByID(rewardInfo.itemid)
                if itemDetail then
                    if itemDetail.kind == 3 and itemDetail.type == 7 then

                    else
                        Public:addPieceImg(rewardItemImage, rewardData);
                    end
                else
                    Public:addPieceImg(rewardItemImage, rewardData);
                end
            end
        end
    end

    local panelBar = TFDirector:getChildByPath(node, "Panel_Jindu")
    panelBar:setVisible(taskInfo.state == 0)

    local goBtn = TFDirector:getChildByPath(node, "Button_Qianwang")
    local getRewardBtn = TFDirector:getChildByPath(node, "Button_Lingqu")
    goBtn:setVisible(false)
    getRewardBtn:setVisible(false)

    if taskInfo.state == 0 then
        local progressBar = TFDirector:getChildByPath(node, "LoadingBar_Jindutiao")
        progressBar:setPercent(taskInfo.currstep/taskInfo.totalstep * 100)

        local stepLabel = TFDirector:getChildByPath(node, "Label_Num")
        stepLabel:setText(taskInfo.currstep.."/"..taskInfo.totalstep)

        if TaskManager:CanGoToLayer(taskData, false) then
            goBtn:setVisible(true)
            goBtn:addMEListener(TFWIDGET_CLICK,
            audioClickfun(function()
                -- if not self.bGuideMode then
                PlayerGuideManager:showNextGuideStep_taskGoto()
                self:SetGuideMode(false)
                TaskManager:CanGoToLayer(taskData, true)
                -- end 
            end),1)
        end
    elseif taskInfo.state == 1 then
        getRewardBtn:setVisible(true)
        getRewardBtn:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            showLoading()
            self:SetGuideMode(false)
            TFDirector:send(c2s.GET_TASK_REWARD, {taskInfo.taskid})
        end),1)

        if getRewardBtn.effect then 
            getRewardBtn:removeChild(getRewardBtn.effect)
            getRewardBtn.effect = nil
        end
        Public:addBtnWaterEffect(getRewardBtn, true, 0)
        CommonManager:updateRedPoint(getRewardBtn, TaskManager:isCanGetReward(taskInfo.taskid),ccp(0,0))
    end

    local taskIconImage = TFDirector:getChildByPath(node, "Img_Taskicon")
    taskIconImage:setTexture("icon/task/"..taskData.icon_id..".png")
end

function TaskLayer.numberOfCellsInTableView(table)
    local taskNum = TaskManager:GetTaskNum(table.logic.taskType)
    return taskNum
end

function TaskLayer:SetGuideMode(bGuideMode)
    self.bGuideMode = bGuideMode
    if bGuideMode then
        self.taskTableView:setInertiaScrollEnabled(false)
    else
        self.taskTableView:setInertiaScrollEnabled(true)
    end
end

return TaskLayer