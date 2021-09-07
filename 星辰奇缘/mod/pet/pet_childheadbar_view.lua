-- ----------------------------------------------------------
-- 子女头像
-- hosr
-- ----------------------------------------------------------
PetChildHeadBar = PetChildHeadBar or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetChildHeadBar:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetChildHeadBar"
    self.resList = {
        {file = AssetConfig.petwindow_childheadbar, type = AssetType.Main}
        , {file = AssetConfig.childhead, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    self.is_show = false

    self.container = nil
    self.headobject = nil
    self.scrollrect = nil

    self.headList = {}
    self.isshow = false

    self._updatepethead = function() self:updatepethead() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currItem = nil
    self.currIndex = 0
    self.headLoaderList = {}
    self.listener = function() self:Update() end
end

function PetChildHeadBar:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self:OnHide()

end

function PetChildHeadBar:OnShow()
    self:OnHide()
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.listener)
    self:Update()
end

function PetChildHeadBar:OnHide()
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.listener)
end

function PetChildHeadBar:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petwindow_childheadbar))
    self.gameObject.name = "PetChildHeadBar"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    self.container = self.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.baseItem = self.container.transform:FindChild("PetHead").gameObject

    self.scrollrect = self.transform:FindChild("HeadBar/mask"):GetComponent(ScrollRect)

    self.init = true
    self:InitItem()
    self:OnShow()
end

function PetChildHeadBar:InitItem()
    for i = 1, 6 do
        local index = i
        local item = PetChildHeadItem.New(GameObject.Instantiate(self.baseItem), self, index)
        item:ShowAdd()
        table.insert(self.headList, item)
    end
end

function PetChildHeadBar:Update()
    local list = ChildrenManager.Instance.childData
    table.sort(list, function(a,b)
            if a.stage == b.stage then
                return a.child_id < b.child_id
            else
                return a.stage > b.stage
            end
        end)

    for i,item in ipairs(self.headList) do
        local dat = list[i]
        if dat ~= nil then
            dat.attach_pet_ids = {}
            for i = 1, #PetManager.Instance.model.petlist do
                local data = PetManager.Instance.model.petlist[i]
                if data.spirit_child_flag == 1 then
                    if data.child_id == dat.child_id and data.platform == dat.platform and data.zone_id == dat.zone_id then
                        table.insert(dat.attach_pet_ids,data.id)
                    end
                end
            end
            item:SetData(dat)


            if #dat.attach_pet_ids > 0 then
                item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
                local attach_pet_id = dat.attach_pet_ids[1]
                local attach_pet_data = self.model:getpet_byid(attach_pet_id)
                local headId = tostring(attach_pet_data.base.head_id)
                local loaderId = item.gameObject:GetInstanceID()
                if self.headLoaderList[loaderId] == nil then
                    self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:FindChild("AttachHeadIcon/Image").gameObject)
                end
                self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
            -- headitem.transform:FindChild("AttachHeadIcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
            else
                item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
            end
        else
            item:ShowAdd()
        end
    end
    -- for i,v in ipairs(list) do
    --     local item = self.headList[i]
    --     item:SetData(v)
    -- end
    self.currIndex = PetManager.Instance.model.currIndex or 0
    if self.currIndex == 0 then
        self.currIndex = 1
    end
    self.headList[self.currIndex]:ClickSelf()
end

function PetChildHeadBar:SelectOne(item, index)
    if item ~= nil and item.data ~= nil then
        if item.data.stage == ChildrenEumn.Stage.Adult then
            -- 正常跳转
            PetManager.Instance.model.currChild = item.data
            PetManager.Instance.model.currIndex = index

            if self.currItem ~= nil then
                self.currItem:Select(false)
            end
            self.currItem = item
            self.currIndex = self.currItem.index
            self.currItem:Select(true)
            self.parent:SelectChild()
        else
            -- 到家园那个界面
            item:Select(false)
            if ChildrenManager.Instance:GetChildhood() ~= nil then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_study_win)
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_get_win)
            end
        end
    end
end