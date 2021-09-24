robReportVo={}
function robReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


--rid			战报id
--type 			自己是否是攻击者 1攻击 2防守
--uid 			自己的id
--name 			自己的名字
--enemyId		对方的id
--enemyName 	对方的名字
--time			时间
--isRead		是否已读
--isVictory		是否获胜
--robSuccess	是否抢夺碎片成功
--robinfo		抢夺的碎片信息
--wid 			抢夺的碎片信息：对应超级武器id
--wLevel		抢夺的碎片信息：对应超级武器品阶，即等级
--fid 			抢夺的碎片id
--report 		战斗信息
--elementNum    纳米元件数量
function robReportVo:initWithData(rid,type,uid,name,enemyId,enemyName,time,isRead,isVictory,robSuccess,wid,wLevel,fid,report,elementNum)
	self.rid=rid
	self.type=type
	self.uid=uid or 0
	self.name=name or ""
	self.enemyId=enemyId or 0
	self.enemyName=enemyName or ""
	self.time=time or 0
	self.isRead=isRead or 0
	self.isVictory=isVictory or 1
	self.robSuccess=robSuccess or 0
	self.wid=wid
	self.wLevel=wLevel
	self.fid=fid
    self.report=report or {}
	self.elementNum=tonumber(elementNum) or 0
end

