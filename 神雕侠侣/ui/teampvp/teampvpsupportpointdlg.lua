require "ui.dialog"
TeampvpSupportPointDlg = {}
setmetatable(TeampvpSupportPointDlg, Dialog)
TeampvpSupportPointDlg.__index = TeampvpSupportPointDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpSupportPointDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpSupportPointDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpSupportPointDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpSupportPointDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpSupportPointDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpSupportPointDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpSupportPointDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpSupportPointDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpSupportPointDlg.GetLayoutFileName()
    return "teampvpcheck.layout"
end
function TeampvpSupportPointDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.ok = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpcheck/OK"))
    self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpcheck/Canle"))
    
    self.ok:subscribeEvent("Clicked",TeampvpSupportPointDlg.HandleOKClicked,self)
    self.cancel:subscribeEvent("Clicked",TeampvpSupportPointDlg.HandleCancelClicked,self)
    
    self.num = CEGUI.Window.toEditbox(winMgr:getWindow("teampvpcheck/num"))
    self.num:setReadOnly(true)
	  self.num:subscribeEvent("MouseClick", TeampvpSupportPointDlg.HandleEditClicked, self)
	  
	  self.teamid = 0
	  self.remainpoints = 0
   
end
  


require "ui.numinputdlg"
function TeampvpSupportPointDlg:HandleEditClicked(args)
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.num)
end
------------------- private: -----------------------------------
function TeampvpSupportPointDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpSupportPointDlg)
    return self
end


function TeampvpSupportPointDlg:HandleOKClicked(args)
  if self.num:getText() == "" or tonumber(self.num:getText()) >  self.remainpoints then
	GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(145623))
    return
  end
  local p = require "protocoldef.knight.gsp.faction.csurportfactionteam":new()
  p.teamid = self.teamid
  p.surportpoint = self.num:getText()
  require "manager.luaprotocolmanager":send(p)
  self.DestroyDialog()

end


function TeampvpSupportPointDlg:HandleCancelClicked(args)
    self.DestroyDialog()
end
return TeampvpSupportPointDlg
