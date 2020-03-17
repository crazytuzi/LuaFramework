--[[
主界面运营按钮基类
lizhuangzhuang
2015年5月14日16:37:27
]]

_G.BaseYunYingBtn = {};

function BaseYunYingBtn:new()
	local obj = setmetatable({},{__index=self});
	return obj;
end

--获取舞台按钮名
function BaseYunYingBtn:GetStageBtnName()
	return "";
end

--是否显示按钮
function BaseYunYingBtn:IsShow()
	return true;
end

--刷新按钮显示
function BaseYunYingBtn:RefreshBtn()
	if UIMainYunYingFunc:IsShow() then
		UIMainYunYingFunc:DrawLayout();
	end
end

function BaseYunYingBtn:SetButton(mc)
	if self.button then
		self:RemoveButton();
	end
	self.button = mc;
	self.button.click = function() self:OnBtnClick(); end
	self:OnBtnInit();
end

function BaseYunYingBtn:GetButton()
	return self.button;
end

function BaseYunYingBtn:RemoveButton()
	if not self.button then
		return;
	end
	self.button.click = nil;
	self.button = nil;
end

function BaseYunYingBtn:OnBtnInit()

end

--点击按钮
function BaseYunYingBtn:OnBtnClick()

end

function BaseYunYingBtn:OnRefresh()

end

--显示UI
function BaseYunYingBtn:DoShowUI(uiName)
	local ui = UIManager:GetUI(uiName);
	if not ui then return; end
	if ui:IsShow() then
		ui:Hide();
	else
		if self.button then
			ui.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		ui:Show();
	end
end