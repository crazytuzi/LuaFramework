require "ui.dialog"
CharacterReturninSetDlg = {}
setmetatable(CharacterReturninSetDlg, Dialog)
CharacterReturninSetDlg.__index = CharacterReturninSetDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CharacterReturninSetDlg.getInstance()
    if not _instance then
        _instance = CharacterReturninSetDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CharacterReturninSetDlg.getInstanceAndShow()
    if not _instance then
        _instance = CharacterReturninSetDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CharacterReturninSetDlg.getInstanceNotCreate()
    return _instance
end

function CharacterReturninSetDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function CharacterReturninSetDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CharacterReturninSetDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function CharacterReturninSetDlg.GetLayoutFileName()
    return "characterreturninset.layout"
end
function CharacterReturninSetDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.desc = winMgr:getWindow("characterreturninset/txt")
	self.button = CEGUI.Window.toPushButton(winMgr:getWindow("characterreturninset/ok"))
	self.rewardbutton = CEGUI.Window.toPushButton(winMgr:getWindow("characterreturninset/buttonno"))
	self.friendname = CEGUI.Window.toEditbox(winMgr:getWindow("characterreturninset/inset"))
	self.itemcell = {}
	self.itemname = {}
	for i = 0 , 3 do
		self.itemcell[i] = CEGUI.toItemCell(winMgr:getWindow("characterreturninset/item" .. i))
		self.itemname[i] = winMgr:getWindow("characterreturninset/itemname" .. i)
	end

	local strBuild = StringBuilder:new()
	strBuild:Set("parameter1", GetDataManager():GetMainCharacterName())
	self.desc:setText(strBuild:GetString(MHSD_UTILS.get_resstring(3056)))	
	strBuild:delete()
	
	self.button:subscribeEvent("Clicked",CharacterReturninSetDlg.HandleClicked,self)
	self.rewardbutton:subscribeEvent("Clicked",CharacterReturninSetDlg.HandleClicked,self)
	
	self.button:setID(1)
	self.rewardbutton:setID(2)




	self.laozhanyouLiwu = 2559
	local cfglb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cactivityaward"):getRecorder(self.laozhanyouLiwu)
	local cfglx = knight.gsp.item.GetCItemTypeNameListTableInstance()
	for i = 0 , 3 do
		i = i*4
		local lbid = cfglb.firstClassAward[i]
		local lbitemid = cfglx:getRecorder(lbid).items[0]
		local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(lbitemid)
		self.itemname[i/4]:setText(item.name)
		self:AddTip(self.itemcell[i/4],item,cfglb.firstClassAward[i+1])
	end

	self.friendname:setReadOnly(true)
	self.friendname:subscribeEvent("MouseClick", CharacterReturninSetDlg.HandleEditClicked, self)

end

require "ui.numinputdlg"
function CharacterReturninSetDlg:HandleEditClicked(args)
  NumInputDlg.ToggleOpenClose()
  NumInputDlg.getInstance():setTargetWindow(self.friendname)
end

------------------- private: -----------------------------------
function CharacterReturninSetDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterReturninSetDlg)
    return self
end
function CharacterReturninSetDlg:HandleClicked(args)
	local id  = CEGUI.toWindowEventArgs(args).window:getID()
	if id == 1 then
		if  GetDataManager():GetMainCharacterLevel() < 60 then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145820).msg)
			return
		end
		if self.friendname:getText() == "" then
			return
		end

		local p = require("protocoldef.knight.gsp.activity.veteran.cveteranfillin"):new()
		p.inviter = self.friendname:getText()
		require("manager.luaprotocolmanager"):send(p)
	else
		local p = require("protocoldef.knight.gsp.activity.veteran.cveteranaward"):new()
		p.taskid = 0 
		require("manager.luaprotocolmanager"):send(p)
	end
end

function CharacterReturninSetDlg:process(args)
	self.button:setVisible(false)
	self.rewardbutton:setVisible(false)
	self.friendname:setVisible(false)
	if args == 0 then
		self.friendname:setVisible(true)
		self.button:setVisible(true)
	elseif args == 1 then
		self.rewardbutton:setVisible(true)
	elseif args == 2 then
		self.rewardbutton:setVisible(true)
		self.rewardbutton:setEnabled(false)
	end
end

function CharacterReturninSetDlg:AddTip(itemcell,item,num)
	itemcell:SetImage(GetIconManager():GetImageByID(item.icon))
	itemcell:setID(item.id)
	itemcell:SetTextUnit(num)
	itemcell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
end









return CharacterReturninSetDlg
