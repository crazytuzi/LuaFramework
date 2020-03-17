--[[
坐骑管理
zhangshuhui
2014年11月05日17:20:20
]]
_G.MountLingShouController = setmetatable({},{__index=IController})

MountLingShouController.name = "MountLingShouController";
MountLingShouController.biszidongbuy = 0;--自动购买
MountLingShouController.zidongtype = 0;--自动进阶类型
MountLingShouController.biszidongup = 0;--自动进阶
MountLingShouController.bstopzidongup = 0;--是否要停止自动进阶
MountLingShouController.bsended = 0;--是否发送了信息

--剩余的秒数
MountLingShouController.timelast = 0;
--剩余时间定时器key
MountLingShouController.lastTimerKey = nil;

--自动进阶间隔时间
MountLingShouController.ZiDongSpaceTime = 0;
--自动进阶是否计时
MountLingShouController.isZiDongTime = false;
--升阶进度条满后需要立即清空
MountLingShouController.ProgeressSpaceTime = 0;
--标记正在上马过程中
MountLingShouController.ridingState = false;

--获得灵力提示升星时间间隔
MountLingShouController.lingliuptimelast = 0;

function MountLingShouController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_LingShouHorseInfo,self,self.OnLingShouHorseInfo);
	MsgManager:RegisterCallBack(MsgType.SC_LSHorseLvlUpInfo,self,self.OnLSHorseLvlUpInfo);
	MsgManager:RegisterCallBack(MsgType.SC_LSHorseLvlUpSucess,self,self.OnLSHorseLvlUpSucess);
end
	
-- 坐骑进阶
function MountLingShouController:BuyMountUpTool(type,nBuyType)
	
	-- 默认材料不足自动购买
	local uptype = 0
	
	--不自动购买材料不足时
	if nBuyType == 0 then
		if type == 0 then
			--材料充足
			if MountUtil:GetIsJinJieByBagItem(MountLingShouModel.mountLevel) == 1 then
				uptype = 1
			--材料不足
			else
				--取消自动进阶
				if self.biszidongup == 1 then
					self:FailCancelUpZiDong(1)
				end
				return
			end
		elseif type == 1 then
			--灵力充足
			if MountUtil:GetIsJinJieByLingLi(MountLingShouModel.mountLevel) == 1 then
				uptype = 1
			--材料不足
			else
				--取消自动进阶
				if self.biszidongup == 1 then
					self:FailCancelUpZiDong(3)
				end
				return
			end
		end
	--自动购买材料不足时
	else
		--材料充足
		if MountUtil:GetIsJinJieByBagItem(MountLingShouModel.mountLevel) == 1 then
			uptype = 1
		--材料不足,自动购买
		else
			--金钱足够买升阶所需的进阶丹
			if MountUtil:GetIsJinJieByMoney(MountLingShouModel.mountLevel) == 1 then
				uptype = 0
			--没钱购买升阶所需的进阶丹
			else
				--取消自动进阶
				if self.biszidongup == 1 then
					self:FailCancelUpZiDong(1)
				end
				return
			end
		end
	end
	
	--银两不足
	if MountUtil:GetIsJinJieByYinLiang(MountLingShouModel.mountLevel) == 0 then
		--取消自动进阶
		if self.biszidongup == 1 then
			self:FailCancelUpZiDong(2)
		end
		return;
	end
	
	if self.bstopzidongup == 1 then
		if self.bstopzidongup == 1 then
			self:SucCancelUpZiDong()
		else
			self.bstopzidongup = 0
		end
	end
	
	self.bsended = 1
	local msg = ReqLSHorseLvlUpMsg:new()
	msg.type = type
	msg.autoBuy = uptype
	MsgManager:Send(msg)
	
	-- print('=============灵兽坐骑进阶')
	-- trace(msg)
end

function MountLingShouController:BeforeLineChange()
	--取消自动进阶
	if self.biszidongup == 1 then
		self:FailCancelUpZiDong(0)
	end
end

function MountLingShouController:BeforeEnterCross()
	--取消自动进阶
	if self.biszidongup == 1 then
		self:FailCancelUpZiDong(0)
	end
end


-- 返回灵兽坐骑信息
function MountLingShouController:OnLingShouHorseInfo(msg)
	-- print('=============返回灵兽坐骑信息')
	-- trace(msg)
	MountLingShouModel.mountLevel = msg.lshorseStep;
	MountLingShouModel.starProgress = msg.starProgress;
	MountLingShouModel:SetZZPillNum(msg.zzpillNum)
	--星级改成自己算
	MountLingShouModel.mountStar = MountUtil:GetStarByProgress(msg.lshorseStep, msg.starProgress);
	self:StartLastTimer();
end

-- 返回灵兽坐骑进阶进度
function MountLingShouController:OnLSHorseLvlUpInfo(msg)
	-- print('=============返回灵兽坐骑进阶进度')
	-- trace(msg)
	
	self.bsended = 0
	
	if msg.result == 0 then
		local rideStar = MountUtil:GetStarByProgress(msg.lshorseLevel, msg.starProgress);
		
		MountLingShouModel:FeedMount(msg.lshorseLevel, rideStar, msg.starProgress, msg.uptype)
		
		-- 升阶了则取消自动进阶状态
		if rideStar >= MountConsts.MountStarMax then
			self.biszidongup = 0
			self.bsended = 0;
			self:sendNotification(NotifyConsts.MountLSSucCancelZiDong);
		end
		
		if self.bstopzidongup == 1 then
			self.biszidongup = 0
			self.ZiDongSpaceTime = 0;
			self.isZiDongTime = false;
			self.bstopzidongup = 0
			self:sendNotification(NotifyConsts.MountLSSucCancelZiDong);
		end
		
		print('===================self.biszidongup=',self.biszidongup)
		
		--继续自动进阶
		if self.biszidongup == 1 then
			self.ZiDongSpaceTime = 0;
			self.isZiDongTime = true;
		end
		
	--灵力还未通知客户端消耗信息
	elseif msg.result == 3 then
		self:FailCancelUpZiDong(2)
	elseif msg.result == 4 then
		self:FailCancelUpZiDong(1)
	else
		self:FailCancelUpZiDong(0)
	end
end

-- 返回灵兽坐骑进阶成功
function MountLingShouController:OnLSHorseLvlUpSucess(msg)
	-- print('=============返回灵兽坐骑进阶成功')
	-- trace(msg)
	
	MountLingShouModel:MountLevelUpSuc(msg.lshorseLevel)
	
	--强制使用最新皮肤
	MountController:ChangeMount(msg.lshorseLevel);
	--强制骑上坐骑
	if MountModel.ridedMount.mountState == 0 then
		MountController:RideMount();
	end
end

-- 自动进阶,模拟自动进阶
function MountLingShouController:MountUpZiDong(type,nBuyType)
	if self.biszidongup == 1 or self.bstopzidongup == 1 then
		return 0
	end
	
	self.biszidongbuy = nBuyType
	self.zidongtype = type;
	self.biszidongup = 1
	
	self:BuyMountUpTool(type,nBuyType)
	
	return 1
end

-- 进阶成功取消自动进阶
function MountLingShouController:SucCancelUpZiDong()
	if self.bsended == 0 then
		self.biszidongup = 0
		self.ZiDongSpaceTime = 0;
		self.isZiDongTime = false;
		self:sendNotification(NotifyConsts.MountLSSucCancelZiDong);
	else
		self.bstopzidongup = 1
	end
end

-- 材料不足取消自动进阶 1 材料不足 2 银两不足
function MountLingShouController:FailCancelUpZiDong(type)
	self.biszidongup = 0
	self.ZiDongSpaceTime = 0;
	self.isZiDongTime = false;
	self:sendNotification(NotifyConsts.MountLSFailCancelZiDong, {type=type});
end

function MountLingShouController:StartLastTimer()
	if not self.lastTimerKey then
		self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 100, 0 );
	end
end

--倒计时自动
function MountLingShouController.DecreaseTimeLast( count )
	--自动进阶间隔时间
	if MountLingShouController.isZiDongTime == true then
		MountLingShouController.ZiDongSpaceTime = MountLingShouController.ZiDongSpaceTime + 0.1;
		
		if MountLingShouController.ZiDongSpaceTime >= MountConsts.ZiDongSpaceTime then
			MountLingShouController.isZiDongTime = false;
			MountLingShouController.ZiDongSpaceTime = 0;
			MountLingShouController:BuyMountUpTool(MountLingShouController.zidongtype,MountLingShouController.biszidongbuy);
		end
	end
end