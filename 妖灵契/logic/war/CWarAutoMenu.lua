local CWarAutoMenu = class("CWarAutoMenu", CBox)

function CWarAutoMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AutoBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	-- self.m_SelMagicBg = self:NewUI(3, CSprite)
	self.m_MagicGrid = self:NewUI(4, CGrid)
	self.m_MagicBox = self:NewUI(5, CBox)
	self.m_CompleteBtn = self:NewUI(6, CButton)
	self.m_LockSpr = self:NewUI(7, CSprite)
	self.m_CurWids = {}
	self.m_DelayUpdateTimer = nil
	self:InitContent()
end

function CWarAutoMenu.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CWarAutoMenu.InitContent(self)
	self.m_MagicBox:SetActive(false)
	self.m_AutoBtn:AddUIEvent("click", callback(self, "StartAuto"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "CancelAuto"))
	-- self.m_CompleteBtn:AddUIEvent("click", callback(self, "OnComplete"))
	--local bGuide = (g_WarCtrl:GetWarType() == define.War.Type.Guide1) or (g_WarCtrl:GetWarType() == define.War.Type.Guide2)
	self.m_LockSpr:SetActive(g_AttrCtrl.grade < 4)
	--self.m_AutoBtn:SetGreySprites(bGuide)
	g_GuideCtrl:AddGuideUI("war_order_all", self.m_CompleteBtn)
	self.m_CompleteBtn:SetActive(false)
	self:UpdateMenu()
end

function CWarAutoMenu.OnComplete(self)
	netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 3)
	g_WarOrderCtrl:FinishOrder()
end

function CWarAutoMenu.StartAuto(self)
	if g_AttrCtrl.grade < 4 then
		g_NotifyCtrl:FloatMsg("4级开启自动模式")
		return
	end
	netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 1)
	g_WarOrderCtrl:FinishOrder()
end

function CWarAutoMenu.CancelAuto(self)
	--if (g_WarCtrl:GetWarType() == define.War.Type.Guide1) or (g_WarCtrl:GetWarType() == define.War.Type.Guide2) or g_AttrCtrl.grade < 13  then
	--	g_NotifyCtrl:FloatMsg("4级开启手动模式")
	--else
		netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 0)	
	--end
end

function CWarAutoMenu.DelayUpdateMenu(self)
	if self.m_DelayUpdateTimer then
		Utils.DelTimer(self.m_DelayUpdateTimer)
	end
	self.m_DelayUpdateTimer = Utils.AddTimer(callback(self, "UpdateMenu"), 0, 0)
end

function CWarAutoMenu.UpdateMenu(self)
	local bAuto = g_WarCtrl:IsAutoWar()
	local bCanOrder  = g_WarOrderCtrl:IsCanOrder()
	local bIsInAction = g_WarCtrl:IsInAction()
	--[[
	if g_WarCtrl:GetWarType() == define.War.Type.Guide1 then
		bAuto = true
		bCanOrder = false
	end	
	]]
	self.m_AutoBtn:SetActive(not bAuto)
	-- self.m_CompleteBtn:SetActive(not bAuto and bCanOrder)
	self.m_CancelBtn:SetActive(bAuto)
	self.m_MagicGrid:SetActive(bAuto)
	local wids = {}
	if bAuto then
		for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			if oWarrior:IsAlly() and oWarrior.m_OwnerWid 
				and oWarrior.m_OwnerWid == g_WarCtrl.m_HeroWid
				and #oWarrior.m_MagicList > 0 and not oWarrior.m_IsSummon then
				table.insert(wids, oWarrior.m_ID)
			end
		end
		local sortfunc = self:SortPartnerFunc()
		table.sort(wids, sortfunc)
		table.insert(wids, 1, g_WarCtrl.m_HeroWid)
	end
	self.m_CurWids = wids
	self:RefreshMagicTable()
	if self.m_ParentView then
		self.m_ParentView:RefreshBgSpriteSize()
	end
	self.m_DelayUpdateTimer = nil

	self.m_AutoBtn:DelEffect("circle")	
	if g_WarCtrl:GetWarType() == define.War.Type.Guide4 and not g_GuideCtrl:IsCustomGuideFinishByKey("AutoWar") then
		if bAuto then
			g_GuideCtrl:ResetAutoWarGuide()
			g_GuideCtrl:ReqCustomGuideFinish("AutoWar")
			g_GuideCtrl:ReqCustomGuideFinish("WarAutoWar")
		else
			g_GuideCtrl:StartAutoWarGuide()
			self.m_AutoBtn:AddEffect("circle", 60)
		end
	end	
end

function CWarAutoMenu.SortPartnerFunc(self)
	return function(wid1, wid2)
		local oWarrior1 = g_WarCtrl:GetWarrior(wid1)
		local oWarrior2 = g_WarCtrl:GetWarrior(wid2)
		local oHeroWarrior = g_WarCtrl:GetWarrior(g_WarCtrl.m_HeroWid)
		local iMainFightPos = oHeroWarrior.m_CampPos+4
		if oWarrior1.m_CampPos == oWarrior2.m_CampPos then
			return wid1 < wid2
		elseif oWarrior1.m_CampPos == iMainFightPos then
			return true
		elseif oWarrior2.m_CampPos == iMainFightPos then
			return false
		else
			return oWarrior1.m_CampPos < oWarrior2.m_CampPos
		end
	end
end

function CWarAutoMenu.RefreshMagicTable(self)
	local sKey = "CWarAutoMenu.MagicBox"
	for i = 1 , 5 do
		g_GuideCtrl:AddGuideUI(string.format("war_auto_skill_box%d", i))
	end

	self.m_MagicGrid:Recycle(function(o) return {magic=o.m_MagicID} end)
	for i, wid in ipairs(self.m_CurWids) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			local magicid = oWarrior:GetAutoMagic()
			local oBox = g_ResCtrl:GetObjectFromCache(sKey, {magic=magicid})
			if not oBox then
				oBox = self.m_MagicBox:Clone()
				oBox.m_MagicSpr = oBox:NewUI(1, CSprite)
				oBox.m_Avatar = oBox:NewUI(2, CSprite)
				oBox.m_SpLabel = oBox:NewUI(4, CLabel)
				-- oBox.m_HeroSpr = oBox:NewUI(3, CSprite)
				oBox:SetActive(true)
				oBox:SetCacheKey(sKey)
			end
			oBox:AddUIEvent("click", callback(self, "OnSelMagic", oBox, i))
			oBox.m_PartnerID = oWarrior.m_PartnerID
			oBox.m_Wid = wid
			oBox.m_MagicID = magicid
			oBox.m_Level = g_WarCtrl:GetMagicLevel(wid, magicid)
			if magicid == 0 or magicid == nil then
				--[[
				if g_WarCtrl:GetWarType() == define.War.Type.Guide1 then
					printc("警告：新手引导magicid异常，找程序看，保留现场")
					if wid == 2 then
						oBox.m_MagicSpr:SpriteMagic(30202)
					elseif wid == 3 then
						oBox.m_MagicSpr:SpriteMagic(50202)
					end
				else
					oBox.m_MagicSpr:SetSpriteName("")
					printc("警告：magicid异常->",magicid)
					table.print(oWarrior:GetAutoMagic())
				end
				]]
			else
				oBox.m_MagicSpr:SpriteMagic(magicid)
			end
			local bHero = oWarrior.m_ID == g_WarCtrl.m_HeroWid
			oBox.m_Avatar:SpriteWarAvatar(oWarrior:GetShape())
			local dData = DataTools.GetMagicData(magicid)
			if dData and dData.sp and dData.sp > 0 then
				oBox.m_SpLabel:SetActive(true)
				oBox.m_SpLabel:SetText(tostring(dData.sp/20))
			else
				oBox.m_SpLabel:SetActive(false)
			end

			self.m_MagicGrid:AddChild(oBox)

			if i >= 1 and i <=5 then
				g_GuideCtrl:AddGuideUI(string.format("war_auto_skill_box%d", i), oBox)
			end	
		end
	end
	self.m_MagicGrid:Reposition()

	--每次刷新自动技能时检测战斗4引导
	g_GuideCtrl:TriggerCheckWarGuide()
	-- local bounds = UITools.CalculateRelativeWidgetBounds(self.m_MagicGrid.m_Transform)
	-- self.m_SelMagicBg:SetWidth(bounds.max.x-bounds.min.x+20)
end 

function CWarAutoMenu.OnSelMagic(self, oBox, i)
	CWarSelAutoView:ShowView(function(oView)
			oView:SetWid(oBox.m_Wid, i)
			UITools.NearTarget(oBox, oView.m_Bg, enum.UIAnchor.Side.Top, Vector2.zero, true)
		end)
end

function CWarAutoMenu.GetMagicBoxCount(self)
	return self.m_MagicGrid:GetCount()
end

return CWarAutoMenu