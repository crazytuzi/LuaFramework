require "ui.dialog"
require "utils.scene_common"
require "ui.xiake.skillbooksxk"
require "ui.xiake.skill_xkjh"
require "ui.xiake.skill_xktips"

XiakeListItemMore = {
ePageSize = 10,
}
setmetatable(XiakeListItemMore, Dialog);
XiakeListItemMore.__index = XiakeListItemMore;

function XiakeListItemMore:OnCreate()
	Dialog.OnCreate(self);
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pBtn = winMgr:getWindow("quackmorebtn/next");	
	self.m_pBtn:subscribeEvent("Clicked", XiakeListItemMore.HandleMore, self);
end

function XiakeListItemMore.GetLayoutFileName()
	return "quackmorebtn.layout";
end

function XiakeListItemMore:HandleMore(arg)
	print("more clicked");
	local myxk = MyXiake_xiake.peekInstance();
	if myxk ~= nil then
		myxk.m_iPageCount = myxk.m_iPageCount + 1;
		myxk:RefreshMyXiakes();
	end
end

function XiakeListItemMore:new()
	local moreItem = {};
	moreItem = Dialog:new();
	setmetatable(moreItem, XiakeListItemMore);
	return moreItem;
end

function CreateListItemMore()
	local ret = XiakeListItemMore:new();
	ret:OnCreate();

	return ret;
end

XiakeListItem = {
m_strNamePrefix,
m_pXiakeFrame,
m_XiakeData,
m_pMarkInBattle,
m_pType,
m_pJie,
m_pJieIcon,
m_pScore,
m_pTxtLevel,

m_pIcon,
m_pName,
m_pPanel,

m_pBtnJinhua,
m_pBtnEnterBattle
}
setmetatable(XiakeListItem, Dialog);
XiakeListItem.__index = XiakeListItem;

function XiakeListItem:OnCreate()

	print(self.m_strNamePrefix);

	Dialog.OnCreate(self, nil, self.m_strNamePrefix);

	local winMgr = CEGUI.WindowManager:getSingleton();

	local pfx = self.m_strNamePrefix;
	self.m_pMarkInBattle = winMgr:getWindow(pfx.."quackowncell/mark");
	self.m_pMarkInBattle:setAlwaysOnTop(true);
	self.m_pType = winMgr:getWindow(pfx.."quackowncell/info0");
	self.m_pJieTxt = winMgr:getWindow(pfx.."quackowncell/txt1");
	self.m_pJie  = winMgr:getWindow(pfx.."quackowncell/info1");
	self.m_pJieIcon = winMgr:getWindow(pfx.."quackowncell/role/mark");
	self.m_pJieIcon:setProperty("Image", "");
	self.m_pScore= winMgr:getWindow(pfx.."quackowncell/info2");
	self.m_pQiXueTxt = winMgr:getWindow(pfx.."quackowncell/txt3");
	self.m_pQiXueInfo = CEGUI.Window.toProgressBar(winMgr:getWindow(pfx.."quackowncell/txt3/info3"));
	self.m_pQiXueTxt:setVisible(false)

	self.m_pDeadBlack = winMgr:getWindow(pfx.."quackowncell/back/black")
	self.m_pDeadBlack:setVisible(false)

	self.m_pXiakeFrame = winMgr:getWindow(pfx.."quackowncell/role");
    self.m_pElite = winMgr:getWindow(pfx.."quackowncell/role/elite")
    if self.m_pElite then
        self.m_pElite:setVisible(false)
    else
        print("____error get quackowncell/role/elite")
    end
	self.m_pIcon = winMgr:getWindow(pfx.."quackowncell/role/icon");
	self.m_pName = winMgr:getWindow(pfx.."quackowncell/role/name");

	self.m_pPanel = winMgr:getWindow(pfx.."quackowncell/back");
	self.m_pTxtLevel = winMgr:getWindow(pfx.."quackowncell/role/level");
	self.m_pBtnJinhua = winMgr:getWindow(pfx.."quackowncell/btn0");
	self.m_pBtnEnterBattle = winMgr:getWindow(pfx.."quackowncell/btn2");

	self.m_pType:setText("");
	self.m_pJie:setText("");
	self.m_pScore:setText("");

	self.m_pName:setText("");
	self.m_pMarkInBattle:setVisible(false);
	self.m_pBtnJinhua:subscribeEvent("Clicked", XiakeListItem.HandleJinHua, self);
	if MyXiake_xiake.peekInstance() and MyXiake_xiake.peekInstance().m_ViewMode == 1 then
		self.m_pBtnEnterBattle:subscribeEvent("Clicked", XiakeListItem.HandleEnterBattle_yuanzheng, self);
	else
		self.m_pBtnEnterBattle:subscribeEvent("Clicked", XiakeListItem.HandleEnterBattle, self);
	end
	self.m_pPanel:setMousePassThroughEnabled(false);
	self.m_pPanel:subscribeEvent("MouseClick", XiakeListItem.HandleSelect, self);
	self.m_pIcon:subscribeEvent("MouseButtonUp", XiakeListItem.HandleSelect, self);
end

function XiakeListItem.GetLayoutFileName()
	return "quackowncell.layout";
end

function XiakeListItem:GetWnd()
	return self.m_pMainFrame;
end

function XiakeListItem:HandleSelect(arg)
	print("handle select");
	if self.m_XiakeData == nil then
		print("***********************xia ke list");
	end
	if XiakeMng.m_vXiakes[self.m_XiakeData.xiakekey] ~= nil and
	self.m_XiakeData ~= XiakeMng.m_vXiakes[self.m_XiakeData.xiakekey] then
		self.m_XiakeData = XiakeMng.m_vXiakes[self.m_XiakeData.xiakekey];
	end

	if self.m_XiakeData.bIsDetail == nil or self.m_XiakeData.bIsDetail == false then
		--request detail info
		local req = knight.gsp.xiake.CGetMyXiakeInfo(self.m_XiakeData.xiakekey);
		GetNetConnection():send(req);
	end
	MyXiake_xiake.getInstance().m_iSelectedXiakeKey = self.m_XiakeData.xiakekey;
	MyXiake_xiake.getInstance():RefreshCurrentXiake(self.m_XiakeData);
end

function XiakeListItem:HandleJinHua(arg)
    print("____XiakeListItem:HandleJinHua")
    print("____self.m_XiakeData.xiakekey: " .. self.m_XiakeData.xiakekey)
	JinhuaXiake.Show(XiakeMng.m_vXiakes[self.m_XiakeData.xiakekey]);
	XiakeMng.RequestUpgradeXiake(self.m_XiakeData.xiakekey, 0);
end

function XiakeListItem:HandleEnterBattle(arg)
	LogInfo("____XiakeListItem:HandleEnterBattle")

    if self.m_bInBattle then
        LogInfo("self.m_bInBattle: true")
    else
        LogInfo("self.m_bInBattle: false")
	end
    
    local bOrderChanged = false;
	if self.m_bInBattle == true then
		for i = 1, 4 do
			if XiakeMng.m_vBattleOrder[i] ~= nil and self.m_XiakeData ~= nil and XiakeMng.m_vBattleOrder[i] == self.m_XiakeData.xiakekey then
				XiakeMng.m_vBattleOrder[i] = nil;
				bOrderChanged = true;
			end
		end
	else
		--lvl < 28 max 2
		--lvl < 30 max 3
		local iCount = 0;
		for i = 1, 4 do
			if XiakeMng.m_vBattleOrder[i] ~= nil and XiakeMng.m_vBattleOrder[i] ~= 0 then
				iCount = iCount + 1;
			end
		end
		
		-- local lvl = GetDataManager():GetMainCharacterLevel();
		-- if lvl >= 28 and lvl < 30 and iCount >= 3 then
		-- 	return;--addmsg
		-- end

		-- if lvl < 28 and iCount >= 2 then
		-- 	return;	
		-- end
		
        if XiakeMng.HasSameXKIDInBattleFromXKID(self.m_XiakeData.xiakeid) then
            local xkReg = XiakeMng.ReadXiakeData(self.m_XiakeData.xiakeid)
            local strbuilder = StringBuilder:new()
            local strMsg = ""
            strbuilder:Set("parameter1", xkReg.xkxx.name)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144934))
            GetGameUIManager():AddMessageTip(strMsg)
            strbuilder:delete()
            return
        end

		for i = 1, 4 do
			if XiakeMng.m_vBattleOrder[i] == nil or XiakeMng.m_vBattleOrder[i] == 0 then
				if self.m_XiakeData ~= nil then
					XiakeMng.m_vBattleOrder[i] = self.m_XiakeData.xiakekey;
					bOrderChanged = true;
					break;
				end
			end
		end
	end
	if bOrderChanged then
		BuzhenCell.SendBattleList();
	else
		GetGameUIManager():AddMessageTipById(144936);
	end
end

function XiakeListItem:HandleEnterBattle_yuanzheng(arg)
	if #XiakeMng.m_vBattleOrder_yuanzheng == 4 and not self.m_bInBattle then
		GetGameUIManager():AddMessageTipById(144936)
		return
	end
	local xiake = XiakeMng.GetXiakeFromKey(self.m_XiakeData.xiakekey)
	local idx = 0
	for i,v in ipairs(XiakeMng.m_vBattleOrder_yuanzheng) do
		local xiaket = XiakeMng.GetXiakeFromKey(v)
		if xiaket.xiakeid == xiake.xiakeid then
			idx = i
			break
		end
	end
	if idx > 0 and self.m_bInBattle then
		table.remove(XiakeMng.m_vBattleOrder_yuanzheng, idx)
	elseif not self.m_bInBattle then
		table.insert(XiakeMng.m_vBattleOrder_yuanzheng, xiake.xiakekey)
	end
	local CChangeXiake = require "protocoldef.knight.gsp.xiake.xiaganyidan.cchangexiake"
	local req = CChangeXiake.Create()
	req.fightxiakes = XiakeMng.m_vBattleOrder_yuanzheng
	LuaProtocolManager.getInstance():send(req)
end

function XiakeListItem:SetXiakeInfo(aXiake)
	self.m_XiakeData = aXiake;

	local aXiakeID = aXiake.xiakeid;
	local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
	local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
	
    --xiaolong added for elite
    if self.m_pElite then
        self.m_pElite:setVisible(XiakeMng.IsElite(aXiake.xiakekey))
    end

    local path = GetIconManager():GetImagePathByID(shape.headID):c_str();
    self.m_pIcon:setProperty("Image", path);
	local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
	
	self.m_pJieIcon:setProperty("Image", XiakeMng.eLvImages[aXiake.starlv]);
	self.m_pType:setText(xkxx.kinddes);
	self.m_pJie:setText(MHSD_UTILS.get_resstring(XiakeMng.eColorDes[aXiake.color])..MHSD_UTILS.get_resstring(XiakeMng.eJieDes[aXiake.starlv]));
	self.m_pScore:setText(tostring(aXiake.score));
	self.m_pTxtLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
	self.m_pName:setText(scene_util.GetPetNameColor(aXiake.color)..xkxx.name);
	self.m_pXiakeFrame:setProperty("Image", XiakeMng.eXiakeFrames[aXiake.color]);

	self.m_pJieTxt:setVisible(false)
	self.m_pQiXueTxt:setVisible(false)
	self.m_pBtnEnterBattle:setEnabled(true)
	if MyXiake_xiake.peekInstance().m_ViewMode == 1 then
		local yuanzheng = XiakeMng.GetXiaKeYuanZhengData(self.m_XiakeData.xiakekey)
		self.m_pQiXueInfo:setProgress(yuanzheng.qixue)
		self.m_pQiXueInfo:setText(tostring(math.floor(yuanzheng.qixue*100)) .. "%")
		self.m_pQiXueTxt:setVisible(true)
		self.m_pDeadBlack:setVisible(yuanzheng.hasdead)
		self.m_pBtnEnterBattle:setEnabled(not yuanzheng.hasdead)
	else
		self.m_pJieTxt:setVisible(true)
	end
end

function XiakeListItem:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, XiakeListItem);

	return self;
end

function CreateListItem(aStrPrefix)
	local ret = XiakeListItem:new();
	ret.m_strNamePrefix = aStrPrefix;
	ret:OnCreate();

	return ret;
end

MyXiake_xiake = {
m_iSelectedXiakeKey,
--left
m_pXiakeList,
m_vXiakeItems,

--right
m_pXiakeFrame,
m_pXiakeIcon,
m_pXiakeName,
m_pTextLevel,
m_pMark,

m_pTextLife,
m_pTextNeiShang,
m_pTextWaiShang,
m_pTextWaiFang,
m_pTextNeiFang,
m_pTextSpeed,

	--yuan
m_vpTextYuans,
m_vpYuanBacks,

	--skill_xian_tian
m_vpSkillsXian,

	--skill_hou_tian
m_vpSkillsHou,
m_vpSkillLevels,
}

setmetatable(MyXiake_xiake, Dialog);
MyXiake_xiake.__index = MyXiake_xiake;

local _instance;
function MyXiake_xiake.getInstance()
	if not _instance then
		_instance = MyXiake_xiake:new();
		_instance:OnCreate();
	end

	local frame = XiakeMainFrame:getInstance();
	if frame ~= nil then
		frame.m_pMainFrame:setVisible(true);
	end

	return _instance;
end

function MyXiake_xiake.peekInstance()
	return _instance;
end

function MyXiake_xiake:SetVisible(bV)
	if bV == self.m_pMainFrame:isVisible() then return; end
    
	self.m_pMainFrame:setVisible(bV);
end

function MyXiake_xiake.GetLayoutFileName()
	return "quackowndialog.layout";
end

function MyXiake_xiake:HandleNextPage(arg)
	self.m_iPageCount = self.m_iPageCount + 1;
	local barPos = self.m_pXiakeList:getVertScrollbar():getScrollPosition();
	self.m_pXiakeList:getVertScrollbar():Stop();
	self:RefreshMyXiakes();
	self.m_pXiakeList:getVertScrollbar():setScrollPosition(barPos);
end

function MyXiake_xiake:OnCreate()
	Dialog.OnCreate(self);

	self.m_vXiakeItems = {};
	self.m_vpTextYuans = {};
	self.m_vpYuanBacks = {};
	self.m_vpSkillsXian = {};
	self.m_vpSkillsHou = {};
	self.m_mapSkill = {};
	self.m_iPageCount = 1;
	self.m_pNextPageBtn = nil;

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_pXiakeFrame = winMgr:getWindow("quackowndialog/right/role");
    self.m_pElite = winMgr:getWindow("quackowndialog/right/role/elite")
    if self.m_pElite then
        self.m_pElite:setVisible(false)
    else
        print("____error get quackowndialog/right/role/elite")
    end
	self.m_pXiakeList = CEGUI.Window.toScrollablePane(winMgr:getWindow("quackowndialog/left"));
	self.m_pTextLevel = winMgr:getWindow("quackowndialog/right/role/level");
	self.m_pTextLevel:setText("");
	self.m_pMark = winMgr:getWindow("quackowndialog/right/role/mark");
	self.m_pMark:setProperty("Image", "");
	self.m_pXiakeIcon = winMgr:getWindow("quackowndialog/right/role/icon");
	self.m_pXiakeName = winMgr:getWindow("quackowndialog/right/role/name");
	self.m_pTextLife = winMgr:getWindow("quackowndialog/right/num");
	self.m_pTextWaiShang = winMgr:getWindow("quackowndialog/right/num1");
	self.m_pTextWaiFang = winMgr:getWindow("quackowndialog/right/num2");
	self.m_pTextNeiFang = winMgr:getWindow("quackowndialog/right/num3");
	self.m_pTextSpeed = winMgr:getWindow("quackowndialog/right/num4");
    self.m_pLblShanghaiLeixing = winMgr:getWindow("quackowndialog/right/txt1");
    self.m_pTextLife:setText("");
	self.m_pTextWaiShang:setText("");
	self.m_pTextWaiFang:setText("");
	self.m_pTextSpeed:setText("");
	self.m_pTextNeiFang:setText("");
    
    --xiaolong add for chuan gong xing ji
    self.m_groupREdBoxStar = winMgr:getWindow("quackowndialog/right/txt")
    self.m_arrREdBoxStar = {}
    for i = 1, 5, 1 do
        self.m_arrREdBoxStar[i] = CEGUI.Window.toRichEditbox(winMgr:getWindow("quackowndialog/right/txt/box" .. (i-1)))
    end
    self.m_groupREdBoxStar:setVisible(false)

	self.m_pXiakeList:subscribeEvent("NextPage", MyXiake_xiake.HandleNextPage, self);

	for i = 1, 6 do
		self.m_vpTextYuans[i] = winMgr:getWindow("quackowndialog/right/info1/name"..(i-1));
		self.m_vpTextYuans[i]:setText("");
		self.m_vpTextYuans[i]:subscribeEvent("MouseClick", MyXiake_xiake.HandleYuanClick, self);

		self.m_vpYuanBacks[i] = winMgr:getWindow("quackowndialog/right/info1/back"..(i-1));
	end

	local pYuanPanel = winMgr:getWindow("quackowndialog/right/info1");
	pYuanPanel:subscribeEvent("MouseClick", MyXiake_xiake.HandleYuanClick, self);
	local pYuanPic = winMgr:getWindow("quackowndialog/right/info1/pic");
	pYuanPic:subscribeEvent("MouseClick", MyXiake_xiake.HandleYuanClick, self);
	for i = 1, 4 do
		self.m_vpSkillsXian[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("quackowndialog/right/info2/skill"..(i-1)));
		self.m_vpSkillsXian[i]:subscribeEvent("SKillBoxClick", MyXiake_xiake.HandleXianSkillClicked, self.m_vpSkillsXian[i]);
	end

	self.m_vpSkillLevels = {};
	for i = 1, 4 do
		self.m_vpSkillsHou[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("quackowndialog/right/info2/nskill"..(i-1)));
--		Move to RefreshCurrentXiake()
--		self.m_vpSkillsHou[i]:subscribeEvent("SKillBoxClick", MyXiake_xiake.HandleHouSkillClicked, self.m_vpSkillsHou[i]);
		self.m_vpSkillLevels[i] = winMgr:getWindow("quackowndialog/right/info2/nskillnum"..(i-1));
		self.m_vpSkillLevels[i]:getParent():setVisible(false);
	end

	self.m_iSelectedXiakeKey = 0;

--	self:RefreshMyXiakes();
    
    self.m_btnSelfChuanGong = CEGUI.Window.toPushButton(winMgr:getWindow("quackowndialog/right/benzunchuangong0"))
    self.m_btnSelfChuanGong:subscribeEvent("Clicked", MyXiake_xiake.HandleClickSelfChuanGongBtn, self)
    self.m_btnXiakeChuanGong = CEGUI.Window.toPushButton(winMgr:getWindow("quackowndialog/right/benzunchuangong01"))
    self.m_btnXiakeChuanGong:subscribeEvent("Clicked", MyXiake_xiake.HandleClickXiakeChuanGongBtn, self)

	self.m_pWeiboShareBtn = CEGUI.Window.toPushButton(winMgr:getWindow("quackowndialog/right/share"))
	self.m_pWeiboShareBtn:setVisible(false)
	if Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "tiger" then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", MyXiake_xiake.HandleWeiboShareBtnClicked, self)
	elseif ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", MyXiake_xiake.HandleFacebookShareBtnClicked, self)
	end

	self.m_ViewMode = 0
--	local child = CreateListItem();
--	self.m_pXiakeList:addChildWindow(child:GetWnd());

	self.xiuxing = winMgr:getWindow("quackowndialog/right/info3/back/img")
	self.xiuxing:subscribeEvent("MouseButtonUp", MyXiake_xiake.XiuXingClicked, self)
end

function MyXiake_xiake:OnClose()
	if self.m_ViewMode and  self.m_ViewMode == 1 then
		local lable = XiakeMainFrame.peekInstance()
		if lable then
			lable.m_pButton1:setVisible(true)
			lable.m_pButton2:setVisible(true)
			lable.m_pButton3:setVisible(true)
			lable.m_pButton4:setVisible(true)
			lable.m_pButton5:setVisible(true)
		end
	end
	Dialog.OnClose(self)
end

function MyXiake_xiake:XiuXingClicked(args)
	if not  XiakeMng.practiseLevel[self.m_iSelectedXiakeKey]  then return end 

--[[
	if XiakeMng.practiseLevel[self.m_iSelectedXiakeKey]  <= 0 then
		local xkinfo = XiakeMng.m_vXiakes[self.m_iSelectedXiakeKey]
		local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticeexpconfig"):getRecorder(xkinfo["xiakeid"])
	 	local strBuilder = StringBuilder:new()
 
		strBuilder:Set("parameter1", cfg.touru)	
	 	if not cfg or not xkinfo then return end

		if cfg.originColor < 3 then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146440).msg)
		elseif 
		end

		
		strBuilder:delete()
		return
	end
]]
	local p = require("protocoldef.knight.gsp.xiake.practice.copenxiakepractice"):new()
	p.xiakekey = self.m_iSelectedXiakeKey
	require("manager.luaprotocolmanager"):send(p)
end

function MyXiake_xiake:XiuXingSetImage()
	if not XiakeMng.practiseLevel[self.m_iSelectedXiakeKey]  then return end 
	 self.xiuxing:setProperty("Image", "set:MainControl43 image:xiakexiuxing" .. XiakeMng.practiseLevel[self.m_iSelectedXiakeKey])
end

-- 0 普通
-- 1 侠客远征
function MyXiake_xiake:SetViewMode(mode)
	self.m_ViewMode = mode
	if self.m_ViewMode == 1 then
		local lable = XiakeMainFrame.peekInstance()
		if lable then
			lable.m_pButton1:setVisible(false)
			lable.m_pButton2:setVisible(false)
			lable.m_pButton3:setVisible(false)
			lable.m_pButton4:setVisible(false)
			lable.m_pButton5:setVisible(false)
		end
	end
end

function MyXiake_xiake:RefreshMyXiakes()
	if self.m_ViewMode == 1 then
		self:RefreshMyXiakes_yuanzheng()
		return
	end
	if XiakeMng == nil then
		print("xiake mng is not inited");
		return;
	end
	local vXiakes = XiakeMng.GetXiakesOrderByScore();
	local vCounters = {};
	local iXiakeCount = 0;
	for k, v in pairs(XiakeMng.m_vXiakes) do
		if vCounters[v.xiakeid] == nil then
			vCounters[v.xiakeid] = 1;
		else
			vCounters[v.xiakeid] = vCounters[v.xiakeid] + 1;
		end
		iXiakeCount = iXiakeCount + 1;
	end

	if vXiakes == nil then print("my xiake data not init");return;end
	local bRefreshFirst = false;
	if self.m_iSelectedXiakeKey ~= 0 then
		bRefreshFirst = true;
	end
	local iIndex = 1;
	local vb = XiakeMng.m_vBattleOrder
	for i = 1, 4 do
		if vb[i] ~= nil and vb[i] ~= 0 and XiakeMng.m_vXiakes[vb[i]] == nil then
			print("battle order not exist");	
		elseif vb[i] ~= nil and vb[i] ~= 0 then
			if iIndex > #self.m_vXiakeItems then
				local child = CreateListItem(tostring(iIndex));
				child:SetXiakeInfo(XiakeMng.m_vXiakes[vb[i]]);
				self.m_pXiakeList:addChildWindow(child:GetWnd());
				local cnt = #self.m_vXiakeItems;
				XiakeMng.SetWndPos(child:GetWnd(), 0, cnt*180 + 1);
				self.m_vXiakeItems[#self.m_vXiakeItems + 1] = child;
			else
				self.m_vXiakeItems[iIndex]:SetXiakeInfo(XiakeMng.m_vXiakes[vb[i]]);
			end
			if bRefreshFirst == false then
				bRefreshFirst = true;
				self.m_iSelectedXiakeKey = XiakeMng.m_vXiakes[vb[i]].xiakekey;
				self:RefreshCurrentXiake(XiakeMng.m_vXiakes[vb[i]]);
			end
			if vCounters[XiakeMng.m_vXiakes[vb[i]].xiakeid] < 2 then
				self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(false);
			else
				self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(true);
			end
			self.m_vXiakeItems[iIndex].m_pMarkInBattle:setVisible(true);
			self.m_vXiakeItems[iIndex].m_pBtnEnterBattle:setText(MHSD_UTILS.get_resstring(2767));
			self.m_vXiakeItems[iIndex].m_bInBattle = true;
			iIndex = iIndex + 1;
		elseif self.m_vXiakeItems[i] ~= nil then
			self.m_vXiakeItems[i].m_pMarkInBattle:setVisible(false);
		end
	end

	for k,v in pairs(vXiakes) do
		if self.m_iPageCount * XiakeListItemMore.ePageSize <= iIndex then
			break;
		end

		if iIndex > #self.m_vXiakeItems then
			local child = CreateListItem(tostring(iIndex));
			child:SetXiakeInfo(v);
			self.m_pXiakeList:addChildWindow(child:GetWnd());
			local cnt = #self.m_vXiakeItems;
			child:GetWnd():setPosition(
				CEGUI.UVector2(
					CEGUI.UDim(0, 0),  
					CEGUI.UDim(0, cnt*180+1)
					)
				);
			self.m_vXiakeItems[#self.m_vXiakeItems + 1] = child;
		else
			self.m_vXiakeItems[iIndex].m_pMainFrame:setVisible(true);
			self.m_vXiakeItems[iIndex]:SetXiakeInfo(v);
		end
		if bRefreshFirst == false and vb[i] ~= 0 and XiakeMng.m_vXiakes[vb[i]] ~= nil then
			bRefreshFirst = true;
			self.m_iSelectedXiakeKey = XiakeMng.m_vXiakes[vb[i]].xiakekey;
			self:RefreshCurrentXiake(XiakeMng.m_vXiakes[vb[i]]);
		end
		if vCounters[v.xiakeid] < 2 then
			self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(false);
		else
			self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(true);
		end
		self.m_vXiakeItems[iIndex].m_pBtnEnterBattle:setText(MHSD_UTILS.get_resstring(2766));
		self.m_vXiakeItems[iIndex].m_bInBattle = false;
		iIndex = iIndex + 1;
	end

	for i = iIndex, #self.m_vXiakeItems do
		self.m_vXiakeItems[i].m_pMainFrame:setVisible(false);
	end

--	if iIndex < iXiakeCount then
--		if self.m_pNextPageBtn == nil then
--			self.m_pNextPageBtn = CreateListItemMore();
--		end
--		self.m_pNextPageBtn.m_pMainFrame:setVisible(true);
--		self.m_pXiakeList:addChildWindow(self.m_pNextPageBtn.m_pMainFrame);
--		XiakeMng.SetWndPos(self.m_pNextPageBtn.m_pMainFrame, 0, (iIndex-1)*180);
--	else
--		if self.m_pNextPageBtn ~= nil then
--			self.m_pNextPageBtn.m_pMainFrame:setVisible(false);
--		end
--	end
end

function MyXiake_xiake:RefreshMyXiakes_yuanzheng()
	if XiakeMng == nil then
		print("xiake mng is not inited");
		return;
	end
	local vXiakes = XiakeMng.GetXiakesOrderByScore_yuanzheng()
	local vCounters = {};
	local iXiakeCount = 0;
	for k, v in pairs(XiakeMng.m_vXiakes) do
		if vCounters[v.xiakeid] == nil then
			vCounters[v.xiakeid] = 1;
		else
			vCounters[v.xiakeid] = vCounters[v.xiakeid] + 1;
		end
		iXiakeCount = iXiakeCount + 1;
	end

	if vXiakes == nil then print("my xiake data not init");return;end
	local bRefreshFirst = false;
	if self.m_iSelectedXiakeKey ~= 0 then
		bRefreshFirst = true;
	end
	local iIndex = 1;
	local vb = XiakeMng.m_vBattleOrder_yuanzheng
	for i = 1, 4 do
		if vb[i] ~= nil and vb[i] ~= 0 and XiakeMng.m_vXiakes[vb[i]] == nil then
			print("battle order not exist");	
		elseif vb[i] ~= nil and vb[i] ~= 0 then
			if iIndex > #self.m_vXiakeItems then
				local child = CreateListItem(tostring(iIndex));
				child:SetXiakeInfo(XiakeMng.m_vXiakes[vb[i]]);
				self.m_pXiakeList:addChildWindow(child:GetWnd());
				local cnt = #self.m_vXiakeItems;
				XiakeMng.SetWndPos(child:GetWnd(), 0, cnt*180 + 1);
				self.m_vXiakeItems[#self.m_vXiakeItems + 1] = child;
			else
				self.m_vXiakeItems[iIndex]:SetXiakeInfo(XiakeMng.m_vXiakes[vb[i]]);
			end
			if bRefreshFirst == false then
				bRefreshFirst = true;
				self.m_iSelectedXiakeKey = vb[i]
				self:RefreshCurrentXiake(XiakeMng.m_vXiakes[self.m_iSelectedXiakeKey]);
			end
			if vCounters[XiakeMng.m_vXiakes[vb[i]].xiakeid] < 2 then
				self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(false);
			else
				self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(true);
			end
			self.m_vXiakeItems[iIndex].m_pMarkInBattle:setVisible(true);
			self.m_vXiakeItems[iIndex].m_pBtnEnterBattle:setText(MHSD_UTILS.get_resstring(2767));
			self.m_vXiakeItems[iIndex].m_bInBattle = true;
			iIndex = iIndex + 1;
		elseif self.m_vXiakeItems[i] ~= nil then
			self.m_vXiakeItems[i].m_pMarkInBattle:setVisible(false);
		end
	end

	for k,v in pairs(vXiakes) do
		if self.m_iPageCount * XiakeListItemMore.ePageSize <= iIndex then
			break;
		end

		if iIndex > #self.m_vXiakeItems then
			local child = CreateListItem(tostring(iIndex));
			child:SetXiakeInfo(v);
			self.m_pXiakeList:addChildWindow(child:GetWnd());
			local cnt = #self.m_vXiakeItems;
			child:GetWnd():setPosition(
				CEGUI.UVector2(
					CEGUI.UDim(0, 0),  
					CEGUI.UDim(0, cnt*180+1)
					)
				);
			self.m_vXiakeItems[#self.m_vXiakeItems + 1] = child;
		else
			self.m_vXiakeItems[iIndex].m_pMainFrame:setVisible(true);
			self.m_vXiakeItems[iIndex]:SetXiakeInfo(v);
		end
		if bRefreshFirst == false and vb[i] ~= 0 and XiakeMng.m_vXiakes[vb[i]] ~= nil then
			bRefreshFirst = true;
			self.m_iSelectedXiakeKey = XiakeMng.m_vXiakes[vb[i]].xiakekey;
			self:RefreshCurrentXiake(XiakeMng.m_vXiakes[vb[i]]);
		end
		if vCounters[v.xiakeid] < 2 then
			self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(false);
		else
			self.m_vXiakeItems[iIndex].m_pBtnJinhua:setEnabled(true);
		end
		self.m_vXiakeItems[iIndex].m_pBtnEnterBattle:setText(MHSD_UTILS.get_resstring(2766));
		self.m_vXiakeItems[iIndex].m_bInBattle = false;
		iIndex = iIndex + 1;
	end

	for i = iIndex, #self.m_vXiakeItems do
		self.m_vXiakeItems[i].m_pMainFrame:setVisible(false);
	end

--	if iIndex < iXiakeCount then
--		if self.m_pNextPageBtn == nil then
--			self.m_pNextPageBtn = CreateListItemMore();
--		end
--		self.m_pNextPageBtn.m_pMainFrame:setVisible(true);
--		self.m_pXiakeList:addChildWindow(self.m_pNextPageBtn.m_pMainFrame);
--		XiakeMng.SetWndPos(self.m_pNextPageBtn.m_pMainFrame, 0, (iIndex-1)*180);
--	else
--		if self.m_pNextPageBtn ~= nil then
--			self.m_pNextPageBtn.m_pMainFrame:setVisible(false);
--		end
--	end
end

function MyXiake_xiake:HandleFacebookShareBtnClicked(args)
	LogInfo("PKDialog HandleWeiboShareBtnClicked")
	-- local strbuilder = StringBuilder:new()	
	-- strbuilder:SetNum("parameter1", GetPKManager():getRank())
	--strbuilder:GetString(msg)
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cfacebook", 1)
	local shareinfo = {}
	shareinfo[1] = record.Comment
	shareinfo[2] = record.Link
	shareinfo[3] = record.LinkPicture
	shareinfo[4] = record.LinkName
	shareinfo[5] = record.LinkCaption
	shareinfo[6] = record.LinkDescription


	if Config.isKoreanAndroid() then
		local luaj = require "luaj"
		luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "ShareFacebook", luaj.checkArguments(shareinfo))
	elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" then
         SDXL.ChannelManager:CommonShare(record.Comment,record.Link, record.LinkPicture, record.LinkName,record.LinkCaption,record.LinkDescription)
	end

	-- strbuilder:delete()
end


function MyXiake_xiake:HandleClickSelfChuanGongBtn(args)
    LogInfo("____MyXiake_xiake:HandleClickSelfChuanGongBtn")
    
    if self.m_iSelectedXiakeKey > 0 then
        local openCGAction = COpenChuangong.Create()
        openCGAction.cgtype = 1
        openCGAction.xiakekey = self.m_iSelectedXiakeKey
        LuaProtocolManager.getInstance():send(openCGAction)
    end
end

function MyXiake_xiake:HandleClickXiakeChuanGongBtn(args)
    LogInfo("____MyXiake_xiake:HandleClickXiakeChuanGongBtn")
    
    if self.m_iSelectedXiakeKey > 0 then
        local openCGAction = COpenChuangong.Create()
        openCGAction.cgtype = 2
        openCGAction.xiakekey = self.m_iSelectedXiakeKey
        LuaProtocolManager.getInstance():send(openCGAction)
    end
end

function MyXiake_xiake:HandleYuanClick(arg)
	if self.m_iSelectedXiakeKey ~= 0 and XiakeMng.m_vXiakes[self.m_iSelectedXiakeKey] ~= nil then
		YuanXiake.getInstance().SetAndShow(XiakeMng.m_vXiakes[self.m_iSelectedXiakeKey]);
	end
end

function MyXiake_xiake:HandleXianSkillClicked(arg)
	if MyXiake_xiake.getInstance().m_iSelectedXiakeKey == 0 then return; end
	local iSkillID = self:GetSkillID();
	if iSkillID ~= 0 then
		local tip = SkillXkTip.getInstance();
		tip.m_pMainFrame:setVisible(true);
		tip.m_pMainFrame:moveToFront();
		XiakeMng.SetWndPos(tip.m_pMainFrame, 180, 130);
		local info = {};
		info.mK = iSkillID;
		info.mV = 0;
		tip:SetSkillInfo(info, true);
	end
end

function MyXiake_xiake:HandleHouSkillClicked(arg)
	print("skill clicked");
--	local book = SkillBookXq.getInstance();
--	book.m_pMainFrame:setVisible(true);
--	book.m_pMainFrame:moveToFront();
	if MyXiake_xiake.getInstance().m_iSelectedXiakeKey == 0 then return; end
	xiakeData = XiakeMng.m_vXiakes[MyXiake_xiake.getInstance().m_iSelectedXiakeKey]
	if xiakeData.bIsDetail == nil then
		XiakeMng.RequestXiakeDetail(xiakeData.xiakekey);
	end
	print(MyXiake_xiake.getInstance().m_iSelectedXiakeKey);
	local iSkillID = self:GetSkillID();
	print(iSkillID);
	if iSkillID == 0 then -- will add
		local books = SkillBookXq.getInstance();
		books.m_pMainFrame:setVisible(true);
		books.m_pMainFrame:moveToFront();
		XiakeMng.SetWndPos(books.m_pMainFrame, 230, 100);	
		books:ModeAdd();
	else -- will view skill
		local qianghua = SkillXkTip.getInstance();
		qianghua.m_pMainFrame:setVisible(true);
		qianghua.m_pMainFrame:moveToFront();
		XiakeMng.SetWndPos(qianghua.m_pMainFrame, 180, 100);
		local xkUI = MyXiake_xiake.getInstance();
		if xkUI.m_mapSkill ~= nil and xkUI.m_mapSkill[self] ~= nil then
			qianghua:SetSkillInfo(xkUI.m_mapSkill[self]);
			print("handle skill");
		end
	end
end

function MyXiake_xiake:HandleLockedSkillClicked(args)
	if MyXiake_xiake.getInstance().m_iSelectedXiakeKey == 0 then return; end
	xiakeData = XiakeMng.m_vXiakes[MyXiake_xiake.getInstance().m_iSelectedXiakeKey]
	if xiakeData.bIsDetail == nil then
		XiakeMng.RequestXiakeDetail(xiakeData.xiakekey);
	end
	GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145427),MyXiake_xiake.HandleExtXiakeSkillConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

function MyXiake_xiake.HandleExtXiakeSkillConfirmClicked(args)
	xiakeData = XiakeMng.m_vXiakes[MyXiake_xiake.getInstance().m_iSelectedXiakeKey];
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false);
	XiakeMng.RequestExtSkill(xiakeData.xiakekey);
end

function MyXiake_xiake:RefreshXiakeDetail(xiakeData)
	self:RefreshCurrentXiake(xiakeData);
	self:RefreshMyXiakes();
end

function MyXiake_xiake:RefreshCurrentXiake(xiakeData)
	if xiakeData == nil then return; end
	if xiakeData.xiakekey ~= self.m_iSelectedXiakeKey and
		self.m_iSelectedXiakeKey == 0 then
		return;
	end
    
    print("____xiakeData.xiakekey: " .. xiakeData.xiakekey)

	local aXiakeID = xiakeData.xiakeid;
	local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
	local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
	local path = GetIconManager():GetImagePathByID(shape.headID):c_str();
	self.m_pXiakeIcon:setProperty("Image", path);
	
    --xiaolong added for elite
    if self.m_pElite then
        self.m_pElite:setVisible(XiakeMng.IsElite(xiakeData.xiakekey))
    end

	--for skill 4 add by wuyao
    local xkxxs4 = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakexin"):getRecorder(aXiakeID)
    local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
	self.m_pXiakeName:setText(scene_util.GetPetNameColor(xiakeData.color)..xkxx.name);
	self.m_pXiakeFrame:setProperty("Image", XiakeMng.eXiakeFrames[xiakeData.color]);
	self.m_pTextLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
	self.m_pMark:setProperty("Image", XiakeMng.eLvImages[xiakeData.starlv]);
	for i = 1, 6 do
		self.m_vpTextYuans[i]:setText("");
	end

	for i = 1, xkxx.yuan:size() do
		if xkxx.yuan[i - 1] ~= 0 then
			local y = knight.gsp.npc.GetCXiakeyuanTableInstance():getRecorder(xkxx.yuan[i - 1]);
			self.m_vpTextYuans[i]:setText(y.name);
			self.m_vpYuanBacks[i]:setProperty("Image", "set:MainControl7 image:quackyuannormal");

			if xiakeData.yuanids ~= nil then
				for k,v in pairs(xiakeData.yuanids) do
					if v == xkxx.yuan[i - 1] then
						self.m_vpYuanBacks[i]:setProperty("Image", "set:MainControl7 image:quackyuanlight");
					end
				end
			end
		end
	end

	for i = xkxx.yuan:size() + 1, 6 do
		self.m_vpYuanBacks[i]:setProperty("Image", "set:MainControl7 image:quackyuannormal");
	end

	for i = 1, 4 do 
		if xkxxs4["skill"..tostring(i)] ~= nil and xkxxs4["skill"..tostring(i)] ~= 0 then
			--self.m_vpSkillsXian[i]:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell3"));
			CSkillBoxControl:GetInstance():SetSkillInfo(self.m_vpSkillsXian[i], xkxxs4["skill"..tostring(i)]);
			self.m_vpSkillsXian[i]:SetBackgroundDynamic(true);
			local sk = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(xkxxs4["skill"..tostring(i)]);
			self.m_vpSkillsXian[i]:SetBackGroundImage(CEGUI.String(XiakeMng.eSkillFrames[sk.color].imageset), CEGUI.String(XiakeMng.eSkillFrames[sk.color].image));
			self.m_vpSkillsXian[i]:setVisible(true);
		elseif xkxxs4["skill"..tostring(i)] == nil then
			CSkillBoxControl:GetInstance():SetSkillInfo(self.m_vpSkillsXian[i], 0);
			self.m_vpSkillsXian[i]:SetBackgroundDynamic(false);
			self.m_vpSkillsXian[i]:setVisible(true);
		else
			self.m_vpSkillsXian[i]:setVisible(false);
		end
	end

	local imgs = XiakeMng.eSkillFrames;
    self.m_mapSkill = {};
    
    self.m_groupREdBoxStar:setVisible(false)
	if xiakeData.bIsDetail then
        print("____is DetailInfo")
        
		self.m_pTextLife:setText(string.format("%d", xiakeData.datas[140]));
		self.m_pTextWaiFang:setText(string.format("%d", xiakeData.datas[100]));
		if xkxx.waigong == 1 then
			self.m_pTextWaiShang:setText(string.format("%d", xiakeData.datas[80]));
			self.m_pLblShanghaiLeixing:setText(MHSD_UTILS.get_resstring(2751)..":");
		else
			self.m_pTextWaiShang:setText(string.format("%d", xiakeData.datas[810]));
			self.m_pLblShanghaiLeixing:setText(MHSD_UTILS.get_resstring(2750)..":");
		end
		self.m_pTextNeiFang:setText(string.format("%d", xiakeData.datas[820]));
		self.m_pTextSpeed:setText(string.format("%d", xiakeData.datas[130]));
--	for k,v in pairs(xiakeData.datas) do
--		print(tostring(k).."::::"..tostring(v));
--	end
		local cnt = 1;
		local maxskillnum = xiakeData.extskillnum + 3;
		--Skill had learen
		for k,v in pairs(xiakeData.skills) do
			self.m_vpSkillsHou[cnt]:Clear();
			self.m_vpSkillsHou[cnt]:SetBackgroundDynamic(true);
			GetGameUIManager():RemoveUIEffect(self.m_vpSkillsHou[cnt]);
			local sk = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(k);
			self.m_vpSkillsHou[cnt]:SetBackGroundImage(CEGUI.String(imgs[sk.color].imageset), CEGUI.String(imgs[sk.color].image));
			CSkillBoxControl:GetInstance():SetSkillInfo(self.m_vpSkillsHou[cnt], k);

			self.m_vpSkillLevels[cnt]:getParent():setVisible(true);
			self.m_vpSkillLevels[cnt]:setText(tostring(sk.skilllevel));
			print("########skill", k, v, "skill########");
		
			local skillItem = {};
			skillItem.mK = k;
			skillItem.mV = v;
			self.m_mapSkill[self.m_vpSkillsHou[cnt]] = skillItem;

			if self.m_vpSkillsHou[cnt]:isEventPresent("SKillBoxClick") then
				self.m_vpSkillsHou[cnt]:removeEvent("SKillBoxClick");
			end
			self.m_vpSkillsHou[cnt]:subscribeEvent("SKillBoxClick", MyXiake_xiake.HandleHouSkillClicked, self.m_vpSkillsHou[cnt]);
			cnt = cnt+1;
		end
		

		--empty skill
		if cnt <= maxskillnum then
			for i = cnt, maxskillnum do
				self.m_vpSkillsHou[i]:Clear();
				self.m_vpSkillsHou[i]:SetBackGroundImage(nil);
				self.m_vpSkillsHou[i]:SetBackgroundDynamic(false);
				GetGameUIManager():RemoveUIEffect(self.m_vpSkillsHou[i]);
				GetGameUIManager():AddUIEffect(self.m_vpSkillsHou[i], MHSD_UTILS.get_effectpath(10374), true);
				self.m_vpSkillLevels[i]:getParent():setVisible(false);
				if self.m_vpSkillsHou[cnt]:isEventPresent("SKillBoxClick") then
					self.m_vpSkillsHou[cnt]:removeEvent("SKillBoxClick");
				end
				self.m_vpSkillsHou[cnt]:subscribeEvent("SKillBoxClick", MyXiake_xiake.HandleHouSkillClicked, self.m_vpSkillsHou[cnt]);
				cnt = cnt + 1;			
			end
		end
		
		--locked skill
		if cnt <= 4 then
			for i = cnt, 4 do
				self.m_vpSkillsHou[i]:Clear();
				self.m_vpSkillsHou[i]:SetBackgroundDynamic(true);
				GetGameUIManager():RemoveUIEffect(self.m_vpSkillsHou[cnt]);
				self.m_vpSkillLevels[i]:getParent():setVisible(false);
				self.m_vpSkillsHou[cnt]:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell1"))
				self.m_vpSkillsHou[cnt]:SetImage(CEGUI.String("BaseControl"), CEGUI.String("PetSkillLock"))
				if self.m_vpSkillsHou[cnt]:isEventPresent("SKillBoxClick") then
					self.m_vpSkillsHou[cnt]:removeEvent("SKillBoxClick");
				end
				self.m_vpSkillsHou[cnt]:subscribeEvent("SKillBoxClick", MyXiake_xiake.HandleLockedSkillClicked, self.m_vpSkillsHou[cnt]);
				cnt = cnt + 1;	
			end
		end
		
        if XiakeMng.IsElite(xiakeData.xiakekey) then
            print("____iselite xiakekey: " .. xiakeData.xiakekey)
            self.m_groupREdBoxStar:setVisible(true)
            for i = 1, 5, 1 do
                self.m_arrREdBoxStar[i]:Clear()
                self.m_arrREdBoxStar[i]:SetEmotionScale(CEGUI.Vector2(0.4, 0.4))
                local curProp = XiakeMng.GetCGPropFromXKKeyAndPropIndex(xiakeData.xiakekey, i)
                if curProp and curProp.color and curProp.star then
                    print("____index: " .. i)
                    print("____color: " .. curProp.color .. " star: " .. curProp.star)
                end
                if curProp and curProp.star and curProp.color >= 1 and curProp.color <= 7 then
                    for j = 1, curProp.star, 1 do
                        self.m_arrREdBoxStar[i]:AppendEmotion(150+curProp.color)
                    end
                end
                self.m_arrREdBoxStar[i]:Refresh()
            end
        end
        self:XiuXingSetImage()
	else
        print("____is not DetailInfo")
		XiakeMng.RequestXiakeDetail(xiakeData.xiakekey);
	end
end

function MyXiake_xiake:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, MyXiake_xiake);

	return self;
end

function MyXiake_xiake.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end

	if XiakeMainFrame.peekInstance() then
		XiakeMainFrame.DestroyDialog();
	end
    
    SelfChuanGong.DestroyDialog()
    XiakeChuanGong.DestroyDialog()
end

function MyXiake_xiake:HandleWeiboShareBtnClicked(args)
	LogInfo("MyXiake_xiake HandleWeiboShareBtnClicked")
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cweiboshow", 401)
	local title = record.title
	if record.title == "0" then
		title = ""
	end
	local msg = record.msg
	if record.msg == "0" then
		msg = ""
	end
	local link = record.link
	if record.link == "0" then
		link = ""
	end
    local link1 = record.link1
	if record.link1 == "0" then
		link1 = ""
	end
	local strbuilder = StringBuilder:new()	
	local xiakeinfo = XiakeMng.m_vXiakes[self.m_iSelectedXiakeKey]
	if xiakeinfo then
		strbuilder:Set("parameter1", MHSD_UTILS.get_resstring(xiakeinfo.color + 3016))
		local xiakeid = xiakeinfo.xiakeid
		local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(xiakeid)
		if xkxx.id ~= -1 then
			strbuilder:Set("parameter2", xkxx.name)	
		end
		SDXL.ChannelManager:CommonShare(title, strbuilder:GetString(msg), link, link1)		
	end
	
	strbuilder:delete()
end
return MyXiake_xiake;
