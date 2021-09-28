require "ui.dialog"
LoginRewardCell = {}
setmetatable(LoginRewardCell, Dialog)
LoginRewardCell.__index = LoginRewardCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginRewardCell.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LoginRewardCell:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginRewardCell.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginRewardCell:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginRewardCell.getInstanceNotCreate()
    return _instance
end

function LoginRewardCell.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function LoginRewardCell.ToggleOpenClose()
	if not _instance then 
		_instance = LoginRewardCell:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


function LoginRewardCell.CreateNewDlg(pParentDlg, id)
	local newDlg = LoginRewardCell:new()
	newDlg:OnCreate(pParentDlg, id)
    return newDlg
end



function LoginRewardCell.GetLayoutFileName()
    return "loginrewardscell.layout"
end



function LoginRewardCell:OnCreate(pParentDlg, id)
    Dialog.OnCreate(self,pParentDlg, id)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.item1 = CEGUI.toItemCell(winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/item"))
	self.item2 = CEGUI.toItemCell(winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/item1"))
	self.item3 = CEGUI.toItemCell(winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/item2"))


	self.cell2 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell1")
	self.cell3 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell2")
	self.cellnpc = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/npcback")

	
	self.item1:SetBackGroundEnable(true)
	self.item2:SetBackGroundEnable(true)
	self.item3:SetBackGroundEnable(true)


	self.name1 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/shuoming")
	self.name2 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/shuoming1")
	self.name3 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/shuoming2")

	self.num1 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/num")
	self.num2 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/num1")
	self.num3 = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/cell/num2")


	self.npchead = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/npcback/head")

	self.side = winMgr:getWindow(tostring(id) .. "loginrewardscell/xuanzhzhong")
	self.side:setVisible(false)

	self.ok = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/lingqu/xuankuang"))
	self.ok:subscribeEvent("Clicked",LoginRewardCell.HandleClicked,self)	
	self.ok:setEnabled(false)
	self.chibang = winMgr:getWindow(tostring(id) .. "loginrewardscell/kuang/lingqu")
	self.chibang:setVisible(false)




end

------------------- private: -----------------------------------
function LoginRewardCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginRewardCell)
    return self
end
LoginRewardCell.clickedBtn = nil
function LoginRewardCell:HandleClicked(args)
	local p = require "protocoldef.knight.gsp.item.creqpresentnew":new()
	p.presenttype = 1
	p.presentid = CEGUI.toWindowEventArgs(args).window:getID()
	require "manager.luaprotocolmanager":send(p)
	LoginRewardCell.clickedBtn = self.ok
end
function LoginRewardCell.DisableOKButton()
	LoginRewardCell.clickedBtn:setEnabled(false) 
end

function LoginRewardCell:ItemMode(args,award,id)
	if award == 0 then
		self.chibang:setVisible(true)
		self.ok:setEnabled(true) 
	end
	
	self.ok:setID(id)	
	
	if args.item1id > 0 then
		local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(args.item1id)
		self.name1:setText(item.name)
		self.num1:setText(args.item1num)
		self:AddTip(self.item1,item,args.item1num)
	end

	if args.item3num == 0 then
		self.cellnpc:setVisible(true)
		self.cell2:setVisible(false) 
		self.cell3:setVisible(false)
		if args.xiakeid > 0 then
			local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(args.xiakeid)
			local iconpath = GetIconManager():GetImagePathByID(xkxx.headpic)
            	self.npchead:setProperty("Image",iconpath:c_str())
		end
	elseif args.item3id > 0 then
		self.cellnpc:setVisible(false)
		self.cell2:setVisible(true) 
		self.cell3:setVisible(true) 
		if args.item2id > 0 then
			local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(args.item2id)
			self.name2:setText(item.name)
			self.num2:setText(args.item2num)
			self:AddTip(self.item2 , item , args.item2num)
		end
		local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(args.item3id)
		self.name3:setText(item.name)
		self.num3:setText(args.item3num)
		self:AddTip(self.item3 , item , args.item3num)
	end
end

function LoginRewardCell:AddTip(itemcell,item,num)
	itemcell:SetImage(GetIconManager():GetImageByID(item.icon))
	itemcell:setID(item.id)
	itemcell:SetTextUnit(num)
	itemcell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
end






























return LoginRewardCell
