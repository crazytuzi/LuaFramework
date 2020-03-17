--[[
帮派副本-地宫炼狱场景界面
2015年1月9日14:32:36
haohu
]]

_G.UIUnionHellScene = BaseUI:new("UIUnionHellScene");

UIUnionHellScene.stratumId = nil;

function UIUnionHellScene:Create()
	self:AddSWF("unionHellScenePanel.swf", true, "center");
end

function UIUnionHellScene:OnLoaded( objSwf )
	local panel = objSwf.panel;
	panel.labName.text    = StrConfig['unionhell034'];
	panel.labTime.text    = StrConfig['unionhell035'];
	panel.labReward.text  = StrConfig['unionhell045'];
	panel.btnName.click   = function() self:OnBtnNameClick(); end
	panel.btnQuit.click   = function() self:OnBtnQuitClick(); end
	RewardManager:RegisterListTips( panel.list );
	objSwf.btnTitle.click = function() self:OnBtnTitleClick(); end
end

function UIUnionHellScene:OnShow()
	self:InitShow();
	self:StartTimer();
	UIAutoBattleTip:Open(function()UIUnionHellScene:OnBtnNameClick()end,true);
end

function UIUnionHellScene:InitShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local stratum = self.stratumId;
	local cfg = t_guildHell[stratum];
	if not cfg then return; end
	local monsterId   = cfg.bossid;
	local monsterCfg  = t_monster[monsterId];
	local monsterName = monsterCfg.name;
	local stratumTxt  = UnionDungeonHellUtils:GetStratumTxt( stratum );
	local vo = UnionDungeonHellModel:GetStratum( stratum );
	local attrWeakTotal = math.min( vo.numPass * cfg.reduceAtt, cfg.maxReduceAtt );
	local panel = objSwf.panel;
	panel.btnName.htmlLabel   = string.format( StrConfig['unionhell036'], stratumTxt, monsterName );
	panel.txtNumPass.htmlText = string.format( StrConfig['unionhell044'], vo.numPass );
	panel.txtWeaken.htmlText  = string.format( StrConfig['unionhell037'], attrWeakTotal );
	local list = panel.list;
	list.dataProvider:cleanUp();
	local rewardList = UnionDungeonHellUtils:GetRewardProvider(stratum);
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
	local itemList = {};
			itemList[1] = objSwf.panel.item1;
			itemList[2] = objSwf.panel.item2;
			itemList[3] = objSwf.panel.item3;
			itemList[4] = objSwf.panel.item4;
			UIDisplayUtil:HCenterLayout(#rewardList, itemList, 64, 100, 187);
			itemList = nil;		
end

function UIUnionHellScene:OnHide()
	self:StopTimer();
	if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	end
	self:CancelQuitConfirm()
end

function UIUnionHellScene:OnBtnNameClick()
	self:RunToFight()
end

function UIUnionHellScene:RunToFight()
	local stratum = self.stratumId;
	if not stratum then return end
	local cfg = t_guildHell[stratum];
	if not cfg then return; end
	local posVO = QuestUtil:GetQuestPos(cfg.pos_id); --{x,y,mapId,range};
	if not posVO then return end
	MainPlayerController:DoAutoRun( posVO.mapId, _Vector3.new( posVO.x, posVO.y, 0 ), function()
		AutoBattleController:SetAutoHang();
	end );
end

function UIUnionHellScene:OnBtnQuitClick()
	local content = StrConfig['unionhell038'];
	local confirmFunc = function()
		UnionDungeonHellController:Quit()
	end
	self.quitConfirm = UIConfirm:Open( content, confirmFunc );
end

function UIUnionHellScene:CancelQuitConfirm()
	if self.quitConfirm then
		UIConfirm:Close( self.quitConfirm )
		self.quitConfirm = nil
	end
end

function UIUnionHellScene:OnBtnTitleClick()
	local objSwf = self.objSwf;
	local panel = objSwf and objSwf.panel;
	if not panel then return; end
	panel.visible = not panel.visible;
end

local timerKey = nil;
local limitTime;
function UIUnionHellScene:StartTimer()
	local cb = function(count)
		self:OnTimer(count);
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	local panel = objSwf and objSwf.panel;
	if not panel then return; end
	limitTime = UnionDungeonHellUtils:GetLimitTime( self.stratumId );
	panel.txtTime.text = SitUtils:ParseTime( limitTime );
end

function UIUnionHellScene:OnTimer(count)
	local timeRest = limitTime - count;
	if timeRest == 0 then
		self:OnTimeUp();
	end
	local objSwf = self.objSwf;
	local panel = objSwf and objSwf.panel;
	if not panel then return; end
	panel.txtTime.text = SitUtils:ParseTime( timeRest );
end

function UIUnionHellScene:OnTimeUp()
	self:StopTimer();
	local objSwf = self.objSwf;
	local panel = objSwf and objSwf.panel;
	if not panel then return; end
	panel.txtTime.text = "";
end

function UIUnionHellScene:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey);
		timerKey = nil;
	end
end

---------------------------------------------------
-- @param id:层级id
-- @param bossWeaken:boss攻防减少
function UIUnionHellScene:Open( id )
	self.stratumId = id;
	if self:IsShow() then
		self:InitShow();
	else
		self:Show();
	end
end

--改变挂机按钮文本
function UIUnionHellScene:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state then
		if UIAutoBattleTip:IsShow() then
			UIAutoBattleTip:Hide();
		end
	else
		UIAutoBattleTip:Open( function() self:RunToFight() end );
	end
end

function UIUnionHellScene:HandleNotification(name,body)
	if name == NotifyConsts.AutoHangStateChange then
		-- self:OnChangeAutoText(body.state);
	end
end
function UIUnionHellScene:ListNotificationInterests()
	return {
		NotifyConsts.AutoHangStateChange,
	}
end
