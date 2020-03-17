--[[
	2015年11月14日14:50:54
	wangyanwei
	骑战副本结局面板
]]

_G.UIQiZhanDungeonResult = BaseUI:new('UIQiZhanDungeonResult');

function UIQiZhanDungeonResult:Create()
	self:AddSWF('qizhanDungeonResult.swf',true,'center');
end

function UIQiZhanDungeonResult:OnLoaded(objSwf)
	
	objSwf.icon_lose.txt_lose.text = StrConfig['qizhanDungeon7001'];
	-- objSwf.icon_lose.txt_cap.text = StrConfig['qizhanDungeon7002'];
	objSwf.icon_end.txt_win.text = StrConfig['qizhanDungeon7003'];
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_enter.click = function () self:OnEnerClick(); end
end

function UIQiZhanDungeonResult:OnEnerClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if self.dungeonLayer >= QiZhanDungeonUtil:GetMaxDungeonLayer() and self.dungeonResult == 0 then
		QiZhanDungeonController:SendQuitQiZhanDungeon();
		return
	end
	
	if not self.dungeonResult or not self.dungeonLayer then
		return
	end

	if self.dungeonResult ~= 0 then
		QiZhanDungeonController:SendQuitQiZhanDungeon();
		return
	end

	if TeamModel:IsInTeam() and not TeamUtils:MainPlayerIsCaptain() then
		self:Hide();
		return
	end
	
	if self.dungeonResult == 0 and self.dungeonLayer < QiZhanDungeonUtil:GetMaxDungeonLayer() then
		--寻路到传送点！！！
		-- print('寻路到传送点！！！')
		-- self:GoPoint();
		print("继续挑战.....")
		QiZhanDungeonController:SendQiZhanDungeonContinue()
		self:Hide();
		return
	end
	--[[
	if self.dungeonLayer == 0 then
		QiZhanDungeonController:SendEnterQiZhanDungeon();
		return
	end
	--]]
	
	--[[
	if self.dungeonResult ~= 0 then
		--//请求进入上一层
		-- QiZhanDungeonController:SendEnterQiZhanDungeon();
		-- 请求退出副本
		QiZhanDungeonController:SendQuitQiZhanDungeon();
		return
	end
	--]]
end

--寻路到传送
function UIQiZhanDungeonResult:GoPoint()
	if not self.dungeonLayer then return end
	if not self.dungeonResult then return end
	local cfg = t_ridedungeon[self.dungeonLayer];
	if not cfg then return end
	local map = t_map[cfg.map];
	if not map then return end
	
	local nowMap = t_map[CPlayerMap:GetCurMapID()];
	if not nowMap then return end
	
	if nowMap.id ~= map.id then
		return
	end
	local func = function() end
	MainPlayerController:DoAutoRun(cfg.map,_Vector3.new(cfg.door_point[1],cfg.door_point[2],0),func);
	self:Hide();
end

function UIQiZhanDungeonResult:OnShow()
	self:ShowResultData();
	self:OnTimeHandler();
end

function UIQiZhanDungeonResult:OnTimeHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	
	if not self.dungeonLayer then return end
	if not self.dungeonResult then return end
	
	local timeNum = 15;
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		timeNum = timeNum - 1;
		if timeNum == 0 then
			if self.dungeonResult ~= 0 then		--如果结局是失败  请求进入下一层  如果是0层 请求退出
				if self.dungeonLayer == 0 then
					QiZhanDungeonController:SendQuitQiZhanDungeon();
					return
				end
					QiZhanDungeonController:SendQuitQiZhanDungeon();  --直接退出
					-- QiZhanDungeonController:SendEnterQiZhanDungeon();
				return
			end
			if self.dungeonLayer >= QiZhanDungeonUtil:GetMaxDungeonLayer() then -- 如果成功 又是最高层 发送退出  or  寻路到传送点！！！
				QiZhanDungeonController:SendQuitQiZhanDungeon();
				return;
			else
				-- self:GoPoint();
				QiZhanDungeonController:SendQiZhanDungeonContinue()
				self:Hide();
				return;
			end
		end
		if timeNum <= 0 then
			timeNum = 0;
		end
		objSwf.txt_time.htmlText = string.format(self.dungeonResult == 0 and StrConfig['qizhanDungeon2005'] or StrConfig['qizhanDungeon2004'],timeNum);
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIQiZhanDungeonResult:ShowResultData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_ridedungeon[self.dungeonLayer];
	if not cfg then return end
	if not self.dungeonResult then return end
	objSwf.icon_lose._visible = false;
	objSwf.icon_win._visible = false;
	objSwf.icon_end._visible = false;
	objSwf.txt_info._visible = false;
	objSwf.bgGray._visible = false;
	objSwf.bgWin._visible = false;
	if self.dungeonResult == 0 then
		objSwf.txt_info._visible = true;
		objSwf.bgWin._visible = true;
		objSwf.btn_enter.label = self.dungeonLayer >= QiZhanDungeonUtil:GetMaxDungeonLayer() and UIStrConfig['qizhanDungeon6'] or UIStrConfig['qizhanDungeon5'];
		if self.dungeonLayer >= QiZhanDungeonUtil:GetMaxDungeonLayer() then 
			objSwf.icon_end._visible = true; 
			objSwf.txt_info.text = StrConfig['qizhanDungeon2003'];
		else 
			objSwf.icon_win._visible = true;
			objSwf.txt_info.htmlText = string.format(StrConfig['qizhanDungeon2002'],self.dungeonLayer);
		end
		self:ShowReward();
	else
		objSwf.btn_enter.label = UIStrConfig['qizhanDungeon3'];
		objSwf.icon_lose._visible = true;
		objSwf.bgGray._visible = true;
		objSwf.txt_info.htmlText = string.format(StrConfig['qizhanDungeon2001'],self.dungeonLayer);
		objSwf.txt_info._visible = false;
	end
	if self.dungeonLayer == 0 then
		objSwf.txt_info._visible = false;
	end
end

function UIQiZhanDungeonResult:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_ridedungeon[self.dungeonLayer];
	if not cfg then return end
	local randomList = RewardManager:Parse( cfg.reward );
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end

function UIQiZhanDungeonResult:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList:invalidateData();
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.txt_time.text = '';
end

UIQiZhanDungeonResult.dungeonResult = nil;
UIQiZhanDungeonResult.dungeonLayer = nil;
function UIQiZhanDungeonResult:Open(result,layer)
	if not result or not layer then return end
	self.dungeonLayer = layer;
	self.dungeonResult = result;
	self:Show();
end

function UIQiZhanDungeonResult:GetWidth()
	return 938
end

function UIQiZhanDungeonResult:GetHeight()
	return 473
end