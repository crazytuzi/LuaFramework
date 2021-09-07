BibleDailyHoroscopePanel = BibleDailyHoroscopePanel or BaseClass(BasePanel)

function BibleDailyHoroscopePanel:__init(model, parent)
    self.model = DailyHoroscopeManager.Instance.model
    self.parent = parent
    self.mgr = BibleManager.Instance
    self.soundCount = 0
    self.resList = {
        {file = AssetConfig.bible_daily_horoscope_panel, type = AssetType.Main}
        ,{file = AssetConfig.big_buff_icon, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20136), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20137), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20138), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.bottom_item_list = nil
    self.previewComposite = nil
    self.last_model = nil

    self.show_effect = false

    self.ImgTipsPos = {
        [6] ={x= 20, y = -8}
        ,[1] ={x= -170, y = -80}
        ,[2] ={x= -65, y = -80}
        ,[3] ={x= 32, y = -80}
        ,[4] ={x= 142, y = -80}
        ,[5] ={x= 251, y = -80}
    }


    self.update_info_panel = function()
        self:update_info()
    end

    self.headLoaderList = {}
    self.update_panel_effect = function()
        self:set_show_effect()
    end

    self.OnOpenEvent:AddListener(function()
        DailyHoroscopeManager.Instance:request15900()
    end)
end

function BibleDailyHoroscopePanel:__delete()
    if self.slot_item2 ~= nil then
        self.slot_item2.slot:DeleteMe()
    end
    if self.slot_item3 ~= nil then
        self.slot_item3.slot:DeleteMe()
    end
    
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.bottom_item_list ~= nil then
        for k, v in pairs(self.bottom_item_list) do
            v.ImgHead.sprite = nil
        end
    end

    self.ImgBuffTips.sprite = nil
    self.BuffBg.sprite = nil
    self.ImgBuffSlotBg.sprite = nil
    self.ImgBuff.sprite = nil
    self.LeftCon:Find("BottomImg"):GetComponent(Image).sprite = nil

    EventMgr.Instance:RemoveListener(event_name.daily_horoscope_update, self.update_info_panel)
    EventMgr.Instance:RemoveListener(event_name.daily_horoscope_effect_update, self.update_panel_effect)

    self.is_open  =  false
    self.show_effect = false
    self.last_model = nil
    self.bottom_item_list = nil
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end


    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function BibleDailyHoroscopePanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_daily_horoscope_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DailyHoroscopePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)


    self.transform = self.gameObject.transform
    -- local CloseBtn = self.transform:FindChild("CloseButton"):GetComponent(Button)
    -- CloseBtn.onClick:AddListener(function() self.model:CloseMainUI() end)

    self.ImgBubble = self.transform:FindChild("ImgBubble").gameObject
    self.ImgBubbleCon = self.ImgBubble.transform:FindChild("Con")
    self.ImgBubbleTxt = self.ImgBubbleCon:FindChild("TxtDesc"):GetComponent(Text)
    self.ImgBubbleItemExtTxt = MsgItemExt.New(self.ImgBubbleTxt, 166, 18, 20)

    self.ImgBubble.transform:GetComponent(Button).onClick:AddListener(function()
        self.ImgBubble:SetActive(false)
    end)

    self.TopCon = self.transform:FindChild("TopCon")
    self.LeftCon = self.TopCon:FindChild("LeftCon")
    self.LeftCon:Find("BottomImg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.TxtName = self.LeftCon:FindChild("TxtName"):GetComponent(Text)
    self.Preview = self.LeftCon:FindChild("Preview").gameObject

    self.RightCon = self.TopCon:FindChild("RightCon")
    self.RightImgTitle = self.RightCon:FindChild("ImgTitle1")
    self.ImgDesc = self.RightCon:FindChild("ImgDesc")
    self.TxtDesc = self.ImgDesc:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtTitle = self.RightImgTitle:FindChild("Text"):GetComponent(Text)

    self.ItemCon = self.RightCon:FindChild("ItemCon")
    self.SlotCon1 = self.ItemCon:FindChild("SlotCon1")
    self.BuffBg = self.SlotCon1:FindChild("Slot"):GetComponent(Image)
    self.ImgAsk1 = self.SlotCon1:FindChild("ImgAsk").gameObject
    self.ImgBuff = self.SlotCon1:FindChild("ImgBuff"):GetComponent(Image)
    self.slot_item1 = {}
    self.slot_item1.txtDesc = self.SlotCon1:FindChild("TxtDesc"):GetComponent(Text)

    self.SlotCon2 = self.ItemCon:FindChild("SlotCon2")
    self.ImgAsk2 = self.SlotCon2:FindChild("ImgAsk").gameObject
    self.slot_item2 = self:create_slot_item(self.SlotCon2)

    self.SlotCon3 = self.ItemCon:FindChild("SlotCon3")
    self.ImgAsk3 = self.SlotCon3:FindChild("ImgAsk").gameObject
    self.slot_item3 = self:create_slot_item(self.SlotCon3)

    self.ImgTips = self.transform:FindChild("ImgTips").gameObject
    self.ImgTipsBtn = self.ImgTips.transform:GetComponent(Button)
    self.ImgTipsCon = self.ImgTips.transform:FindChild("Con")
    self.ImgBuffSlotBg = self.ImgTipsCon:FindChild("Slot"):GetComponent(Image)
    self.ImgBuffTips = self.ImgTipsCon:FindChild("ImgBuff"):GetComponent(Image)
    self.TxtNameTips = self.ImgTipsCon:FindChild("TxtName"):GetComponent(Text)
    self.TxtNameDesc = self.ImgTipsCon:FindChild("TxtNameDesc"):GetComponent(Text)
    self.TxtDescTips = self.ImgTipsCon:FindChild("TxtDesc"):GetComponent(Text)
    self.ImgTips:SetActive(false)
    self.ImgTipsCon.gameObject:SetActive(true)
    self.SlotCon1:GetComponent(Button).onClick:AddListener(function()
        if 1 - self.model.info_data.free_rf_count == 0 or self.model.info_data.day_best == 5 then
            local buff_cfg_data = DataPray.data_pray_buff[self.model.info_data.buff]
            if buff_cfg_data ~= nil then
                self.ImgTips:SetActive(true)
                local pos = self.ImgTipsPos[6]
                self.ImgTips:GetComponent(RectTransform).anchoredPosition = Vector2(pos.x, pos.y)

                self.ImgBuffTips.sprite = self.assetWrapper:GetSprite(AssetConfig.big_buff_icon, buff_cfg_data.show_icon)
                self.TxtNameTips.text = buff_cfg_data.name
                self.TxtNameDesc.text = ""
                self.TxtDescTips.text = buff_cfg_data.describe
            end
        end
    end)

    self.ImgTipsBtn.onClick:AddListener(function()
        self.ImgTips:SetActive(false)
    end)


    self.BottomCon = self.transform:FindChild("BottomCon")

    self.Item1 = self.BottomCon:FindChild("Item1")
    self.Item2 = self.BottomCon:FindChild("Item2")
    self.Item3 = self.BottomCon:FindChild("Item3")
    self.Item4 = self.BottomCon:FindChild("Item4")
    self.Item5 = self.BottomCon:FindChild("Item5")
    self.BtnUp = self.BottomCon:FindChild("BtnUp"):GetComponent(Button)
    self.BottomCon:FindChild("BtnUp").anchoredPosition3D = Vector3(202, 0, 0)
    self.BtnCost = self.BottomCon:FindChild("BtnCostUp"):GetComponent(Button)
    self.BtnReward = self.BottomCon:FindChild("BtnReward"):GetComponent(Button)

    self.BtnUp.transform:Find("Text"):GetComponent(Text).text = TI18N("提升祝福")

    self.BtnUpEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnUpEffect.transform:SetParent(self.BtnUp.transform)
    self.BtnUpEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnUpEffect.transform, "UI")
    self.BtnUpEffect.transform.localScale = Vector3(1.6, 0.8, 1)
    self.BtnUpEffect.transform.localPosition = Vector3(-52, -19, -400)

    self.BtnRewardEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnRewardEffect.transform:SetParent(self.BtnReward.transform)
    self.BtnRewardEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnRewardEffect.transform, "UI")
    self.BtnRewardEffect.transform.localScale = Vector3(1.75, 0.65, 1)
    self.BtnRewardEffect.transform.localPosition = Vector3(-54, -14, -400)


    self.TxtLeftFreeTime = self.BottomCon:FindChild("TxtLeftFreeTime"):GetComponent(Text)
    self.BottomCon:FindChild("TxtLeftFreeTime").anchoredPosition3D = Vector3(202, -35, 0)
    self.BtnCost_txt = self.BtnCost.transform:FindChild("Text"):GetComponent(Text)
    self.BtnCost_txt.text = ""
    self.BtnCost_msg = MsgItemExt.New(self.BtnCost_txt, 108, 16, 20)

    self.bottom_item1 = self:create_bottom_item(self.Item1)
    self.bottom_item2 = self:create_bottom_item(self.Item2)
    self.bottom_item3 = self:create_bottom_item(self.Item3)
    self.bottom_item4 = self:create_bottom_item(self.Item4)
    self.bottom_item5 = self:create_bottom_item(self.Item5)
    self.bottom_item_list = {}
    table.insert(self.bottom_item_list, self.bottom_item1)
    table.insert(self.bottom_item_list, self.bottom_item2)
    table.insert(self.bottom_item_list, self.bottom_item3)
    table.insert(self.bottom_item_list, self.bottom_item4)
    table.insert(self.bottom_item_list, self.bottom_item5)

    self.bottom_item1.button.onClick:AddListener(function() self:onClickBottomItem(self.bottom_item1) end)
    self.bottom_item2.button.onClick:AddListener(function() self:onClickBottomItem(self.bottom_item2) end)
    self.bottom_item3.button.onClick:AddListener(function() self:onClickBottomItem(self.bottom_item3) end)
    self.bottom_item4.button.onClick:AddListener(function() self:onClickBottomItem(self.bottom_item4) end)
    self.bottom_item5.button.onClick:AddListener(function() self:onClickBottomItem(self.bottom_item5) end)
    self.BtnUp.onClick:AddListener(function() self:onClickUpBtn() end)
    self.BtnReward.onClick:AddListener(function() self:onClickRewardBtn() end)
    self.BtnCost.onClick:AddListener(function() self:onClickUpBtn() end)

    self:update_bottom_items()
    self:update_info()
    -- DailyHoroscopeManager.Instance:request15900()

    EventMgr.Instance:AddListener(event_name.daily_horoscope_update, self.update_info_panel)
    EventMgr.Instance:AddListener(event_name.daily_horoscope_effect_update, self.update_panel_effect)

    self.is_open  =  true
end


------------------------更新五个头像逻辑
function BibleDailyHoroscopePanel:update_bottom_items()
    for i=1,5 do
        local cfg_data = DataPray.data_pray_prop[i]
        local item = self.bottom_item_list[i]
        item.is_open = false
        self:set_bottom_item_data(item, BaseUtils.copytab(cfg_data), i)
    end

end

------------------------界面更新逻辑
function BibleDailyHoroscopePanel:update_info()
    if self.is_open == false then
        self.show_effect = false
        return
    end

    if self.show_effect then
        self.show_effect = false
        self.BtnUpEffect:SetActive(false)
        --将所有泡泡隐藏
        for i=1,#self.bottom_item_list do
            local item = self.bottom_item_list[i]
            item.ImgBubble.gameObject:SetActive(false)
        end

        --装B播特效
        local index = self.model.last_index
        local next_index = index + 1
            local step = 200/(self.model.info_data.day_best*3)  --每次步进,单位毫秒
            local last_step = step
            local round = 0
            self.delay_fun = function()
                if self.is_open == false then
                    if self.model.up_result_msg ~= nil then
                        NoticeManager.Instance:FloatTipsByString(self.model.up_result_msg)
                        self.model.up_result_msg = nil
                    end
                    return
                end
                local item = self.bottom_item_list[index]
                self:set_item_effect(item, 1)
                if index <= self.model.last_index then
                    index = index + 1
                    if index > 5 then
                        index = 1
                    end
                else
                    index = 1
                end
                if round < 2 then
                    last_step = last_step + step
                    LuaTimer.Add(last_step, function() self.delay_fun() end)
                    round = math.floor((last_step/step)/self.model.info_data.day_best) --走了多少个，除去一圈多少个，得出已经走了几圈
                else
                    if index == self.model.info_data.day_best then
                        --到终点
                        item = self.bottom_item_list[self.model.info_data.day_best]
                        item.ImgBubble.gameObject:SetActive(true)
                        self:set_item_effect(item, 2)
                        self:update_info()

                        if self.model.up_result_msg ~= nil then
                            NoticeManager.Instance:FloatTipsByString(self.model.up_result_msg)
                            self.model.up_result_msg = nil
                        end

                        --冒个泡
                        self:onClickBubble(item)
                        LuaTimer.Add(7000, function()
                            if self.is_open then
                                self.ImgBubble:SetActive(false)
                            end
                        end)
                        LuaTimer.Add(1000, function()
                            if self.is_open then
                                for i=1, #self.bottom_item_list do
                                    if i ~= self.model.info_data.day_best then
                                        self:set_item_effect(self.bottom_item_list[i], 0)
                                    else
                                        self.bottom_item_list[i].effect_20137:SetActive(false)
                                    end
                                end
                            end
                        end)

                        self:set_btnup_state(true)
                    else
                        last_step = last_step + step
                        LuaTimer.Add(last_step, function() self.delay_fun() end)
                    end
                end
            end
            LuaTimer.Add(last_step, function() self.delay_fun() end)

    else
        if self.model.info_data == nil then
            return
        end
        local cfg_data = DataPray.data_pray_prop[self.model.info_data.day_best]
        local pray_result_key = ""
        for i=1,#self.model.info_data.pray_result do
            local f = self.model.info_data.pray_result[i]
            if pray_result_key == "" then
                pray_result_key = tostring(f.pray_lv)
            else
                pray_result_key = string.format("%s_%s", pray_result_key,f.pray_lv)
            end
        end

        pray_result_key = string.format("%s_%s", pray_result_key, self.model.info_data.free_rf_count)
        local result_cfg_data = DataPray.data_pray_result[pray_result_key]

        local top_name = ""
        local right_desc = self.TxtDesc.text
        self.TxtDesc.text = ""


        local buff_cfg_data = DataPray.data_pray_buff[self.model.info_data.buff]

        if (result_cfg_data ~= nil and self.model.info_data.is_receive == 0) or (self.model.info_data.is_receive ~= 0 and right_desc == "") then
            self.bubble_msg = ""
            top_name = string.format("%s<color='#FFDC5F'>%s（%s）</color>", TI18N("当前祝福："), cfg_data.name, result_cfg_data.luck)

            local temp_tbl = StringHelper.Split(result_cfg_data.desc, "|")
            local con_tbl = {}
            for i=1,#temp_tbl do
                if temp_tbl[i] ~= nil and temp_tbl[i] ~= "" then
                    table.insert(con_tbl, temp_tbl[i])
                end
            end
            local range_index = Random.Range(1, #con_tbl)
            right_desc = string.format("<color='#F7D65D'>%s</color>", con_tbl[range_index])

            temp_tbl = StringHelper.Split(result_cfg_data.content, "|")
            con_tbl = {}
            for i=1,#temp_tbl do
                if temp_tbl[i] ~= nil and temp_tbl[i] ~= "" then
                    table.insert(con_tbl, temp_tbl[i])
                end
            end
            local range_index = Random.Range(1, #con_tbl)
            self.bubble_msg = con_tbl[range_index]

            if buff_cfg_data ~= nil and (self.model.info_data.free_rf_count ~= 0 or self.model.info_data.day_best == 5) then
                right_desc = string.format("%s\n<color='#ffff00'>[%s]</color>%s", right_desc, buff_cfg_data.name, buff_cfg_data.describe)
            end

        else
            top_name = string.format("%s<color='#FFDC5F'>%s</color>", TI18N("当前祝福："), cfg_data.name)
        end

        self.TxtDesc.text = right_desc
        self.TxtName.text = top_name


        -- self.slot_item1.slot:SetAll(nil)
        self.BuffBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        self.ImgBuffSlotBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        self.slot_item2.slot:SetAll(nil)
        self.slot_item3.slot:SetAll(nil)
        self.slot_item1.txtDesc.text = TI18N("神秘奖励")
        self.slot_item2.txtDesc.text = TI18N("神秘奖励")
        self.slot_item3.txtDesc.text = TI18N("神秘奖励")

        self.ImgBuff.gameObject:SetActive(false)
        self.ImgAsk1:SetActive(true)
        self.ImgAsk2:SetActive(true)
        self.ImgAsk3:SetActive(true)


        if 1 - self.model.info_data.free_rf_count == 0 or self.model.info_data.day_best == 5 then
            for i=1,#self.model.info_data.rewards do
                local _data = self.model.info_data.rewards[i]
                local base_data = DataItem.data_get[_data.item_id]
                if i == 1 then
                    self:set_stone_slot_data(self.slot_item2.slot, base_data)
                    self.slot_item2.txtDesc.text = base_data.name
                    self.ImgAsk2:SetActive(false)
                elseif i == 2 then
                    self:set_stone_slot_data(self.slot_item3.slot, base_data)
                    self.slot_item3.txtDesc.text = base_data.name
                    self.ImgAsk3:SetActive(false)
                end
            end


            if buff_cfg_data ~= nil then
                self.ImgAsk1:SetActive(false)
                self.ImgBuff.gameObject:SetActive(true)
                self.slot_item1.txtDesc.text = buff_cfg_data.name
                self.ImgBuff.sprite = self.assetWrapper:GetSprite(AssetConfig.big_buff_icon, buff_cfg_data.show_icon)

                if buff_cfg_data.show_icon == 3 or  buff_cfg_data.show_icon == 7 then
                    self.BuffBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item4"))
                    self.ImgBuffSlotBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item4"))
                elseif buff_cfg_data.show_icon == 4 or  buff_cfg_data.show_icon == 8 then
                    self.BuffBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item5"))
                    self.ImgBuffSlotBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item5"))
                end
            end
        end


        -- 更新底部三个宠物头像
        for i=1,self.model.info_data.day_best do
            local temp_cfg_data = BaseUtils.copytab(DataPray.data_pray_prop[i])
            temp_cfg_data.is_open = true
            local item = self.bottom_item_list[i]
            self:set_bottom_item_data(item, temp_cfg_data, i)
        end

        -- 更新模型
        self:update_model(cfg_data)


        if 1 - self.model.info_data.free_rf_count > 0 and self.model.info_data.day_best ~= 5 then
            self.TxtLeftFreeTime.text = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("剩余"), 1 - self.model.info_data.free_rf_count, TI18N("次"))
        else
            self.TxtLeftFreeTime.text = ""
        end

        self.BtnUp.gameObject:SetActive(false)
        self.BtnCost.gameObject:SetActive(false)
        self.BtnReward.gameObject:SetActive(false)
        -- self.BtnUp.transform:GetComponent(RectTransform).anchoredPosition = Vector2(218, 30)
        self.BtnCost.transform:GetComponent(RectTransform).anchoredPosition = Vector2(218, 30)
        self.BtnReward.transform:GetComponent(RectTransform).anchoredPosition = Vector2(205, -30)
        --底部按钮更新
        if self.model.info_data.day_best < 5 then
            if self.model.info_data.is_receive == 1 then
                --已经领取，灰掉
                self.BtnReward.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).text = TI18N("明日再来")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
                self.BtnRewardEffect:SetActive(false)
                self.BtnReward.transform:GetComponent(RectTransform).anchoredPosition = Vector2(205, -5)
                self.BtnReward.gameObject:SetActive(true)

                if self.slot_item1.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item1.txtDesc.text = ""
                end
                if self.slot_item2.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item2.txtDesc.text = ""
                end
                if self.slot_item3.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item3.txtDesc.text = ""
                end

                self.ImgAsk1:SetActive(false)
                self.ImgAsk2:SetActive(false)
                self.ImgAsk3:SetActive(false)
            elseif self.model.info_data.free_rf_count == 0 then
                --没失败过，显示提升
                self.BtnUp.gameObject:SetActive(true)
                -- self.BtnUp.transform:GetComponent(RectTransform).anchoredPosition = Vector2(218, 0)
            else
                self.BtnReward.transform:GetComponent(RectTransform).anchoredPosition = Vector2(205, -5)
                self.BtnReward.gameObject:SetActive(true)
                if self.model.info_data.is_receive == 1 then
                    --已经领取，灰掉
                    self.BtnReward.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    self.BtnReward.transform:FindChild("Text"):GetComponent(Text).text = TI18N("明日再来")
                    self.BtnReward.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
                    self.BtnRewardEffect:SetActive(false)
                else
                    self.BtnReward.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                    self.BtnReward.transform:FindChild("Text"):GetComponent(Text).text = TI18N("领取祝福")
                    self.BtnReward.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
                    self.BtnRewardEffect:SetActive(true)
                end

                if self.slot_item1.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item1.txtDesc.text = ""
                end
                if self.slot_item2.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item2.txtDesc.text = ""
                end
                if self.slot_item3.txtDesc.text ==  TI18N("神秘奖励") then
                    self.slot_item3.txtDesc.text = ""
                end

                self.ImgAsk1:SetActive(false)
                self.ImgAsk2:SetActive(false)
                self.ImgAsk3:SetActive(false)
            end
        else
            --只显示领取奖励
            self.BtnReward.gameObject:SetActive(true)
            self.BtnReward.transform:GetComponent(RectTransform).anchoredPosition = Vector2(205, -5)
            if self.model.info_data.is_receive == 1 then
                --已经领取，灰掉
                self.BtnReward.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).text = TI18N("已领取")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
            else
                self.BtnReward.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).text = TI18N("领取奖励")
                self.BtnReward.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
            end

            if self.slot_item1.txtDesc.text ==  TI18N("神秘奖励") then
                self.slot_item1.txtDesc.text = ""
            end
            if self.slot_item2.txtDesc.text ==  TI18N("神秘奖励") then
                self.slot_item2.txtDesc.text = ""
            end
            if self.slot_item3.txtDesc.text ==  TI18N("神秘奖励") then
                self.slot_item3.txtDesc.text = ""
            end
            self.ImgAsk1:SetActive(false)
            self.ImgAsk2:SetActive(false)
            self.ImgAsk3:SetActive(false)
        end

    end
end

--设置提升按钮状态
function BibleDailyHoroscopePanel:set_btnup_state(state)
    self.BtnUp.enabled = state
    self.BtnUpEffect:SetActive(state)
    if state then
        self.BtnUp.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.BottomCon:FindChild("BtnUp"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
    else
        self.BtnUp.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BottomCon:FindChild("BtnUp"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
    end
end

------------------------监听器
--点击底部宠物头像监听
function BibleDailyHoroscopePanel:onClickBottomItem(item)
    if item.data ~= nil then

    end
end

--点击提升按钮监听
function BibleDailyHoroscopePanel:onClickUpBtn()
    if self.model.up_cost_confirm_tips == false then
        --判断下是否要消耗钻石
        if self.model.info_data.free_rf_count ~= 0 then
            local cfg_cost_data = DataPray.data_pray_cost[self.model.info_data.pay_rf_count+1]
            if cfg_cost_data == nil then
                cfg_cost_data = DataPray.data_pray_cost[7]
            end

            local cost_type = ""
            if cfg_cost_data.assets_type == "gold" then
                cost_type = "90002"
            elseif cfg_cost_data.assets_type == "gold_bind" then
                cost_type = "90003"
            elseif cfg_cost_data.assets_type == "coin" then
                cost_type = "90000"
            end


            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format("%s%s{assets_2,%s}%s<color='#ffff00'>%s</color>", TI18N("消耗"), cfg_cost_data.cost, cost_type, TI18N("再次提升祝福"), TI18N("（本次登录不再提示）"))
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                DailyHoroscopeManager.Instance.model.up_cost_confirm_tips = true
                DailyHoroscopeManager.Instance:request15903()

                self:set_btnup_state(false)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            DailyHoroscopeManager.Instance:request15901()
            self:set_btnup_state(false)
        end
    else
        DailyHoroscopeManager.Instance:request15903()
        self:set_btnup_state(false)
    end
        self.soundCount = 0
end

--点击领取奖励按钮监听
function BibleDailyHoroscopePanel:onClickRewardBtn()
    if self.model.info_data.is_receive == 1 then
        DailyHoroscopeManager.Instance:request15902()
        return
    end
    if self.model.info_data.day_best < 5 then
        -- local buff_cfg_data = DataPray.data_pray_buff[self.model.info_data.buff]
        -- local data = NoticeConfirmData.New()
        -- data.type = ConfirmData.Style.Normal
        -- data.content = string.format("%s<color=''>[%s]</color>%s", TI18N("领取奖励后"), buff_cfg_data.name, TI18N("将立即生效且今日无法再次提升祝福"))
        -- data.sureLabel = TI18N("确认")
        -- data.cancelLabel = TI18N("取消")
        -- data.sureCallback = function()
        --     DailyHoroscopeManager.Instance:request15902()
        -- end
        -- NoticeManager.Instance:ConfirmTips(data)
        DailyHoroscopeManager.Instance:request15902()
    elseif self.model.info_data.day_best == 5 then
        -- local buff_cfg_data = DataPray.data_pray_buff[self.model.info_data.buff]
        -- local data = NoticeConfirmData.New()
        -- data.type = ConfirmData.Style.Normal
        -- data.content = string.format("%s<color=''>[%s]</color>%s", TI18N("领取奖励后"), buff_cfg_data.name, TI18N("将立即生效"))
        -- data.sureLabel = TI18N("确认")
        -- data.cancelLabel = TI18N("取消")
        -- data.sureCallback = function()
        --     DailyHoroscopeManager.Instance:request15902()
        -- end
        -- NoticeManager.Instance:ConfirmTips(data)
        DailyHoroscopeManager.Instance:request15902()
    end
end

------------------------辅助函数
--创建slotItem
function BibleDailyHoroscopePanel:create_slot_item(slotCon)
    local Slo2 = slotCon:FindChild("Slot").gameObject
    local TxtDesc2 = slotCon:FindChild("TxtDesc"):GetComponent(Text)
    local item = {}
    item.slot = self:create_slot(Slo2)
    item.txtDesc = TxtDesc2
    return item
end


--创建slot
function BibleDailyHoroscopePanel:create_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function BibleDailyHoroscopePanel:set_stone_slot_data(slot, data)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, {nobutton = true})
end


--创建底部宠物item
function BibleDailyHoroscopePanel:create_bottom_item(bottom_item)
    local item = {}
    item.gameObject = bottom_item.gameObject
    item.bg = bottom_item:GetComponent(Image)
    item.ImgHead = bottom_item:FindChild("ImgHead"):GetComponent(Image)
    item.ImgBubble = bottom_item:FindChild("ImgBubble"):GetComponent(Image)
    item.ImgBubbleBtn = bottom_item:FindChild("ImgBubble"):GetComponent(Button)
    item.button = bottom_item:FindChild("ImgBtn"):GetComponent(Button)

    item.effect_20136 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20136)))
    item.effect_20136.transform:SetParent(bottom_item.transform)
    item.effect_20136.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(item.effect_20136.transform, "UI")
    item.effect_20136.transform.localScale = Vector3(1, 1, 1)
    item.effect_20136.transform.localPosition = Vector3(0, 0, -500)

    item.effect_20137 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20137)))
    item.effect_20137.transform:SetParent(bottom_item.transform)
    item.effect_20137.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(item.effect_20137.transform, "UI")
    item.effect_20137.transform.localScale = Vector3(1, 1, 1)
    item.effect_20137.transform.localPosition = Vector3(0, 0, -500)

    item.effect_20138 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20138)))
    item.effect_20138.transform:SetParent(bottom_item.transform)
    item.effect_20138.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(item.effect_20138.transform, "UI")
    item.effect_20138.transform.localScale = Vector3(1, 1, 1)
    item.effect_20138.transform.localPosition = Vector3(0, 0, -500)


    item.effect_20136:SetActive(false)
    item.effect_20137:SetActive(false)
    item.effect_20138:SetActive(false)

    item.button.onClick:AddListener(function() self:onClickBubble(item) end)
    item.ImgBubbleBtn.onClick:AddListener(function() self:onClickBubble(item) end)
    return item
end

--点击item冒泡
function BibleDailyHoroscopePanel:onClickBubble(item)
    if item.index == self.model.info_data.day_best then
        local newX = -230+(item.index-1)*100
        self.ImgBubbleCon:GetComponent(RectTransform).anchoredPosition = Vector2(newX, -62)
        self.ImgBubble:SetActive(true)
        self.ImgBubbleItemExtTxt:SetData(self.bubble_msg)
    else
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.ImgBuffTips.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,item.data.icon)

        -- self.ImgBuffTips.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(item.data.icon), tostring(item.data.icon))
        self.TxtNameTips.text = self.model.item_bubble_tips_name[item.index]
        self.TxtNameDesc.text= self.model.item_bubble_tips[item.index]
        self.TxtDescTips.text = self.model.item_bubble_tips2[item.index]

        local pos = self.ImgTipsPos[item.index]
        self.ImgTips:GetComponent(RectTransform).anchoredPosition = Vector2(pos.x, pos.y)
        self.ImgTips.gameObject:SetActive(true)
    end
end

--设置显示特效
function BibleDailyHoroscopePanel:set_show_effect()
    self.show_effect = true
end

--设置底部宠物item的数据
function BibleDailyHoroscopePanel:set_bottom_item_data(item, data, index)
    item.data = data

    local loaderId = item.ImgHead.gameObject:GetInstanceID()
    --
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(item.ImgHead.gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,data.icon)
    -- item.ImgHead.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data.icon), tostring(data.icon))
    item.ImgHead.gameObject:SetActive(true)
    item.index = index
    if data.is_open then
        BaseUtils.SetGrey(item.ImgHead, false)
        BaseUtils.SetGrey(item.bg, false)
    else
        BaseUtils.SetGrey(item.ImgHead, true)
        BaseUtils.SetGrey(item.bg, true)
    end

    if self.model.info_data ~= nil then
        if index == self.model.info_data.day_best then
            --显示冒泡
            item.ImgBubble.gameObject:SetActive(true)
            item.effect_20138:SetActive(true)
        else
            item.ImgBubble.gameObject:SetActive(false)
        end
    else
        item.ImgBubble.gameObject:SetActive(false)
    end
end

--设置item显示的特效
function BibleDailyHoroscopePanel:set_item_effect(item, index)
    item.effect_20136:SetActive(false)
    item.effect_20137:SetActive(false)
    item.effect_20138:SetActive(false)
    if index == 1 then
        --经过
        item.effect_20136:SetActive(true)
        if self.soundCount < 3 then
            SoundManager.Instance:Play(236)
            self.soundCount = self.soundCount + 1
        end
    elseif index == 2 then
        --选中
        item.effect_20137:SetActive(true)
        item.effect_20138:SetActive(true)
    end
end

------------------------模型逻辑
function BibleDailyHoroscopePanel:update_model(cfg_data)
    if self.last_model == cfg_data.model then
        return
    end
    self.last_model = cfg_data.model
    local petData = DataPet.data_pet[cfg_data.model]
    local data = {type = PreViewType.Pet, skinId = petData.skin_id_0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = {}}

     local callback = function(composite)
        self:preview_loaded(composite)
    end

    if self.previewComposite == nil then
        local setting = {
            name = "DailyHoroscope"
            ,orthographicSize = 0.5
            ,width = 256
            ,height = 256
            ,offsetY = -0.4
        }
        self.previewComposite = PreviewComposite.New(callback, setting, data)
    else
        self.previewComposite:Reload(data, callback)
    end
end

function BibleDailyHoroscopePanel:preview_loaded(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, 0, 0))
    self.Preview:SetActive(true)
end