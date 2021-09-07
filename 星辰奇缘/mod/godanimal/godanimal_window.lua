-- @author zgs
GodAnimalWindow = GodAnimalWindow or BaseClass(BaseWindow)

function GodAnimalWindow:__init(model)
    self.model = model
    self.name = "GodAnimalWindow"

    self.showType = 1 -- 显示类型： 神兽=1，精灵龙冰凤凰=2，珍兽=3
    self.selectIndex = 1

    self.lastItemDic = nil
    self.slotList = {}
    self.skillList = {}

    self.skillItemDic = {}
    self.headLoaderList = {}
    self.iconIdList =
    {
        [1] = 20004,
        [2] = 20006,
        [3] = 20002,
    }
    self.tabTextList = {
        [GodAnimalManager.Instance.SHOWTYPE_GOD] = TI18N("神兽"),
        [GodAnimalManager.Instance.SHOWTYPE_DRAGON] = TI18N("精灵兽"),
        [GodAnimalManager.Instance.SHOWTYPE_JANE] = TI18N("珍兽")
    }

    self.resList = {
        {file = AssetConfig.godanimal_window, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
        --[[
        ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.shop_textures, type = AssetType.Dep}
        --]]
    }

    self.updateListener = function() if self.selectIndex ~= nil then self:UpdateWindow() end end

    self.OnOpenEvent:AddListener(function()
        -- self.showType = self.openArgs[1]
        -- self:UpdateWindow()
        self.tabGroup:ChangeTab(self.openArgs[1])

    end)
end

function GodAnimalWindow:OnInitCompleted()
    -- self.showType = self.openArgs[1]
    -- self:UpdateWindow()
    self.tabGroup:ChangeTab(self.openArgs[1])
end

function GodAnimalWindow:__delete()
    print("GodAnimalWindow:__delete()")
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.getButton ~= nil then
        self.getButton:DeleteMe()
        self.getButton = nil
    end
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.slotList ~= nil then
        for _, slot in pairs(self.slotList) do
            if slot ~= nil then
                slot:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.skillList ~= nil then
        for i,v in pairs(self.skillList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.skillList = nil
    end

    -- self.OnOpenEvent:RemoveAll()
    -- GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    -- self.gameObject = nil
    self.model = nil
end

function GodAnimalWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godanimal_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.titleDesc = self.transform:Find("Main/Title/Text"):GetComponent(Text)

    self.center = self.transform:Find("Main/Content/Center")
    self.godanimalName = self.center:Find("AnimalNameText"):GetComponent(Text) --神兽名字
    self.center:Find("AnimalStandImg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.animalTransParent = self.center:Find("AnimalStandImg/AnimalParent")
    self.nextBtn = self.center:Find("NextButton"):GetComponent(Button)
    self.nextBtn.onClick:AddListener(function()
                self:OnClickNext()
            end)
    self.nextBtnEnable = self.center:Find("NextButton/Enable").gameObject
    self.nextBtnDisable = self.center:Find("NextButton/Disable").gameObject
    self.preBtn = self.center:Find("PreButton"):GetComponent(Button)
    self.preBtn.onClick:AddListener(function()
                self:OnClickPre()
            end)
    self.preBtnEnable = self.center:Find("PreButton/Enable").gameObject
    self.preBtnDisable = self.center:Find("PreButton/Disable").gameObject
    self.preDesc = self.center:Find("AnimalStandImg/Image/Text"):GetComponent(Text)

    self.centerRight = self.center:Find("CenterRight")
    self.skillDesc = self.centerRight:Find("Text"):GetComponent(Text)
    self.talent = self.centerRight:Find("Property1/Value"):GetComponent(Text)
    self.hpTalent = self.centerRight:Find("AttItem1/VText"):GetComponent(Text)
    self.atkTalent = self.centerRight:Find("AttItem2/VText"):GetComponent(Text)
    self.defendTalent = self.centerRight:Find("AttItem3/VText"):GetComponent(Text)
    self.defendMagicTalent = self.centerRight:Find("AttItem4/VText"):GetComponent(Text)
    self.speedTalent = self.centerRight:Find("AttItem5/VText"):GetComponent(Text)

    self.skillParent = self.centerRight:Find("SkillMask/SkillParent")
    self.skillItemClone = self.centerRight:Find("SkillMask/SkillParent/SkillItem")
    self.skillItemClone.gameObject:SetActive(false)
    for i=1, 6 do
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(self.skillParent.gameObject, slot.gameObject)
        table.insert(self.skillItemDic, slot)
    end

    self.bottom = self.transform:Find("Main/Content/Bottom")
    self.bottomImgObj = self.bottom:Find("Image").gameObject
    self.bottomTextTrans = self.bottom:Find("Text")
    self.bottomText = self.bottomTextTrans:GetComponent(Text)
    self.needItemObj = self.bottom:Find("NeedItem").gameObject
    self.needItem = self.bottom:Find("NeedItem/ImageParent")
    self.needCount = self.bottom:Find("NeedItem/CntImage/Text"):GetComponent(Text)
    self.needItemObj2 = self.bottom:Find("NeedItem2").gameObject
    self.needItem2 = self.bottom:Find("NeedItem2/ImageParent")
    self.needCount2 = self.bottom:Find("NeedItem2/CntImage/Text"):GetComponent(Text)
    self.getBtn = self.bottom:Find("GetButton").gameObject
    -- self.getBtn.onClick:AddListener(function()
    --             self:OnClickGetAnimal()
    --         end)
    self.getButton = BuyButton.New(self.getBtn, TI18N("兑 换"))
    self.getButton.key = "GodAnimalExchange"
    self.getButton.protoId = 10524
    self.getButton:Show()

    self.AniParent = self.bottom:Find("AniParent"):GetComponent(ScrollRect)

    self.godAnimalGrid = self.bottom:Find("AniParent/GodGrid").gameObject
    self.godAnimalGridTrans = self.bottom:Find("AniParent/GodGrid"):GetComponent(RectTransform)

    self.godAnimalItem = self.bottom:Find("AniParent/GodGrid/Ani1").gameObject
    self.godAnimalItem:SetActive(false)
    self.allGodAnimalDic = {}

    self.godAnimalDragonGrid = self.bottom:Find("AniParent/GodDragonGrid").gameObject
    self.godAnimalDragonGridTrans = self.bottom:Find("AniParent/GodDragonGrid"):GetComponent(RectTransform)
    self.godAnimalDragonItem = self.bottom:Find("AniParent/GodDragonGrid/Ani1").gameObject
    self.godAnimalDragonItem:SetActive(false)
    self.godAnimalDragonDic = {}

    self.janeAnimalGrid = self.bottom:Find("AniParent/JaneGrid").gameObject
    self.janeAnimalGridTrans = self.bottom:Find("AniParent/JaneGrid"):GetComponent(RectTransform)
    self.janeAnimalItem = self.bottom:Find("AniParent/JaneGrid/Ani1").gameObject
    self.janeAnimalItem:SetActive(false)
    self.allJaneAnimalDic = {}

    self.descText = self.bottom:Find("DescText"):GetComponent(Text)

    self.descButton = self.center:FindChild("DescButton"):GetComponent(Button)
    self.descButton.onClick:AddListener(function() self:showTips() end)

    self:InitAnimal()

    self.tabGroupObj = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject

    for i=1,3 do
         local loaderId = self.tabGroupObj.transform:GetChild(i - 1).transform:Find("Icon").gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(self.tabGroupObj.transform:GetChild(i - 1).transform:Find("Icon").gameObject.gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,self.iconIdList[i])

    end
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 0, 9876},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)
    for i,v in ipairs(self.tabGroup.buttonTab) do
        v.normalTxt.transform.sizeDelta = Vector2(30, 100)
        v.selectTxt.transform.sizeDelta = Vector2(30, 100)
        v.normalTxt.text = self.tabTextList[i]
        v.selectTxt.text = self.tabTextList[i]
    end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)
end

function GodAnimalWindow:TabChange(index)
    -- print(index.."------"..debug.traceback())
    self.showType = index
    self.selectIndex = 1    --界面的第几只宠物
    self:UpdateWindow()
end

function GodAnimalWindow:InitAnimal()
    --
    self.godAnimalLayout = LuaBoxLayout.New(self.godAnimalGrid, {axis = BoxLayoutAxis.X, cspacing = 3,border = 8})
    self.godAnimalDragonLayout = LuaBoxLayout.New(self.godAnimalDragonGrid, {axis = BoxLayoutAxis.X, cspacing = 3,border = 4})
     self.janeAnimalLayout = LuaBoxLayout.New(self.janeAnimalGrid, {axis = BoxLayoutAxis.X, cspacing = 3,border = 8})
    --for i=1,DataPet.data_pet_exchange_length do
    local i = 1
    local j = 1
    local h = 1
    -- if self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
    local DragonPetData = { }
    for i,v in pairs(DataPet.data_pet_exchange_assign) do
        if v ~= nil then table.insert(DragonPetData, v) end
    end
    table.sort(DragonPetData, function(a,b) return a.base_id > b.base_id end )
    -- local DragonPetIdList = {20012, 20010, 20007, 20006, 20005}
    --     for i,j in pairs(DragonPetIdList) do

        for i,v in pairs(DragonPetData) do
            --精灵兽
            local dataTemp = DataPet.data_pet[v.base_id]
            local obj = nil
            if dataTemp.genre == 2 then
                obj = GameObject.Instantiate(self.godAnimalDragonItem)
                obj:SetActive(true)
                obj.name = tostring(h)
                self.godAnimalDragonLayout:AddCell(obj)
            end
            local riObjImage = obj.transform:Find("Image"):GetComponent(Image)

            local loaderId = riObjImage.gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(riObjImage.gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,dataTemp.head_id)
            -- riObjImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(dataTemp.head_id), tostring(dataTemp.head_id))
            local selectImg = obj.transform:Find("SelectedImage").gameObject
            selectImg:SetActive(false)
            obj:GetComponent(Button).onClick:AddListener(function()
                    self:OnClickAnimalHead(tonumber(obj.name))
                end)
            local itemDic = {
                index = h,
                key = DragonPetData[i].base_id,
                petData = dataTemp,
                petDataExchange = v,
                petHeadObj = obj,
                petImage = riObjImage,
                simg = selectImg,
            }
            if dataTemp.genre == 2 then
                self.godAnimalDragonDic[h] = itemDic
                h = h + 1
            end
        end
    -- else
        for k,v in pairs(DataPet.data_pet_exchange) do
            --神兽（genre = 2 ） + 珍兽（genre = 4）
            local dataTemp = DataPet.data_pet[v.base_id]

            local obj = nil
            if dataTemp.genre == 2 then
                if DataPet.data_pet_exchange_assign[v.base_id] ~= nil then
                    ----
                else
                    obj = GameObject.Instantiate(self.godAnimalItem)
                    obj:SetActive(true)
                    obj.name = tostring(i)
                    self.godAnimalLayout:AddCell(obj)
                end
            elseif dataTemp.genre == 4 then
                obj = GameObject.Instantiate(self.janeAnimalItem)
                obj.name = tostring(j)
                self.janeAnimalLayout:AddCell(obj)
            end


            local riObjImage = obj.transform:Find("Image"):GetComponent(Image)
            local loaderId = riObjImage.gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(riObjImage.gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,dataTemp.head_id)

            -- riObjImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(dataTemp.head_id), tostring(dataTemp.head_id))
            local selectImg = obj.transform:Find("SelectedImage").gameObject
            selectImg:SetActive(false)
            obj:GetComponent(Button).onClick:AddListener(function()
                    self:OnClickAnimalHead(tonumber(obj.name))
                end)
            local iTemp = i
            if dataTemp.genre == 4 then
                iTemp = j
            end
            local itemDic = {
                index = iTemp,
                key = k,
                petData = dataTemp,
                petDataExchange = v,
                petHeadObj = obj,
                petImage = riObjImage,
                simg = selectImg,
            }
            if dataTemp.genre == 2 then
                if DataPet.data_pet_exchange_assign[v.base_id] ~= nil then
                    ---
                else
                    self.allGodAnimalDic[i] = itemDic
                    i = i + 1
                end
            elseif dataTemp.genre == 4 then
                self.allJaneAnimalDic[j] = itemDic
                j = j + 1
            end
        end
    -- end
end
--点击头像
function GodAnimalWindow:OnClickAnimalHead(index)
    -- body
    if self.selectIndex ~= index then
        self:UpdateContent(index)
    end
end
--点击后一个
function GodAnimalWindow:OnClickNext()
    -- body
    if self.showType == GodAnimalManager.Instance.SHOWTYPE_GOD then
        if self.selectIndex < #self.allGodAnimalDic then
            self:UpdateContent(self.selectIndex + 1)
        end
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_JANE then
        if self.selectIndex < #self.allJaneAnimalDic then
            self:UpdateContent(self.selectIndex + 1)
        end
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
        if self.selectIndex < #self.godAnimalDragonDic then
            self:UpdateContent(self.selectIndex + 1)
        end
    end

end
--点击前一个
function GodAnimalWindow:OnClickPre()
    -- body
    if self.selectIndex > 1 then
        self:UpdateContent(self.selectIndex - 1)
    end
end
--进入界面时，刷新整个界面
function GodAnimalWindow:UpdateWindow()
    -- body
    self:UpdateDesc()

    self:UpdateContent(self.selectIndex)
end
--刷新界面内容
function GodAnimalWindow:UpdateContent(index)
    -- body
    if self.lastItemDic ~= nil then
        if self.lastItemDic.simg ~= nil then
            self.lastItemDic.simg:SetActive(false)
        end
    end
    local curItemDic
    if self.showType == GodAnimalManager.Instance.SHOWTYPE_GOD then
        if index == 1 then
            self.preBtnEnable:SetActive(false)
            self.preBtnDisable:SetActive(true)
        else
            self.preBtnEnable:SetActive(true)
            self.preBtnDisable:SetActive(false)
        end
        if index == #self.allGodAnimalDic then
            self.nextBtnEnable:SetActive(false)
            self.nextBtnDisable:SetActive(true)
        else
            self.nextBtnEnable:SetActive(true)
            self.nextBtnDisable:SetActive(false)
        end

        -- self.lastItemDic =  self.allGodAnimalDic[self.selectIndex]
        -- lastItemDic.simg:SetActive(false)
        self.AniParent.content = self.godAnimalGridTrans
        self.selectIndex = index
        curItemDic = self.allGodAnimalDic[self.selectIndex]
        self.lastItemDic = curItemDic
        self.bottomText.text = TI18N("兑换所需")
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_JANE then

        if index == 1 then
            self.preBtnEnable:SetActive(false)
            self.preBtnDisable:SetActive(true)
        else
            self.preBtnEnable:SetActive(true)
            self.preBtnDisable:SetActive(false)
        end
        if index == #self.allJaneAnimalDic then
            self.nextBtnEnable:SetActive(false)
            self.nextBtnDisable:SetActive(true)
        else
            self.nextBtnEnable:SetActive(true)
            self.nextBtnDisable:SetActive(false)
        end
        self.AniParent.content = self.janeAnimalGridTrans
        -- self.lastItemDic =  self.allJaneAnimalDic[self.selectIndex]
        -- lastItemDic.simg:SetActive(false)
        self.selectIndex = index
        curItemDic = self.allJaneAnimalDic[self.selectIndex]
        self.lastItemDic = curItemDic
        self.bottomText.text = TI18N("兑换所需")
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
        if index == 1 then
            self.preBtnEnable:SetActive(false)
            self.preBtnDisable:SetActive(false)
        else
            self.preBtnEnable:SetActive(true)
            self.preBtnDisable:SetActive(false)
        end
        if index == #self.godAnimalDragonDic then
            self.nextBtnEnable:SetActive(false)
            self.nextBtnDisable:SetActive(false)
        else
            self.nextBtnEnable:SetActive(true)
            self.nextBtnDisable:SetActive(false)
        end
        self.AniParent.content = self.godAnimalDragonGridTrans
        -- self.lastItemDic =  self.godAnimalDragonDic[self.selectIndex]
        -- lastItemDic.simg:SetActive(false)
        self.selectIndex = index
        curItemDic = self.godAnimalDragonDic[self.selectIndex]
        self.lastItemDic = curItemDic
        self.bottomText.text = TI18N("兑换所需")
        --self.bottomText.text = string.format(TI18N("兑换<color='%s'>%s</color>所需"),ColorHelper.color[5], curItemDic.petData.name)
    end


    curItemDic.simg:SetActive(true)

    self:UpdateAnimal(curItemDic)

    self:UpdateAnimalData(curItemDic)
end

--更换模型
function GodAnimalWindow:UpdateAnimal(itemDic)
    local petData = itemDic.petData
    local data = {type = PreViewType.Pet, skinId = petData.skin_id_0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_0}

    local setting = {
        name = "AnimalView"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.animalTransParent)
        rawImage.transform.localPosition = Vector3(0, 30, 0)
        rawImage.transform.localScale = Vector3(1.2, 1.2, 1.2)
        --rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.previewComposite == nil then
        self.previewComposite = PreviewComposite.New(fun, setting, data)
        --self.previewComposite:BuildCamera()
    else
        self.previewComposite:Reload(data, fun)
    end
end
--右侧数据更新
function GodAnimalWindow:UpdateAnimalData(itemDic)
    -- body
    local petData = itemDic.petData

    self.godanimalName.text = petData.name

    self.talent.text = string.format("%s(%d)",
        PetManager.Instance.model:gettalentclass(itemDic.petDataExchange.talent), itemDic.petDataExchange.talent)

    local percent = 1 --0.8
    self.hpTalent.text = string.format("%d~%d",petData.hp_aptitude * percent,petData.hp_aptitude)
    self.atkTalent.text = string.format("%d~%d",petData.phy_aptitude * percent,petData.phy_aptitude)
    self.defendTalent.text = string.format("%d~%d",petData.pdef_aptitude * percent,petData.pdef_aptitude)
    self.defendMagicTalent.text = string.format("%d~%d",petData.magic_aptitude * percent,petData.magic_aptitude)
    self.speedTalent.text = string.format("%d~%d",petData.aspd_aptitude * percent,petData.aspd_aptitude)

    -- local skills = petData.base_skills
    -- for i,v in ipairs(self.skillItemDic) do
    --     local sk = skills[i]
    --     if sk ~= nil then
    --         v.gameObject:SetActive(true)
    --         if v.childCount > 0 then
    --             if self.skillList[i] ~= nil then
    --                 self.skillList[i]:DeleteMe()
    --                 self.skillList[i] = nil
    --             end
    --             GameObject.Destroy(v:GetChild(0).gameObject)
    --         end
    --         local ss = self.skillList[i]
    --         if ss == nil then
    --             ss = SkillSlot.New()
    --             NumberpadPanel.AddUIChild(v.gameObject, ss.gameObject)
    --             self.skillList[i] = ss
    --         end
    --         ss:SetAll(Skilltype.petskill, DataSkill.data_petSkill[string.format("%s_1", sk[1])])
    --     else
    --         v.gameObject:SetActive(false)
    --     end
    -- end
    self.skillParent.localPosition = Vector2(-160, 0)

    local base_skills = petData.base_skills
    local tempList = {}
    for i = 1, #base_skills do
        tempList[i] = { id = base_skills[i][1] }
    end

    local skills = PetManager.Instance.model:makeBreakSkill(petData.id, tempList)

    for i=1,#skills do
        local skill_id = skills[i].id
        local icon = self.skillItemDic[i]
        icon.gameObject.name = skill_id
        local skill_data = DataSkill.data_petSkill[string.format("%s_1", skill_id)]
        icon:SetAll(Skilltype.petskill, skill_data)
        icon:ShowLabel(skills[i].isBreak, TI18N("<color='#ffff00'>突破</color>"))
        -- icon:ShowBreak(skills[i].isBreak, TI18N("未激活"))
    end

    for i=#skills+1,#self.skillItemDic do
        local icon = self.skillItemDic[i]
        icon.gameObject.name = ""
        icon:Default()
        icon.skillData = nil
    end

    -- if self.needItem.childCount > 0 then
    --     GameObject.Destroy(self.needItem:GetChild(0).gameObject)
    -- end

    -- self.needItemList = self.needItemList or {}

    local slot = self.slotList[1] or ItemSlot.New()
    -- table.insert(self.slotList, slot)
    self.slotList[1] = slot
    local itemdata = ItemData.New()
    local cell = DataItem.data_get[itemDic.petDataExchange.cost[1][1]]
    itemdata:SetBase(cell)
    slot:SetAll(itemdata, {inbag = false, nobutton = false})
    NumberpadPanel.AddUIChild(self.needItem.gameObject, slot.gameObject)

    local num = BackpackManager.Instance:GetItemCount(itemDic.petDataExchange.cost[1][1])
    local need = itemDic.petDataExchange.cost[1][2]
    local color = (num < need) and ColorHelper.color[4] or  ColorHelper.color[1]
    self.needCount.text = string.format("<color='%s'>%s</color>/%s", color, num, need)

    if #itemDic.petDataExchange.cost == 1 then
        local baseidToNeed = {[itemDic.petDataExchange.cost[1][1]] = {need = itemDic.petDataExchange.cost[1][2]}}
        self.getButton:Layout(baseidToNeed, function ()
            -- body
            self:OnClickGetAnimal()
        end)

        self.needItemObj2:SetActive(false)

        if CampaignManager.Instance.campaignTab[73] ~= nil then
            self.bottomImgObj:SetActive(true)
            self.bottomImgObj.transform.anchoredPosition = Vector2(42.2, -13)
            self.bottomTextTrans.anchoredPosition = Vector2(-36.3, 15.3)

            if self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
                self.bottomImgObj:SetActive(false)
            end
        else
            self.bottomImgObj:SetActive(false)
            self.bottomTextTrans.anchoredPosition = Vector2(-36.3, 3)
        end

        self.needItemObj.transform.anchoredPosition = Vector2(189, 3)
    else
        -- if self.needItem2.childCount > 0 then
        --     GameObject.Destroy(self.needItem2:GetChild(0).gameObject)
        -- end

        self.needItemObj2:SetActive(true)

        local slot = self.slotList[2] or ItemSlot.New()
        -- table.insert(self.slotList, slot)
        self.slotList[2] = slot
        local itemdata = ItemData.New()
        local cell = DataItem.data_get[itemDic.petDataExchange.cost[2][1]]
        itemdata:SetBase(cell)

        slot:SetAll(itemdata, {inbag = false, nobutton = false})
        NumberpadPanel.AddUIChild(self.needItem2.gameObject, slot.gameObject)

        local num2 = BackpackManager.Instance:GetItemCount(itemDic.petDataExchange.cost[2][1])
        local need2 = itemDic.petDataExchange.cost[2][2]
        local color2 = (num2 < need2) and ColorHelper.color[4] or  ColorHelper.color[1]
        self.needCount2.text = string.format("<color='%s'>%s</color>/%s", color2, num2, need2)

        if CampaignManager.Instance.campaignTab[73] ~= nil then
            self.bottomImgObj:SetActive(true)
            self.bottomImgObj.transform.anchoredPosition = Vector2(-13, -13)
            self.bottomTextTrans.anchoredPosition = Vector2(-92, 15.3)

            if self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
                self.bottomImgObj:SetActive(false)
            end
        else
            self.bottomImgObj:SetActive(false)
            self.bottomTextTrans.anchoredPosition = Vector2(-92, 3)
        end

        self.needItemObj.transform.anchoredPosition = Vector2(133, 3)

        local baseidToNeed = {[itemDic.petDataExchange.cost[1][1]] = {need = itemDic.petDataExchange.cost[1][2]}, [itemDic.petDataExchange.cost[2][1]] = {need = itemDic.petDataExchange.cost[2][2]}}
        self.getButton:Layout(baseidToNeed, function ()
            -- body
            self:OnClickGetAnimal()
        end)
    end
end
--更新描述（神兽或者是珍兽 界面）
function GodAnimalWindow:UpdateDesc()
    -- body
    if self.showType == GodAnimalManager.Instance.SHOWTYPE_GOD then
        self.titleDesc.text = TI18N("兑换神兽")
        self.preDesc.text = TI18N("神兽预览")
        self.skillDesc.text = TI18N("神兽技能")
        self.descText.text = TI18N("随机获得一只神兽")
        self.godAnimalGrid:SetActive(true)
        self.godAnimalDragonGrid:SetActive(false)
        self.janeAnimalGrid:SetActive(false)
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
        self.titleDesc.text = TI18N("兑换神兽")
        self.preDesc.text = TI18N("神兽预览")
        self.skillDesc.text = TI18N("神兽技能")
        self.descText.text = ""
        self.godAnimalGrid:SetActive(false)
        self.godAnimalDragonGrid:SetActive(true)
        self.janeAnimalGrid:SetActive(false)
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_JANE then
        self.titleDesc.text = TI18N("兑换珍兽")
        self.preDesc.text = TI18N("珍兽预览")
        self.skillDesc.text = TI18N("珍兽技能")
        self.descText.text = TI18N("随机获得一只珍兽")
        self.godAnimalGrid:SetActive(false)
        self.godAnimalDragonGrid:SetActive(false)
        self.janeAnimalGrid:SetActive(true)
    end
end
--领取
function GodAnimalWindow:OnClickGetAnimal()
    print("GodAnimalWindow:OnClickGetAnimal()")
    -- body
    local roledata = RoleManager.Instance.RoleData
    local gold = roledata:GetMyAssetById(KvData.assets.gold)
    if self.getButton.money > gold then
        NoticeManager.Instance:FloatTipsByString(TI18N("你没有足够的道具，无法进行兑换"))
    else
        if self.showType == GodAnimalManager.Instance.SHOWTYPE_GOD then
            GodAnimalManager.Instance:send10524(2)
        elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_JANE then
             GodAnimalManager.Instance:send10524(4)
        elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
            local cost = self.godAnimalDragonDic[self.selectIndex].petDataExchange.cost
            local mark = false
            for key, value in ipairs(cost) do
                local countTemp = BackpackManager.Instance:GetItemCount(value[1])
                if countTemp < value[2] then
                    mark = true
                    break
                end
            end
            if mark then
                local petName = DataPet.data_pet[self.godAnimalDragonDic[self.selectIndex].petDataExchange.base_id].name
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s只在<color='#ffff00'>特殊活动</color>中少量出现，如若有缘相遇不要错过哦{face_1,22}"), petName))
            else
                GodAnimalManager.Instance:send10545(self.godAnimalDragonDic[self.selectIndex].petDataExchange.base_id)
            end
        end
    end
end

function GodAnimalWindow:OnClickClose()
    self.model:CloseMain()
end

function GodAnimalWindow:showTips()
    if self.showType == GodAnimalManager.Instance.SHOWTYPE_GOD or self.showType == GodAnimalManager.Instance.SHOWTYPE_DRAGON then
        TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject
            , itemData = { TI18N("神兽天赋：进阶可获得全资质提升<color='#00ff00'>+30</color>") }})
    elseif self.showType == GodAnimalManager.Instance.SHOWTYPE_JANE then
        TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject
            , itemData = { TI18N("珍兽天赋：进阶可获得全资质提升<color='#00ff00'>+30</color>") }})
    end
end
