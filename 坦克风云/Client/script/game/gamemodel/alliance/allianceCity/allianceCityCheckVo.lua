allianceCityCheckVo={}
function allianceCityCheckVo:new()
    local nc={
        aid=nil, --军团id
        type=0,
        ptEndTime=0, --保护结束时间
        x=0,
        y=0,
        name="", --地块名称
        allianceName="", --军团名称
        level=1, --城市等级
        cr=0, --稀土数量
        defendc=0, --驻防总人数
        maxdef=0, --可以驻防的总人数（军团成员个数）
        defenders={}, --驻防战力排行（{{uid,战力,name}}）
        roblist={}, --掠夺排行 （{{uid,掠夺稀土量,name}}）
        grabinfo={}, -- grabinfo = {R=0,T=WeeTs,DR=0}, --抢夺信息 {今日抢夺稀土,上次抢夺或被抢夺的凌晨时间,今日被抢夺稀土},
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- --查看或侦查城市的数据格式
-- acitydetail={
--     cr=0, --稀土数量
--     defendc=0, --驻防总人数
--     defenders={}, --驻防战力排行（{{玩家昵称，战力},{玩家昵称，战力}}）
--     roblist={}, --掠夺排行 （{{玩家昵称，掠夺稀土量},{玩家昵称，掠夺稀土量}}）注意：当查看敌方城市时无此字段
-- }

function allianceCityCheckVo:initWithData(data)
    if data.aid then
        self.aid=data.aid
    end
    if data.type then
        self.type=data.type
    end
    if data.ptEndTime then
        self.ptEndTime=data.ptEndTime
    end
    if data.x then
        self.x=data.x
    end
    if data.y then
        self.y=data.y
    end
    if data.level then
        self.level=data.level or 1
    end
    if data.name then
        self.name=data.name
    end
    if data.allianceName then
        self.allianceName=data.allianceName
    end
    if data.cr then
        self.cr=data.cr
    end
    if data.defendc then
        self.defendc=data.defendc
    end
    if data.maxdef then
        self.maxdef=data.maxdef
    end
    if data.defenders then
        self.defenders=data.defenders
    end
    if data.roblist then
        self.roblist=data.roblist
    end
    if data.grabinfo then
        self.grabinfo=data.grabinfo
    end
end