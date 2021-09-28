require "ui.dialog"
require "utils.mhsdutils"
require "utils.scene_common"

JinhuaCell = {
	m_strNamePrefix,
};

setmetatable(JinhuaCell, Dialog);
JinhuaCell.__index = JinhuaCell;

function JinhuaCell.newItem()
	local item = {pElite = nil, pIcon = nil, pName = nil, pLevel = nil, pMark = nil,
					pData = nil	};
	return item;
end

function JinhuaCell:GetLayoutFileName()
	return "quackcelllist1.layout";
end

function JinhuaCell:GetWnd()
	return self.m_pMainFrame;
end

function JinhuaCell:HandleXiakeSelected(arg)
	print("jin hua cell clicked");--6 ge o~
end

function JinhuaCell:SetItems(i, items)
	for inx = 1, 5 do
		local xiake = items[(i-1)*5+inx];
		if xiake ~= nil then
			local aXiakeID = xiake.xiakeid;
			local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
			local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
			local path = GetIconManager():GetImagePathByID(shape.headID):c_str();
			self.m_vItems[inx].pIcon:setProperty("Image", path);
            
            if self.m_vItems[inx].pElite then
                self.m_vItems[inx].pElite:setVisible(XiakeMng.IsElite(xiake.xiakekey))
            end

			local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
			self.m_vItems[inx].pName:setText(scene_util.GetPetNameColor(xiake.color)..xkxx.name);
			self.m_vItems[inx].pFrame:setProperty("Image", XiakeMng.eXiakeFrames[xiake.color]);
			self.m_vItems[inx].pLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
			self.m_vItems[inx].pMark:setProperty("Image", XiakeMng.eLvImages[xiake.starlv]);
			self.m_vItems[inx].pData = xiake;
		else
			self.m_vItems[inx].pData = nil;
			self.m_vItems[inx].pIcon:setProperty("Image", "");
            if self.m_vItems[inx].pElite then
                self.m_vItems[inx].pElite:setVisible(false)
            end
			self.m_vItems[inx].pName:setText("");
			self.m_vItems[inx].pFrame:setProperty("Image", XiakeMng.eXiakeFrames[3]);
			self.m_vItems[inx].pLevel:setText("");
			self.m_vItems[inx].pMark:setProperty("Image", "");
		end
	end
	self.m_pMainFrame:invalidate();
end

function JinhuaCell:OnCreate()
	Dialog.OnCreate(self, nil, self.m_strNamePrefix);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_vItems = {};
	local pfx = self.m_strNamePrefix;
	self.m_vItems[1] = JinhuaCell.newItem();
	self.m_vItems[1].pFrame = winMgr:getWindow(pfx.."quackcelllist1/quack");
    self.m_vItems[1].pElite = winMgr:getWindow(pfx.."quackcelllist1/elite")
    if self.m_vItems[1].pElite then
        self.m_vItems[1].pElite:setVisible(false)
    else
        print("____error get quackcelllist1/elite")
	end
    self.m_vItems[1].pIcon = winMgr:getWindow(pfx.."quackcelllist1/icon");
	self.m_vItems[1].pName = winMgr:getWindow(pfx.."quackcelllist1/name");
	self.m_vItems[1].pLevel = winMgr:getWindow(pfx.."quackcelllist1/level");
	self.m_vItems[1].pMark = winMgr:getWindow(pfx.."quackcelllist1/mark");
	self.m_vItems[1].pMark:setProperty("Image", "");
	self.m_vItems[1].pLevel:setText("");
	self.m_vItems[1].pIcon:subscribeEvent("MouseButtonUp", JinhuaCell.HandleIconClick, self.m_vItems[1]);
	for i = 2, 5 do
		self.m_vItems[i] = JinhuaCell.newItem();
		self.m_vItems[i].pFrame = winMgr:getWindow(pfx.."quackcelllist1/quack"..tostring(i-1));
        self.m_vItems[i].pElite = winMgr:getWindow(pfx.."quackcelllist1/elite"..tostring(i-1));
        if self.m_vItems[i].pElite then
            self.m_vItems[i].pElite:setVisible(false)
        else
            print("____error get quackcelllist1/elite1_4")
        end
		self.m_vItems[i].pIcon = winMgr:getWindow(pfx.."quackcelllist1/icon"..tostring(i-1));
		self.m_vItems[i].pName = winMgr:getWindow(pfx.."quackcelllist1/name"..tostring(i-1));
		self.m_vItems[i].pLevel = winMgr:getWindow(pfx.."quackcelllist1/level"..tostring(i-1));
		self.m_vItems[i].pMark = winMgr:getWindow(pfx.."quackcelllist1/mark"..tostring(i-1));
		self.m_vItems[i].pMark:setProperty("Image", "");
		self.m_vItems[i].pLevel:setText("");
		self.m_vItems[i].pIcon:subscribeEvent("MouseButtonUp", JinhuaCell.HandleIconClick, self.m_vItems[i]);
	end


end

function JinhuaCell:HandleIconClick(arg)
	if self.pData == nil then 
		JinhuaXiake.SetDieingXiake(nil);
		JinhuaXiake.getInstance():RefreshJinhuaInfos(JinhuaXiake.getInstance().m_pJinhuaData);
		return; 
	end

	JinhuaXiake.SetDieingXiake(self.pData);
	--request preview from server
	print(JinhuaXiake.getInstance().m_XiakeData.xiakekey, JinhuaXiake.getInstance().m_MaterialXiakeData.xiakekey);
	local req = knight.gsp.xiake.CUpgradeXiakePreview(JinhuaXiake.getInstance().m_XiakeData.xiakekey, JinhuaXiake.getInstance().m_MaterialXiakeData.xiakekey);
	GetNetConnection():send(req);
end


function JinhuaCell:new()
	local cell = {};
	cell = Dialog:new();
	setmetatable(cell, JinhuaCell);
	
	return cell;
end

function JinhuaCell.CreateItem(aStrPrefix)
	local ret = JinhuaCell:new();
	ret.m_strNamePrefix = aStrPrefix;
	ret:OnCreate();

	return ret;
end

JinhuaXiake = {
	m_XiakeData,
	m_MaterialXiakeData,
	m_iAddedExp,
	m_vDieingXiakes,
	m_vPRows;

	m_pBLife,
	m_pBAttack,
	m_pBDefence,
	m_pBDefenceNei,
	m_pBSpeed,

	m_pALife,
	m_pAAttack,
	m_pADefence,
	m_pADefenceNei,
	m_pASpeed,

	m_pProgressCur,
	m_pProgressNex,

	m_pList,
	m_ChooseingCtls,
	m_pMainIcon,
    m_pMainElite,
	m_pMainMark,
	m_pMainLevel,
	m_pMainName,

	m_pDieingIcon,
    m_pDieingElite,
	m_pDieingMark,
	m_pDieingLevel,
	m_pDieingName,

	m_pBtnJinhua,
	m_bIsInhuaing,
};

setmetatable(JinhuaXiake, Dialog);
JinhuaXiake.__index = JinhuaXiake;

function JinhuaXiake:OnEffectEnd()
--	JinhuaXiake.getInstance().m_bIsInhuaing = false;
end

function JinhuaXiake:PlayEffectJinhua(isLevelUp)
	if isLevelUp then
		GetGameUIManager():AddUIEffect(self.m_pMainIcon, MHSD_UTILS.get_effectpath(10386), false);
	else
		GetGameUIManager():AddUIEffect(self.m_pMainIcon, MHSD_UTILS.get_effectpath(10296), false);
	end
end

function JinhuaXiake:HandleJinhuaClicked(arg)
	if self.m_MaterialXiakeData == nil then
		-- GetGameUIManager():AddMessageTipById(144904);
		-- return;
		if self.m_vDieingXiakes[1] ~= nil then
			self.m_MaterialXiakeData = self.m_vDieingXiakes[1]
		else
			GetGameUIManager():AddMessageTipById(145895)
			return
		end
	end

--	if self.m_bIsInhuaing == true then return; end

--	local pEffect = GetGameUIManager():AddUIEffect(self.m_pMainIcon, MHSD_UTILS.get_effectpath(10296), false);
--	if pEffect then
--		local notify = CGameUImanager:createNotify(self.OnEffectEnd);
--		pEffect:AddNotify(notify);
--		self.m_bIsInhuaing = true;
--	end

	XiakeMng.m_MaterialXiakeToBeDelete = self.m_MaterialXiakeData;
	XiakeMng.RequestUpgradeXiake(self.m_XiakeData.xiakekey, self.m_MaterialXiakeData.xiakekey);
end

function JinhuaXiake:HandleJinhuaAllClicked(arg)
	local DieKeys = {}
	local index = 0
	local have = false
	for k,v in pairs(self.m_vDieingXiakes) do
		index = index + 1
		DieKeys[index] = v.xiakekey
		have = true
	end

	if not have then
		GetGameUIManager():AddMessageTipById(145895)
		return
	end

	local function ClickYes(self, args)
		GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		XiakeMng.RequestUpgradeAllXiake(self.m_XiakeData.xiakekey, DieKeys)
	end

	local confirmMsg = MHSD_UTILS.get_msgtipstring(145903)
	GetMessageManager():AddConfirmBox(eConfirmNormal, confirmMsg, ClickYes, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)	
	
	-- XiakeMng.RequestUpgradeAllXiake(self.m_XiakeData.xiakekey, DieKeys)
end

local _instance;
function JinhuaXiake.getInstance()
	if not _instance then
		_instance = JinhuaXiake:new();
		_instance:OnCreate();
	end

	return _instance;
end

function JinhuaXiake.peekInstance()
	return _instance;
end

function JinhuaXiake.GetLayoutFileName()
	return "quackevolve.layout";
end

function JinhuaXiake:OnCreate()
	Dialog.OnCreate(self);

	self.m_vPRows = {};
	self.m_ChooseingCtls = {};
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pBLife = winMgr:getWindow("quackevolve/top/num");	
	self.m_pBAttack = winMgr:getWindow("quackevolve/top/num1");
	self.m_pBDefence = winMgr:getWindow("quackevolve/top/num2");
	self.m_pBDefenceNei = winMgr:getWindow("quackevolve/top/num3");
	self.m_pBSpeed = winMgr:getWindow("quackevolve/top/num8");
	self.m_pBFrame = winMgr:getWindow("quackevolve/quack1");
	
	self.m_pALife = winMgr:getWindow("quackevolve/top/num4");
	self.m_pAAttack = winMgr:getWindow("quackevolve/top/num5");
	self.m_pADefence = winMgr:getWindow("quackevolve/top/num6");
	self.m_pADefenceNei = winMgr:getWindow("quackevolve/top/num7");
	self.m_pASpeed = winMgr:getWindow("quackevolve/top/num9");
	self.m_pAFrame = winMgr:getWindow("quackevolve/quack0");

	self.m_pLblShanghaiLeixing = winMgr:getWindow("quackevolve/top/txt1");
	self.m_pLblShanghaiLeixing2 = winMgr:getWindow("quackevolve/top/txt5");
	
	self.m_pBLife:setText("");
	self.m_pBAttack:setText("");
	self.m_pBDefence:setText("");
	self.m_pBDefenceNei:setText("");
	self.m_pBSpeed:setText("");

	self.m_pALife:setText("");
	self.m_pAAttack:setText("");
	self.m_pADefence:setText("");
	self.m_pADefenceNei:setText("");
	self.m_pASpeed:setText("");

	self.m_pProgressCur = CEGUI.Window.toProgressBar(winMgr:getWindow("quackevolve/top/barture"));
	self.m_pProgressNex = CEGUI.Window.toProgressBar(winMgr:getWindow("quackevolve/top/bar"));
	self.m_pList = winMgr:getWindow("quackevolve/main/scroll");
	
	self.m_pMainName = winMgr:getWindow("quackevolve/name1");
    self.m_pMainElite = winMgr:getWindow("quackevolve/elite1")
    if self.m_pMainElite then
        self.m_pMainElite:setVisible(false)
    else
        print("____error get quackevolve/elite1")
    end
	self.m_pMainIcon = winMgr:getWindow("quackevolve/icon1");
	self.m_pMainLevel = winMgr:getWindow("quackevolve/level1");
	self.m_pMainMark = winMgr:getWindow("quackevolve/mark1");
	self.m_pMainMark:setProperty("Image", "");

	self.m_pDieingName = winMgr:getWindow("quackevolve/name0");
    self.m_pDieingElite = winMgr:getWindow("quackevolve/elite0")
    if self.m_pDieingElite then
        self.m_pDieingElite:setVisible(false)
    else
        print("____error get quackevolve/elite0")
    end
	self.m_pDieingIcon = winMgr:getWindow("quackevolve/icon0");
	self.m_pDieingLevel = winMgr:getWindow("quackevolve/level0");
	self.m_pDieingMark = winMgr:getWindow("quackevolve/mark0");
	self.m_pDieingMark:setProperty("Image", "");

	self.m_pMainLevel:setText("");
	self.m_pDieingLevel:setText("");

	self.m_pBtnJinhua = winMgr:getWindow("quackevolve/ok");
	self.m_pBtnJinhua:subscribeEvent("Clicked", JinhuaXiake.HandleJinhuaClicked, self);
	self.m_pDieingIcon:subscribeEvent("MouseButtonUp", JinhuaXiake.HandleDieingIconClick, self);

	self.m_pBtnJinhuaAll = winMgr:getWindow("quackevolve/yijianjinhua");
	self.m_pBtnJinhuaAll:subscribeEvent("Clicked", JinhuaXiake.HandleJinhuaAllClicked, self);

	self:RefreshDieingXiakes();
	XiakeMainFrame.getInstance():GetWindow():setVisible(false)
end

function JinhuaXiake:new()
	local newWnd = {};
	newWnd = Dialog:new();
	setmetatable(newWnd, JinhuaXiake);

	return newWnd;
end

function JinhuaXiake.DestroyDialog()
	if _instance then
		XiakeMng.m_MaterialXiakeToBeDelete = nil;
		_instance:OnClose();
		_instance = nil;
	end
	
	local myXiake = MyXiake_xiake.peekInstance();
	if myXiake ~= nil then
		myXiake.m_pMainFrame:setVisible(true);
	end
end

function JinhuaXiake:HandleDieingIconClick(arg)
	if self.m_MaterialXiakeData ~= nil then
		JinhuaXiake.SetDieingXiake(nil);
		JinhuaXiake.getInstance():RefreshJinhuaInfos(JinhuaXiake.getInstance().m_pJinhuaData);
	end
end

function JinhuaXiake:RefreshDieingXiakes()
--calc dieing count

	if self.m_XiakeData == nil then return; end
	self.m_vDieingXiakes = {};
	local iXiakeID = self.m_XiakeData.xiakeid;
	for k,v in pairs(XiakeMng.m_vXiakes) do
		if v.xiakeid == iXiakeID and self.m_XiakeData.xiakekey ~= v.xiakekey then
			self.m_vDieingXiakes[#self.m_vDieingXiakes+1] = v;
		end
	end
--find highest score
	local bMainChange = false;
	for i = 1, #self.m_vDieingXiakes do
		if self.m_vDieingXiakes[i].score > self.m_XiakeData.score then
			local t = self.m_XiakeData;
			self.m_XiakeData = self.m_vDieingXiakes[i]
			self.m_vDieingXiakes[i] = t;
			bMainChange = true;
		end
	end

	if bMainChange then
		self:SetMainXiake(self.m_XiakeData);
		XiakeMng.RequestUpgradeXiake(self.m_XiakeData.xiakekey, 0);
	end

	for i = 1, #self.m_vPRows do
		local t = {};
		self.m_vPRows[i]:SetItems(i, t);
	end

	local nRow = math.ceil(#self.m_vDieingXiakes/5.0);
	for i = 1, nRow do
		if #self.m_vPRows >= i then
			self.m_vPRows[i]:SetItems(i, self.m_vDieingXiakes);
		else
			local itm = JinhuaCell.CreateItem(tostring(i));
			self.m_pList:addChildWindow(itm:GetWnd());
			itm.m_pMainFrame:setPosition(
				CEGUI.UVector2(
					CEGUI.UDim(0,0),
					CEGUI.UDim(0,1 + (i - 1)*250)
					)
				);
			self.m_vPRows[#self.m_vPRows+1] = itm;
			itm:SetItems(i, self.m_vDieingXiakes);
		end
	end

	self.m_pList:invalidate();
end

function JinhuaXiake:RefreshUpgradePreview(aXiakeKey, aAddexp)
	local xd = self.m_XiakeData;
	if xd.bIsDetail == nil or xd.bIsDetail == false then
		print("no detail for " , aXiakeKey);
		XiakeMng.RequestXiakeDetail(aXiakeKey);
		self.m_iAddedExp = aAddexp;
		return;
	end

	local expAdd  = 0;
	if aAddexp == nil then 
		if self.m_iAddedExp == nil then return; end
		expAdd = self.m_iAddedExp;
		self.m_iAddedExp = nil;
	else
		expAdd = aAddexp;
	end

	if self.m_XiakeData ~= nil and self.m_XiakeData.xiakekey == aXiakeKey then
		local ug = knight.gsp.npc.GetCXiakeupgradeTableInstance():getRecorder(self.m_XiakeData.xiakeid);
		local neededExp = ug.needexp[(xd.color-1)*3+xd.starlv-1];
		local curExp = xd.starlvexp;
		local aftad = curExp + expAdd;
		if aftad > neededExp then aftad = neededExp; end
		self.m_pProgressCur:setText(tostring(curExp).."[colour='FF00FF00']+"..tostring(expAdd).."[colour='FFFFFFFF']/"..tostring(neededExp));
		self.m_pProgressCur:setProgress(curExp/neededExp);
		self.m_pProgressNex:setProgress(aftad/neededExp);
	end
end

function JinhuaXiake:RefreshJinhuaInfos(aJinhuaData)
	if aJinhuaData ~= nil and aJinhuaData.xiakekey ~= self.m_XiakeData.xiakekey then
		return;
	end

	local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(self.m_XiakeData.xiakeid);

	self.m_pJinhuaData = aJinhuaData;

	if aJinhuaData ~= nil then
		local c = aJinhuaData.curdatas
		self.m_pBLife:setText(string.format("%d", c[140]));
		self.m_pBAttack:setText(string.format("%d", c[80]));
		self.m_pBDefence:setText(string.format("%d", c[100]));
		self.m_pBDefenceNei:setText(string.format("%d", c[820]));
		self.m_pBSpeed:setText(string.format("%d", c[130]));

		local n = aJinhuaData.nextdatas;
		self.m_pALife:setText(string.format("%d", n[140]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[140]) - math.floor(c[140])));
--		self.m_pAAttack:setText(string.format("%d", n[80]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[80]) - math.floor(c[80])));
		self.m_pADefenceNei:setText(string.format("%d", n[820]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[820]) - math.floor(c[820])));
		self.m_pADefence:setText(string.format("%d", n[100]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[100]) - math.floor(c[100])));
		self.m_pASpeed:setText(string.format("%d", n[130]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[130]) - math.floor(c[130])));

		if xkxx.waigong == 1 then
			self.m_pLblShanghaiLeixing:setText(MHSD_UTILS.get_resstring(2751));
			self.m_pLblShanghaiLeixing2:setText(MHSD_UTILS.get_resstring(2751));
			self.m_pBAttack:setText(string.format("%d", c[80]));
			self.m_pAAttack:setText(string.format("%d", n[80]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[80]) - math.floor(c[80])));
		else
			self.m_pLblShanghaiLeixing:setText(MHSD_UTILS.get_resstring(2750));
			self.m_pLblShanghaiLeixing2:setText(MHSD_UTILS.get_resstring(2750));
			self.m_pBAttack:setText(string.format("%d", c[810]));
			self.m_pAAttack:setText(string.format("%d", n[810]) .. "[colour='FF00FF00']+" .. string.format("%d", math.floor(n[810]) - math.floor(c[810])));
		end

		local ug = knight.gsp.npc.GetCXiakeupgradeTableInstance():getRecorder(aJinhuaData.xiakeid);
		local neededExp = ug.needexp[(aJinhuaData.color-1)*3 + aJinhuaData.starlv - 1];
		local curExp = aJinhuaData.starexp;

		self.m_pProgressNex:setProgress(curExp/neededExp);
		self.m_pProgressCur:setProgress(curExp/neededExp);
		self.m_pProgressCur:setText(tostring(curExp).."/"..tostring(neededExp));
		if self.m_MaterialXiakeData ~= nil then
			XiakeMng.m_vXiakes[self.m_MaterialXiakeData.xiakekey] = nil;
			self:RefreshDieingXiakes();
			JinhuaXiake.SetDieingXiake(nil);
		end
	end
end

function JinhuaXiake.SetDieingXiake(aXiake)
	local xkUI = JinhuaXiake.getInstance();
	if aXiake == nil then
		xkUI.m_MaterialXiakeData = nil;
		xkUI.m_pDieingIcon:setProperty("Image", "");
        if xkUI.m_pDieingElite then
            xkUI.m_pDieingElite:setVisible(false)
        end
		xkUI.m_pDieingMark:setProperty("Image", "");
		xkUI.m_pDieingLevel:setText("");
		xkUI.m_pDieingName:setText("");
		xkUI.m_pAFrame:setProperty("Image", XiakeMng.eXiakeFrames[3]);
		return;
	end

	local xiake = XiakeMng.ReadXiakeData(aXiake.xiakeid);
	xkUI.m_pDieingIcon:setProperty("Image", xiake.path);
    if xkUI.m_pDieingElite then
        xkUI.m_pDieingElite:setVisible(XiakeMng.IsElite(aXiake.xiakekey))
    end
	xkUI.m_pDieingMark:setProperty("Image", XiakeMng.eLvImages[aXiake.starlv]);
	xkUI.m_pDieingLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
	xkUI.m_pDieingName:setText(scene_util.GetPetNameColor(aXiake.color)..xiake.xkxx.name);
	xkUI.m_pAFrame:setProperty("Image", XiakeMng.eXiakeFrames[aXiake.color]);
	xkUI.m_MaterialXiakeData = aXiake;
end

function JinhuaXiake:SetMainXiake(aXiakeData)
	if aXiakeData == nil then return; end
	local xkAll = XiakeMng.ReadXiakeData(aXiakeData.xiakeid);
	self.m_pMainIcon:setProperty("Image", xkAll.path);
    if self.m_pMainElite then
        self.m_pMainElite:setVisible(XiakeMng.IsElite(aXiakeData.xiakekey))
    end
	self.m_pMainMark:setProperty("Image", XiakeMng.eLvImages[aXiakeData.starlv]);
	self.m_pMainName:setText(scene_util.GetPetNameColor(aXiakeData.color)..xkAll.xkxx.name);
	self.m_pBFrame:setProperty("Image", XiakeMng.eXiakeFrames[aXiakeData.color]);

end

function JinhuaXiake.Show(aXiake)
--get xiake data from xiake key
	if aXiake == nil then return; end
    
    if aXiake.xiakekey then
        print("____aXiake.xiakekey: " .. aXiake.xiakekey)
    end

	local myXiake = MyXiake_xiake.peekInstance();
	if myXiake ~= nil then
		myXiake.m_pMainFrame:setVisible(false);
	end

	XiakeMng.m_MaterialXiakeToBeDelete = nil;
	JinhuaXiake.getInstance().m_XiakeData = aXiake;
	JinhuaXiake.getInstance().m_MaterialXiakeData = nil;

	if aXiake.bIsDetail == nil or aXiake.bIsDetail == false then
		XiakeMng.RequestXiakeDetail(aXiake.xiakekey);
	end

	JinhuaXiake.getInstance():SetMainXiake(aXiake);
	
	JinhuaXiake.getInstance().m_pMainFrame:setVisible(true);
	JinhuaXiake.getInstance():RefreshDieingXiakes();
end

return JinhuaXiake;

