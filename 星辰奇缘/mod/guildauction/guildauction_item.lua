GuildAuctionItem = GuildAuctionItem or BaseClass()

function GuildAuctionItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.ImgIcon = self.transform:Find("ImgIcon"):GetComponent(Image)
    self.ItemNameText = self.transform:Find("ItemNameText"):GetComponent(Text)
    local acp = self.transform:Find("ItemNameText").anchoredPosition
    self.transform:Find("ItemNameText").anchoredPosition3D = Vector3(acp.x, 0, 0)
    self.transform:Find("ItemTypeText").gameObject:SetActive(false)
    -- self.ItemTypeText = self.transform:Find("ItemTypeText"):GetComponent(Text)
    self.PriceCon = self.transform:Find("PriceCon").gameObject
    self.PriceCon:SetActive(true)
    self.PriceTextCurr = self.transform:Find("PriceCon/TextCurr"):GetComponent(Text)
    self.AddButton = self.transform:Find("PriceCon/AddButton"):GetComponent(Button)
    self.AddButtonImg = self.transform:Find("PriceCon/AddButton"):GetComponent(Image)
    self.AddButton.onClick:AddListener(function()
        self:OnAdd()
    end)
    self.myprice = self.transform:Find("myprice").gameObject
    -- self.TextOnce = self.transform:Find("PriceCon/TextOnce"):GetComponent(Text)
    -- self.OnceButton = self.transform:Find("PriceCon/OnceButton"):GetComponent(Button)
    -- self.OnceButton.onClick:AddListener(function()
    --     self:OnOnce()
    -- end)
    self.StatusImage = self.transform:Find("StatusImage"):GetComponent(Image)
    self.LikeButton = self.transform:Find("LikeButton"):GetComponent(Button)
    self.LikeButton.onClick:AddListener(function()
        self:OnLike()
    end)
    self.LikeButtonicon = self.transform:Find("LikeButton/icon").gameObject
    self.StatusText = self.transform:Find("StatusText"):GetComponent(Text)
    self.clock = self.transform:Find("StatusText/clock").gameObject
    self.EndButton = self.transform:Find("EndButton"):GetComponent(Button)
    self.EndButton.onClick:AddListener(function()
        self:OnEnd()
    end)

    self.slot = ItemSlot.New()
    self.info = ItemData.New()

    -- self.slot:SetAll(info, extra)
    self.slot:Default()
    UIUtils.AddUIChild(self.ImgIcon.gameObject,self.slot.gameObject)
    self.slot:ShowBg(false)
    self.transform:Find("ImgIcon").sizeDelta = Vector2(80, 80)
end

--设置


function GuildAuctionItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildAuctionItem:set_my_index(_index)

end

--更新内容
function GuildAuctionItem:update_my_self(data, _index)
    self.data = data
    self.endtime = GuildAuctionManager.Instance:GetEndTime(self.data.start_time, self.data.last_bidden, self.data.timeout)
    local base = DataItem.data_get[data.item_id]
    local cfgdata = DataGuildAuction.data_list[data.item_id]
    local talismandata = DataTalisman.data_get[data.item_id]
    self.info:SetBase(base)
    local extra = {inbag = false, nobutton = true, noselect = true, noqualitybg = true}
    self.slot:SetAll(self.info, extra)
    self.slot:ShowBg(false)
    self.clock:SetActive(true)
    self.slot.transform:Find("QualityBg").gameObject:SetActive(false)

    self.ImgIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level"..tostring(talismandata.quality))
    self.ItemNameText.text = ColorHelper.color_item_name(talismandata.quality , TalismanEumn.FormatQualifyName(talismandata.quality, talismandata.name))
    if base.quality == 2 then
        self.ItemNameText.text = string.format("<color='#225ee7'>%s</color>", TalismanEumn.FormatQualifyName(talismandata.quality, talismandata.name))
    end
    -- self.ItemTypeText.text = BackpackEumn.ItemTypeName[base.type]
    self.PriceTextCurr.text = data.current_price
    if data.current_price == 0 then
        self.PriceTextCurr.text = cfgdata.min_price
        data.current_price = cfgdata.min_price
    end
    if cfgdata.min_price ~= data.current_price then
        self.PriceTextCurr.color = Color(36/255, 144/255, 21/255)
    else
        self.PriceTextCurr.color = Color(12/255, 82/255, 176/255)
    end
    -- self.TextOnce.text = data.max_price
    self.StatusText.gameObject:SetActive(true)
    if data.status ~= 1 then
        self.LikeButton.gameObject:SetActive(true)
    else
        self.LikeButton.gameObject:SetActive(false)
    end
    self.myprice:SetActive(self.data.bidders[1] ~= nil and self.data.bidders[1].name == RoleManager.Instance.RoleData.name)
    -- self.LikeButton.gameObject:SetActive(data.transaction_type == 0)
    self.LikeButtonicon:SetActive(GuildAuctionManager.Instance.likeList[data.id] ~= nil)
    -- if self.parent.index == 2 then
    --     if self.timer ~= nil then
    --         LuaTimer.Delete(self.timer)
    --         self.timer = nil
    --     end
    --     self.LikeButton.gameObject:SetActive(false)
    --     if data.status == 1 then
    --         self.StatusText.text = data.bidders[1].name
    --         self.EndButton.gameObject:SetActive(true)
    --     elseif data.status == 2 then
    --         self.StatusText.text = TI18N("已转换为\n公会资金")
    --         self.StatusImage.sprite = self.parent.nobuysprite
    --     else
    --         self.StatusText.text = TI18N("已经结束")
    --         self.EndButton.gameObject:SetActive(false)
    --     end
    -- end
    -- if data.status ~= 0 or self.parent.index == 2 then
    --     if self.timer ~= nil then
    --         LuaTimer.Delete(self.timer)
    --         self.timer = nil
    --     end
    --     if data.current_price == data.max_price then
    --         self.StatusImage.sprite = self.parent.oncesprite
    --         self.StatusText.text = data.bidders[1].name
    --         self.PriceTextCurr.text = data.max_price
    --     else
    --         if data.status == 1 then
    --             self.StatusText.text = data.bidders[1].name
    --             self.PriceTextCurr.text = data.current_price
    --             self.StatusImage.sprite = self.parent.buysprite
    --         elseif data.status == 2 then
    --             self.StatusText.text = TI18N("已转换为\n公会资金")
    --             self.StatusImage.sprite = self.parent.nobuysprite
    --         end
    --     end
    --     self.LikeButton.gameObject:SetActive(false)
    --     self.AddButton.gameObject:SetActive(false)
    --     self.StatusImage:SetNativeSize()
    --     self.StatusImage.gameObject:SetActive(true)
    --     self.EndButton.gameObject:SetActive(true)
    --     self.clock:SetActive(false)
    -- else
    --      -- 拍卖开始
    --     if self.data.start_time > BaseUtils.BASE_TIME then
    --         self.AddButtonImg.color = Color(0.8, 0.8, 0.8)
    --         if self.timer == nil then
    --             self.timer = LuaTimer.Add(0, 1000, function()
    --                 self:OnTick()
    --             end)
    --         end
    --         self.LikeButton.gameObject:SetActive(true)
    --         self.AddButton.gameObject:SetActive(true)
    --         self.StatusImage.gameObject:SetActive(false)
    --         self.EndButton.gameObject:SetActive(false)
    --         self.clock:SetActive(true)
    --         -- 显示未开始倒计时
    --     elseif self.data.last_bidden ~= 0 or tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 0 then
    --         self.AddButtonImg.color = Color.white
    --         if self.timer == nil then
    --             self.timer = LuaTimer.Add(0, 1000, function()
    --                 self:OnTick()
    --             end)
    --         end
    --         --显示当天10点结算倒计时
    --     else
    --         self.AddButtonImg.color = Color.white
    --         self.clock:SetActive(false)
    --         self.StatusText.text = TI18N("竞拍中")
    --         --显示周日10点结算倒计时
    --         if self.timer ~= nil then
    --             LuaTimer.Delete(self.timer)
    --             self.timer = nil
    --         end
    --     end
    -- end
    if self.parent.index == 2 then
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        self.EndButton.gameObject:SetActive(false)
        if data.status == 1 then
            if data.current_price == data.max_price then
                self.StatusImage.sprite = self.parent.oncesprite
                self.PriceTextCurr.text = data.max_price
            else
                self.StatusImage.sprite = self.parent.buysprite
                self.PriceTextCurr.text = data.current_price
            end
            self.StatusText.text = data.bidders[1].name
            self.EndButton.gameObject:SetActive(true)
        elseif data.status == 2 then
            self.StatusText.text = TI18N("已转换为\n公会资金")
            self.StatusImage.sprite = self.parent.nobuysprite
        else
            self.StatusText.text = TI18N("已经结束")
            self.EndButton.gameObject:SetActive(false)
        end
        self.LikeButton.gameObject:SetActive(false)
        self.AddButton.gameObject:SetActive(false)
        self.StatusImage.gameObject:SetActive(true)
        self.clock:SetActive(false)
    else
        if self.data.start_time > BaseUtils.BASE_TIME then
            self.AddButtonImg.color = Color(0.8, 0.8, 0.8)
            if self.timer == nil then
                self.timer = LuaTimer.Add(0, 1000, function()
                    self:OnTick()
                end)
            end
            self.LikeButton.gameObject:SetActive(true)
            self.AddButton.gameObject:SetActive(true)
            self.StatusImage.gameObject:SetActive(false)
            self.EndButton.gameObject:SetActive(false)
            self.clock:SetActive(true)
            -- 显示未开始倒计时
        elseif data.status == 0 and self.data.last_bidden ~= 0 or tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 0 and (data.timeout == 0 or data.timeout > BaseUtils.BASE_TIME) then
            self.AddButtonImg.color = Color.white
            if self.timer == nil then
                self.timer = LuaTimer.Add(0, 1000, function()
                    self:OnTick()
                end)
            end
            self.LikeButton.gameObject:SetActive(true)
            self.AddButton.gameObject:SetActive(true)
            self.StatusImage.gameObject:SetActive(false)
            self.EndButton.gameObject:SetActive(false)
            self.clock:SetActive(true)
            --显示当天10点结算倒计时
        elseif data.status == 1 or (data.timeout ~= 0 and data.timeout > BaseUtils.BASE_TIME) then
            if data.current_price == data.max_price then
                self.StatusImage.sprite = self.parent.oncesprite
                self.PriceTextCurr.text = data.max_price
            else
                self.StatusImage.sprite = self.parent.buysprite
                self.PriceTextCurr.text = data.current_price
            end
            self.StatusText.text = data.bidders[1].name
            self.EndButton.gameObject:SetActive(true)
            self.LikeButton.gameObject:SetActive(false)
            self.AddButton.gameObject:SetActive(false)
            self.StatusImage.gameObject:SetActive(true)
            self.clock:SetActive(false)
        elseif data.status == 2 then
            self.StatusText.text = TI18N("已转换为\n公会资金")
            self.StatusImage.sprite = self.parent.nobuysprite
            self.EndButton.gameObject:SetActive(true)
            self.LikeButton.gameObject:SetActive(false)
            self.AddButton.gameObject:SetActive(false)
            self.StatusImage.gameObject:SetActive(true)
            self.clock:SetActive(false)
        else
            self.AddButtonImg.color = Color.white
            self.clock:SetActive(false)
            self.StatusText.text = TI18N("竞拍中")
            --显示周日10点结算倒计时
            if self.timer ~= nil then
                LuaTimer.Delete(self.timer)
                self.timer = nil
            end
            self.LikeButton.gameObject:SetActive(true)
            self.AddButton.gameObject:SetActive(true)
            self.StatusImage.gameObject:SetActive(false)
            self.EndButton.gameObject:SetActive(false)
        end
    end


end

function GuildAuctionItem:Refresh(args)

end

function GuildAuctionItem:__delete()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.info ~= nil then
        self.info:DeleteMe()
        self.info = nil
    end
end

function GuildAuctionItem:OnEnd()
    if self.data ~= nil then
        -- if self.data.rolename ~= "" then
            if self.data.status == 1 then
                TipsManager.Instance:ShowText({gameObject = self.LikeButton.gameObject, itemData = {string.format(TI18N("恭喜<color='#00ff00'>%s</color>竞拍成功！\n竞拍金额<color='#ffff00'>%s</color>{assets_2,90036}其中：\n50%%作为分红邮件发放给公会成员\n50%%转化为公会资金"), self.data.bidders[1].name, self.data.current_price)}})
            else
                TipsManager.Instance:ShowText({gameObject = self.LikeButton.gameObject, itemData = {string.format(TI18N("本次竞拍无人出价\n底价<color='#ffff00'>%s</color>{assets_2,90036}其中：\n50%%作为分红邮件发放给公会成员\n50%%转化为公会资金"), self.data.current_price)}})
            end
        -- else
        --     TipsManager.Instance:ShowText({gameObject = self.LikeButton.gameObject, itemData = {TI18N("尚未有人竞拍")}})
        -- end
    end
end

function GuildAuctionItem:OnAdd()
    if self.endtime > BaseUtils.BASE_TIME then
        if self.data.start_time < BaseUtils.BASE_TIME then
            GuildAuctionManager.Instance.model:OpenPanel(self.data)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("未开始拍卖，请耐心等待"))
        end
    else
        if self.data.timeout > 0 then
            GuildAuctionManager.Instance.model:OpenPanel(self.data)
        else
            -- NoticeManager.Instance:FloatTipsByString(TI18N("拍卖已经结束"))
            GuildAuctionManager.Instance.model:OpenPanel(self.data)
        end
    -- else
    --     NoticeManager.Instance:FloatTipsByString(TI18N("拍卖未开始，请耐心等待"))
    end
end

function GuildAuctionItem:OnOnce()
    if self.data.start_time < BaseUtils.BASE_TIME and self.endtime > BaseUtils.BASE_TIME then
        if self.data.start_time < BaseUtils.BASE_TIME then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否以<color='#ffff00'>%s</color>{assets_2,90036}的价格竞拍该道具？"), self.data.max_price)
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                GuildAuctionManager:send19703(self.data.id, self.data.max_price)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("未开始拍卖，请耐心等待"))
        end
    elseif self.endtime < BaseUtils.BASE_TIME then
        if self.data.timeout > 0 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("是否以<color='#ffff00'>%s</color>{assets_2,90036}的价格竞拍该道具？"), self.data.max_price)
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                GuildAuctionManager:send19703(self.data.id, self.data.max_price)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("拍卖已经结束"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("拍卖未开始，请耐心等待"))
    end
end

function GuildAuctionItem:OnLike()
    if GuildAuctionManager.Instance.likeList[self.data.id] ~= nil then
        GuildAuctionManager.Instance:send19706(self.data.id)
    else
        GuildAuctionManager.Instance:send19705(self.data.id)
    end
    -- self.LikeButtonicon:SetActive(not self.LikeButtonicon.activeSelf)
end

function GuildAuctionItem:OnTick()
    if self.data.start_time > BaseUtils.BASE_TIME then
        if self.data.start_time - BaseUtils.BASE_TIME > 3600 then
            self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后开始", BaseUtils.formate_time_gap(self.data.start_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.HOUR))
        else
            self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后开始", BaseUtils.formate_time_gap(self.data.start_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN))
        end
        -- 显示未开始倒计时
    elseif self.data.status == 0 and self.data.last_bidden ~= 0 or tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 0 then
        local daysecond = 3600*24
        local deltatime = self.endtime - BaseUtils.BASE_TIME
        if self.data.timeout > 0 then
            deltatime = self.data.timeout - BaseUtils.BASE_TIME
            print("超时事件")
            print(deltatime)
        end
        local daynum = math.ceil(deltatime/3600/24)
        if deltatime > 3600 and deltatime < daysecond then
            self.StatusText.text = string.format("       <color='#248813'>%s</color>\n     后结束", BaseUtils.formate_time_gap(deltatime, ":", 1, BaseUtils.time_formate.HOUR))
        elseif deltatime > 0 and deltatime < 3600 then
            self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后结束", BaseUtils.formate_time_gap(deltatime, ":", 1, BaseUtils.time_formate.MIN))
        elseif deltatime > 0 then
            self.StatusText.text = string.format(TI18N("<color='#248813'>%s天后结束</color>"), tostring(daynum))
            self.clock:SetActive(false)
            if self.timer ~= nil then
                LuaTimer.Delete(self.timer)
                self.timer = nil
            end
        else
            self.StatusText.text = TI18N("等待结算")
            self.clock:SetActive(false)
            if self.timer ~= nil then
                LuaTimer.Delete(self.timer)
                self.timer = nil
            end
        end
        --显示当天10点结算倒计时
    else
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        self:update_my_self(self.data)
    end


    -- if self.data.status == 0 and self.parent.index ~= 2 then
    --     if self.data.start_time > BaseUtils.BASE_TIME then
    --         if self.data.start_time - BaseUtils.BASE_TIME > 3600 then
    --             self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后开始", BaseUtils.formate_time_gap(self.data.start_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.HOUR))
    --         else
    --             self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后开始", BaseUtils.formate_time_gap(self.data.start_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN))
    --         end
    --         -- 显示未开始倒计时
    --     elseif self.data.last_bidden ~= 0 or tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 0 then
    --         local daysecond = 3600*24
    --         local deltatime = self.endtime - BaseUtils.BASE_TIME
    --         if self.data.timeout > 0 then
    --             deltatime = self.data.timeout - BaseUtils.BASE_TIME
    --         end
    --         local daynum = math.ceil(deltatime/3600/24)
    --         if deltatime > 3600 and deltatime < daysecond then
    --             self.StatusText.text = string.format("       <color='#248813'>%s</color>\n     后结束", BaseUtils.formate_time_gap(deltatime, ":", 1, BaseUtils.time_formate.HOUR))
    --         elseif deltatime < 3600 then
    --             self.StatusText.text = string.format("       <color='#ffff00'>%s</color>\n     后结束", BaseUtils.formate_time_gap(deltatime, ":", 1, BaseUtils.time_formate.MIN))
    --         else
    --             self.StatusText.text = string.format(TI18N("<color='#248813'>%s天后结束</color>"), tostring(daynum))
    --             self.clock:SetActive(false)
    --             if self.timer ~= nil then
    --                 LuaTimer.Delete(self.timer)
    --                 self.timer = nil
    --             end
    --         end
    --         --显示当天10点结算倒计时
    --     else
    --         self.clock:SetActive(false)
    --         self.StatusText.text = TI18N("竞拍中")
    --         if self.timer ~= nil then
    --             LuaTimer.Delete(self.timer)
    --             self.timer = nil
    --         end
    --         --显示周日10点结算倒计时
    --     end
    -- else
    --     if self.timer ~= nil then
    --         LuaTimer.Delete(self.timer)
    --         self.timer = nil
    --     end
    --     self:update_my_self(self.data)
    -- end


end