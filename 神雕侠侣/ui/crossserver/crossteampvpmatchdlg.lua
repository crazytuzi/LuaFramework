require "ui.dialog"
CrossTeampvpMatchDlg = {}
setmetatable(CrossTeampvpMatchDlg, Dialog)
CrossTeampvpMatchDlg.__index = CrossTeampvpMatchDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CrossTeampvpMatchDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = CrossTeampvpMatchDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CrossTeampvpMatchDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = CrossTeampvpMatchDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CrossTeampvpMatchDlg.getInstanceNotCreate()
    return _instance
end

function CrossTeampvpMatchDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function CrossTeampvpMatchDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CrossTeampvpMatchDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function CrossTeampvpMatchDlg.GetLayoutFileName()
    return "teampvpmatchdlg.layout"
end
function CrossTeampvpMatchDlg:OnCreate()
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
    self.ok:subscribeEvent("Clicked",CrossTeampvpMatchDlg.HandleClicked,self)
  --  self.ok:setEnabled(false)
 
	self.ok1 = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmatchdlg/ok1"))
    self.ok1:subscribeEvent("Clicked",CrossTeampvpMatchDlg.HandlerCloseEvent,self)

    self.tickRemainTime = 0
	
end

------------------- private: -----------------------------------
function CrossTeampvpMatchDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CrossTeampvpMatchDlg)
    return self
end
function CrossTeampvpMatchDlg:HandleClicked(args)
    local p = require "protocoldef.knight.gsp.cross.ccrossreadyfight":new()
    require "manager.luaprotocolmanager":send(p)
    self.ok:setEnabled(false)
end
function CrossTeampvpMatchDlg:Process(remainTime,team1Name,team1winTimes,team2Name,team2winTimes,currChangci,flag)

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
    self.currChangci:setText(currChangci .. " / 5")
  end

  self.tick = 0 
  self.tickRemainTime = 0
  self.remainTime:setText(string.format("%02d:%02d:%02d",math.floor(remainTime / 1000 / 3600 ), 
      math.floor(remainTime / 1000 % 3600 / 60  % 100), math.floor(remainTime / 1000 % 3600 % 60)))

  if flag == 1 then
      if tonumber(remainTime) and remainTime > 0 then 
          self.tickRemainTime =  remainTime
          self.ok:setEnabled(false)
      end
  elseif flag == 0 then
      self.ok:setEnabled(true)
  elseif flag == 2 then
      if tonumber(remainTime) and remainTime > 0 then 
          self.tickRemainTime =  remainTime
          self.ok:setEnabled(true)
      end
  end
end

function CrossTeampvpMatchDlg:run(delta)
  self.tick = self.tick + delta
  if self.tick >= 1000  and self.tickRemainTime > 1000 then
     self.tick = self.tick -1000
     self.tickRemainTime = self.tickRemainTime - 1000
     self.remainTime:setText(string.format("%02d:%02d:%02d",math.floor(self.tickRemainTime / 1000 / 3600 ), math.floor(self.tickRemainTime / 1000 % 3600 / 60  % 100), math.floor(self.tickRemainTime / 1000 % 3600 % 60)))
  elseif self.tick >= 1000 and self.tickRemainTime > 0 and self.ok:isDisabled() then
     self.tick = self.tick -1000
     self.tickRemainTime = 0
     self.remainTime:setText("00:00:00")
  end
end

function CrossTeampvpMatchDlg.refresh(time)
    if _instance ~= nil then
      _instance.tickRemainTime = time
      _instance.ok:setEnabled(false)
    end
end

function CrossTeampvpMatchDlg:HandlerCloseEvent(args)
	self.DestroyDialog()
end
return CrossTeampvpMatchDlg
