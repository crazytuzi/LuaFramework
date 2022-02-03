-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-02-28
-- --------------------------------------------------------------------
OnecentgiftController = OnecentgiftController or BaseClass(BaseController)

function OnecentgiftController:config()
    self.model = OnecentgiftModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function OnecentgiftController:getModel()
    return self.model
end

function OnecentgiftController:registerEvents()
end

function OnecentgiftController:registerProtocals()
    self:RegisterProtocal(16651, "handle16651")
    self:RegisterProtocal(16652, "handle16652")
end

--战力飞升礼包信息
function OnecentgiftController:send16651()
    self:SendProtocal(16651, {})
end

function OnecentgiftController:handle16651(data)
    self.role_vo = RoleController:getInstance():getRoleVo()
    if self.role_power_exchange_event == nil and self.role_vo then
        self.role_power_exchange_event = self.role_vo:Bind(RoleEvent.UPDATE_POWER_VALUE, function(cur_power, old_power)
            self.model:updateRed(cur_power)
        end)
    end
    self.model:setBaseInfo(data)
    self.dispather:Fire(OnecentgiftEvent.Onecentgift_Init_Event)
end

--领取战力飞升礼包奖励
function OnecentgiftController:send16652(receive_id)
    self:SendProtocal(16652, {id = receive_id})
end

function OnecentgiftController:handle16652(data)
    message(data.msg)
end

--打开界面
function OnecentgiftController:openOnecentiftView(status)
    if status == true then
        if not self.onecentgift_window then
            self.onecentgift_window = OneCentGiftWindow.New()
        end
        self.onecentgift_window:open()
    else
        if self.onecentgift_window then
            self.onecentgift_window:close()
            self.onecentgift_window = nil
        end
    end
end

function OnecentgiftController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
