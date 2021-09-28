TeamApplyCell = {}

setmetatable(TeamApplyCell, Dialog)
TeamApplyCell.__index = TeamApplyCell
local prefix = 1
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function TeamApplyCell.CreateNewDlg(pParentDlg)
	LogInfo("enter TeamApplyCell.CreateNewDlg")
	local newDlg = TeamApplyCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function TeamApplyCell.GetLayoutFileName()
    return "teamapplycell.layout"
end

function TeamApplyCell:OnCreate(pParentDlg)
	LogInfo("enter TeamApplyCell oncreate")
	prefix = prefix + 1	
    Dialog.OnCreate(self, pParentDlg, prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "teamapply/back/name")
	self.m_pSchool = winMgr:getWindow(tostring(prefix) .. "teamapply/back/school")
	self.m_pLevel = winMgr:getWindow(tostring(prefix) .. "teamapply/back/level")
	self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "teamapply/back/btn"))

	self.m_pBtn:subscribeEvent("Clicked",TeamApplyCell.HandleBtnClicked, self)

	LogInfo("exit TeamApplyCell OnCreate")
end

------------------- public: -----------------------------------

function TeamApplyCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamApplyCell)

    return self
end

function TeamApplyCell:Init(apply)
	LogInfo("TeamApplyCell init")
	self.m_pName:setText(apply.strName)
	self.m_pLevel:setText(tostring(apply.level))
	self.m_pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(apply.eSchool).name)

	self.m_iID = apply.id
end

function TeamApplyCell:HandleBtnClicked(args)
	LogInfo("TeamApplyCell handle btn clicked")
	GetTeamManager():RequestAcceptToMyTeam(self.m_iID)
	return true
end

return TeamApplyCell
