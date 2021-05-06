local CTeaartFeelPage = class("CTeaartFeelPage", CPageBase)

function CTeaartFeelPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeaartFeelPage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CBox)
	self.m_BoxGrid = self:NewUI(2, CGrid)
	self.m_SampleBox = self:NewUI(3, CBox)
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	self.m_BoxArr = {}
	self.m_SampleBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "HideAll"))
	self:SetData()
end

function CTeaartFeelPage.SetData(self)
	local dData = self:GetProductList()
	for i,v in ipairs(dData) do
		if self.m_BoxArr[i] == nil then
			self.m_BoxArr[i] = self:CreateBox()
			self.m_BoxGrid:AddChild(self.m_BoxArr[i])
		end
		self.m_BoxArr[i]:SetActive(true)
		self.m_BoxArr[i]:SetData(v)
	end
	for i = #dData + 1, #self.m_BoxArr do
		self.m_BoxArr[i]:SetActive(false)
	end
end

function CTeaartFeelPage.CreateBox(self)
	local oBox = self.m_SampleBox:Clone()
	oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
	oBox.m_LockSpr = oBox:NewUI(2, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnClickBox"))

	function oBox.SetData(self, dData)
		oBox.m_ID = dData.id
		oBox.m_OpenLv = dData.openLv
		oBox.m_ItemData = DataTools.GetItemData(oBox.m_ID)
		oBox.m_ItemSpr:SpriteItemShape(oBox.m_ItemData.icon)
		oBox.m_LockSpr:SetActive(not dData.open)
		oBox.m_IsOpen = dData.open
	end
	
	return oBox
end

function CTeaartFeelPage.OnClickBox(self, oBox)
	if oBox.m_IsOpen then
		CHouseItemDescView:ShowView(function(oView)
			oView:SetItemShape(oBox)
		end)
	else
		g_NotifyCtrl:FloatMsg(string.format("厨艺等级达到%s级时解锁该礼物。", oBox.m_OpenLv))
		-- g_NotifyCtrl:FloatMsg("没有达到制作等级")
	end
end

function CTeaartFeelPage.GetProductList(self)
	local list = {}
	local iCurLevel = g_HouseCtrl:GetTalentLevel()
	local talentList = {}
	for k,v in pairs(data.housedata.Talent) do
		table.insert(talentList, v)
	end
	local function sortFunc(v1, v2)
		return v1.talent_level < v2.talent_level
	end
	table.sort(talentList, sortFunc)
	for i,v in ipairs(talentList) do
		for i, id in ipairs(v.sid_list) do
			table.insert(list, {id = id, open = iCurLevel >= v.talent_level, openLv = v.talent_level})
		end
	end
	return list
end

function CTeaartFeelPage.HideAll(self)
	self.m_ParentView:HideAllPage()
end

function CTeaartFeelPage.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.TalentRefresh then
		self:SetData()
	end
end


return CTeaartFeelPage