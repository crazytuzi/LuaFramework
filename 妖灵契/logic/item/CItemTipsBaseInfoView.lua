---------------------------------------------------------------
--物品基本信息展示窗口


---------------------------------------------------------------

local CItemTipsBaseInfoView = class("CItemTipsBaseInfoView", CViewBase)

CItemTipsBaseInfoView.enum =
{
	BaseInfo = 1,	--基本信息
	SellInfo = 2	--出售信息
}

CItemTipsBaseInfoView.EnumPopup = 
{
	Use  = { Enum = 1, String = "使用", Key = "use"},
	Get  = { Enum = 2, String = "获取", Key = "get"},	
	Sell = { Enum = 3, String = "出售", Key = "sell"},	
	Buy  = { Enum = 4, String = "购买", key = "buy"},
	Composite  = { Enum = 5, String = "合成", key = "composite"},
}

CItemTipsBaseInfoView.BatUseMinCount = 2

function CItemTipsBaseInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsBaseInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
	--self.m_ExtendClose = "ClickOut"

	self.m_OwnerView = nil
	self.m_ItemInfo = nil
	self.m_Type = nil
	self.m_PopupList = {}
	self.m_SourceBoxList = {}
end

function CItemTipsBaseInfoView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ItemIconSprite = self:NewUI(2, CSprite)
	self.m_ItemQualitySprite = self:NewUI(3, CSprite)
	self.m_ItemNameLabel = self:NewUI(4, CLabel)
	self.m_ItemTypeLabel = self:NewUI(5, CLabel)
	self.m_ItemUseforLabel = self:NewUI(6, CLabel)
	self.m_ItemBingSprite = self:NewUI(7, CSprite)
	self.m_ItemDestroyBtn = self:NewUI(8, CButton)
	self.m_ItemTimeLimitLabel = self:NewUI(9, CLabel)	
	self.m_ItemPriceLabel = self:NewUI(10, CLabel)
	self.m_ItemDesLabel = self:NewUI(11, CLabel)
	self.m_ItemCountLabel = self:NewUI(12, CLabel)
	self.m_ItemUseBtn = self:NewUI(13, CButton)
	self.m_ItemUnConfirmleBtn = self:NewUI(14, CButton)	--可变功能按钮
	self.m_ItemUnConfirmleLabel = self:NewUI(15, CLabel)
	self.m_ItemMorePopupBox = self:NewUI(16, CPopupBox, true, CPopupBox.EnumMode.NoneSelectedMode,nil, true)
	self.m_ItemMorePopupBox.m_BgSprite = self.m_ItemMorePopupBox:NewUI(8, CSprite)
	self.m_ItemUseBtnLabel = self:NewUI(17, CLabel)
	self.m_FindWayGroup = self:NewUI(18, CBox)
	self.m_FindWayGrid = self:NewUI(19, CGrid)
	self.m_FindWayCloneBox = self:NewUI(20, CBox)
	self.m_BottomGroup = self:NewUI(21, CWidget)
	self.m_BgSprite = self:NewUI(22, CSprite)
	self.m_MaskGrid = self:NewUI(23, CGrid)
	self.m_DesBgSpr = self:NewUI(24, CSprite)
	self.m_SourceWayLabel = self:NewUI(25, CLabel)
	self.m_SourceWayGrid = self:NewUI(26, CGrid)
	self.m_SourceWayBox = self:NewUI(27, CBox)
	self.m_FindWayGroupBgSrp = self:NewUI(28, CSprite)
	self.m_TitleQualitySpr = self:NewUI(29, CSprite)
	self.m_SubTitleQualitySpr = self:NewUI(30, CSprite)
	self.m_MaskWidget = self:NewUI(31, CBox)
	self.m_ItemBgSpr = self:NewUI(32, CSprite)
	self.m_PartnerBgSpr = self:NewUI(33, CSprite)
	self.m_PartnerShapSpr = self:NewUI(34, CSprite)
	self.m_PartnerQualitySpr = self:NewUI(35, CSprite)	

	self:InitContent()
end

function CItemTipsBaseInfoView.InitContent(self, type)
	UITools.ResizeToRootSize(self.m_MaskGrid)
	self.m_MaskGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "OnMaskClose"))
		return oBox
	end)
	self.m_MaskWidget:AddUIEvent("click", callback(self, "OnMaskClose"))

	self.m_ItemUseBtn:AddUIEvent("click", callback(self, "OnBtnClick", "use"))
	self.m_ItemDestroyBtn:AddUIEvent("click", callback(self, "OnBtnClick", "destory"))
	self.m_ItemUnConfirmleBtn:SetActive(false)
	self.m_FindWayGroup:SetActive(false)
	self.m_FindWayCloneBox:SetActive(false)
	self.m_SourceWayBox:SetActive(false)
	self.m_SourceWayLabel:SetActive(false)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))	
end

function CItemTipsBaseInfoView.SetContent(self, type, tItem)
	self.m_Type = type
	self:SetInitBox(tItem)

	if self.m_Type == CItemTipsBaseInfoView.enum.BaseInfo then		
		--显示获取途径
		self:OnBtnClick("get")	
	else
		self.m_FindWayGroup:SetActive(false)
	end
end

function CItemTipsBaseInfoView.SetInitBox( self, tItem)
	if not tItem then
		return		
	end
	self.m_ItemInfo = tItem
	self:RefreshBaeInfo()
	if self.m_Type == CItemTipsBaseInfoView.enum.BaseInfo then
		self.m_ItemUseBtn:SetActive(true)
		self:RefreshBtnState()
	elseif self.m_Type == CItemTipsBaseInfoView.enum.SellInfo then
		self.m_ItemUseBtn:SetActive(false)
		self.m_ItemUnConfirmleBtn:SetActive(false)
		self.m_ItemMorePopupBox:SetActive(false)
	end

	self:RefreshBg()
end

function CItemTipsBaseInfoView.RefreshBtnState( self )
	if self.m_ItemInfo:GetLimitTime() ~= "已失效" then
		self.m_ItemUseBtn:SetActive(true)
		self.m_ItemDestroyBtn:SetActive(false)
		local count = self.m_ItemInfo:GetValue("amount")	
		local useType = self.m_ItemInfo:GetValue("use_type")
		local compose_amount = self.m_ItemInfo:GetValue("compose_amount") or 0
		local compose_item = self.m_ItemInfo:GetValue("compose_item") or {}

		self.m_PopupList = {}
		local isInbagView = CItemBagMainView:GetView() ~= nil
			
		if useType ~= nil and useType ~= "" then
			if useType == "partner_awake" then
				if isInbagView or self.m_ItemInfo:GetValue("composable") == 1 then
					self.m_ItemUseBtnLabel:SetText("使用")
				else
					self.m_ItemUseBtnLabel:SetText("确定")
				end
			elseif useType == "composite_in_bag" then
				self.m_ItemUseBtnLabel:SetText("合成")	
			else
				self.m_ItemUseBtnLabel:SetText("使用")
			end

			--如果，右侧按钮有使用功能，则左侧更多不出现使用
			--table.insert(self.m_PopupList, CItemTipsBaseInfoView.EnumPopup.Use)	
		else
			self.m_ItemUseBtnLabel:SetText("确定")
		end

		if isInbagView and self.m_ItemInfo:GetValue("sale_price") ~= 0 then
			table.insert(self.m_PopupList, CItemTipsBaseInfoView.EnumPopup.Sell)	
		end

		if self.m_ItemInfo:GetValue("composable") == 1 then
			if isInbagView then
				table.insert(self.m_PopupList, CItemTipsBaseInfoView.EnumPopup.Composite)	
			else
				self.m_ItemUseBtnLabel:SetText("合成")
			end
		else
			if compose_amount ~= 0 and next(compose_item) and useType ~= "composite_in_bag" then
				table.insert(self.m_PopupList, CItemTipsBaseInfoView.EnumPopup.Composite)	
			end
		end

		self.m_ItemUnConfirmleBtn:SetActive(false)
		self.m_ItemMorePopupBox:SetActive(false)
		if #self.m_PopupList == 1 then
			self.m_ItemUnConfirmleBtn:SetActive(true)
			self.m_ItemUnConfirmleLabel:SetText(self.m_PopupList[1].String)
			self.m_ItemUnConfirmleBtn:AddUIEvent("click", callback(self, "OnBtnClick", self.m_PopupList[1].Key ))

			---如果左侧功能按钮是1个，则点击获取途径以外的按钮会隐藏获取途径
			--g_UITouchCtrl:TouchOutDetect(self.m_FindWayGroup, callback(self, "HideFindWayGroup"))

			self.m_ItemUseBtn:SetLocalPos(Vector3.New(106, self.m_ItemUseBtn:GetLocalPos().y, 0))

		elseif #self.m_PopupList > 1 then
			self.m_ItemMorePopupBox:ShowAniConfig()
			self.m_ItemMorePopupBox:Clear()
			local FindWarBtnIndex = 0
			self.m_ItemMorePopupBox:SetActive(true)
			self.m_ItemMorePopupBox:SetCallback(callback(self, "OnMoreClick"))
			for i = 1, #self.m_PopupList  do				
				if self.m_PopupList[i].String == "获取" then
					FindWarBtnIndex = (#self.m_PopupList - i) + 1
					self.m_ItemMorePopupBox:AddSubMenu(self.m_PopupList[i].String, nil, nil, false)
				else			
					self.m_ItemMorePopupBox:AddSubMenu(self.m_PopupList[i].String)	
				end				
			end	
			self.m_ItemMorePopupBox:SetPopupShowAni(false)

			--如果左侧功能按钮是2个以上（包括2个）则，把获取途径挂到popupbox上，方便同时隐藏
			-- self.m_FindWayGroup.m_Transform:SetParent(self.m_ItemMorePopupBox.m_BgSprite.m_Transform)
			-- if FindWarBtnIndex ~= 0 then
			-- 	local pos = self.m_FindWayGroup:GetLocalPos()
			-- 	local h = self.m_FindWayCloneBox:GetHeight()
			-- 	self.m_FindWayGroup:SetLocalPos(Vector3.New(pos.x, pos.y + FindWarBtnIndex * h, pos.z))
			-- end

			self.m_ItemUseBtn:SetLocalPos(Vector3.New(106, self.m_ItemUseBtn:GetLocalPos().y, 0))

		else
			self.m_ItemUseBtn:SetLocalPos(Vector3.New(0, self.m_ItemUseBtn:GetLocalPos().y, 0))
		end	
	else
		self.m_ItemDestroyBtn:SetActive(true)
		self.m_ItemUseBtn:SetActive(false)
		self.m_ItemUnConfirmleBtn:SetActive(false)
		self.m_ItemMorePopupBox:SetActive(false)
	end
end

function CItemTipsBaseInfoView.HideFindWayGroup(self)
	self.m_FindWayGroup:SetActive(false)
end

function CItemTipsBaseInfoView.OnMoreClick(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local clickType = self.m_ItemMorePopupBox:GetSelectedIndex()
	if self.m_PopupList[clickType].String == "出售" then
		self:OnBtnClick("sell")	
	elseif self.m_PopupList[clickType].String == "获取" then
		self:OnBtnClick("get")	
	elseif self.m_PopupList[clickType].String == "使用" then		
		self:OnBtnClick("use")	
	elseif self.m_PopupList[clickType].String == "合成" then		
		self:OnBtnClick("composite")
		self:CloseView()			
	end
end

function CItemTipsBaseInfoView.RefreshBaeInfo(self)
	local oItem = self.m_ItemInfo
	local shape = oItem:GetValue("icon") or 0
	local quality = oItem:GetValue("itemlevel") or 0
	local name = oItem:GetValue("name") or ""
	local iType = oItem:GetValue("type")
	local usefor = oItem:GetValue("introduction") or "没什么卵用"
	local key = oItem:GetValue("key")
	local bing =  oItem:IsBingdingItem()
	local limit = oItem:IsLimitItem()
	local des = oItem:GetValue("description") or "这东西没什么卵用，随便写写"
	local count = oItem:GetValue("amount")	

	if iType == define.Item.ItemType.PartnerChip then
		self.m_ItemBgSpr:SetActive(false)
		self.m_PartnerBgSpr:SetActive(true)
		local rare = oItem:GetValue("rare")			
		self.m_PartnerShapSpr:SpriteAvatarBig(shape)			
		self.m_PartnerBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
		self.m_PartnerQualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))			
	else
		self.m_ItemBgSpr:SetActive(true)
		self.m_PartnerBgSpr:SetActive(false)
		self.m_ItemIconSprite:SpriteItemShape(shape)
	end

	
	self.m_ItemQualitySprite:SetItemQuality(quality)
	self.m_ItemNameLabel:SetQualityColorText(quality, name)

	self.m_ItemTypeLabel:SetText(string.format("类型: %s",define.Item.ItemTypeString[iType]))
	self.m_ItemUseforLabel:SetText(string.format("[作用]%s", usefor))
	self.m_ItemBingSprite:SetActive(bing)
	self.m_ItemDesLabel:SetText(des)
	self.m_ItemCountLabel:SetText(string.format("数量: %d", count))

	self.m_TitleQualitySpr:SetTitleQuality(quality, 1)
	self.m_SubTitleQualitySpr:SetTitleQuality(quality, 2)

	local price = 0
	if self.m_Type == CItemTipsBaseInfoView.enum.BaseInfo then
		price = oItem:GetValue("buy_price") or 0		
		-- if price ~= 0 then
		-- 	self.m_ItemPriceLabel:SetActive(true)
		-- 	self.m_ItemPriceLabel:SetText(string.format("价格 :%d", price))
		-- else
		-- 	self.m_ItemPriceLabel:SetActive(false)
		-- end
		--隐藏购买价格
		self.m_ItemPriceLabel:SetActive(false)

	--不显示出售价格		
	elseif self.m_Type == CItemTipsBaseInfoView.enum.SellInfo then
		-- price = oItem:GetValue("sale_price") or 0		
		-- if price ~= 0 then
		-- 	self.m_ItemPriceLabel:SetActive(true)
		-- 	self.m_ItemPriceLabel:SetText(string.format("价格 :%d", price))				
		-- else
		-- 	self.m_ItemPriceLabel:SetActive(false)	
		-- end
	end
	if limit then
		self.m_ItemTimeLimitLabel:SetActive(true)
		self.m_ItemTimeLimitLabel:SetText(oItem:GetLimitTime())
	else 
		self.m_ItemTimeLimitLabel:SetActive(false)
	end
end

function CItemTipsBaseInfoView.OnBtnClick(self, bKey)
	local sid = self.m_ItemInfo:GetValue("sid")
	local id = self.m_ItemInfo:GetValue("id")
	local targetId = g_AttrCtrl.pid
	local useType = self.m_ItemInfo:GetValue("use_type")
	local sale_price = self.m_ItemInfo:GetValue("sale_price")
	local count = self.m_ItemInfo:GetValue("amount")	
	local batUse = self.m_ItemInfo:GetValue("bat_use") or 0
	local useInwar = self.m_ItemInfo:GetValue("use_inwar") or 0
	if bKey == "use" then
		if useInwar == 1 and g_WarCtrl:IsWar() then
			g_NotifyCtrl:FloatMsg("战斗中无法进行该操作")
			return
		end
		if count == 0 then
			if self.m_ItemInfo:GetValue("composable") == 1 then
				CAwakeItemComposeView:ShowView(function(oView)
					oView:SetItem(self.m_ItemInfo.m_CDataGetter()["id"])
					self:CloseView()
				end)
			else
				self:UseWhenItemReduce()	
			end
		else
			local minGrade = self.m_ItemInfo:GetValue("min_grade") or 0
			if g_AttrCtrl.grade < minGrade then
				g_NotifyCtrl:FloatMsg(string.format("主角需达到%d级使用", minGrade))	
			else

				--当前状态下，是否可以使用某种道具
				if self:CheckOpenCondition(sid) then
					local gift_choose_amount = self.m_ItemInfo:GetValue("gift_choose_amount") or 0			
					--万能碎片道具
					if sid == 14002 then			
						CItemPartnerItemSelectView:ShowView(function (oView)
							oView:SetItemId(id)
						end)
						self:CloseView()

					elseif sid == 13281 then
						CItemPartnertSelectPackageView:ShowView(function (oView)
							oView:SetData(sid, false, id)
						end)
						
					elseif sid == 13270 or sid == 13271 or sid == 13269 then
						CItemPartnerEquipSoulSelectView:ShowView(function (oView)
							oView:SetItem(self.m_ItemInfo)
						end)

					--可选礼包
					elseif gift_choose_amount > 0 then
						if sid == 13276 then
							CItemFuWenGiftSelectView:ShowView(function (oView)
								oView:SetItem(sid, id)
							end)
						else
							CItemTipsPackageSelectView:ShowView(function (oView)
								oView:SetItem(sid, id)
							end)
						end
					elseif  self.m_ItemInfo:GetValue("amount") >= CItemTipsBaseInfoView.BatUseMinCount and useType == "bag" and batUse == 1 then
						g_WindowTipCtrl:SetWindowItemTipsBatUseItem(self.m_ItemInfo,
						{widget =  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
					else
						
						if useType == "bag" then
							g_ItemCtrl:C2GSItemUse(id, targetId, 1)				
						else
							--切换画面操作，返回true表示，会关闭打开 tips 的父页面
							if g_ItemCtrl:ItemUseSwitchTo(self.m_ItemInfo) == true then
								local oView = self.m_OwnerView
								if oView ~= nil then
									--如果是在背包页面切换画面，关闭背包页面
									if oView.classname == "CItemBagMainView" then
										oView:CloseView()
									end
								end
							end
							self:CloseView()
						end
					end
				end				
			end
		end

	elseif bKey	== "get" then
		--g_NotifyCtrl:FloatMsg("获取路径...")	

		local gainWay = self.m_ItemInfo:GetValue("gain_way_id") or {}
		if gainWay and next(gainWay) then
			self.m_FindWayGroup:SetActive(true)
			self.m_FindWayGrid:Clear()	
			local cnt = 0
			for i = 1, #gainWay do
				local d = data.itemdata.MODULE_SRC[gainWay[i]]
				if d then
					cnt = cnt + 1
					local oBox = self.m_FindWayCloneBox:Clone()
					oBox.m_NameLabel = oBox:NewUI(1, CLabel)

					local listName = {[1]=""}
					if d.name and d.name ~= "" then
						listName = string.split(d.name, "\n")
					end
					if listName[1] then
						oBox.m_NameLabel:SetText(listName[1])
					else
						oBox.m_NameLabel:SetText(d.name)
					end
					oBox:SetActive(true)
					local function cb()										
						if not g_ActivityCtrl:ActivityBlockContrl("item_resource") and not g_ActivityCtrl:ActivityBlockContrl("partner_resource") then
					   		return
					   	end						
						if d.blockkey ~= "" then
							if not g_ActivityCtrl:ActivityBlockContrl(d.blockkey) then
						   		return
						   	end
						end						
						if g_ItemCtrl:ItemFindWayToSwitch(d.id, self.m_ItemInfo) == true then
							local oView = self.m_OwnerView
							if oView ~= nil then
								--如果是在背包页面切换画面，关闭背包页面
								if oView.classname == "CItemBagMainView" then
									oView:CloseView()
								end
							end
							self:CloseView()
						end							
					end
					oBox:AddUIEvent("click", cb)
					self.m_FindWayGrid:AddChild(oBox)
				end						
			end
			self.m_FindWayGrid:Reposition()
			local w, h = self.m_FindWayGrid:GetCellSize()
			self.m_FindWayGroupBgSrp:SetHeight(91 + cnt * h)
		else
			self.m_FindWayGroup:SetActive(false)
		end

	elseif bKey == "sell" then
		if count == 0 then
			self:UseWhenItemReduce()
		else
			--价格大于0，才能出售
			if sale_price > 0 then
				--直接打开背包的统一出售
				local oView = CItemBagMainView:GetView()
				if oView and oView.m_SellInfoPart and oView.m_SellInfoPart.ShowSellInfoWidget then
					oView.m_SellInfoPart:ShowSellInfoWidget(self.m_ItemInfo:GetValue("id"))
					self:CloseView()
				end				
				--如果数目为1，直接卖出,否则弹出批量出售窗口
				-- if count == 1 then				
				-- 	g_ItemCtrl:C2GSRecycleItem(id, 1)
				-- else
				-- 	g_WindowTipCtrl:SetWindowItemTipsSellItem(self.m_ItemInfo,
				-- 		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
				-- end			
			else
				g_NotifyCtrl:FloatMsg("该道具不可出售")
			end			
		end
	elseif bKey	== "destory" then
		if sale_price ~= 0 then
			g_ItemCtrl:C2GSRecycleItem(id, count)
		else
			g_ItemCtrl:C2GSItemUse(id, targetId, count)
		end

	elseif bKey == "composite" then
		if self.m_ItemInfo:GetValue("composable") == 1 then
			CAwakeItemComposeView:ShowView(function(oView)
				oView:SetItem(self.m_ItemInfo.m_CDataGetter()["id"])
				self:CloseView()
			end)
		else
			local compose_amount = self.m_ItemInfo:GetValue("compose_amount") or 0
			local compose_item = self.m_ItemInfo:GetValue("compose_item") or {}
			local sid = self.m_ItemInfo:GetValue("sid")						
			if compose_amount ~= 0 and next(compose_item) then
				CItemTipsPropComposeView:ShowView(function (oView)
					oView:SetItem(sid)
				end)
			end
		end
	end
end

function CItemTipsBaseInfoView.OnCtrlItemlEvent(  self, oCtrl )
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		local id = self.m_ItemInfo:GetValue("id")
		local count = g_ItemCtrl:GetTargetItemCountById(id)
		if count == 0 then	   		
			--如果当前没有打开批量使用或者在出售时 并且是在售或者使用,才会关闭此画面
		 	if CItemTipsMoreView:GetView() == nil and 
		 		(g_ItemCtrl.m_CurSellItemId == id or g_ItemCtrl.m_CurUseItemId == id ) then
		 		g_ItemCtrl.m_CurSellItemId = 0
		 		g_ItemCtrl.m_CurUseItemId = 0
				self:CloseView()
		 	end
		 	self.m_ItemInfo:SetValue("amount", count)	   				   		
		 end		  
		 self.m_ItemCountLabel:SetText(string.format("数量:%d", count))

	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if oCtrl.m_EventData ~= nil then
			if oCtrl.m_EventData:GetValue("id") == self.m_ItemInfo:GetValue("id") then
				self.m_ItemInfo = oCtrl.m_EventData
	   			self.m_ItemCountLabel:SetText(string.format("数量:%d", self.m_ItemInfo:GetValue("amount")))
			end
		end	   
	end
end

function CItemTipsBaseInfoView.UseWhenItemReduce(self)
	--printtrace()
	if CItemBagMainView:GetView() then
		g_NotifyCtrl:FloatMsg(string.format("%s数量发生变化，请重新确定数量", self.m_ItemInfo:GetValue("name")))
	end
	self:CloseView()	
end

function CItemTipsBaseInfoView.CheckOpenCondition(self, sid)
	return g_ItemCtrl:CheckOpenCondition(sid)
end

function CItemTipsBaseInfoView.RefreshBg(self)
	local h1 = self.m_ItemUseforLabel:GetLocalPos().y - self.m_ItemUseforLabel:GetHeight()
	self.m_ItemDesLabel:SetLocalPos(Vector3.New(self.m_ItemDesLabel:GetLocalPos().x, h1, 0))

	local h2 = self.m_ItemUseforLabel:GetHeight()  + self.m_ItemDesLabel:GetHeight()  + 20
	h2 = h2 > 100 and h2 or 100

	self.m_BgSprite:SetHeight(h2 + 200)

	local h3 = self.m_BgSprite:GetLocalPos().y - self.m_BgSprite:GetHeight() + 55
	self.m_BottomGroup:SetLocalPos(Vector3.New(self.m_BottomGroup:GetLocalPos().x, h3, 0))
end

function CItemTipsBaseInfoView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CItemTipsBaseInfoView.OnMaskClose(self)
	self:CloseView()
end


function CItemTipsBaseInfoView.SetMaskWidget(self, b)
	self.m_MaskWidget:SetActive(b)
end

return CItemTipsBaseInfoView