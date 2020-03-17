--[[坐骑界面主面板
zhangshuhui
2014年11月05日17:20:20
]]

_G.MountLingShouModel = Module:new();

MountLingShouModel.mountLevel = 0;
MountLingShouModel.starProgress = 0;
MountLingShouModel.mountStar = 0;
MountLingShouModel.zzpillNum = 0;

--获取当前坐骑等级
function MountLingShouModel:GetMountLvl()
	return MountLingShouModel.mountLevel;
end

-- 坐骑升阶进度
function MountLingShouModel:FeedMount(mountLeve, mountStar, starProgress, uptype)
	local isup = false;
	if self.mountStar < mountStar then
		isup = true;
	end
	
	local addProgress = 0
	addProgress = starProgress - self.starProgress

	local oldstarProgress = self.starProgress
	
	self.mountLevel = mountLeve
	self.mountStar = mountStar
	self.starProgress = starProgress
	
	--如果升阶了
	if starProgress == 0 then
		return;
	end
	
	--星升级 会播放特效
	if isup == true then
		self:sendNotification(NotifyConsts.MountLSXingUpSucChanged,{addProgress=addProgress, uptype=uptype, mountStar=mountStar, mountLeve=mountLeve});
	--星没有升级 只改变进度条
	else
		self:sendNotification(NotifyConsts.MountLSLvUpInfoChanged,{addProgress=addProgress, uptype=uptype, oldstarProgress = oldstarProgress});
	end
end

-- 坐骑进阶
function MountLingShouModel:MountLevelUpSuc(mountLeve)
	self.mountLevel = mountLeve
	
	MountController:sendNotification(NotifyConsts.MountLSLvUpSucChanged);
end

-- 坐骑进阶
function MountLingShouModel:MountLevelUpSuc(mountLeve)
	self.mountLevel = mountLeve
	
	MountController:sendNotification(NotifyConsts.MountLSLvUpSucChanged);
end

-- 资质丹
function MountLingShouModel:SetZZPillNum(zznum)
	self.zzpillNum = zznum;
	self:sendNotification(NotifyConsts.MountLSZZSXDChanged);
end

function MountLingShouModel:GetZZPillNum()
	return self.zzpillNum;
end

-- 零售坐骑等级上限
function MountLingShouModel:GetMaxLevel()
	if not maxLevel then
		maxLevel = 0
		for level, _ in pairs(t_horselingshou) do
			maxLevel = math.max(maxLevel, level)
		end
	end
	return maxLevel
end