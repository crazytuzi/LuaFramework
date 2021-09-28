require "ui.dialog"
TeampvpMatchDlg = {}
setmetatable(TeampvpMatchDlg, Dialog)
TeampvpMatchDlg.__index = TeampvpMatchDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpMatchDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpMatchDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpMatchDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpMatchDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpMatchDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpMatchDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpMatchDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpMatchDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpMatchDlg.GetLayoutFileName()
    return "teampvpmatchdlg.layout"
end
function TeampvpMatchDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.currChangci = winMgr:getWindow("teampvpmatchdlg/txt")
    self.currChangci:setText("")
    
    
    self.team1Name = winMgr:getWindow("teampvpmatchdlg/info0")
    self.team1Name:setText("")
    
    self.team2Name = winMgr:getWindow("teampvpmatchdlg/info1")
    self.team2Name:setText("")
    
    self.remainTime = winMgr:getWindow("teampvpmatchdlg/time")
    self.remainTime:setText("")
    
    self.team1winTimes = winMgr:getWindow("teampvpmatchdlg/line111")
    self.team1winTimes:setProperty("Image","set:MainControl1 image:0")
    
    self.team2winTimes = winMgr:getWindow("teampvpmatchdlg/line11")
    self.team2winTimes:setProperty("Image","set:MainControl1 image:0")
    
    
    self.ok = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmatchdlg/ok"))
    self.ok:subscribeEvent("Clicked",TeampvpMatchDlg.HandleClicked,self)
  --  self.ok:setEnabled(false)
 
	self.ok1 = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmatchdlg/ok1"))
    self.ok1:subscribeEvent("Clicked",TeampvpMatchDlg.HandlerCloseEvent,self)

    self.tickRemainTime = 0
	
end

------------------- private: -----------------------------------
function TeampvpMatchDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpMatchDlg)
    return self
end
function TeampvpMatchDlg:HandleClicked(args)
    local p = require "protocoldef.knight.gsp.faction.creadyteamfight":new()
    require "manager.luaprotocolmanager":send(p)
    self.ok:setEnabled(false)
end
function TeampvpMatchDlg:Process(remainTime,team1Name,team1winTimes,team2Name,team2winTimes,currChangci,dzxl,flag)


  if team1Name then
     self.team1Name:setText(team1Name)
  end
  
  if tonumber(team1winTimes) and team1winTimes >0 and team1winTimes < 10 then
    self.team1winTimes:setProperty("Image","set:MainControl1 image:" .. team1winTimes)
  end
  
  if team2Name then
    self.team2Name:setText(team2Name)
  end
  
  if tonumber(team2winTimes) and team2winTimes and team2winTimes < 10 then
    self.team2winTimes:setProperty("Image","set:MainControl1 image:" .. team2winTimes)
  end

  if tonumber(currChangci) and currChangci >= 0 then
    self.currChangci:setText(currChangci .. " / 3")
  end

  self.tick = 0 
  self.tickRemainTime = 0
  if flag == 1 then
      if tonumber(remainTime) and remainTime > 0 then 
          self.remainTime:setText(string.format("%02d:%02d:%02d",math.floor(self.tickRemainTime / 1000 / 3600 ), math.floor(self.tickRemainTime / 1000 % 3600 / 60  % 100), math.floor(self.tickRemainTime / 1000 % 3600 % 60)))
          self.tickRemainTime =  remainTime
          self.ok:setEnabled(false)
      end
  else
      self.ok:setEnabled(true)
  end
end

function TeampvpMatchDlg:run(delta)
  self.tick = self.tick + delta
  if self.tick >= 1000  and self.tickRemainTime > 1000 then
     self.tick = self.tick -1000
     self.tickRemainTime = self.tickRemainTime - 1000
     self.remainTime:setText(string.format("%02d:%02d:%02d",math.floor(self.tickRemainTime / 1000 / 3600 ), math.floor(self.tickRemainTime / 1000 % 3600 / 60  % 100), math.floor(self.tickRemainTime / 1000 % 3600 % 60)))
  elseif self.tick >= 1000 and self.tickRemainTime > 0 and self.ok:isDisabled() then
     self.tick = self.tick -1000
     self.tickRemainTime = 0
  -- self.ok:setEnabled(true)
     self.remainTime:setText("00:00:00")
  end
end

function TeampvpMatchDlg.refresh(time)
    if _instance ~= nil then
      _instance.tickRemainTime = time
      _instance.ok:setEnabled(false)
    end
end

function TeampvpMatchDlg:HandlerCloseEvent(args)
	self.DestroyDialog()
end
return TeampvpMatchDlg
