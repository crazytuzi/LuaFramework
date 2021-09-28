require "ui.dialog"

ConvertDlg = {}
setmetatable(ConvertDlg, Dialog)
ConvertDlg.__index = ConvertDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ConvertDlg.getInstance()
	print("enter get convertdlg dialog instance")
    if not _instance then
        _instance = ConvertDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ConvertDlg.getInstanceAndShow()
	print("enter convertdlg dialog instance show")
    if not _instance then
        _instance = ConvertDlg:new()
        _instance:OnCreate()
	else
		print("set convertdlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ConvertDlg.getInstanceNotCreate()
    return _instance
end

function ConvertDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function ConvertDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ConvertDlg:new() 
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

function ConvertDlg.GetLayoutFileName()
    return "convertdlg.layout"
end

function ConvertDlg:OnCreate()
	print("convertdlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pOKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("convertdlg/ok"))
    self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("convertdlg/cancel"))
	self.m_pEditBox = CEGUI.Window.toEditbox(winMgr:getWindow("convertdlg/editbox"))

    -- subscribe event
    self.m_pOKBtn:subscribeEvent("Clicked", ConvertDlg.HandleOKBtnClicked, self) 
    self.m_pCancelBtn:subscribeEvent("Clicked", ConvertDlg.HandleCancelBtnClicked, self) 

	-- 设置编辑框
	self.m_pEditBox:setMaxTextLength(self.MAX_LENGTH_CODE)
	self.m_pEditBox:setValidationString("[A-Za-z]*")

	print("convertdlg dialog oncreate end")
end

------------------- private: -----------------------------------


function ConvertDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ConvertDlg)

	--新手卡最长是11位长度
	self.MAX_LENGTH_CODE = 11
	--新手卡最短是4位长度
	self.MIN_LENGTH_CODE = 4
    return self
end

function ConvertDlg:HandleOKBtnClicked(args)
	print("convertdlg ok clicked")

	local code_length = string.len(self.m_pEditBox:getText())
	--如果长度不足
	if code_length < self.MIN_LENGTH_CODE then
		GetGameUIManager():AddMessageTipById(144962)
		--print("兑换码不足4位")
		return true
	end

	require "protocoldef.knight.gsp.cfreshcard"
	local card = CFreshCard.Create()
	--现在新手卡类型都是3，加上这个字段,以后扩充新类型的时候可以用的上
	card.qtype = 3
	print(self.m_pEditBox:getText())
	card.cardnumber = StringCover.StringToOctect(self.m_pEditBox:getText(), code_length)
	LuaProtocolManager.getInstance():send(card)
	ConvertDlg.DestroyDialog()
	return true
end

function ConvertDlg:HandleCancelBtnClicked(args)
	print("convertdlg cancel clicked")
	ConvertDlg.DestroyDialog()
	return true
end

return ConvertDlg
