--[[内心独白对话框
liyuan
2014年9月28日10:33:06
]]

_G.UIStoryDialog = BaseUI:new("UIStoryDialog") 
UIStoryDialog.lastTime = 5000
UIStoryDialog.curDialogId = nil
UIStoryDialog.talkCfg = ''
UIStoryDialog.index = 1
UIStoryDialog.isPlay = false
UIStoryDialog.timerID = nil
UIStoryDialog.objUIDraw = nil;--draw 3d
UIStoryDialog.curIndex = 1
function UIStoryDialog:Create()
	self:AddSWF("storyDialogPanel.swf", true, "story")
end

function UIStoryDialog:OnLoaded(objSwf,name)
	objSwf.txtDialog.text = ""
	objSwf.txtTitle.text = ""
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UIStoryDialog:OnBtnCloseClick()
	self:CheckNextDialog()
end

function UIStoryDialog:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIStoryDialog:GetWidth(szName)
	return 530 
end

function UIStoryDialog:GetHeight(szName)
	return 180
end

function UIStoryDialog:Update()
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.isPlay then return end
	if not self.talkCfg then return end
	
	objSwf.txtDialog.text = string.sub(self.talkCfg.talk,1,self.index)
	self.index = self.index + 1
	if objSwf.txtDialog.text == self.talkCfg.talk then
		self.isPlay = false
		objSwf.txtDialog.text = self.talkCfg.talk
		self.index = 1		
	end
end

function UIStoryDialog:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	self:TweenShowEff()
	self:UpdateInfo()
end

function UIStoryDialog:PlayStoryDialog(dialogId)
	self.curDialogId = toint(dialogId)
	self.curIndex = 1
	if self.bShowState then
		self:UpdateInfo()
	else
		self:Show()
	end
end

function UIStoryDialog:CheckNextDialog()
	local playList = StoryDialogPlayList[self.curDialogId]
	if not playList then 
		self:Hide()
		return 
	end
	local dialogLen = #playList
	if self.curIndex >= dialogLen then
		self:Hide()
		return
	end
	self.curIndex = self.curIndex + 1
	
	self:UpdateInfo()
end

function UIStoryDialog:UpdateInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local playList = StoryDialogPlayList[self.curDialogId]
	if not playList then return end
	if not playList[self.curIndex] then return end
	local cfg = StoryDialogConfig[playList[self.curIndex]]
	if not cfg then return end
	
	self.index = 1
	self.talkCfg = cfg
	self:PlayText()
	
	if cfg.head == -1 then
		local player = MainPlayerController:GetPlayer()
		if player then
			local eaZone = '%]'
			local npcName = player:GetName()
			
			local startIndex,endIndex = string.find(npcName, eaZone)
			if endIndex then
				npcName = string.sub(npcName, endIndex+1, -1)
			end
			objSwf.txtTitle.text = npcName
		end
	else
		objSwf.txtTitle.text = cfg.title or ""
	end
end

function UIStoryDialog:PlayText()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.timerID then
		TimerManager:UnRegisterTimer( self.timerID )
		self.timerID = nil
	end
	self.timerID = TimerManager:RegisterTimer(function()
			self:CheckNextDialog()
		end,self.lastTime,1)
	objSwf.txtDialog.text = ""
	if self.talkCfg.head == -1 then
		self:Show3DRole()
	else
		self:DrawNpc()
	end
	self.isPlay = true
end

function UIStoryDialog:StopText()
	self.isPlay = false
	
end

function UIStoryDialog:OnHide()
	self.isPlay = false
	if self.timerID then
		TimerManager:UnRegisterTimer( self.timerID )
		self.timerID = nil
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	self.objAvatar = nil
	self.curDialogId = nil
	self.talkCfg = nil
	self.index = 1
	self.curIndex = 1
end

--画Npc模型
function UIStoryDialog:DrawNpc()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.talkCfg.head then return end
	
	local npcAvatar = nil
	npcAvatar = NpcAvatar:NewNpcAvatar(self.talkCfg.head);
	npcAvatar:InitAvatar();
		
	local drawCfg = UIDrawChatNpcCfg[self.talkCfg.head];
	if not drawCfg then
		drawCfg = {
						EyePos = _Vector3.new(0,-40,20),
						LookPos = _Vector3.new(0,0,10),
						VPort = _Vector2.new(490,320),
						Rotation = 0
					};
	end
	
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("UIStoryDialog",npcAvatar, objSwf.iconLoader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UINpc");
	else
		self.objUIDraw:SetUILoader(objSwf.iconLoader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(npcAvatar);
	end
	npcAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );
	self.objUIDraw:SetDraw(true);
end

function UIStoryDialog:Show3DRole()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local uiLoader = objSwf.iconLoader;
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("UIStoryDialog", self.objAvatar, uiLoader,
							UIDrawChatRoleCfg[prof].VPort,UIDrawChatRoleCfg[prof].EyePos,UIDrawChatRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawChatRoleCfg[prof].VPort,UIDrawChatRoleCfg[prof].EyePos,UIDrawChatRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	
end

--UI开启缓动，
function UIStoryDialog:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local startX,startY = self:GetCfgPos();
	local endX = startX ;
	local endY = startY - 200;
	objSwf._x = startX;
	objSwf._y = startY;	
	
	Tween:To(self.objSwf,1,{_y = endY},{onComplete = callback})
end