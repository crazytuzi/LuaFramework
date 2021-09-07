-- ------------------------------
-- 诸神之战 -- 荣誉积分排行榜
-- hosr
-- ------------------------------
GodsWarJiFenRankPanel = GodsWarJiFenRankPanel or BaseClass(BasePanel)

function GodsWarJiFenRankPanel:__init(parent)

    self.parent = parent
    self.resList = {
        {file = AssetConfig.godswarjifenrankgepanel, type = AssetType.Main},
        {file = AssetConfig.attr_icon,type = AssetType.Dep},
        {file = AssetConfig.godswartexture,type = AssetType.Dep}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currIndex = 0
    self.panelList = {}
    self.mainTextList = {}
    self.showFuncTab = {}
    self.mainButtonList = {}
    self.subButtonList = {}
    self.mainImageList = {}
    self.subImageList = {}
    self.subTextList = {}
    self.subOpenList = {}

    self.rank_type = {
        Lev = 1 --1等级
        ,Pet = 2 --2:宠物
        ,Shouhu = 3 --3:守护
        ,RenQiHistory = 4 --4 历史人气
        ,SendFlower = 5  -- 送花
        ,GetFlower = 6 -- 收花
        ,Weapon = 10 --10:武器
        ,Cloth = 11 --11:衣服
        ,Belt = 12 --12:腰带
    }
    self.classList = {
        {name = TI18N("本服榜"),subList = {},id = 2,icon = "bfb"},
        {name = TI18N("好友榜"),subList = {},id = 3,icon = "hyb"},
        {name = TI18N("跨服榜"), subList = {{id = 80,name = TI18N("新星组")},{id = 90,name = TI18N("超凡组")},{id = 101,name = TI18N("绝尘组")},{id = 106,name = TI18N("登峰组")},{id = 116,name = TI18N("王者组")}},id = 1,icon = "icon1"},
    }
    self.currentMain = 2
    self.currentSub = 1

    self.rankItemList = {}

    self.listener = function(list) self:Update(list) end

end

function GodsWarJiFenRankPanel:AddAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarRankData:AddListener(self.listener)
end

function GodsWarJiFenRankPanel:RemoveAllListeners()
    GodsWarManager.Instance.OnUpdateGodsWarRankData:RemoveListener(self.listener)
end
function GodsWarJiFenRankPanel:__delete()
    self:RemoveAllListeners()

    if self.rankItemList ~= nil then
        for k,v in pairs(self.rankItemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.rankItemList = nil
    end
     if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
end

function GodsWarJiFenRankPanel:OnShow()
    self:AddAllListeners()
    GodsWarManager.Instance:Send17906()
    self.args = self.openArgs
    self:ClickMainButton(1)
end

function GodsWarJiFenRankPanel:OnHide()
    self:RemoveAllListeners()
    for i,v in ipairs(self.panelList) do
        v:Hiden()
    end
end

function GodsWarJiFenRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarjifenrankgepanel))
    self.gameObject.name = "GodsWarJiFenRankPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(-8,46)

    self.barContainer = self.transform:Find("Bar/Container").gameObject
    self.barRect = self.barContainer:GetComponent(RectTransform)

    self.mainButtonTemplate = self.barContainer.transform:Find("MainButton").gameObject
    self.mainButtonHeight = 58
    self.mainButtonTemplate:SetActive(false)
    self.subButtonTemplate = self.barContainer.transform:Find("SubButton").gameObject
    -- self.subButtonTemplate.transform:Find("Text").anchoredPosition = Vector2(-25.4,-1.8)
    self.subButtonHeight = 50
    self.subButtonTemplate:SetActive(false)

    self.cloner = self.transform.transform:Find("Panel/Panel/Container/Cloner").gameObject
    self.container = self.transform.transform:Find("Panel/Panel/Container")
    self.scrollTr = self.transform.transform:Find("Panel/Panel")
    self.scrollTr.gameObject:SetActive(false)
    self.cloner.gameObject:SetActive(false)

    self.tabLayout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 0})

    self.nothing = self.transform:Find("Panel/Nothing").gameObject
    self.nothing.gameObject:SetActive(true)

    self:InitLeftButtonList()
    self:InitRightRankList()
    self:OnShow()
end

function GodsWarJiFenRankPanel:InitRightRankList()
    local obj = nil
    for i=1,16 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        obj.transform:SetParent(self.container)
        obj.transform.localScale = Vector3(1,1,1)
        obj.transform.localPosition = Vector3(1,1,1)
        self.rankItemList[i] = GodsWarJiFenRankItem.New(obj,self,self.assetWrapper)
        self.tabLayout:AddCell(obj)
    end
    self.setting = {
       item_list = self.rankItemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y ---父容器改变时上一次的y坐标
       ,scroll_con_height = self.scrollTr:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.scrollTr:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

end

function GodsWarJiFenRankPanel:InitLeftButtonList()
    local mainBtn
    local subBtn
    local subList = nil
    local subObjList = nil
    local subImageList = nil
    local subTextList = nil
    for i=1,#self.classList do
        local data = self.classList[i]
        mainBtn = GameObject.Instantiate(self.mainButtonTemplate)
        mainBtn.name = tostring(i)
        mainBtn:SetActive(true)
        UIUtils.AddUIChild(self.barContainer, mainBtn)
        self.mainTextList[i] = mainBtn.transform:Find("Text"):GetComponent(Text)
        self.mainTextList[i].text = data.name

        if data.icon ~= nil then
            mainBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.godswartexture, data.icon)
        end

        mainBtn:GetComponent(Button).onClick:AddListener(function ()
            self:ClickMainButton(i)
        end)

        subList = data.subList
        if #subList <=0 then
            mainBtn.transform:Find("Arrow").gameObject:SetActive(false)
        else
            mainBtn.transform:Find("Arrow").gameObject:SetActive(true)
        end

        subObjList = {}
        subImageList = {}
        subTextList = {}

        local show = false
        for j=1,#subList do
            local subdata = subList[j]
            subBtn = GameObject.Instantiate(self.subButtonTemplate)
            subBtn:GetComponent(Button).onClick:AddListener(function ()
                self:ClickSubButton(i,j)
            end)
            subBtn.name = tostring(i.."_"..j)
            UIUtils.AddUIChild(self.barContainer, subBtn)
            subObjList[j] = subBtn
            subTextList[j] = subBtn.transform:Find("Text"):GetComponent(Text)
            subTextList[j].text = subdata.name
            if subdata.path == nil then
                subBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, subdata.icon)
                subBtn.transform:Find("Icon").gameObject:SetActive(false)
            else
                subBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(subdata.path, subdata.icon)
                subBtn.transform:Find("Icon").gameObject:SetActive(true)
            end
            subImageList[j] = subBtn:GetComponent(Image)
            subBtn:SetActive(false)
        end
        self.mainButtonList[i] = mainBtn
        self.subButtonList[i] = subObjList
        self.mainImageList[i] = mainBtn:GetComponent(Image)
        self.subImageList[i] = subImageList
        self.subTextList[i] = subTextList
        self.subOpenList[i] = false
    end
end

function GodsWarJiFenRankPanel:ClickMainButton(selectMain)
    local model = self.model

    local main = self.currentMain
    local sub = self.currentSub

    self.lastPosition = 0
    self.selectIndex = nil
    if selectMain ~= self.currentMain then
        self:EnableMain(self.currentMain, false)
        self:ShowSubButton(self.currentMain, false)
        self.currentSub = 1

        self.currentMain = selectMain
        self:EnableMain(self.currentMain, true)
        self:ShowSubButton(self.currentMain, true)
        if #self.classList[selectMain].subList <=0 then
            GodsWarManager.Instance:Send17937(self.classList[selectMain].id,0,true)
        else
            GodsWarManager.Instance:Send17937(self.classList[selectMain].id,self.classList[selectMain].subList[self.currentSub].id,true)
        end

    else
        self:ShowSubButton(selectMain, not self.subOpenList[selectMain])
         if #self.classList[selectMain].subList <=0 then
            GodsWarManager.Instance:Send17937(self.classList[selectMain].id,0,true)
        else
            GodsWarManager.Instance:Send17937(self.classList[selectMain].id,self.classList[selectMain].subList[self.currentSub].id,true)
        end
    end
end

function GodsWarJiFenRankPanel:EnableMain(currentMain, bool)
    local preload = PreloadManager.Instance
    if self.mainImageList[currentMain] ~= nil then
        if bool then
            self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton9")
            self.mainTextList[currentMain].color = ColorHelper.DefaultButton9
            self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow3")
        else
            self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton8")
            self.mainTextList[currentMain].color = ColorHelper.DefaultButton8
            self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow4")
        end
    end
end

function GodsWarJiFenRankPanel:ShowSubButton(selectMain, bool)
    self.subOpenList[selectMain] = bool
    local h = (self.mainButtonHeight + 3) * #self.classList
    for k,v in pairs(self.subButtonList[selectMain]) do
        local type = self.classList[selectMain].subList[k].type
        v:SetActive(bool and (self.showFuncTab[type] == nil or self.showFuncTab[type]()))
        if bool then
            h = h + self.subButtonHeight
        end
    end
    self.barRect.sizeDelta = Vector2(self.barRect.sizeDelta.x, h)
    self:EnableSub(self.currentMain, self.currentSub, bool)
    if bool then
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(-1, 1, 1)
    else
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(1, 1, 1)
    end
end

function GodsWarJiFenRankPanel:EnableSub(currentMain, currentSub, bool)
    if bool then
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton11
        end
    else
        if self.subImageList ~= nil and self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton10
        end
    end
end

function GodsWarJiFenRankPanel:ClickSubButton(selectMain, selectSub)
    local model = self.model

    local main = self.currentMain
    local sub = self.currentSub

    self.lastPosition = 0
    self.selectIndex = nil
    if selectMain ~= self.currentMain then
        print("23333333333333333333333333333333333333333333333333333331")
        self:EnableSub(self.currentMain, self.currentSub, false)
        self:EnableMain(selectMain, false)
        self:ShowSubButton(self.currentMain, false)
        self.currentMain = selectMain
        self.currentSub = selectSub
        self:ShowSubButton(self.currentMain, true)
        self:EnableMain(selectMain, true)
        self:EnableSub(self.currentMain, self.currentSub, true)
        self.scrollTr.gameObject:SetActive(false)
        GodsWarManager.Instance:Send17937(self.classList[selectMain].id,self.classList[selectMain].subList[selectSub].id,true)
    elseif selectSub ~= self.currentSub then
        print("23333333333333333333333333333333333333333333333333333332")
        self:EnableSub(self.currentMain, self.currentSub, false)
        self.currentSub = selectSub
        self:EnableSub(self.currentMain, self.currentSub, true)
        GodsWarManager.Instance:Send17937(self.classList[selectMain].id,self.classList[selectMain].subList[selectSub].id,true)
    end
    GodsWarManager.Instance:Send17937(self.classList[selectMain].id,self.classList[selectMain].subList[selectSub].id,true)
end

function GodsWarJiFenRankPanel:EnableSub(currentMain, currentSub, bool)
    if bool then
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton11
        end
    else
        if self.subImageList ~= nil and self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton10
        end
    end
end

function GodsWarJiFenRankPanel:Update(list,isChange)
    self.setting.data_list = list or {}

    if #self.setting.data_list == 0 then
        self.nothing.gameObject:SetActive(true)
        self.scrollTr.gameObject:SetActive(false)
    else
        self.nothing.gameObject:SetActive(false)
        self.scrollTr.gameObject:SetActive(true)


        BaseUtils.refresh_circular_list(self.setting)

        self:Select(self.rankItemList[1])
    end
    -- if GodsWarManager.Instance.myData ~= nil and GodsWarManager.Instance.myData.tid ~= 0 then
    --     self.tipsRect.anchoredPosition = Vector3(248, 217, 0)
    --     self.request:SetActive(false)
    -- else
    --     self.request:SetActive(true)
    --     self.tipsRect.anchoredPosition = Vector3(0, 217, 0)
    -- end
end

function GodsWarJiFenRankPanel:Select(item)
    if self.currItem ~= nil then
        self.currItem:Select(false)
    end
    self.currItem = item
    self.currItem:Select(true)
end



