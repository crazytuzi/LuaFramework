require "ui.dialog"
TeampvpShowDlg = {}
setmetatable(TeampvpShowDlg, Dialog)
TeampvpShowDlg.__index = TeampvpShowDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpShowDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpShowDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpShowDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpShowDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpShowDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpShowDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpShowDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpShowDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpShowDlg.GetLayoutFileName()
    return "teampvpshowdlg.layout"
end
function TeampvpShowDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.pane = CEGUI.Window.toScrollablePane(winMgr:getWindow("teampvpshowdlg/back/main"))
	  self.refresh = CEGUI.Window.toPushButton(winMgr:getWindow("teampvpshowdlg/refresh"))
	  self.refresh:subscribeEvent("Clicked",TeampvpShowDlg.HandleClicked,self)
	  self.cells = {}
	  self.battleinfo = {}
end

------------------- private: -----------------------------------
function TeampvpShowDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpShowDlg)
    return self
end
function TeampvpShowDlg:HandleClicked(args)
  require"manager.luaprotocolmanager":send(require "protocoldef.knight.gsp.faction.creqbattleinfo":new())
end


function TeampvpShowDlg:Process(battleinfo)
print("sssssss",#battleinfo)
  local winMgr = CEGUI.WindowManager:getSingleton()
  self.battleinfo = battleinfo
  if #battleinfo > 0 then
    for i = 1 , #battleinfo do
      if self.cells[i] == nil then
        self.cells[i] = self:CreateNewCell(i)
      end
      local teamname1 = winMgr:getWindow(i .. "teampvpshowcell/back/left0")
      local teamname2 = winMgr:getWindow(i .. "teampvpshowcell/back/right0")
      local mask = winMgr:getWindow(i .. "teampvpshowcell/back/mark0")
      teamname1:setText(battleinfo[i].teamname1)
      teamname2:setText(battleinfo[i].teamname2)
      
      local watchBtn = CEGUI.Window.toPushButton(winMgr:getWindow(i .. "teampvpshowcell/back/btn0"))
      watchBtn:subscribeEvent("Clicked",TeampvpShowDlg.ItemClick,self)
      watchBtn:setID(i)
	
    
      if battleinfo[i].flag == 1 then
		mask:setProperty("Image","set:MainControl25 image:ing")
	  elseif  battleinfo[i].flag == 2 then
		mask:setProperty("Image","set:MainControl25 image:over")
	  else
		mask:setProperty("Image","set:MainControl25 image:off")		
      end
      
      self.cells[i]:setVisible(true)
    end
    local len = #battleinfo
    while len < #self.cells do
      len = len + 1
      self.cells[len]:setVisible(false)
    end
  end
end

function TeampvpShowDlg:CreateNewCell(id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local cell = winMgr:loadWindowLayout("teampvpshowcell.layout",id)
    self.pane:addChildWindow(cell)
    local x , y ,foo
    if id % 2 == 1 then 
      x = 3
      foo = (id -1) / 2
     else 
      x = 393 
      foo = id / 2 - 1
     end
    y = foo*100 + 1
    cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,x),CEGUI.UDim(0,y)))
    return cell
end

function TeampvpShowDlg:ItemClick(args)
  local p = require "protocoldef.knight.gsp.faction.cwatchbattle":new()
  p.watchid = self.battleinfo[CEGUI.toWindowEventArgs(args).window:getID()].watchid
  require "manager.luaprotocolmanager":send(p)
end
return TeampvpShowDlg
