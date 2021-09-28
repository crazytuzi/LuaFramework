require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

WeddingRankDialog = {}
setmetatable(WeddingRankDialog, Dialog)
WeddingRankDialog.__index = WeddingRankDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WeddingRankDialog.getInstance()
	LogInfo("enter get WeddingRankDialog instance")
    if not _instance then
        _instance = WeddingRankDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WeddingRankDialog.getInstanceAndShow()
	LogInfo("enter WeddingRankDialog instance show")
    if not _instance then
        _instance = WeddingRankDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set WeddingRankDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WeddingRankDialog.getInstanceNotCreate()
    return _instance
end

function WeddingRankDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy WeddingRankDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function WeddingRankDialog.GetLayoutFileName()
    return "marrylist.layout"
end

function WeddingRankDialog:OnCreate()
	LogInfo("WeddingRankDialog oncreate begin")
  Dialog.OnCreate(self)

  local winMgr = CEGUI.WindowManager:getSingleton()
  self.m_pMain = CEGUI.Window.toMultiColumnList(winMgr:getWindow("marrylist/PersonalInfo/list"))
  self.m_pMain:setUserSortControlEnabled(false)

  self.m_num =  winMgr:getWindow("marrylist/fanye")
  self.m_tips = winMgr:getWindow("marrylist/personalrank")
  self.m_btnUp = CEGUI.Window.toPushButton(winMgr:getWindow("marrylist/up"))
  self.m_btnDown = CEGUI.Window.toPushButton(winMgr:getWindow("marrylist/down"))
  
  self.m_btnUp:subscribeEvent("Clicked", WeddingRankDialog.HandleUpClicked, self)
  self.m_btnDown:subscribeEvent("Clicked", WeddingRankDialog.HandleDownClicked, self)
	self.m_curPage = 1
	self.m_totalPage = 1
	LogInfo("WeddingRankDialog oncreate end")
end

------------------- private: -----------------------------------
function WeddingRankDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WeddingRankDialog)
    return self
end

function WeddingRankDialog:HandleUpClicked(args)
    LogInfo("WeddingRankDialog HandleUpClicked()")
    if self.m_curPage == 1 then
      return
    end
    
    self.m_curPage = self.m_curPage - 1
    require "protocoldef.knight.gsp.marry.cfamilylist"
    local p = CFamilyList.Create()
    p.pageindex = self.m_curPage
    require "manager.luaprotocolmanager":send(p)
end

function WeddingRankDialog:HandleDownClicked(args)
    LogInfo("WeddingRankDialog HandleDownClicked()")
    if self.m_totalPage == self.m_curPage then
      return
    end
    
    self.m_curPage = self.m_curPage + 1
    require "protocoldef.knight.gsp.marry.cfamilylist"
    local p = CFamilyList.Create()
    p.pageindex = self.m_curPage
    require "manager.luaprotocolmanager":send(p)
end

function WeddingRankDialog:SetRank(rank)
    LogInfo("WeddingRankDialog SetRank()")
    
    self.m_curPage = rank.currpageno
    self.m_totalPage = rank.totalpageno
    
    self.m_btnUp:setEnabled(true)
    self.m_btnDown:setEnabled(true)
    
    if self.m_curPage == 1 then
      self.m_btnUp:setEnabled(false)
    end
    if self.m_totalPage == self.m_curPage then
      self.m_btnDown:setEnabled(false)
    end

    self.m_num:setText(string.format("%d/%d", self.m_curPage, self.m_totalPage))    

    local curindex = (rank.currpageno-1)*rank.shownum

    --set rank string
    local msg = ""
    if 0 == rank.rank then
        msg = MHSD_UTILS.get_resstring(3113)
    else
        local formatstr = MHSD_UTILS.get_resstring(3114)
        local sb = require "utils.stringbuilder":new()
        sb:Set("parameter1", tostring(rank.rank) or " ")
        msg = sb:GetString(formatstr)
        sb:delete()
    end
    self.m_tips:setText(msg)

    --reset wedding list
    self.m_pMain:resetList()

    local record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(39)
    self.m_pMain:getListHeader():getSegmentFromColumn(0):setText(record.name1)
    self.m_pMain:setColumnHeaderWidth(0, CEGUI.UDim(record.kuandu1, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(1):setText(record.name2)
    self.m_pMain:setColumnHeaderWidth(1, CEGUI.UDim(record.kuandu2, 0))
    self.m_pMain:getListHeader():getSegmentFromColumn(2):setText(record.name3)
    self.m_pMain:setColumnHeaderWidth(2, CEGUI.UDim(record.kuandu3, 0))

    for i=1, #rank.family do

        --default color
        local color = "FFFFFFFF"

        if i == rank.rank then
            color = "FF33FF33"
        end

        if self.m_curPage == 1 then
          if i == 1 then
              color = "FFFF1493"
          elseif i == 2 or i == 3 then
              color = "FFFFA500"
          end
        end

        self.m_pMain:addRow(i-1)

        local pItem = CEGUI.createListboxTextItem(tostring(curindex + i))
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
        pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
        self.m_pMain:setItem(pItem, 0, i-1)

        pItem = CEGUI.createListboxTextItem(rank.family[i].man)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
        pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
        self.m_pMain:setItem(pItem, 1, i-1)

        pItem = CEGUI.createListboxTextItem(rank.family[i].woman)
        pItem:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
        pItem:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
        self.m_pMain:setItem(pItem, 2, i-1)
    end
end

return WeddingRankDialog
