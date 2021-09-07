QualifyFinishWindow  =  QualifyFinishWindow or BaseClass(BaseWindow)

function QualifyFinishWindow:__init(model)
    self.name  =  "QualifyFinishWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.qualifying_finish, type  =  AssetType.Main}
        , {file  =  AssetConfig.qualifying_lev_icon, type  =  AssetType.Dep}
    }


    self.plus_total_count = 0
    self.divide_total_count = 0
    self.count = 0
    self.count_end = 0
    self.now_count_end = 0
    self.now_win_point = 0
    self.point_count = 0
    self.run_total_count = 0
    self.has_init = false
    self.progBarMax = 166
    self.tweenId1 = nil
    self.tweenId2 = nil

    self.win_timer_id = 0
    self.duanwei_timer_id = 0
    self.run_plus_timer_id = 0
    self.run_divide_timer_id = 0

    self.iconVal2Loader = nil
    self.iconVal3Loader = nil

    return self
end

function QualifyFinishWindow:__delete()
     if self.tweenId1 ~= nil then
         Tween.Instance:Cancel(self.tweenId1)
     end
     if self.tweenId2 ~= nil then
         Tween.Instance:Cancel(self.tweenId2)
     end

     if self.iconVal2Loader ~= nil then
        self.iconVal2Loader:DeleteMe()
        self.iconVal2Loader = nil
     end

     if self.iconVal3Loader ~= nil then
        self.iconVal3Loader:DeleteMe()
        self.iconVal3Loader = nil
     end

    self.ImgIcon.sprite = nil
    self:stop_rotate_win_bg()
    self:stop_rotate_duanwei_bg()
    self:stop_run_plus()
    self:stop_run_divide()

    self.win_timer_id = 0
    self.duanwei_timer_id = 0
    self.run_plus_timer_id = 0
    self.run_divide_timer_id = 0

    self.is_open = false

    self.plus_total_count = 0
    self.divide_total_count = 0
    self.count = 0
    self.count_end = 0
    self.now_count_end = 0
    self.now_win_point = 0
    self.point_count = 0
    self.run_total_count = 0
    self.has_init = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function QualifyFinishWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.qualifying_finish))
    self.gameObject:SetActive(false)
    self.gameObject.name = "QualifyFinishWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("FinishCon")
    self.TopCon = self.MainCon:FindChild("TopCon")
    self.ImgTitle = self.TopCon.transform:FindChild("ImgTitle").gameObject
    self.ImgWinWord = self.TopCon.transform:FindChild("ImgWinWord").gameObject
    self.ImgLoseWord = self.TopCon.transform:FindChild("ImgLoseWord").gameObject

    self.ImgTitle:SetActive(false)
    self.ImgWinWord:SetActive(false)
    self.ImgLoseWord:SetActive(false)

    self.MidCon = self.MainCon:FindChild("MidCon").gameObject
    self.ImgLeftIcon = self.MidCon.transform:FindChild("ImgLeftIcon").gameObject
    self.ImgLeftIconbg = self.ImgLeftIcon.transform:FindChild("ImgLeftIconbg").gameObject
    self.ImgIcon = self.ImgLeftIcon.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.TxtLeftIconName = self.ImgLeftIcon.transform:FindChild("TxtLeftIconName"):GetComponent(Text)
    self.TxtWinPoint = self.MidCon.transform:FindChild("TxtWinPoint"):GetComponent(Text)
    self.ImgArrowUp = self.MidCon.transform:FindChild("ImgArrowUp").gameObject
    self.ImgArrowDown = self.MidCon.transform:FindChild("ImgArrowDown").gameObject
    self.ImgArrowUp:SetActive(false)
    self.ImgArrowDown:SetActive(false)

    self.ImgProg = self.MidCon.transform:FindChild("ImgProg").gameObject
    self.ImgProgBar = self.ImgProg.transform:FindChild("ImgProgBar").gameObject
    self.ImgProgBar_rect = self.ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    self.TxtProgBar = self.ImgProg.transform:FindChild("TxtProgBar"):GetComponent(Text)

    self.tweenProgBarFun = function(val)
        self.ImgProgBar_rect.sizeDelta = Vector2(val, self.ImgProgBar_rect.rect.height)
    end

    self.tweenPlusFinishFun = function()
        if self.tweenId1 ~= nil then
            Tween.Instance:Cancel(self.tweenId1)
        end
        local width = math.floor((self.now_fenzi/self.now_fenmu)*self.progBarMax)
        self.tweenId1 = Tween.Instance:ValueChange(0, width, 0.6, nil, LeanTweenType.linear, self.tweenProgBarFun).id
    end

    self.tweenDivideFinishFun = function()
        if self.tweenId2 ~= nil then
            Tween.Instance:Cancel(self.tweenId2)
        end
        local width = math.floor((self.now_fenzi/self.now_fenmu)*self.progBarMax)
        self.tweenId2 = Tween.Instance:ValueChange(self.progBarMax, width, 0.6, nil, LeanTweenType.linear, self.tweenProgBarFun).id
    end

    self.TxtVal1 = self.MidCon.transform:FindChild("TxtVal1"):GetComponent(Text)
    self.iconVal2 = self.MidCon.transform:FindChild("ImgIcon2"):GetComponent(Image)
    self.TxtVal2 = self.MidCon.transform:FindChild("TxtVal2"):GetComponent(Text)
    self.iconVal3 = self.MidCon.transform:FindChild("ImgIcon3"):GetComponent(Image)
    self.TxtVal3 = self.MidCon.transform:FindChild("TxtVal3"):GetComponent(Text)

    self.TxtVal1.text = "+0"
    self.TxtVal2.text = "+0"
    self.TxtVal3.text = "+0"

    self.BottomCon = self.MainCon:FindChild("BottomCon").gameObject
    self.BottomItem1 = self.BottomCon.transform:FindChild("BottomItem1").gameObject
    self.ImgFriend_1 = self.BottomItem1.transform:FindChild("ImgFriend"):GetComponent(Button)
    self.ImgHead_1 = self.BottomItem1.transform:FindChild("ImgHead").gameObject
    self.Img_1 = self.ImgHead_1.transform:FindChild("Img"):GetComponent(Image)
    self.TxtLev_1 = self.ImgHead_1.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtName_1 = self.BottomItem1.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtZone_1 = self.BottomItem1.transform:FindChild("TxtZone"):GetComponent(Text)
    self.ImgGood_1 = self.BottomItem1.transform:FindChild("ImgGood"):GetComponent(Button)

    self.BottomItem2 = self.BottomCon.transform:FindChild("BottomItem2").gameObject
    self.ImgFriend_2 = self.BottomItem2.transform:FindChild("ImgFriend"):GetComponent(Button)
    self.ImgHead_2 = self.BottomItem2.transform:FindChild("ImgHead").gameObject
    self.Img_2 = self.ImgHead_2.transform:FindChild("Img"):GetComponent(Image)
    self.TxtLev_2 = self.ImgHead_2.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtName_2 = self.BottomItem2.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtZone_2 = self.BottomItem2.transform:FindChild("TxtZone"):GetComponent(Text)
    self.ImgGood_2 = self.BottomItem2.transform:FindChild("ImgGood"):GetComponent(Button)

    self.ImgReturnBack = self.BottomCon.transform:FindChild("ImgReturnBack"):GetComponent(Button)
    self.ImgBeginMatch = self.BottomCon.transform:FindChild("ImgBeginMatch"):GetComponent(Button)


    self.ImgReturnBack.onClick:AddListener(function() self:on_return_back() end)
    self.ImgBeginMatch.onClick:AddListener(function() self:on_match_click() end)
    self.ImgGood_1.onClick:AddListener(function() self:on_click_goood(1) end)
    self.ImgGood_2.onClick:AddListener(function() self:on_click_goood(2) end)
    self.ImgFriend_1.onClick:AddListener(function() self:on_click_friend(1) end)
    self.ImgFriend_2.onClick:AddListener(function() self:on_click_friend(2) end)

    self.has_init = true



    self:update_view()
end

---监听器
function QualifyFinishWindow:on_return_back()
    self.model:OpenQualifyMainUI()
end

function QualifyFinishWindow:on_match_click()
    QualifyManager.Instance:request13500(self.model.qualifying_type.type_1)
end

--好友点击
function QualifyFinishWindow:on_click_friend(g)
    if g == 1 then
        local data1 = self.model.qualifying_result.team_list[1]
        if data1 ~= nil then
            -- mod_friend.request11804(data1.rid, data1.platform, data1.zone_id)
            FriendManager.Instance:Require11804(data1.rid, data1.platform, data1.zone_id)
            self.ImgFriend_1.enabled=false
            self.ImgFriend_1.image.color = Color.grey
        end
    elseif g == 2 then
        local data2 = self.model.qualifying_result.team_list[2]
        if data2 ~= nil then
            -- mod_friend.request11804(data2.rid, data2.platform, data2.zone_id)
            FriendManager.Instance:Require11804(data2.rid, data2.platform, data2.zone_id)
            self.ImgFriend_2.enabled=false
            self.ImgFriend_2.image.color = Color.grey
        end
    end
end

function QualifyFinishWindow:on_click_goood(g)
    if g == 1 then
        local data = self.model.qualifying_result.team_list[1]
        QualifyManager.Instance:request13510(data.rid, data.platform, data.zone_id)
        self.ImgGood_1.enabled=false
        self.ImgGood_1.image.color = Color.grey
    elseif g == 2 then
        local data = self.model.qualifying_result.team_list[2]
        QualifyManager.Instance:request13510(data.rid, data.platform, data.zone_id)
        self.ImgGood_2.enabled=false
        self.ImgGood_2.image.color = Color.grey
    end
end

-------------------更新逻辑
function QualifyFinishWindow:update_view()
    self.ImgTitle:SetActive(false)
    self.ImgWinWord:SetActive(false)
    self.ImgLoseWord:SetActive(false)

    if self.model.qualifying_result.result == 1 or self.model.qualifying_result.result == 2 then
        self.ImgWinWord:SetActive(true)
        self.ImgTitle:SetActive(true)
        self:star_rotate_win_bg()
    else
        self.ImgLoseWord:SetActive(true)
    end

    local now_cfg_data = self.model:get_cfg_data_by_point(self.model.qualifying_result.a_rank_point)
    self.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.qualifying_lev_icon,tostring(now_cfg_data.rank_type))
    self.ImgIcon.gameObject:SetActive(true)
    self:star_rotate_duanwei_bg()
    self.TxtLeftIconName.text = now_cfg_data.lev_name

    local win_point = self.model.qualifying_result.a_rank_point - self.model.qualifying_result.b_rank_point

    self.ImgArrowUp:SetActive(false)
    self.ImgArrowDown:SetActive(false)
    if win_point > 0 then
        self.ImgArrowUp:SetActive(true)
    elseif win_point < 0 then
        self.ImgArrowDown:SetActive(true)
    else
        self.TxtWinPoint.text = "0"
    end

    local last_fenzi, last_fenmu = self:count_fenzi_fenmu(self.model.qualifying_result.b_rank_point)
    local now_fenzi, now_fenmu = self:count_fenzi_fenmu(self.model.qualifying_result.a_rank_point)
    self.TxtProgBar.gameObject:SetActive(true)
    if now_fenmu ~= -1 then
        if win_point ~= 0 then
            self:play_bar_run(now_fenzi, now_fenmu, last_fenzi, last_fenmu, win_point)
        else
            --直接设置进度条宽度
            -- self.TxtProgBar.text = string.format("%s/%s", now_fenzi, now_fenmu)
        end
    else
        --达到最高
        self.TxtProgBar.gameObject:SetActive(false)
        --直接设置进度条到最大
        local width = self.progBarMax
        self.ImgProgBar_rect.sizeDelta = Vector2(width, self.ImgProgBar_rect.rect.height)
    end

    --设置奖励
    for i=1,#self.model.qualifying_result.assets  do
        local dat = self.model.qualifying_result.assets[i]
        if dat ~= nil then
            if dat.id == 90012 then
                self.TxtVal1.text = tostring(dat.val)
            elseif dat.id == 90010 then
                if self.iconVal3Loader == nil then
                    self.iconVal3Loader = SingleIconLoader.New(self.iconVal3.gameObject)
                end
                self.iconVal3Loader:SetSprite(SingleIconType.Item, dat.id)
                self.TxtVal3.text = tostring(dat.val)
            elseif dat.id == 90005 then
                if self.iconVal2Loader == nil then
                    self.iconVal2Loader = SingleIconLoader.New(self.iconVal2.gameObject)
                end
                self.iconVal2Loader:SetSprite(SingleIconType.Item, dat.id)
                self.TxtVal2.text = tostring(dat.val)
            end
        end
    end


    --设置底部队友
     self.BottomItem1:SetActive(false)
     self.BottomItem2:SetActive(false)
    if #self.model.qualifying_result.team_list == 1 then
        self.BottomItem1:SetActive(true)
    elseif #self.model.qualifying_result.team_list == 2 then
        self.BottomItem1:SetActive(true)
        self.BottomItem2:SetActive(true)
    end

    for i=1,#self.model.qualifying_result.team_list do
        local data = self.model.qualifying_result.team_list[i]
        if i == 1 then
            self.Img_1.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s",tostring(data.classes),tostring(data.sex)))
            self.TxtName_1.text = data.name
            self.TxtZone_1.text = string.format("%s%s", data.zone_id, TI18N("区"))
            self.TxtLev_1.text = tostring(data.lev)
        elseif i== 2 then
            self.Img_2.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s",tostring(data.classes),tostring(data.sex)))
            self.TxtName_2.text = data.name
            self.TxtZone_2.text = string.format("%s%s", data.zone_id, TI18N("区"))
            self.TxtLev_2.text = tostring(data.lev)
        end
    end
end

--设置底部队友item数据
function QualifyFinishWindow:set_team_item_date(item, data, i)
    self.ImgGood_1 = self.BottomItem1.transform:FindChild("ImgGood").gameObject
    self.ImgGood_2 = self.BottomItem1.transform:FindChild("ImgGood").gameObject
end

--传入当前段位分，计算进度条的分子和分母
function QualifyFinishWindow:count_fenzi_fenmu(rank_point)
    local now_data = self.model:get_cfg_data_by_point(rank_point)
    local fenzi = rank_point - now_data.point
    --对应等级
    local fenmu = now_data.need_point
    return fenzi,fenmu
end

----------------------------播放逻辑
--播放胜利背景转圈
function QualifyFinishWindow:star_rotate_win_bg()
    self:stop_rotate_win_bg()
    self.win_timer_id = LuaTimer.Add(0, 2, function(id) self.ImgTitle.transform:RotateAround(self.ImgTitle.transform.position, self.ImgTitle.transform.forward, 0.4) end)
end

--停止播放胜利背景转圈
function QualifyFinishWindow:stop_rotate_win_bg()
    if self.win_timer_id ~= 0 then
        LuaTimer.Delete(self.win_timer_id)
        self.win_timer_id = 0
    end
end

--播放段位背景转圈
function QualifyFinishWindow:star_rotate_duanwei_bg()
    self:stop_rotate_duanwei_bg()
    self.duanwei_timer_id = LuaTimer.Add(0, 2, function()
        self.ImgLeftIconbg.transform:RotateAround(self.ImgLeftIconbg.transform.position, self.ImgLeftIconbg.transform.forward, 0.4)
        self.ImgTitle.transform:RotateAround(self.ImgTitle.transform.position, self.ImgTitle.transform.forward, 0.4)
    end)
end

--停止播放段位背景转圈
function QualifyFinishWindow:stop_rotate_duanwei_bg()
    if self.duanwei_timer_id ~= 0 then
        LuaTimer.Delete(self.duanwei_timer_id)
        self.duanwei_timer_id = 0
    end
end

--播放跑条
function QualifyFinishWindow:play_bar_run(now_fenzi, now_fenmu, last_fenzi, last_fenmu, win_point)

    -- print("===================ddddddd")
    -- print("now_fenzi ："..now_fenzi )
    -- print("now_fenmu ："..now_fenmu )
    -- print("last_fenzi："..last_fenzi)
    -- print("last_fenmu："..last_fenmu)
    -- BaseUtils.dump(self.model.qualifying_result)

    local rectTrans  = self.ImgProgBar.gameObject.transform:GetComponent(RectTransform)
    local width = math.floor((last_fenzi/last_fenmu)*self.progBarMax)
    self.ImgProgBar_rect.sizeDelta = Vector2(width, self.ImgProgBar_rect.rect.height)
    self.now_fenmu = now_fenmu
    self.now_fenzi = now_fenzi
    self.last_fenmu = last_fenmu
    self.last_fenzi = last_fenzi
    self.count = (last_fenzi/last_fenmu)*100
    self.now_count_end = (now_fenzi/now_fenmu)*100
    self.now_win_point = win_point
    if win_point < 0 then
        self.TxtWinPoint.text = string.format("%s", win_point)
    else
        self.TxtWinPoint.text = string.format("<color='#4dd52b'>+%s</color>", win_point)
    end




    self.TxtProgBar.text = string.format("%s/%s", now_fenzi, now_fenmu)
    if self.model.qualifying_result.b_rank_point < self.model.qualifying_result.a_rank_point then
        --进度条前进
        if (last_fenzi+win_point) > last_fenmu then
            --跑完last，在跑now
            self.tweenId1 = Tween.Instance:ValueChange(width, self.progBarMax, 0.6, self.tweenPlusFinishFun, LeanTweenType.linear, self.tweenProgBarFun).id
        else
            --直接跑now
            local endWidth = math.floor((self.now_fenzi/self.now_fenmu)*self.progBarMax)
            self.tweenId1 = Tween.Instance:ValueChange(width, endWidth, 0.6, nil, LeanTweenType.linear, self.tweenProgBarFun).id
        end
    else
        --进度条后退
        if (last_fenzi+win_point) < 0 then
            self.tweenId1 = Tween.Instance:ValueChange(width, 0, 0.6, self.tweenDivideFinishFun, LeanTweenType.linear, self.tweenProgBarFun).id
        else
            --直接跑now
            local endWidth = math.floor((self.now_fenzi/self.now_fenmu)*self.progBarMax)
            self.tweenId1 = Tween.Instance:ValueChange(width, endWidth, 0.6, nil, LeanTweenType.linear, self.tweenProgBarFun).id
        end
    end


    -- if win_point > 0 then
    --     --进度条前进
    --     self.count_end = now_fenzi
    --     self.cur_fenmu = self.last_fenmu
    --     if last_fenzi+win_point > last_fenmu then
    --         self.count_end = last_fenmu
    --     end

    --     self.plus_total_count = 100 - self.count + self.now_count_end
    --     self:star_run_plus()
    -- else
    --     --进度条后退
    --     self.count_end = now_fenzi
    --     self.cur_fenmu = self.last_fenmu
    --     if last_fenzi + win_point < last_fenmu then
    --         self.count_end = 0
    --     end
    --     self.divide_total_count = self.count + 100 - self.now_count_end
    --     self:star_run_divide()
    -- end
end

--跑条前进开始
function QualifyFinishWindow:star_run_plus()
    self:stop_run_plus()
    self.run_plus_timer_id = LuaTimer.Add(0, 2, function(id) self:run_plus_tick() end)
end

--跑条前进结束
function QualifyFinishWindow:stop_run_plus()
    if self.run_plus_timer_id ~= 0 then
        LuaTimer.Delete(self.run_plus_timer_id)
        self.run_plus_timer_id = 0
    end
end

--跑条前进tick
function QualifyFinishWindow:run_plus_tick()
    self.count = self.count + 1
    local percent = self.count / self.cur_fenmu
    local width = percent*self.progBarMax
    self.ImgProgBar_rect.sizeDelta = Vector2(width, self.ImgProgBar_rect.rect.height)

    self.run_total_count = self.run_total_count + 1
    self.point_count = math.floor(self.run_total_count/self.plus_total_count*self.now_win_point)
    -- self.TxtWinPoint.text = string.format("<color='#4dd52b'>+%s</color>", self.point_count)
    if self.count >= self.count_end then --前进到尽头
        if self.now_count_end ~= -1 then
            self.count = 0
            self.count_end = self.now_fenzi
            self.cur_fenmu = self.now_fenmu
            self:star_run_plus()
            self.now_count_end = -1
        else
            self:stop_run_plus()
            self.point_count = 0

            self:check_show_open_lock()
        end
    end
end


--跑条后退开始
function QualifyFinishWindow:star_run_divide()
    self:stop_run_divide()
    self.run_divide_timer_id = LuaTimer.Add(0, 2, function(id) self:run_divide_tick() end)
end

--跑条后退结束
function QualifyFinishWindow:stop_run_divide()
    if self.run_divide_timer_id ~= 0 then
        LuaTimer.Delete(self.run_divide_timer_id)
        self.run_divide_timer_id = 0
    end
end

--跑条前进tick
function QualifyFinishWindow:run_divide_tick()
    self.count = self.count - 1
    local percent = self.count / self.now_fenmu
    local width = percent*self.progBarMax
    self.ImgProgBar_rect.sizeDelta = Vector2(width, self.ImgProgBar_rect.rect.height)

    self.run_total_count = self.run_total_count - 1
    self.point_count = math.floor(-(self.run_total_count/self.divide_total_count)*self.now_win_point)
    -- self.TxtWinPoint.text = string.format("%s", self.point_count)

    if self.count <= self.count_end then --前进到尽头
        if self.now_count_end ~= -1 then
            self.count = self.now_fenmu
            self.count_end = self.now_fenzi
            self.cur_fenmu = self.now_fenmu
            self:star_run_divide()
            self.now_count_end = -1
        else
            self:stop_run_divide()
            self.point_count = 0
            -- self:check_show_open_lock()
        end
    end
end


function QualifyFinishWindow:check_show_open_lock()
    if self.model.do_open_lock_win then
        self.model:HideQualifyFinishUI()

        LuaTimer.Add(500, function ()
            self.model:OpenQualifyOpenLockUI()
            self.model.do_open_lock_win = false
        end)
    end
end




