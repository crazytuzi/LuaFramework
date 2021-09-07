-- 战斗录像
-- @author 郑子龙
-- @date 20170104

CombatVedioWindow = CombatVedioWindow or BaseClass(BaseWindow)

function CombatVedioWindow:__init(model)
    self.model = model
    self.name = "CombatVedioWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.winLinkType = WinLinkType.Single
    self.resList = {
        {file = AssetConfig.combatvedio_window, type = AssetType.Main}
    }
    CombatManager.Instance:Send10747()
    CombatManager.Instance:Send10748()
    CombatManager.Instance:Send10749()
    CombatManager.Instance:Send10757()
    self.closefunc = function(cbtype)
        self.model:CloseWin()
    end
    self.openfunc = function(cbtype)
        if  CombatManager.Instance.isWatchRecorder then
            self.model:OpenWindow()
        end
    end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.levToggleList = {TI18N("全部等级"), TI18N("1-69级"), TI18N("70-79级"), TI18N("80-89级"), TI18N("90-99级"), TI18N("100级以上")}
    self.levToggleDataList = {[2] = {min = 1, max = 69}, [3] = {min = 70, max = 79}, [4] = {min = 80, max = 89}, [5] = {min = 90, max = 99}, [6] = {min = 100, max = 1000}}
    self.curToggleLevIndex = 1 --即self.levToggleList第一项
    self.currentMain = 1
    self.currentSub = 1
    self.curDataList = nil
    self.hasInit = false
end

function CombatVedioWindow:__delete()
    self.hasInit = false
    self.curDataList = nil
    CombatManager.Instance.OnCurrLogChange:RemoveAll()
    CombatManager.Instance.OnKeepLogChange:RemoveAll()
    CombatManager.Instance.OnHotLogChange:RemoveAll()
    CombatManager.Instance.OnFirstKillChange:RemoveAll()
    CombatManager.Instance.OnZanChange:RemoveAll()
    CombatManager.Instance.OnKuafuGoodChange:RemoveAll()
    CombatManager.Instance.OnRecordListChange:RemoveAll()
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        item:Release()
    end
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.closefunc)
    self:ClearDepAsset()
end

function CombatVedioWindow:OnShow()
    if self.gameObject ~= nil then
        self.transform:SetAsLastSibling()
    end
    self:ReloadRightList()
    CombatManager.Instance:Send10747()
    CombatManager.Instance:Send10748()
    CombatManager.Instance:Send10749()
    CombatManager.Instance:Send10757()
    -- CombatManager.Instance:Send10759()
    if self.openArgs ~= nil then
        self:ClickMainButton(self.openArgs[1], self.openArgs[2])
        self.openArgs = nil
    end
end

function CombatVedioWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatvedio_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:Find("Main")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseWin()
    end)

    --左边菜单列表
    self.barContainer = self.MainCon:Find("Bar/Container").gameObject
    self.barRect = self.barContainer:GetComponent(RectTransform)
    self.mainButtonTemplate = self.barContainer.transform:Find("MainButton").gameObject
    self.mainButtonHeight = 58
    self.mainButtonTemplate:SetActive(false)
    self.subButtonTemplate = self.barContainer.transform:Find("SubButton").gameObject
    self.subButtonHeight = 50
    self.subButtonTemplate:SetActive(false)

    self.heartImgList = {}
    for i=1,3 do
        local tempTrans = self.MainCon:Find(string.format("HeartCon/ImgHeart%s", i))
        local img = tempTrans:GetComponent(Image)
        table.insert(self.heartImgList, img)
        tempTrans:GetComponent(Button).onClick:AddListener(function ()
            local tips = {}
            table.insert(tips, TI18N("每日获得3个爱心，消耗爱心可为任意战斗录像点赞，助其登上热门榜"))
            TipsManager.Instance:ShowText({gameObject = tempTrans.gameObject, itemData = tips})
        end)
    end

    --右边数据列表
    self.RightCon = self.MainCon:Find("RightCon")
    self.TitleCon = self.RightCon:Find("TitleCon")
    -- self.Toggle = self.TitleCon:Find("Toggle1"):GetComponent(Toggle)



    self.ToggleList = self.TitleCon:Find("ToggleList")
    self.Background = self.TitleCon:Find("ToggleList/Background").gameObject
    self.Label = self.TitleCon:Find("ToggleList/Label"):GetComponent(Text)
    self.Label.text = self.levToggleList[self.curToggleLevIndex]
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.ClassList:SetActive(open == false)
    end)

    self.ClassList = self.MainCon:Find("ClassList").gameObject
    self.ClassListBtn = self.MainCon:Find("ClassList/Button"):GetComponent(Button)
    self.ClassListBtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.ClassList:SetActive(false)
    end)
    self.ClassListCon = self.MainCon:Find("ClassList/Mask/Scroll")
    self.ClassListItem = self.MainCon:Find("ClassList/Mask/Scroll"):GetChild(0).gameObject
    self.ClassListItem:SetActive(false)
    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.ClassListCon, setting1)
    for i=1,#self.levToggleList do
        local item = GameObject.Instantiate(self.ClassListItem)
        item.transform:Find("I18NText"):GetComponent(Text).text = self.levToggleList[i]
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self.Label.text = item.transform:Find("I18NText"):GetComponent(Text).text
            self.curToggleLevIndex = i
            self.Background:SetActive(false)
            self.ClassList:SetActive(false)
            self:OnToggleUpdateList(self.curDataList)
        end)
        self.Layout1:AddCell(item)
    end




    self.GirlGuide = self.RightCon:Find("GirlGuide")
    self.MaskCon = self.RightCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.ScrollCon:GetComponent(RectTransform).sizeDelta = Vector2(581, 387)
    self.Container = self.ScrollCon:Find("Container")
    self.itemConLastY = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.settingData)
    end)
    self.itemList = {}
    for i=1,13 do
        local go = self.Container:FindChild(tostring(i)).gameObject
        local item = CombatVedioItem.New(go, self)
        table.insert(self.itemList, item)
    end
    self.singleItemHeight = self.itemList[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scrollConHeight = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y
    self.settingData = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.singleItemHeight --一条item的高度
       ,item_con_last_y = self.itemConLastY --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scrollConHeight--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    -- self.Toggle.onValueChanged:AddListener(function(on)
    --     self:OnToggleUpdateList(self.curDataList)
    -- end)

    self.updateRecent = function() --最近挑战
        if self.hasInit == false then
            return
        end
        if self.currentMain == 5 and self.currentSub == 1 then
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.currList)
        end
    end
    self.updateCollection = function() --我的收藏
        if self.hasInit == false then
            return
        end
        if self.currentMain == 5 and self.currentSub == 2 then
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.keepList)
        end
    end
    self.updateHot = function(rank_type) --热门录像
        if self.hasInit == false then
            return
        end
        if self.currentMain == 1 and self.currentSub == rank_type then
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.hotList)
        end
    end
    self.updateFirstKill = function() --首杀
        if self.hasInit == false then
            return
        end
        self:UpdateRight(CombatManager.Instance.WatchLogmodel.firstKillList)
    end
    self.updateZan = function() --首杀
        if self.hasInit == false then
            return
        end
        self:UpdateZanHeart()
    end

    self.updateKuafuGood = function(rank_type)
        if self.hasInit == false then
            return
        end
        if self.currentMain == 4 and ((self.currentSub == 1 and rank_type == 40)  or (self.currentSub == 2 and rank_type == 110) or (self.currentSub == 9 and rank_type == 113) or (self.currentSub == 10 and rank_type == 114) or (self.currentSub == 11 and rank_type == 116)) then
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.kuafuGoodList[rank_type])
        end
    end

    self.updateRecordList = function()
        self:InitBarList()
        if self.openArgs ~= nil then
            self:ClickMainButton(self.openArgs[1], self.openArgs[2])
            self.openArgs = nil
        else
            self:ClickMainButton(5)
        end
    end

    EventMgr.Instance:AddListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.closefunc)
    CombatManager.Instance.OnCurrLogChange:AddListener(self.updateRecent)
    CombatManager.Instance.OnKeepLogChange:AddListener(self.updateCollection)
    CombatManager.Instance.OnHotLogChange:AddListener(self.updateHot)
    CombatManager.Instance.OnFirstKillChange:AddListener(self.updateFirstKill)
    CombatManager.Instance.OnZanChange:AddListener(self.updateZan)
    CombatManager.Instance.OnKuafuGoodChange:AddListener(self.updateKuafuGood)
    CombatManager.Instance.OnRecordListChange:AddListener(self.updateRecordList)

    self.hasInit = true
    CombatManager.Instance:Send10759()
    self:UpdateZanHeart()
end

--左边菜单列表
function CombatVedioWindow:InitBarList()
    self.mainButtonList = {}
    self.mainImageList = {}
    self.subButtonList = {}
    self.subImageList = {}
    self.mainTextList = {}
    self.subTextList = {}
    self.subOpenList = {}

    local mainBtn
    local subBtn
    local subList = nil
    local subObjList = nil
    local subImageList = nil
    local subTextList = nil

    local barDataList = self.model:GetBarDataList()
    for i=1,#barDataList do
        local data = barDataList[i]
        mainBtn = GameObject.Instantiate(self.mainButtonTemplate)
        mainBtn.name = tostring(i)
        mainBtn:SetActive(true)
        UIUtils.AddUIChild(self.barContainer, mainBtn)
        self.mainTextList[data.index] = mainBtn.transform:Find("Text"):GetComponent(Text)
        self.mainTextList[data.index].text = data.name

        mainBtn:GetComponent(Button).onClick:AddListener(function ()
            self:ClickMainButton(data.index)
        end)

        subList = data.subList
        subObjList = {}
        subImageList = {}
        subTextList = {}
        for j=1,#subList do
            local subdata = subList[j]
            subBtn = GameObject.Instantiate(self.subButtonTemplate)
            subBtn:GetComponent(Button).onClick:AddListener(function ()
                self:ClickSubButton(data.index, subdata.sub)
            end)
            subBtn.name = tostring(i.."_"..subdata.sub)
            UIUtils.AddUIChild(self.barContainer, subBtn)
            subObjList[subdata.sub] = subBtn
            subTextList[subdata.sub] = subBtn.transform:Find("Text"):GetComponent(Text)
            subTextList[subdata.sub].text = subdata.name
            subImageList[subdata.sub] = subBtn:GetComponent(Image)
            subBtn:SetActive(false)
        end
        self.mainButtonList[data.index] = mainBtn
        self.subButtonList[data.index] = subObjList
        self.mainImageList[data.index] = mainBtn:GetComponent(Image)
        self.subImageList[data.index] = subImageList
        self.subTextList[data.index] = subTextList
        self.subOpenList[data.index] = false
    end
end

function CombatVedioWindow:ShowSubButton(selectMain, bool)
    self.subOpenList[selectMain] = bool
    local h = (self.mainButtonHeight + 3) * #self.model:GetBarDataList()
    for k,v in pairs(self.subButtonList[selectMain]) do
        v:SetActive(bool)
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



function CombatVedioWindow:ClickMainButton(selectMain, sub)
    if selectMain ~= self.currentMain then
        self:EnableMain(self.currentMain, false)
        self:ShowSubButton(self.currentMain, false)
        if sub ~= nil then
            self.currentSub = sub
        else
            self.currentSub = 1
        end
        self.currentMain = selectMain
        self:EnableMain(self.currentMain, true)
        self:ShowSubButton(self.currentMain, true)
        self:ReloadRightList()
    else
        self:ShowSubButton(selectMain, not self.subOpenList[selectMain])
        self:ReloadRightList()
    end
end

function CombatVedioWindow:EnableMain(currentMain, bool)
    if bool then
        self.mainImageList[currentMain].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        -- self.mainTextList[currentMain].color = Color(1, 1, 1)
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow3")
    else
        self.mainImageList[currentMain].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        -- self.mainTextList[currentMain].color = Color(118/255, 157/255, 199/255)
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow4")
    end
end

function CombatVedioWindow:ClickSubButton(selectMain, selectSub)
    SingManager.Instance.model:StopSong()
    -- self.model.datalist[self.currentMain][self.currentSub][2] = nil

    if selectMain ~= self.currentMain then
        self:EnableSub(self.currentMain, self.currentSub, false)
        self:EnableMain(selectMain, false)
        self:ShowSubButton(self.currentMain, false)
        self.currentMain = selectMain
        self.currentSub = selectSub
        self:ShowSubButton(self.currentMain, true)
        self:EnableMain(selectMain, true)
        self:EnableSub(self.currentMain, self.currentSub, true)
        self:ReloadRightList()
    elseif selectSub ~= self.currentSub then
        self:EnableSub(self.currentMain, self.currentSub, false)
        self.currentSub = selectSub
        self:EnableSub(self.currentMain, self.currentSub, true)
        self:ReloadRightList()
    end
end

function CombatVedioWindow:EnableSub(currentMain, currentSub, bool)
    if bool then
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
            -- self.subTextList[currentMain][currentSub].color = Color(1, 1, 1)
        end
    else
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
            -- self.subTextList[currentMain][currentSub].color = Color(118/255, 157/255, 199/255)
        end
    end
end

--更新点赞心icon的显示
function CombatVedioWindow:UpdateZanHeart()
    if self.model.zanData ~= nil then
        -- local num = math.floor(self.model.zanData.online/1200)
        -- num = num > 3 and 3 or num
        local num = 3
        local lightNum = num - self.model.zanData.liked
        for i=1,#self.heartImgList do
            self.heartImgList[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "HeartGrey")
        end
        for i=1,lightNum do
            self.heartImgList[i].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "Heart")
        end
    end
end


---右边数据列表逻辑
function CombatVedioWindow:ReloadRightList()
    -- self.currentMain = 1
    -- self.currentSub = 1
    self.settingData.data_list = {}
    BaseUtils.refresh_circular_list(self.settingData)
    self.Background:SetActive(open == false)
    self.ClassList:SetActive(open == false)
    if self.currentMain == 5 then
        --我的录像
        if self.currentSub == 1 then --最近挑战
            -- CombatManager.Instance:Send10747()
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.currList)
        elseif self.currentSub == 2 then --我的收藏
            -- CombatManager.Instance:Send10748()
            self:UpdateRight(CombatManager.Instance.WatchLogmodel.keepList)
        end
    elseif self.currentMain == 1 then
        --热门录像
        if self.currentSub == 1 then --一周热门
            CombatManager.Instance:Send10754(1)
        elseif self.currentSub == 2 then -- 历史热门
            CombatManager.Instance:Send10754(2)
        end
    elseif self.currentMain == 2 then
        --首杀
        self.ToggleList.gameObject:SetActive(false)
        if self.currentSub == 1 then -- BOSS首杀
            CombatManager.Instance:Send10755(1) --"1boss首杀，3爵位首杀，14星座首杀"}
        elseif self.currentSub == 14 then -- 星座首杀
            CombatManager.Instance:Send10755(14)
        elseif self.currentSub == 3 then -- 爵位首杀
            CombatManager.Instance:Send10755(3)
        elseif self.currentSub == 16 then -- 天空首杀
            CombatManager.Instance:Send10755(16)
        elseif self.currentSub == 15 then -- 夺宝首杀
            CombatManager.Instance:Send10755(15)
        end
    elseif self.currentMain == 3 then
        --怪物讨伐
        local combatTypeDic = {}
        if self.currentSub == 1 then -- 世界BOSS
            combatTypeDic[5] = 1
        elseif self.currentSub == 2 then -- 星座挑战
            combatTypeDic[26] = 1
        elseif self.currentSub == 3 then -- 爵位挑战
            combatTypeDic[21] = 1
        elseif self.currentSub == 4 then -- 天空之塔
            combatTypeDic[16] = 1
        elseif self.currentSub == 5 then -- 夺宝奇兵
            combatTypeDic[54] = 1
        elseif self.currentSub == 6 then -- 英雄副本
            combatTypeDic[56] = 1
        elseif self.currentSub == 7 then -- 龙王资格
            combatTypeDic[61] = 1
        elseif self.currentSub == 8 then -- 龙王试练
            combatTypeDic[62] = 1
        elseif self.currentSub == 9 then    -- 玲珑宝阁
            combatTypeDic[63] = 1
        elseif self.currentSub == 10 then    -- 星辰试炼
            combatTypeDic[68] = 1
        elseif self.currentSub == 11 then    -- 幻月灵兽
            combatTypeDic[72] = 1
        end
        local list = self.model:GetVedioListByCombatType(combatTypeDic)
        self:UpdateRight(list)
    elseif self.currentMain == 4 then
        --玩家对决
        local combatTypeDic = {}
        if self.currentSub == 1 then -- 武道会
            CombatManager.Instance:Send10758(40)
        -- elseif self.currentSub == 2 then -- 冠军联赛
        --     CombatManager.Instance:Send10758(108)
        elseif self.currentSub == 2 then -- 诸神之战
            CombatManager.Instance:Send10758(110)
        elseif self.currentSub == 9 then -- 诸神之战
            CombatManager.Instance:Send10758(113)
        elseif self.currentSub == 10 then -- 钻石联赛
            CombatManager.Instance:Send10758(114)
        elseif self.currentSub == 11 then -- 峡谷之巅
            CombatManager.Instance:Send10758(116)
        else
            if self.currentSub == 3 then -- 竞技场
                combatTypeDic[100] = 1
            elseif self.currentSub == 4 then -- 段位赛
                combatTypeDic[102] = 1
            elseif self.currentSub == 5 then -- 公会战
                combatTypeDic[105] = 1
            elseif self.currentSub == 6 then -- 公会英雄战
                combatTypeDic[106] = 1
            elseif self.currentSub == 7 then -- 荣耀战场
                combatTypeDic[107] = 1
            elseif self.currentSub == 8 then -- 巅峰对决
                combatTypeDic[104] = 1
            elseif self.currentSub == 9 then -- 英雄擂台
                combatTypeDic[113] = 1
            end
            local list = self.model:GetVedioListByCombatType(combatTypeDic)
            self:UpdateRight(list)
        end
    end
end

function CombatVedioWindow:UpdateRight(list)
    self.curDataList = list
    if list ~= nil then
        if self.curToggleLevIndex ~= 1 and self.currentMain ~= 2 then
            --进行等级筛选
            local minLev = self.levToggleDataList[self.curToggleLevIndex].min
            local maxLev = self.levToggleDataList[self.curToggleLevIndex].max
            local tempList = {}
            for i = 1, #list do
                local temp = list[i]
                if temp.avg_lev >= minLev and temp.avg_lev <= maxLev then
                    table.insert(tempList, temp)
                end
            end
            self.settingData.data_list = tempList
        else
            --不做等级筛选
            self.settingData.data_list = list
        end
    else
        self.settingData.data_list = {}
    end
    if #self.settingData.data_list == 0 then
        --没数据
        if self.currentMain ~= 2 then
            self.ToggleList.gameObject:SetActive(true)
        end
        self.GirlGuide.gameObject:SetActive(true)
        self.MaskCon.gameObject:SetActive(false)
    else
        if self.currentMain ~= 2 then
            self.ToggleList.gameObject:SetActive(true)
        end
        self.GirlGuide.gameObject:SetActive(false)
        self.MaskCon.gameObject:SetActive(true)
        BaseUtils.refresh_circular_list(self.settingData)
    end
end

--toggle更新数据
function CombatVedioWindow:OnToggleUpdateList(list)
    if list ~= nil then
        if self.curToggleLevIndex ~= 1 and self.currentMain ~= 2 then
            --进行等级筛选
            local minLev = self.levToggleDataList[self.curToggleLevIndex].min
            local maxLev = self.levToggleDataList[self.curToggleLevIndex].max
            local tempList = {}
            for i = 1, #list do
                local temp = list[i]
                if temp.avg_lev >= minLev and temp.avg_lev <= maxLev then
                    table.insert(tempList, temp)
                end
            end
            self.settingData.data_list = tempList
        else
            --不做等级筛选
            self.settingData.data_list = list
        end
    else
        self.settingData.data_list = {}
    end
    if #self.settingData.data_list == 0 then
        --没数据
        self.GirlGuide.gameObject:SetActive(true)
        self.MaskCon.gameObject:SetActive(false)
    else
        self.GirlGuide.gameObject:SetActive(false)
        self.MaskCon.gameObject:SetActive(true)
        BaseUtils.refresh_circular_list(self.settingData)
    end
end