HeadSlot = HeadSlot or BaseClass()

-- 一定要记得调用DeleteMe() ！！！！！
-- 不然会出事！！！！
--第二个参数为是否显示头像相框，默认不显示
function HeadSlot:__init(gameObject,isActiveFrame)
    self.portraitListener = function(rid, platform, zone_id) self:PortraitListener(rid, platform, zone_id) end
    self.typeImage = {}

    self.isSmall = false
    self.isActiveFrame = isActiveFrame or false
    self:Create(gameObject)
end

function HeadSlot:__delete()
    self:RemoveAllListeners()
    self.button.onClick:RemoveAllListeners()
    if not BaseUtils.isnull(self.gameObject) then
        self.baseLoader:DeleteMe()
        self.hairImage.sprite = nil
        self.faceImage.sprite = nil
        self.bangsImage.sprite = nil
        self.glassImage.sprite = nil
        self.clothImage.sprite = nil
        self.headwearImage.sprite = nil
        self.image.sprite = nil
    end
    self.typeImage = nil
end

function HeadSlot:Create(gameObject)
    if self.gameObject == nil then
        if gameObject == nil then
            gameObject = GameObject.Instantiate(PortraitManager.Instance:GetPrefab(AssetConfig.headslot))
            gameObject.name = "HeadSlot"
        end
        self.gameObject = gameObject
        self.transform = gameObject.transform
        local t = self.transform

        self.image = gameObject:GetComponent(Image)
        self.baseLoader = SingleIconLoader.New(t:Find("Custom/Base").gameObject)
        self.button = gameObject:GetComponent(Button)

        self.customTrans = t:Find("Custom")
        self.customTransMask = t:Find("Custom"):GetComponent(Mask)
        self.customObj = self.customTrans.gameObject
        self.containerTrans = t:Find("Custom/Container")
        self.mask = t:Find("Custom/Container/Mask").gameObject

        self.bgImage = t:Find("Custom/Container/Mask/Bg"):GetComponent(Image)
        self.hairImage = t:Find("Custom/Container/Mask/Hair"):GetComponent(Image)
        self.headwearImage = t:Find("Custom/Container/Mask/Headwear"):GetComponent(Image)
        self.faceImage = t:Find("Custom/Container/Mask/Face"):GetComponent(Image)
        self.bangsImage = t:Find("Custom/Container/Mask/Bang"):GetComponent(Image)
        self.headwearFrontImage = t:Find("Custom/Container/Mask/HeadwearFront"):GetComponent(Image)
        self.glassImage = t:Find("Custom/Container/Mask/Glass"):GetComponent(Image)
        self.clothImage = t:Find("Custom/Container/Mask/Cloth"):GetComponent(Image)
        self.photoframeImage = t:Find("Custom/Container/PhotoFrameImage"):GetComponent(Image)
        self.photoframeImage.type = Image.Type.Sliced

        self.excessList = {}

        for i=1,3 do
            self.excessList[i] = t:Find("Custom/Container/PhotoFrameExcess" .. i):GetComponent(Image)
        end

        self.select = t:Find("Select").gameObject

        --只有type 1-5 才被选择显示，如头像框装饰type6 不提供Image组件显示
        self.typeImage[1] = {self.bangsImage, self.hairImage}
        self.typeImage[2] = {self.faceImage}
        self.typeImage[3] = {self.bgImage}
        self.typeImage[4] = {self.headwearFrontImage, self.headwearImage}
        self.typeImage[5] = {self.photoframeImage,self.excessList[1],self.excessList[2],self.excessList[3]}



        self.hairImage.gameObject:SetActive(false)
        self.headwearImage.gameObject:SetActive(false)
        self.faceImage.gameObject:SetActive(false)
        self.bangsImage.gameObject:SetActive(false)
        self.headwearFrontImage.gameObject:SetActive(false)
        self.glassImage.gameObject:SetActive(false)
        self.clothImage.gameObject:SetActive(false)



        self.attrObj = t:Find("Attr").gameObject
    end
    self:Default()
end

-- data:{id, platform, zone_id, sex, classes}，必须参数
-- setting = {
--      isSmall = 是否大头像 现在还没什么卵用
--      clickCallback = 点击回调
--      loadCallback = 加载回调，传入参数true表示有自定义头像
--      noPortrait = 传入参数false表示不显示自定义头像
--  }
function HeadSlot:SetAll(data, setting)
    self.myData = data
    setting = setting or {}

    self.containerTrans.gameObject:SetActive(false)
    self.baseLoader.gameObject:SetActive(true)
    self.attrObj:SetActive(false)
    self.roleData = self.roleData or {}
    self.roleData["id"] = data["id"]
    self.roleData["platform"] = data["platform"]
    self.roleData["zone_id"] = data["zone_id"]
    self.roleData["classes"] = data["classes"]
    self.roleData["zone_id"] = data["zone_id"]
    self.roleData["sex"] = data["sex"]
    self.setting = setting
    self.isSmall = setting.isSmall or false
    self.loadCallback = setting.loadCallback

    self:RemoveAllListeners()
    self.customTransMask.enabled = true
    self:SetPivot()
    -- self:RemoveAllListeners()
    EventMgr.Instance:AddListener(event_name.custom_portrait_update, self.portraitListener)

    if not BaseUtils.isnull(data.classes) or not BaseUtils.isnull(data.sex) then
        self.baseLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex))
    end
    if not setting.noPortrait then
        self:SetPurePortrait(PortraitManager.Instance:GetInfos(data.id, data.platform, data.zone_id))
    end
    self.button.onClick:RemoveAllListeners()
    if setting.clickCallback ~= nil then
        self.button.onClick:AddListener(setting.clickCallback)
    end
end

function HeadSlot:SetMystery()
    self.containerTrans.gameObject:SetActive(false)
    self.baseLoader.gameObject:SetActive(true)
    self.baseLoader:SetOtherSprite(PortraitManager.Instance.assetWrapper:GetSprite(AssetConfig.portrait_textures, "Unknow"))
    self:RemoveAllListeners()
    self:SetPivot()
    self.button.onClick:RemoveAllListeners()
end

function HeadSlot:Default()
    self.containerTrans.gameObject:SetActive(false)
    self.baseLoader.gameObject:SetActive(false)
    self.attrObj:SetActive(false)

    self:RemoveAllListeners()
end

function HeadSlot:SetRectParent(parent)
    local trans = self.gameObject.transform
    trans:SetParent(parent.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    trans.anchorMax = Vector2.one
    trans.anchorMin = Vector2.zero
    trans.offsetMin = Vector2.zero
    trans.offsetMax = Vector2.zero
    trans.anchoredPosition = Vector2.zero
end

function HeadSlot:Select(bool)
    if self.select ~= nil then
        self.select:SetActive(bool == true)
    end
end

function HeadSlot:PortraitListener(rid, platform, zone_id)
    local roleData = self.roleData
    if rid ~= nil and platform ~= nil and zone_id ~= nil and roleData ~= nil and roleData.id == rid and roleData.platform == platform and roleData.zone_id == zone_id and self.gameObject ~= nil then
        self:SetPurePortrait(PortraitManager.Instance:GetInfos(rid, platform, zone_id))
        if self.setting.myCallBack ~= nil then
            self.setting.myCallBack(PortraitManager.Instance:GetInfos(rid, platform, zone_id))
        end
    end
    -- BaseUtils.dump(self.setting,"fdsfsdfsdfsdf")

end

function HeadSlot:SetPortrait(info, setting)

    setting = setting or {}
    self.isSmall = setting.isSmall or false
    self:SetPurePortrait(info)

    self:RemoveAllListeners()
    self.button.onClick:RemoveAllListeners()
    if setting.clickCallback ~= nil then
        self.button.onClick:AddListener(setting.clickCallback)
    end
    self.loadCallback = nil
end

function HeadSlot:SetPurePortrait(info)
    self:SetPivot()


    -- info = {20000, 10000, 40000, 30000}
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    local scale = self.containerTrans.rect.width / 160
    local realyScale = self.containerTrans.rect.width / 180

    local dirx = 8
    local diry = 8
    self.roleData = self.roleData or {}
    local sex = self.roleData["sex"] or RoleManager.Instance.RoleData.sex
    local c = 0
    if info ~= nil then
        for type,num in pairs(info) do
            c = c + 1
            local data = nil
            if type == PortraitEumn.Type.photoFrame then
                data = DataHead.data_photoframe[string.format("%s_%s", tostring(type), tostring(num))]
            else
                data = DataHead.data_res_config[string.format("%s_%s", tostring(type), tostring(num))]
            end
            if self.typeImage[type] ~= nil then
                if data ~= nil then
                    if type == PortraitEumn.Type.photoFrame and self.isActiveFrame == false then
                        break
                    end

                    self.typeImage[type][1].sprite = PortraitManager.Instance:GetHeadcustomSprite(type, sex, data.res)

                    if self.typeImage[type][1].sprite == nil then
                        Log.Error(string.format("type=%s, sex=%s, data.res=%s", tostring(type), tostring(sex), tostring(data.res)))
                    end

                    self.typeImage[type][1]:SetNativeSize()
                    -- local size = self.typeImage[type][1].transform.sizeDelta
                    local size = self.typeImage[type][1].sprite.textureRect.size



                    if type == PortraitEumn.Type.photoFrame then
                        local photoFrame_size = 20      --头像框size固定改为20（50010特殊），@hze/180925
                        self.typeImage[type][1].transform.sizeDelta = Vector2(photoFrame_size * realyScale * PortraitManager.Instance.standardScale[type], photoFrame_size * realyScale * PortraitManager.Instance.standardScale[type])
                        -- self.typeImage[type][1].transform.sizeDelta = Vector2(size.x * realyScale * PortraitManager.Instance.standardScale[type], size.y * realyScale * PortraitManager.Instance.standardScale[type])
                        self.typeImage[type][1].transform.anchoredPosition = Vector2((data.res_x - 1.25) * realyScale*PortraitManager.Instance.standardScale[type], (-data.res_y + 1.2) * realyScale*PortraitManager.Instance.standardScale[type])
                    else
                        self.typeImage[type][1].transform.sizeDelta = Vector2(size.x * scale * PortraitManager.Instance.standardScale[type], size.y * scale * PortraitManager.Instance.standardScale[type])
                        self.typeImage[type][1].transform.anchoredPosition = Vector2((data.res_x - dirx) * scale, -(data.res_y - diry) * scale)
                    end
                    self.typeImage[type][1].gameObject:SetActive(true)

                    if data.res_ext ~= "" and self.typeImage[type][2] ~= nil then
                        self.typeImage[type][2].gameObject:SetActive(true)
                        self.typeImage[type][2].sprite = PortraitManager.Instance:GetHeadcustomSprite(type, sex, data.res_ext)
                        self.typeImage[type][2]:SetNativeSize()
                        -- local size = self.typeImage[type][2].transform.sizeDelta
                        local size = self.typeImage[type][2].sprite.textureRect.size
                        self.typeImage[type][2].transform.sizeDelta = Vector2(size.x * scale * PortraitManager.Instance.standardScale[type], size.y * scale * PortraitManager.Instance.standardScale[type])
                        self.typeImage[type][2].transform.anchoredPosition = Vector2((data.res_ext_x - dirx)* scale, -(data.res_ext_y - diry) * scale)
                    else
                        if self.typeImage[type][2] ~= nil then
                            self.typeImage[type][2].gameObject:SetActive(false)
                        end
                    end


                    if type == PortraitEumn.Type.photoFrame and #data.excess > 0 and self.isActiveFrame == true then
                        self.customTransMask.enabled = false
                        for i2,v2 in ipairs(data.excess) do
                            local excessId = string.format("%s_%s", tostring(type + 1), tostring(v2))
                            if DataHead.data_photoframe[excessId] ~= nil then
                                local myData = DataHead.data_photoframe[string.format("%s_%s", tostring(type + 1), tostring(v2))]
                                if self.typeImage[type][i2 + 1] ~= nil then
                                    self.typeImage[type][i2 + 1].gameObject:SetActive(true)
                                    self.typeImage[type][i2 + 1].sprite = PortraitManager.Instance:GetHeadcustomSprite(type, sex, myData.res)
                                    self.typeImage[type][i2 + 1]:SetNativeSize()

                                    local size = self.typeImage[type][i2 + 1].sprite.textureRect.size
                                    self.typeImage[type][i2 + 1].transform.sizeDelta = Vector2(size.x * realyScale * PortraitManager.Instance.standardScale[6], size.y * realyScale * PortraitManager.Instance.standardScale[6])
                                    self.typeImage[type][i2 + 1].transform.anchoredPosition = Vector2((myData.res_x*0.66666 - 25*0.66666) * realyScale *PortraitManager.Instance.standardScale[6], (-myData.res_y*0.66666 + 26.5*0.66666) * realyScale *PortraitManager.Instance.standardScale[6])

                                else
                                    local num = i2+1
                                    error(string.format("头像配件GameObject为空[%s][%s]",type,num))
                                end

                            else
                                error("头像配件id索引的数据为空:" .. excessId)
                            end
                        end
                    else
                        self.customTransMask.enabled = true
                    end

                    if #self.typeImage[type] > #data.excess then
                        for i=#data.excess + 1,#self.typeImage[type] - 1 do
                            if i >1 then
                                self.typeImage[type][i + 1].gameObject:SetActive(false)
                            end
                        end
                    end

                -- else
                --     self.typeImage[type][1].gameObject:SetActive(false)
                --     self.typeImage[type][2].gameObject:SetActive(false)
                end
            end
        end
        for i,list in pairs(self.typeImage) do
            if info[i] == nil then
                for _,v in pairs(list) do
                    v.gameObject:SetActive(false)
                end
            end
        end
    else
        for i,list in pairs(self.typeImage) do
            for _,v in pairs(list) do
                v.gameObject:SetActive(false)
            end
        end
    end
    self.containerTrans.gameObject:SetActive(c > 0)

    if  (info  == nil or #info  == 0) or (info  ~= nil and info[1]  == nil and info[5] ~= nil) then
        if self.myData == nil then
            local roleData = RoleManager.Instance.RoleData
            self.baseLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, roleData.classes .. "_" .. roleData.sex))
        else
            local roleData = RoleManager.Instance.RoleData
            self.baseLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.heads, self.myData.classes .. "_" .. self.myData.sex))
        end
        self.mask.gameObject:SetActive(false)
        self.baseLoader.gameObject:SetActive(true)
    else
        self.mask.gameObject:SetActive(true)
        self.baseLoader.gameObject:SetActive(c == 0)
    end
    if self.loadCallback ~= nil then
        self.loadCallback(info ~= nil)
    end
end

function HeadSlot:RemoveAllListeners()
    EventMgr.Instance:RemoveListener(event_name.custom_portrait_update, self.portraitListener)
end

function HeadSlot:SetPivot()
    -- local dis1 = 0.03
    -- self.customTrans.anchorMin = Vector2(0.03, 0.03)
    -- self.customTrans.anchorMax = Vector2(0.97, 0.96)
    -- self.customTrans.offsetMin = Vector2.zero
    -- self.customTrans.offsetMax = Vector2.zero
    -- self.customTrans.anchorMin = Vector2(0.08, 0.08)
    -- self.customTrans.anchorMax = Vector2(0.98, 0.98)

end

function HeadSlot:HideSlotBg(bool, dis)
    self.image.enabled = (bool == false)

    local dis1 = 0
    if bool == true then
        dis1 = 0
    else
        dis1 = 0.0625
    end
    if dis ~= nil then
        dis1 = dis
    end
    self.customTrans.anchorMin = Vector2(dis1, dis1)
    self.customTrans.anchorMax = Vector2(1-dis1,1-dis1)
    -- self.baseImage.transform.anchorMax = Vector2(1 - dis1, 1 - dis1)
    -- self.baseImage.transform.anchorMin = Vector2(dis1, dis1)
end

function HeadSlot:SetGray(bool)
    if bool == true then
        self.baseLoader.image.color = Color(0.5, 0.5, 0.5)
        for _,list in pairs(self.typeImage) do
            for _,v in pairs(list) do
                v.color = Color(0.5, 0.5, 0.5)
            end
        end
    else
        self.baseLoader.image.color = Color(1, 1, 1)
        for _,list in pairs(self.typeImage) do
            for _,v in pairs(list) do
                v.color = Color(1, 1, 1)
            end
        end
    end
end

function HeadSlot:AddAllListener()
    self:RemoveAllListeners()
    EventMgr.Instance:AddListener(event_name.custom_portrait_update, self.portraitListener)
end

function HeadSlot:SetActive(bol)
    if not BaseUtils.isnull(self.gameObject) and self.gameObject.activeSelf ~= bol then
        self.gameObject:SetActive(bol)
    end
end
