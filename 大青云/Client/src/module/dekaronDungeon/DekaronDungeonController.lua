--[[
	2016年1月8日11:37:23
	挑战副本
	wangyanwei
]]

_G.DekaronDungeonController = setmetatable( {}, {__index = IController} )
DekaronDungeonController.name = "DekaronDungeonController";

function DekaronDungeonController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackDekaronDungeonDate,self,self.OnBackDekaronDungeonDate);				--返回挑战副本date
	MsgManager:RegisterCallBack(MsgType.SC_BackDekaronDungeonEnter,self,self.OnBackDekaronDungeonEnter);			--返回挑战副本进入结果
	MsgManager:RegisterCallBack(MsgType.SC_BackDekaronDungeonQuit,self,self.OnBackDekaronDungeonQuit);				--返回挑战副本退出结果
	MsgManager:RegisterCallBack(MsgType.SC_BackDekaronDungeonResult,self,self.OnBackDekaronDungeonResult);			--返回挑战副本通关结果
	
	MsgManager:RegisterCallBack(MsgType.SC_BackDekaronDungeonInfo,self,self.OnBackDekaronDungeonInfo);				--返回挑战副本挑战过程
	
	
end

function DekaronDungeonController:OnBackDekaronDungeonDate(msg)
	-- trace(msg)
	local dungeonData = {};
	dungeonData.enterNum 		= msg.enterNum;				--进入进入次数
	dungeonData.nowBestLayer 	= msg.nowBestLayer;			--今日挑战的最好成绩
	dungeonData.bestLayer 		= msg.bestLayer;			--自己历史最好成绩
	dungeonData.bestTeamLayer 	= msg.bestTeamLayer;		--全服历史最好成绩
	dungeonData.bestTeamList 	= msg.bestTeamList;			--最强通关队伍列表
	dungeonData.rankList 		= msg.rankList;				--排行榜列表
	
	DekaronDungeonModel:DekaronDungeonUpDate(dungeonData);
	
	--//派发
	Notifier:sendNotification(NotifyConsts.DekaronDungeonUpDate);
end

--返回挑战副本进入结果
DekaronDungeonController.dekarondungeonInState = false;
function DekaronDungeonController:OnBackDekaronDungeonEnter(msg)
	local result = msg.result ;		--进入结果 0成功
	local layer  = msg.layer ;		--进入层
	local state  = msg.state ;		--盖层挑战状态 0未挑战 1已挑战
	-- trace(msg)
	if result == 0 then
		UIDungeonNpcChat:Hide();
		UIQiZhanDungeonTip:Hide();
		self.dekarondungeonInState = true;
		MainMenuController:HideRight();
		MainMenuController:HideRightTop();			--//隐藏功能界面及任务界面
		UIDekaronDungeon:Hide();						--//关闭主UI
		
		UIDekaronDungeonInfo:Open(layer,state);			--//打开信息界面
		UIDekaronDungeonResult:Hide();			--//关闭结局界面
		
		QiZhanDungeonDieTip:Hide();				--//关闭死亡提示
		if state == 1 then
			UIQiZhanDungeonTip:Open(1);
		elseif state == 0 then
			local cfg = t_tiaozhanfuben[layer];
			if cfg.duntalk and cfg.duntalk ~= 0 then
				UIDungeonNpcChat:Open(cfg.duntalk);
			end
		end
		return
	end
	if result == 1 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6001'] );
	elseif result == 2 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6002'] );
	elseif result == 3 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6003'] );
	elseif result == 4 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6004'] );
	elseif result == 5 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6005'] );
	elseif result == 6 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6006'] );
	elseif result == 7 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6007'] );
	elseif result == 8 then
		FloatManager:AddNormal( StrConfig['dekaronDungeon6008'] );
	end
end

--返回退出挑战副本
function DekaronDungeonController:OnBackDekaronDungeonQuit(msg)
	local result = msg.result ;		--退出结果 0成功
	
	if result == 0 then
		UIDungeonNpcChat:Hide();
		UIQiZhanDungeonTip:Hide();
		self.dekarondungeonInState = false;
		MainMenuController:UnhideRight();
		MainMenuController:UnhideRightTop();
		
		UIDekaronDungeonResult:Hide();			--//关闭结局界面
		UIDekaronDungeonInfo:Hide();
		
		QiZhanDungeonDieTip:Hide();				--//关闭死亡提示
	end
end

--返回挑战副本通关结果
function DekaronDungeonController:OnBackDekaronDungeonResult(msg)
	local layer  = msg.layer;		--通关层数
	local result  = msg.result;		--通关结果
	UIQiZhanDungeonTip:Hide();
	UIDungeonNpcChat:Hide();
	if layer >= DekaronDungeonUtil:GetMaxDungeonLayer() then
		UIDekaronDungeonInfo:Hide();				--//追踪关闭
	else
		UIDekaronDungeonInfo:ResultOpen(result);		--//追踪修改
	end
	
	UIDekaronDungeonResult:Open(result,layer);	--//打开结局
	
	QiZhanDungeonDieTip:Hide();				--//关闭死亡提示
end

--返回挑战副本挑战过程
function DekaronDungeonController:OnBackDekaronDungeonInfo(msg)
	local killList = msg.killList;	--//击杀列表
	DekaronDungeonModel:SetDungeonLayerMonster(killList);
	
	Notifier:sendNotification(NotifyConsts.DekaronDungeonInfoUpDate);
end

function DekaronDungeonController:GetInDekaronDungeonState()
	return self.dekarondungeonInState
end

--////////////////////////C TO S\\\\\\\\\\\\\\\\\\\\\\--
--请求挑战副本data
function DekaronDungeonController:SendDekaronDungeonData()
	local msg = ReqDekaronDungeonDateMsg:new();
	
	MsgManager:Send(msg);
end

--请求进入挑战副本
function DekaronDungeonController:SendEnterDekaronDungeon()
	local msg = ReqDekaronDungeonEnterMsg:new();
	
	MsgManager:Send(msg);
end

--请求退出挑战副本
function DekaronDungeonController:SendQuitDekaronDungeon()
	local msg = ReqDekaronDungeonQuitMsg:new();
	
	MsgManager:Send(msg);
end