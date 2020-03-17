--[[
	2015年10月31日16:29:29
	wangyanwei

	-- 野外BOSS暂时放这里

]]

_G.PersonalBossController = setmetatable({},{__index=IController})

PersonalBossController.name = 'PersonalBossController';

function PersonalBossController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_PersonalBossList,self,self.OnPersonalBossList);  							--服务器返回BOSS挑战列表
	MsgManager:RegisterCallBack(MsgType.SC_BackEnterResultPersonalBoss,self,self.OnBackEnterResultPersonalBoss);  		--服务器返回进入个人BOSS结果
	MsgManager:RegisterCallBack(MsgType.SC_BackQuitPersonalBoss,self,self.OnBackQuitPersonalBoss);  					--服务器:退出个人BOSS结果
	MsgManager:RegisterCallBack(MsgType.SC_PersonalBossResult,self,self.OnPersonalBossResult);  						--服务器:挑战个人BOSS结果
	MsgManager:RegisterCallBack(MsgType.WC_FieldBoss,self,self.OnFieldBossList);  	
    MsgManager:RegisterCallBack(MsgType.WC_MiJingBoss,self,self.OnMiJingBossList);
	 									--服务器返回野外BOSS挑战列表
end

--服务器返回BOSS挑战列表
function PersonalBossController:OnPersonalBossList(msg)
	local list = msg.PersonalBossItem;
	local itemEnterNum = msg.itemEnterNum;		--道具进入次数
	
	PersonalBossModel:SetItemEnterNum(itemEnterNum);		--剩余道具进入次数
	PersonalBossModel:PersonalBossUpDate(list);
end

function PersonalBossController:OnFieldBossList(msg)
	local list = msg.list
	if not list then
		print("BOSS 列表被鬼吃了")
		return
	end
	PersonalBossModel:FieldBossUpDate(list);
	Notifier:sendNotification(NotifyConsts.FieldBossUpdate)
end

--服务器返回进入个人BOSS结果
function PersonalBossController:OnBackEnterResultPersonalBoss(msg)
	local result = msg.result;
	local id = msg.id;
	local _type = msg.type;			--0是消耗道具进入
	local enterNum = msg.enterNum;
	local itemEnterNum = msg.itemEnterNum;
	-- trace(msg)
	print('进入个人BOSS结果!!!!!!!!!!!!!!!!')
	if result == 0 then
		if UILoadingScene:IsShow () then
			UILoadingScene:Hide();
		end
		MainMenuController:HideRight();
		MainMenuController:HideRightTop();
		UIBossBasic:Hide();								--关闭主界面
		UIPersonalBossInfo:Open(id);						--打开追踪面板
		PersonalBossModel:SetBossID(id);
		PersonalBossModel:SetItemEnterNum(itemEnterNum);		--剩余道具进入次数
		PersonalBossModel:removePersonalBossNum(id,enterNum);	--剩余进入次数
		
		AutoBattleController:CloseAutoHang();			--关闭挂机状态
		self:ChangeSceneMap();							--再次打开挂机按钮
		
		if PersonalBossModel:GetAutoNum() > 0 then
			UIPersonalBossAutoBtn:Show();
		elseif PersonalBossModel:GetAutoFlag() then
			UIPersonalBossAutoBtn:Show()
		else
			UIPersonalBossAutoBtn:Hide();
		end
		UIPersonalResult:Hide();
	elseif result == -1 then
		FloatManager:AddNormal( StrConfig['personalboss101'] );
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['personalboss102'] );
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['personalboss103'] );
	elseif result == -4 then
		FloatManager:AddNormal( StrConfig['personalboss104'] );
	elseif result == -5 then
		FloatManager:AddNormal( StrConfig['personalboss108'] );
	end
end

--服务器:退出个人BOSS结果
function PersonalBossController:OnBackQuitPersonalBoss(msg)
	local result = msg.result;
	
	if result == 0 then
		PersonalBossModel:EndTimeNum();						--关闭计时
		UIPersonalBossInfo:Hide();							--关闭追踪面板
		MainMenuController:UnhideRight();
		MainMenuController:UnhideRightTop();
		UIPersonalResult:Hide();
		UIPersonalBossAutoBtn:Hide();
		if UIAutoBattleTip:IsShow() then
			UIAutoBattleTip:Hide();
		end
		PersonalBossModel:SetAutoNum(nil);					--清除自动副本次数
		PersonalBossModel:SetAutoFlag(false)
	elseif result == -1 then
		FloatManager:AddNormal( StrConfig['personalboss106'] );
	end
end

--服务器:挑战个人BOSS结果
function PersonalBossController:OnPersonalBossResult(msg)
	local result = msg.result;				--挑战结果 0成功
	local isfirst = msg.isfirst;			--是否首通 0是
	print('-------------通关结果')
	-- trace(msg)
	PersonalBossModel:EndTimeNum();						--关闭计时
	UIPersonalBossInfo:Hide();							--关闭追踪面板
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function()
		local cfg = t_personalboss[self.personalbossID]
		if result == 0 then
			if not cfg then return end
			PersonalBossModel:SetFirstState(cfg.id);
		end
		if PersonalBossModel:GetAutoNum() > 0 then
			if UILoadingScene:IsShow() then return end
			if self.loadingTimeKey then
				TimerManager:UnRegisterTimer(self.loadingTimeKey);
				self.loadingTimeKey = nil;
			end
			local enterItemCfg = split(cfg.itemNumber,',')
			local itemCfg = t_item[toint(enterItemCfg[1])];
			local BgItemNum = BagModel:GetItemNumInBag(itemCfg.id);

			-- self.autoNum
			local enterItemNum = PersonalBossModel:GetItemEnterNum();
			local personalBossVO = PersonalBossModel:GetIDPersonalBossDate(cfg.id)
			local enterNum = enterItemNum + personalBossVO.num;
			if enterNum < 1 then
				FloatManager:AddNormal(StrConfig['personalboss102'])
				PersonalBossModel:SetAutoNum(nil)
				UIPersonalResult:Open(result,isfirst)
				return
			end
			if BgItemNum + personalBossVO.num < 1 then
				FloatManager:AddNormal(StrConfig['personalboss107'])
				PersonalBossModel:SetAutoNum(nil)
				UIPersonalResult:Open(result,isfirst)
				return
			end
			UILoadingScene:Open();
			local loadingFunc = function ()
				PersonalBossModel:RemoveAutoNum();
				PersonalBossController:SendLoadingEnd(self.personalbossID);--请求loading结束									-- PersonalBossController:SendEnter(self.personalbossID);
				TimerManager:UnRegisterTimer(self.loadingTimeKey);
				self.loadingTimeKey = nil;
			end
			self.loadingTimeKey = TimerManager:RegisterTimer(loadingFunc,2000,1);
		elseif PersonalBossModel:GetAutoFlag() then
			local level = MainPlayerModel.humanDetailInfo.eaLevel;
			local id  = 0
			for k, bossCfg in ipairs(t_personalboss) do
				local personalBossVO = PersonalBossModel:GetIDPersonalBossDate(bossCfg.id);
				if personalBossVO then
					if level >= bossCfg.playerLevel then
						if personalBossVO.num > 0 then
							id = bossCfg.id
							break
						end
					end
				end
			end
			if id == 0 then
				PersonalBossModel:SetAutoFlag(false)
				UIPersonalResult:Open(result,isfirst);
			elseif id ~= 0 then
				if UILoadingScene:IsShow() then return end
				UILoadingScene:Open();
				if self.loadingTimeKey then
					TimerManager:UnRegisterTimer(self.loadingTimeKey);
					self.loadingTimeKey = nil;
				end
				local loadingFunc = function ()
					PersonalBossController:SendLoadingEnd(id);--请求loading结束									-- PersonalBossController:SendEnter(self.personalbossID);
					TimerManager:UnRegisterTimer(self.loadingTimeKey);
					self.loadingTimeKey = nil;
				end
				self.loadingTimeKey = TimerManager:RegisterTimer(loadingFunc,2000,1);
			end
		else
			UIPersonalResult:Open(result,isfirst);				--打开结局面板
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,5000,1);
end

------------///////////////////////C to S\\\\\\\\\\\\\\\\\\\\\\-------------
--请求loading结束
function PersonalBossController:SendLoadingEnd(id)
	local msg = ReqPersonalBossLoadingMsg:new();
	msg.id = id
	MsgManager:Send(msg);
end

--请求进入
PersonalBossController.personalbossID = nil;
function PersonalBossController:SendEnter(id)
	if not self.personalbossID then self.personalbossID = id end
	local msg = ReqEnterPersonalBossMsg:new();
	msg.id = id;
	print('请求进入副本------',id)
	MsgManager:Send(msg);
end
function PersonalBossController:OnLevelUp(oldLevel,newLevel)
	
	local openLevel = t_funcOpen[72].open_level;	
	if MainPlayerModel.humanDetailInfo.eaLevel>=openLevel then
		UIMainFunc:ShowOtherBtn(MainPlayerModel.humanDetailInfo.eaLevel);
	end
end
--请求退出
function PersonalBossController:SendQuitPersonalBoss()
	PersonalBossModel:SetAutoFlag(false)
	PersonalBossModel:SetAutoNum(nil);				--清除自动副本次数
	self.personalbossID = nil;
	local msg = ReqQuitPersonalBossMsg:new();
	MsgManager:Send(msg);
	print('请求退出个人BOSS')
end

--进入地图
function PersonalBossController:ChangeSceneMap(msg)
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	local cfg = t_consts[136];
	if not cfg then return end
	if CPlayerMap:GetCurMapID() == cfg.val3 then
		PersonalBossModel:StartTime();
		UIAutoBattleTip:Open(function() PersonalBossController:OnAutoStart() end,true);
	end
end

function PersonalBossController:OnAutoStart()
	local _pos = 21001;
	local point = QuestUtil:GetQuestPos(_pos);
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

--请求野外BOSS信息
function PersonalBossController:AskGetFieldBossInfo()
	local msg = ReqFieldBossMsg:new();
	MsgManager:Send(msg);
end

--返回秘境boss
function PersonalBossController:OnMiJingBossList(msg)
    local list = msg.list
	if not list then
		return
	end
	PersonalBossModel:PalaceBossUpDate(list);
	Notifier:sendNotification(NotifyConsts.PalaceBossUpdate)
end

--请求秘境boss信息
function PersonalBossController:AskGetPalaceBossInfo()
	local msg = ReqMiJingBossMsg:new();
	MsgManager:Send(msg);
end
