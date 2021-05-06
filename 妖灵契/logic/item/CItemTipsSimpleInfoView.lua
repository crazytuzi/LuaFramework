---------------------------------------------------------------
--物品简单信息展示窗口


---------------------------------------------------------------
local CItemTipsSimpleInfoView = class("ItemTipsSimpleInfoView", CViewBase)


function CItemTipsSimpleInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsSimpleInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
end

function CItemTipsSimpleInfoView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_QualitySprite = self:NewUI(3, CSprite)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_BingSprite = self:NewUI(5, CSprite)
	self.m_TitleLabel = self:NewUI(7, CLabel)
	self.m_DesLabel = self:NewUI(8, CLabel)
	self.m_ItemBG = self:NewUI(9, CSprite)
	self.m_DebrisBox = self:NewUI(10, CBox)
	self.m_BlackTipBox = self:NewUI(11, CBox)
	self.m_BgSprite = self:NewUI(12, CSprite)
	self.m_FindWayGroup = self:NewUI(13, CBox)
	self.m_FindWayGrid = self:NewUI(14, CGrid)
	self.m_FindWayCloneBox = self:NewUI(15, CBox)
	self.m_FindWayBgSpr = self:NewUI(16, CSprite)
	self.m_TitleQualitySpr = self:NewUI(17, CSprite)
	self.m_SubTitleQualitySpr = self:NewUI(18, CSprite)
	self.m_BuyBtn = self:NewUI(19, CButton)
	self.m_QuickBuyPart = self:NewUI(20, CBox)
	self.m_QuickBuyGrid = self:NewUI(21, CGrid)
	self.m_QuickBuyBox = self:NewUI(22, CItemTipsQuickBuyBox)
	self.m_FindWayTitleLabel = self:NewUI(23, CLabel)

	self.m_Sid = nil
	self.m_QuickBuyBox:SetActive(false)
	self.m_BuyBtn:SetActive(false)
	self.m_BingSprite:SetActive(false)
	self.m_FindWayCloneBox:SetActive(false)
	self:InitBlackTipBox()

	self.m_BgSprite.m_OHight = self.m_BgSprite:GetHeight()

	self.m_OwnerView = nil
	self.m_ItemInfo = nil	
	self.m_IgnoreCloseOwnerView = false
	self.m_ExtendClose = true
end

function CItemTipsSimpleInfoView.InitQuickBuyPart(self, sid, config)
	self.m_FindWayTitleLabel:SetText("获取途径")
	if not config.showQuickBuy then
		-- printc("not showQuickBuy")
		self.m_QuickBuyPart:SetActive(false)
		self.m_QuickBuyGrid:Clear()
		return
	end
	-- printc("showQuickBuy")
	
	self.m_BuyBoxArr = self.m_BuyBoxArr or {}
	local oData = DataTools.GetItemData(sid)
	local count = 1
	if oData.buy_cost and #oData.buy_cost > 0 then
		self.m_FindWayTitleLabel:SetText("玩法获取")
		for i,v in ipairs(oData.buy_cost) do
			if self.m_BuyBoxArr[i] == nil then
				self.m_BuyBoxArr[i] = self.m_QuickBuyBox:Clone()
				self.m_QuickBuyGrid:AddChild(self.m_BuyBoxArr[i])
			end
			if self.m_BuyBoxArr[i] and not Utils.IsNil(self.m_BuyBoxArr[i]) then
				self.m_BuyBoxArr[i]:SetActive(true)
				self.m_BuyBoxArr[i]:SetData(oData, i)
			end			
			count = count + 1
		end
		self.m_QuickBuyPart:SetActive(true)
	else
		self.m_QuickBuyPart:SetActive(false)
	end

	for i=count, #self.m_BuyBoxArr do
		if self.m_BuyBoxArr[i] and not Utils.IsNil(self.m_BuyBoxArr[i]) then
			self.m_BuyBoxArr[i]:SetActive(false)
		end
	end
end

function CItemTipsSimpleInfoView.OnBuyBtn(self)
	--通用购买物品
end

function CItemTipsSimpleInfoView.InitBlackTipBox(self)
	local box = self.m_BlackTipBox
	box.m_BG = box:NewUI(1, CSprite)
	box.m_ItemSpr = box:NewUI(2, CSprite)
	box.m_NameLabel = box:NewUI(3, CLabel)
	box.m_DesLabel = box:NewUI(4, CLabel)
end

function CItemTipsSimpleInfoView.Clear(self)
	self.m_TitleLabel:SetText("")
	self.m_DesLabel:SetText("")
	self.m_ItemBG:SetActive(false)
	self.m_Container:SetActive(true)
	self.m_BlackTipBox:SetActive(false)
	self.m_DebrisBox:SetActive(false)
end

function CItemTipsSimpleInfoView.SetInitBox(self, sid, parId, config)
	local tItem	= CItem.NewBySid(sid) 
	if not tItem then
		return		
	end
	self.m_ItemInfo = tItem
	self:RefreshBaeInfo(sid, parId, config)
end

function CItemTipsSimpleInfoView.RefreshBaeInfo(self, sid, parId, config)
	local oItem	= CItem.NewBySid(sid) 
	if not oItem or self.m_Sid == sid then
		return		
	end
	self:Clear()
	self.m_Sid = sid
	config = config or {}
	if data.itemdata.VIRTUAL[sid] and not config.buy and not config.buyfun then
		self:ShowBlackBox(sid, parId)
		self:ShowFindWayBox(false)
	else
		self.m_BgSprite:SetActive(true)
		self.m_BlackTipBox:SetActive(false)
		self:ShowFindWayBox(true)
	end

	local shape = oItem:GetValue("icon") or 0
	local quality = nil
	if config and config.quality then
		quality = config.quality
	else
		quality = oItem:GetValue("quality") or 0
	end
	local name = oItem:GetValue("name") or ""
	local iType = oItem:GetValue("type")
	local usefor = oItem:GetValue("introduction")
	local key = oItem:GetValue("key")
	local bing =  oItem:IsBingdingItem()
	local limit = oItem:IsLimitItem()
	local des = oItem:GetValue("description")
	local count = oItem:GetValue("amount")	

	self.m_NameLabel:SetQualityColorText(quality, name)
	if oItem:GetValue("partner_type") then
		self.m_DebrisBox:SetActive(true)
		local oBox=self.m_DebrisBox
		oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
		oBox.m_BorderSpr = oBox:NewUI(2, CSprite)
		oBox.m_ChipSpr = oBox:NewUI(3, CSprite)
		oBox.m_AvatarSpr:SpriteAvatar(oItem:GetValue("icon"))
		g_PartnerCtrl:ChangeRareBorder(oBox.m_BorderSpr, oItem:GetValue("rare"))
		local filename = define.Partner.CardColor[oItem:GetValue("rare")] or "hui"
		oBox.m_ChipSpr:SetSpriteName("pic_suipian_"..filename.."se")
	else
		--非伙伴碎片道具
		self.m_ItemBG:SetActive(true)
		self.m_IconSprite:SpriteItemShape(shape)
		self.m_QualitySprite:SetItemQuality(quality)
	end

	self.m_TitleQualitySpr:SetTitleQuality(quality, 1)
	self.m_SubTitleQualitySpr:SetTitleQuality(quality, 2)


	local text = ""
	local desStr = ""
	if iType ~= nil then
		text = text .. "类型:"..define.Item.ItemTypeString[iType]
	end
	if usefor ~= nil then
		if oItem:GetValue("weapon_type") then
			local usefors = string.split(usefor, " ")
			text = text .. "\n" .. usefors[2]
			text = text .. "\n" .. usefors[1]
		else
			self.m_DesLabel:SetText("作用:"..usefor) 
		end
	end
	self.m_TitleLabel:SetText(text)

	if des ~= nil then
		local curDes = self.m_DesLabel:GetText()
		self.m_DesLabel:SetText(curDes.."\n"..des)
	end

	self:InitQuickBuyPart(sid, config)

	if config.buy then
		self.m_BuyBtn:SetActive(true)
		self.m_QuickBuyPart:SetActive(false)
		self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuyBtn"))
	end

	if config.buyfun then
		--不走通用购买
		self.m_BuyBtn:SetActive(true)
		self.m_QuickBuyPart:SetActive(false)
		self.m_BuyBtn:AddUIEvent("click", config.buyfun)
	end

	self.m_IgnoreCloseOwnerView = config.ignoreCloseOwnerView or false

	self:AdjustBgSprite()
end

function CItemTipsSimpleInfoView.ShowBlackBox(self, sid, parId)
	self.m_BgSprite:SetActive(false)
	local box = self.m_BlackTipBox
	box:SetActive(true)
	local info = self.m_ItemInfo

	box.m_NameLabel:SetText(info:GetValue("name"))
	box.m_ItemSpr:SpriteItemShape(info:GetValue("icon"))
	local desc = string.format("◆%s\n◆%s\n", info:GetValue("introduction"), info:GetValue("description"))
	box.m_DesLabel:SetText(desc)
	local h = box.m_DesLabel:GetHeight()
	box.m_BG:SetHeight(h + 60)
end

function CItemTipsSimpleInfoView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

function CItemTipsSimpleInfoView.ShowFindWayBox(self, b)
	local gainWay = self.m_ItemInfo:GetValue("gain_way_id") or {}
	local viewList = {"CForgeMainView", "CPartnerHireView", "CPartnerImproveView"}

	local CheckFindWayView = function (oView)
		local b = false
		if oView and next(viewList) then
			for k, v in pairs(viewList) do
				if oView.classname == v then
					b = true
					break
				end
			end
		end
		return b
	end
	if b == true and self.m_OwnerView and gainWay and next(gainWay) and CheckFindWayView(self.m_OwnerView) then
		self.m_FindWayGroup:SetActive(true)
		self.m_FindWayGrid:Clear()	
		for i = 1, #gainWay do
			local d = data.itemdata.MODULE_SRC[gainWay[i]]
			if d then
				local oBox = self.m_FindWayCloneBox:Clone()
				oBox.m_NameLabel = oBox:NewUI(1, CLabel)
				oBox.m_DiscountMark = oBox:NewUI(2, CSprite)
				oBox.m_DiscountMark:SetActive(string.find(d.config, "shop_4_1") ~= nil)
				oBox.m_NameLabel:SetText(d.name)
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
						if oView ~= nil and (self.m_IgnoreCloseOwnerView ~= true or d.switch_type ~= 1) then
							oView:CloseView()
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
		self.m_FindWayBgSpr:SetHeight(91 + #gainWay * h)
	else
		self.m_FindWayGroup:SetActive(false)
	end
end

function CItemTipsSimpleInfoView.ForceShowFindWayBox(self)
	local gainWay = self.m_ItemInfo:GetValue("gain_way_id") or {}
	if gainWay and next(gainWay) then
		self.m_FindWayGroup:SetActive(true)
		self.m_FindWayGrid:Clear()	
		for i = 1, #gainWay do
			local d = data.itemdata.MODULE_SRC[gainWay[i]]
			if d then
				local oBox = self.m_FindWayCloneBox:Clone()
				oBox.m_NameLabel = oBox:NewUI(1, CLabel)
				oBox.m_DiscountMark = oBox:NewUI(2, CSprite)
				oBox.m_DiscountMark:SetActive(string.find(d.config, "shop_4_1") ~= nil)
				oBox.m_NameLabel:SetText(d.name)
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
						if oView ~= nil and (self.m_IgnoreCloseOwnerView ~= true or d.switch_type ~= 1) then
							oView:CloseView()
						end
						self:CloseView()
					end							
					if string.find(d.config, "shop") then
						
					end
				end
				oBox:AddUIEvent("click", cb)
				self.m_FindWayGrid:AddChild(oBox)
			end						
		end
		self.m_FindWayGrid:Reposition()
		local w, h = self.m_FindWayGrid:GetCellSize()
		self.m_FindWayBgSpr:SetHeight(91 + #gainWay * h)
	else
		self.m_FindWayGroup:SetActive(false)
	end
end

function CItemTipsSimpleInfoView.SetOwnerView(self, owner)
	self.m_OwnerView = owner
end

function CItemTipsSimpleInfoView.AdjustBgSprite(self)
	local h1 = self.m_DesLabel:GetHeight() + 10
	if self.m_BuyBtn:GetActive() then
		h1 = h1 + self.m_BuyBtn:GetHeight() + 10
	end
	if self.m_QuickBuyPart:GetActive() then
		local w, h = self.m_QuickBuyGrid:GetCellSize()
		h1 = h1 + self.m_QuickBuyGrid:GetCount() * h - 10
	end
	self.m_BgSprite:SetHeight(self.m_BgSprite.m_OHight + h1)
	self.m_FindWayGroup:SetLocalPos(Vector3.New(self.m_FindWayGroup:GetLocalPos().x, - self.m_BgSprite:GetHeight()-20, 0))
end

return CItemTipsSimpleInfoView