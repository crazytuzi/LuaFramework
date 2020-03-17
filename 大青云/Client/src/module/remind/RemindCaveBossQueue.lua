--[[
	BOSS刷新提示
	2015年5月6日, PM 04:14:08
	wangyanwei
]]
_G.RemindCaveBossQueue = setmetatable({},{__index=RemindQueue});

function RemindCaveBossQueue:GetType()
	return RemindConsts.Type_CaveBoss;
end;

function RemindCaveBossQueue:GetLibraryLink()
	return "RemindCaveUpData";
end;

--是否显示
function RemindCaveBossQueue:GetIsShow()
	return self.isshow;
end

function RemindCaveBossQueue:GetPos()
	return 2;
end;

function RemindCaveBossQueue:GetShowIndex()
	return 32;
end;

function RemindCaveBossQueue:GetBtnWidth()
	return 282;
end

function RemindCaveBossQueue:GetBtnHeight()
	return 130;
end

--
function RemindCaveBossQueue:AddData(data)
	self.isshow = true;
	self:RefreshData();
end

--按钮初始化 
function RemindCaveBossQueue:OnBtnInit()
	if self.button then
		self.button.tf4.text = UIStrConfig['cave101'];
		self.button.tf5.text = UIStrConfig['cave102'];
		self.button.tf6.htmlText = UIStrConfig['cave103'];
		self.button.tf8.text = UIStrConfig['cave100'];
		self.button.btn_close.click = function () self:OnCloseClick(); end
		self.button.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
		self.button.rewardList.itemRollOut = function () TipsManager:Hide(); end
	end
end

function RemindCaveBossQueue:OnBtnShow()
	if not self.button then
		return 
	end
	local rewardList = RewardManager:Parse(UIXianYuanCave.RewardIconTable);
	self.button.rewardList.dataProvider:cleanUp();
	self.button.rewardList.dataProvider:push(unpack(rewardList));
	self.button.rewardList:invalidateData();
end

RemindCaveBossQueue.isshow = true;
function RemindCaveBossQueue:DoClick()
	-- UIXianYuanCave:Show();
	FuncManager:OpenFunc(FuncConsts.XianYuanCave);
	self.isshow = false;
	self:RefreshData();
end

function RemindCaveBossQueue:OnCloseClick()
	self.isshow = false;
	self:RefreshData();
end

function RemindCaveBossQueue:DoRollOver()
	-- if not UICaveBossTip:IsShow() then
		-- UICaveBossTip:Show();
	-- end
end
--鼠标移出处理
function RemindCaveBossQueue:DoRollOut()
	-- UICaveBossTip:Hide();
end