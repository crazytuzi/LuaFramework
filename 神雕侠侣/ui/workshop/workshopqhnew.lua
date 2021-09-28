require "ui.dialog"
require "ui.workshop.workshophelper"
require "ui.workshop.workshopequipcell"
require "utils.mhsdutils"
require "utils.stringbuilder"


WorkshopQhNew = {}
setmetatable(WorkshopQhNew, Dialog)
WorkshopQhNew.__index = WorkshopQhNew
local _instance
function WorkshopQhNew.getInstance()
	print("new Workshopcxnew Instance")
	if not _instance then
		_instance = WorkshopQhNew:new()
		_instance:OnCreate()
	end
	return _instance
end

function WorkshopQhNew.getInstanceOrNot()
	return _instance
end

function WorkshopQhNew:new()
	local self = {}
	self = Dialog:new()
	self.m_LinkLabel = nil
	self.QhProgressing = false
	self.PreviewItems = {}
	self.QhItems = {}
	setmetatable(self, WorkshopQhNew)
	return self
end

function WorkshopQhNew:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.EffectWnd = winMgr:getWindow("workshopqhnew/effect")
	self.ItemPane = CEGUI.toScrollablePane(winMgr:getWindow("workshopqhnew/left"))
	self:InitAttrPages(winMgr)
	self:InitMaterial(winMgr)
	self:InitEquipItem()
	self.QhButton = CEGUI.toPushButton(winMgr:getWindow("workshopqhnew/right/ok"))
	self.QhButton:subscribeEvent("MouseClick", WorkshopQhNew.HandleQhBtnClicked, self)
	self.AllButton = CEGUI.toPushButton(winMgr:getWindow("workshopqhnew/right/all"))
	self.AllButton:subscribeEvent("MouseClick", WorkshopQhNew.HandleAllBtnClicked, self)
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopQhNew.OnItemNumChange)
	self.m_hPackMoneyChange = GetRoleItemManager().EventPackMoneyChange:InsertScriptFunctor(WorkshopQhNew.OnMoneyChange)
end

function WorkshopQhNew.OnMoneyChange()
	if not _instance then
		return
	end
	for i = 1, #_instance.QhItems do
		local curItem = _instance.QhItems[i]
		local qhitemkey = _instance.QhItems[i].Item:getID() 
		if qhitemkey ~= 0 then
			if _instance:CanItemQh(qhitemkey) then
				curItem.Mark:setVisible(true)
				if curItem.HasEffect == nil or not curItem.HasEffect then
					LogInsane("add mark effect")
					GetGameUIManager():AddUIEffect(curItem.Mark, MHSD_UTILS.get_effectpath(10375), true)
				end
				curItem.HasEffect = true
			else
				curItem.Mark:setVisible(false)
				if curItem.HasEffect then
					LogInsane("remove mark effect")
					GetGameUIManager():RemoveUIEffect(curItem.Mark)
				end
				curItem.HasEffect = false
			end
		end
	end
	_instance:UpdateMaterialColor()
end

function WorkshopQhNew:HandleAllBtnClicked(e)
	local ret, config
--[[	for i = 1, #WorkshopHelper.ItemList do
		local item_local = WorkshopHelper.ItemList[i]
		local roleItemManager = GetRoleItemManager()
		local bagtype = knight.gsp.item.BagTypes.EQUIP
		local item = roleItemManager:FindItemByBagIDAndPos(bagtype, item_local.type)
		if item then
			ret, config = self:CanItemQh(item:GetThisID())
			if ret then
				local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10176), false);
			    if pEffect then
			    	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
			       	pEffect:AddNotify(notify)
			    	self.QhProgressing = true
			    	self.QhAll = true
			    	return
			    end
			end
		end 
	end
]]
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickeditem.Item:getID(), knight.gsp.item.BagTypes.EQUIP)
	if item then
		ret, config = self:CanItemQh(item:GetThisID())
		if ret then
			local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10176), false);
			if pEffect then
				local notify = CGameUImanager:createNotify(self.OnEffectEnd)
				pEffect:AddNotify(notify)
				self.QhProgressing = true
				self.QhAll = true
				return
			end
		end
	else
		LogInsaneFormat("Unable to find item in bag")
		return true
	end 
	if config == 1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144763)
        end
	elseif config == 2 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144763)
        end
	elseif config == 3 then
        -- if GetChatManager() then
        --     GetChatManager():AddTipsMsg(144764)
        -- end
        self:showQuickBuyMoneyDlg()
	elseif config == 4 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144763)
        end
	else
		local param = std.vector_std__wstring_()
        param:push_back(tostring(config));
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144761,0,param);
        end
	end
end

function WorkshopQhNew.OnItemNumChange(bagid, itemkey, itembaseid)
	if _instance == nil then
		return
	end
	LogInsane(string.format("WorkshopQhNew.OnItemNumChange(%d, %d, %d)", bagid, itemkey, itembaseid))
	for i = 1, #_instance.QhItems do
		local curItem = _instance.QhItems[i]
		local qhitemkey = _instance.QhItems[i].Item:getID() 
		if qhitemkey ~= 0 then
			if _instance:CanItemQh(qhitemkey) then
				curItem.Mark:setVisible(true)
				if curItem.HasEffect == nil or not curItem.HasEffect then
					LogInsane("add mark effect")
					GetGameUIManager():AddUIEffect(curItem.Mark, MHSD_UTILS.get_effectpath(10375), true)
				end
				curItem.HasEffect = true
			else
				curItem.Mark:setVisible(false)
				if curItem.HasEffect then
					LogInsane("remove mark effect")
					GetGameUIManager():RemoveUIEffect(curItem.Mark)
				end
				curItem.HasEffect = false
			end
		end
	end
	_instance:UpdateMaterialColor();
end

local function toQhIntroduce(itemid, typestr, level)
	local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(itemid)
	local color = MHSD_UTILS.getColorIntrStrByID(equipConfig.equipcolor)
	return string.format("%s%s%s%s", color, typestr, level, MHSD_UTILS.get_resstring(1359))
end

function WorkshopQhNew:InitEquipItem()
	local selected = false
	for i = 1, #WorkshopHelper.ItemList do
		local newItem = Workshopequipcell.new(self.ItemPane, i - 1)
		self.QhItems[i] = newItem
		local item_local  = WorkshopHelper.ItemList[i]
		if item_local == nil then
			print("local item is nil index="..i)
		end
		local roleItemManager = GetRoleItemManager()
		local bagtype = knight.gsp.item.BagTypes.EQUIP
		local item = roleItemManager:FindItemByBagIDAndPos(bagtype, item_local.type)
		if item == nil then
			--local equipframe = winMgr:getWindow(name_prefix.."back"..n)
			--equipframe:setVisible(false) MHSD_UTILS.get_resstring(2709)
			newItem.Name:setText(MHSD_UTILS.get_resstring(2736)..MHSD_UTILS.get_resstring(item_local.empty_string))
			newItem.Level:setText("")
			newItem.Mark:setVisible(false)
			newItem.HasEffect = false
		else
			local equipObj = toEquipObject(item:GetObject())
			if equipObj then
				if item:GetObject().bNeedRequireData then
					GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
				end
			end
			local iconManager = GetIconManager()
			local attr = item:GetBaseObject()
			newItem.Name:setText(item:GetName())
			local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
			newItem.Name:setProperty("TextColours", color)
			newItem.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
			
			local equipObj = toEquipObject(item:GetObject())
			if equipObj then
				newItem.Level:setText(toQhIntroduce(
					item:GetBaseObject().id, 
					MHSD_UTILS.get_resstring(item_local.empty_string),
					attr.level))
				newItem.Level:setProperty("TextColours", color)
			else
				newItem.Level:setText("")
			end
			newItem.Item:setID(item:GetThisID())
			if not selected then
				selected = true
				if self.clickeditem then
					self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
				end
				self.clickeditem = self.QhItems[i]
				self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
				local bagid = knight.gsp.item.BagTypes.EQUIP
				self:ShowItem(item:GetThisID(), bagid)
			end
			LogInsane("Show mark effect")
			if self:CanItemQh(item:GetThisID()) then
				newItem.Mark:setVisible(true)
				if not newItem.HasEffect then
					LogInsane("add mark effect")
					GetGameUIManager():AddUIEffect(newItem.Mark, MHSD_UTILS.get_effectpath(10375), true)
				end
				newItem.HasEffect = true
			else
				newItem.Mark:setVisible(false)
				if newItem.HasEffect then
					LogInsane("remove mark effect")
					GetGameUIManager():RemoveUIEffect(newItem.Mark)
				end
				newItem.HasEffect = false
			end
		end
		newItem.Frame:subscribeEvent("MouseClick", WorkshopQhNew.HandleItemClicked,self)
		
	end
end

local function InitAttrPage(page)
	page.Name:setText("")
	page.Name:setText("")
	page.Introduce:setText("")
	for i = 1, 3 do
	--	page.BaseEffects[i].Name:setText("")
		page.BaseEffects[i].Value:setText("0")
	end
	page.Score.Value:setText("0")
end

function WorkshopQhNew:InitAttrPages(winMgr)
	------------------- about Attributes page
	self.AttrPages = {}
	self.AttrPages.CurItem = {}
	self.AttrPages.CurItem.Item = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/part1/item1"))
	self.AttrPages.CurItem.Name = winMgr:getWindow("workshopqhnew/right/part1/name1")
	self.AttrPages.CurItem.Introduce = winMgr:getWindow("workshopqhnew/right/part1/level1")
	self.AttrPages.CurItem.BaseEffects = {}
	for i = 1, 3 do
		self.AttrPages.CurItem.BaseEffects[i] = {}
		self.AttrPages.CurItem.BaseEffects[i].Name = winMgr:getWindow("workshopqhnew/right/part1/txt"..i-1)
		self.AttrPages.CurItem.BaseEffects[i].Value = winMgr:getWindow("workshopqhnew/right/part1/num"..i-1)
	end
	self.AttrPages.CurItem.Score = {}
	self.AttrPages.CurItem.Score.Name = winMgr:getWindow("workshopqhnew/right/part1/txt"..3)
	self.AttrPages.CurItem.Score.Value = winMgr:getWindow("workshopqhnew/right/part1/num"..3)
	
	self.AttrPages.PreviewItem = {}
	self.AttrPages.PreviewItem.Item = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/part2/item2"))
	self.AttrPages.PreviewItem.Name = winMgr:getWindow("workshopqhnew/right/part2/name2")
	self.AttrPages.PreviewItem.Introduce = winMgr:getWindow("workshopqhnew/right/part2/level2")
	self.AttrPages.PreviewItem.BaseEffects = {}
	for i = 1, 3 do
		self.AttrPages.PreviewItem.BaseEffects[i] = {}
		self.AttrPages.PreviewItem.BaseEffects[i].Name = winMgr:getWindow("workshopqhnew/right/part2/txt"..i-1)
		self.AttrPages.PreviewItem.BaseEffects[i].Value = winMgr:getWindow("workshopqhnew/right/part2/num"..i-1)
	end
	self.AttrPages.PreviewItem.Score = {}
	self.AttrPages.PreviewItem.Score.Name = winMgr:getWindow("workshopqhnew/right/part2/txt"..3)
	self.AttrPages.PreviewItem.Score.Value = winMgr:getWindow("workshopqhnew/right/part2/num"..3)
	InitAttrPage(self.AttrPages.CurItem)
	InitAttrPage(self.AttrPages.PreviewItem)
end

function WorkshopQhNew:InitMaterial(winMgr)
	self.Material = {}
	self.Material.Material = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/bot/item1"))
	self.Material.MaterialName = winMgr:getWindow("workshopqhnew/right/bot/name1")
	self.Material.Paper = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/bot/item2"))
	self.Material.PaperName = winMgr:getWindow("workshopqhnew/right/bot/name2")
	self.Material.Money = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/bot/item3"))
	self.Material.Money:SetImage(GetIconManager():GetItemIconByID(1262))
	self.Material.MoneyName = winMgr:getWindow("workshopqhnew/right/bot/name3")
	self.Material.MoneyName:setText(MHSD_UTILS.get_resstring(2636))
	self.Material.PaperName:setText("")
	self.Material.MaterialName:setText("")
	self.Material.Cailiao = CEGUI.toItemCell(winMgr:getWindow("workshopqhnew/right/bot/item4"))
	self.Material.CailiaoName = winMgr:getWindow("workshopqhnew/right/bot/name4")
	MHSD_UTILS.SetWindowShowtips(self.Material.Material)
	MHSD_UTILS.SetWindowShowtips(self.Material.Paper)
	MHSD_UTILS.SetWindowShowtips(self.Material.Cailiao)
end

function WorkshopQhNew:ShowItem(itemkey, bagid)
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		--print("not found item in equip")
		return true
	end
	local itemobj = require "manager.itemmanager".getObject(bagid, itemkey)
	self:ShowInPage(item:GetBaseObject(), itemobj, self.AttrPages.CurItem, false)
	local previewattr = self:getPreviewItem(itemkey)
	if previewattr then
		self:ShowInPage(previewattr, itemobj, self.AttrPages.PreviewItem, true)
	end
	------ show material
	self:UpdateMaterialColor()
end

function WorkshopQhNew:UpdateMaterialColor()
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local itemkey = self.clickeditem.Item:getID()
	if itemkey == 0 then
		return true
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		print("not found item in equip")
		return true
	end
	local config = knight.gsp.item.GetCEquipStrengthenTableInstance():getRecorder(item:GetBaseObject().id)
	if config.id == -1 then
		return
	end
	local materialattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.needitemid)
	if materialattr.id ~= -1 then
		self.Material.Material:setID(materialattr.id)
		self.Material.Material:SetImage(GetIconManager():GetItemIconByID(materialattr.icon))
		self.Material.Material:SetTextUnit(config.needitemnum)
		local materialnum = GetRoleItemManager():GetItemNumByBaseID(materialattr.id)
		if materialnum >= config.needitemnum then
			self.Material.Material:SetTextUnitColor(MHSD_UTILS.get_greencolor())
		else
			self.Material.Material:SetTextUnitColor(MHSD_UTILS.get_redcolor())
		end
		self.Material.MaterialName:setText(materialattr.name)
	end
	local paperattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.paperid)
	if paperattr.id ~= -1 then
		self.Material.Paper:setID(paperattr.id)
		self.Material.Paper:SetImage(GetIconManager():GetItemIconByID(paperattr.icon))
		self.Material.Paper:SetTextUnit(config.papernum)
		local materialnum = GetRoleItemManager():GetItemNumByBaseID(paperattr.id)
		if materialnum >= config.papernum then
			self.Material.Paper:SetTextUnitColor(MHSD_UTILS.get_greencolor())
		else
			self.Material.Paper:SetTextUnitColor(MHSD_UTILS.get_redcolor())
		end
		self.Material.PaperName:setText(paperattr.name)
	else
		self.Material.Paper:setID(0)
		self.Material.Paper:SetImage(nil)
		self.Material.Paper:SetTextUnit("")
		self.Material.PaperName:setText("")
	end
	local moneynum = GetRoleItemManager():GetPackMoney()

	local strBuild = StringBuilder:new()
	local str = nil
	local found = false
	local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getAllID()

    for k,v in pairs(ids) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(v)
		if Config.CUR_3RD_LOGIN_SUFFIX == item.platformid then
			found = true
			if config.needmoney < item.number then
				strBuild:SetNum("parameter1",config.needmoney)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
			else
				if item.number == 1000000 then	
	 				strBuild:SetNum("parameter1",  (math.floor(config.needmoney / 1e4) / 1e2))
				 else
					strBuild:SetNum("parameter1", math.ceil(config.needmoney/item.number))
				end
				strBuild:SetNum("parameter2",item.company)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
			end
			break
		end
	end

	if not found then
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(1)
		if config.needmoney < item.number then
			strBuild:SetNum("parameter1",config.needmoney)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
		else
			if item.number == 1000000 then	
 				strBuild:SetNum("parameter1",  (math.floor(config.needmoney / 1e4) / 1e2))
			 else
				strBuild:SetNum("parameter1", math.ceil(config.needmoney/item.number))
			end
			strBuild:SetNum("parameter2",item.company)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
		end
	end

	self.Material.Money:SetTextUnit(str)

	strBuild:delete()

	if moneynum >= config.needmoney then
		self.Material.Money:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.Material.Money:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
	
	if config and config.cailiaoid > 0 then
		self.Material.Cailiao:setVisible(true)
		self.Material.CailiaoName:setVisible(true)
		local cailiaoattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.cailiaoid)
			if cailiaoattr.id ~= -1 then
			self.Material.Cailiao:setID(cailiaoattr.id)
			self.Material.Cailiao:SetImage(GetIconManager():GetItemIconByID(cailiaoattr.icon))
			self.Material.Cailiao:SetTextUnit(config.cailiaoshuliang)
			local materialnum = GetRoleItemManager():GetItemNumByBaseID(cailiaoattr.id)
			if materialnum >= config.cailiaoshuliang then
				self.Material.Cailiao:SetTextUnitColor(MHSD_UTILS.get_greencolor())
			else
				self.Material.Cailiao:SetTextUnitColor(MHSD_UTILS.get_redcolor())
			end
			self.Material.CailiaoName:setText(cailiaoattr.name)
		end
	else
		self.Material.Cailiao:setVisible(false)
		self.Material.CailiaoName:setVisible(false)
	end
end


function WorkshopQhNew:HandleItemClicked(e)
--	print("clicked qh item")
	if self.QhProgressing then
		LogInsaneFormat("You are qhing")
		return false
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.QhItems do
		if self.QhItems[i].Frame == mouseArgs.window then
			if self.QhItems[i].Item:getID() == 0 then
				return false
			end
			if self.clickeditem then
				self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
			end
			self.clickeditem = self.QhItems[i]
			self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
		end
	end
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local itemkey = self.clickeditem.Item:getID()
	if itemkey == 0 then
		return true
	end
	self:ShowItem(itemkey, bagid)
	return true;
end

function WorkshopQhNew:ShowInPage(attr, equipObj, page, preview)
--	local attr = item:GetBaseObject()
	page.Name:setText(attr.name)
--	local itemcolor = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
	local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
	local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor);
	page.Name:setProperty("TextColours", colorconfig.colorvalue)
	page.Item:SetImage(GetIconManager():GetItemIconByID(attr.icon))
	local item_type = math.floor(attr.itemtypeid / 0x10)%0x10
--	print("item pos="..item_type)
	local item_local = nil
	for i = 1, #WorkshopHelper.ItemList do
		if item_type == WorkshopHelper.ItemList[i].type then
			item_local = WorkshopHelper.ItemList[i]
			break
		end
	end
	if item_local == nil then
		return
	end
--	local equipObj = toEquipObject(item:GetObject())
	if not equipObj then
		return
	end
	
	page.Introduce:setText(toQhIntroduce(
				attr.id, 
				MHSD_UTILS.get_resstring(item_local.empty_string),
				attr.level))
	page.Introduce:setProperty("TextColours", colorconfig.colorvalue)
	page.Score.Value:setText(GetLuaEquipScore(attr.id, equipObj, item_type))
	if preview then
		page.Score.Value:setProperty("TextColours", "FF33FF33")
	end
	local crystalnum = equipObj.crystalnum
--[[	if preview and crystalnum < 64 then
		crystalnum = crystalnum + 1
	end]]
	if crystalnum == 0 then
		crystalnum = 1
	end
	local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum)
	if starconfig.id == -1 then
	--	print("Unable to find star config id="..crystalnum)
		return
	end
	local j = 1
	for i=1,#item_local.BaseEffectIDs do
		if j > #page.BaseEffects then
			break
		end
		local effectid = item_local.BaseEffectIDs[i]
		local effectval = 0
		local equip = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
		for i = 0, equip.baseEffect:size() - 1 do
			if effectid == equip.baseEffectType[i] then
			 effectval=equip.baseEffect[i]
			end
		end
	--	local effectval = equipObj:GetBaseEffec(effectid)
		if effectval ~= 0 then
			page.BaseEffects[j].Name:setText(WorkshopHelper.GetAttributeName(effectid))
			local uprate = 0
			if starconfig.id ~= -1 then
				uprate = starconfig.uprate
			end
			local value
			
			if uprate > 0 then
				if preview then
					local newcolor = string.format("[colour='%x']", 0xFF33FF33)
					value = string.format("%s%s[colour='FFFFFFFF']+%d%%",newcolor, effectval, starconfig.uprate)
				else
					value = string.format("%s+%d%%",effectval, starconfig.uprate)
				end
			else
				 value = effectval
			end
			page.BaseEffects[j].Value:setText(value)
			j = j + 1
		end
	end
	
end

function WorkshopQhNew:getPreviewItem(itemkey)
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		return nil;
	end

	local config = knight.gsp.item.GetCEquipStrengthenTableInstance():getRecorder(item:GetBaseObject().id)
	--local previewItem = CRoleItem(item)
	if config.id ~= -1 then
		return knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.nextequipid)
	end
	return nil
end

function WorkshopQhNew:OnEffectEnd()
	if _instance == nil then
		return
	end
	_instance.QhProgressing = false
	if not _instance.QhAll then
		LogInsaneFormat("SendProtocol")
		if _instance.clickeditem == nil then
			LogInsaneFormat("Choose a item first")
			return
		end
		local itemkey = _instance.clickeditem.Item:getID()
		local bagid = knight.gsp.item.BagTypes.EQUIP
		GetNetConnection():send(knight.gsp.item.CQianghuaEquip(bagid, itemkey))
	else
		local p = require "protocoldef.knight.gsp.item.cqianghuaallequip":new()
		p.equipitemkey = _instance.clickeditem.Item:getID()
		require "manager.luaprotocolmanager":send(p)
	end
	
end

function WorkshopQhNew:CanItemQh(itemkey)
	local item = GetRoleItemManager():FindItemByBagAndThisID( 
		itemkey, knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		LogInsaneFormat("Unable to find item in bag")
		return false
	end
	local config = knight.gsp.item.GetCEquipStrengthenTableInstance():getRecorder(item:GetBaseObject().id)
	if config.id == -1 then
		return false
	end
	local materialnum = GetRoleItemManager():GetItemNumByBaseID(config.needitemid)
	if materialnum < config.needitemnum then
		LogInsaneFormat("Need itemid=%d", config.needitemid)
		return false, 1
	end
	local papernum = GetRoleItemManager():GetItemNumByBaseID(config.paperid)
	if papernum < config.papernum then
		LogInsaneFormat("Need paperid=%d", config.paperid)
		return false, 2
	end
	local moneynum = GetRoleItemManager():GetPackMoney()
	if moneynum < config.needmoney then
		LogInsaneFormat("Need money=%d", config.needmoney)
		return false, 3
	end
	if config.cailiaoid ~= 0 then
		local cailiaonum = GetRoleItemManager():GetItemNumByBaseID(config.cailiaoid)
		if cailiaonum < config.cailiaoshuliang then
			LogInsaneFormat("Need cailiaoid=%d", config.cailiaoid)
			return false, 4
		end
	end
	local nextattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.nextequipid);
    if nextattr.id == -1 then
        return false;
    end
    if nextattr.needLevel > GetDataManager():GetMainCharacterLevel() then
    	LogInsane("Need Level "..nextattr.needLevel)
        return false, nextattr.needLevel
    end
    return true, config
end

function WorkshopQhNew:showQuickBuyMoneyDlg()
	local itemid = 38349
	if GetChatManager() then
		GetChatManager():AddTipsMsg(146312)
    end
	local ybnum = GetDataManager():GetYuanBaoNumber()
	if ybnum >= 600 then
		itemid = 38771
	elseif ybnum >= 100 then
		itemid = 38350
	elseif ybnum < 10 then
        return false
	end
	CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
end

function WorkshopQhNew:HandleQhBtnClicked(e)
	LogInsaneFormat("clicked qh btn")
	if self.QhProgressing then
		LogInsaneFormat("You are qhing")
		return false
	end
	if self.clickeditem == nil then
		LogInsaneFormat("Choose an item plz")
		return true
	end
	LogInsaneFormat("self.clickeditem.id=%d", self.clickeditem.Item:getID())
	local item = GetRoleItemManager():FindItemByBagAndThisID( 
		self.clickeditem.Item:getID(), knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		LogInsaneFormat("Unable to find item in bag")
		return true
	end
	local config = knight.gsp.item.GetCEquipStrengthenTableInstance():getRecorder(item:GetBaseObject().id)
	if config.id == -1 then
		return true
	end
	local materialnum = GetRoleItemManager():GetItemNumByBaseID(config.needitemid)
	if materialnum < config.needitemnum then
		LogInsaneFormat("Need itemid=%d", config.needitemid)
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144763)
        end
--		CGreenChannel:GetSingletonDialogAndShowIt():SetItem(config.needitemid, config.needitemnum - materialnum)
		return true
	end
	local papernum = GetRoleItemManager():GetItemNumByBaseID(config.paperid)
	if papernum < config.papernum then
		LogInsaneFormat("Need paperid=%d", config.paperid)
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144763)
        end
--		CGreenChannel:GetSingletonDialogAndShowIt():SetItem(config.paperid, config.papernum - papernum)
		return true
	end
	local moneynum = GetRoleItemManager():GetPackMoney()
	if moneynum < config.needmoney then
		LogInsaneFormat("Need money=%d", config.needmoney)
        -- if GetChatManager() then
        --     GetChatManager():AddTipsMsg(144764)
        -- end
        self:showQuickBuyMoneyDlg()
		return true
	end
	if config.cailiaoid ~= 0 then
		local cailiaonum = GetRoleItemManager():GetItemNumByBaseID(config.cailiaoid)
		if cailiaonum < config.cailiaoshuliang then
               if GetChatManager() then
                   GetChatManager():AddTipsMsg(144763)
               end
			return true
		end
	end
	local nextattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(config.nextequipid);
    if nextattr.id == -1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144762);
        end
        return true;
    end
    if nextattr.needLevel > GetDataManager():GetMainCharacterLevel() then
        local param = std.vector_std__wstring_()
        param:push_back(tostring(nextattr.needLevel));
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144761,0,param);
        end
        return true;
    end
	local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10176), false);
    if pEffect then
    	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
       pEffect:AddNotify(notify);
    	self.QhProgressing = true
    	self.QhAll = false
    end
    
	return true
end

function WorkshopQhNew:SetItemSelected(bagid, itemkey)
	LogInsane(string.format("WorkshopQhNew:SetItemSelected(%d %d)", bagid, itemkey))
	if bagid == knight.gsp.item.BagTypes.EQUIP then
		local item = GetRoleItemManager():FindItemByBagAndThisID( 
			itemkey, bagid)
		
		if item then
			local index, item_local = WorkshopHelper.GetLocalItem(item:GetItemTypeID())
			if self.clickeditem then
				self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
			end
			self.clickeditem = self.QhItems[index]
			self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
			if self.clickeditem then
				self:ShowItem(itemkey, bagid)
			end
		end
	end
end

function WorkshopQhNew:RefreshItemTips(item)
	local location = item:GetLocation()
	if location.tableType ~= knight.gsp.item.BagTypes.EQUIP then
		return
	end
	local index, item_local = WorkshopHelper.GetLocalItem(item:GetItemTypeID())
	local uiitem = self.QhItems[index]
	if uiitem then
		local iconManager = GetIconManager()
		local attr = item:GetBaseObject()
		uiitem.Name:setText(item:GetName())
		local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
		uiitem.Name:setProperty("TextColours", color)
		uiitem.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
		local equipObj = toEquipObject(item:GetObject())
		if equipObj then
			uiitem.Level:setText(toQhIntroduce(
				item:GetBaseObject().id, 
				MHSD_UTILS.get_resstring(item_local.empty_string),
				attr.level))
			uiitem.Level:setProperty("TextColours", color)
		else
			uiitem.Level:setText("")
		end
		if self:CanItemQh(item:GetThisID()) then
			uiitem.Mark:setVisible(true)
			if uiitem.HasEffect == nil or not uiitem.HasEffect then
				GetGameUIManager():AddUIEffect(uiitem.Mark, MHSD_UTILS.get_effectpath(10375), true)
			end
			uiitem.HasEffect = true
		else
			uiitem.Mark:setVisible(false)
			if uiitem.HasEffect then
				GetGameUIManager():RemoveUIEffect(uiitem.Mark)
			end
			uiitem.HasEffect = false
		end
	end
	
	self:ShowItem(item:GetThisID(), knight.gsp.item.BagTypes.EQUIP)
	local warninglist = CWaringlistDlg:GetSingleton()
	local pWarning = warninglist:GetWarning(3)
	if pWarning then
		pWarning:RefreshState()
	end
end

function WorkshopQhNew:GetLayoutFileName()
	return "workshopqhnew.layout"
end
function WorkshopQhNew:DestroyDialog()
	if self.m_LinkLabel then
		self.m_LinkLabel:OnClose()
		self.m_LinkLabel = nil
	else
		self:OnClose()
	end
end
function WorkshopQhNew:OnClose()
	Dialog.OnClose(self)
	_instance.m_LinkLabel =nil
	_instance.QhProgressing = false
	_instance.PreviewItems = {}
	GetRoleItemManager().EventPackMoneyChange:RemoveScriptFunctor(_instance.m_hPackMoneyChange)
    GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
	_instance = nil
end

return WorkshopQhNew
