require "ui.dialog"
NumInputDlg = {}
setmetatable(NumInputDlg, Dialog)
NumInputDlg.__index = NumInputDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NumInputDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = NumInputDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function NumInputDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = NumInputDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function NumInputDlg.getInstanceNotCreate()
    return _instance
end

function NumInputDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function NumInputDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NumInputDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function NumInputDlg:GetSingleton()
	return self.getInstance()
end
function NumInputDlg:ToggleOpenHide()
	self.ToggleOpenClose()
end
function NumInputDlg.GetLayoutFileName()
    return "numberinput.layout"
end
local MAX_NUM = 10
function NumInputDlg:OnCreate()
	local prefix = "NumInputDlg"
    Dialog.OnCreate(self,nil,prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pNumBtn = {}
	for  i = 0 ,  MAX_NUM-1  do
        self.m_pNumBtn[i] = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "numberinput/btn" .. i))
		self.m_pNumBtn[i]:setID(i)
        self.m_pNumBtn[i]:subscribeEvent("Clicked",NumInputDlg.HandleNumBtnClicked,self)
	end
	
	self.m_pDelBtn = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "numberinput/btn10"))
    self.m_pDelBtn:subscribeEvent("Clicked",NumInputDlg.HandleDelBtnClicked,self)
    
    self.m_pClearBtn = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "numberinput/btn11"))
    self.m_pClearBtn:subscribeEvent("Clicked",NumInputDlg.HandleClearBtnClicked,self)
    
    self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow(prefix .. "numberinput/closed"))
    self.m_pCloseBtn:subscribeEvent("Clicked",NumInputDlg.HandleCloseBtnClicked,self)
end

------------------- private: -----------------------------------
function NumInputDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NumInputDlg)
    return self
end


--按数字键
function NumInputDlg:HandleNumBtnClicked(e)
	local windowargs = CEGUI.toWindowEventArgs(e)	
    local num = windowargs.window:getID()
    self.m_pTarget:appendText(num)
    return true
	
end


--按清除键
function NumInputDlg:HandleDelBtnClicked(args)
	if self.m_pTarget:getText() ~= nil then
		self.m_pTarget:setText(string.sub(self.m_pTarget:getText(),1,string.len(self.m_pTarget:getText()) - 1))
    end
	return true
end



--按删除键
function NumInputDlg:HandleClearBtnClicked(args)
	self.m_pTarget:setText("")
    return true
end


--按关闭按钮
function NumInputDlg:HandleCloseBtnClicked(args)
	self.DestroyDialog()
	return true

end
function NumInputDlg:setTargetWindow(target)
	self.m_pTarget = target
    self:ajustPostion()
end
local function cegui_absdim(v)
	return CEGUI.UDim(0, v)
end
function NumInputDlg:ajustPostion()
	if self.m_pTarget == nil then
			return  
	end
    local targetPos = self.m_pTarget:GetScreenPos()
    local x
	local y
    if (targetPos.x + self.m_pTarget:getPixelSize().width + self:GetWindow():getPixelSize().width) < CEGUI.System:getSingleton():getGUISheet():getPixelSize().width then
        --放在右边
        x = targetPos.x + self.m_pTarget:getPixelSize().width
    else
        --放在左边
        x = targetPos.x - self:GetWindow():getPixelSize().width
    end
    if (targetPos.y - self:GetWindow():getPixelSize().height) > 0 then
        --放在上面
        y = targetPos.y - self:GetWindow():getPixelSize().height
    else
        --放在下面
        y = targetPos.y + self.m_pTarget:getPixelSize().height
    end
    self:GetWindow():setPosition(CEGUI.UVector2(cegui_absdim(x),cegui_absdim(y)))
end

return NumInputDlg
