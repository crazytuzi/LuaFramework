--[[
战场二级面板
wangshuai
]]

_G.UIZhanChErjiView = BaseUI:new("UIZhanChErjiView")

function UIZhanChErjiView:Create()
	self:AddSWF("zhanchangErjiPanel.swf",true,"center")
end;

function UIZhanChErjiView:OnLoaded(objSwf)
	objSwf.btnRule.rollOver = function() self:ShowRule() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide() end;
	objSwf.showpanel.click = function() self:CloseCurpanle() end;
end;

function UIZhanChErjiView:OnShow()
	self:SetMyInfoPanel()
end;

function UIZhanChErjiView:OnHide()

end;

function UIZhanChErjiView:ShowRule()
	TipsManager:ShowBtnTips(StrConfig["activity10002"]);
end;

function UIZhanChErjiView:SetMyInfoPanel()
	local objSwf = self.objSwf
	local cfg = ActivityZhanChang.zcInfoVo;
	--objSwf.xinshiNum.text = cfg.num;
	--trace(cfg)
	--print("信息更新-~~~~~~~~~~~~UI")
	objSwf.scoreA.num = cfg.scoreA;
	objSwf.scoreB.num = cfg.scoreB;
end;

function UIZhanChErjiView:CloseCurpanle()
	UIZhanChang:Show();
	self:Hide();
end;
