--[[
首冲礼包
wangshuai
]]

_G.UIVplanNoviceBag = BaseUI:new("UIVplanNoviceBag")

function UIVplanNoviceBag:Create()
	self:AddSWF("VplanNoviceBag.swf",true,nil)
end;

function UIVplanNoviceBag:OnLoaded(objSwf)
	objSwf.receive.click = function() self:OnReceive()end;
	objSwf.GoVPrivilege.click = function() self:OnGoVprivilege() end;
	RewardManager:RegisterListTips(objSwf.rewardlist);
	RewardManager:RegisterListTips(objSwf.rewardlist2);
end;

function UIVplanNoviceBag:OnShow()	
	self:OnSetUIState();
	self:OnShowList();
end;

function UIVplanNoviceBag:OnSetUIState()
	local objSwf = self.objSwf;
	local isVip = VplanModel:GetIsVplan();
	local isGetReward = VplanModel:GetVGiftState()
	if isGetReward then 
		--objSwf.receive.textField.text = StrConfig["vplan204"]
		objSwf.receive.disabled = false;
		objSwf.receive_ling._visible = false;
	else
		--objSwf.receive.textField.text = StrConfig["vplan203"]
		objSwf.receive._visible = false;
		objSwf.receive_ling._visible = true;
	end;

	local isgetYaerGift = VplanModel:GetYearGiftState();
	if isgetYaerGift then -- 未领取
		objSwf.GoVPrivilege.disabled = false
		objSwf.GoVPrivilege_ling._visible = false;
	else -- 以领取
		objSwf.GoVPrivilege_ling._visible = true;
		objSwf.GoVPrivilege._visible = false
	end;
end;

function UIVplanNoviceBag:OnShowList()
	local objSwf = self.objSwf;
	local vipLvl = 1 --月费
	local cfg = t_vtype[vipLvl].reward;
	local rewardStrList = RewardManager:Parse(cfg);
	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(rewardStrList));
	objSwf.rewardlist:invalidateData();


	local vipyear = 2 --年费
	local cfgcc = t_vtype[vipyear].reward;
	local rewardStrListcc = RewardManager:Parse(cfgcc);
	objSwf.rewardlist2.dataProvider:cleanUp();
	objSwf.rewardlist2.dataProvider:push(unpack(rewardStrListcc));
	objSwf.rewardlist2:invalidateData();

end;

function UIVplanNoviceBag:OnReceive()
	VplanController:ReqVplanVGift()
end;

function UIVplanNoviceBag:OnGoVprivilege()
	local isgetYaerGift = VplanModel:GetYearGiftState();
	if isgetYaerGift then -- 未领取
		VplanController:ReqVplanYearGift()		
	end;
end;

function UIVplanNoviceBag:OnHide()

end;


function UIVplanNoviceBag:HandleNotification(name,body)
	if name==NotifyConsts.VFlagChange then
		self:OnSetUIState();
		self:OnShowList();
	end
end

function UIVplanNoviceBag:ListNotificationInterests()
	return {NotifyConsts.VFlagChange};
end