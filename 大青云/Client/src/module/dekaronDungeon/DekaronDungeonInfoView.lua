--[[
	2016年1月8日15:00:46
	wangyanwei
	挑战副本
]]

_G.UIDekaronDungeonInfo = BaseUI:new('UIDekaronDungeonInfo');

function UIDekaronDungeonInfo:Create()
	self:AddSWF('dekaronDungeonInfoPanel.swf',true,'bottom');
end

function UIDekaronDungeonInfo:OnLoaded(objSwf)
	objSwf.panel_info.txt_1.text = StrConfig['dekaronDungeon210'];
	objSwf.panel_info.txt_2.text = StrConfig['dekaronDungeon211'];
	objSwf.btn_state.click = function () self:ShowInfoClick(); end
	
	objSwf.panel_info.btn_quit.click = function ()
		local func = function ()
			DekaronDungeonController:SendQuitDekaronDungeon();
		end
		self.uicUIConfirmID = UIConfirm:Open(StrConfig['dekaronDungeon220'],func);		
	end
	objSwf.panel_info.btn_goto.click = function () self:GoPoint(); end
	
	for i = 1 , 4 do
		objSwf.panel_info['txt_monster' .. i].click = function () self:OnMonsterClick(i); end
	end
	objSwf.panel_info.txt_monsterInfo.rollOver = function () self:ShowMonsterInfo(); end
	objSwf.panel_info.txt_monsterInfo.rollOut = function () TipsManager:Hide(); end
end

--点击怪物寻路
function UIDekaronDungeonInfo:OnMonsterClick(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if not self.enterLayer then return end
	local cfg = t_tiaozhanfuben[self.enterLayer];
	if not cfg then return end
	local pointCfg = split(cfg.position,'#');
	if not pointCfg[index] then return end
	local nowMap = t_map[CPlayerMap:GetCurMapID()];
	if not nowMap then return end
	local map = t_map[cfg.map];
	if not map then return end
	if nowMap.id ~= map.id then
		return
	end
	local func = function() AutoBattleController:OpenAutoBattle(); end
	local point = split(pointCfg[index],',')
	MainPlayerController:DoAutoRun(cfg.map,_Vector3.new(toint(point[1]),toint(point[2]),0),func);
end

--寻路到传送
function UIDekaronDungeonInfo:GoPoint()
	if not self.enterLayer then return end
	local cfg = t_tiaozhanfuben[self.enterLayer];
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
end

function UIDekaronDungeonInfo:ShowInfoClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_info.visible = not objSwf.panel_info.visible;
end

function UIDekaronDungeonInfo:OnShow()
	self:ShowMonsterData();
	self:OnTimeHandler();
end

--计时
function UIDekaronDungeonInfo:OnTimeHandler()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local layer = self.enterLayer;
	if not layer then return end
	local cfg = t_tiaozhanfuben[layer];
	if not cfg then return end
	
	local haveBossTalk = false;
	local talkList = {};
	--------------定时BOSS喊话
	local timeTalkCfg = split(cfg.timetalk,'#');
	if #timeTalkCfg > 0 then
		haveBossTalk = true;
		for i , talkCfg in ipairs(timeTalkCfg) do
			local timeCfg = split(talkCfg , ',');
			local vo = {};
			vo.time = toint(timeCfg[1]);
			vo.chatID = toint(timeCfg[2]);
			talkList[i] = vo;
		end
	end
	--------------定时BOSS喊话
	
	local timeNum = cfg.time;
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		local hour , min , sec = self:OnBackNowLeaveTime(timeNum);
		timeNum = timeNum - 1;
		
		------------BOSS定时喊话
		
		if haveBossTalk and self.layerState == 0 then
			for _time , talkCfg in ipairs(talkList) do
				if talkCfg.time == timeNum then
					UIDungeonNpcChat:Open(talkCfg.chatID);
					break
				end
			end
		end
		
		------------BOSS定时喊话
		
		if timeNum == 10 then
			UIQiZhanDungeonTip:Open(2);
		end
		if timeNum < 0 then
			if self.layerState == 1 then
				DekaronDungeonController:SendQuitDekaronDungeon();
			end
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		objSwf.panel_info.txt_time.text = hour .. ':' .. min .. ':' .. sec;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIDekaronDungeonInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

UIDekaronDungeonInfo.enterLayer = nil;
UIDekaronDungeonInfo.layerState = nil;	--盖层挑战状态 0未挑战 1已挑战
function UIDekaronDungeonInfo:Open(layer,state)
	if not layer then print('!!!!!!!!!!!!!Error:: ' .. layer)return end
	if not state then print('!!!!!!!!!!!!!Error:: ' .. state)return end
	self.enterLayer = layer ;
	self.layerState = state ;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIDekaronDungeonInfo:ResultOpen(result)
	if not self:IsShow () then
		return
	end
	UIConfirm:Close(self.uicUIConfirmID);
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.panel_info.txt_monsterInfo.visible = false;
	if result ~= 0 then
		return
	end
	self:OnChangePanel();
end

function UIDekaronDungeonInfo:OnChangePanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local layer = self.enterLayer;
	if not layer then return end
	for i = 1 , 4 do
		objSwf.panel_info['txt_monster' .. i].visible = false;
	end
	objSwf.panel_info.btn_goto.visible = true;
	objSwf.panel_info.txt_1.htmlText = StrConfig['dekaronDungeon212'];
end

--显示本层都有哪些怪物
function UIDekaronDungeonInfo:ShowMonsterData()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.panel_info.txt_monsterInfo.visible = false;
	local layer = self.enterLayer;
	if not layer then return end
	if not self.layerState then return end
	local cfg = t_tiaozhanfuben[layer];
	if not cfg then return end
	
	if self.layerState == 0 then
		local monsterList = split(cfg.show,'#');			--所有怪物
		for i = 1 , 4 do
			if monsterList[i] then
				local monsterVO = split(monsterList[i],',');
				local monster = t_monster[toint(monsterVO[1])];
				if monster then
					objSwf.panel_info['txt_monster' .. i].visible = true;
					objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['dekaronDungeon201'],monster.name,0,monsterVO[2]) .. '</u>';
				else
					objSwf.panel_info['txt_monster' .. i].visible = false;
				end
			else
				objSwf.panel_info['txt_monster' .. i].visible = false;
			end
		end
		objSwf.panel_info.btn_goto.visible = false;
	else
		for i = 1 , 4 do
			objSwf.panel_info['txt_monster' .. i].visible = false;
		end
		objSwf.panel_info.btn_goto.visible = true;
	end
	objSwf.panel_info.txt_layer._visible = layer > 0;
	objSwf.panel_info.txt_layer.htmlText = string.format(StrConfig['dekaronDungeon202'],layer);
	if layer == 0 then
		objSwf.panel_info.btn_goto.visible = true;
	end
	if layer < 1 then
		objSwf.panel_info.txt_1.htmlText = StrConfig['dekaronDungeon212'];
		return
	end
	if self.layerState == 0 then
		objSwf.panel_info.txt_1.text = StrConfig['dekaronDungeon210'];
		objSwf.panel_info.txt_monsterInfo.visible = true;
		objSwf.panel_info.txt_monsterInfo.txt_monsterInfo.htmlText = '<u>' .. cfg.description .. '</u>';
	else
		objSwf.panel_info.txt_1.htmlText = StrConfig['dekaronDungeon212'];
	end
end

function UIDekaronDungeonInfo:ShowMonsterInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local layer = self.enterLayer;
	local cfg = t_tiaozhanfuben[layer];
	if not cfg then return end
	TipsManager:ShowBtnTips(cfg.xiangxi,TipsConsts.Dir_RightDown);
end

function UIDekaronDungeonInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_info.visible = true;
	objSwf.panel_info.txt_time.text = '';
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIConfirm:Close(self.uicUIConfirmID);
end

function UIDekaronDungeonInfo:GetWidth()
	return 237
end

function UIDekaronDungeonInfo:GetHeight()
	return 358
end

--//击杀怪物信息
function UIDekaronDungeonInfo:OnShowKillData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local killList = DekaronDungeonModel:GetDungeonKillMonsterList();
	if not killList then return end
	
	local layer = self.enterLayer;
	if not layer then return end
	local cfg = t_tiaozhanfuben[layer];
	if not cfg then return end
	
	-- local monsterCfg = DekaronDungeonUtil:GetDekaronDungeonData(layer);
	
	local monsterList = split(cfg.show,'#');
	for i = 1 , 4 do
		if monsterList[i] then
			local monsterCfg = split(monsterList[i],',');
			local monster = t_monster[toint(monsterCfg[1])];
			if monster then
				if killList[monster.id] then
					local num = killList[monster.id].num;
					if toint(monsterCfg[2]) == num then
						objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['dekaronDungeon203'],monster.name,num,monsterCfg[2]) .. '</u>';
					else
						objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['dekaronDungeon201'],monster.name,num,monsterCfg[2]) .. '</u>';
					end
				end
			end
		end
	end
	
end

function UIDekaronDungeonInfo:HandleNotification(name, body)
	if name == NotifyConsts.DekaronDungeonInfoUpDate then			--波数信息刷新
		self:OnShowKillData();
	end
end

--监听消息列表
function UIDekaronDungeonInfo:ListNotificationInterests()
	return { 
		NotifyConsts.DekaronDungeonInfoUpDate,
	};
end