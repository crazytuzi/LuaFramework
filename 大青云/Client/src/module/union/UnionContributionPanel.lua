--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionContributionPanel = BaseUI:new("UIUnionContributionPanel")
UIUnionContributionPanel.ResItemsController = nil

function UIUnionContributionPanel:Create()
	self:AddSWF("unionContributionPanel.swf", true, "top");
end

function UIUnionContributionPanel:OnLoaded(objSwf, name)
	for i=82, 86 do 
		objSwf['labUnion'..i].text = UIStrConfig['union'..i]
	end
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.input1.textChange = function() self:OnContributeChange(); end
	objSwf.input2.textChange = function() self:OnContributeChange(); end
	objSwf.input3.textChange = function() self:OnContributeChange(); end
	
	objSwf.btn1.click = function() 
		if toint(objSwf.input1.text) <=0 then return end 
		if toint(objSwf.input1.text) > BagModel:GetItemNumInBag(UnionConsts.QingtongTokenId) then FloatManager:AddSysNotice(2005032); return end--数量不足
		UnionController:ReqGuildContribute(UnionConsts.QingtongTokenId, toint(objSwf.input1.text)) 
	end
	objSwf.btn2.click = function() 
		if toint(objSwf.input2.text) <=0 then return end 
		if toint(objSwf.input2.text) > BagModel:GetItemNumInBag(UnionConsts.BaiyingTokenId) then FloatManager:AddSysNotice(2005032); return end--数量不足
		UnionController:ReqGuildContribute(UnionConsts.BaiyingTokenId, toint(objSwf.input2.text)) 
	end
	objSwf.btn3.click = function() 
		if toint(objSwf.input3.text) <=0 then return end 
		if toint(objSwf.input3.text) > BagModel:GetItemNumInBag(UnionConsts.HuangjinTokenId) then FloatManager:AddSysNotice(2005032); return end--数量不足
		UnionController:ReqGuildContribute(UnionConsts.HuangjinTokenId, toint(objSwf.input3.text)) 
	end
	objSwf.btn4.click = function() 
		local contriMoney = toint(UnionConsts.ContrbutionList[objSwf.ddList.selectedIndex+1])
		if toint(contriMoney) <=0 then return end 
		local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
		if toint(contriMoney) > moneyNum then FloatManager:AddSysNotice(2005032); return end--数量不足
		UnionController:ReqGuildContribute(UnionConsts.MoneyId, objSwf.ddList.selectedIndex+1) 

	end
	
	-- 资源列表
	self.ResItemsController = UnionResController:New(objSwf, true)
	
	objSwf.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(UnionConsts.ContrbutionList) do
		objSwf.ddList.dataProvider:push(vo);
	end
	objSwf.ddList.change = function(e) self:OnContributeChange(); end
	objSwf.ddList:invalidateData();
	objSwf.ddList.rowCount = 5;
	objSwf.ddList.selectedIndex = 0
	
	objSwf.labMyContributionAdd._visible = false
	objSwf.labUnionMoneyAdd._visible = false
	
	objSwf.btn1.rollOver = function(e) self:ShowTip(1); end
	objSwf.btn1.rollOut = function(e) self:HideTip(e); end
	objSwf.btn2.rollOver = function(e) self:ShowTip(2); end
	objSwf.btn2.rollOut = function(e) self:HideTip(e); end
	objSwf.btn3.rollOver = function(e) self:ShowTip(3); end
	objSwf.btn4.rollOut = function(e) self:HideTip(e); end
	objSwf.btn4.rollOver = function(e) self:ShowTip(4); end
	objSwf.btn4.rollOut = function(e) self:HideTip(e); end
end

function UIUnionContributionPanel:ShowTip(cType)
	self:CalculateAddValue(cType)
end

function UIUnionContributionPanel:HideTip(e)
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.labMyContributionAdd._visible = false
	objSwf.labUnionMoneyAdd._visible = false
end

function UIUnionContributionPanel:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	self:UpdateUnionResList()
	
	objSwf.labTip1.text = string.format(StrConfig['union26'], UnionConsts.QingtongTokenContribution)
	objSwf.labTip2.text = string.format(StrConfig['union27'], UnionConsts.BaiyingTokenContribution)
	objSwf.labTip3.text = string.format(StrConfig['union28'], UnionConsts.HuangjinTokenContribution)
	objSwf.labTip4.text = string.format(StrConfig['union29'], toint(UnionConsts.MoneyNeed/10000),toint(UnionConsts.MoneyUnionMoney/10000),UnionConsts.MoneyContribution)
	self:AutoInputNum()
end

function UIUnionContributionPanel:AutoInputNum()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local qingtongNum = BagModel:GetItemNumInBag(UnionConsts.QingtongTokenId)
	local baiyinNum = BagModel:GetItemNumInBag(UnionConsts.BaiyingTokenId)
	local huangjinNum = BagModel:GetItemNumInBag(UnionConsts.HuangjinTokenId)
	objSwf.input1.text = qingtongNum
	objSwf.input2.text = baiyinNum
	objSwf.input3.text = huangjinNum
	
	local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	if moneyNum >= toint(UnionConsts.ContrbutionList[5]) then
		objSwf.ddList.selectedIndex = 4
	elseif moneyNum >= toint(UnionConsts.ContrbutionList[4]) then
		objSwf.ddList.selectedIndex = 3
	elseif moneyNum >= toint(UnionConsts.ContrbutionList[3]) then
		objSwf.ddList.selectedIndex = 2
	elseif moneyNum >= toint(UnionConsts.ContrbutionList[2]) then
		objSwf.ddList.selectedIndex = 1
	else
		objSwf.ddList.selectedIndex = 0
	end
	
	if toint(objSwf.input1.text) <= 0 then objSwf.btn1.disabled = true else objSwf.btn1.disabled = false end
	if toint(objSwf.input2.text) <= 0 then objSwf.btn2.disabled = true else objSwf.btn2.disabled = false end
	if toint(objSwf.input3.text) <= 0 then objSwf.btn3.disabled = true else objSwf.btn3.disabled = false end
end

function UIUnionContributionPanel:GetPanelType()
	return 0;
end

function UIUnionContributionPanel:ESCHide()
	return true;
end
--消息处理
function UIUnionContributionPanel:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self:GetSWF("UIUnionContributionPanel")
	if not objSwf then return; end
	
	if name == NotifyConsts.StageClick then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.UpdateContribute then
		self:UpdateUnionResList()
	elseif name == NotifyConsts.BagItemNumChange then
		if UnionConsts.QingtongTokenId == body.id or UnionConsts.BaiyingTokenId == body.id or UnionConsts.HuangjinTokenId == body.id then
			self:UpdateUnionResList()
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:UpdateUnionResList()
		end
	end
end

-- 消息监听
function UIUnionContributionPanel:ListNotificationInterests()
	return {NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.UpdateContribute,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.PlayerAttrChange};
end

-- 更新帮派资源
function UIUnionContributionPanel:UpdateUnionResList()
	local objSwf = self.objSwf
	if not objSwf then return; end

	-- 帮派资源列表
	self.ResItemsController:UpdateUnionResList()
	
	objSwf.labUnionMoney.text = UnionModel.MyUnionInfo.captial
	objSwf.labMyContribution.text = UnionModel.MyUnionInfo.contribution
	
	self:AutoInputNum()
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------

function UIUnionContributionPanel:OnContributeChange()
	local objSwf = self:GetSWF("UIUnionContributionPanel")
	if not objSwf then return; end

	local qingtongNum = BagModel:GetItemNumInBag(UnionConsts.QingtongTokenId)
	local baiyinNum = BagModel:GetItemNumInBag(UnionConsts.BaiyingTokenId)
	local huangjinNum = BagModel:GetItemNumInBag(UnionConsts.HuangjinTokenId)
	local moneyNum = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	objSwf.input1.text = _G.strtrim(objSwf.input1.text)
	objSwf.input2.text = _G.strtrim(objSwf.input2.text)
	objSwf.input3.text = _G.strtrim(objSwf.input3.text)
	if objSwf.input1.text == "" or toint(objSwf.input1.text) == nil then objSwf.input1.text = "0" end
	if objSwf.input2.text == "" or toint(objSwf.input2.text) == nil then objSwf.input2.text = "0" end
	if objSwf.input3.text == "" or toint(objSwf.input3.text) == nil then objSwf.input3.text = "0" end
	
	if toint(objSwf.input1.text) > qingtongNum then objSwf.input1.text = qingtongNum end
	if toint(objSwf.input2.text) > baiyinNum then objSwf.input2.text = baiyinNum end
	if toint(objSwf.input3.text) > huangjinNum then objSwf.input3.text = huangjinNum end
	
	if toint(objSwf.input1.text) <= 0 then 
		objSwf.btn1.disabled = true 
		objSwf.btn1:clearEffect();
	else 
		objSwf.btn1.disabled = false
		objSwf.btn1:showEffect(ResUtil:GetButtonEffect7());
	end
	if toint(objSwf.input2.text) <= 0 then 
		objSwf.btn2.disabled = true
		objSwf.btn2:clearEffect();
	else
		objSwf.btn2.disabled = false
		objSwf.btn2:showEffect(ResUtil:GetButtonEffect7());
	end
	if toint(objSwf.input3.text) <= 0 then 
		objSwf.btn3.disabled = true 
		objSwf.btn3:clearEffect();
	else 
		objSwf.btn3.disabled = false 
		objSwf.btn3:showEffect(ResUtil:GetButtonEffect7());
	end
	
	local contriMoney = toint(UnionConsts.ContrbutionList[objSwf.ddList.selectedIndex+1])
	local moneyRate = contriMoney/UnionConsts.MoneyNeed
	
	local contributeAdd = UnionConsts.QingtongTokenContribution*toint(objSwf.input1.text) + 
							UnionConsts.BaiyingTokenContribution*toint(objSwf.input2.text) + 
							UnionConsts.HuangjinTokenContribution*toint(objSwf.input3.text) + 
							toint(UnionConsts.MoneyContribution*moneyRate)
	
	local moneyAdd = toint(UnionConsts.MoneyUnionMoney*moneyRate)
	
	objSwf.labMyContributionAdd.text = '+'..contributeAdd
	objSwf.labUnionMoneyAdd.text = '+'..moneyAdd
end
function UIUnionContributionPanel:CalculateAddValue(cType)
	local objSwf = self.objSwf
	if not objSwf then return; end

	local contributeAdd = 0
	local moneyAdd = 0
	local contriMoney = toint(UnionConsts.ContrbutionList[objSwf.ddList.selectedIndex+1])
	local moneyRate = contriMoney/UnionConsts.MoneyNeed
	
	if cType == 1 then
		contributeAdd = UnionConsts.QingtongTokenContribution*toint(objSwf.input1.text)
	elseif cType == 2 then
		contributeAdd = UnionConsts.BaiyingTokenContribution*toint(objSwf.input2.text)
	elseif cType == 3 then
		contributeAdd = UnionConsts.HuangjinTokenContribution*toint(objSwf.input3.text)
	elseif cType == 4 then
		contributeAdd = toint(UnionConsts.MoneyContribution*moneyRate)
		moneyAdd = toint(UnionConsts.MoneyUnionMoney*moneyRate)
	end

	objSwf.labMyContributionAdd.text = '+'..contributeAdd
	objSwf.labUnionMoneyAdd.text = '+'..moneyAdd
	
	if contributeAdd and contributeAdd > 0 then
		objSwf.labMyContributionAdd._visible = true
	end
	
	if moneyAdd and moneyAdd > 0 then
		objSwf.labUnionMoneyAdd._visible = true
	end
end

--输入文本失去焦点
function UIUnionContributionPanel:OnIpSearchFocusOut()
	local objSwf = self:GetSWF("UIUnionContributionPanel");
	if not objSwf then return; end
	
	for i = 1, 4 do
		if objSwf['input'..i] and objSwf['input'..i].focused then
			objSwf['input'..i].focused = false;
		end
	end
end


function UIUnionContributionPanel:OnDelete()	
	if self.UnionResController then
		self.UnionResController:OnDelete()
		self.UnionResController = nil
	end
end
function UIUnionContributionPanel:IsShowSound()
	return true;
end

function UIUnionContributionPanel:IsShowLoading()
	return true;
end