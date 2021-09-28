CrossCellFour = {}

setmetatable(CrossCellFour, Dialog)
CrossCellFour.__index = CrossCellFour
local id = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function CrossCellFour.CreateNewDlg(pParentDlg, id)
	LogInfo("enter CrossCellFour.CreateNewDlg")
	local newDlg = CrossCellFour:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function CrossCellFour.GetLayoutFileName()
    return "huashanzhidianxuanzhancell1.layout"
end

function CrossCellFour:OnCreate(pParentDlg, id)
	LogInfo("enter CrossCellFour oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_btns = {}
	self.m_btns[1] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/btn")
	self.m_btns[2] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/btn1")
	self.m_btns[3] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/btn2")
	self.m_btns[4] = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/btn3")

	self.m_btns[1].m_text = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/txt")
	self.m_btns[2].m_text = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/txt1")
	self.m_btns[3].m_text = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/txt2")
	self.m_btns[4].m_text = winMgr:getWindow(tostring(id) .. "huashanzhidiaxuanzhancell1/back/img/txt3")

	for i,v in ipairs(self.m_btns) do
		v:setText("")
		v.m_text:setText("")
	end

	self.m_width = self:GetWindow():getPixelSize().width
	
	self.pWnd = self:GetWindow()

	LogInfo("exit CrossCellFour OnCreate")
end

------------------- public: -----------------------------------

function CrossCellFour:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CrossCellFour)

    return self
end

return CrossCellFour
