-- 作者:jia
-- 7/4/2017 4:58:31 PM
-- 功能:爵位挑战预览关卡界面

GloryBeforeFightPanel = GloryBeforeFightPanel or BaseClass(BasePanel)
function GloryBeforeFightPanel:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.glorybeforefight, type = AssetType.Main }
        ,{ file = AssetConfig.rank_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.arena_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.half_length, type = AssetType.Dep }
        ,{ file = AssetConfig.attr_icon, type = AssetType.Dep }
        ,{ file = AssetConfig.guard_head, type = AssetType.Dep }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.MyCurID = self.model:GetMyCurID();
    self.CurID = self.MyCurID
    self.isCanRight = false;
    self.isCanLeft = false;
    self.shouhuObjList = { }
    self.CurSHList = { }
    self.CurFormSHList = { }
    self.GuardNum = 4;
    self.guardSelectListener = function(index) self:GuardSelectListener(index) end
    self.formationSelectListener = function(index) self:FormationSelectListener(index) end
    self.UpdateCombatForceListener = function() self:UpdateCombatForce() end
    self.hasInit = false
end

function GloryBeforeFightPanel:UpdateCombatForce()
    self.CurSHList = BaseUtils.copytab(ShouhuManager.Instance.model.my_sh_list)
    self.CurFormSHList = { }
    local formList = FormationManager.Instance.guardList;
    for _, item in pairs(formList) do
        if item.status == 1 then
            self.CurFormSHList[item.number - 1] = item
        end
    end
    -- 阵
    local formationId = FormationManager.Instance.formationId
    local formationLev = FormationManager.Instance.formationLev
    local formationData = DataFormation.data_list[BaseUtils.Key(formationId, formationLev)]
    if formationData ~= nil then
        self.formationText.text = string.format("%sLv.%s", formationData.name, formationLev)
    end
    -- 守护
    if self.shouhuLayout == nil then
        self.shouhuLayout = LuaBoxLayout.New(self.shouhuContainer, { axis = BoxLayoutAxis.X, cspacing = 0, border = 14 })
    end
    local obj = nil
    for i = 1, 4 do
        if self.shouhuObjList[i] == nil then
            obj = GameObject.Instantiate(self.shouhuCloner)
            obj.name = tostring(i)
            self.shouhuObjList[i] = obj
            self.shouhuLayout:AddCell(obj)
            local btn = obj:GetComponent(Button)
            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener( function() self:OnClickGuard(i) end)
        end
    end

    for i = 1, 4 do
        obj = self.shouhuObjList[i]
        local t = obj.transform
        local image = t:Find("Image"):GetComponent(Image)
        local addObj = t:Find("Add").gameObject
        local imgMask = t:Find("ImgMask").gameObject
        local attrObj = t:Find("Attr").gameObject
        local txtUnOpen = t:Find("TxtUnOpen").gameObject
        local shouhuData = self.CurFormSHList[i];
        if shouhuData ~= nil then
            self.model["guardId" .. i] = shouhuData.guard_id
            image.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, shouhuData.guard_id)
            image.gameObject:SetActive(true)
            addObj:SetActive(false)
            -- 处理属性
            local effects = DataFormation.data_list[formationId .. "_" .. formationLev]["attr_" ..(i + 1)]
            if effects ~= nil then
                -- 属性1
                local attrString = ""
                local effect_data = effects[1]
                local arrow1 = t:Find("Attr/Arrow1").gameObject
                if effect_data == nil then
                    arrow1:SetActive(false)
                else
                    attrString = KvData.attr_name_show[effect_data.attr_name]
                    if effect_data.val > 0 then
                        arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                    else
                        arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                    end
                    arrow1:SetActive(true)
                end
                -- 属性2
                effect_data = effects[2]
                local arrow2 = t:Find("Attr/Arrow2").gameObject
                if effect_data == nil then
                    arrow2:SetActive(false)
                else
                    attrString = string.format("%s\n%s", attrString, KvData.attr_name_show[effect_data.attr_name])
                    if effect_data.val > 0 then
                        arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                    else
                        arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                    end
                    arrow2:SetActive(true)
                end
                t:Find("Attr/Text"):GetComponent(Text).text = attrString
                if #effects == 1 then
                    arrow1.transform.localPosition = Vector2(20.9, 3)
                    t:Find("Attr/Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(70, 25)
                else
                    arrow1.transform.localPosition = Vector2(20.9, 12.4)
                    t:Find("Attr/Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(70, 40)
                end
            end
            if effects == nil or #effects == 0 then
                attrObj:SetActive(false)
            else
                attrObj:SetActive(i <= self.GuardNum)
            end
        else
            image.gameObject:SetActive(false)
            addObj:SetActive(true)
            attrObj:SetActive(false)
        end
        imgMask:SetActive(i > self.GuardNum);
        txtUnOpen:SetActive(i > self.GuardNum)
        obj:SetActive(true)
    end

    -- 宠物
    local petData = PetManager.Instance.model.battle_petdata
    local attrObj = self.petAttrObj
    if petData == nil then
        self.petImage.gameObject:SetActive(false)
        self.petAddObj:SetActive(true)
        attrObj:SetActive(false)
    else
        self.petImage.gameObject:SetActive(true)
        local headId = tostring(petData.base.head_id)
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petImage.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,headId)

        -- self.petImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        self.petAddObj:SetActive(false)

        -- 处理属性
        local effects = DataFormation.data_list[formationId .. "_" .. formationLev].pet_attr
        if effects ~= nil then
            -- 属性1
            local attrString = ""
            local effect_data = effects[1]
            local arrow1 = self.petAttrArrow1
            if effect_data == nil then
                arrow1:SetActive(false)
            else
                attrString = KvData.attr_name_show[effect_data.attr_name]
                if effect_data.val > 0 then
                    arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                else
                    arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                end
                arrow1:SetActive(true)
            end
            -- 属性2
            effect_data = effects[2]
            local arrow2 = self.petAttrArrow2
            if effect_data == nil then
                arrow2:SetActive(false)
            else
                attrString = string.format("%s\n%s", attrString, KvData.attr_name_show[effect_data.attr_name])
                if effect_data.val > 0 then
                    arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                else
                    arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                end
                arrow2:SetActive(true)
            end

            self.petAttrText.text = attrString

            if #effects == 1 then
                arrow1.transform.localPosition = Vector2(20.9, 3)
                self.petAttrBgImage.rectTransform.sizeDelta = Vector2(70, 25)
            else
                arrow1.transform.localPosition = Vector2(20.9, 12.4)
                self.petAttrBgImage.rectTransform.sizeDelta = Vector2(70, 40)
            end
        end

        if effects == nil or #effects == 0 then
            attrObj:SetActive(false)
        else
            attrObj:SetActive(true)
        end
    end
end

function GloryBeforeFightPanel:__delete()
    self:RemoveListeners();
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.guardSelect ~= nil then
        self.guardSelect:DeleteMe()
        self.guardSelect = nil
    end
    if self.formationSelect ~= nil then
        self.formationSelect:DeleteMe()
        self.formationSelect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GloryBeforeFightPanel:OnHide()

end

function GloryBeforeFightPanel:OnOpen()
    self:RemoveListeners();
    self:AddListeners();

    self.MyCurID = self.model:GetMyCurID();
    self.CurID = self.MyCurID

    self.guardSelect:Hiden()
    self.formationSelect:Hiden()
    self.formationBtn.onClick:RemoveAllListeners()
    self.formationBtn.onClick:AddListener(
    function()
        self.guardSelect:Hiden()
        if self.formationSelect.isOpen == true then
            self.formationSelect:Hiden()
        else
            self.formationSelect:Show(FormationManager.Instance.formationList, FormationManager.Instance.formationId)
        end
    end )
    self:UpdateData();
end

function GloryBeforeFightPanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.formation_update, self.UpdateCombatForceListener)
    EventMgr.Instance:AddListener(event_name.pet_update, self.UpdateCombatForceListener)
    EventMgr.Instance:AddListener(event_name.guard_position_change, self.UpdateCombatForceListener)
end

function GloryBeforeFightPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.pet_update, self.UpdateCombatForceListener)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.UpdateCombatForceListener)
    EventMgr.Instance:RemoveListener(event_name.guard_position_change, self.UpdateCombatForceListener)
end

function GloryBeforeFightPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryBeforeFightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glorybeforefight))
    self.gameObject.name = "GloryBeforeFightPanel"

    self.transform = self.gameObject.transform

    UIUtils.AddUIChild(self.model.gloryWin.gameObject, self.gameObject)

    self.BtnSelf = self.transform:Find("Panel"):GetComponent(Button);
    self.BtnSelf.onClick:AddListener(
    function()
        self:OnClose();
    end );

    self.Main = self.transform:Find("Main")
    self.BtnClose = self.transform:Find("Main/Close"):GetComponent(Button);
    self.BtnClose.onClick:AddListener(
    function()
        self:OnClose();
    end );

    self.TxtTitle = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.TxtTitle.text = TI18N("爵位挑战");

    self.TxtName = self.transform:Find("Main/Name"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("Main/TextBg/Text"):GetComponent(Text)

    self.BtnChallenge = self.transform:Find("Main/Challenge"):GetComponent(Button);
    self.BtnChallenge.onClick:AddListener(
    function()

        GloryManager.Instance:send14420()
    end );

    self.BtnLeft = self.transform:Find("Main/Left"):GetComponent(Button)
    self.BtnRight = self.transform:Find("Main/Right"):GetComponent(Button)
    self.BtnLeft.onClick:AddListener(
    function()
        self:OnArrow(-1);
    end );
    self.BtnRight.onClick:AddListener(
    function()
        self:OnArrow(1);
    end );
    self.TxtNum = self.transform:Find("Main/Condition/Text"):GetComponent(Text)

    self.formationBtn = self.transform:Find("Main/Formation/"):GetComponent(Button)
    self.formationText = self.transform:Find("Main/Formation/Text"):GetComponent(Text)

    self.petBtn = self.transform:Find("Main/Pet/Icon"):GetComponent(Button)
    self.petImage = self.transform:Find("Main/Pet/Icon/Image"):GetComponent(Image)
    self.petBtn.onClick:AddListener( function() self:OnClickPet() end)

    self.petAttrObj = self.transform:Find("Main/Pet/Icon/Attr").gameObject
    self.petAttrBgImage = self.petAttrObj.transform:Find("Image"):GetComponent(Image)
    self.petAttrArrow1 = self.petAttrObj.transform:Find("Arrow1").gameObject
    self.petAttrArrow2 = self.petAttrObj.transform:Find("Arrow2").gameObject
    self.petAttrText = self.petAttrObj.transform:Find("Text"):GetComponent(Text)
    self.petAddObj = self.transform:Find("Main/Pet/Icon/Add").gameObject

    self.shouhuContainer = self.transform:Find("Main/Guild/Container")
    self.shouhuCloner = self.transform:Find("Main/Guild/Icon").gameObject
    self.shouhuCloner:SetActive(false)

    self.formationSelectArea = self.transform:Find("Main/FormatChangeGuard").gameObject
    self.guardSelectArea = self.transform:Find("Main/TeamChangeGuard").gameObject

    self.guardSelect = ArenaGuardSelect.New(self.model, self.guardSelectArea, self.assetWrapper, self.guardSelectListener)
    self.formationSelect = ArenaFormationSelect.New(self.model, self.formationSelectArea, self.assetWrapper, self.formationSelectListener)

end

function GloryBeforeFightPanel:UpdateData()
    local tmpData = DataGlory.data_level[self.CurID];
    if tmpData ~= nil then
        local offset = self.CurID - self.MyCurID;
        local curStr = "";
        if offset == 0 then
            curStr = TI18N("<color='#ffffaa'>(当前)</color>");
        elseif offset == 1 then
            curStr = TI18N("<color='#ffffaa'>(第2关)</color>");
        else
            curStr = TI18N("<color='#ffffaa'>(第3关)</color>");
        end
        -- 取消当前关卡显示
        curStr = ""
        local nameStr = string.format(TI18N("第%s层 %s %s"), tmpData.id, tmpData.name, curStr);
        self.TxtName.text = nameStr;
        local descstr = tmpData.desc;
        local myfc = RoleManager.Instance.RoleData.fc;
        if tmpData.need_fc > myfc then
            descstr = string.format(TI18N("推荐评分：<color='#ffff00'>%s</color>  我的评分：<color='#ffff00'>%s</color>"), tmpData.need_fc, myfc);
        end
        self.TxtDesc.text = descstr;
        self.GuardNum = tmpData.guard_num;
        self.TxtNum.text = string.format(TI18N("本关可上阵<color='#21E77A'>%s个</color>守护"), self.GuardNum);
        --        local maxLen = DataGlory.data_level_length;
        --        self.isCanRight = self.CurID < maxLen and self.CurID < self.MyCurID + 2;
        --        self.isCanLeft = self.CurID > self.MyCurID;
        self.isCanRight = false;
        self.isCanLeft = false;

        self.BtnRight.gameObject:SetActive(self.isCanRight);
        self.BtnLeft.gameObject:SetActive(self.isCanLeft);
        self:UpdateCombatForce()
    end
end

function GloryBeforeFightPanel:OnArrow(num)
    self.CurID = self.CurID + num
    self:UpdateData()
end

function GloryBeforeFightPanel:OnClose()
    self.model:CloseBeforePanel();
end

function GloryBeforeFightPanel:GuardSelectListener(index)
    local model = ArenaManager.Instance.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.guardSelect:UnSelect(self.guardSelect.lastSelect)
    local tab = self.guardSelect.selectTab
    if self.guardSelect.lastSelect == nil then
        tab[index] = true
        self.guardSelect.lastSelect = index
    elseif self.guardSelect.lastSelect == index then
        tab[index] = false
        self.guardSelect.lastSelect = nil
    else
        tab[self.guardSelect.lastSelect] = false
        tab[index] = true
        self.guardSelect.lastSelect = index
    end
    self.guardSelect:Select(self.guardSelect.lastSelect)

    local selectIndex = self.guardSelect:GetSelection()
    if selectIndex ~= nil then
        local base_id = self.CurSHList[selectIndex].base_id
        local swap_base_id = 0;
        if self.CurFormSHList[self.guardWarId] ~= nil then
            swap_base_id = self.CurFormSHList[self.guardWarId].guard_id
        end
        FormationManager.Instance:Send12905(base_id, 1, swap_base_id)
    end
end

function GloryBeforeFightPanel:FormationSelectListener(index)
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()
    self.formationSelect:UnSelect(self.formationSelect.lastSelect)
    local tab = self.formationSelect.selectTab
    if self.formationSelect.lastSelect ~= nil then
        tab[self.formationSelect.lastSelect] = false
    end
    tab[index] = true
    self.formationSelect.lastSelect = index
    self.formationSelect:Select(self.formationSelect.lastSelect)

    local selectIndex = self.formationSelect:GetSelection()
    if selectIndex ~= nil then
        local selectID = FormationManager.Instance.formationList[selectIndex].id
        FormationManager.Instance:Send12901(selectID);
    end
end

function GloryBeforeFightPanel:OnClickGuard(index)
    self.formationSelect:Hiden()
    local model = ArenaManager.Instance.model
    if self.guardSelect.isOpen == true then
        self.guardSelect:Hiden()
    else
        self.guardWarId = index
        local curBaseId = 0;
        if self.CurFormSHList[index] then
            curBaseId = self.CurFormSHList[index].base_id
        end;
        self.guardSelect:Show(self.CurSHList, index, curBaseId, { id = FormationManager.Instance.formationId, lev = FormationManager.Instance.formationLev })
    end
end

function GloryBeforeFightPanel:OnClickPet()
    local exceptionList = { }
    local attachPetList = PetManager.Instance.model:GetAttachPetList()
    for _, value in ipairs(attachPetList) do
        table.insert(exceptionList, value.id)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function() end, function(data) self:SelectPetCallBack(data) end, 1, exceptionList })
end

function GloryBeforeFightPanel:SelectPetCallBack(data)
    if data ~= nil then
        if ArenaManager.Instance.model.pet_id == data.id then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前宠物已出阵"))
        else
            PetManager.Instance:Send10501(data.id, 1)
        end
    end
end
