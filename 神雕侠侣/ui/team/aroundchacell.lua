AroundChaCell = {}

setmetatable(AroundChaCell, Dialog)
AroundChaCell.__index = AroundChaCell
local prefix = 1
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function AroundChaCell.CreateNewDlg(pParentDlg)
	LogInfo("enter AroundChaCell.CreateNewDlg")
	local newDlg = AroundChaCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function AroundChaCell.GetLayoutFileName()
    return "teamforcell.layout"
end

function AroundChaCell:OnCreate(pParentDlg)
	LogInfo("enter AroundChaCell oncreate")
	prefix = prefix + 1	
    Dialog.OnCreate(self, pParentDlg, prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "teamfor/back/name")
	self.m_pSchool = winMgr:getWindow(tostring(prefix) .. "teamfor/back/school")
	self.m_pLevel = winMgr:getWindow(tostring(prefix) .. "teamfor/back/level")
	self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "teamfor/back/btn"))
	self.m_pCamp = winMgr:getWindow(tostring(prefix) .. "teamfor/back/camp")

	self.m_pBtn:subscribeEvent("Clicked",AroundChaCell.HandleBtnClicked, self)

	LogInfo("exit AroundChaCell OnCreate")
end

------------------- public: -----------------------------------

function AroundChaCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AroundChaCell)

    return self
end

function AroundChaCell:Init(character)
	LogInfo("AroundChaCell init")
	self.m_pName:setText(character.roleName)
	self.m_pLevel:setText(tostring(character.roleLevel))
	self.m_pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(character.roleSchool).name)
	if character.campType == 1 then
		self.m_pCamp:setVisible(true)
		self.m_pCamp:setProperty("Image", "set:MainControl image:campred")	
	elseif character.campType == 2 then
		self.m_pCamp:setVisible(true)
		self.m_pCamp:setProperty("Image", "set:MainControl image:campblue")	
	else
		self.m_pCamp:setVisible(false)
	end
	self.m_iID = character.roleID 
end

function AroundChaCell:HandleBtnClicked(args)
	LogInfo("AroundChaCell handle btn clicked")
	GetTeamManager():RequestInviteToMyTeam(self.m_iID)
	return true
end

return AroundChaCell
