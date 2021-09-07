GodsWarWorShipItem = GodsWarWorShipItem or BaseClass()

function GodsWarWorShipItem:__init(gameObject,parent,id)
    self.id = id
    self.gameObject = gameObject
    self.parent = parent
    self.resources = {
            {file = AssetConfig.fashion_selection_show_big1, type = AssetType.Dep}
            ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}
            ,{file = AssetConfig.fashion_selection_texture, type = AssetType.Dep}

    }
    self.callback = function() self:InitBigBg() end

    self.assetWrapper = AssetBatchWrapper.New()



    self.extra = {inbag = false, nobutton = true}
    self.isActive = true
    self.isCanvasing = true
    self.isCanVote = true
    self:InitPanel()

end
function GodsWarWorShipItem:InitBigBg()
   self.transform:Find("TopBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")

   self.transform:Find("BottomBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2, "FashionSelectionBottom")
end


function GodsWarWorShipItem:InitPanel()
   self.transform = self.gameObject.transform
   self.previewParent = self.transform:Find("Preview")
   self.previewButton = self.transform:Find("Preview"):GetComponent(Button)
   self.previewButton.onClick:AddListener(function() self:ApplyPreviewButton() end)
   self.assetWrapper:LoadAssetBundle(self.resources,self.callback)

   self.titleText = self.transform:Find("TitleBg/Text"):GetComponent(Text)
end

function GodsWarWorShipItem:ApplyPreviewButton()
    -- print("skjflksdjlkfjsd")
    if self.godsWarWorShipData ~= nil then
        -- print("233333333333333")
        local showData = {id = self.godsWarWorShipData.rid, zone_id = self.godsWarWorShipData.zone_id, platform = self.godsWarWorShipData.platfrom, sex = self.godsWarWorShipData.sex, classes = self.godsWarWorShipData.classes, name = self.godsWarWorShipData.name, lev = self.godsWarWorShipData.lev}
        TipsManager.Instance:ShowPlayer(showData)
    end
end

function GodsWarWorShipItem:__delete()
    if self.refreshId ~= nil then
        LuaTimer.Delete(self.refreshId)
        self.refreshId = 0
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function GodsWarWorShipItem:OnOpen()
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
end



function GodsWarWorShipItem:SetData(data,callBack,index)
    self.index = index
    self.newCallBack = nil or callBack
    self.godsWarWorShipData = data
    self.titleText.text = self.godsWarWorShipData.name
    self:UpdateLooks(data.looks)

    -- local looks = BaseUtils.copytab(data.looks)
    -- for i,v in pairs(looks) do
    --     if v.looks_val == 20024 then
    --         v.looks_val = 30006
    --     end
    -- end
    -- self:UpdateLooks(looks)
end


function GodsWarWorShipItem:UpdateLooks(kvlooks)
    self:SetPreviewComp(kvlooks)
end


function GodsWarWorShipItem:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = self.godsWarWorShipData.classes, sex = self.godsWarWorShipData.sex, looks = myLooks}

   if modelData ~= nil then
        local callback = function(composite)
                if self.refreshId ~= nil then
                    LuaTimer.Delete(self.refreshId)
                    self.refreshId = nil
                end
                if self.refreshId == nil then
                    self.refreshId = LuaTimer.Add(500, function()
                            if self.previewComp ~= nil and self.previewComp.loader ~= nil then
                                -- if self.previewComp.loader.weaponLoader.weaponEffect ~= nil then
                                --     self.previewComp.loader.weaponLoader.weaponEffect.gameObject:SetActive(false)
                                -- end

                                -- if self.previewComp.loader.weaponLoader.weaponEffect2 ~= nil then
                                --     self.previewComp.loader.weaponLoader.weaponEffect2.gameObject:SetActive(false)
                                -- end
                            end
                     end)
                end

        end

        if modelData.scale == nil then
            modelData.scale = 3
        else
            modelData.scale = modelData.scale * 3
        end
        if self.previewComp == nil then
            local setting = {
                name = "previewComp" .. self.id
                ,layer = "UI"
                ,parent = self.previewParent.transform
                ,localRot = Vector3(0, 0, 0)
                ,localPos = Vector3(0, -88, -150)
                ,localScale = Vector3(260,260,260)
                ,usemask = true
                ,sortingOrder = 29
            }
            local effectSetting = {
                wingEffect = false,
                weaponEffect = false,
            }
            self.previewComp = PreviewmodelComposite.New(callback, setting, modelData, effectSetting)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function GodsWarWorShipItem:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end
