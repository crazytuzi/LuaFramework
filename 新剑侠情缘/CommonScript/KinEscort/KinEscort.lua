KinEscort.nSaveKeyUserValueId 			= 48;                                     --保存用户存储数据的key
KinEscort.nRefDateKey 					= 1;                                      --保存上次刷新玩家活动数据日期
KinEscort.nKinIdKey 					= 2;                                      --用户上次参加运镖的Id
KinEscort.nRobCountKey					= 3;                                      --用户劫镖次数
KinEscort.nMinAttendLevel = 30	-- xx级以上才可以参加（获得经验、最终奖励、劫镖）

function KinEscort:IsLevelEnough(pPlayer)
	return pPlayer.nLevel>=self.nMinAttendLevel
end

function KinEscort:GetDegree()
	local remain = 1
	local total = 1

	while true do
		if me.GetUserValue(self.nSaveKeyUserValueId, self.nRefDateKey)==Lib:GetLocalDay() and
			me.GetUserValue(self.nSaveKeyUserValueId, self.nKinIdKey)>0 then 
			remain = 0
			break
		end	

		break
	end
	
	return remain, total
end