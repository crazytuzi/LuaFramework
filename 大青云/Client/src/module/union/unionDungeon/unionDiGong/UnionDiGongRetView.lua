--[[地宫争夺结果界面
zhangshuhui
]]

_G.UIUnionDiGongRetView = BaseUI:new("UIUnionDiGongRetView")

function UIUnionDiGongRetView:Create()
	self:AddSWF("unionDiGongRetPanel.swf", true, "center")
end

function UIUnionDiGongRetView:OnLoaded(objSwf,name)
	objSwf.btnok.click   = function() self:OnBtnOkClick() end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	
	RewardManager:RegisterListTips(objSwf.unionawardList);
	RewardManager:RegisterListTips(objSwf.personawardList);
end

function UIUnionDiGongRetView:OnShow()
	self:ShowInfo();
	self:InitData();
	self:ShowDaoJiShi();
	self:StartTimer();
end

function UIUnionDiGongRetView:OnHide()
	self:DelTimerKey();
end

function UIUnionDiGongRetView:InitData()
	self.curTime = 10;
end

function UIUnionDiGongRetView:OpenPanel()
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIUnionDiGongRetView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.sucpanel._visible = false;
	objSwf.failpanel._visible = false;
	--if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		local severLevel = MainPlayerController:GetServerLvl();
		--自己帮派获胜
		if UnionDiGongModel:GetWinUnionId() == UnionModel.MyUnionInfo.guildId then
			objSwf.sucpanel._visible = true;
			
			--帮派奖励
			local unionrewardList = RewardManager:Parse(enAttrType.eaBindGold..","..t_digongguildreward[severLevel].winReward1,"102"..","..t_digongguildreward[severLevel].winReward2);
			objSwf.unionawardList.dataProvider:cleanUp();
			objSwf.unionawardList.dataProvider:push(unpack(unionrewardList));
			objSwf.unionawardList:invalidateData();
			
			--个人奖励
			local playerInfo = MainPlayerModel.humanDetailInfo;
			local personrewardList = RewardManager:Parse(t_digongreward[playerInfo.eaLevel].reward1);
			objSwf.personawardList.dataProvider:cleanUp();
			objSwf.personawardList.dataProvider:push(unpack(personrewardList));
			objSwf.personawardList:invalidateData();
		--失败
		else
			objSwf.failpanel._visible = true;
			
			--帮派奖励
			local unionrewardList = RewardManager:Parse(enAttrType.eaBindGold..","..t_digongguildreward[severLevel].lostReward1,"102"..","..t_digongguildreward[severLevel].lostReward2);
			objSwf.unionawardList.dataProvider:cleanUp();
			objSwf.unionawardList.dataProvider:push(unpack(unionrewardList));
			objSwf.unionawardList:invalidateData();
			
			--个人奖励
			local playerInfo = MainPlayerModel.humanDetailInfo;
			local personrewardList = RewardManager:Parse(t_digongreward[playerInfo.eaLevel].reward2);
			objSwf.personawardList.dataProvider:cleanUp();
			objSwf.personawardList.dataProvider:push(unpack(personrewardList));
			objSwf.personawardList:invalidateData();
		end
	--end
end

function UIUnionDiGongRetView:OnBtnOkClick()
	self:Hide();
	UnionDiGongController:ReqQuitGuildDiGong(UnionDiGongController.curId);
end

function UIUnionDiGongRetView:OnBtnCloseClick()
	self:Hide();
	UnionDiGongController:ReqQuitGuildDiGong(UnionDiGongController.curId);
end


function UIUnionDiGongRetView:ShowDaoJiShi()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local t,s,m  = self:GetTime(self.curTime);
	objSwf.tftime.htmlText = string.format( StrConfig["unionDiGong010"],"00:"..s..":"..m);
end

function UIUnionDiGongRetView:GetTime(time)
	if not time then return end;
	if time <= 0 then return "00","00","00" end;
	local ti = time / 60 -- 分
	local tim = (ti % 1)*60 + 0.1
	local m = toint(tim)
	if m < 10 then 
		m = "0"..m
	end;
	local s = toint(ti)
	local t = 0;
	if s >= 60 then 
		t = toint(s/60);
		s = s%60;
	end;

	if s < 10 then 
		s = "0"..s
	end;

	if t < 10 then 
		t = "0"..t;
	end;

	return t,s,m
end;

function UIUnionDiGongRetView:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function UIUnionDiGongRetView:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UIUnionDiGongRetView:OnTimer()
	UIUnionDiGongRetView.curTime = UIUnionDiGongRetView.curTime - 1;
	UIUnionDiGongRetView:ShowDaoJiShi();
	
	if UIUnionDiGongRetView.curTime <= 0 then
		UIUnionDiGongRetView:Hide();
		UnionDiGongController:ReqQuitGuildDiGong(UnionDiGongController.curId);
		UIUnionDiGongRetView:DelTimerKey();
	end
end;