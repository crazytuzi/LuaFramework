local believerBattleReportVo={}

function believerBattleReportVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function believerBattleReportVo:initWithData(report,detail)
	if report then
		self.id=report[1] --战报id
		self.enemyName=believerVoApi:getEnemyNameStr(report[2]) --对手昵称
		self.score=report[3] --战斗获得积分
		self.gradeUp=report[4] --大段位上升
		self.queueUp=report[5] --小段位上升
		self.isVictory=report[6] --战斗是否胜利
		self.timeStr=G_getDateStr(report[7],true) --战斗时间
		self.isRead=report[9] or 0 --战报是否读取过
	end
	if detail then
		self.detail=detail
	end
end

return believerBattleReportVo