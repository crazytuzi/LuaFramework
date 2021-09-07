-- @author 黄耀聪
-- @date 2016年6月21日

RechargeGiftItem = RechargeGiftItem or BaseClass()

function RechargeGiftItem:__init(model, gameObject, assetWrapper, callback)
    print("sfjsdkfjksd")
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.callback = callback

    local t = self.transform
    self.diamondImage = t:Find("Diamonds"):GetComponent(Image)
    self.moneyText = t:Find("Money"):GetComponent(Text)
    self.moneyIcon = t:Find("Money/Icon"):GetComponent(Image)
    self.assetText = t:Find("AssetBg/Asset"):GetComponent(Text)
    self.tokes = t:Find("Tokes")
    self.tipsLabelObj = t:Find("TipsLabel").gameObject
    self.btn = gameObject:GetComponent(Button)
    self.assetWrapper = assetWrapper

    self.tipsSecondLabelTr = t:Find("TipsSecondLabel")
    self.tipsSecondLabelText = t:Find("TipsSecondLabel/Text"):GetComponent(Text)
    self.tipsSecondLabelText.text = "哇哈哈哈"
    self.tipsSecondLabelTr.gameObject:SetActive(false)

    self.tokes.gameObject:SetActive(false)
    self.tipsLabelObj:SetActive(false)

    self.buyData = nil

    self.btn.onClick:AddListener(function() self.callback(self.buyData) end)
end

function RechargeGiftItem:__delete()
    self.diamondImage.sprite = nil
end

function RechargeGiftItem:update_my_self(data, index)
    -- self.diamondImage.gameObject:SetActive(false)
    self.data = data
    self.diamondImage.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, self.model.itemidToRes[data.item_list[1][1]])
    -- BaseUtils.dump(data)
    -- print(DataItem.data_get[data.item_list[1][1]].icon)
    self.diamondImage:SetNativeSize()
    self.moneyText.text = tostring(data.money)
    self.assetText.text = tostring(data.gold)

    -- self.buyData = {tag = "StardustRomance3K" .. data.gold, rmb = data.money, gold = data.gold}
    self.buyData = {tag = ShopManager.Instance.model:GetSpecialChargeData(tonumber(data.gold)), rmb = data.money, gold = data.gold}
end

function RechargeGiftItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function RechargeGiftItem:SetSecondLabel(t,num)
    if t == true then
        self.tipsSecondLabelTr.gameObject:SetActive(true)
        self.tipsSecondLabelText.text = string.format(TI18N("获得宝藏<color='#ffff00'>%s份</color>"),num)
    else
        self.tipsSecondLabelTr.gameObject:SetActive(false)
    end
end

