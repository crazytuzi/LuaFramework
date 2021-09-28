TowerModel = BaseClass(LuaModel)

function TowerModel:__init()
	self.curLevel = 0
	self.curReward = {}

	self.autoAttack = false
end

function TowerModel:Reset()
	self.autoAttack = false
end

--当前的层数的奖励
function TowerModel:GetCurrentReward()
	return self.curReward
end

--设置当前的层数的奖励
function TowerModel:SetCurrentReward(rewardList)
	self.curReward = {}
	if rewardList then 
		for i=1,#rewardList do
			local item = rewardList[i]
			if item then 
				local goods = RewardVo.New()
				goods.goodsType = item[1]
				goods.goodsId = item[2]
				goods.goodsNum = item[3]
				if item[4] == 1 then 
					goods.isBind = true
				end
				table.insert(self.curReward,goods)
			end
		end
	end
end

function TowerModel:GetTowerDataByMapId(mapId)
	local data = GetCfgData( "tower" )
	for k, v in pairs(data) do
		if type(v) ~= "function" then
			if v.mapId == tonumber(mapId) then
				return v
			end
		end
	end
end

--单例
function TowerModel:GetInstance()
	if TowerModel.inst == nil then 
		TowerModel.inst = TowerModel.New()
	end
	return TowerModel.inst
end

function TowerModel:__delete()
	self.curLevel = 0
	TowerModel.inst = nil
end