local CArenaWarStartView = class("CArenaWarStartView", CViewBase)

function CArenaWarStartView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaWarStartView.prefab", ob)
	self.m_GroupName = "WarMain"
end

function CArenaWarStartView.OnCreateView(self)
	self.m_LeftSlot = self:NewUI(1, CBox)
	self.m_RightSlot = self:NewUI(2, CBox)
	self.m_Middle = self:NewUI(3, CBox)
	self:InitContent()
end

function CArenaWarStartView.InitContent(self)
	local oView = CWarFloatView:GetView()
	if oView then
		oView:SetActive(false)
	end

	self.m_InfoBoxArr = {}
	self.m_LoadCount = 0
	self.m_InfoBoxArr[1] = self:CreateInfoBox(self.m_LeftSlot, true)
	self.m_InfoBoxArr[2] = self:CreateInfoBox(self.m_RightSlot)
end

function CArenaWarStartView.CreateInfoBox(self, oInfoBox, isFanZhuan)
	oInfoBox.m_AvatarTexture = oInfoBox:NewUI(1, CTexture)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_Grid = oInfoBox:NewUI(3, CGrid)
	oInfoBox.m_Grid:SetActive(false)
	oInfoBox.m_ShapeBoxArr = {}
	oInfoBox.m_Grid:InitChild(function (obj, index)
		local oShapeBox = CBox.New(obj)
		oShapeBox.m_ShapeSprite = oShapeBox:NewUI(1, CSprite)
		oShapeBox.m_GradeLabel = oShapeBox:NewUI(2, CLabel)
		oShapeBox.m_ShapeBgSprite = oShapeBox:NewUI(3, CSprite)
		oShapeBox.m_GradeBgSprite = oShapeBox:NewUI(4, CSprite)
		oShapeBox.m_Tween = oShapeBox.m_ShapeSprite:GetComponent(classtype.TweenScale)
		local idx = index
		if isFanZhuan then
			idx = 6 - index
		end
		oInfoBox.m_ShapeBoxArr[idx] = oShapeBox
		oInfoBox.m_ShapeBoxArr[idx]:SetActive(false)
		return oShapeBox
	end)

	function oInfoBox.SetData(self, oData)
		oInfoBox.m_NameLabel:SetText(oData.name)
		local bArena = g_WarCtrl:GetWarType() == define.War.Type.Arena or g_WarCtrl:GetWarType() == define.War.Type.ClubArena
		oInfoBox.m_ShapeBoxArr[1].m_ShapeSprite:SpriteAvatar(oData.shape)
		oInfoBox.m_ShapeBoxArr[1].m_GradeBgSprite:SetActive(bArena)
		oInfoBox.m_ShapeBoxArr[1].m_GradeLabel:SetText(oData.grade)
		for i,v in ipairs(oData.parlist) do
			if oInfoBox.m_ShapeBoxArr[i + 1] then
				oInfoBox.m_ShapeBoxArr[i + 1].m_ShapeSprite:SpriteAvatar(v.shape)
				oInfoBox.m_ShapeBoxArr[i + 1].m_GradeBgSprite:SetActive(bArena)
				oInfoBox.m_ShapeBoxArr[i + 1].m_GradeLabel:SetText(v.grade)
				local partnerData = data.partnerdata.DATA[v.par]
				if partnerData then
					g_PartnerCtrl:ChangeRareBorder(oInfoBox.m_ShapeBoxArr[i + 1].m_ShapeBgSprite, partnerData.rare)
				end
				-- oInfoBox.m_ShapeBoxArr[i + 1]:SetActive(true)
				oInfoBox.m_ShapeBoxArr[i + 1].m_NeedShow = true
			end
		end
		if oData.parlist then
			for i = #oData.parlist + 2, #oInfoBox.m_ShapeBoxArr do
				-- oInfoBox.m_ShapeBoxArr[i]:SetActive(false)
				if oInfoBox and oInfoBox.m_ShapeSprite and oInfoBox.m_ShapeSprite[i + 1] then
					oInfoBox.m_ShapeBoxArr[i + 1].m_NeedShow = false
				end
			end
		end
	end

	function oInfoBox.PlayAni(self)
		for i,v in ipairs(oInfoBox.m_ShapeBoxArr) do
			if v.m_NeedShow then
				v:DelayCall(i * 0.1, "SetActive", true)
			end
		end
		oInfoBox.m_Grid:SetActive(false)
		oInfoBox.m_Grid:SetActive(true)
	end

	return oInfoBox
end

function CArenaWarStartView.SetData(self, oData)
	self.m_Data = oData
	for i,v in ipairs(self.m_Data) do
		self:SetTexture(self.m_InfoBoxArr[i].m_AvatarTexture, v.shape)
		self.m_InfoBoxArr[i]:SetData(v)
	end

	self:SetActive(false)
end

function CArenaWarStartView.SetTexture(self, oTexture, shape)
	oTexture:LoadArenaPhoto(shape, callback(self, "AfterLoadPhoto"))
	-- if data.arenadata.Avatar_UV[shape] then
	-- 	local uv = data.arenadata.Avatar_UV[shape].uv
	-- 	if uv == nil then
	-- 		return
	-- 	end
	-- 	-- printc(string.format("h:%s,w:%s,x:%s,y:%s", uv.h, uv.w, uv.x, uv.y))
	-- 	oTexture:SetUVRect(UnityEngine.Rect.New(uv.x, uv.y, uv.w, uv.h))
	-- end
end

function CArenaWarStartView.AfterLoadPhoto(self)
	self.m_LoadCount = self.m_LoadCount + 1
	if self.m_LoadCount >= 2 then
		self:SetActive(true)
		self.m_TimerID = Utils.AddTimer(callback(self, "OnNotifyClose"), 0, 3.6)
		self.m_ShowTimerID = Utils.AddTimer(callback(self, "OnNotifyShow"), 0, 0.6)
	end
end

function CArenaWarStartView.OnNotifyShow(self)
	self.m_Middle:SetActive(true)
	self.m_InfoBoxArr[1]:PlayAni()
	self.m_InfoBoxArr[2]:PlayAni()
end

function CArenaWarStartView.Destroy(self)
	if self.m_TimerID then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
	if self.m_ShowTimerID then
		Utils.DelTimer(self.m_ShowTimerID)
		self.m_ShowTimerID = nil
	end
	CViewBase.Destroy(self)
	if g_WarCtrl:IsPlayRecord() and 
		(g_WarCtrl:GetWarType() == define.War.Type.Arena or 
		g_WarCtrl:GetWarType() == define.War.Type.EqualArena or 
		g_WarCtrl:GetWarType() == define.War.Type.ClubArena) and 
		not g_NetCtrl:IsProtoRocord() then
		-- g_NotifyCtrl:FloatMsg("C2GSEndFilmBout: " .. 1)
		netwar.C2GSEndFilmBout(g_WarCtrl:GetWarID(), 1)
	end
end

function CArenaWarStartView.OnNotifyClose(self)
	self:CloseView()
	if not g_WarCtrl:IsPlayRecord() then
		CWarFloatView:ShowView()
		CWarMainView:ShowView()
		local oView = CMainMenuView:GetView()
		if oView then
			oView:SetActive(true)
		end
	else
		CWarWatchView:ShowView()
	end
end

return CArenaWarStartView
