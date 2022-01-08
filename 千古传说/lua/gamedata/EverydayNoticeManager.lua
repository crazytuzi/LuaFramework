--拍脸公告

local EverydayNoticeManager = class("EverydayNoticeManager")

function EverydayNoticeManager:ctor()
    self:registerEvents()
    self.infos ={}
    -- self:createTestDate()  --test

end 
function EverydayNoticeManager:restart(  )
    self.infos ={}
end

function EverydayNoticeManager:registerEvents()
	TFDirector:addProto(s2c.ADVERTISE_PRIORITY, self, self.onReceiveAdvertisePriority);
end

function EverydayNoticeManager:onReceiveAdvertisePriority(event)
	self.infos = event.data.id or {}
end


function EverydayNoticeManager:getInfo()
    return self.infos
end



return EverydayNoticeManager:new();
