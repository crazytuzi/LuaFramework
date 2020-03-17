--[[章节动画
liyuan
2014年9月28日10:33:06
]]

_G.UIStoryChapter = BaseUI:new("UIStoryChapter") 

UIStoryChapter.lastTime = 7000
UIStoryChapter.chapterName = nil
UIStoryChapter.UIWidth = 1920
UIStoryChapter.UIHeight = 1080
UIStoryChapter.chapterWidth = 0
UIStoryChapter.chapterHeight = 0
function UIStoryChapter:Create()
	self:AddSWF("storyChapterPanel.swf", true, "story")
end

function UIStoryChapter:OnLoaded(objSwf,name)
	objSwf.desLoader.loaded = function() 
		local winW,winH = UIManager:GetWinSize()
		self:DoResize(winW,winH)
	end
end

-- 重新调整布局
function UIStoryChapter:DoResize( dwWidth, dwHeight )
	local objSwf = self.objSwf
	if not objSwf then return end
	
	-- objSwf.mcBlack._x = dwWidth / 2
	-- objSwf.mcBlack._y = dwHeight / 2
	-- objSwf.mcBlack._width = dwWidth;
	-- objSwf.mcBlack._height = dwHeight;
	if dwHeight <= 940 then
		objSwf.desLoader._y = -78
	else
		objSwf.desLoader._y = 0
	end
		objSwf.desLoader._x = 0
end

function UIStoryChapter:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then return end
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	self:UpdateInfo()
end

function UIStoryChapter:ShowChapter(chapterName, playEndFunc)
	self.chapterName = chapterName
	self.callBackFunc = playEndFunc
	ClickLog:Send(ClickLog.T_Stroy_Chapter,self.chapterName);
	
	if self.bShowState then
		self:UpdateInfo()
	else
		self:Show()
	end
end

function UIStoryChapter:UpdateInfo()	
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.mcBlack:gotoAndPlay(1)	
	UILoaderManager:LoadList({"resfile/swf/"..self.chapterName..".swf"},function()		
		objSwf.desLoader.source = "resfile/swf/"..self.chapterName..".swf"
		local winW,winH = UIManager:GetWinSize()
		self:DoResize(winW,winH)
		if self.timerID then
			TimerManager:UnRegisterTimer( self.timerID )
			self.timerID = nil
		end
		self.timerID = TimerManager:RegisterTimer(function()
			self:Hide()
		end,self.lastTime,1)
	end)
end

function UIStoryChapter:OnHide()
	if self.objSwf then 
		self.objSwf.desLoader:unload()
		self.objSwf.desLoader.source = nil;
	end
	
	ClickLog:Send(ClickLog.T_Stroy_Chapter_End,self.chapterName);
	
	if self.timerID then
		TimerManager:UnRegisterTimer( self.timerID )
		self.timerID = nil
	end
	
	if self.callBackFunc then
		self.callBackFunc()
	end
end
