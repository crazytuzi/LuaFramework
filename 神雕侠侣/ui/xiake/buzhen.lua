require "ui.dialog"
require "ui.team.zhenfachoosedlg"

BuzhenCell = {
m_strNamePrefix,
}
setmetatable(BuzhenCell, Dialog);
BuzhenCell.__index = BuzhenCell;

function BuzhenCell.GetLayoutFileName()
	return "quackcelllist2.layout";
end

function BuzhenCell:OnCreate()
	Dialog.OnCreate(self, nil, self.m_strNamePrefix);

	local winMgr = CEGUI.WindowManager:getSingleton();
	local pfx = self.m_strNamePrefix;

	self.m_vItems = {};
	for i = 1, 5 do
		self.m_vItems[i] = {};
		local v = self.m_vItems[i];
		v.pIcon = winMgr:getWindow(pfx.."quackcelllist2/icon"..tostring(i-1));
        v.pElite = winMgr:getWindow(pfx.."quackcelllist2/elite"..tostring(i-1))
        if v.pElite then
            v.pElite:setVisible(false)
        else
            print("____error get quackcelllist2/elite0_4")
        end
		v.pName = winMgr:getWindow(pfx.."quackcelllist2/name"..tostring(i-1));
		v.pLevel= winMgr:getWindow(pfx.."quackcelllist2/level"..tostring(i-1));
		v.pMark = winMgr:getWindow(pfx.."quackcelllist2/mark"..tostring(i-1));
		v.pScore= winMgr:getWindow(pfx.."quackcelllist2/num"..tostring(i-1));
		v.pFrame= winMgr:getWindow(pfx.."quackcelllist2/quack"..tostring(i-1));
		v.pChange=winMgr:getWindow(pfx.."quackcelllist2/change"..tostring(i-1));
		v.pIcon:subscribeEvent("MouseButtonUp", BuzhenCell.HandleCellClick, v); 
		v.pChange:subscribeEvent("MouseClick", BuzhenCell.HandleCellChangeClick, v);
		v.pChange:setVisible(false);
	end
	self:ClearAll();
end

function BuzhenCell:HandleCellChangeClick(arg)
    print("____BuzhenCell:HandleCellChangeClick")
    
	local tp = BuzhenXiake.getInstance().m_iHuanPos;
    
    if tp and self and self.data then
        print("***************", tp , self, self.data)
    end

	if self.data ~= nil and tp ~= 0 then
        print("____self.data.xiakeid: " .. self.data.xiakeid)
        print("____self.data.xiakekey: " .. self.data.xiakekey)
        if XiakeMng.HasSameXKIDInBattleFromXKID(self.data.xiakeid, tp) then
            local xkReg = XiakeMng.ReadXiakeData(self.data.xiakeid)
            local strbuilder = StringBuilder:new()
            local strMsg = ""
            strbuilder:Set("parameter1", xkReg.xkxx.name)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144934))
            GetGameUIManager():AddMessageTip(strMsg)
            strbuilder:delete()
        else
            local v = std.vector_int_();
            XiakeMng.m_vBattleOrder[tp] = self.data.xiakekey;
            BuzhenCell.SendBattleList();
            --BuzhenXiake.getInstance().m_pHouxuanList:setVisible(false);
            BuzhenXiake.getInstance():LightBattlePos(0);
            BuzhenXiake.getInstance().m_iLastChangePos = 0;

            BuzhenXiake.getInstance().m_iHuanPos = 0;
            BuzhenXiake.getInstance():RefreshXiakes();
        end
	end
end

function BuzhenCell.SendBattleList()
	print("send battle order");
	local v = std.vector_int_();
	for i = 1, 4 do
		if XiakeMng.m_vBattleOrder[i] ~= nil and XiakeMng.m_vBattleOrder[i] ~= 0 then
			v:push_back(XiakeMng.m_vBattleOrder[i]);
			print(XiakeMng.m_vBattleOrder[i]);
		end
	end

	local req = knight.gsp.xiake.CChangeXiakeBattleList(v);
	GetNetConnection():send(req);
	print("send finish");
end

function BuzhenCell:HandleCellClick(arg)
    print("____BuzhenCell:HandleCellClick")
    
	local tp = BuzhenXiake.getInstance().m_iHuanPos;
	local lvl = GetDataManager():GetMainCharacterLevel();
	if XiakeMng.IsBattlePosFull() then
	--[[
		if tp == 3 and lvl < 28 then 
			return;
		end
		if tp == 4 and lvl < 30 then
			return;
		end
		--]]
		local level = XiakeMng.battlePos[tp]
		if not level then
			return;
		end
		if lvl < level then
			return
		end
	end

	if self.data  ~= nil and tp ~= 0 then
        print("____self.data.xiakeid: " .. self.data.xiakeid)
        print("____self.data.xiakekey: " .. self.data.xiakekey)
        if XiakeMng.HasSameXKIDInBattleFromXKID(self.data.xiakeid, tp) then
            local xkReg = XiakeMng.ReadXiakeData(self.data.xiakeid)
            local strbuilder = StringBuilder:new()
            local strMsg = ""
            strbuilder:Set("parameter1", xkReg.xkxx.name)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144934))
            GetGameUIManager():AddMessageTip(strMsg)
            strbuilder:delete()
        else
            local v = std.vector_int_();
            XiakeMng.m_vBattleOrder[tp] = self.data.xiakekey;
            BuzhenCell.SendBattleList();
            --BuzhenXiake.getInstance().m_pHouxuanList:setVisible(false);
        end
	end
end

function BuzhenCell:Reset(i)
	local v = self.m_vItems[i];
	if v then
		v.pIcon:setProperty("Image", "");
        if v.pElite then
            v.pElite:setVisible(false)
        end
		v.pName:setText("");
		v.pLevel:setText("");
		v.pMark:setProperty("Image", "");
		v.pScore:setText("");
		v.pScore:setVisible(false);
	end
end

function BuzhenCell:ClearAll()
	for i = 1, 5 do
		self:Reset(i);
	end
end

function BuzhenCell:SetAddProperty(aBShowAdd)
    self.pChange:setVisible(aBShowAdd)
end

function BuzhenCell:SetXiakeData(aXiakeData, aBShowAdd)
	--self is m_vItem[i];
	self.data = aXiakeData;
    
    if not aXiakeData then
        self.pIcon:setProperty("Image", "");
        if self.pElite then
            self.pElite:setVisible(false)
        end
        self.pName:setText("");
        self.pLevel:setText("");
        self.pMark:setProperty("Image", "");
        self.pScore:setText("");
        self.pFrame:setProperty("Image", XiakeMng.eXiakeFrames[3]);
        self.pChange:setVisible(false)
        return
    end

	local xk = XiakeMng.ReadXiakeData(aXiakeData.xiakeid);
	self.pIcon:setProperty("Image", xk.path);
    if self.pElite then
        self.pElite:setVisible(XiakeMng.IsElite(aXiakeData.xiakekey))
    end
	self.pName:setText(scene_util.GetPetNameColor(aXiakeData.color)..xk.xkxx.name);
	self.pLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
	self.pMark:setProperty("Image", XiakeMng.eLvImages[aXiakeData.starlv]);
	self.pScore:setText(tostring(aXiakeData.score));
	self.pFrame:setProperty("Image", XiakeMng.eXiakeFrames[aXiakeData.color]);
	self.pChange:setVisible(aBShowAdd);
end

function BuzhenCell:ShowCell(bVisible)
    self.m_pMainFrame:setVisible(bVisible)
end

function BuzhenCell:new()
	local cell = {};
	cell = Dialog:new();
	setmetatable(cell, BuzhenCell);

	return cell;
end

function CreateBuzhenItem(aStrPrefix)
	local ret = BuzhenCell:new();
	ret.m_strNamePrefix = aStrPrefix;
	ret:OnCreate();

	return ret;
end


BuzhenXiake = {
m_pBtnCurZhen,

m_pBattlocs = {},
m_pChangeBtns = {},

m_iHuanPos, 

m_pHouxuanList,
m_pHouxuanLight,

m_iLastChangePos,

m_vRows,

m_vBattlePos,
m_pBtnZhen,
m_vHuans,

m_xiakesNotInBattle = nil,
m_iBarPos = 0,
m_iCurPage = 1,
m_iOnePageCount = 3,

m_pTeam = {}  --Zhenrong buttons
}

setmetatable(BuzhenXiake, Dialog);
BuzhenXiake.__index = BuzhenXiake;

local _instance;
function BuzhenXiake.getInstance()
	if not _instance then
		_instance = BuzhenXiake:new();
		_instance:OnCreate();
	end

	return _instance;
end

function BuzhenXiake.peekInstance()
	return _instance;
end

function BuzhenXiake:SetVisible(bV)
	if self.m_pMainFrame:isVisible() == bV then return; end

	self.m_pMainFrame:setVisible(bV);
	if bV then
	else
	end
end

function BuzhenXiake.DestroyDialog()
	if _instance then
        _instance:cleanupPane()
		_instance:OnClose();
		_instance = nil;
	end

	if XiakeMainFrame.peekInstance() then
		XiakeMainFrame.DestroyDialog();
	end
end

function BuzhenXiake.GetLayoutFileName()
	return "quacksort.layout";
end

function BuzhenXiake:OnCreate()
	Dialog.OnCreate(self);

	self.m_vRows = {};
	self.m_iLastChangePos = 0;

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_vBattlePos = {};
	self.m_iHuanPos = 0;
	self.m_vBattlePos[1] = {};
	self.m_vBattlePos[1].pHead = winMgr:getWindow("quacksort/Back/Team0/Head");
	self.m_vBattlePos[1].pElite = winMgr:getWindow("quacksort/Back/Team0/elite")
    if self.m_vBattlePos[1].pElite then
        self.m_vBattlePos[1].pElite:setVisible(false)
    else
        print("____error get quacksort/Back/Team0/elite")
    end
    self.m_vBattlePos[1].pName = winMgr:getWindow("quacksort/Back/Team0/Name");
	self.m_vBattlePos[1].pMark = winMgr:getWindow("quacksort/Back/Team0/mark");
	self.m_vBattlePos[1].pLevel = winMgr:getWindow("quacksort/Back/Team0/level");
	local md = GetDataManager():GetMainCharacterData();
	local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(md.shape);
	self.m_vBattlePos[1].pHead:setProperty("Image", GetIconManager():GetImagePathByID(shape.headID):c_str());
	self.m_vBattlePos[1].pName:setText(md.strName);
	self.m_vBattlePos[1].pMark:setProperty("Image", "");
	self.m_vBattlePos[1].pLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));

	
	for i = 2, 5 do
		self.m_vBattlePos[i] = {};
		self.m_vBattlePos[i].pHead = winMgr:getWindow("quacksort/Back/Team/Head"..tostring(i - 1));
        self.m_vBattlePos[i].pElite = winMgr:getWindow("quacksort/Back/Team/elite"..tostring(i - 1))
        if self.m_vBattlePos[i].pElite then
            self.m_vBattlePos[i].pElite:setVisible(false)
        else
            print("____error get quacksort/Back/Team/elite1_4")
        end
		self.m_vBattlePos[i].pName = winMgr:getWindow("quacksort/Back/Team/Name"..tostring(i - 1));
		self.m_vBattlePos[i].pLight = winMgr:getWindow("quacksort/Back/Light"..tostring(i - 1));
		self.m_vBattlePos[i].pAdd = winMgr:getWindow("quacksort/Back/add"..tostring(i - 1));
		self.m_vBattlePos[i].pChange = winMgr:getWindow("quacksort/Back/change"..tostring(i - 1));
		self.m_vBattlePos[i].pMark = winMgr:getWindow("quacksort/Back/mark"..tostring(i - 1));
		self.m_vBattlePos[i].pLevel = winMgr:getWindow("quacksort/Back/level"..tostring(i - 1));
		self.m_vBattlePos[i].pFrame = winMgr:getWindow("quacksort/Back/Team"..tostring(i - 1));

		self.m_vBattlePos[i].pLight:setVisible(false);
		self.m_vBattlePos[i].pAdd:setVisible(false);
		self.m_vBattlePos[i].pChange:setVisible(false);
		self.m_vBattlePos[i].pMark:setProperty("Image", "");
		self.m_vBattlePos[i].pLevel:setText("");
		self.m_vBattlePos[i].pName:setText("");
		self.m_vBattlePos[i].pHead:setProperty("Image", "");

		self.m_vBattlePos[i].pHead:subscribeEvent("MouseClick", BuzhenXiake.HandleHeadClicked, i);
		self.m_vBattlePos[i].pAdd:subscribeEvent("MouseClick", BuzhenXiake.HandleAddClicked, i);
		self.m_vBattlePos[i].pChange:subscribeEvent("MouseClick", BuzhenXiake.HandleChangeClicked, i);
	end

	self.m_vBattlePos[4].pLock = winMgr:getWindow("quacksort/Back/lock1");
	self.m_vBattlePos[5].pLock = winMgr:getWindow("quacksort/Back/lock2");
	local curLevel = GetDataManager():GetMainCharacterLevel();
--	if curLevel >= 28 then
		self.m_vBattlePos[4].pLock:setVisible(false);
--	end

--	if curLevel >= 30 then
		self.m_vBattlePos[5].pLock:setVisible(false);
--	end

	self.m_pBtnZhen = winMgr:getWindow("quacksort/Back/sortbtn");
	self.m_pBtnZhen:subscribeEvent("Clicked", BuzhenXiake.HandleBuzhenClick, self);
	self.m_vHuans = {};
	self.m_vHuans[1] = winMgr:getWindow("quacksort/Back/btn0");
	self.m_vHuans[2] = winMgr:getWindow("quacksort/Back/btn1");
	self.m_vHuans[3] = winMgr:getWindow("quacksort/Back/btn2");
	self.m_vHuans[4] = winMgr:getWindow("quacksort/Back/btn3");
	for i = 1, 4 do
		self.m_vHuans[i]:subscribeEvent("Clicked", BuzhenXiake.HandleHuanClick, i);
		self.m_vHuans[i]:setVisible(false);
	end

	self.m_pHouxuanLight = winMgr:getWindow("quacksort/Back/Member/Light");
	self.m_pHouxuanLight:setVisible(false);
	self.m_pHouxuanLight:setMousePassThroughEnabled(true);
	self.m_pHouxuanLight:setAlwaysOnTop(true);
	self.m_pHouxuanList  = CEGUI.Window.toScrollablePane(winMgr:getWindow("quacksort/Back/Member"))
    self.m_pHouxuanList:subscribeEvent("NextPage", BuzhenXiake.HandleScrollNextPage, self)
	
	--create zhenrong buttons
	self.m_pTeam = {}
	for i=1, 3 do
		self.m_pTeam[i] = CEGUI.Window.toGroupButton(winMgr:getWindow("quacksort/Back/team"..tostring(i-1)))
		self.m_pTeam[i]:setGroupID(1)
		self.m_pTeam[i]:setID(i)
		self.m_pTeam[i]:setSelected(false)
	end
	self.m_pTeam[XiakeMng.m_iZhenRong]:setSelected(true)
	for i=1, 3 do
		self.m_pTeam[i]:subscribeEvent("SelectStateChanged", BuzhenXiake.HandleSelectZhenRongClicked, self)
	end	
	self:RefreshXiakes();
	self:RefreshBattleOrder();
	self:refreshFormation()
end

function BuzhenXiake:cleanupPane()
    LogInfo("____BuzhenXiake:cleanupPane")
    
    self.m_pHouxuanList:cleanupNonAutoChildren()
    self.m_xiakesNotInBattle = nil
    self.m_iBarPos = 0
    self.m_iCurPage = 1
end

function BuzhenXiake:HandleScrollNextPage(args)
    LogInfo("____BuzhenXiake:HandleScrollNextPage")
    
    local maxPage = 0
    if self.m_xiakesNotInBattle then
        maxPage = math.ceil(#self.m_xiakesNotInBattle/5)
    else
        print("____error not self.m_xiakesNotInBattle")
        local xiakes = XiakeMng.GetXiakesOrderByScore()
        maxPage = math.ceil(#xiakes/5)
    end

    if self.m_iCurPage < maxPage then
        self.m_iCurPage = self.m_iCurPage + 1
        self.m_iBarPos = self.m_pHouxuanList:getVertScrollbar():getScrollPosition()
        self.m_pHouxuanList:getVertScrollbar():Stop()
        
        local aShowAddBtn = nil
        if self.m_vRows[1] and self.m_vRows[1].m_vItems[1] and self.m_vRows[1].m_vItems[1].pChange then
            local pChange = self.m_vRows[1].m_vItems[1].pChange
            
            if pChange:isVisible() then
                aShowAddBtn = true
            end
        end
        
        self:RefreshXiakes(aShowAddBtn, true)
    end

	return true
end

function BuzhenXiake:RefreshBattleOrder()
print("+++++++++++++battle order+++++++++");
	local bo = XiakeMng.m_vBattleOrder;
	for i = 1, 4 do
		local xk = XiakeMng.m_vXiakes[bo[i]];
		if bo[i] ~= 0 and xk ~= nil then
			local xkd = XiakeMng.ReadXiakeData(xk.xiakeid);
			self.m_vBattlePos[i + 1].pAdd:setVisible(false);
			self.m_vBattlePos[i + 1].pMark:setProperty("Image", XiakeMng.eLvImages[xk.starlv]);
			self.m_vBattlePos[i + 1].pLevel:setText(GetDataManager():GetMainCharacterLevel());
			self.m_vBattlePos[i + 1].pName:setText(scene_util.GetPetNameColor(xk.color)..(xkd.xkxx.name));
			self.m_vBattlePos[i + 1].pHead:setProperty("Image", xkd.path);
            if self.m_vBattlePos[i + 1].pElite then
                self.m_vBattlePos[i + 1].pElite:setVisible(XiakeMng.IsElite(xk.xiakekey))
            end
			self.m_vBattlePos[i + 1].pFrame:setProperty("Image", XiakeMng.eXiakeFrames[xk.color]);
		else
			local curLevel = GetDataManager():GetMainCharacterLevel();
--			if curLevel >= 30 then
				self.m_vBattlePos[i + 1].pAdd:setVisible(true);
--			elseif curLevel >= 28 and i ~= 4 then
--				self.m_vBattlePos[i + 1].pAdd:setVisible(true);
--			elseif curLevel < 28 and i ~= 3 and i ~= 4 then
--				self.m_vBattlePos[i + 1].pAdd:setVisible(true);
--			end

			self.m_vBattlePos[i + 1].pAdd:moveToFront();
			self.m_vBattlePos[i + 1].pMark:setProperty("Image", "");
			self.m_vBattlePos[i + 1].pLevel:setText("");
			self.m_vBattlePos[i + 1].pName:setText("");
			self.m_vBattlePos[i + 1].pHead:setProperty("Image", "");
            if self.m_vBattlePos[i + 1].pElite then
                self.m_vBattlePos[i + 1].pElite:setVisible(false)
            end
			self.m_vBattlePos[i + 1].pFrame:setProperty("Image", XiakeMng.eXiakeFrames[3]);
		end
	end
	self:RefreshXiakes()
end

function BuzhenXiake:GetItem(index)
	if index <= 0 then return; end
	
	local c = index%5;
	if c == 0 then c = 5; end
	local r = math.ceil(index/5);
	if r > #self.m_vRows then
		for i = #self.m_vRows + 1, r do
			local nr = CreateBuzhenItem("buzhen"..tostring(i));
			self.m_vRows[#self.m_vRows + 1] = nr;
			self.m_pHouxuanList:addChildWindow(nr.m_pMainFrame);
			XiakeMng.SetWndPos(nr.m_pMainFrame, 0, (i-1) * 250 + 1);
		end
	end

	return self.m_vRows[r].m_vItems[c];
end

function BuzhenXiake:RefreshXiakes(aShowAddBtn, isNextPage)
--	self.m_pHouxuanList:setVisible(true);
    
    LogInfo("____BuzhenXiake:RefreshXiakes")

	local xiakes = XiakeMng.GetXiakesOrderByScore();
    
    if not isNextPage then
        self.m_iBarPos = 0
        self.m_iCurPage = 1
        self.m_xiakesNotInBattle = xiakes
    end

	local startPos = (self.m_iCurPage-1)*self.m_iOnePageCount*5 + 1;
    local endPos = startPos + self.m_iOnePageCount*5 - 1
    
    local num = #xiakes
    if isNextPage then
        num = #self.m_xiakesNotInBattle
    end
    
    if endPos > num then
        endPos = num
    end

    local indexCellOld = -1
    local indexCellNew = -1
    for index = startPos, endPos, 1 do
        
        --print("____index: " .. index)

        local item = self:GetItem(index)
        
        if self.m_xiakesNotInBattle and self.m_xiakesNotInBattle[index] then
            BuzhenCell.SetXiakeData(item, self.m_xiakesNotInBattle[index], aShowAddBtn ~= nil)
        else
            print("____error have not get xiake")
            BuzhenCell.SetXiakeData(item, xiakes[index], aShowAddBtn ~= nil)
        end

        indexCellNew = math.ceil(index/5)
        
        if indexCellNew ~= indexCellOld then
            if self.m_vRows[indexCellNew] then
                XiakeMng.SetWndPos(self.m_vRows[indexCellNew].m_pMainFrame, 0, (indexCellNew-1)*250+1);
                self.m_vRows[indexCellNew]:ShowCell(true)
            end
            indexCellOld = indexCellNew
        end
    end
    
    local endRow = math.ceil(endPos/5)
    local totalEndPos = endRow * 5
    print("____endPos: " .. endPos .. " totalEndPos: " .. totalEndPos)
    for k = endPos+1, totalEndPos, 1 do
        local col = k%5
        if col == 0 then
            col = 5
        end
        
        print("____endRow: " .. endRow .. " pos: " .. k .. " col: " .. col)
        if self.m_vRows and self.m_vRows[endRow] and self.m_vRows[endRow].m_vItems[col] then
            print("____cur row col item exist")
            local curItem = self.m_vRows[endRow].m_vItems[col]
            BuzhenCell.SetXiakeData(curItem, nil, false)
        end
    end
    for j = endRow+1, #self.m_vRows, 1 do
        --print("____j: " .. j)
        
        if self.m_vRows[j] then
            XiakeMng.SetWndPos(self.m_vRows[j].m_pMainFrame, 0, 1);
            self.m_vRows[j]:ShowCell(false)
        else
            print("error not get self.m_vRows[j]")
        end
    end
    
    --set scroll bar pos
	if self.m_iCurPage == 1 then
		self.m_pHouxuanList:getVertScrollbar():setScrollPosition(0)
	else
		self.m_pHouxuanList:getVertScrollbar():setScrollPosition(self.m_iBarPos)
	end	
	
	local t = BuzhenXiake.getInstance();
	t:LightBattlePos(0);
	t.m_iLastChangePos = 0;
--	t.m_pHouxuanList:setVisible(false);
	BuzhenXiake.getInstance():SetCurScrollConAddProp(false)
	BuzhenXiake.getInstance().m_iHuanPos = 0;	
end

function BuzhenXiake:RefreshXiakesKeepOldAddState()
    LogInfo("____BuzhenXiake:RefreshXiakesKeepOldAddState")

    local aShowAddBtn = nil
    if self.m_vRows[1] and self.m_vRows[1].m_vItems[1] and self.m_vRows[1].m_vItems[1].pChange then
        local pChange = self.m_vRows[1].m_vItems[1].pChange
        
        if pChange:isVisible() then
            aShowAddBtn = true
        end
    end
    
    self:RefreshXiakes(aShowAddBtn)
end

function BuzhenXiake:SetCurScrollConAddProp(bShowAdd)
    LogInfo("____BuzhenXiake:SetCurScrollConAddProp")
    
    bShowAdd = bShowAdd or false
    
    local startPos = 1
    local endPos = (self.m_iCurPage)*self.m_iOnePageCount*5
    
    local num = 0
    if self.m_xiakesNotInBattle then
        num = #self.m_xiakesNotInBattle
    else
        local xiakes = XiakeMng.GetXiakesOrderByScore()
        num = #xiakes
    end
    
    if endPos > num then
        endPos = num
    end
    
    for index = startPos, endPos, 1 do
        local item = self:GetItem(index)
        BuzhenCell.SetAddProperty(item, bShowAdd)
    end
end

function BuzhenXiake:LightBattlePos(index)
	for i = 2, 5 do
		if index == 0 then
			self.m_vBattlePos[i].pLight:setVisible(false);
			self.m_vBattlePos[i].pChange:setVisible(false);
		elseif index == i then
			self.m_vBattlePos[i].pLight:setVisible(true);
		elseif XiakeMng.m_vBattleOrder[i - 1] ~= nil and XiakeMng.m_vBattleOrder[i - 1] ~= 0 then
			self.m_vBattlePos[i].pLight:setVisible(false);
			self.m_vBattlePos[i].pChange:setVisible(true);
			self.m_vBattlePos[i].pChange:moveToFront();
		end
	end
end

function BuzhenXiake:HandleHeadClicked(arg)
	local t = BuzhenXiake.getInstance();
	if t.m_iLastChangePos == 0 then
		t.m_iLastChangePos = self;
		t.m_iHuanPos = self - 1;
		t:LightBattlePos(self);
		t:SetCurScrollConAddProp(true)
	end	
end

function BuzhenXiake:HandleAddClicked(arg)
	print("add clicked");
	BuzhenXiake.getInstance().m_iHuanPos = self - 1;
	--BuzhenXiake.getInstance():RefreshXiakes();
end

function BuzhenXiake:HandleChangeClicked(arg)
	print("change clicked");
	local t = BuzhenXiake.getInstance();
	if t.m_iLastChangePos ~= 0 then
		print(t.m_iLastChangePos, self);
		local tmp = XiakeMng.m_vBattleOrder[t.m_iLastChangePos - 1];
		XiakeMng.m_vBattleOrder[t.m_iLastChangePos - 1] = XiakeMng.m_vBattleOrder[self - 1];
		XiakeMng.m_vBattleOrder[self - 1] = tmp;
		BuzhenCell.SendBattleList();
		t:LightBattlePos(0);
		t.m_iLastChangePos = 0;
--		t.m_pHouxuanList:setVisible(false);
		BuzhenXiake.getInstance():SetCurScrollConAddProp(false)
		BuzhenXiake.getInstance().m_iHuanPos = 0;
	end
end

function BuzhenXiake:HandleBuzhenClick(arg)
	print("buzhen");
	ZhenfaChooseDlg.getInstanceAndShow()
end

function BuzhenXiake:HandleHuanClick(arg)
	BuzhenXiake.getInstance().m_iHuanPos = self;
	BuzhenXiake.getInstance().m_iLastChangePos = 0;
	BuzhenXiake.getInstance():LightBattlePos(0);
	BuzhenXiake.getInstance():RefreshXiakes();
end

function BuzhenXiake:HandleSelectZhenRongClicked(arg)
	local selected = self.m_pTeam[1]:getSelectedButtonInGroup():getID()
	if XiakeMng.m_iZhenRong ~= selected then
		require "protocoldef.knight.gsp.xiake.cchangexiakezhenrong"	
		XiakeMng.m_iZhenRong = selected 
		local p = CChangeXiakeZhenrong.Create()
		p.zhenrong = selected;
		LuaProtocolManager.getInstance():send(p)
	end
end

function BuzhenXiake:new()
	local buzhen = {};
	buzhen = Dialog:new();
	setmetatable(buzhen, BuzhenXiake);

	return buzhen;
end

function BuzhenXiake:refreshFormation()
	LogInfo("buzhenxiake refresh formation")
	local manager = FormationManager.getInstance()
	local formationConfig = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(manager.m_iMyFormation)
	self.m_pBtnZhen:setText(formationConfig.name)
end

return BuzhenXiake;

