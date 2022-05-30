
local typeEnum = {
    task    = 1,
    road    = 2,
    collect = 3,
    activity = 4,
}
require ("utility.ResMgr")
require ("utility.richtext.globalFunction")
require ("game.DialyTask.TaskModel")
local data_item_item = require("data.data_item_item")
local ActivityItemView = require("game.nbactivity.HuiKui.ActivityItemView")
local TaskPopup = class("TaskPopup", function()
    return display.newLayer("TaskPopup")
end)

function TaskPopup:ctor(mainscene,viewSize)
    -- dump(data.rtnObj.missions)
    -- dump(data.rtnObj.extendMissionDefines)
    --测试数据
    --设置背景图
    self:load()
    local bng = display.newScale9Sprite("#month_bg.png", 0, 0, 
                viewSize)
    bng:setAnchorPoint(cc.p(0,0))
    self:addChild(bng)
    self:getData(function()
        self:setUpView(mainscene,viewSize)
    end)
    
end

function TaskPopup:getData(func)
    RequestHelper.dialyTask.getTaskList({
                callback = function(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else
                        dump(data)
                        self.taskModel = TaskModel:getInstance():init(data)
                        self._data = self.taskModel:getActivityList()
                        if #self._data == 0 then 
                            self._start = 0
                            self._end = 0
                            self._nowTime = 0
                        else
                            self._start = self._data[1].startTime
                            self._end = self._data[1].endTime
                            self._nowTime = self._data[1].endTime - data.rtnObj.timeNow
                        end
                        
                        func()
                    end
                end,
                missionType = 5
                })

end

function TaskPopup:timeFormat(timeAll)
    local basehour = 60 * 60
    local basemin  = 60
    local hour = math.floor(timeAll / basehour) 
    local time = timeAll - hour * basehour
    local min  = math.floor(time / basemin) 
    local time = time - basemin * min
    local sec  = math.floor(time)
    hour = hour < 10 and "0"..hour or hour
    min = min < 10 and "0"..min or min
    sec = sec < 10 and "0"..sec or sec
    local nowTimeStr = hour.."时"..min.."分"..sec.."秒"
    return nowTimeStr
end


function TaskPopup:setUpView(mainscene,viewSize)
    self._viewSize = viewSize
    self:setContentSize(self._viewSize)
    
    
    

    local topBng = display.newSprite("#chongzhi_top_bng.png")
    topBng:setAnchorPoint(cc.p(0.5,1))
    topBng:setPosition(cc.p(display.cx,viewSize.height))
    self:addChild(topBng,10)

    self._listBngSize = cc.size(viewSize.width,viewSize.height - topBng:getContentSize().height - 30)
    --背景框
    local innerBng = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, 
                        self._listBngSize)
    innerBng:setAnchorPoint(cc.p(0.5,0))
    innerBng:setPosition(viewSize.width * 0.5, 10)
    self:addChild(innerBng)
    self._listBng = innerBng

    local timeTitle = ui.newTTFLabelWithOutline({  text = "活动时间:", 
                                            size = 22, 
                                            color = ccc3(0,254,60),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    timeTitle:setAnchorPoint(cc.p(1,0))
    timeTitle:setPosition(cc.p(50 , 20))
    topBng:addChild(timeTitle)

    local timeLabel = ui.newTTFLabelWithOutline({  text = "00:00:00", 
                                            size = 22, 
                                            color = ccc3(0,254,60),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    timeLabel:setAnchorPoint(cc.p(0,0))
    timeLabel:setPosition(cc.p(300 , 20))
    topBng:addChild(timeLabel)

    --活动时间
    local startTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._start) / 1000))
    local endTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._end) / 1000))

    local startTimeStr = string.split(startTimeStr,"-")
    local startTime
    startTime = startTimeStr[1].."年"
    startTime = startTime..startTimeStr[2].."月"
    startTime = startTime..startTimeStr[3].."日"

    local endTimeStr = string.split(endTimeStr,"-")
    local endTime
    endTime = endTimeStr[1].."年"
    endTime = endTime..endTimeStr[2].."月"
    endTime = endTime..endTimeStr[3].."日"

    
    timeLabel:setString(startTime.."至"..endTime)

    local countDownTitle = ui.newTTFLabelWithOutline({  text = "活动剩余时间:", 
                                            size = 22, 
                                            color = ccc3(0,254,60),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    countDownTitle:setAnchorPoint(cc.p(1,0))
    countDownTitle:setPosition(cc.p(50 , -10))
    topBng:addChild(countDownTitle)

    self._timeLabelCountDown = ui.newTTFLabelWithOutline({  text = "00时00分00秒", 
                                            size = 22, 
                                            color = ccc3(0,254,60),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self._timeLabelCountDown:setAnchorPoint(cc.p(0,0))
    self._timeLabelCountDown:setPosition(cc.p(50 + countDownTitle:getContentSize().width + 10 , -10))
    topBng:addChild(self._timeLabelCountDown)


    self._countDownTime = self._nowTime / 1000
    --倒计时
    if not self._schedulerTime then
        self._schedulerTime = require("framework.scheduler")
        local countDown = function()
            --剩余时间 
            self._countDownTime = self._countDownTime - 1
            if self._countDownTime <= 0 then
                self._schedulerTime.unscheduleGlobal(self._scheduleTime)
                --self._timeLabelCountDown:setString("活动已结束")
                --show_tip_label("活动已结束")
            else
                self._timeLabelCountDown:setString(self:timeFormat(self._countDownTime))
            end
        end
        self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 1, false)
    end



	self:setUpTableView()
	self:reloadData()
end

function TaskPopup:clear()
    if self._scheduleTime then
        self._schedulerTime.unscheduleGlobal(self._scheduleTime)
    end
    self:closeSelf()
    print("clear")
end

function TaskPopup:load()
    display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.addSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.addSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.png")
    display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
    display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")  
    display.addSpriteFramesWithFile("ui/ui_vipLibao.plist", "ui/ui_vipLibao.png")
    display.addSpriteFramesWithFile("ui/ui_nbactivity_chongzhihuikui.plist", "ui/ui_nbactivity_chongzhihuikui.png")

end

function TaskPopup:closeSelf()
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.removeSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.removeSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
    display.removeSpriteFramesWithFile("ui/ui_vipLibao.plist", "ui/ui_vipLibao.png")
    display.removeSpriteFramesWithFile("ui/ui_nbactivity_chongzhihuikui.plist", "ui/ui_nbactivity_chongzhihuikui.png")

end


function TaskPopup:setUpTableView()
    self.tableView = CCTableView:create(cc.size(self._listBngSize.width,self._listBngSize.height - 30))

    self.tableView:setPosition(cc.p(0, 15))
    self.tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    self._listBng:addChild(self.tableView)
    
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

    local touchNode = display.newNode()
    touchNode:setTouchEnabled(true)
    touchNode:setContentSize(cc.size(display.width,display.height))
    touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        self.posX = event.x
        self.posY = event.y
    end)
    self:addChild(touchNode,20)
end

function TaskPopup:scrollViewDidScroll(view)
end

function TaskPopup:scrollViewDidZoom(view)
end

function TaskPopup:tableCellTouched(table,cell)
    for i = 1, cell:getChildByTag(1):getIconNum() do
        local icon , data = cell:getChildByTag(1):getIcon(i)
        local pos = icon:convertToNodeSpace(cc.p(self.posX, self.posY))
        if cc.rectContainsPoint(cc.rect(0, 0, icon:getContentSize().width, icon:getContentSize().height), pos) then
            self:onIconClick(data)
            break
        end
    end
end


function TaskPopup:onIconClick(data)
    if tonumber(data.type) ~=6 then
        if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
            local closeFunc = function()
                if CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
                    CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
                end
            end
            local itemInfo = require("game.Huodong.ItemInformation").new({
                            id = tonumber(data.id), 
                            type = tonumber(data.type), 
                            name = data_item_item[tonumber(data.id)].name, 
                            describe = data_item_item[tonumber(data.id)].describe,
                            endFunc = closeFunc
                            })
            CCDirector:sharedDirector():getRunningScene():addChild(itemInfo,100000000,1111)
        end
    else
        local closeFunc = function()
            if CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
                CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111, true)
            end
        end
        if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then
            local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {resId = tonumber(data.id)},nil,closeFunc)
            CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 100000000,1111)
        end
    end
end

function TaskPopup:cellSizeForTable(table,idx)
    return self:getCellSize(idx + 1)
end

function TaskPopup:tableCellAtIndex(table, idx) 
    local cell = CCTableViewCell:new()
    local height , width = self:getCellSize(idx + 1)
    itemView = ActivityItemView.new(cc.size(width,height),self._data[idx + 1],self) 
    cell:addChild(itemView,0,1)
    return cell
end

function TaskPopup:numberOfCellsInTableView(tableView)
    return table.maxn(self._data)
end


function TaskPopup:getCellSize(index)
    return 200,self._viewSize.width
end

function TaskPopup:reloadData()
    self.tableView:reloadData()
end

return TaskPopup
