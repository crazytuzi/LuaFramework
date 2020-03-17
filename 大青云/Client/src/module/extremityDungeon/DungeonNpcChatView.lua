--[[
	2015年3月13日, PM 03:02:13
	副本剧情对话
	wangyanwei
]]

_G.UIDungeonNpcChat = BaseUI:new('UIDungeonNpcChat');

UIDungeonNpcChat.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(450,520),
	Rotation = 0
};

function UIDungeonNpcChat:Create()
	self:AddSWF("chatFramePanel.swf", true, "bottom");	
end

UIDungeonNpcChat.chatCfg = {};
UIDungeonNpcChat.chatState = 0;
function UIDungeonNpcChat:OnLoaded(objSwf)
	
end

function UIDungeonNpcChat:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIDungeonNpcChat:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt:ClearTimer();
	local cfg = self.chatCfg;
	local npcCfg = t_npc[cfg.npcID];
	if not npcCfg then return end
	self:DrawNpc(cfg.npcID);
	local str = '';
	if cfg.id < 2000000 then
		local talkCfg = split(cfg.chatStr,'#');
		str = talkCfg[self.chatState];
	else
		str = cfg.chatStr;
	end
	if str == '' then return end
	self.timeKey = TimerManager:RegisterTimer(function()
		self:ChangeChatTxt(str);
	end,500,1);
	if cfg.state ~= 0 then
		self.timeHideKey = TimerManager:RegisterTimer(function()
			self:Hide();
		 end, cfg.state * 1000 ,1);
	end
end

--@param chatId 剧情ID   
function UIDungeonNpcChat:Open(chatId,state)
	if not state then state = 1; end
	self.chatState = state;
	local cfg = t_duntalk[chatId];
	if not cfg then return end
	self.chatCfg = cfg;
	if state == 2 then 
		local talkCfg = split(cfg.chatStr,'#');
		if talkCfg[2] == '' then return end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.timeHideKey then
		TimerManager:UnRegisterTimer(self.timeHideKey);
		self.timeHideKey = nil;
	end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

--显示文本
function UIDungeonNpcChat:ChangeChatTxt(strStr)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.txt:SetData(strStr);
end

--画NPC模型
UIDungeonNpcChat.npcAvatar = nil;
function UIDungeonNpcChat:DrawNpc(id)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.npcAvatar = nil;
	self.npcAvatar = NpcAvatar:NewNpcAvatar(id);
	self.npcAvatar:InitAvatar();
	local drawCfg = UIDrawChatNpcCfg[id];
	if not drawCfg then 
		drawCfg = self:GetDefaultCfg();
	end
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("chatNpc",self.npcAvatar, objSwf.npcLoader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UINpc");
	else
		self.objUIDraw:SetUILoader(objSwf.npcLoader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(self.npcAvatar);
	end
	local rotation = drawCfg.Rotation or 0;
	self.npcAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
end

function UIDungeonNpcChat:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIDungeonNpcChat:OnHide()
	local objSwf = self.objSwf;
	objSwf.txt:ClearTimer();
	objSwf.npcLoader.source = nil;
	if self.timeHideKey then
		TimerManager:UnRegisterTimer(self.timeHideKey);
		self.timeHideKey = nil;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.npcAvatar then
		self.npcAvatar = nil;
	end
end