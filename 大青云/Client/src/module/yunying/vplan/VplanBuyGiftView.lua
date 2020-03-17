--[[
	2015年10月16日, PM 05:10:16
	wangyanwei
	消费礼包
]]

_G.UIVplanBuyGift = BaseUI:new('UIVplanBuyGift');

function UIVplanBuyGift:Create()
	self:AddSWF('vplanXiaofeipanel.swf',true,nil);
end

function UIVplanBuyGift:OnLoaded(objSwf)
	objSwf.list.handlerRewardClick = function (e) VplanController:ReqBuyGift(e.item.id); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
end

function UIVplanBuyGift:OnShow()
	VplanController:ReqBuyGift(0);
	self:ShowPanelDate();
end

function UIVplanBuyGift:ShowPanelDate()
	self:ShowTxt();
	self:ShowRewardList();
end

function UIVplanBuyGift:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIVplanBuyGift:ShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function ()
		-- local restTime = ;
		local day,hour,min,sec = CTimeFormat:sec2formatEx((VplanModel:GetBuyGiftRestTime() or 0) - GetServerTime());
		if (VplanModel:GetBuyGiftRestTime() or 0) >= 0 then
			if hour < 10 then hour = '0' .. hour ; end
			if min < 10 then min = '0' .. min ; end
			if sec < 10 then sec = '0' .. sec ; end
			objSwf.txt_time.htmlText = string.format(StrConfig['vplan12001'],day,hour,min,sec);
		else
			objSwf.txt_time.htmlText = string.format(StrConfig['vplan12001'],0,0,0,0)
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
	objSwf.txt_xh.htmlText = string.format(StrConfig['vplan12002'],VplanModel:GetBuyGiftXnum() or 0)
	objSwf.txt_1.htmlText = StrConfig['vplan12003'];
	objSwf.txt_2.htmlText = StrConfig['vplan12004'];
end

function UIVplanBuyGift:ShowRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp();
	local allData = self:GetAllData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();

end

function UIVplanBuyGift:GetAllData()
	local list = {};
	local vo;
	local giftList = VplanModel:GetBuyGiftListInfo();
	-------------
	if not giftList then
		giftList = {
			[1] = {
				['state'] = 0,
			},
			[2] = {
				['state'] = 1,
			},
			[3] = {
				['state'] = 2,
			},
			[4] = {
				['state'] = 0,
			},
			[5] = {
				['state'] = 1,
			},
		}
	end
	-------------
	local xhNum = VplanModel:GetBuyGiftXnum() or 0;
	for id , listVO in ipairs(t_vconsume) do
		vo = {};
		vo.id = listVO.id;
		if self:GetBuyGiftState(listVO.id) then
			vo.state = 2;
		else
			if xhNum >= listVO.need then
				if VplanModel:GetIsVplan() then
					vo.state = 1;
				else
					vo.state = 0;
				end
			else
				vo.state = 0;
			end
		end
		-- vo.state = giftList[id].state;
		vo.needNum = string.format(StrConfig['vplan12005'],listVO.need);
		local majorStr = UIData.encode(vo);
		local rewardList = RewardManager:Parse( listVO.reward );
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list;
end

function UIVplanBuyGift:GetBuyGiftState(id)
	local giftList = VplanModel:GetBuyGiftListInfo();
	if not giftList then return end
	for i , v in pairs(giftList) do
		if id == v.id then
			return true
		end
	end
	return false
end