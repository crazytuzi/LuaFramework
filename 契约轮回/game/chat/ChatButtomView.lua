--
-- @Author: chk
-- @Date:   2018-09-04 19:40:29
--
ChatButtomView = ChatButtomView or class("ChatButtomView",BaseItem)
local ChatButtomView = ChatButtomView

function ChatButtomView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatButtomView"
	self.layer = "Bottom"

	self.bagViews = {}
	self.bagBtns = {}
	self.commonLGItems = {}
	self.emoji_pages = {}
	self.emoji_buttons = {}
	self.now_page = 1
	self.total_page = 1
	self.pre_x = 0
	self.model = ChatModel.GetInstance()
	ChatButtomView.super.Load(self)
end

function ChatButtomView:dctor()
	self.model.last_buttom_view = nil


	for i, v in pairs(self.events or {}) do
		GlobalEvent:RemoveListener(v)
	end

	for i, v in pairs(self.bagViews) do
		v:destroy()
	end

	for i, v in pairs(self.emoji_pages) do
		v:destroy()
	end

	for i, v in pairs(self.emoji_buttons) do
		v:destroy()
	end

	for i, v in pairs(self.commonLGItems) do
		v:destroy()
	end
	self.commonLGItems = {}

	if self.model.last_bag_view ~= nil then
		self.model.last_bag_view = nil
	end

	self.events = nil
	self.settors = nil
	self.bagViews = nil
	self.bagBtns = inl
	self.commonLGItems = nil
	self.emoji_pages = nil
	self.emoji_buttons = nil

	self.last_btn_select = nil
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if self.StencilMask2 then
        destroy(self.StencilMask2)
        self.StencilMask2 = nil
    end
end

function ChatButtomView:LoadCallBack()
	self.nodes = {
		"mask",
		"btnContain/emojiBtn",
		"btnContain/emojiBtn/Background/emojiSelect",
		"btnContain/bagBtn",
		"btnContain/bagBtn/Background/bagSelect",
		"btnContain/commonLGBtn",
		"btnContain/commonLGBtn/Background/commonLGSelect",
		"bagView",
		"bagView/bagBtnContain",
		"bagView/bagViewContain",
		"emojiView",
		"emojiView/EmojiScrollView",
		"emojiView/EmojiScrollView/Viewport1",
		"emojiView/EmojiScrollView/Viewport1/emojiContent",
		"commonLGView",
		"commonLGView/Scroll View/Viewport2",
		"commonLGView/Scroll View/Viewport2/commonLGContent",
		"emojiView/page_buttons",
		"emojiView/EmojiScrollView/ScrollbarHorizontal",
	}

	self:GetChildren(self.nodes)
	self.ScrollbarHorizontal = self.ScrollbarHorizontal:GetComponent("Scrollbar")
	self.emojiContentRectTra = GetRectTransform(self.emojiContent.gameObject)
	--self.emojiScrollRect = self.EmojiScrollView:GetComponent('ScrollRect')
	self:AddEvent()
--[[	self.model.inlineManagerScpButtom = self.transform:GetComponent("InlineManager")
	self.model.inlineManagerScpButtom:LoadEmoji("asset/chatemoji_asset","e",0,54)
	
	self.model.CMLGInlineManager = self.CMLGInlineManager
	self.model.inlineMgrComLGScp = self.CMLGInlineManager.transform:GetComponent('InlineManager')
	self.model.inlineMgrComLGScp:LoadEmoji("asset/chatemoji_asset","e",0,30)--]]
	self:SetMask()
	self:ClickEmojiBtn()
end

function ChatButtomView:LoadEmoji()
	if self.emojiContent.transform.childCount <= 1 then
		--local emojiNums = self.model.inlineManagerScpButtom:GetEmojiNums(0)
		local emojiNums = table.nums(Config.db_emoji)
		local pages = math.ceil(emojiNums / self.model.emojisOnePage)
		self.total_page = pages
		for i = 1, pages do
			local data = {}
			data.graphicIdx = 0
			data.page = i
			data.emojiNums = emojiNums
			local emojiPageItem = ChatEmojiPageItemSettor(self.emojiContent)
			emojiPageItem:SetData(data)
			self.emoji_pages[i] = emojiPageItem
			local buttonItem = ChatPageScrollItem(self.page_buttons)
			self.emoji_buttons[i] = buttonItem
			buttonItem:SetData(i, pages, 0)
		end

		self.emojiContentRectTra.sizeDelta = Vector2(664, self.emojiContentRectTra.sizeDelta.y * pages+30)
	end
end

function ChatButtomView:OnEnable()

end

function ChatButtomView:AddEvent()

	local function call_back()
		GlobalEvent:Brocast(ChatEvent.OpenEmojiView,false)
	end
	AddClickEvent(self.mask.gameObject,call_back)


	AddClickEvent(self.emojiBtn.gameObject,handler(self,self.ClickEmojiBtn))

	local function call_back(  )
		if self.last_btn_select == self.bagSelect then
			return
		end
		if table.nums(self.bagBtns) <= 0 then
			self:CreateChatBagBtn()
		end

		SetVisible(self.bagSelect.gameObject,true)
		if self.last_btn_select ~= nil then
			SetVisible(self.last_btn_select.gameObject,false)
		end

		self.last_btn_select = self.bagSelect

		if self.model.last_buttom_view ~= nil then
			SetVisible(self.model.last_buttom_view.gameObject,false)
		end

		SetVisible(self.bagView.gameObject,true)
		self.model.last_buttom_view = self.bagView
	end

	AddClickEvent(self.bagBtn.gameObject,call_back)

	local function call_back(  )
		if self.last_btn_select == self.commonLGSelect then
			return
		end
		SetVisible(self.commonLGSelect.gameObject,true)

		if self.last_btn_select ~= nil then
			SetVisible(self.last_btn_select.gameObject,false)
		end

		self.last_btn_select = self.commonLGSelect

		if self.model.last_buttom_view ~= nil then
			SetVisible(self.model.last_buttom_view.gameObject,false)
		end

		SetVisible(self.commonLGView.gameObject,true)
		self.model.last_buttom_view = self.commonLGView


		if table.nums(self.commonLGItems) <= 0 then
			--local idx = 0
			local commonLGTbl = string.split(HelpConfig.Chat.CommonLG,'\n')
			for i=1, #commonLGTbl-1 do
			--for i, v in pairs(commonLGTbl) do
				--idx = idx + 1
				local commonItem = ChatCommonLGItemSettor(self.commonLGContent)
				commonItem:SetData({info = commonLGTbl[i], index = i})
				table.insert(self.commonLGItems,commonItem)
			end
		end

		--self.CMLGInlineManager.transform:SetAsLastSibling()
	end

	AddClickEvent(self.commonLGBtn.gameObject,call_back)

	local function call_back(value)
		self.model:Brocast(ChatEvent.EmojiScrollChange, value)
	end
	self.ScrollbarHorizontal.onValueChanged:AddListener(call_back)

	local function call_back()
		local now_x = self.ScrollbarHorizontal.value
		local to_right = true
		if now_x - self.pre_x > 0 then
			self.now_page = self.now_page + 1
		elseif now_x - self.pre_x < 0 then
			self.now_page = self.now_page - 1
			to_right = false
		else
			return
		end
		self.now_page = (self.now_page <= 1 and 1 or self.now_page)
		self.now_page = (self.now_page >= self.total_page and self.total_page or self.now_page)

		local to_value = (self.now_page-1)/(self.total_page-1)
		self.ScrollbarHorizontal.value = to_value
		self.pre_x = to_value
	end
	AddDragEndEvent(self.EmojiScrollView.gameObject, call_back)
end

function ChatButtomView:ClickEmojiBtn()
	if self.last_btn_select == self.emojiSelect then
		return
	end
	SetVisible(self.emojiSelect.gameObject,true)

	if self.last_btn_select ~= nil then
		SetVisible(self.last_btn_select.gameObject,false)
	end

	self.last_btn_select = self.emojiSelect

	if self.emojiContent.transform.childCount < 2 then
		self:LoadEmoji()
	end

	SetVisible(self.emojiView.gameObject,true)

	if self.model.last_buttom_view ~= nil then
		SetVisible(self.model.last_buttom_view.gameObject,false)
	end

	self.model.last_buttom_view = self.emojiView
end

function ChatButtomView:CreateChatBagBtn(  )
	--背包
	self.model.default_bag_name = ConfigLanguage.Bag.Bag
	local bagData = {}
	bagData.name = ConfigLanguage.Bag.Bag
	bagData.btnCB = handler(self,self.ShowBagItems)
	bagData.idx = 1
	self.bagBtns[bagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[bagData.name]:SetData(bagData)

	--仓库
	local wareHouseData = {}
	wareHouseData.name = ConfigLanguage.Bag.Warehouse
	wareHouseData.btnCB = handler(self,self.ShowWarehouseItems)
	wareHouseData.idx = 2
	self.bagBtns[bagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[bagData.name]:SetData(wareHouseData)


	--装备
	local equipData = {}
	equipData.name = ConfigLanguage.Equip.Equip
	equipData.btnCB = handler(self,self.ShowEquipBagItems)
	equipData.idx = 3
	self.bagBtns[bagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[bagData.name]:SetData(equipData)


	--神兽
	local beastBagData = {}
	beastBagData.name = ConfigLanguage.Beast.BEAST_PANEL
	beastBagData.btnCB = handler(self,self.ShowBeastBagItems)
	beastBagData.idx = 4
	self.bagBtns[beastBagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[beastBagData.name]:SetData(beastBagData)

	--宠物
	local petBagData = {}
	petBagData.name = ConfigLanguage.Pet.PET_PANEL
	petBagData.btnCB = handler(self,self.ShowPetBagItems)
	petBagData.idx = 5
	self.bagBtns[petBagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[petBagData.name]:SetData(petBagData)

	--图鉴
	local illuBagData = {}
	illuBagData.name = "Atlas"
	illuBagData.btnCB = handler(self,self.ShowIlluBagItems)
	illuBagData.idx = 6
	self.bagBtns[illuBagData.name] = ChatBagBtn(self.bagBtnContain)
	self.bagBtns[illuBagData.name]:SetData(illuBagData)
end


--显示背包的物品
function ChatButtomView:ShowBagItems( ... )
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end

	if self.bagViews[ConfigLanguage.Bag.Bag] == nil then
		self.bagViews[ConfigLanguage.Bag.Bag] = ChatBagView(self.bagViewContain)
	end
	SetVisible(self.bagViews[ConfigLanguage.Bag.Bag].gameObject,true)


	self.model.last_bag_view = self.bagViews[ConfigLanguage.Bag.Bag]
end


--显示仓库的物品
function ChatButtomView:ShowWarehouseItems( ... )
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end

	if self.bagViews[ConfigLanguage.Bag.Warehouse] == nil then
		self.bagViews[ConfigLanguage.Bag.Warehouse] = ChatWareHouseView(self.bagViewContain)
	end
	SetVisible(self.bagViews[ConfigLanguage.Bag.Warehouse].gameObject,true)



	self.model.last_bag_view = self.bagViews[ConfigLanguage.Bag.Warehouse]

end

--显示装备的物品
function ChatButtomView:ShowEquipBagItems( ... )
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end


	if self.bagViews[ConfigLanguage.Equip.Equip] == nil then
		self.bagViews[ConfigLanguage.Equip.Equip] = ChatEquipBagView(self.bagViewContain)
	end
	SetVisible(self.bagViews[ConfigLanguage.Equip.Equip].gameObject,true)


	self.model.last_bag_view = self.bagViews[ConfigLanguage.Equip.Equip]

end

--显示神兽的物品
function ChatButtomView:ShowBeastBagItems( )
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end

	if self.bagViews[ConfigLanguage.Beast.BEAST_PANEL] == nil then
		self.bagViews[ConfigLanguage.Beast.BEAST_PANEL] = ChatBeastBagView(self.bagViewContain)
	end
	SetVisible(self.bagViews[ConfigLanguage.Beast.BEAST_PANEL].gameObject,true)


	self.model.last_bag_view = self.bagViews[ConfigLanguage.Beast.BEAST_PANEL]
end

--显示宠物的物品
function ChatButtomView:ShowPetBagItems()
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end

	if self.bagViews[ConfigLanguage.Pet.PET_PANEL] == nil then
		self.bagViews[ConfigLanguage.Pet.PET_PANEL] = ChatPetBagView(self.bagViewContain)
	end
	SetVisible(self.bagViews[ConfigLanguage.Pet.PET_PANEL].gameObject,true)


	self.model.last_bag_view = self.bagViews[ConfigLanguage.Pet.PET_PANEL]
end

--显示图鉴的物品
function ChatButtomView:ShowIlluBagItems()
	if self.model.last_bag_view ~= nil then
		SetVisible(self.model.last_bag_view.gameObject,false)
	end

	if self.bagViews["Atlas"] == nil then
		self.bagViews["Atlas"] = ChatIlluBagView(self.bagViewContain)
	end
	SetVisible(self.bagViews["Atlas"].gameObject,true)


	self.model.last_bag_view = self.bagViews["Atlas"]
end


function ChatButtomView:SetMask()
	self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport1.gameObject)
    self.StencilMask2 = AddRectMask3D(self.Viewport2.gameObject)
    self.StencilMask.id = self.StencilId
    self.StencilMask2.id = self.StencilId
end
