local CScheduleMainView = class("CScheduleMainView", CViewBase)

function CScheduleMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleMainView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CScheduleMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_WeekBtn = self:NewUI(3, CButton)
	self.m_TagTopGrid = self:NewUI(4, CTabGrid)
	self.m_TagRightGrid = self:NewUI(5, CTabGrid)
	self.m_ScheduleScroll = self:NewUI(6, CScrollView)
	--self.m_ScheduleGrid = self:NewUI(7, CGrid)
	self.m_WrapContent = self:NewUI(7, CWrapContent)
	self.m_ScheduleBox = self:NewUI(8, CBox)
	self.m_NowActiveLabel = self:NewUI(9, CLabel)
	self.m_HuoYueSlider = self:NewUI(10, CBox)
	self.m_TreasurePart = self:NewUI(11, CBox)
	self.m_RewarPart = self:NewUI(12, CBox)
	self:InitContent()
end

function CScheduleMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_TagTop = nil
	self.m_TagRight = nil
	self.m_TagDic = {}
	self.m_TreasureList = {}
	self.m_SliderList = {}
	self.m_BoxDic = {}
	self.m_ScheduleBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_WeekBtn:AddUIEvent("click", callback(self, "OnWeek"))
	g_ScheduleCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlScheduleEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self:InitTagTop()
	self:InitTagRight()
	self:InitSliderBox()
	self:InitActiveReward()
	self:InitTreasurePart()
	self:InitRewarPart()
end

function CScheduleMainView.OnCtrlScheduleEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Schedule.Event.Refresh then
		self:SwitchTag()
		self:InitActiveReward()
		self:InitTreasurePart()
	end
end

function CScheduleMainView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["grade"] then
			self:SwitchTag()
			self:RefreshTagRight()
		end
	end
end

function CScheduleMainView.OnWeek(self)
	CScheduleWeekView:ShowView()
end

function CScheduleMainView.InitTagTop(self)
	local info = {
		{name = "全部", tagtype = define.Schedule.Tag.Top5,},
		{name = "经验", tagtype = define.Schedule.Tag.Top1,},
		{name = "金币", tagtype = define.Schedule.Tag.Top2,},
		{name = "装备", tagtype = define.Schedule.Tag.Top3,},
		{name = "伙伴", tagtype = define.Schedule.Tag.Top4,},
	}

	self.m_WrapContent:SetCloneChild(self.m_ScheduleBox, 
		function(oBox)
			self:CreateScheduleBox(oBox)
			return oBox
		end)

	self.m_TagTopGrid:InitChild(function (obj, idx)
		local oTag = CBox.New(obj)
		oTag:SetActive(true)
		oTag.m_UnSelectSpr = oTag:NewUI(1, CSprite)
		oTag.m_SelectSpr = oTag:NewUI(3, CSprite)
		oTag.m_SelectLabel = oTag:NewUI(4, CLabel)
		return oTag
	end)
	for i,oTag in ipairs(self.m_TagTopGrid:GetChildList()) do
		local v = info[i]
		if v then
			oTag.m_TagType = v.tagtype
			oTag.m_SelectLabel:SetText(v.name)
			oTag.m_UnSelectSpr:SetActive(true)
			oTag.m_SelectSpr:SetActive(false)
			oTag:SetClickSounPath(define.Audio.SoundPath.Tab)
			oTag:AddUIEvent("click", callback(self, "OnTagTop", oTag))
			self.m_TagDic[v.tagtype] = oTag
		end
	end

	local oDefaultBox = self.m_TagTopGrid:GetChild(1)
	if oDefaultBox then
		self:OnTagTop(oDefaultBox)
	end
end

function CScheduleMainView.OnTagTop(self, oTag)
	if self.m_TagTop ~= nil then
		self.m_TagTop.m_UnSelectSpr:SetActive(true)
		self.m_TagTop.m_SelectSpr:SetActive(false)
	end
	self.m_TagTop = oTag
	self.m_TagTop.m_UnSelectSpr:SetActive(false)
	self.m_TagTop.m_SelectSpr:SetActive(true)
	self:SwitchTag(nil, self.m_TagTop.m_TagType)
end

function CScheduleMainView.InitTagRight(self)
	local info = {
		{name = "必做", tagtype = define.Schedule.Tag.Right1,},
		{name = "预告", tagtype = define.Schedule.Tag.Right2,},
	}
	self.m_TagRightGrid:InitChild(function (obj, idx)
		local oTag = CBox.New(obj)
		oTag:SetActive(true)
		oTag.m_UnSelectSpr = oTag:NewUI(1, CSprite)
		oTag.m_UnSelectLabel = oTag:NewUI(2, CLabel)
		oTag.m_SelectSpr = oTag:NewUI(3, CSprite)
		oTag.m_SelectLabel = oTag:NewUI(4, CLabel)
		return oTag
	end)
	for i,oTag in ipairs(self.m_TagRightGrid:GetChildList()) do
		local v = info[i]
		if v then
			oTag.m_TagType = v.tagtype
			oTag.m_SelectLabel:SetText(v.name)
			oTag.m_UnSelectLabel:SetText(v.name)
			oTag.m_UnSelectSpr:SetActive(true)
			oTag.m_SelectSpr:SetActive(false)
			oTag:SetClickSounPath(define.Audio.SoundPath.Tab)
			oTag:AddUIEvent("click", callback(self, "OnTagRight", oTag))
			self.m_TagDic[v.tagtype] = oTag
		end
	end
	local oDefaultBox = self.m_TagRightGrid:GetChild(1)
	if oDefaultBox then
		self:OnTagRight(oDefaultBox)
	end
	self:RefreshTagRight()
end

function CScheduleMainView.RefreshTagRight(self)
	local TagRight2 = self.m_TagDic[define.Schedule.Tag.Right2]
	local listData = {}
	local curGrade = g_AttrCtrl.grade
	local addGrade = curGrade + 5
	local bAct = false
	for k,v in pairs(g_ScheduleCtrl.m_Schedules) do
		local min = v:GetValue("mingrade")
		local max = v:GetValue("maxgrade")
		if min and max and addGrade >= min and curGrade < min then
			bAct = true
			break
		end
	end
	if TagRight2 then
		TagRight2:SetActive(bAct)
	end
	self.m_TagRightGrid:Reposition()
end

function CScheduleMainView.OnTagRight(self, oTag)
	if self.m_TagRight ~= nil then
		self.m_TagRight.m_UnSelectSpr:SetActive(true)
		self.m_TagRight.m_SelectSpr:SetActive(false)
	end
	self.m_TagRight = oTag
	self.m_TagRight.m_UnSelectSpr:SetActive(false)
	self.m_TagRight.m_SelectSpr:SetActive(true)
	if self.m_TagRight.m_TagType == define.Schedule.Tag.Right1 then
		self.m_TagTopGrid:SetActive(true)
	else
		self.m_TagTopGrid:SetActive(false)
	end
	self:SwitchTag(self.m_TagRight.m_TagType)
end

function CScheduleMainView.SwitchTag(self, tagRight, tagTop, cbfun)
	tagRight = tagRight or (self.m_TagRight and self.m_TagRight.m_TagType) or define.Schedule.Tag.Right1
	tagTop = tagTop or (self.m_TagTop and self.m_TagTop.m_TagType) or define.Schedule.Tag.Top1
	if tagRight and self.m_TagRight and self.m_TagRight.m_TagType and self.m_TagRight.m_TagType  ~= tagRight then
		self:OnTagRight(self.m_TagDic[tagRight])
		return
	end
	if tagTop and self.m_TagTop and self.m_TagTop.m_TagType and self.m_TagTop.m_TagType ~= tagTop then
		self:OnTagTop(self.m_TagDic[tagTop])
		return
	end
	local function f()
		if Utils.IsNil(self) then
			return
		end
		local listData = self:GetScheduleDatas(tagRight, tagTop)
		self:RefreshScheduleGrid(listData, tagRight)
		if cbfun then
			cbfun()
		end
	end
	Utils.AddTimer(f, 0, 0.1)
end

function CScheduleMainView.RefreshScheduleGrid(self, listData, tagRight)
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			self:UpdataScheduleBox(oBox, dData, tagRight)
			oBox:SetActive(true)
		else	
			oBox:SetActive(false)
		end
	end)
	self.m_WrapContent:SetData(listData, true)
	self.m_ScheduleScroll:ResetPosition()
	--[[
	self.m_ScheduleGrid:Clear()
	for i,v in ipairs(listData) do
		local oBox = self:CreateScheduleBox(tagRight)
		oBox = self:UpdataScheduleBox(oBox, v, tagRight)
		self.m_ScheduleGrid:AddChild(oBox)
	end
	self.m_ScheduleGrid:Reposition()
	self.m_ScheduleScroll:ResetPosition()
	]]
end

function CScheduleMainView.CreateScheduleBox(self, oBox)
	oBox.m_IconSprite = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_FinishSprite = oBox:NewUI(3, CSprite)
	oBox.m_DescLabel = oBox:NewUI(4, CLabel)
	oBox.m_NumLabel = oBox:NewUI(5, CLabel)
	oBox.m_GoToBtn = oBox:NewUI(6, CButton)
	oBox.m_LabelGrid = oBox:NewUI(7, CGrid)
	oBox.m_ItemGrid = oBox:NewUI(8, CGrid)
	oBox.m_ItemBox = oBox:NewUI(9, CItemRewardBox)
	oBox.m_TimeLabel = oBox:NewUI(10, CLabel)
	oBox.m_TagSprite = oBox:NewUI(11, CSprite)
	oBox.m_ItemBox:SetActive(false)
	oBox.m_TagSprite:SetActive(false)
	oBox.m_ItemList = {}
	oBox.m_ItemGrid:Clear()
	return oBox
end

function CScheduleMainView.UpdataScheduleBox(self, oBox, v, tagRight)
	self.m_BoxDic[oBox:GetInstanceID()] = oBox
	oBox.m_ID = v:GetValue("id")
	oBox:SetName(tostring(oBox.m_ID))
	oBox.m_IconSprite:SetSpriteName(v:GetValue("icon"))
	oBox.m_NameLabel:SetText(v:GetValue("name"))
	oBox.m_GoToBtn:SetActive(tagRight == define.Schedule.Tag.Right1)
	--预告检测
	if tagRight == define.Schedule.Tag.Right2 then
		local min = v:GetValue("mingrade")
		oBox.m_DescLabel:SetText(string.format("[FF5555]%d等级开启", min))
		oBox.m_FinishSprite:SetActive(false)
		oBox.m_NumLabel:SetActive(false)
		oBox.m_TimeLabel:SetActive(false)
		local tagTop = v:GetValue("tag")[1]
		if tagTop and tagTop ~= 5 then
			oBox.m_TagSprite:SetActive(true)
			oBox.m_TagSprite:SetSpriteName(string.format("pic_tag_%d", tagTop))
		else
			oBox.m_TagSprite:SetActive(false)
		end
	else
		--活跃度检测
		local done_cnt = v:GetValue("done_cnt") 
		local maxtimes = v:GetValue("maxtimes")
		local maxactive = v:GetValue("maxactive")
		oBox.m_FinishSprite:SetActive(done_cnt == maxtimes)
		oBox.m_NumLabel:SetActive(maxactive > 0)
		local tagTop = v:GetValue("tag")[1]
		if tagTop and tagTop ~= 5 then
			oBox.m_TagSprite:SetActive(true)
			oBox.m_TagSprite:SetSpriteName(string.format("pic_tag_%d", tagTop))
		else
			oBox.m_TagSprite:SetActive(false)
		end
		if maxactive > 0 then
			--oBox.m_DescLabel:SetText(string.format("每次+%d  总活跃(%d/%d)", v:GetValue("active"), v:GetValue("active") * done_cnt,v:GetValue("maxactive")))
			oBox.m_DescLabel:SetText(string.format("[8D6D4C]活跃度+%d", maxactive))
			oBox.m_NumLabel:SetText(string.format("(%d/%d)", done_cnt, maxtimes))
			oBox.m_FinishSprite:SetActive(done_cnt == maxtimes)
			oBox.m_NumLabel:ResetAndUpdateAnchors()
		else
			local txt
			if oBox.m_ID == define.Schedule.ID.Travel then
				if v:GetValue("flag") == 1 then
					txt = "#G未派遣"
				else
					txt = "#R已派遣"
				end
			elseif oBox.m_ID == define.Schedule.ID.EndlessPVE then
				local left = v:GetValue("left")
				txt = string.format("剩余镜花水月%d个", left)
				if left == 0 then
					txt = "#R"..txt
				else
					txt = "[8D6D4C]"..txt
				end
			elseif oBox.m_ID == define.Schedule.ID.Treasure then
				local left = v:GetValue("left")
				txt = string.format("剩余星象图%d个", left)
				if left == 0 then
					txt = "#R"..txt
				else
					txt = "[8D6D4C]"..txt
				end
			end
			if txt then
				oBox.m_DescLabel:SetText(txt)
			else
				oBox.m_DescLabel:SetActive(false)
			end
			oBox.m_FinishSprite:SetActive(false)
			oBox.m_NumLabel:SetActive(false)
		end
		if v:GetValue("limit") == define.Schedule.Limit.Xianshi then
			oBox.m_TimeLabel:SetActive(true)
			oBox.m_TimeLabel:SetText(v:GetXianShiDesc())
		else
			oBox.m_TimeLabel:SetActive(false)
		end
		oBox:AddUIEvent("click", callback(self,"OnScheduleBox", oBox))
		oBox.m_GoToBtn:AddUIEvent("click", callback(self,"OnGoToBtn", oBox))
	end
	
	oBox.m_LabelGrid:Reposition()

	for i,v in ipairs(oBox.m_ItemList) do
		if v then
			v:SetActive(false)
		end
	end

	local rewars = v:GetValue("rewardlist") or {}
	local config = {isLocal = true,}
	table.print(rewars,"-------------------------------------"..v:GetValue("id"))
	for i,v in ipairs(rewars) do
		local box = oBox.m_ItemList[i]
		if box then
			box:SetActive(true)
		else
			box = oBox.m_ItemBox:Clone()
			box:SetActive(true)
			table.insert(oBox.m_ItemList, box)
			oBox.m_ItemGrid:AddChild(box)
		end
		box:SetItemBySid(v.sid, v.num, config)
	end
	oBox.m_ItemGrid:Reposition()
	return oBox
end

function CScheduleMainView.OnScheduleBox(self, oBox)
	if oBox.m_ID and oBox.m_ID > 0 then
		CScheduleTipsView:ShowView(function (oView)
			oView:SetScheduleID(oBox.m_ID)
		end)
	end
end

function CScheduleMainView.OnGoToBtn(self, oBox)
	local id = oBox.m_ID
	g_GuideCtrl:ReqTipsGuideFinish("schedule_allday_go_btn", id)
	-- if id == g_GuideCtrl:IsInTipsGuide("schedule_allday_go_btn", id) then
	-- 	local t = g_GuideCtrl:GetTipsGuideDataByOpenId("schedule_allday_go_btn", id)
	-- 	g_GuideCtrl:AddGuideUIEffect("schedule_allday_go_btn", t.ui_effect, true)
	-- else
	-- 	oBox.m_GoToBtn:ClearEffect()
	-- end
	--新手引导处理
	--if id == 1006 and not g_GuideCtrl:IsCompleteTipsGuideByKey("Tips_MingLei") then
	--	self:CloseView()			
	--	g_ActivityCtrl:WalkToMingLeiGuideNpc()

	-- if id == 1005 and not g_GuideCtrl:IsCompleteTipsGuideByKey("PEFbView") then
	-- 	self:CloseView()
	-- 	nethuodong.C2GSOpenPEMain()

	-- elseif id == 1003 and not g_GuideCtrl:IsCompleteTipsGuideByKey("EquipFuben_View") then
	-- 	self:CloseView()
	-- 	g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain()

	-- elseif id == 1018 and not g_GuideCtrl:IsCompleteTipsGuideByKey("Convoy_View") then
	-- 	self:CloseView()
	-- 	nethuodong.C2GSShowConvoy()
	-- else
		g_ScheduleCtrl:GoToWay(id)
	--end
end

function CScheduleMainView.GetScheduleDatas(self, tagRight, tagTop)
	local schedules = g_ScheduleCtrl.m_Schedules
	local listData = {}
	if tagRight == define.Schedule.Tag.Right1 then
		local curGrade = g_AttrCtrl.grade
		for k,v in pairs(schedules) do
			local tag = v:GetValue("tag")
			local min = v:GetValue("mingrade")
			local max = v:GetValue("maxgrade")
			local bWeek = not v:CheckOpenWeek()
			if table.index(tag, tagTop) 
				and min and max and curGrade >= min and curGrade <= max 
				and bWeek then
				table.insert(listData, v)
			end
		end
		local function sortfunc(a, b)
			local aSort = a:GetSortValue()
			local bSort = b:GetSortValue()
			if aSort == bSort then
				aSort = a:GetValue("sort")
				bSort = b:GetValue("sort")
				return aSort < bSort
				--[[
				local aGrade = a:GetValue("mingrade")
				local bGrade = b:GetValue("mingrade")
				if aGrade == bGrade then
					return a:GetValue("id") < b:GetValue("id")
				else
					return aGrade < bGrade
				end
				]]
			else
				return aSort < bSort
			end
		end
		table.sort(listData, sortfunc)
	elseif tagRight == define.Schedule.Tag.Right2 then
		local curGrade = g_AttrCtrl.grade
		local addGrade = curGrade + 5
		for k,v in pairs(schedules) do
			local tag = v:GetValue("tag")
			local min = v:GetValue("mingrade")
			local max = v:GetValue("maxgrade")
			if not table.index(tag, 0) 
				and min and max and curGrade < min and addGrade >= min then 
				table.insert(listData, v)
			end
		end
		local function sortfunc(a, b)
			local aGrade = a:GetValue("mingrade")
			local bGrade = b:GetValue("mingrade")
			if aGrade == bGrade then
				return a:GetValue("id") < b:GetValue("id")
			else
				return aGrade < bGrade
			end
		end
		table.sort(listData, sortfunc)
	end
	return listData
end

function CScheduleMainView.InitActiveReward(self)
	local activepoint = g_ScheduleCtrl:GetActivePoint()
	local max = data.scheduledata.ACTIVEREWARD[#data.scheduledata.ACTIVEREWARD].active
	self.m_NowActiveLabel:SetText(activepoint)
	self:RefreshSliderBox(activepoint)
	--self.m_HuoYueSlider:SetValue(activepoint / max)
	local rewardidx = g_ScheduleCtrl:GetRewardIdx()
	if rewardidx == 0 then
		rewardidx = 1 
	end
	self.m_RewardIdx = rewardidx
end

function CScheduleMainView.InitSliderBox(self)
	local activereward = data.scheduledata.ACTIVEREWARD
	for i=1,5 do
		self.m_SliderList[i] = self.m_HuoYueSlider:NewUI(i, CSlider)
		self.m_SliderList[i]:SetValue(1)
		local max = activereward[i].active
		self.m_SliderList[i].m_MaxValue = max
		local min = activereward[i-1] and activereward[i-1].active or -1
		self.m_SliderList[i].m_MinValue = min + 1
	end
end

function CScheduleMainView.RefreshSliderBox(self, activepoint)
	for i,v in ipairs(self.m_SliderList) do
		if activepoint > v.m_MaxValue then
			v:SetValue(1)
		elseif activepoint < v.m_MinValue then
			v:SetValue(0)
		elseif activepoint >= v.m_MinValue and activepoint < v.m_MaxValue then
			v:SetValue((activepoint - v.m_MinValue) / (v.m_MaxValue - v.m_MinValue))
		end
	end
end

function CScheduleMainView.InitTreasurePart(self)
	if #self.m_TreasureList == 0 then
		for i = 1, 5 do
			local oBox = self.m_TreasurePart:NewUI(i, CBox)
			oBox.m_ActiveLabel = oBox:NewUI(2, CLabel)
			oBox.m_IconSprite = oBox:NewUI(3, CSprite)
			oBox.m_TweenRotation = oBox.m_IconSprite:GetComponent(classtype.TweenRotation)
			oBox.m_TweenRotation.enabled = false
			oBox.m_Idx = i
			oBox:AddUIEvent("click", callback(self,"OnTreasureBox", oBox))
			if i == 1 then
				g_GuideCtrl:AddGuideUI("schedule_award_box_1_btn", oBox)
			end
			table.insert(self.m_TreasureList, oBox)
		end
	end
	local dData = data.scheduledata.ACTIVEREWARD
	for i,oBox in ipairs(self.m_TreasureList) do
		local d = dData[i]
		if d then
			oBox.m_Data = d
			self:RefreshTreasureBox(oBox)
		end
	end
end

function CScheduleMainView.RefreshTreasureBox(self, oBox)
	local data = oBox.m_Data
	oBox.m_ActiveLabel:SetText(data.active)
	oBox.m_Get = MathBit.andOp(self.m_RewardIdx, 2 ^ data.id) == 0
	if oBox.m_Get then
		oBox.m_IconSprite:SetSpriteName(string.format("pic_baoxiang_%d_h",oBox.m_Idx))
 	else
 		oBox.m_IconSprite:SetSpriteName(string.format("pic_baoxiang_%d",oBox.m_Idx))
 	end
 	local activepoint = g_ScheduleCtrl:GetActivePoint()
 	local bTween = oBox.m_Get and activepoint >= data.active
 	if bTween then
 		oBox.m_TweenRotation.enabled = true
 	else
 		oBox.m_TweenRotation.enabled = false
 	end
end

function CScheduleMainView.StartSpriteAnimation(self, oBox)
	netopenui.C2GSScheduleReward(oBox.m_Data.id)
end

function CScheduleMainView.OnTreasureBox(self, oBox)
	--可以领取
	table.print(oBox.m_Data)
	if oBox.m_TweenRotation.enabled then
		self:StartSpriteAnimation(oBox)
		return
	else
		self:ShowRewarPart(true, oBox)
	end
end

function CScheduleMainView.InitRewarPart(self)
	self.m_RewarBG = self.m_RewarPart:NewUI(1, CTexture)
	self.m_RewarLabel = self.m_RewarPart:NewUI(2, CLabel)
	self.m_RewarGrid = self.m_RewarPart:NewUI(3, CGrid)
	self.m_RewarBox = self.m_RewarPart:NewUI(4, CItemRewardBox)
	self.m_RewarExpLabel = self.m_RewarPart:NewUI(5, CLabel)
	self.m_RewarBG:AddUIEvent("click", callback(self, "ShowRewarPart", false))
	self.m_RewarPart:SetActive(false)
	self.m_RewarBox:SetActive(false)
end

function CScheduleMainView.ShowRewarPart(self, bShow, oBox)
	self.m_RewarPart:SetActive(bShow)
	local dData = oBox and oBox.m_Data
	if dData then
		local iNeed = dData.active
		self.m_RewarLabel:SetText(string.format("每日活跃到达%d可获得", iNeed))
		local code = "return " .. string.gsub(dData.exp, "lv", g_AttrCtrl.grade)
		self.m_RewarExpLabel:SetText("Exp:"..loadstring(code)())
		local rewardlist = dData.rewardlist or {}
		self.m_RewarGrid:Clear()
		for i,v in ipairs(rewardlist) do
			local oBox = self.m_RewarBox:Clone()
			local config = {isLocal = true,}
			oBox:SetActive(true)
			oBox:SetItemBySid(v.sid, v.num, config)
			self.m_RewarGrid:AddChild(oBox)
		end
		self.m_RewarGrid:Reposition()
	end
end

function CScheduleMainView.Select(self, tagRight, tagTop, idTag)
	if idTag then
		local function cbfun()
		 	for i,v in ipairs(self.m_WrapContent.m_DataList) do
		 		if v.m_ID == idTag then
					self.m_ScheduleScroll:Move2Pos(Vector3(0, -((i-1)*115), 0))
					for k,oBox in pairs(self.m_BoxDic) do
						if oBox.m_ID == v.m_ID then
							g_GuideCtrl:AddGuideUI("schedule_allday_go_btn", oBox.m_GoToBtn)
							break
						end
					end
					break
				end
		 	end	
		end
		self:SwitchTag(tagRight, tagTop, cbfun)
	else
		self:SwitchTag(tagRight, tagTop)
	end
end

return CScheduleMainView