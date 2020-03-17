--[[
	登陆奖励
	2014年12月16日, PM 12:11:24
	wangyanwei
]]

_G.RegisterAwardController = setmetatable({},{__index=IController})

RegisterAwardController.name="RegisterAwardController";

function RegisterAwardController:Create()
	--签到
	MsgManager:RegisterCallBack(MsgType.SC_SignListResult,self,self.OnSubmitSighResult);
	MsgManager:RegisterCallBack(MsgType.SC_SignRewardResult,self,self.OnSubmitVipResult);
	MsgManager:RegisterCallBack(MsgType.SC_Sign,self,self.OnBackSignesult);
	MsgManager:RegisterCallBack(MsgType.SC_SignResult,self,self.OnBackSigneResult);
	--在线抽奖
	MsgManager:RegisterCallBack(MsgType.SC_BackRewardIndex,self,self.OnBackRewardIndex);  --返回抽奖的索引
	MsgManager:RegisterCallBack(MsgType.SC_BackRewardNum,self,self.OnBackRewardInfo);	 --返回抽奖次数及累积在线时间

	MsgManager:RegisterCallBack(MsgType.SC_LvRewardInfo,self,self.OnLvRewardInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_GetLvlRewardResult,self,self.OnGetLvlRewardRefreshResult);
	
	MsgManager:RegisterCallBack(MsgType.SC_OutLineTime,self,self.ReqGetOutLineTimeMsg);
	MsgManager:RegisterCallBack(MsgType.SC_GetOutLineReward,self,self.OnGetOutLineAwardResult);
	
	--激活码
	MsgManager:RegisterCallBack(MsgType.WC_ActivationCode,self,self.OnGetActivationCodeResult);
	MsgManager:RegisterCallBack(MsgType.WC_InvitationCode,self,self.OnInvitationCodeResult);
end
--请求签到
function RegisterAwardController:OnSendSignHandler(obj)
	local msg = ReqSignMsg:new();
	msg.day = obj.day;
	msg.state = obj.state;
	MsgManager:Send(msg);
end
--请求领取奖励
function RegisterAwardController:OnSendSignVipRewardHandler(awardType)
	local msg = ReqSignRewardMsg:new();
	msg.day = awardType.day;
	msg.type = awardType.type;
	MsgManager:Send(msg);
end

-------------------------------------在线奖励----------------------------------------

--返回抽奖的索引
function RegisterAwardController:OnBackRewardIndex(msg)
	RegisterAwardModel:GetLineRewardIndex(msg);
	Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 2} );
end

--返回抽奖次数及累积在线时间
function RegisterAwardController:OnBackRewardInfo(msg)
	-- trace(msg)
	RegisterAwardModel:OnBackLineInfo(msg);
	Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 2} );
end

-------------------------------------在线奖励----------------------------------------

--请求抽奖
function RegisterAwardController:OnSendRandomReward(index)
	-- print('------------------RegisterAwardController:OnSendRandomReward(index)')
	local msg = ReqRandomRewardMsg:new();
	msg.index = index;
	MsgManager:Send(msg);
end

--请求抽奖次数
function RegisterAwardController:OnSendRandomRewardNum()
	local msg = ReqRandomRewardNumMsg:new();
	MsgManager:Send(msg);
end

--请求领取奖励
function RegisterAwardController:OnSendGetReward(index)
	print('------------------RegisterAwardController:OnSendGetReward(index)')
	print("领取索引为",index,"的奖励")
	local msg = ReqGetRandomRewardMsg:new();
	msg.index = index;
	MsgManager:Send(msg);
end

----------------------服务器返回-------------------------
--每日签到list
function RegisterAwardController:OnSubmitSighResult(msg)
	local num = msg.day;
	RegisterAwardModel:OnUpDataMySignReward(msg);
	Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 1} );
end
--3、5、7日奖励list
function RegisterAwardController:OnSubmitVipResult(msg)
	local list = msg.list;
	RegisterAwardModel:OnUpDataMySignVipReward(list);
	Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 1} );
end

--签到奖励领取返回
function RegisterAwardController:OnBackSignesult(msg)
	RegisterAwardModel:OnSignRewardUpData(msg.flag);
	Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 1} );
end

--返回结果
function RegisterAwardController:OnBackSigneResult(msg)
	if msg.result == 1 then
		print('重复签到')
	elseif msg.result == 2 then
		print('VIP等级不足')
	elseif msg.result == 3 then
		print('补签次数不足')
	elseif msg.result == 4 then
		print('提前签次数不足')
	end
end

-----------------------------------------------------等级奖励--------------------------------------------
---------------------------以下为客户端发送消息----------
-- 请求获取等级奖励
function RegisterAwardController:ReqGetLvlAward(lvl)
	local msg = ReqGetLvlRewardMsg:new()
	msg.lvl = lvl;
	MsgManager:Send(msg)
end

---------------------------以下为处理服务器返回消息------
-- 返回等级奖励信息
function RegisterAwardController:OnLvRewardInfoResult(msg)
	local list = {};
	for i,vo in pairs(msg.lvrewardList) do
		if vo then
			table.push(list,vo);
		end
	end
	
	--设置等级奖励信息
	RegisterAwardModel:SetLevelAwardList(list);
	
	--是否有未领取的等级奖励
	if RegisterAwardUtil:GetIsHaveLevelReward() == true then
		RemindController:AddRemind(RemindConsts.Type_LevelReward,1);
	end
end
-- 领取等级奖励结果
function RegisterAwardController:OnGetLvlRewardRefreshResult(msg)
	if msg.result == 0 then
		RegisterAwardModel:AddGetedAwardlvl(msg.lvl);
		SoundManager:PlaySfx(2041);
	end
end

-----------------------------------------------------离线收益--------------------------------------------
---------------------------以下为客户端发送消息----------
-- 请求获取离线收益
function RegisterAwardController:ReqGetOutLineAward(type)
	local msg = ReqGetOutLineRewardMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
end

---------------------------以下为处理服务器返回消息------
-- 返回离线时间
function RegisterAwardController:ReqGetOutLineTimeMsg(msg)
	--设置离线时间
	RegisterAwardModel:SetOutLineTime(msg.time, 0);
end
-- 返回离线奖励结果
function RegisterAwardController:OnGetOutLineAwardResult(msg)
	if msg.result == 0 then
		RegisterAwardModel:SetOutLineTime(0, msg.type);
	end
end

-----------------------------------------------------激活码--------------------------------------------
---------------------------以下为客户端发送消息----------
-- 请求激活激活码
function RegisterAwardController:ReqActivatyCode(code)
	if not code then return; end
	if string.find(code,"_") then
		--兄弟召回激活码
		local msg = ReqInvitationCodeMsg:new();
		msg.code = code;
		MsgManager:Send(msg);
	else
		local msg = ReqActivationCodeMsg:new()
		msg.code = code;
		MsgManager:Send(msg);
	end
end

---------------------------以下为处理服务器返回消息------
-- 返回激活激活码结果
function RegisterAwardController:OnGetActivationCodeResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.GetCodeReward, {id=msg.id});
		FloatManager:AddNormal( StrConfig['registerReward2000'] );
	elseif msg.result == 1 then
		FloatManager:AddNormal( StrConfig['registerReward2001'] );
	elseif msg.result == 2 then
		FloatManager:AddNormal( StrConfig['registerReward2002'] );
	elseif msg.result == 3 then
		FloatManager:AddNormal( StrConfig['registerReward2003'] );
	elseif msg.result == 4 then
		FloatManager:AddNormal( StrConfig['registerReward2004'] );
	elseif msg.result == 5 then
		FloatManager:AddNormal( StrConfig['registerReward2005'] );
	elseif msg.result == 6 then
		FloatManager:AddNormal( StrConfig['registerReward2006'] );
	end
end

function RegisterAwardController:OnInvitationCodeResult(msg)
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.GetCodeReward, {id=msg.id});
		FloatManager:AddNormal( StrConfig['registerReward5001'] );
	elseif msg.result == 1 then
		FloatManager:AddNormal( StrConfig['registerReward5002'] );
	elseif msg.result == 2 then
		FloatManager:AddNormal( StrConfig['registerReward5003'] );
	elseif msg.result == 3 then
		FloatManager:AddNormal( StrConfig['registerReward5004'] );
	elseif msg.result == 4 then
		FloatManager:AddNormal( StrConfig['registerReward5005'] );
	elseif msg.result == 5 then
		FloatManager:AddNormal( StrConfig['registerReward5006'] );
	end
end