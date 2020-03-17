--[[
	主宰之路追踪面板
	2015年6月5日, PM 08:00:28
	wnagyanwei
]]

_G.UIDominateRouteInfo = BaseUI:new('UIDominateRouteInfo');

function UIDominateRouteInfo:Create()
	self:AddSWF('dominateRouteInfoPanel.swf',true,'center');
end

function UIDominateRouteInfo:OnLoaded(objSwf)
	-- objSwf.small.txt_title.text = StrConfig['dominateRoute0900'];
	objSwf.small.tf1.text = UIStrConfig['dominateRoute50'];
	objSwf.small.tf2.text = UIStrConfig['dominateRoute51'];
	-- objSwf.small.tf3.text = UIStrConfig['dominateRoute52'];
	
	-- objSwf.small.level_1.tf1.text = UIStrConfig['dominateRoute31'];
	-- objSwf.small.level_2.tf1.text = UIStrConfig['dominateRoute32'];
	-- objSwf.small.level_3.tf1.text = UIStrConfig['dominateRoute33'];
	
	objSwf.small.txt_winPoint.text = UIStrConfig['dominateRoute56'];
	objSwf.small.btn_quit.click = function () self:OnQuitClick(); end
	-- objSwf.small.btn_auto.click = function() self:OnBtnAutoClick(); end
	
	objSwf.small.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.small.rewardList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.btn_state.click = function () 
						objSwf.btn_state.selected = objSwf.small.visible;
						objSwf.small.visible = not objSwf.small.visible; 
						end
	
	-- objSwf.small.btn_firstReward.rollOver = function ()
		-- local drID = self.dominateRouteID;
		-- local cfg = t_zhuzairoad[drID];
		-- TipsManager:ShowBtnTips(cfg.firstTipStr,TipsConsts.Dir_RightDown);
	-- end
	-- objSwf.small.btn_firstReward.rollOut = function () TipsManager:Hide(); end
	objSwf.btn_state.btnRule._visible = false
end

function UIDominateRouteInfo:OnShow()
	self:OnChangeLevel();
	self:OnDrawRewardList();
	self:OnChangeParbar();
	self:FirstRewrad();
	-- 开启自动挂机
	UIAutoBattleTip:Open(function()UIDominateRouteInfo:OnBtnAutoClick();end,true);
	self:SetUIState()
end

function UIDominateRouteInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.small._visible = true
	objSwf.small.hitTestDisable = false;
	objSwf.btn_state.selected = false;
end;


UIDominateRouteInfo.dominateRouteID = nil;
function UIDominateRouteInfo:Open(id)
	self.dominateRouteID = id;
	self:Show();
end

function UIDominateRouteInfo:GetID()
	return self.dominateRouteID;
end

--退出
function UIDominateRouteInfo:OnQuitClick()
	local func = function () 
		DominateRouteController:SendDominateRouteQuit();
	end
	self.uiconfirmID = UIConfirm:Open(StrConfig['dominateRoute050'],func);
end

--等级距离区分
function UIDominateRouteInfo:OnChangeLevel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	local levelCfg = split(cfg.level_star,'#');
	objSwf.small.proBar.maximum = cfg.level_limit;
	for i , v in ipairs(levelCfg) do
		local vo = split(v,',');
		local num = toint(vo[2]) / cfg.level_limit;
		-- 8:左侧底板和遮罩的间距 171:遮罩的长度
		objSwf.small['level_' .. i]._x = objSwf.small.proBar._x + 171 * num + 8 ;
	end
	
	--章节图片
	objSwf.small.icon.text = cfg.roundtextName;
	objSwf.small.icon._visible = false
	
	--UI文本
	local strVO = split(cfg.titleInfo,'#');
	objSwf.small.txt_info.text = strVO[1] .. ' ' .. strVO[2];
	objSwf.small.txt_info._visible = false
	objSwf.small.visible = true;
end

--进度条改变
function UIDominateRouteInfo:OnChangeParbar()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	local maxNum = cfg.level_limit;
	objSwf.small.proBar.maximum = cfg.level_limit;
	objSwf.small.proBar.value = maxNum;
	local func = function ()
		maxNum = maxNum - 1;
		local min,sec = self:OnBackNowLeaveTime(maxNum);
		objSwf.small.txt_time.htmlText = string.format(StrConfig['dominateRoute020'],min,sec);
		local starNum = self:OnGetStr(maxNum);
		for i = 1 , 3 do
			objSwf.small['star_' .. i]._visible = starNum >= i;
		end
		if maxNum < 1 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		objSwf.small.proBar.value = maxNum;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIDominateRouteInfo:GetWidth()
	return 237;
end

--传入num，求出star等级
function UIDominateRouteInfo:OnGetStr(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	local levelCfg = split(cfg.level_star,'#');
	local level = 0;
	for i , v in ipairs(levelCfg) do
		local vo = split(v,',');
		if num >= toint(vo[2]) then
			level = i;
		end
	end
	return level;
end

--时间换算
function UIDominateRouteInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return min,sec
end

--画奖励list
function UIDominateRouteInfo:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.dominateRouteID];
	if not cfg then return end
	
	local isFirst = DominateRouteModel:GetDominateRouteIsPass(self.dominateRouteID);
	local rewardStr = '';
	if isFirst then
		objSwf.small.tf3.text = StrConfig['dominateRoute0400'];
		rewardStr = cfg.rewardStr;
	else
		objSwf.small.tf3.text = StrConfig['dominateRoute0401'];
		rewardStr = cfg.firstrewardStr;
	end
	
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.small.rewardList.dataProvider:cleanUp();
	objSwf.small.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.small.rewardList:invalidateData();
end

--首通奖励的按钮
function UIDominateRouteInfo:FirstRewrad()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local drID = self.dominateRouteID;
	local cfg = t_zhuzairoad[drID];
	if not cfg then return end
	
	local isFirst = DominateRouteModel:GetDominateRouteIsPass(drID);
	-- if not isFirst then
		-- objSwf.small.tf2.text = UIStrConfig['dominateRoute57'];
		-- objSwf.small.txt_winPoint._visible = false;
		-- objSwf.small.btn_firstReward.visible = true;
	-- else
	objSwf.small.tf2.text = UIStrConfig['dominateRoute51'];
		-- objSwf.small.txt_winPoint._visible = true;
		-- objSwf.small.btn_firstReward.visible = false;
	-- end
	-- if not objSwf.small.btn_firstReward.visible then
		-- return
	-- end
	-- local equipCreateCfg = nil;
	
	-- for i , v in pairs(t_equipcreate) do
		-- if v.fubId == drID then
			-- equipCreateCfg = v;
			-- break;
		-- end
	-- end
	-- if not equipCreateCfg then return end
	-- objSwf.small.btn_firstReward.htmlLabel = string.format(StrConfig['dominateRoute021'],equipCreateCfg.name);
end

function UIDominateRouteInfo:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local objSwf = self.objSwf;
	if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	end
	UIConfirm:Close(self.uiconfirmID);
end

function UIDominateRouteInfo:OnBtnAutoClick()
	local roadboxId = toint(self.dominateRouteID/10000);
	local cfg = t_roadbox[roadboxId];
	if not cfg then return; end
	local point = QuestUtil:GetQuestPos(cfg.posId);
	if not point then return end
	local completeFuc = function()
		AutoBattleController:SetAutoHang();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

--改变挂机按钮文本
function UIDominateRouteInfo:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state then
		if UIAutoBattleTip:IsShow() then
			UIAutoBattleTip:Hide();
		end
	else
		UIAutoBattleTip:Open(function()UIDominateRouteInfo:OnBtnAutoClick();end);
	end
end

---------------------功能引导相关接口---------------------
function UIDominateRouteInfo:GetAutoBtn()
	return
	-- if not self:IsShow() then return; end
	-- return self.objSwf.small.btn_auto;
end

function UIDominateRouteInfo:HandleNotification(name,body)
	if name == NotifyConsts.AutoHangStateChange then
		-- self:OnChangeAutoText(body.state);
	end
end
function UIDominateRouteInfo:ListNotificationInterests()
	return {
		NotifyConsts.AutoHangStateChange
	}
end