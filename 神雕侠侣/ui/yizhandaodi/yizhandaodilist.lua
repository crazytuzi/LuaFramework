require "ui.dialog"

YiZhanDaoDiListDlg = {}
setmetatable(YiZhanDaoDiListDlg, Dialog)
YiZhanDaoDiListDlg.__index = YiZhanDaoDiListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YiZhanDaoDiListDlg.getInstance()
	-- print("enter get YiZhanDaoDiListDlg dialog instance")
    if not _instance then
        _instance = YiZhanDaoDiListDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YiZhanDaoDiListDlg.getInstanceAndShow()
	-- print("enter YiZhanDaoDiListDlg dialog instance show")
    if not _instance then
        _instance = YiZhanDaoDiListDlg:new()
        _instance:OnCreate()
	else
		-- print("set YiZhanDaoDiListDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YiZhanDaoDiListDlg.getInstanceNotCreate()
    return _instance
end

function YiZhanDaoDiListDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YiZhanDaoDiListDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YiZhanDaoDiListDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function YiZhanDaoDiListDlg.GetLayoutFileName()
    return "yizhandaodilist.layout"
end

function YiZhanDaoDiListDlg:OnCreate()
	-- print("YiZhanDaoDiListDlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pList  = CEGUI.Window.toMultiColumnList(winMgr:getWindow("YizhandaodiList/PersonalInfo/list"))
	self.m_pNum   = winMgr:getWindow("YizhandaodiList/text1")
	self.m_pClose = CEGUI.Window.toPushButton(winMgr:getWindow("YizhandaodiList/get"))

    -- subscribe event
	self.m_pClose:subscribeEvent("Clicked", YiZhanDaoDiListDlg.HandleCloseBtn, self)

	-- print("YiZhanDaoDiListDlg dialog oncreate end")
end

------------------- private: -----------------------------------


function YiZhanDaoDiListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YiZhanDaoDiListDlg)
    return self
end

function YiZhanDaoDiListDlg:AddRow(id, name, num)
	self.m_pList:insertRow(id-1)
	local color = "FFFFFFFF"
	local pItem0 = CEGUI.createListboxTextItem(id)
	pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	pItem0:setID(id)
	self.m_pList:setItem(pItem0, 0, id-1)
	local pItem1 = CEGUI.createListboxTextItem(name)
	pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	pItem1:setID(id)
	self.m_pList:setItem(pItem1, 1, id-1)
	local pItem2 = CEGUI.createListboxTextItem(num)
	pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
	pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	pItem2:setID(id)
	self.m_pList:setItem(pItem2, 2, id-1)
end

function YiZhanDaoDiListDlg:Refresh(list, num)
	self.m_pNum:setText(tostring(num))
	self.m_pList:resetList()
	local yzddrankrecord = require "protocoldef.rpcgen.knight.gsp.activity.yzdd.yzddrankrecord"
	local sizeof_recordlist = list:size()
	for k = 0,sizeof_recordlist - 1 do
		local row = yzddrankrecord:new()
		row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
		-- print("row.rank = " .. row.rank)
		-- print("row.name = " .. row.name)
		-- print("row.num = " .. row.num)
		self:AddRow(row.rank, row.name, row.num)
	end
end

function YiZhanDaoDiListDlg:HandleCloseBtn(args)
	YiZhanDaoDiListDlg.DestroyDialog()
end

return YiZhanDaoDiListDlg
