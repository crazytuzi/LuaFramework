-- @Author: lwj
-- @Date:   2019-01-31 00:25:14
-- @Last Modified by:   win 10
-- @Last Modified time: 2020-01-06 11:34:07

CombinePanel = CombinePanel or class("CombinePanel", WindowPanel)
local CombinePanel = CombinePanel

function CombinePanel:ctor()
    self.abName = "combine"
    self.assetName = "CombinePanel"
    self.layer = "UI"
    self.default_table_index = 1

    self.topWidth = 0
    self.slotHeight = 0

    self.globalEvents = {}
    self.topmenu_list = {}
    self.slotitem_list = {}
    self.lock_list = {}     --有锁的icon
    self.puton_List = {}
    self.fixPoint_List = {}
    self.needicon_List = {}
    self.needicon2uid = {}  --材料项对应选择的材料
    self.alreadyAddList = {}  --已经添加上的材料
    self.gridList = {}        --格子列表
    self.numList = {}             --固定材料数量文本
    self.role_update_list = self.role_update_list or {}

    self.left_menu = nil
    self.cur_itemid = 0     --当前选中的合成装备
    self.selecticon = nil
    self.isOpen = false

    self.panel_type = 2
    self.settledMaterial = nil
    self.targetItem = nil

    self.model = CombineModel:GetInstance()
    self.bagModel = BagModel:GetInstance()

    self.is_jump_in = false             --是否跳转进来的，跳转进来就不选择第一个
    self.rd_show_tog_key = "Is_Show_Combine_Red_Dot"
end

function CombinePanel:dctor()
    if self.left_menu then
        self.left_menu:destroy()
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end

    self:CleanSlotItems()

    if self.targetItem ~= nil then
        self.targetItem:destroy()
    end

    self.bagModel = nil
end

function CombinePanel:Open(side_idx, tog_idx, is_auto, defa_first_id, defa_sec_id)
    self.model:CheckScanListRD()
    local is_auto_set = is_auto == 1 and true or false
    local is_man = RoleInfoModel.GetInstance():GetSex() == 1
    if side_idx then
        self.default_table_index = tonumber(side_idx)
    end
    if tog_idx then
        self.model.default_tog = tonumber(tog_idx)
        self.is_jump_in = true
    else
        if OpenTipModel.GetInstance():IsOpenSystem(170, 2) then
            self.model.default_tog = is_man and 101 or 102
        end
    end
    if is_auto_set == true then
        self.model.default_first_id = defa_first_id or is_man and 20101 or 20201
    else
        if defa_first_id then
            self.is_jump_in = true
            self.model.default_first_id = defa_first_id
        else
            --没有传参
            if not self.is_jump_in then
                self.model.default_first_id = self.model:GetCurLockStair()
            end
        end
    end
    if is_auto_set == true then
        self.model.default_sec_id = defa_sec_id or is_man and 2010105 or 2020105
    elseif defa_sec_id then
        self.model.default_sec_id = defa_sec_id
        self.is_jump_in = true
    end
    self.model.is_auto_judge_gender_tog = is_auto_set
    BasePanel.Open(self)
end

function CombinePanel:LoadCallBack()
    self.nodes = {
        "TopScrollView/Viewport/TopContent",
        "LeftMenu",
        "RightContent/SlotScrollView/Viewport/SlotContent",
        "RightContent",
        "RightCombine",
        "RightCombine/itembg/itemicon",
        "RightCombine/itembg/Success",
        "RightCombine/needitem/needicon1/lock1",
        "RightCombine/needitem/needicon1/fixPoint",
        "RightCombine/needitem/needicon1",
        "RightCombine/needitem/needicon2",
        "RightCombine/needitem/needicon3",
        "RightCombine/needitem/needicon4",
        "RightCombine/needitem/needicon5",
        "RightCombine/needitem/num_3", "RightCombine/needitem/num_2", "RightCombine/needitem/num_1",
        "RightCombine/needitem/needicon2/puton2",
        "RightCombine/needitem/needicon2/fixPoint2",
        "RightCombine/needitem/needicon2/lock2",
        "RightCombine/needitem/needicon3/puton3",
        "RightCombine/needitem/needicon3/lock3",
        "RightCombine/needitem/needicon4/puton4",
        "RightCombine/needitem/needicon4/lock4",
        "RightCombine/needitem/needicon5/puton5",
        "RightCombine/needitem/needicon5/lock5",
        "RightCombine/bottom/quickadd",
        "RightCombine/bottom/combine", "RightCombine/needitem/needicon3/fixPoint3", "RightCombine/needitem/needicon4/fixPoint4", "RightCombine/needitem/needicon5/fixPoint5",
        "RightCombine/itembg/Question",
        "xiaojiejie", "RightCombine/needitem/needicon1/puton1",
        "RightContent/tip",
        "RightContent/right_bg",
        "RightCombine/itembg/name",
        "RightCombine/bottom/littile_tip", "eft_con",

        "RightContent/getequipbg", "RightCombine/getequipbg2", "RightCombine/composetipbtn",
        "RightContent/getequipbg/worldbossbtn1", "RightContent/getequipbg/marketbtn1",
        "RightCombine/getequipbg2/worldbossbtn2", "RightCombine/getequipbg2/marketbtn2",
        "rd_tog",
    }
    self:GetChildren(self.nodes)
    self.item_name = GetText(self.name)
    self.middle_tip = GetText(self.xiaojiejie)
    self.top_tip = GetText(self.tip)
    self.rd_tog = GetToggle(self.rd_tog)
    self.middle_tip_rect = GetRectTransform(self.xiaojiejie)
    SetAnchoredPosition(self.middle_tip_rect, 108.1, -23)

    self.isOpen = true
    self:BindRoleUpdate()
    --self:SwitchCallBack(2)
    self:SetTileTextImage("combine_image", "Combine_Title_Text")

    table.insert(self.lock_list, self.lock5)
    table.insert(self.lock_list, self.lock4)
    table.insert(self.lock_list, self.lock3)
    table.insert(self.lock_list, self.lock2)
    table.insert(self.lock_list, self.lock1)

    table.insert(self.puton_List, self.puton5)
    table.insert(self.puton_List, self.puton4)
    table.insert(self.puton_List, self.puton3)
    table.insert(self.puton_List, self.puton2)
    table.insert(self.puton_List, self.puton1)

    self.fixPoint_List[#self.fixPoint_List + 1] = self.fixPoint5
    self.fixPoint_List[#self.fixPoint_List + 1] = self.fixPoint4
    self.fixPoint_List[#self.fixPoint_List + 1] = self.fixPoint3
    self.fixPoint_List[#self.fixPoint_List + 1] = self.fixPoint2
    self.fixPoint_List[#self.fixPoint_List + 1] = self.fixPoint1

    self.needicon_List[#self.needicon_List + 1] = self.needicon1
    self.needicon_List[#self.needicon_List + 1] = self.needicon2
    self.needicon_List[#self.needicon_List + 1] = self.needicon3
    self.needicon_List[#self.needicon_List + 1] = self.needicon4
    self.needicon_List[#self.needicon_List + 1] = self.needicon5

    self.numList[#self.numList + 1] = self.num_1
    self.numList[#self.numList + 1] = self.num_2
    self.numList[#self.numList + 1] = self.num_3
    self:AddEvent()
    local is_tick = CacheManager.GetInstance():GetBool(self.rd_show_tog_key)
    self.model.is_hide_combine_rd = is_tick
    self.rd_tog.isOn = is_tick
    for i, v in pairs(self.model.side_rd_list) do
        local is_show = v
        if self.model.is_hide_combine_rd and v then
            --红点已开，显示红点
            is_show = false
        end
        self.model:Brocast(CombineEvent.UpdateEquipCombineRD, is_show, i)
    end
end

function CombinePanel:GetGridIdxByGridTrans(trans)
    local tbl = self.needicon_List
    local idx = nil
    for i = 1, #tbl do
        if tbl[i] == trans then
            idx = i
            break
        end
    end
    return idx
end

function CombinePanel:AddEvent()
    local function callback()
        self.model.is_hide_combine_rd = self.rd_tog.isOn
        CacheManager.GetInstance():SetBool(self.rd_show_tog_key, self.rd_tog.isOn)
        GlobalEvent:Brocast(CombineEvent.UpdateRDSwitch, self.rd_tog.isOn)
    end
    AddClickEvent(self.rd_tog.gameObject, callback)

    self.side_rd_update_event_id = self.model:AddListener(CombineEvent.UpdateEquipCombineRD, handler(self, self.UpdateSideRDShow))

    local function callback()
        local eft = UIEffect(self.eft_con, 10119, false, self.layer)
        eft:SetOrderIndex(299)
    end
    self.succes_event_id = self.model:AddListener(CombineEvent.SuccessCombine, callback)

    local function leftfirstmenuclick_call_back(ClickIndex, is_Show)
        if is_Show then
            self:CleanSlotItems()
            self:ResetCombineArea()
            self.model:CleanUsedUids()
            SetVisible(self.RightCombine, false)
            SetVisible(self.RightContent, true)
        else
            SetVisible(self.xiaojiejie, false)
            SetVisible(self.tip, true)
            SetVisible(self.right_bg, true)
            local subtypes = self.model.cur_first_menu_list
            self.model.select_fst_menu_id = subtypes[ClickIndex][1]

            local fourType = Config.db_equip_combine_thr_type[self.model.select_fst_menu_id].four_type
            local fourTypeTbl = String2Table(fourType)
            if self.is_jump_in then
                self.is_jump_in = false
            else
                GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.__cname, fourTypeTbl[1][1])
            end
        end
    end

    local function call_back(menu_id, TypeId)
        self.model.select_sec_menu_id = TypeId
        self:Leftsecondmenuclick_call_back(TypeId)
    end
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, call_back)

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.TopButtonClick, handler(self, self.Topbuttonclick_call_back))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, leftfirstmenuclick_call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.UpdateCombineArea, handler(self, self.AfterFinishCombine))

    function rightslotitemclick_call_back(ItemId)
        self.cur_itemid = ItemId
        self.RightContent.gameObject:SetActive(false)
        self.RightCombine.gameObject:SetActive(true)
        self:ShowRightCombine(ItemId)

        local req_List = String2Table(Config.db_equip_combine[ItemId].reqs_show)[1]
        if req_List then
            self.model.cur_Stairs = req_List[1]
            self.model.cur_Stars = req_List[2]
            self.model.cur_Colors = req_List[3]
        end

        local cfg = Config.db_equip_combine[ItemId]
        self:CheckIsHaveEnoughMat(cfg, true)
        self.item_name.text = cfg.title
    end
    self.rightslotitemclick_event_id = GlobalEvent:AddListener(CombineEvent.RightSlotItemClick, rightslotitemclick_call_back)

    function selectequipitemclick_call_back(Item)
        local trans = self.needicon_List[self.selecticon]
        local param = {}
        local operate_param = {}
        if self.model.curBagType == 101 or self.model.curBagType == BagModel.artifact then
            param["cfg"] = Config.db_equip[Item.id]
        elseif self.model.curBagType == 104 then
            param["cfg"] = Config.db_beast_equip[Item.id]
        elseif self.model.curBagType == 106 then
            param["cfg"] = Config.db_baby_equip[Item.id]
        elseif self.model.curBagType == 108 then
            param["cfg"] = Config.db_god_equip[Item.id]
        elseif self.model.curBagType == 109 then
            param["cfg"] = Config.db_mecha_equip[Item.id]
        elseif self.model.curBagType == 110 then
            param["cfg"] = Config.db_pet_equip[Item.id.."@"..Item.misc.stren_phase]
        elseif self.model.curBagType == 402 then
            param["cfg"] = Config.db_totems_equip[Item.id]
        end
        param["model"] = self.model
        param["p_item_base"] = Item
        param["can_click"] = true
        param["operate_param"] = operate_param
        param['bind'] = 0
        local function call_back()
            self.model:RemoveSpecifiedUid(Item.uid)
            self:PutOffSpecifiedSettor(Item.parent_trans_idx)
            GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        end
        GoodsTipController.Instance:SetTakeOffCB(operate_param, call_back, { Item })

        local goodsItem = GoodsIconSettorTwo(trans)
        goodsItem:SetIcon(param)
        --所选择放入框的transform
        self.alreadyAddList[self.selecticon] = goodsItem
        self.needicon2uid[self.selecticon] = Item.uid
        CombineModel:GetInstance():AddUsedUid(Item.uid, 1)
        self:SetGridState(self.selecticon, 1)
        self:CalcSuccess()
    end
    self.selectequipitemclick_event_id = GlobalEvent:AddListener(CombineEvent.SelectEquipItemClick, selectequipitemclick_call_back)

    for i = 1, #self.needicon_List do
        local g = self.needicon_List[i].gameObject
        --放入装备点击
        local function call_back(target, x, y)
            self.model.cur_grid_index = i
            local cfg = Config.db_equip_combine[self.cur_itemid]
            if not self:CheckIsHaveEnoughMat(cfg) then
                return
            end
            self.selecticon = self:GetGridIdxByGridTrans(target.transform)
            local SelectEquipPanel = lua_panelMgr:GetPanelOrCreate(CombineSelectEquipPanel)
            SelectEquipPanel:SetItemId(self.cur_itemid)
            SelectEquipPanel:Open()
        end
        AddClickEvent(g, call_back)
    end

    --一键添加材料
    local function quickadd_call_back(target, x, y)
        local combinebase = Config.db_equip_combine[self.cur_itemid]
        --检查一下是否有材料可以添加
        if not self:CheckIsStillHave(combinebase) then
            self:ShowNoItemText()
            return
        end
        --获取可以加入的材料列表
        local item_uids = {}
        if self.model.curBagType == 101 then
            item_uids = CombineController:GetInstance():GetAllCombineEquips(String2Table(combinebase.other_cost))
            --item_uids = self.model:GetRankedBagItem()
        elseif self.model.curBagType == 104 then
            local list = BeastModel:GetInstance():GetAllEqipBaseTbl(String2Table(combinebase.other_cost))
            local finalCount = #list
            if #list > 20 then
                finalCount = 20
            end
            for i = 1, finalCount do
                item_uids[#item_uids + 1] = list[i]
            end
        elseif self.model.curBagType == 108 or self.model.curBagType == 106 or self.model.curBagType == 109 or self.model.curBagType == BagModel.artifact then
            local list = String2Table(combinebase.other_cost)
            for _, itemId in pairs(list) do
                local equips = {}
                if self.model.curBagType == 108 then
                    equips = BagModel:GetInstance().godItems
                elseif self.model.curBagType == 109 then
                    equips = BagModel:GetInstance().mechaItems
                elseif self.model.curBagType == 106 then
                    equips = BagModel:GetInstance().babyItems
                elseif self.model.curBagType == BagModel.artifact then
                    equips = BagModel:GetInstance().artifactItems
                end
                for _, v in pairs(equips) do
                    if itemId == v.id then
                        if not self.model:IsUidUsed(v.uid) and #item_uids < 20 then
                            item_uids[#item_uids + 1] = v
                        end
                    end
                end
            end
        else
            item_uids = CombineModel:GetInstance():CheckAddItems(self.model.curBagType,String2Table(combinebase.other_cost))
        end
        local itemNums = #item_uids
        --可以放入材料的格子的剩余数
        local remainNumber = 0
        local finalAddNum = 0
        local max_num = combinebase.max_num
        local curNum = self:GetNeedIcon2UidListLength()
        remainNumber = max_num - curNum
        if itemNums >= remainNumber then
            finalAddNum = remainNumber
        else
            finalAddNum = itemNums
        end
        for i = 1, finalAddNum do
            local fixPoint_Idx = self:GetOpenGrid()
            if not fixPoint_Idx then
                break
            end
            if not self.needicon2uid[fixPoint_Idx] then
                local uid = item_uids[i].uid
                local item = nil
                local param = {}
                local operate_param = {}
                if self.model.curBagType == 101 or self.model.curBagType == BagModel.artifact then
                    param["cfg"] = Config.db_equip[item_uids[i].id]
                elseif self.model.curBagType == 104 then
                    param["cfg"] = Config.db_beast_equip[item_uids[i].id]
                elseif self.model.curBagType == 106 then
                    param["cfg"] = Config.db_baby_equip[item_uids[i].id]
                elseif self.model.curBagType == 108 then
                    param["cfg"] = Config.db_god_equip[item_uids[i].id]
                elseif self.model.curBagType == 109 then
                    param["cfg"] = Config.db_mecha_equip[item_uids[i].id]
                elseif self.model.curBagType == 110 then
                    param["cfg"] = Config.db_pet_equip[item_uids[i].id .. "@1"]
                elseif  self.model.curBagType == 402  then
                    param["cfg"] = Config.db_totems_equip[item_uids[i].id]
                end
                param["model"] = self.model
                param["p_item_base"] = item_uids[i]
                param["can_click"] = true
                param["operate_param"] = operate_param
                param['bind'] = 0
                local function callback()
                    self.model:RemoveSpecifiedUid(uid)
                    self:PutOffSpecifiedSettor(fixPoint_Idx)
                    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
                end
                GoodsTipController.Instance:SetTakeOffCB(operate_param, callback, { item_uids[i] })
                item = GoodsIconSettorTwo(self.needicon_List[fixPoint_Idx])
                item:SetIcon(param)
                self.alreadyAddList[fixPoint_Idx] = item
                self.needicon2uid[fixPoint_Idx] = uid
                CombineModel:GetInstance():AddUsedUid(uid, 1)
                self:SetGridState(fixPoint_Idx, 1)
            end
        end
        self:CalcSuccess()
    end
    AddClickEvent(self.quickadd.gameObject, quickadd_call_back)

    --合成
    local function combine_call_back(target, x, y)
        if self:CombineBtnTips() then
            CombineController:GetInstance():RequestCombine(self.cur_itemid)
        end
    end
    AddClickEvent(self.combine.gameObject, combine_call_back)

    --问号帮助按钮
    local function call_back(target, x, y)
        ShowHelpTip(string.format(HelpConfig.Equip.Combine, self.model.help_color_text))
    end
    AddClickEvent(self.Question.gameObject, call_back)

    local function call_back(target, x, y)
        OpenLink(160, 1, 1, true)
    end
    AddButtonEvent(self.worldbossbtn1.gameObject, call_back)
    AddButtonEvent(self.worldbossbtn2.gameObject, call_back)

    local function call_back(target, x, y)
        OpenLink(250, 1, 1, true)
    end
    AddButtonEvent(self.marketbtn1.gameObject, call_back)
    AddButtonEvent(self.marketbtn2.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(ComposeEquipTipPanel):Open()
    end
    AddButtonEvent(self.composetipbtn.gameObject, call_back)
end

function CombinePanel:UpdateSideRDShow(is_show, idx)
    self:SetIndexRedDotParam(idx, is_show)
end

function CombinePanel:BindRoleUpdate(data)
    local function call_back()
        local SecTypeId = self.model.cur_Select_TypeSetId
        self:Leftsecondmenuclick_call_back(SecTypeId)
        self:SwitchCallBack(2)
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", call_back)
end

function CombinePanel:CheckIsHaveEnoughMat(cfg, isOnlyGetCondition)
    local isEnough = true
    if cfg == nil then
        return
    end
    --不固定材料拥有数量
    local HaveCount = 0
    local isStillHave = true
    isStillHave, HaveCount = self:CheckIsStillHave(cfg)
    if isOnlyGetCondition then
        isStillHave = false
        HaveCount = 0
    end
    --如果已经没有可以加入的装备
    if not isStillHave then
        --拥有的少于需要的
        if HaveCount < cfg.min_num then
            local costTbl = String2Table(cfg.cost)
            local numTbl = nil
            --如果该物品需要固定材料
            if costTbl[1] ~= nil then
                --固定材料 的拥有数量
                local need_puton = self.model:NeedPutOnItem(cfg.id)
                numTbl = self.model:GetItemNumByTbl(costTbl, need_puton)
                self:MakeTips(numTbl, cfg, false, isOnlyGetCondition)
            else
                self:MakeTips(nil, cfg, false, isOnlyGetCondition)
            end
        else
            --拥有的足够
            if not isOnlyGetCondition then
                self:ShowNoItemText()
            end
        end
        isEnough = false
    end
    return isEnough
end

function CombinePanel:MakeTips(numTbl, cfg, isAtCombineBtn, isOnlyGetCondition)
    local tips = ""
    local regularName = ""
    local lessNum = 0
    local costTbl = String2Table(cfg.cost)
    local materialNum = self.model:GetMaterialNum(cfg, 2)
    local finalCompareNum = 0
    local putOnNum = 0
    if numTbl ~= nil then
        local isEnough = true
        local lackTbl = {}
        for i = 1, #numTbl do
            if numTbl[i] < costTbl[i][2] then
                lackTbl[#lackTbl + 1] = costTbl[i][2] - numTbl[i]
                isEnough = false
            else
                lackTbl[#lackTbl + 1] = 0
            end
        end
        if not isEnough then
            for i = 1, #lackTbl do
                if lackTbl[i] ~= 0 then
                    local equipCfg = Config.db_item[costTbl[i][1]]
                    local colorName = CombineColor_List[equipCfg.color]
                    local finalColor = string.format("<color=#%s>%s</color>", self.model:CheckTypeNameColor(colorName), equipCfg.name)
                    regularName = regularName .. lackTbl[i] .. "X" .. finalColor
                end
            end
        end
    end
    if isAtCombineBtn then
        putOnNum = self:GetNeedIcon2UidListLength()
        finalCompareNum = putOnNum
    else
        finalCompareNum = materialNum
    end
    lessNum = cfg.min_num - finalCompareNum
    if lessNum <= 0 and lessNum and not isOnlyGetCondition then
        tips = string.format(ConfigLanguage.Equip.CombineEquipNotEnough1, regularName)
    else
        if regularName ~= "" then
            regularName = regularName .. ","
        end
        local stairsName = ""
        local starsName = ""
        local bag_type = self.model.curBagType
        if bag_type == 101 or bag_type == BagModel.artifact then
            --只有背包才有
            stairsName = CombineStair_List[self.model.cur_Stairs]
        end
        if bag_type ~= 108 and bag_type ~= 109 and bag_type ~= 106 then
            --除外
            starsName = CombineStars_List[self.model.cur_Stars] or ""
        end
        local colorsName = CombineColor_List[self.model.cur_Colors]
        local stairsAfter = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep), stairsName)
        local starsAfter = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep), starsName)
        local colorsAfter = string.format("<color=#%s>%s</color>", self.model:CheckTypeNameColor(colorsName), colorsName)
        if isOnlyGetCondition then
            local min = cfg.min_num
            local max = cfg.max_num
            local other_cost_num = ""
            if min ~= max then
                other_cost_num = min .. "~" .. max
            else
                other_cost_num = min
            end
            if regularName ~= "" then
                regularName = regularName .. "and"
            end
            self.model.help_color_text = regularName .. "" .. other_cost_num .. "X" .. stairsAfter .. starsAfter .. colorsAfter
        else
            tips = string.format(ConfigLanguage.Equip.CombineEquipNotEnough2, regularName, lessNum, stairsAfter .. starsAfter .. colorsAfter)
        end
    end
    if not isOnlyGetCondition then
        Notify.ShowText(tips)
    end
end

function CombinePanel:CheckIsStillHave(cfg)
    local hasCount = self.model:GetMaterialNum(cfg, 2)
    local putOnCount = self:GetNeedIcon2UidListLength()
    if hasCount - putOnCount == 0 then
        return false, hasCount
    else
        return true, hasCount
    end
end

function CombinePanel:CombineBtnTips()
    local count = 0
    for i, v in pairs(self.alreadyAddList) do
        if v ~= nil then
            count = count + 1
        end
    end
    local cfg = Config.db_equip_combine[self.cur_itemid]
    local needCount = cfg.min_num
    --不固定材料剩余需要的数量
    local finalNum = needCount - count
    local costTbl = String2Table(cfg.cost)
    local numTbl = {}
    local isEnough = true
    local need_puton = self.model:NeedPutOnItem(self.cur_itemid)
    if costTbl[1] ~= nil then
        numTbl = self.model:GetItemNumByTbl(costTbl, need_puton)
        for i = 1, #numTbl do
            if numTbl[i] < costTbl[i][2] then
                isEnough = false
                break
            end
        end
    end
    if finalNum > 0 then
        --不固定材料不够
        self:MakeTips(numTbl, cfg, true)
        return false
    else
        if costTbl[1] ~= nil then
            if not isEnough then
                self:MakeTips(numTbl, cfg, true)
                return false
            end
        end
    end
    return true
end

function CombinePanel:ShowNoItemText()
    local tips = string.format(ConfigLanguage.Equip.CombineEquipNotEnough3)
    Notify.ShowText(tips)
end

function CombinePanel:OpenCallBack()
    self:UpdateView()
    local is_show = self.model.is_show_combine_rd
    if is_show and self.model.is_hide_combine_rd then
        is_show = false
    end
    for i, v in pairs(self.model.side_rd_list) do
        local is_show = v
        if self.model.is_hide_combine_rd and v then
            --红点已开，显示红点
            is_show = false
        end
        self:UpdateSideRDShow(is_show, i)
    end
end

function CombinePanel:UpdateView()

end

function CombinePanel:CleanSlotItems()
    for _, slotitem in pairs(self.slotitem_list) do
        slotitem:destroy()
    end
    self.slotitem_list = {}
    if self.isSetBg then
        SetVisible(self.xiaojiejie, true)
        SetVisible(self.tip, false)
        SetVisible(self.right_bg, false)
    end
    self.isSetBg = true
end

function CombinePanel:CloseCallBack()
    if not table.isempty(self.topmenu_list) then
        for i, v in pairs(self.topmenu_list) do
            v:destroy()
        end
    end
    if self.side_rd_update_event_id then
        self.model:RemoveListener(self.side_rd_update_event_id)
        self.side_rd_update_event_id = nil
    end
    if self.puton_List then
        self.puton_List = nil
    end
    if self.numList then
        self.numList = nil
    end
    if self.fixPoint_List then
        self.fixPoint_List = nil
    end
    if self.needicon_List then
        self.needicon_List = nil
    end
    if self.succes_event_id then
        self.model:RemoveListener(self.succes_event_id)
        self.succes_event_id = nil
    end
    self:CleanSlotItems()
    self.lock_list = {}
    self.needicon2uid = {}  --材料项对应选择的材料
    CombineModel:GetInstance():CleanUsedUids()
    if self.topbuttonclick_event_id then
        GlobalEvent:RemoveListener(self.topbuttonclick_event_id)
        self.topbuttonclick_event_id = nil
    end

    if self.rightslotitemclick_event_id then
        GlobalEvent:RemoveListener(self.rightslotitemclick_event_id)
        self.rightslotitemclick_event_id = nil
    end

    if self.selectequipitemclick_event_id then
        GlobalEvent:RemoveListener(self.selectequipitemclick_event_id)
        self.selectequipitemclick_event_id = nil
    end

    if not table.isempty(self.role_update_list) then
        for _, event_id in pairs(self.role_update_list) do
            RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    self:ResetCombineArea()
    self.isOpen = false
    self:CheckSettledExist()
end

function CombinePanel:ChangeHelpIconShow(flag)
    SetVisible(self.Question, flag)
    SetVisible(self.littile_tip, flag)
    SetVisible(self.getequipbg, flag)
    SetVisible(self.getequipbg2, flag)
    SetVisible(self.composetipbtn, flag)
end

function CombinePanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    --道具

    if index == 2 then
        self.middle_tip.text = ConfigLanguage.Combine.MiddleItenTip
        self.top_tip.text = ConfigLanguage.Combine.ItemTopTip
        self:ChangeHelpIconShow(false)
    elseif index == 3 then
        self.middle_tip.text = ConfigLanguage.Combine.MiddleSoulTip
        -- self.top_tip.text = ConfigLanguage.Combine.SoulTopTip
        self.top_tip.text = ConfigLanguage.Combine.ItemTopTip
        self:ChangeHelpIconShow(false)
    elseif index == 4 then
        self.middle_tip.text = ConfigLanguage.Combine.MiddleMagicTip
        self.top_tip.text = ConfigLanguage.Combine.MagicTopTip
        self:ChangeHelpIconShow(false)
    end
    local canShowList = {}
    local combinetype = Config.db_equip_combine_type[tonumber(index)]
    local subtypes = String2Table(combinetype.sec_type)
    local intera = table.pairsByKey(Config.db_equip_combine_sec_type)
    for i, v in intera do
        if v.open_level <= RoleInfoModel.GetInstance():GetMainRoleData().level then
            for ii, vv in ipairs(subtypes) do
                if vv[1] == v.id then
                    table.insert(canShowList, vv)
                end
            end
        end
    end
    if not table.isempty(self.topmenu_list) then
        for _, topmenuitem in pairs(self.topmenu_list) do
            if topmenuitem then
                topmenuitem:destroy()
                topmenuitem = nil
            end
        end
    end
    self.topmenu_list = {}
    self.topWidth = 0
    local count = #canShowList
    for i = 1, count do
        local item = canShowList[i]

        if i == 1 then
            if self.model.is_auto_judge_gender_tog then
                self.model.select_type_id = RoleInfoModel.GetInstance():GetSex() == 1 and 201 or 202
                self.model.is_auto_judge_gender_tog = false
            else
                self.model.select_type_id = self.model.default_tog or item[1]
            end
        end

        local topbutton = CombineTopButtonItem(self.TopContent, "UI")
        topbutton:SetData(item)
        self.topWidth = self.topWidth + topbutton:getWidth()
        table.insert(self.topmenu_list, topbutton)
    end
    self:RelayoutTop()
    --end
    self:Topbuttonclick_call_back(self.model.select_type_id)

end

function CombinePanel:Topbuttonclick_call_back(SecTypeId)
    local subtypes = String2Table(Config.db_equip_combine_sec_type[SecTypeId].thr_type)
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = FoldMenu(self.LeftMenu, nil, self, nil, nil, true)
    self.left_menu:SetStickXAxis(8.5)
    self.left_menu:SetScrollSize(261, 474)
    self.left_menu:SetViewSize(261, 464)
    --self.model.select_type_id = SecTypeId

    local count = #subtypes
    local firstdata = {}
    local subdata = {}
    for i = 1, count do
        local item = subtypes[i]
        if Config.db_equip_combine_thr_type[item[1]] ~= nil then
            local four_types = String2Table(Config.db_equip_combine_thr_type[item[1]].four_type)
            local sub_item = {}
            for j = 1, #four_types do
                local four_type = four_types[j]
                local combine_set = Config.db_equip_combine_type_set[four_type[1]]
                if combine_set then
                    if RoleInfoModel.GetInstance():GetMainRoleData().level >= combine_set.open_level then
                        table.insert(sub_item, four_type)
                    end
                else
                    logError("在db_equip_combine_type_set配置中没有" .. four_type[1] .. ":" .. four_type[2])
                end

            end
            if #sub_item > 0 then
                table.insert(firstdata, item)
                subdata[item[1]] = sub_item
            end
        end
    end
    self.model.cur_first_menu_list = firstdata
    self.left_menu:SetData(firstdata, subdata)
    self:UpdateTopSelect(SecTypeId)
    self:CleanSlotItems()
    self:ResetCombineArea()
    self.model:CleanUsedUids()
    SetVisible(self.RightCombine, false)
    SetVisible(self.RightContent, true)

    --装备
    if self.switch_index == 1 then
        self.top_tip.text = ConfigLanguage.Combine.EquipTopTip
        self.middle_tip.text = ConfigLanguage.Combine.SelectNorEquip
        self:ChangeHelpIconShow(true)
    end
    if not self.is_jump_in then
        if SecTypeId == 101 or SecTypeId == 102 then
            local stair = self.model:GetCurLockStair(SecTypeId)
            local name = self.model:GetStairName(stair, SecTypeId)
            self.model.default_first_id = stair
            self.middle_tip.text = string.format(ConfigLanguage.Combine.SelectEquip, name)
            self.model.cur_top_id = SecTypeId
        end
    end
    self:DelaySelectFirstMenuDefault()
end

--点击二级菜单的回调
function CombinePanel:Leftsecondmenuclick_call_back(TypeId)
    self.model.cur_Select_TypeSetId = TypeId
    local item_ids = String2Table(Config.db_equip_combine_type_set[TypeId].item_ids)
    if table.nums(item_ids) == 1 then
        --只有一个合成项 直接显示合成界面
        self.RightContent.gameObject:SetActive(false)
        self.RightCombine.gameObject:SetActive(true)
        self.model.curBagType = Config.db_item[String2Table(Config.db_equip_combine[item_ids[1]].gain)[1][1]].bag
        self.cur_itemid = item_ids[1]
        self:ShowRightCombine(item_ids[1])
        self:ResetCombineArea()
        self.model:CleanUsedUids()
        return
    end

    self.RightContent.gameObject:SetActive(true)
    self.RightCombine.gameObject:SetActive(false)

    self.slotitem_list = self.slotitem_list or {}
    local len = #item_ids
    for i = 1, len do
        local item = self.slotitem_list[i]
        if not item then
            item = CombineSlotItem(self.SlotContent, 'UI')
            self.slotitem_list[i] = item
            self:CheackChangeLine(i, item)
        else
            item:SetVisible(true)
        end
        item:SetData(item_ids[i], i)
    end
    for i = len + 1, #self.slotitem_list do
        local item = self.slotitem_list[i]
        item:SetVisible(false)
    end

    self:RelayoutSlot()
    self:ResetCombineArea()
    self.model:CleanUsedUids()
end

function CombinePanel:CheackChangeLine(i, Item)
    if (i - 1) % 3 == 0 then
        self.slotHeight = self.slotHeight + Item:GetHeight()
    end
end

function CombinePanel:RelayoutTop()
    self.TopContent.sizeDelta = Vector2(self.topWidth, 70)
end

function CombinePanel:RelayoutSlot()
    self.SlotContent.sizeDelta = Vector2(self.SlotContent.sizeDelta.x, self.slotHeight)
end


--显示右侧合并道具界面
function CombinePanel:ShowRightCombine(ItemId)
    self:CheckTargetItem()
    local param = {}
    local operate_param = {}
    local id = String2Table(Config.db_equip_combine[ItemId].gain)[1][1]
    --if self.model.curBagType == 101 then
    --    param["cfg"] = Config.db_item[id]
    --elseif self.model.curBagType == 104 then
    --    param["cfg"] = Config.db_beast_equip[id]
    --elseif self.model.curBagType == 108 then
    --    param["cfg"] = Config.db_god_equip[id]
    --end
    param.item_id = id
    param["can_click"] = true
    param["size"] = { x = 94, y = 94 }
    param["operate_param"] = operate_param
    param["bind"] = 0

    local item_cfg = Config.db_item[id]
    if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        param["cfg"] = Config.db_pet_equip[id.."@"..1]
    end

    local goodsItem = GoodsIconSettorTwo(self.itemicon)
    goodsItem:SetIcon(param)
    self.targetItem = goodsItem
    self:HideNumList()
    local combinebase = self:UpdateSettledIcon(ItemId)
    for _, lock_item in pairs(self.lock_list) do
        lock_item.gameObject:SetActive(false)
    end
    for i, v in ipairs(self.puton_List) do
        v.gameObject:SetActive(true)
    end
    for i, v in ipairs(self.fixPoint_List) do
        v.gameObject:SetActive(true)
    end
    --多出的格子数量
    local remain = 5
    local num = combinebase.max_num
    remain = remain - num
    local cost_num = #String2Table(combinebase.cost)
    remain = remain - cost_num
    for i = 1, remain do
        self.puton_List[i].gameObject:SetActive(false)
        self.lock_list[i].gameObject:SetActive(true)
        self.fixPoint_List[i].gameObject:SetActive(false)
        self:SetGridState(i + combinebase.max_num + cost_num, 1)
    end
    self:CalcSuccess()
end

--计算成功率
function CombinePanel:CalcSuccess()
    local combinebase = Config.db_equip_combine[self.cur_itemid]
    local num = CombineModel:GetInstance():GetUsedNum()
    local probs = String2Table(combinebase.probs)
    local count = #probs
    local final_prob = 0
    if combinebase.other_cost == [[]] then
        SetVisible(self.Success, false)
    else
        SetVisible(self.Success, true)
        for i = 1, count do
            local item = probs[i]
            if num >= item[1] then
                final_prob = item[2]
            end
        end
        self.Success:GetComponent('Text').text = "Success Rate " .. final_prob .. "%"
    end
end

function CombinePanel:UpdateTopSelect(Sel_Id)
    for i, v in pairs(self.topmenu_list) do
        v:Select(Sel_Id)
    end
end

function CombinePanel:CheckSettledExist()
    if self.settleItemList then
        for i = 1, #self.settleItemList do
            if self.settleItemList[i] then
                self.settleItemList[i]:destroy()
            end
        end
    end
    self.settleItemList = {}
end

function CombinePanel:CheckTargetItem()
    if self.targetItem ~= nil then
        self.targetItem:destroy()
    end
end

function CombinePanel:ResetCombineArea()
    if self.alreadyAddList then
        for i, v in pairs(self.alreadyAddList) do
            if v then
                v:destroy()
            end
        end
        self.alreadyAddList = {}
    end

    if self.needicon2uid then
        self.needicon2uid = {}
    end

    self:ResetGridList()

    if self.Success then
        self.Success:GetComponent('Text').text = 0 .. "%"
    end
end

function CombinePanel:PutOffSpecifiedSettor(grid_Index)
    for index, item in pairs(self.alreadyAddList) do
        if index == grid_Index then
            self:SetGridState(index, 0)
            if self.alreadyAddList[index] then
                self.alreadyAddList[index]:destroy()
            end
            self.alreadyAddList[index] = nil
            break
        end
    end
    self.model:RemoveSpecifiedUid(self.needicon2uid[grid_Index])
    self.needicon2uid[grid_Index] = nil
    self:CalcSuccess()
end

function CombinePanel:UpdateSettledIcon(ItemId)
    local combinebase = Config.db_equip_combine[ItemId]
    --判断是否戒指手镯
    local need_puton = self.model:NeedPutOnItem(ItemId)
    --固定材料
    local cost = String2Table(combinebase.cost)
    self:CheckSettledExist()
    local fixIndex = 5
    self.settleItemList = self.settleItemList or {}
    for i = 1, #cost do
        SetVisible(self.numList[i], true)
        if i == 1 then
            SetVisible(self.lock1, false)
            self:SetGridState(1, 1)
        else
            SetVisible(self.lock_list[6 - i], false)
            self:SetGridState(i - 1, 1)
        end
        local id = cost[i][1]
        local hasNum = self.model:GetMaterialNum(combinebase, nil, nil, id)
        if need_puton then
            local itemcfg = Config.db_item[id]
            local putonitem = EquipModel.GetInstance():GetEquipBySlot(itemcfg.stype)
            if putonitem and putonitem.id == id then
                hasNum = hasNum + 1
            end
        end
        local param = {}
        local operate_param = {}
        param["item_id"] = id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param['bind'] = 0
        local goodsItem = nil
        if i == 1 then
            goodsItem = GoodsIconSettorTwo(self.fixPoint)
        else
            goodsItem = GoodsIconSettorTwo(self.fixPoint_List[fixIndex - i + 1])
        end
        goodsItem:SetIcon(param)
        self.settleItemList[#self.settleItemList + 1] = goodsItem
        local stairsAfter = hasNum
        if hasNum < cost[i][2] then
            stairsAfter = string.format("<color=#f53b3b>%s</color>", hasNum)
        end
        self.numList[i]:GetComponent('Text').text = stairsAfter .. "/" .. cost[i][2]
    end
    return combinebase
end

function CombinePanel:AfterFinishCombine()
    self:ResetCombineArea()
    self.model:CleanUsedUids()
    self:HideNumList()
    self:UpdateSettledIcon(self.cur_itemid)
    self:CalcSuccess()
end

function CombinePanel:HideNumList()
    for i, v in pairs(self.numList) do
        v.gameObject:SetActive(false)
    end
end

function CombinePanel:GetNeedIcon2UidListLength()
    local count = 0
    for i, v in pairs(self.needicon2uid) do
        if v ~= nil then
            count = count + 1
        end
    end
    return count
end

function CombinePanel:SetGridState(idx, state)
    for i, v in pairs(self.gridList) do
        if i == idx then
            if state == 1 then
                --不能点击
                RemoveClickEvent(self.needicon_List[i].gameObject)
            else
                local function call_back(target, x, y)
                    self.model.cur_grid_index = i
                    local cfg = Config.db_equip_combine[self.cur_itemid]
                    if not self:CheckIsHaveEnoughMat(cfg) then
                        return
                    end
                    self.selecticon = self:GetGridIdxByGridTrans(target.transform)
                    local SelectEquipPanel = lua_panelMgr:GetPanelOrCreate(CombineSelectEquipPanel)
                    SelectEquipPanel:SetItemId(self.cur_itemid)
                    SelectEquipPanel:Open()
                end
                AddClickEvent(self.needicon_List[i].gameObject, call_back)
            end
            self.gridList[i] = state
            break
        end
    end
end

function CombinePanel:GetOpenGrid()
    local index = nil
    for i = 1, #self.gridList do
        if self.gridList[i] == 0 then
            index = i
            break
        end
    end
    return index
end

function CombinePanel:ResetGridList()
    if not self.needicon_List then
        return
    end
    for i = 1, #self.needicon_List do
        self:SetGridState(i, 0)
        self.gridList[i] = 0
    end
end

function CombinePanel:NeedPutOnItem(id)
    local combinebase = Config.db_equip_combine[id]
    local gain = String2Table(combinebase.gain)[1]
    local r_item_id = gain[1]
    local itemcfg = Config.db_item[r_item_id]
    local need_puton = false
    if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_RING1 or itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_RING2 then
        need_puton = true
    end
    return need_puton
end

---------首次打开选择操作
function CombinePanel:SelectFloldMenuDefault(SecTypeId)
    self.isSetBg = false
    self.model.cur_top_id = SecTypeId
    self:Topbuttonclick_call_back(SecTypeId)
end

---------默认选择操作
function CombinePanel:DelaySelectFirstMenuDefault()
    local defa_index = 1
    local defa_id = self.model:GetCurFstMenuFstId()
    if self.model.default_first_id then
        defa_index = self.model:GetFstMenuIdxByMenuId(self.model.default_first_id)
        defa_id = self.model.default_first_id
        self.model.default_first_id = nil
    end
    self.model.select_fst_menu_id = defa_id
    GlobalEvent:Brocast(CombineEvent.SelectFstMenuDefault .. self.__cname, defa_index)
end