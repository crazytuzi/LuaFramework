ltzdzAttackReportVo={}

function ltzdzAttackReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzAttackReportVo:initWithData(data)
    self.rid=data.id or 0 --战报id
    self.rtype=data.type or 1 --战报的类型（1：战斗报告，2：运输报告）
	self.startCity=data.sc --出发城市 {城市id,主基地等级}
    self.targetCity=data.tc --目标城市
	self.time=data.ts --发生战斗的时间
	self.isRead=data.isread or {} --战报是否已经读取
    self.isVictory=data.isvictory or 0 --攻击方是否胜利
    self.auid=data.auid --进攻方uid
    self.duid=data.duid --防守方uid
    self.attacker=data.auser --攻击方玩家数据 {头像id,名字,等级,所在服务器}
    self.defender=data.duser --防守方玩家数据，格式同attacker。注意：当攻击的是野城时，此字段为nil或{}
    self.city=data.city --城市数据 city[1]起始城，city[2]目标城 格式：{城id,等级}
    self.reserve=data.reserve or 0 --防守方损失预备役
end

function ltzdzAttackReportVo:addContent(data)
    if data.tank then --坦克部队
        self.tank=data.tank
    end
    if data.destroy then
        self.destroy=data.destroy --进攻方和防守方损失的部队
    end
    if data.report then --战斗相关数据
        self.report=data.report
    end
    if data.aey then --配件相关数据
        self.accessory=data.aey --accessory[1]进攻方，accessory[2]防守方  格式：{配件强度,{各个品阶配件的个数}}
    end
    if data.hh then --将领相关数据
        self.hero=data.hh --hero[1]进攻方,hero[2]防守方  格式：{{"将领id-等级-品阶",""},将领强度}
    end
    if data.equip then --军徽数据 
        self.emblemID=data.equip --emblemID[1]进攻方军徽id，emblemID[2]防守方军徽id
    end
    if data.plane then --飞机相关数据
        self.plane=data.plane --plane[1]进攻方，plane[2]防守方  格式：{飞机id,威力}
    end
    if data.ait then --AI部队数据
        self.aitroops=data.ait
    end
    if data.dmg then --进攻方收到的城防伤害
        self.dmg=data.dmg
    end
    if data.ri then --以后功能扩展新增字段
        --tskinList：坦克皮肤数据
        self.tskinList=G_formatExtraReportInfo(data.ri)
    end
end