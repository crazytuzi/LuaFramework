 ActivityDynamicVo =BaseClass(InnerEvent)

function ActivityDynamicVo:__init()
	self.id = 0		--活动编号
	self.enterCount = 0	--已进入次数
	self.state = 0	--活动状态 0:开启 1:关闭
end

