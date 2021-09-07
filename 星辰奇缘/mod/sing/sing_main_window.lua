-- ---------------------
-- 星辰声音主界面
-- hosr
-- 2016-07-25
-- ---------------------

SingMainWindow = SingMainWindow or BaseClass(BaseWindow)

function SingMainWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.sing_main_window
    -- self.cacheMode = CacheMode.Destroy
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.sing_main, type = AssetType.Main},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currentItem = nil
    self.currentPlayItem = nil
    self.currentPlayData = nil
    self.currentData = nil
    self.soundData = nil

    self.timeId = nil
    self.count = 0
    self.maxTime = 0

    self.listener = function() self:UpdateFollow() end

    -- 当前数据列表
    self.dataList = {}
    -- 当前照片缓存
    self.pictureTab = {}
    -- 当前搜索结果列表
    self.searchList = {}

    model.currentTab = 1
end

function SingMainWindow:__delete()
    self.model.playCallback = nil
    self:StopSong()
    for i,item in ipairs(self.rank_item_list) do
        item:DeleteMe()
    end
    for i,v in ipairs(self.rankItemList) do
        v:DeleteMe()
    end
    self.rankItemList = nil
    self.rank_item_list = nil
    EventMgr.Instance:RemoveListener(event_name.sing_follow_update, self.listener)
    self.pictureTab = nil

    if self.rewardPanel ~= nil then
        self.rewardPanel:DeleteMe()
        self.rewardPanel = nil
    end
    if self.model.multiItemPanel ~= nil then
        self.model.multiItemPanel:DeleteMe()
        self.model.multiItemPanel = nil
    end
    if self.model.singRankTypePanel ~= nil then
        self.model.singRankTypePanel:DeleteMe()
        self.model.singRankTypePanel = nil
    end
end

function SingMainWindow:OnOpen()
    self.cacheMode = CacheMode.Destroy
    self:OnRefresh()
    self:SelectOne()

    self.tabGroup:ChangeTab(self.model.currentTab or 1)
end

function SingMainWindow:OnHide()
    self.model.playCallback = nil
    self:StopSong()
end

function SingMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sing_main))
    self.gameObject.name = "SingMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMain() end)

    local search = self.transform:Find("Main/Search")
    search:Find("SearchBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickSearch() end)
    self.searchTxt = search:Find("SearchBtn/Text"):GetComponent(Text)
    self.searchTxt.text = TI18N("搜 索")
    self.searchImg = search:Find("SearchBtn"):GetComponent(Image)
    self.searchObj = search.gameObject

    self.input = search:Find("InputField"):GetComponent(InputField)

    local refreshBtn = self.transform:Find("Main/RefreshBtn").gameObject
    refreshBtn:SetActive(true)
    refreshBtn:GetComponent(Button).onClick:AddListener(function() self:Refresh() end)
    refreshBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
	refreshBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("换一批")
    self.input.gameObject.transform.anchorMax = Vector2(0,0.5)
    self.input.gameObject.transform.anchorMin = Vector2(0,0.5)
    self.input.gameObject.transform.pivot = Vector2(0,0.5)
    search.sizeDelta = Vector2(260,40)
    search.anchoredPosition = Vector2(23,-35)
    self.input.gameObject.transform.sizeDelta = Vector2(198,30)
    self.input.gameObject.transform.anchoredPosition = Vector2(50, 0)
    self.input.gameObject.transform:Find("Placeholder"):GetComponent(Text).text = TI18N("输入玩家名字或ID搜索")
    self.searchImg.gameObject.transform.anchoredPosition = Vector2(108.5, 0)
    self.searchImg.gameObject.transform.sizeDelta = Vector2(90, 40)
    refreshBtn.transform:SetParent(search)
    refreshBtn.transform.localScale = Vector3.one
    refreshBtn.transform.pivot = Vector2(0.5, 0.5)
    refreshBtn.transform.anchorMax = Vector2(1,0.5)
    refreshBtn.transform.anchorMin = Vector2(1,0.5)
    refreshBtn.transform.sizeDelta = Vector2(90, 40)
    refreshBtn.transform.anchoredPosition = Vector2(56,0)

    self.transform:Find("Main/Right/Head"):GetComponent(Button).onClick:AddListener(function() self:ClickHead() end)
    self.headImg = self.transform:Find("Main/Right/Head/Image"):GetComponent(Image)
    self.classesImg = self.transform:Find("Main/Right/Info/Classes"):GetComponent(Image)
    self.name = self.transform:Find("Main/Right/Info/Name"):GetComponent(Text)
    self.rewardBtn = self.transform:Find("Main/Right/Info/Reward"):GetComponent(Button)
    self.headImg.gameObject:SetActive(true)

    self.playBtn = self.transform:Find("Main/Right/Sound/Play"):GetComponent(Button)
    self.playImg = self.transform:Find("Main/Right/Sound/Play/Img"):GetComponent(Image)
    self.startTxt = self.transform:Find("Main/Right/Sound/Start"):GetComponent(Text)
    self.endTxt = self.transform:Find("Main/Right/Sound/End"):GetComponent(Text)
    self.slider = self.transform:Find("Main/Right/Sound/Slider"):GetComponent(Slider)

    self.desc = self.transform:Find("Main/Right/Desc/Text"):GetComponent(Text)

    self.btn1 = self.transform:Find("Main/Right/Options/Button1"):GetComponent(Button)
    self.btn2 = self.transform:Find("Main/Right/Options/Button2"):GetComponent(Button)
    self.btn3 = self.transform:Find("Main/Right/Options/Button3"):GetComponent(Button)
    self.btn4 = self.transform:Find("Main/Right/Options/Button4"):GetComponent(Button)

    self.playBtn.onClick:AddListener(function() self:OnPlay() end)
    self.btn1.onClick:AddListener(function() self:OnClick1() end)
    self.btn2.onClick:AddListener(function() self:OnClick2() end)
    self.btn3.onClick:AddListener(function() self:OnClick3() end)
    self.btn4.onClick:AddListener(function() self:OnClick4() end)
    self.rewardBtn.onClick:AddListener(function() self:OnShowPreview() end)

    for i=2,5 do
        local t = self.transform:Find("Main/Left/Title"):GetChild(i - 1).gameObject
        t:SetActive(false)
    end

    local title = self.transform:Find("Main/Left/Title/Text"):GetComponent(Text)
    title.gameObject.transform.sizeDelta = Vector2(480,30)
    if SingManager.Instance.activeState ~= SingEumn.ActiveState.SignUp and SingManager.Instance.activeState ~= SingEumn.ActiveState.VotePre and SingManager.Instance.activeState ~= SingEumn.ActiveState.Vote then
        title.text = TI18N("  关注     编号          名称           声音简介             好评       好听")
    else
        title.text = TI18N("  关注     编号          名称           声音简介                   人气")
    end

    self.nothing = self.transform:Find("Main/Left/Scroll/Nothing").gameObject
    self.nothing:SetActive(false)

    self.leftRect = self.transform:Find("Main/Left")
    self.Container = self.transform:Find("Main/Left/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Left/Scroll")
    self.rankContainer = self.ScrollCon:Find("RankContainer")
    self.rankCloner = self.ScrollCon:Find("RankCloner").gameObject
    self.rank_item_list = {}

    for i = 1, 10 do
        local go = self.Container:Find(string.format("Item%s", i)).gameObject
        local item = SingShowItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.rankItemList = {}
    self.layout = LuaBoxLayout.New(self.rankContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    for i=1,16 do
        local obj = GameObject.Instantiate(self.rankCloner)
        obj.name = tostring(i)
        self.layout:AddCell(obj)
        self.rankItemList[i] = SingRankItem.New(obj, self)
        self.rankItemList[i].bgImg.enabled = true
        if i%2 == 0 then
            self.rankItemList[i].bgImg.color = self.rank_item_list[1].bgImg.color
        else
            self.rankItemList[i].bgImg.color = self.rank_item_list[2].bgImg.color
        end
    end
    self.layout:DeleteMe()
    self.layout = nil

    self.setting1 = {
       item_list = self.rankItemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.rankContainer  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.tabGroup = TabGroup.New(self.transform:Find("Main/Tab"), function(index) self:ChangeTab(index) end, {isVertical = true, notAutoSelect = true,noCheckRepeat = false, perHeight = 110, perWidth = 40, cspacing = 0})

    if SingManager.Instance.activeState == SingEumn.ActiveState.SignUp or SingManager.Instance.activeState == SingEumn.ActiveState.VotePre or SingManager.Instance.activeState == SingEumn.ActiveState.Vote then
        self.tabGroup.buttonTab[2].gameObject:SetActive(true)
        self.tabGroup.buttonTab[3].gameObject:SetActive(false)
        self.tabGroup.buttonTab[4].gameObject:SetActive(false)
    else
        self.tabGroup.buttonTab[2].gameObject:SetActive(false)
        self.tabGroup.buttonTab[3].gameObject:SetActive(true)
        self.tabGroup.buttonTab[4].gameObject:SetActive(true)
    end

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.rankCloner:SetActive(false)

    self.descButton = self.transform:Find("Main/Left/Title/DescButton"):GetComponent(Button)
    self.descButton.onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject, itemData = { 
                        "1、好评：收花数+点赞数，由此评选<color='#00ff00'>偶像榜</color>"
                        , "2、好听：点赞数，由此评选<color='#00ff00'>实力榜</color>"
                    }
                })
        end)

    EventMgr.Instance:AddListener(event_name.sing_follow_update, self.listener)
    self:OnOpen()
end

function SingMainWindow:ClickSearch()
    if self.input.text == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入要搜索的内容"))
        return
    end
    if self.searchTxt.text == TI18N("搜索") then
        self:OnSearch()
    elseif self.searchTxt.text == TI18N("返回") then
        self:OnRefresh()
    end
end

function SingMainWindow:OnSearch()
    self.searchTxt.text = TI18N("返回")
    self.searchImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    local str = self.input.text
    self.dataList = SingManager.Instance:GetOrderList()
    self.searchList = {}
    for i, data in ipairs(self.dataList) do
        if string.find(data.name, str) ~= nil then
            table.insert(self.searchList, data)
        elseif tonumber(str) ~= nil and tonumber(str) == data.id then
            table.insert(self.searchList, data)
        end
    end

    if #self.searchList == 0 then
        self.nothing:SetActive(true)
        self.Container.gameObject:SetActive(false)
    else
        self.nothing:SetActive(false)
        self.Container.gameObject:SetActive(true)
        self.setting.data_list = self.searchList
        BaseUtils.refresh_circular_list(self.setting)
    end
end

function SingMainWindow:Refresh()
    SingManager.Instance:AskSongList(1)
end

function SingMainWindow:OnRefresh()
    self.searchImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    -- self.Container.gameObject:SetActive(true)
    self.searchTxt.text = TI18N("搜索")
    self.nothing:SetActive(false)
    self.dataList = SingManager.Instance:GetOrderList(1)
    self.setting.data_list = self.dataList
    BaseUtils.refresh_circular_list(self.setting)
end

function SingMainWindow:SelectAndPlay(item)
    if self.currentItem ~= nil then
        self.currentItem:UpdateState(SingEumn.State.Normal)
    end
    self:SelectOne(item)
    self:OnPlay()
end

function SingMainWindow:SelectOne(item)
    if self.currentItem ~= nil then
        self.currentItem:Select(false)
    end

    if item == nil then
        self.currentItem = self.rank_item_list[1]
    else
        self.currentItem = item
    end
    self.currentItem:Select(true)
    self.currentData = self.currentItem.data
    SingManager.Instance.currentShowKey = string.format("%s_%s_%s", self.currentData.rid, self.currentData.platform, self.currentData.zone_id)
    self:UpdateInfo()
end

function SingMainWindow:UpdateInfo()
    if self.currentData == nil then
        return
    end
    self:UpdateRole()
    self:UpdateSound()
    self:UpdateDesc()
end

function SingMainWindow:UpdateRole()
    local sprite = self.pictureTab[string.format("%s_%s_%s", self.currentData.rid, self.currentData.platform, self.currentData.zone_id)]
    if sprite == nil then
        self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.currentData.classes, self.currentData.sex))
        ZoneManager.Instance:RequirePhotoQueue(self.currentData.rid, self.currentData.platform, self.currentData.zone_id, function(photo) if not BaseUtils.isnull(self.headImg) then self:toPhoto(photo, self.headImg, self.currentData.rid, self.currentData.platform, self.currentData.zone_id) end end)
    else
        self.headImg.sprite = sprite
    end
    self.classesImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.currentData.classes))
    --self.name.text = string.format("%s Lv.%s", self.currentData.name, self.currentData.lev)
    self.name.text = string.format("%s", self.currentData.name)
end

function SingMainWindow:UpdateDesc()
    self.desc.text = self.currentData.summary
end

function SingMainWindow:UpdateSound()
    self.soundData = self.currentData.clip
    self.startTxt.text = "00:00"
    local minute = math.floor(self.currentData.time/60)
    local second = self.currentData.time - minute*60
    if second < 10 then
        second = string.format("0%s", second)
    end
    self.endTxt.text = string.format("0%s:%s", minute, second)
    self.slider.value = 0
    self.maxTime = self.currentData.time

    if SingManager.Instance.currentShowKey == SingManager.Instance.currentPlayKey then
        self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
        self:UpdateSlider()
    else
        self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
    end
end

-- 举报
function SingMainWindow:OnClick1()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function() SingManager.Instance:Send16807(self.currentData.rid, self.currentData.platform, self.currentData.zone_id) end
    confirmData.content = TI18N("成功举报后系统将给予第一个举报的玩家奖励，是否继续？")
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 宣传
function SingMainWindow:OnClick2()
    self.cacheMode = CacheMode.Visible
    SingManager.Instance.model:OpenAdvert(self.currentData)
end

-- 送花
function SingMainWindow:OnClick3()
    self.cacheMode = CacheMode.Visible
    local data = {}
    data.id = self.currentData.rid
    data.platform = self.currentData.platform
    data.zone_id = self.currentData.zone_id
    data.name = self.currentData.name
    data.classes = self.currentData.classes
    data.sex = self.currentData.sex
    data.lev = self.currentData.lev

    if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
        GivepresentManager.Instance:OpenGiveWin(data)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() GivepresentManager.Instance:OpenGiveWin(data) end
        confirmData.content = TI18N("当前<color='#ffff00'>星辰好声音</color>活动处于<color='#ffff00'>报名阶段</color>，送花将<color='#ffff00'>不增加好评</color>，是否继续？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

-- 好评
function SingMainWindow:OnClick4()
    SingManager.Instance:Send16810(self.currentData.rid, self.currentData.platform, self.currentData.zone_id)
end

-- 播放
function SingMainWindow:OnPlay()
    local key = string.format("%s_%s_%s", self.currentData.rid, self.currentData.platform, self.currentData.zone_id)
    if SingManager.Instance.currentPlayKey == key and SingManager.Instance.songPlaying then
        self:StopSong()
    else
        if self.currentPlayData ~= nil then
            self.currentPlayData.state = SingEumn.State.Normal
        end
        if self.currentPlayItem ~= nil then
            self.currentPlayItem:UpdateState(SingEumn.State.Normal)
        end
        self.currentItem:UpdateState(SingEumn.State.Downloading)
        SingManager.Instance.currentPlayKey = key
        self.currentPlayItem = self.currentItem
        self.currentPlayData = self.currentItem.data
        self.model.playCallback = function() self:PlaySong() end
        self.model:PlaySong(self.currentData)
    end
end

function SingMainWindow:PlaySong()
    if self.currentItem ~= nil then
        self.currentItem:UpdateState(SingEumn.State.Playing)
    end
    self:TimeCount()
    self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
end

function SingMainWindow:StopSong()
    SingManager.Instance.currentPlayKey = ""
    if self.currentPlayData ~= nil then
        self.currentPlayData.state = SingEumn.State.Normal
    end
    if self.currentItem ~= nil then
        self.currentItem:UpdateState(SingEumn.State.Normal)
    end
    self:StopTimeCount()
    self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
    self.model:StopSong()
    self:UpdateSlider()
end

function SingMainWindow:StopTimeCount()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    self.count = 0
end

function SingMainWindow:TimeCount()
    self:StopTimeCount()
    self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function SingMainWindow:Loop()
    self.count = self.count + 1
    if SingManager.Instance.currentPlayKey == SingManager.Instance.currentShowKey then
        self:UpdateSlider()
    end

    if self.count >= self.maxTime then
        self:StopSong()
    end
end

function SingMainWindow:UpdateSlider()
    local startstr = string.format("00:%s", self.count)
    if self.count < 10 then
        startstr = "00:0"..self.count
    end
    self.startTxt.text = startstr
    self.endTxt.text = string.format("00:%s", self.maxTime)
    self.slider.value = self.count / self.maxTime
    -- if self.slider.value >= 1 then
    --     self:StopSong()
    -- end
end

function SingMainWindow:UpdateFollow()
    for i,item in ipairs(self.rank_item_list) do
        item:UpdateFollow()
    end
    self:OnRefresh()
end

function SingMainWindow:ClickHead()
    if self.currentData ~= nil then
        TipsManager.Instance:ShowPlayer(self.currentData)
    end
end

function SingMainWindow:toPhoto(photo, img, id, platform, zone_id)
    if BaseUtils.isnull(img) or photo[1] == nil then
        return
    end
    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)

    local result = tex2d:LoadImage(photo[1].photo_bin)
    if result then
        img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
    end

    self.pictureTab[string.format("%s_%s_%s", id, platform, zone_id)] = img.sprite
end

function SingMainWindow:OnShowPreview()
    -- if self.rewardList == nil then
    --     local tab = {}
    --     for k,v in pairs(DataSing.data_rank_reward) do
    --         local start_time = os.time{year = v.start_time[1][1], month = v.start_time[1][2], day = v.start_time[1][3], hour = v.start_time[1][4], minute = v.start_time[1][5], second = v.start_time[1][6]}
    --         local end_time = os.time{year = v.end_time[1][1], month = v.end_time[1][2], day = v.end_time[1][3], hour = v.end_time[1][4], minute = v.end_time[1][5], second = v.end_time[1][6]}
    --         if start_time < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= end_time then
    --             table.insert(tab, v)
    --         end
    --     end
    --     table.sort(tab, function(a,b) return a.min_rank < b.min_rank end)
    --     local list = {}
    --     for i,v in ipairs(tab) do
    --         local items = {}
    --         for _,item in pairs(v.reward) do
    --             table.insert(items, {base_id = item[1], num = item[2]})
    --         end
    --         table.insert(list, {title = v.title, items = items})
    --     end
    --     self.rewardList = {list = list}
    -- end
    -- if self.rewardPanel == nil then
    --     self.rewardPanel = MultiItemPanel.New(self.gameObject)
    -- end
    -- self.rewardPanel:Show(self.rewardList)
    self.model:ShowRankReward(self.gameObject)
end

function SingMainWindow:ChangeTab(index)
    local title = self.transform:Find("Main/Left/Title/Text"):GetComponent(Text)
    self.model.currentTab = index
    if index == 1 then
        self.searchObj:SetActive(true)
        self.leftRect.sizeDelta = Vector2(470, 408)
        self.ScrollCon.sizeDelta = Vector2(466, 360)
        self.leftRect.anchoredPosition = Vector2(20, -77)
        self.Container.gameObject:SetActive(true)
        self.rankContainer.gameObject:SetActive(false)
        self.ScrollCon:GetComponent(ScrollRect).content = self.Container

        self.dataList = SingManager.Instance:GetOrderList(1)
        self.setting.data_list = self.dataList
        self.vScroll.onValueChanged:RemoveAllListeners()
        self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)
        BaseUtils.refresh_circular_list(self.setting)
        if SingManager.Instance.activeState ~= SingEumn.ActiveState.SignUp and SingManager.Instance.activeState ~= SingEumn.ActiveState.VotePre and SingManager.Instance.activeState ~= SingEumn.ActiveState.Vote then
            title.text = TI18N("  关注     编号          名称           声音简介             好评       好听")
            self.descButton.transform.localPosition = Vector2(215, -20)
            self.descButton.gameObject:SetActive(true)
        else
            title.text = TI18N("  关注     编号          名称           声音简介                   人气  ")
            self.descButton.gameObject:SetActive(false)
        end
    elseif index == 2 then
        self.searchObj:SetActive(false)
        self.leftRect.sizeDelta = Vector2(470, 450)
        self.ScrollCon.sizeDelta = Vector2(466, 402)
        self.leftRect.anchoredPosition = Vector2(20, -33)
        self.Container.gameObject:SetActive(false)
        self.rankContainer.gameObject:SetActive(true)
        self.ScrollCon:GetComponent(ScrollRect).content = self.rankContainer

        self.setting1.data_list = self:GetRankList()
        self.vScroll.onValueChanged:RemoveAllListeners()
        self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting1) end)
        BaseUtils.refresh_circular_list(self.setting1)
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            title.text = TI18N("  排名     编号          名称           声音简介                 好评  ")
            self.descButton.gameObject:SetActive(true)
            self.descButton.transform.localPosition = Vector2(200, -20)
        else
            title.text = TI18N("  排名     编号          名称           声音简介                 人气  ")
            self.descButton.gameObject:SetActive(false)
        end
    elseif index == 3 then
        self.searchObj:SetActive(false)
        self.leftRect.sizeDelta = Vector2(470, 450)
        self.ScrollCon.sizeDelta = Vector2(466, 402)
        self.leftRect.anchoredPosition = Vector2(20, -33)
        self.Container.gameObject:SetActive(false)
        self.rankContainer.gameObject:SetActive(true)
        self.ScrollCon:GetComponent(ScrollRect).content = self.rankContainer

        self.setting1.data_list = self:GetRankList(1)
        self.vScroll.onValueChanged:RemoveAllListeners()
        self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting1) end)
        BaseUtils.refresh_circular_list(self.setting1)
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            title.text = TI18N("  排名     编号          名称           声音简介                 好评  ")
            self.descButton.gameObject:SetActive(true)
            self.descButton.transform.localPosition = Vector2(200, -20)
        else
            title.text = TI18N("  排名     编号          名称           声音简介                 人气  ")
            self.descButton.gameObject:SetActive(false)
        end
    elseif index == 4 then
        self.searchObj:SetActive(false)
        self.leftRect.sizeDelta = Vector2(470, 450)
        self.ScrollCon.sizeDelta = Vector2(466, 402)
        self.leftRect.anchoredPosition = Vector2(20, -33)
        self.Container.gameObject:SetActive(false)
        self.rankContainer.gameObject:SetActive(true)
        self.ScrollCon:GetComponent(ScrollRect).content = self.rankContainer

        self.setting1.data_list = self:GetRankList(2)
        self.vScroll.onValueChanged:RemoveAllListeners()
        self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting1) end)
        BaseUtils.refresh_circular_list(self.setting1)
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            title.text = TI18N("  排名     编号          名称           声音简介                 好听  ")
            self.descButton.gameObject:SetActive(true)
            self.descButton.transform.localPosition = Vector2(200, -20)
        else
            title.text = TI18N("  排名     编号          名称           声音简介                 人气  ")
            self.descButton.gameObject:SetActive(false)
        end
    end
end

function SingMainWindow:GetRankList(rankType)
    local tList = {}
    local list = {}
    if SingManager.Instance.songList ~= nil then
        for k,v in pairs(SingManager.Instance.songList) do
            table.insert(tList, v)
        end
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            if rankType == nil then
                table.sort(tList, function(a,b) return a.liked > b.liked end)
            elseif rankType == 1 then
                table.sort(tList, function(a,b) return a.liked > b.liked end)
            elseif rankType == 2 then
                table.sort(tList, function(a,b) return a.only_liked > b.only_liked end)
            end
        else
            table.sort(tList, function(a,b) return a.caster_num > b.caster_num end)
        end
        for i=1,50 do
            if tList[i] == nil then
                break
            else
                table.insert(list, tList[i])
            end
        end
    end
    return list
end

