-- @Author: lwj
-- @Date:   2018-12-26 15:35:31
-- @Last Modified by:   win 10
-- @Last Modified time: 2018-12-26 15:35:37

FashionModel = FashionModel or class("FashionModel", BaseBagModel)
local FashionModel = FashionModel

function FashionModel:ctor()
    FashionModel.Instance = self
    self:Reset()
end

function FashionModel:Reset()
    self.infoList = {}          --當前標簽欄下的數據
    self.allInfoList = {}       --全部時裝的數據
    self.curItemId = nil
    self.curMenu = 1
    self.curItemStar = nil
    self.btnMode = 0            --右下角按鈕的模式  0:激活    1:升星    2:分解    3:穿戴(飄字顯示)
    self.isCanShowTips = false
    self.isOpenTitle = false        --是否正在打開稱號界面
    self.title_index = 4  --稱號的標簽欄索引
    self.default_sel_id = nil
    self.isGameStart = true         --是否是遊戲開始時，檢查紅點的模式
    self.red_dot_list = {}
    self.isShowRedInMain = false    --主界面圖標中是否正在顯示紅點
    self.is_open_panel = false        --是否要打開界面
    self.is_need_update_role_icon = false --是否需要更新角色頭像
    self.is_openning_fashion_panel = false      --是否正在打開界面
    self.cur_deco_type = 12               --當前打開的裝飾界面類型

    self.is_can_click_activa = true          --在點擊按鈕之後，到收到包之前都無法再點擊生效
    self.is_can_click_dress = true
    self.cur_icon_id = 0                    --當前選中的頭像與對話框的id
    self.cur_chat_id = 0
    self.is_activa = false                  --是否是激活操作
    self.openning_index = 12                --正在打開的界面
    self.defa_deco_id = nil                 --默認選中裝飾id
end

function FashionModel.GetInstance()
    if FashionModel.Instance == nil then
        FashionModel()
    end
    return FashionModel.Instance
end

function FashionModel:GetCurInfoList()
    self.infoList = {}
    self.infoList.fashions = {}
    if not table.isempty(self.allInfoList.fashions) then
        local cf = Config.db_fashion_type[self.curMenu]
        if cf then
            local contain = cf.contain
            local curMenu = String2Table(contain)
            for i, v in pairs(self.allInfoList.fashions) do
                for ii, vv in pairs(curMenu) do
                    --if vv.menu_type == "fashion" then
                    if table.nums(curMenu) == 1 then
                        if vv == v.id then
                            self.infoList.fashions[v.id] = v
                            break
                        end
                    else
                        if vv[1] == v.id then
                            self.infoList.fashions[v.id] = v
                            break
                        end
                    end
                    --end
                end
            end
        end
        self.infoList.puton_id = self.allInfoList.puton_id
        return self.infoList
    else
        return self.infoList
    end
end

function FashionModel:GetCurMenuPutOnId()
    return self.allInfoList.puton_id[self.curMenu]
end

function FashionModel:GetMenuPutOnIdByMenu(idx)
    return self.allInfoList.puton_id[idx]
end

function FashionModel:GetConfigList(index)
    local cf = Config.db_fashion_type[index]
    if not cf then
        return
    end
    return String2Table(cf.contain)
end

function FashionModel:GetCueShowList(index)
    local conList = {}
    local itemList = {}
    local val = nil
    local showTime = 0
    local lostTime = 0
    local conData = {}
    conList = self:GetConfigList(index)
    if not conList then
        return
    end
    local removeList = {}
    if table.isempty(self.infoList.fashions) then
        for i = 1, #conList do
            conData = {}
            if #conList > 1 then
                conData = Config.db_fashion[conList[i][1] .. "@" .. index]
            else
                conData = Config.db_fashion[conList[i] .. "@" .. index]
            end
            showTime = TimeManager.GetInstance():String2Time(conData.show_time)
            lostTime = TimeManager.GetInstance():String2Time(conData.lost_time)
            if showTime and lostTime then
                if os.time() < showTime or os.time() > lostTime then
                    local num = BagModel.GetInstance():GetItemNumByItemID(conData.id)
                    if num == 0 then
                        table.insert(removeList, conList[i])
                    end
                end
            end
        end
        for i, v in pairs(removeList) do
            table.removebyvalue(conList, v)
        end
        itemList = conList
    else
        if index == 11 or index == 12 then
            return conList
        end
        local interator = table.pairsByKey(self.infoList.fashions)
        for id, mValue in interator do
            for serial, idValue in pairs(conList) do
                if type(idValue) == "table" then
                    val = idValue[1]
                else
                    val = idValue
                end
                if mValue.id == val then
                    itemList[#itemList + 1] = idValue
                    table.removebyvalue(conList, idValue)
                    break
                end

            end
        end
        local listIntera = table.pairsByKey(conList)
        for i, v in listIntera do
            conData = {}
            if type(v) == "number" then
                conData = Config.db_fashion[v .. "@" .. index]
            else
                conData = Config.db_fashion[v[1] .. "@" .. index]
            end
            showTime = TimeManager.GetInstance():String2Time(conData.show_time)
            lostTime = TimeManager.GetInstance():String2Time(conData.lost_time)
            if showTime and lostTime then
                if os.time() >= showTime and os.time() <= lostTime then
                    itemList[#itemList + 1] = v
                else
                    local num = BagModel.GetInstance():GetItemNumByItemID(conData.id)
                    if num > 0 then
                        itemList[#itemList + 1] = v
                    end
                end
            else
                itemList[#itemList + 1] = v
            end
        end
    end
    return itemList
end

--在當前標簽欄中尋找
function FashionModel:GetFashionItemById(id)
    local result = nil
    if id then
        if table.isempty(self.infoList.fashions) then
            return result
        else
            for i, v in pairs(self.infoList.fashions) do
                if v.id == id then
                    result = v
                    break
                end
            end
        end
    end
    return result
end

--在全部數據中尋找
function FashionModel:GetFashionInfoById(id)
    local result = nil
    if id then
        if table.isempty(self.allInfoList.fashions) then
            return result
        else
            for i, v in pairs(self.allInfoList.fashions) do
                if v.id == id then
                    result = v
                    break
                end
            end
        end
    end
    return result
end

function FashionModel:SetNormalBtnMode(mode)
    self.btnMode = mode
end

function FashionModel:GetNormalBtnMode()
    return self.btnMode
end

function FashionModel:AddInfo(data)
    local fashions = data.fashions
    for id, value in pairs(fashions) do
        self.infoList.fashions = self.infoList.fashions or {}
        self.infoList.fashions[id] = value
        self.allInfoList.fashions = self.allInfoList.fashions or {}
        self.allInfoList.fashions[id] = value
    end
    local put_list = data.puton_id
    for type, id in pairs(put_list) do
        self.infoList.puton_id = self.infoList.puton_id or {}
        self.infoList.puton_id[type] = id
        self.allInfoList.puton_id = self.allInfoList.puton_id or {}
        self.allInfoList.puton_id[type] = id
    end
    self:GetCurInfoList()
end

function FashionModel:AddRedDotToList(side_index, fashion_id)
    self.red_dot_list[side_index] = self.red_dot_list[side_index] or {}
    self.red_dot_list[side_index][fashion_id] = true

    if side_index == 11 or side_index == 12 then
        --裝飾
        local idx = side_index == 11 and 2 or 1
        GlobalEvent:Brocast(FashionEvent.AddDecoRD, true, idx)
        local stronger_id = side_index == 11 and 62 or 63
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, stronger_id, true)
        GlobalEvent:Brocast(FashionEvent.ChangeChatDecoRD, true)
    else
        if not self.isShowRedInMain then
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "fashion", true)
            self.isShowRedInMain = true
        end
    end
end

function FashionModel:RemoveRedDotFromList(side_index, fashion_id)
	if not side_index then
        side_index = self.curMenu
    end
    if not fashion_id then
        fashion_id = self.curItemId
    end
	if (not self.red_dot_list) or (not self.red_dot_list[side_index]) or (not self.red_dot_list[side_index][fashion_id]) then
		return 
	end 
    if self.red_dot_list[side_index] == nil or table.isempty(self.red_dot_list[side_index]) then
        GlobalEvent:Brocast(FashionEvent.ChangeSideRedDot, false)
        if table.nums(self.red_dot_list) == 0 and TitleModel.GetInstance().is_show_title_red == false then
            if self.isShowRedInMain then
                self.isShowRedInMain = false
                GlobalEvent:Brocast(MainEvent.ChangeRedDot, "fashion", false)
            end
        end
        self:Brocast(FashionEvent.ChangeItemRedDot, false, fashion_id)
        return
    end
    --激活後
    --檢查是否可以升星
    if self:CheckIsCanUpStar(fashion_id) then
        return
    end
    self.red_dot_list[side_index][fashion_id] = nil
    --隱藏界面按鈕紅點
    self:Brocast(FashionEvent.ChangePanelRedDot, false, side_index)
    self:Brocast(FashionEvent.ChangeItemRedDot, false, fashion_id)
    if side_index ~=4 and side_index ~=11 and side_index ~=12 and table.nums(self.red_dot_list[side_index]) == 0 then
        self.red_dot_list[side_index] = nil
        GlobalEvent:Brocast(FashionEvent.ChangeSideRedDot, false)
    end
    if table.nums(self.red_dot_list) == 0 and TitleModel.GetInstance().is_show_title_red == false then
        if self.isShowRedInMain then
            self.isShowRedInMain = false
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "fashion", false)
        end
    end

    if (side_index == 11 or side_index == 12) then
        self.red_dot_list[side_index][fashion_id] = nil
        local idx = side_index == 11 and 2 or 1
        --該標簽沒有紅點，或者，沒有該標簽列表
        if (not self.red_dot_list[side_index]) or table.nums(self.red_dot_list[side_index]) == 0 then
            GlobalEvent:Brocast(FashionEvent.ChangeDecoSideRD, false, idx)
            local stronger_id = side_index == 11 and 62 or 63
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, stronger_id, false)
        end
        if not self:IsHaveDecoRD() then
            GlobalEvent:Brocast(FashionEvent.ChangeChatDecoRD, false)
        end
    end
end

function FashionModel:IsHaveDecoRD()
    self.red_dot_list = self.red_dot_list or {}
    local is_show = false
    for idx, rd_list in pairs(self.red_dot_list) do
        if rd_list then
            if idx == 11 or idx == 12 then
                for _, is_show_rd in pairs(rd_list) do
                    if is_show_rd then
                        is_show = true
                        break
                    end
                end
            end
        end
    end
    return is_show
end

function FashionModel:IsHaveRD()
    self.red_dot_list = self.red_dot_list or {}
    local is_show = false
    if TitleModel.GetInstance().is_show_title_red then
        is_show=true
    else
        for idx, rd_list in pairs(self.red_dot_list) do
            if rd_list and idx~=11 and idx~=12   then
                for _, is_show_rd in pairs(rd_list) do
                    if is_show_rd then
                        is_show = true
                        break
                    end
                end
            end
        end
    end
    return is_show
end

function FashionModel:CheckIsShowSideRedDot(side_index)
    local isShow = false
    if self.red_dot_list[side_index] and (not table.isempty(self.red_dot_list[side_index])) then
        isShow = true
    end
    return isShow
end

function FashionModel:CheckIsShowItemRedDot(side_index, fashion_id)
    if self.red_dot_list[side_index] then
        return self.red_dot_list[side_index][fashion_id] or false
    else
        return false
    end
end

function FashionModel:CheckIsCanUpStar(fashion_id)
    if not self.allInfoList.fashions[fashion_id] then
        return
    end
    local isCanUp = false
    local next_star = self.allInfoList.fashions[fashion_id].star + 1
    local star_cf = Config.db_fashion_star[fashion_id .. "@" .. next_star]
    if star_cf then
        local cost_tbl = String2Table(star_cf.cost)
        if type(cost_tbl[2]) == "table" then
            --兩個以上的消耗材料
            for i = 1, #cost_tbl do
                local haveNum = BagModel.GetInstance():GetItemNumByItemID(cost_tbl[i][1])
                if cost_tbl[i][2] <= haveNum then
                    isCanUp = true
                else
                    break
                end
            end
        else
            local haveNum = BagModel.GetInstance():GetItemNumByItemID(cost_tbl[1])
            if haveNum >= cost_tbl[2] then
                isCanUp = true
            end
        end
    end
    return isCanUp
end

--聊天相關 設置默認選擇
function FashionModel:SetDefaultSel(idx, first_item_id)
    local puton_id
    if self.defa_deco_id then
        --默認選中
        puton_id = self.defa_deco_id
    else
        puton_id = self:GetMenuPutOnIdByMenu(idx)
        --當前穿戴 或者 第一個
        puton_id = puton_id or first_item_id
        --選中判定 默認的話
        if puton_id == 110000 or puton_id == 120000 then
            --換成當前選中的
            local cur_sel = idx == 12 and self.cur_chat_id or self.cur_icon_id
            --容錯 沒有選中的話就是 第一個
            cur_sel = cur_sel == 0 and first_item_id or cur_sel
            puton_id = cur_sel
        end
    end
    self.curItemId = puton_id
    self:Brocast(FashionEvent.SetDefaultSel, puton_id)
    self.defa_deco_id = nil
end

function FashionModel:ModifyPutId(type, id)
    self.allInfoList.puton_id[type] = id
end