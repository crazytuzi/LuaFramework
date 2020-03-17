--[[
V计划 等级礼包
wangshuai
]]
_G.UIVplanLevelGift = BaseUI:new("UIVplanLevelGift")

UIVplanLevelGift.cuepage=0;
function UIVplanLevelGift:Create()
	self:AddSWF("VplanLevelGiftPanel.swf",true,nil)
end;

function UIVplanLevelGift:OnLoaded(objSwf)
	objSwf.btn_VplanOfficialWeb.click = function () VplanController:ToWebSite() end
	objSwf.scrollbar.scroll = function() self:OnVplanScrollBar() end;
	for i=1,5 do
		local item = objSwf["item"..i];
		item.btn.click = function() self:ItemClick(i) end;
		RewardManager:RegisterListTips(item.list);
	end
end;

function UIVplanLevelGift:OnShow()
	local objSwf = self.objSwf
	self:OnShowData()
	objSwf.scrollbar:setScrollProperties(5,0,#self.dataList-5);
	objSwf.scrollbar.trackScrollPageSize = 1;
	objSwf.scrollbar.position = 0;
	self.cuepage = 0;
end;

function UIVplanLevelGift:YearClick()
	
end;

function UIVplanLevelGift:OnShowData()
	local objSwf = self.objSwf;
	self.dataList = self:OnListData();
	if not self.dataList then self.dataList = {};end;
	self:OnShowList(self.cuepage);
	self:SetBtnState()
end;

function UIVplanLevelGift:SetBtnState()
	local objSwf = self.objSwf;
	local isVip = VplanModel:GetIsVplan()
	if isVip then 
	else
	end;

	local isOpen = true;
	for i,info in ipairs(self.dataList) do 
		if not info.receive then 
			isOpen = false;
		end;
	end;
end;

function UIVplanLevelGift:OnVplanScrollBar()
	local objSwf = self.objSwf;
	local value = objSwf.scrollbar.position;
	self.cuepage = value
	self:OnShowList(value);
end;

function UIVplanLevelGift:OnShowList(val)
	local listvo = {};
	for i=1,5 do 
		table.push(listvo,self.dataList[val+i])
	end;
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel -- 人物等级
	local objSwf = self.objSwf;
	for i,info in ipairs(listvo) do 
		local item = objSwf["item"..i];
		if item then 
			if mylvl >= info.lvl then 
				item.btn.disabled = false;
			else
				item.btn.disabled = true;
			end;
			if info.isReward then 
				item.lingqu._visible = true;
				item.btn._visible = false
			else
				item.lingqu._visible = false;
				item.btn._visible = true;
			end;
			local rewardList = RewardManager:Parse(info.reward);
			item.levelNum.htmlText = info.lvl .. "级";
			item.list.dataProvider:cleanUp();
			item.list.dataProvider:push(unpack(rewardList));
			item.list:invalidateData();
		end;
	end;

end;

function UIVplanLevelGift:OnListData()
	local objSwf = self.objSwf
	local cfg = t_vlvlreward;
	local serCfg = VplanModel:GetLevelGift()
	if not serCfg then serCfg = {}; end;
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel -- 人物等级
	local listvo = {};
	for i,info in ipairs(cfg) do
		local id = serCfg[info.id]
		local vo = {};
		vo.id = info.id;
		vo.reward = info.levelreward;
		vo.lvl    = info.level;
		--vo.lvlnum = info.level .. "d"
		if id then -- 领取过了
			vo.isReward = true;
			vo.receive = true;
		else -- 没有领取过
			vo.isReward = false;
			vo.receive = false;
		end;
		--print(mylvl,vo.lvl)
		if mylvl < vo.lvl then 
			vo.receive = true;
		end;
		local isVip = VplanModel:GetIsVplan()
		if not isVip then 
			vo.receive = true;
		end;
		table.push(listvo,vo)
	end;
	return listvo
end;

function UIVplanLevelGift:OnGiveMeReward()
	if VplanModel:GetIsVplan() then -- 已开通，一件领取 
		self:AutoGiveMeReward()
	else
		VplanController:ToYRecharge()
	end;
end;

function UIVplanLevelGift:AutoGiveMeReward()
	local cfg = t_vlvlreward;
	local serCfg = VplanModel:GetLevelGift()
	if not serCfg then serCfg = {};end;
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel -- 人物等级
	local listvo = {};
	for i,info in ipairs(cfg) do
		local id = serCfg[info.id]
		if id then -- 领取过了
		else -- 没有领取过
			local vo = {}
			if info.level > mylvl then 
				break;
			end;
			vo.id = info.id;
			table.push(listvo,vo)
		end;
	end;
	VplanController:ReqVplanLevelGift(listvo)
end;

function UIVplanLevelGift:OnScrollBar()

end

function UIVplanLevelGift:ItemClick(i)
	
	local list = {};
	local vo = {};
	local page = self.cuepage+i;
	local cfg = t_vlvlreward[page];
	if not cfg then return end;
	vo.id = cfg.id;
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if cfg.level > playerLevel then 
		FloatManager:AddNormal(StrConfig["yunying016"]);
		return 
	end;
	table.push(list,vo)
	VplanController:ReqVplanLevelGift(list)
end;

function UIVplanLevelGift:OnHide()

end;	


function UIVplanLevelGift:HandleNotification(name,body)
	if name==NotifyConsts.VFlagChange then
		self:OnShowData();
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then 
			self:OnShowData()
		end;
	end
end

function UIVplanLevelGift:ListNotificationInterests()
	return {NotifyConsts.VFlagChange,
			NotifyConsts.PlayerAttrChange
			};
end