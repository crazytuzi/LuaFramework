


local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ItemDetail = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local EquipMeltingUI = require "Zeus.UI.XmasterBag.GameUIMelt"
local CurrencyUI = require "Zeus.UI.XmasterBag.GameUIMoneyShow"
local CurrencyTipUI = require "Zeus.UI.XmasterBag.CurrencyTip"
local ComposeUI = require "Zeus.UI.XmasterBag.ItemComposeUI"
local StoreUI = require "Zeus.UI.XmasterBag.GameUIBagStore"
local bit = require 'bit'
local _M = {
    showSelect = nil,
    funcs = nil,
    selectTbtn = nil
}
_M.__index = _M
local MAX_COLUMNS = 5

local string_param_tbt = "closeUI=%d:subScreen=%d:param=%s"

function _M.CreateTbtParam(closeTag,subTag,param)
    return string.format(string_param_tbt,closeTag,subTag,param)
end


local Text = {
    NumFormat1 = Util.GetText(TextConfig.Type.ITEM,'bagGridFmt1'),
    NumFormat2 = Util.GetText(TextConfig.Type.ITEM,'bagGridFmt2'),
    CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costDiamond'),
    GridNumTitle = Util.GetText(TextConfig.Type.ITEM,'buyNumTitle'),
}

local ui_names = {
    {
        name = 'btn_arrange',
        click = function(self)
            local userdata = DataMgr.Instance.UserData
            userdata:BagPackUp(userdata.RoleBag.PackType)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zhengli')

        end
    },
    {
        name = 'btn_close',
        click = function(self)
            self:Close();
        end
    },
    { name = "cvs_bag" },
    { name = 'cvs_cell' },
    { name = 'sp_content_bag' },
    { name = 'tbt_all' },
    { name = 'tbt_equip' },
    { name = 'tbt_material' },
    { name = 'tbt_other' },
    { name = 'tbt_xuemai' },
    { name = 'lb_bunding2' },
    { name = 'cvs_information' },
    
    { name = 'tbt_bag' },
    { name = 'tbt_warehouse'},
    { name = 'tbt_compose' },
    { name = 'tbt_smelt' },
    { name = 'tbt_money' },
    { name = "cvs_combine"},


}

local function Close(self)
    self.menu:Close()
end

local function AddCategory(self, filter, name)
    for _, v in ipairs(self.cate_tbts) do
        if not v.Visible then
            self.filters = self.filters or { }
            self.filters[name] = filter
            v.Name = name
            v.Visible = true
            return v
        end
    end
end

local function SwitchToCategory(self, categoryName)
    for _, v in ipairs(self.cate_tbts) do
        if categoryName == v.Name then
            v.IsChecked = true
        end
    end
end

local function OnCategoryChecked(self, sender)
    if not sender.IsChecked then return end

    if self.selectTbtn and self.selectTbtn == self.tbt_smelt and sender ~= self.tbt_equip then
        self.tbt_bag.IsChecked = true
    end
    self.Container.Filter = self.filters[sender.Name]
    self.selected_category = sender
    local rolebag = self.Container.ItemPack
    local max_rows = math.floor(rolebag.MaxLimitSize / MAX_COLUMNS)
    if rolebag.MaxLimitSize % MAX_COLUMNS ~= 0 then
        max_rows = max_rows + 1
    end
    max_rows =(max_rows < 5 and 20) or max_rows
    if self.sp_content_bag.Rows <= 0 then
        local cellW = self.sp_content_bag.Width / 5
        self.sp_content_bag:Initialize(cellW, cellW, max_rows, MAX_COLUMNS, self.cvs_cell,
        function(gx, gy, node)
            if self.Container ~= nil then
                self.Container:SetItemShowParent(node, gy * MAX_COLUMNS + gx + 1)
            end
        end , function() 
           
        end)
    else
        self.sp_content_bag.Rows = max_rows  

        self.Container:ClearAllSelect()
        if self.funcs.itemDetail ~= nil then
            self.funcs.itemDetail.menu.Visible = true
        end
        if self.selectTbtn == self.tbt_warehouse then
            self.Container:ClearAllSelect()
            self.funcs.itemDetail.menu.Visible = false
            return
        end
        local itemShow = self.Container:GetItemShowAt(1)
        if itemShow then
            self.Container:SetSelectItem(itemShow, itemShow.Num)
            if itemShow.LastItemData then
                self.item_click(nil, itemShow)
            else
                self.funcs.itemDetail.menu.Visible = false
            end
        else
            self.funcs.itemDetail.menu.Visible = false
        end
    end
end

local function AddCategoryWithType(self, seq, type, name)
    if self.filters and self.filters[name] then
        return
    end
    local filter = ItemPack.FilterInfo.New()
    filter.IsSequence = seq
    filter.Type = type

    
    if filter.Type == ItemData.TYPE_TASK then
        filter.CheckHandle = function(item)
            local detail = item.detail
            if detail then
                if not string.find(detail.static.Code, "vq") then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
    end

    local tbn = AddCategory(self, filter, name)
    return tbn
end

local function get_gem_icon(code)
    return "static_n/item/" .. code .. ".png";
end

local function OnfuncChoiceSelect(self, sender)
    
    self.selectTbtn = sender
    if (sender == self.tbt_bag) then
        self:setSelectBag()
    elseif (sender == self.tbt_compose) then
        self:setSelectComponse()
    elseif (sender == self.tbt_smelt) then
        self:setSelectMelting()
    elseif (sender == self.tbt_money) then
        self:setSelectCurrency()
    elseif (sender == self.tbt_warehouse) then
        self:setSelectStore()
    end
end

local function todoParam(self,code,value)
    if value and string.len(value) > 0 then
        if code == "closeUI" then
            if value ~= "0" then
                local closeTag = tonumber(value)
                GlobalHooks.CloseUI(closeTag)
            end
        elseif code == "subScreen" then
            local targetTag = tonumber(value)
            if GlobalHooks.CheckUICanOpen(targetTag) then
                self.openTarget = targetTag
                 if targetTag == GlobalHooks.UITAG.GameUICombine then
                    Util.ChangeMultiToggleButtonSelect(self.tbt_compose, self.func_tbts)
                 elseif targetTag == GlobalHooks.UITAG.GameUIMelt then
                    Util.ChangeMultiToggleButtonSelect(self.tbt_smelt, self.func_tbts)
                elseif targetTag == GlobalHooks.UITAG.GameUIBagMain then
                    Util.ChangeMultiToggleButtonSelect(self.tbt_bag, self.func_tbts)
                end
            else
                self:Close()
            end
        elseif code == "param" then
            if self.openTarget == GlobalHooks.UITAG.GameUICombine then
                self.funcs.compose:SetParam(value)
            end
        end
    end
end

local function SetScoreUp(it)
    local pro = DataMgr.Instance.UserData.Pro
    local score_up_conf = it:GetNodeConfig(HZItemShow.CompType.score_up)
    local detail = it.LastItemData.detail

    if detail.equip.isIdentfied == 1 and detail.equip.pro == pro then
        local cmp = ItemModel.GetLocalCompareDetail(detail.itemSecondType)
        if not cmp then
            score_up_conf.Val = true
        elseif cmp.equip.isIdentfied == 1 then
            score_up_conf.Val = cmp.equip.baseScore < detail.equip.baseScore
        else
            score_up_conf.Val = false
        end
    else
        score_up_conf.Val = false
    end
end

local function ItemshowExt(con, it)
    if not it.LastItemData then
        it.event_LongPoniterDown = nil
        it.event_PointerUp = nil
        it:RemoveCustomAttribute('detail_tips')
        return
    end
    
    

    local pro = DataMgr.Instance.UserData.Pro
    local detail = it.LastItemData.detail
    
    local isEquip = it.LastItemData.IsEquip
    local ProTable = GlobalHooks.DB.Find('Character', DataMgr.Instance.UserData.Pro)
    local red_limit = false
    local unidentify = false
    local score_up = false
    local bind = false
    local showpoint = false
    local label_num = false
    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    if detail then
        if isEquip then
            local ProTable = GlobalHooks.DB.Find('Character', DataMgr.Instance.UserData.Pro)
            red_limit = detail.static.Pro ~= ProTable.ProName and detail.static.Pro ~= 0 or detail.static.LevelReq > lv
            unidentify = detail.equip.isIdentfied ~= 1
            score_up = true
            it.IsShowRedPoint = false
        else
            local itemdata = GlobalHooks.DB.Find("Items", it.LastItemData.TemplateId)
            if it.LastItemData.Type == ItemData.TYPE_CHEST or (itemdata.RedPoint and itemdata.RedPoint == 1) then
                it.IsShowRedPoint = true
              
            else
                it.IsShowRedPoint = false
            end
        end
        local bindType = detail.bindType or detail.static.BindType
        bind = bindType == 1
        label_num = true
        it.Num = it.LastItemData.Num
    end
    it:SetNodeConfigVal(HZItemShow.CompType.red_limit, red_limit)
    it:SetNodeConfigVal(HZItemShow.CompType.unidentify, unidentify)
    it:SetNodeConfigVal(HZItemShow.CompType.bind, bind)
    
    
    

    if score_up then
        SetScoreUp(it)
    else
        it:SetNodeConfigVal(HZItemShow.CompType.score_up, score_up)
    end

    local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    local attention_list = string.split(GlobalHooks.DB.GetGlobalConfig('Item.Attention'))
    local self_diamond = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)








end

local function OnEnter(self)
    local rolebag = DataMgr.Instance.UserData.RoleBag
    self.Container:AddItemShowInitHandle('itshow', ItemshowExt)
    
    
    
    
    
    
    local iter = rolebag.AllData:GetEnumerator()
    local isred = false
    while iter:MoveNext() do
        local data = iter.Current.Value
        local it = GlobalHooks.DB.Find("Items", data.TemplateId)
        if data.Type == ItemData.TYPE_CHEST or (it.RedPoint and it.RedPoint == 1) then
           isred = true
           break
        end         
    end 
    

    EventManager.Fire("Event.Hud.red", {value=isred})   
    
    if string.len(self.menu.ExtParam) > 0 then
        local temps = string.split(self.menu.ExtParam, ":")
        for i = 1, #temps, 1 do
            local sList = string.split(temps[i], "=")
            todoParam(self, sList[1], sList[2])
        end
    else
        Util.ChangeMultiToggleButtonSelect(self.tbt_bag, self.func_tbts)
    end

    self.tbt_compose.Visible = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUICombine, false)
    self.tbt_smelt.Visible = GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUIMelt, false)
end

local function OnDestory(self)

end

local function OnExit(self)
    
    DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
    EventManager.Unsubscribe("Event.FunctionOpen.WaitToPlay", self.OpenUIChangeFlag)
    self.Container:RemoveItemShowInit('itshow')
    self.Container:ClearAllSelect()
     
    local rolebag = DataMgr.Instance.UserData.RoleBag
    local iter = rolebag.AllData:GetEnumerator()
    local isred = false
    while iter:MoveNext() do
        local data = iter.Current.Value
        local it = GlobalHooks.DB.Find("Items", data.TemplateId)
        if data.Type == ItemData.TYPE_CHEST or (it.RedPoint and it.RedPoint == 1) then
           isred = true
           break
        end         
    end 
    

    EventManager.Fire("Event.Hud.red", {value=isred})  
end

local function changeToSimpleChoice(self)
    if self.showSelect then
        self.showSelect = false
        self.Container:ClearAllSelect()
        self.Container:RemoveItemShowInit("normal")
        self.Container:RemoveItemShowInit("melt")
        self.Container:AddItemShowInitHandle("normal", function(con, itshow)
            if not itshow.LastItemData or not itshow.Parent then return end
            local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
            tbt_gou.Visible = false
        end )
    end
    
    if self.showSelect == false then
        if self.selectTbtn == self.tbt_warehouse then
            self.Container:ClearAllSelect()
            return
        end
        local itemShow = self.Container:GetItemShowAt(1)
        if itemShow then
            self.Container:SetSelectItem(itemShow, itemShow.Num)
            if itemShow.LastItemData then
                self.item_click(nil, itemShow)
            else
                if self.funcs.itemDetail ~= nil then
                    self.funcs.itemDetail.menu.Visible = false
                end
            end
        else
            if self.funcs.itemDetail ~= nil then
                self.funcs.itemDetail.menu.Visible = false
            end
        end
    end
end

local function OpenGrid(self, it)
    if it then
        it.IsSelected = true
    end
    local rolebag = DataMgr.Instance.UserData.RoleBag
    local function num_input_cb(input_obj, result)
        if result then
            if rolebag.UnitDimond*result > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
                 local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
                local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
                local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
                local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
                GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil,
                function()
                    ItemModel.OpenGridRequest(rolebag.PackType, result)
                end, 
                function()
                end)
            else
                ItemModel.OpenGridRequest(rolebag.PackType, result)
            end
        end
    end

    local CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costBindDiamond')
    local function num_change(input_obj, num)
        input_obj.tb_cost.XmlText = string.format(CostDiamond,num * rolebag.UnitDimond)
    end

    local max_open = rolebag.MaxLimitSize - rolebag.LimitSize
    local txts = {
        string.format(Text.NumFormat1,rolebag.LimitSize),
        string.format(Text.NumFormat2,max_open),
    }

    
    EventManager.Fire("Event.ShowNumInput", {
        min = 1,
        max = max_open,
        num = (max_open > 5 and 5) or max_open,
        cb = num_input_cb,
        title = Text.GridNumTitle,
        change_cb = num_change,
        
        txt = txts,
        exit_cb = function()
            if it then
                it.IsSelected = false
            end
        end
    } )
end

local function CreateParams(self, roleEquip, it)
    local params = {
        id = it.LastItemData.Id,
        anchor = 'L',
        cb = function(d, eventname, param)
            DetailCallback(self, roleEquip, d, eventname, param)
        end
    }

    if not GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIMelt) then
        params.show_sidebtn = true
        if it.LastItemData.IsEquip then
            if roleEquip then
                params.button1 = 'Event.UnEquipItem'
                
                params.button2 = 'Event.EntryStrengthen'
                
                
                params.anchor = 'R'
            else
                params.button1 = 'Event.EquipItem'
                params.button2 = 'Event.IdentifyEquip'
                params.button3 = 'Event.SellItem'
                params.button4 = 'Event.EquipCompare'
                params.score_compare = 0
            end
        else
            
            params.button1 = 'Event.ItemCombine'
            params.button2 = 'Event.UseItem'
            params.button3 = 'Event.SellItem'
            
        end
    end
    return params
end

local btns_equip = {
    { title = Util.GetText(TextConfig.Type.ITEM, 'btnEquip'), eventName = "Event.EquipItem" },
    { title = Util.GetText(TextConfig.Type.ITEM, 'btnSmelt'), eventName = "Event.SellItem" }
}

local btns_material = {
    { title = Util.GetText(TextConfig.Type.ITEM, 'btnUse'), eventName = "Event.UseItem" },
    { title = Util.GetText(TextConfig.Type.ITEM, 'btnSell'), eventName = "Event.SellItem" }
}

local function itemOperateCallBack(self, event)
    if (event == "itemNull") then
        if self.funcs.itemDetail then
            self.funcs.itemDetail.menu.Visible = false
        end
    else
        self.funcs.itemDetail:ResetWithBagUI()
    end
end

local function ClickItemshow(self, roleEquip, it)
    local detail = it.LastItemData.detail
    local isEquip = it.LastItemData.IsEquip
    if self.selectTbtn == self.tbt_warehouse then
        self.funcs.store:OnItemClick(it,true)





    else
        if self.funcs.itemDetail == nil then
             self.funcs.itemDetail = ItemDetail.CreateWithBagUI(1, self.cvs_information)
        end
        self.funcs.itemDetail:SetItem(it.LastItemData, isEquip)
        local function callback(sender, name, param)
            itemOperateCallBack(self, param)
        end
        local btns = {}
        if (isEquip) then
            if detail.static.NoSell == 0 then
                table.insert(btns,btns_equip[2])
            end
            table.insert(btns,btns_equip[1])
            self.funcs.itemDetail:setButtons(btns, callback)
        else
            if detail.static.NoSell == 0 then
                table.insert(btns,btns_material[2])
            end
            if detail.static.IsApply == 1 then
                table.insert(btns,btns_material[1])
            end

            
            if detail.static.Type == "virtQuest" then
                table.insert(btns,btns_equip[2])
            end

            self.funcs.itemDetail:setButtons(btns, callback)
        end
        self.funcs.itemDetail.menu.Visible = self.tbt_bag.IsChecked
    end
end


function _M:setSelectStore()
    self.tbt_all:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_material:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_other:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_xuemai:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_equip:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self:closeAllFuncs()
    if self.funcs.store == nil then
        self.funcs.store = StoreUI.Create(GlobalHooks.UITAG.GameUIBagStore, self.cvs_information)
    end
    self.funcs.store:OnEnter()
    self.funcs.store:SetBag(self)
    changeToSimpleChoice(self)
end


function _M:setSelectMelting()
    Util.ChangeMultiToggleButtonSelect(self.tbt_equip,self.cate_tbts)
    
    
    
    self:closeAllFuncs()
    if self.funcs.melting == nil then
        self.funcs.melting = EquipMeltingUI.Create(GlobalHooks.UITAG.GameUIMelt, self.cvs_information)
    end
    self.funcs.melting:SetBag(self)
    self.funcs.melting.menu.Visible = true
    self.Container:ClearAllSelect()
    self.showSelect = true
    self.funcs.melting:OnEnter()
end

function _M:OpenMelt()
    Util.ChangeMultiToggleButtonSelect(self.tbt_smelt,self.func_tbts)
end


function _M:setSelectComponse()
    self.tbt_all:SetBtnLockState(HZToggleButton.LockState.eLockUnSelect)
    self.tbt_material:SetBtnLockState(HZToggleButton.LockState.eLockUnSelect)
    self.tbt_other:SetBtnLockState(HZToggleButton.LockState.eLockUnSelect)
    self.tbt_xuemai:SetBtnLockState(HZToggleButton.LockState.eLockUnSelect)
    if self.funcs.compose == nil then
        self.funcs.compose = ComposeUI.Create(GlobalHooks.UITAG.GameUIItemCombine,self.cvs_combine)
    end
    self.funcs.compose:OnEnter()
    changeToSimpleChoice(self)
end



function _M:setItemDetailBtnValues()
    local btns = { }
    btns.tag = "UIBagMian"
    btns.info = { }
    table.insert(btns.info, { "btn_equip", "Event.EquipItem" })
    
    table.insert(btns.info, { "btn_sale", "Event.SellItem" })
    
    table.insert(btns.info, { "btn_use", "Event.UseItem" })
    
    table.insert(btns.info, { "btn_sale2", "Event.SellItem" })
    
    return btns
end

function _M:closeAllFuncs()
    for k, v in pairs(self.funcs) do
        if v.CloseMenu then
            v:CloseMenu()
        end
    end
end


function _M:setSelectBag()
    self.tbt_all:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_material:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_other:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_xuemai:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_equip:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self:closeAllFuncs()
    if self.funcs.itemDetail == nil then
        self.funcs.itemDetail = ItemDetail.CreateWithBagUI(1, self.cvs_information)
    end
    self.funcs.itemDetail.menu.Visible = true
    changeToSimpleChoice(self)
end


function _M:setSelectCurrency()
    self.tbt_all:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_material:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_other:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self.tbt_equip:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
    self:closeAllFuncs()
    if self.funcs.currency == nil then
        self.funcs.currency = CurrencyUI.Create(GlobalHooks.UITAG.GameUIMoneyShow, self.cvs_information)
        self.funcs.currency:SetBag(self)
    end
    self.funcs.currency:Open()
    changeToSimpleChoice(self)
end

function _M:OpenCurrencyTip(currency)
    if (self.currencyTip == nil) then
        self.currencyTip = CurrencyTipUI.Create(self.cvs_bag)
    end
    self.currencyTip:Open(currency)
end



function _M:ItemDetailOnExit(con, d)
    if d.item then
        local it = con:FindItemShow(d.item.Id)
        if it then
            con:SetSelectItem(it, 0)
        end
    end
end

function _M:DetailCallback(roleEquip, d, eventname, param)
    if eventname == 'Event.OnExit' then
        if roleEquip then
            ItemDetailOnExit(self, self.avatar_lua.EquipContainer, d)
        elseif self.bag_main.bag then
            ItemDetailOnExit(self, self.bag_main.bag.Container, d)
        else
            self.eventDetail = nil
        end
    elseif eventname == 'Event.IdentifyEquip' then
        self.eventDetail:Reset(self.detailParams)
    elseif eventname == 'Event.EquipItem' then
    end
end



local function InitComponent(self, tag)
    
    self.menu = LuaMenuU.Create('xmds_ui/bag/bag.gui.xml', tag)
    self.menu.Enable = false
    self.menu.ShowType = UIShowType.HideBackHud
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.funcs = { }
    self.uniqueInt = Util.GetUniqueInt()
    self.filter = ItemPack.FilterInfo.New()
    
    self.lb_bj_char = self.menu:GetComponent("lb_bj_bag")

    self.menu:SubscribOnExit( function()
        OnExit(self)
    end )
    self.menu:SubscribOnEnter( function()
        OnEnter(self)
    end )
    self.menu:SubscribOnDestory( function()
        OnDestory(self)
    end )

    self.Container = HZItemsContainer.New()
    self.Container.IsShowNew = true
    self.Container.IsShowStrengthenLv = true
    self.Container.IsShowLockUnlock = true
    self.Container.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_cell.Size2D)
    self.cvs_cell.Visible = false
    self.Container.OnItemClik = function(con, it)
        if self.Container.Filter and it.Status == HZItemShow.ItemStatus.LOCK then
            OpenGrid(self, it)
        end
    end
    self.item_click = function(roleEquip, it)
        ClickItemshow(self, roleEquip, it)
    end
    
    self.cate_tbts = { self.tbt_all, self.tbt_equip, self.tbt_material, self.tbt_other, self.tbt_xuemai}
    
    self.func_tbts = { self.tbt_bag, self.tbt_warehouse,self.tbt_compose, self.tbt_smelt, self.tbt_money }
    for _, v in ipairs(self.cate_tbts) do
        v.Visible = false
    end
    local rolebag = DataMgr.Instance.UserData.RoleBag

    self.filter.NofityCB = function(pack, status, index)
        
        local str = Util.GetText(TextConfig.Type.ITEM, "bagCountFormat",
        rolebag.AllData.Count, rolebag.LimitSize)
        if(self.lb_bunding2) then
            self.lb_bunding2.Text = str
        end
    end
    self.Container.ItemPack = rolebag
    self.showSelect = false
    AddCategoryWithType(self, false, ItemData.TYPE_ALL, "all", false)
    AddCategoryWithType(self, true, ItemData.TYPE_EQUIP, "equip", false)
    AddCategoryWithType(self, true, ItemData.TYPE_MATERIAL, "material", false)
    local other_type = bit.bxor(ItemData.TYPE_ALL, ItemData.TYPE_EQUIP, ItemData.TYPE_MATERIAL, ItemData.TYPE_TASK)
    AddCategoryWithType(self, true, other_type, "other", false)
    AddCategoryWithType(self, true, ItemData.TYPE_TASK, "xuemai", false)
    if rolebag~=nil then
        rolebag:AddFilter(self.filter)
    end
    Util.InitMultiToggleButton( function(sender)
        OnCategoryChecked(self, sender)
    end , self.tbt_all, self.cate_tbts)
    Util.InitMultiToggleButton( function(sender)
        OnfuncChoiceSelect(self, sender)
    end , nil, self.func_tbts)

    self.Container:OpenSelectMode(true, false, nil, function(con, it)
        if not it.LastItemData then return end
        if it:ContainCustomAttribute('detail_tips') then
            it:RemoveCustomAttribute('detail_tips')
            return
        end
        if self.showSelect then
            local node = it.Parent
            local select = self.funcs.melting:SelectItem(node, it.LastItemData)
            if (select) then
                con:SetSelectItem(it, it.Num)
            else
                con:SetSelectItem(it, 0)
            end
        else
            con:ClearAllSelect()
            if not it.IsSelected then
                con:SetSelectItem(it, it.Num)
                if self.item_click then
                    self.item_click(false, it)
                end
            end
        end
    end )
end


local function Create(tag, param)
    local ret = { }
    setmetatable(ret, _M)
    InitComponent(ret, tag)
    return ret
end

local function LockCategory(self, lock)
    for _, v in ipairs(self.cate_tbts) do
        v.Enable = not lock
    end
end


_M.Create = Create
_M.Close = Close
_M.LockCategory = LockCategory
_M.OpenGrid = OpenGrid
_M.ClickItemshow = ClickItemshow
return _M

