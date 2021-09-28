require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.ranklist.creqcamprank"

CampRankListDlg = {}
setmetatable(CampRankListDlg, Dialog)
CampRankListDlg.__index = CampRankListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampRankListDlg.getInstance()
	LogInfo("enter get CampRankListDlg instance")
    if not _instance then
        _instance = CampRankListDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampRankListDlg.getInstanceAndShow()
	LogInfo("enter CampRankListDlg instance show")
    if not _instance then
        _instance = CampRankListDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set CampRankListDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampRankListDlg.getInstanceNotCreate()
    return _instance
end

function CampRankListDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy CampRankListDlg")
		_instance:OnClose()
		_instance = nil
	end
end

function CampRankListDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampRankListDlg:new() 
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

function CampRankListDlg.GetLayoutFileName()
    return "campranklistdlg.layout"
end

function CampRankListDlg:OnCreate()
	LogInfo("CampRankListDlg oncreate begin")

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pTitle = winMgr:getWindow("campranklist/title")
	self.m_pMain = CEGUI.Window.toMultiColumnList(winMgr:getWindow("campranklist/main"))
	self.m_pScore = winMgr:getWindow("campranklist/info1")
	self.m_pMyTitle = winMgr:getWindow("campranklist/info2")
	self.m_pPrePageBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campranklist/up"))
	self.m_pNextPageBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campranklist/up1"))

	self.m_pPrePageBtn:subscribeEvent("Clicked", CampRankListDlg.HandlePrePageClicked, self)
	self.m_pNextPageBtn:subscribeEvent("Clicked", CampRankListDlg.HandleNextPageClicked, self)

	self.m_iCurPage = 0

	LogInfo("CampRankListDlg oncreate end")
end

------------------- private: -----------------------------------


function CampRankListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampRankListDlg)
    return self
end

function CampRankListDlg:HandlePrePageClicked(args)
	LogInfo("CampRankListDlg handle pre page clicked")
	local reqRank = CReqCampRank.Create()
	reqRank.camp = self.m_iCamp
	reqRank.page = self.m_iCurPage - 1
	LuaProtocolManager.getInstance():send(reqRank)
end

function CampRankListDlg:HandleNextPageClicked(args)
	LogInfo("CampRankListDlg handle next page clicked")
	local reqRank = CReqCampRank.Create()
	reqRank.camp = self.m_iCamp
	reqRank.page = self.m_iCurPage + 1
	LuaProtocolManager.getInstance():send(reqRank)
end

function CampRankListDlg:refreshInfo(page, hasmore, camp, myscore, mytitle, recordlist)
	LogInfo("CampRankListDlg refresh list")
	self.m_iCurPage = page
	self.m_iCamp = camp
	if camp == 1 then
		self.m_pTitle:setText(MHSD_UTILS.get_resstring(2839))
	else
		self.m_pTitle:setText(MHSD_UTILS.get_resstring(2840))
	end
	self.m_pScore:setText(tostring(myscore))

	if mytitle == "" then
		self.m_pMyTitle:setText(MHSD_UTILS.get_resstring(511))
	else
		self.m_pMyTitle:setText(mytitle)
	end

	self.m_lRecordList = recordlist

	if page == 0 then
		self.m_pPrePageBtn:setEnabled(false)
	else
		self.m_pPrePageBtn:setEnabled(true)
	end
	if hasmore == 1 then
		self.m_pNextPageBtn:setEnabled(false)
	else
		self.m_pNextPageBtn:setEnabled(true)
	end

	self:refreshList()
end

function CampRankListDlg:refreshList()
	LogInfo("CampRankListDlg refresh list")
	self.m_pMain:resetList()
	local num = 0
	for i,v in pairs(self.m_lRecordList) do
		self.m_pMain:addRow(num)

		local pItem0 = CEGUI.createListboxTextItem(tostring(v.index))	
		pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)

		local pItem1 = CEGUI.createListboxTextItem(v.rolename)	
		pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)

		local pItem2 = CEGUI.createListboxTextItem(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name)
		pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)

		local pItem3 = CEGUI.createListboxTextItem(tostring(v.level))
		pItem3:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem3:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		
		local pItem4 = CEGUI.createListboxTextItem(tostring(v.score))
		pItem4:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem4:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)

		local pItem5 = CEGUI.createListboxTextItem(v.title)
		pItem5:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		pItem5:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)

		self.m_pMain:setItem(pItem0, 0, num)
		self.m_pMain:setItem(pItem1, 1, num)
		self.m_pMain:setItem(pItem2, 2, num)
		self.m_pMain:setItem(pItem3, 3, num)
		self.m_pMain:setItem(pItem4, 4, num)
		self.m_pMain:setItem(pItem5, 5, num)

		num = num + 1
	end
end

return CampRankListDlg
