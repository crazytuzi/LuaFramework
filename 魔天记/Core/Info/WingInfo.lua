WingInfo = class("WingInfo");

function WingInfo:New(data)
    self = { };
    setmetatable(self, { __index = WingInfo });
    self:_Init(data);
    return self;
end

function WingInfo:_Init(data) 
    local config = WingManager.GetWingConfigById(data.id, data.level) 
    ConfigManager.copyTo(config, self)
    self.curExp = data.exp
    self.needItem = { }
    local need = string.split(self.need_item, '_')
    self.needItem.itemId = tonumber(need[1])
    self.needItem.itemCount = tonumber(need[2])
end

 
