--[[
坐骑管理
zhangshuhui
2014年11月05日17:20:20
]]
_G.MountController = setmetatable({},{__index=IController})

MountController.name = "MountController";
MountController.biszidongbuy = 0;--自动购买
MountController.zidongtype = 0;--自动进阶类型
MountController.biszidongup = 0;--自动进阶
MountController.bstopzidongup = 0;--是否要停止自动进阶
MountController.bsended = 0;--是否发送了信息

--剩余的秒数
MountController.timelast = 0;
--剩余时间定时器key
MountController.lastTimerKey = nil;

--自动进阶间隔时间
MountController.ZiDongSpaceTime = 0;
--自动进阶是否计时
MountController.isZiDongTime = false;
--升阶进度条满后需要立即清空
MountController.ProgeressSpaceTime = 0;
--标记正在上马过程中
MountController.ridingState = false;

--获得灵力提示升星时间间隔
MountController.lingliuptimelast = 0;

function MountController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_RideInfo,self,self.OnMountInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_RideLvlUpInfo,self,self.OnMountLvlUpInfo);
	MsgManager:RegisterCallBack(MsgType.SC_RideLvlUpSucess,self,self.OnMountLvUpSucResult);
	MsgManager:RegisterCallBack(MsgType.SC_UseAttrDan,self,self.OnMountUsePill);
	MsgManager:RegisterCallBack(MsgType.SC_ChangeRideId,self,self.OnChangeRideMountResult);
	MsgManager:RegisterCallBack(MsgType.SC_ChangeRideState,self,self.OnChangeRideStateResult);
	MsgManager:RegisterCallBack(MsgType.SC_RideSpecial,self,self.OnRideSpecialInfo);
end

---------------------------以下为客户端发送消息-----------------------------
-- 坐骑进阶
function MountController:BuyMountUpTool(type,nBuyType)
	
	-- 默认材料不足自动购买
	local uptype = 0
	--不自动购买材料不足时
	if nBuyType == 0 then
		--材料充足
		if MountUtil:GetIsJinJieByBagItem(MountModel.ridedMount.mountLevel) == 1 then
			uptype = 1
		--材料不足
		else
			--取消自动进阶
			if self.biszidongup == 1 then
				self:FailCancelUpZiDong(1)
			end
			return
		end
	--自动购买材料不足时
	else
		--材料充足
		if MountUtil:GetIsJinJieByBagItem(MountModel.ridedMount.mountLevel) == 1 then
			uptype = 1
		--材料不足,自动购买
		else
			--金钱足够买升阶所需的进阶丹
			if MountUtil:GetIsJinJieByMoney(MountModel.ridedMount.mountLevel) == 1 then
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
	if MountUtil:GetIsJinJieByYinLiang(MountModel.ridedMount.mountLevel) == 0 then
		--取消自动进阶
		if self.biszidongup == 1 then
			self:FailCancelUpZiDong(2)
		end
		return;
	end
		if self.bstopzidongup == 1 then
			self:SucCancelUpZiDong()
		else
			self.bstopzidongup = 0
		end
	
	
	self.bsended = 1
	local msg = ReqRideLvlUpMsg:new()
	msg.type = type
	msg.autoBuy = uptype
	MsgManager:Send(msg)
end

-- 自动进阶,模拟自动进阶
function MountController:MountUpZiDong(type,nBuyType)
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
function MountController:SucCancelUpZiDong()
	if self.bsended == 0 then
		self.biszidongup = 0
		self.ZiDongSpaceTime = 0;
		self.isZiDongTime = false;
		self:sendNotification(NotifyConsts.MountSucCancelZiDong);
	else
		self.bstopzidongup = 1
	end
end

-- 材料不足取消自动进阶 1 材料不足 2 银两不足
function MountController:FailCancelUpZiDong(type)
	self.biszidongup = 0
	self.ZiDongSpaceTime = 0;
	self.isZiDongTime = false;
	self:sendNotification(NotifyConsts.MountFailCancelZiDong, {type=type});
end

-- 使用属性丹
-- 1、坐骑，2、灵兽，3、神兵、4、灵阵，5、骑战，6、神灵，7、元灵，8、灵兽坐骑百分比属性丹，9、战弩，10 = 五行灵脉 11 法宝 12 命玉 13  保甲 14  境界
function MountController:FeedShuXingDan(type)
	local msg = ReqUseAttrDanMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
	
	-- print('===============使用属性丹')
	-- trace(msg)
end

-- 上下坐骑
function MountController:RideMount()
	if not MountUtil:IsCanMount() then
		return
	end
	if MountController.ridingState == true then
		return
	end
	local rideState = MountModel:GetNextState()
	--判断腰闪了没
	if self.timelast < MountConsts.RideMountTime then
		FloatManager:AddCenter(StrConfig["mount14"])
		return;
	end
		--客户端先下马
	if rideState == 0 then
		local selfRoleID = MainPlayerController:GetRoleID()
		CPlayerMap:OnPlayerMountChange(selfRoleID, 0)
	    --请求上马
	elseif rideState == 1 then
		if not MainPlayerController:IsCanRide() then
			FloatManager:AddCenter(StrConfig["mount15"])
			return
		end
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit()
		end
		MountController:SetReqRidingState()
	end

	local msg = ReqChangeRideStateMsg:new()
	msg.rideState = rideState
	MsgManager:Send(msg)

end

-- 更改骑坐骑
function MountController:ChangeMount(mountId)
	local msg = ReqChangeRideIdMsg:new()
	msg.rideId = mountId
	MsgManager:Send(msg)
end

-- 下坐骑
function MountController:RemoveRideMount()
	--客户端先下马
	local selfRoleID = MainPlayerController:GetRoleID()
	CPlayerMap:OnPlayerMountChange(selfRoleID, 0)
	if MountController.ridingState == true then
		return
	end
	local rideState = MountModel:GetNextState()
	if rideState == 0 then 
		local msg = ReqChangeRideStateMsg:new()
		msg.rideState = rideState
		MsgManager:Send(msg)
	end
end


function MountController:BeforeLineChange()
	--取消自动进阶
	if self.biszidongup == 1 then
		self:FailCancelUpZiDong(0)
	end
end

function MountController:BeforeEnterCross()
	--取消自动进阶
	if self.biszidongup == 1 then
		self:FailCancelUpZiDong(0)
	end
end


---------------------------以下为处理服务器返回消息-----------------------------
-- 坐骑列表消息
function MountController:OnMountInfoResult(msg)
	-- print('=============坐骑列表消息')
	-- trace(msg)
	if msg.rideLevel == 0 then
		Debug("拥有0个坐骑");
	end
	-- 加载坐骑数据表
	MountModel:InitMountList();
	
	local mountVO = MountVO:new();
	MountModel.ridedMount.mountId = msg.rideLevel;
	MountModel.ridedMount.mountLevel = msg.rideLevel;
	MountModel.ridedMount.starProgress = msg.starProgress;
	--星级改成自己算
	MountModel.ridedMount.mountStar = MountUtil:GetStarByProgress(msg.rideLevel, msg.starProgress);
	MountModel.ridedMount.zizhiNum=msg.zizhiNum;
	ZiZhiModel:SetZZNum(6, msg.zizhiNum)
	MountModel.ridedMount.pillNum = msg.pillNum;
	MountModel.ridedMount.mountState = msg.rideState;
	
	-- 当前乘坐的坐骑
	MountModel.ridedMount.ridedId = msg.rideId;
	--登陆骑乘
	if MountModel.ridedMount.mountState == 1 then
		local ModelId = MountUtil:GetPlayerMountModelId(MountModel.ridedMount.ridedId);
		if MountModel.ridedMount.ridedId ~= 0 and ModelId ~= 0 then
			local player = MainPlayerController:GetPlayer()
			if player then
				player:GetPlayerShowInfo().dwHorseID = ModelId
			end
		end
	end
	
	-- 特殊坐骑
	for i,vo in ipairs(msg.specailRides) do
		if vo.rideId ~= 0 then
			local mountVOSpecail = MountVO:new();
			mountVOSpecail.mountId = vo.rideId;
			mountVOSpecail.mountLevel = vo.rideId;
			--毫秒转换为秒
			if vo.time <= 0 then
				mountVOSpecail.time = vo.time;
			else
				mountVOSpecail.time = vo.time;
			end
			MountModel:UpdateMount(mountVOSpecail);
		end
	end
	
	--记录服务器时间
	local curtime = GetServerTime();
	MountModel:SetMountListServerTime(curtime);
	
	self:StartLastTimer();
end
	
-- 返回坐骑进阶进度
function MountController:OnMountLvlUpInfo(msg)
	-- print('=============返回坐骑进阶进度')
	-- trace(msg)
	
	self.bsended = 0
	
	if msg.result == 0 then
		VipModel:SetIsChange(VipConsts.TYPE_MOUNT,true);
		local rideStar = MountUtil:GetStarByProgress(msg.rideLevel, msg.starProgress);
		
		MountModel:FeedMount(msg.rideLevel, rideStar, msg.starProgress, msg.uptype)
		
		-- 升阶了则取消自动进阶状态
		if rideStar >= MountConsts.MountStarMax then
			self.biszidongup = 0
			self.bsended = 0;
			self:sendNotification(NotifyConsts.MountSucCancelZiDong);
		end
		
		if self.bstopzidongup == 1 then
			self.biszidongup = 0
			self.ZiDongSpaceTime = 0;
			self.isZiDongTime = false;
			self.bstopzidongup = 0
			self:sendNotification(NotifyConsts.MountSucCancelZiDong);
		end
		
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

-- 坐骑成功进阶
function MountController:OnMountLvUpSucResult(msg)
	-- print('=============坐骑成功进阶')
	-- trace(msg)
	
	MountModel:MountLevelUpSuc(msg.rideLevel)
	
	--强制使用最新皮肤
	MountController:ChangeMount(msg.rideLevel);
	--强制骑上坐骑
	if MountModel.ridedMount.mountState == 0 then
		MountController:RideMount();
	end
end

-- 坐骑使用属性丹
-- 1、坐骑，2、灵兽，3、神兵、4、灵阵，5、骑战，6、神灵，7、元灵，8、灵兽坐骑百分比属性丹，9、战弩，10 = 五行灵脉 11 法宝 12 命玉 13  保甲 14  境界
function MountController:OnMountUsePill(msg)
	-- print('===============坐骑使用属性丹')
	-- trace(msg)
	if msg.result == 0 then
		FloatManager:AddNormal( StrConfig["mount21"]);
		if msg.type == 1 then
			MountModel:MountUsePill(msg.pillNum);
		elseif msg.type == 2 then
			SpiritsModel:SetPillNum(msg.pillNum);
		elseif msg.type == 3 then
			MagicWeaponModel:SetPillNum(msg.pillNum);
		elseif msg.type == 5 then
			QiZhanModel:SetPillNum(msg.pillNum);
		elseif msg.type == 8 then
			MountLingShouModel:SetZZPillNum(msg.pillNum);
		-- elseif msg.type == 10 then
		-- 	WuxinglingmaiModel:SetPillNum(msg.pillNum);
		elseif msg.type == 11 then
			LingQiModel:SetPillNum(msg.pillNum);
		elseif msg.type == 12 then
			MingYuModel:SetPillNum(msg.pillNum);
		elseif msg.type == 13 then
			ArmorModel:SetPillNum(msg.pillNum);
		elseif msg.type == 14 then
			RealmModel:SetPillNum(msg.pillNum);
		end
		self:sendNotification(NotifyConsts.MountUsePillChanged);
	end
end

-- 更改坐骑结果
function MountController:OnChangeRideMountResult(msg)
	-- print('=============更改坐骑结果')
	-- trace(msg)
	
	if msg.result == 0 then
		-- 骑坐骑失败
		return
	else
		MountModel:ChangeRideMount(msg.rideId,msg.rideState)
	end
end

-- 上下坐骑结果
function MountController:OnChangeRideStateResult(msg)
	-- print('=============上下坐骑结果')
	-- trace(msg)
	
	if msg.rideState == 0 then
		self.timelast = 0;
	end
	MountController.ridingState = false
	MountModel:ChangeRideStarte(msg.rideState)
end

-- 特色坐骑时间变动
function MountController:OnRideSpecialInfo(msg)
	print('=============特色坐骑时间变动')
	-- trace(msg)
	--过期
	if msg.time == 0 then
		--当前乘坐的坐骑
		if MountModel.ridedMount.ridedId == msg.rideId then
			self:ChangeMount(MountModel.ridedMount.mountLevel);
		end
	else
		self:ChangeMount(msg.rideId);
	end
	
	MountModel:ChangeRideSpecialInfo(msg.rideId, msg.time)
end

function MountController:StartLastTimer()
	if not self.lastTimerKey then
		self.timelast = MountConsts.RideMountTime;
		self.lingliuptimelast = MountConsts.lingliuptimelast;
		self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 100, 0 );
	end
end

--倒计时自动
function MountController.DecreaseTimeLast( count )
	MountController.timelast = MountController.timelast + 0.1;
	MountController.lingliuptimelast = MountController.lingliuptimelast + 0.1;
	
	--自动进阶间隔时间
	if MountController.isZiDongTime == true then
		MountController.ZiDongSpaceTime = MountController.ZiDongSpaceTime + 0.1;
		
		if MountController.ZiDongSpaceTime >= MountConsts.ZiDongSpaceTime then
			MountController.isZiDongTime = false;
			MountController.ZiDongSpaceTime = 0;
			MountController:BuyMountUpTool(MountController.zidongtype,MountController.biszidongbuy);
		end
	end
end

-- 灵力变化弹出升阶提示
function MountController:OnLingLiChange()
	if MountUtil:GetIsMountUpLingLi() == true then
		if MountController.lingliuptimelast > MountConsts.lingliuptimelast then
			MountController.lingliuptimelast = 0;
			UIItemGuide:Open(13);
		end
	end
end

function MountController:SetReqRidingState()
	MountController.ridingState = true
	if MountController.timePlan then
		TimerManager:UnRegisterTimer(MountController.timePlan)
	end
	MountController.timePlan = TimerManager:RegisterTimer(function()
		MountController.ridingState = false	
	end, 3000, 1)
end
function MountController:GetMountUpdate()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Horse) then  return false  end
	if  MountUtil:CheckCanLvUp() then
		return true;
	else
		return false;
	end

end
