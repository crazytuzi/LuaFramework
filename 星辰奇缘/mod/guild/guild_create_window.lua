GuildCreateWindow  =  GuildCreateWindow or BaseClass(BaseWindow)

function GuildCreateWindow:__init(model)
    self.name  =  "GuildCreateWindow"
    self.model  =  model

    self.windowId = WindowConfig.WinID.guildcreatewindow

    self.resList  =  {
        {file  =  AssetConfig.guild_create_win, type  =  AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.font, type = AssetType.Dep}
    }
    self.effect  =  nil
    self.fps  =  nil
    self.timerId  =  0

    self.purposeText = {
         TI18N("我们不畏惧一切艰难.因为我们身边依然有我们的兄弟.")
        , TI18N("没有永远的游戏，只有永远的朋友。")
        , TI18N("让我们歃血为盟，让我们同甘共苦，让我们肝胆相照，让我们荣辱与共……")
        , TI18N("让我们的身体，流淌勇者的血液，让我们的灵魂，接受战斗的洗礼……")
        , TI18N("让我们一起，实现这个美丽的梦想!")
        , TI18N("请不要错过，你生命中注定永恒的朋友，请不要错过，你岁月里注定属于你的荣誉;")
        , TI18N("让我们疯狂的游戏,疯狂的度过这热血的青春。")
        , TI18N("这里是讲义气,重情理,识大体,有人品的chengren玩家!")
        , TI18N("这里有你梦寐以求的歃血为盟的战友,这里有你苦寻不到的同甘共苦的朋友!")
        , TI18N("让我们的身体,流淌勇者的鲜血,让我们的灵魂,接受圣灵的洗礼,让我们一起,书写辉煌!")
        , TI18N("我们是一个拥有共同目标而走到一起的大家庭。")
        , TI18N("希望大家用我们无限的爱心和努力来让这个温暖的大家庭茁壮成长!")
        , TI18N("大家离去时请记住曾欢笑的我们。")
        , TI18N("你似行云我如风,来去无心皆作尘。")
        , TI18N("惟愿长忆双宿曾,不遗与君双飞痕。")
        , TI18N("只有我们不要的人，没有不要我们的人。")
        , TI18N("好兄弟。同天下。戰八方。游四海。")
        , TI18N("大家有福同享,大碗喝酒,大口吃肉,大称分银.")
        , TI18N("俺们勒噶都是星辰人，俺们那嘎达都是活累疯。")
        , TI18N("我们不能玩一辈子的游戏,但能做一辈子的朋友!")
        , TI18N("朋友们，赶紧做公会任务，赶快升级吧，因为只有我们站的更高，才可以看的更远。")
        , TI18N("大家一定要用马列思想武装自己，灵活运用三个代表，熟练背诵八荣八耻，为建设社会主义新公会而努力奋斗。")
    }
    return self
end


function GuildCreateWindow:__delete()
    self.is_open  =  false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildCreateWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_create_win))
    self.gameObject.name  =  "guild_create_win"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.main_con = self.gameObject.transform:FindChild("MainCon").gameObject
    self.guild_name_con = self.main_con.transform:FindChild("GuildNameCon").gameObject
    self.name_input = self.guild_name_con.transform:FindChild("NameInput"):GetComponent(InputField)
    self.name_input.textComponent  =  self.name_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.name_input.placeholder  =  self.name_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.guild_purpose = self.main_con.transform:FindChild("GuildPurpose").gameObject
    self.purpose_input = self.guild_purpose.transform:FindChild("InputCon"):FindChild("PurposeInput"):GetComponent(InputField)
    self.purpose_input.textComponent  =  self.purpose_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.purpose_input.placeholder  =  self.purpose_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    -- self.name_input.characterLimit  =  5
    self.purpose_input.characterLimit  =  50

    self.btn_cancel  =  self.main_con.transform:FindChild("BtnCancel"):GetComponent(Button)
    self.btn_create = self.main_con.transform:FindChild("BtnCreate"):GetComponent(Button)
    self.btn_create.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("<color='#906014'>500</color>      创建")

    self.btn_sezi = self.guild_name_con.transform:FindChild("BtnSeZi"):GetComponent(Button)
    self.btn_sezi.transform:GetComponent(Button).onClick:AddListener(function()
        self:on_build_random_name(self.btn_sezi) end)

    local cancel_click  =  function()
        self:on_click_btn(self.btn_cancel)
    end
    local create_click  =  function()
        self:on_click_btn(self.btn_create)
    end
    self.btn_cancel.onClick:AddListener(cancel_click)
    self.btn_create.onClick:AddListener(create_click)

    self.is_open  =  true

    local purposeTextIndex = math.floor(Random.Range(1, #self.purposeText))
    self.purpose_input.text = self.purposeText[purposeTextIndex]

    local itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.main_con.transform:Find("Item").gameObject, itemSolt.gameObject)
    local itembase = BackpackManager.Instance:GetItemBase(70053)
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemSolt:SetAll(itemData)
    itemSolt:ShowBg(false)
    self.main_con.transform:Find("Item/Text"):GetComponent(Text).text = itemData.name
    self.main_con.transform:Find("Item/Text").gameObject:SetActive(true)

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

function GuildCreateWindow:on_click_btn(btn)
    if btn == self.btn_create then
        local purp = self.purpose_input.text
        if purp == "" then
            -- purp = "招收各职业成员，公会战勇夺第一！"
            NoticeManager.Instance:FloatTipsByString(TI18N("公会宗旨是立会之本，请先填写"))
            return
        end
        GuildManager.Instance:request11103(self.name_input.text, purp)
    elseif btn == self.btn_cancel then
        self.model:InitFindUI()
    end
end

function GuildCreateWindow:on_build_random_name()
    self.name_input.text = self:get_random_name()
    -- self.name_input.textComponent.color = Color(199/255, 249/255, 255/255)
end

function GuildCreateWindow:get_random_name()
    local first_name_index = Random.Range(1,  DataRandomName.data_create_guild_random_name_length)
    first_name_index = math.floor(first_name_index)
    local sec_name_index = Random.Range(1, DataRandomName.data_create_guild_random_name_length)
    sec_name_index = math.floor(sec_name_index)
    local first_name = DataRandomName.data_create_guild_random_name[first_name_index].front
    local sec_name = DataRandomName.data_create_guild_random_name[sec_name_index].back

    return string.format("%s%s", first_name, sec_name)
end