--[[
求婚界面
wangshuai
]]

_G.UIMarryBeProposal = BaseUI:new("UIMarryBeProposal")

UIMarryBeProposal.data = nil;

function UIMarryBeProposal:Create()
	self:AddSWF("marryBeProposalPanel.swf",true,"center")
end;

function UIMarryBeProposal:OnLoaded(objSwf)

	objSwf.ringItem.rollOver = function() self:OnRingOver() end;
	objSwf.ringItem.rollOut  = function() TipsManager:Hide() end;


	objSwf.yesBtn.click = function() self:YesBtn()end;
	objSwf.noBtn.click = function() self:NoBtn()end;

	
end;

function UIMarryBeProposal:UpdataShow()
	self.data = MarriageModel.BeProposaledData;
	if not self.data then return end;
	if not self.data.name then return end;
	if not self.data.ringId then return end
	if not self:IsShow() then 
		self:Show();
	else
		self:OnShow();
	end;
end;

function UIMarryBeProposal:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end

	--trace(self.data)
	--print("哈哈哈哈哈。。。。。。")

	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	local itemvo = RewardSlotVO:new()
	itemvo.id = cfg.itemId
	itemvo.count = 0
	objSwf.ringItem:setData(itemvo:GetUIData());

	objSwf.loveText.text = self.data.loveText or "";
	objSwf.tfName.text = self.data.name;
end;

function UIMarryBeProposal:OnHide()
	self.data = nil;
end;	

function UIMarryBeProposal:YesBtn()
	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	MarriagController:ReqBeProposal(self.data.name,1,self.data.ringId)
	self:Hide();
end;

function UIMarryBeProposal:NoBtn()
	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	MarriagController:ReqBeProposal(self.data.name,0,self.data.ringId)
	self:Hide();
end;

function UIMarryBeProposal:OnRingOver()
	if not self.data or self.data.ringId == 0 then 
		return 
	end;
	local cfg = t_marryRing[self.data.ringId]
	if not cfg then return end;
	TipsManager:ShowItemTips(cfg.itemId);
end;

-- 是否缓动
function UIMarryBeProposal:IsTween()
	return true;
end

--面板类型
function UIMarryBeProposal:GetPanelType()
	return 0;
end
--是否播放开启音效
function UIMarryBeProposal:IsShowSound()
	return true;
end

function UIMarryBeProposal:IsShowLoading()
	return true;
end
