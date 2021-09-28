local btnCloseRes = {
    normal   =  "#win_base_close.png",
    pressed  =  "#win_base_close.png",
    disabled =  "#win_base_close.png"
}

local goldStateRes = {
    normal   =  "#gold_close.png",
    pressed  =  "#gold_open.png",
    disabled =  "#gold_none.png"
}

local RADIO_BUTTON_IMAGES = {
    task = {
        off          = "#task_p.png",
        off_pressed  = "#task_p.png",
        off_disabled = "#task_p.png",
        on           = "#task_n.png",
        on_pressed   = "#task_n.png",
        on_disabled  = "#task_n.png",
    },
    road = {
        off          = "#road_p.png",
        off_pressed  = "#road_p.png",
        off_disabled = "#road_p.png",
        on           = "#road_n.png",
        on_pressed   = "#road_n.png",
        on_disabled  = "#road_n.png",
    },
    collect = {
        off          = "#collect_p.png",
        off_pressed  = "#collect_p.png",
        off_disabled = "#collect_p.png",
        on           = "#collect_n.png",
        on_pressed   = "#collect_n.png",
        on_disabled  = "#collect_n.png",
    },
    activity = {
        off          = "#activity_p.png",
        off_pressed  = "#activity_p.png",
        off_disabled = "#activity_p.png",
        on           = "#activity_n.png",
        on_pressed   = "#activity_n.png",
        on_disabled  = "#activity_n.png",
    }
     
}
local commonRes = {
    mainFrameRes     = "#win_base_bg2.png",
    mainInnerRes     = "#win_base_inner_bg_light.png",
    tableViewBngRes  = "#win_base_bg3.png",
    progressNoneBng  = "#progress_zero.png",
    progressFullBng  = "#progress_full.png"
}

local typeEnum = {
    task    = 1,
    road    = 2,
    collect = 3,
    activity = 4,
}
require ("utility.ResMgr")
require ("utility.richtext.globalFunction")

local TaskItemView = require("game.DialyTask.TaskItemView")
local GiftGetPopup = require("game.DialyTask.GiftGetPopup")
local ActivityItemView = require("game.DialyTask.ActivityItemView")
local RoadItemView = require("game.DialyTask.RoadItemView")

require ("game.DialyTask.TaskModel")

local TaskPopup = class("TaskPopup", function()
    return display.newLayer("TaskPopup")
end)

function TaskPopup:ctor(data,mainscene)
    self._mainFrameHeightOffset = 100
    self._mainFrameWidthOffset  = 20
    self._mainPopupSize = nil
    self._innerContainerBorderOffset = 10
    self._innerContainerHeight = 900
    self._innerContainerSize = nil

    self._titleDisOffsetOfTop = 20
    self._titleDisFontSize = 25
    self._checkBoxMargin = -24
    self._mianPopup = nil
    self._innerContainer = nil

    self._tableContainer = nil
    self._tableContainerSize = nil
    self._tableContainerBorderOffset = 10
    self._titleDisLabel = nil
    self._tableCellHeight = 130
    -- dump(data.rtnObj.missions)
    -- dump(data.rtnObj.extendMissionDefines)
    --测试数据
    self._dataSelf = data
    self._data = {}
    self.taskModel = TaskModel:getInstance():init(data)
    self._data = self.taskModel:getTaskList(1)

    self._mainMenuScene = mainscene
    self:setUpView()

end

function TaskPopup:update()

	--检查小红点
	local isShowMainTips = false
    for i = 1,2 do
    	local ret = TaskModel:getInstance():checkStateByType(i)
    	if ret then
    		isShowMainTips = true
    		if self.group:getButtonAtIndex(i):getChildByTag(111) then
    			self.group:getButtonAtIndex(i):removeChildByTag(111)
    		end
    		local tagnew = display.newSprite("#toplayer_mail_tip.png")
    		tagnew:setPosition(cc.p(150,10))
    		self.group:getButtonAtIndex(i):addChild(tagnew,0,111)
    	else 
    		if self.group:getButtonAtIndex(i):getChildByTag(111) then
    			self.group:getButtonAtIndex(i):removeChildByTag(111)
    		end
    	end
    end
    game.player.m_isShowChengzhang = isShowMainTips
    PostNotice(NoticeKey.MainMenuScene_ChengZhangZhilu)
    
    local leftAdgeOffset = 40
    local titleViewHeight = 100
    if not self.titleView  then
        self:reloadData(self._currentType)
        return
    end
    self._goldIcon:removeFromParent()
    local titleViewSize = self.titleView:getContentSize()
    local res 
    local xunhuanEffect 
    if self.taskModel:checkHasReword() then
        res = goldStateRes.pressed
        
    else 
        res = goldStateRes.normal
    end
    self._goldIcon = display.newSprite(res)
    self._goldIcon:setTouchEnabled(true)
    self._goldIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        local giftGetPopup = GiftGetPopup.new()
        self:addChild(giftGetPopup)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end)
    if not self.taskModel:checkHasReword() then
    	self._goldIcon:removeChildByTag(111)
    end
    self._goldIcon:setAnchorPoint(cc.p(0,0.5))
    self._goldIcon:setPosition(cc.p(leftAdgeOffset,titleViewSize.height / 2 - 20))
    self.titleView:addChild(self._goldIcon)
	
    self:reloadData(self._currentType)

end

function TaskPopup:setUpView()
    display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.addSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.addSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.png")
    display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
    display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
    display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")

	local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask)

    self._mianPopup = display.newScale9Sprite(commonRes.mainFrameRes, 0, 0, 
                    cc.size(display.width - self._mainFrameWidthOffset, display.height - 100))
                    :pos(display.cx,display.cy)
                    :addTo(self)
    self._mainPopupSize = self._mianPopup:getContentSize()
    self._innerContainerHeight = self._mainPopupSize.height - 140
    self._innerContainer = display.newScale9Sprite(commonRes.mainInnerRes, 0, 0, 
                        cc.size(self._mainPopupSize.width - self._innerContainerBorderOffset * 2, self._innerContainerHeight))
                        :pos(self._mainPopupSize.width / 2, self._innerContainerBorderOffset)
                        :addTo(self._mianPopup,1)
    self._innerContainerSize = self._innerContainer:getContentSize()
    self._innerContainer:setAnchorPoint(cc.p(0.5,0))                 
    --关闭按钮
    local closeBtn = cc.ui.UIPushButton.new(btnCloseRes)
    closeBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
            if event.name == "began" then 
                closeBtn:setScale(1.2)
                return true
            elseif event.name == "ended" then 
                closeBtn:setScale(1.0)
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
                self:closeSelf()
            end
        end)
    closeBtn:pos(self._mainPopupSize.width - 30, self._mainPopupSize.height- 30)
    closeBtn:addTo(self._mianPopup):setAnchorPoint(cc.p(0.5,0.5))

    --title标签
    self._titleDisLabel = ui.newBMFontLabel({
        text = "成长之路", 
        size = self._titleDisFontSize, 
        align = ui.TEXT_ALIGN_CENTER , 
        font = "res/fonts/font_title.fnt"})
        :pos( self._mainPopupSize.width / 2, 
         self._mainPopupSize.height - self._titleDisOffsetOfTop)
        :addTo(self._mianPopup)
    self._titleDisLabel:setAnchorPoint(cc.p(0.5,1))

    self:setUpTableView()
    self:setUpRadioBtns()


    --检查小红点
    for i = 1,2 do
    	local ret = TaskModel:getInstance():checkStateByType(i)
    	if ret then
    		if self.group:getButtonAtIndex(i):getChildByTag(111) then
    			self.group:getButtonAtIndex(i):removeChildByTag(111)
    		end
    		local tagnew = display.newSprite("#toplayer_mail_tip.png")
    		tagnew:setPosition(cc.p(150,10))
    		self.group:getButtonAtIndex(i):addChild(tagnew,0,111)
    	else 
    		if self.group:getButtonAtIndex(i):getChildByTag(111) then
    			self.group:getButtonAtIndex(i):removeChildByTag(111)
    		end
    	end
    end
end

function TaskPopup:closeSelf()
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.removeSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.removeSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.removeSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")

    self:removeFromParent()
    self = nil
end

--标签页
function TaskPopup:setUpRadioBtns()
    self.group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.task)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.road)
            :align(display.LEFT_CENTER))
        --:addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.collect)
		--align(display.LEFT_CENTER))
        
        :onButtonSelectChanged(function(event)
            self:reloadData(event.selected)
            for i = 1,self.group:getButtonsCount() do
                self.group:getButtonAtIndex(i):setZOrder(self.group:getButtonsCount() - i)
            end
            self.group:getButtonAtIndex(event.selected):setZOrder(10)
        end)
        :setButtonsLayoutMargin(0,-30,0,0)
        :addTo(self._mianPopup)
    self.group:setPosition(20, self._innerContainerSize.height + self._innerContainerBorderOffset - 10)

    --:addButton(cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES.activity)
            --:align(display.LEFT_CENTER))
	
           


    self.group:getButtonAtIndex(1):setButtonSelected(true)
end

--创建tableView
function TaskPopup:setUpTableView()
    self._tableContainer = display.newScale9Sprite(commonRes.tableViewBngRes, 0, 0, 
                        cc.size(self._innerContainerSize.width - self._tableContainerBorderOffset * 2, 
                        self._innerContainerSize.height - self._tableContainerBorderOffset * 2))
                        :pos(self._tableContainerBorderOffset, self._tableContainerBorderOffset)
                        :addTo(self._innerContainer)
    self._tableContainer:setAnchorPoint(cc.p(0,0))
    self._tableContainerSize = self._tableContainer:getContentSize()
    self:selectContent(self._tableContainer,index)
end


function TaskPopup:selectContent(innerContainer,index)
    local innerSize = innerContainer:getContentSize()
    self.tableView = CCTableView:create(cc.size(innerSize.width,innerSize.height - 40))
    self.tableView:setPosition(cc.p(0, 20))
    self.tableView:setAnchorPoint(cc.p(0.5,0.5))
    self.tableView:setDelegate()
    innerContainer:addChild(self.tableView)
    
    local listenerEnum = {
        CCTableView.kNumberOfCellsInTableView,
        CCTableView.kTableViewScroll,
        CCTableView.kTableViewZoom,
        CCTableView.kTableCellTouched,
        CCTableView.kTableCellSizeForIndex,
        CCTableView.kTableCellSizeAtIndex
    }
    local listenerFuc = {
        "numberOfCellsInTableView",
        "scrollViewDidScroll",
        "scrollViewDidZoom",
        "tableCellTouched",
        "cellSizeForTable",
        "tableCellAtIndex"
    }
    for key, var in pairs(listenerEnum) do
        self.tableView:registerScriptHandler(function(...)
           return self[listenerFuc[key]](self,...)
        end,var)
    end
    self.tableView:setDirection(kCCScrollViewDirectionVertical)
    self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

function TaskPopup:scrollViewDidScroll(view)
end

function TaskPopup:scrollViewDidZoom(view)
end

function TaskPopup:tableCellTouched(table,cell)
end

function TaskPopup:cellSizeForTable(table,idx)
    return self:getCellSize(self._currentType,idx + 1)
end

function TaskPopup:tableCellAtIndex(table, idx) 
    local cell = CCTableViewCell:new()
    local height , width = self:getCellSize(self._currentType,idx + 1)
    local itemView
    if     self._currentType == typeEnum.task then
        itemView = TaskItemView.new(cc.size(width,height),self._data[idx + 1])
    elseif self._currentType == typeEnum.road then 
        itemView = RoadItemView.new(cc.size(width,height),self._data[idx + 1],self._mainMenuScene,self)
    elseif self._currentType == typeEnum.collect then 
        itemView = TaskItemView.new(cc.size(width,height),self._data[idx + 1],self._mainMenuScene)
    elseif self._currentType == typeEnum.activity then
        itemView = ActivityItemView.new(cc.size(width,height),self._data[idx + 1],self._mainMenuScene)
    end    
    cell:addChild(itemView)
    return cell
end

function TaskPopup:numberOfCellsInTableView(tableView)
    return table.maxn(self._data)
end


function TaskPopup:getCellSize(type,index)
    if     self._currentType == typeEnum.task then
        return 150,self._tableContainerSize.width
    elseif self._currentType == typeEnum.road then 
        return 150,self._tableContainerSize.width
    elseif self._currentType == typeEnum.collect then 
        return 150,self._tableContainerSize.width
    elseif self._currentType == typeEnum.activity then
        local txt = string.gsub(self._data[index].dis, "\r\n", "\n")
        local label = CCLabelTTF:create(txt, FONTS_NAME.font_fzcy, 18,
        cc.size(self._tableContainerSize.width - 80,0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        self._data[index].rewords = {}
        if #self._data[2].rewords == 0 then
        	return 300 + label:getContentSize().height + 30,self._tableContainerSize.width
        else
        	return 50 + label:getContentSize().height + 30,self._tableContainerSize.width
        end
    end
end

function TaskPopup:reloadData(index)
    self._currentType = index
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
    self:clearTitle()
    if self._currentType == typeEnum.task then
        self._data = self.taskModel:getTaskList(1)
        dump(self._data)
        self:createTitleTask()
        self.tableView:setViewSize(cc.size(self._tableContainerSize.width,self._tableContainerSize.height - 130))
        self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width,self._tableContainerSize.height - 90))
    elseif self._currentType == typeEnum.road then
        self._data = self.taskModel:getTaskList(2)
        self.tableView:setViewSize(cc.size(self._innerContainerSize.width,self._tableContainerSize.height - 40))
        self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width,self._tableContainerSize.height))
    elseif self._currentType == typeEnum.collect then
        self._data = self.taskModel:getTaskList(3)
        self.tableView:setViewSize(cc.size(self._innerContainerSize.width,self._tableContainerSize.height - 40))
        self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width,self._tableContainerSize.height ))
    elseif self._currentType == typeEnum.activity then
        self._data = self.taskModel:getActivityList()
        self.tableView:setViewSize(cc.size(self._innerContainerSize.width,self._tableContainerSize.height - 40))
        self._tableContainer:setContentSize(cc.size(self._tableContainerSize.width,self._tableContainerSize.height ))
    end
    self.tableView:reloadData()
end

function TaskPopup:clearTitle()
    if self.titleView then
        self.titleView:removeFromParent()
        self.titleView = nil
    end
end

--任务界面的上方积分
function TaskPopup:createTitleTask()
    local leftAdgeOffset = 40
    local titleViewHeight = 100
    self.titleView = CCLayer:create()
    self.titleView:setContentSize(cc.size(self._tableContainerSize.width,titleViewHeight))
    
    self.titleView:setAnchorPoint(cc.p(0,1))
    self.titleView:setPosition(cc.p(0,self._innerContainerHeight - 100))
    self._innerContainer:addChild(self.titleView)

    --宝箱
    local titleViewSize = self.titleView:getContentSize()
    local res 
    local xunhuanEffect 
    if self.taskModel:checkHasReword() then
        res = goldStateRes.pressed
        xunhuanEffect = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "fubenjiangli_shanguang",
        })
        
    else 
        res = goldStateRes.normal
    end
    self._goldIcon = display.newSprite(res)
    self._goldIcon:setTouchEnabled(true)
    if self._goldIcon:getChildByTag(111) then
    	self._goldIcon:removeChildByTag(111)
    end
    if self.taskModel:checkHasReword() then
    	xunhuanEffect:setPosition(self._goldIcon:getContentSize().width/2, self._goldIcon:getContentSize().height/2)
    	self._goldIcon:addChild(xunhuanEffect,0,111)
    end
    self._goldIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then 
            self._goldIcon:setScale(1.2)
            return true
        elseif event.name == "ended" then 
            self._goldIcon:setScale(1.0)
            local giftGetPopup = GiftGetPopup.new(self._mainMenuScene)
            self:addChild(giftGetPopup)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end
    end)
    self._goldIcon:setAnchorPoint(cc.p(0,0.5))
    self._goldIcon:setPosition(cc.p(leftAdgeOffset,titleViewSize.height / 2 - 20))

    
    self.titleView:addChild(self._goldIcon)

    --积分
    local countDisLeftOffset = 10
    local iconSize = self._goldIcon:getContentSize()
    local countDis = ui.newTTFLabel({text = "当前积分", font = FONTS_NAME.font_fzcy , size = 22,
        color = ccc3(64,37,7),align = ui.TEXT_ALIGN_LEFT})
    countDis:setAnchorPoint(cc.p(0,1))
    countDis:setPosition(cc.p(leftAdgeOffset + iconSize.width + countDisLeftOffset , titleViewSize.height - 20))
    self.titleView:addChild(countDis)

    local posX = countDis:getPositionX()
    local offset = countDis:getContentSize().width + 10
    local countDis = ui.newTTFLabel({text = self._dataSelf.rtnObj.dailyMission.jifen, font = FONTS_NAME.font_fzcy , size = 22,
        color = ccc3(147,5,5),align = ui.TEXT_ALIGN_LEFT})
    countDis:setAnchorPoint(cc.p(0,1))
    countDis:setPosition(cc.p(posX + offset, titleViewSize.height - 20))
    self.titleView:addChild(countDis)

    local posX = countDis:getPositionX()
    local offset = countDis:getContentSize().width + 15
    local countDis = ui.newTTFLabel({text = "/"..TaskModel:getInstance():getMaxJIfen(), font = FONTS_NAME.font_fzcy , size = 22,
        color = ccc3(64,37,7),align = ui.TEXT_ALIGN_LEFT})
    countDis:setAnchorPoint(cc.p(0,1))
    countDis:setPosition(cc.p(posX + offset, titleViewSize.height - 20))
    self.titleView:addChild(countDis)


    local progress = display.newSprite(commonRes.progressNoneBng)
    local fill = display.newProgressTimer(commonRes.progressFullBng, display.PROGRESS_TIMER_BAR)
    fill:setMidpoint(CCPoint(0,0.5))
    fill:setBarChangeRate(CCPoint(1.0,0))
    fill:setPosition(progress:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
    progress:addChild(fill)
    progress:setPosition(leftAdgeOffset + iconSize.width + countDisLeftOffset, titleViewSize.height - 60)
    fill:setPercentage((self.taskModel:getJifen()/TaskModel:getInstance():getMaxJIfen())*100)
    progress:setAnchorPoint(cc.p(0,1))
    self.titleView:addChild(progress)



    --进度条上边的数字显示
    local margin = 10
    local progressBngSize = progress:getContentSize()
    local beginLabel = ui.newTTFLabel({text = "0", size = 20, font = FONTS_NAME.font_fzcy ,align = ui.TEXT_ALIGN_LEFT})
        :pos(margin, progressBngSize.height / 2)
        :addTo(progress)
    beginLabel:setAnchorPoint(cc.p(0,0.5))
    beginLabel:setVisible(false)
    local endLabel  = ui.newTTFLabel({text = TaskModel:getInstance():getMaxJIfen(), size = 20, font = FONTS_NAME.font_fzcy, align = ui.TEXT_ALIGN_LEFT})
        :pos(progressBngSize.width - margin, progressBngSize.height / 2)
        :addTo(progress)
    endLabel:setAnchorPoint(cc.p(1,0.5))
end

return TaskPopup
