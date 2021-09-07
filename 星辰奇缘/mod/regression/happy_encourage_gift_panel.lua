-- ----------------------------------------------------------
-- UI - 老玩家回归窗口 欢乐助长礼面板
-- ----------------------------------------------------------
HappyEncourageGiftPanel = HappyEncourageGiftPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function HappyEncourageGiftPanel:__init(parent, parentContainer)
	self.parent = parent
    self.model = parent.model
    self.parentContainer = parentContainer
    self.name = "HappyEncourageGiftPanel"
    self.resList = {
        {file = AssetConfig.regression_panel4, type = AssetType.Main}
        , {file = AssetConfig.bigatlas_regression, type = AssetType.Main}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
        , {file = AssetConfig.regression_textures, type = AssetType.Dep}
        , {file = AssetConfig.big_buff_icon, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.item_list = {}
	self.itemSlot_list = {}
    self.itemImage_list = {}
    self.itemText_list = {}

    self.fateItemList = {}
    self.fateTextList = {}

    self.tipsPanel = nil
    self.tipsImage = nil
    self.tipsName = nil
    self.tipsDesc = nil
    self.tipsNameDesc = nil

    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HappyEncourageGiftPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regression_panel4))
    self.gameObject.name = "HappyEncourageGiftPanel"
    self.gameObject.transform:SetParent(self.parentContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform
    UIUtils.AddBigbg(transform:Find("Regression"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_regression)))

    transform:Find("BigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    -- 按钮功能绑定
    local btn
    -- self.okBtuuton = transform:FindChild("BindText"):GetComponent(Button)
    -- self.okBtuuton.onClick:AddListener(function() self:OnOkButton() end)
    -- self.textExt = MsgItemExt.New(transform:FindChild("Mask/Text"):GetComponent(Text), 520, 16, 30)
    -- self.textExt:SetData(campaign_data.cond_desc)

    self.descText = transform:FindChild("DescText"):GetComponent(Text)

    self.container = self.gameObject.transform:FindChild("Mask/Container")
	self.item = self.container:FindChild("Item").gameObject
	self.item:SetActive(false)

    for i=1, 3 do 
        local item = self.gameObject.transform:FindChild("Item"..i).gameObject
        table.insert(self.fateItemList, item)
        
        local text = item.transform:FindChild("Text"):GetComponent(Text)
        table.insert(self.fateTextList, text)
    end

    self.tipsPanel = self.gameObject.transform:FindChild("ImgTips").gameObject
    self.tipsPanel:SetActive(false)
    self.tipsPanel:GetComponent(Button).onClick:AddListener(function() self:OnTipsClick() end)

    self.tipsImage =  self.tipsPanel.transform:FindChild("Con/ImgBuff")
    self.tipsName =  self.tipsPanel.transform:FindChild("Con/TxtName"):GetComponent(Text)
    self.tipsDesc =  self.tipsPanel.transform:FindChild("Con/TxtDesc"):GetComponent(Text)
    self.tipsNameDesc =  self.tipsPanel.transform:FindChild("Con/TxtNameDesc"):GetComponent(Text)

    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function HappyEncourageGiftPanel:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HappyEncourageGiftPanel:OnShow()
    self:update()
end

function HappyEncourageGiftPanel:OnHide()
end

function HappyEncourageGiftPanel:update()
    local descString = TI18N("玩家回归一段时间内每日均可获得以下特权：\n1.<color='#af3eeb'>回归登陆</color>即可领取<color='#af3eeb'>储备经验</color>，助你升级永不掉队！")
    
    for i=1, 3 do
        local buff = self.model.buffs[i]
        if buff == nil then
            self.fateItemList[i]:SetActive(false)
            local item = self.item_list[i]
            if item ~= nil then
                item:SetActive(false)
            end
        else
            local recalled_growth_buff = DataFriend.data_get_recalled_growth_buff[buff.buff_id]
            if recalled_growth_buff ~= nil then
                self.fateItemList[i]:SetActive(true)
                self.fateTextList[i].text = recalled_growth_buff.event

                local item = self.item_list[i]
                local image = self.itemImage_list[i]
                local text = self.itemText_list[i]
                if item == nil then
                    item = GameObject.Instantiate(self.item)
                    item:SetActive(true)
                    UIUtils.AddUIChild(self.container, item)
                    table.insert(self.item_list, item)

                    image = item.transform:FindChild("Image")
                    table.insert(self.itemImage_list, image)

                    text = item.transform:FindChild("Text"):GetComponent(Text)
                    table.insert(self.itemText_list, text)

                    local index = i
                    item:GetComponent(Button).onClick:AddListener(function() self:OnFateClick(index) end)
                end

                item:SetActive(true)
                image:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.big_buff_icon, recalled_growth_buff.icon)
                text.text = recalled_growth_buff.name

                descString = string.format("%s\n%s.%s", descString, i+1, recalled_growth_buff.desc)
            end
        end
    end

    self.descText.text = descString
end

function HappyEncourageGiftPanel:OnOkButton()
    
end

function HappyEncourageGiftPanel:OnFateClick(index)
    local buff = self.model.buffs[index]
    if buff ~= nil then
        local recalled_growth_buff = DataFriend.data_get_recalled_growth_buff[buff.buff_id]
        if recalled_growth_buff ~= nil then
            self.tipsPanel:SetActive(true)
            self.tipsImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.big_buff_icon, recalled_growth_buff.icon)
            self.tipsName.text = recalled_growth_buff.name
            self.tipsDesc.text = recalled_growth_buff.depict
            self.tipsNameDesc.text = ""
        end
    end
end

function HappyEncourageGiftPanel:OnTipsClick()
    self.tipsPanel:SetActive(false)
end
