--[[
	在线时间奖励
	2014年12月17日, PM 10:07:20
	wangyanwei
]]

_G.UIRegisterTimePanel = BaseUI:new("UIRegisterTimePanel");
UIRegisterTimePanel.rotTime = 50;
UIRegisterTimePanel.rotItem = 1;

function UIRegisterTimePanel:Create()
	self:AddSWF("registerTime.swf", true, nil);
end

function UIRegisterTimePanel:OnLoaded(objSwf)
	local obj = RegisterAwardModel:GetTimeInfo();
	for i = 1 , 4 do
		objSwf['btnReward_' .. i].click = function () RegisterAwardController:OnSendRandomReward(i); end
		objSwf['timeInfo_' .. i].num = obj[i];
		-- objSwf['btnReward_' .. i].timeRewardEffct_1.complete = function () objSwf['btnReward_' .. i].timeRewardEffct_1:playEffect(1); end
		-- objSwf['btnReward_' .. i].timeRewardEffct_1.visible = false;
		-- objSwf['btnReward_' .. i].timeRewardEffct_1:stopEffect();
	end
end

function UIRegisterTimePanel:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:OnShowRewardIcon();
end

function UIRegisterTimePanel:OnHide()
	self.rotItem = 1;
end

--画出奖励图标
UIRegisterTimePanel.RewardVO = {};
UIRegisterTimePanel.RewardVO1 = {};
function UIRegisterTimePanel:OnShowRewardIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local objIndex = RegisterAwardModel:GetItemIndex();
	local objLevel = RegisterAwardModel:GetRewardLevel();
	for i = 1 , 4 do
		local cfg = RewardSlotVO:new();
		local rewardCfg = split(t_onlineaward[objLevel[i]]['indexReward_' .. (i - 1)],'#');
		local smallCfg = {};
		local bagCfg = {};
		if #rewardCfg ==2 then
			bagCfg = split(rewardCfg[2],',');
		end
		if objIndex == {} then
			-- print('-----------objIndex == {}')
			smallCfg = split(rewardCfg[1],',');
		else
			if not objIndex[i] or objIndex[i] == 0 then
				-- print('-----------not objIndex[i] or objIndex[i] == 0')
				smallCfg = split(rewardCfg[1],',');
			else
				-- print('-----------11')
				smallCfg = split(rewardCfg[1],',');
				cfg.isBlack = true;
			end
		end
		
		cfg.id = toint(smallCfg[1]);
		cfg.count = toint(smallCfg[2]);
		self.RewardVO[i] = {};
		self.RewardVO[i] = cfg;
		-- objSwf['txt_reward' .. i].htmlText = string.format(StrConfig['registerReward5000'] ,TipsConsts:GetItemQualityColor(t_item[toint(smallCfg[1])].quality),t_item[toint(smallCfg[1])].name);
		-- objSwf['txt_reward' .. i].text = t_onlinetimes[i].type;
		objSwf['timeReward_' .. i]:setData(cfg:GetUIData());
		objSwf['timeReward_' .. i].rollOver = function (e) local vo = self.RewardVO[i]:GetTipsInfo();if not vo then return end TipsManager:ShowTips(vo.tipsType,vo.info,vo.tipsShowType,TipsConsts.Dir_RightDown,vo.itemID); end;
		objSwf['timeReward_' .. i].rollOut = function () TipsManager:Hide(); end;
		
		if #rewardCfg ==2 then
			objSwf['timeReward1_' .. i]._visible = true
			cfg.id = toint(bagCfg[1]);
			cfg.count = toint(bagCfg[2]);
			self.RewardVO1[i] = {};
			self.RewardVO1[i] = cfg;
			objSwf['timeReward1_' .. i]:setData(cfg:GetUIData());
			objSwf['timeReward1_' .. i].rollOver = function (e) local vo = self.RewardVO1[i]:GetTipsInfo();if not vo then return end TipsManager:ShowTips(vo.tipsType,vo.info,vo.tipsShowType,TipsConsts.Dir_RightDown, vo.itemID); end;
			objSwf['timeReward1_' .. i].rollOut = function () TipsManager:Hide(); end;
		else
			objSwf['timeReward1_' .. i]._visible = false
		end
	end
	
	--抽奖按钮状态
	self:OnChangeBtnState();
end

function UIRegisterTimePanel:OnChangeBtnState()
	local objSwf = self.objSwf;
	for i = 1 , 4 do
		if RegisterAwardModel:GetIndexRewardBoolean(i) then
			objSwf['btnReward_' .. i].visible = (i == self.nowRewarIndex);
		else
			if RegisterAwardModel:GetIndexIsOpen(i) == true then
				objSwf['btnReward_' .. i].disabled =(i == self.nowRewarIndex);
				if not objSwf['btnReward_' .. i].disabled then 
					-- objSwf['btnReward_' .. i].timeRewardEffct_1.visible = true;
					-- objSwf['btnReward_' .. i].timeRewardEffct_1:playEffect(1);
					objSwf['btnReward_' .. i]:showEffect(ResUtil:GetButtonEffect10());
				else
					-- objSwf['btnReward_' .. i].timeRewardEffct_1:stopEffect();
					objSwf['btnReward_' .. i]:clearEffect();
				end
			elseif RegisterAwardModel:GetIndexIsOpen(i) == false then
				objSwf['btnReward_' .. i].disabled = true;
				-- objSwf['btnReward_' .. i].timeRewardEffct_1:stopEffect();
				objSwf['btnReward_' .. i]:clearEffect();
			end
			objSwf['rewarded_' .. i]._visible = false;
		end
	end
end

--收到抽奖协议执行
UIRegisterTimePanel.nowRewarIndex = -1;
function UIRegisterTimePanel:OnTweenRewardItem(body)
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- objSwf['txt_reward' .. body.timeIndex].text = '';
	objSwf['timeReward_' .. body.timeIndex]:setData('');
	objSwf['timeReward1_' .. body.timeIndex]:setData('');
	objSwf['tweenReward_' .. body.timeIndex].visible = true;
	objSwf['tweenReward_' .. body.timeIndex]:playEffect(1);
	objSwf['btnReward_' .. body.timeIndex].disabled = true;
	-- objSwf['btnReward_' .. body.timeIndex].timeRewardEffct_1.visible = false;
	-- objSwf['btnReward_' .. body.timeIndex].timeRewardEffct_1:stopEffect();
	objSwf['btnReward_' .. body.timeIndex]:clearEffect();
	objSwf['tweenReward_' .. body.timeIndex].complete = function()
		objSwf['tweenReward_' .. body.timeIndex].visible = false;
		objSwf['btnReward_' .. body.timeIndex].visible = false;
		objSwf['geted_' .. body.timeIndex].visible = true;
		objSwf['geted_' .. body.timeIndex]:playEffect(1);
	end;
	objSwf['geted_' .. body.timeIndex].complete = function()
		objSwf['geted_' .. body.timeIndex].visible = false;
		objSwf['rewarded_' .. body.timeIndex]._visible = true;
	end
	self.nowRewarIndex = body.timeIndex;
	
	local cfg = split(t_onlineaward[MainPlayerModel.humanDetailInfo.eaLevel]['indexReward_' .. (body.timeIndex - 1)],'#');
	local rewardCfg = split(cfg[body.index + 1],',');
	local func = function ()
		
		local vo = RewardSlotVO:new();
		vo.id = toint(rewardCfg[1]);
		vo.count = toint(rewardCfg[2]);
		vo.isBlack = true;
		self.RewardVO[body.timeIndex] = vo;
		local objSwf = self.objSwf;
		if objSwf then
			objSwf['timeReward_' .. body.timeIndex]:setData(vo:GetUIData());
		--body.index + 1
			self.nowRewarIndex = -1;
			-- objSwf['txt_reward' .. body.timeIndex].htmlText = string.format(StrConfig['registerReward5000'] ,TipsConsts:GetItemQualityColor(t_item[toint(rewardCfg[1])].quality),t_item[toint(rewardCfg[1])].name);
			-- debug.debug();
		end
		if #cfg == 2 then
			local rewardCfg1 = split(cfg[2],',');
			local vo1 = RewardSlotVO:new();
			vo1.id = toint(rewardCfg1[1]);
			vo1.count = toint(rewardCfg1[2]);
			vo1.isBlack = true;
			self.RewardVO1[body.timeIndex] = vo1;
			objSwf['timeReward1_' .. body.timeIndex]:setData(vo1:GetUIData());
		end
	end
	TimerManager:RegisterTimer(func,500,1);
end

--剩余时间
function UIRegisterTimePanel:OnUpDataTimeTxt()
	local objSwf = self.objSwf;
	if RegisterAwardModel.timeNum<1 then
		return
	end
	local hour,min,sec = self:OnBackNowLeaveTime(RegisterAwardModel.timeNum);
	-- objSwf.txtTime_1.num = hour .. 'm' .. min .. 'm' .. sec;
		objSwf.txtTime_2.text = hour .. '：' .. min .. '：' .. sec;
	objSwf.txtTime_3.text = StrConfig['registerReward5007']
	--每一秒钟闪一次奖励图标
	-- for i = 1 , 4 do
		-- local cfg = RewardSlotVO:new();
		-- local rewardCfg = split(t_onlineaward[MainPlayerModel.humanDetailInfo.eaLevel]['indexReward_' .. (i - 1)],'#');
		-- local num = RegisterAwardModel.timeNum%#rewardCfg;
		-- if num == 0 then num = #rewardCfg; end
		-- local smallCfg = split(rewardCfg[num],',');
		-- if not RegisterAwardModel:GetIndexRewardBoolean(i) and i ~= self.nowRewarIndex then
			-- cfg.id = toint(smallCfg[1]);
			-- cfg.count = toint(smallCfg[2]);
			-- self.RewardVO[i] = cfg;
			-- objSwf['timeReward_' .. i]:setData(cfg:GetUIData());
			-- objSwf['txt_reward' .. i].htmlText = string.format(StrConfig['registerReward5000'] ,TipsConsts:GetItemQualityColor(t_item[toint(smallCfg[1])].quality),t_item[toint(smallCfg[1])].name);
		-- end
	-- end
end

function UIRegisterTimePanel:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end


function UIRegisterTimePanel:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.GetRewardIndex then
		self:OnTweenRewardItem(body);
	elseif name == NotifyConsts.TimeNumUpData then
		self:OnUpDataTimeTxt();
	elseif name == NotifyConsts.UpdataTimeRewardNum then
		self:OnChangeBtnState();
	end
	
end
function UIRegisterTimePanel:ListNotificationInterests()
	return {
		NotifyConsts.GetRewardIndex,
		NotifyConsts.TimeNumUpData,
		NotifyConsts.UpdataTimeRewardNum
	}
end