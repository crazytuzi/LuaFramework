require "ui.dialog"
require "manager.beanconfigmanager"
LoginRewardDlg = {}
setmetatable(LoginRewardDlg, Dialog)
LoginRewardDlg.__index = LoginRewardDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginRewardDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LoginRewardDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginRewardDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginRewardDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginRewardDlg.getInstanceNotCreate()
    return _instance
end

function LoginRewardDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function LoginRewardDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LoginRewardDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function LoginRewardDlg.GetLayoutFileName()
    return "loginrewards.layout"

end
function LoginRewardDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.left = CEGUI.Window.toPushButton(winMgr:getWindow("loginrewards/back/left"))
	self.right = CEGUI.Window.toPushButton(winMgr:getWindow("loginrewards/back/right")) 
	self.left:subscribeEvent("Clicked",LoginRewardDlg.HandleLeftClicked,self)
	self.right:subscribeEvent("Clicked",LoginRewardDlg.HandleRightClicked,self)


	--CEGUI.Window.toPushButton(winMgr:getWindow("loginrewards/closebutton")):subscribeEvent("Clicked",LoginRewardDlg.CloseHandler,self)


	self.progress = CEGUI.toProgressBar(winMgr:getWindow("loginrewards/day/recent"))
	self.main = CEGUI.Window.toScrollablePane(winMgr:getWindow("loginrewards/back/list"))
	self.main:EnableHorzScrollBar(true)
	require "ui.loginreward.loginrewardcell"

	self.cells = {} 
	for i = 1,7 do
		self.cells[i] = LoginRewardCell.CreateNewDlg(self.main, i)
		self.cells[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, (i - 1) * self.cells[i]:GetWindow():getPixelSize().width ),CEGUI.UDim(0, 0)))
	end
	self.cellWidth = self.cells[1]:GetWindow():getPixelSize().width
	self.main:getHorzScrollbar():setDocumentSize(self.cellWidth*7)
end

------------------- private: -----------------------------------
function LoginRewardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginRewardDlg)
    return self
end
function LoginRewardDlg:HandleLeftClicked(args)
	self.main:getHorzScrollbar():setScrollPosition(self.main:getHorzScrollbar():getScrollPosition() - self.cellWidth )
end

function LoginRewardDlg:HandleRightClicked(args)
	self.main:getHorzScrollbar():setScrollPosition(self.main:getHorzScrollbar():getScrollPosition() + self.cellWidth )
end
LoginRewardDlg.hasShow = false
function LoginRewardDlg:process(days,awards)
	if days == 0 then
		self.progress:setProgress(0)
	elseif days == 7 then
		self.progress:setProgress(1)
	else
		self.progress:setProgress(days/7)
	end

	if not award then
		award = {}
	end
	
	local cell 
	local cfg = nil
	local showNum = 1
	LoginRewardDlg.hasShow = false
	cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cloginaward")
	for i = 1,7 do
		cell = self.cells[i] 
		local recorder = cfg:getRecorder(i)
		cell:ItemMode(recorder,awards[i],i)
		if awards[i] == 0 then
			LoginRewardDlg.hasShow = true
		end
	end
	for i = 7,1,-1 do
		if awards[i] == 0 then
			showNum = i
		end
	end
	if showNum >=3 and showNum <=5 then
		self.main:getHorzScrollbar():setScrollPosition(self.cellWidth * (showNum - 2 ))
	elseif showNum == 6 or showNum == 7 then 
		self.main:getHorzScrollbar():setScrollPosition(self.cellWidth * 4)
	else
		self.main:getHorzScrollbar():setScrollPosition(0)
	end

	return self
end


function LoginRewardDlg:HandleCloseBtnClick(args)
	LoginRewardDlg.getInstance():SetVisible(false)
end


























return LoginRewardDlg
