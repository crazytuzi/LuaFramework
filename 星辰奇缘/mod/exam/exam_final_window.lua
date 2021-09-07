-- zzl
-- 2016/7/6
ExamFinalWindow  =  ExamFinalWindow or BaseClass(BaseWindow)

function ExamFinalWindow:__init(model)
    self.name  =  "ExamFinalWindow"
    self.model  =  model

    -- 缓存
    self.cacheMode = CacheMode.Visible
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.exam_final_win, type  =  AssetType.Main}
        , {file = AssetConfig.exam_res, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20118), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20155), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20156), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20157), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    -- self.windowId = WindowConfig.WinID.exam_main_win

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isHideMainUI = false

    self.is_double_effect = false

    self.has_erease_btns = {}

    self.option_btn_erease_effects = {}

    self.prog_timer_id = 0
    self.prog_tick_time = 0

    self.prog_timer_id2 = 0
    self.prog_tick_time2 = 0

    self.prepare_timer_id = 0
    self.prepare_left_time = 0

    self.last_qid = 0

    self.out_time = false
    self.do_out_time_tips = true

    self.has_init = false
    self.result_time_str = ""
    self.result_reward_str = ""

    self.question_gap = 3

    return self
end

function ExamFinalWindow:OnHide()

end

function ExamFinalWindow:OnShow()
    self:do_show_view()
    ExamManager.Instance:request14516()
    -- self:update_info(self.model.cur_final_question_data)
end

function ExamFinalWindow:__delete()
    self.has_init = false
    self:stop_prepare_timer()
    self:stop_prog_timer()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ExamFinalWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exam_final_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ExamFinalWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero

    self.mainCon = self.gameObject.transform:Find("MainCon")
    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseFinalExamUI()
    end)


    self.LeftCon = self.mainCon.transform:Find("LeftCon")

    --左边排行榜
    self.MaskCon = self.LeftCon.transform:Find("MaskCon")
    self.ScrollCon = self.MaskCon.transform:Find("ScrollCon")
    self.Container = self.ScrollCon.transform:Find("Container")
    self.left_item_list = {}
    for i=1,11 do
        local go = self.Container.transform:Find(string.format("Item%s", i)).gameObject
        local item = ExamFinalRankItem.New(go, self)
        go:SetActive(false)
        table.insert(self.left_item_list, item)
    end
    self.single_item_height = self.left_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting_data = {
       item_list = self.left_item_list--放了 item类对象的列表
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
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)

    --左边底部，我的积分和我的排名
    self.BottomCon = self.LeftCon.transform:Find("BottomCon")
    self.ImgBox_Btn = self.BottomCon:GetComponent(Button)
    self.TxtMyScore = self.BottomCon.transform:Find("TxtMyScore"):GetComponent(Text)
    self.TxtMyRank = self.BottomCon.transform:Find("TxtMyRank"):GetComponent(Text)
   
    if self.imgLoader == nil then
         self.ImgBoxGo = self.BottomCon.transform:Find("ImgBox").gameObject
         self.imgLoader = SingleIconLoader.New(self.ImgBoxGo)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 22504)

    self.MidCon = self.mainCon.transform:Find("MidCon")
    --未开启逻辑
    self.UnOpenTopCon = self.MidCon.transform:Find("UnOpenTopCon")

    self.UnOpenTopCon.transform:Find("TxtDesc"):GetComponent(Text).color = ColorHelper.DefaultButton8
    self.UnOpenTopCon.transform:Find("TxtTimeDesc"):GetComponent(Text).color = ColorHelper.DefaultButton8

    self.UnOpenTopTxtTime = self.UnOpenTopCon.transform:Find("TxtTime"):GetComponent(Text)

    --开启逻辑
    self.TopCon = self.MidCon.transform:Find("TopCon")

    --答对播特效
    self.answer_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20157)))
    self.answer_right_effect.transform:SetParent(self.TopCon)
    self.answer_right_effect.transform.localRotation = Quaternion.identity
    self.answer_right_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.answer_right_effect.transform, "UI")
    self.answer_right_effect.transform.localScale = Vector3(1, 1, 1)
    self.answer_right_effect.transform.localPosition = Vector3(-110, 0, -100)

    --双倍特效
    self.double_new_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20156)))
    self.double_new_effect.transform:SetParent(self.TopCon)
    self.double_new_effect.transform.localRotation = Quaternion.identity
    self.double_new_effect:SetActive(false)
    Utils.ChangeLayersRecursively(self.double_new_effect.transform, "UI")
    self.double_new_effect.transform.localScale = Vector3(1, 1, 1)
    self.double_new_effect.transform.localPosition = Vector3(0, 0, -100)

    --题目内容
    self.TxtQuestion = self.TopCon.transform:Find("TxtQuestion"):GetComponent(Text)

    --进度条
    self.ImgProgCon = self.TopCon.transform:Find("MidCon")
    self.ImgProg = self.ImgProgCon.transform:Find("ImgProg")
    self.ImgBarRect = self.ImgProg.transform:Find("ImgBar"):GetComponent(RectTransform)
    self.TxtNum = self.ImgProg.transform:Find("TxtNum"):GetComponent(Text)
    self.TxtProgTime = self.ImgProgCon.transform:Find("TxtProgTime"):GetComponent(Text)

    --选项的四个按钮
    self.AnswerBtnCon = self.TopCon.transform:Find("BottomCon")
    self.Btn_A = self.AnswerBtnCon.transform:Find("Btn_A"):GetComponent(Button)
    self.Btn_B = self.AnswerBtnCon.transform:Find("Btn_B"):GetComponent(Button)
    self.Btn_C = self.AnswerBtnCon.transform:Find("Btn_C"):GetComponent(Button)
    self.Btn_D = self.AnswerBtnCon.transform:Find("Btn_D"):GetComponent(Button)

    self.btn_list = {}
    table.insert(self.btn_list, self.Btn_A)
    table.insert(self.btn_list, self.Btn_B)
    table.insert(self.btn_list, self.Btn_C)
    table.insert(self.btn_list, self.Btn_D)

    self.Btn_A_Mask_Rect = self.Btn_A.transform:Find("MaskCon"):GetComponent(RectTransform)
    self.Btn_B_Mask_Rect = self.Btn_B.transform:Find("MaskCon"):GetComponent(RectTransform)
    self.Btn_C_Mask_Rect = self.Btn_C.transform:Find("MaskCon"):GetComponent(RectTransform)
    self.Btn_D_Mask_Rect = self.Btn_D.transform:Find("MaskCon"):GetComponent(RectTransform)

    self.Btn_A_Option_Txt = self.Btn_A.transform:Find("MaskCon"):Find("TxtOption"):GetComponent(Text)
    self.Btn_B_Option_Txt = self.Btn_B.transform:Find("MaskCon"):Find("TxtOption"):GetComponent(Text)
    self.Btn_C_Option_Txt = self.Btn_C.transform:Find("MaskCon"):Find("TxtOption"):GetComponent(Text)
    self.Btn_D_Option_Txt = self.Btn_D.transform:Find("MaskCon"):Find("TxtOption"):GetComponent(Text)

    --选项按钮橡皮擦特效
    for i=1,4 do
        local erease_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20155)))
        erease_effect.transform:SetParent(self.btn_list[i].transform)
        erease_effect.transform.localRotation = Quaternion.identity
        erease_effect:SetActive(false)
        Utils.ChangeLayersRecursively(erease_effect.transform, "UI")
        table.insert(self.option_btn_erease_effects, erease_effect)

        erease_effect.transform.localScale = Vector3(1, 1, 1)
        erease_effect.transform.localPosition = Vector3(-72, 5, -100)
    end


    self.erease_effect_2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20155)))
    self.erease_effect_2.transform:SetParent(self.Btn_B.transform)
    self.erease_effect_2.transform.localRotation = Quaternion.identity
    self.erease_effect_2:SetActive(true)
    Utils.ChangeLayersRecursively(self.erease_effect_2.transform, "UI")



    --中间底部作弊的三个按钮
    self.CheatCon = self.MidCon.transform:Find("BottomCon")
    self.Btn_1 = self.CheatCon.transform:Find("Btn_1"):GetComponent(Button)
    self.Btn_2 = self.CheatCon.transform:Find("Btn_2"):GetComponent(Button)
    self.Btn_3 = self.CheatCon.transform:Find("Btn_3"):GetComponent(Button)


    --双倍积分转圈圈特效
    self.double_btn_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20118)))
    self.double_btn_effect.transform:SetParent(self.Btn_1.transform)
    self.double_btn_effect.transform.localRotation = Quaternion.identity
    self:set_double_effect(false)
    Utils.ChangeLayersRecursively(self.double_btn_effect.transform, "UI")
    self.double_btn_effect.transform.localScale = Vector3(0.75, 1.5, 1)
    self.double_btn_effect.transform.localPosition = Vector3(-38, 50, -100)


    self.Btn_1_RedPoint = self.CheatCon.transform:Find("Btn_1"):Find("ImgRedPoint").gameObject
    self.Btn_2_RedPoint = self.CheatCon.transform:Find("Btn_2"):Find("ImgRedPoint").gameObject
    self.Btn_3_RedPoint = self.CheatCon.transform:Find("Btn_3"):Find("ImgRedPoint").gameObject

    self.Btn_1_RedPoint_Txt = self.CheatCon.transform:Find("Btn_1"):Find("Text"):GetComponent(Text)
    self.Btn_2_RedPoint_Txt = self.CheatCon.transform:Find("Btn_2"):Find("Text"):GetComponent(Text)
    self.Btn_3_RedPoint_Txt = self.CheatCon.transform:Find("Btn_3"):Find("Text"):GetComponent(Text)



    self.Btn_1_RedPoint_Txt.text = ""
    self.Btn_2_RedPoint_Txt.text = ""
    self.Btn_3_RedPoint_Txt.text = ""


    --右边选手答题情况列表
    self.RightCon = self.mainCon.transform:Find("RightCon")
    self.RightMaskCon = self.RightCon.transform:Find("MaskCon")
    self.RightScrollCon = self.RightMaskCon.transform:Find("ScrollCon")
    self.RightContainer = self.RightScrollCon.transform:Find("Container")

    self.right_item_list = {}
    for i=1,13 do
        local go = self.RightContainer.transform:Find(string.format("Item%s", i)).gameObject
        local item = ExamFinalAnswerItem.New(go, self)
        go:SetActive(false)
        table.insert(self.right_item_list, item)
    end

    --注册监听器
    self.Btn_A.onClick:AddListener(function()
        if self.has_erease_btns[self.Btn_A] ~= nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该选项已经被排除，无法选择"))
            return
        end
        if self.out_time then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
            return
        end
        self.Btn_1.enabled = false
        ExamManager.Instance:request14511(self.model.cur_final_question_data.qid, 1)
    end)
    self.Btn_B.onClick:AddListener(function()
        if self.has_erease_btns[self.Btn_B] ~= nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该选项已经被排除，无法选择"))
            return
        end
        if self.out_time then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
            return
        end
        self.Btn_1.enabled = false
        ExamManager.Instance:request14511(self.model.cur_final_question_data.qid, 2)
    end)
    self.Btn_C.onClick:AddListener(function()
        if self.has_erease_btns[self.Btn_C] ~= nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该选项已经被排除，无法选择"))
            return
        end
        if self.out_time then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
            return
        end
        self.Btn_1.enabled = false
        ExamManager.Instance:request14511(self.model.cur_final_question_data.qid, 3)
    end)
    self.Btn_D.onClick:AddListener(function()
        if self.has_erease_btns[self.Btn_D] ~= nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("该选项已经被排除，无法选择"))
            return
        end
        if self.out_time then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
            return
        end
        self.Btn_1.enabled = false
        ExamManager.Instance:request14511(self.model.cur_final_question_data.qid, 4)
    end)

    self.Btn_1.onClick:AddListener(function()
        --双倍积分
        if self.model.cur_final_question_data == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请耐心等待"))
            return
        end
        self.double_new_effect:SetActive(false)
        self.double_new_effect:SetActive(true)
        LuaTimer.Add(1500, function() self.double_new_effect:SetActive(false) end)

        ExamManager.Instance:request14517(self.model.cur_final_question_data.qid)
    end)
    self.Btn_2.onClick:AddListener(function()
        --降低难度
        if self.model.cur_final_question_data == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请耐心等待"))
            return
        end
        ExamManager.Instance:request14515(self.model.cur_final_question_data.qid)
    end)
    self.Btn_3.onClick:AddListener(function()
        --偷看答案
        if self.model.cur_final_question_data == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请耐心等待"))
            return
        end
        ExamManager.Instance:request14513(self.model.cur_final_question_data.qid)
    end)


    self.ImgBox_Btn.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1.<color='#ffff00'>[双倍积分]</color>:使用后回答正确，可获得<color='#ffff00'>双倍</color>得分"))
        table.insert(tips, TI18N("2.<color='#ffff00'>[降低难度]</color>：使用后可以<color='#ffff00'>擦掉</color>当前题目中一个错误答案"))
        table.insert(tips, TI18N("3.<color='#ffff00'>[偷看答案]</color>：当有选手回答正确时，可以<color='#ffff00'>偷看</color>他的答案"))
        table.insert(tips, TI18N("4.对决共<color='#ffff00'>25</color>题，每题得分根据<color='#ffff00'>消耗</color>时间获得"))
        table.insert(tips, TI18N("5.最后将按照获得的分数<color='#ffff00'>排名</color>给予奖励"))
        TipsManager.Instance:ShowText({gameObject = self.ImgBox_Btn.gameObject, itemData = tips})
    end)


    --请求当前题目
    self:do_show_view()

    --请求排行榜
    ExamManager.Instance:request14512()

    --请求个人信息
    ExamManager.Instance:request14516()
end

--执行界面更新
function ExamFinalWindow:do_show_view()
    self.TopCon.gameObject:SetActive(false)
    self.UnOpenTopCon.gameObject:SetActive(false)

    if self.model.cur_exam_status == 2 then
        self:stop_prepare_timer()
        self.TopCon.gameObject:SetActive(true)
        ExamManager.Instance:request14510()
    else
        --还没开始，还在通知阶段
        if self.prepare_left_time == 0 then
            self.prepare_left_time = self.model.cur_final_prepare_left_time - Time.time
        end

        self:start_prepare_timer()
        self.UnOpenTopCon.gameObject:SetActive(true)
    end
end

--更新总入口
function ExamFinalWindow:update_info()
    -- self:update_question_info()
    -- self:update_rank_list()
    -- self:update_answer_list()
end

--设置双倍特效状态
function ExamFinalWindow:set_double_effect(state)
    self.is_double_effect = state
    self.double_btn_effect:SetActive(false)
end

--播放双倍特效
function ExamFinalWindow:update_final_double_effect()
    --贱人策划说不要了，还是先注释免得被坑了
    self:set_double_effect(true)
end

--更新答题结果
function ExamFinalWindow:update_answer_result(data)

    self.do_out_time_tips = false

    for i=1,#self.btn_list do
        self:set_btn_answer_state(self.btn_list[i], 0)
    end

    if data.choice == data.right_answer then
        --答对了
        if data.right_answer ~= 0 then
            self:set_btn_answer_state(self.btn_list[data.choice], 1)
        end

        if self.is_double_effect then
            --飘下双倍效果
            self.double_new_effect:SetActive(false)
            self.double_new_effect:SetActive(true)
            LuaTimer.Add(1500, function() self.double_new_effect:SetActive(false) end)
        end
        self:set_double_effect(false)

        self.answer_right_effect:SetActive(false)
        self.answer_right_effect:SetActive(true)
        LuaTimer.Add(1500, function() self.answer_right_effect:SetActive(false) end)
    else

    self:set_double_effect(false)
        --错的
        if data.choice ~= 0 then
            self:set_btn_answer_state(self.btn_list[data.choice], 2)
        end
        -- if data.right_answer ~= 0 then
        --     self:set_btn_answer_state(self.btn_list[data.right_answer], 1)
        -- end
    end
    for i=1,#self.btn_list do
        self.btn_list[i].enabled = false
    end
end

--更新底部个人信息
function ExamFinalWindow:update_final_person_data()
    -- self.model.cur_final_person_data
    self.TxtMyScore.text = tostring(self.model.cur_final_person_data.score)


    self.Btn_1_RedPoint:SetActive(false)
    self.Btn_2_RedPoint:SetActive(false)
    self.Btn_3_RedPoint:SetActive(false)


    if self.model.cur_final_person_data.max_peeking - self.model.cur_final_person_data.peeked >=0 then
        --偷看
        -- self.Btn_3_RedPoint:SetActive(true)
        local left_time = self.model.cur_final_person_data.max_peeking - self.model.cur_final_person_data.peeked
        self.Btn_3_RedPoint_Txt.text = string.format("%s<color='#ffff00'>(%s/3)</color>", TI18N("偷看答案"), left_time)
    end


    if self.model.cur_final_person_data.max_easing - self.model.cur_final_person_data.eased >=0 then
        --降低难度次数
        -- self.Btn_2_RedPoint:SetActive(true)
        local left_time = self.model.cur_final_person_data.max_easing - self.model.cur_final_person_data.eased
        self.Btn_2_RedPoint_Txt.text = string.format("%s<color='#ffff00'>(%s/3)</color>", TI18N("降低难度"), left_time)
    end


    if self.model.cur_final_person_data.max_doubling - self.model.cur_final_person_data.double_used >=0 then
        --双倍积分
        -- self.Btn_1_RedPoint:SetActive(true)
        local left_time = self.model.cur_final_person_data.max_doubling - self.model.cur_final_person_data.double_used
        self.Btn_1_RedPoint_Txt.text = string.format("%s<color='#ffff00'>(%s/3)</color>", TI18N("双倍积分"), left_time)
    end
end

--降低难度，擦掉某个答案
function ExamFinalWindow:update_final_erase_data(data)

    local wrong_list = {}
    local question_cfg_data = DataQuestion.data_final_question_cfg[self.model.cur_final_question_data.qid]
    if question_cfg_data.option_a ~= "" and data.right_answer ~= 1 then
        table.insert(wrong_list, 1)
    end

    if question_cfg_data.option_b ~= "" and data.right_answer ~= 2 then
        table.insert(wrong_list, 2)
    end

    if question_cfg_data.option_c ~= "" and data.right_answer ~= 3 then
        table.insert(wrong_list, 3)
    end

    if question_cfg_data.option_d ~= "" and data.right_answer ~= 4 then
        table.insert(wrong_list, 4)
    end

    local wrong_option = 0
    local wrong_option = wrong_list[Random.Range(1,  #wrong_list)]

    NoticeManager.Instance:FloatTipsByString(TI18N("这个答案已经被排除了，请选择别的答案"))


    if wrong_option == 1 then
        self:on_erase_option(self.Btn_A, self.Btn_A_Mask_Rect)
    elseif wrong_option == 2 then
        self:on_erase_option(self.Btn_B, self.Btn_B_Mask_Rect)
    elseif wrong_option == 3 then
        self:on_erase_option(self.Btn_C, self.Btn_C_Mask_Rect)
    elseif wrong_option == 4 then
        self:on_erase_option(self.Btn_D, self.Btn_D_Mask_Rect)
    end

    local erease_effect = self.option_btn_erease_effects[wrong_option]
    erease_effect:SetActive(false)
    erease_effect:SetActive(true)
    LuaTimer.Add(1300, function() erease_effect:SetActive(false) end)
end

--偷看答案
function ExamFinalWindow:update_final_cheat_data(data)
    local _list = {}
    table.insert(_list, {_type = 1, right_answer = data.choice, name = data.name})

    if self.model.final_exam_answers[self.model.cur_final_question_data.qid] ~= nil then
        for i=#self.model.final_exam_answers[self.model.cur_final_question_data.qid],1,-1 do
            table.insert(_list, self.model.final_exam_answers[self.model.cur_final_question_data.qid][i])
        end
    end
    self.model.final_exam_answers[self.model.cur_final_question_data.qid] = _list

    for i=1,#self.right_item_list do
        local item = self.right_item_list[i]
        item.gameObject:SetActive(false)
    end

    for i=1,#_list do
        if i > #self.right_item_list then
            --超过可显示条数
            break
        end
        local item = self.right_item_list[i]
        local data = _list[i]
        item:update_my_self(data, i)
        item.gameObject:SetActive(true)
    end
end


--更新左边排名列表内容
function ExamFinalWindow:update_rank_list(data)

    table.sort(data.examination_taker, function(a,b) return a.score > b.score end)

    self.TxtMyRank.text = TI18N("榜外")
    for i=1,#data.examination_taker do
        local temp_data = data.examination_taker[i]
        if temp_data.rid == RoleManager.Instance.RoleData.id and temp_data.platform == RoleManager.Instance.RoleData.platform and temp_data.zone_id == RoleManager.Instance.RoleData.zone_id then
            self.TxtMyRank.text = tostring(i)
            break
        end
    end

    -- 循环列表
    self.setting_data.data_list = data.examination_taker
    BaseUtils.refresh_circular_list(self.setting_data)
end


--更新右边答题情况内容
function ExamFinalWindow:update_answer_list()
    -- self.right_item_list
    if self.model.final_exam_answers[self.model.cur_final_question_data.qid] == nil then
        return
    end

    for i=1,#self.right_item_list do
        local item = self.right_item_list[i]
        item.gameObject:SetActive(false)
    end

    local _list = {}
    for i=1,#self.model.final_exam_answers[self.model.cur_final_question_data.qid] do
        table.insert(_list, self.model.final_exam_answers[self.model.cur_final_question_data.qid][i])
    end

    for i=1,#_list do
        if i > #self.right_item_list then
            --超过可显示条数
            break
        end
        local item = self.right_item_list[i]
        local data = _list[i]
        item:update_my_self(data, i)
        item.gameObject:SetActive(true)
    end
end

------------------------------橡皮擦，缓动选项按钮
--传入按钮和该按钮的mask_rect，缓动该mask_rect的宽度，擦掉内容的效果
function ExamFinalWindow:on_erase_option(_btn, _mask_rect)
    -- _btn.enabled = false
    self.has_erease_btns[_btn] = _btn
    Tween.Instance:ValueChange(150, 0, 0.8, callback, nil, function(val)
        _mask_rect.sizeDelta = Vector2(val, _mask_rect.rect.height)
    end)
end

--传入按钮和该按钮的mask_rect,还原按钮状态
function ExamFinalWindow:on_unerase_btn(_btn, _mask_rect)
    -- _btn.enabled = true
    self.has_erease_btns[_btn] = nil
    _mask_rect.sizeDelta = Vector2(150, _mask_rect.rect.height)
end

--传入按钮和该按钮的mask_rect,设置按钮桩位为擦掉内容
function ExamFinalWindow:on_erase_btn(_btn, _mask_rect)
    -- _btn.enabled = false
    self.has_erease_btns[_btn] = _btn
    _mask_rect.sizeDelta = Vector2(0, _mask_rect.rect.height)
end


------------------------------题目内容更新
function ExamFinalWindow:update_question_info()

    self:set_double_effect(false)

    self.out_time = false

    self.do_out_time_tips = true

    self.Btn_1.enabled = true

    local question_cfg_data = DataQuestion.data_final_question_cfg[self.model.cur_final_question_data.qid]

    self.ImgBarRect.sizeDelta = Vector2(0, self.ImgBarRect.rect.height) --max width 209.9
    self.TxtNum.text = ""
    self.TxtProgTime.text = ""

    --题目内容
    local total = self.model.cur_final_question_data.total_question
    local fenzi = self.model.cur_final_question_data.asked_num
    self.TxtQuestion.text = string.format("<color='#249015'>%s%s/%s%s:</color><color='%s'>[%s]</color>%s", TI18N("第"), fenzi, total, TI18N("题"), self.model.exam_type_name_colors[question_cfg_data.subject] , self.model.exam_type_name[question_cfg_data.subject], question_cfg_data.question)


    if self.last_qid == 0 or self.last_qid ~= self.model.cur_final_question_data.qid then
        --不是重复的题才更新
        --根据data的内容，设置哪些选项按钮为erase，那些为正常可以点击选择的按钮
        self:on_unerase_btn(self.Btn_A, self.Btn_A_Mask_Rect)
        self:on_unerase_btn(self.Btn_B, self.Btn_B_Mask_Rect)
        self:on_unerase_btn(self.Btn_C, self.Btn_C_Mask_Rect)
        self:on_unerase_btn(self.Btn_D, self.Btn_D_Mask_Rect)

        self:update_btn_state(self.Btn_A, self.Btn_A_Option_Txt, question_cfg_data.option_a)
        self:update_btn_state(self.Btn_B, self.Btn_B_Option_Txt, question_cfg_data.option_b)
        self:update_btn_state(self.Btn_C, self.Btn_C_Option_Txt, question_cfg_data.option_c)
        self:update_btn_state(self.Btn_D, self.Btn_D_Option_Txt, question_cfg_data.option_d)
    end

    self.last_qid = self.model.cur_final_question_data.qid



    ---时间计时显示
    self.cur_max_time = self.model.cur_final_question_data.expire - self.model.cur_final_question_data.asked - self.question_gap
    self.cur_left_time = self.model.cur_final_question_data.expire - BaseUtils.BASE_TIME  - self.question_gap --self.model.cur_final_question_data.asked

    self.cur_left_time = self.cur_left_time <= 0 and 1 or self.cur_left_time
    self.cur_left_time = self.cur_left_time > self.cur_max_time and self.cur_max_time or self.cur_left_time

    if self.cur_left_time > 0 then
        --题目还没过期
        self:start_prog_timer(1)
    else
        --题目已经过期
        -- self.TxtProgTime.text = TI18N("已过期")

        ExamManager.Instance:request14510()
        ExamManager.Instance:request14512()
        ExamManager.Instance:request14516()
    end

end


---------------------------按钮逻辑
--根据传入的答案状态设置按钮是否显示
function ExamFinalWindow:update_btn_state(btn, btn_txt, btn_str)
    if btn_str == "" then
        btn.gameObject:SetActive(false)
        self:set_btn_state(btn, false)
    else
        btn.gameObject:SetActive(true)
        self:set_btn_state(btn, true)
        self:set_btn_answer_state(btn, 0)
        btn_txt.text = btn_str
    end
end

--更新传入按钮的状态
function ExamFinalWindow:set_btn_state(btn, state)
    btn.enabled = state
    if state then
        btn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    else
        btn.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
end

--设置按钮的对错状态
function ExamFinalWindow:set_btn_answer_state(btn, flag)
    local imgRight = btn.transform:FindChild("ImgRight").gameObject
    local imgWrong = btn.transform:FindChild("ImgWrong").gameObject
    if flag == 0 then
        imgRight:SetActive(false)
        imgWrong:SetActive(false)
    elseif flag == 1 then
        imgRight:SetActive(true)
        imgWrong:SetActive(false)
    elseif flag == 2 then
        imgRight:SetActive(false)
        imgWrong:SetActive(true)
    end
end



---------------------------------------计时器逻辑
--计时关掉界面
function ExamFinalWindow:start_prog_timer(_type)
    self:stop_prog_timer()
    self.prog_tick_time = self.cur_left_time
    self.prog_tick_time2 = self.cur_left_time
    self.temp_time1= Time.time
    self.temp_time2= Time.time

    self.prog_timer_type = _type


    self.prog_timer_id = LuaTimer.Add(0, 1000, function() self:timer_prog_tick() end)

    if self.prog_timer_type == 1 then
        self.prog_timer_id2 = LuaTimer.Add(0, 50, function() self:timer_prog_tick2() end)
    end
end

function ExamFinalWindow:stop_prog_timer()
    if self.prog_timer_id ~= 0 then
        LuaTimer.Delete(self.prog_timer_id)
        self.prog_timer_id = 0
        self.prog_tick_time = 0
    end
    if self.prog_timer_id2 ~= 0 then
        LuaTimer.Delete(self.prog_timer_id2)
        self.prog_timer_id2 = 0
        self.prog_tick_time2 = 0
    end
end

function ExamFinalWindow:timer_prog_tick()
    self.prog_tick_time = self.prog_tick_time - (Time.time - self.temp_time1)
    self.temp_time1 = Time.time

    if self.prog_tick_time <= 0 then
        self.out_time = true
    end

     if self.prog_tick_time >= 0 then
        if self.prog_timer_type == 1 then
            self.TxtProgTime.text = string.format("%s%s", math.floor(self.prog_tick_time),TI18N("秒"))
        elseif self.prog_timer_type == 2 then
            self.TxtProgTime.text = string.format("%s%s %s", math.floor(self.prog_tick_time),TI18N("秒"), TI18N("后下一题"))
        end
    end

    --置进度条
    if self.prog_tick_time <= 0 then
        if self.do_out_time_tips then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("答题超时"))
        end

        if self.prog_timer_type == 1 then
            self.cur_left_time = self.question_gap
            self.cur_max_time = self.question_gap
            self:start_prog_timer(2)
        elseif self.prog_timer_type == 2 then
            self:stop_prog_timer()

            -- LuaTimer.Add((self.question_gap - 1)*1000, function ()
                if self.model.cur_final_question_data.total_question ~= self.model.cur_final_question_data.asked_num then
                    ExamManager.Instance:request14510()
                    ExamManager.Instance:request14512()
                    ExamManager.Instance:request14516()
                end
            -- end)

        end
    end
end

function ExamFinalWindow:timer_prog_tick2()
    self.prog_tick_time2 = self.prog_tick_time2 - (Time.time - self.temp_time2)
    self.temp_time2 = Time.time
    --置进度条
    if self.prog_tick_time2 < 0 then

    else
        self.ImgBarRect.sizeDelta = Vector2((self.prog_tick_time2/self.cur_max_time)*205, self.ImgBarRect.rect.height) --max width 209.9
    end
end



--准备阶段计时器
--计时关掉界面
function ExamFinalWindow:start_prepare_timer()
    self:stop_prepare_timer()
    self.prepare_timer_id = LuaTimer.Add(0, 1000, function() self:timer_prepare_tick() end)
end

function ExamFinalWindow:stop_prepare_timer()
    if self.prepare_timer_id ~= 0 then
        LuaTimer.Delete(self.prepare_timer_id)
        self.prepare_timer_id = 0
    end
end

function ExamFinalWindow:timer_prepare_tick()
    self.prepare_left_time = self.prepare_left_time - 1

    if self.prepare_left_time < 0 then
        self:stop_prepare_timer()
        return
    end

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.prepare_left_time)

    self.UnOpenTopTxtTime.text = string.format("%s%s%s%s", my_minute, TI18N("分"), my_second, TI18N("秒"))
end
