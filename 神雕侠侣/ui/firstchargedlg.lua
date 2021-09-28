require "ui.dialog"
require "ui.chargedialog"

FirstChargeDlg = {}
setmetatable(FirstChargeDlg, Dialog)
FirstChargeDlg.__index = FirstChargeDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FirstChargeDlg.getInstance()
	LogInfo("FirstChargeDlg getinstance")
    if not _instance then
        _instance = FirstChargeDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FirstChargeDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = FirstChargeDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FirstChargeDlg.getInstanceNotCreate()
    return _instance
end

function FirstChargeDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function FirstChargeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FirstChargeDlg:new() 
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

function FirstChargeDlg.GetLayoutFileName()
    return "addcashmore.layout"
end

function FirstChargeDlg:OnCreate()
	LogInfo("enter FirstChargeDlg oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_ChargeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashmore/go"))

	self.m_Cells = {}
	self.m_Names = {}
	for i = 0,4 do
		table.insert(self.m_Cells, CEGUI.Window.toItemCell(winMgr:getWindow("addcashmore/item" .. i)))
		table.insert(self.m_Names, winMgr:getWindow("addcashmore/name" .. i))
	end
	

    -- subscribe event
	self.m_ChargeBtn:subscribeEvent("Clicked", FirstChargeDlg.HandleChargeBtnClick, self) 

    --init settings
	self:InitItemsInfo()
end

function FirstChargeDlg:InitByState(state)
	LogInfo("first charge dlg init state: " .. state)
	self.m_ChargeState = state
	if state == 1 then
		self.m_ChargeBtn:setText(MHSD_UTILS.get_resstring(2780))
	end
end

------------------- private: -----------------------------------


function FirstChargeDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FirstChargeDlg)

    return self
end

function FirstChargeDlg:InitItemsInfo()
	local allid = std.vector_int_:new_local()
	knight.gsp.game.GetCshouchonglibaoTableInstance():getAllID(allid)
	local index = 1
	for k = 1, allid:size() do
		local giftbean = knight.gsp.game.GetCshouchonglibaoTableInstance():getRecorder(allid[k-1])
		local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(giftbean.itemid)
		if itembean.id ~= -1 then
			self.m_Names[index]:setText(itembean.name)
			self.m_Cells[index]:SetImage(GetIconManager():GetImageByID(itembean.icon))
			self.m_Cells[index]:SetTextUnit(tostring(giftbean.itemnum))
			self.m_Cells[index]:setID(itembean.id)
			self.m_Cells[index]:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable) 

			index = index + 1
		end
	end
end

function FirstChargeDlg:HandleChargeBtnClick(args)
	LogInfo("first charge dlg state: " .. self.m_ChargeState)
    if self.m_ChargeState==0 then
        ChargeDialog.GeneralReqCharge()
	end

	if self.m_ChargeState==1 then
		require "protocoldef.knight.gsp.yuanbao.creqtakeoutextragift"
		local luap = CReqTakeOutExtraGift.Create()
		LuaProtocolManager.getInstance():send(luap)
		self.m_ChargeBtn:setEnabled(false)
	end
end


return FirstChargeDlg
