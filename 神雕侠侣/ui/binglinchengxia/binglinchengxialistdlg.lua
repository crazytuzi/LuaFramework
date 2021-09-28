require "ui.dialog"
BingLinChengXiaListDlg = {}
setmetatable(BingLinChengXiaListDlg, Dialog)
BingLinChengXiaListDlg.__index = BingLinChengXiaListDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BingLinChengXiaListDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = BingLinChengXiaListDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BingLinChengXiaListDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = BingLinChengXiaListDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BingLinChengXiaListDlg.getInstanceNotCreate()
    return _instance
end

function BingLinChengXiaListDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function BingLinChengXiaListDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BingLinChengXiaListDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function BingLinChengXiaListDlg.GetLayoutFileName()
    return "binglinchengxialist.layout"
end
function BingLinChengXiaListDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.hurt = winMgr:getWindow("binglinchengxialist/text2")
	self.myrank = winMgr:getWindow("binglinchengxialist/text0")
	self.rankReward = CEGUI.Window.toPushButton(winMgr:getWindow("binglinchengxialist/button1"))
	self.hurtReward = CEGUI.Window.toPushButton(winMgr:getWindow("binglinchengxialist/button0"))
	self.main = CEGUI.Window.toMultiColumnList(winMgr:getWindow("binglinchengxialist/PersonalInfo/list"))

	self.rankReward:subscribeEvent("Clicked",BingLinChengXiaListDlg.HandleClicked,self) 
	self.hurtReward:subscribeEvent("Clicked",BingLinChengXiaListDlg.HandleClicked,self) 
	self.main:subscribeEvent("SelectionChanged", self.HandleListMemberSelected, self)

	self.rankReward:setID(1)
	self.hurtReward:setID(2)

end

------------------- private: -----------------------------------
function BingLinChengXiaListDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BingLinChengXiaListDlg)
    return self
end
function BingLinChengXiaListDlg:HandleClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if not id then
		return
	end

	local p = require("protocoldef.knight.gsp.binglinchengxia.cgetprize"):new()
	p.prizetype = id
	require("manager.luaprotocolmanager"):send(p)
end

function BingLinChengXiaListDlg.AddRow(mainWindow,data,rowid)
--print("data.fightpower",data.fightpower,mainWindow:getListHeader():getSegmentFromColumn(2):setText("record"))
	mainWindow:addRow(rowid)
	
	if data.rank then
		local pItem0 = CEGUI.createListboxTextItem(data.rank)
		pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem0, 0, rowid)
		pItem0:setID(rowid)

	end

	if data.rolename then
		local pItem1 = CEGUI.createListboxTextItem(data.rolename)
		pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem1, 1, rowid)
		pItem1:setID(rowid)

	end

	if data.damage then
		local pItem2 = CEGUI.createListboxTextItem(data.damage)
		pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem2, 2, rowid)
		pItem2:setID(rowid)
	end
end

function BingLinChengXiaListDlg:process(damagerank,mydamage,myrank,iscangetdamageprize,iscangetrankprize)
	if #damagerank > 0 then
		local func = function (a,b) return a.rank < b.rank end
		table.sort(damagerank,func)
	end

	if damagerank and #damagerank > 0 and not self.isSetList then
		self.isSetList = 1
		for i = 1 , #damagerank do
			self.AddRow(self.main,damagerank[i],i-1)
			if GetDataManager():GetMainCharacterID() == damagerank[i].roleid then
				local strbuilder = StringBuilder:new()	
				strbuilder:Set("parameter1", damagerank[i].rank)
				self.myrank:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2899)))
				strbuilder:delete()
			end
		end
	end
	self.hurt:setText(mydamage)
	self.rankReward:setEnabled( iscangetrankprize == 1 )
	self.hurtReward:setEnabled( iscangetdamageprize  == 1 )

end

function BingLinChengXiaListDlg:HandleListMemberSelected(args)
	local rowItem = self.main:getFirstSelectedItem()
	if rowItem == nil then
		return true
	end
	local rowId = rowItem:getID()
	rowId = rowId + 1
	local cfg = require("utils.mhsdutils").getLuaBean("knight.gsp.game.cbinlinrankaward",rowId)

	local guiSystem = CEGUI.System:getSingleton()
	local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
	if cfg and  cfg.preview > 0 then
		local pt = CEGUI.toWindowEventArgs(args).window:GetScreenPos()
		CToolTipsDlg:GetSingletonDialog():RefreshItemTipsByBaseID(cfg.preview, mousePos.x  ,mousePos.y, false, 0, true)
	end
end
return BingLinChengXiaListDlg
