require "ui.dialog"
CrossTeampvpSupportPointDlg = {}
setmetatable(CrossTeampvpSupportPointDlg, Dialog)
CrossTeampvpSupportPointDlg.__index = CrossTeampvpSupportPointDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CrossTeampvpSupportPointDlg.getInstance()
	print("enter CrossTeampvpSupportPointDlg getinstance")
    if not _instance then
        _instance = CrossTeampvpSupportPointDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CrossTeampvpSupportPointDlg.getInstanceAndShow()
	print("enter CrossTeampvpSupportPointDlg instance show")
    if not _instance then
        _instance = CrossTeampvpSupportPointDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CrossTeampvpSupportPointDlg.getInstanceNotCreate()
    return _instance
end

function CrossTeampvpSupportPointDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function CrossTeampvpSupportPointDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CrossTeampvpSupportPointDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function CrossTeampvpSupportPointDlg.GetLayoutFileName()
    return "teampvpcheck.layout"
end
function CrossTeampvpSupportPointDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.ok = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpcheck/OK"))
    self.cancel = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpcheck/Canle"))
    
    self.ok:subscribeEvent("Clicked",CrossTeampvpSupportPointDlg.HandleOKClicked,self)
    self.cancel:subscribeEvent("Clicked",CrossTeampvpSupportPointDlg.HandleCancelClicked,self)
    
    self.num = CEGUI.Window.toEditbox(winMgr:getWindow("teampvpcheck/num"))
    self.num:setReadOnly(true)
	  self.num:subscribeEvent("MouseClick", CrossTeampvpSupportPointDlg.HandleEditClicked, self)
	  
	  self.teamid = 0
	  self.remainpoints = 0
   
end
  


require "ui.numinputdlg"
function CrossTeampvpSupportPointDlg:HandleEditClicked(args)
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.num)
end
------------------- private: -----------------------------------
function CrossTeampvpSupportPointDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CrossTeampvpSupportPointDlg)
    return self
end


function CrossTeampvpSupportPointDlg:HandleOKClicked(args)
  if self.num:getText() == "" or tonumber(self.num:getText()) >  self.remainpoints then
	  GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(145623))
    return
  end
  local p = require "protocoldef.knight.gsp.cross.csurportcrossteam":new()
  p.teamid = self.teamid
  p.surportpoint = self.num:getText()
  require "manager.luaprotocolmanager":send(p)
  self.DestroyDialog()

end


function CrossTeampvpSupportPointDlg:HandleCancelClicked(args)
    self.DestroyDialog()
end
return CrossTeampvpSupportPointDlg
