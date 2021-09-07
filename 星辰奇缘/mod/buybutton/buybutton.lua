BuyButton = BuyButton or BaseClass(BasePanel)

-- parent   父容器
-- content  文字内容
-- noGold 在按钮上是否不显示钻石数量
function BuyButton:__init(parent, content, noGold)
    self.isInited = false
    self.frozen = nil
    self.parent = parent
    self.content = content
    self.key = nil
    self.originHeight = nil
    self.originWidth = nil
    self.originSize = 18
    self.gap = 10
    self.freezetime = 3
    self.active = true
    self.waitForPrice = false

    self.beforeContent = nil        -- 正式进入之前，需要有一个确认框
    self.beforeSureConent = nil
    self.beforeCancelContent = nil

    self.protoId = 0        --用来记录购买场景

    self.noGold = noGold
    if self.noGold == nil then
        self.noGold = true
    end

    self.resList = {
        {file = AssetConfig.buy_button, type = AssetType.Main}
    }

    self.btn_enabled = true
    self.clickListener = function() self:OnClickTrue() end      -- 改变按钮逻辑
    self.btn_enabled = true
    if self.isInited == true then
        self:Layout(self.baseidToNeed, self.onClick, self.callback)
    end

    self.originHeight = parent:GetComponent(RectTransform).sizeDelta.y
    self.originWidth = parent:GetComponent(RectTransform).sizeDelta.x

    self.askCallbackKey = nil
    self.askCallbackIndex = nil

    -- 指引添加额外点击监听
    self.guideClickListener = nil
end

function BuyButton:InitPanel()
    if self.customButton ~= nil then
        self.gameObject = self.customButton.gameObject
        self:SetActive(self.active)
    else
        self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buy_button))
        UIUtils.AddUIChild(self.parent, self.gameObject)
        self:SetActive(self.active)
    end
    self.transform = self.gameObject.transform
    if self.key ~= nil then
        self.gameObject.name = self.key
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
    end
    self.frozen = FrozenButton.New(self.gameObject, {timeout = self.freezetime})

    self.money = 0

    self.btnImg = self.transform:GetComponent(Image)
    self.centerText = self.transform:Find("CenterText"):GetComponent(Text)
    self.need = self.transform:Find("Need")
    self.numText = self.need:Find("Text/Image/Num"):GetComponent(Text)
    self.text = self.need:Find("Text"):GetComponent(Text)
    self.image = self.need:Find("Text/Image"):GetComponent(Image)

    self:Update()

    if self.isInited == true then
        self:Layout(self.baseidToNeed, self.onClick, self.callback)
        self:EnableBtn(self.btn_enabled)
        self:Update()
    end
    self:Set_btn_img(self.btnImgStr)
    self:SetTextColor(ColorHelper[self.btnImgStr] or Color(1, 1, 1))
end

function BuyButton:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BuyButton:__delete()
    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.notify ~= nil then
        self.notify:DeleteMe()
        self.notify = nil
    end
    if self.confirm ~= nil then
        self.confirm:DeleteMe()
        self.confirm = nil
    end
    if self.noticeData ~= nil then
        self.noticeData:DeleteMe()
        self.noticeData = nil
    end

    -- 清除回调
    if MarketManager.Instance.model.on12416_callback ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey] ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] ~= nil then
        MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] = nil
    end
    self.parent = nil
    if self.gameObject~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BuyButton:SetActive(active)
    self.active = active
    if self.gameObject~= nil then
        self.gameObject:SetActive(active)
    end
end

-- baseidToNeed = {[base_id] = {need = 所需数目}} （注意，base_id不应超过90000）
-- onClick 点击回调
-- callback 服务器返回价格之后回调，参数是{[base_id] = {
--                                              allprice = 总价（大于0代表本角色有足够货币购买，小于0代表本角色没有足够金币货币购买）,
--                                              assets = 货币类型
--                                          }}
-- setting = {
--      antofreeze = true,  自动执行冻结快捷按钮操作
-- }
function BuyButton:Layout(baseidToNeed, onClick, callback, setting)
    self.baseidToNeed = baseidToNeed

    if setting == nil then
        setting = {}
    end
    if setting.gap ~= nil then
        self.gap = setting.gap
    end
    if setting.fontSize ~= nil then
        self.originSize = setting.fontSize
    end
    self.antofreeze = setting.antofreeze or (setting.antofreeze == nil)
    self.customButton = setting.customButton
    if setting.freezetime ~= nil then
        self.freezetime = setting.freezetime
    end
    self.onClick = function()
        if self.frozen ~= nil and self.antofreeze == true then
            self.frozen:OnClick()
        end
        if onClick ~= nil then
            onClick()
        end
    end
    self.callback = callback
    self.isInited = true
    self.baseidToPrice = {}
    self.money = 0
    self.idToNumPrice = {}
    self.baseidToAllprice = {}
    self.base_ids = {}

    if self.gameObject == nil then
        return
    end

    self.button = self.gameObject:GetComponent(Button)
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnClick() end)

    if self.baseidToNeed == nil then
        self.money = nil
        self:Update()
        return
    end

    self:GetBaseidList()

    local base_ids = {}
    for _,v in pairs(self.base_ids) do
        local inShop = false
        if DataItem.data_get[v.base_id].buy_source[1] == 1 then
            for k,v1 in pairs(DataShop.data_hidens) do
                if k == v.base_id then
                    if v.base_id == 20038 and CampaignManager.Instance.campaignTab[73] ~= nil then -- 开服神兽9折。。。
                        self.baseidToPrice[k] = {price = v1.price * 0.9, assets = KvData.assets[v1.assets_type], source = MarketEumn.SourceType.Shop}
                    else
                        self.baseidToPrice[k] = {price = v1.price, assets = KvData.assets[v1.assets_type], source = MarketEumn.SourceType.Shop}
                    end
                    inShop = true
                    break
                end
            end
            if inShop ~= true then
                for k,v1 in pairs(ShopManager.Instance.itemPriceTab) do
                    if v1.discount == 0 and v1.base_id == v.base_id and v1.tab == 1 and v1.tab2 == 1 then
                        if v.base_id == 20038 and CampaignManager.Instance.campaignTab[73] ~= nil then
                            self.baseidToPrice[v.base_id] = {price = v1.price * 0.9, assets = KvData.assets[v1.assets_type], source = MarketEumn.SourceType.Shop}
                        else
                            self.baseidToPrice[v.base_id] = {price = v1.price, assets = KvData.assets[v1.assets_type], source = MarketEumn.SourceType.Shop}
                        end
                        inShop = true
                        break
                    end
                end
            end
            if inShop ~= true then
                table.insert(base_ids, v)
            end
        else
            table.insert(base_ids, v)
        end
    end

    local tempBaseIds = {}
    for _,v in ipairs(base_ids) do
        if v.base_id < 90000 then
            table.insert(tempBaseIds, v)
        end
    end

    if #tempBaseIds > 0 then
        -- 清除上次layout的回调
        if self.askCallbackKey ~= nil and self.askCallbackIndex ~= nil and MarketManager.Instance.model.on12416_callback ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey] ~= nil and MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] ~= nil then
            MarketManager.Instance.model.on12416_callback[self.askCallbackKey][self.askCallbackIndex] = nil
        end

        self.askCallbackKey,self.askCallbackIndex = MarketManager.Instance:send12416({["base_ids"] = tempBaseIds}, function(priceByBaseid)
            -- self.baseidToPrice = priceByBaseid
            for _,v in pairs(priceByBaseid) do
                self.baseidToPrice[v.base_id] = {}
                for key,value in pairs(v) do
                    self.baseidToPrice[v.base_id][key] = value --{price = v.price, assets = v.assets, source = MarketEumn.SourceType.Market}
                end
            end

            self:GetMoney()
            if self.callback ~= nil then
                self.callback(self.baseidToAllprice)
            end
            self:Update()

            if self.waitForPrice then
                self:ShowConfirm()
                self.waitForPrice = false
            end
        end)

        -- print(string.format("%s %s", tostring(self.askCallbackKey),tostring(self.askCallbackIndex)))
    else
        self:GetMoney()
        if self.callback ~= nil then
            self.callback(self.baseidToAllprice)
        end
        self:Update()
    end
    -- self.isInited = true
end

function BuyButton:OnClick()
    local func = function()
        if self.clickListener ~= nil then
            self.clickListener()
        else
            self:OnClickTrue()
        end

        if self.guideClickListener ~= nil then
            self.guideClickListener()
            self.guideClickListener = nil
        end
    end

    if self.beforeContent ~= nil then
        self.noticeData = self.noticeData or NoticeConfirmData.New()
        self.noticeData.content = self.beforeContent
        self.noticeData.sureLabel = self.beforeSureContent or TI18N("确 认")
        self.noticeData.cancelLabel = self.beforeCancelContent or TI18N("取 消")
        self.noticeData.sureCallback = func
        NoticeManager.Instance:ConfirmTips(self.noticeData)
    else
        func()
    end
end

function BuyButton:OnClickTrue()
    if self.money == nil then
        return
    end

    if self.noCost then
        self.onClick()
    else
        self:ShowConfirm()
    end
    -- elseif self.money > 0 then
    --     -- self:ShowNotice()
    --     self:ShowConfirm()
    -- else
    --     self.onClick()
    -- end
end

-- 显示最后购买确认框
function BuyButton:ShowNotice(checkNoGold)
    if checkNoGold ~= true and self.noGold ~= true then
        self.onClick()
        return
    end
    if self.notify == nil  then
        self.notify = BuyNotify.New(self.idToNumPrice, self.baseidToNeed, self.onClick, self.content)
    else
        self.notify.content = self.content
        if self.notify.loading ~= true then
            self.notify:ResetData(self.idToNumPrice, self.baseidToNeed)
        end
    end
    self.notify:Show()
end

--设置按钮是否生效
function BuyButton:EnableBtn(bool)
    self.btn_enabled = bool
    if self.gameObject ~= nil then
        self.gameObject:GetComponent(Button).enabled = bool
    end
end

function BuyButton:GetBaseidList()
    if self.baseidToNeed == nil then
        return
    end

    self.base_ids = {}
    self.baseidToBackpack = {}
    for k,v in pairs(self.baseidToNeed) do
        self.baseidToBackpack[k] = BackpackManager.Instance:GetItemCount(k)
        if self.baseidToBackpack[k] < v.need then
            table.insert(self.base_ids, {base_id = k})
        end
    end
end

function BuyButton:GetMoney()
    self.noCost = true
    local roledata = RoleManager.Instance.RoleData
    local coins = roledata:GetMyAssetById(KvData.assets.coin)
    local gold_bind = roledata:GetMyAssetById(KvData.assets.gold_bind)
    local gold = roledata:GetMyAssetById(KvData.assets.gold)
    local star_gold = roledata:GetMyAssetById(KvData.assets.star_gold)

    local world_lev = RoleManager.Instance.world_lev
    local glodbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
    local sliver_to_gold = DataMarketSilver.data_market_silver_ratio[world_lev].rate

    self.isNeedStarGold = false
    self.isNeedGold = false

    for k,v in pairs(self.baseidToNeed) do
        local buyinfo = self.baseidToPrice[k]
        if buyinfo ~= nil and v.need > self.baseidToBackpack[k] then
            self.noCost = false
            local result = buyinfo.price * (v.need - self.baseidToBackpack[k])
            if buyinfo.assets == KvData.assets.coin then
                self.isNeedStarGold = true
                if result > coins then  -- 银币不足
                    local num = v.need - self.baseidToBackpack[k]
                    self.baseidToAllprice[k] = {allprice = 0 - result, assets = buyinfo.assets}
                    self.idToNumPrice[k] = {num = num, money = math.ceil(num * buyinfo.price / sliver_to_gold), isDouble = true, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source, single_price = buyinfo.price}
                    coins = coins % buyinfo.price
                else
                    self.baseidToAllprice[k] = {allprice = result, assets = buyinfo.assets}
                    coins = coins - result
                end

            elseif buyinfo.assets == KvData.assets.gold_bind then
                self.isNeedStarGold = true
                if result > gold_bind then  -- 金币市场
                    local num = v.need - self.baseidToBackpack[k]
                    self.idToNumPrice[k] = {num = num, money = math.ceil(num * buyinfo.price / glodbind_to_gold), isDouble = true, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source, single_price = buyinfo.price}
                    self.baseidToAllprice[k] = {allprice = 0 - result, assets = buyinfo.assets}
                    gold_bind = gold_bind % buyinfo.price
                else
                    self.baseidToAllprice[k] = {allprice = result, assets = buyinfo.assets}
                    gold_bind = gold_bind - result
                end
            elseif buyinfo.assets == KvData.assets.star_gold then -- 星钻
                self.isNeedStarGold = true
                if result > star_gold then  -- 星钻不足
                    local num = v.need - self.baseidToBackpack[k]
                    self.idToNumPrice[k] = {num = num, money = num * buyinfo.price, isDouble = true, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source, single_price = buyinfo.price}
                    self.baseidToAllprice[k] = {allprice = 0 - result, assets = buyinfo.assets}
                    star_gold = star_gold % buyinfo.price
                else
                    self.baseidToAllprice[k] = {allprice = result, assets = buyinfo.assets}
                    star_gold = star_gold - result
                end
            elseif buyinfo.assets == KvData.assets.gold then    -- 蓝钻
                -- if result > gold then
                    local num = v.need - self.baseidToBackpack[k]
                    self.idToNumPrice[k] = {num = num, money = num * buyinfo.price, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source}
                    self.baseidToAllprice[k] = {allprice = 0 - result, assets = buyinfo.assets, single_price = buyinfo.price}
                    -- gold = gold % buyinfo.price
                    local c = math.floor(gold / buyinfo.price)
                    if num > c + 1 then
                        gold = gold % buyinfo.price
                    else
                        gold = gold - (num - 1) * buyinfo.price
                    end
                -- else
                --     local num = v.need
                --     self.idToNumPrice[k] = {num = num, money = num * buyinfo.price}
                --     self.baseidToAllprice[k] = {allprice = result, assets = buyinfo.assets}
                --     gold = gold - result
                -- end
            elseif buyinfo.assets == KvData.assets.star_gold_or_gold then    -- 双钻
                self.isNeedStarGold = true
                if result > star_gold then      -- 星钻不够，蓝钻补上
                    local num = v.need - self.baseidToBackpack[k]
                    if star_gold == 0 then
                        self.idToNumPrice[k] = {num = num, money = num * buyinfo.price, isDouble = true, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source, single_price = buyinfo.price}
                    else
                        self.idToNumPrice[k] = {num = num, money = num * buyinfo.price, isDouble = true, assets_num = num * buyinfo.price, assets = buyinfo.assets, source = buyinfo.source, single_price = buyinfo.price}
                    end
                    self.baseidToAllprice[k] = {allprice = 0 - result, assets = KvData.assets.star_gold_or_gold}
                    gold = gold - (result - star_gold)
                    star_gold = 0
                    local c = math.floor(gold / buyinfo.price)
                    if num > c + 1 then
                        gold = gold % buyinfo.price
                    else
                        gold = gold - (num - 1) * buyinfo.price
                    end
                else
                    -- 星钻足够就按星钻走，和上面309行一样
                    local num = v.need - self.baseidToBackpack[k]
                    self.idToNumPrice[k] = {num = num, money = num * buyinfo.price, assets = KvData.assets.star_gold, source = buyinfo.source, assets_num = num * buyinfo.price, isDouble = true, single_price = buyinfo.price}
                    self.baseidToAllprice[k] = {allprice = result, assets = buyinfo.assets, assets = KvData.assets.star_gold, isDouble = true}
                    star_gold = star_gold - result
                end
            end
        end
    end

    local star_gold = roledata:GetMyAssetById(KvData.assets.star_gold)
    for _,v in pairs(self.idToNumPrice) do
        -- if v.assets == KvData.assets.gold then
        --     self.isNeedGold = true
        -- else
        --     if star_gold == 0 then
        --         self.isNeedGold = true
        --     elseif star_gold < v.money then
        --         self.isNeedGold = true
        --         self.isNeedStarGold = true
        --         star_gold = 0
        --     else
        --         self.isNeedStarGold = true
        --         star_gold = star_gold - v.money
        --     end
        -- end
        self.money = self.money + v.money
    end
end

function BuyButton:ResetDatasource(idToPriceAsset)
    self.idToNumPrice = {}

    local world_lev = RoleManager.Instance.world_lev
    local glodbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
    local sliver_to_gold = DataMarketSilver.data_market_silver_ratio[world_lev].rate

    if idToPriceAsset ~= nil then
        for k,v in pairs(self.idToPriceAsset) do
            local tbl = {}
            if v.asset == KvData.assets.coin then
                tbl.money = math.ceil(v.num / sliver_to_gold)
            elseif v.asset == KvData.assets.gold_bind then
                tbl.money = math.ceil(v.num / glodbind_to_gold)
            elseif v.asset == KvData.assets.gold then
                tbl.money = math.ceil(v.num)
            end
            self.money = self.money + tbl.money
            tbl.num = v.lack
            self.idToNumPrice[k] = tbl
        end
    end
end

function BuyButton:Update()
    if BaseUtils.isnull(self.gameObject) then
        Log.Error("[BuyButton]没有正确释放，key: "..self.key)
        return
    end

    local t = self.transform
    if self.money ~= nil and self.money > 0 and self.btn_enabled == true and self.noGold == false then
        self.centerText.gameObject:SetActive(false)
        self.need.gameObject:SetActive(true)
        self.text.text = self.content
        if self.btnImgStr ~= nil then
            self.text.color = ColorHelper.ButtonColorDic[self.btnImgStr]
        end
        self.numText.text = tostring(self.money)

        if self.isNeedStarGold == true then
            if self.iconloader == nil then
                self.iconloader = SingleIconLoader.New(self.image.gameObject)
            end
            self.iconloader:SetSprite(SingleIconType.Item, 29255)
        else
            self.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
        end

    else
        self.centerText.gameObject:SetActive(true)
        self.centerText.text = self.content
        if self.btnImgStr ~= nil then
            self.centerText.color = ColorHelper.ButtonColorDic[self.btnImgStr]
        end
        self.need.gameObject:SetActive(false)
    end

    if self.noGold == false then
        self:Resize()
    end
end

--设置按钮文字，外部直接调用
function BuyButton:Set_btn_txt(str)
    self.content = str
    if self.centerText ~= nil then
        self.centerText.text = str
        self.text.text = str
    end
end

function BuyButton:Set_btn_img(str)
    self.btnImgStr = str
    if self.btnImg ~= nil and str ~= nil then
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, str)
        self:SetTextColor(ColorHelper[str] or Color(1, 1, 1))
    end
end

function BuyButton:SetTextColor(color)
    if self.centerText ~= nil then
        self.centerText.color = color
    end
    if self.numText ~= nil then
        self.numText.color = color
    end
end

function BuyButton:Resize()
    local rect = self.parent:GetComponent(RectTransform)
    local width = rect.sizeDelta.x  -- 按钮宽度
    local height = rect.sizeDelta.y -- 按钮高度

    local textRect = self.text:GetComponent(RectTransform)
    local textPreferredWidth = self.text.preferredWidth  -- 文字宽度
    local textHeight = self.text.preferredHeight -- 文字控件高度
    if textHeight > 21 then
        textHeight = 21
    end
    textRect.sizeDelta = Vector2(textPreferredWidth + self.gap, textHeight)
    local textWidth = textRect.sizeDelta.x  -- 文字控件宽度

    local imageRect = self.transform:Find("Need/Text/Image"):GetComponent(RectTransform)
    local imageWidth = imageRect.sizeDelta.x    -- 钻石宽度
    local imageHeight = imageRect.sizeDelta.y   -- 钻石高度

    local numRect = self.numText:GetComponent(RectTransform)
    local numPreferredWidth = self.numText.preferredWidth    -- 数字宽度
    local numHeight = numRect.sizeDelta.y   -- 数字控件高度
    numRect.sizeDelta = Vector2(numPreferredWidth + self.gap, numHeight)
    local numWidth = numRect.sizeDelta.x    -- 数字控件宽度

    if textWidth + imageWidth + numWidth > width then
        textRect.anchoredPosition = Vector2(0, textHeight / 2)
        imageRect.anchoredPosition = Vector2((textWidth + numWidth + imageWidth) / 2, 0 - (textHeight + imageHeight) / 2 + 5)
    else
        local widthSum = imageWidth + numWidth
        textRect.anchoredPosition = Vector2(widthSum / 2, 0)
        imageRect.anchoredPosition = Vector2(0, 0)
    end
end

-- 手动释放按钮
function BuyButton:ReleaseFrozon()
    if self.frozen ~= nil and self.frozen.enabled ~= true then
        self.frozen:Release()
    end
end

-- 手动冻结按钮
function BuyButton:Freeze()
    if self.frozen ~= nil and self.frozen.enabled then
        self.frozen:OnClick()
    end
end

-- 快捷购买新确认框
function BuyButton:ShowConfirm()
    if next(self.baseidToPrice) == nil then
        self.waitForPrice = true
        return
    end
    local baseidToNeed = {}
    local num = 0
    for base_id,v in pairs(self.baseidToNeed) do
        if base_id < 90000 and (self.baseidToPrice[base_id] ~= nil and (self.baseidToPrice[base_id].assets ~= KvData.assets.gold or self.baseidToPrice[base_id].assets ~= KvData.assets.star_gold or self.baseidToPrice[base_id].assets ~= KvData.assets.star_gold_or_gold)) then
            local has = BackpackManager.Instance:GetItemCount(base_id)
            if has < v.need then
                baseidToNeed[base_id] = {need = v.need - has}
            end

            if BuyManager.Instance.autoBuyList[self.key] == nil or BuyManager.Instance.autoBuyList[self.key][base_id] ~= true then
                num = num + 1
            end
        end
    end

    if num == 0 then
        self:onClick()
        return
    end

    if BuyManager.Instance.buyConfirm == nil then
        BuyManager.Instance.buyConfirm = BuyConfirm.New()
    end

    BuyManager.Instance.buyConfirm:Show({baseidToPrice = self.baseidToPrice, baseidToNeed = baseidToNeed, clickCallback = self.onClick, content = self.content, key = self.key, protoId = self.protoId})
    -- BuyManager.Instance:ShowQuickBuy(baseidToNeed)
end

