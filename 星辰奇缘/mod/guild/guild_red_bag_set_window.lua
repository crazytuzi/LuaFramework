GuildRedBagSetWindow  =  GuildRedBagSetWindow or BaseClass(BasePanel)

function GuildRedBagSetWindow:__init(model)
    self.name  =  "GuildRedBagSetWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.guild_red_bag_set_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
    }

    self.windowId = WindowConfig.WinID.guild_red_bag_set_win
    self.is_open = false

    self.my_type = 0
    self.cur_random_num = 0

    return self
end

function GuildRedBagSetWindow:__delete()
    self.bg2.sprite = nil
    self.is_open = false
    self.my_type = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildRedBagSetWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_red_bag_set_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildRedBagSetWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRedBagSetUI() end)

    self.MainCon=self.transform:FindChild("MainCon")

    self.bg2 = self.transform:FindChild("MainCon"):FindChild("bg2"):GetComponent(Image)
    local close_btn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseRedBagSetUI() end)

    self.Item1 = self.MainCon:FindChild("Item1")
    self.Item1InputField = self.Item1:FindChild("InputField"):GetComponent(InputField)
    self.Item1InputField.textComponent = self.Item1InputField.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.Item1InputField.placeholder = self.Item1InputField.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.Item1InputField.characterLimit = 14

    self.Item1InputField.onEndEdit:AddListener(function(str)
        if str == "" then
            self.Item1InputField.text = TI18N("恭喜发财，大吉大利")
        end
    end)

    self.TxtGuildMemNum = self.MainCon:FindChild("TxtGuildMemNum"):GetComponent(Text)

    self.Item2 = self.MainCon:FindChild("Item2")
    self.Item2:GetComponent(Button).onClick:AddListener(function()
        self.model:InitRedBagMoneyUI()
    end)
    self.Item2TxtNum = self.Item2:FindChild("TxtNum"):GetComponent(Text)

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

        local cfg_data = DataGuild.data_get_redbag_data[self.my_type]
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

        local cfg_data = DataGuild.data_get_redbag_data[self.my_type]
        if self.cur_random_num < cfg_data.max then
            self.cur_random_num = self.cur_random_num + 1
            self.Item3InputField.text = tostring(self.cur_random_num)
            if self.cur_random_num == cfg_data.max then
                self.BtnPlus.gameObject:SetActive(false)
            end
        end
    end)

    self.TxtNum = self.MainCon:FindChild("TxtNum"):GetComponent(Text)
    self.TxtNum.text = "0"

    self.BtnPut = self.MainCon:FindChild("BtnPut"):GetComponent(Button)
    self.BtnPut.onClick:AddListener(function()
        if self.my_type == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
            return
        end
        GuildManager.Instance:request11131(self.Item1InputField.textComponent.text, self.cur_random_num, self.my_type, 1)
    end)


    self.TxtGuildMemNum.text = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("本帮成员数量"), self.model.my_guild_data.MemNum + self.model.my_guild_data.FreshNum, TI18N("人"))

    self.MainCon:FindChild("TxtTitle"):GetComponent(Text).color = Color(141/255, 69/255, 31/255)
    self.TxtGuildMemNum.color = Color(141/255, 69/255, 31/255)
    self.MainCon:FindChild("TxtDesc"):GetComponent(Text).color = Color(141/255, 69/255, 31/255)
end


--更新选中的发送数量
function GuildRedBagSetWindow:update_send_info(_type)
    self.my_type = _type
    local cfg_data = DataGuild.data_get_redbag_data[_type]
    self.Item2TxtNum.text = tostring(cfg_data.amount)
    self:on_random_num()
    self.TxtNum.text = tostring(cfg_data.amount)
end

--随机个数量出来
function GuildRedBagSetWindow:on_random_num()
    if self.my_type == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择红包金额"))
        return
    end

    local cfg_data = DataGuild.data_get_redbag_data[self.my_type]
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


