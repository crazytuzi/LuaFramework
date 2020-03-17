--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/7/28
    Time: 19:05
   ]]

_G.QiZhanWallAvatar = {}
setmetatable(QiZhanWallAvatar, {__index = CAvatar})
local metaQiZhanWallAvatar = {__index = QiZhanWallAvatar}
function QiZhanWallAvatar:CreateNewAvatar(skn,skl)
	local avatar = CAvatar:new()
	avatar.wallSkn = skn;
	avatar.wallSkl = skl;
	setmetatable(avatar, metaQiZhanWallAvatar)
	return avatar
end

function QiZhanWallAvatar:InitAvatar()
	local sklFile = self.wallSkl;
	local sknFile = self.wallSkn;
	self:SetPart("Body", sknFile)
	self:ChangeSkl(sklFile)
	self:SetNullPick();
	self.pickFlag = enPickFlag.EPF_Null;
end

function QiZhanWallAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end