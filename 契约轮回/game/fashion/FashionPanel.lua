-- @Author: lwj
-- @Date:   2018-12-26 15:32:17
-- @Last Modified time: 2019-10-11 16:32:56

FashionPanel = FashionPanel or class("FashionPanel", WindowPanel)
local FashionPanel = FashionPanel

function FashionPanel:ctor()
    self.abName = "fashion"
    self.assetName = "FashionPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.model = FashionModel.GetInstance()
    self.show_sidebar = true        --是否顯示側邊欄
    if self.show_sidebar then
        -- 側邊欄配置
        self.sidebar_data = {
            { text = ConfigLanguage.Fashion.Clothe, id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
            { text = ConfigLanguage.Fashion.Head, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
            { text = ConfigLanguage.Fashion.Weapon, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
            { text = ConfigLanguage.Fashion.Title, id = 4, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
            { text = ConfigLanguage.Fashion.Magic, id = 5, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
        }
    end

    self.itemList = {}
    self.needIconList = {}
    self.role_model = nil
    self.proItemList = {}
    self.rightIcon = nil
    self.ori_weapon = nil
    self.single_item_height = 81
    self.left_offset = 24

    self.modelEventList = {}
    self.global_event = {}
    self.is_loading_model = false

    self.maxStar = 5
end

function FashionPanel:dctor()
end

function FashionPanel:Open()
    WindowPanel.Open(self)
    if self.model.side_index then
        self.default_table_index = self.model.side_index
    end
end

function FashionPanel:LoadCallBack()
    self.nodes = {
        "leftContain", "middleContain/havent_own",
        "leftContain/leftScroll/Viewport/letContent",
        "middleContain/sceneImg/model_con",
        "middleContain/title/name","normalContain",
        "normalContain/starContain/star_3", "normalContain/starContain/star_5", "normalContain/starContain/star_4", "normalContain/starContain/star_2", "normalContain/starContain/star_1",
        "normalContain/starContain",
        "normalContain/btn_change", "middleContain/sceneImg/eft_con",
        "rightContain/powerText",
        "normalContain/propertyContain",
        "normalContain/btn_upStar/Text", "normalContain/btn_upStar", "normalContain/icon", "normalContain/costNum",
        "normalContain/haveMaxLevel", "rightContain/attr_con/bottomDes",
        --"middleContain/dragview",
        "rightContain/attr_con", "rightContain/wayText",
        "middleContain/right_rotate", "middleContain/left_rotate", "middleContain", "normalContain/already_wear",
    }
    self:GetChildren(self.nodes)
    self.nameT = self.name:GetComponent('Text')
    self.powerT = self.powerText:GetComponent('Text')
    self.rightBtnT = self.Text:GetComponent('Text')
    self.wayT = self.wayText:GetComponent('Text')
    self.costT = self.costNum:GetComponent('Text')
    self.bottomT = GetText(self.bottomDes)
    self.left_con_rect = GetRectTransform(self.letContent)
    self.left_con_layoutGroup = GetGridLayoutGroup(self.letContent)
    SetRotation(self.eft_con.transform, 17.35, 0, 0)
    SetLocalPosition(self.eft_con.transform, 13, -190, 0)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con.transform, nil, true, nil, 1, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.havent_own.transform, nil, true, nil, 1, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_rotate.transform, nil, true, nil, 1, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.right_rotate.transform, nil, true, nil, 1, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.already_wear.transform, nil, true, nil, 1, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.btn_change.transform, nil, true, nil, 1, 3)


    self:SetSidebarLast()

    self:AddStars()
    --self:LoadRoleModel()
    self:AddEvent()
end

function FashionPanel:AddStars()
    self.starList = {}
    table.insert(self.starList, self.star_1)
    table.insert(self.starList, self.star_2)
    table.insert(self.starList, self.star_3)
    table.insert(self.starList, self.star_4)
    table.insert(self.starList, self.star_5)
end

local lastX = 0
function FashionPanel:AddEvent()
    --local call_back = function(target, x, y)
    --    if lastX == 0 then
    --        lastX = x;
    --        return ;
    --    end
    --    local x1 = x - lastX;
    --    self.role_model.transform:Rotate(0, -x1, 0);
    --    lastX = x;
    --end
    --AddDragEvent(self.dragview.gameObject, call_back);

    --local call_back = function(target, x, y)
    --    lastX = 0;
    --end
    --AddDragEndEvent(self.dragview.gameObject, call_back);

    local function call_back()
        self.role_model:SetModelRotationY(30);
    end
    AddButtonEvent(self.right_rotate.gameObject, call_back)

    local function call_back()
        self.role_model:SetModelRotationY(-30);
    end
    AddButtonEvent(self.left_rotate.gameObject, call_back)

    local function call_back()
        local mode = self.model:GetNormalBtnMode()
        local haveNum = BagModel.GetInstance():GetItemNumByItemID(self.model.curItemId)
        if mode == 0 then
            --激活
            local cost = String2Table(Config.db_fashion[self.model.curItemId .. "@" .. self.model.curMenu].cost)[2]
            if not cost then
                logError("FashionPanel,line:128,沒有所需的cost！當前選中的id是：", self.model.curItemId)
                return
            end
            if haveNum < cost then
                Notify.ShowText(ConfigLanguage.Fashion.MaterialNotEnouth)
            else
                self.model:Brocast(FashionEvent.ActivateFashion)
            end
        elseif mode == 1 then
            --升星
            local cost = String2Table(Config.db_fashion_star[self.model.curItemId .. "@" .. self.model.curItemStar].cost)[2]
            if not cost then
                logError("FashionPanel,line:140,沒有所需的cost！當前選中的id是：", self.model.curItemId)
                return
            end
            if type(cost) == "table" then
                --兩個以上的消耗材料
                local isCanUp = true
                local tbl = String2Table(Config.db_fashion_star[self.model.curItemId .. "@" .. self.model.curItemStar].cost)
                for i = 1, #tbl do
                    haveNum = BagModel.GetInstance():GetItemNumByItemID(tbl[i][1])
                    if tbl[i][2] > haveNum then
                        isCanUp = false
                        break
                    end
                end
                if isCanUp then
                    self.model:Brocast(FashionEvent.UpStarFashion)
                else
                    Notify.ShowText(ConfigLanguage.Fashion.MaterialNotEnouth)
                end
            else
                if haveNum < cost then
                    Notify.ShowText(ConfigLanguage.Fashion.MaterialNotEnouth)
                else
                    self.model:Brocast(FashionEvent.UpStarFashion)
                end
            end
        end


        --elseif mode == 2 then
        --self.model:Brocast(FashionEvent.ResolveFashion)
        self.model.isCanShowTips = true
    end
    AddButtonEvent(self.btn_upStar.gameObject, call_back)

    local function call_back()
        self.model:SetNormalBtnMode(3)
        self.model:Brocast(FashionEvent.PutOnFashion)
        self.model.isCanShowTips = true
    end
    AddButtonEvent(self.btn_change.gameObject, call_back)

    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.FashionItemClick, handler(self, self.HandleItemClick))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.UpdatePanel, handler(self, self.HandleUpdatePanel))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.ChangePanelRedDot, handler(self, self.SetRedDot))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.CloseFashionPanel, handler(self, self.Close))

    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(FashionEvent.ChangeSideRedDot, handler(self, self.ChangeSideRedDotState))
end

function FashionPanel:ChangeSideRedDotState(is_show, is_title)
    local index = self.model.title_index
    if not is_title then
        index = self.model.curMenu
    end
    self:SetIndexRedDotParam(index, is_show)
end

function FashionPanel:HandleOpenTitleBaPanel()
    if not self.title_panel then
        self.title_panel = TitlePanel(self.child_transform, "UI")
    end
    self:PopUpChild(self.title_panel)
end

function FashionPanel:OpenCallBack()
    self.model.is_openning_fashion_panel = true
    if TitleModel.GetInstance().is_show_title_red then
        self:SetIndexRedDotParam(self.model.title_index, true)
    end
    if self.model.isShowRedInMain then
        for i = 1, table.nums(Config.db_fashion_type) do
            if self.model:CheckIsShowSideRedDot(i) then
                self:SetIndexRedDotParam(i, true)
            end
        end
    end
end

function FashionPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    --稱號
    if index == self.model.title_index then
        self:SetTileTextImage("fashion_image", "title_title_img")
        SetVisible(self.leftContain, false)
        SetVisible(self.middleContain, false)
        SetVisible(self.normalContain, false)
        GlobalEvent:Brocast(TitleEvent.OpenTitlePanel)
        self:HandleOpenTitleBaPanel()
        return
    end
    --時裝
    self:SetTileTextImage("fashion_image", "FashionPanel_TitleImg")
    SetVisible(self.leftContain, true)
    SetVisible(self.middleContain, true)
    SetVisible(self.normalContain, true)
    if self.title_panel then
        SetVisible(self.title_panel, false)
    end
    self.model.curMenu = index
    self.model:GetCurInfoList()
    self:LoadLeftItem(index)
    self.model:Brocast(FashionEvent.UpdatePuttOn)

    --if not table.isempty(self.itemList) then
    --    if self.model.side_index and self.model.side_index ~= 4 then
    --        if self.model.side_index == index then
    --            for i = 1, #self.itemList do
    --                if self.itemList[i].data.conData.id == self.model.default_sel_id then
    --                    self.itemList[i]:SetDefault()
    --                    self.model.default_sel_id = nil
    --                    self.model.side_index = nil
    --                    break
    --                end
    --            end
    --        end
    --    else
    --        self.itemList[1]:SetDefault()
    --    end
    --end
end

function FashionPanel:HandleUpdatePanel()
    local fItem = self.model:GetFashionItemById(self.model.curItemId)
    local conData = Config.db_fashion[self.model.curItemId .. "@" .. self.model.curMenu]
    if fItem then
        self.model.curItemStar = fItem.star
    end
    self:UpdateMiddle(fItem)
    self:UpdateRight(conData, fItem)
    self:UpdateLeftItem()
    self.model:Brocast(FashionEvent.UpdatePuttOn)
end

function FashionPanel:LoadRoleModel(con_data)
    if self.is_loading_model then
        return
    end
    self.is_loading_model = true
    self.gender = RoleInfoModel.GetInstance():GetSex()
    local gender = self.gender
    --self:DestroyRoleModel()
    local model = nil

    if not table.isempty(self.itemList) then
        if gender == 1 then
            model = con_data.man_model
        else
            model = con_data.girl_model
        end
    end
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local data = {}
    --for i, v in pairs(role) do
    --    data[i] = v
    --end
    data = clone(role)
    local config = {}
    if self.model.curMenu == 1 then
        data.figure['fashion_clothes'] = {}
        data.figure["fashion_clothes"].model = model
        data.figure["fashion_clothes"].show = true
        if not data.figure.fashion_head then
            data.figure.fashion_head = {}
            data.figure.fashion_head.model = role.gender == 2 and 12001 or 11001
            data.figure.fashion_head.show = true
        end
        if not data.figure.weapon then
            data.figure.weapon = {}
            data.figure.weapon.model = role.gender == 2 and 12001 or 11001
            data.figure.weapon.show = true
        end
    elseif self.model.curMenu == 2 then
        data.figure.fashion_head = {}
        data.figure.fashion_head.model = model
        data.figure.fashion_head.show = true
        if not data.figure.weapon then
            data.figure.weapon = {}
            data.figure.weapon.model = role.gender == 2 and 12001 or 11001
            data.figure.weapon.show = true
        end
    elseif self.model.curMenu == 3 then
        --dump(data.figure, "<color=#6ce19b>LoadRoleModel   LoadRoleModel  LoadRoleModel  LoadRoleModel</color>")
        data.figure.weapon = {}
        data.figure.weapon.model = model
        data.figure.weapon.show = true
        if not data.figure.fashion_head then
            data.figure.fashion_head = {}
            data.figure.fashion_head.model = role.gender == 2 and 12001 or 11001
            data.figure.fashion_head.show = true
        end
    end
    if self.model.curMenu == 5 then
        if not self.role_model then
            local role = clone(RoleInfoModel.GetInstance():GetMainRoleData())
            if self.role_model == nil then
                local config = {}
                config.is_show_wing = false
                config.is_show_before_unloaded = true
                config.trans_offset = { y = 18.16 }
                config.trans_x = 830
                config.trans_y = 830
                local function callback()
                    self.is_loading_model = false
                end
                self.role_model = UIRoleCamera(self.model_con, nil, role, 1, nil, nil, config, 500)
                self.role_model:AddLoadCallBack(callback)
            end
        end
        self.is_loading_model = false
        SetVisible(self.eft_con, true)
        if self.eft ~= nil then
            self.eft:destroy()
            self.eft = nil
        end
        self.eft = UIEffect(self.eft_con, model, false, self.layer)
        self.eft:SetConfig({ is_loop = true })
        SetVisible(self.eft.gameObject, true)
    else
        SetVisible(self.eft_con, false)
        config.is_show_wing = false
        config.is_show_before_unloaded = true
        config.trans_offset = { y = 18.16 }
        config.trans_x = 830
        config.trans_y = 830
        local function callback()
            self.is_loading_model = false
        end
        if not self.role_model then
            self.role_model = UIRoleCamera(self.model_con, nil, data, 1, nil, nil, config, 500)
        else
            self.role_model:ReLoadModel(data)
        end
        self.role_model:AddLoadCallBack(callback)
    end
end

function FashionPanel:HandleItemClick(conData, fashionItem, is_show_red, is_from_defa_sel)
    if fashionItem then
        self.model.curItemStar = fashionItem.star
    end
    self:LoadRoleModel(conData)
    self:UpdateMiddle(fashionItem)
    is_show_red = is_show_red or false
    self:UpdateRight(conData, fashionItem, is_show_red)
    if not is_from_defa_sel then
        return
    end
    self:ChangeContenPos(conData.index)
end

function FashionPanel:LoadLeftItem(index)
    --self:DestroyItems()
    local list = self.model:GetCueShowList(index)
    local dataList = {}
    local itemData = {}
    for i = 1, #list do
        itemData = {}
        if type(list[i]) == "table" then
            itemData.conData = Config.db_fashion[list[i][1] .. "@" .. index]
        else
            itemData.conData = Config.db_fashion[list[i] .. "@" .. index]
        end
        dataList[i] = itemData
    end
    self.itemList = self.itemList or {}
    local len = #dataList
    for i = 1, len do
        local item = self.itemList[i]
        if not item then
            item = FashionItem(self.letContent, 'UI')
            self.itemList[i] = item
            --local x = 0
            --local y = -(i-1) * 150
            --item:SetPosition(x, y)
            --item:SetCallBack(callback)
        else
            item:SetVisible(true)
        end
        dataList[i].is_show_red = self.model:CheckIsShowItemRedDot(index, dataList[i].conData.id)
        dataList[i].conData.index = i
        item:SetData(dataList[i])
    end
    for i = len + 1, #self.itemList do
        local item = self.itemList[i]
        item:SetVisible(false)
    end
end

function FashionPanel:UpdateLeftItem()
    for i, v in pairs(self.itemList) do
        if v.data.conData.id == self.model.curItemId then
            v:SetData()
        end
    end
end

function FashionPanel:UpdateMiddle(fItem)
    self.nameT.text = Config.db_item[self.model.curItemId].name
    if fItem then
        --self:ShowMiddleStars()
        for i = 1, #self.starList do
            SetVisible(self.starList[i], i <= fItem.star)
        end
        local cur_put_on = self.model:GetCurMenuPutOnId()
        if cur_put_on and fItem.id == cur_put_on then
            SetVisible(self.btn_change, false)
            SetVisible(self.already_wear, true)
            SetVisible(self.havent_own, false)
        else
            SetVisible(self.btn_change, true)
            SetVisible(self.already_wear, false)
            SetVisible(self.havent_own, false)
        end
    else
        self:HideMiddleStars()
        SetVisible(self.already_wear, false)
        SetVisible(self.havent_own, true)
    end
end

function FashionPanel:UpdateRight(conData, fItem, is_show_red)
    --self:DestroyProItem()
    self:DestroyRightIcon()
    local star = nil
    local next_Star = -1
    local arrtri = nil
    local next_arrtri = nil
    local isMax = false
    local isHideCur = false
    if fItem then
        --已激活
        star = fItem.star
        self.bottomT.text = ConfigLanguage.Fashion.NeedOfUpStar
        self.rightBtnT.text = ConfigLanguage.Fashion.UpStar
        self.model:SetNormalBtnMode(1)
    else
        self.bottomT.text = ConfigLanguage.Fashion.NeedOfActivate
        self.rightBtnT.text = ConfigLanguage.Fashion.ActicateFashion
        self.model:SetNormalBtnMode(0)
        isHideCur = true
        star = 0
    end
    arrtri = String2Table(Config.db_fashion_star[conData.id .. "@" .. star].attrib)
    local cost_tbl = String2Table(Config.db_fashion_star[conData.id .. "@" .. star].cost)
    local star_max = Config.db_fashion_star[conData.id .. "@" .. star].starmax

    if not fItem then
        --未激活 star_max变为0 要不然会导致未激活就显示已满级
        star_max = 0
    end

    if star_max == 0 then
        if table.isempty(cost_tbl) then
            --初始時裝特殊設置
            isHideCur = true
            SetVisible(self.btn_upStar, false)
            SetVisible(self.haveMaxLevel, false)
            SetVisible(self.attr_con, false)
        else
            SetVisible(self.attr_con, true)
            SetVisible(self.btn_upStar, true)
        end
        if fItem then
            next_Star = star + 1
        else
            next_Star = star
        end
        local config = Config.db_fashion_star[conData.id .. "@" .. next_Star]
        if config then
            next_arrtri = String2Table(config.attrib)
            self.powerT.text = GetPowerByConfigList(next_arrtri) .. " u"
            SetVisible(self.haveMaxLevel, false)
            SetVisible(self.btn_upStar, true)
        end
    else
        --拉滿
        isMax = true
        self.powerT.text = GetPowerByConfigList(arrtri)
        SetVisible(self.haveMaxLevel, true)
        self.model:SetNormalBtnMode(2)
        self.rightBtnT.text = ConfigLanguage.Fashion.ResoveFashion
        SetVisible(self.btn_upStar, false)
    end

    local dataList = {}
    local itemData = {}
    for i = 1, #arrtri do
        itemData = {}
        if isHideCur then
            itemData.isHideCur = true
            itemData.upValue = arrtri[i][2]
        else
            itemData.isHideCur = false
            itemData.curStr = arrtri[i][2]
            itemData.isMax = isMax
            if not isMax and next_arrtri then
                itemData.upValue = next_arrtri[i][2]
            end
        end
        itemData.titleStr = GetAttrNameByIndex(arrtri[i][1])
        dataList[i] = itemData
    end

    self.proItemList = self.proItemList or {}
    local len = #dataList
    for i = 1, len do
        local item = self.proItemList[i]
        if not item then
            item = FashionPanelProItem(self.propertyContain, 'UI')
            self.proItemList[i] = item
            --local x = 0
            --local y = -(i-1) * 150
            --item:SetPosition(x, y)
            --item:SetCallBack(callback)
        else
            item:SetVisible(true)
        end
        item:SetData(dataList[i])
    end
    for i = len + 1, #self.proItemList do
        local item = self.proItemList[i]
        item:SetVisible(false)
    end

    self.wayT.text = Config.db_item[conData.id].guide

    if table.isempty(cost_tbl) then
        return
    end
    local next_Star = nil
    if isHideCur then
        next_Star = 0
    else
        next_Star = star + 1
    end
    local mode = self.model:GetNormalBtnMode()
    local cost = nil
    if mode == 0 then
        --激活讀取所需材料
        cost = String2Table(Config.db_fashion[conData.id .. "@" .. self.model.curMenu].cost)
    else
        if isMax then
            next_Star = star
        end
        cost = String2Table(Config.db_fashion_star[conData.id .. "@" .. next_Star].cost)
    end
    local num = 0
    local numStr = ""
    local rightIcon = nil
    self:SetRedDot(is_show_red)
    if table.isempty(cost) then
        return
    end
    if type(cost[1]) == "table" then
        for i = 1, #cost do
            num = BagModel.GetInstance():GetItemNumByItemID(cost[i][1])
            if num < cost[i][2] then
                --不夠
                numStr = "<color=#FF0000>" .. num .. "/" .. cost[i][2] .. "</color>"
            else
                numStr = "<color=#18C114>" .. num .. "/" .. cost[i][2] .. "</color>"
            end
            rightIcon = GoodsIconSettorTwo(self.icon)
            local param = {}
            param["model"] = self.model
            param["item_id"] = cost[i][1]
            param["num"] = numStr
            param["size"] = { x = 84, y = 84 }
            param["can_click"] = true
            rightIcon:SetIcon(param)
            local item_rect = GetRectTransform(rightIcon)
            SetLocalScale(item_rect, 0.9, 0.9)
            --rightIcon:UpdateIconByItemIdClick(cost[i][1], numStr, { x = 84, y = 84 })
            table.insert(self.needIconList, rightIcon)
        end
    else
        num = BagModel.GetInstance():GetItemNumByItemID(conData.id)
        if num < cost[2] then
            --不夠
            numStr = "<color=#FF0000>" .. num .. "/" .. cost[2] .. "</color>"
        else
            numStr = "<color=#ffea00>" .. num .. "/" .. cost[2] .. "</color>"
        end
        rightIcon = GoodsIconSettorTwo(self.icon)
        local param = {}
        param["model"] = self.model
        param["item_id"] = cost[1]
        param["num"] = numStr
        param["size"] = { x = 84, y = 84 }
        param["can_click"] = true
        rightIcon:SetIcon(param)
        local item_rect = GetRectTransform(rightIcon)
        SetLocalScale(item_rect, 0.9, 0.9)
        --rightIcon:UpdateIconByItemIdClick(cost[1], numStr, { x = 84, y = 84 })
        table.insert(self.needIconList, rightIcon)
    end
end

function FashionPanel:ChangeContenPos(idx)
    if idx <= 6 then
        return
    end
    local move_num = idx - 6
    local move_dis = move_num * self.single_item_height - self.left_offset
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.left_con_rect)
    local time = 0.2
    local moveAction = cc.MoveTo(time, 0, move_dis, 0)
    cc.ActionManager:GetInstance():addAction(moveAction, self.left_con_rect)
end

function FashionPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.btn_upStar, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(40, 12)
    self.red_dot:SetRedDotParam(isShow)
end

function FashionPanel:ShowMiddleStars()
    SetVisible(self.starContain, true)
    SetVisible(self.btn_change, true)
end

function FashionPanel:HideMiddleStars()
    SetVisible(self.starContain, false)
    SetVisible(self.btn_change, false)
end

function FashionPanel:DestroyRoleModel()
    if self.role_model ~= nil then
        self.role_model:destroy()
        self.role_model = nil
    end
end

function FashionPanel:DestroyProItem()
    for i, v in pairs(self.proItemList) do
        if v then
            v:destroy()
        end
    end
    self.proItemList = {}
end

function FashionPanel:DestroyItems()
    for i, v in pairs(self.itemList) do
        if v then
            v:destroy()
        end
    end
    self.itemList = {}
end

function FashionPanel:DestroyRightIcon()
    for i, v in pairs(self.needIconList) do
        if v then
            v:destroy()
        end
    end
    self.needIconList = {}
end

function FashionPanel:CloseCallBack()
    destroySingle(self.eft)
    self.eft = nil
    self.model.is_openning_fashion_panel = false
    self.model.default_sel_id = nil
    self.model.side_index = nil
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    if self.title_panel then
        self.title_panel:destroy()
        self.title_panel = nil
    end
    self:DestroyItems()
    self:DestroyProItem()
    self:DestroyRoleModel()
    self:DestroyRightIcon()

    for i, v in pairs(self.modelEventList) do
        self.model:RemoveListener(v)
    end
    self.modelEventList = {}
    self.starList = {}
    self.norTitleList = {}

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

