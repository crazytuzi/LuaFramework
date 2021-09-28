require "ui.dialog"


FactionBeastCell2 = {}
setmetatable(FactionBeastCell2, Dialog)
FactionBeastCell2.__index = FactionBeastCell2

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FactionBeastCell2.getInstance()
	print("enter get FactionBeastCell2 dialog instance")
    	if not _instance then
    	    	_instance = FactionBeastCell2:new()
    	    	_instance:OnCreate()
    	end
    	
    	return _instance
end

function FactionBeastCell2.getInstanceAndShow()
	print("enter FactionBeastCell2 dialog instance show")
    	if not _instance then
       		 _instance = FactionBeastCell2:new()
        	_instance:OnCreate()
	else
		print("set FactionBeastCell2 dialog visible")
		_instance:SetVisible(true)
    	end
    
    	return _instance
end

function FactionBeastCell2.getInstanceNotCreate()
	return _instance
end

function FactionBeastCell2.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FactionBeastCell2.ToggleOpenClose()
	if not _instance then 
		_instance = FactionBeastCell2:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function FactionBeastCell2.GetLayoutFileName()
	return "bangpaixunshoumaincell2.layout"
end

function FactionBeastCell2:new()
    	local self = {}
    	self = Dialog:new()
    	setmetatable(self, FactionBeastCell2)

    	return self
end

function FactionBeastCell2.CreateNewDlg(pParentDlg, id)
	local newDlg = FactionBeastCell2:new()
	newDlg:OnCreate(pParentDlg, id)
    	return newDlg
end

function FactionBeastCell2:OnCreate(pParentDlg, id)
	Dialog.OnCreate(self,pParentDlg, id)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.head = CEGUI.toItemCell(winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell2/back/head"))
	self.name = winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell2/back/name")
	local showTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeastshow")
	local record = showTable:getRecorder(id)
	if record then
		local modelid = record.modelID
		local name = record.name
		self.head:setProperty("Image", "")

		local wndWidth = self.head:getPixelSize().width
		local wndHeight = self.head:getPixelSize().height
		local Sprite = GetGameUIManager():AddWindowSprite(self.head, modelid, XiaoPang.XPDIR_BOTTOMRIGHT, wndWidth/2.0, wndHeight-20, true)
		self.head:removeEvent("MouseClick")
		self.head:subscribeEvent("MouseClick", FactionBeastDlg.HandleBeastClicked, FactionBeastDlg.getInstance())

		self.name:setText(name)
	else
		self.head:setProperty("Image", "")
		self.name:setText("")
	end
end

return FactionBeastCell2
