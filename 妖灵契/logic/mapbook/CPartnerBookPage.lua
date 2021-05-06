local CPartnerBookPage = class("CPartnerBookPage", CPageBase)
--符文佚书

function CPartnerBookPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerBookPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_MainPart = self:NewUI(2, CBox)
	self.m_ChapterPart = self:NewUI(3, CBox)
	self.m_ReadPart = self:NewUI(4, CBox)
	self.m_PartnerBtn = self:NewUI(5, CButton)
	self.m_BookBG = self:NewUI(6, CObject)
	self:InitMainPart()
	self:InitChapterPart()
	self:InitReadPart()
	self:RefreshMainPart()
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnBackPartner"))
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookCtrlEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTaskEvent"))
end

function CPartnerBookPage.OnShowPage(self)
	self.m_PartnerBookList = nil
	self.m_KeyList = nil
	self:ShowFilterKey({})
	self:RefreshMainPart()
	self:OnBackMain()
end

function CPartnerBookPage.InitMainPart(self)
	local mainpart = self.m_MainPart
	self.m_MainGrid = mainpart:NewUI(1, CBox)
	self.m_PartnerBookBox = mainpart:NewUI(2, CPartnerBookBox)
	self.m_PageDnBtn = mainpart:NewUI(3, CButton)
	self.m_PageUpBtn = mainpart:NewUI(4, CButton)
	self.m_FilterBox = mainpart:NewUI(5, CBox)
	self.m_FilterSelSpr = self.m_FilterBox:NewUI(1, CSprite)
	self.m_FilterLabel = self.m_FilterBox:NewUI(2, CLabel)
	self.m_FilterGrid = self.m_FilterBox:NewUI(3, CGrid)

	self.m_TotalProgress = mainpart:NewUI(6, CLabel)
	self.m_LeftPageLabel = mainpart:NewUI(7, CLabel)
	self.m_RightPageLabel = mainpart:NewUI(8, CLabel)
	self.m_FilterLabel:SetActive(false)
	self.m_PartnerBookBox:SetActive(false)
	self:InitBookGrid()
	self.m_PageUpBtn:AddUIEvent("click", callback(self, "OnPageUp"))
	self.m_PageDnBtn:AddUIEvent("click", callback(self, "OnPageDn"))
	self.m_FilterBox:AddUIEvent("click", callback(self, "OnShowFilter"))
	self.m_MainPart:SetActive(true)
end

function CPartnerBookPage.InitBookGrid(self)
	self.m_GridList = {}
	local iStartX, iStartY = 0, 0
	local iDeltaX, iDeltaY = -172, -270
	for i = 1, 10 do
		self.m_GridList[i] = self.m_PartnerBookBox:Clone()
		self.m_GridList[i]:SetParent(self.m_MainGrid.m_Transform)
		local idxx = math.floor((i-1)/2)
		local idxy = (i-1) % 2
		if i == 5 then
			iStartX = -35
		end
		self.m_GridList[i]:SetLocalPos(Vector3.New(iStartX + idxx*iDeltaX, iStartY + idxy*iDeltaY, 0))
	end
end

function CPartnerBookPage.InitChapterPart(self)
	self.m_ChapterGrid = self.m_ChapterPart:NewUI(1, CGrid)
	self.m_ChapterBox = self.m_ChapterPart:NewUI(2, CPartnerChapterBox)
	self.m_ChapterLabel = self.m_ChapterPart:NewUI(3, CLabel)
	self.m_BackMainBtn = self.m_ChapterPart:NewUI(4, CButton)
	self.m_PartnerNameLabel = self.m_ChapterPart:NewUI(5, CLabel)
	self.m_EmptyChapterLabel = self.m_ChapterPart:NewUI(6, CLabel)
	self.m_PartnerTexture = self.m_ChapterPart:NewUI(7, CTexture)
	self.m_ChapterBox:SetActive(false)
	self.m_ChapterPart:SetActive(false)
	self.m_EmptyChapterLabel:SetActive(false)
	self.m_BackMainBtn:AddUIEvent("click", callback(self, "OnBackMain"))
end

function CPartnerBookPage.InitReadPart(self)
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

function CPartnerBookPage.OnMapBookCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdatePartnerBook then
		self:UpdatePartnerBook(oCtrl.m_EventData)
	end
end

function CPartnerBookPage.OnTaskEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.RefreshAllTaskBox or
	   oCtrl.m_EventID == define.Task.Event.RefreshPartnerTaskBox then	
		self:DelayCall(0, "RefreshPage")
	end
end

function CPartnerBookPage.RefreshMainPart(self)
	self.m_Page = 1
	self.m_PageAmount = 10
	self.m_BookBG:SetActive(true)
	local bookList = self:GetBookList()
	self.m_BookList = bookList
	self.m_MaxPage = math.floor((#bookList - 1)/self.m_PageAmount) + 1
	self:RefreshPage()
	local amount = 0
	for _, oBook in ipairs(bookList) do
		if oBook.unlock == 1 then
			amount = amount + 1
		end
	end
	self.m_TotalProgress:SetText(string.format("%d/%d", amount, #bookList))
end

function CPartnerBookPage.RefreshPage(self)
	local bookList = self.m_BookList
	for i = 1, self.m_PageAmount do
		local idx = (self.m_Page - 1) * self.m_PageAmount + i
		local oBox = self.m_GridList[i]
		if bookList[idx] then
			oBox:SetActive(true)
			oBox:RefreshData(bookList[idx])
			oBox:AddUIEvent("click", callback(self, "OnClickBook", bookList[idx]))

			if bookList[idx].name == "重华" then
				g_GuideCtrl:AddGuideUI("mapbook_partner_photo_1", oBox)
			end				
		else
			oBox:SetActive(false)
		end
	end
	self.m_PageDnBtn:SetActive(self.m_Page < self.m_MaxPage)
	self.m_PageUpBtn:SetActive(self.m_Page > 1)
	self.m_LeftPageLabel:SetText(string.format("%d/%d", self.m_Page*2, self.m_MaxPage*2))
	self.m_RightPageLabel:SetText(string.format("%d/%d", self.m_Page*2-1, self.m_MaxPage*2))
end

function CPartnerBookPage.RefreshRead(self, iChapter)
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

function CPartnerBookPage.DoReadEffect(self)
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

function CPartnerBookPage.RefreshChapter(self, oData)
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
		lastBox = box
		self.m_ChapterGrid:AddChild(box)
	end
	self.m_EmptyChapterLabel:SetActive(#oData.chapter_list == 0)
	self.m_ChapterGrid:Reposition()
	self.m_PartnerNameLabel:SetText(oData.name)
	local pdata = data.partnerdata.DATA[oData.target_id]
	self.m_PartnerTexture:SetActive(false)
	self.m_PartnerTexture:LoadFullPhoto(pdata["shape"], function () 
		self.m_PartnerTexture:SnapFullPhoto(pdata["shape"], 1)
		self.m_PartnerTexture:SetActive(true)
	end)
end

function CPartnerBookPage.CreateChapterBox(self, iChapter)
	local chapterdata = {
		id = iChapter,
		unlock = 0,
		read = 0,
		condition = {}
	}
	for _, oData in ipairs(self.m_ChapterList) do
		if oData.id == iChapter then
			chapterdata = table.update(chapterdata, oData)
			break
		end
	end
	local box = self.m_ChapterBox:Clone()
	box:SetActive(true)
	box:RefreshData(chapterdata)
	local scondtion = chapterdata.condition or {}
	if chapterdata.unlock == 0 or #scondtion < #data.mapbookdata.CHAPTER[iChapter].condition then
		box:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("条件尚未完成，无法开启该故事书。") end)
	else
		box:AddUIEvent("click", callback(self, "OnClickChapter", iChapter, chapterdata.read))
	end
	return box
end

function CPartnerBookPage.UpdatePartnerBook(self, oBook)
	for i = 1, 10 do
		local box = self.m_GridList[i]
		if box.m_ID == oBook.id then
			box:RefreshData(oBook)
			box:AddUIEvent("click", callback(self, "OnClickBook", oBook))
			break
		end
	end

	if self.m_ChapterID == oBook.id then
		self:RefreshChapter(oBook)
	end
	for i =1, #self.m_BookList do
		if self.m_BookList[i].id == oBook.id then
			self.m_BookList[i] = oBook
			break
		end
	end
end

function CPartnerBookPage.OnPageUp(self)
	self.m_Page = math.max(self.m_Page - 1, 1)
	self:RefreshPage()
end

function CPartnerBookPage.OnPageDn(self)
	self.m_Page = math.min(self.m_Page + 1, self.m_MaxPage)
	self:RefreshPage()
end

function CPartnerBookPage.OnShowFilter(self)
	CLostBookFilterView:ShowView(function(oView)
		oView:SetType("PartnerBook")
		oView:SetLastList(self.m_KeyList, callback(self, "RefreshFilter"))
	end)
end

function CPartnerBookPage.GetBookList(self)
	local bookList = self.m_PartnerBookList or g_MapBookCtrl:GetPartnerBookList()
	local headlist = {}
	local taillist = {}
	for _, oBook in ipairs(bookList) do
		if oBook.red_point and oBook.red_point > 0 then
			table.insert(headlist, oBook)
		else
			table.insert(taillist, oBook)
		end
	end
	table.extend(headlist, taillist)
	return headlist
end

function CPartnerBookPage.OnClickBook(self, oData)
	if oData.unlock == 0 then
		g_NotifyCtrl:FloatMsg("未获得该伙伴，无法取阅该资料")
	else
		g_MapBookCtrl:OnClickBook(oData)
		self.m_ChapterPart:SetActive(true)
		self.m_MainPart:SetActive(false)
		self:RefreshChapter(oData)
	end
end

function CPartnerBookPage.OnClickChapter(self, iChapter, bRead, box)
	if data.mapbookdata.CHAPTER[iChapter]["content"] == " " then
		g_NotifyCtrl:FloatMsg("该佚文尚未重新誊写，暂时无法查看")
		return
	end
	if box.m_FrontLock then
		g_NotifyCtrl:FloatMsg("上一话未曾阅读")
		return
	end
	if bRead == 0 then
		nethandbook.C2GSReadChapter(iChapter)
	end
	self:RefreshRead(iChapter)
end

function CPartnerBookPage.OnReadTitleFinish(self, p)
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

function CPartnerBookPage.OnBackChapter(self)
	self.m_ChapterPart:SetActive(true)
	self.m_MainPart:SetActive(false)
	self.m_ReadPart:SetActive(false)
	self.m_BookBG:SetActive(true)
end

function CPartnerBookPage.OnBackMain(self)
	self.m_ChapterPart:SetActive(false)
	self.m_MainPart:SetActive(true)
	self.m_ReadPart:SetActive(false)
end

function CPartnerBookPage.OnBack(self)
	g_MapBookCtrl:OnClickMenu(1)
	self.m_ParentView:ShowMainPage()
end

function CPartnerBookPage.OnBackPartner(self)
	g_MapBookCtrl:OnClickMenu(1)
	if self.m_ChapterPart:GetActive() then
		self.m_ParentView:ShowPartnerPage(self.m_ChapterTargetID)
	else
		self.m_ParentView:ShowPartnerPage()
	end
end

function CPartnerBookPage.RefreshFilter(self, keyList)
	local newlist  = {}
	local bookList = g_MapBookCtrl:GetPartnerBookList()
	self.m_KeyList = keyList
	for _, oBook in ipairs(bookList) do
		local addflag = true
		for _, v in ipairs(keyList) do
			if v == "未相遇" then
				addflag = self:CheckLock(oBook, false)
			
			elseif v == "已相遇" then
				addflag = self:CheckLock(oBook, true)
			
			elseif v == "相遇未阅" then
				addflag = self:CheckLock(oBook, true) and self:CheckRead(oBook, false)

			elseif v == "已阅读" then
				addflag = self:CheckLock(oBook, true) and self:CheckRead(oBook, true)

			elseif table.index({"精英", "传说"}, v) then
				addflag = self:CheckRare(oBook, v)

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
			return CPartnerBookBox:GetProgress(a) > CPartnerBookBox:GetProgress(b)
		end)
	elseif keyList[1] == "低至高" then
		table.sort(newlist, function(a, b)
			return CPartnerBookBox:GetProgress(a) < CPartnerBookBox:GetProgress(b)
		end)
	end
	self.m_PartnerBookList = newlist
	self:RefreshMainPart()
end

function CPartnerBookPage.ShowFilterKey(self, keyList)
	local textlist = {}
	local templist = {}
	for i, text in ipairs(keyList) do
		if i == 1 then
			if text == "高至低" then
				table.insert(templist, "章节进度高")
			elseif text == "低至高" then
				table.insert(templist, "章节进度低")
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

function CPartnerBookPage.CheckLock(self, oBook, bValue)
	local bflag = oBook.unlock == 1
	return bflag == bValue
end

function CPartnerBookPage.CheckRead(self, oBook, bValue)
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

function CPartnerBookPage.CheckRare(self, oBook, sRare)
	local iPartnerType = oBook.target_id
	local pdata = data.partnerdata.DATA[iPartnerType]
	local iRare = 1
	if sRare == "传说" then
		iRare = 2
	end
	if pdata then
		if iRare == pdata["rare"] then
			return true
		end
	end
	return false
end

function CPartnerBookPage.CheckSex(self, oBook, sSex)
	local iPartnerType = oBook.target_id
	local pdata = data.partnerdata.DATA[iPartnerType]
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

return CPartnerBookPage