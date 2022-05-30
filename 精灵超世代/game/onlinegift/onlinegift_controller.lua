OnlineGiftController = OnlineGiftController or BaseClass(BaseController)

function OnlineGiftController:config()
    self.model = OnlineGiftModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function OnlineGiftController:getModel()
    return self.model
end

function OnlineGiftController:registerEvents()
end

function OnlineGiftController:registerProtocals()
    self:RegisterProtocal(10926, "handle10926")
    self:RegisterProtocal(10927, "handle10927")
end

function OnlineGiftController:openOnlineGiftView(bool)
    if bool == true then 
        if not self.onlinegiftView then
            self.onlinegiftView = OnlineGiftWindow.New()
        end
        self.onlinegiftView:open()
    else
        if self.onlinegiftView then 
            self.onlinegiftView:close()
            self.onlinegiftView = nil
        end
    end
end

function OnlineGiftController:sender10926()
    self:SendProtocal(10926, {})
end
function OnlineGiftController:handle10926(data)
    self.onlinegift_data = data.list
    self.online_time = data.time
    GlobalEvent:getInstance():Fire(OnlineGiftEvent.Get_Data, data)
end

function OnlineGiftController:setOnlineGiftData(time)
    if self.onlinegift_data then
        table.sort( self.onlinegift_data.time, time )
    end
end
function OnlineGiftController:getOnlineGiftData()
    if self.onlinegift_data then
        return self.onlinegift_data
    end
end
--获取在线奖励的时间
function OnlineGiftController:getOnlineTime()
    if self.online_time then
        return self.online_time
    end
end

function OnlineGiftController:sender10927(time)
    local proto = {}
    proto.time = time
    self:SendProtocal(10927, proto)
end

function OnlineGiftController:handle10927(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(OnlineGiftEvent.Updata_Data, data.time)
    end
end

function OnlineGiftController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
