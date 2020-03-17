--[[
QQ充值
lizhuangzhuang
2016年1月22日20:03:20
]]

_G.UIQQCharge = BaseUI:new("UIQQCharge");

UIQQCharge.ChargeMap = {
	"G001*100*1",
	"G002*300*1",
	"G003*1000*1",
	"G004*5000*1",
	"G005*10000*1",
}

function UIQQCharge:Create()
	self:AddSWF("qqRecharge.swf",true,"center");
end

function UIQQCharge:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	for i=1,5 do
		objSwf["btn"..i].click = function() self:OnBtnChargeClick(i); end
	end
end

function UIQQCharge:IsTween()
	return true;
end

function UIQQCharge:GetPanelType()
	return 0;
end

function UIQQCharge:IsShowSound()
	return true;
end

function UIQQCharge:IsShowLoading()
	return true;
end

function UIQQCharge:OnBtnChargeClick(index)
	local payitem = UIQQCharge.ChargeMap[index];
	if not payitem then return; end
	if Version:GetName() == VersionConsts.TXQQ then
		Version:TXCharge(payitem,"元宝*元宝")
	end
end

function UIQQCharge:OnBtnCloseClick()
	self:Hide();
end