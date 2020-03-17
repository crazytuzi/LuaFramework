--[[
	2015年1月23日, PM 04:33:46
	wangyanwei
]]

_G.UIBabelLayerInfo = BaseUI:new('UIBabelLayerInfo');

function UIBabelLayerInfo:Create()
	self:AddSWF("babelLayerInfo.swf",true,"bottom");
end

function UIBabelLayerInfo:OnLoaded(objSwf)
	-- objSwf.minPanel.btn_combat.htmlLabel = UIStrConfig['babel156'];
	-- objSwf.minPanel.btn_combat.click = function () self:OnChangeStateClick(); end  --挂机切换
	objSwf.minPanel.btn_out.click = function () self:OnOutBabelClick(); end
	objSwf.minPanel.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.minPanel.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.minPanel.btnOpen.click = function () self:panelStateClick(); end   
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.minPanel.txt_1.text = UIStrConfig['babel151'];
	objSwf.minPanel.txt_2.text = UIStrConfig['babel152'];
	objSwf.minPanel.txt_3.text = UIStrConfig['babel153'];
	objSwf.minPanel.txt_4.text = UIStrConfig['babel154'];
	objSwf.minPanel.txt_5.text = UIStrConfig['babel155'];
	objSwf.minPanel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['babel100'], TipsConsts.Dir_RightDown )
	 end
	objSwf.minPanel.btnRule.rollOut = function() TipsManager:Hide(); end
end

function UIBabelLayerInfo:OnShow()
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	--self:OnChangePanelInfo();显示面板信息
	-- self:OnPlayMovie();   				-- 播放mov
	BabelController:OnSendStoryEnd()    -- 临时的，绕过mov

	self.objSwf.minPanel.txt_nowAtt.text = '0';
	self:SetUIState()
end

function UIBabelLayerInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.minPanel._visible = true
	objSwf.btnCloseState._visible = false
end;


function UIBabelLayerInfo:panelStateClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = false
	objSwf.btnCloseState._visible = true
end

function UIBabelLayerInfo:OnBtnCloseClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = true;
	objSwf.btnCloseState._visible = false;

end


--播放剧情
-- 剧情1 
function UIBabelLayerInfo:OnPlayMovie2()
	if BabelController.lastState == 1 then 
		local cfg = t_doupocangqiong[BabelModel.nowLayer];
		local movie = cfg.movieid1;
		local func = function ()
			self:OnPlayMovie();
		end
		BabelController.lastState = 0;
		StoryController:StoryStartDoupocangqiong(movie,func,cfg.movieNpcId,false);
	else
		self:OnTimeTwoHandler();
	end;
end

--剧情2
function UIBabelLayerInfo:OnPlayMovie()
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- objSwf.minPanel.btn_combat.htmlLabel = UIStrConfig['babel156'];
	local cfg = t_doupocangqiong[BabelModel.nowLayer];
	local movie = cfg.movieid;
	local func = function ()
		self:OnTimeTwoHandler();
	end
	StoryController:StoryStartDoupocangqiong(movie,func,cfg.movieNpcId,true,true);
end
--剧情恢复延时1秒钟
function UIBabelLayerInfo:OnTimeTwoHandler()
	local objSwf = self.objSwf;
	objSwf.minPanel.txt_timeNow.text = '';
	local func = function ()
		BabelController:OnSendStoryEnd();
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
		UIAutoBattleTip:Open(function()UIBabelLayerInfo:OnGoMonster();end,true);
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,1);
end

--挂机切换
function UIBabelLayerInfo:OnChangeStateClick()
	self:OnGoMonster();
end

--寻路
function UIBabelLayerInfo:OnGoMonster()
	local cfg = t_doupocangqiong[BabelModel.nowLayer];
	local mapid = CPlayerMap:GetCurMapID();
	local point = split(cfg.autoFight,",")
	local completeFuc = function()
		local objSwf = self.objSwf;
		if not objSwf then return end
		AutoBattleController:SetAutoHang();
		-- objSwf.minPanel.btn_combat.htmlLabel = UIStrConfig['babel157'];
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(point[1],point[2],0),completeFuc);
end

--切换挂机
function UIBabelLayerInfo:OhChangeIsAutoHang(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state then
		if UIAutoBattleTip:IsShow() then
			UIAutoBattleTip:Hide();
		end
	else
		UIAutoBattleTip:Open(function()UIBabelLayerInfo:OnGoMonster();end);
	end
end

--退出斗破苍穹
function UIBabelLayerInfo:OnOutBabelClick()
	local func = function () 
		BabelController:OnOutBabel(0);
	end
	self.uiconfirmID = UIConfirm:Open(StrConfig['cave002'],func);
end

--显示详细信息
function UIBabelLayerInfo:OnChangePanelInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_doupocangqiong[BabelModel.nowLayer];
	if not cfg then
		Debug("not find cfgData in t_doupocangqiong")
	end
	objSwf.minPanel.txt_layer.text = cfg.id .. '';
	local bossId = cfg.bossId
	local monsterCfg = t_monster[bossId]
	if not monsterCfg then return end
	local monsterHp = monsterCfg.hp
	local maxTime = cfg.maxTime
	local minAtt = math.floor(monsterHp / maxTime)
	objSwf.minPanel.txt_minAtt.text = minAtt .. '';
	self:OnChangeTimeTxt(cfg.maxTime); --开始计时
	self:ShowRewardList();
end

--显示本层奖励list
function UIBabelLayerInfo:ShowRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel.rewardList.dataProvider:cleanUp();
	local cfg = t_doupocangqiong[BabelModel.nowLayer];
	local rewardList = '';
	if BabelModel.layerState == 1 then 
		rewardList = RewardManager:Parse(cfg.firstReward);
	else
		local extrarewardCfg = split(cfg.extrareward,',');
	
		--changer:houxudong  date:2016/7/9
		-- local extrarewardStr = extrarewardCfg[1] .. ',' .. extrarewardCfg[2];
	
		-- rewardList = RewardManager:Parse(extrarewardStr .. '#' .. cfg.reward);
		rewardList = RewardManager:Parse(cfg.reward);
	end
	objSwf.minPanel.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.minPanel.rewardList:invalidateData();
end

--计算剩余时间  														还有秒伤！！！
UIBabelLayerInfo.timeKey = nil;
UIBabelLayerInfo.nowTime = 0;
UIBabelLayerInfo.secondHarm = 0;
UIBabelLayerInfo.count = 1;
function UIBabelLayerInfo:OnChangeTimeTxt(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.nowTime = num + 1;
	local timeCount = t_consts[48].val2 >= 1000 and t_consts[48].val2 or 1000;
	local func = function(count)
		self.nowTime = self.nowTime - 1;
		UIBabelLayerInfo.count = count;
		-- print(UIBabelLayerInfo.count,timeCount / 1000,'timetimetimetime')
		if UIBabelLayerInfo.count % math.floor(timeCount / 1000) == 0 then
			self:OnChangeHarm();
		end
		if self.nowTime == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self.nowTime = 0;
			objSwf.minPanel.txt_timeNow.text = '00:00:00';
			return;
		end
		local hour,min,sec = self:OnBackNowLeaveTime(self.nowTime);
		objSwf.minPanel.txt_timeNow.text = hour .. ':' .. min .. ':' .. sec;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func(1);
end

function UIBabelLayerInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

function UIBabelLayerInfo:OnChangeHarm()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if toint(self.secondHarm/self.count) < 0 then
		objSwf.minPanel.txt_nowAtt.text = '0';
		return
	end
	objSwf.minPanel.txt_nowAtt.text = toint(self.secondHarm/self.count);
end

function UIBabelLayerInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.secondHarm = 0;
	objSwf.minPanel.txt_nowAtt.text = '0';
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
		self.nowTime = 0;
	end
	objSwf.minPanel.rewardList.dataProvider:cleanUp();
	objSwf.minPanel.rewardList:invalidateData();
	objSwf.minPanel.txt_layer.text = '';
	objSwf.minPanel.txt_minAtt.text = '';
	if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	end
	UIConfirm:Close(self.uiconfirmID);
end

function UIBabelLayerInfo:GetWidth()
	return 237
end

function UIBabelLayerInfo:GetHeight()
	return 380
end

function UIBabelLayerInfo:HandleNotification(name,body)
	if name == NotifyConsts.BabelInfoPanelOpen then
		self:OnPlayMovie2();
	elseif name == NotifyConsts.AutoHangStateChange then
		-- self:OhChangeIsAutoHang(body.state);
	elseif name == NotifyConsts.BabelStory then
		self:OnChangePanelInfo();
	elseif name == NotifyConsts.BabelSecondHarm then
		self.secondHarm = self.secondHarm + body.harm;
		-- self:OnChangeHarm();
	end
end

function UIBabelLayerInfo:ListNotificationInterests()
	return {
		NotifyConsts.BabelInfoPanelOpen,
		NotifyConsts.AutoHangStateChange,
		NotifyConsts.BabelStory,
		NotifyConsts.BabelSecondHarm
	}
end