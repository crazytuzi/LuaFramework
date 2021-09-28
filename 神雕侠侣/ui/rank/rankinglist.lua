require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "protocoldef.knight.gsp.ranklist.crequestranklist"
require "protocoldef.rpcgen.knight.gsp.ranklist.ranktype"
require "protocoldef.rpcgen.knight.gsp.ranklist.levelrankdata"
require "protocoldef.rpcgen.knight.gsp.ranklist.petgraderankdata"
require "protocoldef.rpcgen.knight.gsp.ranklist.camprecordbean"
require "protocoldef.rpcgen.knight.gsp.ranklist.marshalxiakescorerecord"
require "protocoldef.rpcgen.knight.gsp.ranklist.factionrankrecord"
require "protocoldef.rpcgen.knight.gsp.ranklist.rolezongherankrecord"
require "protocoldef.rpcgen.knight.gsp.ranklist.flowerrankdata"
require "protocoldef.knight.gsp.ranklist.creqrankaward"
require "protocoldef.rpcgen.knight.gsp.ranklist.activeroserankrecord"
require "protocoldef.rpcgen.knight.gsp.activity.yibaiceng.yibaicengrankrecord"
require "protocoldef.rpcgen.knight.gsp.ranklist.swornrecord"
require "protocoldef.rpcgen.knight.gsp.ranklist.shiderankrecord"

local FIRST_COLOR = "[border='FF5F5033'][colrect='tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751']"
RankingList = {}
setmetatable(RankingList, Dialog)
RankingList.__index = RankingList 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local typeEnum = RankType:new()  
function RankingList.getInstance()
	LogInfo("enter getfriendsdialoginstance")
    if not _instance then
        _instance = RankingList:new()
        _instance:OnCreate()
    end

    return _instance
end

function RankingList.hide()
  if _instance then
    _instance:SetVisible(false)
  end
end

function RankingList.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = RankingList:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
		_instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function RankingList.getInstanceNotCreate()
    return _instance
end

function RankingList:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function RankingList.DestroyDialog()
	if _instance then 
		if _instance then _instance:OnClose() end
		_instance = nil
	end
end

function RankingList.ToggleOpenClose()
	if not _instance then 
		_instance = RankingList:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RankingList.processList(ranktype, myrank, list, page, hasmore, mytitle, takeAwardFlag)
	LogInfo("RankingList processList")
	if _instance then
		_instance.m_rankType = ranktype
		if myrank == 0 then
			if ranktype == typeEnum.ROLE_ZONGHE_RANK then
				local strbuilder = StringBuilder:new()	
				strbuilder:Set("parameter1", mytitle)
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2913)))				
				strbuilder:delete()
			elseif ranktype == typeEnum.ACTIVE_FLOWER_RECEIVE_RANK or ranktype == typeEnum.ACTIVE_FLOWER_SEND_RANK  then
				local strbuilder = StringBuilder:new()
				local cfgFlower = require "utils.mhsdutils".getLuaBean("knight.gsp.timer.cfloweractivityconfig", 1)
				local syear,smonth,sday,shour,sminute,ssecond,eyear,emonth,eday,ehour,eminute,esecond ,startTime,endTime
				syear,smonth,sday,shour,sminute,ssecond = string.match(cfgFlower.settleStartTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
				eyear,emonth,eday,ehour,eminute,esecond = string.match(cfgFlower.settleEndTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
				strbuilder:Set("parameter1", smonth .. "-" ..sday .. " " .. shour .. ":" .. sminute)
				strbuilder:Set("parameter2", emonth .. "-" ..eday .. " " .. ehour .. ":" .. eminute)
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(3036)))				
				strbuilder:delete()
			else
				_instance.m_pText:setText(MHSD_UTILS.get_resstring(2898))
			end
		else
			local strbuilder = StringBuilder:new()	
			strbuilder:Set("parameter1", myrank)
			if ranktype == typeEnum.FACTION_RANK then
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2911)))
			elseif ranktype == typeEnum.ROLE_ZONGHE_RANK then
				strbuilder:Set("parameter1", myrank)
				strbuilder:Set("parameter2", mytitle)
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2912)))	
			elseif ranktype == typeEnum.ACTIVE_FLOWER_RECEIVE_RANK or ranktype == typeEnum.ACTIVE_FLOWER_SEND_RANK  then
				local strbuilder = StringBuilder:new()
				local cfgFlower = require "utils.mhsdutils".getLuaBean("knight.gsp.timer.cfloweractivityconfig", 1)
				local syear,smonth,sday,shour,sminute,ssecond,eyear,emonth,eday,ehour,eminute,esecond ,startTime,endTime
				syear,smonth,sday,shour,sminute,ssecond = string.match(cfgFlower.settleStartTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
				eyear,emonth,eday,ehour,eminute,esecond = string.match(cfgFlower.settleEndTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
				strbuilder:Set("parameter1", myrank)
				strbuilder:Set("parameter2", smonth .. "-" ..sday .. " " .. shour .. ":" .. sminute)
				strbuilder:Set("parameter3", emonth .. "-" ..eday .. " " .. ehour .. ":" .. eminute)
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(3035)))				
				strbuilder:delete()
			else
				_instance.m_pText:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2899)))
			end
			strbuilder:delete()
		end
		_instance.m_iCurPage = page
		_instance.m_bHasMore = hasmore
		
		local record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(ranktype)
		if record.lingjiang == 0 then
			_instance.m_pRewardBtn:setVisible(false)
		else
			_instance.m_pRewardBtn:setVisible(true)
		end
		if takeAwardFlag == 1 then
			_instance.m_pRewardBtn:setEnabled(true)
		else
			_instance.m_pRewardBtn:setEnabled(false)
		end

		if ranktype == typeEnum.LEVEL_RANK then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = LevelRankData:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid, tostring(row.rank), row.nickname, knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(row.school).name, tostring(row.level))
			end
		elseif ranktype == typeEnum.PET_GRADE_RANK then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = PetGradeRankData:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1,row.roleid, tostring(row.rank), row.petname, row.nickname, tostring(row.petgrade))
			end
		elseif (ranktype == typeEnum.CAMP_TRIBE_RANK) or (ranktype == typeEnum.CAMP_LEAGUE_RANK) then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = CampRecordBean:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.index - 1, row.roleid,tostring(row.index), row.rolename, knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(row.school).name, tostring(row.score), row.title)
			end
		elseif ranktype == typeEnum.XIAKE_RANK then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = MarshalXiakeScoreRecord:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid,tostring(row.rank), row.rolename, tostring(row.xiakescore))
			end
		elseif ranktype == typeEnum.FACTION_RANK then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = FactionRankRecord:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.factionkey,tostring(row.rank), row.factionname, tostring(row.level), row.mastername)
			end
		elseif ranktype == typeEnum.ROLE_ZONGHE_RANK then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = RoleZongheRankRecord:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid, tostring(row.rank), row.rolename, knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(row.school).name,tostring(row.score))
			end
        elseif (ranktype == typeEnum.TODAY_FLOWER_RANK) or (ranktype == typeEnum.YESTERDAY_FLOWER_RANK) or (ranktype == typeEnum.HISTORY_FLOWER_RANK) or (ranktype == typeEnum.LASTWEEK_FLOWER_RANK) then
        
            local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = FlowerRankData:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid, tostring(row.rank), row.nickname, row.title, tostring(row.flowernum))
			end
		elseif ranktype == typeEnum.ACTIVE_FLOWER_RECEIVE_RANK or ranktype == typeEnum.ACTIVE_FLOWER_SEND_RANK  then
			local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = ActiveRoseRankRecord:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid, tostring(row.rank), row.rolename, row.title ,tostring(row.num))
			end
		elseif ranktype == typeEnum.QBJJ_RANK  then
      local sizeof_recordlist = list:size()
			for k = 0,sizeof_recordlist - 1 do
				local row = yibaicengrankrecord:new()
				row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
				_instance:AddRow(row.rank - 1, row.roleid, row.rank, row.name, row.layer)
			end
		elseif ranktype == typeEnum.SWORN_RANK  then
      local sizeof_recordlist = list:size()
      for k = 0,sizeof_recordlist - 1 do
        local row = SwornRecord:new()
        row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
        if row.level <= 0 or row.level > 7 then
          row.level = 1
        end
        
        local chenghao = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.ctotoltip"):getRecorder(row.level).name
        _instance:AddRow(row.id - 1, myrank == row.id, row.id, row.name, chenghao, row.score)
      end
    elseif ranktype == typeEnum.SHIDE_RANK  then
      local sizeof_recordlist = list:size()
      for k = 0,sizeof_recordlist - 1 do
        local row = ShiDeRankRecord:new()
        row:unmarshal(GNET.Marshal.OctetsStream:new(list[k]))
        _instance:AddRow(row.rank - 1, row.roleid, row.rank, row.rolename, tostring(row.num))
      end
		end
	end
end

function RankingList.TakeAwardSuccess(ranktype)
	LogInfo("RankingList take award success")
	if _instance then
		if _instance.m_rankType == ranktype then
			_instance.m_pRewardBtn:setEnabled(false)
		end
	end
end

----/////////////////////////////////////////------

function RankingList.GetLayoutFileName()
    return "rankinglist.layout"
end

function RankingList:OnCreate()
	LogInfo("enter RankingList oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pTree = CEGUI.toGroupBtnTree(winMgr:getWindow("RankingList/tree"))
	self.m_pMain = CEGUI.Window.toMultiColumnList(winMgr:getWindow("RankingList/PersonalInfo/list"))
   	self.m_pTitle = winMgr:getWindow("RankingList/title")
	self.m_pRewardBtn = CEGUI.Window.toPushButton(winMgr:getWindow("RankingList/get"))
	self.m_pText = winMgr:getWindow("RankingList/personalrank")

	self.m_pMain:setUserSortControlEnabled(false)
	self:InitTree()

    -- subscribe event
	self.m_pTree:subscribeEvent("ItemSelectionChanged", RankingList.HandleSelectRank, self)
	self.m_pMain:subscribeEvent("NextPage", RankingList.HandleNextPage, self)	
	self.m_pMain:subscribeEvent("SelectionChanged", RankingList.HandleListMemberSelected, self)
	self.m_pRewardBtn:subscribeEvent("Clicked", RankingList.HandleBtnClicked, self)
	self.m_pTree:SetLastOpenItem(self.m_PersonalItem)
	self.m_pTree:SetLastSelectItem(self.m_zongheItem)
	self.m_pTree:invalidate()

	local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
	require "manager.luaprotocolmanager".getInstance():send(p)

	LogInfo("exit RankingList OnCreate")
end

------------------- private: -----------------------------------

function RankingList:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RankingList)

    return self
end

function RankingList:HandleSelectRank(args)
	LogInfo("RankingList handle select rank")
	local item = self.m_pTree:getSelectedItem()
	if item == nil then
		return true
	end

	local id = item:getID()
	local req = CRequestRankList.Create()	
	req.ranktype = id
	self.m_iRankType = id
	req.page = 0
	self.m_iCurPage = 0
	LuaProtocolManager.getInstance():send(req)

	self.m_pMain:resetList()
	local record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(id)
	self.m_pMain:getListHeader():getSegmentFromColumn(0):setText(record.name1)
	self.m_pMain:setColumnHeaderWidth(0, CEGUI.UDim(record.kuandu1, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(1):setText(record.name2)
	self.m_pMain:setColumnHeaderWidth(1, CEGUI.UDim(record.kuandu2, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(2):setText(record.name3)
	self.m_pMain:setColumnHeaderWidth(2, CEGUI.UDim(record.kuandu3, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(3):setText(record.name4)
	self.m_pMain:setColumnHeaderWidth(3, CEGUI.UDim(record.kuandu4, 0))
	self.m_pMain:getListHeader():getSegmentFromColumn(4):setText(record.name5)
	self.m_pMain:setColumnHeaderWidth(4, CEGUI.UDim(record.kuandu5, 0))

	self.m_pTitle:setText(record.leixing)
end

function RankingList:HandleListMemberSelected(args)
	local rowItem = self.m_pMain:getFirstSelectedItem()
	local rankItem = self.m_pTree:getSelectedItem()
	if rankItem == nil or rowItem == nil then
		return true
	end
	local rowId = rowItem:getID() -- 行号是从0开始的
	local rankType = rankItem:getID()

	-- 排行榜查看功能（ROLE_ZONGHE_RANK，LEVEL_RANK，PET_GRADE_RANK，XIAKE_RANK）

	if rankType == typeEnum.ROLE_ZONGHE_RANK or rankType == typeEnum.LEVEL_RANK or rankType == typeEnum.PET_GRADE_RANK or rankType == typeEnum.XIAKE_RANK then
		local req = require "protocoldef.knight.gsp.ranklist.getrankinfo.cgetrankdetailinfo".Create()
		req.ranktype = rankType
		req.rank = rowId
		require "manager.luaprotocolmanager".getInstance():send(req)

	-- ACTIVE_FLOWER_RECEIVE_RANK，ACTIVE_FLOWER_SEND_RANK

	elseif rankType == typeEnum.ACTIVE_FLOWER_RECEIVE_RANK or rankType == typeEnum.ACTIVE_FLOWER_SEND_RANK then
		rowId = rowId + 1
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cawardperview",rankType)
		if cfg == nil or cfg.itemAward == "" then
			return true 
		end
		local code = "return { " .. cfg.itemAward .. "}"
		cfg = loadstring(code)()


		local itemid = 0
		if rowId >= 1 and rowId <= cfg[#cfg - 1][1] then
			itemid = cfg[rowId][2]
		elseif rowId <= cfg[#cfg][1] then
			itemid = cfg[#cfg][2]
		end
		if itemid == 0 then
			return true
		end


		if itemid > 0 then
			local pt = CEGUI.toWindowEventArgs(args).window:GetScreenPos()
			CToolTipsDlg:GetSingletonDialog():RefreshItemTipsByBaseID(itemid, pt.x,pt.y + rowId * 15, false, 0, true)
		end
	end

end


function RankingList:HandleNextPage(args)
	LogInfo("RankingList handle next page")
	if self.m_bHasMore then
		self.m_iCurPage = self.m_iCurPage + 1
		local BarPos = self.m_pMain:getVertScrollbar():getScrollPosition()
		self.m_pMain:getVertScrollbar():Stop()
		self.m_pMain:getVertScrollbar():setScrollPosition(BarPos)
		
		local req = CRequestRankList.Create()	
		req.ranktype = self.m_iRankType 
		req.page = self.m_iCurPage
		LuaProtocolManager.getInstance():send(req)
	end	
	return true
end

function RankingList:InitTree()
	LogInfo("RankingList init tree")
	local first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(2900)))

	local record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.ROLE_ZONGHE_RANK)
	local second = first:addItem(CEGUI.String(record.leixing), typeEnum.ROLE_ZONGHE_RANK)
	self:SetSecondItemIcon(second)	
	
	self.m_PersonalItem = first
	self.m_zongheItem = second

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.LEVEL_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.LEVEL_RANK)
	self:SetFirstItemIcon(first)
	self:SetSecondItemIcon(second)	

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.PET_GRADE_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.PET_GRADE_RANK)
	self:SetSecondItemIcon(second)	

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.XIAKE_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.XIAKE_RANK)
	self:SetSecondItemIcon(second)	
	first:toggleIsOpen()


	--wan jia guan xi bang
  first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(3159)))
  self:SetFirstItemIcon(first)

  record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.SWORN_RANK)
  second = first:addItem(CEGUI.String(record.leixing), typeEnum.SWORN_RANK)
  self:SetSecondItemIcon(second)
  
  record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.SHIDE_RANK)
  second = first:addItem(CEGUI.String(record.leixing), typeEnum.SHIDE_RANK)
  self:SetSecondItemIcon(second)
  
  --
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(2901)))
	self:SetFirstItemIcon(first)

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.CAMP_LEAGUE_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.CAMP_LEAGUE_RANK)
	self:SetSecondItemIcon(second)	
	
	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.CAMP_TRIBE_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.CAMP_TRIBE_RANK)
	self:SetSecondItemIcon(second)	

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.FACTION_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.FACTION_RANK)
	self:SetSecondItemIcon(second)	
    
    
  --flower rank list
	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(437)))
	self:SetFirstItemIcon(first)

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.TODAY_FLOWER_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.TODAY_FLOWER_RANK)
	self:SetSecondItemIcon(second)
	
	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.YESTERDAY_FLOWER_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.YESTERDAY_FLOWER_RANK)
	self:SetSecondItemIcon(second)
	
	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.LASTWEEK_FLOWER_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.LASTWEEK_FLOWER_RANK)
	self:SetSecondItemIcon(second)

	record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.HISTORY_FLOWER_RANK)
	second = first:addItem(CEGUI.String(record.leixing), typeEnum.HISTORY_FLOWER_RANK)
	self:SetSecondItemIcon(second)

	    
    --shouhua xianhua rank list
	local cfgFlower = require "utils.mhsdutils".getLuaBean("knight.gsp.timer.cfloweractivityconfig", 1)
	local syear,smonth,sday,shour,sminute,ssecond,eyear,emonth,eday,ehour,eminute,esecond ,startTime,endTime
	syear,smonth,sday,shour,sminute,ssecond = string.match(cfgFlower.activityStartTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	eyear,emonth,eday,ehour,eminute,esecond = string.match(cfgFlower.activityEndTime,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	startTime = os.time({year=syear,month=smonth,day=sday,hour=shour,min=sminute,sec=ssecond})
	endTime = os.time({year=eyear,month=emonth,day=eday,hour=ehour,min=eminute,sec=esecond})
 	if startTime < GetServerTime() / 1000 and GetServerTime() / 1000 < endTime then
		first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. cfgFlower.activityName )) 
		self:SetFirstItemIcon(first)

		record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.ACTIVE_FLOWER_RECEIVE_RANK)
		second = first:addItem(CEGUI.String(record.leixing), typeEnum.ACTIVE_FLOWER_RECEIVE_RANK)
		self:SetSecondItemIcon(second)
		
		record = knight.gsp.game.GetCpaihangbangTableInstance():getRecorder(typeEnum.ACTIVE_FLOWER_SEND_RANK)
		second = first:addItem(CEGUI.String(record.leixing), typeEnum.ACTIVE_FLOWER_SEND_RANK)
		self:SetSecondItemIcon(second)
    end
	
    --huo dong rank list
    local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.paihangbangkaiqi")
    local anyhuodong = false
    local counthuodong = 1 --count huodong, mu qian zhi you yi ge .
    
    for i=1, counthuodong do
      if config:getRecorder(i).shifoukaiqi == 1 then
        anyhuodong = true
        break
      end
    end
    
    if anyhuodong == true then
    	first = self.m_pTree:addItem(CEGUI.String(FIRST_COLOR .. MHSD_UTILS.get_resstring(3065)))
    	self:SetFirstItemIcon(first)

      -- ai chuang jue qing gu.
      if config:getRecorder(1).shifoukaiqi == 1 then
        second = first:addItem(CEGUI.String(config:getRecorder(1).name), typeEnum.QBJJ_RANK)
        self:SetSecondItemIcon(second)
      end

      -- for some other huodongs
      --if config:getRecorder(2).shifoukaiqi == 1 then
      --  second = first:addItem(CEGUI.String(config:getRecorder(2).name), typeEnum.XXXX_RANK)
      --  self:SetSecondItemIcon(second)
      --end
  	end
end

function RankingList:SetFirstItemIcon(pItem)
    pItem:seNormalImage(CEGUI.String("MainControl3"), CEGUI.String("TrackNormal"))
    pItem:setSelectionImage(CEGUI.String("MainControl3"),CEGUI.String("TrackPushed"))
    pItem:setOpenImage(CEGUI.String("MainControl3"),CEGUI.String("TrackPushed"))
end

function RankingList:SetSecondItemIcon(pItem)
    pItem:seNormalImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
     pItem:setSelectionImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittlePushed"))
     pItem:setOpenImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
     pItem:setHoverImage(CEGUI.String("MainControl3"), CEGUI.String("TrackLittleNormal"))
end

function RankingList:AddRow(rownum, id , col0, col1, col2, col3, col4)
	LogInfo("RankingList add row")
	self.m_pMain:addRow(rownum)
	local color = "FFFFFFFF"
	if id == GetDataManager():GetMainCharacterID() then
		color = "FF33FF33"
	end
	
	--for SWORN_RANK
	if self.m_iRankType == typeEnum.SWORN_RANK and id == true then
    color = "FF33FF33"
	end
	
	if self.m_iRankType == typeEnum.FACTION_RANK and self.m_iFactionID and id == self.m_iFactionID then
		color = "FF33FF33"
	end	
	if rownum == 0 then
		color = "FFFF1493"
	elseif rownum == 1 or rownum == 2 then
		color = "FFFFA500"
	end
	if col0 then
		local pItem0 = CEGUI.createListboxTextItem(col0)		
		pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem0:setID(rownum)
		self.m_pMain:setItem(pItem0, 0, rownum)
	end

	if col1 then
		local pItem1 = CEGUI.createListboxTextItem(col1)		
		pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem1:setID(rownum)
		self.m_pMain:setItem(pItem1, 1, rownum)
	end

	if col2 then
		local pItem2 = CEGUI.createListboxTextItem(col2)		
		pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem2:setID(rownum)
		self.m_pMain:setItem(pItem2, 2, rownum)
	end

	if col3 then
		local pItem3 = CEGUI.createListboxTextItem(col3)		
		pItem3:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem3:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem3:setID(rownum)
		self.m_pMain:setItem(pItem3, 3, rownum)
	end

	if col4 then
		local pItem4 = CEGUI.createListboxTextItem(col4)		
		pItem4:setTextColours(CEGUI.PropertyHelper:stringToColour(color))
		pItem4:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem4:setID(rownum)
		self.m_pMain:setItem(pItem4, 4, rownum)
	end
end

function RankingList:HandleBtnClicked(args)
	LogInfo("RankingList handle button clicked")
	if self.m_rankType == nil then
		return true
	end
	local req = CReqRankAward.Create()
	req.ranktype = self.m_rankType
	LuaProtocolManager.getInstance():send(req)

end

return RankingList
