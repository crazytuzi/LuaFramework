--[[
v计划

]]
_G.VplanController = setmetatable({},{__Index = IController});
VplanController.name = "VplanController";

function VplanController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_VPlan,			self,self.OnVplan); -- 8357
	MsgManager:RegisterCallBack(MsgType.SC_VPlanGift,		self,self.OnVPlanGift); -- 8358
	MsgManager:RegisterCallBack(MsgType.SC_VLevelGift,		self,self.OnVLevelGift); -- 8359
	MsgManager:RegisterCallBack(MsgType.SC_VDayGift,		self,self.OnVDayGift); -- 8360
	MsgManager:RegisterCallBack(MsgType.SC_VVGift,			self,self.OnVVGift); -- 8361
	MsgManager:RegisterCallBack(MsgType.SC_VYearGift,		self,self.OnVYearGift); -- 8362
	MsgManager:RegisterCallBack(MsgType.SC_VTitle,			self,self.OnVTitle); -- 8363
	MsgManager:RegisterCallBack(MsgType.SC_VplanMyInfo,		self,self.OnVmyinfo); -- 8527
	MsgManager:RegisterCallBack(MsgType.SC_VPlanBuyGiftDate,self,self.OnVPlanBuyGiftDate); -- 8530 这个是消费礼包下个月加！
end;

--打开V官网
function VplanController:ToWebSite()
	Version:VPlanBrowse();
end

--打开月费充值界面
function VplanController:ToMRecharge()
	Version:VPlanMRecharge();
end

--打开年费充值界面
function VplanController:ToYRecharge()
	Version:VPlanYRecharge();
end

function VplanController:OnEnterGame()
	self:ReqVplan();
end

--返回平台V信息
function VplanController:OnVplan(msg)
	VplanModel:SetVplaninfo(msg)
	Notifier:sendNotification(NotifyConsts.VFlagChange);
	-- trace(msg)
	-- print('V平台信息')
end;

--返回V计划礼包领取情况 --登录推
function VplanController:OnVPlanGift(msg)
	VplanModel:SetVplanGift(msg);
	-- trace(msg)
	-- print("收到登录推消息， 礼包领取情况")
	-- debug.debug();
	Notifier:sendNotification(NotifyConsts.VFlagChange);
end;

--返回领取V等级礼包
function VplanController:OnVLevelGift(msg)
	-- trace(msg);
	-- print("返回领取V等级礼包")
	for i,info in ipairs(msg.levelGiftRet) do 
		if info.result == 0 then 
			-- 成功，领取
			FloatManager:AddNormal(StrConfig["vplan206"]);
		elseif info.result == 1 then 
			-- 不可领取
			FloatManager:AddNormal(StrConfig["vplan208"]);
		elseif info.result == 2 then 
			-- 以领取
			FloatManager:AddNormal(StrConfig["vplan207"]);
		end;
		VplanModel:SetvplanLvlGift(info.id,info.result)
	end;
	if UIVplanLevelGift:IsShow()  then 
		UIVplanLevelGift:OnShowData()
	end;
	
end;

--返回领取V每日礼包
function VplanController:OnVDayGift(msg)
	-- trace(msg);
	-- print("返回领取V每日礼包")
	if msg.result == 0 then 
		-- 成功，领取
		FloatManager:AddNormal(StrConfig["vplan206"]);
	elseif msg.result == 1 then 
		-- 不可领取
		FloatManager:AddNormal(StrConfig["vplan208"]);
	elseif msg.result == 2 then 
		-- 以领取
		FloatManager:AddNormal(StrConfig["vplan207"]);
	end;
	if UIVplanDailyReward:IsShow() then 
		UIVplanDailyReward:UpUIdata()
	end;
end;

--返回领取V首充礼包
function VplanController:OnVVGift(msg)	
	if msg.result == 0 then 
		-- 成功，领取
		FloatManager:AddNormal(StrConfig["vplan206"]);
	elseif msg.result == 1 then 
		-- 不可领取
		FloatManager:AddNormal(StrConfig["vplan208"]);
	elseif msg.result == 2 then 
		-- 以领取
		FloatManager:AddNormal(StrConfig["vplan207"]);
	end;
	-- VplanModel:SetvplanVGift(msg.result);
	if UIVplanNoviceBag:IsShow()  then 
		UIVplanNoviceBag:OnSetUIState();
		UIVplanNoviceBag:OnShowList();
	end;
	-- trace(msg);
	-- print("返回领取V首充礼包")
end;

--返回领取V年费礼包
function VplanController:OnVYearGift(msg)
	if msg.result == 0 then 
		-- 成功，领取
		FloatManager:AddNormal(StrConfig["vplan206"]);
	elseif msg.result == 1 then 
		-- 不可领取
		FloatManager:AddNormal(StrConfig["vplan208"]);
	elseif msg.result == 2 then 
		-- 以领取
		FloatManager:AddNormal(StrConfig["vplan207"]);
	end;
	--VplanModel:SetVYearGift(msg.result);
	if UIVplanYear:IsShow()  then 
		UIVplanYear:SetShowState()
	end;
	-- trace(msg);
	-- print("返回领取V年费礼包")
end;

--返回领取V称号
function VplanController:OnVTitle(msg)
	if msg.result == 0 then 
		-- 成功，领取
		FloatManager:AddNormal(StrConfig["vplan206"]);
	elseif msg.result == 1 then 
		-- 不可领取
		FloatManager:AddNormal(StrConfig["vplan208"]);
	elseif msg.result == 2 then 
		-- 以领取
		FloatManager:AddNormal(StrConfig["vplan207"]);
	end;
	--print("返回领取V称号")
	if UIVplanTitleNew:IsShow() then 
		UIVplanTitleNew:InintUiData()
	end;
end;


function VplanController:OnVmyinfo(msg)
	-- trace(msg)
	-- print("收到服务器返回我的信息")
	-- debug.debug();
	VplanModel:SetMyVinfo(msg.exp,msg.Allexp,msg.speed,msg.expiretime)

	if UIMyVplanInfo:IsShow() then 
		UIMyVplanInfo:UpdataUI()
	end;
end;

function VplanController:OnVPlanBuyGiftDate(msg)
	local giftList = msg.BuyGift;
	local restTime = msg.restTime;
	local xnum 	   = msg.xnum;
	VplanModel:VplanBuyGiftInfo(giftList,restTime,xnum);
	if UIVplanBuyGift:IsShow() then 
		UIVplanBuyGift:ShowPanelDate();
	end
end;
--------------------------C to s

--请求平台V信息
function VplanController:ReqVplan()
	if Version:IsOpenVPlan() then
		local msg = ReqVPlanMsg:new()
		MsgManager:Send(msg)
	end
end;

--V等级礼包
function VplanController:ReqVplanLevelGift(list)
	local msg = ReqVLevelGiftMsg:new()
	msg.levelGift = list;
	MsgManager:Send(msg)
	-- print("V等级礼包")
	-- trace(msg)

end;
--V每日礼包
function VplanController:ReqVplanDayGift(type)
	local msg = ReqVDayGiftMsg:new();
	msg.type = type
	MsgManager:Send(msg)
	-- print("V每日礼包")
end;

--V首充礼包
function VplanController:ReqVplanVGift()
	local msg = ReqVVGiftMsg:new();
	MsgManager:Send(msg)
	-- print("V首充礼包")
end;

--V年费礼包
function VplanController:ReqVplanYearGift()
	local msg = ReqVYearGiftMsg:new()
	MsgManager:Send(msg)
	-- print("V年费礼包")
end;

--V称号
function VplanController:ReqVplanTitle(type)
	local msg = ReqVTitleMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
	-- print("V称号")
end;

--请求领取消费礼包
function VplanController:ReqBuyGift(index)
	local msg = ReqGiveBuyGiftMsg:new();
	msg.index = index;
	MsgManager:Send(msg);
end