require "ui.dialog"

FactionTrack = {}
setmetatable(FactionTrack, Dialog)
FactionTrack.__index = FactionTrack

local function createdlg()
	local self = {}
	setmetatable(self, FactionTrack)
	function self.GetLayoutFileName()
		return "familytrack.layout"
	end
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pReduceBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyTrack/min"))
	self.m_pAddBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyTrack/max"))
	self.m_pNumEditbox = CEGUI.toEditbox(winMgr:getWindow("FamilyTrack/num"))
	self.m_pCurrentContribute = winMgr:getWindow("FamilyTrack/Money/banggong")
	self.m_pCurrentMoney = winMgr:getWindow("FamilyTrack/Money/recent")
	self.m_pCurrentBlevel = winMgr:getWindow("FamilyTrack/Money/build")
	self.m_pExchangeContribute = winMgr:getWindow("FamilyTrack/Money/gong")
	self.m_pExchangeMoney = winMgr:getWindow("FamilyTrack/Money/need")
	self.m_pExchangeBlevel = winMgr:getWindow("FamilyTrack/Money/needbuild") 
	self.m_pOkBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyTrack/change"))
	self.m_pOkBtn:subscribeEvent("Clicked", self.HandleOkBtnClicked, self)
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.faction.cfactionbaseinfo")
	self.m_pExchangeConfig = tt:getRecorder(1)--datamanager.factionlevel or 
	self.m_pNumEditbox:subscribeEvent("TextChanged", self.HandleContributeChanged, self)
	self.m_pNumberInput = require "ui.numberinputcomponent"(self.m_pReduceBtn, self.m_pAddBtn, self.m_pNumEditbox)
--	self.m_pNumEditbox:SetOnlyNumberMode(true, 999999, true)
	self.m_pNumberInput:setInterval(10)
	self.m_pNumEditbox:setText(10)
	self.m_pNumEditbox:SetOnlyNumberMode(true, 10)
	return self
end

function FactionTrack:RefreshData()
	local datamanager = require "ui.faction.factiondatamanager"
	local money = GetRoleItemManager():GetPackMoney()
	self.m_pCurrentMoney:setText(money)
	local datamanager = require "ui.faction.factiondatamanager"
	self.m_pCurrentContribute:setText(datamanager.currentcontribution or 0)
	self.m_pCurrentBlevel:setText(datamanager.buildlevel or 0)
	self.m_pExchangeContribute:setText(datamanager.exchangemax or 0)
	self.m_pNumberInput.max = datamanager.exchangemax
	self.m_pNumEditbox:SetOnlyNumberMode(true, datamanager.exchangemax)
end

function FactionTrack:HandleOkBtnClicked(e)
	
	local exchange = CEGUI.PropertyHelper:stringToUint(self.m_pNumEditbox:getText())
	
	local needmoney = math.floor(exchange * self.m_pExchangeConfig.devote)
	print("needmoney : ", needmoney)
	if needmoney > GetRoleItemManager():GetPackMoney() then
		-- // 38350 硕大的钱袋 100
     	-- // 38349 钱袋 10
     	-- // 38771 乾坤大钱箱 600
		local itemid = 38349
		if GetChatManager() then
            GetChatManager():AddTipsMsg(146311)
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
	else 
		local p = require "protocoldef.knight.gsp.faction.cexchangefactioncontribute":new()
		p.contribute = exchange
		require "manager.luaprotocolmanager":send(p)
	end
	return true
end

function FactionTrack:HandleContributeChanged(e)
	if self.m_pNumberInput.max and self.m_pNumberInput.max < 10 then
		GetChatManager():AddTipsMsg(145090)
	end
	local exchange = CEGUI.PropertyHelper:stringToUint(self.m_pNumEditbox:getText()) or 0
	if exchange < 10  and GetChatManager() then
		GetChatManager():AddTipsMsg(145111)
	end
--	LogInsane("exchange contribute="..exchange)
	local devote = self.m_pExchangeConfig.devote
	local needmoney = math.floor(exchange * devote)

	local incrbuild = math.floor(needmoney / self.m_pExchangeConfig.construction)
	self.m_pExchangeBlevel:setText(incrbuild)

	self.m_pExchangeMoney:setText(needmoney)
	
	return true
end

local _instance

function FactionTrack.getInstanceAndShowIt()
	if not _instance then
		_instance = createdlg()
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionTrack.getInstance()
	if not _instance then
		_instance = createdlg()
	end
	return _instance
end

function FactionTrack.getInstanceOrNot()
	return _instance
end

function FactionTrack:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function FactionTrack.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

return FactionTrack
