-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ExchangeController = ExchangeController or BaseClass(BaseController)

function ExchangeController:config()
    self.model = ExchangeModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ExchangeController:getModel()
    return self.model
end

function ExchangeController:registerEvents()
    --[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                self:send23606() --红点                
            end
        end)
    end --]]
end

function ExchangeController:registerProtocals()
    self:RegisterProtocal(23606, "handle23606")
    self:RegisterProtocal(23607, "handle23607")
end

function ExchangeController:send23606()
    self:SendProtocal(23606, {})
end

function ExchangeController:handle23606( data )
    self.dispather:Fire(ExchangeEvent.Extra_Reward, data)
end

function ExchangeController:send23607(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(23607, protocal)
end

function ExchangeController:handle23607(data)
    message(data.msg)
end

--打开兑换窗口
function ExchangeController:openExchangeMainView( status )
	if status then 
        if not self.exchange_win  then
            self.exchange_win = ExchangeWindow.New()
        end
        self.exchange_win:open()
    else
        if self.exchange_win then 
            self.exchange_win:close()
            self.exchange_win = nil
        end
    end
end

function ExchangeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end