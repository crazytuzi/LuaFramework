local CMapBookCityPage = class("CMapBookCityPage", CPageBase)

function CMapBookCityPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookCityPage.OnInitPage(self)
	self.m_EventBox = self:NewUI(1, CBox)
	self.m_ExpandBtn = self:NewUI(2, CButton)
	self.m_LeftBtn = self:NewUI(3, CButton)
	self.m_RightBtn = self:NewUI(4, CButton)
	self.m_StoryBG = self:NewUI(5, CTexture)
	self.m_StoryLabel = self:NewUI(6, CLabel)
	self.m_CloseStoryBtn = self:NewUI(7, CButton)
	self.m_BackBtn = self:NewUI(8, CButton)
	self.m_NormalBox = self:NewUI(9, CBox)
	self.m_CityBoxList = {}
	self.m_CityBoxList[1] = self:NewUI(10, CBox)
	self.m_CityBoxList[2] = self:NewUI(11, CBox)

	self.m_BtnList = {}
	for i = 1, 3 do
		local btn = self:NewUI(i+20, CButton)
		self.m_BtnList[i] = btn
	end
	self.m_BookNode = self:NewUI(24, CObject)
	self.m_SelectObj = self:NewUI(25, CObject)
	self.m_HeroIcon = self:NewUI(26, CSprite)
	self:InitEventBox()
	self.m_StoryBG:SetActive(false)
	self.m_StoryLabel:SetActive(false)
	self.m_BookNode:SetActive(true)
	self.m_SelectObj:SetActive(false)
	self.m_HeroIcon:SetSpriteName("pic_map_avatar_" .. g_AttrCtrl.model_info.shape)
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OnExpandEventBox"))
	self.m_CloseStoryBtn:AddUIEvent("click", callback(self, "OnCloseStory"))
	self.m_LeftBtn:AddUIEvent("click", callback(self, "OnLeftMove"))
	self.m_RightBtn:AddUIEvent("click", callback(self, "OnRightMove"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_GuideCtrl:AddGuideUI("mapbook_world_main_city_close", self.m_BackBtn)
end

function CMapBookCityPage.InitEventBox(self)
	self.m_HideBtn = self.m_EventBox:NewUI(1, CButton)
	self.m_TitleLabel = self.m_EventBox:NewUI(2, CLabel)
	self.m_PartnerGrid = self.m_EventBox:NewUI(3, CGrid)
	self.m_PartnerItem = self.m_EventBox:NewUI(4, CBox)
	self.m_AwardBtn = self.m_EventBox:NewUI(5, CButton)
	self.m_StoryBtn = self.m_EventBox:NewUI(6, CButton)

	self.m_AwardBtn.m_TweenRotation = self.m_AwardBtn:GetComponent(classtype.TweenRotation)
	self.m_PartnerItem:SetActive(false)
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnHideEventBox"))
	self.m_AwardBtn:AddUIEvent("click", callback(self, "OnGetAward"))
	g_GuideCtrl:AddGuideUI("mapbook_world_city_award_btn", self.m_AwardBtn)
end

function CMapBookCityPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MapBook.Event.UpdateWorldMap then
		self:OnClickEvent(self.m_EventID)
	end
end

function CMapBookCityPage.RefreshCity(self, iCity)
	self.m_City = iCity
	self.m_PartData = g_MapBookCtrl:GetCityPart(iCity)
	for i, box in ipairs(self.m_CityBoxList) do
		box:SetActive(false)
	end
	if self.m_CityBoxList[iCity] then
		self:RefreshCityUI(iCity)
		return
	end
	self.m_NormalBox:SetActive(true)
	local flag =true
	local iEventID = nil
	for i = 1, 3 do
		if self.m_PartData[i] then
			local name = string.format("部位%d", self.m_PartData[i].part_id)
			self.m_BtnList[i]:SetText(name)
			self.m_BtnList[i]:AddUIEvent("click", callback(self, "OnClickEvent", self.m_PartData[i].id))
			local sdata = g_MapBookCtrl:GetWorldData(self.m_PartData[i].id)
			self.m_BtnList[i]:DelEffect("RedDot")
			if sdata["done"] == 1 then
				if not iEventID then
					iEventID = self.m_PartData[i].id
				else
					self.m_BtnList[i]:AddEffect("RedDot")
				end
			end
		end
	end

	if not iEventID then
		iEventID = self.m_PartData[1].id
	end
	self:OnClickEvent(iEventID)
end

function CMapBookCityPage.RefreshCityUI(self, iCity)
	self.m_NormalBox:SetActive(false)
	local citybox = self.m_CityBoxList[iCity]
	citybox:SetActive(true)
	local city2shape = {
		[1] = 3012,
		[2] = 3013.
	}
	if not citybox.m_Init then
		citybox.m_BtnList = {}
		for i = 1, 3 do
			local box = citybox:NewUI(i, CBox)
			citybox.m_BtnList[i] = box
			box.m_Btn = box:NewUI(1, CButton)
			box.m_TextureList = {}
			box.m_SelNode = box:NewUI(10, CObject)
			for j = 2, 10 do
				local oTexture = box:NewUI(j, CTexture, false)
				if oTexture then
					table.insert(box.m_TextureList, oTexture)
				else
					break
				end
			end
		end
		citybox.m_ActorTexture = citybox:NewUI(4, CActorTexture)
		citybox.m_TextureNode = citybox:NewUI(5, CObject)
		citybox.m_TextureNode:SetActive(false)
		citybox.m_ActorTexture:ChangeShape(city2shape[iCity], {}, callback(self, "HideActorTexture", citybox))
		citybox.m_Init = true
	else
		citybox.m_TextureNode:SetActive(false)
		citybox.m_ActorTexture:SetActive(true)
		self:HideActorTexture(citybox)
	end
	local flag =true
	local iEventID = nil
	for i = 1, 3 do
		if self.m_PartData[i] then
			citybox.m_BtnList[i].m_Btn:AddUIEvent("click", callback(self, "OnClickEvent", self.m_PartData[i].id))
			local sdata = g_MapBookCtrl:GetWorldData(self.m_PartData[i].id)
			citybox.m_BtnList[i]:DelEffect("RedDot")
			if sdata["done"] == 1 then
				if not iEventID then
					iEventID = self.m_PartData[i].id
				else
					citybox.m_BtnList[i]:AddEffect("RedDot")
				end
			else

			end
		end
	end
	if not iEventID then
		iEventID = self.m_PartData[1].id
	end
	self:OnClickEvent(iEventID)
end

function CMapBookCityPage.SelectBox(self, oBox)
	self.m_SelectObj:SetActive(true)
	self.m_SelectObj:SetLocalPos(Vector3.New(0, 0, 0))
	self.m_SelectObj:SetParent(oBox.m_SelNode.m_Transform)
end

function CMapBookCityPage.SetOriBox(self, oBox)
	for _, oTexture in ipairs(oBox.m_TextureList) do
		oTexture:SetColor(Utils.HexToColor("FFFFFFFF"))
		oTexture:SetGradientColor(Utils.HexToColor("FFFFFFFF"))
	end
end

function CMapBookCityPage.SetUnlockBox(self, oBox)
	for _, oTexture in ipairs(oBox.m_TextureList) do
		oTexture:SetColor(Utils.HexToColor("000000FF"))
		oTexture:SetGradientColor(Utils.HexToColor("FFFFFFFF"))
	end
end

function CMapBookCityPage.HideActorTexture(self, obj)
	local function delay()
		if not Utils.IsNil(obj) then
			obj.m_TextureNode:SetActive(true)
			obj.m_ActorTexture:SetActive(false)
		end
	end
	if self.m_HideTimer then
		Utils.DelTimer(self.m_HideTimer)
	end
	self.m_HideTimer = Utils.AddTimer(delay, 0, 1)
end

function CMapBookCityPage.RefreshCondition(self)
	self.m_TargetCondition = {}
	for _, condtionStr in ipairs(self.m_EventData.condition) do
		local list = string.split(condtionStr, ":")
		local key, target, value = list[1], list[2], list[3]
		target = tonumber(target)
		self.m_TargetCondition[target] = self.m_TargetCondition[target] or {}
		self.m_TargetCondition[target][key] = {tonumber(value)}
	end
	
	for _, t in ipairs(self.m_SData.cur) do
		if self.m_TargetCondition[t.targetid] and self.m_TargetCondition[t.targetid][t.key] then
			table.insert(self.m_TargetCondition[t.targetid][t.key], t.value)
		end
	end

	for target, t in pairs(self.m_TargetCondition) do
		local bfinish = true
		for key, values in pairs(t) do
			if not values[2] or values[2] < values[1] then
				bfinish = false
				break
			end
		end
		self.m_TargetCondition[target]["finish"] = bfinish
	end
	self:ShowConditon()
end

function CMapBookCityPage.ShowConditon(self)
	self.m_PartnerGrid:Clear()
	local partnerList = table.keys(self.m_TargetCondition)
	for _, targetid in ipairs(partnerList) do
		local box = self:CreatePartnerItem(targetid)
		box:SetActive(true)
		self.m_PartnerGrid:AddChild(box)
	end
	self.m_PartnerGrid:Reposition()
	self.m_StoryBtn:SetActive(true)
	if self.m_SData["done"] > 0 then
		self.m_StoryBtn:SetSpriteName("btn_tujian_yuedu")
		self.m_StoryBtn:AddUIEvent("click", callback(self, "OnShowStory"))
	else
		self.m_StoryBtn:SetSpriteName("btn_tujian_shouji")
		self.m_StoryBtn:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("请先完成收集解锁故事 ") end)
	end
end

function CMapBookCityPage.CreatePartnerItem(self, targetid)
	local box = self.m_PartnerItem:Clone()
	local condition = self.m_TargetCondition[targetid]
	local iStar = condition["伙伴星级"][1] or 1
	local iGrade = condition["伙伴等级"][1] or 1
	box.m_Icon = box:NewUI(1, CSprite)
	box.m_RareSpr = box:NewUI(2, CSprite)
	box.m_Grid = box:NewUI(3, CGrid)
	box.m_StarSpr = box:NewUI(4, CSprite)
	box.m_GradeLabel = box:NewUI(5, CLabel)
	box.m_AwakeSpr = box:NewUI(6, CSprite)
	box.m_StarSpr:SetActive(false)
	box.m_AwakeSpr:SetActive(false)
	if condition["伙伴觉醒"] then
		box.m_AwakeSpr:SetActive(true)
	end
	local pdata = data.partnerdata.DATA[targetid]
	g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, pdata.rare)
	box.m_Icon:SpriteAvatar(pdata["icon"])
	box.m_Icon:SetGrey(not self.m_TargetCondition[targetid]["finish"])
	box.m_Grid:Clear()
	for i = 1, iStar do
		local spr = box.m_StarSpr:Clone()
		spr:SetActive(true)
		box.m_Grid:AddChild(spr)
	end
	box.m_Grid:Reposition()
	box.m_GradeLabel:SetText(tostring(iGrade))
	return box
end

function CMapBookCityPage.OnClickEvent(self, iEventID)
	self.m_EventID = iEventID
	self.m_EventData = data.mapbookdata.WORLDMAP[self.m_EventID]
	self.m_SData = g_MapBookCtrl:GetWorldData(self.m_EventID)
	self.m_TitleLabel:SetText(self.m_EventData.name)
	self:RefreshCondition()
	self.m_AwardBtn:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	if self.m_SData["done"] == 1 then
		self.m_AwardBtn:SetSpriteName("pic_baoxiang_3_h")
		self.m_AwardBtn.m_TweenRotation.enabled = true
	elseif self.m_SData["done"] == 2 then
		self.m_AwardBtn:SetSpriteName("pic_baoxiang_3")
		self.m_AwardBtn.m_TweenRotation.enabled = false
	else
		self.m_AwardBtn:SetSpriteName("pic_baoxiang_3_h")
		self.m_AwardBtn.m_TweenRotation.enabled = false
	end
	self:RefreshAllSelect(iEventID)
end

function CMapBookCityPage.RefreshAllSelect(self, iEventID)
	if not self.m_CityBoxList[self.m_City] then
		return
	end
	local boxList = self.m_CityBoxList[self.m_City].m_BtnList
	for i = 1, 3 do
		if self.m_PartData[i] then
			if self.m_PartData[i].id == iEventID then
				boxList[i]:DelEffect("RedDot")
				self:SelectBox(boxList[i])
			else
				local sdata = g_MapBookCtrl:GetWorldData(self.m_PartData[i].id)
				if sdata["done"] > 1 then
					self:SetOriBox(boxList[i])
				else
					self:SetUnlockBox(boxList[i])
				end
			end
		end
	end
end

function CMapBookCityPage.OnGetAward(self)
	g_GuideCtrl.m_ClickMapBookReward = true
	if self.m_EventData then
		if self.m_SData["done"] == 0 then
			CMapBookAwardView:ShowView(function (oView)
				oView:RefreshAward(self.m_EventData)
			end)
		
		elseif self.m_SData["done"] == 1 then
			netachieve.C2GSPictureReward(self.m_EventID)
			
		elseif self.m_SData["done"] == 2 then
			g_NotifyCtrl:FloatMsg("你已经领取过此奖励")
		end
	end
end

function CMapBookCityPage.OnShowStory(self)
	if self.m_EventData then
		self.m_StoryBG:SetActive(true)
		self.m_StoryLabel:SetActive(true)
		self.m_StoryLabel:SetText(self.m_EventData.story)
		self.m_EventBox:SetActive(false)
		self.m_BookNode:SetActive(false)
	end
end

function CMapBookCityPage.OnCloseStory(self)
	self.m_StoryBG:SetActive(false)
	self.m_StoryLabel:SetActive(false)
	self.m_EventBox:SetActive(true)
	self.m_BookNode:SetActive(true)
end

function CMapBookCityPage.OnBack(self)
	self.m_ParentView:ShowMainPage(self)
end

function CMapBookCityPage.OnLeftMove(self)
	local list = g_MapBookCtrl:GetCityList()
	if list[1] == self.m_City then
		self:RefreshCity(list[#list])
	else
		for i = 2, #list do
			if list[i] == self.m_City then
				self:RefreshCity(list[i-1])
				break
			end
		end
	end
end

function CMapBookCityPage.OnRightMove(self)
	local list = g_MapBookCtrl:GetCityList()
	if list[#list] == self.m_City then
		self:RefreshCity(list[1])
	else
		for i = 1, #list-1 do
			if list[i] == self.m_City then
				self:RefreshCity(list[i+1])
				break
			end
		end
	end
end

function CMapBookCityPage.OnExpandEventBox(self, iCity)
	self.m_EventBox:SetActive(true)
	self.m_ExpandBtn:SetActive(false)
end

function CMapBookCityPage.OnHideEventBox(self, iCity)
	self.m_EventBox:SetActive(false)
	self.m_ExpandBtn:SetActive(true)
end

return CMapBookCityPage