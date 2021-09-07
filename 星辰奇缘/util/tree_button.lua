-- -----------------------------
-- 树形结构按钮群处理脚本
-- 传入container和对象母本
-- 母本基础结构(可在此基础加自己逻辑资源)
-- --BaseItem
-- ----Select
-- ----Normal
-- ----SubContainer
-- ------SubItem
-- --------Normal
-- --------Select
-- 基础结构必须一致才能用此处理脚本
-- hosr
-- -----------------------------
TBBaseItem = TBBaseItem or BaseClass()
function TBBaseItem:__init()
    self.gameObject = nil
    self.transform = nil
    self.rect = nil
    self.main = nil
    self.isShowSub = false
    self.subContainer = nil
    self.subTab = {}
    self.containerHeight = 0
end

TBButtonItem = TBButtonItem or BaseClass()
function TBButtonItem:__init()
    self.label = TI18N("按钮")
    self.height = 0
    self.gameObject = nil
    self.transform = nil
    self.normal = nil
    self.normalLabel = nil
    self.select = nil
    self.selectLabel = nil
end

TreeButton = TreeButton or BaseClass()
function TreeButton:__init(container, baseItem, callback, mainCallback)
    self.container = container
    self.baseItem = baseItem
    self.callback = callback
    self.mainTab = {}
    self.baseItem:SetActive(false)
    self.clickMainCallback = mainCallback
    self.canRepeat = true

    self.currentIndex = 0
    self.currentSubData = nil

    self.info = nil
end

function TreeButton:__delete()
    if self.petLoader ~= nil then
        self.petLoader:DeleteMe()
        self.petLoader = nil
    end
    self.container = nil
    self.baseItem = nil
    self.callback = nil
    if self.mainTab ~= nil then
        for _,v in pairs(self.mainTab) do
            if v.iconLoader ~= nil then
                v.iconLoader:DeleteMe()
            end
        end
        self.mainTab = nil
    end
    self.clickMainCallback = nil
    self.canRepeat = nil
    self.currentIndex = nil
    self.currentSubData = nil
    self.info = nil
end

function TreeButton:Reset()
    for i,item in ipairs(self.mainTab) do
        item.gameObject:SetActive(false)
    end
end

function TreeButton:HideAll()
    for i,v in ipairs(self.mainTab) do
        v.gameObject:SetActive(false)
    end
    self.currentIndex = 0
end

function TreeButton:ShowAll()
    for i,v in ipairs(self.mainTab) do
        v.gameObject:SetActive(true)
    end
end
-- 这里传人每项显示内容和点击回调参数
-- info = {main1,main2...}
-- main = {label,height,subs={sub1,sub2...},sprite, resize}
-- sub = {label,height,callbackData}
function TreeButton:SetData(info)
    -- print(debug.traceback())
    -- BaseUtils.dump(info,"传入的按钮信息表")
    self:Reset()
    self.info = info
    local mh = 0
    for i,main in ipairs(info) do
        local item = self.mainTab[i]
        if item == nil then
            item = TBBaseItem.New()
            item.gameObject = GameObject.Instantiate(self.baseItem)
            item.transform = item.gameObject.transform
            item.transform:SetParent(self.container.transform)
            item.transform.localScale = Vector3.one
            item.transform.localPosition = Vector3(0, -mh, 0)
            item.rect = item.gameObject:GetComponent(RectTransform)
            item.subContainer = item.transform:Find("SubContainer").gameObject
            item.subContainer:SetActive(false)
            item.baseSubItem = item.subContainer.transform:Find("SubItem").gameObject
            item.baseSubItem:SetActive(false)
            item.button = item.transform:Find("MainButton"):GetComponent(Button)
            local mData = TBButtonItem.New()
            mData.normal = item.transform:Find("MainButton/Normal").gameObject
            mData.normalLabel = mData.normal.transform:Find("Text"):GetComponent(Text)
            mData.select = item.transform:Find("MainButton/Select").gameObject
            mData.selectLabel = mData.select.transform:Find("Text"):GetComponent(Text)
            mData.flagImgTran = item.transform:Find("MainButton/FlagImg")
            if item.transform:Find("MainButton/Icon") ~= nil then
                item.iconLoader = SingleIconLoader.New(item.transform:Find("MainButton/Icon").gameObject)
            end

            if item.transform:Find("MainButton/Notify") ~= nil then
                item.notify = item.transform:Find("MainButton/Notify").gameObject
                item.notify:SetActive(false)
            end
            item.main = mData
            self.mainTab[i] = item
        end
        item.main.isHaveArrow = main.isHaveArrow
        item.main.select:SetActive(false)
        item.main.normal:SetActive(true)
        self:ShowUpDownFlag(item,item.main.isHaveArrow,false)
        item.main.normalLabel.text = main.label
        item.main.selectLabel.text = main.label
        item.main.label = main.label
        item.main.height = main.height
        if main.close == true then
            -- item.gameObject:SetActive(false)
        else
            mh = mh + main.height
        end
        if item.iconLoader ~= nil then
            if main.sprite ~= nil then
                if main.isSprite == true then
                    if self.petLoader == nil then
                        self.petLoader = SingleIconLoader.New(item.iconLoader.image.gameObject)
                    end
                    self.petLoader:SetSprite(SingleIconType.Pet, 10021)
                else
                    item.iconLoader.image.sprite = main.sprite
                end
                if main.resize ~= false then
                    item.iconLoader.image:SetNativeSize()
                end
                item.iconLoader.gameObject.transform.localScale = Vector3.one
                item.iconLoader.gameObject:SetActive(true)
            elseif main.spriteFunc ~= nil then
                main.spriteFunc(item.iconLoader)
                if main.resize ~= false then
                    item.iconLoader.image:SetNativeSize()
                end
                item.iconLoader.gameObject.transform.localScale = Vector3.one
                item.iconLoader.gameObject:SetActive(true)
            else
                item.iconLoader.gameObject:SetActive(false)
            end
        end

        local index = i
        item.button.onClick:RemoveAllListeners()
        item.button.onClick:AddListener(function() self:ClickMain(index) end)
        if main.close == true then
            item.gameObject:SetActive(false)
        else
            item.gameObject:SetActive(true)
        end

        local h = 0
        for j,sub in ipairs(main.subs) do
            local sData = item.subTab[j]
            if sData == nil then
                sData = TBButtonItem.New()
                sData.height = sub.height
                sData.label = sub.label
                sData.gameObject = GameObject.Instantiate(item.baseSubItem)
                sData.gameObject:SetActive(true)
                sData.transform = sData.gameObject.transform
                sData.transform:SetParent(item.subContainer.transform)
                sData.transform.localScale = Vector3.one
                sData.transform.localPosition = Vector3(0, -h, 0)
                sData.button = sData.gameObject:GetComponent(Button)
                sData.normal = sData.transform:Find("Normal").gameObject
                sData.normalLabel = sData.normal.transform:Find("Text"):GetComponent(Text)
                sData.select = sData.transform:Find("Select").gameObject
                sData.selectLabel = sData.select.transform:Find("Text"):GetComponent(Text)
                local transform = sData.transform:Find("Notify")
                if transform ~= nil then
                    sData.notify = transform.gameObject
                    sData.notify:SetActive(false)
                end

                table.insert(item.subTab, sData)
            end
            sData = item.subTab[j]
            sData.select:SetActive(false)
            sData.normal:SetActive(true)
            sData = item.subTab[j]
            sData.normalLabel.text = sub.label
            sData.selectLabel.text = sub.label
            sData.callbackData = sub.callbackData
            sData.button.onClick:RemoveAllListeners()
            sData.button.onClick:AddListener(function() self:ClickSub(sData) end)
            h = h + sub.height + 5
        end

        for j=#main.subs + 1, #item.subTab do
            item.subTab[j].gameObject:SetActive(false)
        end

        item.containerHeight = h
    end

    for i=#info + 1, #self.mainTab do
        self.mainTab[i].gameObject:SetActive(false)
    end

    self:Layout()
end

function TreeButton:Layout()
    local h = 0
    for i,item in ipairs(self.mainTab) do
        item.rect.anchoredPosition = Vector2(0, -h)
        if item.gameObject.activeSelf then
            h = h + item.main.height
        end
        if item.isShowSub and item.containerHeight ~= 0 then
            h = h + item.containerHeight + 5
        end
    end
    self.container:GetComponent(RectTransform).sizeDelta = Vector2(220, h)
end

function TreeButton:ClickMain(index, subIndex)
    local subIndex = subIndex or 1
    if self.canRepeat then
        if self.currentIndex ~= 0 then
            self:HideSub(self.mainTab[self.currentIndex])
        end
        if index ~= self.currentIndex then
            self.currentIndex = index
            if self.clickMainCallback ~= nil and self.currentIndex ~= 0 then
                self.clickMainCallback(self.currentIndex)
            end
            local item = self.mainTab[index]
            self:ShowSub(item)
            self:ClickSub(item.subTab[subIndex])
        else
            self.currentIndex = 0
        end
    else
        if self.currentIndex ~= 0 and index ~= self.currentIndex then
            self:HideSub(self.mainTab[self.currentIndex])
        end

        self.currentIndex = index
        if self.clickMainCallback ~= nil and self.currentIndex ~= 0 then
            self.clickMainCallback(self.currentIndex)
        end
        local item = self.mainTab[index]
        self:ShowSub(item)
        self:ClickSub(item.subTab[subIndex])
    end

    -- if self.clickMainCallback ~= nil and self.currentIndex ~= 0 then
    --     self.clickMainCallback(self.currentIndex)
    -- end
    self:Layout()
end

function TreeButton:ClickSub(data)
    if self.currentSubData ~= nil and self.currentSubData ~= data then
        self.currentSubData.normal:SetActive(true)
        self.currentSubData.select:SetActive(false)
    end

    if data == nil then
        return
    end

    self.currentSubData = data
    self.currentSubData.normal:SetActive(false)
    self.currentSubData.select:SetActive(true)

    if self.callback ~= nil then
        self.callback(data.callbackData)
    end
end

function TreeButton:ShowSub(item)
    item.isShowSub = true
    item.main.normal:SetActive(false)
    item.main.select:SetActive(true)
    item.subContainer:SetActive(true)
    self:ShowUpDownFlag(item,item.main.isHaveArrow,true)
end

function TreeButton:HideSub(item)
    item.isShowSub = false
    item.main.normal:SetActive(true)
    item.main.select:SetActive(false)
    item.subContainer:SetActive(false)
    self:ShowUpDownFlag(item,item.main.isHaveArrow,false)
end

function TreeButton:ShowUpDownFlag(item,bo,flag)
    if item.main.flagImgTran ~= nil then
        item.main.flagImgTran.gameObject:SetActive(bo)
        if bo == true then
            if flag == true then
                item.main.flagImgTran.rotation = Quaternion.Euler(0, 0, 90)
            else
                item.main.flagImgTran.rotation = Quaternion.Euler(0, 0, -90)
            end
        end
    end
end

function TreeButton:RedMain(mainIndex, bool)
    local item = self.mainTab[mainIndex]
    if item ~= nil and item.notify ~= nil then
        item.notify:SetActive(bool)
    end
end

function TreeButton:RedSub(mainIndex, subIndex, bool)
    local item = self.mainTab[mainIndex]
    if item ~= nil then
        local sub = item.subTab[subIndex]
        if sub ~= nil and sub.notify ~= nil then
            sub.notify:SetActive(bool)
        end
    end
end