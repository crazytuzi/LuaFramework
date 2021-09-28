TeamAroundCell = {}

setmetatable(TeamAroundCell, Dialog)
TeamAroundCell.__index = TeamAroundCell
local prefix = 1
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function TeamAroundCell.CreateNewDlg(pParentDlg)
	LogInfo("enter TeamAroundCell.CreateNewDlg")
	local newDlg = TeamAroundCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function TeamAroundCell.GetLayoutFileName()
    return "teamaroundcell.layout"
end

function TeamAroundCell:OnCreate(pParentDlg)
	LogInfo("enter TeamAroundCell oncreate")
	prefix = prefix + 1	
    Dialog.OnCreate(self, pParentDlg, prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "teamaround/back/name")
	self.m_pLevel = winMgr:getWindow(tostring(prefix) .. "teamaround/back/level")
	self.m_pNum = winMgr:getWindow(tostring(prefix) .. "teamaround/back/num")
	self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "teamaround/back/btn"))

	self.m_pBtn:subscribeEvent("Clicked",TeamAroundCell.HandleBtnClicked, self)

	LogInfo("exit TeamAroundCell OnCreate")
end

------------------- public: -----------------------------------

function TeamAroundCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamAroundCell)

    return self
end

function TeamAroundCell:Init(team)
	LogInfo("TeamAroundCell init")
	self.m_pName:setText(team.leadername)
	self.m_pLevel:setText(tostring(team.leaderlevel))
	self.m_pNum:setText(tostring(team.membernum))

	self.m_iID = team.leaderid 
end

function TeamAroundCell:HandleBtnClicked(args)
	LogInfo("TeamAroundCell handle btn clicked")
	GetTeamManager():RequestJoinOneTeam(self.m_iID)
	return true
end

return TeamAroundCell
