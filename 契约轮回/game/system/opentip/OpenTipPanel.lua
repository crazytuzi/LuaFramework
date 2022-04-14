-- @Author: lwj
-- @Date:   2018-11-13 16:10:13
-- @Last Modified time: 2019-10-31 11:57:32

OpenTipPanel = OpenTipPanel or class("OpenTipPanel", BasePanel)
local OpenTipPanel = OpenTipPanel

function OpenTipPanel:ctor()
    self.abName = "system"
    self.assetName = "OpenTipPanel"
    self.layer = "UI"

    self.model = OpenTipModel.GetInstance()
    self.isInTopRight = false
    self.is_serch_id = false      --是否只是用于展示的弹窗
    self.pos_y = 0
    self.pos_z = 750
    self.pos_x = -4011
    self.rota_y = 0
    self.show_time = 9

    self.is_hide_other_panel = true
    self.panel_type = 2
end

function OpenTipPanel:dctor()
end

function OpenTipPanel:Open(isOpenUI, data, child_index)
    self.isOpenUI = isOpenUI
    self.data = data
    self.model.cur_open_sys = data
    self.child_index = child_index

    BasePanel.Open(self)
end

function OpenTipPanel:LoadCallBack()
    self.nodes = {
        "confirm_btn", "block",
        "icon",
        "iconContent",
        "modelContent", "Title", "modelContent/Floor",
        "eft_content", "modelContent/Attr_Bg", "modelContent/attr_con",
        "modelContent/name", "modelContent/attr_con/OpenTipAttrItem",
        "modelContent/model_img/Camera", "modelContent/model_img",
        "iconContent/third/des", "iconContent/third",
        "iconContent/second/icon_bg", "iconContent/second/Title_Text", "iconContent/second",
        "confirm_btn/CDT",
    }
    self:GetChildren(self.nodes)
    SetLocalPositionY(self.des.transform, -63)
    self.icon_img = self.icon:GetComponent("Image")
    self.name = GetText(self.name)
    self.eft_rect = GetRectTransform(self.eft_content)
    self.btn_rect_transform = self.confirm_btn:GetComponent('RectTransform')
    self.item_obj = self.OpenTipAttrItem.gameObject
    self.block_img = GetImage(self.block)
    self.block_img.enabled = true
    self.icon_bg = GetImage(self.icon_bg)
    self.Title_Text = GetImage(self.Title_Text)
    self.btn_img = GetImage(self.confirm_btn)
    self.CDT = GetText(self.CDT)
    self.des_t = GetText(self.des)
    SetVisible(self.second, false)

    self.countdowntext = CountDownText(self.confirm_btn, { nodes = { "CDT" }, formatText = "Confirm (%s sec)", formatTime = "%d", isShowMin = false, isShowHour = false, isShowDay = false });
    self.countdowntext.gameObject:SetActive(true);
    local function call_back()
        self:ClickFunction()
        self.countdowntext:StopSchedule()
    end
    self.countdowntext:StartSechudle(os.time() + self.show_time, call_back)

    self.texture = CreateRenderTexture()
    self.texture_cpn = self.model_img:GetComponent("RawImage")
    self.texture_cpn.texture = self.texture
    self.cam = self.Camera:GetComponent("Camera")
    self.cam.targetTexture = self.texture

    self.tbl = Config.db_sysopen[self.data]
    self:AddEvent()
    self:UpdateView()
end

function OpenTipPanel:OpenCallBack()
    local bottom = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Bottom)
    SetVisible(bottom, false)
    SoundManager.GetInstance():PlayById(53)
    GlobalEvent:Brocast(MainEvent.CloseGMPanel)
    TaskModel:GetInstance():PauseTask()

    --SetAnchoredPosition(self.eft_rect, -16.6, -51.7)
    SetLocalPosition(self.attr_con.transform, 69.9, -198.7)
    SetLocalPosition(self.iconContent, 0, 0, 0)
    SetLocalPosition(self.icon.transform, -4.8, 28.5, 0)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.block.transform, nil, true, nil, false, -420)
end
--------------------动画
function OpenTipPanel:PlayFirstAni()
    --缩放
    local scale_act = cc.ScaleTo(0.05, 1)
    cc.ActionManager:GetInstance():addAction(scale_act, self.transform)
    --第二部分
    local function step()
        local sec_fadein_act = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act, self.icon_bg)
        --local sec_fadein_act_1 = cc.FadeIn(0.5)
        local sec_fadein_act_2 = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act_2, self.Title_Text)
    end
    self.show_sec_sche_id = GlobalSchedule:StartOnce(step, 0.2)

    --第三部分
    local function third_step()
        SetVisible(self.icon, true)
        local sec_fadein_act_1 = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act_1, self.CDT)
        local sec_fadein_act_2 = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act_2, self.btn_img)
        local sec_fadein_act_3 = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act_3, self.icon_img)
        local sec_fadein_act_4 = cc.FadeIn(0.1)
        cc.ActionManager:GetInstance():addAction(sec_fadein_act_4, self.des_t)
    end
    self.show_third_sche_id = GlobalSchedule:StartOnce(third_step, 0.4)
end

function OpenTipPanel:RotateAnim()
    local action = cc.RotateTo(4, 360)
    action = cc.Sequence(action, cc.RotateTo(0, 360))
    return action
end

-----------------------------------------

function OpenTipPanel:SetPos()
    if self.data == "110@6" then
        self.x = 516.1411
        self.y = -34.20654
        return
    end
    self.x = nil
    self.y = nil
    local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
    local key = Config.db_sysopen[self.data].key
    local id_sub_id = self.tbl.id .. self.tbl.sub_id
    if JudgeIsInTopRight(key) or id_sub_id == "4001" then
        self.isInTopRight = true
        mainpanel.main_top_right:ChangeToShowMode(true)
        if id_sub_id == "4001" then
            self.x, self.y = mainpanel.main_top_right:GetItemPos("daily")
        else
            self.x, self.y = mainpanel.main_top_right:GetItemPos(key)
        end
        self.x = self.x
        self.y = self.y
    else
        self.x, self.y = mainpanel.main_bottom_right:GetRightIconPos(key)
    end
end

function OpenTipPanel:AddEvent()
    local function call_back()
        self:ClickFunction()
    end
    AddClickEvent(self.confirm_btn.gameObject, call_back)
end

function OpenTipPanel:ClickFunction()
    SetVisible(self.bg, false)
    SetVisible(self.iconContent, false)
    SetVisible(self.modelContent, false)
    SetVisible(self.confirm_btn, false)
    SetVisible(self.background, false)
    SetVisible(self.icon, true)
    SetVisible(self.eft_content, false)
    SetVisible(self.Title, false)
    SetVisible(self.block, false)
    SetVisible(self.icon, true)
    local bottom = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Bottom)
    SetVisible(bottom, true)
    self:SetPos()
    --local time = 5
    local time = 0.5
    self.x = self.x or 0
    self.y = self.y or 0
    local tbl = string.split(self.data, "@")
    local moveAction = cc.MoveTo(time, self.x, self.y, 0)
    moveAction = cc.EaseExponentialOut(moveAction)
    local function end_call_back()
        if self.isInTopRight then
            GlobalEvent:Brocast(MainEvent.ShowSelfAfterOpen, self.data)
        else
            GlobalEvent:Brocast(EventName.ShowSpecifiedMainRightIcon, tonumber(tbl[1]), tonumber(tbl[2]))
        end
        self:Close()
    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action, moveAction, call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.icon)
end

function OpenTipPanel:UpdateView()
    self.sysData = GetOpenByKey(self.data)
    local res_tab
    local sysopen_cf = Config.db_sysopen[self.data]

    --if not self.sysData then
    --    self.is_serch_id = true
    --    self.sysData = GetIconDataByKey(Config.db_sysopen[self.data].key)9GetInstance
    --    res_tab = string.split(self.sysData, ":")
    --else
    --    res_tab = string.split(self.sysData.icon, ":")
    --end

    local str
    if sysopen_cf.type == 3 then
        str = String2Table(sysopen_cf.res)[2]
        self.is_serch_id = true
    elseif sysopen_cf.type == 4 then
        self.is_serch_id = true
        str = sysopen_cf.res
    else
        self.is_serch_id = true
        self.sysData = GetIconDataByKey(Config.db_sysopen[self.data].key)
        str = self.sysData
    end
    res_tab = string.split(str, ":")

    local abName = res_tab[1]
    local assetName = res_tab[2]
    lua_resMgr:SetImageTexture(self, self.icon_img, abName, assetName, true, nil, false)
    if self.tbl.type == 1 or self.tbl.type == 4 then
        --图标
        --SetVisible(self.eft_rect, false)
        self:SetAttrState(false)
        SetAnchoredPosition(self.eft_rect, -17, -50)
        SetVisible(self.iconContent, true)
        self.des:GetComponent('Text').text = Config.db_sysopen[self.data].des
        if self.newSysOpen ~= nil then
            self.newSysOpen:destroy()
        end
        self.newSysOpen = UIEffect(self.eft_content, 10125, false, self.layer)
        self.newSysOpen.is_hide_clean = false
        self.newSysOpen:SetOrderIndex(199)
        SetAnchoredPosition(self.btn_rect_transform, -8.3, -203.8)
        self:PlayFirstAni()
    elseif self.tbl.type == 2 or self.tbl.type == 3 then
        --模型
        SetLocalScale(self.transform, 1, 1, 1)
        SetAlpha(self.btn_img, 1)
        SetAlpha(self.CDT, 1)
        SetAlpha(self.icon_img, 1)
        self:SetAttrState(true)
        self:LoadAttr()
        local str = sysopen_cf.title_name
        if str ~= "" then
            self.name.text = str
        end
        SetAnchoredPosition(self.eft_rect, 0, -49)
        self:DestroyModel()
        local res_id = self.tbl.res
        local res_tbl = String2Table(self.tbl.res)
        if self.tbl.id == 130 and self.tbl.sub_id == 1 then
            self.ui_model = UIMountModel(self.model_img.transform, res_id, handler(self, self.Loadui_modelCallBack));
        else
            self:GetRightPos(self.tbl.res)
            self.ui_model = UIModelManager:GetInstance():InitModel(nil, res_tbl[1], self.model_img.transform, handler(self, self.model_cb), true)
        end

        SetVisible(self.modelContent, true)
        SetVisible(self.icon, false)
        SetVisible(self.iconContent, false)
        SetAnchoredPosition(self.btn_rect_transform, 0, -313.4)
        self:LoadModelEffect()
    end
end
function OpenTipPanel:GetRightPos(res_str)
    self.model_cb = handler(self, self.LoadMgrModelCallB)
    local tbl = string.split(res_str, "_")
    local type = tbl[2]
    if type == "fabao" then
        self.pos_y = -67
        self.pos_z = 328
        self.rota_y = 180
    elseif type == "monster" then
        self.pos_y = 0
    elseif type == "mount" then
        self.pos_y = -238
    elseif type == "npc" then
        self.pos_y = 0
    elseif type == "pet" then
        self.pos_y = -121.6
        self.pos_z = 477.1
        self.rota_y = 180
    elseif type == "role" then
        self.pos_y = 0
    elseif type == "wing" then
        self.pos_x = -4014.1
        self.pos_y = -47
        self.pos_z = 373
    elseif type == "weapon" then
        self.pos_y = -35
        self.pos_z = 483
        self.rota_y = 180
        self.model_cb = handler(self, self.WeaponCallBack)
    elseif type == "hand" then
        self.pos_y = -102
    elseif type == "machiaction" then
        self.pos_y = -240
        self.pos_z = 450
        self.rota_y = 180
        SetVisible(self.Floor, false)
    end
end

function OpenTipPanel:LoadModelEffect()
    if self.newSysOpen ~= nil then
        self.newSysOpen:destroy()
    end
    self.newSysOpen = UIEffect(self.eft_content, 10101, false, self.layer)
    self.newSysOpen:SetConfig({ is_loop = true })
    self.newSysOpen.is_hide_clean = false
    self.newSysOpen:SetOrderIndex(199)
end

function OpenTipPanel:Loadui_modelCallBack()
    SetLocalPosition(self.ui_model.transform, self.pos_x, -185, self.pos_z)
    --SetLocalRotation(self.ui_model.transform, 1, -124.5, 1)
    SetLocalRotation(self.ui_model.transform, 0, 225, 0)
    SetLocalScale(self.ui_model.transform, 100, 100, 100)
end
function OpenTipPanel:LoadMgrModelCallB()
    SetLocalPosition(self.ui_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.ui_model.transform.localScale;
    SetLocalScale(self.ui_model.transform, 100, 100, 100);
    SetLocalRotation(self.ui_model.transform, 0, self.rota_y, 0);
end
function OpenTipPanel:WeaponCallBack()
    SetLocalPosition(self.ui_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.ui_model.transform.localScale;
    SetLocalScale(self.ui_model.transform, 100, 100, 100);
    SetLocalRotation(self.ui_model.transform, 0, self.rota_y, 0);

    self.ui_model:AddAnimation({ "show", "idle2" }, false, "idle2", 0)--,"casual"
    self.ui_model.animator:CrossFade("idle2", 0)
end

--function OpenTipPanel:SetData(data, child_index)
--    self.data = data
--    self.model.cur_open_sys = data
--    self.child_index = child_index
--    if self.is_loaded then
--        self:UpdateView()
--        self:SetPos()
--    end
--end

function OpenTipPanel:DestroyModel()
    if self.ui_model ~= nil then
        self.ui_model:destroy()
        self.ui_model = nil
    end
end

function OpenTipPanel:SetAttrState(flag)
    SetVisible(self.Attr_Bg, flag)
    SetVisible(self.attr_con, flag)
end

function OpenTipPanel:LoadAttr()
    local temp_list = String2Table(self.tbl.attrs)
    local list = {}
    if type(temp_list[1]) == "number" then
        list = { temp_list[1], temp_list[2] }
    else
        list = temp_list
    end
    self.attr_item_list = self.attr_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.attr_item_list[i]
        if not item then
            item = OpenTipAttrItem(self.item_obj, self.attr_con)
            self.attr_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.attr_item_list do
        local item = self.attr_item_list[i]
        item:SetVisible(false)
    end
end

function OpenTipPanel:CloseCallBack()
    if self.show_sec_sche_id then
        GlobalSchedule:Stop(self.show_sec_sche_id)
        self.show_sec_sche_id = nil
    end
    if self.show_third_sche_id then
        GlobalSchedule:Stop(self.show_third_sche_id)
        self.show_third_sche_id = nil
    end
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.Title_Text)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.icon_bg)

    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.icon_img)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.des_t)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.CDT)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_img)

    if self.countdowntext then
        self.countdowntext:destroy();
        self.countdowntext = nil
    end
    if self.newSysOpen ~= nil then
        self.newSysOpen:destroy()
        self.newSysOpen = nil
    end

    if self.texture_cpn then
        self.texture_cpn.texture = nil
    end

    if self.cam then
        self.cam.targetTexture = nil
    end

    if self.texture then
        ReleseRenderTexture(self.texture)
        self.texture = nil
    end
    self.model:RemoveNeedShow()
    if not table.isempty(self.attr_item_list) then
        for i, v in pairs(self.attr_item_list) do
            if v then
                v:destroy()
            end
        end
        self.attr_item_list = {}
    end

    self.model.isOpenning = false
    TaskModel:GetInstance():ResumeTask()
    if self.isOpenUI then
        UnpackLinkConfig(self.data)
    else
        GlobalEvent:Brocast(EventName.OpenNextSysTipPanel)
    end
    self:DestroyModel()
end