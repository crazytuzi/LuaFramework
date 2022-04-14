-- @Author: lwj
-- @Date:   2018-12-03 20:08:02
-- @Last Modified time: 2019-12-18 19:55:14

VipExclusivePanel = VipExclusivePanel or class("VipExclusivePanel", BaseItem)
local VipExclusivePanel = VipExclusivePanel

function VipExclusivePanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "VipExclusivePanel"
    self.layer = layer

    self.model = VipModel.GetInstance()
    self.vipItemList = {}
    self.detailPanel = {}
    self.middleItemList = {}
    self.giftItemList = {}
    self.topItemWidth = 130
    self.contentHeight = 44.7
    self.startPos = Vector2(65.12, -22.34997)
    self.lastLeftName = nil
    self.last_model = 0

    BaseItem.Load(self)
end

function VipExclusivePanel:dctor()
    if self.gift_red_dot then
        self.gift_red_dot:destroy()
        self.gift_red_dot = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

    self:DestroyLeftModel()
    --保存关闭界面的时间
    CacheManager.GetInstance():SetFloat("lastOpenVipTime", os.time())

    if not table.isempty(self.modelEventList) then
        for i, v in pairs(self.modelEventList) do
            self.model:RemoveListener(v)
        end
        self.modelEventList = {}
    end

    if self.countdowntext then
        self.countdowntext:destroy()
        self.countdowntext = nil
    end

    if self.getGiftCountDown then
        self.getGiftCountDown:destroy()
        self.getGiftCountDown = nil
    end

    if not table.isempty(self.vipItemList) then
        for i, v in pairs(self.vipItemList) do
            if v then
                v:destroy()
            end
        end
        self.vipItemList = {}
    end

    if not table.isempty(self.middleItemList) then
        for i, v in pairs(self.middleItemList) do
            if v then
                v:destroy()
            end
        end
        self.middleItemList = {}
    end

    self:CleanGiftList()
end

function VipExclusivePanel:LoadCallBack()
    self.nodes = {
        "RightContain/Top/percent",
        "RightContain/Top/btn_Get",
        "RightContain/Top/btn_Get_grey",
        "RightContain/Top/notifyPos",
        "RightContain/Top/DateT",
        "RightContain/TopBtn/TopContent/Viewport/vipBtnContent",
        "RightContain/TopBtn/TopContent",
        "RightContain/Middle/linkImg",
        "RightContain/Middle/middleScroll/Viewport/MiddleContent",
        "RightContain/Bottom/WeekGiftScroll/Viewport/GiftContent",
        "RightContain/Bottom/giftTypeT",
        "RightContain/Bottom/levelT",
        "RightContain/Bottom/CountDText",
        "RightContain/Bottom/btn_GetWeek_Grey",
        "RightContain/Bottom/btn_GetWeek_Grey/Text",
        "RightContain/Bottom/btn_GetWeek",
        "RightContain/Top/progress",
        "RightContain/Bottom/levelGiftTitleImg",
        "RightContain/Bottom/giftTitleImg",
        "RightContain/Top/icon/topText",
        "RightContain/topLeft",
        "RightContain/topRight", "RightContain/Bottom/can_get_text",
        "RightContain/Middle/middleText",
        "LeftBg/left_Img", "LeftBg/Top_Con/v_text",
        "RightContain/Top/btn_Get_grey/get_GrayT",
        "RightContain/Top/sundries/overdue", "RightContain/red_con",
        "RightContain/Top/btn_Get/dailyGetText", "LeftBg/left_con", "LeftBg/model_des", "LeftBg", "RightContain/Bottom/btn_GetWeek/gift_red_con",
        "RightContain/Top/DateT/cd",
    }
    self:GetChildren(self.nodes)
    self.percentT = self.percent:GetComponent('Text')
    self.slider = self.progress:GetComponent('Image')
    self.rectTran = self.vipBtnContent:GetComponent('RectTransform')
    self.levelTe = self.levelT:GetComponent('Text')
    self.topTextT = self.topText:GetComponent('Text')
    self.middlText = self.middleText:GetComponent('Text')
    self.grayBtnT = self.Text:GetComponent('Text')
    self.leftI = self.left_Img:GetComponent('Image')
    self.leftTopT = self.v_text:GetComponent('Text')
    self.topBtnScroll = self.TopContent:GetComponent('ScrollRect')
    self.left_title_img = GetImage(self.model_des)
    self.left_bg_img = GetImage(self.LeftBg)
    self.vip_time_t = GetText(self.cd)

    SetLocalPosition(self.can_get_text, 298, 21.55, 0)
    SetLocalPosition(self.left_con, 12, 45, 0)
    SetSizeDelta(self.rectTran, (table.nums(Config.db_vip_level) - 1) * self.topItemWidth, self.contentHeight)

    self:AddEvent()
    self:InitPanel()
    self:LaterInit()
end

function VipExclusivePanel:AddEvent()
    local function call_back()
        if self.model.roleData.viptype == 1 or self.model.roleData.vipend - os.time() <= 0 then
            --OpenLink(180, 1, 2, 1, 17)
            lua_panelMgr:GetPanelOrCreate(VipRenewPanel):Open()
            --GlobalEvent:Brocast(VipEvent.CloseVipPanel)
        else
            Dialog.ShowTwo(ConfigLanguage.Vip.GetDailyExpLogTitle, ConfigLanguage.Vip.GetDailyExpLogText, "Confirm", handler(self, self.DialogOkCall), nil, "Cancel", nil, nil, "Auto-claim", false);
        end
    end
    AddButtonEvent(self.btn_Get.gameObject, call_back)

    local function call_back()
        self.detailPanel = lua_panelMgr:GetPanelOrCreate(VipDetailPanel)
        self.detailPanel:Open(RoleInfoModel.GetInstance():GetMainRoleVipLevel())
    end
    AddClickEvent(self.linkImg.gameObject, call_back)

    local function call_back()
        if self.model.roleData.viptype == enum.VIP_TYPE.VIP_TYPE_TASTE then
            Notify.ShowText(ConfigLanguage.Vip.TasteVipCanNotFetch)
            return
        end
        self.model:Brocast(VipEvent.FetchAward, self.model.curGiftType, self.model.curLv)
    end
    AddButtonEvent(self.btn_GetWeek.gameObject, call_back)

    local function call_back()
        if self.model.curLv ~= 1 then
            self:UpdateVipButnSel(self.model.curLv - 1)
            self:SetTopContentPos()
        end
    end
    AddButtonEvent(self.topLeft.gameObject, call_back)

    local function call_back()
        if self.model.curLv ~= 12 then
            self:UpdateVipButnSel(self.model.curLv + 1)
            self:SetTopContentPos()
        end
    end
    AddButtonEvent(self.topRight.gameObject, call_back)

    self.modelEventList = {}
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.RoleInfoUpdate, handler(self, self.HandleRoleInfoUpdate))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.VipExpChange, handler(self, self.HandleVipExpChange))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.UpdateVipBtnSelect, handler(self, self.UpdateVipButnSel))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.AlredyGetGift, handler(self, self.HandleAlreadyGetGift))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.UpdateDailyExpGetRD, handler(self, self.SetRedDot))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(VipEvent.UpdateGiftBtnRD, handler(self, self.SetGiftRedDot))

    self.topBtnScroll.onValueChanged:AddListener(handler(self, self.TopBtnScrollChange))
end

function VipExclusivePanel:TopBtnScrollChange()
    if self.rectTran.anchoredPosition.x > -10 then
        SetVisible(self.topLeft.gameObject, false)
        SetVisible(self.topRight, true)
    else
        SetVisible(self.topLeft, true)
        SetVisible(self.topRight, true)
    end
    if self.rectTran.anchoredPosition.x < -886 then
        SetVisible(self.topLeft, true)
        SetVisible(self.topRight, false)
    end
end

function VipExclusivePanel:SetTopContentPos(direction)
    local lv = self.model.curLv
    --if self.rectTran.anchoredPosition.x < -5 or self.rectTran.anchoredPosition.x > -892 then
    if lv > 2 and lv < 11 then
        local delta = -(self.model.curLv - 3) * self.topItemWidth
        SetAnchoredPosition(self.rectTran, delta, self.vipBtnContent.transform.position.y)
    else
        if lv <= 2 then
            SetAnchoredPosition(self.rectTran, 0.001, self.vipBtnContent.transform.position.y)
        elseif lv >= 11 then
            SetAnchoredPosition(self.rectTran, -897.5, self.vipBtnContent.transform.position.y)
        end
    end
end

function VipExclusivePanel:DialogOkCall(bool)
    if bool then
        self.model:Brocast(VipEvent.SetAutoGetExp, true)
    end
    self.model:Brocast(VipEvent.FetchAward, 1, self.model.roleData.viplv)
    SetVisible(self.btn_Get, false)
    SetVisible(self.btn_Get_grey, true)
    self:ShowShiftWord()
    self:SetRedDot(false)
    CacheManager.GetInstance():SetFloat("lastFetchDailyTime", os.time())
end

function VipExclusivePanel:HandleVipExpChange()
    self.model.roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    self:UpdateExpText()
end

function VipExclusivePanel:HandleRoleInfoUpdate()
    self.model.roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    self:UpdateExpText()
    self.topTextT.text = "V" .. self.model.roleData.viplv
    self:LocatCurVipBtn()
end

function VipExclusivePanel:UpdateVipButnSel(id)
    for i, v in pairs(self.vipItemList) do
        v:Select(id)
    end
    self.middlText.text = "V" .. id
    self.model.curLv = id
    self:LoadMiddleItem(false)
    self:InitGiftShow(id)
end

function VipExclusivePanel:InitPanel()
    self:UpdateExpText()
    self:LoadVipBtn()
    self.countdowntext = CountDownText(self.DateT, { nodes = { "cd" }, is_auto_hide = true, isShowDay = true, isShowMin = true, isShowHour = true, isShowSec = true, isChineseType = true });
    self.getGiftCountDown = CountDownText(self.CountDText, { is_auto_hide = true, isShowDay = true, isShowSec = true, isShowMin = true, isShowHour = true, isChineseType = true, formatTime = "%d", formatText = ConfigLanguage.Vip.GetCountDown });
end

function VipExclusivePanel:LoadVipBtn()
    local count = table.nums(Config.db_vip_level) - 1
    local item = nil
    local data = {}
    for i = 1, count do
        data = {}
        item = VipTopItem(self.vipBtnContent, "UI")
        data.level = Config.db_vip_level[i + 1].level
        data.position = self.startPos
        item:SetData(data)
        table.insert(self.vipItemList, item)
        local x = self.startPos.x + self.topItemWidth
        self.startPos = Vector2(x, self.startPos.y)
    end
end

function VipExclusivePanel:InitGiftShow(id)
    --箭头
    if id == 1 then
        SetVisible(self.topLeft, false)
        SetVisible(self.topRight, true)
    elseif id == 12 then
        SetVisible(self.topRight, false)
        SetVisible(self.topLeft, true)
    else
        SetVisible(self.topRight, true)
        SetVisible(self.topLeft, true)
    end
    self.levelTe.text = id
    if not self.model.vipInfo then
        return
    end
    local haveGetLv = self.model.vipInfo.lv_reward
    local vip_lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel(true)
    if table.isempty(haveGetLv) then
        if vip_lv >= id and self.model.roleData.vipend - os.time() > 0 then
            self.model.curGiftType = 2
            self:LoadLevelGift(id, 1)
            self:ShowBrightBtn()
            self:SwitchGiftText(1)
            self.grayBtnT.text = "Claim"
        else
            self:LoadLevelGift(id, 1)
            self:ShowGrayBtn()
            self:SwitchGiftText(1)
            self.grayBtnT.text = "Pending"
        end
        if self.model.roleData.vipend - os.time() <= 0 then
            self.grayBtnT.text = "Expired"
        end
    else
        if not self:CheckGiftExist(id, haveGetLv) then
            --未领取等级礼包
            self.model.curGiftType = 2
            self:SwitchGiftText(1)
            self:LoadLevelGift(id, 1)
            --不够级数
            if self.model.roleData.viplv < id then
                self.grayBtnT.text = "Pending"
                self:ShowGrayBtn()
            else
                self.grayBtnT.text = "Claim"
                self:ShowBrightBtn()
            end
        else
            if self.model.roleData.viptype == 2 then
                --已领取等级礼包
                --当前等级
                if id == self.model.roleData.viplv then
                    self.model.curGiftType = 3
                    --显示周礼包
                    self:SwitchGiftText(2)
                    self:LoadLevelGift(id, 2)
                    --已领取周礼包
                    if self.model.vipInfo.weekly_gift then
                        self.grayBtnT.text = "Claimed"
                        self:ShowGrayBtn()
                        SetVisible(self.CountDText, true)
                        self:StartGiftCountD()
                        --self.model.curGiftType = 0
                    else
                        --未领取周礼包
                        self:ShowBrightBtn()
                        SetVisible(self.CountDText, false)
                    end
                elseif id < self.model.roleData.viplv then
                    self.grayBtnT.text = "Claimed"
                    self:ShowLevelGift(id)
                else
                    self.grayBtnT.text = "Pending"
                    self:ShowLevelGift(id)
                end
            else
                self:ShowLevelGift(id)
                self.grayBtnT.text = "Claimed"
                self:ShowGrayBtn()
            end
        end
    end
end

function VipExclusivePanel:ShowLevelGift(id)
    if id == 1 then
        self.model.curGiftType = 2
    else
        self.model.curGiftType = 3
    end
    self:LoadLevelGift(id, 1)
    self:SwitchGiftText(1)
    self:ShowGrayBtn()
end

function VipExclusivePanel:ShowGrayBtn()
    SetVisible(self.btn_GetWeek_Grey, true)
    SetVisible(self.btn_GetWeek, false)
end

function VipExclusivePanel:ShowBrightBtn()
    SetVisible(self.btn_GetWeek_Grey, false)
    SetVisible(self.btn_GetWeek, true)
    SetVisible(self.can_get_text, true)
end

function VipExclusivePanel:HandleAlreadyGetGift(data)
    if data.type == 2 then
        table.insert(self.model.vipInfo.lv_reward, data.level)
        self:InitGiftShow(self.model.curLv)
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleData().viplv
        local interator = table.pairByValue(self.model.vipInfo.lv_reward)
        local isHaveNotGetLevel = false
        for i = 1, cur_lv do
            local isGet = false
            for ii, v in interator do
                if i == v then
                    isGet = true
                    break
                end
            end
            if not isGet then
                self:UpdateVipButnSel(i)
                self:SetTopContentPos()
                isHaveNotGetLevel = true
                break
            end
        end
        if not isHaveNotGetLevel then
            if not self.model.vipInfo.weekly_gift then
                self:UpdateVipButnSel(cur_lv)
            end
        end
    elseif data.type == 3 then
        self:StartGiftCountD()
        SetVisible(self.CountDText, true)
        self.model.vipInfo.weekly_gift = true
        self:ShowGrayBtn()
    else
        self:ShowGrayBtn()
    end
    Notify.ShowText("Claimed")
end

function VipExclusivePanel:SwitchGiftText(id)
    if id == 1 then
        SetVisible(self.levelGiftTitleImg, true)
        SetVisible(self.giftTitleImg, false)
        SetVisible(self.getGiftCountDown, false)
    elseif id == 2 then
        SetVisible(self.levelGiftTitleImg, false)
        SetVisible(self.giftTitleImg, true)
        SetVisible(self.getGiftCountDown, true)
    end
end

function VipExclusivePanel:CheckGiftExist(id, list)
    local isGet = false
    for i, v in pairs(list) do
        if v == id then
            isGet = true
            break
        end
    end
    return isGet
end

function VipExclusivePanel:LoadLevelGift(id, type)
    if id ~= 0 then
        self:CleanGiftList()
        local giftList = nil
        if type == 1 then
            giftList = String2Table(Config.db_vip_level[id + 1].reward)
        elseif type == 2 then
            giftList = String2Table(Config.db_vip_level[id + 1].gift)
        end
        local list = self:CheckGiftList(giftList) or giftList
        local item = nil
        for i = 1, table.nums(list) do
            local param = {}
            param["model"] = self.model
            param["item_id"] = list[i][1]
            param["num"] = list[i][2]
            param["can_click"] = true

            item = GoodsIconSettorTwo(self.GiftContent)
            item:SetIcon(param)
            table.insert(self.giftItemList, item)
        end
    end
end
function VipExclusivePanel:CheckGiftList(list)
    dump(list, "<color=#6ce19b>VipExclusivePanel   VipExclusivePanel  VipExclusivePanel  VipExclusivePanel</color>")
    local final_list = {}
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    for i = 1, #list do
        local cf = list[i]
        local item_id = cf[1]
        local item_cf = Config.db_item[item_id]
        if item_cf then
            if item_cf.type == 10 and item_cf.stype == 10083 then
                local gift_cf = Config.db_item_gift[item_id]
                if gift_cf then
                    local con = String2Table(gift_cf.reward)
                    for i = 1, #con do
                        local item_tbl = con[i][3][1]
                        if lv >= con[i][1] and lv <= con[i][2] then
                            final_list[#final_list + 1] = item_tbl
                        end
                    end
                end
            else
                final_list[#final_list + 1] = cf
            end
        end
    end
    return final_list
end

function VipExclusivePanel:LocatCurVipBtn()
    local level = self.model.roleData.viplv
    self.topTextT.text = "V" .. level
    self.middlText.text = "V" .. level
    for i, v in pairs(self.vipItemList) do
        v:SetSelectFlag(level)
    end
    self.model.curLv = level
    self:InitGiftShow(level)
end

function VipExclusivePanel:HandleOverdue()
    SetVisible(self.btn_Get_grey, false)
    SetVisible(self.btn_Get, true)
    self.dailyGetText:GetComponent('Text').text = "Renew"
    SetVisible(self.overdue, true)
    SetVisible(self.DateT, false)
    SetVisible(self.getGiftCountDown, false)
    self:ShowGrayBtn()
    self:SetRedDot(false)
end

function VipExclusivePanel:HandleIndue()
    SetVisible(self.overdue, false)
    SetVisible(self.DateT, true)
    self.get_GrayT:GetComponent('Text').text = "Please come tomorrow"
    SetVisible(self.btn_Get_grey, false)
    SetVisible(self.btn_Get, true)
    self:ShowBrightBtn()
end

function VipExclusivePanel:LaterInit()
    if self.model.roleData.vipend - os.time() <= 0 then
        self:HandleOverdue()
    else
        self:SetGiftRedDot(self.model.is_show_gift_rd)
        self:HandleIndue()

        local vip_end = RoleInfoModel.GetInstance():GetRoleValue("vipend")
        local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
        if lv >= 4 then
            SetVisible(self.DateT, true)
            self.vip_time_t.text = "Permanent"
        else
            local function call_back()
                --vip时间到期
                self:HandleOverdue()
            end
            self.countdowntext:StartSechudle(vip_end, call_back)
        end

        --周礼包倒数
        SetVisible(self.getGiftCountDown, true)
        -- self:StartGiftCountD()
        local lastWeekTime = CacheManager.GetInstance():GetFloat('lastOpenVipTime')
        if lastWeekTime ~= 0 then
            local result = TimeManager.GetInstance():GetDifDay(lastWeekTime, os.time())
            if result > 0 then
                --打开时，已经是下一周之后 重置奖励
                self:ResetWeekGift()
            end
        else
            self:ResetWeekGift()
        end

        --每日经验判断
        if self.model.roleData and self.model.roleData.viptype == 2 then
            if self.model.vipInfo ~= nil and self.model.vipInfo.auto_fetch then
                local lastOpenTime = CacheManager.GetInstance():GetFloat('lastFetchDailyTime')
                if lastOpenTime ~= 0 then
                    local result = TimeManager.GetInstance():GetDifDay(lastOpenTime, os.time())
                    if result > 0 and not self.model.vipInfo.daily_expthen then
                        self:ShowShiftWord()
                        CacheManager.GetInstance():SetFloat("lastFetchDailyTime", os.time())
                    end
                end
            end

            if self.model.vipInfo.daily_exp then
                self:SetRedDot(false)
                SetVisible(self.btn_Get, false)
                SetVisible(self.btn_Get_grey, true)
                --不是自动领取且未领取
            elseif not self.model.vipInfo.auto_fetch and not self.model.vipInfo.daily_exp then
                self:SetRedDot(true)
                SetVisible(self.btn_Get, true)
                SetVisible(self.btn_Get_grey, false)
            end
        else
            self:SetRedDot(false)
            self.dailyGetText:GetComponent('Text').text = ConfigLanguage.Vip.BecomeVip
        end
    end

    self:LocatCurVipBtn()
    if self.model.curLv > 3 then
        local delta = -(self.model.curLv - 3) * self.topItemWidth
        SetAnchoredPosition(self.rectTran, delta, self.vipBtnContent.transform.position.y)
    end
    self:LoadMiddleItem(true)
end

--设置每日经验红点
function VipExclusivePanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function VipExclusivePanel:StartGiftCountD()
    SetVisible(self.can_get_text, false)
    local curCountD = TimeManager.GetInstance():GetZeroTime(os.time() + (TimeManager.DaySec))
    local function call_back()
        if self.getGiftCountDown then
            self.getGiftCountDown:StopSchedule()
        end
        self:ShowBrightBtn()
    end
    self.getGiftCountDown:StartSechudle(curCountD, call_back)
end

function VipExclusivePanel:ResetWeekGift()
    self:ShowBrightBtn()
end

function VipExclusivePanel:LoadMiddleItem(isStart)
    local tbl = Config.db_vip_show
    local rightsTbl = self.model:GetVipRightsCf()
    local item = nil
    local data = {}
    local value = nil
    local des = nil
    local icon = nil
    local titleDes = nil
    local changeLineStr = ""
    local lv = self.model.curLv
    if isStart then
        lv = self.model.roleData.viplv
    end
    self:SetLeftPic(tbl[lv].chartlet, lv)
    local list = String2Table(tbl[lv].rights)

    local count = table.nums(self.middleItemList)
    for i = 1, table.nums(list) do
        --local right_id = list[i]
        --local order = Config.db_vip_rights[right_id].order
        local ri_cf = Config.db_vip_rights[list[i]]
        data = {}
        value = ri_cf["vip" .. lv]
        des = ri_cf.desc
        icon = String2Table(tbl[lv].icon)[i]
        data.icon = icon
        changeLineStr = string.gsub(des, "q", "\n")
        if ri_cf.type ~= 2 then
            des = string.gsub(changeLineStr, "x", self.model:GetValueByType(ri_cf.type, value))
        else
            des = changeLineStr
        end
        data.des = des
        titleDes = String2Table(tbl[lv].title)[i][1]
        data.titleDes = titleDes
        if count > 0 then
            self.middleItemList[i]:SetData(data)
        else
            item = RightsItem(self.MiddleContent, "UI")
            item:SetData(data)
            table.insert(self.middleItemList, item)
        end
    end
end

function VipExclusivePanel:SetLeftPic(bgName, lv)
    local num = Config.db_vip_show[lv].level
    lua_resMgr:SetImageTexture(self, self.left_bg_img, "iconasset/icon_vip", "exclu_left_bg_" .. num, true, nil, false)
    lua_resMgr:SetImageTexture(self, self.left_title_img, "iconasset/icon_vip", "exclu_left_Txt_" .. num, true, nil, false)
    self.leftTopT.text = num
    local res = String2Table(Config.db_vip_show[lv].chartlet)
    if res[1] == "model" then
        if res[3] == self.last_model then
            return
        end
        self:DestroyLeftModel()
        self.last_model = res[3]
        local eft_id = {}
        local size = 4
        if res[2] == enum.MODEL_TYPE.MODEL_TYPE_PET and res[3] == tonumber(Config.db_pet[40400503].model) then
            eft_id = 10312
        elseif res[2] == enum.MODEL_TYPE.MODEL_TYPE_PET and res[3] == 20005 then
            size = 6
        end
        SetVisible(self.left_con, true)
        SetVisible(self.left_Img, false)
        self.left_model = UIPetCamera(self.left_con, nil, res[3], size, false, nil, eft_id)
        --self.left_model = UIModelManager:GetInstance():InitModel(res[2], res[3], self.left_con, handler(self, self.LoadLeftModelCB), nil, 4, model_data)
    elseif res[1] == "texture" then
        SetVisible(self.left_con, false)
        SetVisible(self.left_Img, true)
        local res_tbl = string.split(res[2], ":")
        lua_resMgr:SetImageTexture(self, self.leftI, res_tbl[1], res_tbl[2], false, nil, false)
    end
end
function VipExclusivePanel:LoadLeftModelCB()
    SetLocalPosition(self.left_model.transform, 7, -200, -400)
    SetLocalRotation(self.left_model.transform, 10, 180, 0)
    SetLocalScale(self.left_model.transform, 200, 200, 200)
end
function VipExclusivePanel:DestroyLeftModel()
    if self.left_model then
        self.left_model:destroy()
        self.left_model = nil
    end
end


--增加经验飘字
function VipExclusivePanel:ShowShiftWord()
    local layer = panelMgr:GetLayer("Top")
    local value = Config.db_vip_level[self.model.roleData.viplv + 1].vip_exp / 100
    ShiftWord(self.notifyPos, layer, "+" .. tostring(value))
end

function VipExclusivePanel:UpdateExpText()
    local curVipLv = RoleInfoModel.GetInstance():GetMainRoleData().viplv
    if curVipLv ~= "0" then
        local curExp = math.floor(tonumber(self.model.roleData.vipexp) / 100)
        local maxExp = nil
        if curVipLv == table.nums(Config.db_vip_level) - 1 then
            maxExp = Config.db_vip_level[curVipLv + 1].exp / 100
        else
            maxExp = Config.db_vip_level[tonumber(curVipLv) + 2].exp / 100
        end
        self.percentT.text = curExp .. "/" .. maxExp
        self.slider.fillAmount = curExp / maxExp
    end
end

function VipExclusivePanel:CleanGiftList()
    if not table.isempty(self.giftItemList) then
        for i, v in pairs(self.giftItemList) do
            if v then
                v:destroy()
            end
        end
        self.giftItemList = {}
    end
end

function VipExclusivePanel:SetGiftRedDot(isShow)
    if not self.gift_red_dot then
        self.gift_red_dot = RedDot(self.gift_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.gift_red_dot:SetPosition(0, 0)
    self.gift_red_dot:SetRedDotParam(isShow)
end

