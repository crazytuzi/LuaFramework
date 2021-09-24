allianceVo={}
function allianceVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--exp			经验
--num 			军团当前人数
--maxNum		军团总人数
--rank			排名
--fight			战力
--desc			军团宣言
--type          加入条件 0为不需要验证 1为需要验证
--joinCondition	加入要求
--leaderName	团长昵称
--notice		内部公告
--oid           创建人id
--oname         创建人昵称
--requests      申请玩家列表
--point         军团资金
--role          0是普通成员, 1是副军团长, 2是军团长

function allianceVo:initWithData(data,aid,name,exp,level,num,maxnum,rank,fight,desc,type,leaderName,notice,oid,oname,requests,leaderId,fight_limit,level_limit,role,groupmsg_limit,donateCount,lastDonateTime,joinTime,point,alliancewar,allianceDonateMembers)
	self.aid=aid
	self.name=name
	self.exp=exp
	self.level=level
	self.num=num
	self.maxnum=maxnum
	self.rank=rank
	self.fight=fight
	self.desc=desc
	self.type=type
	--self.joinCondition=joinCondition
    self.leaderName=leaderName
    self.notice=notice
    self.oid=oid
    self.oname=oname
    self.requests=requests
    self.leaderId=leaderId
    self.fight_limit=fight_limit
    self.level_limit=level_limit
    self.role=role
    self.groupmsg_limit=groupmsg_limit
    self.donateCount=donateCount
    self.lastDonateTime=lastDonateTime
    self.joinTime=joinTime

    self.point=(point==nil and o or point)
    self.alliancewar=alliancewar
    self.allianceDonateMembers=allianceDonateMembers
    self.addDonateCount=2

    if data then
        if data.banner then
            self.banner = data.banner
        end

        if data.banner_at then
            self.banner_at = data.banner_at
        end
        if data.unlockflag then --已经拥有的军团旗帜（某些军团旗帜不是根据等级解锁的，而是通过别的方式获取的）
            self.unlockflag = data.unlockflag
        end
    end
end