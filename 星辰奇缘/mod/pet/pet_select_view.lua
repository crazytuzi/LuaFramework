PetSelectView = PetSelectView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function PetSelectView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.petselect
    self.name = "PetSelectView"
    self.resList = {
        {file = AssetConfig.selectpetwindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.Layout = nil
    self.CopyItem = nil

    -- 2:坐骑契约
    self.type = 1
    self.okbutton_callBack = nil
    self.callBack = nil

    self.headLoaderList = {}
    self.exceptionList = {} -- 例外列表, id
    self.tipsArgs = nil -- 没有可选宠物时的提示， text 提示语 callback 点击回调
    -----------------------------------------
    self.select_item = nil
    self.select_data = nil
end

function PetSelectView:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self:ClearDepAsset()
end

function PetSelectView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.selectpetwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CopyItem = self.transform:Find("Main/mask/Item").gameObject
    self.CopyItem:SetActive(false)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = nil
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/mask")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("Main/mask/ItemContainer"), setting)

    self.transform:Find("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OkButtonClick() end)

    self.tipsText = self.transform:Find("Main/TipsText"):GetComponent(Text)

    self.battle_pet = nil
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.callBack = self.openArgs[1] -- 点击回调
        if #self.openArgs > 1 then
            self.okbutton_callBack = self.openArgs[2] -- 点击确定按钮回调
            if #self.openArgs > 2 then
                self.type = self.openArgs[3] -- 选择类型
                if #self.openArgs > 3 then
                    self.exceptionList = self.openArgs[4] -- 排除列表
                    if #self.openArgs > 4 then
                        self.tipsArgs = self.openArgs[5] -- 列表为空时的提示
                    end
                end
            end
        end


        if self.openArgs.battle_pet ~= nil then
            self.battle_pet = {}
            for k,v in pairs(self.openArgs.battle_pet) do
                 self.battle_pet[k] = v
             end
        end
    end
    self.no_need_master = ((self.openArgs or {}).is_need_master ~= 1)
    self:UpdateList()
end

function PetSelectView:Close()
    self.model:ClosePetSelectWindow()
    -- WindowManager.Instance:CloseWindow(self)
end

function PetSelectView:UpdateList()
    local templist = BaseUtils.copytab(self.model.petlist)
    local list = nil
    if self.no_need_master == true then
        list = {}
        for _,v in ipairs(templist) do
            if v.master_pet_id == 0 then
                table.insert(list, v)
            end
        end
    else
        list = templist
    end
    if self.battle_pet ~= nil then
        for _,v in pairs(list) do
            v.status = 0
            if self.battle_pet[v.id] == nil then
                v.battle_desc = nil
            else
                v.battle_desc = self.battle_pet[v.id]
            end
        end
    end

    if self.type == 2 then
        list = BaseUtils.BubbleSort(list, function(a, b)
            if RideManager.Instance.model.contractPetTab[a.id] ~= nil and RideManager.Instance.model.contractPetTab[b.id] == nil then
                return true
            else
                return false
            end
        end)
    end

    for k,v in ipairs(list) do
        if not table.containValue(self.exceptionList, v.id) then
            local item = GameObject.Instantiate(self.CopyItem)
            self:SetItem(item, v)
            self.Layout:AddCell(item.gameObject)
        end
    end

    self.Layout:ReSize()

    if self.tipsArgs ~= nil then
        if self.tipsArgs.text ~= nil then
            self.tipsText.text = self.tipsArgs.text
        end
        self.tipsText.gameObject:SetActive(#self.Layout.cellList == 0)
    end
end

function PetSelectView:SetItem(item, data)
    local its = item.transform
    local headId = tostring(data.base.head_id)
    local headImage = its.transform:FindChild("Head_78/Head"):GetComponent(Image)

    local loaderId = headImage.gameObject:GetInstanceID()
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
    -- headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
    -- headImage:SetNativeSize()
    headImage.rectTransform.sizeDelta = Vector2(54, 54)
    -- headImage.gameObject:SetActive(true)

    local headbg = self.model:get_petheadbg(data)
    its.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
        = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

    its:Find("LVText"):GetComponent(Text).text = string.format(TI18N("等级:%s"), data.lev)
    its:Find("NameText"):GetComponent(Text).text = data.name

    its.transform:FindChild("Using").gameObject:SetActive(data.status == 1)

    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function() self:OnClickItem(item, data) end)

    its:Find("Desc"):GetComponent(Text).text = ""
    if self.type == 2 then
        -- 这宠物契约了坐骑
        if RideManager.Instance.model.contractPetTab[data.id] ~= nil then
            its:Find("Desc").gameObject:SetActive(true)
            its:Find("Desc"):GetComponent(Text).text = TI18N("已契约")
        end
    end

    its:Find("Desc").gameObject:SetActive(false)
    if data.battle_desc ~= nil then
        local desc = its:Find("Desc"):GetComponent(Text).text
        if desc ~= "" and desc ~= nil then
            desc = desc .. "\n" .. data.battle_desc
        else
            desc = data.battle_desc
        end
        its:Find("Desc"):GetComponent(Text).text = desc
        its:Find("Desc").gameObject:SetActive(true)
    end
end

function PetSelectView:OnClickItem(item, data)
    self.callBack(data, self.transform)
    if self.okbutton_callBack == nil then
        self:Close()
    else
        if self.select_item ~= nil then
            self.select_item.transform:FindChild("Select").gameObject:SetActive(false)
        end
        self.select_item = item
        self.select_data = data
        self.select_item.transform:FindChild("Select").gameObject:SetActive(true)
    end
end

function PetSelectView:OkButtonClick()
    if self.okbutton_callBack == nil then
        self:Close()
    else
        self.okbutton_callBack(self.select_data)
        self:Close()
    end
end