local CLostBookPage = class("CLostBookPage", CPageBase)
--符文佚书

function CLostBookPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CLostBookPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_MainPart = self:NewUI(2, CBox)
	self.m_ChapterPart = self:NewUI(3, CBox)
	self.m_ReadPart = self:NewUI(4, CBox)
	self.m_PartnerEquipBtn = self:NewUI(5, CButton)
	self.m_BookBG = self:NewUI(6, CObject)

	self.m_PageAmount = 6
	self:InitMainPart()
	self:InitChapterPart()
	self:InitReadPart()
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_PartnerEquipBtn:AddUIEvent("click", callback(self, "OnBackEquip"))
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self:OnItemCtrlEvent()
end

function CLostBookPage.OnShowPage(self)
	self.m_EquipBookList = nil
	self.m_KeyList = nil
	self:ShowFilterKey({})
	self:RefreshMainPart()
	self:OnBackMain()
end

function CLostBookPage.InitMainPart(self)
	local mainpart = self.m_MainPart
	self.m_MainGrid = mainpart:NewUI(1, CBox)
	self.m_LostBookBox = mainpart:NewUI(2, CLostBookMainBox)
	self.m_PageDnBtn = mainpart:NewUI(3, CButton)
	self.m_PageUpBtn = mainpart:NewUI(4, CButton)
	self.m_FilterBox = mainpart:NewUI(5, CBox)
	self.m_FilterSelSpr = self.m_FilterBox:NewUI(1, CSprite)
	self.m_FilterLabel = self.m_FilterBox:NewUI(2, CLabel)
	self.m_FilterGrid = self.m_FilterBox:NewUI(3, CGrid)

	self.m_TotalProgress = mainpart:NewUI(6, CLabel)
	self.m_LeftPageLabel = mainpart:NewUI(7, CLabel)
	self.m_RightPageLabel = mainpart:NewUI(8, CLabel)

	self:InitBookGrid()
	self.m_FilterLabel:SetActive(false)
	self.m_LostBookBox:SetActive(false)
	self.m_PageUpBtn:AddUIEvent("click", callback(self, "OnPageUp"))
	self.m_PageDnBtn:AddUIEvent("click", callback(self, "OnPageDn"))
	self.m_FilterBox:AddUIEvent("click", callback(self, "OnShowFilter"))
	self.m_MainPart:SetActive(true)
	self:RefreshProgress()
end

function CLostBookPage.InitBookGrid(self)
	self.m_GridList = {}
	local iStartX, iStartY = 0, 0
	local iDeltaX, iDeltaY = -250, -290
	for i = 1, self.m_PageAmount do
		self.m_GridList[i] = self.m_LostBookBox:Clone()
		self.m_GridList[i]:SetParent(self.m_MainGrid.m_Transform)
		local idxx = math.floor((i-1)/2)
		local idxy = (i-1) % 2
		if i == 3 then
			iStartX = -50
		end
		self.m_GridList[i]:SetLocalPos(Vector3.New(iStartX + idxx*iDeltaX, iStartY + idxy*iDeltaY, 0))
	end
end

function CLostBookPage.InitChapterPart(self)
	self.m_ChapterGrid = self.m_ChapterPart:NewUI(1, CGrid)
	self.m_ChapterBox = self.m_ChapterPart:NewUI(2, CLostBookArticleBox)
	self.m_ChapterLabel = self.m_ChapterPart:NewUI(3, CLabel)
	self.m_BackMainBtn = self.m_ChapterPart:NewUI(4, CButton)
	self.m_EquipNameLabel = self.m_ChapterPart:NewUI(5, CLabel)
	self.m_EmptyChapterLabel = self.m_ChapterPart:NewUI(6, CLabel)
	self.m_PartnerTexture = self.m_ChapterPart:NewUI(7, CTexture)
	self.m_ChapterBox:SetActive(false)
	self.m_ChapterPart:SetActive(false)
	self.m_EmptyChapterLabel:SetActive(false)
	self.m_BackMainBtn:AddUIEvent("click", callback(self, "OnBackMain"))
end

function CLostBookPage.InitReadPart(self)
	self.m_ReadTitle = self.m_ReadPart:NewUI(1, CLabel)
	self.m_ReadContent = self.m_ReadPart:NewUI(2, CLabel)
	self.m_BackChapterBtn = self.m_ReadPart:NewUI(3, CButton)
	self.m_ReadScrollView = self.m_ReadPart:NewUI(4, CScrollView)
	self.m_ContentTitle = self.m_ReadPart:NewUI(5, CLabel)
	self.m_ReadTitleTexture = self.m_ReadPart:NewUI(6, CTexture)
	self.m_ReadContentTexture = self.m_ReadPart:NewUI(7, CTexture)
	self.m_ReadTitle2 = self.m_ReadPart:NewUI(8, CLabel)
	self.m_CalcaLabel = self.m_ReadPart:NewUI(9, CLabel)

	local list = self.m_ReadTitle2:GetComponents(classtype.UITweener)
	self.m_ReadTitle2.m_Tween1 = list[0]
	self.m_ReadTitle2.m_Tween2 = list[1]
	self.m_ReadTitle.m_Tween = self.m_ReadTitle:GetComponent(classtype.UITweener)

	self.m_BackChapterBtn:AddUIEvent("click", callback(self, "OnBackChapter"))
	self.m_ReadPart:SetActive(false)
end

function CLostBookPage.OnMapBookCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdateEquipBook then
		self:UpdateEquipBook(oCtrl.m_EventData)
	end
end

function CLostBookPage.OnItemCtrlEvent(self, oCtrl)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	local stramount = string.format("时光钥匙所持数×%d", amount)
	self.m_ChapterLabel:SetText(stramount)
end

function CLostBookPage.RefreshMainPart(self)
	self.m_Page = 1
	self.m_BookBG:SetActive(true)
	local bookList = self:GetEquipBookList()
	self.m_BookList = bookList
	self.m_MaxPage = math.floor((#bookList - 1)/self.m_PageAmount) + 1
	self:RefreshPage()
end

function CLostBookPage.RefreshPage(self)
	local bookList = self.m_BookList
	for i = 1, self.m_PageAmount do
		local idx = (self.m_Page - 1) * self.m_PageAmount + i
		local oBox = self.m_GridList[i]
		if bookList[idx] then
			oBox:SetActive(true)
			oBox:RefreshData(bookList[idx])
			oBox:AddUIEvent("click", callback(self, "OnClickBook", bookList[idx]))
		else
			oBox:SetActive(false)
		end
	end
	self.m_PageDnBtn:SetActive(self.m_Page < self.m_MaxPage)
	self.m_PageUpBtn:SetActive(self.m_Page > 1)
	self.m_LeftPageLabel:SetText(string.format("%d/%d", self.m_Page*2, self.m_MaxPage*2))
	self.m_RightPageLabel:SetText(string.format("%d/%d", self.m_Page*2-1, self.m_MaxPage*2))
end

function CLostBookPage.RefreshRead(self, iChapter)
	self.m_ChapterPart:SetActive(false)
	self.m_MainPart:SetActive(false)
	self.m_ReadPart:SetActive(true)
	self.m_BookBG:SetActive(false)

	self.m_ReadTitle:SetActive(true)
	self.m_ReadContent:SetActive(true)
	self.m_ContentTitle:SetActive(true)
	self.m_ReadTitleTexture:SetActive(true)
	self.m_ReadContentTexture:SetActive(false)
	local chapterdata = data.mapbookdata.CHAPTER[iChapter]
	self.m_ReadContentStr = chapterdata.content
	self.m_ReadContentTitleStr = chapterdata.name.." "..chapterdata.title
	self.m_ReadTitle:SetText(chapterdata.name)
	self.m_ReadTitle.m_Tween:ResetToBeginning()
	self.m_ReadTitle.m_Tween:Play(true)

	if not self.m_TitleEffect then
		self.m_TitleEffect = CEffect.New("Effect/UI/ui_eff_1137/Prefabs/ui_eff_1137.prefab", self:GetLayer(), false)
		self.m_TitleEffect:SetParent(self.m_ReadTitleTexture.m_Transform)
	end

	self.m_TitleEffect:SetActive(false)
	self.m_TitleEffect:SetActive(true)
	self.m_ReadTitle2:SetActive(false)
	local function delay()
		self.m_ReadTitle2:SetActive(true)
		self.m_ReadTitle2.m_Tween1:ResetToBeginning()
		self.m_ReadTitle2.m_Tween2:ResetToBeginning()
		self.m_ReadTitle2.m_Tween1:Play(true)
		self.m_ReadTitle2.m_Tween2:Play(true)
		self.m_ReadTitle2:SetText(chapterdata.title)
		self.m_CalcaLabel:SetText(chapterdata.title)
		local w = self.m_CalcaLabel:GetWidth()
		self.m_CalcaLabel:SetText("")
		local v = self.m_ReadTitle2:GetLocalPos()
		v.x = - w / 2
		self.m_ReadTitle2:SetLocalPos(v)
	end
	delay()
	self:DoReadEffect()
end

function CLostBookPage.DoReadEffect(self)
	if self.m_ReadTimer then
		Utils.DelTimer(self.m_ReadTimer)
	end
	self.m_ReadTimerCnt = 0
	local function update()
		self.m_ReadTimerCnt = self.m_ReadTimerCnt + 1
		if self.m_ReadTimerCnt > 15 then
			if self.m_ReadTimerCnt >= 25 then
				self:OnReadTitleFinish()
				return
			else
				self:OnReadTitleFinish((self.m_ReadTimerCnt-15) / 10)
				return true
			end
		else
			return true
		end
	end
	self.m_ReadTimer = Utils.AddTimer(update, 0.1, 1)
end

function CLostBookPage.RefreshProgress(self)
	local bookList = g_MapBookCtrl:GetEquipBookList()
	local total = #bookList
	local amount = 0
	for _, oBook in ipairs(bookList) do
		if oBook.unlock == 1 and
			oBook.repair == 1 and
			oBook.show == 1 and
			oBook.entry_name == 1 then
			amount = amount + 1
		end
	end
	self.m_TotalProgress:SetText(string.format("%d/%d", amount, total))
end

function CLostBookPage.RefreshChapter(self, oData)
	self.m_ChapterID = oData.id
	self.m_ChapterTargetID = oData.target_id
	self.m_ChapterGrid:Clear()
	self.m_ChapterList = oData.chapter
	local lastBox = nil
	for _, iChapter in ipairs(oData.chapter_list) do
		local box = self:CreateChapterBox(iChapter)
		if lastBox then
			box:SetFrontBox(lastBox)
		end
		self.m_ChapterGrid:AddChild(box)
		lastBox = box
	end
	self.m_ChapterGrid:Reposition()
	self.m_EmptyChapterLabel:SetActive(#oData.chapter_list == 0)
	self.m_EquipNameLabel:SetText(oData.name)
	local pdata = data.partnerequipdata.EQUIPTYPE[oData.target_id]
	if not pdata then
		return
	end
	local sPath = string.format("Texture/PartnerEquip/bg_fw_"..pdata["icon"]..".png")
	self.m_PartnerTexture:SetActive(false)
	self.m_PartnerTexture:LoadPath(sPath , function() self.m_PartnerTexture:SetActive(true) end)
end

function CLostBookPage.CreateChapterBox(self, iChapter)
	local chapterdata = {
		id = iChapter,
		unlock = 0,
		read = 0,
		condition = {}
	}
	for _, oData in ipairs(self.m_ChapterList) do
		if oData.id == iChapter then
			chapterdata = oData
			break
		end
	end
	local box = self.m_ChapterBox:Clone()
	box:SetActive(true)
	box:RefreshData(chapterdata)
	box:AddUIEvent("click", callback(self, "OnClickChapter", iChapter, chapterdata.read))
	return box
end

function CLostBookPage.UpdateEquipBook(self, oBook)
	for i = 1, self.m_PageAmount do
		local box = self.m_GridList[i]
		if box.m_ID == oBook.id then
			box:UpdateData(oBook)
			box:AddUIEvent("click", callback(self, "OnClickBook", oBook))
			break
		end
	end

	if self.m_ChapterID == oBook.id then
		self:RefreshChapter(oBook)
	end
	self:RefreshProgress()
end

function CLostBookPage.OnPageUp(self)
	self.m_Page = math.max(self.m_Page - 1, 1)
	self:RefreshPage()
end

function CLostBookPage.OnPageDn(self)
	self.m_Page = math.max(self.m_Page + 1, self.m_MaxPage)
	self:RefreshPage()
end

function CLostBookPage.OnShowFilter(self)
	CLostBookFilterView:ShowView(function(oView)
		oView:SetType("LostBook")
		oView:SetLastList(self.m_KeyList, callback(self, "RefreshFilter"))
	end)
end

function CLostBookPage.GetEquipBookList(self)
	local bookList = self.m_EquipBookList or  g_MapBookCtrl:GetEquipBookList()
	local headlist = {}
	local taillist = {}
	for _, oBook in ipairs(bookList) do
		if oBook.red_point and oBook.red_point > 1 then
			table.insert(headlist, oBook)
		else
			table.insert(taillist, oBook)
		end
	end
	table.extend(headlist, taillist)
	return  headlist
end

function CLostBookPage.OnClickBook(self, oData)
	if oData.unlock == 0 then
		if #oData.condition == #oData.condition_list then
			self:UnlockBook(oData)
		else
			g_NotifyCtrl:FloatMsg("该孤本已丢失，需要先完成解锁条件")
		end
	else
		g_MapBookCtrl:OnClickBook(oData)
		self.m_ChapterPart:SetActive(true)
		self.m_MainPart:SetActive(false)
		self.m_ReadPart:SetActive(false)
		self:RefreshChapter(oData)
	end
end

function CLostBookPage.UnlockBook(self, oBook)
	local windowConfirmInfo = {
		msg = "该禁忌的佚书上附着有禁术，可使用1个时光钥匙解开封印",
		okStr = "解封",
		cancelStr = "放弃",
		title = "佚书解封",
		cancelCallback = function() end,
		okCallback = function()
			nethandbook.C2GSUnlockBook(oBook.id)
		end
	}
	CMapBookConfirmView:ShowView(function(oView)
		oView:InitArg(windowConfirmInfo)
	end)
end

function CLostBookPage.OnClickChapter(self, iChapter, bRead, box)
	local chapterdata = nil
	for _, oChapter in ipairs(self.m_ChapterList) do
		if oChapter.id == iChapter then
			chapterdata = oChapter
			break
		end
	end
	if chapterdata then
		if data.mapbookdata.CHAPTER[iChapter]["content"] == " " then
			g_NotifyCtrl:FloatMsg("该佚文尚未重新誊写，暂时无法查看")
			return
		end
		if box.m_FrontLock then
			g_NotifyCtrl:FloatMsg("上一话未曾阅读")
			return
		end
		local totalconditon = #data.mapbookdata.CHAPTER[iChapter].condition
		if chapterdata.unlock == 0 then
			
			if #chapterdata.condition == totalconditon then
				--可解锁
				self:RepairChapter(iChapter)
			else
			end
		else
			if #chapterdata.condition == totalconditon then
				if bRead == 0 then
					nethandbook.C2GSReadChapter(iChapter)
				end
				self:RefreshRead(iChapter)
			else
				g_NotifyCtrl:FloatMsg("该孤本暂时无法查看")
			end
		end
	end
	
end

function CLostBookPage.RepairChapter(self, iChapter)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	local cost = data.mapbookdata.CHAPTER[iChapter].unlock_keys
	local msg = string.format("该佚文有破损，使用%d个时光钥匙对其进行修补后方能阅读", cost)
	local windowConfirmInfo = {
		msg = msg,
		okStr = "修补",
		title = "佚书修补",
		cancelStr = "取消",
		cancelCallback = function() end,
		okCallback = function()
			nethandbook.C2GSUnlockChapter(iChapter)
		end
	}
	CMapBookConfirmView:ShowView(function(oView)
		oView:InitArg(windowConfirmInfo)
	end)
end

function CLostBookPage.OnReadTitleFinish(self, p)
	local bShow = self.m_ReadContentTexture:GetActive()
	if p then
		self.m_ReadTitleTexture:SetActive(true)
		self.m_ReadTitleTexture:SetAlpha((1-p)*(1-p))
		self.m_ReadContentTexture:SetActive(true)
		self.m_ReadContentTexture:SetAlpha(p*p)
	else
		self.m_ReadTitleTexture:SetActive(false)
		self.m_ReadTitleTexture:SetAlpha(1)
		self.m_ReadContentTexture:SetActive(true)
		self.m_ReadContentTexture:SetAlpha(1)
	end
	if not bShow then
		self.m_ContentTitle:SetText(self.m_ReadContentTitleStr)
		self.m_ReadContent:SetText(self.m_ReadContentStr)
		self.m_ReadScrollView:ResetPosition()
	end
end

function CLostBookPage.OnBack(self)
	g_MapBookCtrl:OnClickMenu(2)
	self.m_ParentView:ShowMainPage()
end

function CLostBookPage.OnBackEquip(self)
	g_MapBookCtrl:OnClickMenu(2)
	if self.m_ChapterPart:GetActive() then
		self.m_ParentView:ShowEquipPage(self.m_ChapterTargetID)
	else
		self.m_ParentView:ShowEquipPage()
	end

end

function CLostBookPage.OnBackChapter(self)
	self.m_BookBG:SetActive(true)
	self.m_ChapterPart:SetActive(true)
	self.m_MainPart:SetActive(false)
	self.m_ReadPart:SetActive(false)
end

function CLostBookPage.OnBackMain(self)
	self.m_ChapterPart:SetActive(false)
	self.m_MainPart:SetActive(true)
	self.m_ReadPart:SetActive(false)
end

function CLostBookPage.RefreshFilter(self, keyList)
	local newlist  = {}
	local bookList = g_MapBookCtrl:GetEquipBookList()
	self.m_KeyList = keyList
	for _, oBook in ipairs(bookList) do
		local addflag = true
		for _, v in ipairs(keyList) do
			if v == "绘像已修" then
				addflag = self:CheckRepair(oBook, true)
			
			elseif v == "名字已录" then
				addflag = self:CheckEntryname(oBook, true)
			
			elseif v == "绘像未修" then
				addflag = self:CheckRepair(oBook, false)
			
			elseif v == "名字未录" then
				addflag = self:CheckEntryname(oBook, false)

			elseif v == "未解锁" then
				addflag = self:CheckLock(oBook, false)
			
			elseif v == "可解锁" then
				addflag = self:CheckCanLock(oBook, true)
			
			elseif v == "已解锁" then
				addflag = self:CheckLock(oBook, true)
			
			elseif v == "已解未阅" then
				addflag = self:CheckLock(oBook, true) and self:CheckRead(oBook, false)

			elseif v == "已阅读" then
				addflag = self:CheckLock(oBook, true) and self:CheckRead(oBook, true)

			elseif table.index({"他", "她", "它"}, v) then
				addflag = self:CheckSex(oBook, v)
			end

			if addflag == false then
				break
			end
		end
		if addflag == true then
			table.insert(newlist, oBook)
		end
	end
	local sortKey = nil
	if keyList[1] == "高至低" then
		table.sort(newlist, function(a, b)
			return CLostBookMainBox:GetProgress(a) > CLostBookMainBox:GetProgress(b)
		end)
	elseif keyList[1] == "低至高" then
		table.sort(newlist, function(a, b)
			return CLostBookMainBox:GetProgress(a) < CLostBookMainBox:GetProgress(b)
		end)
	end

	self:ShowFilterKey(keyList)
	self.m_EquipBookList =  newlist
	self:RefreshMainPart()
end

function CLostBookPage.ShowFilterKey(self, keyList)
	local textlist = {}
	local templist = {}
	for i, text in ipairs(keyList) do
		if i == 1 then
			if text == "高至低" then
				table.insert(templist, "佚存度高")
			elseif text == "低至高" then
				table.insert(templist, "佚存度低")
			end
		else
			if text ~= "无指定" then
				table.insert(templist, text)
			end
		end
		if #templist == 2 then
			table.insert(textlist, 1, templist)
			templist = {}
		end
	end
	if #templist > 0 then
		table.insert(textlist, 1, templist)
	end
	
	if #textlist > 0 then
		self.m_FilterSelSpr:SetActive(true)
	else
		self.m_FilterSelSpr:SetActive(false)
		textlist = {{"无检索"}}
	end
	self.m_FilterGrid:Clear()
	for _, list in ipairs(textlist) do
		local label = self.m_FilterLabel:Clone()
		label:SetActive(true)
		label:SetText(table.concat(list, "·"))
		self.m_FilterGrid:AddChild(label)
	end
	self.m_FilterGrid:Reposition()
end

function CLostBookPage.CheckEntryname(self, oBook, bValue)
	local bflag = oBook.entry_name == 1
	return bflag == bValue
end

function CLostBookPage.CheckLock(self, oBook, bValue)
	local bflag = oBook.unlock == 1
	return bflag == bValue
end

function CLostBookPage.CheckRepair(self, oBook, bValue)
	local bflag = oBook.repair == 1
	return bflag == bValue
end

function CLostBookPage.CheckCanLock(self, oBook)
	local bflag = false
	if oBook.unlock == 0 and #oBook.condition == #oBook.condition_list then
		bflag = true
	end
	return bflag
end

function CLostBookPage.CheckRead(self, oBook, bValue)
	local bflag = true
	for _, oChapter in ipairs(oBook.chapter) do
		if oChapter.unlock == 1 and oChapter.read == 1 then
			
		else
			bflag = false
			break
		end
	end
	return bflag == bValue
end

function CLostBookPage.CheckSex(self, oBook, sSex)
	local iType = oBook.target_id
	local pdata = data.partnerequipdata.EQUIPTYPE[iType]
	local list = {""}
	if pdata then
		local iSex = 0
		if sSex == "它" then
			iSex = 0
		elseif sSex == "他" then
			iSex = 1
		elseif sSex == "她" then
			iSex = 2
		end
		if iSex == pdata["sex"] then
			return true
		end
	end
	return false
end

return CLostBookPage