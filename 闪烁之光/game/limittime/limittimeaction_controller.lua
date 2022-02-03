--******** 文件说明 ********
-- @Author:      lc 
-- @description: 
-- @DateTime:    2019-12-07
LimitTimeActionController = LimitTimeActionController or BaseClass(BaseController)

function LimitTimeActionController:config()
    self.model = LimitTimeActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function LimitTimeActionController:getModel()
    return self.model
end

function LimitTimeActionController:registerEvents()

end

function LimitTimeActionController:registerProtocals()
    self:RegisterProtocal(28000, "handle28000")
    --self.play_next_act = GlobalEvent:getInstance():Bind(StoryEvent.PLAY_NEXT_ACT,function()
    -- self:RegisterProtocal(25701, "handle25701")
    -- self:RegisterProtocal(25702, "handle25702")
    -- self:RegisterProtocal(25703, "handle25703")
    -- self:RegisterProtocal(25704, "handle25704")

    -- --个人推送礼包
    -- self:RegisterProtocal(26300, "handle26300")
    -- self:RegisterProtocal(26301, "handle26301")
end
--
function LimitTimeActionController:sender28000()
    self:SendProtocal(28000, {})
end
function LimitTimeActionController:handle28000(data)
    if data ~= nil and next(data) ~= nil then
        GlobalEvent:getInstance():Fire(LimitTimeActionEvent.Limit_Time_Gift_Event, data)
    end
end



--打开限时钜惠礼包界面
function LimitTimeActionController:openLimitTimeGiftWindow(status)
    if status == true then
        if not self.limit_time_gift_window then
            self.limit_time_gift_window = LimitTimeGiftWindow.New()
        end
        self.limit_time_gift_window:open()
    else
        if self.limit_time_gift_window then 
            self.limit_time_gift_window:close()
            self.limit_time_gift_window = nil
        end
    end
end

function LimitTimeActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end