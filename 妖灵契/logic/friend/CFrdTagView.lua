local CFrdTagView = class("CFrdTagView", CViewBase)

function CFrdTagView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FriendTagView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CFrdTagView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainGrid = self:NewUI(2, CGrid)
	self.m_MainTagBtn = self:NewUI(3, CBox)
	self.m_TagGrid = self:NewUI(4, CGrid)
	self.m_TagBox = self:NewUI(5, CBox)
	self.m_TagLabel = self:NewUI(6, CLabel)
	self.m_ClearBtn = self:NewUI(7, CButton)
	self.m_ConfirmBtn = self:NewUI(8, CButton)
	self.m_ScrollView = self:NewUI(9, CScrollView)
	self:InitContent()
end

function CFrdTagView.InitContent(self)
	self.m_SelectList = {}
	self.m_MainTagBtn:SetActive(false)
	self.m_TagBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClear"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self:CreateMainGrid()
end

function CFrdTagView.UpdateSelectTag(self, taglist)
	self.m_SelectList = taglist
	self:CreateMainGrid()
end

function CFrdTagView.SetEditView(self, bSet)
	self.m_IsEditView = bSet
end

function CFrdTagView.SetCallback(self, cbfunc)
	self.m_CallBack = cbfunc
end

function CFrdTagView.CreateMainGrid(self)
	self.m_MainGrid:Clear()
	for _, name in ipairs(data.tagdata.MainTag) do
		local box = self.m_MainTagBtn:Clone()
		box.m_Btn = box:NewUI(1, CButton)
		box.m_SelText = box:NewUI(2, CLabel)
		box.m_Label = box:NewUI(3, CLabel)
		box:SetActive(true)
		box.m_Label:SetText(name)
		box.m_SelText:SetText(name)
		box.m_KeyName = name
		box:SetGroup(self.m_MainGrid:GetInstanceID())
		box:AddUIEvent("click", callback(self, "RefreshMainTag", name))
		self.m_MainGrid:AddChild(box)
	end
	local firstbtn = self.m_MainGrid:GetChild(1)
	firstbtn:SetSelected(true)
	self:RefreshMainTag(firstbtn.m_KeyName)
	self:UpdateLabel()
end

function CFrdTagView.RefreshMainTag(self, key)
	self.m_TagGrid:Clear()
	self.m_MainKey = key
	for _, name in ipairs(data.tagdata.Tag[key]) do
		local box = self.m_TagBox:Clone()
		box.m_Btn = box:NewUI(1, CButton)
		box.m_SelBtn = box:NewUI(2, CButton)
		local idx = table.index(self.m_SelectList, name)
		if idx then
			box.m_SelBtn:SetActive(true)
			box.m_Btn:SetActive(false)
		else
			box.m_SelBtn:SetActive(false)
			box.m_Btn:SetActive(true)
		end
		box.m_Btn:AddUIEvent("click", callback(self, "OnSelectTag", box))
		box.m_SelBtn:AddUIEvent("click", callback(self, "OnSelectTag", box))
		box:SetActive(true)
		box.m_SelBtn:SetText(name)
		box.m_Btn:SetText(name)
		box.m_Name = name
		self.m_TagGrid:AddChild(box)
	end
	self.m_TagGrid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CFrdTagView.UpdateLabel(self)
	local str = "已选择："..table.concat(self.m_SelectList, "、")
	if #self.m_SelectList > 4 then
		str = "已选择："
		for i = 1, 4 do
			str = str .. self.m_SelectList[i].."、"
		end
		str = str .. string.format("...（共%d种标签）", #self.m_SelectList)
	elseif #self.m_SelectList == 0 then
		str = "已选择：无"
	end
	self.m_TagLabel:SetText(str)
end

function CFrdTagView.OnSelectTag(self, box)
	local name = box.m_Name
	local index = table.index(self.m_SelectList, name)
	if index then
		box.m_SelBtn:SetActive(false)
		box.m_Btn:SetActive(true)
		table.remove(self.m_SelectList, index)
	else
		if #self.m_SelectList > 3 and self.m_IsEditView then
			box.m_SelBtn:SetActive(false)
			box.m_Btn:SetActive(true)
			g_NotifyCtrl:FloatMsg("最多选择4个标签")
		else
			box.m_SelBtn:SetActive(true)
			box.m_Btn:SetActive(false)
			table.insert(self.m_SelectList, name)
		end
	end
	self:UpdateLabel()
end

function CFrdTagView.OnClear(self)
	self.m_SelectList = {}
	self:RefreshMainTag(self.m_MainKey)
	self:UpdateLabel()
end

function CFrdTagView.OnConfirm(self)
	if self.m_CallBack then
		self.m_CallBack(table.copy(self.m_SelectList))
		self:OnClose()
	else
		self:SaveTag()
	end
end

function CFrdTagView.SaveTag(self)
	local data ={
		pid = self.m_InfoData["pid"],
		grade = self.m_InfoData["grade"],
		school = self.m_InfoData["school"],
		orgname = self.m_InfoData["orgname"],
		charm = self.m_InfoData["charm"],
		charm_rank = self.m_InfoData["charm_rank"],
		name = self.m_InfoData["name"],
		sex = self.m_InfoData["sex"],
		signa = self.m_InfoData["signa"],
		photo = self.m_InfoData["photo"],
		birthday = self.m_InfoData["birthday"],
		addr = self.m_InfoData["addr"],
	}
	if data["birthday"]["year"] == 0 then
		data["birthday"] = {year = 1990, month = 1, day = 1}
	end
	data["labal"] = table.copy(self.m_SelectList)
	netfriend.C2GSEditDocument(data)
	self:OnClose()
end

return CFrdTagView