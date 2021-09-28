require "Core.Module.Common.Panel"
require "Core.Module.Common.StarItem"

AchievemenRewardPanel = class("AchievemenRewardPanel", Panel);

local autoCloseTime = 5
function AchievemenRewardPanel:New()
	self = {};
	setmetatable(self, {__index = AchievemenRewardPanel});
	return self
end

function AchievemenRewardPanel:GetUIOpenSoundName()
	return ""
end


function AchievemenRewardPanel:IsPopup()
	return false;
end

function AchievemenRewardPanel:IsFixDepth()
	return true;
end

function AchievemenRewardPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._time = autoCloseTime
end

function AchievemenRewardPanel:_InitReference()
	
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtCount1 = UIUtil.GetChildInComponents(txts, "txtNum1")
	self._txtCount2 = UIUtil.GetChildInComponents(txts, "txtNum2")
	self._imgIcon1 = UIUtil.GetChildByName(self._trsContent, "UISprite", "icon1")
	self._imgIcon2 = UIUtil.GetChildByName(self._trsContent, "UISprite", "icon2")
	
	self._txtName = UIUtil.GetChildInComponents(txts, "name")
	self._btnGetReward = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGetReward")
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx1")
	self._phalanx = Phalanx:New()
	self._phalanx:Init(self._phalanxInfo, StarItem)
	self._timer = Timer.New(function() AchievemenRewardPanel._OnTimerHandler(self) end, 1, - 1, false);
end

function AchievemenRewardPanel:_InitListener()
	self._onClickBtnGetReward = function(go) self:_OnClickBtnGetReward(self) end
	UIUtil.GetComponent(self._btnGetReward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetReward);
end

function AchievemenRewardPanel:_OnClickBtnGetReward()
	MainUIProxy.SendGetAchievementReward(self.data.id)
	ModuleManager.SendNotification(MainUINotes.CLOSE_ACHIEVEMENTREWARD)
end

function AchievemenRewardPanel:_Dispose()
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
	self:_DisposeListener();
	self:_DisposeReference();
	
end

function AchievemenRewardPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnGetReward, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGetReward = nil;
end

function AchievemenRewardPanel:_DisposeReference()
	
end

function AchievemenRewardPanel:UpdatePanel(data)
	self.data = data
	self._timer:Stop()
	self._time = autoCloseTime
	self._timer:Start()
	if(data) then
		local count = 1
		for k, v in pairs(self.data.rewards) do
			local item = ProductManager.GetProductById(v.id)
			self["_txtCount" .. count].text = tostring(v.num)
			ProductManager.SetIconSprite(self["_imgIcon" .. count], item.icon_id)
			-- if(v.id == SpecialProductId.Money) then
			-- 	self._txtLingshi.text = tostring(v.num)
			-- elseif(v.id == SpecialProductId.BGold) then
			-- 	self._txtXianyu.text = tostring(v.num)
			-- end
			count = count + 1
		end
		
		local star = {}
		local curStar = self.data.star
		for i = 1, self.data.max_star do
			if(i <= curStar) then
				star[i] = true
			else
				star[i] = false
			end
		end
		self._phalanx:Build(1, self.data.max_star, star)
		self._txtName.text = self.data.name
	end
end

function AchievemenRewardPanel:_OnTimerHandler()
	self._time = self._time - 1
	
	if(self._time == 0) then
		self._timer:Stop()
		ModuleManager.SendNotification(MainUINotes.CLOSE_ACHIEVEMENTREWARD)
		
		-- self:SetActive(false)
	end
end 