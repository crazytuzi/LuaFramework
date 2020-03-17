--[[
    Created by IntelliJ IDEA.
    NPC指引气泡
    User: Hongbin Yang
    Date: 2016/8/24
    Time: 21:37
   ]]


_G.UINpcGuildChat = BaseUI:new("UINpcGuildChat")
UINpcGuildChat.lovelpet = nil
UINpcGuildChat.chatText = ""
UINpcGuildChat.chatStart = 0
UINpcGuildChat.offsetX = 0
UINpcGuildChat.offsetY = 0
UINpcGuildChat.lastTime = 0;

function UINpcGuildChat:Create()
	self:AddSWF("npcGuildChatPanel.swf", true, "bottom")
end

function UINpcGuildChat:OnLoaded(objSwf,name)
	objSwf.BtnLovelyPetChatBg.hitTestDisable = true;
	objSwf.textpanel.hitTestDisable = true;
end

function UINpcGuildChat:Update()
	if not self.bShowState then return end

	local objSwf = self.objSwf
	if not objSwf then return end

	if not self.lovelpet then
		return;
	end

	--状态

	local timeNow = GetCurTime()
	if timeNow - self.chatStart > self.lastTime then
		self:Hide()
	else
		local talkPos = self.lovelpet:GetNamePos()
		if not talkPos then
			self:Hide()
			return
		end
		objSwf._x =talkPos.x + self.offsetX
		objSwf._y =talkPos.y + 30 + self.offsetY
	end
end

function UINpcGuildChat:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	self:Reset()
end

function UINpcGuildChat:Reset()
	local objSwf = self.objSwf
	if not objSwf then return end
	self.chatStart = GetCurTime()
	objSwf.textpanel.textField.htmlText = self.chatText
	objSwf.textpanel.textField._height = objSwf.textpanel.textField.textHeight + 24;
	objSwf.BtnLovelyPetChatBg._width = objSwf.textpanel.textField.textWidth + 40;
	objSwf.BtnLovelyPetChatBg._height = objSwf.textpanel.textField.textHeight + 34;
	objSwf._x =500
	objSwf._y =300
end

function UINpcGuildChat:OnHide()
	self.lovelpet = nil
	self.chatText=""
	self.chatStart=0
end

----------------------------------
function UINpcGuildChat:Set(chatText, role, duration)
	self.lovelpet = role
	self.chatText=chatText--.talk
	self.offsetX = 0--chatText.offsetX or 0
	self.offsetY = 0--chatText.offsetY or 0
	self.chatStart=0

	if not duration then duration = 8000; end
	self.lastTime = duration;

	if chatText=="" then
		self:Hide()
		return
	end
	if self.bShowState then
		self:Reset()
	else
		self:Show()
	end
end
