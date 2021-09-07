--称号
BackPackHonorItem = BackPackHonorItem or BaseClass()

function BackPackHonorItem:__init(gameObject, parent, model)
    self.gameObject = gameObject
    self.data = nil
    self.args = args
    self.model = model
    self.parent = parent
    self.transform = self.gameObject.transform

    self.selectBg = self.transform:Find("ImgBg").gameObject
    self.ImgChenHao = self.transform:Find("ImgChenHao"):GetComponent(Image)
    self.TxtChenHao = self.transform:Find("TxtChenHao"):GetComponent(Text)
    self.ImgChenHao.gameObject:SetActive(false)
    self.TxtChenHao.gameObject:SetActive(false)
    self.Txt_desc1 = self.transform:Find("Txt_desc1"):GetComponent(Text)
    self.Txt_desc2 = self.transform:Find("Txt_desc2"):GetComponent(Text)
    self.Imgusing = self.transform:Find("Imgusing").gameObject
    self.Imgusing:SetActive(false)
    self.Txt_using = self.transform:Find("Txt_using"):GetComponent(Text)
    self.Txt_using2 = self.transform:Find("Txt_using2"):GetComponent(Text)
    self.btn = self.transform:GetComponent(Button)
    self.BtnUp = self.transform:Find("BtnUp"):GetComponent(Button)
    self.ImgUp = self.transform:Find("BtnUp/Image"):GetComponent(Image)
    self.BtnUp.onClick:AddListener(
    function ()
        self:ShowTips();
    end)
    if self.transform:Find("Select") ~= nil then
        self.select = self.transform:Find("Select").gameObject
    end

    self.clickCallback = function() self:on_click_honor(self.data) end

    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function BackPackHonorItem:Release()
    self.btn.onClick:RemoveAllListeners()
    self.clickCallback = nil
end

function BackPackHonorItem:__delete()
    self:Release()
end

function BackPackHonorItem:InitPanel(_data)
    self.data = _data.data

    self:Update()
end

function BackPackHonorItem:Refresh(args)
    self.args = args

    self:Update()
end

function BackPackHonorItem:Update()
    if self.data.res_id ~= 0 then
        self.ImgChenHao.gameObject:SetActive(true)
        self.TxtChenHao.gameObject:SetActive(false)
        self.ImgChenHao.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img,tostring(self.data.res_id))
        self.ImgChenHao:SetNativeSize()
    else
        self.ImgChenHao.gameObject:SetActive(false)
        self.TxtChenHao.gameObject:SetActive(true)

        local honor_name = ""
        if self.data.type == 3 then
            -- honor_name = string.format("%s%s%s", GuildManager.Instance.model.my_guild_data.Name, TI18N("的"), self.data.name)
            local guildName = ""
            if GuildManager.Instance.model.my_guild_data ~= nil then
                guildName = GuildManager.Instance.model.my_guild_data.Name
            end
            honor_name = string.format("%s%s", guildName, self.data.name)
        elseif self.data.type == 7 then
            if TeacherManager.Instance.model.myTeacherInfo.name ~= "" then
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, self.data.name)
            elseif TeacherManager.Instance.model.myTeacherInfo.status == 3 then     -- 师傅
                honor_name = self.data.name
            elseif TeacherManager.Instance.model.myTeacherInfo.status ~= 0 then -- 徒弟或者已出师
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, self.data.name)
            end
        elseif self.data.type == 10 then
            if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn then
                honor_name = string.format(TI18N("%s之%s%s"), SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.rankList[SwornManager.Instance.model.myPos], SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
            end
        else
            honor_name = self.data.name
        end
        self.data.final_name = honor_name
        self.TxtChenHao.text = honor_name
    end
    local strlist = StringHelper.ConvertStringTable(self.data.cond_desc)
    if #strlist > 20 then
        self.Txt_desc1.text = string.format("%s...", table.concat(strlist, "", 1, 20))
    else
        self.Txt_desc1.text = self.data.cond_desc
    end

    local str = ""
    for i=1, #self.data.attr_list do
        local da = self.data.attr_list[i]
        if da.name >= 51 and da.name<= 62 then
            str = string.format("%s%s+%s%s", str, KvData.attr_name[da.name], da.val, "%")
        else
            str = string.format("%s%s+%s", str, KvData.attr_name[da.name], da.val)
        end
    end
    self.Txt_desc2.text = str


    local isUse = false;
    if self.data.id == HonorManager.Instance.model.current_honor_id then
        self.Imgusing:SetActive(true)
        self.Txt_using.text = TI18N("使用中")
        self.Txt_using.color = Color(0.549, 0.913, 0.165, 1)
        isUse = true
    else
        self.Imgusing:SetActive(false)
        self.Txt_using.text = ""
    end
    self.BtnUp.gameObject:SetActive(#self.data.attr_list > 0 and not isUse)

    if self.data.has then
        -- self.transform:GetComponent(Image).color = Color.white
        self.TxtChenHao.color = Color(0.764, 0.176, 0.98, 1)
        self.ImgUp.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.res_honor,"tips2")
    else
        -- self.transform:GetComponent(Image).color = Color.grey
        self.TxtChenHao.color = Color.grey
        self.ImgUp.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.res_honor,"tips1")
        self.Txt_using.text = TI18N("未获得")
        self.Txt_using.color = Color(0.925, 0.369, 0.192, 1)
    end

    if DataHonor.data_get_honor_list[self.data.id].is_can_pre == 0 then
        self.Txt_using2.gameObject:SetActive(false)
    elseif DataHonor.data_get_honor_list[self.data.id].is_can_pre == 1 then
        self.Txt_using2.gameObject:SetActive(true)
    end
    self.gameObject.name = self.data.i
end

function BackPackHonorItem:ShowTips()
    local TipsData;
    local str = "附加属性："
    local isExt = false;
    for _, attr in pairs(self.data.attr_list)  do
        isExt = true
        if attr.name >= 51 and attr.name <= 62 then
            str = string.format("%s%s+%s%s", str, KvData.attr_name[attr.name], attr.val, "%").."，"
        else
            str = string.format("%s%s+%s", str, KvData.attr_name[attr.name], attr.val).."，"
        end
    end
    local len = string.len(str);
    if isExt then
        str = string.sub(str, 1, len - 1)
     else
        str = "附加属性：无"
    end
    local TipsData = {
        str
        ,TI18N("获得称号时属性即可生效")
        };
    TipsManager.Instance:ShowText( { gameObject = self.BtnUp.gameObject, itemData = TipsData })
end

function BackPackHonorItem:on_click_honor()
    -- mod_tips.honor_tips(self.data)
    -- self.args.onClick(self)
    HonorManager.Instance.model.current_data = self.data
    HonorManager.Instance.model:InitMainUI()
end

function BackPackHonorItem:update_my_self(data)
    self:InitPanel({data = data})
    if self.select ~= nil then
        if data.id == self.model.lastHonorId then
            self.select:SetActive(true)
        else
            self.select:SetActive(false)
        end
    end
end

function BackPackHonorItem:OnClick()
    if self.model.lastHonorSelect ~= nil then
        self.model.lastHonorSelect:SetActive(false)
    end
    if self.select ~= nil then
        self.select:SetActive(true)
        self.model.lastHonorId = self.data.id
        self.model.lastHonorSelect = self.select
    end
    if self.clickCallback ~= nil then
        self.clickCallback(self.data)
    end
end
