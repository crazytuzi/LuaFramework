--[[
主线副本信息面板
author：houxudong
date:2016年9月5日 11:02:05
--]]
_G.UITrunkDungeonInfo = BaseUI:new("UITrunkDungeonInfo");
UITrunkDungeonInfo.TweenScale = 20;
UITrunkDungeonInfo.autoTimerKey = nil;
UITrunkDungeonInfo.questId = nil;

function UITrunkDungeonInfo:Create()
	self:AddSWF("trunkDungeonInfoPanel.swf", true, "center");
end

function UITrunkDungeonInfo:OnLoaded( objSwf )
	objSwf.btnEnter.click = function() self:OnEnterClick(); end
	objSwf.btnEnter.label = StrConfig['quest1004'];
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function() TipsManager:Hide(); end
end

function UITrunkDungeonInfo:OnShow()
	self:StartTime()
	self:DrawEquipModel()
end


local viewPort = nil;
function UITrunkDungeonInfo:DrawEquipModel( )
	-- self:ResetEquipDraw();	
	if not self.objUIDraw then
		if not viewPort then
		   viewPort = _Vector2.new(400, 300); 
		end
		self.objUIDraw = UISceneDraw:new( "UITrunkDungeonInfoModel", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);

	local dungeonIndex = TrunkDungeonUtil:GetTrunkDungeonNum(self.questId)
	if dungeonIndex == 0 then return; end
	local model_tips = nil;
	local cfg = t_questdungeon[dungeonIndex]
	if not cfg then return; end
	-- 模型
	model_tips = cfg.sen
	-- title
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.titleDes.source = ResUtil:GetTruckDungeonTitle(cfg.title);
	-- 描述
	objSwf.tfAttr.htmlText = cfg.describe
	-- 战斗力
	objSwf.numFight.num = toint(cfg.fight);
	self.objUIDraw:SetScene( model_tips );
	self.objUIDraw:SetDraw( true );
	-- 奖励
	local currentMapId = CPlayerMap:GetCurMapID()
	local rewardCfg = t_questdungeon[dungeonIndex];
	if rewardCfg then
		objSwf.rewardList.dataProvider:cleanUp();
		local rewardList = RewardManager:Parse(rewardCfg['equipId']);
		objSwf.rewardList.dataProvider:push(unpack(rewardList));
		objSwf.rewardList:invalidateData();
	end
end

function UITrunkDungeonInfo:ResetEquipDraw()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end

function UITrunkDungeonInfo:StartTime()
	local autoTime = 10;
	local count = 0;
	self:ShowLeaveTime(autoTime,count)
	self:StopTime()
	self.autoTimerKey = TimerManager:RegisterTimer(function()
			count = count + 1;
			if count > autoTime then
				count = 10;
				self:StopTime();
				if self:IsShow() then
					self:Hide();
				end
			end
			if count == autoTime then
				self:ConfirmEnter()
			else
				self:ShowLeaveTime(autoTime,count)
			end
	end,1000,autoTime);
end

function UITrunkDungeonInfo:StopTime()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
end

function UITrunkDungeonInfo:ShowLeaveTime(time,count)
	local objSwf = self.objSwf
	if not objSwf then return; end
	local levelTime = time-count;
	if levelTime <= 0 then
		levelTime = 0;
	end
	objSwf.txtTime.htmlText = string.format(StrConfig["npcDialog0007"],levelTime);
end

function UITrunkDungeonInfo:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UITrunkDungeonInfo:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

function UITrunkDungeonInfo:Open(confirmFunc,questId)
	self.confirmFunc = confirmFunc;
	self.questId = questId;
	if self:IsShow() then
	 	--刷新内容
		self:OnShow();  
	else
		--打开UI
		self:Show();    
	end
end

function UITrunkDungeonInfo:OnEnterClick()
	self:ConfirmEnter();
	self:StopTime();
end

function UITrunkDungeonInfo:ConfirmEnter( )
	self.confirmFunc()
	self:Hide()
end

function UITrunkDungeonInfo:GetWidth()
	return 828;
end

function UITrunkDungeonInfo:GetHeight()
	return 289;
end

function UITrunkDungeonInfo:IsTween()
	return true;
end

function UITrunkDungeonInfo:OnHide(name)
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(self.objUIDraw)
		self.objUIDraw = nil
	end
	self.confirmFunc = nil;
	self.questId = nil;
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
end