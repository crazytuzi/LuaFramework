--[[
 	时间：   2016年10月19日 21:40:36
	开发者:  houxudong
	功能:    牧野之战控制器
]]
_G.MakinoBattleController = setmetatable( {}, {__index = IController} )
MakinoBattleController.name = "MakinoBattleController";

MakinoBattleController.currentLayer = 0;        --当前的层数
MakinoBattleController.inDungeonState= false;   --是否在牧野副本中

function MakinoBattleController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackMuYeWarInfo,self,self.OnBackMakinoDungeonDate);	--服务器返回请求牧业战信息
	MsgManager:RegisterCallBack(MsgType.SC_BackMuYeWarEnter,self,self.OnBackMakniobattleResult);--返回牧野之战副本进入结果
	MsgManager:RegisterCallBack(MsgType.SC_GetMuYeReward,self,self.OnBackGetRewardResult);      --获取牧野首通奖励返回结果
	MsgManager:RegisterCallBack(MsgType.SC_MuYeRewardUpdate,self,self.OnBackWaveAndReward);     --返回每波奖励和波数结果
	MsgManager:RegisterCallBack(MsgType.SC_MuYeHPUpdate,self,self.OnBackRespMuYeHPUpdateMsg);   --返回牧野战城门血量更新
	MsgManager:RegisterCallBack(MsgType.SC_BackMuYeWarQuit,self,self.OnBackMaknioResult);       --返回退出牧野战
	MsgManager:RegisterCallBack(MsgType.SC_MuYeScoreUpdate,self,self.OnPointRecordUpdate);      --技能总积分更新
	MsgManager:RegisterCallBack(MsgType.SC_BackMuYeWarResult,self,self.OnBackMuYeWarResult);    --返回牧业战通关结果
	MsgManager:RegisterCallBack(MsgType.SC_MuYeSecUpdate,self,self.OnBackSecUpdateResult);      --返回下波刷新剩余秒数
end
-------------------------------S TO C-------------------------------
-- 返回请求牧业战信息界面信息
function MakinoBattleController:OnBackMakinoDungeonDate(msg)
	local dungeonData = {};
	dungeonData.enterNum 		= msg.enterNum;				--进入进入次数
	dungeonData.nowBestLayer 	= msg.nowBestLayer;			--今日挑战的最好成绩
	dungeonData.bestLayer 		= msg.bestLayer;			--自己历史最好成绩
	dungeonData.bestTeamLayer 	= msg.bestTeamLayer;		--全服历史最好成绩
	dungeonData.bestTeamList 	= msg.bestTeamList;			--最强通关队伍列表
	dungeonData.rankList 		= msg.rankList;				--排行榜列表
	dungeonData.rewardList 		= msg.rewardList;		    --奖励领取列表

	MakinoBattleDungeonModel:UpDateMakinoBattleDungeonData(dungeonData);
	Notifier:sendNotification(NotifyConsts.MakinoBattleDungeonUpDate);
end

-- 返回牧野之战副本进入结果
function MakinoBattleController:OnBackMakniobattleResult( msg )
	local result = msg.result ;		--进入结果 0成功
	if result == 1 then
		FloatManager:AddNormal( StrConfig['makinoBattle6001'] );
	elseif result == 2 then
		FloatManager:AddNormal( StrConfig['makinoBattle6002'] );
	elseif result == 3 then
		FloatManager:AddNormal( StrConfig['makinoBattle6003'] );
	elseif result == 4 then
		FloatManager:AddNormal( StrConfig['makinoBattle6004'] );
	elseif result == 5 then
		FloatManager:AddNormal( StrConfig['makinoBattle6005'] );
	elseif result == 6 then
		FloatManager:AddNormal( StrConfig['makinoBattle6006'] );
	elseif result == 7 then
		FloatManager:AddNormal( StrConfig['makinoBattle6007'] );
	elseif result == 8 then
		FloatManager:AddNormal( StrConfig['makinoBattle6008'] );
	end
	if result == 0 then
		self.inDungeonState = true
		MakinoBattleDungeonModel:SetInitNpcHp(msg)
		UIDungeonMain:Hide()
		MainMenuController:HideRight()
		MainMenuController:HideRightTop()
		UIMakinoBattleDungeon:Hide()
		UIMakinobattleInfo:Show()
		UIMakinobattleSkillView:Show();  --临时屏蔽特殊技能
		-- AutoBattleController:OpenAutoBattle()  --自动挂机
		self:OnAutoFunc()  --自动挂机(跑到一个指定位置开始挂机)
		MakinoBattleDungeonModel:SetCurWave()  --清空波数
		MakinoBattleDungeonModel:ClearEveryWaveReward( )  --清空累计奖励
		MakinoBattleDungeonModel:ClearCurAllPointScore()  --清空积分数据
		self:Updatemonster()
	end

end

-- 跑到一个指定位置开始挂机
function MakinoBattleController:OnAutoFunc()
	local myPos = "-6,159"
	if not myPos then return end
	local mapid = CPlayerMap:GetCurMapID();
	local point = split(myPos,",");
	local completeFuc = function()
		AutoBattleController:SetAutoHang();
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(point[1],point[2],0),completeFuc);
end

-- 刷新怪物(5秒)
function MakinoBattleController:Updatemonster( )
	local dealyNum = 5
	local types = 4
	local paramOne = function( )
		UIMakinobattleInfo:StartTimer(30)
	end
	local paramTwo = function( )
		UIMakinobattleInfo:StopTimer(30)
	end
	PublicUtil:OnMonsterComeTime(dealyNum,types,paramOne,paramTwo)
end

-- 获取牧业首通奖励返回结果
function MakinoBattleController:OnBackGetRewardResult(msg)
	if msg.result == 0 then
		MakinoBattleDungeonModel:ChangeRewardState( msg )
		Notifier:sendNotification(NotifyConsts.MakinoBattleRewardStateChange);
	elseif msg.result == -1 then
		print("Get Reward failed ......")
	end
end

-- 返回信息界面波数和奖励
function MakinoBattleController:OnBackWaveAndReward(msg)
	MakinoBattleDungeonModel:BackWaveAndRewardData(msg)
	UIMakinobattleInfo:UpdateWaveAndReward( )
end

-- 返回牧业战城门血量更新
function MakinoBattleController:OnBackRespMuYeHPUpdateMsg(msg)
	local curHp = msg.currentHP
	UIMakinobattleInfo:UpdateGiValue( curHp )
end

-- 返回退出牧野战
function MakinoBattleController:OnBackMaknioResult( msg )
	local result = msg.result;
	if result == 0 then
		self.inDungeonState = false
		MainMenuController:UnhideRight();
		MainMenuController:UnhideRightTop();
		UIMakinoBatleDungeonResultView:Hide();			
		UIMakinobattleInfo:Hide();
		UIMakinobattleSkillView:Hide();  --临时屏蔽特殊技能
		if UIConfirm:IsShow() then
			UIConfirm:Hide();
		end
		if UIFloat:IsShow() then
			UIFloat:ClearAllDungeonText( )
		end
	else
		FloatManager:AddNormal( StrConfig['makinoBattle6009'] );
	end
end

-- 技能总积分更新
function MakinoBattleController:OnPointRecordUpdate(msg)
	MakinoBattleDungeonModel:SetCurAllPointScore(msg)
	UIMakinobattleSkillView:UpdateSkillInfo(msg.score)  --临时屏蔽特殊技能
end

-- 返回牧业战通关结果
function MakinoBattleController:OnBackMuYeWarResult( msg )
	UIMakinoBatleDungeonResultView:Show()
	UIMakinobattleSkillView:Hide();  --临时屏蔽特殊技能
	UIMakinobattleInfo:Hide();
end

-- 下波刷新剩余秒数
function MakinoBattleController:OnBackSecUpdateResult( msg )
	local second = msg.sec
	-- 跑马灯走起
	-- FloatManager:AddAnnounceForMakinoBattle(StrConfig['makinoBattle99999'])
	
	-- 开启下拨怪物刷新倒计时
	-- @paramTwo 取消信息面板倒计时
	-- @paramOne 开始信息面板倒计时
	local paramTwo = function( )
		UIMakinobattleInfo:StartTimer(second)
	end
	PublicUtil:OnMonsterComeTime(second,3,nil,paramTwo)
end

-------------------------------C TO S-------------------------------
-- 刚进入游戏时请求副本数据
function MakinoBattleController:OnEnterGame()
	local msg = ReqMuYeWarInfoMsg:new();
	MsgManager:Send(msg);
end

--请求牧野之战副本数据
function MakinoBattleController:ReqMakinoBattleDungeonData()
	local msg = ReqMuYeWarInfoMsg:new();
	MsgManager:Send(msg);
end

--客户端请求：退出牧野之战
function MakinoBattleController:ReqQuitMakinoBattleDungeon()
	local msg = ReqMuYeWarQuitMsg:new();
	MsgManager:Send(msg);
end

--客户端请求：领取首通奖励
function MakinoBattleController:ReqGetFirstReward(num)
	local msg = ReqGetMuYeRewardMsg:new()   
	msg.index = num
	MsgManager:Send(msg);
end