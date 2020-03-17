--[[
转职
jiayong
]]
_G.ZhuanZhiController=setmetatable({},{__index=IController});

local s_zhuanzhiDup = {11402005,}
ZhuanZhiController.zhuanzhiComInfoMsg = nil;
function ZhuanZhiController:Create()
    MsgManager:RegisterCallBack(MsgType.SC_ZhuanZhiInfo,self,self.Zhuanzhinfo);
    MsgManager:RegisterCallBack(MsgType.SC_ZhuanZhiUpdate,self,self.ZhuanZhiComInfo)
	MsgManager:RegisterCallBack(MsgType.SC_ZhuanShengResult,self,self.ZhuanZhiResult)
	MsgManager:RegisterCallBack(MsgType.SC_GetZhuanZhiRewardResult,self,self.GetRewardResult)
	MsgManager:RegisterCallBack(MsgType.SC_ZhuanZhiAutoFinishResult,self,self.AutoZhuanZhiResult)
	MsgManager:RegisterCallBack(MsgType.SC_EnterZhuanZhiDungeonResult,self,self.EnterZhuanZhiDup)
	MsgManager:RegisterCallBack(MsgType.SC_ZhuanShengStep,self,self.ZhuanZhiDupInfo)
	MsgManager:RegisterCallBack(MsgType.SC_QuitZhuanShengDungeon,self,self.OutDupResult)
end
function ZhuanZhiController:Zhuanzhinfo(msg)
	ZhuanZhiModel:SetLv(msg.level)
	ZhuanZhiModel:UpDateZhuanZhiInfo(msg.count)
end

function ZhuanZhiController:ZhuanZhiComInfo(msg)
	self.zhuanzhiComInfoMsg = msg;
	for k, v in pairs(msg.ZhuanZhiUpdatelist) do
		ZhuanZhiModel:UPDateZhuanZhiCom(v.tid, v.status, v.value)
	end
	--- 这里需要刷新界面
	Notifier:sendNotification(NotifyConsts.ZhuanZhiUpdate)
end

--服务器返回转生成功
function ZhuanZhiController:ZhuanZhiResult(msg)
	if msg.result == 0 then
		--转职成功
		ZhuanZhiModel:SetLv(msg.level)
		Notifier:sendNotification(NotifyConsts.ZhuanZhiSuccess)
		local mapid = MainPlayerController:GetMapId()
		for k, v in pairs(s_zhuanzhiDup) do
			if v == mapid then
				ZhuanZhiResultView:Show()
				return
			end
		end
	end
end

function ZhuanZhiController:GetRewardResult(msg)
	if msg.result == 0 then
		--领取成功
		ZhuanZhiModel:UpDateZhuanZhiInfo(msg.tid)
	end
	Notifier:sendNotification(NotifyConsts.ZhuanZhiUpdate)
end

function ZhuanZhiController:AutoZhuanZhiResult(msg)
	if msg.result == 0 then
		--一键转职成功
		Notifier:sendNotification(NotifyConsts.ZhuanZhiSuccess)
	end
end

function ZhuanZhiController:EnterZhuanZhiDup(msg)
	-- 进入转职副本了
	if msg.result == 0 then 
		MainMenuController:HideRightTop();
		ZhuanModel:SetZhuanActState(true)
	elseif msg.result == -2 then 
		FloatManager:AddNormal( StrConfig["zhuansheng016"] );
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig["zhuansheng017"] );
	elseif msg.result == -4 then 
		FloatManager:AddNormal( StrConfig["zhuansheng021"] );
	elseif msg.result == -5 then 
		FloatManager:AddNormal( StrConfig["zhuansheng018"] );
	elseif msg.result == -6 then 
		FloatManager:AddNormal( StrConfig["zhuansheng019"] );
	elseif msg.result == -7 then 
		FloatManager:AddNormal( StrConfig["zhuansheng020"] );
	else
		FloatManager:AddNormal( StrConfig["zhuansheng007"] );
	end;
end
ZhuanZhiController.timerKey = nil;
function ZhuanZhiController:OutDupResult(msg)
	-- 退出副本了
	MainMenuController:UnhideRightTop();
	ZhuanModel:SetZhuanActState(false)	
	if UIZhuanWindow:IsShow() then 
		UIZhuanWindow:Hide();
	end;
	
	if ZhuanZhiModel:GetLv()==1 then
		self.timerKey = TimerManager:RegisterTimer(function()
			QuestScriptManager:DoScript("wingfuncguide")
		if self.timerKey then
			TimerManager:UnRegisterTimer(self.timerKey)
			self.timerKey = nil;
		end
		end,7000,1);
	end
end


function ZhuanZhiController:AskGetReward(id)
	local msg = ReqGetZhuanZhiRewardMsg:new();
	--转职ID
	msg.tid = id
	MsgManager:Send(msg);
end

function ZhuanZhiController:AutoZhuanZhi()
	local msg = ReqZhuanZhiAutoFinishMsg:new()
	msg.level = ZhuanZhiModel:GetLv() and ZhuanZhiModel:GetLv() + 1 or 1
	MsgManager:Send(msg)
end

function ZhuanZhiController:AskToDup(id)
	local msg = ReqEnterZhuanZhiDungeonMsg:new()
	--转职ID
	for k, v in pairs(t_transfer) do
		if v.number == id then
			msg.tid = k
			break
		end
	end
	MsgManager:Send(msg)
end

function ZhuanZhiController:AskOutDup()
	local msg = ReqQuitZhuanShengDungeon:new()
	MsgManager:Send(msg)
	ZhuanZhiResultView:Hide()
end

function ZhuanZhiController:ZhuanZhiDupInfo(msg)
	MainMenuController:HideRightTop();
	ZhuanModel:SetZhuanActState(true)
	ZhuanModel:SetZhuanInfo(msg.monsterList,msg.copyId)
	ZhuanModel:SetZhuanActState(true)

	if t_dunstep[msg.copyId] then 
		local cfgd = t_dunstep[msg.copyId];
		if cfgd.dunEffect and cfgd.dunEffect ~= "" then 
			local effectCfg = GetCommaTable(cfgd.dunEffect)
			ZhuanContoller:PlayStoryEffect(effectCfg)
		end;
	end;

	if not UIZhuanWindow:IsShow() then 
		UIZhuanWindow:Show()
	else
		UIZhuanWindow:UpdataStep();
	end;
	if UIZhuanSheng:IsShow() then 
		UIZhuanSheng:Hide();
	end;
	if UIZhuanWindow.isAutoing then 
		if msg.copyId == 103002 then 
			--如果id为对话1就不执行自动逻辑，等待mv播放完执行
			return 
		end;
		UIZhuanWindow:GoStepClick()
	end;
end