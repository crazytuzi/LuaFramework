local itemmanager = require "manager.itemmanager"

PetAmuletCompositeDlg = {}

setmetatable(PetAmuletCompositeDlg, Dialog);
PetAmuletCompositeDlg.__index = PetAmuletCompositeDlg;

local _instance;

local moneyMul = 200

function PetAmuletCompositeDlg.getInstance()
	if _instance == nil then
		_instance = PetAmuletCompositeDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function PetAmuletCompositeDlg.getInstanceNotCreate()
	return _instance;
end

function PetAmuletCompositeDlg.DestroyDialog()
	if _instance then
		_instance:resetList()
		_instance:OnClose();
		_instance = nil;
		LogInfo("PetAmuletCompositeDlg DestroyDialog")
	end
end

function PetAmuletCompositeDlg.getInstanceAndShow()
    if not _instance then
        _instance = PetAmuletCompositeDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetAmuletCompositeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetAmuletCompositeDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAmuletCompositeDlg.GetLayoutFileName()
	return "petskillhufuaddmain.layout";
end

function PetAmuletCompositeDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, PetAmuletCompositeDlg);

	return zf;
end

------------------------------------------------------------------------------

function PetAmuletCompositeDlg:OnCreate()
	LogInfo("PetAmuletCompositeDlg OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_panel = CEGUI.Window.toScrollablePane(winMgr:getWindow("petskillhufuaddmain/left"))
	self.m_iconLeft = CEGUI.toItemCell(winMgr:getWindow("petskillhufuaddmain/right/up/img/item2"))
	self.m_iconRight = CEGUI.toItemCell(winMgr:getWindow("petskillhufuaddmain/right/up/img/item21"))
	
	self.m_leftDetailName = winMgr:getWindow("petskillhufuaddmain/right/left/name")
	self.m_leftDetailLevel = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt1")
	self.m_leftDetailAttrName = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt3")
	self.m_leftDetailAttr = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt32")


	self.m_rightDetailName = winMgr:getWindow("petskillhufuaddmain/right/left/name1")

	self.m_rightDetailLevel = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt11")
	self.m_rightDetailLevelUp = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt111")


	self.m_rightDetailAttrName = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt31")
	self.m_rightDetailAttr = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt312")
	self.m_rightDetailAttrUp = winMgr:getWindow("petskillhufuaddmain/right/left/rtxt3111")


	self.m_progress = CEGUI.Window.toProgressBar(winMgr:getWindow("petskillhufuaddmain/right/up/bar"))
	self.m_progressText = winMgr:getWindow("petskillhufuaddmain/right/up/bar/txt")

	self.m_costMoney = winMgr:getWindow("petskillhufuaddmain/money1")
	self.m_yijianBtn = winMgr:getWindow("petskillhufuaddmain/btn")
	self.m_hechengBtn = winMgr:getWindow("petskillhufuaddmain/btn1")

	self.m_yijianBtn:subscribeEvent("MouseClick", self.HandleYiJianBtnClicked, self)
	self.m_hechengBtn:subscribeEvent("MouseClick", self.HandleHeChengBtnClicked, self)

	self.m_cells = {}
	self.m_oblations = {}
	self.m_amuletNum = 0
	self:PushAmulets(PetPropertyDlg.GetAmuletsInBag())

	LogInfo("PetAmuletCompositeDlg OnCreate finish")
end

function PetAmuletCompositeDlg:resetList()
	if self.m_panel then
		self.m_panel:cleanupNonAutoChildren()
		self.m_cells = {}
	end
end

function PetAmuletCompositeDlg:HandleYiJianBtnClicked( )
	local sb = StringBuilder.new()
	sb:Set("parameter1", self.m_mainAmuletName)

	--cost money
	for i,v in ipairs(self.m_cells) do
		v.m_selectOld = v.m_select
		v.m_select = true
	end
	self:RefreshOblation()
	for i,v in ipairs(self.m_cells) do
		v.m_select = v.m_selectOld
		v.m_selectOld = nil
	end
	sb:Set("parameter2", tostring(self.m_oblations.exp * moneyMul))
	self:RefreshOblation()

	GetMessageManager():AddConfirmBox(eConfirmNormal,sb:GetString(MHSD_UTILS.get_msgtipstring(146103))
		,self.EatAll,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)

end

function PetAmuletCompositeDlg:EatAll()
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	self.m_oblations = {}
	for i = 1, self.m_amuletNum do
		self.m_oblations[i] = self.m_cells[i]
	end
	self:HandleHeChengBtnClicked()
end

function PetAmuletCompositeDlg:HandleHeChengBtnClicked()
	for i,v in ipairs(self.m_oblations) do
		if v.diaowenid and v.diaowenid ~= 0 then
			GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(146102)
				,self.ConfirmCallback,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
			return
		end
	end
	self:SendCombineProtocol(self.m_oblations)
end

function PetAmuletCompositeDlg:ConfirmCallback()
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	self:SendCombineProtocol(self.m_oblations)
end

function PetAmuletCompositeDlg:SendCombineProtocol( list )
	if not list[1] then return end
	local p = require "protocoldef.knight.gsp.pet.cpetamuletcombine" : new()
    p.petkey = self.m_petkey
    p.gridkey = self.m_cellid
    p.assistkeys = {}
    for i,v in ipairs(list) do
    	p.assistkeys[i] = v.m_itemkey
    end

    require "manager.luaprotocolmanager":send(p)

end

function PetAmuletCompositeDlg:PushAmulets( list )
	self.m_amuletNum = #list
	for i = #self.m_cells + 1, #list do
		local cell = PetAmuletCell.CreateNewDlg(self.m_panel, i + 1000)
		self.m_cells[i] = cell
		cell.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0,cell.pWnd:getPixelSize().height * (i - 1) + 1)))
		cell.m_back:subscribeEvent("MouseClick", self.HandleCellClicked, self)
		cell.m_itemcell:subscribeEvent("MouseClick", self.HandleCellClicked, self)
		cell.m_back:setID(i)
		cell.m_itemcell:setID(i)
	end
	for i,v in ipairs(self.m_cells) do
		v:SetVisible(false)
	end
	for i,v in ipairs(list) do
		self.m_cells[i]:SetVisible(true)
		self.m_cells[i]:SetData(v.petamuletid, v.itemkey)
		self.m_cells[i].curexp = v.curexp
		self.m_cells[i].diaowenid = v.diaowenid
		self.m_cells[i]:UnSelect()
	end
end

function PetAmuletCompositeDlg:HandleCellClicked( args )
	local e = CEGUI.toWindowEventArgs(args)
	local cellid = e.window:getID()
	self.m_cells[cellid]:ToggleSelectState()
	self:RefreshOblation()
end

function PetAmuletCompositeDlg:RefreshOblation()
	self.m_oblations = {}
	self.m_oblations.exp = 0
	for i = 1, self.m_amuletNum do
		local cell = self.m_cells[i]
		if cell.m_select then
			local pobj = itemmanager.getObject(knight.gsp.item.BagTypes.BAG, cell.m_itemkey)
			table.insert(self.m_oblations, cell)
			local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(cell.m_amuletid)
			self.m_oblations.exp = self.m_oblations.exp + (pobj and pobj.curexp or 0) + record.provideexp
		end
	end
	if #self.m_oblations > 0 then --show right icon
		local amuletid = self.m_oblations[1].m_amuletid
		if #self.m_oblations > 1 then
			amuletid = 32567
		end
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(amuletid)
		local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(amuletid)
		self.m_iconRight:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
		self.m_iconRight:SetTextUnitText(CEGUI.String(tostring(#self.m_oblations)))
	else --empty right icon
		self.m_iconRight:SetImage(nil)
		self.m_iconRight:SetTextUnitText(CEGUI.String(""))
	end

	--show upgrade data
	

	local record = self:GetAmuletRecord(self.amuletid)
	local attrOld = record.description
	-- up level
	local upLevel = 0
	local exp = self.m_oblations.exp + self.m_curexp
	while record.needexp <= exp do
		if record.nextamulet ~= 0 then
			upLevel = upLevel + 1
			exp = exp - record.needexp
			record = self:GetAmuletRecord(record.nextamulet)
		else
			break
		end
	end

	self.m_rightDetailName:setText(record.amuletname)
	self.m_rightDetailLevelUp:setText("+"..tostring(upLevel))
	self.m_progress:setProgress(exp / record.needexp)
	self.m_progressText:setText(tostring(exp).."/"..tostring(record.needexp))
	self.m_rightDetailAttrUp:setText("+"..tostring(record.description - attrOld))
	self.m_costMoney:setText(tostring((self.m_oblations.exp) * moneyMul))
end

function PetAmuletCompositeDlg:GetAmuletRecord( id )
	return BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(id)
end

function PetAmuletCompositeDlg:PlaySuccessEffect()
	GetGameUIManager():AddUIEffect(self.m_iconLeft, MHSD_UTILS.get_effectpath(10384), false)
end

function PetAmuletCompositeDlg:OnMainAmuletChanged( mainAmulet )
	self:SetMainAmulet(mainAmulet.petamuletid, self.m_cellid, self.m_petkey, self.m_diaowenid, mainAmulet.curexp )
	local amuletsInBag = PetPropertyDlg.GetAmuletsInBag()
	if #amuletsInBag < self.m_amuletNum then
		self:PlaySuccessEffect()
	end
	self:PushAmulets(amuletsInBag)
	self:RefreshOblation()
end

function PetAmuletCompositeDlg:SetMainAmulet( amuletid, cellid, petid, diaowenid, exp )
	self.amuletid = amuletid
	self.m_cellid = cellid
	self.m_curexp = exp
	self.m_petkey = petid
	self.m_diaowenid = diaowenid

	local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(amuletid)
	local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(amuletid)
	self.m_iconLeft:SetImage(GetIconManager():GetItemIconByID(itembean.icon))

	self.m_mainAmuletName = record.amuletname
	self.m_leftDetailName:setText(record.amuletname)
	self.m_leftDetailLevel:setText(tostring(record.amuletgrade))
	local attrSep = string.find(record.descrip, "+")
	self.m_leftDetailAttrName:setText(record.attributename)
	self.m_leftDetailAttr:setText(record.description)

	self.m_rightDetailName:setText(record.amuletname)
	self.m_rightDetailLevel:setText(tostring(record.amuletgrade))
	self.m_rightDetailAttrName:setText(record.attributename)
	self.m_rightDetailAttr:setText(record.description)

	self.m_rightDetailLevelUp:setText("+0")
	self.m_rightDetailAttrUp:setText("+0")

	self.m_progress:setProgress( exp / record.needexp )
	self.m_progressText:setText(tostring(exp).."/"..tostring(record.needexp))
	self.m_costMoney:setText("0")
end


return PetAmuletCompositeDlg

