alienMinesEnemyInfoVoApi={
	enemyInfo={},
}

-- 初始化数据
function alienMinesEnemyInfoVoApi:add(x,y,oid,data)
	if self.enemyInfo[x*100+y]==nil then
		self.enemyInfo[x*100+y]=alienMinesEnemyInfoVo:new(oid,data[4] or data["4"],data[2] or data["2"],data[1] or data["1"],data[3] or data["3"])
	end
end

-- 取坐标点x,y的敌人信息并判断是否过期
function alienMinesEnemyInfoVoApi:getEnemyInfoVoByXYAndOid(x,y,oid)
	if self.enemyInfo[x*100+y] then
		local vo = self.enemyInfo[x*100+y]
		if vo then
			if base.serverTime>vo.expireTime or vo.oid~=oid then
				self.enemyInfo[x*100+y]=nil
				return nil
			end
		end
		return vo
	end
	return nil
end

-- 清除数据（否则串服）
function alienMinesEnemyInfoVoApi:clear()
	self.enemyInfo={}
end

