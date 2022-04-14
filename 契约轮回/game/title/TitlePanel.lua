-- @Author: lwj
-- @Date:   2018-12-16 16:48:47
-- @Last Modified time: 2018-12-16 16:48:56
TitlePanel = TitlePanel or class("TitlePanel", BaseItem)
local TitlePanel = TitlePanel

function TitlePanel:ctor(parent_node, layer)
    self.abName = "title"
    self.assetName = "TitlePanel"
    self.layer = layer

    self.model = TitleModel.GetInstance()
    self.events = {}
    self.modelEventList = {}
    self.subItemList = {}
    self.properTitleList = {}
    self.proValueList = {}
    self.role_model = nil
    self.isCanSetId = true
    self.show_percent_after_idx = 12

    BaseItem.Load(self)
end

function TitlePanel:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.cdText then
        self.cdText:destroy()
    end
    self.cdText = nil

    for i, v in pairs(self.modelEventList) do
        self.model:RemoveListener(v)
    end
    self.modelEventList = {}

    GlobalEvent:RemoveTabListener(self.events);

    self:ClearSchedual()

    for i, v in pairs(self.properTitleList) do
        if v then
            table.removebyvalue(self.properTitleList, v)
        end
    end
    self.properTitleList = {}

    for i, v in pairs(self.proValueList) do
        if v then
            table.removebyvalue(self.proValueList, v)
        end
    end
    self.proValueList = {}

    self:DestroyLeftMenu()

    self:DestroyRoleModel()
    self.subItemList = {}
end

function TitlePanel:LoadCallBack()
    self.nodes = {
        "leftContain/foldContain",
        "middleContain/title",
        "middleContain/name",
        "middleContain/btn_puton",
        "middleContain/btn_puton/putText",
        "rightContain/powerText",
        "rightContain/properties/pro_3", "rightContain/properties/pro_4", "rightContain/properties/pro_1", "rightContain/properties/pro_2", "rightContain/properties/pro_5",
        "rightContain/propertiyValues/value_3", "rightContain/propertiyValues/value_4", "rightContain/propertiyValues/value_1", "rightContain/propertiyValues/value_2", "rightContain/propertiyValues/value_5",
        "middleContain/remainBg",
        "rightContain/des",
        "middleContain/remainBg/TitleText/countdowntext",
        "middleContain/remainBg/TitleText",
        "middleContain/txcontain/touxian", "middleContain/txcontain/name_touxian",
        "middleContain/txcontain",
        "middleContain/model_content",
        "middleContain/hadntGet", "middleContain/already_wear",
        "middleContain/left_rotate", "middleContain/right_rotate", "middleContain/red_con", "rightContain/properties/pro_6", "rightContain/propertiyValues/value_6",
    }
    self:GetChildren(self.nodes)
    self.titleImg = self.title:GetComponent('Image')
    self.nameT = self.name:GetComponent('Text')
    self.powerT = self.powerText:GetComponent('Text')
    self.putT = self.putText:GetComponent('Text')
    self.desT = self.des:GetComponent('Text')
    self.cdT = self.countdowntext:GetComponent('Text')
    self.touxianT = self.touxian:GetComponent('Text')
    self.nameTouT = self.name_touxian:GetComponent('Text')
    self.nameT_outline = self.nameT:GetComponent('Outline')
    self.nameTouT_outline = self.name_touxian:GetComponent('Outline')
    self.touxian_outline = self.touxian:GetComponent('Outline')

    SetVisible(self.already_wear,true)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_content.transform, nil, true, nil, 1, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.hadntGet.transform, nil, true, nil, 1, 10)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.already_wear.transform, nil, true, nil,1 , 10)
    SetVisible(self.already_wear,false)

    self:AddProperTitle()
    self:AddProValue()

    self:AddEvent()
    self:CheckTitleShow()
    local defa_id = FashionModel.GetInstance().default_sel_id
    if defa_id and defa_id >= 46000 then
        self.model.curSub_id = defa_id
    else
        self.model.curSub_id = String2Table(Config.db_title_menu[1].sub_id)[1][1]
    end
    self.menuId = 1
    self:InitPanel(true)
    self:UpdatePanelShow()
    self:LoadRoleModel()
    self:CheckIsNeedSelDefault()
end

function TitlePanel:AddProperTitle()
    self.pro_1T = self.pro_1:GetComponent('Text')
    self.pro_2T = self.pro_2:GetComponent('Text')
    self.pro_3T = self.pro_3:GetComponent('Text')
    self.pro_4T = self.pro_4:GetComponent('Text')
    self.pro_5T = self.pro_5:GetComponent('Text')
    self.pro_6T = self.pro_6:GetComponent('Text')

    table.insert(self.properTitleList, self.pro_1T)
    table.insert(self.properTitleList, self.pro_2T)
    table.insert(self.properTitleList, self.pro_3T)
    table.insert(self.properTitleList, self.pro_4T)
    table.insert(self.properTitleList, self.pro_5T)
    table.insert(self.properTitleList, self.pro_6T)
end

function TitlePanel:AddProValue()
    self.value_1T = self.value_1:GetComponent('Text')
    self.value_2T = self.value_2:GetComponent('Text')
    self.value_3T = self.value_3:GetComponent('Text')
    self.value_4T = self.value_4:GetComponent('Text')
    self.value_5T = self.value_5:GetComponent('Text')
    self.value_6T = self.value_6:GetComponent('Text')

    table.insert(self.proValueList, self.value_1T)
    table.insert(self.proValueList, self.value_2T)
    table.insert(self.proValueList, self.value_3T)
    table.insert(self.proValueList, self.value_4T)
    table.insert(self.proValueList, self.value_5T)
    table.insert(self.proValueList, self.value_6T)
end

function TitlePanel:AddEvent()
    local function call_back()
        self.role_model:SetModelRotationY(30)
    end
    AddButtonEvent(self.right_rotate.gameObject, call_back)

    local function call_back()
        self.role_model:SetModelRotationY(-30)
    end
    AddButtonEvent(self.left_rotate.gameObject, call_back)

    local function call_back()
        local mode = self.model.curBtnMode
        if mode == 1 then
            self.model.curInfoListMode = 2
            self.model:Brocast(TitleEvent.PutOnTitle)
        elseif mode == 2 then
            self.model.curInfoListMode = 2
            self.model:Brocast(TitleEvent.PutOffTitle)
        elseif mode == 3 then
            self.model.curInfoListMode = 1
            self.model:Brocast(TitleEvent.ActivateTitle)
        end
    end
    AddButtonEvent(self.btn_puton.gameObject, call_back)

    self.modelEventList = {}
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.events);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.events);

    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(TitleEvent.UpdateTitleInfoLIst, handler(self, self.HandleUpdatePanel))
end

function TitlePanel:HandleLeftFirstClick(index)
    if self.isCanSetId then
        self.menuId = index
        if table.nums(self.sub_menu[index]) > 0 then
            self.model.curSub_id = FashionModel.GetInstance().default_sel_id or self.sub_menu[index][1][1]
        end
        self:UpdatePanelShow()
    else
        self.isCanSetId = true
    end
end

--Put按钮操作
function TitlePanel:HandleUpdatePanel()
    self.isCanSetId = false
    self:DestroyLeftMenu()
    self:InitPanel(false)
    self:UpdatePanelShow()
    local index = self:GetIndexByMenu(self.menuId)
    self.leftMenu:SetDefaultSelected(self.menuId, index)
end

function TitlePanel:InitPanel(isInitDefault)
    GlobalEvent:Brocast(TitleEvent.UpdateTitlePuton, self.model.titleInfoList.puton_id)
    self.leftMenu = TreeMenu(self.foldContain, nil, self, TreeOnePhotoMenu, TreeTwoPhotoMenu)
    self.menuTran = self.leftMenu.transform:GetComponent('RectTransform')
    self.menuTran.sizeDelta = Vector2(250, 514)
    --self.leftMenu.LeftScrollView:GetComponent('RectTransform').sizeDelta = Vector2(0, 0)
    self.leftMenu:SetViewSize(248, 508)

    self.menu, self.sub_menu = {}, {}
    local showTime = 0
    local lostTime = 0
    local conData = nil
    local removeList = {}
    for i = 1, #Config.db_title_menu do
        local item = Config.db_title_menu[i]
        local list = String2Table(item.sub_id)
        local sub_List = {}
        if table.isempty(self.model.titleInfoList.titles) then
            for ii = 1, #list do
                conData = {}
                conData = Config.db_title[list[ii][1]]
                showTime = TimeManager.GetInstance():String2Time(conData.show_time)
                lostTime = TimeManager.GetInstance():String2Time(conData.lost_time)
                local is_empty = not showTime and not lostTime
                if showTime ~= 0 and lostTime ~= 0 and not is_empty then
                    if os.time() < showTime or os.time() > lostTime then
                        local num = BagModel.GetInstance():GetItemNumByItemID(conData.id)
                        if num == 0 then
                            table.insert(removeList, list[ii])
                        end
                    end
                end
            end
            for i, v in pairs(removeList) do
                table.removebyvalue(list, v)
            end
            removeList = {}
            sub_List = list
        else
            local interator = table.pairsByKey(self.model.titleInfoList.titles)
            for id, value in interator do
                for seri, listV in pairs(list) do
                    if value.id == listV[1] then
                        sub_List[#sub_List + 1] = listV
                        table.removebyvalue(list, listV)
                        break
                    end
                end
            end
            local listIntera = table.pairsByKey(list)
            for listId, listV in listIntera do
                conData = Config.db_title[listV[1]]
                showTime = TimeManager.GetInstance():String2Time(conData.show_time)
                lostTime = TimeManager.GetInstance():String2Time(conData.lost_time)
                if showTime and lostTime then
                    if os.time() >= showTime and os.time() <= lostTime then
                        sub_List[#sub_List + 1] = listV
                    else
                        local num = BagModel.GetInstance():GetItemNumByItemID(conData.id)
                        if num > 0 then
                            sub_List[#sub_List + 1] = listV
                        end
                    end
                else
                    sub_List[#sub_List + 1] = listV
                end
            end
        end
        self.sub_menu[item.type_id] = sub_List

        local data = { item.type_id, item.name }
        table.insert(self.menu, data)
    end
    self.leftMenu:SetData(self.menu, self.sub_menu, self.sub_menu[1][1], 2, 2)
    if isInitDefault then
        self.leftMenu:SetDefaultSelected(self.sub_menu[1], self.sub_menu[1][1])
    end
    local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    local touxian = nil
    if role_data.figure.jobtitle then
        touxian = role_data.figure.jobtitle.model
    end
    if touxian == nil or touxian == 0 then
        SetVisible(self.txcontain, false)
        SetVisible(self.name, true)
        touxian = ""
        SetColor(self.nameT, 255, 250, 201)
        SetOutLineColor(self.nameT_outline, 6, 0, 1, 255)
        self.nameT.text = role_data.name
    else
        SetVisible(self.txcontain, true)
        SetVisible(self.name, false)
        local r, g, b, a = HtmlColorStringToColor(Config.db_jobtitle[touxian].color)
        touxian = Config.db_jobtitle[touxian].name
        SetOutLineColor(self.touxian_outline, r, g, b, a)
        SetColor(self.nameTouT, 255, 250, 201)
        SetOutLineColor(self.nameTouT_outline, 6, 0, 1, 255)
        self.touxianT.text = touxian
        self.nameTouT.text = role_data.name
    end
end

function TitlePanel:GetIndexByMenu(menuId)
    local list = self.sub_menu[menuId]
    local result = nil
    for i = 1, #list do
        if list[i][1] == self.model.curSub_id then
            result = i
            break
        end
    end
    return result
end

function TitlePanel:LoadRoleModel()
    self:DestroyRoleModel()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local config = {}
    config.trans_offset = {y=18.16}
    config.trans_x = 830
    config.trans_y = 830
    if self.role_model == nil then
        self.role_model = UIRoleCamera(self.model_content, nil, role, 1, nil, nil, config)
        self.role_model:SetDragViewPosition(-8.7, -41)
        self.role_model:SetDragViewSize(492.6, 365.3)
    else
        self.role_model:ReLoadModel(role)
    end

    self.ui_model_rect = GetRectTransform(self.role_model)
    SetAnchoredPosition(self.ui_model_rect, -34, 0)
end

function TitlePanel:CheckTitleShow()
    --开启计时
    self:ClearSchedual()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.CheckTitleOutDate), 0.2, -1)
end

function TitlePanel:CheckIsNeedSelDefault()
    local defo_id = FashionModel.GetInstance().default_sel_id
    defo_id = defo_id or 46000
    local side_index = FashionModel.GetInstance().side_index
    local menu = nil
    if defo_id and side_index == 4 then
        local cf = Config.db_title
        for i, v in pairs(cf) do
            if v.id == defo_id then
                menu = v.type_id
                break
            end
        end
    end
    menu = menu or 1
    GlobalEvent:Brocast(CombineEvent.SelectFstMenuDefault .. self.__cname, menu)
    GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.__cname, defo_id)
    FashionModel.GetInstance().default_sel_id = nil
end

function TitlePanel:HandleLeftSecItemClick(menuId, subId, is_show_red)
    self.model.curSub_id = FashionModel.GetInstance().default_sel_id or subId
    self.menuId = menuId
    self:UpdatePanelShow(is_show_red)
end

function TitlePanel:UpdatePanelShow(is_show_red)
    local defa_id = FashionModel.GetInstance().default_sel_id or self.model.curSub_id
    if defa_id and defa_id >= 46000 then
        self.model.curSub_id = defa_id
    else
        self.model.curSub_id = String2Table(Config.db_title_menu[1].sub_id)[1][1]
    end
    lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, tostring(self.model.curSub_id), false, nil, false)
    local attriList = String2Table(Config.db_title[self.model.curSub_id].attrib)
    self.powerT.text = GetPowerByConfigList(attriList) .. " u"
    self.desT.text = Config.db_item[self.model.curSub_id].guide

    local len = #attriList
    for i = 1, len do
        SetVisible(self.properTitleList[i].transform, true)
        SetVisible(self.proValueList[i].transform, true)
        local atr = attriList[i][1]
        self.properTitleList[i].text = PROP_ENUM[atr].label
        if atr > self.show_percent_after_idx then
            local result = attriList[i][2] / 100
            self.proValueList[i].text = "+" .. result .. "%"
        else
            self.proValueList[i].text = "+" .. attriList[i][2]
        end
    end
    for i = len + 1, #self.properTitleList do
        SetVisible(self.properTitleList[i].transform, false)
        SetVisible(self.proValueList[i].transform, false)
    end
    --
    --for i = 1, #self.properTitleList do
    --    self.properTitleList[i].text = GetAttrNameByIndex(attriList[i][1])
    --    self.proValueList[i].text = "+" .. attriList[i][2]
    --end
    local p_title = self.model:GetPTitleBySunId(self.model.curSub_id)
    if p_title then
        --拥有该称号
        self:ShowPutBtn()
        if self.model.titleInfoList.puton_id == self.model.curSub_id then
            self:SetPutOff()
            SetVisible(self.already_wear, true)
        else
            self:SetPutOn()
            SetVisible(self.already_wear, false)
        end
        if p_title.etime == 0 then
            if self.cdText then
                self.cdText:StopSchedule()
            end
            self.cdT.text = ConfigLanguage.Title.RestTime .. ConfigLanguage.Title.LastingTitle
        else
            --不是永久
            if not self.cdText then
                self.cdText = CountDownText(self.TitleText, { is_auto_hide = true, isShowDay = true, isShowMin = true, isShowHour = true, isChineseType = true, formatTime = "%d", formatText = "Time left: %s" })
            end
            SetVisible(self.countdowntext, true)
            local function call_back()
                --倒计时结束
                self:HidePutBtn()
                if self.cdText then
                    self:StopCountDown()
                end
            end
            self.cdText:StartSechudle(p_title.etime - 1, call_back)
        end
    else
        --为拥有
        SetVisible(self.already_wear, false)
        local num = BagModel.GetInstance():GetItemNumByItemID(self.model.curSub_id)
        if num > 0 then
            self:SetAcitvate()
        else
            self:HidePutBtn()
        end
    end
    if is_show_red ~= nil then
        self:SetRedDot(is_show_red)
        self.red_dot:SetPosition(0, 0)
    end
    GlobalEvent:Brocast(TitleEvent.UpdateTitlePuton, self.model.titleInfoList.puton_id)
end

function TitlePanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    --self.red_dot:SetPosition(105, 24)
    self.red_dot:SetRedDotParam(isShow)
end

function TitlePanel:CheckTitleOutDate()
    if table.nums(self.model.secItemList) > 0 then
        local itemList = {}
        for i, v in pairs(self.model.secItemList) do
            if v then
                if v.p_title.etime - os.time() <= 0 then
                    v:SelectPutOn(0)
                    --设置灰色
                    ShaderManager.GetInstance():SetImageGray(v.img)
                    table.insert(itemList, v)
                end
            end
        end
        if not table.isempty(itemList) then
            for i, v in pairs(itemList) do
                if v.data[1] == self.model.titleInfoList.puton_id then
                    self.model.titleInfoList.puton_id = 0
                end
                table.removebykey(self.model.titleInfoList.titles, v.data[1])
                table.removebyvalue(self.model.secItemList, v)
                table.removebyvalue(itemList, v)
            end
            self:DestroyLeftMenu()
            self:InitPanel(true)
        end
    end
end

function TitlePanel:SetPutOn()
    self.model.curBtnMode = 1
    self.putT.text = ConfigLanguage.Title.PutOnTitle
end

function TitlePanel:SetPutOff()
    self.model.curBtnMode = 2
    self.putT.text = ConfigLanguage.Title.PutOffTitle
end

function TitlePanel:ShowPutBtn()
    SetVisible(self.btn_puton, true)
    SetVisible(self.remainBg, true)
    SetVisible(self.hadntGet, false)
end

function TitlePanel:HidePutBtn()
    SetVisible(self.btn_puton, false)
    SetVisible(self.remainBg, false)
    SetVisible(self.hadntGet, true)
end

function TitlePanel:SetAcitvate()
    self.model.curBtnMode = 3
    SetVisible(self.btn_puton, true)
    SetVisible(self.remainBg, false)
    SetVisible(self.hadntGet, false)
    self.putT.text = ConfigLanguage.Title.ActivateTitle
end

function TitlePanel:ClearSchedual()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = nil

end

function TitlePanel:DestroyLeftMenu()
    if self.leftMenu then
        self.leftMenu:destroy()
    end
    --self.menuTran = nil
    self.leftMenu = nil
end

function TitlePanel:StopCountDown()
    self.cdText:StopSchedule()
    SetVisible(self.remainBg, false)
    SetVisible(self.hadntGet, true)
end

function TitlePanel:DestroyRoleModel()
    if self.role_model ~= nil then
        self.role_model:destroy()
        self.role_model = nil
    end
end