-- 宠物仓库面板
-- @author zgs
PetStorePanel = PetStorePanel or BaseClass(BasePanel)

function PetStorePanel:__init(model,parent)
    self.model = model
    self.name = "PetStorePanel"
    self.parent = parent

    self.isSelectedDefault = false

    self.resList = {
        {file = AssetConfig.petstoreitems_panel, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePetUpdateEvent()
    end)
    self.lastSelectItem = nil
    self.itemDataTimeDic = {}
    self.selectedType = 0 --选中类型。 0表示不选中，1表示选中仓库宠物，2表示选中携带宠物
    self.hideSelectedTaken = function ()
        self:HideSelectedTakenGrid()
    end
    self.hideSelectedStore = function ()
        self:HideSelectedStoreGrid()
    end

    self.petUpdateFun = function ()
        self:UpdateTakenPet()
    end

    self.petStoreUpdateFun = function ()
        if self.itemGps ~= nil then
            self:UpdateStorePet()
        end
    end

    self.petreleasepanel = nil
    self.headLoaderList = {}
    -- EventMgr.Instance:AddListener(event_name.pet_update, self.petUpdateFun)
    EventMgr.Instance:AddListener(event_name.petstore_update, self.petStoreUpdateFun)
end

function PetStorePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function PetStorePanel:__delete()

    -- EventMgr.Instance:RemoveListener(event_name.pet_update, self.petUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.petstore_update, self.petStoreUpdateFun)

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
    end
    self.itemStoreDic = {}
    self.itemTakenDic = {}
    self:AssetClearAll()
    self:RemovePetUpdateEvent()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function PetStorePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petstoreitems_panel))
    self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent, self.gameObject)

    self.storeBtnImg = self.transform:Find("StoreButton"):GetComponent(Image)
    self.storeBtn = self.transform:Find("StoreButton"):GetComponent(Button)
    self.storeBtn.onClick:AddListener(function ()
        self:ClickStoreBtn()
    end)
    self.getBtnImg = self.transform:Find("GetButton"):GetComponent(Image)
    self.getBtn = self.transform:Find("GetButton"):GetComponent(Button)
    self.getBtn.onClick:AddListener(function ()
        self:ClickGetBtn()
    end)
    self.freeBtn = self.transform:Find("FreeButton"):GetComponent(Button)
    self.freeBtn.onClick:AddListener(function ()
        -- self:ClickFreeBtn()
        if self.selectedType ~= 0 then
            if self.lastSelectItem ~= nil then
                -- if self.selectedType == 1 then
                --     self.model.lastFreeType = 1
                --     PetManager.Instance:Send10532(self.lastSelectItem.dataItem.id)
                -- elseif self.selectedType == 2 then
                --     self.model.lastFreeType = 2
                --     PetManager.Instance:Send10522(self.lastSelectItem.dataItem.id)
                -- end
                -- self:Reset()
                local petData = self.lastSelectItem.dataItem
                if petData.lev < 50 then
                    self.petreleasepanel = PetReleasePanel.New(self, petData.id, self.selectedType)
                    self.petreleasepanel:Show()
                else
                    if petData.lock == 1 then
                        NoticeManager.Instance:FloatTipsByString(TI18N("该宠物已锁定，无法进行炼化"))
                    elseif petData.status == 1 then
                        NoticeManager.Instance:FloatTipsByString(TI18N("该宠物当前处于<color='#ffff00'>出战状态</color>，无法炼化"))
                    elseif petData.genre == 2 or petData.genre == 4 then
                        NoticeManager.Instance:FloatTipsByString(TI18N("无法炼化<color='#ffff00'>神兽/珍兽</color>"))
                    else
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petartificewindow, { petData })
                    end
                end
            end
        else
            if self.freeBtnText.text == TI18N("放 生") then
                NoticeManager.Instance:FloatTipsByString(TI18N("请选择要放生的宠物"))
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请选择要炼化的宠物"))
            end
        end
    end)
    self.freeBtnText = self.transform:Find("FreeButton/Text"):GetComponent(Text)

    self.selectedGridStore = self.transform:Find("PetStore/LbgImage/Image").gameObject
    self.selectedGridStore:SetActive(false)
    self.gridPetStore = self.transform:Find("PetStore/LMask/Grid")
    self.itemGps = self.gridPetStore:Find("Item").gameObject
    self.itemGps.transform:Find("SelectedImage"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Select2")
    self.itemGps:SetActive(false)
    self.gpsLayout = LuaBoxLayout.New(self.gridPetStore.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.itemStoreDic = {}

    self.selectedGridTaken = self.transform:Find("PetTaken/LbgImage/Image").gameObject
    self.selectedGridTaken:SetActive(false)
    self.gridPetTaken = self.transform:Find("PetTaken/LMask/Grid")
    self.itemGpt = self.gridPetTaken:Find("Item").gameObject
    self.itemGpt:SetActive(false)
    self.gptLayout = LuaBoxLayout.New(self.gridPetTaken.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.itemTakenDic = {}

    self:SetSelect(0,nil)

    self:InitStorePet()
    self:InitTakenPet()
end

--初始化仓库宠物
function PetStorePanel:InitStorePet()
    local totalCnt = self.model.pet_nums + 1
    local max = 0
    for _,val in pairs(DataPet.data_store_pet_grid) do
        if max <= val.pet_nums then 
            max = val.pet_nums
        end
    end

    if totalCnt > max + 1 then
        totalCnt = max + 1
    end
    for i=1,totalCnt do
        local itemTaken = self.itemStoreDic[i]
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemGps)
            obj.name = tostring(i)

            self.gpsLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = nil,
                isLock = false,
                btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("NameText"):GetComponent(Text),
                levText = obj.transform:Find("LevText"):GetComponent(Text),
                scoreText = obj.transform:Find("ScoreText"):GetComponent(Text),
                descText = obj.transform:Find("DescText"):GetComponent(Text),
                -- fightFlag = obj.transform:Find("FightFlag").gameObject,
                img = obj.transform:Find("HeadImageBg/Image"):GetComponent(Image),
                genreImg = obj.transform:Find("GenreImg"):GetComponent(Image),
                lock = obj.transform:Find("HeadImageBg/Lock").gameObject,
                selectedImgObj = obj.transform:Find("SelectedImage").gameObject,
            }
            self.itemStoreDic[i] = itemDic
            itemTaken = itemDic

            itemDic.btn.onClick:AddListener(function ()
                self:ClickStoreItem(i)
            end)
        end
        itemTaken.isLock = false
        itemTaken.dataItem = nil
        itemTaken.lock:SetActive(false)
        itemTaken.thisObj:SetActive(true)
        itemTaken.nameText.text = ""
        itemTaken.levText.text = ""
        itemTaken.scoreText.text = ""
        itemTaken.descText.text = ""
        itemTaken.genreImg.gameObject:SetActive(false)
        -- itemTaken.fightFlag:SetActive(data.status == 1)
        -- if self.lastSelectItem ~= nil and self.lastSelectItem.thisObj == itemTaken.thisObj then
        --     itemTaken.selectedImgObj:SetActive(true)
        -- else
        --     itemTaken.selectedImgObj:SetActive(false)
        -- end
        itemTaken.selectedImgObj:SetActive(false)
        itemTaken.img.gameObject:SetActive(false)
        if self.model.pet_nums < max and i == self.model.pet_nums + 1 then
            itemTaken.isLock = true
            itemTaken.lock:SetActive(true)
        end
    end
end

--初始化携带宠物
function PetStorePanel:InitTakenPet()
    for i=1,PetManager.Instance.model.pet_nums do
        local itemTaken = self.itemTakenDic[i]
        -- BaseUtils.dump(data,"PetManager.Instance.model.petlist[i]")
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemGpt)
            obj.name = tostring(i)

            self.gptLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = nil,
                isLock = false,
                btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("NameText"):GetComponent(Text),
                levText = obj.transform:Find("LevText"):GetComponent(Text),
                scoreText = obj.transform:Find("ScoreText"):GetComponent(Text),
                descText = obj.transform:Find("DescText"):GetComponent(Text),
                fightFlag = obj.transform:Find("FightFlag"):GetComponent(Image),
                img = obj.transform:Find("HeadImageBg/Image"):GetComponent(Image),
                genreImg = obj.transform:Find("GenreImg"):GetComponent(Image),
                selectedImgObj = obj.transform:Find("SelectedImage").gameObject,
            }
            self.itemTakenDic[i] = itemDic
            itemTaken = itemDic
            itemTaken.fightFlag.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_PetBattle")

            itemDic.btn.onClick:AddListener(function ()
                self:ClickTakenItem(i)
            end)
        end
        itemTaken.dataItem = nil
        itemTaken.thisObj:SetActive(true)
        itemTaken.nameText.text = ""
        itemTaken.levText.text = ""
        itemTaken.scoreText.text = ""
        itemTaken.descText.text = ""
        itemTaken.fightFlag.gameObject:SetActive(false)
        itemTaken.selectedImgObj:SetActive(false)
        itemTaken.genreImg.gameObject:SetActive(false)

        itemTaken.img.gameObject:SetActive(false)
    end
end

--存入
function PetStorePanel:ClickStoreBtn()
    if self.selectedType == 2 then
        local takenItem = self.lastSelectItem
        self:StoreIn(takenItem)
    else
        if #PetManager.Instance.model.petlist <= 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有可存入的宠物"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要存入的宠物"))
            self.selectedGridTaken:SetActive(true)
            LuaTimer.Add(1000,self.hideSelectedTaken)
        end
    end
end
function PetStorePanel:HideSelectedTakenGrid()
    self.selectedGridTaken:SetActive(false)
end
--取出
function PetStorePanel:ClickGetBtn()
    if self.selectedType == 1 then
        local takenItem = self.lastSelectItem
        self:GetOut(takenItem)
    else
        if #self.model.petlist <=0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("仓库没有可取出的宠物"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要取出的宠物"))
            self.selectedGridStore:SetActive(true)
            LuaTimer.Add(1000,self.hideSelectedStore)
        end
    end
end
function PetStorePanel:HideSelectedStoreGrid()
    if self.selectedGridStore ~= nil then
        self.selectedGridStore:SetActive(false)
    end
end
--放生
function PetStorePanel:ClickFreeBtn()
    if self.selectedType ~= 0 then
        if self.lastSelectItem ~= nil then
            if (#self.model.petlist + #PetManager.Instance.model.petlist) == 1 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Sure
                data.content = TI18N("你舍得抛弃最后的伙伴吗？")
                data.sureLabel = TI18N("确认")
                NoticeManager.Instance:ConfirmTips(data)
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("你确定要将<color='#00ff00'>%s lv.%s</color>放生吗"), self.lastSelectItem.dataItem.name, self.lastSelectItem.dataItem.lev)
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    if self.selectedType == 1 then
                        self.model.lastFreeType = 1
                        PetManager.Instance:Send10532(self.lastSelectItem.dataItem.id)
                    elseif self.selectedType == 2 then
                        self.model.lastFreeType = 2
                        PetManager.Instance:Send10522(self.lastSelectItem.dataItem.id)
                    end
                    self:Reset()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要放生的宠物"))
    end
end

function PetStorePanel:UpdateWindow()
    self.isSelectedDefault = false
    PetManager.Instance.OnUpdatePetList:Add(self.petUpdateFun)
    self:UpdateStorePet()
    self:UpdateTakenPet()
end
--刷新仓库宠物
function PetStorePanel:UpdateStorePet()
    self:InitStorePet()
    for i=1,#self.model.petlist do
        local itemTaken = self.itemStoreDic[i]
        local data = self.model.petlist[i]
        -- BaseUtils.dump(data,"self.model.petlist[i]")
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemGps)
            obj.name = tostring(i)

            self.gpsLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = data,
                isLock = false,
                btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("NameText"):GetComponent(Text),
                levText = obj.transform:Find("LevText"):GetComponent(Text),
                scoreText = obj.transform:Find("ScoreText"):GetComponent(Text),
                descText = obj.transform:Find("DescText"):GetComponent(Text),
                -- fightFlag = obj.transform:Find("FightFlag").gameObject,
                img = obj.transform:Find("HeadImageBg/Image"):GetComponent(Image),
                genreImg = obj.transform:Find("GenreImg"):GetComponent(Image),
                lock = obj.transform:Find("HeadImageBg/Lock").gameObject,
                selectedImgObj = obj.transform:Find("SelectedImage").gameObject,
            }
            self.itemStoreDic[i] = itemDic
            itemTaken = itemDic

            itemDic.btn.onClick:AddListener(function ()
                self:ClickStoreItem(i)
            end)
        end
        itemTaken.dataItem = data
        itemTaken.lock:SetActive(false)
        itemTaken.thisObj:SetActive(true)
        itemTaken.descText.text = TI18N("评分")
        itemTaken.nameText.text = data.name
        --BaseUtils.dump(itemTaken,"itemTaken仓库宠物数据：")
        itemTaken.levText.text = string.format(TI18N("%s级"), data.lev)
        itemTaken.scoreText.text = string.format("%s(%d)",PetManager.Instance.model:gettalentclass(data.talent),data.talent)
        -- itemTaken.fightFlag:SetActive(data.status == 1)
        -- if self.lastSelectItem ~= nil and self.lastSelectItem.thisObj == itemTaken.thisObj then
        --     itemTaken.selectedImgObj:SetActive(true)
        -- else
        --     itemTaken.selectedImgObj:SetActive(false)
        -- end
        itemTaken.selectedImgObj:SetActive(false)
        itemTaken.img.gameObject:SetActive(true)
        local headId = tostring(data.base.head_id)
        local loaderId = itemTaken.img.gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(itemTaken.img.gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
        -- itemTaken.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        itemTaken.genreImg.gameObject:SetActive(true)
        if data.genre == 6 then
            itemTaken.genreImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.genre-5)))
        else
            itemTaken.genreImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.genre+1)))
        end
    end
    -- for i=#self.model.petlist + 1,#self.itemStoreDic do
    --     local v = self.itemStoreDic[i]
    --     if BaseUtils.isnull(v.thisObj) == false then
    --         v.thisObj:SetActive(false)
    --     end
    -- end
end

function PetStorePanel:ClickStoreItem(index)
    local takenItem = self.itemStoreDic[index]
    if takenItem ~= nil and takenItem.dataItem ~= nil then
        self:SetSelect(1,takenItem)
        self.model.lastFreeType = 1

        local timeTemp = os.time()
        local lastTime = self.itemDataTimeDic[takenItem.dataItem.id]
        if lastTime == nil then
            lastTime = 0
        end
        local timeBetween = timeTemp - lastTime
        self.itemDataTimeDic[takenItem.dataItem.id] = timeTemp
        if timeBetween < 1 then
            self:StoreDoubleClick(takenItem)
        end
    elseif takenItem ~= nil then
        if takenItem.isLock == true then
            local priceItem = DataPet.data_store_pet_grid[index - 1]
            if priceItem ~= nil then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("增加1格宠物仓库，需要消耗{assets_1, %d,%d}"),priceItem.need_item[1].item_id,priceItem.need_item[1].item_val)
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function ()
                    PetManager.Instance:Send10533()
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                Log.Error("仓库格子缺少配置，ID="..tostring(index))
            end
        end
    end
end
--双击仓库宠物，从仓库取出
function PetStorePanel:StoreDoubleClick(takenItem)
    self:GetOut(takenItem)
end
--从仓库取出
function PetStorePanel:GetOut(takenItem)
    if #PetManager.Instance.model:GetMasterPetList() >= PetManager.Instance.model.pet_nums then
        NoticeManager.Instance:FloatTipsByString(TI18N("可携带宠物空间不足，请清理"))
        return
    end
    -- BaseUtils.dump(takenItem,"PetStorePanel:GetOut(takenItem)")
    PetManager.Instance:Send10530(takenItem.dataItem.id)
    self:Reset()
end
--刷新携带宠物
function PetStorePanel:UpdateTakenPet()
    if BaseUtils.isnull(self.itemGpt) then
        return
    end
    self:InitTakenPet()
    for i=1,#PetManager.Instance.model.petlist do
        local itemTaken = self.itemTakenDic[i]
        local data = PetManager.Instance.model.petlist[i]
        -- BaseUtils.dump(data,"PetManager.Instance.model.petlist[i]")
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemGpt)
            obj.name = tostring(i)

            self.gptLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = data,
                isLock = false,
                btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("NameText"):GetComponent(Text),
                levText = obj.transform:Find("LevText"):GetComponent(Text),
                scoreText = obj.transform:Find("ScoreText"):GetComponent(Text),
                descText = obj.transform:Find("DescText"):GetComponent(Text),
                fightFlag = obj.transform:Find("FightFlag"):GetComponent(Image),
                img = obj.transform:Find("HeadImageBg/Image"):GetComponent(Image),
                genreImg = obj.transform:Find("GenreImg"):GetComponent(Image),
                selectedImgObj = obj.transform:Find("SelectedImage").gameObject,
            }
            self.itemTakenDic[i] = itemDic
            itemTaken = itemDic
            itemTaken.fightFlag.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "I18N_PetBattle")

            itemDic.btn.onClick:AddListener(function ()
                self:ClickTakenItem(i)
            end)
        end
        itemTaken.dataItem = data
        itemTaken.thisObj:SetActive(true)
        itemTaken.descText.text = TI18N("评分")
        itemTaken.nameText.text = data.name
        itemTaken.levText.text = string.format(TI18N("%s级"), data.lev)
        --BaseUtils.dump(itemTaken,"itemTaken携带宠物数据：")
        itemTaken.scoreText.text = string.format("%s(%d)",PetManager.Instance.model:gettalentclass(data.talent),data.talent)
        itemTaken.fightFlag.gameObject:SetActive(data.status == 1)
        -- self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (petData.genre+1)))
        -- if self.lastSelectItem ~= nil and self.lastSelectItem.thisObj == itemTaken.thisObj then
        --     itemTaken.selectedImgObj:SetActive(true)
        -- else
        --     itemTaken.selectedImgObj:SetActive(false)
        -- end
        itemTaken.selectedImgObj:SetActive(false)
        itemTaken.img.gameObject:SetActive(true)
        local headId = tostring(data.base.head_id)
        local loaderId = itemTaken.img.gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(itemTaken.img.gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
        -- itemTaken.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        itemTaken.genreImg.gameObject:SetActive(true)
        --itemTaken.genreImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.genre+1)))
        if data.genre == 6 then
            itemTaken.genreImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.genre-5)))
        else
            itemTaken.genreImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", (data.genre+1)))
        end
        if self.isSelectedDefault == false and data.status ~= 1 then
            self.isSelectedDefault = true
            self:ClickTakenItem(i)
        end
    end
    if self.isSelectedDefault == false then
        self.isSelectedDefault = true
    end
    for i=#PetManager.Instance.model.petlist + 1,#self.itemTakenDic do
        local v = self.itemTakenDic[i]
        if BaseUtils.isnull(v.thisObj) == false then
            v.thisObj:SetActive(false)
        end
    end
end

function PetStorePanel:ClickTakenItem(index)
    local takenItem = self.itemTakenDic[index]
    if takenItem ~= nil and takenItem.dataItem ~= nil then
        self:SetSelect(2,takenItem)
        self.model.lastFreeType = 2

        local timeTemp = os.time()
        local lastTime = self.itemDataTimeDic[takenItem.dataItem.id]
        if lastTime == nil then
            lastTime = 0
        end
        local timeBetween = timeTemp - lastTime
        self.itemDataTimeDic[takenItem.dataItem.id] = timeTemp
        if timeBetween < 1 then
            self:TakenDoubleClick(takenItem)
        end
    end
end
--双击携带宠物，存入仓库
function PetStorePanel:TakenDoubleClick(takenItem)
    self:StoreIn(takenItem)
end
--存入仓库
function PetStorePanel:StoreIn(takenItem)
    if takenItem.dataItem.status == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("出战中的宠物不能存入仓库"))
        return
    elseif takenItem.dataItem.genre + 1 == 4 then
        NoticeManager.Instance:FloatTipsByString(TI18N("野生宠物不能存入仓库"))
        return
    elseif #self.model.petlist >= self.model.pet_nums then
        NoticeManager.Instance:FloatTipsByString(TI18N("宠物仓库空间不足，请清理"))
        return
    end
    -- BaseUtils.dump(takenItem,"PetStorePanel:StoreIn(takenItem)")
    PetManager.Instance:Send10529(takenItem.dataItem.id)
    self:Reset()
end

function PetStorePanel:SetSelect(typeV,item)
    -- BaseUtils.dump(self.lastSelectItem)
    self.selectedType = typeV
    if self.lastSelectItem ~= nil then
        self.lastSelectItem.selectedImgObj:SetActive(false)
    end
    self.lastSelectItem = item
    if self.lastSelectItem ~= nil then
        self.lastSelectItem.selectedImgObj:SetActive(true)
    end

    if self.selectedType == 0 then
        self.storeBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.getBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    elseif self.selectedType == 1 then
        self.storeBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.getBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    elseif self.selectedType == 2 then
        self.storeBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.getBtnImg.sprite =  PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    end

    if self.lastSelectItem ~= nil then
        local petData = self.lastSelectItem.dataItem
        if petData ~= nil and petData.lev < 50 then
            self.freeBtnText.text = TI18N("放 生")
        else
            self.freeBtnText.text = TI18N("炼 化")
        end
    end
end

function PetStorePanel:Reset()
    self:SetSelect(0,nil)
end
--移除宠物更新事件
function PetStorePanel:RemovePetUpdateEvent()
    PetManager.Instance.OnUpdatePetList:Remove(self.petUpdateFun)
end

