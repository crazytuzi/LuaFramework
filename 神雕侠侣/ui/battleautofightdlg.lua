require "ui.dialog"
require "utils.mhsdutils"
BattleAutoFightDlg = {}
setmetatable(BattleAutoFightDlg, Dialog)
BattleAutoFightDlg.__index = BattleAutoFightDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BattleAutoFightDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = BattleAutoFightDlg:new()
        _instance:OnCreate()
    end
    return _instance
end
function BattleAutoFightDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = BattleAutoFightDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BattleAutoFightDlg.getInstanceNotCreate()
    return _instance
end

function BattleAutoFightDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end
function BattleAutoFightDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattleAutoFightDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function BattleAutoFightDlg.GetLayoutFileName()
    return "BattleAuto.layout"
end
function BattleAutoFightDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAuto/Cancel"))	
    self.m_pButton:subscribeEvent("Clicked", BattleAutoFightDlg.HandleAutoFigntClicked, self) 
	self:SetAutoFight(GetBattleManager():IsAutoOperate())
end

------------------- private: -----------------------------------
function BattleAutoFightDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattleAutoFightDlg)
	self.m_bEscClose = false
	self.pNormalBegin = "set:MainControl image:BattleAutoNormal"
	self.pPushedBegin = "set:MainControl image:BattleAutoPushed"
	self.pNormalStop = "set:MainControl image:BattleAutostop"
	self.pPushedStop = "set:MainControl image:BattleAutostopPushed"
    return self
end
function BattleAutoFightDlg:HandleAutoFigntClicked(args)
	if GetBattleManager():IsAutoOperate() then
        GetBattleManager():EndAutoOperate()
	else
----策划 GetBattleManager()->BeginAutoOperate()
    end
	self:SetAutoFight(GetBattleManager():IsAutoOperate())
    return true
end 

function BattleAutoFightDlg:SetAutoFight(bAutofight)
	if bAutofight then
		self:SetVisible(true)
		self.m_pButton:setProperty("NormalImage",self.pNormalStop)
		self.m_pButton:setProperty("PushedImage",self.pPushedStop)
		if CCharacterOperateDlg:GetSingleton() then
			CCharacterOperateDlg:GetSingleton():getCancelBtn():setProperty("NormalImage",pNormalStop)
			CCharacterOperateDlg:GetSingleton():getCancelBtn():setProperty("PushedImage",pPushedStop)
		end
	else
		self:SetVisible(false)
		self.m_pButton:setProperty("NormalImage","")
		self.m_pButton:setProperty("PushedImage","")
		if CCharacterOperateDlg:GetSingleton() then
			CCharacterOperateDlg:GetSingleton():getCancelBtn():setProperty("NormalImage",pNormalBegin)
			CCharacterOperateDlg:GetSingleton():getCancelBtn():setProperty("PushedImage",pPushedBegin)
		end
	end
end

function BattleAutoFightDlg.CSetVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end
function BattleAutoFightDlg.CSetAutoFight(b)
	if _instance then
		_instance:SetAutoFight(b)
	end
end
return BattleAutoFightDlg
