BuffVo =BaseClass(InnerEvent)

function BuffVo:__init()
	self.id = 0				--唯一编号
	self.targetGuid = nil	--目标对象
	self.attackGuid = nil	--使用方
	self.buffId = 0			--buff编号(对应表格)
	self.type = 0			--buff类型
	self.endTime = 0		--结束时间  -1：永久  0：移除 其他：倒计时
	self.dmg = 0			--影响受击者血量  <0 加血
	self.hpShow = 0			--非0情况下  持续加减血飘字
end

