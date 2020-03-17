--[[地宫争夺追踪界面
zhangshuhui
]]

_G.UIUnionDiGongZhuiZongView = BaseUI:new("UIUnionDiGongZhuiZongView")
UIUnionDiGongZhuiZongView.curTime = 0;
function UIUnionDiGongZhuiZongView:Create()
	self:AddSWF("unionDiGongZhuiZongPanel.swf", true, "center")
	self:AddChild(UIUnionDiGongMap,"unionmap")
end

function UIUnionDiGongZhuiZongView:OnLoaded(objSwf,name)
	self:GetChild("unionmap"):SetContainer(objSwf.childPanel)
	objSwf.btnExit.click   = function() self:OnBtnCloseClick() end
	objSwf.mapBtn.click = function() self:MapShowBtn() end;
	
	objSwf.btnZhuZi1.click   = function() self:OnBtnZhuZi1Click() end
	objSwf.btnZhuZi2.click   = function() self:OnBtnZhuZi2Click() end
	objSwf.btnGetFlag.click   = function() self:OnBtnGetFlagClick() end

	objSwf.tffalgifno.text   = StrConfig["unionDiGong020"];
	objSwf.btndigongflag.htmlLabel = StrConfig["unionDiGong021"];
	objSwf.rule.rollOver = function() self:OnRuleOver()end;
	objSwf.rule.rollOut  = function() TipsManager:Hide()end;
	objSwf.btndigongflag.rollOver = function() TipsManager:ShowBtnTips(StrConfig["unionDiGong022"],TipsConsts.Dir_RightDown) end;
	objSwf.btndigongflag.rollOut  = function() TipsManager:Hide()end;
end

function UIUnionDiGongZhuiZongView:GetWidth()
	return 369;
end

function UIUnionDiGongZhuiZongView:GetHeight()
	return 413;
end

function UIUnionDiGongZhuiZongView:OnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	TipsManager:ShowBtnTips(StrConfig["unionwar237"],TipsConsts.Dir_RightDown)
end;


function UIUnionDiGongZhuiZongView:MapShowBtn()
	local objSwf = self.objSwf;
	if UIUnionDiGongMap:IsShow() then
		objSwf.childPanel._visible = not objSwf.childPanel._visible;
		objSwf.childPanel.hitTestDisable = not objSwf.childPanel._visible;
	else
		self:ShowMap();
	end;
end;

function UIUnionDiGongZhuiZongView:OnBtnZhuZi1Click()
	local vo = t_guilddigong[UnionDiGongController.curId];
	if not vo then
		return;
	end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun( vo.mapId, _Vector3.new(-265,162,0), completeFuc );
end

function UIUnionDiGongZhuiZongView:OnBtnZhuZi2Click()
	local vo = t_guilddigong[UnionDiGongController.curId];
	if not vo then
		return;
	end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun( vo.mapId, _Vector3.new(263,-200,0), completeFuc );
end

function UIUnionDiGongZhuiZongView:OnBtnGetFlagClick()
	UnionDiGongModel:SetIsGoGetFlag(true);
	self:DoAutoRun();
end

function UIUnionDiGongZhuiZongView:DoAutoRun()
	if not self.bShowState then return; end
	if not UnionDiGongModel:GetIsGoGetFlag() then
		return;
	end
	local vo = t_guilddigong[UnionDiGongController.curId];
	if not vo then
		return;
	end
	--判断距离范围
	local myplay = MainPlayerController:GetPos();
	local cinfox,cinfoy = UnionDiGongModel:GetFlagPos();
	local dx = myplay.x - cinfox;
	local dy = myplay.y - cinfoy;
	local dist = math.sqrt(dx*dx+dy*dy);
	if dist <= 20 then
		local curUnionName,curRoleName = UnionDiGongModel:GetCurFlagInfo();
		if curUnionName ~= "" then
			AutoBattleController:OpenAutoBattle();
		else
			DiGongFlagController:DoCollect();
		end
		UnionDiGongModel:SetIsGoGetFlag(false);
	end
	local posX, posY = UnionDiGongModel:GetFlagPos();
	CPlayerControl:AutoRun(_Vector3.new(posX, posY,0), {func = function() end})
end
	
-- 面板 附带资源
function UIUnionDiGongZhuiZongView:WithRes()
	  return { "UnionDiGongWarMapPanel.swf" };
end;

function UIUnionDiGongZhuiZongView:ShowMap()	
	local child = self:GetChild("unionmap");
	if not child then return end;
	self:ShowChild("unionmap")
end;
function UIUnionDiGongZhuiZongView:HideMap()
	if UIUnionDiGongMap:IsShow() then 
		UIUnionDiGongMap:Hide();
	end;
end;

function UIUnionDiGongZhuiZongView:OnShow()
	self:ShowMap();
	self:ShowInfo();
	self:InitData();
	self:ShowDaoJiShi();
	self:StartTimer();
end

function UIUnionDiGongZhuiZongView:OnHide()
	self:DelTimerKey();
end

function UIUnionDiGongZhuiZongView:InitData()
	self.curTime = UnionDiGongModel:GetDiGongTime();
	UnionDiGongModel:SetIsGoGetFlag(false);
end

function UIUnionDiGongZhuiZongView:OpenPanel(fengyaoid)
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIUnionDiGongZhuiZongView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--帮派积分
	objSwf.tfUnionName1.text = "";
	objSwf.tfUnionScore1.text = "";
	objSwf.tfUnionName2.text = "";
	objSwf.tfUnionScore2.text = "";
	--扛旗信息
	objSwf.tfUnionName.text = "";
	objSwf.tfRoleName.text = "";
	--柱子
	objSwf.btnZhuZi1.htmlLabel = "";
	objSwf.btnZhuZi2.htmlLabel = "";
	objSwf.tfbuff1.text = "";
	objSwf.tfbuff2.text = "";
	
	
	--帮派积分
	local list = UnionDiGongModel:GetDiGongUnionList();
	local listvo = list[UnionDiGongController.curId];
	if not listvo then
		return;
	end
	local unionscorelist = UnionDiGongModel:GetUnionInfo();
	if not unionscorelist then
		return;
	end
	
	objSwf.tfUnionName1.text = listvo.UnionName1;
	local nScore1 = -1;
	if unionscorelist[listvo.unionid1] and unionscorelist[listvo.unionid1].score then
		nScore1 = unionscorelist[listvo.unionid1].score;
		objSwf.tfUnionScore1.text = unionscorelist[listvo.unionid1].score;
	end
	local nScore2 = -1;
	if unionscorelist[listvo.unionid2] and unionscorelist[listvo.unionid2].score then
		nScore2 = unionscorelist[listvo.unionid2].score;
		if nScore2 > -1 then
			objSwf.tfUnionName2.text = listvo.UnionName2;
			objSwf.tfUnionScore2.text = unionscorelist[listvo.unionid2].score;
		end
	end
	if nScore2 > -1 and  nScore1 < nScore2 then
		objSwf.tfUnionName1.text = listvo.UnionName2;
		if unionscorelist[listvo.unionid2] and unionscorelist[listvo.unionid2].score then
			objSwf.tfUnionScore1.text = unionscorelist[listvo.unionid2].score;
		end
		objSwf.tfUnionName2.text = listvo.UnionName1;
		if unionscorelist[listvo.unionid1] and unionscorelist[listvo.unionid1].score then
			objSwf.tfUnionScore2.text = unionscorelist[listvo.unionid1].score;
		end
	end
	--扛旗信息
	local curUnionName,curRoleName = UnionDiGongModel:GetCurFlagInfo();
	objSwf.tfUnionName.text = curUnionName;
	objSwf.tfRoleName.text = curRoleName;
	--柱子
	objSwf.btnZhuZi1.htmlLabel = string.format( StrConfig["unionDiGong002"],"遗迹守护(左)");
	objSwf.btnZhuZi2.htmlLabel = string.format( StrConfig["unionDiGong002"],"遗迹守护(右)");
	objSwf.btnZhuZi1.rollOver = function()
									TipsManager:ShowBtnTips("占领遗迹守护可获得攻击+5%，防御+5%，生命+5%属性加成");
								end
	objSwf.btnZhuZi1.rollOut = function() TipsManager:Hide(); end
	objSwf.btnZhuZi2.rollOver = function ()
									TipsManager:ShowBtnTips("占领遗迹守护可获得攻击+5%，防御+5%，生命+5%属性加成");
								end
	objSwf.btnZhuZi2.rollOut = function() TipsManager:Hide(); end
	objSwf.tfbuff1.text = UnionDiGongUtils:GetZhuZiUnionName(1);
	objSwf.tfbuff2.text = UnionDiGongUtils:GetZhuZiUnionName(2);
end

function UIUnionDiGongZhuiZongView:ShowDaoJiShi()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local t,s,m  = self:GetTime(self.curTime);
	objSwf.tftime.htmlText = string.format( StrConfig["unionDiGong009"],s..":"..m);
end

function UIUnionDiGongZhuiZongView:GetTime(time)
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

function UIUnionDiGongZhuiZongView:OnBtnCloseClick()
	local okfun = function() 
		self:Hide();
		UnionDiGongController:ReqQuitGuildDiGong(UnionDiGongController.curId); 
	end;
	UIConfirm:Open(string.format(StrConfig["unionDiGong016"]),okfun)
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIUnionDiGongZhuiZongView:ListNotificationInterests()
	return {
		NotifyConsts.UnionDiGongWarUpdate,
	};
end

--处理消息
function UIUnionDiGongZhuiZongView:HandleNotification(name, body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.UnionDiGongWarUpdate then
		self:ShowInfo();
	end
end

function UIUnionDiGongZhuiZongView:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function UIUnionDiGongZhuiZongView:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UIUnionDiGongZhuiZongView:OnTimer()
	UIUnionDiGongZhuiZongView.curTime = UIUnionDiGongZhuiZongView.curTime - 1;
	UIUnionDiGongZhuiZongView:ShowDaoJiShi();
	
	if UIUnionDiGongZhuiZongView.curTime <= 0 then
		UIUnionDiGongZhuiZongView:DelTimerKey();
	end
end;