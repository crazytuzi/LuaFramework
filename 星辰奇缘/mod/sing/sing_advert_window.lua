-- -----------------------------
-- 好声音宣传界面
-- hosr
-- -----------------------------
SingAdvertWindow = SingAdvertWindow or BaseClass(BaseWindow)

function SingAdvertWindow:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.sing_advert, type = AssetType.Main},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
    }

    self.isHideMainUI = false

    self.max = 0
    self.count = 0
    self.timeId = nil
    self.isShowHistory = false
    self.pictureTab = {}
end

function SingAdvertWindow:__delete()
    self.pictureTab = nil
    for i,v in ipairs(self.rank_item_list) do
        v:DeleteMe()
    end
    self.rank_item_list = nil
    self.setting.data_list = nil

    self.model.playCallback = nil
    self:StopSong()
    if self.friendPanel ~= nil then
        self.friendPanel:DeleteMe()
    end
    self.friendPanel = nil
end

function SingAdvertWindow:Close()
    SingManager.Instance.model:CloseAdvert()
end

function SingAdvertWindow:OnShow()
    if not self:IsSelf() then
        self:CheckButtonStatus7()
    end
end

function SingAdvertWindow:OnInitCompleted()
    self:OnShow()
end

function SingAdvertWindow:OnHide()
end

function SingAdvertWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sing_advert))
    self.gameObject.name = "SingAdvertWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.big = self.transform:Find("Main").gameObject

    self.mainRcet = self.transform:Find("Main"):GetComponent(RectTransform)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/SmallButton"):GetComponent(Button).onClick:AddListener(function() self:ShowSmall() end)
    self.transform:Find("Main/Head"):GetComponent(Button).onClick:AddListener(function() self:ClickHead() end)
    self.headImg = self.transform:Find("Main/Head/Image"):GetComponent(Image)
    self.headImg.gameObject:SetActive(true)

    self.btn1 = self.transform:Find("Main/Button1"):GetComponent(Button)
    self.btn2 = self.transform:Find("Main/Button2"):GetComponent(Button)
    self.btn3 = self.transform:Find("Main/Button3"):GetComponent(Button)
    self.btn1.onClick:AddListener(function() self:onClick1() end)
    self.btn2.onClick:AddListener(function() self:onClick2() end)
    self.btn3.onClick:AddListener(function() self:onClick3() end)

    self.btn4 = self.transform:Find("Main/Button4"):GetComponent(Button)
    self.btn5 = self.transform:Find("Main/Button5"):GetComponent(Button)
    self.btn6 = self.transform:Find("Main/Button6"):GetComponent(Button)
    self.btn7 = self.transform:Find("Main/Button7"):GetComponent(Button)
    self.btn4.onClick:AddListener(function() self:onClick4() end)
    self.btn5.onClick:AddListener(function() self:onClick3() end)
    self.btn6.onClick:AddListener(function() self:onClick6() end)
    self.btn7.onClick:AddListener(function() self:onClick7() end)

    self.num = self.transform:Find("Main/Num/Val/Text"):GetComponent(Text)
    self.goodTitle = self.transform:Find("Main/Good/Text"):GetComponent(Text)
    self.good = self.transform:Find("Main/Good/Val/Text"):GetComponent(Text)
    self.goodImg = self.transform:Find("Main/Good/Val/Image").gameObject

    self.desc = self.transform:Find("Main/Desc/Desc"):GetComponent(Text)

    self.playBtn = self.transform:Find("Main/Option/PlayBtn"):GetComponent(Button)
    self.playImg = self.transform:Find("Main/Option/PlayBtn/PlayBtn"):GetComponent(Image)
    self.slider = self.transform:Find("Main/Option/Slider"):GetComponent(Slider)
    self.slderVal = self.transform:Find("Main/Option/Slider/Val"):GetComponent(Text)
    self.playBtn.onClick:AddListener(function() self:OnPlay() end)

    self.history = self.transform:Find("Main/History").gameObject
    self.history:SetActive(false)
    self.nothing = self.transform:Find("Main/History/Nothing").gameObject
    self.nothing:SetActive(false)

    self.small = self.transform:Find("Small").gameObject
    self.transform:Find("Small/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Small/SmallButton"):GetComponent(Button).onClick:AddListener(function() self:ShowBig() end)
    self.smallplayBtn = self.transform:Find("Small/Option/PlayBtn"):GetComponent(Button)
    self.smallplayImg = self.transform:Find("Small/Option/PlayBtn/PlayBtn"):GetComponent(Image)
    self.smallslider = self.transform:Find("Small/Option/Slider"):GetComponent(Slider)
    self.smallslderVal = self.transform:Find("Small/Option/Slider/Val"):GetComponent(Text)
    self.smallplayBtn.onClick:AddListener(function() self:OnPlay() end)
    self.small:SetActive(false)

    self.Container = self.transform:Find("Main/History/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/History/Scroll")
    self.ScrollConObj = self.ScrollCon.gameObject
    self.rank_item_list = {}
    for i = 1, 8 do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = SingSupportItem.New(go, self)
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

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self:ShowHistory(false)
    self:SetData()
end

function SingAdvertWindow:SetData()
    if self.openArgs == nil or self.openArgs.id == nil then
        self.rid = RoleManager.Instance.RoleData.id
        self.platform = RoleManager.Instance.RoleData.platform
        self.zone_id = RoleManager.Instance.RoleData.zone_id
        self.name = RoleManager.Instance.RoleData.name
        self.id = SingManager.Instance.mySongId
        self.summary = SingManager.Instance.mySongDesc
        self.classes = RoleManager.Instance.RoleData.classes
        self.sex = RoleManager.Instance.RoleData.sex

        self.singData = {rid = self.rid, platform = self.platform, zone_id = self.zone_id, update_time = 0}

        -- self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex))

        self.num.text = SingManager.Instance.mySongId
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            self.goodImg:SetActive(true)
            self.goodTitle.text = TI18N("好评:")
            self.good.text = SingManager.Instance:ShowLiked(SingManager.Instance.mySongLiked)
        else
            self.goodImg:SetActive(false)
            self.good.text = SingManager.Instance.mySongPlay
            self.goodTitle.text = TI18N("人气:")
        end
        self.desc.text = SingManager.Instance.mySongDesc
        self.slderVal.text = SingManager.Instance.mySongTime

        self.max = SingManager.Instance.mySongTime
    else
        self.singData = self.openArgs
        self.rid = self.singData.rid
        self.platform = self.singData.platform
        self.zone_id = self.singData.zone_id
        self.name = self.singData.name
        self.id = self.singData.id
        self.summary = self.singData.summary
        self.classes = self.singData.classes
        self.sex = self.singData.sex

        -- self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.classes, self.sex))
        self.num.text = self.singData.id
        if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
            self.goodImg:SetActive(true)
            self.goodTitle.text = TI18N("好评:")
            self.good.text = SingManager.Instance:ShowLiked(self.singData.liked)
        else
            self.good.text = self.singData.caster_num
            self.goodImg:SetActive(false)
            self.goodTitle.text = TI18N("人气:")
        end
        self.desc.text = self.singData.summary
        self.slderVal.text = self.singData.time

        self.max = self.singData.time
    end

    local sprite = self.pictureTab[string.format("%s_%s_%s", self.rid, self.platform, self.zone_id)]
    if sprite == nil then
        self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.classes, self.sex))
        ZoneManager.Instance:RequirePhotoQueue(self.rid, self.platform, self.zone_id, function(photo)
            if not BaseUtils.isnull(self.headImg) then
                self:toPhoto(photo, self.headImg, self.rid, self.platform, self.zone_id)
            end
            end)
    else
        self.headImg.sprite = sprite
    end

    self.btn1.gameObject:SetActive(self:IsSelf())
    self.btn2.gameObject:SetActive(self:IsSelf())
    self.btn3.gameObject:SetActive(self:IsSelf())
    self.btn4.gameObject:SetActive(not self:IsSelf())
    self.btn5.gameObject:SetActive(not self:IsSelf())
    self.btn6.gameObject:SetActive(not self:IsSelf())
    self.btn7.gameObject:SetActive(not self:IsSelf())

    self.slderVal.text = string.format(TI18N("%s秒"), self.max)
    self.slider.value = 0
    self.smallslderVal.text = string.format(TI18N("%s秒"), self.max)
    self.smallslider.value = 0
end

function SingAdvertWindow:IsSelf()
    local own = string.format("%s_%s_%s", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    if self.uid == nil then
        self.uid = string.format("%s_%s_%s", self.rid, self.platform, self.zone_id)
    end
    if own == self.uid then
        return true
    end
    return false
end

function SingAdvertWindow:UpdateSlider()
    self.slderVal.text = string.format(TI18N("%s秒"), self.count)
    self.slider.value = self.count / self.max

    self.smallslderVal.text = string.format(TI18N("%s秒"), self.count)
    self.smallslider.value = self.count / self.max

    if self.slider.value >= 1 then
        self:StopSong()
    end
end

-- 编辑
function SingAdvertWindow:onClick1()
    SingManager.Instance.model:OpenSignup()
end

-- 查看自己好评记录
function SingAdvertWindow:onClick2()
    self.isShowHistory = not self.isShowHistory
    self:ShowHistory(self.isShowHistory)
end

-- 宣传
function SingAdvertWindow:onClick3()
    if self.id == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有可宣传的歌曲"))
        return
    end
    local btns = {
        {label = TI18N("分享好友"), callback = function() self:Share(MsgEumn.ChatChannel.Private) end}
        ,{label = TI18N("世界频道"), callback = function() self:Share(MsgEumn.ChatChannel.World) end}
    }
    if GuildManager.Instance.model:check_has_join_guild() then
        table.insert(btns, {label = TI18N("公会频道"), callback = function() self:Share(MsgEumn.ChatChannel.Guild) end})
    end

    if self:IsSelf() then
        TipsManager.Instance:ShowButton({gameObject = self.btn3.gameObject, data = btns})
    else
        TipsManager.Instance:ShowButton({gameObject = self.btn5.gameObject, data = btns})
    end
end

-- 举报
function SingAdvertWindow:onClick4()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function() SingManager.Instance:Send16807(self.rid, self.platform, self.zone_id) end
    confirmData.content = TI18N("成功举报后系统将给予第一个举报的玩家奖励，是否继续？")
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 送花
function SingAdvertWindow:onClick6()
    local data = {}
    data.id = self.singData.rid
    data.platform = self.singData.platform
    data.zone_id = self.singData.zone_id
    data.name = self.singData.name
    data.classes = self.singData.classes
    data.sex = self.singData.sex
    data.lev = self.singData.lev

    if SingManager.Instance.activeState == SingEumn.ActiveState.Vote or SingManager.Instance.activeState == SingEumn.ActiveState.FinalVote then
        GivepresentManager.Instance:OpenGiveWin(data)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() GivepresentManager.Instance:OpenGiveWin(data) end
        confirmData.content = TI18N("当前<color='#ffff00'>星辰好声音</color>活动处于<color='#ffff00'>报名阶段</color>，送花将不增加好评数，是否继续？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

-- 好评
function SingAdvertWindow:onClick7()
    SingManager.Instance:Send16810(self.rid, self.platform, self.zone_id)
end

-- 播放
function SingAdvertWindow:OnPlay()
    if SingManager.Instance.songPlaying then
        self:StopSong()
    else
        SingManager.Instance.currentPlayKey = string.format("%s_%s_%s", self.rid, self.platform, self.zone_id)
        self.model.playCallback = function() self:PlaySong() end
        SingManager.Instance.model:PlaySong(self.singData)
    end
end

function SingAdvertWindow:PlaySong()
    self:TimeCount()
    self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
    self.smallplayImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingStopBtn")
end

function SingAdvertWindow:StopSong()
    SingManager.Instance.currentPlayKey = ""
    self:StopTimeCount()
    self.playImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
    self.smallplayImg.sprite = self.assetWrapper:GetSprite(AssetConfig.sing_res, "SingPlayBtn")
    SingManager.Instance.model:StopSong()

    self.slderVal.text = string.format(TI18N("%s秒"), self.max)
    self.slider.value = 0

    self.smallslderVal.text = string.format(TI18N("%s秒"), self.max)
    self.smallslider.value = 0
end

function SingAdvertWindow:StopTimeCount()
    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
    self.count = 0
end

function SingAdvertWindow:TimeCount()
    self:StopTimeCount()
    self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function SingAdvertWindow:Loop()
    self.count = self.count + 1
    self:UpdateSlider()
end

function SingAdvertWindow:ClickHead()
    if self.singData ~= nil then
        TipsManager.Instance:ShowPlayer(self.singData)
    end
end

function SingAdvertWindow:Share(channel)
    local str = string.format("{sing_1,%s,%s,%s,%s,%s}", self.rid, self.platform, self.zone_id, self.name, self.id)
    if channel == MsgEumn.ChatChannel.Private then
        local setting = {
            ismulti = true,
            maxnum = 5,
            callback = function(list) self:SeleteFriend(list, str) NoticeManager.Instance:FloatTipsByString(TI18N("已成功分享给好友")) end
        }
        if self.friendPanel == nil then
            self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
        end
        self.friendPanel:Show()
    else
        local res = ChatManager.Instance:SendMsg(channel, str)
        if res then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("宣传已发送到%s频道{face_1,18}"), MsgEumn.ChatChannelName[channel]))
        end
    end
end

function SingAdvertWindow:SeleteFriend(list, str)
    for i,v in ipairs(list) do
        FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
    end
end

function SingAdvertWindow:ShowSmall()
    self.big:SetActive(false)
    self.small:SetActive(true)
end

function SingAdvertWindow:ShowBig()
    self.big:SetActive(true)
    self.small:SetActive(false)
end

function SingAdvertWindow:ShowHistory(bool)
    if bool then
        self:UpdateHistory(self.setting.data_list)
        if #self.setting.data_list == 0 then
            SingManager.Instance:Send16811(self.rid, self.platform, self.zone_id)
        end
        self.mainRcet.anchoredPosition = Vector2(-150, -25)
    else
        self.mainRcet.anchoredPosition = Vector2(0, -25)
    end
    self.history:SetActive(bool)
end

function SingAdvertWindow:UpdateHistory(list)
    self.setting.data_list = list
    BaseUtils.refresh_circular_list(self.setting)

    if #list == 0 then
        self.nothing:SetActive(true)
        self.ScrollConObj:SetActive(false)
    else
        self.nothing:SetActive(false)
        self.ScrollConObj:SetActive(true)
    end
end

function SingAdvertWindow:toPhoto(photo, img, id, platform, zone_id)
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

function SingAdvertWindow:CheckButtonStatus7()
    local t = self.btn7.transform

    local status = self:HasComment()
    t:Find("Image").gameObject:SetActive(not status)
    BaseUtils.SetGrey(t:GetComponent(Image), status)
    if not status then
        t:Find("Text").anchoredPosition = Vector2(10, 0)
        t:Find("Text"):GetComponent(Text).text = TI18N("好评")
    else
        t:Find("Text"):GetComponent(Text).text = TI18N("已好评")
        t:Find("Text").anchoredPosition = Vector2(0, 0)
    end
end

function SingAdvertWindow:HasComment()
    return self.model.advertTabToday ~= nil and self.model.advertTabToday[self.uid] == 1
end

