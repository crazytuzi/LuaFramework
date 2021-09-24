tankVo={}
function tankVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--坦克类型编号
function tankVo:initData(sid)
    self.sid=sid
    
end
