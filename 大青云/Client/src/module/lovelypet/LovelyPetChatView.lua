--[[头顶冒泡
zhangshuhui
2015年7月15日10:33:06
]]

_G.UILovelyPetChat = BaseUI:new("UILovelyPetChat") 
UILovelyPetChat.lovelpet = nil
UILovelyPetChat.chatText = ""
UILovelyPetChat.chatStart = 0
UILovelyPetChat.offsetX = 0
UILovelyPetChat.offsetY = 0
local lastTime = 8000

function UILovelyPetChat:Create()
	self:AddSWF("lovelypetChatPanel.swf", true, "bottom")
end

function UILovelyPetChat:OnLoaded(objSwf,name)
	objSwf.BtnLovelyPetChatBg.hitTestDisable = true;
	objSwf.textpanel.hitTestDisable = true;
end

function UILovelyPetChat:Update()
	if not self.bShowState then return end
	
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if not self.lovelpet then
		return;
	end
	
	--状态
	
	local timeNow = GetCurTime()
	if timeNow - self.chatStart > lastTime then
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

function UILovelyPetChat:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	self:Reset()
end

function UILovelyPetChat:Reset()
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

function UILovelyPetChat:OnHide()
	self.lovelpet = nil
	self.chatText="" 
	self.chatStart=0
end

----------------------------------
function UILovelyPetChat:Set(chatText, role)
	self.lovelpet = role
	self.chatText=chatText--.talk 
	self.offsetX = 0--chatText.offsetX or 0
	self.offsetY = 0--chatText.offsetY or 0
	self.chatStart=0
	
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
