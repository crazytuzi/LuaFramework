--[[
37wan
wangshuai 
]]

_G.UI37WanPhone = BaseUI:new("UI37WanPhone");

function UI37WanPhone:Create()
	self:AddSWF("yunying37WanPhonePanel.swf",true,"center")
end;

function UI37WanPhone:OnLoaded(objSwf)
	RewardManager:RegisterListTips( objSwf.itemlist );
	objSwf.closebtn.click = function() self:Hide()end;
	objSwf.bindPhone.click = function() self:OnGoBindPhone()end;
end;

function UI37WanPhone:OnShow()
	self:ShowRewardlist();
end;

function UI37WanPhone:OnGoBindPhone()
	Version:L37wanBindPhone()
end;

function UI37WanPhone:UpdataUI()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRewardlist();
	UIMainYunYingFunc:DrawLayout();
end;

function UI37WanPhone:OnHide()
	
end;

function UI37WanPhone:ShowRewardlist()
	local objSWf = self.objSwf;
	local serverDay = MainPlayerController:GetServerOpenDay();
	if serverDay == 0 then
		serverDay = 1;
	end;
	local datavo = t_consts[166];
	if not datavo then 
		print("ERROR: serverDay is error",serverDay)
		objSWf.itemlist.dataProvider:cleanUp();
		objSWf.itemlist.dataProvider:push({});
		objSWf.itemlist:invalidateData();
		return 
	end;
	local rewardStrList = RewardManager:Parse(datavo.param);
	objSWf.itemlist.dataProvider:cleanUp();
	objSWf.itemlist.dataProvider:push(unpack(rewardStrList));
	objSWf.itemlist:invalidateData();
end;

-- 是否缓动
function UI37WanPhone:IsTween()
	return true;
end

--面板类型
function UI37WanPhone:GetPanelType()
	return 1;
end
--是否播放开启音效
function UI37WanPhone:IsShowSound()
	return true;
end

function UI37WanPhone:IsShowLoading()
	return true;
end


