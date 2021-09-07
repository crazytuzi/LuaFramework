-- ----------------------------------------------------------
-- UI - 宠物窗口 头像栏
-- ----------------------------------------------------------
PetView_HeadBar = PetView_HeadBar or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetView_HeadBar:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetView_HeadBar"
    self.resList = {
        {file = AssetConfig.pet_window_headbar, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.is_show = false

    self.container = nil
    self.headobject = nil
    self.scrollrect = nil

    self.headlist = {}
    self.headLoaderList = {}

    self.isshow = false
    self.petnum_max = 0
    self.updatepethead_mark = false

    ------------------------------------------------
    self._updatepethead = function() self:updatepethead() end
    self._selectPet = function(baseid) self:selectPetByBaseId(baseid) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetView_HeadBar:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_window_headbar))
    self.gameObject.name = "PetView_HeadBar"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    self.headBarRectTransform = self.transform:FindChild("HeadBar"):GetComponent(RectTransform)
    self.container = self.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.headobject = self.container.transform:FindChild("PetHead").gameObject

    self.scrollrect = self.transform:FindChild("HeadBar/mask"):GetComponent(ScrollRect)

    self.toggle = self.transform:FindChild("Toggle"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener(function(on) self:OnToggleChange(on) end)

    self.tabGroupObj = self.transform:FindChild("TabButtonGroup").gameObject
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, { notAutoSelect = true })

    for k,v in pairs(DataPet.data_add_pet_nums) do
        if v.pet_nums > self.petnum_max then
            self.petnum_max = v.pet_nums
        end
    end

    ----------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetView_HeadBar:__delete()
    self:OnHide()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetView_HeadBar:OnShow()
    if RoleManager.Instance.RoleData.lev >= 75 then
        self.toggle.isOn = self.model.headbarToggleOn
        self.tabGroup:ChangeTab(self.model.headbarTabIndex)

        self.tabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.model.headbarTabIndex = 1

        self.tabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end

	if self.is_show == false then
		self:addevents()
        self:updatepethead()
    else
        if #self.model:GetAttachPetList() > 0  then
            self.tabGroupObj:SetActive(true)
            self.headBarRectTransform.sizeDelta = Vector2(246, 415)
        else
            self.tabGroupObj:SetActive(false)
            self.headBarRectTransform.sizeDelta = Vector2(246, 450)
        end
	end
	self.is_show = true

    if self.parent.openArgs ~= nil and #self.parent.openArgs > 2 then
        self:selectPetByBaseId(self.parent.openArgs[3])
        self.parent.openArgs[3] =nil
    end
end

function PetView_HeadBar:OnHide()
	self.is_show = false
    self:removeevents()
end

function PetView_HeadBar:addevents()
    PetManager.Instance.OnUpdatePetList:Add(self._updatepethead)
    PetManager.Instance.OnSelectPet:Add(self._selectPet)
end

function PetView_HeadBar:removeevents()
    PetManager.Instance.OnUpdatePetList:Remove(self._updatepethead)
    PetManager.Instance.OnSelectPet:Remove(self._selectPet)
end


function PetView_HeadBar:updatepethead()
    local isSelect = false
    self.model:sort_petlist()
    local petlist = self.model.petlist
    local headnum = self.model.pet_nums
    local headlist = self.headlist
    local headobject = self.headobject
    local container = self.container
    local data
    -- if not self.toggle.isOn then
    if self.model.headbarTabIndex == 1 then
        petlist = self.model:GetMasterPetList()
    else
        petlist = self.model:GetAttachPetList()

        if #petlist == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有附灵宠物"))
            self.tabGroup:ChangeTab(1)
            return
        end
    end

    if #self.model:GetAttachPetList() > 0  then
        self.tabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.tabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end

    local selectBtn = nil
    for i = 1, #petlist do
        data = petlist[i]
        local headitem = headlist[i]

        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[i] = item
            headitem = item
        end

        headitem:SetActive(true)
        headitem.name = tostring(data.id)

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = data.name
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("等级：%s"), data.lev)
        headitem.transform:FindChild("Using").gameObject:SetActive(data.status == 1)
        headitem.transform:FindChild("Attach").gameObject:SetActive(data.master_pet_id ~= 0 or data.spirit_child_flag == 1)
        -- headitem.transform:FindChild("Possess").gameObject:SetActive(data.possess_pos > 0)
        local headId = tostring(data.base.head_id)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)

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
        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
            = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:onheaditemclick(headitem) end)

        if #data.attach_pet_ids > 0 then
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
            local attach_pet_id = data.attach_pet_ids[1]
            local attach_pet_data = self.model:getpet_byid(attach_pet_id)
            local headId = tostring(attach_pet_data.base.head_id)
            local loaderId = headitem.gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(headitem.transform:FindChild("AttachHeadIcon/Image").gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
            -- headitem.transform:FindChild("AttachHeadIcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        else
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
        end



        local isGuidePetAddPoint = false
        local myData = DataQuest.data_get[41800]
        local questData = QuestManager.Instance:GetQuest(myData.id)
        if questData ~= nil and questData.finish == 1 then
            isGuidePetAddPoint = true
        end
        if isGuidePetAddPoint == true then
            if data.point > 0 and isSelect == false then
                selectBtn = headitem
                isSelect = true
            end
        else
            if self.model.cur_petdata ~= nil and self.model.cur_petdata.id == data.id then selectBtn = headitem end
        end
    end

    if not self.toggle.isOn then

        for i = #petlist + 1, self.model.pet_nums do
            local headitem = headlist[i]
            if headitem == nil then
                local item = GameObject.Instantiate(headobject)
                item.transform:SetParent(container.transform)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                headlist[i] = item
                headitem = item
            end

            headitem:SetActive(true)
            headitem.name = "lock"

            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("Using").gameObject:SetActive(false)
            headitem.transform:FindChild("Attach").gameObject:SetActive(false)
            headitem.transform:FindChild("Possess").gameObject:SetActive(false)

            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
            local loaderId = headImage.gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
            end
            self.headLoaderList[loaderId]:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage"))
            -- headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
            -- headImage:SetNativeSize()
            headImage.rectTransform.sizeDelta = Vector2(32, 36)
            -- headImage.gameObject:SetActive(true)

            headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
                = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")

            local button = headitem:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onheadaddclick(headitem) end)

            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

            if self.model.headbarTabIndex == 1 then
                headitem:SetActive(true)
            else
                headitem:SetActive(false)
            end
        end
    end

    if self.petnum_max > self.model.pet_nums then
        local headitem = headlist[self.model.pet_nums + 1]
        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[self.model.pet_nums + 1] = item
            headitem = item
        end

        headitem:SetActive(true)
        headitem.name = "lock"

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("Using").gameObject:SetActive(false)
        headitem.transform:FindChild("Attach").gameObject:SetActive(false)
        headitem.transform:FindChild("Possess").gameObject:SetActive(false)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
        headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock")
        -- headImage:SetNativeSize()
        headImage.rectTransform.sizeDelta = Vector2(36, 40)
        -- headImage.gameObject:SetActive(true)

        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
             = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:onheadlockclick(headitem) end)

        headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

        if self.model.headbarTabIndex == 1 then
            headitem:SetActive(true)
        else
            headitem:SetActive(false)
        end
    end

    for i = self.model.pet_nums + 2, #headlist do
        headlist[i]:SetActive(false)
    end

    if #petlist > 0 then
        if selectBtn == nil then
            self:onheaditemclick(headlist[1])
        else
            self:onheaditemclick(selectBtn)
        end
    end

    if self.parent.guideScript ~= nil and self.parent.guideScript.gameObject ~= nil and not PetManager.Instance.isWash and not self.parent.canUpdateHead then
        -- if self.model.cur_petdata.base_id ~= 10003 or (self.model.cur_petdata.base_id == 10003 and self.model.cur_petdata.status == 1) then
            -- 不按步骤，干掉,重来
            self.parent.guideScript:DeleteMe()
            self.parent.guideScript = nil
            self.parent:CheckGuide()
        -- end
    end
end

function PetView_HeadBar:onheaditemclick(item)
    self.model.cur_petdata = self.model:getpet_byid(tonumber(item.name))
    self.parent:SelectPet()  --更新对应的childTab  如viewpanel  washpanel

    local head
    for i = 1, #self.headlist do
        head = self.headlist[i]
        head.transform:FindChild("Select").gameObject:SetActive(false)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    self.parent:CheckGuidePoint()
end

function PetView_HeadBar:onheadaddclick()
    self.parent:CloseAllTips()

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你是否要前往宠物图鉴查看可携带宠物？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self.parent.tabGroup:ChangeTab(self.parent.childIndex.manual)  end
    NoticeManager.Instance:ConfirmTips(data)
end

function PetView_HeadBar:onheadlockclick(item)
    self.parent:CloseAllTips()

    local itembase = BackpackManager.Instance:GetItemBase(DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_id)

    local str = string.format(TI18N("是否消耗%s%s开启宠物栏？")
        , DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_val
        , ColorHelper.color_item_name(itembase.quality, itembase.name))

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() PetManager.Instance:Send10523()  end
    NoticeManager.Instance:ConfirmTips(data)
end

function PetView_HeadBar:selectPetByBaseId(base_id)
    print("selectPetByBaseId  "..base_id)
    -- local petlist = self.model.petlist
    local petlist = self.model:GetMasterPetList()
    local headlist = self.headlist
    for i = 1, #petlist do
        local data = petlist[i]
        if data.base_id == base_id then
            local headitem = headlist[i]
            if headitem ~= nil then
                self:onheaditemclick(headitem)
            end
        end

    end
end

function PetView_HeadBar:selectPetObjByBaseId(base_id)
    -- local petlist = self.model.petlist
    local petlist = self.model:GetMasterPetList()
    local headlist = self.headlist
    for i = 1, #petlist do
        local data = petlist[i]
        if data.base_id == base_id then
            local headitem = headlist[i]
            if headitem ~= nil then
                return headitem
            end
        end
    end
end

function PetView_HeadBar:OnToggleChange(on)
    self.model.headbarToggleOn = on
    self:updatepethead()
end

function PetView_HeadBar:ChangeTab(index)
    self.model.headbarTabIndex = index
    self:updatepethead()
end