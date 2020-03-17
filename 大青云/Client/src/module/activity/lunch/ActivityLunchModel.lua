--[[
	2016年8月17日, PM 21:58:59
	houxudong
]]
_G.ActivityLunchModel = Module:new();

ActivityLunchModel.chooseState = 1;  --套餐类型  1.未选择套餐  2.选择普通套餐  3.选择VIP套餐
ActivityLunchModel.ExpReward = 0;    --经验奖励

function ActivityLunchModel:SetChooseState(state)
	self.chooseState = state;
end

-- 选择套餐状态
function ActivityLunchModel:GetChooseState()
	return self.chooseState;
end

function ActivityLunchModel:SetBackReward(reward)
	self.ExpReward = reward;
end

-- 玩家吃饭累计经验
function ActivityLunchModel:GetBackReward()
	return self.ExpReward
end

-- 检测是否可以坐在这个椅子上
function ActivityLunchModel:CheckCanCollect(collection)
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		local collectionTypePos = collection:GetPos().x
		local str = ""
		if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then     --未选择套餐
			if collectionTypePos < 0 then
				str = StrConfig['lunchwarning1']
			elseif collectionTypePos > 0 then
				str = StrConfig['lunchwarning2']
			end
			FloatManager:AddCenter(str)
			return false;
		elseif ActivityLunchModel:GetChooseState() == ActivityLunchConsts.VIPChoose then     --选择VIP套餐
			if collectionTypePos < 0 then
				str = StrConfig['lunchwarning1']
				FloatManager:AddCenter(str)
				return false;
			end
		elseif ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NormalChoose then  --选择普通套餐
			if collectionTypePos > 0 then
				str = StrConfig['lunchwarning2']
				FloatManager:AddCenter(str)
				return false;
			end
		end
	end
	return true
end