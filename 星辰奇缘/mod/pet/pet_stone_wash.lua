PetStoneWash  =  PetStoneWash or BaseClass(BasePanel)

function PetStoneWash:__init(model)
    self.name  =  "PetStoneWash"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.pet_stone_wash_panel, type  =  AssetType.Main}
    }
    self.slotItemData = nil
    self.isShowBtn = false
    self.stonedata = nil
    self.itemDic = {}
    self.OnOpenEvent:AddListener(function()
        self.sendWashMark = false
        self.slotItemData = self.openArgs[1]
        self.isShowBtn = self.openArgs[2]
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function()
        self:DeleteMe()
    end)
    self.pet_stone_wash_succFun = function ()
        self:pet_stone_wash_succ()
    end
    EventMgr.Instance:AddListener(event_name.pet_stone_wash_succ, self.pet_stone_wash_succFun)
    self.pet_stone_wash_save_succFun = function ()
        self:pet_stone_wash_save_succ()
    end
    EventMgr.Instance:AddListener(event_name.pet_stone_wash_save_succ, self.pet_stone_wash_save_succFun)
    self.updateListener = function() self:buyButtonCallBack({}) self:updateRightNormal() end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

    self.isShowRightWashFrame = true
    self.isShowRightWashDescFrame = false

    self.leftSkill = nil
    self.rightSkill = nil
    self.needSlot = {}
    self.sendWashMark = false

    self.buyButtonCallBackFun = function (list)
        self:buyButtonCallBack(list)
    end

end

function PetStoneWash:__delete()
    for k,v in pairs(self.needSlot) do
        v:DeleteMe()
        v = nil
    end

    if self.leftEquipSlot ~= nil then
        self.leftEquipSlot:DeleteMe()
        self.leftEquipSlot = nil
    end
    if self.rightEquipSlot ~= nil then
        self.rightEquipSlot:DeleteMe()
        self.rightEquipSlot = nil
    end
    if self.rightDescEquipSlot ~= nil then
        self.rightDescEquipSlot:DeleteMe()
        self.rightDescEquipSlot = nil
    end
    self.model.isMyPet = false
    if self.BtnUpdate ~= nil then
        self.BtnUpdate:DeleteMe()
    end
    if self.BtnReset ~= nil then
        self.BtnReset:DeleteMe()
    end
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    EventMgr.Instance:RemoveListener(event_name.pet_stone_wash_succ, self.pet_stone_wash_succFun)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.pet_stone_wash_save_succ, self.pet_stone_wash_save_succFun)
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
    self.model.pswPanel = nil
    --self.model = nil
end

function PetStoneWash:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_stone_wash_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "PetStoneWash"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.Panel_btn = self.transform:FindChild("Panel"):GetComponent(Button)

    self.Panel_btn.onClick:AddListener(function() self:Hiden() end)

    self.MainCon = self.transform:FindChild("MainCon").gameObject

    self.ContentCon = self.MainCon.transform:FindChild("ContentCon").gameObject
    self.closeBtn = self.ContentCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:Hiden() end)

    self.leftArrowBtn = self.ContentCon.transform:FindChild("LeftArrowCon"):GetComponent(Button)
    self.rightArrowBtn = self.ContentCon.transform:FindChild("RightArrowCon"):GetComponent(Button)

    self.LeftCon = self.ContentCon.transform:FindChild("LeftCon").gameObject
    self.TopCon = self.LeftCon.transform:FindChild("TopCon").gameObject
    self.ImgEye = self.TopCon.transform:FindChild("ImgEye"):GetComponent(Button)
    self.HeadCon = self.TopCon.transform:FindChild("HeadCon").gameObject
    self.TxtName = self.TopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.Txtlev = self.TopCon.transform:FindChild("TxtLev"):GetComponent(Text)

    self.leftBottomLine = self.LeftCon.transform:FindChild("BottomImgLine").gameObject
    self.BtnSet = self.LeftCon.transform:FindChild("BtnSet"):GetComponent(Button)
    self.BtnOpenRight = self.LeftCon.transform:FindChild("BtnUpdate"):GetComponent(Button)
    self.redpointObj = self.BtnOpenRight.transform:Find("ImgPoint").gameObject
    -- self.BtnOpenRightTxt = self.BtnOpenRight.gameObject.transform:FindChild("Text"):GetComponent(Text)
    -- self.ImgPoint = self.BtnOpenRight.transform:FindChild("ImgPoint").gameObject
    -- self.StoneImgPoint = self.BtnSet.transform:FindChild("ImgPoint").gameObject

    self.RItem0 = self.LeftCon.transform:FindChild("Item0").gameObject
    self.leftDescTxt = self.RItem0.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.tProp0=self.RItem0.transform:FindChild("Prop0"):GetComponent(Text)
    -- self.tProp1=self.RItem0.transform:FindChild("Prop1"):GetComponent(Text)
    -- self.tProp2=self.RItem0.transform:FindChild("Prop2"):GetComponent(Text)
    -- self.tProp3=self.RItem0.transform:FindChild("Prop3"):GetComponent(Text)
    -- self.tProp4=self.RItem0.transform:FindChild("Prop4"):GetComponent(Text)

    -- self.StonePropCon_Y = {26, 2, -24, -50, -74}
    self.StonePropCon = self.RItem0.transform:FindChild("StonePropCon")
    self.desc11=self.StonePropCon:FindChild("TxtDesc2"):GetComponent(Text)
    self.tProp5=self.StonePropCon:FindChild("Prop5"):GetComponent(Text)
    self.imgObjLeft = self.tProp5.transform:Find("Image"):GetComponent(RectTransform)
    self.tProp5Btn = self.tProp5.gameObject:GetComponent(Button)
    self.tProp5Btn.onClick:AddListener(function() self:on_click_tProp5Btn() end)
    self.tProp6=self.StonePropCon:FindChild("Prop6"):GetComponent(Text)
    self.tProp6.gameObject:SetActive(false)

    -- self.desc11.gameObject:SetActive(false)
    -- self.tProp5.gameObject:SetActive(false)
    -- self.tProp6.gameObject:SetActive(false)

    ----右边符石洗炼逻辑
    self.RightCon = self.ContentCon.transform:FindChild("RightCon").gameObject
    self.RTopCon = self.RightCon.transform:FindChild("TopCon").gameObject
    self.RHeadCon = self.RTopCon.transform:FindChild("HeadCon").gameObject
    self.RTxtName = self.RTopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.RTxtlev = self.RTopCon.transform:FindChild("TxtLev"):GetComponent(Text)

    self.RItem1 = self.RightCon.transform:FindChild("Item0").gameObject
    self.bProp0=self.RItem1.transform:FindChild("Prop0"):GetComponent(Text)
    -- self.bProp1=self.RItem1.transform:FindChild("Prop1"):GetComponent(Text)
    -- self.bProp2=self.RItem1.transform:FindChild("Prop2"):GetComponent(Text)
    -- self.bProp3=self.RItem1.transform:FindChild("Prop3"):GetComponent(Text)
    -- self.bProp4=self.RItem1.transform:FindChild("Prop4"):GetComponent(Text)
    -- self.imgUp0 = self.bProp0.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)
    -- self.imgUp1 = self.bProp1.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)
    -- self.imgUp2 = self.bProp2.gameObject.transform:FindChild("ImgUp"):GetComponent(Image)

    self.RStonePropCon = self.RItem1.transform:FindChild("StonePropCon")
    self.descR11=self.RStonePropCon:FindChild("TxtDesc2"):GetComponent(Text)
    self.tPropR5=self.RStonePropCon:FindChild("Prop5"):GetComponent(Text)
    self.imgObjRight = self.tPropR5.transform:Find("Image"):GetComponent(RectTransform)
    self.tPropR5Btn = self.tPropR5.gameObject:GetComponent(Button)
    self.tPropR5Btn.onClick:AddListener(function() self:on_click_tPropR5Btn() end)

    -- self.RBottomConTxtDesc = self.RightCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.RBottomCon = self.RightCon.transform:FindChild("BottomCon").gameObject
    self.BtnUpdateObj = self.RBottomCon.transform:FindChild("BtnUpdate").gameObject --:GetComponent(Button)
    self.BtnUpdate = BuyButton.New(self.BtnUpdateObj,TI18N("洗炼"), false)
    self.BtnUpdate.key = "PetStoneWashUpdate"
    self.BtnUpdate.protoId = 10541
    self.BtnUpdate:Show()


    self.BtnSave=self.RBottomCon.transform:FindChild("BtnSave"):GetComponent(Button)
    self.BtnSave.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    self.RBottomCon.transform:FindChild("BtnSave"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
    self.BtnResetObj = self.RBottomCon.transform:FindChild("BtnReset").gameObject --:GetComponent(Button)
    self.BtnReset = BuyButton.New(self.BtnResetObj,TI18N("洗炼"),false)
    self.BtnReset.key = "PetStoneWashReset"
    self.BtnReset.protoId = 10541
    self.BtnReset:Show()


    self.NeedText = self.RightCon.transform:FindChild("NeedObj/NeedText"):GetComponent(Text)
    self.needSlot = {}
    for i=1,3 do
        local slotTemp = ItemSlot.New()
        NumberpadPanel.AddUIChild(self.RightCon.transform:FindChild("NeedObj/Grid_"..i).gameObject, slotTemp.gameObject)

        table.insert(self.needSlot,slotTemp)
    end

    -- self.greyBtnImg = self.BtnSave.image.sprite
    -- self.normalBtnImg = self.BtnUpdate.image.sprite
    -- self.greenBtnImg = self.BtnReset.image.sprite
    -- self.BtnUpdate.image.sprite = self.normalBtnImg
    -- self.BtnSave.image.sprite = self.greenBtnImg
    -- self.BtnReset.image.sprite = self.normalBtnImg
    -- self.BtnReset.gameObject:SetActive(false)
    -- self.BtnSave.gameObject:SetActive(false)

    -- self.RBottomCon:SetActive(false)
    -- if RoleManager.Instance.RoleData.lev >= 30 then --大于等于40才开启星阵
    --     self.RBottomCon.gameObject:SetActive(true)
    -- end

    ----右边石洗炼描述
    self.RightDescCon = self.ContentCon.transform:FindChild("RightDescCon").gameObject
    self.RightDescCon:SetActive(false)
    self.RDescTopCon = self.RightDescCon.transform:FindChild("TopCon").gameObject
    self.RDescHeadCon = self.RDescTopCon.transform:FindChild("HeadCon").gameObject
    self.RDescTxtName = self.RDescTopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.RDescTxtlev = self.RDescTopCon.transform:FindChild("TxtLev"):GetComponent(Text)

    self.RDescItem1 = self.RightDescCon.transform:FindChild("Item0").gameObject
    self.bDescProp0=self.RDescItem1.transform:FindChild("Prop0"):GetComponent(Text)

    self.StonePropDescCon = self.RDescItem1.transform:FindChild("StonePropCon")
    self.RDesc11=self.StonePropDescCon:FindChild("TxtDesc2"):GetComponent(Text)
    -- self.tDescProp5=self.StonePropDescCon:FindChild("Prop5"):GetComponent(Text)
    self.grid = self.StonePropDescCon:Find("SkillLIstPanel/Grid")
    self.itemGps = self.grid:Find("Prop5").gameObject
    self.itemGps:SetActive(false)
    -- self.gpsLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})

    -- 注册监听
    self.ImgEye.onClick:AddListener(function() self:on_click_eye_btn() end)
    self.BtnSet.onClick:AddListener(function() self:on_click_btn(1) end) --替换
    self.BtnOpenRight.onClick:AddListener(function() self:on_click_btn(2) end) --开关洗炼界面
    -- self.BtnUpdate.onClick:AddListener(function() self:on_click_btn(3) end) --进行洗炼
    self.BtnSave.onClick:AddListener(function() self:on_click_btn(4) end) --洗炼数据保存
    -- self.BtnReset.onClick:AddListener(function() self:on_click_btn(5) end) --继续进行洗炼
    -- self.BtnResetBig.onClick:AddListener(function() self:on_click_btn(5) end)
    -- self.stone_btn_update.onClick:AddListener(function() self:on_click_btn(7) end)
    -- self.stone_BtnRemove.onClick:AddListener(function() self:on_click_btn(8) end)
    self.leftArrowBtn.onClick:AddListener(function()  self:on_switch_left() end)
    self.rightArrowBtn.onClick:AddListener(function()  self:on_switch_right() end)
    -- self.ImgTanHao.onClick:AddListener(function()  self:on_click_tanhao() end)
    -- self.stone_tanhao.onClick:AddListener(function()  self:on_click_stone_tanhao() end)

    -- self.restoreFrozen_reset = FrozenButton.New(self.BtnResetBig)
    -- self.restoreFrozen_upgrade = FrozenButton.New(self.BtnUpdate) --洗炼给个可点击时间
    -- self.restoreFrozen_reset_small = FrozenButton.New(self.BtnReset) --洗炼给个可点击时间
    -- self.restoreFrozen_stone_upgrade = FrozenButton.New(self.stone_btn_update)

    -- self:init_view()

    -- self:CheckGuide()
end
function PetStoneWash:on_switch_left()
    self.slotItemData = self.leftItemData
    self:UpdateWindowByClickLeftOrRight()
end
function PetStoneWash:on_switch_right()
    self.slotItemData = self.rightItemData
    self:UpdateWindowByClickLeftOrRight()
end
--左侧技能点击，显示描述
function PetStoneWash:on_click_tProp5Btn()
    -- body
    if self.leftSkill ~= nil then
        self.descRole = {
            string.format("<color='#dc83f5'>%s：</color><color='#c7f9ff'>%s</color>",self.leftSkill.name,self.leftSkill.desc),
        }
        TipsManager.Instance:ShowText({gameObject = self.tProp5Btn.gameObject, itemData = self.descRole})
    end
end

--右侧技能点击，显示描述
function PetStoneWash:on_click_tPropR5Btn()
    -- body
    if self.rightSkill ~= nil then
        self.descRole = {
            string.format("<color='#dc83f5'>%s：</color><color='#c7f9ff'>%s</color>",self.rightSkill.name,self.rightSkill.desc),
        }
        TipsManager.Instance:ShowText({gameObject = self.tPropR5Btn.gameObject, itemData = self.descRole})
    end
end

function PetStoneWash:on_click_eye_btn()
    self.RightCon:SetActive(false)
    self.isShowRightWashFrame = false
    if self.isShowRightWashDescFrame == false then
        self.isShowRightWashDescFrame = true
        self.RightDescCon:SetActive(true)
    else
        self.isShowRightWashDescFrame = false
        self.RightDescCon:SetActive(false)
    end
end

-- 按钮点击监听
function PetStoneWash:on_click_btn(index)
    if index == 1 then
        --替换
        TipsManager.Instance.model:Pet_gem_replace(self.slotItemData)
        self:Hiden()
    elseif index == 2 then
        --洗炼窗口开关
        self.RightDescCon:SetActive(false)
        self.isShowRightWashDescFrame = false
        if self.isShowRightWashFrame == false then
            self.isShowRightWashFrame = true
            self.RightCon:SetActive(true)
        else
            self.isShowRightWashFrame = false
            self.RightCon:SetActive(false)
        end
    elseif index == 3 then
        --进行洗炼
        self:ConfirmWash(self.model.cur_petdata.id,self.slotItemData.id)
    elseif index == 4 then
        --保存洗炼数据
        self:ConfirmSave(self.model.cur_petdata.id,self.slotItemData.id)
    elseif index == 5 then
        --继续洗炼
        self:ConfirmWash(self.model.cur_petdata.id,self.slotItemData.id)
    end
end

function PetStoneWash:OnInitCompleted()
    self.slotItemData = self.openArgs[1]
    self.isShowBtn = self.openArgs[2]
    self:UpdateWindow()
end

function PetStoneWash:checkLeftRightBtn(curStoneId)
    self.leftArrowBtn.gameObject:SetActive(false)
    self.rightArrowBtn.gameObject:SetActive(false)
    local isRightFirst = true
    local petData = self.model.cur_petdata
    for j=1,#petData.stones do
        if petData.stones[j].id > 1 then
            if petData.stones[j].id == curStoneId - 1 then
                self.leftArrowBtn.gameObject:SetActive(true)

                local stonedata = petData.stones[j]
                local itembase = BackpackManager.Instance:GetItemBase(stonedata.base_id)
                self.leftItemData = ItemData.New()
                self.leftItemData.id = stonedata.id
                self.leftItemData.attr = stonedata.attr
                self.leftItemData.reset_attr = stonedata.reset_attr
                self.leftItemData.extra = stonedata.extra
                self.leftItemData:SetBase(itembase)
            elseif petData.stones[j].id == curStoneId + 1 then
                self.rightArrowBtn.gameObject:SetActive(true)
                if isRightFirst == true then
                    isRightFirst = false

                    local stonedata = petData.stones[j]
                    local itembase = BackpackManager.Instance:GetItemBase(stonedata.base_id)
                    self.rightItemData = ItemData.New()
                    self.rightItemData.id = stonedata.id
                    self.rightItemData.attr = stonedata.attr
                    self.rightItemData.reset_attr = stonedata.reset_attr
                    self.rightItemData.extra = stonedata.extra
                    self.rightItemData:SetBase(itembase)
                end
            end
        end
    end
    -- BaseUtils.dump(self.leftItemData,"self.leftItemData")
    -- BaseUtils.dump(self.rightItemData,"self.rightItemData")
end

function PetStoneWash:UpdateWindow()
    if self.model.isMyPet == true then
        local petData = self.model.cur_petdata
        for j=1,#petData.stones do
            if petData.stones[j].id == self.slotItemData.id then
                self.stonedata = petData.stones[j]
                break
            end
        end
        self:checkLeftRightBtn(self.slotItemData.id)
    else
        -- BaseUtils.dump(self.slot,"==============================")
        self.stonedata = self.slotItemData
        self.leftArrowBtn.gameObject:SetActive(false)
        self.rightArrowBtn.gameObject:SetActive(false)
    end
    -- BaseUtils.dump(self.stonedata,"self.stonedata")
    self.isShowRightWashFrame = false
    self.RightCon:SetActive(false)
    self:updateRightNormal()
    self:updateLeftNormal()
    self:updateRightDescNormal()

    self.sendWashMark = false
end
function PetStoneWash:UpdateWindowByClickLeftOrRight()
    self.stonedata = self.slotItemData
    self:checkLeftRightBtn(self.slotItemData.id)
    self:updateRightNormal()
    self:updateLeftNormal()
    self:updateRightDescNormal()
end
--洗炼成功，数据刷新
function PetStoneWash:pet_stone_wash_succ()
    self.BtnUpdate:ReleaseFrozon()
    self.BtnReset:ReleaseFrozon()

    local petData = self.model.cur_petdata
    for j=1,#petData.stones do
        if petData.stones[j].id == self.slotItemData.id then
            self.stonedata = petData.stones[j]
            break
        end
    end
    self:updateRightData()
end
function PetStoneWash:pet_stone_wash_save_succ()
    local petData = self.model.cur_petdata
    for j=1,#petData.stones do
        if petData.stones[j].id == self.slotItemData.id then
            self.stonedata = petData.stones[j]
            break
        end
    end
    self:updateRightData()
    self:updateLeftData()
end
--左侧符石初始数据界面
function PetStoneWash:updateLeftNormal()
    if self.leftEquipSlot == nil then
        self.leftEquipSlot = ItemSlot.New()
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[self.slotItemData.base_id]
    cell:SetBase(itemData)

    self.leftEquipSlot:SetAll(cell, {inbag = false, nobutton = true})
    NumberpadPanel.AddUIChild(self.HeadCon, self.leftEquipSlot.gameObject)
    self.TxtName.text = self.slotItemData.name
    self.Txtlev.text = string.format(TI18N("类型：%s"),self.slotItemData.func)
    -- self.leftDescTxt.text = itemData.desc

    self.BtnSet.gameObject:SetActive(self.isShowBtn)
    self.BtnOpenRight.gameObject:SetActive(self.isShowBtn)
    self.leftBottomLine:SetActive(self.isShowBtn)

    self:updateLeftData()
end
--左侧符石数据
function PetStoneWash:updateLeftData()
    self:checkRedpoint()

    local attrList = {}
    local skillList = {}
    for i,v in ipairs(self.stonedata.attr) do
        if v.name == 100 then --技能
            table.insert(skillList,v)
        else
            table.insert(attrList,v)
        end
    end
    local attrStr = ""
    for i,v in ipairs(attrList) do
        if KvData.attr_name[v.name] ~= nil then
            attrStr = attrStr .. KvData.attr_name[v.name].."+"..v.val
        end
    end
    self.tProp0.text = string.format("<color='#00ffff'>%s</color>",attrStr)
    self.leftDescTxt.text = string.format(DataPet.data_pet_stone_wash[self.slotItemData.base_id].attr_desc,attrStr)
    self.leftSkill = nil
    if #skillList > 0 then
        self.tProp6.gameObject:SetActive(false)
        self.desc11.gameObject:SetActive(true)
        self.tProp5.gameObject:SetActive(true)
        local skillStr = ""
        for i,v in ipairs(skillList) do
            local skillTpl = DataSkill.data_get_pet_stone[v.val]
            if skillTpl ~= nil then
                self.leftSkill = skillTpl
                if skillStr == "" then
                    skillStr = skillTpl.name
                else
                    skillStr = skillStr .. "\n" ..skillTpl.name
                end
            end
        end
        self.tProp5.text = string.format("<color='#dc83f5'>%s</color>", skillStr)
        self.imgObjLeft.anchoredPosition = Vector3(self.tProp5.preferredWidth + 20,-8,0)
    else
        self.desc11.gameObject:SetActive(false)
        self.tProp5.gameObject:SetActive(false)
        -- self.tProp5.text = string.format("<color='#d781f2'>%s</color>", "无")
    end
end
function PetStoneWash:checkRedpoint()
    local isShowGreenPoint = true
    for kk,kkvv in ipairs(self.stonedata.extra) do
        if kkvv.name == 8 and kkvv.value == 1 then
            isShowGreenPoint = false
        end
    end
    self.redpointObj:SetActive(isShowGreenPoint)

    if isShowGreenPoint == true then
        self.tProp6.gameObject:SetActive(true)
        -- self.leftDescTxt.gameObject:SetActive(true)
    else
        self.tProp6.gameObject:SetActive(false)
        -- self.leftDescTxt.gameObject:SetActive(false)
    end
    return isShowGreenPoint
end
--右侧符石洗炼数据界面
function PetStoneWash:updateRightNormal()
    if self.rightEquipSlot == nil then
        self.rightEquipSlot = ItemSlot.New()
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[self.slotItemData.base_id]
    cell:SetBase(itemData)

    self.rightEquipSlot:SetAll(cell, {inbag = false, nobutton = true})
    NumberpadPanel.AddUIChild(self.RHeadCon, self.rightEquipSlot.gameObject)
    self.RTxtName.text = self.slotItemData.name
    self.RTxtlev.text = string.format(TI18N("类型：%s"),self.slotItemData.func)

    -- self.NeedText.text = string.format("消耗<color='%s'>%d个</color>",ColorHelper.color[1],needItemTemp[1][2])
    -- local msgContent = string.format("每次洗炼消耗{item_2, %d, 0, %d}",needItemTemp[1][1],needItemTemp[1][2])
    -- self.needMsg:SetData(msgContent)

    self:updateRightData()
end
--右侧符石数据更新
function PetStoneWash:updateRightData()
    self:checkRedpoint()

    if self.model.cur_petdata == nil then return end
    local needItemTemp = DataPet.data_pet_stone_wash_cost[self.model.cur_petdata.base.id].val --{{22100,10},{22101,12},{22102,14}}
    local needTable = {}
    for i,v in ipairs(needItemTemp) do
        needTable[v[1]] = {need = v[2]}
    end
    -- BaseUtils.dump(needTable,"function PetStoneWash:updateRightData()==")

    local isEnough = true
    for i,v in ipairs(needItemTemp) do
        if BackpackManager.Instance:GetItemCount(v[1]) < v[2] then
            isEnough = false
            break
        end
    end
    if isEnough == true then
        self.BtnUpdate:Set_btn_txt(TI18N("洗 炼"))
        self.BtnReset:Set_btn_txt(TI18N("洗 炼"))
    else
        self.BtnUpdate:Set_btn_txt(TI18N("洗炼"))
        self.BtnReset:Set_btn_txt(TI18N("洗炼"))
    end

    if self.stonedata.reset_attr ~= nil and #self.stonedata.reset_attr == 0 then
        local attrTemp = DataPet.data_pet_stone_wash[self.stonedata.base_id]
        self.bProp0.text = string.format("<color='#00ffff'>%s+%d~%d</color>",KvData.attr_name[attrTemp.attr_name],attrTemp.attr_min,attrTemp.attr_max)
        self.tPropR5.text = "<color='#dc83f5'>+??</color>"

        self.BtnUpdateObj:SetActive(true)
        self.BtnSave.gameObject:SetActive(false)
        self.BtnResetObj:SetActive(false)

        self.BtnUpdate:Layout(needTable, function () --{[22100]={need=10},[22101]={need=12},[22102]={need=14}}
            -- body
            self:on_click_btn(3)
        end,self.buyButtonCallBackFun,{fontSize = 18,gap = 4})
        self.BtnUpdate:Set_btn_img("DefaultButton1")
        self.BtnUpdate:SetTextColor(ColorHelper.DefaultButton1)

        self.imgObjRight.gameObject:SetActive(false)
        return
    end
    self.imgObjRight.gameObject:SetActive(true)
    local attrList = {}
    local skillList = {}
    if self.stonedata.reset_attr ~= nil then
        for i,v in ipairs(self.stonedata.reset_attr) do
            if v.name == 100 then --技能
                table.insert(skillList,v)
            else
                table.insert(attrList,v)
            end
        end
    end
    local attrStr = ""
    for i,v in ipairs(attrList) do
        if KvData.attr_name[v.name] ~= nil then
            attrStr = attrStr .. KvData.attr_name[v.name].."+"..v.val
        end
    end
    self.bProp0.text = string.format("<color='#00ffff'>%s</color>",attrStr)
    self.rightSkill = nil
    if #skillList > 0 then
        self.descR11.gameObject:SetActive(true)
        self.tPropR5.gameObject:SetActive(true)
        local skillStr = ""
        for i,v in ipairs(skillList) do
            local skillTpl = DataSkill.data_get_pet_stone[v.val]
            if skillTpl ~= nil then
                self.rightSkill = skillTpl
                if skillStr == "" then
                    skillStr = skillTpl.name
                else
                    skillStr = skillStr .. "\n" ..skillTpl.name
                end
            end
        end
        self.tPropR5.text = string.format("<color='#dc83f5'>%s</color>", skillStr)
        self.imgObjRight.anchoredPosition = Vector3(self.tPropR5.preferredWidth + 20,-8,0)

        self:showSkillConfirm(skillList)
    else
        self.descR11.gameObject:SetActive(false)
        self.tPropR5.gameObject:SetActive(false)
        -- self.tPropR5.text = "<color='#dc83f5'>+??</color>"
    end
    self.BtnUpdateObj:SetActive(false)
    self.BtnSave.gameObject:SetActive(true)
    self.BtnResetObj:SetActive(true)

    self.BtnReset:Layout(needTable, function ()
        -- body
        self:on_click_btn(5)
    end,self.buyButtonCallBackFun,{fontSize = 18,gap = 4})--,self.buyButtonCallBackFun)
    self.BtnReset:Set_btn_img("DefaultButton1")
    self.BtnReset:SetTextColor(ColorHelper.DefaultButton1)
end
function PetStoneWash:buyButtonCallBack(list)
    -- BaseUtils.dump(list,"PetStoneWash:buyButtonCallBack(list) == ")
    local needItemTemp = DataPet.data_pet_stone_wash_cost[self.model.cur_petdata.base.id].val
    for i,v in ipairs(needItemTemp) do
        local slotTemp = self.needSlot[i]
        local itemDataTemp = ItemData.New()
        itemDataTemp:SetBase(DataItem.data_get[v[1]])
        slotTemp:SetAll(itemDataTemp, {inbag = false, nobutton = true})
        local cntHad = BackpackManager.Instance:GetItemCount(v[1])
        slotTemp:SetNum(cntHad,v[2])

        slotTemp.gameObject:SetActive(true)

        local serverData = list[v[1]]
        if serverData ~= nil and serverData.assets == KvData.assets.gold_bind and cntHad < v[2] then
            -- local singleprice = math.abs(serverData.allprice) / v[2]
            slotTemp.gameObject.transform.parent:Find("ImageGold").gameObject:SetActive(true)
            local needTemp = slotTemp.gameObject.transform.parent:Find("ImageGold/NeedGoldText"):GetComponent(Text)
            local needCnt = serverData.allprice -- singleprice * (v[2] - cntHad)
            if needCnt > 0 then
                needTemp.text = string.format("<color='#00ff00'>%d</color>",needCnt)
            else
                needTemp.text = string.format("<color='#ff0000'>%d</color>",-needCnt)
            end
        else
            slotTemp.gameObject.transform.parent:Find("ImageGold").gameObject:SetActive(false)
        end
    end
    for i=#needItemTemp + 1,3 do
        local slotTemp = self.needSlot[i]
        if slotTemp ~= nil and slotTemp.gameObject ~= nil then
            slotTemp.gameObject:SetActive(false)
            slotTemp.gameObject.transform.parent:Find("ImageGold").gameObject:SetActive(false)
        end
    end
end
--右侧符石描述界面
function PetStoneWash:updateRightDescNormal()
    if self.rightDescEquipSlot == nil then
        self.rightDescEquipSlot = ItemSlot.New()
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[self.slotItemData.base_id]
    cell:SetBase(itemData)

    self.rightDescEquipSlot:SetAll(cell, {inbag = false, nobutton = true})
    NumberpadPanel.AddUIChild(self.RDescHeadCon, self.rightDescEquipSlot.gameObject)
    self.RDescTxtName.text = self.slotItemData.name
    self.RDescTxtlev.text = string.format(TI18N("类型：%s"),self.slotItemData.func)

    local attrTemp = DataPet.data_pet_stone_wash[self.stonedata.base_id]
    self.bDescProp0.text = string.format("<color='#00ffff'>%s +%d~%d</color>",KvData.attr_name[attrTemp.attr_name],attrTemp.attr_min,attrTemp.attr_max)
    -- self.tDescProp5.text = ""

    for i,v in ipairs(self.itemDic) do
        v.gameObject:SetActive(false)
    end
    local lastPos = Vector3(0,0,0)
    local skillList = DataPet.data_pet_stone_wash[self.stonedata.base_id].skill_list
    for i,v in ipairs(skillList) do
        if v[1] ~= 0 then
            local skillTpl = DataSkill.data_get_pet_stone[v[1]]
            if skillTpl ~= nil then
                local itemTaken = self.itemDic[i]
                if itemTaken == nil then
                    local obj = GameObject.Instantiate(self.itemGps)
                    obj.name = tostring(i)

                    -- self.gpsLayout:AddCell(obj)
                    local rect = obj:GetComponent(RectTransform)
                    rect:SetParent(self.grid.gameObject:GetComponent(RectTransform))
                    obj.transform.localScale = Vector3.one
                    obj:SetActive(true)

                    itemTaken = obj
                    self.itemDic[i] = itemTaken
                end
                itemTaken.gameObject:SetActive(true)
                itemTaken.gameObject:GetComponent(Text).text = string.format("<color='#dc83f5'>%s：</color><color='#c7f9ff'>%s</color>",skillTpl.name,skillTpl.desc)
                itemTaken.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(258, 10 + itemTaken.gameObject:GetComponent(Text).preferredHeight)
                itemTaken.gameObject:GetComponent("RectTransform").anchoredPosition = lastPos
                lastPos = lastPos + Vector3(0,-itemTaken.gameObject:GetComponent("RectTransform").sizeDelta.y,0)
            end
        end
    end
    self.grid.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(258, -lastPos.y)
end

--洗炼出技能时，弹出提示框(暂时屏蔽)
function PetStoneWash:showSkillConfirm(skillList)
    -- if self.sendWashMark then
    --     local skillStr = ""
    --     for i,v in ipairs(skillList) do
    --         local skillTpl = DataSkill.data_get_pet_stone[v.val]
    --         if skillTpl ~= nil then
    --             self.rightSkill = skillTpl
    --             if skillStr == "" then
    --                 skillStr = skillTpl.name
    --             else
    --                 skillStr = skillStr .. "、" ..skillTpl.name
    --             end
    --         end
    --     end

    --     local data = NoticeConfirmData.New()
    --     data.type = ConfirmData.Style.Sure
    --     data.content = string.format("获得特效：<color='#ffff00'>%s</color>", skillStr)
    --     data.sureLabel = "确定"
    --     NoticeManager.Instance:ConfirmTips(data)
    -- end
end

--当前已经洗出特效的情况下，点击洗炼弹出提示
function PetStoneWash:ConfirmWash(petId, itemId)
    local skillList = {}
    if self.stonedata.reset_attr ~= nil then
        for i,v in ipairs(self.stonedata.reset_attr) do
            if v.name == 100 then --技能
                table.insert(skillList,v)
            end
        end
    end

    if #skillList > 0 then
        local skillStr = ""
        for i,v in ipairs(skillList) do
            local skillTpl = DataSkill.data_get_pet_stone[v.val]
            if skillTpl ~= nil then
                self.rightSkill = skillTpl
                if skillStr == "" then
                    skillStr = string.format("[%s]", skillTpl.name)
                else
                    skillStr = string.format("%s、[%s]", skillStr, skillTpl.name)
                end
            end
        end

        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("当前符石已经洗出<color='#00ff00'>%s</color>，继续洗练可能出现其他特效或特效消失，是否继续？"), skillStr)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
                self.sendWashMark = true
                PetManager.Instance:Send10541(petId, itemId)
            end
        data.cancelCallback = function()
                self.BtnUpdate:ReleaseFrozon()
                self.BtnReset:ReleaseFrozon()
            end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self.sendWashMark = true
        PetManager.Instance:Send10541(petId, itemId)
    end
end

--当前已经洗出特效的情况下，点击洗炼弹出提示
function PetStoneWash:ConfirmSave(petId, itemId)
    local skillList = {}
    if self.stonedata.attr ~= nil then
        for i,v in ipairs(self.stonedata.attr) do
            if v.name == 100 then --技能
                table.insert(skillList,v)
            end
        end
    end

    if #skillList > 0 then
        local skillStr = ""
        for i,v in ipairs(skillList) do
            local skillTpl = DataSkill.data_get_pet_stone[v.val]
            if skillTpl ~= nil then
                self.rightSkill = skillTpl
                if skillStr == "" then
                    skillStr = string.format("[%s]", skillTpl.name)
                else
                    skillStr = string.format("%s、[%s]", skillStr, skillTpl.name)
                end
            end
        end
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("当前符石拥有<color='#00ff00'>%s</color>，保存将覆盖掉当前的特技，是否要进行保存？"), skillStr)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
                PetManager.Instance:Send10542(petId, itemId)
            end
        data.cancelCallback = function()
                self.BtnUpdate:ReleaseFrozon()
                self.BtnReset:ReleaseFrozon()
            end
        NoticeManager.Instance:ConfirmTips(data)
    else
        PetManager.Instance:Send10542(petId, itemId)
    end
end