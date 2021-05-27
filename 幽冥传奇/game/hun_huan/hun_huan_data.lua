HunHuanData = HunHuanData or BaseClass()

-- SoulRingPreferenceCfg.GiftPackage

HunHuanData.INFO_CHANGE = "info_change"

function HunHuanData:__init()
	if HunHuanData.Instance then
		ErrorLog("[HunHuanData] attempt to create singleton twice!")
		return
	end
	--数据派发组件
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	HunHuanData.Instance = self
end

function HunHuanData:__delete()
end

function HunHuanData:GetRewardRemind()
	for i = 1, #SoulRingPreferenceCfg.GiftPackage do
		if self.is_lingqu_t[i] == 0 then
			return 1
		end
	end
	return 0
end

function HunHuanData:setFlag(flag)
	self.is_lingqu_t = {}
	for i = 1, #SoulRingPreferenceCfg.GiftPackage do
		self.is_lingqu_t[i] = bit:_and(1, bit:_rshift(flag, i - 1))
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.HunHuan)
	self:DispatchEvent(HunHuanData.INFO_CHANGE, {})
	GameCondMgr.Instance:CheckCondType(GameCondType.IsHunHuanOpen)
end

function HunHuanData:GetIsLingQuByIdx(idx)
	return self.is_lingqu_t[idx] == 1
end

function HunHuanData:GetDataList()
	return SoulRingPreferenceCfg.GiftPackage
end

--结束剩余时间
function HunHuanData.GetSpaceTime()
	local day_time = 60 * 60 * 24
	local servertime_day_time = day_time - TimeCtrl.Instance:GetServerTime() % day_time - 8 * 60 * 60
	local time = (SoulRingPreferenceCfg.FirstEndDay[2] - OtherData.Instance:GetOpenServerDays()) * day_time + servertime_day_time
	-- return (13 - OtherData.Instance:GetOpenServerDays()) * day_time + servertime_day_time
	return time
end

function HunHuanData.GetIsOpen()
	return HunHuanData.GetSpaceTime() > 0 and RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= SoulRingPreferenceCfg.level
end
