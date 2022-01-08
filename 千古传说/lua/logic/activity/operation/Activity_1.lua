
local Activity_1 = class("Activity_1", BaseLayer)

function Activity_1:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.001")
end

function Activity_1:initUI(ui)
	self.super.initUI(self,ui)
    self.btn_phb     	= TFDirector:getChildByPath(ui, 'btn_paihang')
    self.txt_time     	= TFDirector:getChildByPath(ui, 'txt_time')

    local ActivityStatus = OperationActivitiesManager:getActivityStatus(EnumActivitiesType.DXCCC)
    print("ActivityStatus = ", ActivityStatus)
    local startTime = OperationActivitiesManager:parseTime(ActivityStatus.startTime)
    local endTime 	= OperationActivitiesManager:parseTime(ActivityStatus.endTime)

    self.txt_time:setText(startTime.."—"..endTime)

end

function Activity_1:setLogic(logic)
    self.logic = logic
end

function Activity_1:registerEvents()
    self.super.registerEvents(self)

    self.btn_phb:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle))
end

function Activity_1:removeEvents()
    self.super.removeEvents(self)
end

function Activity_1.BtnClickHandle(sender)
    -- local layer = AlertManager:addLayerByFile("lua.logic.leaderboard.LeaderboardLayer.lua")
    -- layer:setIndex()
    -- AlertManager:show();

    OperationActivitiesManager:openleaderBoard(EnumActivitiesType.DXCCC)
end

return Activity_1

