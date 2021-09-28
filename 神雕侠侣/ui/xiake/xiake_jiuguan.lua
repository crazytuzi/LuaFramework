require "ui.dialog"
require "ui.xiake.mainframe"
require "ui.xiake.yuan"
require "protocoldef.knight.gsp.xiake.cclickxiake10times"
require "ui.xiake.xiake_manager"
require "utils.scene_common"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.xiake.creqwmxiake"

XiakeJiuguan = {
m_eMode, 		--begin,end
m_pFindWnd, 	--wnd1
m_pResultWnd,   --wnd2
eLastFindNone = 0, eLastFind10 = 1, eLastFind100 = 2, eLastFind1000 = 3,
m_eLastFind,
m_iLastXiakeKey = 0,

m_pEffectWnd,

--m_i10Left = 0;
--m_i10Time = -1,
--m_i100Time = -1,
--m_i1000Time = -1,

--wnd result childs
m_pXiakeFrame,
m_pHeadIcon,
m_pName,
m_plevel,
m_pJie,

m_pType,
m_pLife,
m_pWaiGongShanghai,
m_pWaiGongFangyu,
m_pNeiGongFangyu,
m_pSpeed,

m_vYuans,
m_vBornSkills,
m_vBornSkillNames,

m_pBtnMyXiake,
m_pBtnContinueFind,
m_pBtnBack,

--wnd find childs
m_pLblTime10,
m_pLblTime100,
m_pLblTime1000,

m_pLblMoney10,
m_pLblMoney100,
m_pLblMoney1000,

m_pBtn10,
m_pBtn100,
m_pBtn1000,
m_pPaop10,
m_pPaop100,
m_pPaop1000,

m_vFoundStates10 	= {},
m_vFoundStates100 	= {},
m_vFoundStates1000 	= {},

m_pFoundLeftCount10,
m_pFoundLeftCount100,
m_pFoundLeftCount1000,

ModeFind = 1, ModeResult = 2
};
setmetatable(XiakeJiuguan, Dialog)
XiakeJiuguan.__index = XiakeJiuguan;


local _instance;
function XiakeJiuguan.getInstance()
	if not _instance then
		_instance = XiakeJiuguan:new()
		_instance:OnCreate()
	end

--	_instance.m_pMainFrame:setVisible(true);
--	_instance.m_pMainFrame:moveToFront();
--    local frame =	XiakeMainFrame:getInstance();
--	frame.m_pMainFrame:setVisible(true);
	return _instance;
end

function XiakeJiuguan.peekInstance()
	return _instance;
end

function XiakeJiuguan.getAndShow()
	XiakeJiuguan.getInstance():SetVisible(true);
	XiakeJiuguan.getInstance():GetWindow():setModalState(true)
end

function XiakeJiuguan:SetVisible(bV)
	if bV == self.m_pMainFrame:isVisible() then return; end
	self.m_pMainFrame:setVisible(bV);
	if bV then
		self:GetWindow():setModalState(bV)
	end
	if bV then
		XiakeMainFrame.getInstance().m_pMainFrame:setVisible(true);	
	else
	end
end

function XiakeJiuguan.GetLayoutFileName()
	return "quackfound.layout";
end

function XiakeJiuguan:OnCreate()
	Dialog.OnCreate(self);
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_eMode = ModeFind;
	self.m_pFindWnd = winMgr:getWindow("quackfound/found");
	self.m_pResultWnd = winMgr:getWindow("quackfound/end");

	self.m_pEffectWnd = winMgr:getWindow("quackfound/effect");
	self.m_pEffectWnd:setAlwaysOnTop(true);
	self.m_pHeadIcon = winMgr:getWindow("quackfound/end/icon");
	self.m_pName 	= winMgr:getWindow("quackfound/end/name");
	self.m_plevel 	= winMgr:getWindow("quackfound/end/level");
	self.m_pJie 		= winMgr:getWindow("quackfound/end/mark");
	self.m_pXiakeFrame = winMgr:getWindow("quackfound/end/back");
	self.m_pBigColor 	= winMgr:getWindow("quackfound/end/color");

	self.m_pType 	= winMgr:getWindow("quackfound/end/info/num0");
	self.m_pLife 	= winMgr:getWindow("quackfound/end/info/num1");
	self.m_pWaiGongShanghai 	= winMgr:getWindow("quackfound/end/info/num2");
	self.m_pWaiGongFangyu 	= winMgr:getWindow("quackfound/end/info/num3");
	self.m_pNeiGongFangyu 	= winMgr:getWindow("quackfound/end/info/num4");
	self.m_pSpeed 			= winMgr:getWindow("quackfound/end/info/num5");
	
	-- 侠客清单
	for i = 1, 3 do
		local XiakePreview = winMgr:getWindow("quackfound/cell"..tostring(i-1))
		if XiakePreview then
			XiakePreview:setID(i)
			XiakePreview:subscribeEvent("MouseClick", XiakeJiuguan.HandleXiakeListClicked, self)
		end
	end

	self.m_pLblTime10 	= winMgr:getWindow("quackfound/cell/time0");
	self.m_pLblTime100  = winMgr:getWindow("quackfound/cell/time1");
	self.m_pLblTime1000 = winMgr:getWindow("quackfound/cell/time2");

	self.m_pLblMoney10  = winMgr:getWindow("quackfound/cell/money0");
	self.m_pLblMoney100 = winMgr:getWindow("quackfound/cell/money1");
	self.m_pLblMoney1000= winMgr:getWindow("quackfound/cell/money2");

	self.m_pBtn10 		= winMgr:getWindow("quackfound/cell/ok0");
	self.m_pBtn100 		= winMgr:getWindow("quackfound/cell/ok1");
	self.m_pBtn1000 	= winMgr:getWindow("quackfound/cell/ok2");
	self.m_pPaop10      = winMgr:getWindow("quackfound/cell/mark");
	self.m_pPaop100 	= winMgr:getWindow("quackfound/cell/mark1");
	self.m_pPaop1000 	= winMgr:getWindow("quackfound/cell/mark2");
	self.m_pPaop1000:setVisible(false);
	self.m_pPaop100:setVisible(false);
	self.m_pPaop10:setVisible(false);

	self.m_p10TimeMoney = winMgr:getWindow("quackfound/found/ditu/money01")
	self.m_p10TimeBtn = CEGUI.toPushButton(winMgr:getWindow("quackfound/found/ditu/ok"))
	self.m_pXiakePic = {}
	self.m_pXiakeLevel = {}
	self.m_pXiakeName = {}
	self.m_pXiakeMark = {}
	for i = 0, 4 do
		self.m_pXiakePic[i] = winMgr:getWindow("quackfound/found/ditu/back0" .. tostring(i))
		self.m_pXiakeLevel[i] = winMgr:getWindow("quackfound/found/ditu/level0" .. tostring(i))
		self.m_pXiakeLevel[i]:setText(tostring(GetDataManager():GetMainCharacterLevel()))
		self.m_pXiakeName[i] = winMgr:getWindow("quackfound/found/ditu/name0" .. tostring(i))
		self.m_pXiakeMark[i] = winMgr:getWindow("quackfound/found/ditu/mark0" .. tostring(i))
		self.m_pXiakeMark[i]:setProperty("Image", XiakeMng.eLvImages[1])
	end

	self.m_pName:setText("");
	self.m_pType:setText("");
	self.m_pLife:setText("");
	self.m_pWaiGongShanghai:setText("");
	self.m_pWaiGongFangyu:setText("");
	self.m_pNeiGongFangyu:setText("");
	self.m_pSpeed:setText("");
	self.m_plevel:setText("");

	self.m_pFoundLeftCount10 = winMgr:getWindow("quackfound/cell0/info3/num");
--	self.m_pFoundLeftCount100= winMgr:getWindow("quackfound/cell1/info3/num");
--	self.m_pFoundLeftCount1000=winMgr:getWindow("quackfound/cell2/info3/num");

	self.m_pBtn10:subscribeEvent("Clicked", XiakeJiuguan.Handle10Clicked, self);
	self.m_pBtn100:subscribeEvent("Clicked", XiakeJiuguan.Handle100Clicked, self);
	self.m_pBtn1000:subscribeEvent("Clicked", XiakeJiuguan.Handle1000Clicked, self);
	self.m_p10TimeBtn:subscribeEvent("Clicked", XiakeJiuguan.Handle10TimeClicked, self)

	for i = 1, 3 do
		self.m_vFoundStates10[i] = winMgr:getWindow("quackfound/cell0/info"..(i));
	end

	self.m_pFound10PricePan = winMgr:getWindow("quackfound/cell0/info4");
	
	self.m_vFoundStates10[2]:setVisible(false);
	for i = 1, 3 do
	    self.m_vFoundStates100[i] = winMgr:getWindow("quackfound/cell1/info"..(i));
	end 
	self.m_vFoundStates100[3]:setVisible(false);
	for i = 1, 3 do
     	self.m_vFoundStates1000[i] = winMgr:getWindow("quackfound/cell2/info"..(i));
	end
	self.m_vFoundStates1000[3]:setVisible(false);

	--self.m_vYuans[1] = winMgr:getWindow("quackfound/end/info1/name");
	self.m_vYuans = {};
	for i = 1, 6 do
		self.m_vYuans[i] = winMgr:getWindow("quackfound/end/info1/name"..(i-1));
		self.m_vYuans[i]:setText("");
		self.m_vYuans[i]:setMousePassThroughEnabled(true);
	end
	local yuanPan = winMgr:getWindow("quackfound/end/info1");
	yuanPan:subscribeEvent("MouseButtonDown", XiakeJiuguan.HandleYuanClicked, self);
	yuanPan:setMousePassThroughEnabled(false);
	local yuanIcon = winMgr:getWindow("quackfound/end/info1/pic");
	yuanIcon:setMousePassThroughEnabled(true);

	self.m_pBtnMyXiake 		= winMgr:getWindow("quackfound/end/my");
	self.m_pBtnContinueFind = winMgr:getWindow("quackfound/end/again");
	self.m_pBtnBack 		= winMgr:getWindow("quackfound/end/return");

	self.m_pBtnMyXiake:subscribeEvent("Clicked", XiakeJiuguan.HandleMyXiakeClicked, self);
	self.m_pBtnContinueFind:subscribeEvent("Clicked", XiakeJiuguan.HandleContinueClicked, self);
	self.m_pBtnBack:subscribeEvent("Clicked", XiakeJiuguan.HandleBackClicked, self);

	self.m_vBornSkills = {};
	self.m_vBornSkillNames = {};
	for i = 1, 4 do
		self.m_vBornSkills[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("quackfound/end/info3/skill"..(i-1)));
		self.m_vBornSkillNames[i] = winMgr:getWindow("quackfound/end/info3/name"..(i-1));
		self.m_vBornSkillNames[i]:setText("");
		self.m_vBornSkills[i]:subscribeEvent("SKillBoxClick", XiakeJiuguan.HandleXianClicked, i);
	end

	self.m_eMode = XiakeJiuguan.ModeResult;
	self:SetMode(XiakeJiuguan.ModeFind);

	self.m_pMainFrame:setVisible(false);

	local req = CReqwmxiake.Create()
	LuaProtocolManager.getInstance():send(req)

end

function XiakeJiuguan:HandleXianClicked(arg)
	if self >= 1 and self <= 4 then
		local xk = XiakeMng.m_vXiakes[XiakeJiuguan.getInstance().m_iLastXiakeKey];
		if xk ~= nil then
			local xkxx = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakexin"):getRecorder(xk.xiakeid)
			if xkxx ~= nil and xkxx.id ~= -1 then
				local skill = xkxx["skill"..tostring(self)];
				local skillinfo = {};
				skillinfo.mK = skill;
				skillinfo.mV = 0;
				SkillXkTip.getInstance():SetSkillInfo(skillinfo, true);
			end
		end
	end
end

function XiakeJiuguan:SetMode(mode)
	if mode == self.m_eMode then return; end
	self.m_eMode = mode;
	if mode == XiakeJiuguan.ModeFind then
		self.m_pFindWnd:setVisible(true);
		self.m_pResultWnd:setVisible(false);
--		self.m_pFindWnd:moveToFront();
	local req = knight.gsp.xiake.COpenXiakeJiuguan();
	if req == nil then print("copenxiakejiuguan is nil"); end
	GetNetConnection():send(req);

	elseif mode == XiakeJiuguan.ModeResult then
		self.m_pFindWnd:setVisible(false);
		self.m_pResultWnd:setVisible(true);
		if self.m_eLastFind == XiakeJiuguan.eLastFind10 then
			self.m_pBtnContinueFind:setText(MHSD_UTILS.get_resstring(2755));	
		elseif self.m_eLastFind == XiakeJiuguan.eLastFind100 then
			self.m_pBtnContinueFind:setText(MHSD_UTILS.get_resstring(2756));
		elseif self.m_eLastFind == XiakeJiuguan.eLastFind1000 then
			self.m_pBtnContinueFind:setText(MHSD_UTILS.get_resstring(2757));
		end
--		self.m_pResultWnd:moveToFront();
	end
end

function XiakeJiuguan:HandleYuanClicked(arg)
print("yuan clicked");
	if self.m_iLastXiakeKey ~= 0 then
		local xiake = XiakeMng.m_vXiakes[self.m_iLastXiakeKey];
		if xiake ~= nil then
			YuanXiake.SetAndShow(xiake);
		end
	end
end

function XiakeJiuguan:HandleMyXiakeClicked(arg)
	print("myxiake");
	local myxk = MyXiake_xiake.peekInstance();
	if myxk ~= nil then
		myxk.m_iSelectedXiakeKey = self.m_iLastXiakeKey;
		myxk.m_XiakeData = XiakeMng.m_vXiakes[self.m_iLastXiakeKey];
	end
	XiakeMainFrame.getInstance():ShowWindow(XiakeMainFrame.kWodeXK);
end

function XiakeJiuguan:HandleContinueClicked(arg)
	print("continue");
	if self.m_pBtn1000:isDisabled() or self.m_pBtn100:isDisabled() or self.m_pBtn1000:isDisabled() then
		return;
	end

	if self.m_eLastFind == XiakeJiuguan.eLastFind10 then
		self:Handle10Clicked(nil);
	elseif self.m_eLastFind == XiakeJiuguan.eLastFind100 then
		self:Handle100Clicked(nil);
	elseif self.m_eLastFind == XiakeJiuguan.eLastFind1000 then
		self:Handle1000Clicked(nil);
	end
end

function XiakeJiuguan:HandleBackClicked(arg)
	print("back");
	self:SetMode(XiakeJiuguan.ModeFind);
end

function XiakeJiuguan:OnEffectEnd()
	print("+++++++++ effect end +++++++++");
	XiakeJiuguan.peekInstance().m_pBtn10:setEnabled(true);
	XiakeJiuguan.peekInstance().m_pBtn100:setEnabled(true);
	XiakeJiuguan.peekInstance().m_pBtn1000:setEnabled(true);
	XiakeJiuguan.peekInstance().m_pMainFrame:setAlwaysOnTop(false);
end

function XiakeJiuguan:PlayEffect(aEffectID, aOnEndHandler)
	self.m_pMainFrame:setAlwaysOnTop(true);
	local pEffect = GetGameUIManager():AddUIEffect(self.m_pEffectWnd,
		MHSD_UTILS.get_effectpath(10371), false, 0, 0);
	if aOnEndHandler == nil then
		aOnEndHandler = XiakeJiuguan.OnEffectEnd;
	end

	if pEffect and aOnEndHandler ~= nil then
		print("added effect");
		local notify = CGameUImanager:createNotify(aOnEndHandler);
		pEffect:AddNotify(notify);
	end
end

function XiakeJiuguan.HandleConfirmBuy(args)
	local xf = XiakeJiuguan.getInstance().LastXunfang;
	if xf == 1 then
		XiakeJiuguan.getInstance():Handle10Clicked();
	elseif xf == 2 then
		XiakeJiuguan.getInstance():Handle100Clicked();
	elseif xf == 3 then
		XiakeJiuguan.getInstance():Handle1000Clicked();
	end
	GetMessageManager():CloseConfirmBox(eConfirmTeamLeaderEnterFuben, false);
	if XiakeMng.ePriceXiake.x10 == -1 then
		return;
	end
	return true;
end

function XiakeJiuguan:HandleCancelBuy(args)
    GetMessageManager():CloseConfirmBox(eConfirmTeamLeaderEnterFuben, false);
    self.show10Confirm = nil
    self.show100Confirm = nil
    self.show1000Confirm = nil
end

function XiakeJiuguan:ShowConfirm(ePrice, aXunfang)
        local strStepInf=tostring(ePrice);
        local strbuilder = StringBuilder:new()	
	     strbuilder:Set("parameter1", strStepInf)
	    
	    local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144955))
        GetMessageManager():AddConfirmBox(eConfirmTeamLeaderEnterFuben,msg,
		 									XiakeJiuguan.HandleConfirmBuy,0,
	     									XiakeJiuguan.HandleCancelBuy,
											self,0,0,nil,"","")

	     self.LastXunfang = aXunfang;
         strbuilder:delete()
	     strbuilder=nil
end

function XiakeJiuguan:checkShowConfirm(args)
    if ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
        if not self["m_pPaop" .. args ]:isVisible() then
            return true
        end
	end
    return false
end

function XiakeJiuguan:Handle10Clicked(arg)
	if XiakeMng.m_b10Chg == true then
		XiakeMng.m_b10Chg = false;
		self:ShowConfirm(XiakeMng.ePriceXiake.x10, 1);
		self.m_eLastFind = XiakeJiuguan.eLastFind10;
        self.show10Confirm = 0
		return;
	end



    if self:checkShowConfirm(10) then
        if not self.show10Confirm then
            self:ShowConfirm(XiakeMng.ePriceXiake.x10, 1)
            self.m_eLastFind = XiakeJiuguan.eLastFind10
            self.show10Confirm = 0
            return
        else
            self.show10Confirm = nil
        end
    end




	local money = GetDataManager():GetYuanBaoNumber(); 
	if money > XiakeMng.ePriceXiake.x10 or (XiakeMng.m_i10Time == 0 and XiakeMng.m_i10Left ~= 0) then
--		self.m_pBtn10:setEnabled(false);
		if XiakeMng.ePriceXiake.x10 ~= -1 then
			self:PlayEffect(10371, nil);
		end
	end
	local iUseMoney = 0;
	if XiakeMng.m_i10Time == 0 and XiakeMng.m_i10Left ~= 0 then
		iUseMoney = 0;
	else
		iUseMoney = 1;
	end

	if iUseMoney == 1 and XiakeMng.ePriceXiake.x10 == -1 then
		GetGameUIManager():AddMessageTipById(144935);
		return;
	end

	if iUseMoney == 0 and XiakeMng.ePriceXiake.x10 == -1 then
		self:PlayEffect(10371, nil);
	end

	local req = knight.gsp.xiake.CClickXiakeJiuguan(1, iUseMoney);
	GetNetConnection():send(req);
	self.m_eLastFind = XiakeJiuguan.eLastFind10;
end

function XiakeJiuguan:Handle100Clicked(arg)
	--firsarg:1,ten,2,h,3,t
	--secondarg:0,free, 1, usem
	if XiakeMng.m_b100Chg == true then
		XiakeMng.m_b100Chg = false;
		self:ShowConfirm(XiakeMng.ePriceXiake.x100, 2);
		self.m_eLastFind = XiakeJiuguan.eLastFind100;
        self.show100Confirm = 0
		return;
	end
    

    if self:checkShowConfirm(100) then
        if not self.show100Confirm then
            self:ShowConfirm(XiakeMng.ePriceXiake.x100, 2)
            self.m_eLastFind = XiakeJiuguan.eLastFind100
            self.show100Confirm = 0
            return
        else
            self.show100Confirm = nil
        end
    end


	local money = GetDataManager():GetYuanBaoNumber(); 
	if money > XiakeMng.ePriceXiake.x100 or XiakeMng.m_i100Time == 0 then
--		self.m_pBtn100:setEnabled(false);
		if XiakeMng.ePriceXiake.x100 ~= -1 then
			self:PlayEffect(10371, nil);
		end
	end

	local iUseMoney = 0;
	if XiakeMng.m_i100Time == 0 then
		iUseMoney = 0;
	else
		iUseMoney = 1;
	end

	if iUseMoney == 1 and XiakeMng.ePriceXiake.x100 == -1 then
		GetGameUIManager():AddMessageTipById(144935);
		return;
	end

	if XiakeMng.ePriceXiake.x100 == -1 and iUseMoney == 0 then
		self:PlayEffect(10371, nil);
	end

	local req = knight.gsp.xiake.CClickXiakeJiuguan(2, iUseMoney);
	GetNetConnection():send(req);
	self.m_eLastFind = XiakeJiuguan.eLastFind100;
end

function XiakeJiuguan:Handle1000Clicked(arg)
	if XiakeMng.m_b1000Chg == true then
		XiakeMng.m_b1000Chg = false;
		self:ShowConfirm(XiakeMng.ePriceXiake.x1000, 3);
		self.m_eLastFind = XiakeJiuguan.eLastFind1000;
        self.show1000Confirm = 0
		return;
	end


    if self:checkShowConfirm(1000)  then
        if not self.show1000Confirm then
            self:ShowConfirm(XiakeMng.ePriceXiake.x1000, 3)
            self.m_eLastFind = XiakeJiuguan.eLastFind1000
            self.show1000Confirm = 0
            return
        else
            self.show1000Confirm = nil
        end
    end
    

    

	local money = GetDataManager():GetYuanBaoNumber(); 
	if money > XiakeMng.ePriceXiake.x1000 or XiakeMng.m_i1000Time == 0 then
--		self.m_pBtn1000:setEnabled(false);
		if XiakeMng.ePriceXiake.x1000 ~= -1 then
			self:PlayEffect(10371, nil);
		end
	end
	local iUseMoney = 0;
	if XiakeMng.m_i1000Time == 0 then
		iUseMoney = 0;
	else
		iUseMoney = 1;
	end

	if iUseMoney == 1 and XiakeMng.ePriceXiake.x1000 == -1 then
		GetGameUIManager():AddMessageTipById(144935);
		return;
	end

	if XiakeMng.ePriceXiake.x1000 == -1 and iUseMoney == 0 then
		self:PlayEffect(10371, nil);
	end

	local req = knight.gsp.xiake.CClickXiakeJiuguan(3, iUseMoney);
	GetNetConnection():send(req);
	self.m_eLastFind = XiakeJiuguan.eLastFind1000;
end

function XiakeJiuguan:SetTime(pTimeLbl, t)
	t = t/1000;

	local sec = t%60;
	local minite = (t/60)%60;
	local hour = (t/(60*60))%60;

	pTimeLbl:setText(string.format("%02d:%02d:%02d", hour, minite, sec));
end

function XiakeJiuguan:Refresh10Price(aPrice)
	if aPrice == -1 then
--		self.m_pLblMoney10:setVisible(false);
--		self.m_pBtn10:setEnabled(false);
		XiakeMng.m_b10Chg = false;
		return;
	end
	self.m_pLblMoney10:setText(tostring(aPrice));
end

function XiakeJiuguan:Refresh100Price(aPrice)
	if aPrice == -1 then
--		self.m_pLblMoney100:setVisible(false);
--		self.m_pBtn100:setEnabled(false);
		XiakeMng.m_b100Chg = false;
		return;
	end
	self.m_pLblMoney100:setText(tostring(aPrice));
end

function XiakeJiuguan:Refresh1000Price(aPrice)
	if aPrice == -1 then
--		self.m_pLblMoney1000:setVisible(false);
--		self.m_pBtn1000:setEnabled(false);
		XiakeMng.m_b1000Chg = false;
		return;
	end
	self.m_pLblMoney1000:setText(tostring(aPrice));
	self.m_p10TimeMoney:setText(tostring(10 * aPrice))
end

function XiakeJiuguan:Refresh10(a10time)
print("----------r 10");
	self.m_vFoundStates10[1]:setVisible(a10time ~= 0);
	self.m_vFoundStates10[3]:setVisible(a10time == 0);

	XiakeMng.m_i10Time = a10time*1000;
	self.m_pPaop10:setVisible(true);
	self.m_pFound10PricePan:setVisible(false);

	if a10time ~= 0 then
	print("*****************jiuguan 10 price");
		self.m_pFound10PricePan:setVisible(true);
		XiakeJiuguan:SetTime(self.m_pLblTime10, a10time);
		self.m_pPaop10:setVisible(false);
	end
end

function XiakeJiuguan:Refresh100(a100time)
	self.m_vFoundStates100[1]:setVisible(a100time ~= 0);
	self.m_vFoundStates100[2]:setVisible(a100time == 0);
	
	XiakeMng.m_i100Time = a100time*1000;
	self.m_pPaop100:setVisible(true);

	if a100time ~= 0 then
		XiakeJiuguan:SetTime(self.m_pLblTime100, a100time);
		self.m_pPaop100:setVisible(false);
	end
end

function XiakeJiuguan:Refresh1000(a1000time)
	self.m_vFoundStates1000[1]:setVisible(a1000time ~= 0);
	self.m_vFoundStates1000[2]:setVisible(a1000time == 0);
	
	XiakeMng.m_i1000Time = a1000time*1000;
	self.m_pPaop1000:setVisible(true);

	if a1000time ~= 0 then
		XiakeJiuguan:SetTime(self.m_pLblTime1000, a1000time);
		self.m_pPaop1000:setVisible(false);
	end
end

function XiakeJiuguan:Refresh10Left(aLeft)
	XiakeMng.m_i10Left = aLeft;
	if aLeft == 0 then
--		self.m_vFoundStates10[1]:setVisible(false);
		self.m_vFoundStates10[2]:setVisible(false);
--		self.m_vFoundStates10[3]:setVisible(false);
--		self.m_pFoundLeftCount10:setVisible(false);
		self.m_pFoundLeftCount10:setText("0/5");
		self.m_pFound10PricePan:setVisible(true);
		self.m_pPaop10:setVisible(false);
	else
		self.m_pFoundLeftCount10:setVisible(true);
		if XiakeMng.m_i10Time <= 0 then	self.m_pFound10PricePan:setVisible(false); end
		self.m_pFoundLeftCount10:setText(tostring(aLeft).."/5");
	end
end

function XiakeJiuguan:RefreshGotXiake(aXiakeKey)
	self.m_iLastXiakeKey = aXiakeKey;
	self:SetMode(XiakeJiuguan.ModeResult);
	local req = knight.gsp.xiake.CGetMyXiakeInfo(aXiakeKey);
	GetNetConnection():send(req);
	self:SetXiakeResult(aXiakeKey);
end

function XiakeJiuguan:SetXiakeResult(aXiakeKey)
	if XiakeMng.m_vXiakes == nil then print("error int xiake mng");return;end

	local vXiakes = XiakeMng.m_vXiakes;
--	for k,v in pairs(vXiakes) do
--		print(tostring(k).."--"..tostring(v));
--	end

	if vXiakes[aXiakeKey] == nil then print("aXiakeKey is not exist");return;end

--	self.m_iLastXiakeKey = 0;

	local xiake = vXiakes[aXiakeKey];
	local aXiakeID = xiake.xiakeid;
	local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
	local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
	local path = GetIconManager():GetImagePathByID(shape.headID):c_str();
	self.m_pHeadIcon:setProperty("Image", path);

	local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
	--for skill 4 add by wuyao
	local xkxxs4 = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakexin"):getRecorder(aXiakeID)
	self.m_pName:setText(scene_util.GetPetNameColor(xkxx.color)..xkxx.name);
	self.m_pXiakeFrame:setProperty("Image", XiakeMng.eXiakeFrames[xkxx.color]);
	self.m_plevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
	self.m_pJie:setProperty("Image", XiakeMng.eLvImages[xiake.starlv]);

	self.m_pBigColor:setProperty("Image", XiakeMng.eBigColors[xkxx.color]);

	self.m_pType:setText(xkxx.kinddes);
	self.m_pWaiGongShanghai:setText(tostring(xkxx.jichugongji));
	self.m_pWaiGongFangyu:setText(tostring(xkxx.jichufangyu));

	for i = 1, xkxx.yuan:size() do
		if xkxx.yuan[i - 1] ~= 0 then
			local y = knight.gsp.npc.GetCXiakeyuanTableInstance():getRecorder(xkxx.yuan[i - 1]);
			self.m_vYuans[i]:setText(y.name);
		else
			self.m_vYuans[i]:setText("");
		end
	end

	for i = xkxx.yuan:size() + 1, 6 do
		if i <= 6 then
			self.m_vYuans[i]:setText("");
		end
	end

	for i = 1, 4 do
		local skillconfig = knight.gsp.npc.GetCXiakeskillTableInstance():getRecorder(xkxxs4["skill"..tostring(i)]);
		if skillconfig == nil or skillconfig.id <= 0 then
			self.m_vBornSkills[i]:Clear();
			self.m_vBornSkills[i]:SetBackGroundImage(nil);
			self.m_vBornSkills[i]:SetBackgroundDynamic(false);
			self.m_vBornSkillNames[i]:setVisible(false);
			self.m_vBornSkills[i]:setVisible(false);
		else
			self.m_vBornSkillNames[i]:setText(skillconfig.skillname);
			self.m_vBornSkills[i]:SetBackgroundDynamic(true);
			self.m_vBornSkills[i]:SetBackGroundImage(CEGUI.String(XiakeMng.eSkillFrames[skillconfig.color].imageset), CEGUI.String(XiakeMng.eSkillFrames[skillconfig.color].image));
			CSkillBoxControl:GetInstance():SetSkillInfo(self.m_vBornSkills[i], xkxxs4["skill"..tostring(i)]);
			self.m_vBornSkillNames[i]:setVisible(true);
			self.m_vBornSkills[i]:setVisible(true);
		end
	end

	if xiake.bIsDetail ~= nil and xiake.bIsDetail == true then
		self.m_pLife:setText(string.format("%d", xiake.datas[140]));
		self.m_pWaiGongShanghai:setText(string.format("%d", xiake.datas[80]));
		self.m_pWaiGongFangyu:setText(string.format("%d", xiake.datas[100]));
		self.m_pNeiGongFangyu:setText(string.format("%d", xiake.datas[820]));
		self.m_pSpeed:setText(string.format("%d", xiake.datas[130]));
	end
end

function XiakeJiuguan:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, XiakeJiuguan);

	self.m_eLastFind = eLastFindNone;
	return self;
end

function XiakeJiuguan.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end

	if XiakeMainFrame:peekInstance() then
		XiakeMainFrame.DestroyDialog();
	end
end

function XiakeJiuguan:Handle10TimeClicked(args)
	LogInfo("XiakeJiuguan Handle10TimeClicked")
	local req = CClickXiake10Times.Create()
	LuaProtocolManager.getInstance():send(req)
end

function XiakeJiuguan:InitXiakeInfo(recordID)
	LogInfo("XiakeJiuguan init xiake info")
	
	--local beanTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakeshilianzhixiyou")
	--local ids = beanTable:getAllID()
	--local recordID = 0
	--local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	--local timeStr = tostring(time.tm_year + 1900) .. "-" .. tostring(time.tm_mon + 1) .. "-" .. tostring(time.tm_mday) .. " " .. tostring(time.tm_hour) .. ":" .. tostring(time.tm_min) .. ":" .. tostring(time.tm_sec)
	--for k,v in pairs(ids) do
	--	local record = beanTable:getRecorder(v)
	--	if record.startTime <= timeStr and record.endTime >= timeStr then
	--		recordID = record.id
	--		break
	--	end
	--	recordID = record.id
	--end
	--
	local beanTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakeshilianzhixiyou")
	local record = beanTable:getRecorder(recordID)
	local xk1 = XiakeMng.ReadXiakeData(record.xiake1)
	local xk2 = XiakeMng.ReadXiakeData(record.xiake2)
	local xk3 = XiakeMng.ReadXiakeData(record.xiake3)
	local xk4 = XiakeMng.ReadXiakeData(record.xiake4)
	local xk5 = XiakeMng.ReadXiakeData(record.xiake5)
	self.m_pXiakePic[0]:setProperty("Image", xk1.path)
	self.m_pXiakePic[1]:setProperty("Image", xk2.path)
	self.m_pXiakePic[2]:setProperty("Image", xk3.path)
	self.m_pXiakePic[3]:setProperty("Image", xk4.path)
	self.m_pXiakePic[4]:setProperty("Image", xk5.path)
	
	self.m_pXiakeName[0]:setText(scene_util.GetPetNameColor(xk1.xkxx.color) .. xk1.xkxx.name)
	self.m_pXiakeName[1]:setText(scene_util.GetPetNameColor(xk2.xkxx.color) .. xk2.xkxx.name)
	self.m_pXiakeName[2]:setText(scene_util.GetPetNameColor(xk3.xkxx.color) .. xk3.xkxx.name)
	self.m_pXiakeName[3]:setText(scene_util.GetPetNameColor(xk4.xkxx.color) .. xk4.xkxx.name)
	self.m_pXiakeName[4]:setText(scene_util.GetPetNameColor(xk5.xkxx.color) .. xk5.xkxx.name)
end

-- 弹出侠客清单
function XiakeJiuguan:HandleXiakeListClicked(args)

    local mouseArgs = CEGUI.toMouseEventArgs(args)
    local id = mouseArgs.window:getID()
	if not id then return end
    
	local XiakePreviewDlg = require "ui.xiake.xiakepreviewdlg"
	local dlg = XiakePreviewDlg.getInstanceAndShow()
	if dlg then
		dlg:InitXiakeList(id)
		dlg:RefreshXiakeList()
	end
end

return XiakeJiuguan;