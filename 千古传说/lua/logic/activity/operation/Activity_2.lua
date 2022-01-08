
local Activity_2 = class("Activity_2", BaseLayer)

function Activity_2:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.002")

end

function Activity_2:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_phb     = TFDirector:getChildByPath(ui, 'btn_paihang')

        self.txt_time     	= TFDirector:getChildByPath(ui, 'txt_time')

   

    local ActivityStatus = OperationActivitiesManager:getActivityStatus(EnumActivitiesType.DXCCC)
    print("ActivityStatus = ", ActivityStatus)
    local startTime = OperationActivitiesManager:parseTime(ActivityStatus.startTime)
    local endTime 	= OperationActivitiesManager:parseTime(ActivityStatus.endTime)

    self.txt_time:setText(startTime.."—"..endTime)
end

function Activity_2:setLogic(logic)
    self.logic = logic
end

function Activity_2:registerEvents()
    self.super.registerEvents(self) 
    self.btn_phb:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle))
end

function Activity_2:removeEvents()
    self.super.removeEvents(self)
end

function Activity_2.BtnClickHandle(sender)
    -- local layer = AlertManager:addLayerByFile("lua.logic.leaderboard.LeaderboardLayer.lua")
    -- layer:setIndex(EnumActivitiesType.XZWLZZ)
    -- AlertManager:show();

    OperationActivitiesManager:openleaderBoard(EnumActivitiesType.XZWLZZ)
end

return Activity_2