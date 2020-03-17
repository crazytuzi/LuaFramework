--[[
礼包功能
sunsusu
2014年9月12日11:58:35
]]

_G.UIBagOpenGift = BaseUI:new("UIBagOpenGift");

UIBagOpenGift.itemId = nil;

function UIBagOpenGift:Create()
	self:AddSWF("bagOpenGiftView.swf", true, "top");
end

function UIBagOpenGift:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	RewardManager:RegisterListTips(objSwf.list);
end
--wqn增加的自动关闭倒计时，到此一游
local autoCloseTime = 10;


function UIBagOpenGift:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local itemCfg = t_item[self.itemId];
	if not itemCfg then return end;
	local color = TipsConsts:GetItemQualityColor(itemCfg.quality);
	local name = itemCfg.name;
	-- objSwf.txtTitle.htmlText = "<font color='"..color.."'>"..name.."</font>";
	objSwf.txtDes.htmlText = string.format( StrConfig["bag21"],  name, self.count ); 
	--显示礼包奖励
	local rewardList = RewardManager:Parse(self.rewardStr);
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	list.dataProvider:push( unpack(rewardList) );
	list:invalidateData();
	list:scrollToIndex(0);
	
	self.objSwf.timetext.htmlText = string.format(StrConfig["bag63"], autoCloseTime);
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
	end
	self.timerKey = TimerManager:RegisterTimer(function(curTimes)
		if self.objSwf then
			self.objSwf.timetext.htmlText = string.format(StrConfig["bag63"], autoCloseTime - curTimes);
		end
		if curTimes >= autoCloseTime then
			self:OnBtnCloseClick();
		end
	end,1000,autoCloseTime);
end

--点击关闭
function UIBagOpenGift:OnBtnCloseClick()
	self:Hide();
end

function UIBagOpenGift:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
	end
end

--点击下方按钮 
function UIBagOpenGift:OnBtnConfirmClick()
	self:Hide();
end
function UIBagOpenGift:GetPanelType()
	return 0;
end
function UIBagOpenGift:ESCHide()
	return true;
end
--打开面板
--@param itemId 礼包id
--@param rewardStr  礼包
function UIBagOpenGift:Open( itemId, rewardStr, count )
	self.itemId = itemId;
	self.rewardStr = rewardStr;
	self.count = count
	if self:IsShow() then
		self:OnShow()
	else
		self:Show();
	end
end



