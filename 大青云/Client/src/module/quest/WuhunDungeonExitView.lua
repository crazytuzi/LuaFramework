--[[
打蛋副本退出确定UI
lizhuangzhuang
2015年8月29日17:23:153
]]

_G.UIWuhunDungeonExit = BaseUI:new("UIWuhunDungeonExit");

UIWuhunDungeonExit.TweenScale = 10;

function UIWuhunDungeonExit:Create()
	self:AddSWF("wuhunDungeonExit.swf",true,"center");
end

function UIWuhunDungeonExit:OnLoaded(objSwf)
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.btnConfirm.label = StrConfig['quest705'];
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function() TipsManager:Hide(); end
end

function UIWuhunDungeonExit:IsTween()
	return true;
end

function UIWuhunDungeonExit:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIWuhunDungeonExit:DoTweenHide()
	self:DoHide();
end

function UIWuhunDungeonExit:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

local viewPort = nil;
function UIWuhunDungeonExit:OnShow()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfTime.htmlText = string.format(StrConfig["quest914"],10);
	self.autoTimerKey = TimerManager:RegisterTimer(function(count)
		if count == 10 then
			self.autoTimerKey = nil;
			self:OnBtnConfirmClick();
		else
			if not self.objSwf then return; end
			objSwf.tfTime.htmlText = string.format(StrConfig["quest915"],10-count);
		end
	end,1000,10);

	-- 奖励
	local currentMapId = CPlayerMap:GetCurMapID()
	local index = 0;
	if currentMapId == QuestConsts.WuhunDungeonMap then
		index = 1;
	elseif currentMapId == QuestConsts.WuhunDungeonMapTwo then
		index = 2;
	elseif currentMapId == QuestConsts.WuhunDungeonMapThree then
		index = 3;
	elseif currentMapId == QuestConsts.WuhunDungeonMapFour then
		index = 4;
	elseif currentMapId == QuestConsts.WuhunDungeonMapFive then
		index = 5;
	end
	local rewardCfg = t_questdungeon[index];
	if rewardCfg then
		objSwf.rewardList.dataProvider:cleanUp();
		local rewardList = RewardManager:Parse(rewardCfg['equipId']);
		objSwf.rewardList.dataProvider:push(unpack(rewardList));
		objSwf.rewardList:invalidateData();
	end
	self:ResetEquipDraw();	
	if not self.objUIDraw then
		if not viewPort then
		   viewPort = _Vector2.new(400, 300); 
		end
		self.objUIDraw = UISceneDraw:new( "UITrunkDungeonInfoModelTwo", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);

	local model_tips = nil;
	local cfg = t_questdungeon[index]
	if not cfg then return; end
	-- 模型
	model_tips = cfg.sen
	-- 描述
	if not cfg.describe then return; end
	objSwf.tfAttr.htmlText = cfg.describe
	-- 战斗力
	objSwf.numFight.num = toint(cfg.fight);
	self.objUIDraw:SetScene( model_tips );
	self.objUIDraw:SetDraw( true );
end

function UIWuhunDungeonExit:ResetEquipDraw()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end

function UIWuhunDungeonExit:OnHide()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

-- 卸载面板时删除场景
function UIWuhunDungeonExit:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIWuhunDungeonExit:OnBtnConfirmClick()
	QuestController:ExitWuhunDungeon();
	QuestController:ExitWuhunDungeonTwo();
	QuestController:ExitWuhunDungeonThree();
	QuestController:ExitWuhunDungeonFour();
	QuestController:ExitWuhunDungeonFive();
end
