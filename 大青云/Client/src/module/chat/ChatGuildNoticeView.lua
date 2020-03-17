--[[
帮派聊天提醒
lizhuangzhuang
2015年10月16日22:25:32
]]

_G.UIChatGuildNotice = BaseUI:new("UIChatGuildNotice");

function UIChatGuildNotice:Create()
	self:AddSWF("chatGuildNotice.swf",true,"bottom")
end

function UIChatGuildNotice:OnLoaded(objSwf)
	objSwf.mcEffect.hitTestDisable = true;
	objSwf.mcEffect._visible = false;
	objSwf.btnGuildNotice.click = function() self:OnBtnGuildNoticeClick(); end
end

function UIChatGuildNotice:GetWidth()
	return 79;
end

function UIChatGuildNotice:GetHeight()
	return 79;
end

function UIChatGuildNotice:PlayEffect()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.mcEffect._visible = true;
end

function UIChatGuildNotice:OnBtnGuildNoticeClick()
	UIChatGuild:Show();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.mcEffect._visible = false;
end