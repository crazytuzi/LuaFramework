--[[author: lvxiaolong
date: 2013/6/27
function: binfen gift dlg
]]

require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

BinfenGiftDlg = { }
setmetatable(BinfenGiftDlg, Dialog)
BinfenGiftDlg.__index = BinfenGiftDlg 

function BinfenGiftDlg.GetTimeDetails(seconds)
    seconds = seconds - GetServerTime()/1000
    if seconds <= 0 then
      return 0, 0, 0, 0
    end
    
    local days = math.floor(seconds/(3600*24))
    local leftHourSec = seconds - days*3600*24
  
    local hours = math.floor(leftHourSec/3600)
    local leftMinSec = leftHourSec - hours*3600
    
    local mins = math.floor(leftMinSec/60)
    local secs = math.floor(leftMinSec - mins*60)

    if days < 0 then
        days = 0
    end
    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end

    return days, hours, mins, secs
end

------------------- public: -----------------------------------
local _instance

function BinfenGiftDlg.getInstance()
	LogInfo("BinfenGiftDlg.getInstance")
    if not _instance then
        _instance = BinfenGiftDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function BinfenGiftDlg.getInstanceAndShow()
	LogInfo("____BinfenGiftDlg.getInstanceAndShow")
    if not _instance then
        _instance = BinfenGiftDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function BinfenGiftDlg.getInstanceNotCreate()
    return _instance
end

function BinfenGiftDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

----/////////////////////////////////////////------
function BinfenGiftDlg.GetLayoutFileName()
    return "addcashactivities.layout"
end

function BinfenGiftDlg:OnCreate()
	LogInfo("enter BinfenGiftDlg oncreate")

  Dialog.OnCreate(self)
  self:GetWindow():setModalState(true)
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.m_mainItems = {}
  self.m_pGroupBtn = {}
  
  for i=1, 5 do
      local nameGroupBtn = "addcashactivities/left/groupbtn" .. tostring(i-1)
      self.m_pGroupBtn[i] = CEGUI.Window.toGroupButton(winMgr:getWindow(nameGroupBtn))
  end
  self.m_pGroupBtn[1]:setSelected(true)
  
  self.m_txtLeftTime = winMgr:getWindow("addcashactivities/time")
  self.m_pPaneContent = CEGUI.Window.toScrollablePane(winMgr:getWindow("addcashactivities/right"))
  
	-- 隐藏累计充值天数（日积月累专用）
	self.m_AccumulateText = winMgr:getWindow("addcashactivities/leiji")
	if self.m_AccumulateText then
		self.m_AccumulateText:setVisible(false)
	end
	
	self.m_AccumulateNum = winMgr:getWindow("addcashactivities/day")
	if self.m_AccumulateNum then
		self.m_AccumulateNum:setVisible(false)
	end
  
  self:GetWindow():subscribeEvent("WindowUpdate", BinfenGiftDlg.HandleWindowUpdate, self)
  
  self.m_curIndex = 1
  
  LogInfo("exit BinfenGiftDlg OnCreate")
end

function BinfenGiftDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BinfenGiftDlg)
    
    return self
end

function BinfenGiftDlg:GetPriceUnit()
    if ((Config.TRD_PLATFORM ==1 and Config.CUR_3RD_PLATFORM == "efunios") or (Config.MOBILE_ANDROID ==1 and Config.CUR_3RD_LOGIN_SUFFIX == "efad")) or
    ((Config.TRD_PLATFORM ==1 and Config.CUR_3RD_PLATFORM == "this") or (Config.MOBILE_ANDROID ==1 and Config.CUR_3RD_LOGIN_SUFFIX == "thlm"))
      then
      return MHSD_UTILS.get_resstring(414)
    else
      return MHSD_UTILS.get_resstring(2967)
    end
end

function BinfenGiftDlg:SetLeftTimes(endTimeReGift, endTimeConGift, endTimeLSaleAct, endTimeDailyTask, endTimeAccumulate)
  --record index
  self.m_recordIndex = {}
  self.m_time1 = endTimeReGift/1000.0
  self.m_time2 = endTimeConGift/1000.0
  self.m_time3 = endTimeLSaleAct/1000.0
  self.m_time4 = endTimeDailyTask/1000.0
  self.m_time5 = endTimeAccumulate/1000.0
  
  --hide all
  for i=1,5 do
    self.m_pGroupBtn[i]:removeEvent("SelectStateChanged")
    self.m_pGroupBtn[i]:setVisible(false)
  end
  
  local index = 1
  
  if endTimeReGift > 0 then
    self.m_recordIndex[1] = index
    self.m_pGroupBtn[index]:setVisible(true)
    self.m_pGroupBtn[index]:setID(1)
    self.m_pGroupBtn[index]:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2796).msg)
    self.m_pGroupBtn[index]:subscribeEvent("SelectStateChanged", BinfenGiftDlg.HandleGroupButtonSelectedChanged, self)
    index = index + 1
  end
  
  if endTimeConGift > 0 then
    self.m_recordIndex[2] = index
    self.m_pGroupBtn[index]:setVisible(true)
    self.m_pGroupBtn[index]:setID(2)
    self.m_pGroupBtn[index]:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2797).msg)
    self.m_pGroupBtn[index]:subscribeEvent("SelectStateChanged", BinfenGiftDlg.HandleGroupButtonSelectedChanged, self)
    index = index + 1
  end
  
  if endTimeLSaleAct > 0 then
    self.m_recordIndex[3] = index
    self.m_pGroupBtn[index]:setVisible(true)
    self.m_pGroupBtn[index]:setID(3)
    self.m_pGroupBtn[index]:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2798).msg)
    self.m_pGroupBtn[index]:subscribeEvent("SelectStateChanged", BinfenGiftDlg.HandleGroupButtonSelectedChanged, self)
    index = index + 1
  end
	
	-- 每日任务
	if endTimeDailyTask > 0 then
		self.m_recordIndex[4] = index
		self.m_pGroupBtn[index]:setVisible(true)
		self.m_pGroupBtn[index]:setID(4)
		self.m_pGroupBtn[index]:setText(MHSD_UTILS.get_resstring(3153))
		self.m_pGroupBtn[index]:subscribeEvent("SelectStateChanged", BinfenGiftDlg.HandleGroupButtonSelectedChanged, self)
		index = index + 1
	end
	
	-- 日积月累
	if endTimeAccumulate > 0 then
		self.m_recordIndex[5] = index
		self.m_pGroupBtn[index]:setVisible(true)
		self.m_pGroupBtn[index]:setID(5)
		self.m_pGroupBtn[index]:setText(MHSD_UTILS.get_resstring(3152))
		self.m_pGroupBtn[index]:subscribeEvent("SelectStateChanged", BinfenGiftDlg.HandleGroupButtonSelectedChanged, self)
		index = index + 1
	end
end

function BinfenGiftDlg:HandleGroupButtonSelectedChanged(args)
  --clean all items
  self:CleanPaneItems()
  
	-- 隐藏累计充值天数（日积月累专用）
	if self.m_AccumulateText then
		self.m_AccumulateText:setVisible(false)
	end
	
	if self.m_AccumulateNum then
		self.m_AccumulateNum:setVisible(false)
	end
  
  local index = CEGUI.toWindowEventArgs(args).window:getID()
  
  require "protocoldef.knight.gsp.yuanbao.copencontinuechargedlg"
  local p = COpenContinueChargeDlg.Create()
  p.page = index
  p.flag = 1
  require "manager.luaprotocolmanager":send(p)
end

function BinfenGiftDlg:CleanPaneItems()
    local winMgr = CEGUI.WindowManager:getSingleton()
    for k, v in pairs(self.m_mainItems) do
      winMgr:destroyWindow(v)
      self.m_pPaneContent:removeChildWindow(v)
    end
    self.m_mainItems = {}
end

function BinfenGiftDlg:SetChargeItems(items, curNum, endTime)
    self.m_curIndex = 1
    self.m_time1 = endTime/1000.0
    self:CleanPaneItems()

    --sort
    local keys = {}
    for k,_ in pairs(items) do
      table.insert(keys, k)
    end
    table.sort(keys)

    local index = 1
    for _,k in pairs(keys) do
        local v = items[k]
        k = v.number
        local winMgr = CEGUI.WindowManager:getSingleton()
        local cellWnd = winMgr:loadWindowLayout("addcashactcell1.layout", tostring(index))
        self.m_pPaneContent:addChildWindow(cellWnd)
        table.insert(self.m_mainItems, cellWnd)

        local configItem = knight.gsp.item.GetCItemAttrTableInstance()
        for i=1, #v.itemlist do
            local item = CEGUI.toItemCell(winMgr:getWindow(tostring(index) .. "addcashactcell1/item" .. tostring(i-1)))
            local itemid = v.itemlist[i].itemid
            if item and itemid ~= 0 then
              item:setID(itemid)
              item:SetTextUnit(v.itemlist[i].itemnumber)
              item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
              item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
            end
        end
        
        --button
        local button = CEGUI.toPushButton(winMgr:getWindow(tostring(index) .. "addcashactcell1/get"))
        button:setID(k)
        button:subscribeEvent("Clicked", BinfenGiftDlg.HandleChargeGetBtn, self)
        local txt2 = winMgr:getWindow(tostring(index) .. "addcashactcell1/txt1")
        local tip2 = winMgr:getWindow(tostring(index) .. "addcashactcell1/num1")
        
        tip2:setText("0" .. self.GetPriceUnit())
        if v.awardflag == 0 then
          button:setEnabled(false)
          tip2:setText(tostring(k-curNum) .. self.GetPriceUnit())
        elseif v.awardflag == 2 then
          button:setEnabled(false)
          button:setText(MHSD_UTILS.get_resstring(2940))
          tip2:setVisible(false)
        end
        
        --tips
        local tip1 = winMgr:getWindow(tostring(index) .. "addcashactcell1/num")
        tip1:setText(tostring(k) .. self.GetPriceUnit())

        if curNum < k then
          tip1:setProperty("TextColours", "FFFF3333")
        else
          tip1:setProperty("TextColours", "FFFFFF33")
        end
        
        --set position
        local y = math.floor((index - 1) * cellWnd:getSize().y.offset)
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))

        index = index + 1
    end
end

function BinfenGiftDlg:SetConsumeItems(items, curNum, endTime)
    self.m_curIndex = 2
    self.m_time2 = endTime/1000.0
    self:CleanPaneItems()

    --sort
    local keys = {}
    for k,_ in pairs(items) do
      table.insert(keys, k)
    end
    table.sort(keys)

    local index = 1
    for _,k in pairs(keys) do
        local v = items[k]
        k = v.number
        local winMgr = CEGUI.WindowManager:getSingleton()
        local cellWnd = winMgr:loadWindowLayout("addcashactcell2.layout", tostring(index))
        self.m_pPaneContent:addChildWindow(cellWnd)
        table.insert(self.m_mainItems, cellWnd)

        local configItem = knight.gsp.item.GetCItemAttrTableInstance()
        for i=1, #v.itemlist do
            local item = CEGUI.toItemCell(winMgr:getWindow(tostring(index) .. "addcashactcell2/item" .. tostring(i-1)))
            local itemid = v.itemlist[i].itemid
            if item and itemid ~= 0 then
              item:setID(itemid)
              item:SetTextUnit(v.itemlist[i].itemnumber)
              item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
              item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
            end
        end
        
        --button
        local button = CEGUI.toPushButton(winMgr:getWindow(tostring(index) .. "addcashactcell2/get"))
        button:setID(k)
        button:subscribeEvent("Clicked", BinfenGiftDlg.HandleConsumeGetBtn, self)
        local txt2 = winMgr:getWindow(tostring(index) .. "addcashactcell2/txt1")
        local tip2 = winMgr:getWindow(tostring(index) .. "addcashactcell2/num1")
        
        tip2:setText("0" .. MHSD_UTILS.get_resstring(414))
        if v.awardflag == 0 then
          button:setEnabled(false)
          tip2:setText(tostring(k-curNum) .. MHSD_UTILS.get_resstring(414))
        elseif v.awardflag == 2 then
          button:setEnabled(false)
          button:setText(MHSD_UTILS.get_resstring(2940))
          tip2:setVisible(false)
        end
        
        --tips
        local tip1 = winMgr:getWindow(tostring(index) .. "addcashactcell2/num")
        tip1:setText(tostring(k) .. MHSD_UTILS.get_resstring(414))

        if curNum < k then
          tip1:setProperty("TextColours", "FFFF3333")
        else
          tip1:setProperty("TextColours", "FFFFFF33")
        end
        
        --set position
        local y = math.floor((index - 1) * cellWnd:getSize().y.offset)
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))

        index = index + 1
    end
end

function BinfenGiftDlg:SetLimitTimeBuyItems(limittimeitems, endTime)
    self.m_curIndex = 3
    self.m_time3 = endTime/1000.0
    self:CleanPaneItems()
    
    self.m_limitItems = limittimeitems
    
    local index = 1
    for _,v in pairs(limittimeitems) do
        local k = v.itemid
        local winMgr = CEGUI.WindowManager:getSingleton()
        local cellWnd = winMgr:loadWindowLayout("addcashactcell3.layout", tostring(index))
        self.m_pPaneContent:addChildWindow(cellWnd)
        table.insert(self.m_mainItems, cellWnd)

        local configItem = knight.gsp.item.GetCItemAttrTableInstance()
        local item = CEGUI.toItemCell(winMgr:getWindow(tostring(index) .. "addcashactcell3/item"))
        item:setID(k)
        item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(k).icon))
        item:SetTextUnit(v.canbuyitemnum)
        item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

        --button
        local button = CEGUI.toPushButton(winMgr:getWindow(tostring(index) .. "addcashactcell3/get"))
        button:setID(k)
        button:subscribeEvent("Clicked", BinfenGiftDlg.HandleLimitTimeBuyBtn, self)
        if v.canbuyitemnum == 0 then
          button:setEnabled(false)
        end
        
        --tips
        local strbuilder = StringBuilder:new()
        local tips = CEGUI.Window.toRichEditbox(winMgr:getWindow(tostring(index) .. "addcashactcell3/txt"))
        local strMsg = ""
        if v.flag == 0 then
            strbuilder:SetNum("parameter1", v.totalitemnum)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145046))
        else
            strbuilder:SetNum("parameter1", v.totalitemnum)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145047))
        end
        strbuilder:delete()
        tips:Clear()
        tips:AppendParseText(CEGUI.String(strMsg))
        tips:Refresh()
        
        --name
        local labelname = winMgr:getWindow(tostring(index) .. "addcashactcell3/name")
        labelname:setText(configItem:getRecorder(k).name)
        labelname:setProperty("TextColours", configItem:getRecorder(k).colour)
        
        --price
        local price1 = winMgr:getWindow(tostring(index) .. "addcashactcell3/num")
        local price2 = winMgr:getWindow(tostring(index) .. "addcashactcell3/num1")
        price1:setText(tostring(v.price))
        local itemShopInfo = knight.gsp.item.GetCItemShopTableInstance():getRecorder(k)
        if itemShopInfo and itemShopInfo.id > 0 and itemShopInfo.needyuanbao and itemShopInfo.needyuanbao ~= v.price then
          price2:setText(tostring(itemShopInfo.needyuanbao))
        else
          price2:setVisible(false)
          winMgr:getWindow(tostring(index) .. "addcashactcell3/pic1"):setVisible(false)
          winMgr:getWindow(tostring(index) .. "addcashactcell3/pic11"):setVisible(false)
        end
        
        --set position
        local y = math.floor((index - 1) * cellWnd:getSize().y.offset)
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))

        index = index + 1
    end
end

-- 每日任务
function BinfenGiftDlg:SetDailyTaskItem(achivelist, endTime)

	self.m_curIndex = 4
	self.m_time4 = endTime/1000.0
	self:CleanPaneItems()
	
	local tNewList = self:ReorderAchivelist(achivelist)
	if not tNewList then return end

	local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end
	
    local configItem = knight.gsp.item.GetCItemAttrTableInstance()
	if not configItem then return end
	
	self.m_DailyTaskButton = {}
	
	for index, achiveinfo in ipairs(tNewList) do
		local nTaskId = achiveinfo.key
		local tTask = MHSD_UTILS.getLuaBean("knight.gsp.yuanbao.ctiandaochouqinconf", nTaskId)
		local nItemId = tTask.itemid
		
		local cellWnd = winMgr:loadWindowLayout("tiandaochouqincell.layout", tostring(index))
		if cellWnd then
			self.m_pPaneContent:addChildWindow(cellWnd)
			table.insert(self.m_mainItems, cellWnd)
			-- 设置位置
			local y = math.floor((index - 1) * cellWnd:getSize().y.offset)
			cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
		end
		
		-- 道具
		local item = CEGUI.toItemCell(winMgr:getWindow(tostring(index) .. "tiandaochouqincell/item"))
		if item then
			item:setID(nItemId)
			item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(nItemId).icon))
			item:SetTextUnit(1)
			item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
		end
		
		-- 按钮
		local button = CEGUI.toPushButton(winMgr:getWindow(tostring(index) .. "tiandaochouqincell/get"))
		if button then
			self.m_DailyTaskButton[nTaskId] = button
			button:setID(nTaskId)
			button:subscribeEvent("Clicked", BinfenGiftDlg.HandleDailyTaskBtnClick, self)
			
			-- 未完成或已领取设为未激活
			button:setEnabled(achiveinfo.awardflag == 1)
			-- 领取后显示“已领取”
			if achiveinfo.awardflag == 2 then
				button:setText(MHSD_UTILS.get_resstring(2940))
			end
		end
		
		-- 进度
		local numText = winMgr:getWindow(tostring(index) .. "tiandaochouqincell/num")
		if numText then
			local sText = tostring(achiveinfo.currnumber)..'/'..tostring(achiveinfo.totalnum)
			numText:setText(sText)
		end
		
		-- 内容
		local contentText = winMgr:getWindow(tostring(index) .. "tiandaochouqincell/text")
		if contentText then
			contentText:setText(tostring(tTask.characterization))
		end
	end
end

-- 日积月累
function BinfenGiftDlg:SetAccumulateItem(achivelist, days, endTime)

	self.m_curIndex = 5
	self.m_time5 = endTime/1000.0
	self:CleanPaneItems()
	
	local tNewList = self:ReorderAchivelist(achivelist)
	if not tNewList then return end

	local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end
	
    local configItem = knight.gsp.item.GetCItemAttrTableInstance()
	if not configItem then return end
	
	self.m_AccumulateButton = {}
	
	for index, achiveinfo in ipairs(tNewList) do
		local nTaskId = achiveinfo.key
		local tTask = MHSD_UTILS.getLuaBean("knight.gsp.yuanbao.crijiyueleiconf", nTaskId)
		local nItemId = tTask.itemid
		
		local cellWnd = winMgr:loadWindowLayout("rijiyueleicell.layout", tostring(index))
		if cellWnd then
			self.m_pPaneContent:addChildWindow(cellWnd)
			table.insert(self.m_mainItems, cellWnd)
			-- 设置位置
			local y = math.floor((index - 1) * cellWnd:getSize().y.offset)
			cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
		end
		
		-- 道具
		local item = CEGUI.toItemCell(winMgr:getWindow(tostring(index) .. "rijiyueleicell/item"))
		if item then
			item:setID(nItemId)
			item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(nItemId).icon))
			item:SetTextUnit(1)
			item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
		end
		
		-- 按钮
		local button = CEGUI.toPushButton(winMgr:getWindow(tostring(index) .. "rijiyueleicell/get"))
		if button then
			self.m_AccumulateButton[nTaskId] = button
			button:setID(nTaskId)
			button:subscribeEvent("Clicked", BinfenGiftDlg.HandleAccumulateBtnClick, self)
		
			-- 未完成或已领取设为未激活
			button:setEnabled(achiveinfo.awardflag == 1)
			-- 领取后显示“已领取”
			if achiveinfo.awardflag == 2 then
				button:setText(MHSD_UTILS.get_resstring(2940))
			end
		end
		
		-- 进度
		local numText = winMgr:getWindow(tostring(index) .. "rijiyueleicell/num")
		if numText then
			local sNumText = tostring(achiveinfo.currnumber)..'/'..tostring(achiveinfo.totalnum)
			numText:setText(sNumText)
		end
		
		-- 内容
		local contentText = winMgr:getWindow(tostring(index) .. "rijiyueleicell/text")
		if contentText then
			local strbuilder = StringBuilder:new()  
			strbuilder:SetNum("parameter1", tTask.yuanbaonum)
			strbuilder:SetNum("parameter2", tTask.id)
			local sContentText = strbuilder:GetString(tTask.characterization)
			strbuilder:delete()
			contentText:setText(sContentText)
		end
	end
	
	-- 显示累计充值天数
	if self.m_AccumulateText then
		self.m_AccumulateText:setVisible(true)
	end
	
	if self.m_AccumulateNum then
		self.m_AccumulateNum:setVisible(true)
		self.m_AccumulateNum:setText(tostring(days))
	end
end

-- 按照可领取、未完成、已领取和id的顺序重新排列
function BinfenGiftDlg:ReorderAchivelist(achivelist)

	if type(achivelist) ~= 'table' then return end

	local tempList = {}
	tempList[0] = {}	-- 未完成
	tempList[1] = {}	-- 可领取
	tempList[2] = {}	-- 已领取
	
	for _, achiveinfo in ipairs(achivelist) do
		if achiveinfo.awardflag and tempList[achiveinfo.awardflag] then
			table.insert(tempList[achiveinfo.awardflag], achiveinfo)
		end
	end
	
	for _,temp in pairs(tempList) do
		table.sort(temp, function (a,b) return a.key < b.key end)
	end
	
	local newList = {}
	local tTempId = {1,0,2}
	
	for _,id in ipairs(tTempId) do
		for _,achiveinfo in ipairs(tempList[id]) do
			table.insert(newList, achiveinfo)
		end
	end

	return newList
end

function BinfenGiftDlg:HandleChargeGetBtn(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
    local curLevelID = mouseArgs.window:getID()
    
    require "protocoldef.knight.gsp.yuanbao.creceivechargeorconsumeaward"
    local p = CReceiveChargeOrConsumeAward.Create()
    p.page = 1
    p.flag = 1
    p.awardlevel = curLevelID
    require "manager.luaprotocolmanager":send(p)
end

function BinfenGiftDlg:HandleConsumeGetBtn(args)
    local mouseArgs = CEGUI.toMouseEventArgs(args)
    local curLevelID = mouseArgs.window:getID()
    
    require "protocoldef.knight.gsp.yuanbao.creceivechargeorconsumeaward"
    local p = CReceiveChargeOrConsumeAward.Create()
    p.page = 2
    p.flag = 1
    p.awardlevel = curLevelID
    require "manager.luaprotocolmanager":send(p)
end

function BinfenGiftDlg:HandleLimitTimeBuyBtn(args)
   local mouseArgs = CEGUI.toMouseEventArgs(args)
   local itemid = mouseArgs.window:getID()
  
   for k,v in pairs(self.m_limitItems) do
    if itemid == v.itemid then
      local shop = require "ui.shop.shopcheckdlg"
      shop.getInstanceAndShow():SetItemInfo(itemid, v.price, v.canbuyitemnum, 2)
      return
    end
   end
end

function BinfenGiftDlg.LimitTimeBuy(itemid, num)   
    require "protocoldef.knight.gsp.yuanbao.cbuylimittimeitem"
    local p = CBuyLimittimeItem.Create()
    p.itemid = itemid
    p.itemnum = num
    p.flag = 1 --from binfen buy
    require "manager.luaprotocolmanager":send(p)
end

-- 每日任务领奖
function BinfenGiftDlg:HandleDailyTaskBtnClick(args)
	local mouseArgs = CEGUI.toMouseEventArgs(args)
	local nTaskId = mouseArgs.window:getID()
	
	local CTakeActiveAward = require 'protocoldef.knight.gsp.yuanbao.ctakeactiveaward'
	local p = CTakeActiveAward.Create()
	p.page = 4
	p.key = nTaskId
	LuaProtocolManager.getInstance():send(p)
end

-- 每日任务领奖后刷新按钮状态
function BinfenGiftDlg:DailyTaskBtnRefresh(key, flag)
	if self.m_curIndex ~= 4 then return end
	
	local button = self.m_DailyTaskButton[key]
	if not button then return end
	
	-- 未完成或已领取设为未激活
	button:setEnabled(flag == 1)
	-- 领取后显示“已领取”
	if flag == 2 then
		button:setText(MHSD_UTILS.get_resstring(2940))
	end
end

-- 日积月累领奖
function BinfenGiftDlg:HandleAccumulateBtnClick(args)
	local mouseArgs = CEGUI.toMouseEventArgs(args)
	local nTaskId = mouseArgs.window:getID()
	
	local CTakeActiveAward = require 'protocoldef.knight.gsp.yuanbao.ctakeactiveaward'
	local p = CTakeActiveAward.Create()
	p.page = 5
	p.key = nTaskId
	LuaProtocolManager.getInstance():send(p)
end

-- 日积月累领奖后刷新按钮状态
function BinfenGiftDlg:AccumulateBtnRefresh(key, flag)
	if self.m_curIndex ~= 5 then return end
	
	local button = self.m_AccumulateButton[key]
	if not button then return end
	
	-- 未完成或已领取设为未激活
	button:setEnabled(flag == 1)
	-- 领取后显示“已领取”
	if flag == 2 then
		button:setText(MHSD_UTILS.get_resstring(2940))
	end
end

function BinfenGiftDlg:HandleWindowUpdate(eventArgs)
	local nInterval = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    self.m_time1 = self.m_time1 - nInterval
    self.m_time2 = self.m_time2 - nInterval
    self.m_time3 = self.m_time3 - nInterval
	self.m_time4 = self.m_time4 - nInterval
	self.m_time5 = self.m_time5 - nInterval
    
    local lefttimenum = self.m_time1
    if self.m_curIndex == 2 then
      lefttimenum = self.m_time2
    elseif self.m_curIndex == 3 then
      lefttimenum = self.m_time3
	elseif self.m_curIndex == 4 then
		lefttimenum = self.m_time4
	elseif self.m_curIndex == 5 then
		lefttimenum = self.m_time5
    end
  
    local leftSeconds = math.floor(lefttimenum)
    local days, hours, mins, secs = BinfenGiftDlg.GetTimeDetails(leftSeconds)

    local strbuilder = StringBuilder:new()  
    if days > 0  or hours > 0 or mins > 0 then
      strbuilder:SetNum("parameter1", days)
      strbuilder:SetNum("parameter2", hours)
      strbuilder:SetNum("parameter3", mins)
      self.m_txtLeftTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2959)))
    elseif secs > 0 then
      strbuilder:SetNum("parameter1", secs)
      self.m_txtLeftTime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2960)))
    else
        self.m_txtLeftTime:setText(MHSD_UTILS.get_resstring(2961))
    end
    strbuilder:delete()
end

return BinfenGiftDlg
