 WingDynamicVo =BaseClass(InnerEvent)

function WingDynamicVo:__init()
	self.wingId = 0			--羽翼ID
	self.star = 0			--星星数
	self.wingValue = 0		--当前羽灵值
	self.dressFlag = nil	--是否穿戴 1: 已穿戴
end

