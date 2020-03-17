--[[
	2015年7月6日, PM 02:55:56
	wangyanwei
	成就完成tips
]]
_G.UIAchievementTip = BaseUI:new('UIAchievementTip');

function UIAchievementTip:Create()
	self:AddSWF('achievementTipPanel.swf',true,'bottom');
end

function UIAchievementTip:OnLoaded(objSwf)
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_getReward.click = function () self:OnGetRewardClick(); end
	
	
	objSwf.effect_title:stopEffect();
	objSwf.icon_title._visible = false;
end

function UIAchievementTip:OnShow()
	self._achievementIndex = self._achievementIndex or 10001;
	self:OnChangeTxt();
	self:OnDrawRewardList();
	self:OnHideTime();
end

--UI开启播放effect
function UIAchievementTip:playEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect_title:playEffect(1);
	objSwf.effect_title.complete = function () 
		objSwf.icon_title._visible = true;
	end
end

--关闭倒计时
function UIAchievementTip:OnHideTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local func = function ()
		Tween:To(objSwf,2,{_alpha = 0},{
		onComplete = function ()
			self:Hide();
		end
		})
	end
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,5000);
end

--文本
function UIAchievementTip:OnChangeTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local achievement = t_achievement[self._achievementIndex];
	objSwf.txt_achievement.htmlText = string.format(StrConfig['Achievement100'],achievement.name);
end

--绘制奖励
function UIAchievementTip:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local achievement = t_achievement[self._achievementIndex];
	local rewardData = achievement.reward;
	local rewardList = RewardManager:Parse(rewardData);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
end

function UIAchievementTip:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList:invalidateData();
	objSwf.txt_achievement.text = '';
	objSwf.effect_title:stopEffect();
	objSwf.icon_title._visible = false;
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

UIAchievementTip._achievementIndex = nil;
function UIAchievementTip:Open(_achievementIndex)
	local cfg = t_achievement[_achievementIndex];
	if not cfg then return end
	self._achievementIndex = _achievementIndex;
	if self:IsShow() then 
		self:OnShow();
	else
		self:Show();
	end
end

function UIAchievementTip:IsTween()
	return true;
end

--UI开启缓动，
UIAchievementTip.TweenScale = 100;
function UIAchievementTip:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX ;
	local startY = endY + self:GetHeight() - self:GetHeight()*self.TweenScale/100/2;
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = 100;
	objSwf._yscale = 100;
	
	Tween:To(self.objSwf,1,{_alpha = 100,_y = endY},{onComplete = callback})
end

function UIAchievementTip:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIAchievementTip:OnFullShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:playEffect();
end

function UIAchievementTip:OnGetRewardClick()
	FuncManager:OpenFunc(FuncConsts.Achievement,false,self._achievementIndex);
	self:Hide();
end

function UIAchievementTip:GetWidth()
	return 391
end

function UIAchievementTip:GetHeight()
	return 108
end