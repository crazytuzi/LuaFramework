local CPersonBookPage = class("CPersonBookPage", CPageBase)

function CPersonBookPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPersonBookPage.OnInitPage(self)
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
end

function CPersonBookPage.InitMainPart(self)
	local mainpart = self.m_MainPart
	self.m_MainGrid = mainpart:NewUI(1, CBox)
	self.m_PersonBookBox = mainpart:NewUI(2, CPersonBookBox)
	self.m_PageDnBtn = mainpart:NewUI(3, CButton)
	self.m_PageUpBtn = mainpart:NewUI(4, CButton)
	self.m_FilterBox = mainpart:NewUI(5, CBox)
	self.m_FilterSelSpr = self.m_FilterBox:NewUI(1, CSprite)
	self.m_FilterLabel = self.m_FilterBox:NewUI(2, CLabel)

	self.m_TotalProgress = mainpart:NewUI(6, CLabel)
	self.m_LeftPageLabel = mainpart:NewUI(7, CLabel)
	self.m_RightPageLabel = mainpart:NewUI(8, CLabel)
	self:InitBookGrid()
	self.m_PersonBookBox:SetActive(false)
	self.m_PageUpBtn:AddUIEvent("click", callback(self, "OnPageUp"))
	self.m_PageDnBtn:AddUIEvent("click", callback(self, "OnPageDn"))
	--self.m_FilterBtn:AddUIEvent("click", callback(self, "OnShowFilter"))
	self.m_MainPart:SetActive(true)
end

function CPersonBookPage.InitBookGrid(self)
	self.m_GridList = {}
	local iStartX, iStartY = 0, 0
	local iDeltaX, iDeltaY = -172, -270
	for i = 1, 10 do
		self.m_GridList[i] = self.m_PersonBookBox:Clone()
		self.m_GridList[i]:SetParent(self.m_MainGrid.m_Transform)
		local idxx = math.floor((i-1)/2)
		local idxy = (i-1) % 2
		if i == 5 then
			iStartX = -35
		end
		self.m_GridList[i]:SetLocalPos(Vector3.New(iStartX + idxx*iDeltaX, iStartY + idxy*iDeltaY, 0))
	end
end

function CPersonBookPage.InitChapterPart(self)
	self.m_ChapterGrid = self.m_ChapterPart:NewUI(1, CGrid)
	self.m_ChapterBox = self.m_ChapterPart:NewUI(2, CPersonChapterBox)
	self.m_ChapterLabel = self.m_ChapterPart:NewUI(3, CLabel)
	self.m_BackMainBtn = self.m_ChapterPart:NewUI(4, CButton)
	self.m_PersonNameLabel = self.m_ChapterPart:NewUI(5, CLabel)
	self.m_PersonTexture = self.m_ChapterPart:NewUI(7, CTexture)
	self.m_ChapterBox:SetActive(false)
	self.m_ChapterPart:SetActive(false)

	self.m_ChapterBox:SetActive(false)
	self.m_ChapterPart:SetActive(false)
	self.m_BackMainBtn:AddUIEvent("click", callback(self, "OnBackMain"))
end

function CPersonBookPage.InitReadPart(self)
	self.m_ReadTitle = self.m_ReadPart:NewUI(1, CLabel)
	self.m_ReadContent = self.m_ReadPart:NewUI(2, CLabel)
	self.m_BackChapterBtn = self.m_ReadPart:NewUI(3, CButton)
	self.m_ReadScrollView = self.m_ReadPart:NewUI(4, CScrollView)
	self.m_ContentTitle = self.m_ReadPart:NewUI(5, CLabel)
	self.m_ReadTitleTexture = self.m_ReadPart:NewUI(6, CTexture)
	self.m_ReadContentTexture = self.m_ReadPart:NewUI(7, CTexture)
	self.m_ReadTitle2 = self.m_ReadPart:NewUI(8, CLabel)

	self.m_BackChapterBtn:AddUIEvent("click", callback(self, "OnBackChapter"))
	self.m_ReadPart:SetActive(false)
end

function CPersonBookPage.OnMapBookCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdatePartnerBook then
		self:UpdatePartnerBook(oCtrl.m_EventData)
	end
end

function CPersonBookPage.RefreshMainPart(self)
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

function CPersonBookPage.RefreshPage(self)
	g_GuideCtrl:AddGuideUI("mapbook_person_1007_reward_btn")
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

	local guide_ui = {"mapbook_person_1007_reward_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)

	self.m_PageDnBtn:SetActive(self.m_Page < self.m_MaxPage)
	self.m_PageUpBtn:SetActive(self.m_Page > 1)
	self.m_LeftPageLabel:SetText(string.format("%d/%d", self.m_Page*2, self.m_MaxPage*2))
	self.m_RightPageLabel:SetText(string.format("%d/%d", self.m_Page*2-1, self.m_MaxPage*2))
end

function CPersonBookPage.RefreshRead(self, iChapter)
	self.m_ChapterPart:SetActive(false)
	self.m_MainPart:SetActive(false)
	self.m_ReadPart:SetActive(true)

	self.m_ReadTitle:SetActive(true)
	self.m_ReadContent:SetActive(false)
	local chapterdata = data.mapbookdata.CHAPTER[iChapter]
	local text = chapterdata.name.."\n"..chapterdata.title.."\n  "
	self.m_ReadContentStr = chapterdata.content
	self.m_ReadTitle:SetText(chapterdata.name)
	self.m_ReadTitle2:SetText(chapterdata.title)
	self.m_ReadTitle2:SetAlpha(0)
	self:DoReadEffect()
end

function CPersonBookPage.DoReadEffect(self)
	if self.m_ReadTimer then
		Utils.DelTimer(self.m_ReadTimer)
	end
	self.m_ReadTimerCnt = 0
	local function update()
		self.m_ReadTitle2:SetAlpha(self.m_ReadTimerCnt/15)
		self.m_ReadTimerCnt = self.m_ReadTimerCnt + 1
		if self.m_ReadTimerCnt > 15 then
			self:OnReadTitleFinish()
			return false
		else
			return true
		end
	end
	self.m_ReadTimer = Utils.AddTimer(update, 0.1, 0)
end

function CPersonBookPage.CreateBookBox(self, oData)
	local oBox = self.m_PersonBookBox:Clone()
	oBox:SetActive(true)
	oBox:RefreshData(oData)
	oBox:AddUIEvent("click", callback(self, "OnClickBook", oData))
	return oBox
end

function CPersonBookPage.RefreshChapter(self, oData)
	self.m_ChapterID = oData.id
	self.m_ChapterGrid:Clear()
	self.m_ChapterList = oData.chapter
	for _, iChapter in ipairs(oData.chapter_list) do
		local box = self:CreateChapterBox(iChapter)
		self.m_ChapterGrid:AddChild(box)
	end
	self.m_ChapterGrid:Reposition()
end

function CPersonBookPage.CreateChapterBox(self, iChapter)
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
	if chapterdata.unlock == 0 then
		box:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("条件尚未完成，无法开启该故事书。") end)
	else
		box:AddUIEvent("click", callback(self, "OnClickChapter", iChapter, chapterdata.read))
	end
	return box
end

function CPersonBookPage.UpdatePartnerBook(self, oBook)
	for i = 1, 10 do
		local box = self.m_GridList[i]
		if box.m_ID == oBook.id then
			box:RefreshData(oBook)
			break
		end
	end

	if self.m_ChapterID == oBook.id then
		self:RefreshChapter(oBook)
	end
end

function CPersonBookPage.OnPageUp(self)
	self.m_Page = math.max(self.m_Page - 1, 1)
	self:RefreshPage()
end

function CPersonBookPage.OnPageDn(self)
	self.m_Page = math.min(self.m_Page + 1, self.m_MaxPage)
	self:RefreshPage()
end

function CPersonBookPage.OnShowFilter(self)
	g_NotifyCtrl:FloatMsg("佚书数量不足，不需要筛选")
end

function CPersonBookPage.RefreshFilter(self, filterList)
	self.m_FilterList = filterList
end

function CPersonBookPage.GetBookList(self)
	local bookList = g_MapBookCtrl:GetPersonBookList()
	if not self.m_FilterList then
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
		return headlist
	end
end

function CPersonBookPage.OnClickBook(self, oData)
	return
end

function CPersonBookPage.OnClickChapter(self, iChapter, bRead)
	if bRead == 0 then
		nethandbook.C2GSReadChapter(iChapter)
	end
	self:RefreshRead(iChapter)
end

function CPersonBookPage.OnReadTitleFinish(self)
	self.m_ReadTitleTexture:SetActive(false)
	self.m_ReadContentTexture:SetActive(true)
	self.m_ReadTitle:SetActive(false)
	self.m_ContentTitle:SetActive(true)
	self.m_ReadContent:SetActive(true)
	self.m_ContentTitle:SetText(self.m_ReadContentTitleStr)
	self.m_ReadContent:SetText(self.m_ReadContentStr)
	self.m_ReadScrollView:ResetPosition()
end

function CPersonBookPage.OnBackChapter(self)
	self.m_ChapterPart:SetActive(true)
	self.m_MainPart:SetActive(false)
	self.m_ReadPart:SetActive(false)
	self.m_BookBG:SetActive(true)
end

function CPersonBookPage.OnBackMain(self)
	self.m_ChapterPart:SetActive(false)
	self.m_MainPart:SetActive(true)
	self.m_ReadPart:SetActive(false)
end

function CPersonBookPage.OnBack(self)
	g_MapBookCtrl:OnClickMenu(3)
	self.m_ParentView:ShowMainPage()
end

function CPersonBookPage.OnBackPartner(self)
	self.m_ParentView:ShowPartnerPage()
end


return CPersonBookPage