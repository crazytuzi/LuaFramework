--[[黑色打字面板
liyuan
2014年9月28日10:33:06
]]

_G.UIStartBalckDialog = BaseUI:new("UIStartBalckDialog") 
UIStartBalckDialog.lastTime = 10000
-- UIStartBalckDialog.dialogId = nil
-- UIStartBalckDialog.talkCfg = ''
-- UIStartBalckDialog.index = 1
-- UIStartBalckDialog.isPlay = false
-- UIStartBalckDialog.timerID = nil
-- UIStartBalckDialog.callBackFunc = nil
-- UIStartBalckDialog.dwStartTime = nil
function UIStartBalckDialog:Create()
	self:AddSWF("startBlackPanel.swf", true, "story")
end

function UIStartBalckDialog:OnLoaded(objSwf,name)
	-- objSwf.txtDialog.text = ""
	objSwf.btnBack.click = function() self:Hide() end
end

-- 重新调整布局
function UIStartBalckDialog:DoResize( dwWidth, dwHeight )
	local objSwf = self.objSwf
	if not objSwf then return end
	
	objSwf.mcBlack._x = 0;
	objSwf.mcBlack._y = 0;
	objSwf.mcBlack._width = dwWidth;
	objSwf.mcBlack._height = dwHeight;
	
	objSwf.mcPiaozi._x = dwWidth / 2
	objSwf.mcPiaozi._y = dwHeight / 2
	
	objSwf.mcLeft._x = 0
	objSwf.mcLeft._y = dwHeight
	
	objSwf.mcRight._x = dwWidth
	objSwf.mcRight._y = 0
	-- objSwf.txtDialog._x = (dwWidth-800)/2;
	-- objSwf.txtDialog._y = (dwHeight-400)/2;
	
	if objSwf.mcbottom then
		objSwf.mcbottom._x = dwWidth / 2;
		objSwf.mcbottom._y = dwHeight
	end
	
	if objSwf.mctop then
		objSwf.mctop._x = dwWidth / 2;
		objSwf.mctop._y = 0
	end
	
	objSwf.btnBack._x = dwWidth - 160
	objSwf.btnBack._y = 70
end

-- function UIStartBalckDialog:Update()
	-- if not self.bShowState then return end
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- if not self.isPlay then return end
	-- if not self.talkCfg then return end
	-- if not self.dwStartTime then self.dwStartTime = GetCurTime() end
	
	-- if GetCurTime()-self.dwStartTime>40 then
		-- self.dwStartTime = GetCurTime()
		-- objSwf.txtDialog.text = string.sub(self.talkCfg.talk,1,self.index)
		-- self.index = self.index + 1
	-- end
	
-- end

function UIStartBalckDialog:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	self:UpdateInfo()
end

function UIStartBalckDialog:PlayStoryDialog(dialogId, playEndFunc)
	-- self.dialogId = dialogId
	self.callBackFunc = playEndFunc
	
	if self.bShowState then
		self:UpdateInfo()
	else
		self:Show()
	end
end

function UIStartBalckDialog:UpdateInfo()
	-- local cfg = StoryDialogConfig[self.dialogId]
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local cfg = StoryDialogConfig[1]
	-- if not cfg then return end
	-- self.talkCfg = cfg
	-- self:PlayText()
		
	self.timerID = TimerManager:RegisterTimer(function()
		-- self.isPlay = false
		-- objSwf.txtDialog.text = self.talkCfg.talk
		-- self.index = 1
		self:Hide()
	end,self.lastTime,1)

	
	-- objSwf.txtTitle.text = cfg.title or ""
end

function UIStartBalckDialog:PlayText()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	-- objSwf.txtDialog.text = ""
	self.isPlay = true
end

function UIStartBalckDialog:StopText()
	-- self.isPlay = false
end

function UIStartBalckDialog:OnHide()
	-- self.index = 1
	-- self.isPlay = false
	if self.timerID then
		TimerManager:UnRegisterTimer( self.timerID )
		self.timerID = nil
	end
	
	if self.callBackFunc then
		self.callBackFunc()
	end
end

