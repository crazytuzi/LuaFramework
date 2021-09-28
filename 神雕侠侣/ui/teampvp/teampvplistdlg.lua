require "ui.dialog"
TeampvpListDlg = {}
setmetatable(TeampvpListDlg, Dialog)
TeampvpListDlg.__index = TeampvpListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpListDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpListDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpListDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpListDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpListDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpListDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpListDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpListDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpListDlg.GetLayoutFileName()
    return "teampvplist1.layout"
end
function TeampvpListDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.mypower = winMgr:getWindow("teampvplist1/num")
	self.leftlist = CEGUI.Window.toMultiColumnList(winMgr:getWindow("teampvplist1/main1"))
	self.rightlist = CEGUI.Window.toMultiColumnList(winMgr:getWindow("teampvplist1/main0"))

end

------------------- private: -----------------------------------
function TeampvpListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpListDlg)
    return self
end

function TeampvpListDlg:Process(lp,rp,sp)
	if sp then
		self.mypower:setText(sp)
	end
	if lp then
		for i = 1 , #lp do
			TeampvpListDlg.AddRow(self.leftlist,lp[i],i-1)
		end
	end

	if rp then
		for i = 1 , #rp do
			TeampvpListDlg.AddRow(self.rightlist,rp[i],i-1)
		end
	end

end

function TeampvpListDlg.AddRow(mainWindow,data,rowid)
--print("data.fightpower",data.fightpower,mainWindow:getListHeader():getSegmentFromColumn(2):setText("record"))
	mainWindow:addRow(rowid)
	local pItem0 = CEGUI.createListboxTextItem(rowid+1)
	pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
	mainWindow:setItem(pItem0, 0, rowid)


	if data.teamname then
		local pItem1 = CEGUI.createListboxTextItem(data.teamname)
		pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem1, 1, rowid)
	end
	if data.fightpower then
		local pItem2 = CEGUI.createListboxTextItem(data.fightpower)
		pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem2, 2, rowid)
	end


end

return TeampvpListDlg
