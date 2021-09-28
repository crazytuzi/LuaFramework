require "ui.dialog"
TeampvpInfoDlg = {}
setmetatable(TeampvpInfoDlg, Dialog)
TeampvpInfoDlg.__index = TeampvpInfoDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpInfoDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpInfoDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpInfoDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpInfoDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpInfoDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpInfoDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpInfoDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpInfoDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpInfoDlg.GetLayoutFileName()
    return "teampvpinfodlg.layout"
end
function TeampvpInfoDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	 
	  self.hassurportpoint = winMgr:getWindow("teampvpinfodlg/info/point1")
	  self.hassurportpoint:setText("")
	  
	  self.remainpoints = winMgr:getWindow("teampvpinfodlg/info/point2")
	  self.remainpoints:setText("")
	  
	  self.supportBtn = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpinfodlg/btn"))
	  self.supportBtn:subscribeEvent("Clicked",TeampvpInfoDlg.HandleEditClicked,self)
	
	  self.teamname = winMgr:getWindow("teampvpinfodlg/right/name")
	  self.teamname:setText("")
	  
	  self.zhzl = winMgr:getWindow("teampvpinfodlg/right/num1")
    self.zhzl:setText("")
    
    self.factionname = winMgr:getWindow("teampvpinfodlg/right/family")
    self.factionname:setText("")
    
    self.renqi = winMgr:getWindow("teampvpinfodlg/right/num2")
    self.renqi:setText("")
    
    self.shenglv = winMgr:getWindow("teampvpinfodlg/info/per")
    self.shenglv:setText("")
    
    self.score = winMgr:getWindow("teampvpinfodlg/info/point0")
    self.score:setText("")
    
	  self.infoPic = {}
	  self.infoSchool = {}
	  self.infoLevel = {}
	  self.infoName = {}
	  self.infoCamp = {}
	  self.infoGroup = {}
	  
	  for i = 0 , 4 do
	    self.infoGroup[i] = CEGUI.Window.toGroupButton(winMgr:getWindow("teampvpinfodlg/back/btn" .. i))
	    self.infoGroup[i]:setVisible(false)

      
      self.infoPic[i] = winMgr:getWindow("teampvpinfodlg/back/pic" .. i)     
   
      self.infoSchool[i] = winMgr:getWindow("teampvpinfodlg/back/school" .. i)
      self.infoSchool[i]:setText("")
      
      self.infoLevel[i] = winMgr:getWindow("teampvpinfodlg/back/level" .. i)
      self.infoLevel[i]:setText("")
      
      self.infoName[i] = winMgr:getWindow("teampvpinfodlg/back/name" .. i)
      self.infoName[i]:setText("")
      
      self.infoCamp[i] = winMgr:getWindow("teampvpinfodlg/back/btn/camp" .. i)
	    self.infoCamp[i]:setVisible(false)
	  end
	  self.teamMemInfo = {}
	  
end

------------------- private: -----------------------------------
function TeampvpInfoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpInfoDlg)
    return self
end

function TeampvpInfoDlg:ShowRoleDetail(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    if self.teamMemInfo[id] ~= nil then
      GetFriendsManager():SetContactRole(self.teamMemInfo[id].roleid,self.teamMemInfo[id].rolename,self.teamMemInfo[id].level,self.teamMemInfo[id].camp)
    end

end
function TeampvpInfoDlg:HandleEditClicked(args)
    require "ui.teampvp.teampvpsupportpointdlg"
    TeampvpSupportPointDlg.ToggleOpenClose()
    if TeampvpSupportPointDlg.getInstanceNotCreate() ~= nil then
      TeampvpSupportPointDlg.getInstanceNotCreate().teamid = self.teamid
	  if tonumber(self.remainpoints:getText()) then
		TeampvpSupportPointDlg.getInstanceNotCreate().remainpoints = tonumber(self.remainpoints:getText())
	  end
	end
end


function TeampvpInfoDlg:Process(zcflag,teammemberinfo,teamname,factionname,shenglv,score,zhzl,renqi,hassurportpoint,remainpoints,teamid)
  self.teamid = teamid
  if zcflag == 0 then
    self.supportBtn:setEnabled(true)
  else
    self.supportBtn:setEnabled(false)
  end
  
  if hassurportpoint then
    self.hassurportpoint:setText(hassurportpoint)
  end
  
  self.point = remainpoints
  if remainpoints then
    self.remainpoints:setText(remainpoints)
  end
  
  
  if teamname then
    self.teamname:setText(teamname)
  end
  
  if zhzl then
    self.zhzl:setText(zhzl)
  end
  
  if factionname then
    self.factionname:setText(factionname)
  end
  
  if renqi then
    self.renqi:setText(renqi)
  end
  
  if shenglv then
    self.shenglv:setText(shenglv)
  end
  
  if score then
    self.score:setText(score)
  end
  
  self.teamMemInfo = teammemberinfo
  
  
  for i = 0,#teammemberinfo -1 do
      local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(teammemberinfo[i+1].shape)
      local path = GetIconManager():GetImagePathByID(headshape.headID):c_str()

      self.infoGroup[i]:setVisible(true)
      self.infoGroup[i]:subscribeEvent("SelectStateChanged",TeampvpInfoDlg.ShowRoleDetail,self)
      self.infoGroup[i]:setID(i+1)
       
      self.infoPic[i]:setProperty("Image", path)
      self.infoSchool[i]:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(teammemberinfo[i+1].school).name)
      self.infoLevel[i]:setText(teammemberinfo[i+1].level)
      self.infoName[i]:setText(teammemberinfo[i+1].rolename)
      if teammemberinfo[i+1].camp == 1 then
        self.infoCamp[i]:setProperty("Image", "set:MainControl image:campred")
        self.infoCamp[i]:setVisible(true)
      elseif teammemberinfo[i+1].camp == 2 then
        self.infoCamp[i]:setProperty("Image", "set:MainControl image:campblue")
        self.infoCamp[i]:setVisible(true)
      else
        self.infoCamp[i]:setVisible(false)
      end
  end
  
end


return TeampvpInfoDlg
