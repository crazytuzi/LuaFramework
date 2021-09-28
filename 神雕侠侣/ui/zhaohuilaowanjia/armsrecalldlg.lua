require "ui.dialog"
ArmsreCallDlg = {}
setmetatable(ArmsreCallDlg, Dialog)
ArmsreCallDlg.__index = ArmsreCallDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ArmsreCallDlg.getInstance()
    if not _instance then
        _instance = ArmsreCallDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end
 
function ArmsreCallDlg.getInstanceAndShow()
    if not _instance then
        _instance = ArmsreCallDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ArmsreCallDlg.getInstanceNotCreate()
    return _instance
end

function ArmsreCallDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function ArmsreCallDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ArmsreCallDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function ArmsreCallDlg.GetLayoutFileName()
    return "armsrecall.layout"
end
function ArmsreCallDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.cell = {}
	self.curprog = {}
	self.prog = {}
	self.button = {}
	self.rewardimage = {}
	for i = 1 , 4 do
		self.cell[i] = 	CEGUI.toItemCell(winMgr:getWindow("armsrecall/right/back" .. (i - 1) .. "/cell"))
		self.curprog[i] = winMgr:getWindow("armsrecall/right/back" .. (i - 1) .. "/text1")
		self.prog[i] = winMgr:getWindow("armsrecall/right/back" .. (i - 1) .. "/text3")
		self.button[i] = CEGUI.Window.toPushButton(winMgr:getWindow("armsrecall/right/back" .. (i - 1) .. "/button"))
		self.button[i]:subscribeEvent("Clicked",ArmsreCallDlg.HandleClicked,self)
		self.button[i]:setID(i)
		self.rewardimage[i] = winMgr:getWindow("armsrecall/right/back" .. (i - 1) .. "/yilingqu")
 
	end
	self.list = CEGUI.Window.toMultiColumnList(winMgr:getWindow("armsrecall/PersonalInfo/list"))
	self.prog[1]:setText(1) 
	self.prog[2]:setText(3)  
	self.prog[3]:setText(5)  
	self.prog[4]:setText(10)  
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(39839)
	self:AddTip(self.cell[1],item)

	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(39840)
	self:AddTip(self.cell[2],item)


	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(39841)
	self:AddTip(self.cell[3],item)


	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(39842)
	self:AddTip(self.cell[4],item)




end

------------------- private: -----------------------------------
function ArmsreCallDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ArmsreCallDlg)
    return self
end
function ArmsreCallDlg:HandleClicked(args)
	id = CEGUI.toWindowEventArgs(args).window:getID()
	local p = require("protocoldef.knight.gsp.activity.veteran.cinvitationaward"):new()
	p.sn = id
	require("manager.luaprotocolmanager"):send(p)
end

function ArmsreCallDlg:respond(args)
	if args then
		self.button[args]:setEnabled(false)
		self.rewardimage[args]:setVisible(true) 
	end
end


function ArmsreCallDlg.AddRow(mainWindow,data,rowid)
	mainWindow:addRow(rowid)
	local pItem0 = CEGUI.createListboxTextItem(rowid+1)
	pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
	pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
	mainWindow:setItem(pItem0, 0, rowid)


	if data.rolename then
		local pItem1 = CEGUI.createListboxTextItem(data.rolename)
		pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem1, 1, rowid)
	end
	if data.level then
		local pItem2 = CEGUI.createListboxTextItem(data.level)
		pItem2:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
		pItem2:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
		mainWindow:setItem(pItem2, 2, rowid)
	end


end


function ArmsreCallDlg:process(invitations,invitationsawards)
	local len = 0
	if invitations and  #invitations >= 1 then
		for i = 1 , #invitations do
			self.AddRow(self.list,invitations[i],i-1)
		end
		len = #invitations 
	end

	for i = 1 , #invitationsawards do
		self:setCurrent(i,len)
		self.button[i]:setEnabled(false)
		self.rewardimage[i]:setVisible(false) 
		local max = tonumber(self.prog[i]:getText())
		if len >= max then
			if invitationsawards[i] == 0 then
				self.button[i]:setEnabled(true)
			elseif invitationsawards[i] == 1 then 
				self.rewardimage[i]:setVisible(true) 
			end
		end
	end
 



end
function ArmsreCallDlg:setCurrent(index,current)
	local max = tonumber(self.prog[index]:getText())
	self.curprog[index]:setText(current < max and current or max)
end

function ArmsreCallDlg:AddTip(itemcell,item,num)
	itemcell:SetImage(GetIconManager():GetImageByID(item.icon))
itemcell:setID(item.id)
--	itemcell:SetTextUnit(num)
itemcell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
end


return ArmsreCallDlg
