local CLinkInfoCtrl = class("CLinkInfoCtrl", CCtrlBase)

define.Link = {
	Event = {
		UpdateIdx = 1,
		UpdateNormalMsg = 2,
		UpdateInputText = 3,
	}
}

function CLinkInfoCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CLinkInfoCtrl.ResetCtrl(self)
	self.m_ItemInfo = {}
	self.m_SummonInfo = {}
	self.m_AttrCardInfo = {}
	self.m_RandList = {}
	self.m_NormalMsgList = nil
end

function CLinkInfoCtrl.SetLinkIdx(self, rand, idx)
	rand = self.m_RandList[rand]
	local list = string.split(rand, ",")
	local ctrldata = nil
	if list[1] == "partner" then
		ctrldata = {linktype = "partner", parid = tonumber(list[2]), idx = idx}
	elseif list[1] == "item" then
		ctrldata = {linktype = "item", itemid = tonumber(list[2]), idx = idx}
	elseif list[1] == "namelink" then
		ctrldata = {linktype = "namelink", idx = idx}
	end
	if ctrldata then
		self:OnEvent(define.Link.Event.UpdateIdx, ctrldata)
	end
end

function CLinkInfoCtrl.GetPartnerLinkIdx(self, parid)
	local rand = string.format("partner,%d", parid)
	local idx = #self.m_RandList
	self.m_RandList[idx+1] = rand
	netlink.C2GSLinkPartner(parid, idx+1)
end

function CLinkInfoCtrl.OnClinkPartnerLink(self, idx)
	netlink.C2GSClickLink(idx)
end

function CLinkInfoCtrl.ShowPartnerLink(self, idx, linkpartner)
	CPartnerLinkView:ShowView(function (oView)
		oView:Refresh(linkpartner.par)
	end)
end

function CLinkInfoCtrl.GetItemLinkIdx(self, itemid)
	local rand = string.format("item,%d", itemid)
	local idx = #self.m_RandList
	self.m_RandList[idx+1] = rand
	netlink.C2GSLinkItem(itemid, idx+1)
end

function CLinkInfoCtrl.ShowItemLink(self, idx, itemlink)
	local oItem = CItem.New(itemlink.item)
	if oItem:IsPartnerEquip() then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {hideui=true})
	elseif oItem:IsPartnerSoul() then
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {hideui=true})
	elseif oItem:IsEquip() then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true,})
	elseif oItem:GetValue("type") == define.Item.ItemType.EquipStone then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true,})
	else
		g_WindowTipCtrl:SetWindowItemTipsSellItemInfo(oItem)
	end
end

function CLinkInfoCtrl.OnClickItemLink(self, idx)
	netlink.C2GSClickLink(idx)
end

function CLinkInfoCtrl.UpdateNormalMsg(self, msglist)
	if not msglist[1] then
		msglist = {}
		for _, v in ipairs(data.chatdata.NormalMsg) do
			table.insert(msglist, v.content)
		end
	end
	self.m_NormalMsgList = msglist
	self:OnEvent(define.Link.Event.UpdateNormalMsg, msglist)
end

function CLinkInfoCtrl.GetNameLinkIdx(self)
	local idx = #self.m_RandList
	self.m_RandList[idx+1] = "namelink"
	netlink.C2GSLinkPlayer(idx+1)
end

function CLinkInfoCtrl.OnClickNameLink(self, idx)
	netlink.C2GSClickLink(idx)
end

function CLinkInfoCtrl.ShowNameLink(self, idx, namelink)
	CAttrLinkView:ShowView(function (oView)
		oView:RefreshData(namelink.player)
	end)
end

function CLinkInfoCtrl.GetNormalMsg(self)
	return self.m_NormalMsgList
end

function CLinkInfoCtrl.C2SGetNormalMsg(self)
	if not self.m_NormalMsgList then
		local msglist = {}
		for _, v in ipairs(data.chatdata.NormalMsg) do
			table.insert(msglist, v.content)
		end
		self.m_NormalMsgList = msglist
		netlink.C2GSGetCommonChat()
	end
	
end

--刷新输入框内容
function CLinkInfoCtrl.UpdateInputText(self, msg)
	self:OnEvent(define.Link.Event.UpdateInputText, msg)
end


return CLinkInfoCtrl

