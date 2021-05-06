local CPartnerShowView = class("CPartnerShowView", CViewBase)

function CPartnerShowView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/PartnerShowView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CPartnerShowView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ShowIconList = {}
	self.m_PartnerList = {}
	for i = 2, 4 do
		local box = self:NewUI(i, CBox)
		box.m_PartnerIcon = box:NewUI(2, CBox)
		box.m_CloseBtn = box:NewUI(3, CButton)
		box.m_PartnerIcon:SetActive(false)
		box.m_Idx = i - 1
		self:InitPartnerIcon(box.m_PartnerIcon)
		box.m_PartnerIcon:AddUIEvent("click", callback(self, "OnDelPartner", box))
		table.insert(self.m_ShowIconList, box)
	end
	self.m_FilterGrid = self:NewUI(5, CGrid)
	self.m_ScrollView = self:NewUI(6, CScrollView)
	self.m_WrapContent = self:NewUI(7, CWrapContent)
	self.m_WrapItem = self:NewUI(8, CBox)
	self.m_PartnerIcon = self:NewUI(9, CBox)
	self.m_FilterBox = self:NewUI(10, CBox)
	self.m_FilterBox:SetActive(false)
	self:InitContent()
end

function CPartnerShowView.InitContent(self)
	self.m_WrapItem:SetActive(false)
	self:InitValue()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:InitFilter()
	self:RefreshList(0)
end

function CPartnerShowView.InitPartnerIcon(self, box)
	box.m_Icon = box:NewUI(1, CSprite)
	box.m_RareSpr = box:NewUI(2, CSprite)
	box.m_StarGrid = box:NewUI(3, CGrid)
	box.m_StarSpr = box:NewUI(4, CSprite)
	box.m_GradeLabel = box:NewUI(5, CLabel)
	box.m_AwakeSpr = box:NewUI(6, CSprite)
	box.m_SelSpr = box:NewUI(7, CSprite, false)
	box.m_StarSpr:SetActive(false)
	for i = 1, 5 do
		local spr = box.m_StarSpr:Clone()
		spr:SetActive(true)
		box.m_StarGrid:AddChild(spr)
	end
	box.m_StarGrid:Reposition()
end

function CPartnerShowView.InitFilter(self)
	local t = {{0, "全部"},  {2, "传说"}, {1, "精英"}, }
	self.m_FilterGrid:Clear()
	for _, v in ipairs(t) do
		local box = self.m_FilterBox:Clone()
		box:SetActive(true)
		box.m_Btn = box:NewUI(1, CButton)
		box.m_Label = box:NewUI(2, CLabel)
		box.m_SelLabel = box:NewUI(3, CLabel)
		box.m_Label:SetText(v[2])
		box.m_SelLabel:SetText(v[2])
		box.m_Btn:AddUIEvent("click", callback(self, "OnClickFilter", v[1]))
		box.m_Btn:SetGroup(self.m_FilterGrid:GetInstanceID())
		self.m_FilterGrid:AddChild(box)
	end
	self.m_FilterGrid:Reposition()
	self.m_FilterGrid:GetChild(1):SetSelected(true)
end

function CPartnerShowView.InitValue(self)
	self.m_WrapContent:SetCloneChild(self.m_WrapItem, 
		function(oChild)
			oChild.m_IconList = {}
			for i = 1, 6 do
				local box = oChild:NewUI(i, CBox)
				self:InitPartnerIcon(box)
				table.insert(oChild.m_IconList, box)
			end
			return oChild
		end)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			oChild:SetActive(true)
			for i = 1, 6 do
				local box = oChild.m_IconList[i]
				if dData[i] then
					box:SetActive(true)
					box.m_ID = dData[i].m_ID
					box:AddUIEvent("click", callback(self, "OnClickPartner", dData[i]))
					if table.index(self.m_PartnerList, box.m_ID) then
						box.m_SelSpr:SetActive(true)
					else
						box.m_SelSpr:SetActive(false)
					end
					self:UpdatePartner(box, dData[i])
				else
					box.m_ID = nil
					box:SetActive(false)
				end
			end
		else
			oChild:SetActive(false)
		end
	end)
end

function CPartnerShowView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateDoc then
		self:RefreshShowPartner(oCtrl.m_EventData["parlist"])
		g_ViewCtrl:TopView(self)
	end
end

function CPartnerShowView.RefreshShowPartner(self, partnerlist)
	self.m_PartnerList = {}
	for i, icon in ipairs(self.m_ShowIconList) do
		if partnerlist[i] then
			local oPartner = g_PartnerCtrl:GetPartner(partnerlist[i].parid) 
			if oPartner then
				table.insert(self.m_PartnerList, partnerlist[i].parid)
				self.m_ShowIconList[i].m_ID = partnerlist[i].parid
				self.m_ShowIconList[i].m_PartnerIcon:SetActive(true)
				self:UpdatePartner(self.m_ShowIconList[i].m_PartnerIcon, oPartner, true)
			else
				self.m_ShowIconList[i].m_ID = nil
				self.m_ShowIconList[i].m_PartnerIcon:SetActive(false)
			end
		else
			self.m_ShowIconList[i].m_ID = nil
			self.m_ShowIconList[i].m_PartnerIcon:SetActive(false)
		end
	end
	self:RefreshWrapItem()
end

function CPartnerShowView.RefreshWrapItem(self)
	for _, boxList in ipairs(self.m_WrapContent:GetChildList()) do
		for _, box in ipairs(boxList.m_IconList) do
			if box:GetActive() then
				if table.index(self.m_PartnerList, box.m_ID) then
					box.m_SelSpr:SetActive(true)
				else
					box.m_SelSpr:SetActive(false)
				end
			end
		end
	end
end


function CPartnerShowView.UpdatePartner(self, box, oPartner, isbigicon)
	box.m_Icon:SpriteAvatar(oPartner:GetIcon())
	g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, oPartner:GetValue("rare"))
	for i, spr in ipairs(box.m_StarGrid:GetChildList()) do
		if oPartner:GetValue("star") >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	box.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
	if isbigicon then
		box.m_GradeLabel:SetText("LV"..tostring(oPartner:GetValue("grade")))
	else
		box.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
	end
	box.m_StarGrid:Reposition()
end

function CPartnerShowView.OnClickPartner(self, oPartner)
	local list = {}
	local addflag = false
	for i = 1, 3 do
		if self.m_ShowIconList[i].m_ID then
			if self.m_ShowIconList[i].m_ID == oPartner.m_ID then
				addflag = true
			else
				table.insert(list, self.m_ShowIconList[i].m_ID)
			end
		else
			if not addflag then
				table.insert(list, oPartner.m_ID)
				addflag = true
				break
			end
		end
	end
	if addflag then
		netfriend.C2GSSetShowPartner(list)
	else
		g_NotifyCtrl:FloatMsg("展示伙伴已满")
	end
end

function CPartnerShowView.OnDelPartner(self, box)
	local list = {}
	for i = 1, 3 do
		local iParid = self.m_ShowIconList[i].m_ID
		if iParid and iParid ~= box.m_ID then
			table.insert(list, iParid)
		end
	end
	netfriend.C2GSSetShowPartner(list)
end

function CPartnerShowView.OnClickFilter(self, iRare)
	self:RefreshList(iRare)
end

function CPartnerShowView.GetPartnerList(self, iRare)
	local list = g_PartnerCtrl:GetPartnerByRare(iRare, true)
	list = self:SortList(list)
	return list
end

function CPartnerShowView.SortList(self, list)
	local lSortList = {"power", "star", "grade", "partner_type", "parid"}
	local function cmp(a, b)
		for _, key in ipairs(lSortList) do
			if a:GetValue(key) ~= b:GetValue(key) then
				return a:GetValue(key) > b:GetValue(key)
			end
		end
		return false
	end
	table.sort(list, cmp)
	return list
end

function CPartnerShowView.RefreshList(self, iRare)
	local list = self:GetPartnerList(iRare)
	local dividelist = self:GetDivideList(list)
	self.m_WrapContent:SetData(dividelist, true)
end

function CPartnerShowView.GetDivideList(self, list)
	local newlist = {}
	local data = {}
	for i, oPartner in ipairs(list) do
		table.insert(data, oPartner)
		if #data > 5 then
			table.insert(newlist, data)
			data = {}
		end
	end
	if #data > 0 then
		table.insert(newlist, data)
	end
	return newlist
end

function CPartnerShowView.ChangeShowPartner(self)
	netfriend.C2GSSetShowPartner()
end

return CPartnerShowView