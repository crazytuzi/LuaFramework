--[[坐骑界面主面板
zhangshuhui
2014年11月05日17:20:20
]]

_G.MountModel = Module:new();

MountModel.horseDataList = {}
MountModel.ridedMount = MountVO:new()--坐骑信息
MountModel.mountlistsevertime = 0--获取坐骑列表时的服务器时间 用于处理坐骑tip的倒计时

--初始化坐骑列表
function MountModel:InitMountList()
	self.horseDataList = {}
	
	--普通坐骑
	for k,cfg in pairs(t_horse) do
		local mountVO = MountVO:new()
		mountVO.mountId = cfg.id;
		mountVO.mountLevel = cfg.id;
		mountVO.nextId = cfg.nextId;
		mountVO.nameIcon = cfg.nameIcon;
		mountVO.shuzi_nameIcon = cfg.shuzi_nameIcon;
		mountVO.time = -1;
		table.insert(self.horseDataList ,mountVO);
	end
	
	--特殊坐骑
	for kskn,cfgskn in pairs(t_horseskn) do
		local mountVO = MountVO:new()
		mountVO.mountId = cfgskn.id;
		mountVO.mountLevel = cfgskn.id;
		mountVO.nameIcon = cfgskn.nameIcon;
		mountVO.shuzi_nameIcon = cfgskn.shuzi_nameIcon;
		mountVO.time = 0;
		table.insert(self.horseDataList ,mountVO);
	end
	
	table.sort(self.horseDataList,function(A,B)
		if A.mountLevel < B.mountLevel then
			return true;
		else
			return false;
		end
	end);
end

--获取坐骑
function MountModel:GetMountVO(mountid)
	for k,cfg in pairs(self.horseDataList) do
		if cfg.mountId == mountid then
			return cfg
		end
	end
	
	return nil
end

--获取当前坐骑等级
function MountModel:GetMountLvl()
	return self.ridedMount.mountLevel;
end

--添加坐骑
function MountModel:AddMount(mountVO)
	table.insert(self.horseDataList, mountVO);
	
	table.sort(self.horseDataList,function(A,B)
		if A.mountLevel < B.mountLevel then
			return true;
		else
			return false;
		end
	end);
end

-- 删除坐骑
function MountModel:DeleteMount(mountId)
	for k,cfg in pairs(self.horseDataList) do
		if cfg.mountId == mountId then
			self.horseDataList[k] = nil;
			return
		end
	end
end

-- 更新坐骑
function MountModel:UpdateMount(mountinfo)
	for k,cfg in pairs(self.horseDataList) do
		if cfg.mountId == mountinfo.mountId then
			self.horseDataList[k].time = mountinfo.time;
			return
		end
	end
end

-- 自己是否骑乘状态
function MountModel:isRideState()
	if MountModel.ridedMount.mountState == 1 then
		return true
	else
		return false
	end
end

-- 自己是否有坐骑
function MountModel:IsGetMount()
	if MountModel.ridedMount.mountLevel > 0 then
		return true
	else
		return false
	end
end

-- 坐骑状态
function MountModel:GetMountState(mountId)
	for k,cfg in pairs(self.horseDataList) do
		if cfg.mountId == mountId then
			return cfg.mountState
		end
	end
	
	return 0
end

-- 下一个骑乘状态
function MountModel:GetNextState()
	if self.ridedMount.mountState == 0 then
		return 1
	else
		return 0
	end
end

-- 坐骑升阶进度
function MountModel:FeedMount(mountLeve, mountStar, starProgress, uptype)
	--增加的进度
	local info = t_horse[self.ridedMount.mountLevel]
	if info == nil then
		return
	end
	
	local isup = false;
	if self.ridedMount.mountStar < mountStar then
		isup = true;
	end
	
	local addProgress = 0
	addProgress = starProgress - self.ridedMount.starProgress

	local oldstarProgress = self.ridedMount.starProgress
	
	self.ridedMount.mountId = mountLeve
	self.ridedMount.mountLevel = mountLeve
	self.ridedMount.mountStar = mountStar
	self.ridedMount.starProgress = starProgress
	
	--如果升阶了
	if starProgress == 0 then
		return;
	end
	
	--星升级 会播放特效
	if isup == true then
		self:sendNotification(NotifyConsts.MountXingUpSucChanged,{addProgress=addProgress, uptype=uptype, mountStar=mountStar, mountLeve=mountLeve});
	--星没有升级 只改变进度条
	else
		self:sendNotification(NotifyConsts.MountLvUpInfoChanged,{addProgress=addProgress, uptype=uptype, oldstarProgress = oldstarProgress});
	end
end

-- 坐骑进阶
function MountModel:MountLevelUpSuc(mountLeve)
	self.ridedMount.mountId = mountLeve
	self.ridedMount.mountLevel = mountLeve
	
	MountController:sendNotification(NotifyConsts.MountLvUpSucChanged);
end

-- 坐骑喂养属性丹进度
function MountModel:MountUsePill(pillNum)
	self.ridedMount.pillNum = pillNum
end

-- 更换坐骑
function MountModel:ChangeRideMount(mountId,rideState)
-- 当前乘坐的坐骑
	self.ridedMount.ridedId = mountId;
	self.ridedMount.mountState = rideState
	
	self:sendNotification(NotifyConsts.MountRidedChanged);
end

-- 更换坐骑状态
function MountModel:ChangeRideStarte(rideState)
	self.ridedMount.mountState = rideState
	
	self:sendNotification(NotifyConsts.MountRidedChangedState, {rideState=rideState});
end

-- 更换特殊坐骑
function MountModel:ChangeRideSpecialInfo(mountId, mounttime)
	for k,cfg in pairs(self.horseDataList) do
		if cfg.mountId == mountId then
			self.horseDataList[k].time = mounttime
			self:sendNotification(NotifyConsts.MountSkinTimeUpdate);
			return
		end
	end
end

-- 每一个坐骑剩余时间减少1秒
function MountModel:MountLoseSecond()
	for k,cfg in pairs(self.horseDataList) do
		if cfg.time > 0 then
			self.horseDataList[k].time = self.horseDataList[k].time - 1
			if self.horseDataList[k].time < 0 then
				self.horseDataList[k].time = 0
			end
		end
	end
end

-- 当前服务器时间
function MountModel:SetMountListServerTime(servertime)
	self.mountlistsevertime = servertime;
end