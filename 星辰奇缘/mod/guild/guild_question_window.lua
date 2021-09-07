GuildQuestionWindow = GuildQuestionWindow or BaseClass(BaseWindow)

function GuildQuestionWindow:__init(model)
    self.name  =  "GuildQuestionWindow"
    self.model  =  model

    self.resList  =  {
        {file = AssetConfig.guild_question_win, type = AssetType.Main}
        , {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
    }

    self.timer_id = 0

    self.end_time = 0
    self.end_time_invoke = 0
    self.show_question_gap = 3 --让玩家看题的时间展示5秒
    self.time_frame = 20
    self.show_question_left_time = 3
    self.show_right_left_time = 5

    self.current_tab_index = -1

    self.show_question_count = 0
    self.run_wait_choice_ttime = 90 --毫秒
    self.percent = 0

    self.event_item_list = nil
    self.rank_item_list = nil
    self.rank_count = 0
    self.answer_back = false
    self.has_answer_this_question = false

    self.show_timer_id = 0
    self.answer_timer_id = 0
    self.rank_timer_id = 0

    return self
end

function GuildQuestionWindow:__delete()

    self.is_open = false
    self.current_tab_index = -1
    self.R_MidCon = nil
    self.TxtNum = nil
    self.TxtProgTime = nil
    self.last_best_name = nil
    self:stop_rank_timer()
    self:stop_show_timer()
    self:stop_answer_timer()

    self.event_item_list = nil
    self.rank_item_list = nil

    self.rank_count = 0

    self.is_open  =  false

    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildQuestionWindow:InitPanel()
    self.is_open = true

    self.MainCon = transform:FindChild("MainCon").gameObject

    local close_btn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseQuestionUI() end)

    self.MainCon = transform:FindChild("MainCon").gameObject
    self.LeftCon = self.MainCon.transform:FindChild("LeftCon").gameObject
    self.BottomCon = self.LeftCon.transform:FindChild("BottomCon").gameObject

    self.EventCon = self.BottomCon.transform:FindChild("EventCon").gameObject
    self.TopCon = self.EventCon.transform:FindChild("TopCon").gameObject
    self.effect_20086 = self.TopCon.transform:FindChild("20086").gameObject
    -- self.effect_20086:SetActive(false)
    -- self.effect_20086.transform:ChangeLayersRecursively("UI")

    self.TxtDesc = self.TopCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtName = self.TopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.E_BottomCon = self.EventCon.transform:FindChild("BottomCon").gameObject
    self.E_MaskCon = self.E_BottomCon.transform:FindChild("MaskCon").gameObject
    self.E_ScorllLayer = self.E_MaskCon.transform:FindChild("ScorllLayer").gameObject
    self.E_LayoutLayer = self.E_ScorllLayer.transform:FindChild("LayoutLayer").gameObject
    self.E_Item = self.E_LayoutLayer.transform:FindChild("Item").gameObject
    self.E_Item:SetActive(false)

    self.RankCon = self.BottomCon.transform:FindChild("RankCon").gameObject
    self.R_MaskCon = self.RankCon.transform:FindChild("MaskCon").gameObject
    self.R_ScrollLayer = self.R_MaskCon.transform:FindChild("ScrollLayer").gameObject
    self.R_LayoutLayer = self.R_ScrollLayer.transform:FindChild("LayoutLayer").gameObject
    self.R_Item = self.R_LayoutLayer.transform:FindChild("Item").gameObject
    self.R_Item:SetActive(false)

    self.RightCon = self.MainCon.transform:FindChild("RightCon").gameObject
    self.R_TopCon = self.RightCon.transform:FindChild("TopCon").gameObject
    self.effect_wrong = self.R_TopCon.transform:FindChild("20088_wrong").gameObject
    self.effect_right = self.R_TopCon.transform:FindChild("20087_right").gameObject
    self.effect_wrong.transform:ChangeLayersRecursively("UI")
    self.effect_right.transform:ChangeLayersRecursively("UI")

    self.TxtHasTime = self.R_TopCon.transform:FindChild("TxtHasTime"):GetComponent(Text)
    self.TxtQuestion = self.R_TopCon.transform:FindChild("TxtQuestion"):GetComponent(Text)


    self.R_MidCon = self.RightCon.transform:FindChild("MidCon").gameObject
    self.R_MidCon:SetActive(false)
    self.ImgProg = self.R_MidCon.transform:FindChild("ImgProg").gameObject
    self.ImgBar = self.ImgProg.transform:FindChild("ImgBar"):GetComponent(Image)
    self.ImgBar_rect  = self.ImgBar.gameObject.transform:GetComponent(RectTransform)

    self.TxtNum = self.ImgProg.transform:FindChild("TxtNum"):GetComponent(Text)
    self.TxtProgTime = self.R_MidCon.transform:FindChild("TxtProgTime"):GetComponent(Text)
    self.TxtProgTime.text = TI18N("后下一题")

    self.R_BottomCon = self.RightCon.transform:FindChild("BottomCon").gameObject
    self.finish_con = self.RightCon.transform:FindChild("ConUnOpen").gameObject
    self.finish_con:SetActive(false)
    self.Btn_A = self.R_BottomCon.transform:FindChild("Btn_A").gameObject
    self.Btn_B = self.R_BottomCon.transform:FindChild("Btn_B").gameObject
    self.Btn_C = self.R_BottomCon.transform:FindChild("Btn_C").gameObject
    self.Btn_D = self.R_BottomCon.transform:FindChild("Btn_D").gameObject

    self.Btn_A_btn = self.Btn_A:GetComponent(Button)
    self.Btn_B_btn = self.Btn_B:GetComponent(Button)
    self.Btn_C_btn = self.Btn_C:GetComponent(Button)
    self.Btn_D_btn = self.Btn_D:GetComponent(Button)

    self.Btn_A:SetActive(false)
    self.Btn_B:SetActive(false)
    self.Btn_C:SetActive(false)
    self.Btn_D:SetActive(false)

    self.option_normal_sprite = self.Btn_B_btn.image.sprite
    self.option_unable_sprite = self.Btn_A_btn.image.sprite


    self.Btn_txt_A = self.Btn_A.transform:FindChild("Text"):GetComponent(Text)
    self.Btn_txt_B = self.Btn_B.transform:FindChild("Text"):GetComponent(Text)
    self.Btn_txt_C = self.Btn_C.transform:FindChild("Text"):GetComponent(Text)
    self.Btn_txt_D = self.Btn_D.transform:FindChild("Text"):GetComponent(Text)

    self.ImgRight_A = self.Btn_A.transform:FindChild("ImgRight").gameObject
    self.ImgRight_B = self.Btn_B.transform:FindChild("ImgRight").gameObject
    self.ImgRight_C = self.Btn_C.transform:FindChild("ImgRight").gameObject
    self.ImgRight_D = self.Btn_D.transform:FindChild("ImgRight").gameObject

    local tabGroup = self.LeftCon.transform:FindChild("TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:on_switch_tab(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:on_switch_tab(2) end)

    self:update_view()
end

--------------------------------面板更新逻辑
function GuildQuestionWindow:update_view()
    if self.is_open == true then
        GuildManager.Instance:request11147()
    end
end

--更新面板右边逻辑
function GuildQuestionWindow:update_right_view()
    self.show_right_left_time = 5
    self.show_question_left_time = 3
    self.end_time = 0
    self.end_time_invoke = 0

    self.show_question_count = 0
    self.percent = 0

    self.answer_back = false
    self:stop_show_timer()
    self:stop_answer_timer()

    local cfg_data = DataQuestion.data_guild_question_cfg[self.model.current_guild_question_data.id]

    self.TxtHasTime.text = string.format("%s：<color='#4dd52b'>%s/%s</color>", TI18N("已答对"), self.model.current_guild_question_data.today_right, self.model.current_guild_question_data.today_max)
    self.TxtQuestion.text = string.format("<color='#4dd52b'>%s%s/%s%s：</color>%s", TI18N("第"), self.model.current_guild_question_data.asked_num, self.model.current_guild_question_data.today_max, TI18N("题"), cfg_data.question)

    local temp_end_time = self.model.current_guild_question_data.asked + self.show_question_gap + self.time_frame - ctx.TimerManager.BASE_TIME


    if temp_end_time > 0 then
        if temp_end_time > self.time_frame then
            --还没有过看题的时间
            self.show_question_left_time = temp_end_time - self.time_frame
            --走让玩家看题的倒计时
            self.end_time = self.time_frame - 1
            self.end_time_invoke = self.end_time
            self:set_answer_btn_state(false)
            self:star_show_timer()
        else
            --问题已经过了看题时间
            self.end_time = temp_end_time - 1
            self.end_time_invoke = self.end_time
            self:star_answer()
        end

    else
        --问题已经结束
        self:set_answer_btn_state(false)
        self.ImgBar_rect.sizeDelta = Vector2(0, self.ImgBar_rect.rect.height)
        self.TxtNum.text = string.format("0/%s", self.time_frame)
    end


    --判断下玩家是否已经答过这道题，避免重登
    local my_answer = 0
    local has_answer = false
    for i=1, #self.model.current_guild_question_data.answers do
        local an = self.model.current_guild_question_data.answers[i]
        if an.rid == mod_role.role_info.id and an.platform == mod_role.role_info.platform and an.zone_id ==  mod_role.role_info.zone_id then
            has_answer = true
            my_answer = an.option
        end
    end

    if has_answer == true then
        local btn = nil
        if my_answer == 1 then
            btn = self.Btn_A
        elseif my_answer == 2 then
            btn = self.Btn_B
        elseif my_answer == 3 then
            btn = self.Btn_C
        elseif my_answer == 4 then
            btn = self.Btn_D
        end
        self:set_click_answerbtn(btn)
        self.has_answer_this_question = true
    else
        self.Btn_A:SetActive(false)
        self.Btn_B:SetActive(false)
        self.Btn_C:SetActive(false)
        self.Btn_D:SetActive(false)
    end
    self.Btn_txt_A.text = string.format("A.%s", cfg_data.option_a)
    self.Btn_txt_B.text = string.format("B.%s", cfg_data.option_b)
    self.Btn_txt_C.text = string.format("C.%s", cfg_data.option_c)
    self.Btn_txt_D.text = string.format("D.%s", cfg_data.option_d)

    if cfg_data.option_a ~= "" then
        self.Btn_A:SetActive(true)
    end
    if cfg_data.option_b ~= "" then
        self.Btn_B:SetActive(true)
    end
    if cfg_data.option_c ~= "" then
        self.Btn_C:SetActive(true)
    end
    if cfg_data.option_d ~= "" then
        self.Btn_D:SetActive(true)
    end
end

-----------------------------点击监听器逻辑
--答题按钮选择监听
function GuildQuestionWindow:on_click_answerbtn(g)
    local index = self:set_click_answerbtn(g)
    GuildManager.Instance:request11148(index)
    self.has_answer_this_question = true
end

--左边切换选项卡逻辑
function GuildQuestionWindow:on_switch_tab(index)
    self.current_tab_index = index - 1
    self.EventCon:SetActive(false)
    self.RankCon:SetActive(false)
    if index == 1 then
        --答题事件
        GuildManager.Instance:request11154()
        self:update_event_list()
    elseif index == 2 then
        --答题排名
        GuildManager.Instance:request1114()
        self:star_rank_timer()
    end
end

--------------------------------------计时器逻辑
--题目展示计时
function GuildQuestionWindow:stop_show_timer()
    if self.show_timer_id ~= 0 then
        LuaTimer.Delete(self.show_timer_id)
        self.show_timer_id = 0
    end
end

function GuildQuestionWindow:star_show_timer()
    self:stop_show_timer()
    LuaTimer.Add(0, 1000, function(id) self:tick_show_timer(id) end)
end

function GuildQuestionWindow:tick_show_timer(id)
    -- if self.is_open == false then
    --     return
    -- end
    self.show_timer_id = id
    self.show_question_count = self.show_question_count + 1

    if self.show_question_count >= self.show_question_left_time then
        self:stop_show_timer()
        self.show_question_count = 0
        self:star_answer_timer()
        return
    end
end

--题目等待玩家回答问题倒计时
function GuildQuestionWindow:star_answer_timer()
    self:set_answer_btn_state(true)
    self:stop_answer_timer()
    self.R_MidCon:SetActive(true)

    self.answer_timer_id = 0
    LuaTimer.Add(0, self.run_wait_choice_ttime, function(id) self:tick_answer_timer(id) end)
end

function GuildQuestionWindow:stop_answer_timer()
    if self.R_MidCon ~= nil then
        self.R_MidCon:SetActive(false)
    end
    if self.TxtNum ~= nil then
        self.TxtNum.text = ""
    end

    if self.answer_timer_id ~= 0 then
        LuaTimer.Delete(self.answer_timer_id)
        self.answer_timer_id = 0
    end
end

--等待玩家做选择倒计时
function GuildQuestionWindow:tick_answer_timer(id)
    if self.is_open == false then
        return
    end
    self.answer_timer_id = id

    --进度条
    self.end_time_invoke = self.end_time_invoke - self.run_wait_choice_ttime
    self.end_time_invoke = self.end_time_invoke > 0 and self.end_time_invoke or 0
    self.percent = self.end_time_invoke/self.time_frame
    if self.percent < 0 then
        self.percent = 0
    end
    self.ImgBar_rect.sizeDelta = Vector2(math.floor(self.percent*319), self.ImgBar_rect.rect.height)

    --结束时间
    local txt_time = math.floor(self.end_time_invoke)
    txt_time = txt_time > 0 and txt_time or 0
    self.TxtNum.text = string.format("%s/%s", txt_time,self.time_frame)

    if self.end_time_invoke <= 0 then
        --完成，停止计时
        self.end_time = 0
        self:set_answer_btn_state(false)
        self:stop_answer_timer()
        self:update_question_state()

        self:stop_answer_timer()
    end
end


--如果在排行tab里面，20秒请求一次排行榜数据
function GuildQuestionWindow:stop_rank_timer()
    if self.rank_timer_id ~= 0 then
        LuaTimer.Delete(self.rank_timer_id)
        self.rank_timer_id = 0
    end
end

function GuildQuestionWindow:star_rank_timer()
    self:stop_rank_timer()
    LuaTimer.Add(0, 1000, function(id) self:tick_rank_timer(id) end)
end

function GuildQuestionWindow:tick_rank_timer(id)
    self.rank_timer_id = id
    if self.is_open == false then
        return
    end
    if self.current_tab_index ~= 1 then
        return
    end

    self.rank_count = self.rank_count + 1
    if self.rank_count >= 20 then
        self.rank_count = 0
        GuildManager.Instance:request11149()
        self:stop_rank_timer()
    end
end



--------------------------------------------协议更新逻辑

--11148协议返回
function GuildQuestionWindow:on_socket_11148_back(result)
    if self.is_open == false then
        return
    end

    self.effect_wrong:SetActive(false)
    self.effect_right:SetActive(false)
    if result ~= 2 then --失败
        -- sound_player:PlayOption(config.sounds.Guild_Answer_wrong)
        self.effect_wrong:SetActive(true)
    else --成功
        -- sound_player:PlayOption(config.sounds.Guild_Answer_right)
        self.effect_right:SetActive(true)
    end
end

--11147协议返回，问题信息返回
function GuildQuestionWindow:on_socket_11147_back()
    self.has_answer_this_question = false
    if self.is_open == true then
        if self.current_tab_index ~= 1 then
            self.TabButtonGroup:SetCurrentIndex(0)
        else

        end
        self:update_right_view()
    end
end

--有新的回答者回答了问题，用于11151协议更新
function GuildQuestionWindow:on_socket_11151_back(data)
    if self.is_open == false then
        return
    end
    if self.current_tab_index ~= 0 then
        return
    end

    local item = GuildQuestionEventItem.New(self, self.E_Item, data, #self.event_item_list+1)
    table.insert(self.event_item_list, item)
end


--更新最牛逼的答题公会
function GuildQuestionWindow:on_socket_11154_back(name)
    if self.is_open == false then
        return
    end

    if name == "" then
        self.TxtName.text = TI18N("暂无")
        return
    end

    self.TxtName.text = name
    self.effect_20086:SetActive(true)
end

--用于11150协议回来的监听
function GuildQuestionWindow:on_socket_11150_back(answer)
    if self.is_open == false then
        return
    end

    if answer == 0 then
        return
    end

    self:stop_answer_timer()
    self:stop_show_timer()

    self:set_answer_btn_state(false)

    local btnImage = nil
    local image_tick = nil


    if answer == 1 then
        btnImage = self.Btn_A_btn.image
        image_tick = self.ImgRight_A
    elseif answer == 2 then
        btnImage = self.Btn_B_btn.image
        image_tick = self.ImgRight_B
    elseif answer == 3 then
        btnImage = self.Btn_C_btn.image
        image_tick = self.ImgRight_C
    elseif answer == 4 then
        btnImage = self.Btn_D_btn.image
        image_tick = self.ImgRight_D
    end

    btnImage.sprite = self.option_normal_sprite
    image_tick:SetActive(true)
    self.answer_back = true
end


---------------------------------------各种列表更新和状态更新
--更新答题事件列表， 协议回来之后调用
function GuildQuestionWindow:update_event_list()

    if self.is_open == false then
        return
    end

    if self.current_tab_index ~= 0 then
        return
    end

    self.effect_20086:SetActive(false)

    if self.event_item_list ~= nil then
        for i=1, #self.event_item_list do
            local item = self.event_item_list[i]
             if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end
    self.event_item_list = {}

    self.EventCon:SetActive(true)

    local data_list = self.model.current_guild_question_data.answers --从mod里面取
    for i=1,#data_list do
        local data = data_list[i]
        local item = self.event_item_list[i]
        if item == nil then
            GuildQuestionEventItem.New(self, self.E_Item, data, i)
            table.insert(self.event_item_list, item)
        else
            item:set_event_item_data(data)
            item.gameObject:SetActive(true)
        end
    end

    if self.model.current_guild_question_data.cheat_off == 1 then
        self:on_socket_11152_back()
    end
end

--更新答题排名列表，协议回来之后调用
function GuildQuestionWindow:update_rank_list(data_list)
    if self.is_open == false then
        return
    end
    if self.current_tab_index ~= 1 then --没选中排行榜tab
        return
    end

    if self.rank_item_list ~= nil then
        for i=1, #self.rank_item_list do
            local item = self.rank_item_list[i]
             if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end

    self.rank_item_list = {}
    self.RankCon:SetActive(true)

    for i=1,#data_list do
        local data = data_list[i]
        local item = self.rank_item_list[i]
        if item == nil then
            GuildQuestionRankItem.New(self, self.R_Item, data, i)
            table.insert(self.rank_item_list, item)
        else
            item:set_rank_item_data(data)
            item.gameObject:SetActive(true)
        end
    end
end

--更新答题活动是否还在进行中的状态
function GuildQuestionWindow:update_question_state()
    if  self.model.current_guild_question_data.asked_num == self.model.current_guild_question_data.today_max then
        --答题活动结束
        self.finish_con:SetActive(true)
        self.R_BottomCon:SetActive(false)
        self.TxtQuestion.gameObject:SetActive(false)
        ui_guild_question_notify.close_my_self()
    end
end



---------utils逻辑
function GuildQuestionWindow:set_click_answerbtn(g)
    self:set_answer_btn_state(false)
    if g == self.Btn_A then
        self.ImgRight_A:SetActive(true)
        self.Btn_A_btn.image.sprite = self.option_normal_sprite
        return 1
    elseif g == self.Btn_B then
        self.ImgRight_B:SetActive(true)
        self.Btn_B_btn.image.sprite = self.option_normal_sprite
        return 2
    elseif g == self.Btn_C then
        self.ImgRight_C:SetActive(true)
        self.Btn_C_btn.image.sprite = self.option_normal_sprite
        return 3
    elseif g == self.Btn_D then
        self.ImgRight_D:SetActive(true)
        self.Btn_D_btn.image.sprite = self.option_normal_sprite
        return 4
    end
end

function GuildQuestionWindow:set_answer_btn_state(state)
    if self.answer_back == true then
        return
    end
    self.Btn_A_btn.enabled = state
    self.Btn_B_btn.enabled = state
    self.Btn_C_btn.enabled = state
    self.Btn_D_btn.enabled = state

    utils.remove_down_up_scale(self.Btn_A)
    utils.remove_down_up_scale(self.Btn_B)
    utils.remove_down_up_scale(self.Btn_C)
    utils.remove_down_up_scale(self.Btn_D)

    self.ImgRight_A:SetActive(false)
    self.ImgRight_B:SetActive(false)
    self.ImgRight_C:SetActive(false)
    self.ImgRight_D:SetActive(false)

    if state == true then
        self.Btn_A_btn.image.sprite = self.option_normal_sprite
        self.Btn_B_btn.image.sprite = self.option_normal_sprite
        self.Btn_C_btn.image.sprite = self.option_normal_sprite
        self.Btn_D_btn.image.sprite = self.option_normal_sprite
        utils.add_down_up_scale(self.Btn_A, "self:on_click_answerbtn")
        utils.add_down_up_scale(self.Btn_B, "self:on_click_answerbtn")
        utils.add_down_up_scale(self.Btn_C, "self:on_click_answerbtn")
        utils.add_down_up_scale(self.Btn_D, "self:on_click_answerbtn")


    else
        self.Btn_A_btn.image.sprite = self.option_unable_sprite
        self.Btn_B_btn.image.sprite = self.option_unable_sprite
        self.Btn_C_btn.image.sprite = self.option_unable_sprite
        self.Btn_D_btn.image.sprite = self.option_unable_sprite
    end
end

--参看答案协议11152返回
function GuildQuestionWindow:on_socket_11152_back()
    if self.is_open == false then
        return
    end
    if self.event_item_list == nil then
        return
    end
    if #self.event_item_list == 0 then
        return
    end

    for i=1,#self.event_item_list do
        local item = self.event_item_list[i]
        if item.data.result == 1 then
            item.ImgLook:SetActive(false)
            item.TxtAnswer.gameObject:SetActive(true)
            if item.data.option == 1 then
                item.TxtAnswer.text ="A"
            elseif item.data.option == 2 then
                item.TxtAnswer.text ="B"
            elseif item.data.option == 3 then
                item.TxtAnswer.text ="C"
            elseif item.data.option == 4 then
                item.TxtAnswer.text ="D"
            end
        end
    end
end