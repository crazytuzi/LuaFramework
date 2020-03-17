--[[
	2015年2月3日, PM 04:29:26
	wangyanwei
	定时副本结局面板
]]
_G.UITimeDungeonResult = BaseUI:new('UITimeDungeonResult');

function UITimeDungeonResult:Create()
	self:AddSWF('timeDungeonResultPanel.swf',true,"center");
end

function UITimeDungeonResult:OnLoaded(objSwf,name)
	objSwf.btn_quit.click = function() TimeDungeonController:QuitTimeDungeon(); end
	objSwf.winpanel.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.winpanel.rewardList.itemRollOut = function() TipsManager:Hide(); end
end

function UITimeDungeonResult:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.lose._visible = false;
	objSwf.win._visible = false;
	objSwf.bgFail._visible = false;
	objSwf.bgWin._visible = false;
	if self.resultData.result == 0 then
		objSwf.lose._visible = true;
		objSwf.winpanel._visible = false;
		objSwf.bgFail._visible = true;
	elseif self.resultData.result == 1 then
		objSwf.win._visible = true;
		objSwf.winpanel._visible = true;
		objSwf.bgWin._visible = true;
	end
	if objSwf.win._visible then
		local rewardCfg = t_monkeytimereward[TimeDungeonModel.dungeonLevel];
		if rewardCfg then
			objSwf.winpanel.rewardList.dataProvider:cleanUp();
			local rewardList = RewardManager:Parse(rewardCfg['difficulty_' .. (TimeDungeonModel.dungeonState or 1)]);
			objSwf.winpanel.rewardList.dataProvider:push(unpack(rewardList));
			objSwf.winpanel.rewardList:invalidateData();
		end
	end
	self:OnTimeChange();
end

function UITimeDungeonResult:OnTimeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = 20;
	objSwf.txt_time.htmlText = string.format(StrConfig['timeDungeon081'],num);
	local func = function ()
		 num = num - 1;
		 objSwf.txt_time.htmlText = string.format(StrConfig['timeDungeon081'],num);
		 if num == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			TimeDungeonController:QuitTimeDungeon();
		 end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

UITimeDungeonResult.resultData = {};
function UITimeDungeonResult:Open(result)
	self.resultData = result;
	self:Show();
end

function UITimeDungeonResult:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.winpanel.rewardList.dataProvider:cleanUp();
	objSwf.winpanel.rewardList:invalidateData();
end