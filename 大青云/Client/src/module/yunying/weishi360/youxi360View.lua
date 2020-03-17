--[[
游戏大厅
wangshuai 
]]

_G.UIyouxi360 = BaseUI:new("UIyouxi360");

function UIyouxi360:Create()
	self:AddSWF("youxi360Reward.swf",true,"center")
end;

function UIyouxi360:OnLoaded(objSwf)
	RewardManager:RegisterListTips( objSwf.itemlist );
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.noreward_mc.noreward_btn.click = function() self:OnNoReward()end;
	objSwf.okreward_mc.getreward_btn.click = function() self:OnOkReward()end;

end;

function UIyouxi360:OnShow()
	self:ShowPanel()
	self:ShowRewardlist();
	self:UpdataBtnState();
	self:SetDayText();
end;

function UIyouxi360:UpdataUI()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowPanel();
	self:ShowRewardlist();
	self:UpdataBtnState();
	self:SetDayText();
	UIMainYunYingFunc:DrawLayout();
end;

function UIyouxi360:OnHide()
	
end;

function UIyouxi360:SetDayText()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = Weishi360Model:GetRewardList();
	objSwf.day_txt.htmlText = string.format(StrConfig["yunying017"],num)
end;

function UIyouxi360:UpdataBtnState()
	local state = Weishi360Model:GetCurDatState(); 
	-- true 是未领取
	local objSwf = self.objSwf;
	objSwf.okreward_mc.getreward_btn.disabled = not state;
	objSwf.okreward_mc.effectgetreward._visible = state;
end;

function UIyouxi360:OnNoReward()
	Version:Download360Game()
end;

function UIyouxi360:OnOkReward()
	-- local num = math.random(10)
	-- Weishi360Model:SetCurLvlState(num)
	-- print(num,"---------------")
	-- local flag = Weishi360Model:GetCurLvlState();
	-- for i=1,31 do
	-- 	local v = bit.rshift(bit.lshift(flag,32-i-1),31);
	-- 	print(i,v)
	-- end

	WeishiController:ReqGetReward(2,0)
end;

function UIyouxi360:ShowPanel()
	local objSwf = self.objSwf;
	local is360 = Version:Is360Game();
	--print("是否是在360游戏大厅：",is360)
	if not is360 then 
		objSwf.noreward_mc._visible = true;
		objSwf.okreward_mc._visible = false;
	else
		objSwf.noreward_mc._visible = false;
		objSwf.okreward_mc._visible = true;
	end;
	local isget = Weishi360Model:GetCurDatState() --true今天未领取
	if isget then 
		
	end;
end;

function UIyouxi360:ShowRewardlist()
	local objSWf = self.objSwf;
	local serverDay = MainPlayerController:GetServerOpenDay();
	if serverDay == 0 then
		serverDay = 1;
	end;
	local datavo = t_youxidating[serverDay];
	if not datavo then 
		print("ERROR: serverDay is error",serverDay)
		objSWf.itemlist.dataProvider:cleanUp();
		objSWf.itemlist.dataProvider:push({});
		objSWf.itemlist:invalidateData();
		return 
	end;
	local rewardStrList = RewardManager:Parse(datavo.reward);
	objSWf.itemlist.dataProvider:cleanUp();
	objSWf.itemlist.dataProvider:push(unpack(rewardStrList));
	objSWf.itemlist:invalidateData();
end;

-- 是否缓动
function UIyouxi360:IsTween()
	return true;
end

--面板类型
function UIyouxi360:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIyouxi360:IsShowSound()
	return true;
end

function UIyouxi360:IsShowLoading()
	return true;
end


