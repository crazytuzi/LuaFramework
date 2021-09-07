WorldRedBagSetWindow  =  WorldRedBagSetWindow or BaseClass(BaseWindow)

function WorldRedBagSetWindow:__init(model)
    self.name  =  "WorldRedBagSetWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.world_red_bag_set_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }
    self.winLinkType = WinLinkType.Link


    self.windowId = WindowConfig.WinID.world_red_bag_set_win
    self.is_open = false

    self.my_type = 0
    self.cur_random_num = 0

    self.view_index = 0

    self.TabGroupObj = nil
    self.TabGroup = nil

    return self
end

function WorldRedBagSetWindow:__delete()
    self.bg2.sprite = nil
    self.is_open = false
    self.my_type = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldRedBagSetWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_red_bag_set_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldRedBagSetWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    -- local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    -- Panel.onClick:AddListener(function() self.model:CloseRedBagSetUI() end)

    self.MainCon=self.transform:FindChild("MainCon")

    self.bg2 = self.transform:FindChild("MainCon"):FindChild("bg2"):GetComponent(Image)
    local close_btn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.Item1 = self.MainCon:FindChild("Item1")
    self.Item1InputField = self.Item1:FindChild("InputField"):GetComponent(InputField)
    self.Item1InputField.textComponent = self.Item1InputField.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.Item1InputField.placeholder = self.Item1InputField.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.Item1InputField.characterLimit = 14
    self.Item1InputField.text = TI18N("恭喜发财，大吉大利")

    self.Item1InputField.onEndEdit:AddListener(function(str)
        if str == "" then
            self.Item1InputField.text = TI18N("恭喜发财，大吉大利")
        end
    end)

    local list = { TI18N("新年快乐"), TI18N("萌萌哒"), TI18N("恭喜发财，大吉大利"), TI18N("新年快乐") }
    self.defaultskey = list[math.random(1, #list)]

    self.Item11 = self.MainCon:FindChild("Item11")
    self.Item11InputField = self.Item11:FindChild("InputField"):GetComponent(InputField)
    self.Item11InputField.textComponent = self.Item11InputField.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.Item11InputField.placeholder = self.Item11InputField.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.Item11InputField.characterLimit = 14
    self.Item11InputField.text = self.defaultskey

    self.Item11InputField.onEndEdit:AddListener(function(str)
        if str == "" then
            self.Item11InputField.text = self.defaultskey
        end
    end)

    self.DescText1 = self.MainCon:FindChild("DescText1"):GetComponent(Text)

    self.Item2 = self.MainCon:FindChild("Item2")
    self.Item2:GetComponent(Button).onClick:AddListener(function()
        self.model:InitRedBagMoneyUI({self.view_index})
    end)
    self.Item2TxtNum = self.Item2:FindChild("TxtNum"):GetComponent(Text)
    self.Item2ImgCoin = self.Item2:FindChild("ImgCoin")

    self.Item3 = self.MainCon:FindChild("Item3")
    self.Item3InputField = self.Item3:FindChild("InputField"):GetComponent(Text)
    self.BtnRandom = self.Item3:FindChild("BtnRandom"):GetComponent(Button)
    self.BtnRandom.onClick:AddListener(function()
        self:on_random_num()
    end)
    --左右加号
    self.BtnDiv = self.Item3:FindChild("BtnDiv"):GetComponent(Button)
    self.BtnPlus = self.Item3:FindChild("BtnPlus"):GetComponent(Button)
    self.BtnDiv.onClick:AddListener(function()
        if self.my_type == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
            return
        end

        self.BtnPlus.gameObject:SetActive(true)

        local cfg_data = DataRedPacket.data_red_packet[string.format("%s_%s", self.view_index, self.my_type)]
        if self.cur_random_num > cfg_data.min then
            self.cur_random_num = self.cur_random_num - 1
            self.Item3InputField.text = tostring(self.cur_random_num)
            if self.cur_random_num == cfg_data.min then
                self.BtnDiv.gameObject:SetActive(false)
            end
        end
    end)

    self.BtnPlus.onClick:AddListener(function()
        if self.my_type == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
            return
        end

        self.BtnDiv.gameObject:SetActive(true)

        local cfg_data = DataRedPacket.data_red_packet[string.format("%s_%s", self.view_index, self.my_type)]
        if self.cur_random_num < cfg_data.max then
            self.cur_random_num = self.cur_random_num + 1
            self.Item3InputField.text = tostring(self.cur_random_num)
            if self.cur_random_num == cfg_data.max then
                self.BtnPlus.gameObject:SetActive(false)
            end
        end
    end)

    self.DescText2 = self.MainCon:FindChild("DescText2"):GetComponent(Text)
    -- self.DescText2.text = ""
    self.DescText2Ext = MsgItemExt.New(self.DescText2, 271, 16, 30)
    self.DescText2Ext:SetData("")

    self.BtnPut = self.MainCon:FindChild("BtnPut"):GetComponent(Button)
    self.BtnPut.onClick:AddListener(function()
        if self.my_type == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
            return
        end
        if self.view_index == 2 then
            if self.Item11InputField.textComponent.text == "" then
                NoticeManager.Instance:FloatTipsByString(TI18N("请先填写口令"))
            else
                RedBagManager.Instance:Send18502(self.view_index, self.my_type, self.cur_random_num, self.Item11InputField.textComponent.text)
            end
        else
            RedBagManager.Instance:Send18502(self.view_index, self.my_type, self.cur_random_num, self.Item1InputField.textComponent.text)
        end
        WindowManager.Instance:CloseWindow(self)
    end)

    self.MainCon:FindChild("DescButton"):GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.MainCon:FindChild("DescButton").gameObject, itemData = {
                    TI18N("1.拼手气红包和口令红包有几率开出<color='#00ff00'>[红包头彩]</color>"),
                    TI18N("2.拼手气红包和口令红包没有被抢完时，不能再发新红包"),
                    TI18N("3.没有被抢完的拼手气和口令红包，将会在<color='#ffff00'>24小时</color>后返回剩余金额给发放者（不包括[红包头彩]）"),
                    TI18N("4.红包雨发放后<color='#ffff00'>1分钟</color>，将随机刷出红包在5大场景之一"),
                    TI18N("5.红包雨<color='#ffff00'>1小时</color>内没有被抢完将返还给发放者"),
                    TI18N("6.红包雨同一时间段最多出现<color='#00ff00'>3人</color>发放"),
                    TI18N("7.当前世界有超过<color='#00ff00'>20个</color>红包未领时，不能发放红包")
                }})
        end)
    self.redBagImage = self.MainCon:FindChild("RedBagImage/Image")
    self.redBagText = self.MainCon:FindChild("RedBagImage/Text"):GetComponent(Text)

    self.TabGroupObj = self.MainCon:FindChild("TabButtonGroup").gameObject
    self.TabGroup = TabGroup.New(self.TabGroupObj, function(index) self:changeTab(index) end)

    self:changeTab(1)
end

--更新选中的发送数量
function WorldRedBagSetWindow:update_send_info(_type)
    self.my_type = _type
    local cfg_data = DataRedPacket.data_red_packet[string.format("%s_%s", self.view_index, self.my_type)]
    self.Item2TxtNum.text = tostring(cfg_data.val)
    self.Item2ImgCoin:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..cfg_data.assets)
    self:on_random_num()

    -- if self.view_index == 1 then
    -- 	-- self.DescText2.text = string.format(TI18N("拼手气红包（可能开出[红包头彩]）\n总金额：%s"), cfg_data.val)
    --     self.DescText2Ext:SetData(string.format(TI18N("拼手气红包（可能开出[红包头彩]）\n总金额：{assets_1,%s,%s})"), cfg_data.assets, cfg_data.val))
    -- elseif self.view_index == 2 then
    -- 	-- self.DescText2.text = string.format(TI18N("口令红包（可能开出[红包头彩]）\n总金额：%s)"), cfg_data.val)
    --     self.DescText2Ext:SetData(string.format(TI18N("口令红包（可能开出[红包头彩]）\n总金额：{assets_1,%s,%s})"), cfg_data.assets, cfg_data.val))
    -- else
    -- 	-- self.DescText2.text = TI18N("红包雨将出现在各大主城，采集红包获得随机红包奖励")
    --     self.DescText2Ext:SetData(TI18N("红包雨将出现在各大主城，采集红包获得随机红包奖励"))
    -- end
end

--随机个数量出来
function WorldRedBagSetWindow:on_random_num()
    if self.my_type == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
        return
    end

    local cfg_data = DataRedPacket.data_red_packet[string.format("%s_%s", self.view_index, self.my_type)]
    local random_num = Random.Range(cfg_data.min , cfg_data.max)
    self.cur_random_num = random_num
    self.Item3InputField.text = tostring(random_num)

    self.BtnDiv.gameObject:SetActive(true)
    self.BtnPlus.gameObject:SetActive(true)
    if self.cur_random_num == cfg_data.min then
        self.BtnDiv.gameObject:SetActive(false)
    end

    if self.cur_random_num == cfg_data.max then
        self.BtnPlus.gameObject:SetActive(false)
    end
end


function WorldRedBagSetWindow:changeTab(index)
    if self.view_index == index then return end
    self.view_index = index

    self.my_type = 0
    if self.view_index == 1 then
    	self.Item1.gameObject:SetActive(true)
       	self.Item11.gameObject:SetActive(false)
        self.Item2TxtNum.text = "0"
        self.DescText1.text = TI18N("拆开随机获得金额")
        -- self.DescText2.text = ""
        -- self.DescText2Ext:SetData("")

        self.redBagImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "RedBagTxt")
        self.redBagImage:GetComponent(Image):SetNativeSize()
        self.redBagText.text = TI18N("拼手气红包")
        self.DescText2Ext:SetData(TI18N("拼手气红包"))
    elseif self.view_index == 2 then
        self.Item1.gameObject:SetActive(false)
       	self.Item11.gameObject:SetActive(true)
        self.Item2TxtNum.text = "0"
        self.DescText1.text = TI18N("其他玩家需要回复口令抢红包")
        -- self.DescText2.text = ""
        -- self.DescText2Ext:SetData("")

        self.redBagImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "Lock")
        self.redBagImage:GetComponent(Image):SetNativeSize()
        self.redBagText.text = TI18N("口令红包")
        self.DescText2Ext:SetData(TI18N("口令红包"))

        local list = { TI18N("新年快乐"), TI18N("萌萌哒"), TI18N("恭喜发财，大吉大利"), TI18N("新年快乐") }
        self.defaultskey = list[math.random(1, #list)]
        self.Item11InputField.text = self.defaultskey
    else
       	self.Item1.gameObject:SetActive(true)
       	self.Item11.gameObject:SetActive(false)
        self.Item2TxtNum.text = "0"
        self.DescText1.text = TI18N("红包雨1分钟后发放")
        -- self.DescText2.text = ""
        -- self.DescText2Ext:SetData("")

        self.redBagImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_dep_res, "RedBagTxt")
        self.redBagImage:GetComponent(Image):SetNativeSize()
        self.redBagText.text = TI18N("红包雨")
        self.DescText2Ext:SetData(TI18N("红包雨将刷出红包在随机主城地图"))
    end

    if self.my_type ~= 0 then
    	self:update_send_info(self.my_type)
    end
end

