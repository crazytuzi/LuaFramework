---------------------------------------------------------------
--打造界面的 强化 子界面


---------------------------------------------------------------
local CForgeStrengthPage = class("CForgeStrengthPage", CPageBase)

CForgeStrengthPage.StrengthMaxLevel = 100

CForgeStrengthPage.EnumIsCanStrength =
{
	Can = {str = ""} ,
	NotMaterial = {str = "材料不足"} ,
	NotGoldCoin = {str = "水晶不足"} ,
}

function CForgeStrengthPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_EquipType = nil
	self.m_AutoFill = g_ItemCtrl.m_ForgeStrengthAutoFill
	self.m_CostMaterailList = {}
	self.m_StrengthLevel = nil
	self.m_StrengthInfo = {}	--用于发送协议缓存
	self.m_IsCanStrength = CForgeStrengthPage.EnumIsCanStrength.Can
	self.m_NeedMater = {}
end

function CForgeStrengthPage.OnInitPage(self)
	self.m_AutoIntensifyBtn = self:NewUI(1, CButton)
	self.m_IntensifyBtn = self:NewUI(2, CButton)
	self.m_AttrGrid = self:NewUI(3, CGrid)
	self.m_AttrGridBox = self:NewUI(4, CBox)
	self.m_AutoLabel = self:NewUI(5, CLabel)
	self.m_AutoSprite = self:NewUI(6, CSprite)
	self.m_AutoSelectSprite = self:NewUI(7, CSprite)
	self.m_NeedGird = self:NewUI(8, CGrid)
	self.m_TipsBtn = self:NewUI(9, CButton)
	self.m_MainAttrGrid = self:NewUI(10, CGrid)
	self.m_MainAttrLabel = self:NewUI(11, CLabel)
	self.m_EquipIconSpr = self:NewUI(12, CSprite)
	self.m_EquipItemLevelSpr = self:NewUI(13, CSprite)
	self.m_EquipBox = self:NewUI(14, CBox)

	self.m_AttrGridBox:SetActive(false)

	self.m_AutoIntensifyBtn:AddUIEvent("click", callback(self, "OnAutoIntensify"))
	self.m_IntensifyBtn:AddUIEvent("click", callback(self, "OnIntensify"))
	self.m_AutoSprite:AddUIEvent("click", callback(self, "OnAutoFill"))
	self.m_EquipBox:AddUIEvent("click", callback(self, "OnShowEquip"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrlEvent"))
	self.m_TipsBtn:AddHelpTipClick("forge_strength")

	g_GuideCtrl:AddGuideUI("forge_strength_fast_strength_btn", self.m_AutoIntensifyBtn)

	self:InitGemGrid()
	self:InitAttrGrid()
	self:InitAutoFill()
	self:RefreshAll()
end

function CForgeStrengthPage.ShowPage(self, pos)
	self.m_EquipType = pos
	if  self.m_IsInit then
		self:RefreshAll()
	end
	CPageBase.ShowPage(self)
end

function CForgeStrengthPage.RefreshAll(self)
	self:RefreshAttrGrid()
	self:RefreshNeedGrid()
end

function CForgeStrengthPage.OnAutoIntensify(self)
	if g_ItemCtrl:CanFastStrength() then
		local args = 
		{
			msg = "一键突破将会帮您突破所有部位的装备，是否继续?",
			okCallback = function ( )
				g_ItemCtrl:C2GSFastStrength()
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(args)	
	else
		self:ShowMaterailTips(self.m_NeedMater.m_Sid, self.m_NeedMater.m_Box)
	end
end

function CForgeStrengthPage.OnIntensify(self)
	if self.m_IsCanStrength == CForgeStrengthPage.EnumIsCanStrength.Can then
		if self.m_StrengthLevel >= CForgeStrengthPage.StrengthMaxLevel then
			g_NotifyCtrl:FloatMsg("已经突破到最高等级")
		else
			g_ItemCtrl:C2GSEquipStrength(self.m_EquipType, self.m_StrengthInfo.strength_info)	
		end
	else
		if self.m_IsCanStrength == CForgeStrengthPage.EnumIsCanStrength.NotMaterial then
			self:ShowMaterailTips(self.m_NeedMater.m_Sid, self.m_NeedMater.m_Box)
		end
		g_NotifyCtrl:FloatMsg(self.m_IsCanStrength.str)	
	end
end


function CForgeStrengthPage.OnAutoFill(self)
	self.m_AutoFill = not self.m_AutoFill
	if self.m_AutoFill then
		g_NotifyCtrl:FloatMsg("设置自动水晶代替材料")
	else
		g_NotifyCtrl:FloatMsg("取消设置水晶代替材料")
	end
	g_ItemCtrl.m_ForgeStrengthAutoFill = self.m_AutoFill
	self:RefreshNeedGrid()
end

function CForgeStrengthPage.RefreshAttrGrid(self)
	local equipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	self.m_StrengthLevel = equipData and equipData:GetStrengthLevel() or 0
	self.m_MainAttrLabel:SetText(string.format("突破等级:%d", self.m_StrengthLevel))
	local tOldAttr = g_ItemCtrl:GetEquipStrengthDataByPosAndLevel(self.m_EquipType, self.m_StrengthLevel) or {}
	local tNewAttr = g_ItemCtrl:GetEquipStrengthDataByPosAndLevel(self.m_EquipType, self.m_StrengthLevel + 1) or {}
	local tAttr = {}
	local tKey = {}
	for k,v in pairs(tOldAttr) do
		if define.Attr.String[k] ~= nil and v ~= 0 then
			tAttr[k] = tAttr[k] or {}
			tAttr[k].from = v
			self:InserKey(tKey , k)	
		end
	end
	for k,v in pairs(tNewAttr) do
		if define.Attr.String[k] ~= nil and v ~= 0 then
			tAttr[k] = tAttr[k] or {}
			tAttr[k].to = v
			self:InserKey(tKey , k)	
		end
	end
	for i = 1, 4 do
		local oBox = self.m_AttrGrid:GetChild(i)
		if i <= #tKey then
			oBox:SetActive(true)
			local sKey = define.Attr.String[tKey[i]] or tKey[i]
			local sBaseAttr = tostring(g_ItemCtrl:AttrStringConvert(tKey[i], equipData:GetEquipBaseAttrByKey(tKey[i])).."+") 

			local sForm = ""
			if  tAttr[tKey[i]].from ~= nil then
				sForm = g_ItemCtrl:AttrStringConvert(tKey[i], tAttr[tKey[i]].from)
			else
				sForm = g_ItemCtrl:AttrStringConvert(tKey[i], 0)
			end

			local sTo = ""
			if tAttr[tKey[i]].to ~= nil then
				sTo = g_ItemCtrl:AttrStringConvert(tKey[i], tAttr[tKey[i]].to) 
			else
				sTo = g_ItemCtrl:AttrStringConvert(tKey[i], 0)
			end

			local sOffset = g_ItemCtrl:AttrStringConvert(tKey[i], 0)
			if tAttr[tKey[i]].to ~= nil and tAttr[tKey[i]].from ~= nil then
				sOffset = g_ItemCtrl:AttrStringConvert(tKey[i], (tAttr[tKey[i]].to - tAttr[tKey[i]].from))
			elseif  tAttr[tKey[i]].to ~= nil then
				sOffset = g_ItemCtrl:AttrStringConvert(tKey[i], tAttr[tKey[i]].to)				
			end

			oBox.m_KeyLabel:SetText(sKey)
			oBox.m_BaseLabel:SetText(sBaseAttr)
			oBox.m_StrengthLabel:SetText(sForm)	
			oBox.m_Offsetlabel:SetText()
			oBox.m_Offsetlabel:SetText(sOffset)		
			if tNewAttr ~= nil and CForgeStrengthPage.StrengthMaxLevel ~= self.m_StrengthLevel then
				oBox.m_Offsetlabel:SetActive(true)
				oBox.m_OffsetSprite:SetActive(true)
			else
				oBox.m_Offsetlabel:SetActive(false)
				oBox.m_OffsetSprite:SetActive(false)
			end

			--自适应
			local p1 = oBox.m_Offsetlabel:GetLocalPos()
			local w1 = oBox.m_Offsetlabel:GetWidth()
			oBox.m_OffsetSprite:SetLocalPos(Vector3.New(p1.x - w1 - 2, p1.y, 0))

			local p2 = oBox.m_OffsetSprite:GetLocalPos()
			local w2 = oBox.m_OffsetSprite:GetWidth()
			oBox.m_StrengthLabel:SetLocalPos(Vector3.New(p2.x - w2 - 2 , p2.y, 0))

			local p3 = oBox.m_StrengthLabel:GetLocalPos()
			local w3 = oBox.m_StrengthLabel:GetWidth()
			oBox.m_BaseLabel:SetLocalPos(Vector3.New(p3.x - w3 - 2 , p3.y, 0))

		else
			oBox:SetActive(false)
		end
	end
	self.m_AttrGrid:Reposition()
end

function CForgeStrengthPage.RefreshNeedGrid(self)
	self.m_IsCanStrength = CForgeStrengthPage.EnumIsCanStrength.Can
	self.m_NeedMater = {}
	local equipData = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	self.m_StrengthLevel = equipData and equipData:GetStrengthLevel() or 0	
	local strengthData = g_ItemCtrl:GetEquipStrengthDataByPosAndLevel(self.m_EquipType, self.m_StrengthLevel) or {}
	local tMaterailList = {}
	local tStrengthInfo = {}
	local tSidList = strengthData.sid_list or {}
	for i = 1, 3 do
		if i <= #tSidList and CForgeStrengthPage.StrengthMaxLevel ~= self.m_StrengthLevel then	
			self.m_CostMaterailList[i]:SetActive(true)				
			local needCount = tonumber(tSidList[i].amount) 
			local sid = tSidList[i].sid				
			local oItem = CItem.NewBySid(sid)
			local ownCount = g_ItemCtrl:GetTargetItemCountBySid(sid)
			local str = ""
			local tPrice = g_ItemCtrl.m_MaterailPriceCache[sid] or 0		
			self.m_CostMaterailList[i].m_ItemSprite:SpriteItemShape(oItem:GetValue("icon"))		
			self.m_CostMaterailList[i].m_QulitySprite:SetItemQuality(oItem:GetValue("qulity"))		
			self.m_CostMaterailList[i].m_ItemSprite:AddUIEvent("click", callback(self, "ShowMaterailTips", sid))
			if needCount > ownCount then 
				str = string.format("#R%d[8A6029]/%d", ownCount, needCount)
				local tSid = sid
				local tCount = needCount - ownCount
				local tCost = tPrice * tCount
				table.insert(tMaterailList, {sid = tSid, count = tCount, cost = tCost})		
				self.m_NeedMater.m_Sid = tSid						
				self.m_NeedMater.m_Box = self.m_CostMaterailList[i]
			else
				str = string.format("#G%d/%d", ownCount, needCount)
			end
			--如果材料不足所需材料，则给服务器发当前拥有材料，否则发所需材料
			local argCount = needCount > ownCount and ownCount or needCount
			--如果当前不设定自动填充，则给服务器传价格为0的道具，否则穿该道具价格
			local argPirce = self.m_AutoFill and  tPrice or 0
			table.insert(tStrengthInfo, {sid = sid, amount = argCount, price = argPirce})
			self.m_CostMaterailList[i].m_CountLabel:SetText(str)
		else
			self.m_CostMaterailList[i]:SetActive(false)
		end
	end		
	self.m_NeedGird:Reposition()
	--设置自动水晶s替换材料 
	local cost = 0
	for i = 1, #tMaterailList do
		cost = cost + tMaterailList[i].cost
	end
	--客户的判断是否能强化
	if cost ~= 0 then
		if self.m_AutoFill then
			if g_AttrCtrl.goldcoin < cost then
				self.m_IsCanStrength = CForgeStrengthPage.EnumIsCanStrength.NotGoldCoin
			end
		else
			self.m_IsCanStrength = CForgeStrengthPage.EnumIsCanStrength.NotMaterial
		end
	end
	--暂时隐藏
	self.m_AutoLabel:SetActive(false)
	--self.m_AutoLabel:SetActive(cost > 0)

	self.m_AutoLabel:SetText("自动"..string.numberConvert(cost).."水晶代替材料")
	--发送强化协议所需参数
	self.m_StrengthInfo.strength_info = tStrengthInfo
end

function CForgeStrengthPage.UpdateEquip(self, pos)
	self.m_EquipType = pos
	self:RefreshAll()
end

function CForgeStrengthPage.InitGemGrid(self )
	self.m_CostMaterailList = {}
	self.m_NeedGird:InitChild(function(obj, idx )
		local oBox = CBox.New(obj)
		oBox.m_ItemSprite = oBox:NewUI(1, CSprite)
		oBox.m_CountLabel = oBox:NewUI(2, CLabel)
		oBox.m_QulitySprite = oBox:NewUI(3, CSprite)
		table.insert(self.m_CostMaterailList, idx, oBox)
		return oBox
	end	)
end

function CForgeStrengthPage.InitAttrGrid( self )
	self.m_AttrGrid:Clear()
	for i = 1, 4 do
		local tBox = self.m_AttrGridBox:Clone()
		tBox:SetActive(true)
		tBox.m_KeyLabel = tBox:NewUI(1, CLabel)
		tBox.m_BaseLabel = tBox:NewUI(2, CLabel)
		tBox.m_StrengthLabel = tBox:NewUI(3, CLabel)
		tBox.m_Offsetlabel = tBox:NewUI(4, CLabel)
		tBox.m_OffsetSprite = tBox:NewUI(5, CSprite)
		self.m_AttrGrid:AddChild(tBox)
	end
end

function CForgeStrengthPage.InserKey( self, t, key)
	for k, v in pairs(t) do
		if v == key then
			return 
		end
	end
	table.insert(t, key)
end

function CForgeStrengthPage.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshItemPrice then   
	   self:RefreshNeedGrid()

	elseif oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		self:RefreshAttrGrid()
	end
end

function CForgeStrengthPage.OnCtrlAttrlEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshNeedGrid()
	end
end

function CForgeStrengthPage.ShowMaterailTips(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
	{widget=  oBox, openView = self.m_ParentView}, nil, {showQuickBuy = true, ignoreCloseOwnerView = true})
end

function CForgeStrengthPage.InitAutoFill(self)
	if self.m_AutoFill == true then
		self.m_AutoSprite:SetSelected(true)
	end
end

function CForgeStrengthPage.RefreshEquip(self, equipPos)
	local tData = g_ItemCtrl:GetEquipedByPos(equipPos)
	local shape = tData:GetValue("icon") or 0
	local itemLevel = tData:GetValue("itemlevel")	
	self.m_EquipIconSpr:SpriteItemShape(shape)
	self.m_EquipItemLevelSpr:SetItemQuality(itemLevel)
end

function CForgeStrengthPage.OnShowEquip(self)
	local oItem = g_ItemCtrl:GetEquipedByPos(self.m_EquipType)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem)
	end	
end

return CForgeStrengthPage