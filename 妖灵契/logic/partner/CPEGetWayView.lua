CPEGetWayView = class("CPEGetWayView", CViewBase)

function CPEGetWayView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerEquipWay.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"

end

function CPEGetWayView.OnCreateView(self)
	self.m_IconSpr = self:NewUI(2, CSprite)
	self.m_FilterGrid = self:NewUI(3, CGrid)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_Grid = self:NewUI(6, CGrid)
	self.m_ItemBox = self:NewUI(7, CBox)
	self.m_NameLabel = self:NewUI(8, CLabel)
	self:InitContent()
end

function CPEGetWayView.InitContent(self)
	self:InitPEData()
	self.m_ItemBox:SetActive(false)
	self.m_FilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", idx))
		oBtn:SetGroup(self.m_FilterGrid:GetInstanceID())
		return oBtn
	end)
end

function CPEGetWayView.InitPEData(self)
	self.m_Type2Time = {}
	for _, fbdata in ipairs(data.pefubendata.FUBEN) do
		for _, etype in ipairs(fbdata.equip) do
			self.m_Type2Time[etype] = self.m_Type2Time[etype] or {}
			for _, t in ipairs(fbdata.open_date) do
				self.m_Type2Time[etype][t] = true
			end
		end
	end
end

function CPEGetWayView.SetData(self, equipType)
	self.m_EquipType = equipType
	self.m_ItemList = {}
	local tdata = data.partnerequipdata.ParSoulType[equipType]
	if tdata then
		for i = 1, 6 do
			self.m_ItemList[i] = tdata.icon * 100 + 10 + i
		end
		self.m_IconSpr:SpriteItemShape(tdata.icon)
		local desc = string.format("%s", tdata.skill_desc)
		self.m_DescLabel:SetText(desc)
	end
	self.m_NameLabel:SetText(tdata.name)
	self:UpdateFilter(1)
	local firstbox = self.m_FilterGrid:GetChild(1)
	firstbox:SetSelected(true)
end

function CPEGetWayView.RefreshGrid(self)
	self.m_Grid:Clear()
	local pedata = data.partnerequipdata.EquipGetWay
	for i = 1, 20 do
		local idx = self.m_ID*100 + i
		if pedata[idx] then
			local box = self:CreateItemBox()
			self:SetItemData(box, pedata[idx])
			self.m_Grid:AddChild(box)
		else
			break
		end
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CPEGetWayView.CreateItemBox(self)
	local box = self.m_ItemBox:Clone()
	box.m_NameLabel = box:NewUI(1, CLabel)
	box.m_Btn = box:NewUI(2, CButton)
	box.m_EnableLabel = box:NewUI(3, CLabel)
	box:SetActive(true)
	return box
end

function CPEGetWayView.SetItemData(self, box, getwaydata)
	if getwaydata then
		box.m_NameLabel:SetText(getwaydata.title.."\n"..getwaydata.desc)
		local d = data.itemdata.MODULE_SRC[getwaydata.funcid]
		local function cb()
			if g_AttrCtrl.grade < getwaydata.unlock_level then
				g_NotifyCtrl:FloatMsg(string.format("%d级开启", getwaydata.unlock_level))
				return
			end
			if not g_ActivityCtrl:ActivityBlockContrl("item_resource") and not g_ActivityCtrl:ActivityBlockContrl("partner_resource") then
				return
			end						
			if d.blockkey ~= "" then
				if not g_ActivityCtrl:ActivityBlockContrl(d.blockkey) then
					return
				end
			end
			if d.id == 173 then
				local a, b = string.find(getwaydata.desc, "%d+")
				if a then
					local iChapter = tonumber(string.sub(getwaydata.desc, a, b))
					if iChapter then
						g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Simple, iChapter)
						self:CloseView()
						return
					end
				end
			end
			if g_ItemCtrl:ItemFindWayToSwitch(d.id) == true then
				self:CloseView()
			end							
		end
		if g_AttrCtrl.grade < getwaydata.unlock_level then
			box.m_Btn:SetActive(false)
			box.m_EnableLabel:SetActive(true)
			box.m_EnableLabel:SetText(string.format("%d级开启", getwaydata.unlock_level))
		else
			box.m_Btn:SetActive(true)
			box.m_EnableLabel:SetActive(false)
		end
		box.m_Btn:AddUIEvent("click", cb)
	end
end


function CPEGetWayView.UpdateFilter(self, iStar)
	self.m_ID = self.m_ItemList[iStar]
	self:RefreshGrid()
end

return CPEGetWayView