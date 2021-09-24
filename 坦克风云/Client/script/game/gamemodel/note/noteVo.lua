noteVo={}
function noteVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.des = nil
    self.read = false
    return nc
end

--type：type=7：系统滚屏的公告
function noteVo:initWithData(data)
    if self.type == nil then
        self.type = 0
    end
    if data.type ~= nil then
        self.type = data.type
    end

    if self.id == nil then
        self.id = 0
    end

    if data.id ~= nil then
        self.id = tonumber(data.id)
    end
    
    if self.st == nil then
        self.st = 0
    end

    if data.time_st ~= nil then
        self.st = tonumber(data.time_st)
    end
    
    if data.et == nil then
        self.et = 0
    end

    if data.time_end ~= nil then
        self.et = tonumber(data.time_end)
    end
    
    if self.title == nil then
        self.title = ""
    end

    if data.title ~= nil then
        self.title = data.title
    end

    if self.isReward == nil then
        self.isReward = 0
    end
    if data.gift ~= nil then
        self.isReward = tonumber(data.gift) or 0
    end
    
    --附属id
    if self.subId == nil then
        self.subId = ""
    end
    if data.nid ~= nil then
        self.subId = data.nid or ""
    end

    --语言
    if self.lang == nil then
        self.lang = ""
    end
    if data.lag ~= nil then
        self.lang = data.lag or ""
    end
    --普通的公告里没有item和content字段
    if data.item then --系统公告用
        self.item=data.item
    end
    if data.content then --系统公告的消息
        self.des=data.content
    end
end

function noteVo:setDes(des)
	self.des = des
end
