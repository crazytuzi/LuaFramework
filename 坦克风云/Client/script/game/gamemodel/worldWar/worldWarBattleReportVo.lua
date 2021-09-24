--战报数据
worldWarBattleReportVo={}
function worldWarBattleReportVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function worldWarBattleReportVo:init(data)
	self.battleData=data.battleData or {} 			--战斗数据battleVo
	self.isRead=data.isRead or 1 					--战报是否已读
	--积分赛有的数据
	self.rid=data.rid or 0 							--战报id,积分赛会有,获取战斗数据
	self.rankPoint=tonumber(data.rankPoint) or 0 	--此轮战斗排名积分变化，上升或下降
	self.point=tonumber(data.point) or 0 			--此轮战斗获得的商店积分
	self.roundIndex=tonumber(data.roundIndex) or 0	--积分赛第几场
end