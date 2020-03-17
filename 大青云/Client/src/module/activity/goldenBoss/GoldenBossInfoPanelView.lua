--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/7/14
    Time: 15:29
   ]]

_G.UIGoldenBossInfoPanel = BaseUI:new("UIGoldenBossInfoPanel");
UIGoldenBossInfoPanel.leftTimerKey = nil;
function UIGoldenBossInfoPanel:Create()
	self:AddSWF("goldenBossInfoPanel.swf", false, "center")
end

function UIGoldenBossInfoPanel:OnLoaded(objSwf, name)
end


function UIGoldenBossInfoPanel:InitView(objSwf)
	-- 界面加载完成后的
	objSwf.btnHide.click = function() self:OnBtnHideClick(); end
	objSwf.btnShow.click = function() self:OnBtnShowClick(); end
	objSwf.contentLayer.btnAutoGuaJi.click = function() self:OnBtnAutoGuaJiClick(); end
	objSwf.contentLayer.btnQuit.click = function() self:OnBtnQuitClick(); end
	objSwf.contentLayer.moneyLoader.num = 0;

	objSwf.contentLayer.txtDeadTip.htmlText = StrConfig["goldenboss02"];
	objSwf.contentLayer.hpProg.trackWidthGap = 20;

	self:UpdateHp(ActivityGoldenBoss.curBossHp);
	self:ShowLeftTime();
end

function UIGoldenBossInfoPanel:OnShow()
	self:InitView(self.objSwf);
	self:OnBtnShowClick();
end

function UIGoldenBossInfoPanel:ShowLeftTime()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	local sec = activity:GetEndLastTime();
	self.objSwf.contentLayer.leftTimeTxt.text = string.format("%02d:%02d:%02d", CTimeFormat:sec2format(sec));
	TimerManager:UnRegisterTimer(self.leftTimerKey)
	self.leftTimerKey = TimerManager:RegisterTimer(function(curTimes)
		if curTimes < sec then
			self.objSwf.contentLayer.leftTimeTxt.text = string.format("%02d:%02d:%02d", CTimeFormat:sec2format(sec - curTimes));
		end
	end, 1000, sec);
end

function UIGoldenBossInfoPanel:UpdateHp(curHP)
	local maxHP = 0;
	local goldBossCFG = t_goldboss[ActivityModel.worldLevel];
	if goldBossCFG then
		local monsterCFG = t_monster[goldBossCFG.bossID];
		if monsterCFG then
			maxHP = monsterCFG.hp;
		end
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local contentLayer = objSwf.contentLayer;
	if curHP <= 0 then
		contentLayer.txtDeadTip._visible = true;
		contentLayer.txtHpTip._visible = false;
		contentLayer.hpProg.maximum = maxHP;
		contentLayer.hpProg.minimum = 0;
		contentLayer.hpProg.value = 0;
		contentLayer.txtHp.text = "0%";
	else
		contentLayer.txtDeadTip._visible = false;
		contentLayer.txtHpTip._visible = true;
		contentLayer.hpProg.maximum = maxHP;
		contentLayer.hpProg.minimum = 0;
		contentLayer.hpProg.value = curHP;
		contentLayer.txtHp.text = toint((curHP / maxHP) * 100) .. "%";
	end
end

function UIGoldenBossInfoPanel:OnBtnAutoGuaJiClick()
	local mapId = CPlayerMap:GetCurMapID();
	local posAStr = GoldenBossUtil:GetAreaAGuaJiPosition(mapId);
	if not posAStr then return; end
	local tA = split(posAStr, ",");
	local autoBattleFunc = function() AutoBattleController:SetAutoHang(); end

	--A区域挂机点不能走就走向B区域挂机点
	if not MainPlayerController:DoAutoRun(toint(tA[1]), _Vector3.new(toint(tA[2]), toint(tA[3]), 0), autoBattleFunc) then
		local posBStr = GoldenBossUtil:GetAreaBGuaJiPosition(mapId);
		if not posBStr then return; end
		local tB = split(posBStr, ",");
		MainPlayerController:DoAutoRun(toint(tB[1]), _Vector3.new(toint(tB[2]), toint(tB[3]), 0), autoBattleFunc)
	end
end

function UIGoldenBossInfoPanel:OnBtnQuitClick()
	local func = function()
		local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
		if not activity then return; end
		if activity:GetType() ~= ActivityConsts.T_GoldenBoss then return; end
		ActivityController:QuitActivity(activity:GetId());
	end
	UIConfirm:Open(StrConfig['goldenboss01'], func);
end

function UIGoldenBossInfoPanel:OnBtnHideClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.contentLayer._visible = false;
	objSwf.btnHide._visible = false;
	objSwf.btnShow._visible = true;
end

function UIGoldenBossInfoPanel:OnBtnShowClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.contentLayer._visible = true;
	objSwf.btnHide._visible = true;
	objSwf.btnShow._visible = false;
end

function UIGoldenBossInfoPanel:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.GoldenBossGotReward then
		local currentDrop = body.currentDrop;
		local totalDrop = body.totalDrop;
		--更新获得收益的面板显示
		self.objSwf.contentLayer.moneyLoader:scrollToNum(totalDrop, 0.5);
	end
	if name == NotifyConsts.GoldenBossUpdateBoss then
		self:UpdateHp(body.hp);
	end
	if name == NotifyConsts.GoldenBossOnScene then
		self:OnBtnAutoGuaJiClick()
		self:UpdateHp(ActivityGoldenBoss.curBossHp);
	end
end

function UIGoldenBossInfoPanel:ListNotificationInterests()
	return { NotifyConsts.GoldenBossGotReward, NotifyConsts.GoldenBossUpdateBoss, NotifyConsts.GoldenBossOnScene }
end


function UIGoldenBossInfoPanel:OnHide()
	TimerManager:UnRegisterTimer(self.leftTimerKey)
	self.leftTimerKey = nil
end

--人物面板中详细信息为隐藏面板，不计算到总宽度内
function UIGoldenBossInfoPanel:GetWidth()
	return 260;
end

function UIGoldenBossInfoPanel:GetHeight()
	return 411;
end

function UIGoldenBossInfoPanel:IsTween()
	return false;
end

function UIGoldenBossInfoPanel:GetPanelType()
	return 0;
end