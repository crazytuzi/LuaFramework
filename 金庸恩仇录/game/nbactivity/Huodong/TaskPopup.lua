
local typeEnum = {
    task    = 1,
    road    = 2,
    collect = 3,
    activity = 4,
}
require ("utility.ResMgr")
require ("utility.richtext.globalFunction")
require ("game.DialyTask.TaskModel")
local ActivityItemView = require("game.nbactivity.Huodong.ActivityItemView")
local TaskPopup = class("TaskPopup", function()
    return display.newLayer("TaskPopup")
end)

function TaskPopup:ctor(data,mainscene,viewSize)
    -- dump(data.rtnObj.missions)
    -- dump(data.rtnObj.extendMissionDefines)
    --测试数据
    self._viewSize = viewSize
    self:setContentSize(self._viewSize)
    self.taskModel = TaskModel:getInstance():init(data)
    self._data = self.taskModel:getActivityList()

    --设置背景图
    local bng = display.newSprite("bg/duobao_bg.jpg")
    bng:setScale(display.height/bng:getContentSize().height)
    bng:setAnchorPoint(cc.p(0,0))
    self:addChild(bng)


    self:setUpView()
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
	self:setUpTableView()
	self:reloadData()
end

function TaskPopup:closeSelf()
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
    display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
    display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
    display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
    display.removeSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
    display.removeSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
    self:removeFromParent()
    self = nil
end


function TaskPopup:setUpTableView()
    self.tableView = CCTableView:create(self._viewSize)

    self.tableView:setPosition(cc.p(0, 0))
    self.tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    self:addChild(self.tableView)
    
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
    return self:getCellSize(idx + 1)
end

function TaskPopup:tableCellAtIndex(table, idx) 
    local cell = CCTableViewCell:new()
    local height , width = self:getCellSize(idx + 1)
    itemView = ActivityItemView.new(cc.size(width,height),self._data[idx + 1],self) 
    cell:addChild(itemView)
    return cell
end

function TaskPopup:numberOfCellsInTableView(tableView)
    return table.maxn(self._data)
end


function TaskPopup:getCellSize(index)
    local txt = string.gsub(self._data[index].dis, "\r\n", "\n")
    local label = CCLabelTTF:create(txt, FONTS_NAME.font_fzcy, 18,
    cc.size(self._viewSize.width - 80,0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    if #self._data[index].rewords == 0 then
    	return 100 + label:getContentSize().height + 30,self._viewSize.width
    else
    	return 300 + label:getContentSize().height + 30,self._viewSize.width
    end
end

function TaskPopup:reloadData()
    self.tableView:reloadData()
end

return TaskPopup
