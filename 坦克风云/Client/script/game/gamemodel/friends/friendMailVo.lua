friendMailVo={}
function friendMailVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function friendMailVo:initWithData(param)
    if param[1] then
        self.uid = param[1]
    end
    if param[2] then
        self.nickname = param[2]
    end
    if param[4] then
        self.rank = tonumber(param[4])
    end
    if param[6] then
        self.title = param[6]
    end
    if param[7] then
        self.fc = tonumber(param[7])
    end
    if param[8] then
        self.level = tonumber(param[8])
    end
    if param[9] then
        self.pic = param[9]
    end
    if param[10] then
        self.bpic = param[10]
    end
end