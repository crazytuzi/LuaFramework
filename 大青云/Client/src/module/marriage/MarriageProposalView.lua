--[[
求婚界面
wangshuai
]]

_G.UIMarryProposal = BaseUI:new("UIMarryProposal")
UIMarryProposal.curRingId = 0;
UIMarryProposal.curRoleId = nil;
UIMarryProposal.curRoleName = nil;
UIMarryProposal.WorldLengthLimit = 48

function UIMarryProposal:Create()
	self:AddSWF("marryProposalPanel.swf",true,"center")
end;

function UIMarryProposal:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.ddNameList.change= function (e) self:OnNameChange(e);end;
	objSwf.ddNameList.rowCount = 10;

	objSwf.ringbtn.click = function() self:RingClick()end;
	objSwf.ringbtn.rollOver = function() self:OnRingOver() end;
	objSwf.ringbtn.rollOut  = function() TipsManager:Hide() end;
	RewardManager:RegisterListTips( objSwf.ringBag.itemlist );

	objSwf.ringBag.itemlist.itemClick = function(e) self:ItemListClick(e) end;
	objSwf.inputtxt.textChange = function()
		local name = objSwf.inputtxt.text
		if string.len(name) > UIMarryProposal.WorldLengthLimit then
			objSwf.inputtxt.text = string.sub( name, 1, UIMarryProposal.WorldLengthLimit )
		end
	end
	objSwf.okBtn.click = function() self:SendClick()end;
end;

-- 显示前的判断，每个show方法第一步
function UIMarryProposal:ShowJudge(roleId)
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level < MarriageConsts.MarryLevel then
		FloatManager:AddNormal(StrConfig["marriage085"]);
		return;
	end
	local state = MarriageModel:GetMyMarryState();
	if state == MarriageConsts.marryReserve or state == MarriageConsts.marryMarried then 
		if state == MarriageConsts.marryReserve then 
			FloatManager:AddNormal( StrConfig['marriage079']);
			return 
		end;
		FloatManager:AddNormal( StrConfig['marriage019']);
		return 
	end;
	self.curRoleId = roleId;
	self:Show();
end;

function UIMarryProposal:OnShow()
	FriendController:ReqRelationChangeList();
	self:InitPanel();
	self:SetBenameList();
end;

function UIMarryProposal:OnHide()
	self.curRoleId = nil;
	self.curRoleName = nil;
	self.curRingId = 0;

	if self.erjiPanel then 
		UIConfirm:Close(self.erjiPanel)
	end;
end;

function UIMarryProposal:SendClick()
	if not self.curRoleId then
		FloatManager:AddNormal(StrConfig["marriage050"]);
		return;
	end
	local txt = self.objSwf.inputtxt.text or "";
	if self.curRingId <= 0 then
		FloatManager:AddNormal(StrConfig["marriage051"]);
		return;
	end
	local cfg = t_marryRing[self.curRingId];
	if not cfg then return end;
	local ringNum = BagModel:GetItemNumInBag(cfg.itemId);
	if ringNum <= 0 then 
		FloatManager:AddNormal( StrConfig['marriage018']); 
		return 
	end;
	local itemCfg = t_item[cfg.itemId]
	local func = function() 
		if not self.curRoleId then return; end
		MarriagController:ReqProposal(self.curRoleId,self.objSwf.inputtxt.text,self.curRingId)
	end;
	self.erjiPanel = UIConfirm:Open( string.format(StrConfig['marriage044'],itemCfg.name,self.curRoleName),func);
end;

function UIMarryProposal:InitPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.ringBag._visible = false;
	objSwf.ringItem:setData({});

end;

function  UIMarryProposal:ItemListClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local index = e.index + 1;
	local cfg = t_marryRing[index]

	local num = BagModel:GetItemNumInBag(cfg.itemId);
	if num <= 0 then 

		FloatManager:AddNormal( StrConfig['marriage018']);
		return 
	end;

	self.curRingId = index;
	
	local itemvo = RewardSlotVO:new()
	itemvo.id = cfg.itemId
	itemvo.count = 0
	objSwf.ringItem:setData(itemvo:GetUIData());
	objSwf.ringBag._visible = false;
end;


function UIMarryProposal:OnRingOver()
	if not self.curRingId or self.curRingId == 0 then 
		return 
	end;
	local cfg = t_marryRing[self.curRingId]
	if not cfg then return end;

	TipsManager:ShowItemTips(cfg.itemId);

end;

function UIMarryProposal:RingClick()
	local objSwf = self.objSwf;
	--print("没有进来人吗？")
	if not objSwf then return end;
	objSwf.ringBag._visible = true;
	local list = t_marryRing;
	--trace(t_marryRing)
	for i,info in ipairs(list) do 
		local itemvo = RewardSlotVO:new()
		itemvo.id = info.itemId
		itemvo.count = BagModel:GetItemNumInBag(info.itemId)
		objSwf.ringBag["item" .. i]:setData(itemvo:GetUIData());
	end;
end;

UIMarryProposal.curRoleList = {};

function UIMarryProposal:SetBenameList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local prof = MainPlayerModel.humanDetailInfo.eaProf;
	local myInfo = t_playerinfo[prof]

	objSwf.ddNameList.dataProvider:cleanUp();

	local friendList = FriendModel:GetListByRType(FriendConsts.RType_Friend);
	self.curRoleList = {};
	for i,info in ipairs(friendList) do 
		local beInfo = t_playerinfo[info:GetIconId()];
		if beInfo and beInfo.sex ~= myInfo.sex then  --玩家为异性
			if info.onlineState ==  1 then --玩家在线
				objSwf.ddNameList.dataProvider:push(info.roleName)
				table.push(self.curRoleList,info)
			end;
		end;
	end;
	for i,info in ipairs(self.curRoleList) do
		if info:GetRoleId() == self.curRoleId then
			objSwf.ddNameList.selectedIndex = i-1;
			return;
		end
	end
	objSwf.ddNameList.selectedIndex = 0;
	if #self.curRoleList > 0 then 
		self.curRoleId = self.curRoleList[1]:GetRoleId();
		self.curRoleName = self.curRoleList[1]:GetRoleName();
	end;
end;	

function UIMarryProposal:OnNameChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local index = e.index;
	if #self.curRoleList > 0 then 
		self.curRoleId = self.curRoleList[index + 1]:GetRoleId();
		self.curRoleName = self.curRoleList[index + 1]:GetRoleName();
	end;
end;




-- 是否缓动
function UIMarryProposal:IsTween()
	return true;
end

--面板类型
function UIMarryProposal:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryProposal:IsShowSound()
	return true;
end

function UIMarryProposal:IsShowLoading()
	return true;
end


	-- notifaction
function UIMarryProposal:ListNotificationInterests()
	return {
		NotifyConsts.FriendChange,
		}
end;
function UIMarryProposal:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.FriendChange then
		self:SetBenameList();
	end;
end;

