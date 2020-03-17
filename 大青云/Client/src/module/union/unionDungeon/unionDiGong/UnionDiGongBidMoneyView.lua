--[[帮主竞标界面
zhangshuhui
]]

_G.UIUnionDiGongBidMoneyView = BaseUI:new("UIUnionDiGongBidMoneyView")

UIUnionDiGongBidMoneyView.curid = 0;
UIUnionDiGongBidMoneyView.rate = 10000

function UIUnionDiGongBidMoneyView:Create()
	self:AddSWF("unionDiGongBidMoneyPanel.swf", true, "center")
end

function UIUnionDiGongBidMoneyView:OnLoaded(objSwf,name)
	objSwf.btnClose.click   = function() self:OnBtnCloseClick() end
	objSwf.BtnAdd.click = function() self:OnBtnAddClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.inputMoney.textChange = function() self:InputMoneyChange()end;
	objSwf.inputMoney.restrict = "0-9"
end

function UIUnionDiGongBidMoneyView:OnShow()
	self:ShowInfo();
	self:SetJIngbiao();
	self:SetJIngbiaoDijia();
end

function UIUnionDiGongBidMoneyView:OpenPanel(curid)
	self.curid = curid;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIUnionDiGongBidMoneyView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self:Top();
end

function UIUnionDiGongBidMoneyView:OnBtnAddClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local dimon = t_guilddigong[self.curid];
	local curMoney = tonumber(objSwf.inputMoney.text);
	local curMoney = tonumber(objSwf.inputMoney.text);
	if not curMoney then
		curMoney = 0;
	end
	objSwf.inputMoney.text = toint((curMoney * self.rate + dimon.bidprice) / 10000);
end

function UIUnionDiGongBidMoneyView:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:Hide();
	
	--如果非帮主 非副帮主
	if not UnionModel:IsLeader() and not UnionModel:IsDutySubLeader() then
		FloatManager:AddNormal( StrConfig["unionDiGong013"], objSwf.btnConfirm);
		return;
	end
	
	--objSwf.inputMoney.text
	local curMoney = tonumber(objSwf.inputMoney.text);
	
	local unionMoney = UnionModel:GetMyUnionMoney();
	if not curMoney then return end;

	curMoney = curMoney * self.rate;	
	
	--帮派资金不足
	if curMoney - UnionDiGongUtils:GetBiddedMoney(self.curid) > unionMoney then
		FloatManager:AddNormal( StrConfig["unionDiGong015"], objSwf.btnConfirm);
		return;
	end
	
	--竞标资金少于第二名
	if curMoney < UnionDiGongUtils:GetCanBidMoney(self.curid) then
		FloatManager:AddNormal( StrConfig["unionDiGong019"], objSwf.btnConfirm);
		return;
	end
	
	--如果该帮派在其他活动有竞标前2名
	if UnionDiGongUtils:GetIsOtherBidMoney(self.curid) == true then
		FloatManager:AddNormal( StrConfig["unionDiGong006"], objSwf.btnConfirm);
		return;
	end

	UnionDiGongController:ReqUnionDiGongBid(self.curid, curMoney);
end

function UIUnionDiGongBidMoneyView:OnBtnCloseClick()
	self:Hide();
end

function UIUnionDiGongBidMoneyView:SetJIngbiao()
	local objSwf = self.objSwf;
	if not objSwf then return end;


	local price = UnionDiGongUtils:GetUnionBidMoney(self.curid);
	objSwf.inputMoney.text = toint(price / 10000);

	local unionMoney = UnionModel:GetMyUnionMoney();
	objSwf.curunionMoney.htmlText = toint(unionMoney / self.rate , -1) .. "万"
end;

function UIUnionDiGongBidMoneyView:SetJIngbiaoDijia()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local dimon = t_guilddigong[self.curid];
	objSwf.dijia.htmlText = "竞标底价："..dimon.pricechinese;

end;

function UIUnionDiGongBidMoneyView:InputMoneyChange()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = toint(objSwf.inputMoney.text);
	if not num then
		objSwf.inputMoney.text = 0;
		return 
	end;
	
	num = num * self.rate;
	objSwf.inputMoney.text = toint(num / self.rate,-1)
end;