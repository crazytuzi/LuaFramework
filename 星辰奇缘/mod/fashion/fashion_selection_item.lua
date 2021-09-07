FashionSelectionItem = FashionSelectionItem or BaseClass()

function FashionSelectionItem:__init(gameObject,parent,id)
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
function FashionSelectionItem:InitBigBg()
   self.transform:Find("TopBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")

   self.transform:Find("BottomBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2, "FashionSelectionBottom")
end


function FashionSelectionItem:InitPanel()
   self.transform = self.gameObject.transform
   self.previewParent = self.transform:Find("FashionPreview")
   self.assetWrapper:LoadAssetBundle(self.resources,self.callback)
   self.selectionBtn = self.transform:Find("SelectionBtn"):GetComponent(Button)
   self.selectionBtnText = self.transform:Find("SelectionBtn/Text"):GetComponent(Text)
   self.selectionBtnIcon = self.transform:Find("SelectionBtn/Icon")
   self.selectionImg = self.transform:Find("SelectionBtn"):GetComponent(Image)
   self.selectionBtn.onClick:AddListener(function()
        local baseTime = BaseUtils.BASE_TIME
        local day = tonumber(os.date("%d",baseTime))
        local startDay = DataCampaign.data_list[self.parent.campId].cli_start_time[1][3]
        local distance = day - startDay
        print(distance)
        local mount = 0
        local itemId = 29929
        if distance == 0 then
            mount = BackpackManager.Instance:GetItemCount(29929)
            itemId = 29929
        elseif distance == 1 then
            mount = BackpackManager.Instance:GetItemCount(29930)
            itemId = 29930
        elseif distance == 2 then
            mount = BackpackManager.Instance:GetItemCount(29931)
            itemId = 29931
        end

        if mount <= 0 then
            local itemData = ItemData.New()
            print(itemId)
            itemData:SetBase(DataItem.data_get[itemId])
            TipsManager.Instance:ShowItem({gameObject = self.selectionBtn.gameObject, itemData = itemData})

        else

            if self.isCanVote == true then
                self.parent:ApplyVoteButton(self.myFashionData)
            else

            end
        end

        if self.isCanVote == true and mount<= 0 then
            NoticeManager.Instance:FloatTipsByString("请前往邮箱领取投票券吧{face_1,3}")
        elseif self.isCanVote == false then
            NoticeManager.Instance:FloatTipsByString("今天已经完成投票，感谢参与{face_1,3}")
        end
    end)

   self.selectionTitleText = self.transform:Find("SelectionBtn/Text"):GetComponent(Text)
   self.helpButton = self.transform:Find("HelpBtn"):GetComponent(Button)
   self.helpButton.onClick:AddListener(function()
        if self.isCanvasing == true then
            self.parent:ApplyFriendHelpButton(self.myFashionData,self.kvLooks[SceneConstData.looktype_weapon])
        else
             NoticeManager.Instance:FloatTipsByString("今日拉票已结束")
        end
   end)
   self.helpBtnText = self.transform:Find("HelpBtn/Text"):GetComponent(Text)
   self.helpRed = self.transform:Find("HelpBtn/RedPoint")

   self.titleText = self.transform:Find("TitleBg/Text"):GetComponent(Text)


end


function FashionSelectionItem:__delete()
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

function FashionSelectionItem:OnOpen()
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
end



function FashionSelectionItem:SetData(data,callBack,index)
    self.index = index
    self.newCallBack = nil or callBack
    self.myFashionData = data
    local data_list = {}
    for k,v in pairs(data.fashion) do
        local myData = DataFashion.data_base[v.value]
        table.insert(data_list, myData)
    end

    self:UpdateLooks(data_list)
    self.titleText.text = DataFashion.data_suit[data.set_id].name

end

function FashionSelectionItem:SetButtonStatus()
    local isHasVote = false
    if FashionSelectionManager.Instance.fashionRoleData.vote_group ~= nil then
        for k,v in pairs(FashionSelectionManager.Instance.fashionRoleData.vote_group) do
            if v.group_id == self.myFashionData.group_id then
                isHasVote = true
                break
            end
        end
    end
    if isHasVote == true and FashionSelectionManager.Instance.fashionRoleData.vote_times ==0 then


        self.selectionBtnIcon.gameObject:SetActive(false)
        self.selectionBtnText.text = "已投票"
        self.selectionBtn.transform.anchoredPosition = Vector2(-50,-141)
        self.selectionBtnText.transform.anchoredPosition = Vector2(0,0)
    else
        self.selectionBtnText.text = "投票"
        self.selectionBtnIcon.gameObject:SetActive(true)
        self.selectionBtn.transform.anchoredPosition = Vector2(0,-141)
        self.selectionBtnText.transform.anchoredPosition = Vector2(11.1,0)

    end

    if isHasVote == true then
        self.helpButton.transform.anchoredPosition = Vector2(32.6,-140)
        self.helpButton.gameObject:SetActive(true)
        self.selectionBtn.transform.anchoredPosition = Vector2(-50,-141)
        -- self.selectionBtnText.transform.anchoredPosition = Vector2(0,0)
    else
        self.helpButton.gameObject:SetActive(false)
        self.selectionBtn.transform.anchoredPosition = Vector2(0,-141)
        -- self.selectionBtnText.transform.anchoredPosition = Vector2(11.1,0)
    end


    if FashionSelectionManager.Instance.fashionRoleData.vote_times > 0 then
        self.selectionBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.selectionBtnText.color = ColorHelper.DefaultButton3

        self.isCanVote = true
    else
        self.selectionBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.selectionBtnText.color = ColorHelper.DefaultButton4

        self.isCanVote = false
    end


    if FashionSelectionManager.Instance.fashionRoleData.invite_votes > 0 then
        self.helpButton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.helpBtnText.color = ColorHelper.DefaultButton3
        self.helpRed.gameObject:SetActive(true)
        self.isCanvasing = true
    else
        self.helpButton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.helpBtnText.color = ColorHelper.DefaultButton4
        self.helpRed.gameObject:SetActive(false)
        self.isCanvasing = false
    end
end

function FashionSelectionItem:UpdateLooks(datalist)
    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)

    self.kvLooks = {}
    for k2,v2 in pairs(unitData.looks) do
        self.kvLooks[v2.looks_type] = v2
    end

    for k,v in pairs(datalist) do
        self.kvLooks[v.type] = {looks_str = "", looks_val = v.model_id, looks_mode = v.texture_id, looks_type = v.type}
    end

    if self.kvLooks[SceneConstData.looktype_wing] ~= nil then
        self.kvLooks[SceneConstData.looktype_wing] = nil
    end

    self:SetPreviewComp(self.kvLooks)
end


function FashionSelectionItem:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = myLooks}

   if modelData ~= nil then
        local callback = function(composite)
                if self.refreshId ~= nil then
                    LuaTimer.Delete(self.refreshId)
                    self.refreshId = nil
                end
                if self.refreshId == nil then
                    self.refreshId = LuaTimer.Add(500, function()
                            if self.previewComp ~= nil and self.previewComp.loader ~= nil then
                                if self.previewComp.loader.weaponLoader.weaponEffect ~= nil then
                                    self.previewComp.loader.weaponLoader.weaponEffect.gameObject:SetActive(false)
                                end

                                if self.previewComp.loader.weaponLoader.weaponEffect2 ~= nil then
                                    self.previewComp.loader.weaponLoader.weaponEffect2.gameObject:SetActive(false)
                                end
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
                ,localPos = Vector3(0, -102, -150)
                ,localScale = Vector3(260,260,260)
                ,usemask = false
                ,sortingOrder = 21
            }
            self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function FashionSelectionItem:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end
