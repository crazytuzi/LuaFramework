--[[结婚流程详情界面
zhangshuhui
]]

_G.UIMarriageJieShaoView = BaseUI:new("UIMarriageJieShaoView")

UIMarriageJieShaoView.liuchengMax = 7;
UIMarriageJieShaoView.curliucheng = 0;

function UIMarriageJieShaoView:Create()
	self:AddSWF("marryJieShaoPanel.swf", true, "center")
end

function UIMarriageJieShaoView:OnLoaded(objSwf,name)
	objSwf.btnClose.click   = function() self:OnBtnCloseClick() end 
	objSwf.btnJieShao.click  = function() self:OnBtnRightClick() end
	objSwf.btnLeft.click = function() self:OnBtnLeftClick() end
	objSwf.btnRight.click = function() self:OnBtnRightClick() end
end

function UIMarriageJieShaoView:OnShow()
	self:InitData();
	self:ShowInfo();
end

function UIMarriageJieShaoView:InitData()
	self.curliucheng = 1;
end

function UIMarriageJieShaoView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnJieShao.visible = false;
	for i=1,self.liuchengMax do
		objSwf["imgliucheng"..i]._visible = false;
	end
	if self.curliucheng == 1 then
		objSwf.btnJieShao.visible = true;
	else
		
	end
	objSwf["imgliucheng"..self.curliucheng]._visible = true;
	
	self:ShowBtnState();
end

function UIMarriageJieShaoView:OnBtnLeftClick()
	self.curliucheng = self.curliucheng - 1;
	self:ShowInfo();
end

function UIMarriageJieShaoView:OnBtnRightClick()
	self.curliucheng = self.curliucheng + 1;
	self:ShowInfo();
end

function UIMarriageJieShaoView:ShowBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnLeft.visible = true;
	objSwf.btnRight.visible = true;
	if self.curliucheng <= 1 then
		objSwf.btnLeft.visible = false;
	elseif self.curliucheng >= 7 then
		objSwf.btnRight.visible = false;
	end
end

function UIMarriageJieShaoView:OnBtnCloseClick()
	self:Hide();
end