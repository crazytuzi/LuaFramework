CampVSItem = {}

setmetatable(CampVSItem, Dialog)
CampVSItem.__index = CampVSItem
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function CampVSItem.CreateNewDlg(pParentDlg)
	print("enter CampVSItem.CreateNewDlg")
	local newDlg = CampVSItem:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function CampVSItem.GetLayoutFileName()
    return "campvsitem.layout"
end

function CampVSItem:OnCreate(pParentDlg)
	print("enter CampVSItem oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pRank = winMgr:getWindow(tostring(prefix) .. "campvsitem/back/txt1")
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "campvsitem/back/txt3")
	self.m_pScore = winMgr:getWindow(tostring(prefix) .. "campvsitem/back/txt4")
	self.m_pPic = winMgr:getWindow(tostring(prefix) .. "campvsitem/back/touxiang")
	self.m_pBack = winMgr:getWindow(tostring(prefix) .. "campvsitem/back")

	print("exit CampVSItem OnCreate")
end

------------------- public: -----------------------------------

function CampVSItem:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampVSItem)

    return self
end

function CampVSItem:Init(rank, roleName, score, shape)
	self.m_pRank:setText(tostring(rank))
	self.m_pName:setText(roleName)	
	self.m_pScore:setText(tostring(score))
	local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shape)
	local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
	self.m_pPic:setProperty("Image", path)
	if rank == 1 then
		self.m_pBack:setProperty("Image", "set:MainControl1 image:camred")
	elseif rank == 2 then
		self.m_pBack:setProperty("Image", "set:MainControl1 image:camyellow")
	elseif rank == 3 then
		self.m_pBack:setProperty("Image", "set:MainControl1 image:camgreen")
	else
		self.m_pBack:setProperty("Image", "set:MainControl1 image:camblue")
	end
end

return CampVSItem
