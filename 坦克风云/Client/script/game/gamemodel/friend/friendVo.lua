friendVo={}
function friendVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function friendVo:initWithData(param)
    self.uid = param.id
    self.pid = param.pid
    self.picture = param.picture
    if(self.picture~=nil)then
        --if(string.len(self.picture)>150)then
            --self.picture="public/defaultFBIcon.jpg"
        --end
    end
    self.pname = param.pname
    self.username = param.username
    if(self.username==nil)then
        self.username=""
    end
    self.lv = tonumber(param.lv)
    if(self.lv==nil)then
        self.lv=0
    end
    self.power = tonumber(param.power)
    if(self.power==nil)then
        self.power=0
    end
    self.star=tonumber(param.star)
    if(self.star==nil)then
        self.star=0
    end
end