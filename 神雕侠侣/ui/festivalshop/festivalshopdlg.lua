require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

FestivalShopDlg = {
	score = 0
}
setmetatable(FestivalShopDlg, Dialog)
FestivalShopDlg.__index = FestivalShopDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FestivalShopDlg.getInstance()
	print("enter get FestivalShopDlg instance")
    if not _instance then
        _instance = FestivalShopDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FestivalShopDlg.getInstanceAndShow()
	print("enter FestivalShopDlg instance show")
    if not _instance then
        _instance = FestivalShopDlg:new()
        _instance:OnCreate()
	else
		print("set FestivalShopDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FestivalShopDlg.getInstanceNotCreate()
    return _instance
end

function FestivalShopDlg.DestroyDialog()
	print("destroy FestivalShopDlg")
	if _instance then 
		print("destroy FestivalShopDlg")
		_instance:OnClose()
		_instance = nil
	end
end

function FestivalShopDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FestivalShopDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FestivalShopDlg:setVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end


----/////////////////////////////////////////------

function FestivalShopDlg.GetLayoutFileName()
    return "festivalshop.layout"
end



function FestivalShopDlg:OnCreate()
	print("FestivalShopDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.m_pTitle = winMgr:getWindow("festivalshop/sellDialog/title/name")
    self.m_pTitle:setText(MHSD_UTILS.get_resstring(3061))
    
	self.m_pTabBack = winMgr:getWindow("festivalshop/backimage")
	self.m_pNeedMoney = winMgr:getWindow("festivalshop/money")
	self.m_pMoneyIcon = winMgr:getWindow("festivalshop/sellDialog/MoneyBack/Money")
	self.m_pMoneyIcon:setProperty("Image","set:MainControl image:TotalStar")

	self.m_pNumEdit = CEGUI.Window.toEditbox(winMgr:getWindow("festivalshop/num"))


    self.m_pCurMoneyIcon = winMgr:getWindow("festivalshop/sellDialog/MoneyBack/Money1")
    self.m_pCurMoneyIcon:setProperty("Image","set:MainControl image:TotalStar")
    self.m_pCurMoneyNum = winMgr:getWindow("festivalshop/money1")
        
	self.m_pBuyBtn = CEGUI.Window.toPushButton(winMgr:getWindow("festivalshop/buyBtn"))
  	
  	self.m_pNumEdit:setText("0")
  	self.m_pNumEdit:SetOnlyNumberMode(true, 99)
  	self.m_pNumEdit:setReadOnly(true)
  	self.m_pNumEdit:setMaxTextLength(3)
    
    self.m_pItemName = winMgr:getWindow("festivalshop/sellDialog/shuoming/name")
    self.m_pItemTips = CEGUI.Window.toRichEditbox(winMgr:getWindow("festivalshop/sellDialog/shuoming/main"))
    self.m_pItemTips:setReadOnly(true);

    self.m_pBuyBtn:subscribeEvent("Clicked", FestivalShopDlg.HandleBuyClicked, self) 

    self.m_pItemTips:setTopAfterLoadFont(true)


  	self:InitItemUnit(self.m_pUnits, winMgr)
  	self:SetAllItem(e)
 
  	self:DefaultSelectUnit()


    self.m_pNumEdit:subscribeEvent("MouseClick", FestivalShopDlg.HandleEditClicked,self)	
    self.m_pNumEdit:subscribeEvent("TextChanged", FestivalShopDlg.HandleNumChange,self)

	LogInfo("FestivalShopDlg oncreate end")

end

------------------- private: -----------------------------------

function FestivalShopDlg:new()
    local self = {}
    self = Dialog:new()
    self.m_SelectItem = nil
    self.m_pUnits = {}
    self.m_iBuyNum = 0
    self.m_oldItem = nil

    setmetatable(self, FestivalShopDlg)
    -- self:OnCreate()

    return self
end

function FestivalShopDlg:InitItemUnit(units, winmgr)
	local nameprefix = "festivalshop/backimage/Item"
	for i=1, 10 do
		local item_path = nameprefix .. i
		print(item_path)
		units[i] = {}
		units[i].Item = winmgr:getWindow(item_path)
		units[i].Item:subscribeEvent("MouseClick", FestivalShopDlg.HandleItemUnitClick, self)
		units[i].Item:setID(i)
				
		units[i].Icon = CEGUI.Window.toItemCell(winmgr:getWindow(item_path .. "/Icon"))
		units[i].Icon:subscribeEvent("MouseClick", FestivalShopDlg.HandleItemUnitClick, self)

		units[i].Name = winmgr:getWindow(item_path .. "/name")
		units[i].Name:setMousePassThroughEnabled(true)

		units[i].PriceIcon = winmgr:getWindow(item_path .. "/money")
		units[i].PriceIcon:setMousePassThroughEnabled(true)

		units[i].Price = winmgr:getWindow(item_path .. "/Price")
		units[i].Price:setMousePassThroughEnabled(true)
	end
end

function FestivalShopDlg:SetAllItem(args)
	LogInfo("SetAllItem")
	local ids = std.vector_int_()
	knight.gsp.item.GetCItemduihuanTableInstance():getAllID(ids)
	local num = ids:size()
	local index = 1
	for k=1, num do
		local rd = knight.gsp.item.GetCItemduihuanTableInstance():getRecorder(ids[k-1])
		if rd.FestivalCredit > 0 then
			local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(rd.id)
			self.m_pUnits[index].Icon:SetImage(GetIconManager():GetImageByID(item.icon))
		
			self.m_pUnits[index].Icon:setID(item.id)
			print("####",rd.id, "**** ", item.id)
			self.m_pUnits[index].Name:setText(item.name)
			self.m_pUnits[index].Price:setText(tostring(rd.FestivalCredit))
			self.m_pUnits[index].PriceIcon:setProperty("Image","set:MainControl image:TotalStar")
			self.m_pUnits[index].itemPrice = rd.FestivalCredit
			index = index+1
		end
	end
end


function FestivalShopDlg:HandleNumChange()
	LogInfo("FestivalShopDlg:HandleNumChange")
	local numStr = self.m_pNumEdit:getText()
	if type(numStr) ~= "string" then 
		self.m_pNumEdit:setText("0")
		return
	else 
		self.m_pNumEdit:setCaratIndex(string.len(numStr))
		self.m_iBuyNum  = CEGUI.PropertyHelper:stringToUint(numStr)	
	end
	
	if self.m_iBuyNum > 99 then
		self.m_pNumEdit:setText("99");
	else 
		self.m_pNumEdit:setText(tostring(self.m_iBuyNum))
	end

	local score = self.m_iBuyNum * self.m_SelectItem.itemPrice
	self:HandleOneItem(score)
end


function FestivalShopDlg:HandleEditClicked(args)
	NumInputDlg.ToggleOpenClose()
	NumInputDlg.getInstance():setTargetWindow(self.m_pNumEdit)
end

function FestivalShopDlg:SetScore(score)
	self.score  = score
end

function FestivalShopDlg:RefreshScore()
	self.m_pCurMoneyNum:setText(tostring(self.score))
end

function FestivalShopDlg:HandleItemUnitClick(e)
	local MouseEventArgs = CEGUI.toMouseEventArgs(e)
	for i=1, #self.m_pUnits do 
		if MouseEventArgs.window == self.m_pUnits[i].Item or MouseEventArgs.window == self.m_pUnits[i].Icon then
			if self.m_pUnits[i].Icon:getID() ~= 0 then
				self:SetItemSelectedEx(i)
				return true
			else
				return false
			end
		end
	end
end

function FestivalShopDlg:DefaultSelectUnit()
	self.m_SelectItem = self.m_pUnits[1]
	self.m_SelectItem.Item:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	self.m_pNumEdit:setText("1");
	self:HandleOneItem(self.m_SelectItem.itemPrice)
	self:RefreshScore()
	self.m_iBuyNum = 1
	self.m_oldItem = self.m_SelectItem
	self:RefreshClickedItemInfo()
end

function FestivalShopDlg:SetItemSelectedEx(i)
	local curclicked = self.m_pUnits[i]
	if self.m_SelectItem and self.m_SelectItem ~= curclicked then
		self.m_SelectItem.Item:setProperty("Image", "set:MainControl9 image:shopcellnormal")
		self.m_oldItem = self.m_SelectItem
		self.m_SelectItem = curclicked
		self.m_SelectItem.Item:setProperty("Image", "set:MainControl9 image:shopcellchoose")		
	end

	self:RefreshClickedItemInfo()
	self:RefreshItemCostInfo()

end

function FestivalShopDlg:RefreshClickedItemInfo()
	-- body
	if self.m_SelectItem == nil then
		return
	end
	local itemId = self.m_SelectItem.Icon:getID()
	print("ICON ID: ", itemId, "TYPE: ", type(itemId))
	local itemInfo = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemId)
	self.m_pItemName:setText(itemInfo.name)
	self.m_pItemTips:Clear()
	local str = itemInfo.destribe
	if string.find(str,'<') ~= nil then
		self.m_pItemTips:AppendParseText(CEGUI.String(str))
	else
		self.m_pItemTips:AppendText(CEGUI.String(str))
	end
	self.m_pItemTips:Refresh()
	self.m_pItemTips:HandleTop()		
end

function FestivalShopDlg:RefreshItemCostInfo()
	print("FestivalShopDlg:ItemCostInfo")
	self:RefreshScore()

	if  self.m_SelectItem ~= self.m_oldItem then
		-- print(" self.m_SelectItem ~= oldItem ")
		self.m_oldItem = self.m_SelectItem
		self.m_iBuyNum = 1
		self.m_pNumEdit:setText("1")

		self:HandleOneItem(self.m_oldItem.itemPrice)
	else
		-- print(" self.m_SelectItem == oldItem ")
		local curNum = CEGUI.PropertyHelper:stringToUint(self.m_pNumEdit:getText())
		if curNum > 0 then
			curNum = curNum + 1
		else
			curNum = 1
		end	
		self.m_pNumEdit:setCaratIndex(string.len(CEGUI.PropertyHelper:uintToString(curNum)))
		self.m_iBuyNum = curNum
		if self.m_iBuyNum > 99 then
			self.m_pNumEdit:setText("99");
		else 
			self.m_pNumEdit:setText(CEGUI.PropertyHelper:uintToString(curNum))
		end

		local score = self.m_iBuyNum * self.m_SelectItem.itemPrice

		self:HandleOneItem(score)
	end
end

function FestivalShopDlg:HandleBuyClicked()
	-- body
	if self.m_SelectItem == nil then
		 return 
	end
	local buyItem = knight.gsp.item.CExchangeItem(8, self.m_SelectItem.Icon:getID(),self.m_iBuyNum)
	GetNetConnection():send(buyItem)
	self.m_pNumEdit:setText("1")
	self:HandleOneItem(self.m_SelectItem.itemPrice)
	self:RefreshScore()
end

function FestivalShopDlg:HandleOneItem(price)
	-- body
	if not price then return end
	local color = "FFFFFFFF"
	if price > self.score then
		color = "FFFF0000"
	end
	self.m_pNeedMoney:setText("[colour='" .. color .." ']" .. tostring(price))
end

return FestivalShopDlg