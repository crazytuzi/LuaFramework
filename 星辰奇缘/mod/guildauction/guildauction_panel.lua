--作者:hzf
--03/17/2017 11:07:01
--功能:公会拍卖出价

GuildAuctionPanel = GuildAuctionPanel or BaseClass(BasePanel)
function GuildAuctionPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.guildauctionpanel, type = AssetType.Main},
		{file = AssetConfig.guildauctiontexture, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.assetListener = function()
		self:OnAssetsUpdate()
	end
	self.goodsListener = function(data)
		if data.id == self.data.id then
			self.openArgs = data
			self:InitData()
		end
	end
end

function GuildAuctionPanel:__delete()
	if self.slot ~= nil then
        self.slot:DeleteMe()
    end
    self.slot = nil
	EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
	GuildAuctionManager.Instance.OnOneGoodsUpdate:Remove(self.goodsListener)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildAuctionPanel:OnHide()

end

function GuildAuctionPanel:OnOpen()

end

function GuildAuctionPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildauctionpanel))
	self.gameObject.name = "GuildAuctionPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
	self.transform:SetAsFirstSibling()
	self.Panel = self.transform:Find("Panel")
	self.Panel:GetComponent(Button).onClick:AddListener(function()
		self.model:ClosePanel()
	end)
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)

	self.ImgIcon = self.transform:Find("Main/Top/ImgIcon")
	self.ImgIcon:GetComponent(Image).color = Color(1, 1, 1, 0)
	self.slot = ItemSlot.New()
    self.info = ItemData.New()

    -- self.slot:SetAll(info, extra)
    self.slot:Default()
    UIUtils.AddUIChild(self.ImgIcon.gameObject,self.slot.gameObject)

	self.ItemNameText = self.transform:Find("Main/Top/ItemNameText"):GetComponent(Text)
	self.ItemTypeText = self.transform:Find("Main/Top/ItemTypeText"):GetComponent(Text)
	-- self.I18NcurrText = self.transform:Find("Main/Top/I18NcurrText"):GetComponent(Text)
	self.TextCurr = self.transform:Find("Main/Top/TextCurr"):GetComponent(Text)

	self.ReloadButton = self.transform:Find("Main/Top/ReloadButton"):GetComponent(Button)
	self.ReloadButton.onClick:AddListener(function()
		self:OnReload()
	end)


	self.defaultBtnList = {}
	for i=1, 3 do
		self.defaultBtnList[i] = {}
		local btntrans = self.transform:Find(string.format("Main/Offer/X%sButton", i))
		self.defaultBtnList[i].Button = btntrans:GetComponent(Button)
		self.defaultBtnList[i].Button.onClick:AddListener(function()
			self:OnQuick(i)
		end)
		self.defaultBtnList[i].NormalText = btntrans:Find("Normal/Text"):GetComponent(Text)
		self.defaultBtnList[i].Select = btntrans:Find("Select").gameObject
		self.defaultBtnList[i].SelectText = btntrans:Find("Select/Text"):GetComponent(Text)
	end
	-- self.I18N_CustomText = self.transform:Find("Main/Offer/I18N_CustomText"):GetComponent(Text)
	self.MaxText = self.transform:Find("Main/Offer/MaxText"):GetComponent(Text)
	self.TextEXT = MsgItemExt.New(self.MaxText, 200, 16, 19)
	self.TextEXT:SetData(TI18N("使用该价格<color='#ffff00'>直接购买</color>"))
	self.CountBtn = self.transform:Find("Main/Offer/CountBg"):GetComponent(Button)
	self.CountBtn.onClick:AddListener(function()
		self:OpenNumPad()
	end)
	self.CountText = self.transform:Find("Main/Offer/CountBg/Count"):GetComponent(Text)
	self.AddBtn = self.transform:Find("Main/Offer/AddBtn"):GetComponent(Button)
	self.AddBtn.onClick:AddListener(function()
		self:OnAdd()
	end)
	self.MinusBtn = self.transform:Find("Main/Offer/MinusBtn"):GetComponent(Button)
	self.MinusBtn.onClick:AddListener(function()
		self:OnDecre()
	end)
	self.OnceButton = self.transform:Find("Main/Offer/OnceButton"):GetComponent(Button)
	self.OnceSelect = self.transform:Find("Main/Offer/OnceButton/Select").gameObject
	self.OnceButton.onClick:AddListener(function()
		self:OnOnce()
	end)
	self.HasText = self.transform:Find("Main/Offer/MoneyBg/Text"):GetComponent(Text)
	self.hideButton = self.transform:Find("Main/hideButton"):GetComponent(Button)
    self.hideButton.onClick:AddListener(function()
        local has = RoleManager.Instance.RoleData.brother
        TipsManager.Instance:ShowText({
            gameObject = self.hideButton.gameObject,
            itemData = {
                string.format(TI18N("当前拥有兄弟币:<color='#ffff00'>%s</color>{assets_2,90036}"), has),
                TI18N("1、可通过<color='#00ff00'>公会攻城战、英雄副本</color>获得"),
                TI18N("2、拍卖中兄弟币不足，可使用{assets_2,90002}代替"),
                TI18N("3、若竞拍不成功将<color='#ffff00'>原额返还</color>兄弟币和钻石"),
            }
        }
        )
    end)

	self.OKButton = self.transform:Find("Main/Offer/OKButton"):GetComponent(Button)
	self.OKButton.onClick:AddListener(function()
		self:OnOK()
	end)
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		self.model:ClosePanel()
	end)
	EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
	GuildAuctionManager.Instance.OnOneGoodsUpdate:Add(self.goodsListener)
	self:InitData()
end

function GuildAuctionPanel:InitData()
	self.data = self.openArgs
	if self.data == nil then
		self.model:ClosePanel()
		return
	elseif self.data.status == 1 then
		self.model:ClosePanel()
		return
	end
	local base = DataItem.data_get[self.data.item_id]
	self.cfgdata = DataGuildAuction.data_list[self.data.item_id]
    self.info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    self.slot:SetAll(self.info, extra)
    self.ItemNameText.text = ColorHelper.color_item_name(base.quality , base.name)
    self.ItemTypeText.text = BackpackEumn.ItemTypeName[base.type]
    self.TextCurr.text = tostring(self.data.current_price)
    self.TextCurr.text = self.data.current_price
    if self.data.current_price == 0 then
        self.TextCurr.text = self.cfgdata.min_price
        self.data.current_price = self.cfgdata.min_price
    end
	self.defaultBtnList[1].NormalText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate1))
	self.defaultBtnList[1].SelectText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate1))
    self:SetNum(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate1))
	self.defaultBtnList[2].NormalText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate2))
	self.defaultBtnList[2].SelectText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate2))
	self.defaultBtnList[3].NormalText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate3))
	self.defaultBtnList[3].SelectText.text = tostring(math.min(self.data.max_price, self.data.current_price + self.cfgdata.ascending_base * self.cfgdata.recommand_rate3))
    self:OnAssetsUpdate()
end

function GuildAuctionPanel:OnReload()
	-- body
end

function GuildAuctionPanel:OnQuick(index)
	for i=1, 3 do
		if index == i then
			self.defaultBtnList[i].Select:SetActive(true)
			self:SetNum(tonumber(self.defaultBtnList[i].SelectText.text))

		else
			self.defaultBtnList[i].Select:SetActive(false)

		end
	end
end

function GuildAuctionPanel:OnOK()
	local num = tonumber(self.CountText.text)
	if num < self.data.current_price + self.cfgdata.ascending_base then
		NoticeManager.Instance:FloatTipsByString(TI18N("不能低于当前价格"))
		self:SetNum(self.data.current_price + self.cfgdata.ascending_base)
		return
	end
	if num > RoleManager.Instance.RoleData.brother then
		if num < self.data.current_price then
			self:SetNum(self.data.current_price +1)
		elseif num > self.data.max_price then
			self:SetNum(self.data.max_price)
		else
			local data = NoticeConfirmData.New()
		    data.type = ConfirmData.Style.Normal
		    local needmore = num - RoleManager.Instance.RoleData.brother
		    -- data.content = string.format(TI18N("兄弟币不足,是否消耗<color='#ffff00'>%s</color>{assets_2,90002}完成支付?\n(1{assets_2,90036}=2{assets_2,90002})"), (num - RoleManager.Instance.RoleData.brother)*2)
		    data.content = string.format(TI18N("当前还缺少<color='#ffff00'>%s</color>{assets_2,90036},是否消耗<color='#ffff00'>%s</color>{assets_2,90002}完成支付？"), needmore, (num - RoleManager.Instance.RoleData.brother)*2)
		    data.sureLabel = TI18N("确定")
		    data.cancelLabel = TI18N("取消")
		    data.sureCallback = function()
				GuildAuctionManager:send19703(self.data.id, num)
	        end
		    NoticeManager.Instance:ConfirmTips(data)
		end
	else
		if num < self.data.current_price then
			self:SetNum(self.data.current_price +1)
		elseif num > self.data.max_price then
			self:SetNum(self.data.max_price)
		else
			local data = NoticeConfirmData.New()
		    data.type = ConfirmData.Style.Normal
		    data.content = string.format(TI18N("是否以<color='#ffff00'>%s</color>{assets_2,90036}的价格竞拍该道具？"), num)
		    data.sureLabel = TI18N("确定")
		    data.cancelLabel = TI18N("取消")
		    data.sureCallback = function()
				GuildAuctionManager:send19703(self.data.id, num)
	        end
		    NoticeManager.Instance:ConfirmTips(data)
			-- GuildAuctionManager:send19703(self.data.id, num)
		end
	end
end

function GuildAuctionPanel:OnAdd()
	local num = tonumber(self.CountText.text)
	local nextnum = num + self.cfgdata.ascending_base
	if nextnum <= self.data.max_price then
		self:SetNum(nextnum)
	else
		self:SetNum(self.data.max_price)
	end
end

function GuildAuctionPanel:OnDecre()
	local num = tonumber(self.CountText.text)
	local nextnum = num - self.cfgdata.ascending_base
	if nextnum < self.data.current_price + self.cfgdata.ascending_base then
		if num -1 < self.data.current_price + self.cfgdata.ascending_base then
			NoticeManager.Instance:FloatTipsByString(TI18N("不能低于当前价格"))
			return
		else
			self:SetNum(num -1)
		end
	end
	if nextnum >= self.data.current_price + self.cfgdata.ascending_base then
		self:SetNum(nextnum)
	else
		self:SetNum(self.data.current_price + self.cfgdata.ascending_base)
	end
end

function GuildAuctionPanel:SetNum(num)
	local colorstr = ColorHelper.DefaultButton1
	if num > RoleManager.Instance.RoleData.brother then
		colorstr = ColorHelper.colorObject[6]
		local str = string.format(TI18N("可使用{assets_1,90002,%s}完成支付"), tostring((num - RoleManager.Instance.RoleData.brother)*2))
		self.TextEXT:SetData(str)
	else
		self.TextEXT:SetData(TI18N("使用该价格<color='#ffff00'>直接购买</color>"))
	end
	self.CountText.color = colorstr
	self.CountText.text = tostring(num)
	self.MaxText.gameObject:SetActive(num >= self.data.max_price or num > RoleManager.Instance.RoleData.brother)
	self.OnceSelect:SetActive(num >= self.data.max_price)
	for i=1, 3 do
		if self.defaultBtnList[i].SelectText.text == self.CountText.text then
			self.defaultBtnList[i].Select:SetActive(true)
		else
			self.defaultBtnList[i].Select:SetActive(false)
		end
	end
end

function GuildAuctionPanel:OpenNumPad()
	local info = {
		parent_obj = self.gameObject,
		gameObject = self.CountBtn.gameObject,
		max_result = self.data.max_price,
		min_result = 1,
		max_by_asset = self.data.max_price,
		textObject = self.CountText,
		show_num = false,
		funcReturn = function() self:OnOK() end,
		callback = function(num) self:SetNum(num) end
	}
    NumberpadManager.Instance:set_data(info)
    NumberpadManager.Instance:OpenWindow()
end


function GuildAuctionPanel:OnAssetsUpdate()
	self.HasText.text = tostring(RoleManager.Instance.RoleData.brother)
end


function GuildAuctionPanel:OnOnce()
	self:SetNum(self.data.max_price)
end