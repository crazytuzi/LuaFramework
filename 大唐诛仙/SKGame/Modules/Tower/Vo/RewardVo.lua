RewardVo = BaseClass()

function RewardVo:__init()
	self.goodsType = 0   --奖品类型
	self.goodsId = 0	 --奖品id
	self.goodsNum = 0   --奖品数量
	self.isBind = false  --是否是绑定的
end

function RewardVo:__delete()
	
end