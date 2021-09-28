require "ui.dialog"
TeampvpMainDlg = {}
setmetatable(TeampvpMainDlg, Dialog)
TeampvpMainDlg.__index = TeampvpMainDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpMainDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpMainDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpMainDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpMainDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpMainDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpMainDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpMainDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpMainDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpMainDlg.GetLayoutFileName()
    return "teampvpmaindlg.layout"
end
function TeampvpMainDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.buttons = {}
    self.buttons[1] = {}
    self.buttons[2] = {}
    
    self.num = {}
    self.num[1] = {}
    self.num[2] = {}
    
    for i = 0,4 do
      self.buttons[1][i] = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmaindlg/main/team" .. i))
      self.buttons[2][i] = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmaindlg/main1/team" .. i)) 
      self.buttons[1][i]:setEnabled(false)
      self.buttons[2][i]:setEnabled(false)
      self.buttons[1][i]:subscribeEvent("Clicked",TeampvpMainDlg.HandleEditClicked,self)
      self.buttons[2][i]:subscribeEvent("Clicked",TeampvpMainDlg.HandleEditClicked,self)
      if i ~= 4 then
        self.num[1][i] = winMgr:getWindow("teampvpmaindlg/main0/num" .. i)
        self.num[2][i] = winMgr:getWindow("teampvpmaindlg/main/num" .. i)
        self.num[1][i]:setText("")
        self.num[2][i]:setText("")
      end
    end
    
  --  self.time = winMgr:getWindow("teampvpmaindlg/time")
    
	self.leftWin = winMgr:getWindow("teampvpmaindlg/main0/win")
	self.rightWin = winMgr:getWindow("teampvpmaindlg/main1/win")

	self.leftWin:setVisible(false)
	self.rightWin:setVisible(false)

	self.timeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpmaindlg/timeinfo"))
	self.timeBtn:subscribeEvent("Clicked",TeampvpMainDlg.ShowTime,self)

	self.leftWinName = winMgr:getWindow("teampvpmaindlg/name1")
	self.rightWinName = winMgr:getWindow("teampvpmaindlg/name12")


end

------------------- private: -----------------------------------
function TeampvpMainDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpMainDlg)
    return self
end

function TeampvpMainDlg:HandleEditClicked(args)
  local e = CEGUI.toWindowEventArgs(args)
  local id = e.window:getID()
  local p = require("protocoldef.knight.gsp.faction.creqfactionteaminfo"):new()
  p.teamid = id
  LuaProtocolManager.getInstance():send(p)
   
end
function TeampvpMainDlg.compare(ob1,ob2)
  if ob1.fightscore == ob2.fightscore  then
    return false
  elseif ob1.fightscore > ob2.fightscore  then
    return true
  else
    return false
  end
end


function TeampvpMainDlg:Process(trimbleteams,leagueteams,nexttime,leagueteamid,trimbleteamid,leaguescore ,trimblescore,guanjunid)
  if #trimbleteams > 1 then
    table.sort(trimbleteams,TeampvpMainDlg.compare)
  end
  
  if #leagueteams > 1 then
    table.sort(leagueteams,TeampvpMainDlg.compare)
  end
  for i = 1,4 do
    if i<= #trimbleteams then
      self.buttons[1][i-1]:setText(trimbleteams[i].teamname)
      self.num[1][i-1]:setText(trimbleteams[i].fightscore)
      self.buttons[1][i-1]:setEnabled(true)
      self.buttons[1][i-1]:setID(trimbleteams[i].teamid) 
      if trimbleteams[i].teamid == trimbleteamid then
        self.leftWinName:setText(trimbleteams[i].teamname)
        self.buttons[1][4]:setEnabled(true)
		self.buttons[1][4]:setID(trimbleteams[i].teamid)
      end
	  if trimbleteams[i].teamid == guanjunid then
		self.leftWin:setVisible(true)
	  end
    end
    
    if i <= #leagueteams then
       self.buttons[2][i-1]:setText(leagueteams[i].teamname)
       self.buttons[2][i-1]:setEnabled(true)
       self.num[2][i-1]:setText(leagueteams[i].fightscore)
       self.buttons[2][i-1]:setID(leagueteams[i].teamid) 
       if leagueteams[i].teamid == leagueteamid then
          self.rightWinName:setText(leagueteams[i].teamname)
          self.buttons[2][4]:setEnabled(true)
		  self.buttons[2][4]:setID(leagueteams[i].teamid)
       end
	   if leagueteams[i].teamid == guanjunid then
			self.rightWin:setVisible(true)
	   end
    end
  end
end

function TeampvpMainDlg:ShowTime(args)
--	require "ui.teampvp.teampvptimeinfodlg".getInstanceAndShow()
	require "manager.luaprotocolmanager":send(require  "protocoldef.knight.gsp.faction.cbattletable" : new())

end

return TeampvpMainDlg
