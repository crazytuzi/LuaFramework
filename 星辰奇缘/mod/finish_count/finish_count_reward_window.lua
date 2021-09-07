------------------
--通关结算系统统一逻辑
------------------
FinishCountRewardWindow = FinishCountRewardWindow or BaseClass(BaseWindow)
local GameObject = UnityEngine.GameObject

function FinishCountRewardWindow:__init(model)
    self.model = model

    self.name = "FinishCountRewardWindow"

    self.isHideMainUI = false

    self.resList = {
        {file = AssetConfig.finish_count_reward_win, type = AssetType.Main}
    }

    self.X_list = {201, 163, 126, 89, 55, 22}
end



function FinishCountRewardWindow:__delete()
    for i,v in ipairs(self.slot_list) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slot_list = nil

    self:ClearDepAsset()
end

function FinishCountRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.finish_count_reward_win))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.MainCon = self.transform:Find("MainCon")

    self.CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseBtn.onClick:AddListener(function () self.model:CloseRewardWin()  end)

    self.ImgTitle = self.MainCon:FindChild("ImgTitle")
    self.TxtTitleTop = self.ImgTitle:FindChild("TxtTitle"):GetComponent(Text)

    self.MidCon = self.MainCon:FindChild("MidCon")
    -- self.TxtPass = self.MidCon:FindChild("TxtPass"):GetComponent(Text)
    self.TxtPassVal1 = self.MidCon:FindChild("TxtPassVal1"):GetComponent(Text)
    self.TxtPassVal = self.MidCon:FindChild("TxtPassVal"):GetComponent(Text)
    self.TxtPassVal2 = self.MidCon:FindChild("TxtPassVal2"):GetComponent(Text)

    self.TxtPassVal1.text = ""
    self.TxtPassVal.text = ""
    self.TxtPassVal2.text = ""


    self.ImgBg = self.MidCon:FindChild("ImgBg")
    self.TxtTitle = self.ImgBg:FindChild("TxtTitle"):GetComponent(Text)
    self.ImgConfirmBtn = self.MainCon:FindChild("ImgConfirmBtn"):GetComponent(Button)
    self.ImgConfirmBtnTxt = self.ImgConfirmBtn.transform:FindChild("Text"):GetComponent(Text)
    self.ImgConfirmBtn.onClick:AddListener(function () self:on_click_btn()  end)

    self.ImgShareBtn = self.MainCon:FindChild("ImgShareBtn"):GetComponent(Button)
    self.ImgShareBtn.onClick:AddListener(function ()
        if self.model.has_share_score == false then
            if GuildManager.Instance.model:check_has_join_guild() then
                local msg = string.format("<color='#4acb5b'>%s%s%s%s%s</color>", TI18N("我的智慧闯关成绩： 答对数："),    self.  model.reward_win_data.scoket_data.right_num , TI18N("题"), TI18N("，总得分："), self.   model.   reward_win_data.scoket_data.score)
                ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.Guild, msg)
                self.model.has_share_score = true
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("你尚未加入公会"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("你已经分享过成绩了"))
        end
    end)

    self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    self.ImgShareBtn.gameObject:SetActive(false)

    self.ConSlot = self.MidCon:FindChild("MaskScroll/ConSlot")
    self.BaseSlot = self.MidCon:Find("MaskScroll/ConSlot/SlotConbase").gameObject

    self.slot_list = {}
    self.slot_con_list = {}
    -- for i=1,6 do
    --     local slot_con = self.ConSlot:FindChild(string.format("SlotCon%s", i))
    --     local slot = self:create_equip_slot(slot_con)
    --     table.insert(self.slot_list, slot)
    --     table.insert(self.slot_con_list, slot_con)
    -- end

    self:update_info()
end

--确定按钮点击事件
function FinishCountRewardWindow:on_click_btn()
    self.model:CloseRewardWin()
    if ExamManager.Instance.data_14503 ~= nil then
        if self.model.reward_win_data.callback ~= nil then
            self.model.reward_win_data.callback()
        end
    end
end

function FinishCountRewardWindow:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

function FinishCountRewardWindow:set_stone_slot_data(slot, data)
    if data ~= nil then
        local cell = ItemData.New()
        cell:SetBase(data)
        slot:SetAll(cell, nil)
    else
        slot:SetAll(nil, nil)
    end
end

function FinishCountRewardWindow:update_info()
    local btn_str = TI18N("确 定")
    self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-100, -119)
    self.ImgShareBtn.gameObject:SetActive(true)

    if ExamManager.Instance.model.cur_exam_type == 2 then
        if self.model.reward_win_data.scoket_data.answered ~= 30 then
            btn_str = TI18N("前往下个考官")
            self.ImgConfirmBtn.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, -119)
            self.ImgShareBtn.gameObject:SetActive(false)
        end
    end
    self.ImgConfirmBtnTxt.text = btn_str

    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.model.reward_win_data.scoket_data.elapsed)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    local time_str = string.format("<color='#8DE92A'>%s%s%s%s</color>", my_minute, TI18N("分"), my_second, TI18N("秒"))
    self.TxtTitleTop.text = self.model.reward_win_data.title_str
    -- self.TxtPass.text = self.model.reward_win_data.mid_title_1
    self.TxtPassVal.text = str
    self.TxtTitle.text = self.model.reward_win_data.mid_title_2

    local fujia_score = 720 - self.model.reward_win_data.scoket_data.elapsed
    fujia_score = fujia_score < 0 and 0 or fujia_score
    fujia_score = fujia_score > 240 and 240 or fujia_score

    local str1 = string.format("%s%s %s%s",TI18N("答对数:"), self.model.reward_win_data.scoket_data.right_num ,TI18N(" 得分:"), self.model.reward_win_data.scoket_data.score -  fujia_score)
    local str2 = string.format("%s%s",TI18N("答题结束 总得分:"), (self.model.reward_win_data.scoket_data.score))
    local str = string.format("%s%s %s%s", TI18N("用时："), time_str, TI18N("附加分："), fujia_score)

    self.TxtPassVal.text = ""
    self.TxtPassVal1.text =  ""
    self.TxtPassVal2.text =  ""
    if ExamManager.Instance.model.cur_exam_type == 2 then
        if self.model.reward_win_data.scoket_data.answered == 30 then
            --会试，最后一道题
            self.TxtPassVal1.text = str1
            self.TxtPassVal.text = str
            self.TxtPassVal2.text = str2
        else
            --会试，不是最后一道题
            -- str = string.format("%s%s %s%s", TI18N("用时："), time_str, TI18N("总得分:"), self.model.reward_win_data.scoket_data.score)
            str = string.format("%s%s", TI18N("总得分:"), self.model.reward_win_data.scoket_data.score)
            str1 = string.format("%s%s %s%s",TI18N("答对数:"), self.model.reward_win_data.scoket_data.right_num ,TI18N("答错数:"), self.model.reward_win_data.scoket_data.answered - self.model.reward_win_data.scoket_data.right_num)
            self.TxtPassVal1.text = str1
            self.TxtPassVal.text = ""--str
            self.TxtPassVal2.text = ""
        end
    elseif ExamManager.Instance.model.cur_exam_type == 1 then
        --院试
        str = string.format("%s%s %s%s", TI18N("用时："), time_str, TI18N("总得分:"), self.model.reward_win_data.scoket_data.score)
        str1 = string.format("%s%s %s%s",TI18N("答对数:"), self.model.reward_win_data.scoket_data.right_num ,TI18N("答错数:"), self.model.reward_win_data.scoket_data.answered - self.model.reward_win_data.scoket_data.right_num)
        self.TxtPassVal1.text =  str1
        self.TxtPassVal.text = str
        self.TxtPassVal2.text =  ""
    elseif ExamManager.Instance.model.cur_exam_type == 3 then
        -- 殿试最后一道题
        str = string.format("%s%s %s%s", TI18N("用时："), time_str, TI18N("答对数:"), self.model.reward_win_data.scoket_data.right_num)
        str1 = string.format("%s%s %s%s",TI18N("答对数:"), self.model.reward_win_data.scoket_data.right_num ,TI18N("答错数:"), self.model.reward_win_data.scoket_data.answered - self.model.reward_win_data.scoket_data.right_num)
        self.TxtPassVal1.text =  str1
        self.TxtPassVal.text = str
        self.TxtPassVal2.text =  ""
    end

    self.TxtPassVal1.gameObject:SetActive(true)
    self.TxtPassVal2.gameObject:SetActive(true)
    self:InitSlot()
    local reward_llist = self.model.reward_win_data.reward_list
    for i=1,#reward_llist do
        local data = reward_llist[i]
        local base_data = DataItem.data_get[data.id]
        self.slot_con_list[i].gameObject:SetActive(true)
        self:set_stone_slot_data(self.slot_list[i], base_data)
        self.slot_list[i]:SetNum(data.num)
    end
    -- self.ConSlot:GetComponent(RectTransform).anchoredPosition = Vector2(self.X_list[#reward_llist], -135.6)
end

function FinishCountRewardWindow:InitSlot()
    local reward_llist = self.model.reward_win_data.reward_list
    for i=1,#reward_llist do
        local slot_con = GameObject.Instantiate(self.BaseSlot)
        slot_con.name = string.format("SlotCon%s", i)
        slot_con = slot_con.transform
        slot_con:SetParent(self.ConSlot)
        slot_con.localScale = Vector3.one
        local slot = self:create_equip_slot(slot_con)
        table.insert(self.slot_list, slot)
        table.insert(self.slot_con_list, slot_con)
    end
end