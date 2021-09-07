QualifyMainWindow  =  QualifyMainWindow or BaseClass(BaseWindow)

function QualifyMainWindow:__init(model)
    self.name  =  "QualifyMainWindow"
    self.model  =  model

    self.windowId = WindowConfig.WinID.qualifying_window
    -- 缓存
    -- self.cacheMode = CacheMode.Visible
    -- self.winLinkType = WinLinkType.Single

    self.list_has_init = false
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.qualifying_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.qualifying_lev_icon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.qualifying_res, type  =  AssetType.Dep}
    }
    self.rank_list_has_init = false
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.match_go_id = 0
    self.total_go_time = 0

    self.is_open = false
    return self
end

function QualifyMainWindow:OnShow()
     --请求当前匹配状态
    QualifyManager.Instance:request13511()
    --请求排行榜数据
    self.rank_load_num = 50
    QualifyManager.Instance:request13508(self.model.rank_type.all, 1, self.rank_load_num)
    --请求段位信息
    QualifyManager.Instance:request13504(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    --请求可参与次数
    --请求当前活动动态
    QualifyManager.Instance:request13509()
end

function QualifyMainWindow:OnHide()
    GuideManager.Instance:CloseWindow(self.windowId)
end

function QualifyMainWindow:__delete()
    self.ImgLeftIcon.sprite = nil
    self:stop_go_timer()
    self.is_open = false
    self.rank_list_has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function QualifyMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.qualifying_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "QualifyMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    self.LeftCon = self.MainCon.transform:FindChild("LeftCon")
    self.TopCon = self.LeftCon:FindChild("TopCon")
    self.FriendToggle = self.TopCon:FindChild("FriendToggle"):GetComponent(Toggle)

    self.FriendToggle.onValueChanged:AddListener( function()
        self:on_click_toggle()
    end)

    self.BottomCon = self.LeftCon:FindChild("BottomCon")
    self.ItemMySelf = self.BottomCon:FindChild("ItemMySelf").gameObject

    self.ItemCon = self.BottomCon:FindChild("ItemCon")
    self.MaskCon = self.ItemCon:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.vScroll = self.ScrollLayer:GetComponent(LVerticalScrollRect)


    self.RightCon = self.MainCon.transform:FindChild("RightCon")
    self.TopCon = self.RightCon.transform:FindChild("TopCon")
    self.BtnTanHao = self.TopCon.transform:FindChild("BtnTanHao"):GetComponent(Button)
    self.ImgLeftIconCon = self.TopCon.transform:FindChild("ImgLeftIconCon")
    self.ImgLeftIcon = self.ImgLeftIconCon.transform:FindChild("ImgLeftIcon"):GetComponent(Image)
    self.TxtLeftIconName = self.ImgLeftIconCon.transform:FindChild("TxtLeftIconName"):GetComponent(Text)
    self.TxtLeftIconPoint = self.ImgLeftIconCon.transform:FindChild("TxtLeftIconPoint"):GetComponent(Text)
    self.ImgLeftIconCon.transform:Find("Img"):SetSiblingIndex(1)

    self.Item1 = self.TopCon.transform:FindChild("Item1")
    self.TxtWinRate = self.Item1.transform:FindChild("TxtWinRate"):GetComponent(Text)

    self.Item2 = self.TopCon.transform:FindChild("Item2")
    self.ImgProg = self.Item2.transform:FindChild("ImgProg")
    self.ImgProgBar = self.ImgProg.transform:FindChild("ImgProgBar"):GetComponent(Image)
    self.TxtProg = self.ImgProg.transform:FindChild("TxtProg"):GetComponent(Text)

    self.Item3 = self.TopCon.transform:FindChild("Item3")
    self.ImgTxtGood = self.Item3.transform:FindChild("ImgTxtGood")
    self.TxtGood = self.ImgTxtGood.transform:FindChild("TxtGood"):GetComponent(Text)

    self.MidCon = self.RightCon.transform:FindChild("MidCon")
    self.M_ScrollLayer = self.MidCon.transform:FindChild("ScrollLayer")
    self.m_vScroll = self.M_ScrollLayer:GetComponent(LVerticalScrollRect)


    self.BottomCon = self.RightCon.transform:FindChild("BottomCon")
    self.BtnCon = self.BottomCon.transform:FindChild("BtnCon")
    self.BtnFirstWin = self.BtnCon.transform:FindChild("BtnFirstWin"):GetComponent(Button)
    self.BtnFineWin = self.BtnCon.transform:FindChild("BtnFineWin"):GetComponent(Button)

    self.ImgPoint1 = self.BtnFirstWin.transform:FindChild("ImgPoint").gameObject
    self.ImgPoint2 = self.BtnFineWin.transform:FindChild("ImgPoint").gameObject

    self.img_first_get = self.BtnFirstWin.transform:FindChild("ImgActive").gameObject
    self.img_fine_get = self.BtnFineWin.transform:FindChild("ImgActive").gameObject

    self.img_first_get:SetActive(false)
    self.img_fine_get:SetActive(false)

    self.ImgPoint1:SetActive(false)
    self.ImgPoint2:SetActive(false)

    self.BottomRewardTips = self.BtnCon.transform:FindChild("BottomRewardTips").gameObject
    self.ImgMask_btn = self.BottomRewardTips.transform:FindChild("ImgMask"):GetComponent(Button)
    self.BottomRewardTips:SetActive(false)
    self.show_first_kill_tips = false
    self.show_first_skill_slots = {}

    self.BtnShop = self.BottomCon.transform:FindChild("BtnShop"):GetComponent(Button)
    self.BtnMatch = self.BottomCon.transform:FindChild("BtnMatch"):GetComponent(Button)
    self.effect_20118 = self.BtnMatch.transform:FindChild("20118").gameObject
    self.BtnMatch_txt = self.BtnMatch.transform:FindChild("Text"):GetComponent(Text)
    self.BtnMatch_pointtxt = self.BtnMatch.transform:FindChild("TxtPoint"):GetComponent(Text)

    self.effect_20118:SetActive(false)
    Utils.ChangeLayersRecursively(self.effect_20118.transform, "UI")


    self.CloseButton =  self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseQualifyMainUI() end)
    self.ImgMask_btn.onClick:AddListener(function()
        self.ImgMask_btn.gameObject:SetActive(false)
        self.BottomRewardTips:SetActive(false)
    end)
    self.BtnShop.onClick:AddListener(function() self:on_click_btn(1) end)
    self.BtnMatch.onClick:AddListener(function() self:on_click_btn(2) end)
    self.BtnFineWin.onClick:AddListener(function() self:on_click_btn(3) end)
    self.BtnFirstWin.onClick:AddListener(function() self:on_click_btn(4) end)


    self.BtnTanHao.onClick:AddListener(function()
        self.model:OpenQualifyMyBestUI()
    end)

    --请求当前匹配状态
    QualifyManager.Instance:request13511()
    --请求排行榜数据
    self.rank_load_num = 50
    QualifyManager.Instance:request13508(self.model.rank_type.all, 1, self.rank_load_num)
    --请求段位信息
    QualifyManager.Instance:request13504(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    --请求可参与次数
    --请求当前活动动态
    -- QualifyManager.Instance:request13509()

    self.is_open = true
end

--更新奖励按钮红点
function QualifyMainWindow:update_reward_btn_point()
    if self.gameObject ==  nil then
        --加载回调两次，这里暂时处理
        return
    end

    if QualifyManager.Instance.model.sign_type ~= 0 then
        --匹配中显示底部信息
        self.effect_20118:SetActive(false)
        self.BtnMatch_txt.text = TI18N("匹配中")
        self:star_go_timer()
    else
        self.effect_20118:SetActive(true)
        self.BtnMatch_txt.text = TI18N("开始匹配")
    end

    self.ImgPoint1:SetActive(false)
    self.ImgPoint2:SetActive(false)
    --判断下五胜和首胜奖励能否领取
    if self.model.match_state_data.win_flag ~= 1 and self.model.match_state_data.win >= 1 then
        self.ImgPoint1:SetActive(true)
    end
    if self.model.match_state_data.win_five_flag ~= 1 and self.model.match_state_data.win > 4 then
        self.ImgPoint2:SetActive(true)
    end
end

---------------------------各种更新逻辑
--更新界面信息
function QualifyMainWindow:update_qualify_info()

    -- BaseUtils.dump()

    self:stop_go_timer()

    self.BtnMatch_pointtxt.text = ""
    if QualifyManager.Instance.model.sign_type ~= 0 then
        --匹配中显示底部信息
        self.effect_20118:SetActive(false)
        self.BtnMatch_txt.text = TI18N("匹配中")
        self:star_go_timer()
    else
        self.effect_20118:SetActive(true)
        self.BtnMatch_txt.text = TI18N("开始匹配")
    end

    self.TxtGood.text = tostring(self.model.mine_qualify_data.thumb_up)

    local TxtWinRate_str = ""
    if self.model.mine_qualify_data.season_combat_count > 0 then
        local temp_rate = (self.model.mine_qualify_data.season_win_count/self.model.mine_qualify_data.season_combat_count)
        local rate = math.floor(temp_rate*100)
        rate = string.format("%s%s",rate, "%")
        TxtWinRate_str = string.format("%s <color='%s'>(%s)</color>", self.model.mine_qualify_data.season_win_count, ColorHelper.color[1], rate)
    else
        TxtWinRate_str = string.format("%s <color='%s'>(%s)</color>", self.model.mine_qualify_data.season_win_count, ColorHelper.color[1], "0%")
    end
    self.TxtWinRate.text = TxtWinRate_str

    local cfg_data = DataQualifying.data_qualify_data_list[self.model.mine_qualify_data.rank_lev]
    local next_cfg_data = nil
    local next_lev = self.model.mine_qualify_data.rank_lev + 1
    if next_lev <= self.model.max_qualify_lev then
        next_cfg_data = DataQualifying.data_qualify_data_list[next_lev]
    end

    self.ImgLeftIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.qualifying_lev_icon,tostring(cfg_data.rank_type))
    self.TxtLeftIconName.text = cfg_data.lev_name
    self.TxtLeftIconPoint.text = tostring(self.model.mine_qualify_data.rank_point)
    self.ImgLeftIcon.gameObject:SetActive(true)

    local rectTrans  = self.ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    local width = (self.model.mine_qualify_data.rank_point - cfg_data.point) / cfg_data.need_point
    local prot_str = string.format("%s/%s", self.model.mine_qualify_data.rank_point - cfg_data.point, cfg_data.need_point)

    width = width > 1 and 1 or width
    self.TxtProg.text = prot_str
    width = width*146
    rectTrans.sizeDelta = Vector2(width, rectTrans.rect.height)
end

--更新五胜和首胜领取状态
function QualifyMainWindow:update_fine_and_first_reward()
    if self.is_open == false then
        return
    end
    if self.model.match_state_data.win_flag == 1 then
        self.img_first_get:SetActive(true)
    else
        self.img_first_get:SetActive(false)
    end

    if self.model.match_state_data.win_five_flag == 1 then
        self.img_fine_get:SetActive(true)
    else
        self.img_fine_get:SetActive(false)
    end
end

--更新排行榜
function QualifyMainWindow:update_rank_items(data)
    -- print("-------------------------收到段位赛数据")
    if self.rank_list_has_init == false  then
        self.rank_list_has_init = true
        self.current_rank_type = data.type
        local GetData = function(index)
            return {item_index = index+1, data = self.model.rank_data_list[index+1]}
        end
        self.vScroll:SetPoolInfo(#self.model.rank_data_list, "QualifyMainRankItem", GetData, {assetWrapper = self.assetWrapper})
    else
        self.vScroll:RefreshList(#self.model.rank_data_list)
    end
    self.ItemMySelf:SetActive(false)
    for i=1,#self.model.rank_data_list do
        local data = self.model.rank_data_list[i]
        if data.rid == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
            if i ~= 1 then
                local TxtIndex = self.ItemMySelf.transform:FindChild("TxtIndex"):GetComponent(Text)
                local ImgIndex3 = self.ItemMySelf.transform:FindChild("ImgIndex3").gameObject
                local ImgIndex2 = self.ItemMySelf.transform:FindChild("ImgIndex2").gameObject
                local ImgIndex1 = self.ItemMySelf.transform:FindChild("ImgIndex1").gameObject
                local TxtName = self.ItemMySelf.transform:FindChild("TxtName"):GetComponent(Text)
                local TxtZone = self.ItemMySelf.transform:FindChild("TxtZone"):GetComponent(Text)
                local TxtNum = self.ItemMySelf.transform:FindChild("TxtNum"):GetComponent(Text)
                local TxtRate = self.ItemMySelf.transform:FindChild("TxtRate"):GetComponent(Text)

                ImgIndex1:SetActive(false)
                ImgIndex2:SetActive(false)
                ImgIndex3:SetActive(false)
                TxtIndex.gameObject:SetActive(false)
                if i == 1 then
                    ImgIndex1:SetActive(true)
                elseif i == 2 then
                    ImgIndex2:SetActive(true)
                elseif i == 3 then
                    ImgIndex3:SetActive(true)
                else
                    TxtIndex.gameObject:SetActive(true)
                    TxtIndex.text = tostring(i)
                end
                self.ItemMySelf:SetActive(false)
            end
            return
        end
    end
end

--更新右边中间排行榜
function QualifyMainWindow:update_activitys()
    if #self.model.qualifying_activitys.msg_list == 0 then
        return
    end

    if self.list_has_init == false then
        self.list_has_init = true
        local GetData = function(index)
            return {item_index = index+1, data = self.model.qualifying_activitys.msg_list[index+1]}
        end
        self.m_vScroll:SetPoolInfo(#self.model.qualifying_activitys.msg_list, "QualifyMainActItem", GetData, {assetWrapper = self.assetWrapper})
    else
        self.m_vScroll:RefreshList(#self.model.qualifying_activitys.msg_list)
    end

end

----------------------------按钮点击监听逻辑
--按钮监听逻辑
function QualifyMainWindow:on_click_btn(index)
    if index == 4 then
        if self.model.match_state_data.win_flag == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("已领取"))
            return
        end
        --首胜奖励
        QualifyManager.Instance:request13514(1)
    elseif index == 3 then
        if self.model.match_state_data.win_five_flag == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("已领取"))
            return
        end
        --五胜奖励
        QualifyManager.Instance:request13514(2)
    elseif index == 1 then
        --打开积分商店
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {2, 1})
    elseif index == 2 then
        if SceneManager.Instance:CurrentMapId() == 30003 then
            --请求开始匹配
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.Match and self.model.sign_type == 0 then
                QualifyManager.Instance:request13500(self.model.qualifying_type.type_1)
            elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Match and self.model.sign_type ~= 0 then
                self.model:OpenQualifyMatchUI()
            end
        else
            if self.model.activity_state == 0 then
                --活动关闭
                NoticeManager.Instance:FloatTipsByString(TI18N("活动未开启，请留意活动开启时间"))
            else
                --活动开启或准备中
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("需要进入比赛场地进行匹配，是否进入")
                data.sureLabel = TI18N("进入")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    QualifyManager.Instance.click_callback()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

--toggle选中逻辑
function QualifyMainWindow:on_click_toggle()
    if self.FriendToggle.isOn then
        --勾选
        QualifyManager.Instance:request13508(self.model.rank_type.friend, 1, self.rank_load_num)
    else
        --没勾选
        QualifyManager.Instance:request13508(self.model.rank_type.all, 1, self.rank_load_num)
    end
end


------------------------------------底部逻辑
--开启计时器
function QualifyMainWindow:star_go_timer()
    self:stop_go_timer()
    self.match_go_id = LuaTimer.Add(0, 1000, function()
        self:update_timer_tick()
    end)
end

--停止计时器
function QualifyMainWindow:stop_go_timer()
    if self.match_go_id ~= 0 then
        LuaTimer.Delete(self.match_go_id)
        self.match_go_id = 0
        self.total_go_time = 0
    end
end



--外部计时器调用
function QualifyMainWindow:update_timer_tick()
    self.total_go_time = self.total_go_time + 1
    local mod = self.total_go_time%4
    if mod == 1 then
        self.BtnMatch_pointtxt.text = TI18N(".")
    elseif mod == 2 then
        self.BtnMatch_pointtxt.text = TI18N("..")
    elseif mod == 3 then
        self.BtnMatch_pointtxt.text = TI18N("...")
    else
        self.BtnMatch_pointtxt.text = TI18N("")
    end
end

