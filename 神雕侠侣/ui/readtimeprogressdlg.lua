require "ui.dialog"
ReadTimeProgressDlg = {}
setmetatable(ReadTimeProgressDlg, Dialog)
ReadTimeProgressDlg.__index = ReadTimeProgressDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ReadTimeProgressDlg.getInstance()
    if not _instance then
        _instance = ReadTimeProgressDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ReadTimeProgressDlg.getInstanceAndShow()
    if not _instance then
        _instance = ReadTimeProgressDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ReadTimeProgressDlg.getInstanceNotCreate()
    return _instance
end

function ReadTimeProgressDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function ReadTimeProgressDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ReadTimeProgressDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function ReadTimeProgressDlg.GetLayoutFileName()
    return "readtimeprogressbardlg.layout"
end
function ReadTimeProgressDlg:OnCreate()
	local prefix = "lua"
    Dialog.OnCreate(self,nil,prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pBar = CEGUI.Window.toProgressBar(winMgr:getWindow(prefix .. "ReadTimeProgressDlg/ReadTimeBar"))
	self.m_pBarText = winMgr:getWindow(prefix .. "ReadTimeProgressDlg/ReadTimeBar/Text")
	self.m_pBar:subscribeEvent("WindowUpdate",ReadTimeProgressDlg.HandleWindowUpdata,self)
	self.m_pBar:setProgress(0)
--	self.m_pBar:setBarType(ProgressBar.GreenBar)
	self.m_fElapsedReadTime = 0
	self.m_fTotalReadTime = 0
	self.dtype = ""

end

---------------- private: -----------------------------------
function ReadTimeProgressDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ReadTimeProgressDlg)
    return self
end
function ReadTimeProgressDlg:HandleClicked(args)

end


function ReadTimeProgressDlg:HandleWindowUpdata(e)  
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsedTime = updateArgs.d_timeSinceLastFrame
	if self.m_bIsReadingTime then
		self.m_fElapsedReadTime = elapsedTime + self.m_fElapsedReadTime
		if self.m_pBar then
			local fProgress = self.m_fElapsedReadTime/self.m_fTotalReadTime
			self.m_pBar:setProgress(fProgress)
		end
        if self.m_fElapsedReadTime > self.m_fTotalReadTime then
			self:EndReadTime()
		end
	end
	return true
end


function ReadTimeProgressDlg:EndReadTime()
	self.m_bIsReadingTime = nil
	ReadTimeProgressDlg.DestroyDialog()
    if self.callback then
        self.callback()
        self.callback = nil
    end

end

function ReadTimeProgressDlg.Setup(text,totaltime,callback)
	self = ReadTimeProgressDlg.getInstance()
	self.m_pBarText:setText("[border='FF190400']" .. text)
	self.m_fTotalReadTime = totaltime
    self.callback = callback
end

function ReadTimeProgressDlg.Start()
	ReadTimeProgressDlg.getInstanceAndShow()
	self.m_bIsReadingTime = true
end

return ReadTimeProgressDlg
