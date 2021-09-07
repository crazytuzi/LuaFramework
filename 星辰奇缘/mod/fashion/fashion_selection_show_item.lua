FashionSelectionShowItem = FashionSelectionShowItem or BaseClass()

function FashionSelectionShowItem:__init(gameObject,parent,id)
    self.id = id
    self.gameObject = gameObject
    self.parent = parent
    self.resources = {
            {file = AssetConfig.fashion_selection_show_big1, type = AssetType.Dep}
            ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}

    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.callback = function() self:InitBigBg() end



    self.extra = {inbag = false, nobutton = true}
    self:InitPanel()
end
function FashionSelectionShowItem:InitBigBg()
    self.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")

   self.transform:Find("BottomBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2, "FashionSelectionBottom")
    self.transform:Find("BottomBg").gameObject:SetActive(true)
end

function FashionSelectionShowItem:InitPanel()
   self.transform = self.gameObject.transform
   self.assetWrapper:LoadAssetBundle(self.resources,self.callback)
   self.previewParent = self.transform:Find("FashionPreview")
   self.selectionBtn = self.transform:Find("SelectionBtn"):GetComponent(Button)
   self.selectionImg = self.transform:Find("SelectionBtn"):GetComponent(Image)
   self.selectionBtnText = self.transform:Find("SelectionBtn/Text"):GetComponent(Text)

   self.nameText = self.transform:Find("TitleBg/Text"):GetComponent(Text)
   self.supportText = self.transform:Find("LeftImage/MountText"):GetComponent(Text)

   self.selectionTitleText = self.transform:Find("SelectionBtn/Text"):GetComponent(Text)
   self.selectionBtn.onClick:AddListener(function() self:ApplyLuckyButton() end)

end


function FashionSelectionShowItem:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
end

function FashionSelectionShowItem:OnOpen()
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
end



function FashionSelectionShowItem:SetData(data)
    self.myFashionData = data
    self.nameText.text = DataFashion.data_suit[data.set_id].name
    self.supportText.text = math.floor(self.myFashionData.vote_rate/10) .. "%"
    local data_list = {}
    for k,v in pairs(data.fashion) do
        local myData = DataFashion.data_base[v.value]
        table.insert(data_list, myData)
    end
    self:UpdateLooks(data_list)


end

function FashionSelectionShowItem:UpdateLooks(datalist)
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


function FashionSelectionShowItem:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = self.parent.sex, looks = myLooks}

   if modelData ~= nil then
        local callback = function(composite)
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

function FashionSelectionShowItem:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function FashionSelectionShowItem:ApplyLuckyButton()
    self.parent:OpenLuckyWindow(self.myFashionData)
end
