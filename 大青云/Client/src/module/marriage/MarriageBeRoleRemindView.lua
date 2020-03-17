--[[
收到婚礼邀请
wangshuai
]]

_G.UIMarryRemind = BaseUI:new("UIMarryRemind")

function UIMarryRemind:Create()
	self:AddSWF("marryBeRoleRemind.swf",true,"center")
end;

function UIMarryRemind:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.btnOk.click = function() self:btnOk() end;
	objSwf.btnNo.click = function() self:btnNo() end;
end;

function UIMarryRemind:OnShow()

	local objSwf = self.objSwf;
	local data = MarriageModel.BeMarryRemind;
	if not objSwf then return end;
	if not data then return end;

	objSwf.tfName1.htmlText = data.naroleName or "";
	objSwf.tfName2.htmlText = data.nvroleName or "";
	objSwf.tfName11.htmlText = data.naroleName or "";
	objSwf.tfName22.htmlText = data.nvroleName or "";

	if data.naprof and data.nvprof then 
		objSwf.icon1.source = ResUtil:GetHeadIcon(data.naprof);
		objSwf.icon2.source = ResUtil:GetHeadIcon(data.nvprof);
	end;
end;

function UIMarryRemind:OnHide()

end;

function UIMarryRemind:btnOk()
	MarriagController:ReqEnterMarryChurch()
	self:Hide();
end;

function UIMarryRemind:btnNo()

	self:Hide();
end;


-- 是否缓动
function UIMarryRemind:IsTween()
	return true;
end

--面板类型
function UIMarryRemind:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryRemind:IsShowSound()
	return true;
end

function UIMarryRemind:IsShowLoading()
	return true;
end