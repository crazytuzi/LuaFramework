require "ui.dialog"

FactionBeastCell1 = {}
setmetatable(FactionBeastCell1, Dialog)
FactionBeastCell1.__index = FactionBeastCell1

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FactionBeastCell1.getInstance()
	print("enter get FactionBeastCell1 dialog instance")
    	if not _instance then
    	    	_instance = FactionBeastCell1:new()
    	    	_instance:OnCreate()
    	end
    	
    	return _instance
end

function FactionBeastCell1.getInstanceAndShow()
	print("enter FactionBeastCell1 dialog instance show")
    	if not _instance then
       		 _instance = FactionBeastCell1:new()
        	_instance:OnCreate()
	else
		print("set FactionBeastCell1 dialog visible")
		_instance:SetVisible(true)
    	end
    
    	return _instance
end

function FactionBeastCell1.getInstanceNotCreate()
	return _instance
end

function FactionBeastCell1.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FactionBeastCell1.ToggleOpenClose()
	if not _instance then 
		_instance = FactionBeastCell1:new() 
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

function FactionBeastCell1.GetLayoutFileName()
    	return "bangpaixunshoumaincell1.layout"
end

function FactionBeastCell1:new()
    	local self = {}
    	self = Dialog:new()
    	setmetatable(self, FactionBeastCell1)

    	return self
end

function FactionBeastCell1.CreateNewDlg(pParentDlg, id, beastlevel)
	local newDlg = FactionBeastCell1:new()
	newDlg:OnCreate(pParentDlg, id, beastlevel)
    	return newDlg
end

function FactionBeastCell1:OnCreate(pParentDlg, id, beastlevel)
	Dialog.OnCreate(self,pParentDlg, id)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.head = winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell1/back/head")
	self.name = winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell1/back/name")
	self.hint = winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell1/name")
	self.arrow = winMgr:getWindow(tostring(id) .. "bangpaixunshoumaincell1/zhishi")
	local showTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeastshow")
	local ids = showTable:getAllID()
	local record = showTable:getRecorder(id)
	if record then
		local modelid = record.modelID
		local name = record.name
		self.head:setProperty("Image", "")

		local wndWidth = self.head:getPixelSize().width
		local wndHeight = self.head:getPixelSize().height
		local Sprite = GetGameUIManager():AddWindowSprite(self.head, modelid, XiaoPang.XPDIR_BOTTOMRIGHT, wndWidth/2.0, wndHeight-20, true)

		self.name:setText(name)

		if id == beastlevel then
			--empty
		elseif id == beastlevel - 1 then
			self:setPreLevel()
		elseif id == beastlevel + 1 then
			self:setNextLevel()
		else
			self:setIndexLevel(id)
		end

		if id == #ids then
			self.arrow:setVisible(false)
		end
	else
		self.head:setProperty("Image", "")
		self.name:setText("")
		self.hint:setText("")
	end
end

function FactionBeastCell1:setIndexLevel(id)
	local strbuilder = StringBuilder:new()
	strbuilder:Set("parameter1", id)
	self.hint:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(3176)))
end

function FactionBeastCell1:setPreLevel()
	self.hint:setText(MHSD_UTILS.get_resstring(3174))
end

function FactionBeastCell1:setNextLevel()
	self.hint:setText(MHSD_UTILS.get_resstring(3175))
end

return FactionBeastCell1
