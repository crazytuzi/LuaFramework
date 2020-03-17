--[[
	2015年4月8日, PM 04:07:59
	wnagyanwei
	血战北仓街结局面板
]]
_G.UIBeicangjieResult = BaseUI:new('UIBeicangjieResult');

function UIBeicangjieResult:Create()
	self:AddSWF("beicangjieResult.swf", true, "top");
end

function UIBeicangjieResult:OnLoaded(objSwf)
	objSwf.btn_out.click = function () self:OnOutActivity(); end
	objSwf.btn_enter.click = function () self:OnEnterLayer(); end
	objSwf.btn_quit.click = function () self:OnQuitActivity(); end
	
	objSwf.rewardList1.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList2.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList1.itemRollOut = function () TipsManager:Hide(); end
	objSwf.rewardList2.itemRollOut = function () TipsManager:Hide(); end
end

--领奖退出
function UIBeicangjieResult:OnOutActivity()
	ActivityBeicangjie:OnGetRewardQuit();   --changer:hoxudong 更改，不需要领奖退出，直接退出就行，详情可以问东哥
	-- local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	-- if not activity then return; end
	-- if activity:GetType() ~= ActivityConsts.T_Beicangjie then return; end
	-- ActivityController:QuitActivity(activity:GetId());
end

--继续下个
function UIBeicangjieResult:OnEnterLayer()
	ActivityBeicangjie:OnGetConBeicangjie();
end

--拒绝挑战退出
function UIBeicangjieResult:OnQuitActivity()
	ActivityBeicangjie:OnGetRewardQuit();
	--[[
	-- local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	-- if not activity then return; end
	-- if activity:GetType() ~= ActivityConsts.T_Beicangjie then return; end
	-- ActivityController:QuitActivity(activity:GetId());
	--]]
end

UIBeicangjieResult.obj = {};
function UIBeicangjieResult:Open(obj)
	self.obj = obj;
	self:Show();
end

function  UIBeicangjieResult:TimeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local func = function(count)
		if self.obj.state == 2 and self.obj.result == 1 then
			objSwf.txt_time.htmlText = string.format(StrConfig['beicangjie008'],10 - count)
		else
			objSwf.txt_time.htmlText = string.format(StrConfig['beicangjie007'],10 - count)
		end
		if count == 10 then
			if self.obj.state == 1 and self.obj.result == 0 then
				-- ActivityBeicangjie:OnGetConBeicangjie();  --封神乱斗等级达到7级以上不进入北仓殿，直接退出
				ActivityBeicangjie:OnGetRewardQuit();
				-- ActivityBeicangjie:QuitActivity();
				-- self:OnOutActivity();
				return
			end
			
			ActivityBeicangjie:OnGetRewardQuit();
			-- ActivityBeicangjie:QuitActivity();
			self:OnOutActivity();
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,10);
	func(0);
end

function UIBeicangjieResult:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_next._visible = false;
	objSwf.panel_end._visible = false;
	objSwf.panel_defeat._visible = false;
	objSwf.panel_win._visible = false;
	
	local rewardConstsNum = 10000;
	
	local rewardCfg = {};
	local rankNum = ActivityBeicangjie:OnGetIsInRank();
	for i , v in pairs(t_beicangjiereward) do
		if v.rank_range and v.rank_range ~= '' then
			local rankCfg = split(v.rank_range,',');
			if rankNum >= toint(rankCfg[1]) and rankNum <= toint(rankCfg[2]) then
				rewardCfg = v;
				break
			end
		end
	end
	local severLevel = MainPlayerController:GetServerLvl();
	local rewardStr = RewardManager:Parse(rewardCfg['reward' .. severLevel]);
	objSwf.rewardList1.dataProvider:cleanUp();
	objSwf.rewardList2.dataProvider:cleanUp();
	--changer:houxudong  date:2016/7/30 18:59
	if self.obj.state == 1 then
		objSwf.btn_enter.visible = false--self.obj.result == 0;
		objSwf.btn_quit.visible = false--self.obj.result == 0;
		objSwf.btn_out.visible = true --self.obj.result ~= 0;
		if self.obj.result == 0 then    --此时跳出进入北仓殿，现在需要屏蔽掉
			-- objSwf.panel_next.txt1.htmlText = string.format(StrConfig['beicangjie010'],self.obj.num,rankNum);
			-- objSwf.panel_next.txt.htmlText = StrConfig['beicangjie011'];
			-- objSwf.rewardList1.dataProvider:push(unpack(rewardStr));
			objSwf.panel_end.txt.htmlText = string.format(StrConfig['beicangjie003'],self.obj.num,rankNum);
			objSwf.rewardList2.dataProvider:push(unpack(rewardStr));
		else
			objSwf.panel_end.txt.htmlText = string.format(StrConfig['beicangjie003'],self.obj.num,rankNum);
			objSwf.rewardList2.dataProvider:push(unpack(rewardStr));
		end
		
		-- objSwf.panel_next._visible = self.obj.result == 0;
		objSwf.panel_end._visible = true  -- self.obj.result ~= 0;
		
	else
		objSwf.btn_enter.visible = false;
		objSwf.btn_quit.visible = false;
		objSwf.btn_out.visible = true;
		objSwf.panel_defeat._visible = self.obj.result ~= 0;
		objSwf.panel_win._visible = false --self.obj.result == 0;
		if self.obj.result == 0 then
			objSwf.panel_win.txt.htmlText = string.format(StrConfig['beicangjie005'],500)
			rewardStr = RewardManager:Parse(t_beicangjiereward[1]['reward' .. severLevel]);
			objSwf.rewardList2.dataProvider:push(unpack(rewardStr));
		else
			objSwf.panel_defeat.txt.text = StrConfig['beicangjie006'];
		end
	end
	objSwf.rewardList1:invalidateData();
	objSwf.rewardList2:invalidateData();
	self:TimeChange();
end

function UIBeicangjieResult:OnHide()
	self.obj = {};
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end