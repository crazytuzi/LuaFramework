--[[
	2015年11月1日15:55:53
	wangyanwei
]]

_G.UIPersonalBossInfo = BaseUI:new('UIPersonalBossInfo');

function UIPersonalBossInfo:Create()
	self:AddSWF('personalbossInfoPanel.swf',true,'bottom');
end

function UIPersonalBossInfo:OnLoaded(objSwf)
	-- objSwf.small.txt_1.text = UIStrConfig['personalboss5'];
	objSwf.small.txt_2.text = UIStrConfig['personalboss7'];
	
	objSwf.btn_state.click = function () self:StateClickHandler(); end
	
	objSwf.small.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.small.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.small.btn_quit.click = function () 
		local func = function()
			PersonalBossController:SendQuitPersonalBoss();
		end
		self.uiconfirmID = UIConfirm:Open(StrConfig['personalboss20'],func);
	end
end

function UIPersonalBossInfo:OnShow()
	self:ShowInfo();
	self:SetUIState();
end

function UIPersonalBossInfo:ShowInfo()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	
	if not self.personalbossID then return end

	local cfg = t_personalboss[self.personalbossID];
	if not cfg then return end
	
	local isfirst = false --PersonalUtil:GetIDIsFirst(cfg.bossId);
	objSwf.small.txt_1.text = isfirst and UIStrConfig['personalboss6'] or UIStrConfig['personalboss5'];
	local randomList = RewardManager:Parse( isfirst and cfg.firstReward or cfg.dropReward);
	objSwf.small.rewardList.dataProvider:cleanUp();
	objSwf.small.rewardList.dataProvider:push(unpack(randomList));
	objSwf.small.rewardList:invalidateData();
end

UIPersonalBossInfo.personalbossID = nil;
function UIPersonalBossInfo:Open(id)
	if not id then return end
	self.personalbossID = id;
	self:Show();
end

function UIPersonalBossInfo:GetWidth()
	return 237
end

function UIPersonalBossInfo:GetHeight()
	return 360
end

function UIPersonalBossInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.small.visible = true;
	self.personalbossID = nil;
	UIConfirm:Close(self.uiconfirmID);
end

function UIPersonalBossInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.small._visible = true
	objSwf.small.hitTestDisable = false;
	objSwf.btn_state.selected = false;
end;

function UIPersonalBossInfo:StateClickHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_state.selected = objSwf.small.visible;
	objSwf.small.visible = not objSwf.small.visible;
	objSwf.small.hitTestDisable = not objSwf.small.visible;
end

function UIPersonalBossInfo:TimeChange(timeNum)
	local objSwf = self.objSwf; 
	if not objSwf then return end
	if not timeNum then print('not timeNum')return end
	if type(timeNum) ~= 'number' then print('type not number',timeNum)return end
	local hour,min,sec = self:OnBackNowLeaveTime(timeNum);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	objSwf.small.txt_time.htmlText = hour .. ':' .. min .. ':' ..sec;
end

function UIPersonalBossInfo:OnBackNowLeaveTime(timeNum)
	-- if not _time then _time = 0 end
	local hour,min,sec = CTimeFormat:sec2format(timeNum);
	return hour,min,sec
end

function UIPersonalBossInfo:HandleNotification(name, body)
	if name == NotifyConsts.PersonalBossTime then			--波数信息刷新
		self:TimeChange(body.timeNum);
	end
end

--监听消息列表
function UIPersonalBossInfo:ListNotificationInterests()
	return { 
		NotifyConsts.PersonalBossTime,
	};
end