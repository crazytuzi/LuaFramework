RankTeamShowItem = RankTeamShowItem or BaseClass()

function RankTeamShowItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
    self.transform = self.gameObject.transform

    self.btn = self.transform:GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClickSelf() end)
    self.PreviewParent = self.transform:Find("Preview")
    --self.PreviewParent.gameObject:SetActive(false)
    self.PreviewParent.gameObject:SetActive(true)
    self.Caption = self.transform:Find("Captin")
    self.NameTxt = self.transform:Find("NameTxt"):GetComponent(Text)
    self.ClassIcon = self.transform:Find("ClassIcon"):GetComponent(Image)
    self.ClassTxt = self.transform:Find("CassesTxt"):GetComponent(Text)
    self.LevelTxt = self.transform:Find("LevelTxt"):GetComponent(Text)
    self.PositionTxt = self.transform:Find("PositionTxt"):GetComponent(Text)
    self.Status = self.transform:Find("Status/Text"):GetComponent(Text)
    self.Status.transform.gameObject:SetActive(false)

end

function RankTeamShowItem:__delete()
    if self.refreshId ~= nil then
        LuaTimer.Delete(self.refreshId)
        self.refreshId = nil
    end

    if self.refreshId1 ~= nil then
        LuaTimer.Delete(self.refreshId1)
        self.refreshId1 = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
end

function RankTeamShowItem:Release()

end

--更新内容
function RankTeamShowItem:update_my_self(data, index)
    self.data = data
    self.index = index

    self.Caption.gameObject:SetActive(data.position == 1)
    self.NameTxt.text = data.name
    self.ClassIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
    self.ClassTxt.text = KvData.classes_name[data.classes]
    self.LevelTxt.text = string.format(TI18N("%s级"), data.lev)
    self.PositionTxt.text = tostring(self.index)
    local looks = BaseUtils.copytab(data.looks)
    for i,v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_wing then
            v.looks_mode = 0
        end
    end
    local modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = looks}
    self:LoadModel(modelData)
end

--加载模型
function RankTeamShowItem:LoadModel(modelData)

    local callback = function(composite)
        -- if self.refreshId ~= nil then
        --     LuaTimer.Delete(self.refreshId)
        --     self.refreshId = nil
        -- end
        -- if self.refreshId1 ~= nil then
        --     LuaTimer.Delete(self.refreshId1)
        --     self.refreshId1 = nil
        -- end
        -- local bpwing = composite.tpose.transform:Find("bp_wing")
        -- local bipweapon1 = composite.tpose.transform:Find("Bip_L_Weapon")
        -- local bipweapon2 = composite.tpose.transform:Find("Bip_R_Weapon")
        -- if bpwing ~= nil then
        --     bpwing.gameObject:SetActive(false)
        -- end
        -- if bipweapon1 ~= nil then
        --     bipweapon1.gameObject:SetActive(false)
        -- end
        -- if bipweapon2 ~= nil then
        --     bipweapon2.gameObject:SetActive(false)
        -- end

        -- self.PreviewParent.gameObject:SetActive(true)
        -- local animationData = DataAnimation.data_role_data[BaseUtils.Key(self.data.classes, self.data.sex)]
        -- composite.tpose:GetComponent(Animator):Play("Stand"..animationData.stand_id)

        -- if self.refreshId == nil then
        --     self.refreshId = LuaTimer.Add(1000, function()
        --         if BaseUtils.isnull(self.gameObject) then return end
        --         if self.previewComp ~= nil and self.previewComp.loader ~= nil then
        --             if self.previewComp.loader.weaponLoader.weaponEffect ~= nil then
        --                 self.previewComp.loader.weaponLoader.weaponEffect.gameObject:SetActive(false)
        --             end

        --             if self.previewComp.loader.weaponLoader.weaponEffect2 ~= nil then
        --                 self.previewComp.loader.weaponLoader.weaponEffect2.gameObject:SetActive(false)
        --             end

        --             if self.previewComp.loader.wingLoader ~= nil and self.previewComp.loader.wingLoader.effectCache ~= nil then
        --                 for i,v in pairs(self.previewComp.loader.wingLoader.effectCache) do
        --                     v.effect.gameObject:SetActive(false)
        --                 end
        --             end
        --             if not BaseUtils.isnull(bpwing) then
        --                 bpwing.gameObject:SetActive(true)
        --             end
        --             if not BaseUtils.isnull(bipweapon1) then
        --                 bipweapon1.gameObject:SetActive(true)
        --             end
        --             if not BaseUtils.isnull(bipweapon2) then
        --                 bipweapon2.gameObject:SetActive(true)
        --             end
        --             -- composite.tpose.transform:Find("bp_wing").gameObject:SetActive(true)
        --             -- composite.tpose.transform:Find("Bip_L_Weapon").gameObject:SetActive(true)
        --             -- composite.tpose.transform:Find("Bip_R_Weapon").gameObject:SetActive(true)
        --             local animationData = DataAnimation.data_role_data[BaseUtils.Key(self.data.classes, self.data.sex)]
        --             composite.tpose:GetComponent(Animator):Play("Stand"..animationData.stand_id)
        --         end
        --     end)
        -- end
    end

    if self.previewComp == nil then
        local setting = {
            name = string.format("RolePreview_%s", self.index)
            ,layer = "UI"
            ,parent = self.PreviewParent
            ,localRot = Vector3(0, 0, 0)
            ,localPos = Vector3(0, -80, -150)
            ,usemask = true
            ,sortingOrder = 10
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


function RankTeamShowItem:OnClickSelf()
    if self.data ~= nil then
        --BaseUtils.dump(self.data,"RankTeamShowItem")
        --self.data.roleid = self.data.role_id
        --TipsManager.Instance:ShowPlayer(self.data)
    end
end