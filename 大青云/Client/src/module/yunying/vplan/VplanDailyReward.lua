--[[
	V每日奖励
	2015年5月12日, PM 05:32:53
	wangyanwei
]]

_G.UIVplanDailyReward = BaseUI:new('UIVplanDailyReward');

function UIVplanDailyReward:Create()
	self:AddSWF("vplanDailyRewardPanel.swf",true,nil);
end

function UIVplanDailyReward:OnLoaded(objSwf)
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
	objSwf.list.itemClick = function() self:ItemClick()end;
	----objSwf.btn_mon.click = function () self:OnGetDaliyReward(); end
	objSwf.btn_year.click = function () self:YearClick()end;
	--objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
	RewardManager:RegisterListTips(objSwf.rewardListasd);
end

function UIVplanDailyReward:OnShow()
	self:UpUIdata();
end

function UIVplanDailyReward:UpUIdata()
	self:ShowDaliyList();
	self:OnChangeBtnState();
end;

function UIVplanDailyReward:OnHide()
	
end

function UIVplanDailyReward:YearClick()
	local isVplan = VplanModel:GetIsVplan();
	if not isVplan then 
		FloatManager:AddNormal(StrConfig["vplan208"]);
	return 
	end
	VplanController:ReqVplanDayGift(2)
end;

function UIVplanDailyReward:ItemClick()
	local isVplan = VplanModel:GetIsVplan();
	if not isVplan then 
		FloatManager:AddNormal(StrConfig["vplan208"]);
		return 
	end
	VplanController:ReqVplanDayGift(1)
end;

function UIVplanDailyReward:OnGetDaliyReward()
	local isVplan = VplanModel:GetIsVplan();
	if not isVplan then return end
	VplanController:ReqVplanDayGift()
end

--按钮状态
function UIVplanDailyReward:OnChangeBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	--是否V月会员
	local isVplan = VplanModel:GetIsVplan();
	local isYVplan = VplanModel:GetYearVplan();
	-- 是否领取
	local isGetDaliy = VplanModel:GetDayYGiftState();
	--objSwf.btn_mon.disabled = false;
	if  isGetDaliy then 
		objSwf.btn_year._visible = true;
		objSwf.year_lingqu._visible = false;
	else
		objSwf.btn_year._visible = false;
		objSwf.year_lingqu._visible = true;
	end;
end

--list
function UIVplanDailyReward:ShowDaliyList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	local allData = self:AllPanelData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();

	local myVLvl = VplanModel:GetVPlanLevel()
	local cfg = t_vlevel[myVLvl];
	if not cfg then 
		cfg = t_vlevel[1];
	end;
	local rewalist =  RewardManager:Parse(cfg.yearreward);
	objSwf.rewardListasd.dataProvider:cleanUp();
	objSwf.rewardListasd.dataProvider:push( unpack(rewalist) );
	objSwf.rewardListasd:invalidateData();
end

function UIVplanDailyReward:AllPanelData()
	local list = {};
	local vo;
	local isGetDaliy = VplanModel:GetDayMGiftState();
	local listCfg = t_vlevel;
	for id , listVO in ipairs(listCfg) do
		vo = {};
		vo.id = id;
		local myVLvl = VplanModel:GetVPlanLevel()
		if id == myVLvl then 
			vo.btnstate = false;
			if isGetDaliy then 
				vo.lingqustate = false;
			else
				vo.lingqustate = true;
			end;
		else
			vo.btnstate = true;
		end;

		-- if item.leve1_mc.source ~= ResUtil:GetVUIIcon(info.lvl) then 
		-- 	item.leve1_mc.source = ResUtil:GetVUIIcon(info.lvl);
		-- end;
		vo.iconUrl = ResUtil:GetVUIIcon(listVO.level);
		local majorStr = UIData.encode(vo);
		local rewardList = RewardManager:Parse( listVO.dailyreward );
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list;
end

function UIVplanDailyReward:HandleNotification(name,body)
	if name == NotifyConsts.VFlagChange then
		self:OnChangeBtnState();
	end
end

function UIVplanDailyReward:ListNotificationInterests()
	return {
		NotifyConsts.VFlagChange,
	}
end