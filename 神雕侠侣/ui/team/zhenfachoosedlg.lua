require "ui.dialog"
require "utils.stringbuilder"
require "ui.team.stformationelement"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.team.cactiveformation"
require "protocoldef.knight.gsp.team.crequestsetformation"

ZhenfaChooseDlg = {}
setmetatable(ZhenfaChooseDlg, Dialog)
ZhenfaChooseDlg.__index = ZhenfaChooseDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ZhenfaChooseDlg.getInstance()
	LogInfo("enter get ZhenfaChooseDlg instance")
    if not _instance then
        _instance = ZhenfaChooseDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ZhenfaChooseDlg.getInstanceAndShow()
	LogInfo("enter ZhenfaChooseDlg instance show")
    if not _instance then
        _instance = ZhenfaChooseDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set ZhenfaChooseDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ZhenfaChooseDlg.getInstanceNotCreate()
    return _instance
end

function ZhenfaChooseDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy ZhenfaChooseDlg")
		for i = 0, 4 do
			_instance.m_FormationElementCell[i]:delete()
		end
		_instance:OnClose()
		_instance = nil
	end

	local myXiake = BuzhenXiake.peekInstance();
	if myXiake ~= nil then
		myXiake.m_pMainFrame:setVisible(true);
	end
end

function ZhenfaChooseDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ZhenfaChooseDlg:new() 
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

function ZhenfaChooseDlg.GetLayoutFileName()
    return "zhenfachoosedlg.layout"
end

function ZhenfaChooseDlg:OnCreate()
	LogInfo("ZhenfaChooseDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pFormationWnd = {}
	self.m_pFormationInfo = {}
	self.m_pFormationLight = {}
	self.m_pFormationName = {}
	for i = 1, 10 do
		if i > 1 then
			self.m_pFormationWnd[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/zhenfa" .. tostring(i - 1))
			self.m_pFormationWnd[i]:setID(i)
			self.m_pFormationInfo[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/info" .. tostring(i - 1))
			self.m_pFormationLight[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/light" .. tostring(i - 1))
			self.m_pFormationName[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/name" .. tostring(i - 1))
		else
			self.m_pFormationWnd[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/zhenfa")
			self.m_pFormationWnd[i]:setID(i)
			self.m_pFormationInfo[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/info")
			self.m_pFormationLight[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/light")
			self.m_pFormationName[i] = winMgr:getWindow("zhenfachoose/leftback/scroll/name")
		end
	end
	self.m_pRightFormationName = winMgr:getWindow("zhenfachoose/right/name")
	self.m_pNeedElement = {}
	self.m_pFormationEffect = {}
	self.m_FormationElementCell = {}
	self.m_pElementNum = {}
	for i = 0, 4 do
		self.m_pNeedElement[i] = winMgr:getWindow("zhenfachoose/left/info" .. tostring(i + 1))
		self.m_pElementNum[i] = winMgr:getWindow("zhenfachoose/left/num" .. tostring(i + 1))
		self.m_FormationElementCell[i] = stFormationElement:new()
		self.m_FormationElementCell[i]:InitElement(i)
		self.m_pFormationEffect[i] = CEGUI.Window.toRichEditbox(winMgr:getWindow("zhenfachoose/right/info" .. tostring(i)))
	end
	self.m_pActivateBtn = CEGUI.Window.toPushButton(winMgr:getWindow("zhenfachoose/left/btn"))
	self.m_pOpenBtn = CEGUI.Window.toPushButton(winMgr:getWindow("zhenfachoose/right/btn"))
	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("zhenfachoose/leftback/scroll"))
	self.m_pPane:EnableAllChildDrag(self.m_pPane)

	self.m_pActivateBar = CEGUI.Window.toProgressBar(winMgr:getWindow("zhenfachoose/left/bar"))
	self.m_pMark = winMgr:getWindow("zhenfachoose/leftback/scroll/mark")

	self.m_pEffectWnd = winMgr:getWindow("zhenfachoose/main/back")
	self.m_pCenterPic = winMgr:getWindow("zhenfachoose/main/back/end")
	self.m_pFormationType = winMgr:getWindow("zhenfachoose/right/name1")

    -- subscribe event
    for i = 1, 10 do
		self.m_pFormationWnd[i]:subscribeEvent("MouseClick", ZhenfaChooseDlg.HandleFormationSelected, self)
	end
	self.m_pActivateBtn:subscribeEvent("Clicked", ZhenfaChooseDlg.HandleActivateClicked, self)
	self.m_pOpenBtn:subscribeEvent("Clicked", ZhenfaChooseDlg.HandleOpenClicked, self)

	local manager = FormationManager.getInstance()
	if manager.m_iMyFormation == 0 then
		self:setFormationSelect(1)
	else
		self:setFormationSelect(manager.m_iMyFormation)
	end
	LogInfo("ZhenfaChooseDlg oncreate end")
end

------------------- private: -----------------------------------


function ZhenfaChooseDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhenfaChooseDlg)
    return self
end

function ZhenfaChooseDlg:HandleFormationSelected(args)
	LogInfo("ZhenfaChooseDlg handle formation selected")
	local wndArgs = CEGUI.toWindowEventArgs(args)
	local id = wndArgs.window:getID()
	self:setFormationSelect(id)		
	GetGameUIManager():RemoveUIEffect(self.m_pEffectWnd)
end

function ZhenfaChooseDlg:setFormationSelect(id)
	LogInfo("ZhenfaChooseDlg set formation select")
	self.m_iCurSelect = id
	self:refreshLeftFormationInfo()
	self:refreshRightFormationInfo()
	self:refreshDownFormationInfo()	

end

function ZhenfaChooseDlg:HandleActivateClicked(args)
	LogInfo("ZhenfaChooseDlg handle activate clicked")
	local manager = FormationManager.getInstance()
	local level = manager.m_lFormaitonList[self.m_iCurSelect].level
	local record = knight.gsp.team.GetCZhenFaupgradeTableInstance():getRecorder(level)
	if level > 0 and record.needexp == 0 then
		GetGameUIManager():AddMessageTipById(145067)	
	else
		local activate = CActiveFormation.Create()		
		activate.formation = self.m_iCurSelect
		LuaProtocolManager.getInstance():send(activate)
	end
end

function ZhenfaChooseDlg:HandleOpenClicked(args)
	LogInfo("ZhenfaChooseDlg handle open clicked")
	local manager = FormationManager.getInstance()
	local myFormation = manager.m_iMyFormation
	local request = CRequestSetFormation.Create()
	if myFormation ~= self.m_iCurSelect then
		request.formation = self.m_iCurSelect
	end
	LuaProtocolManager.getInstance():send(request)
end

function ZhenfaChooseDlg:Run(delta)
	local isstop = true
	for i = 0 , 4 do
		if not self.m_FormationElementCell[i].bstop then
			isstop = false
		end
		self.m_FormationElementCell[i]:Run(delta)
	end
	if not isstop then
		isstop = true
		for i = 0, 4 do
			if not self.m_FormationElementCell[i].bstop then
				isstop = false
			end
		end
		if isstop then
			GetGameUIManager():AddUIEffect(self.m_pEffectWnd, MHSD_UTILS.get_effectpath(10030))
		end
	end
end

function ZhenfaChooseDlg:refreshLeftFormationInfo()
	LogInfo("ZhenfaChooseDlg refresh left formation info")
	local manager = FormationManager.getInstance()
	for i = 1, 10 do
		if manager.m_lFormaitonList[i].level == 0 then
			self.m_pFormationInfo[i]:setProperty("BorderColour", "FF1B1B1C")
			self.m_pFormationInfo[i]:setProperty("TextColours", "tl:FFFFFFFF tr:FFFFFFFF bl:FF9D9D9D br:FF9D9D9D")
			self.m_pFormationInfo[i]:setText(MHSD_UTILS.get_resstring(2811))
			self.m_pFormationName[i]:setProperty("BorderColour", "FF1B1B1C")
			self.m_pFormationName[i]:setProperty("TextColours", "tl:FFFFFFFF tr:FFFFFFFF bl:FF9D9D9D br:FF9D9D9D")
		else
			self.m_pFormationInfo[i]:setProperty("BorderColour", "FF075F00")
			self.m_pFormationInfo[i]:setProperty("TextColours", "tl:FF80FD98 tr:FF80FD98 bl:FF47FF15 br:FF47FF15")
			self.m_pFormationInfo[i]:setText(MHSD_UTILS.get_resstring(2811 + manager.m_lFormaitonList[i].level))
			self.m_pFormationName[i]:setProperty("BorderColour", "FF5F4100")
			self.m_pFormationName[i]:setProperty("TextColours", "tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751")
		end

		if self.m_iCurSelect == i then
			self.m_pFormationLight[i]:setVisible(true)
		else
			self.m_pFormationLight[i]:setVisible(false)
		end
	end
	local openID = manager.m_iMyFormation
	if openID == 0 then
		self.m_pMark:setVisible(false)
	else
		self.m_pMark:setVisible(true)
		self.m_pMark:setPosition(self.m_pFormationWnd[openID]:getPosition())
	end

	self.m_pCenterPic:setProperty("Image", "set:MainControl20 image:ZhenFa" .. tostring(self.m_iCurSelect))

end

function ZhenfaChooseDlg:refreshRightFormationInfo()
	LogInfo("ZhenfaChooseDlg refresh right formation info")
	
	local manager = FormationManager.getInstance()
	local level = manager.m_lFormaitonList[self.m_iCurSelect].level
	local myFormation = manager.m_iMyFormation	

	if myFormation == self.m_iCurSelect then
		self.m_pOpenBtn:setText(MHSD_UTILS.get_resstring(2837))
	else
		self.m_pOpenBtn:setText(MHSD_UTILS.get_resstring(2836))
	end

	local formationConfig = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(self.m_iCurSelect)
	local strbuilder = StringBuilder:new()	
	strbuilder:Set("parameter1", formationConfig.name)
	if level == 0 then
		strbuilder:SetNum("parameter2", 1)
		self.m_pOpenBtn:setEnabled(false)
	else
		self.m_pOpenBtn:setEnabled(true)
		strbuilder:SetNum("parameter2", level)
	end
	self.m_pRightFormationName:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2838)))
	strbuilder:delete()

	local ids = std.vector_int_()
	knight.gsp.team.GetCZhenFaeffectTableInstance():getAllID(ids)
	local num = ids:size()
	for i = 0, num - 1 do
		local record = knight.gsp.team.GetCZhenFaeffectTableInstance():getRecorder(ids[i])
		if record.zhenfaid == self.m_iCurSelect and (record.zhenfaLv == level or (record.zhenfaLv == 1 and level == 0)) then
			for i = 0, 4 do
				self.m_pFormationEffect[i]:Clear()
				self.m_pFormationEffect[i]:AppendParseText(CEGUI.String(record.describe[i]))
				self.m_pFormationEffect[i]:Refresh()
			end
		end
	end	

	self.m_pFormationType:setText(MHSD_UTILS.get_resstring(2846 + formationConfig.type))

end

function ZhenfaChooseDlg:refreshDownFormationInfo()
	LogInfo("ZhenfaChooseDlg refresh down formation info")
	local manager = FormationManager.getInstance()
	local level = manager.m_lFormaitonList[self.m_iCurSelect].level
	local activetimes = manager.m_lFormaitonList[self.m_iCurSelect].activetimes

	if level == 0 then
		self.m_pActivateBar:setText("0/1")
		self.m_pActivateBar:setProgress(0)
	else
		local record = knight.gsp.team.GetCZhenFaupgradeTableInstance():getRecorder(level)
		if record.needexp == 0 then
			self.m_pActivateBtn:setEnabled(false)
			self.m_pActivateBar:setText(MHSD_UTILS.get_resstring(2835))
			self.m_pActivateBar:setProgress(1)
		else
			self.m_pActivateBar:setText(tostring(activetimes) .. "/" .. tostring(record.needexp))
			self.m_pActivateBar:setProgress(activetimes / record.needexp)
		end
	end

	local formationConfig = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(self.m_iCurSelect)
	local canLevelUp = true
	for i = 0, 4 do
		local element = formationConfig.elements[i]
		self.m_FormationElementCell[i]:SetTargetDegree(element)
		self.m_FormationElementCell[i]:refreshElementImage()
		if GetRoleItemManager():GetItemNumByBaseID(element) == 0 then
			canLevelUp = false
			self.m_pNeedElement[i]:setText(MHSD_UTILS.get_resstring(2820 + element - 36096))
    		self.m_pNeedElement[i]:setProperty("TextColours", "FFFF3333")
			self.m_pElementNum[i]:setText(tostring(0))
    		self.m_pElementNum[i]:setProperty("TextColours", "FFFF3333")
		else
			self.m_pNeedElement[i]:setText(MHSD_UTILS.get_resstring(2820 + element - 36096))
    		self.m_pNeedElement[i]:setProperty("TextColours", "FF33FF33")
			self.m_pElementNum[i]:setText(tostring(GetRoleItemManager():GetItemNumByBaseID(element)))
    		self.m_pElementNum[i]:setProperty("TextColours", "FF33FF33")
		end
	end
	if not canLevelUp then
		self.m_pActivateBtn:setEnabled(false)
	else
		self.m_pActivateBtn:setEnabled(true)
	end
end

function ZhenfaChooseDlg:updateFormations()
	LogInfo("ZhenfaChooseDlg update formations")
	local manager = FormationManager.getInstance() 
	if manager.m_iLevelChange then
		GetGameUIManager():AddUIEffect(self.m_pEffectWnd, MHSD_UTILS.get_effectpath(10029), false)
	end
	self:setFormationSelect(self.m_iCurSelect)
end


return ZhenfaChooseDlg
