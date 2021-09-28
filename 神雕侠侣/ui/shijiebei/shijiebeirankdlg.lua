require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

ShijiebeiRankDialog = {}
setmetatable(ShijiebeiRankDialog, Dialog)
ShijiebeiRankDialog.__index = ShijiebeiRankDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ShijiebeiRankDialog.getInstance()
	LogInfo("enter get ShijiebeiRankDialog instance")
    if not _instance then
        _instance = ShijiebeiRankDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ShijiebeiRankDialog.getInstanceAndShow()
	LogInfo("enter ShijiebeiRankDialog instance show")
    if not _instance then
        _instance = ShijiebeiRankDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set ShijiebeiRankDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ShijiebeiRankDialog.getInstanceNotCreate()
    return _instance
end

function ShijiebeiRankDialog.DestroyDialog()
	require "ui.shijiebei.shijiebeilabel".DestroyDialog()
	if _instance then
		LogInfo("destroy ShijiebeiRankDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function ShijiebeiRankDialog.GetLayoutFileName()
    return "rankinglistshijiebei.layout"
end

function ShijiebeiRankDialog:OnCreate()
	LogInfo("ShijiebeiRankDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.m_pMain = CEGUI.Window.toMultiColumnList(winMgr:getWindow("SjbRankingList/PersonalInfo/list"))
	self.m_pMain:setUserSortControlEnabled(false)

	LogInfo("ShijiebeiRankDialog oncreate end")
end

------------------- private: -----------------------------------
function ShijiebeiRankDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShijiebeiRankDialog)
    return self
end

function ShijiebeiRankDialog:SetRankData(rank)
	LogInfo("ShijiebeiLabel:SetRankData")

	self.m_pMain:resetList()

	local record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(38)
	self.m_pMain:getListHeader():getSegmentFromColumn(0):setText(record.name1)
	self.m_pMain:setColumnHeaderWidth(0, CEGUI.UDim(record.kuandu1, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(1):setText(record.name2)
	self.m_pMain:setColumnHeaderWidth(1, CEGUI.UDim(record.kuandu2, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(2):setText(record.name3)
	self.m_pMain:setColumnHeaderWidth(2, CEGUI.UDim(record.kuandu3+0.1, 0))

	local color = "FFFFFFFF"
 	local configSjb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshijiebeishangcheng")
	local configItem = knight.gsp.item.GetCItemAttrTableInstance()

	local sortFunc = function(a, b)
	 return a["num"] > b["num"]
	end
	table.sort(rank, sortFunc)

	for i=1, #rank do
		self.m_pMain:addRow(i-1)

		local pItem = CEGUI.createListboxTextItem(tostring(i))
		pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		self.m_pMain:setItem(pItem, 0, i-1)

		local itemid = configSjb:getRecorder(rank[i].id).itemid
		local itemname = configItem:getRecorder(itemid).name
		pItem = CEGUI.createListboxTextItem(itemname)
		pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		self.m_pMain:setItem(pItem, 1, i-1)

		pItem = CEGUI.createListboxTextItem(tostring(rank[i].num))
		pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		self.m_pMain:setItem(pItem, 2, i-1)
	end
end

return ShijiebeiRankDialog
