--[[
	2016年1月8日15:20:30
	wangyanwei
	挑战副本结局面板
]]

_G.UIDekaronDungeonResult = BaseUI:new('UIDekaronDungeonResult');

function UIDekaronDungeonResult:Create()
	self:AddSWF('dekaronDungeonResultPanel.swf',true,'center');
end

function UIDekaronDungeonResult:OnLoaded(objSwf)
	
	objSwf.icon_lose.txt_lose.text = StrConfig['dekaronDungeon7001'];
	objSwf.icon_lose.txt_cap.text = StrConfig['dekaronDungeon7002'];
	objSwf.icon_end.txt_win.text = StrConfig['dekaronDungeon7003'];
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_enter.click = function () self:OnEnerClick(); end
end

function UIDekaronDungeonResult:OnEnerClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if self.dungeonLayer >= DekaronDungeonUtil:GetMaxDungeonLayer() and self.dungeonResult == 0 then
		DekaronDungeonController:SendQuitDekaronDungeon();
		return
	end
	
	if TeamModel:IsInTeam() and not TeamUtils:MainPlayerIsCaptain() then
		self:Hide();
		return
	end
	
	if not self.dungeonResult or not self.dungeonLayer then
		return
	end
	
	if self.dungeonResult == 0 and self.dungeonLayer >= DekaronDungeonUtil:GetMaxDungeonLayer() then
		DekaronDungeonController:SendQuitDekaronDungeon();
		return
	end
	
	if self.dungeonResult == 0 and self.dungeonLayer < DekaronDungeonUtil:GetMaxDungeonLayer() then
		--//寻路到传送点！！！
		print('寻路到传送点！！！')
		self:GoPoint();
		return
	end
	
	if self.dungeonLayer == 0 then
		DekaronDungeonController:SendEnterDekaronDungeon();
		return
	end
	
	if self.dungeonResult ~= 0 then
		--//请求进入上一层
		DekaronDungeonController:SendEnterDekaronDungeon();
		return
	end
end

--寻路到传送
function UIDekaronDungeonResult:GoPoint()
	if not self.dungeonLayer then return end
	if not self.dungeonResult then return end
	local cfg = t_tiaozhanfuben[self.dungeonLayer];
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

function UIDekaronDungeonResult:OnShow()
	self:ShowResultData();
	self:OnTimeHandler();
end

function UIDekaronDungeonResult:OnTimeHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	
	if not self.dungeonLayer then return end
	if not self.dungeonResult then return end
	
	local timeNum = 60;
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		timeNum = timeNum - 1;
		if timeNum == 0 then
			if self.dungeonResult ~= 0 then		--如果结局是失败  请求进入下一层  如果是0层 请求退出
				if self.dungeonLayer == 0 then
					DekaronDungeonController:SendQuitDekaronDungeon();
					return
				end
					DekaronDungeonController:SendEnterDekaronDungeon();
				return
			end
			if self.dungeonLayer >= DekaronDungeonUtil:GetMaxDungeonLayer() then -- 如果成功 又是最高层 发送退出  or  寻路到传送点！！！
				DekaronDungeonController:SendQuitDekaronDungeon();
			else
				self:GoPoint();
			end
		end
		if timeNum <= 0 then
			timeNum = 0;
		end
		objSwf.txt_time.htmlText = string.format(self.dungeonResult == 0 and StrConfig['dekaronDungeon2005'] or StrConfig['dekaronDungeon2004'],timeNum);
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIDekaronDungeonResult:ShowResultData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_tiaozhanfuben[self.dungeonLayer];
	if not cfg then return end
	if not self.dungeonResult then return end
	objSwf.icon_lose._visible = false;
	objSwf.icon_win._visible = false;
	objSwf.icon_end._visible = false;
	objSwf.txt_info._visible = false;
	if self.dungeonResult == 0 then
		objSwf.txt_info._visible = true;
		objSwf.btn_enter.label = self.dungeonLayer >= DekaronDungeonUtil:GetMaxDungeonLayer() and UIStrConfig['dekaronDungeon6'] or UIStrConfig['dekaronDungeon5'];
		if self.dungeonLayer >= DekaronDungeonUtil:GetMaxDungeonLayer() then 
			objSwf.icon_end._visible = true; 
			objSwf.txt_info.text = StrConfig['dekaronDungeon2003'];
		else 
			objSwf.icon_win._visible = true;
			objSwf.txt_info.htmlText = string.format(StrConfig['dekaronDungeon2002'],self.dungeonLayer);
		end
		self:ShowReward();
	else
		objSwf.btn_enter.label = UIStrConfig['dekaronDungeon4'];
		objSwf.icon_lose._visible = true;
		objSwf.txt_info.htmlText = string.format(StrConfig['dekaronDungeon2001'],self.dungeonLayer);
		objSwf.txt_info._visible = false;
	end
	if self.dungeonLayer == 0 then
		objSwf.txt_info._visible = false;
	end
end

function UIDekaronDungeonResult:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_tiaozhanfuben[self.dungeonLayer];
	if not cfg then return end
	local randomList = RewardManager:Parse( cfg.reward );
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end

function UIDekaronDungeonResult:OnHide()
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

UIDekaronDungeonResult.dungeonResult = nil;
UIDekaronDungeonResult.dungeonLayer = nil;
function UIDekaronDungeonResult:Open(result,layer)
	if not result or not layer then return end
	self.dungeonLayer = layer;
	self.dungeonResult = result;
	self:Show();
end

function UIDekaronDungeonResult:GetWidth()
	return 938
end

function UIDekaronDungeonResult:GetHeight()
	return 473
end