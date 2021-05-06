---------------------------------------------------------------
--技能界面的 修炼 子界面


---------------------------------------------------------------
local CSkillCultivatePage = class("CSkillCultivatePage", CPageBase)

CSkillCultivatePage.HighLightLevelColor = 
{	
	[1] = {0/255, 43/255, 43/255, 255/255},	
	[2] = {0/255, 85/255, 85/255, 255/255},	
	[3] = {0/255, 128/255, 128/255, 255/255},	
	[4] = {0/255, 170/255, 170/255, 255/255},	
	[5] = {0/255, 213/255, 213/255, 255/255},	
	[6] = {0/255, 255/255, 255/255, 255/255},	
	[7] = {43/255, 255/255, 255/255, 255/255},	
	[8] = {85/255, 255/255, 255/255, 255/255},	
	[9] = {128/255, 255/255, 255/255, 255/255},	
	[10] = {170/255, 255/255, 255/255, 255/255},	
}

CSkillCultivatePage.LearnOne = 1
CSkillCultivatePage.LearnMulti = 10

function CSkillCultivatePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_SelectCultivateType = g_SkillCtrl.m_RecordCultivateType
	self.m_Timer = nil
	self.m_IsAutoLearning = false
	self.m_IsOpenCloseWindow = false
	self.m_ReqBeforeSkillInfo = {}
	self.m_UseItemId = 0
	self.m_CoinItemId = tonumber(data.globaldata.GLOBAL.attr_coin_itemid.value) 
end

function CSkillCultivatePage.OnInitPage(self)
	self.m_TipsBtn = self:NewUI(1, CButton)
	self.m_SideGrid = self:NewUI(2, CGrid)
	self.m_CenterGrid = self:NewUI(3, CGrid)
	self.m_ArrowsGrid = self:NewUI(4, CGrid)
	self.m_InfoBox = self:NewUI(5, CBox)
	self.m_AutoAniBox = self:NewUI(6, CWidget)
	self:InitContent()
end

function CSkillCultivatePage.InitContent(self)
	self:IntiInfoContent()
	self:InitSideContent()
	self:InitCenterContent()
	self:InitArrowsContent()
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnBtnClick", "Tips"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSkillEvent"))	
	self:RefreshAll()
end

function CSkillCultivatePage.InitSideContent(self)
	self.m_SideGrid:InitChild(function ( obj, idx )
		local oBox = CBox.New(obj)
		oBox.m_TitleLabel = oBox:NewUI(1, CLabel)
		oBox.m_LevelLabel = oBox:NewUI(2, CLabel)
		oBox.m_HighLightSprite = oBox:NewUI(3, CSprite)
		oBox.m_SelectSprite = oBox:NewUI(4, CSprite)
		oBox:AddUIEvent("click", callback(self, "OnBtnClick", "Switch", idx))
		oBox:SetGroup(self.m_SideGrid:GetInstanceID())
		
		if self.m_SelectCultivateType == idx then
			oBox:SetSelected(true)
		end
		return oBox
	end)
end

function CSkillCultivatePage.InitCenterContent(self)
	self.m_CenterGrid:InitChild(function ( obj, idx )
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnBtnClick", "Switch", idx))
		oBox.m_HighLightSprite = oBox:NewUI(1, CSprite)
		oBox:SetGroup(self.m_CenterGrid:GetInstanceID())
		if self.m_SelectCultivateType == idx then
			oBox:SetSelected(true)
		end
		return oBox
	end)
end

function CSkillCultivatePage.IntiInfoContent(self)
	self.m_ItemCountLabel = self.m_InfoBox:NewUI(1, CLabel)
	self.m_ItemAddBtn = self.m_InfoBox:NewUI(2, CButton)
	self.m_CoinCountLabel = self.m_InfoBox:NewUI(3, CLabel)
	self.m_CoinAddBtn = self.m_InfoBox:NewUI(4, CButton)
	self.m_LearnOneBtn = self.m_InfoBox:NewUI(5, CButton)
	self.m_LearnTenBtn = self.m_InfoBox:NewUI(6, CButton)
	self.m_AutoLearnBtn = self.m_InfoBox:NewUI(7, CButton)
	self.m_AutoLearnLabel = self.m_InfoBox:NewUI(8, CLabel)
	self.m_CurCultivateTitleLabel = self.m_InfoBox:NewUI(9, CLabel)
	self.m_CurCultivateDesLabel = self.m_InfoBox:NewUI(10, CLabel)
	self.m_CurCultivateLabel = self.m_InfoBox:NewUI(11, CLabel)
	self.m_NextCultivateLabel = self.m_InfoBox:NewUI(12, CLabel)
	self.m_ExpLabel = self.m_InfoBox:NewUI(13, CLabel)
	self.m_ExpSlider = self.m_InfoBox:NewUI(14, CSlider)
	self.m_UseItemTipsBtn = self.m_InfoBox:NewUI(15, CButton)
	self.m_CoinTipsBtn = self.m_InfoBox:NewUI(16, CButton)	
	self.m_ItemAddBtn:AddUIEvent("click", callback(self, "OnBtnClick", "AddItem"))
	self.m_CoinAddBtn:AddUIEvent("click", callback(self, "OnBtnClick", "AddCoin"))
	self.m_LearnOneBtn:AddUIEvent("click", callback(self, "OnBtnClick", "Learn", CSkillCultivatePage.LearnOne, false))
	self.m_LearnTenBtn:AddUIEvent("click", callback(self, "OnBtnClick", "Learn", CSkillCultivatePage.LearnMulti, false))
	self.m_AutoLearnBtn:AddUIEvent("click", callback(self, "OnBtnClick", "AutoLearn"))
	self.m_UseItemTipsBtn:AddUIEvent("click", callback(self, "OnBtnClick", "UseItemTips"))
	self.m_CoinTipsBtn:AddUIEvent("click", callback(self, "OnBtnClick", "CoinItem"))	

	local oCoinItem = CItem.NewBySid(self.m_CoinItemId)
	self.m_CoinTipsBtn:SpriteItemShape(oCoinItem:GetValue("icon"))
end

function CSkillCultivatePage.InitArrowsContent(self)
	self.m_ArrowsGrid:InitChild(function ( obj, idx )
		local oBox = CBox.New(obj)
		oBox:SetGroup(self.m_CenterGrid:GetInstanceID())
		if self.m_SelectCultivateType == idx then
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
		return oBox
	end)
end

function CSkillCultivatePage.RefreshAll(self)
	self.m_SelectCultivateType = g_SkillCtrl.m_RecordCultivateType
	self:RefreshInfo()
	self:RefreshSide()
	self:RefreshCenter()
	self:RefreshArrows()
	self:RefreshWealthInfo()
end

function CSkillCultivatePage.RefreshInfo(self)
	local tData = g_SkillCtrl:GetCultivateServerDataByType(self.m_SelectCultivateType)
	local level = tData.level 
	local exp = tData.exp
	local curCultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level)	
	local nextCultivate  = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level + 1)	
	local itemSid = curCultivate and curCultivate.cost_item.itemid or nextCultivate.cost_item.itemid
	local skillName = curCultivate and curCultivate.name or nextCultivate.name
	local skillCost = curCultivate and curCultivate.cost_coin or nextCultivate.cost_coin
	local itemCount = curCultivate and curCultivate.cost_item.cost_amount or nextCultivate.cost_item.cost_amount
	local expGain = curCultivate and curCultivate.upgrade_gain_exp or nextCultivate.upgrade_gain_exp
	self.m_CurCultivateTitleLabel:SetText(string.format("%sLV %d", skillName, level))
	self.m_CurCultivateDesLabel:SetText(string.format("修炼一次需要%d修炼丹或者%d金币 增加%d修炼经验", itemCount,skillCost, expGain))
	if curCultivate == nil and nextCultivate ~=nil then
		self.m_CurCultivateLabel:SetText(string.format("当前属性:%s", "无"))
	else
		self.m_CurCultivateLabel:SetText(string.format("当前属性:%s", curCultivate.shortdesc))
	end
	if nextCultivate == nil and curCultivate ~=nil then
		self.m_NextCultivateLabel:SetText("下级属性:[ff0000]已到最高等级")	
		self.m_ExpLabel:SetText(string.format(" %d/--",exp))
		self.m_ExpSlider:SetValue(1)		
	else
		self.m_NextCultivateLabel:SetText(string.format("下级属性:%s",nextCultivate.shortdesc))		
		self.m_ExpLabel:SetText(string.format(" %d/%d",exp, nextCultivate.upgrade_total_exp))
		self.m_ExpSlider:SetValue( exp / nextCultivate.upgrade_total_exp)
	end
end

function CSkillCultivatePage.RefreshSide(self, iType)
	local func = function( index )
		local tData = g_SkillCtrl:GetCultivateServerDataByType(index)
		local level = tData.level
		local cultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(index, level)	or g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(index, level + 1)
		
		local oBox	= self.m_SideGrid:GetChild(index)

		oBox.m_TitleLabel:SetText(string.format("%s LV%d",cultivate.name, level))
		if level ~= 0 then
			oBox.m_LevelLabel:SetText(cultivate.shortdesc)
		else
			oBox.m_LevelLabel:SetText("可提高"..cultivate.name)
		end
		
		if self.m_SelectCultivateType == index then
			oBox:SetSelected(true)
		end
		oBox.m_HighLightSprite:SetColor(self:GetHighLightLevelColor(level))
	end

	if iType == nil then
		for k, v in pairs (define.Skill.CultivateType) do
			func(v)	
		end
	else
		func(i)
	end
end

function CSkillCultivatePage.RefreshCenter(self)
	for i = 1, self.m_CenterGrid:GetCount() do
		local oBox = self.m_CenterGrid:GetChild(i)
		if i == self.m_SelectCultivateType then
			oBox:SetSelected(true)
		end
		local tData = g_SkillCtrl:GetCultivateServerDataByType(i)
		local level = tData.level
		oBox.m_HighLightSprite:SetColor(self:GetHighLightLevelColor(level))
	end
end

function CSkillCultivatePage.RefreshArrows(self)
	for i = 1, self.m_ArrowsGrid:GetCount() do
		local oBox = self.m_ArrowsGrid:GetChild(i)
		if i == self.m_SelectCultivateType then
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end
end

function CSkillCultivatePage.OnBtnClick(self, sKey, idx, isAuto)
	if sKey == "Switch" then
		g_SkillCtrl.m_RecordCultivateType = idx
		if self.m_IsAutoLearning then
			g_NotifyCtrl:FloatMsg("停止自动修炼")
			self:OnStopAutoLearn()			
		end
		self:RefreshAll()

	elseif sKey == "Learn" then
		--当在自动修炼时，不能手动点修炼
		if self.m_IsAutoLearning then
			if isAuto == false then
				g_NotifyCtrl:FloatMsg("已经在自动修炼中")
				return
			end
		end
		local tData = g_SkillCtrl:GetCultivateServerDataByType(self.m_SelectCultivateType)
		local level = tData.level 
		local curCultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level)	
		local nextCultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level + 1)	
		local cost = curCultivate and curCultivate.cost_coin or nextCultivate.cost_coin
		local itemSid = curCultivate and curCultivate.cost_item.itemid or nextCultivate.cost_item.itemid
		local skillId = curCultivate and curCultivate.skill_id or nextCultivate.skill_id
		local itemCount = curCultivate and curCultivate.cost_item.cost_amount or nextCultivate.cost_item.cost_amount
		local OwnItemCount = g_ItemCtrl:GetTargetItemCountBySid(itemSid)
		local CoinCount =  math.floor(g_AttrCtrl.coin / cost)  		--身上金币足够修炼的次数
		if nextCultivate == nil and curCultivate ~= nil then
			g_NotifyCtrl:FloatMsg("已经达到修炼最高级，无法修炼")
			if self.m_IsAutoLearning then
				self:OnStopAutoLearn()
			end				
			return
		end
		--点击10次的修炼
		if idx == CSkillCultivatePage.LearnMulti then
			--可修炼的次数大于10次，才进行修炼
			if OwnItemCount + CoinCount >= (CSkillCultivatePage.LearnMulti * itemCount) then
				self:LearnCultivate(skillId, CSkillCultivatePage.LearnMulti, level)				
			else
				--铜币不足，如果当前是在自动修炼状态，则关掉自动修炼，否则提示购买铜币或者修炼丹
				if self.m_IsAutoLearning then
					self:OnStopAutoLearn()
					g_NotifyCtrl:FloatMsg("铜币不足，您可以在商城购买")
				else
					self:OnGoToShopConfirm()
				end	
			end
		--点击1次的修炼
		else
			--可修炼1次的时候，才进行修炼
			if OwnItemCount + CoinCount >= CSkillCultivatePage.LearnOne then
				self:LearnCultivate(skillId, CSkillCultivatePage.LearnOne, level)	
			else
				self:OnGoToShopConfirm()
			end
		end

	elseif sKey == "AutoLearn" then
		if self.m_IsAutoLearning then
			self:OnStopAutoLearn()
		else
			local tData = g_SkillCtrl:GetCultivateServerDataByType(self.m_SelectCultivateType)
			local level = tData.level 
			local curCultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level)	
			local nextCultivate  = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level + 1)	
			local itemCount = curCultivate and curCultivate.cost_item.cost_amount or nextCultivate.cost_item.cost_amount
			local skillCost = curCultivate and curCultivate.cost_coin or nextCultivate.cost_coin			
			local args = 
			{
				msg = string.format("将进行自动修炼至下修炼等级，每次消耗%d修炼丹或者%d金币，当金币不足时自动停止，也可以手动停止", ( itemCount * 10), (skillCost * 10)),
				okCallback = callback(self, "OnAutoLearnConfirm")				
			}
			g_WindowTipCtrl:SetWindowConfirm(args)
		end

	elseif sKey == "AddItem" then
		if self.m_IsAutoLearning then
			g_NotifyCtrl:FloatMsg("停止自动修炼")
			self:OnStopAutoLearn()			
		end
		g_NotifyCtrl:FloatMsg("添加修炼丹")

		elseif sKey	 == "AddCoin" then
		if self.m_IsAutoLearning then
			g_NotifyCtrl:FloatMsg("停止自动修炼")
			self:OnStopAutoLearn()			
		end
		g_NpcShopCtrl:ShowGold2CoinView()

	elseif sKey == "Tips" then
		local title = "修炼"
		local tContent = {
			[1] = "玩家可以通提高修炼技能来提高战斗力。修炼对战斗力的加成是非常明显的，想要战斗力爆表，从学习修炼技能开始！",
			[2] = " ",
			[3] = " ",
		}
		for k, iType in pairs (define.Skill.CultivateType) do
			local str = ""
			local tData = g_SkillCtrl:GetCultivateServerDataByType(iType)
			local level = tData.level
			local cultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(iType, level)	or g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(iType, level + 1)
			if level ~= 0 then
				str = string.format("[%s] Lv%d %s", cultivate.name, level, cultivate.shortdesc)
			else
				str = string.format("[%s] 未修炼", cultivate.name, level, cultivate.shortdesc)
			end
			table.insert(tContent, str)
		end
		table.insert(tContent, " ")
		table.insert(tContent, " ")
		g_WindowTipCtrl:SetWindowItemTipsWindow(title, tContent,
			{widget=  self.m_TipsBtn, side = enum.UIAnchor.Side.Bottom ,offset = Vector2.New(-50, -20)})

	elseif sKey == "UseItemTips" then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(self.m_UseItemId,
		{widget = self.m_UseItemTipsBtn, openView = self.m_ParentView})

	elseif sKey == "CoinItem" then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(self.m_CoinItemId,
		{widget =  self.m_CoinTipsBtn, openView = self.m_ParentView})
	end

end

function CSkillCultivatePage.OnStopAutoLearn(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_IsAutoLearning = false
	self.m_AutoAniBox:SetActive(false)
	self.m_AutoLearnLabel:SetText("自动修炼")
	g_NotifyCtrl:FloatMsg("停止自动修炼")	
end

function CSkillCultivatePage.OnStartAutoLearn(self)
	
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	if self.m_IsAutoLearning == false then
		return
	end
	self.m_AutoAniBox:SetActive(true)
	--如果当前没有在打开关闭画面时，才会自动修炼请求
	if self.m_IsOpenCloseWindow == false then
		self:OnBtnClick("Learn", CSkillCultivatePage.LearnMulti, true )	
	end
	self.m_Timer = Utils.AddTimer(callback(self, "OnStartAutoLearn"), 0.1, 2.0)	
end

function CSkillCultivatePage.LearnCultivate(self , skillId, count, preLevel)
	self.m_ReqBeforeSkillInfo.level = preLevel
	self.m_ReqBeforeSkillInfo.sk = skillId
	g_SkillCtrl:C2GSLearnCultivateSkill(skillId, count )
end

function CSkillCultivatePage.OnCtrlSkillEvent(self, oCtrl, tt)
	if oCtrl.m_EventID == define.Skill.Event.CultivateRefresh then
		self:RefreshInfo()
		self:RefreshSide()
		self:RefreshCenter()
		if oCtrl.m_EventData ~= nil and oCtrl.m_EventData.level > self.m_ReqBeforeSkillInfo.level then
			g_NotifyCtrl:FloatMsg("修炼技能升级...")
			if self.m_IsAutoLearning then
				self:OnStopAutoLearn()
			end
		end
	end
end

function CSkillCultivatePage.OnCtrlItemEvent(self, oCtrl, tt)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshBagItem	then
		self:RefreshWealthInfo()
	end
end

function CSkillCultivatePage.OnCtrlAttrEvent(self, oCtrl, tt)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshWealthInfo()
	end
end

function CSkillCultivatePage.RefreshWealthInfo(self)
	local tData = g_SkillCtrl:GetCultivateServerDataByType(self.m_SelectCultivateType)
	local level = tData.level 
	local curCultivate = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level)	
	local nextCultivate  = g_SkillCtrl:GetCultivateLocalDataByTypeAndLevel(self.m_SelectCultivateType, level + 1)	
	local itemSid = curCultivate and curCultivate.cost_item.itemid or nextCultivate.cost_item.itemid
	local ItemCount = g_ItemCtrl:GetTargetItemCountBySid(itemSid)
	self.m_ItemCountLabel:SetText(tostring(ItemCount))
	self.m_CoinCountLabel:SetText(tostring(g_AttrCtrl.coin))
	self.m_UseItemId = itemSid
	local oUseItem = CItem.NewBySid(itemSid)
	self.m_UseItemTipsBtn:SpriteItemShape(oUseItem:GetValue("icon"))
end

function CSkillCultivatePage.OnAutoLearnConfirm(self)
	self.m_AutoLearnLabel:SetText("暂停自动修炼")
	self.m_IsAutoLearning = true
	self:OnStartAutoLearn()
end

function CSkillCultivatePage.OnGoToShopConfirm(self)
	local args = 
	{
		msg = string.format("铜币不足，是否前去购买"),
		okCallback = function ()
			g_NotifyCtrl:FloatMsg("正在打开商店")	
		end				
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CSkillCultivatePage.GetHighLightLevelColor(self, level)
	local highLighLevel = math.floor(level / 3) + 1 
	if highLighLevel > 10 then
		highLighLevel = 10
	end
	if highLighLevel < 1 then
		highLighLevel = 1
	end
	local color = Color.New(
			CSkillCultivatePage.HighLightLevelColor[highLighLevel][1],
			CSkillCultivatePage.HighLightLevelColor[highLighLevel][2],
			CSkillCultivatePage.HighLightLevelColor[highLighLevel][3],
			CSkillCultivatePage.HighLightLevelColor[highLighLevel][4]
			)
	return color
end

return CSkillCultivatePage