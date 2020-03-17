-- 运营活动领奖界面

_G.UIOperactivitesGetAward = BaseUI:new('UIOperactivitesGetAward');
function UIOperactivitesGetAward:Create()
	self:AddSWF('operactivitesGetAward.swf',true,"top");
end

function UIOperactivitesGetAward:OnLoaded(objSwf)
	objSwf.closeBtn.click = function() self:Hide() end
	objSwf.getBtn.click = function()
		UIOperactivitesAward:GetRewardClick() 
	 end
	-- objSwf.vipBtn.click = function() FuncManager:OpenFunc(63) end
	RewardManager:RegisterListTips( objSwf.rewardList )
end

function UIOperactivitesGetAward:OnShow()
	self.objSwf.rewardList.dataProvider:cleanUp()
	self.objSwf.rewardList.dataProvider:push(unpack(self.list))
	self.objSwf.rewardList:invalidateData()
end

function UIOperactivitesGetAward:OpenGetAward(item)
	self.list = {}
	for k,v in pairs(RewardSlotVO) do
		if type(v) == "function" then
			item[k] = v;
		end
	end
	self.item = item
	table.push(self.list,item:GetUIData());
	if not self:IsShow() then
		self:Show()
	else
		self:OnShow()
	end
end

function UIOperactivitesGetAward:ListNotificationInterests()
	return {
		NotifyConsts.UpdateOperActAwardState,
	}
end

function UIOperactivitesGetAward:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if body.isAward == 2 then
		local startPos = UIManager:PosLtoG(self.objSwf.item1,70,17);
		RewardManager:FlyIcon({self.item},startPos,5,true,60)
	end
	self:Hide()
end