--[[
	2015年11月14日14:49:20
	wangyanwei
	骑战副本追踪
]]

_G.UIQiZhanDungeonInfo = BaseUI:new('UIQiZhanDungeonInfo');

function UIQiZhanDungeonInfo:Create()
	self:AddSWF('qizhanDungeonInfo.swf',true,'bottom');
end

function UIQiZhanDungeonInfo:OnLoaded(objSwf)
	objSwf.panel_info.txt_1.text = StrConfig['qizhanDungeon210'];
	objSwf.panel_info.txt_2.text = StrConfig['qizhanDungeon213'];
	objSwf.panel_info.txt_3.text = StrConfig['qizhanDungeon211'];
	objSwf.panel_info.btnOpen.click = function () self:ShowInfoClick(); end   --显示状态
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.panel_info.btn_quit.click = function ()
		local func = function ()
			QiZhanDungeonController:SendQuitQiZhanDungeon();
		end
		self.uicUIConfirmID = UIConfirm:Open(StrConfig['qizhanDungeon220'],func);		
	end
	objSwf.panel_info.btn_goto.click = function () self:GoPoint(); end
	
	for i = 1 , 4 do
		objSwf.panel_info['txt_monster' .. i].click = function () self:OnMonsterClick(i); end
	end
	objSwf.btnCloseState._visible = false
	objSwf.panel_info.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['qizhanDungeon050'], TipsConsts.Dir_RightDown )
	 end
	objSwf.panel_info.btnRule.rollOut = function() TipsManager:Hide(); end
	RewardManager:RegisterListTips( objSwf.panel_info.rewardList );
end

--点击怪物寻路
function UIQiZhanDungeonInfo:OnMonsterClick(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if not self.enterLayer then return end
	local cfg = t_ridedungeon[self.enterLayer];
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
function UIQiZhanDungeonInfo:GoPoint()
	if not self.enterLayer then return end
	local cfg = t_ridedungeon[self.enterLayer];
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

function UIQiZhanDungeonInfo:ShowInfoClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_info.visible = false;
	objSwf.btnCloseState._visible = true
	-- objSwf.panel_info.visible = not objSwf.panel_info.visible;
end

function UIQiZhanDungeonInfo:OnBtnCloseClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnCloseState._visible = false
	objSwf.panel_info.visible = true;
end

function UIQiZhanDungeonInfo:OnShow()
	self:OnTimeHandler(true);
	self:ShowMonsterData();
	self:UpdateShowReward()
end

-- 更新每波的奖励
function UIQiZhanDungeonInfo:UpdateShowReward( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardAllList = QiZhanDungeonModel:GetQiZhanDungeonRewardListData( )
	if not rewardAllList then
		Debug("not rewardList data......")
		return
	end
	local isShowNum = true
	local rewardStr = ''
	for i,v in ipairs(rewardAllList) do
		if isShowNum then
			rewardStr = rewardStr .. ( i >= #rewardAllList and v.id .. ',' .. v.num or v.id .. ',' .. v.num .. '#'  )
		else
			rewardStr = rewardStr .. ( i >= #rewardAllList and v.id or v.id ..'#'  )
		end
	end
	local getItemList = RewardManager:Parse( rewardStr )
	objSwf.panel_info.rewardList.dataProvider:cleanUp()
	objSwf.panel_info.rewardList.dataProvider:push( unpack(getItemList) )
	objSwf.panel_info.rewardList:invalidateData()
end

--计时
local timeNum;
--@union: true 是第一次进，false  为暂停后重新进
function UIQiZhanDungeonInfo:OnTimeHandler(union)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local layer = self.enterLayer;
	if not layer then return end
	if union then
		local cfg = t_ridedungeon[layer];
		if not cfg then return end
		self.timeNum = cfg.time;
	end
	if not self.timeNum then return; end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		local hour , min , sec = self:OnBackNowLeaveTime(self.timeNum);
		self.timeNum = self.timeNum - 1;
		if self.timeNum == 10 then
			UIQiZhanDungeonTip:Open(2);
		end
		if self.timeNum < 0 then
			if self.layerState == 1 then
				QiZhanDungeonController:SendQuitQiZhanDungeon();
			end
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		objSwf.panel_info.txt_time.text = hour .. ':' .. min .. ':' .. sec;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

-- 关闭倒计时
--@reason 在每一层刚开始等待怪物刷新的时候停止倒计时，怪物刷新出来后继续倒计时
--@date 2016/7/21
function UIQiZhanDungeonInfo:ONCloseTimer( )
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

--重新开始计时
function UIQiZhanDungeonInfo:RestartTimer( )
	self:OnTimeHandler(false)
end

function UIQiZhanDungeonInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

UIQiZhanDungeonInfo.enterLayer = nil;
UIQiZhanDungeonInfo.layerState = nil;	--盖层挑战状态 0未挑战 1已挑战
function UIQiZhanDungeonInfo:Open(layer,state)
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

function UIQiZhanDungeonInfo:ResultOpen(result)
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
	objSwf.panel_info.txt_monsterInfo._visible = false;
	if result ~= 0 then
		return
	end
	self:OnChangePanel();
end

function UIQiZhanDungeonInfo:OnChangePanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local layer = self.enterLayer;
	if not layer then return end
	for i = 1 , 4 do
		objSwf.panel_info['txt_monster' .. i].visible = false;
	end
	objSwf.panel_info.btn_goto.visible = true;
	objSwf.panel_info.txt_1.htmlText = StrConfig['qizhanDungeon212'];
end

--显示本层都有哪些怪物
function UIQiZhanDungeonInfo:ShowMonsterData()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.panel_info.txt_monsterInfo._visible = false;
	local layer = self.enterLayer;
	if not layer then return end
	if not self.layerState then return end
	local cfg = t_ridedungeon[layer];
	if not cfg then return end
	
	if self.layerState == 0 then
		local monsterList = split(cfg.show,'#');			--所有怪物
		for i = 1 , 4 do
			if monsterList[i] then
				local monsterVO = split(monsterList[i],',');
				local monster = t_monster[toint(monsterVO[1])];
				if monster then
					objSwf.panel_info['txt_monster' .. i].visible = true;
					objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['qizhanDungeon201'],monster.name,0,monsterVO[2]) .. '</u>';
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
	objSwf.panel_info.txt_layer.htmlText = string.format(StrConfig['qizhanDungeon202'],layer);
	if layer == 0 then
		objSwf.panel_info.btn_goto.visible = true;
	end
	if layer < 1 then
		objSwf.panel_info.txt_1.htmlText = StrConfig['qizhanDungeon212'];
		return
	end
	if self.layerState == 0 then
		objSwf.panel_info.txt_1.text = StrConfig['qizhanDungeon210'];
		objSwf.panel_info.txt_monsterInfo._visible = true;
		objSwf.panel_info.txt_monsterInfo.text = cfg.description;
	else
		objSwf.panel_info.txt_1.htmlText = StrConfig['qizhanDungeon212'];
	end
end

function UIQiZhanDungeonInfo:OnHide()
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

function UIQiZhanDungeonInfo:GetWidth()
	return 237
end

function UIQiZhanDungeonInfo:GetHeight()
	return 358
end

--//击杀怪物信息
function UIQiZhanDungeonInfo:OnShowKillData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local killList = QiZhanDungeonModel:GetDungeonKillMonsterList();
	if not killList then return end
	
	local layer = self.enterLayer;
	if not layer then return end
	local cfg = t_ridedungeon[layer];
	if not cfg then return end
	
	-- local monsterCfg = QiZhanDungeonUtil:GetQiZhanDungeonData(layer);
	
	local monsterList = split(cfg.show,'#');
	for i = 1 , 4 do
		if monsterList[i] then
			local monsterCfg = split(monsterList[i],',');
			local monster = t_monster[toint(monsterCfg[1])];
			if monster then
				if killList[monster.id] then
					local num = killList[monster.id].num;
					if toint(monsterCfg[2]) == num then
						objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['qizhanDungeon203'],monster.name,num,monsterCfg[2]) .. '</u>';
					else
						objSwf.panel_info['txt_monster' .. i].htmlLabel = '<u>' .. string.format(StrConfig['qizhanDungeon201'],monster.name,num,monsterCfg[2]) .. '</u>';
					end
				end
			end
		end
	end
	
end

function UIQiZhanDungeonInfo:HandleNotification(name, body)
	if name == NotifyConsts.QiZhanDungeonInfoUpDate then			--波数信息刷新
		self:OnShowKillData();
	elseif name == NotifyConsts.QiZhanDungeonRewardUpDate then
		self:UpdateShowReward();
	end
end

--监听消息列表
function UIQiZhanDungeonInfo:ListNotificationInterests()
	return { 
		NotifyConsts.QiZhanDungeonInfoUpDate,NotifyConsts.QiZhanDungeonRewardUpDate,
	};
end