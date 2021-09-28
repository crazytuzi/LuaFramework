CrossCellTwo = {}

setmetatable(CrossCellTwo, Dialog)
CrossCellTwo.__index = CrossCellTwo
local id = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function CrossCellTwo.CreateNewDlg(pParentDlg, id)
	LogInfo("enter CrossCellTwo.CreateNewDlg")
	local newDlg = CrossCellTwo:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function CrossCellTwo.GetLayoutFileName()
    return "huashanzhidianxuanzhancell2.layout"
end

function CrossCellTwo:OnCreate(pParentDlg, id)
	LogInfo("enter CrossCellTwo oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_btns = {}
	self.m_btns[1] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell2/back/img/btn1")
	self.m_btns[2] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell2/back/img/btn2")

	for i,v in ipairs(self.m_btns) do
		v:setText("")
	end

	self.m_width = self:GetWindow():getPixelSize().width
	
	self.pWnd = self:GetWindow()

	LogInfo("exit CrossCellTwo OnCreate")
end

------------------- public: -----------------------------------

function CrossCellTwo:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CrossCellTwo)

    return self
end

return CrossCellTwo
