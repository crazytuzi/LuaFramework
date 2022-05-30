-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- --------------------------------------------------------------------
DayChargeController = DayChargeController or BaseClass(BaseController)

function DayChargeController:config()
    self.model = EscortModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function DayChargeController:getModel()
    return self.model
end

function DayChargeController:registerEvents()

end

function DayChargeController:registerProtocals()
    self:RegisterProtocal(21010, "handle21010")
    self:RegisterProtocal(21011, "handle21011")
end

--每日首充
function DayChargeController:sender21010()
    self:SendProtocal(21010, {})
end
function DayChargeController:handle21010(data)
    local status = false
    if data.status == 1 then
        status = true
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.day_first_charge, status)
    GlobalEvent:getInstance():Fire(DayChargetEvent.DAY_FIRST_CHARGE_EVENT, data)
end
function DayChargeController:sender21011()
    self:SendProtocal(21011, {})
end
function DayChargeController:handle21011(data)
    message(data.msg)
    if data.code == 1 then
        self:openDayFirstChargeView(false)
    end
end
-------打开界面
function DayChargeController:openDayFirstChargeView(status)
    if status then
        if not self.daycharge_window then
            self.daycharge_window = DayChargeWindow.New()
        end
        self.daycharge_window:open()
    else
        if self.daycharge_window then
            self.daycharge_window:close()
            self.daycharge_window = nil
        end
    end
end

function DayChargeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
