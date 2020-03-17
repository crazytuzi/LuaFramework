--[[
360卫士
wangshuai
]]

_G.WeishiController = setmetatable({},{__index=IController});
WeishiController.name = "WeishiController";

function WeishiController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_PrerogativeReward  ,self,self.WeishiReward)
	MsgManager:RegisterCallBack(MsgType.SC_PrerogativeInfo  ,self,self.TequanReward)
	MsgManager:RegisterCallBack(MsgType.SC_BackWeishiStatus ,self,self.WeishiState)
	MsgManager:RegisterCallBack(MsgType.SC_WeiShiChannelReward ,self,self.WanChannelReward)	
end;

--卫士特权按钮是否显示
WeishiController.isShowWeishiState = false;
--卫士特权加速礼包按钮是否显示
WeishiController.isShowWeishiQuickState = false;
--wan平台指定渠道进入领奖礼包按钮是否显示
WeishiController.isShowwanChannelShowRewardBtnState = true;  --目前先默认他是true
function WeishiController:WeishiState(msg)
	if msg.type == 1 then
		self:WeishiTeQuanState(msg);
	elseif msg.type == 3 then
		self:WeishiTeQuanQuickState(msg);
	end;
end;
--卫士特权
function WeishiController:WeishiTeQuanState(msg)
	if msg.status == 0 then 
		self.isShowWeishiState = false;
	elseif msg.status == 1 then 
		self.isShowWeishiState = true;
	end;
	UIMainYunYingFunc:DrawLayout();
end;
--卫士特权加速礼包
function WeishiController:WeishiTeQuanQuickState(msg)
	if msg.status == 0 then 
		self.isShowWeishiQuickState = false;
	elseif msg.status == 1 then 
		self.isShowWeishiQuickState = true;
	end;
	UIMainYunYingFunc:DrawLayout();
end;

function WeishiController:WeishiReward(msg)
	if msg.type == 1 then  --卫士特权
		 if msg.result == 0 then 
		 	--成功
			UIConfirm:Open(StrConfig["yunying015"]);
		 elseif msg.result == 1 then 
		 	-- 系统繁忙，请您稍后再来领取特权！
		 	UIConfirm:Open( StrConfig['yunying004']);
		 elseif msg.result == 2 then 
		 	-- 已领取
		 	UIConfirm:Open( StrConfig['yunying014']);
		 elseif msg.result == -1 then 
		 	-- 请先登录安全卫士，领取对应特权，获得礼包领取资格
		 	local fun = function() 
		 				Version:Hd360Browse()
		 				end;
		 	UIConfirm:Open( StrConfig['yunying005'],fun);
		 elseif msg.result == -2 then 
		 	--您的安全卫士等级不满足领取条件，请提升卫士等级
		 		local fun = function() 
		 				Version:Hd360Browse()
		 				end;
		 	UIConfirm:Open( StrConfig['yunying006'],fun);
		 elseif msg.result == -3 then 
		 	-- 系统错误，请您稍后再来领取特权！
		 	UIConfirm:Open( StrConfig['yunying007']);
		 elseif msg.result == -4 then 
		 	--特权活动未上线，请等待上线后再来领取;
		 	UIConfirm:Open( StrConfig['yunying008']);
		 elseif msg.result == -5 then 
		 	-- 很遗憾！360卫士特权活动已结束，敬请期待下次活动！
		 	UIConfirm:Open( StrConfig['yunying009']);
		 elseif msg.result == -6 then 
		 	--系统异常，请您稍后再来领取特权！;
		 	UIConfirm:Open( StrConfig['yunying010']);
		 elseif msg.result == -7 then 
		 	--请先登录安全卫士，领取对应特权，分享特权活动到指定社交平台获得分享礼包;
		 	local fun = function() 
		 				Version:Hd360Browse()
		 				end;
		 	UIConfirm:Open( StrConfig['yunying011'],fun);
		 elseif msg.result == -8  then 
		 	--礼包审核中，我们将于您分享特权活动48小时之后给您发送礼包，请耐心等待！;
		 	UIConfirm:Open( StrConfig['yunying012']);
		 end;
	elseif msg.type == 2 then --  游戏大厅
		if msg.result == -1 then 
			--活动未开启
		 	UIConfirm:Open( StrConfig['yunying013']);
		elseif msg.result == -2 then 
			-- 已领取
		 	UIConfirm:Open( StrConfig['yunying014']);
		end;
	end;
end;

function WeishiController:TequanReward(msg)
	for i,info in ipairs(msg.PrerogativeList) do 
		if info.type == 1 then      --卫士特权
			Weishi360Model:SetCurLvlState(info.flags)
		elseif info.type == 2 then  -- 游戏大厅
			Weishi360Model:SetCurDataState(info.flags)
		elseif info.type == 3 then  -- 特权加速礼包
			Weishi360Model:SetCurDayQuickReward(info.flags);
		end;	 
	end;
	if UIyouxi360:IsShow() then 
		UIyouxi360:UpdataUI();
	end;
	if UIWeishi360:IsShow() then 
		UIWeishi360:ShowLIst();
	end;
	if UIweishi360TeQuanQuickView:IsShow() then 
		UIweishi360TeQuanQuickView:ShowLIst();
	end;
	self:sendNotification(NotifyConsts.Youxi360Update);
end;

function WeishiController:ReqGetReward(type,param)
	print("--------发给服务器")
	local msg = ReqPrerogativeRewardMsg:new();
	msg.type =  type;
	msg.param = param;
	MsgManager:Send(msg);
end;

-- 请求领取wan平台特殊奖励
function WeishiController:ReqWanChannelReward( target )
	local msg = ReqWeiShiChannelRewardMsg:new()
	msg.type = target
	MsgManager:Send(msg)
end

-- 收到玩平台的操作结果
function WeishiController:WanChannelReward(msg)
	Weishi360Model:SetWanChannelReward(1,msg.type1)
	Weishi360Model:SetWanChannelReward(2,msg.type2)
	Weishi360Model:SetWanChannelReward(3,msg.type3)
	self:sendNotification(NotifyConsts.wanChannelUpdata);
end










