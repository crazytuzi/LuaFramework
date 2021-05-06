-----------------------------------------------------------------------------
--装备的基本属性显示界面


-----------------------------------------------------------------------------

local CItemTipsEquipInfoPage = class("CItemTipsEquipInfoPage", CPageBase)

function CItemTipsEquipInfoPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_CItem = nil

	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_ItemBox = self:NewUI(2, CItemTipsBox)
	self.m_AttrTable = self:NewUI(3, CTable)
	self.m_AttrContentCloneBox = self:NewUI(4, CBox)
	self.m_AttrTitleCloneBox = self:NewUI(5, CBox)
	self.m_AttrGemCloneBox = self:NewUI(6, CBox)
	self.m_EquipSuitShowPart = self:NewUI(7, CItemTipsEquipSuitInfoPart)
	self.m_TipWidget = self:NewUI(8, CWidget)
	self.m_AttrOptionBox = self:NewUI(10, CBox)
	self.m_AttrContentCloneSEBox = self:NewUI(11, CBox)
	self.m_PosLabel = self:NewUI(12, CLabel)
	self.m_FitLabel = self:NewUI(13, CLabel)
	self.m_LevelLabel = self:NewUI(14, CLabel)
	self.m_ScoreLabel = self:NewUI(15, CLabel)
	self.m_AttrContentListCloneBox = self:NewUI(16, CBox)
	self.m_TitleQualitySpr = self:NewUI(17, CSprite)
	self.m_SubTitleQualitySpr = self:NewUI(18, CSprite)
	self:InitContent()

end

function CItemTipsEquipInfoPage.InitContent(self)
	self.m_AttrContentCloneBox:SetActive(false)
	self.m_AttrTitleCloneBox:SetActive(false)
	self.m_AttrGemCloneBox:SetActive(false)
	self.m_EquipSuitShowPart:SetActive(false)
	self.m_AttrOptionBox:SetActive(false)
	self.m_AttrContentCloneSEBox:SetActive(false)
	self.m_AttrContentListCloneBox:SetActive(false)
end

function CItemTipsEquipInfoPage.AdjustHeight(self )
	self.m_AttrTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_AttrTable.m_Transform)
	self:SetHeight( self:GetHeight() + bounds.max.y - bounds.min.y)
end

function CItemTipsEquipInfoPage.OnForgeShow( self )
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade then
		local pos = self.m_CItem:GetValue("pos") or define.Equip.Pos.Weapon
		CForgeMainView:ShowView(function (oView)
			oView:ShowIntensifyPage()
			oView:OnEquipClick(pos)
		end)
		self.m_ParentView:CloseView()
		if CAttrMainView:GetView() ~= nil then
			CAttrMainView:CloseView()
		end
	else
		g_NotifyCtrl:FloatMsg(string.format("%d级开启装备功能哦", data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade))
	end
end

function CItemTipsEquipInfoPage.OnChangeShow( self )
	local t = g_ItemCtrl:GetEquipByPosAndMaxLevel(self.m_CItem:GetValue("pos"), g_AttrCtrl.grade)
	if #t == 0 then
		g_NotifyCtrl:FloatMsg("没有同类装备可以更换")
	else
		--oView:SetData(tItem, args.equipList, CItemTipsEquipChangeView.enum.ChangeInfo, args.showCenterMaskWidget)
		CItemTipsAttrEquipChangeView:ShowView(function (oView)
			oView:SetData(t[1], t)
		end)
		-- g_WindowTipCtrl:SetWindowItemTipsEquipItemChange(t[1],
		-- 	{equipList = t, widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), })	
		self.m_ParentView:CloseView()		
	end
end

function CItemTipsEquipInfoPage.ShowPage( self, tItem, isLink)
	CPageBase.ShowPage(self)
	self:SetInitBox(tItem, isLink)
end

function CItemTipsEquipInfoPage.SetInitBox( self, tItem, isLink)
	if not tItem then
		return
	end

	self.m_CItem = tItem
	
	self.m_ItemBox:SetItemData(tItem:GetValue("sid"), 1, nil , {oItem = tItem})
	self.m_ItemBox:SetShowTips(false)
	self.m_AttrTable:Clear()
	self.m_PosLabel:SetText("类型:"..define.Equip.PosName[tItem:GetValue("pos")] ) 
	local level = tItem:GetValue("equip_level") or tItem:GetValue("level")
	self.m_LevelLabel:SetText("等级:"..level) 
	self.m_FitLabel:SetText("适用:"..tItem:GetEquipFitInfo())
	self.m_ScoreLabel:SetText("评分:"..tItem:GetEquipScore()) 

	local itemlevel = tItem:GetValue("itemlevel")
	self.m_TitleQualitySpr:SetTitleQuality(itemlevel, 1)
	self.m_SubTitleQualitySpr:SetTitleQuality(itemlevel, 2)

	local t1 = tItem:GetEquipAttrBase() or {}
	local t2 = tItem:GetEquipAttrStrength() or {}
	local t3 = tItem:GetEquipAttrFuWen() or {}
	local t4 = tItem:GetEquipAttrGem() or {}

	--显示强化等级
	local strengthLevel = 0
	for _,v in pairs (t2) do
		if v.key == "level" then	
			local lv = v.value or 0
			strengthLevel = tonumber(lv) 
		end
	end
	local name = string.format("%s+%d", tItem:GetValue("name"), strengthLevel)
	self.m_NameLabel:SetQualityColorText(tItem:GetValue("itemlevel"), name)

	local t1_temp = table.copy(t1)
	t1_temp = self:SortAttr(t1_temp)
	--强化属性和装备属性加在一起显示
	for k, v in pairs(t2) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			local isFind = false
			for _k, _v in pairs(t1_temp) do
				if _v.key == v.key then
					isFind = true					
					_v.value = _v.value + v.value
					_v.strength_value = v.value or 0
				end
			end
			--如果装备没有该强化属性，则插入强化属性
			if isFind == false then
				local t = {key = v.key, value = v.value, strength_value = v.value}				
				table.insert(t1_temp, t)
			end			
		end
	end

	self:AddTitleBox("装备属性")
	local baseAttr = {}
	for _,v in pairs (t1_temp) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			local sKey = define.Attr.String[v.key] or v.key
			local str = string.format("%s+%s", sKey, g_ItemCtrl:AttrStringConvert(v.key, v.value))
			local strength = ""
			if v.strength_value ~= nil then
				strength = string.format("(+%s)", g_ItemCtrl:AttrStringConvert(v.key, v.strength_value))							
			end	

			local d = {str = str}
			table.insert(baseAttr, d)
			self:AddContentListBox(baseAttr)	
			baseAttr = {}
		end
	end
	

	--显示淬灵属性
	local fuwenAttr = { }	
	for _,v in pairs (t3) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then					
			local sKey = define.Attr.String[v.key] or v.key
			local str = sKey.."+"..g_ItemCtrl:AttrStringConvert(v.key, v.value)
			local d = {str = "[54e414]"..str}
			table.insert(fuwenAttr, d)
		end	
	end
	if next(fuwenAttr) then
		self:AddTitleBox("淬灵属性")
		self:AddContentListBox(fuwenAttr)
	end

	local gemAttr = self.m_CItem:GetEquipGemAttr()
	local str = nil
	if next(gemAttr) ~= nil then
		for k, v in pairs(gemAttr) do
			if str ~= nil then
				str = str .. "\n"
			end			
			str = string.format("%s+%s", define.Attr.String[k], g_ItemCtrl:AttrStringConvert(k, v)) 
		end
	end
	if str then		
		self:AddTitleBox("宝石属性")
		table.sort(t4, function(a,b)
			return a.sid > b.sid
		end)
		local temp = table.copy(data.itemdata.GEM[t4[1].sid]) 
		local name = temp.name
		name = string.gsub(name, string.format("%d级", temp.level), "")
		local d = {str = string.format("[4dc8e5]%s   %s", name, str)}
		self:AddContentListBox({[1] = d})
	end

	-- if str then
	-- 	self.m_MainAttrBox:SetActive(true)
	-- 	self.m_MainAttrLabel:SetText(str)
	-- else
	-- 	self.m_MainAttrBox:SetActive(false)
	-- end



	-- table.sort(t4, function(a,b)
	-- 	return a.sid > b.sid
	-- end)
	-- if #t4 > 0 then
	-- 	local oGemBox = nil
	-- 	if #t4 > 0 then
	-- 		oGemBox = self.m_AttrGemCloneBox:Clone()
	-- 		oGemBox:SetActive(true)
	-- 		self.m_AttrTable:AddChild(oGemBox)
	-- 		oGemBox.m_Grid = oGemBox:NewUI(1, CGrid) 
	-- 		oGemBox.m_Grid:InitChild(function(obj, index)
	-- 			local oSprite = CSprite.New(obj)
	-- 			if index <= #t4 then
	-- 				local data = data.itemdata.GEM[t4[index].sid]
	-- 				oSprite:SetActive(true)
	-- 				oSprite:SpriteItemShape(data.icon)
	-- 			else
	-- 				oSprite:SetActive(false)
	-- 			end

	-- 			return oSprite
	-- 		end)		
	-- 	end
	-- end

	--装备特效
	local other = self.m_CItem:GetEquipSEString()
	if other ~= "无" then
		self:AddTitleBox("装备效果")	
		self:AddContentSEBox(self.m_CItem:GetEquipSEString(2))
	end

	--是否是装备链接
	if isLink ~= true then
		local tBox = self.m_AttrOptionBox:Clone()
		tBox:SetActive(true)
		tBox.m_ForgeBtn = tBox:NewUI(1, CButton)
		tBox.m_ChangeBtn = tBox:NewUI(2, CButton)
		tBox.m_ForgeBtn:AddUIEvent("click", callback(self, "OnForgeShow"))
		tBox.m_ChangeBtn:AddUIEvent("click", callback(self, "OnChangeShow"))
		self.m_AttrTable:AddChild(tBox)
	end

	--self:ShowEquipSuitPart()	
	self:AdjustHeight()

end

function CItemTipsEquipInfoPage.ShowEquipSuitPart( self )
	self.m_EquipSuitShowPart:SetActive(true)
	self.m_EquipSuitShowPart:SetInitBox(self.m_CItem)
end

function CItemTipsEquipInfoPage.AddTitleBox(self, text)
	local tBox = self.m_AttrTitleCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_TitleLabel = tBox:NewUI(1, CLabel):SetText(text)			
	self.m_AttrTable:AddChild(tBox)
end

function CItemTipsEquipInfoPage.AddContentBox(self, text, subText)
	local tBox = self.m_AttrContentCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel = tBox:NewUI(1, CLabel):SetText(text)
	tBox.m_OtherLabel = tBox:NewUI(2, CLabel)

	--隐藏装备强化属性单独显示
	if true then
		tBox.m_OtherLabel:SetActive(false)
	else
		if subText ~= nil and subText ~= "" then
			tBox.m_OtherLabel:SetActive(true)
			tBox.m_OtherLabel:SetText(subText)
		else
			tBox.m_OtherLabel:SetActive(false)
		end		
	end

	self.m_AttrTable:AddChild(tBox)
end

function CItemTipsEquipInfoPage.AddContentSEBox(self, text)
	local tBox = self.m_AttrContentCloneSEBox:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel = tBox:NewUI(1, CLabel):SetText(text)
	self.m_AttrTable:AddChild(tBox)
end

function CItemTipsEquipInfoPage.AddContentListBox(self, list)
	local tBox = self.m_AttrContentListCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel1 = tBox:NewUI(1, CLabel)
	tBox.m_CompareSpr1 = tBox:NewUI(2, CSprite)
	tBox.m_ContentLabel2 = tBox:NewUI(3, CLabel)
	tBox.m_CompareSpr2 = tBox:NewUI(4, CSprite)
	tBox.m_Box1 = self:NewUI(5, CBox)
	tBox.m_Box2 = self:NewUI(6, CBox)
	tBox.m_ContentLabel1:SetActive(false)
	tBox.m_CompareSpr1:SetActive(false)
	tBox.m_ContentLabel2:SetActive(false)
	tBox.m_CompareSpr2:SetActive(false)	
	if list[1] and list[1].str then
		tBox.m_ContentLabel1:SetActive(true)
		tBox.m_ContentLabel1:SetText(list[1].str)

		if list[1].isUp ~= nil then
			tBox.m_CompareSpr1:SetActive(true)
			if list[1].isUp then
				tBox.m_CompareSpr1:SetSpriteName("pic_tisheng")
			else
				tBox.m_CompareSpr1:SetSpriteName("pic_xiajiang")
			end
			tbox.m_Box1:SimulateOnEnable()
		end		
	end

	if list[2] and list[2].str then
		tBox.m_ContentLabel2:SetActive(true)
		tBox.m_ContentLabel2:SetText(list[2].str)

		if list[2].isUp ~= nil then
			tBox.m_CompareSpr2:SetActive(true)
			if list[2].isUp then
				tBox.m_CompareSpr2:SetSpriteName("pic_tisheng")
			else
				tBox.m_CompareSpr2:SetSpriteName("pic_xiajiang")
			end
			tbox.m_Box2:SimulateOnEnable()
		end		
	end

	self.m_AttrTable:AddChild(tBox)
end

function CItemTipsEquipInfoPage.SortAttr(self, attrs)
	local t = {}
	for _k, _v in ipairs(define.Attr.AttrKey) do 
		for k,v in pairs(attrs) do
			if define.Attr.String[v.key] ~= nil and _v == v.key then			
				local d = {key = v.key, value = v.value}
				table.insert(t, d)		
			end
		end
	end
	return t
end

return CItemTipsEquipInfoPage