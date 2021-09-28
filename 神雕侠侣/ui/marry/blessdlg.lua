require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

BlessDialog = {}
setmetatable(BlessDialog, Dialog)
BlessDialog.__index = BlessDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BlessDialog.getInstance()
	LogInfo("enter get BlessDialog instance")
    if not _instance then
        _instance = BlessDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BlessDialog.getInstanceAndShow()
	LogInfo("enter BlessDialog instance show")
    if not _instance then
        _instance = BlessDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set BlessDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BlessDialog.getInstanceNotCreate()
    return _instance
end

function BlessDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy BlessDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function BlessDialog.GetLayoutFileName()
    return "bless.layout"
end

function BlessDialog:OnCreate()
	LogInfo("BlessDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --richEdit
    self.m_richEdit =  CEGUI.Window.toRichEditbox(winMgr:getWindow("bless/txt1"))
    self.m_richEdit:setMaxTextLength(50)
    self.m_txt1 =  winMgr:getWindow("bless/yinliang/txt")
    self.m_txt2 =  winMgr:getWindow("bless/yinliang/txt2")

    local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cblessing")

    self.m_txt1:setText(tostring(config:getRecorder(1).needyinliang or "50000"))
    self.m_txt2:setText(tostring(config:getRecorder(2).needyuanbao or "50"))

    --button
    self.m_commonBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bless/common"))
    self.m_goldBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bless/gold"))

    self.m_commonBtn:subscribeEvent("Clicked", BlessDialog.HandleCommonClicked, self)
    self.m_goldBtn:subscribeEvent("Clicked", BlessDialog.HandleGoldClicked, self)

	LogInfo("BlessDialog oncreate end")
end

------------------- private: -----------------------------------
function BlessDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BlessDialog)
    return self
end

function BlessDialog:HandleCommonClicked(args)
    LogInfo("BlessDialog HandleCommonClicked clicked.")
    require "protocoldef.knight.gsp.marry.cweddingbless"
    local text = self.m_richEdit:GetPureText()
    local p = CWeddingBless.Create()
    p.flag = 1
    p.content = text
    require "manager.luaprotocolmanager":send(p)
end

function BlessDialog:HandleGoldClicked(args)
    LogInfo("BlessDialog HandleGoldClicked clicked.")
    require "protocoldef.knight.gsp.marry.cweddingbless"
    local text = self.m_richEdit:GetPureText()
    local p = CWeddingBless.Create()
    p.flag = 2
    p.content = text
    require "manager.luaprotocolmanager":send(p)
end

return BlessDialog
