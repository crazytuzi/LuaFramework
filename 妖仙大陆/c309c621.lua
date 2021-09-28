

local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local EventDetail = require 'Zeus.UI.XmasterBag.EventItemDetail'
local _M = { }
_M.__index = _M
local MAX_COLUMNS = 4
local PERSON_STORE = 2

local function Close(self)
    self.menu:Close()
end



local Text = {
    NumFormat1 = Util.GetText(TextConfig.Type.ITEM,'storeGridFmt1'),
    NumFormat2 = Util.GetText(TextConfig.Type.ITEM,'storeGridFmt2'),
    NumFormat3 = Util.GetText(TextConfig.Type.ITEM,'StoreNumAvailable'),
    CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costDiamond'),
    BottomFormat = Util.GetText(TextConfig.Type.ITEM,'bagCountFormat'),
    Push = Util.GetText(TextConfig.Type.ITEM,'storeOpPush'),
    Pop = Util.GetText(TextConfig.Type.ITEM,'storeOpPop'),
    GridNumTitle = Util.GetText(TextConfig.Type.ITEM,'buyNumTitle'),
    StoreNumTitle = Util.GetText(TextConfig.Type.ITEM,'StoreNumTitle'),
    pickNumTitle = Util.GetText(TextConfig.Type.ITEM,'pickNumTitle'),
    pickNumAvailable = Util.GetText(TextConfig.Type.ITEM,'pickNumAvailable'),
}

function _M:OnEnter()
    
    
    
    
    self.menu.Visible = true
    self:OnStoreSelected(PERSON_STORE)
end

function _M:CloseMenu()
    
    self:OnExit()
end

function _M:OnExit()
    
    if self.bag then
        self.bag.Container:RemoveItemShowInit('store')

        local child_list = self.bag.sp_content_bag.Scrollable.Container:GetAllChild()
        local children = Util.List2Luatable(child_list)
        for _, v in ipairs(children) do
            v.TouchClick = nil
        end

        self.bag.Container:ForEachAllItemShow( function(con, itshow)
            itshow.EnableTouch = true
        end )

        
        self.bag = nil
    end
    self.selected_pack = nil
    if self.itshow then
        self.itshow.IsSelected = false
    end
    if self.eventDetail then
        self.eventDetail:Close()
        self.eventDetail = nil
    end
    self.menu.Visible = false
end

function _M:OnDestory(self)
    
    self.Container:Dispose()
end

local function UpdateBagSize(self)
    local max_open = self.selected_pack.MaxLimitSize - self.selected_pack.LimitSize
    local count = self.filter.ItemCount
    self.tbh_tishi.Text = Util.GetText(TextConfig.Type.ITEM, "bagCountFormat", count, self.selected_pack.LimitSize)
end

local function OpenGrid(self, it)
    if it then
        it.IsSelected = true
    end
    local function num_input_cb(input_obj, result)
        if result then
            if self.selected_pack.UnitDimond*result > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
                local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
                local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
                local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
                local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
                GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil, 
                function()
                    ItemModel.OpenGridRequest(self.selected_pack.PackType, result, function()
                        UpdateBagSize(self)
                    end )
                end, 
                function()
                end)
            else
                ItemModel.OpenGridRequest(self.selected_pack.PackType, result, function()
                    UpdateBagSize(self)
                end )
            end
        end
    end

    local CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costBindDiamond')
    local function num_change(input_obj, num)
        input_obj.tb_cost.XmlText = string.format(CostDiamond,num * self.selected_pack.UnitDimond)
    end

    local max_open = self.selected_pack.MaxLimitSize - self.selected_pack.LimitSize
    local txts = {
        string.format(Text.NumFormat1,self.selected_pack.LimitSize),
        string.format(Text.NumFormat2,max_open),
    }

    
    EventManager.Fire("Event.ShowNumInput", {
        min = 1,
        max = max_open,
        num = (max_open > 5 and 5) or max_open,
        cb = num_input_cb,
        change_cb = num_change,
        title = Text.GridNumTitle,
        
        txt = txts,
        exit_cb = function()
            if it then
                it.IsSelected = false
            end
        end
    } )
end

local ui_names =
{
    
    
    
    { name = 'tbh_tishi' },
    { name = 'cvs_item1' },
    { name = 'sp_ware' },
    { name = 'btn_buy', click = OpenGrid },
    {
        name = 'btn_order',
        click = function(self)
            local userdata = DataMgr.Instance.UserData
            userdata:BagPackUp(self.selected_pack.PackType)
        end
    },
    { name = 'btn_close', click = Close }
}


function _M:OnStoreSelected(sender)

    local pack_type = sender
    if pack_type <= 0 then return end
    local itempack = DataMgr.Instance.UserData:GetItemPackByType(pack_type)
    self.selected_pack = itempack
    if itempack then
        self.Container.ItemPack = itempack
        local max_rows = math.floor(itempack.MaxLimitSize / MAX_COLUMNS)
        if itempack.MaxLimitSize % MAX_COLUMNS ~= 0 then
            max_rows = max_rows + 1
        end

        if self.sp_ware.Rows <= 0 then
            local cellW = self.sp_ware.Width / MAX_COLUMNS
            self.sp_ware:Initialize(cellW, self.cvs_item1.Height, max_rows, MAX_COLUMNS, self.cvs_item1,
            function(gx, gy, node)
                self.Container:SetItemShowParent(node, gy * MAX_COLUMNS + gx + 1)
            end , function() end)
        else
            self.sp_ware.Rows = max_rows
        end
        UpdateBagSize(self)
    else

    end
end

local function ShowOpMenu(self, itshow, is_bag)
    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagOpMenu, 0)

    obj.btn_inf.Enable = true
    obj.btn_inf.IsGray = false
    obj.btn_save.Enable = true
    obj.btn_save.IsGray = false

    obj:SetExitCb( function()
        if self.itshow then
            self.itshow.IsSelected = false
        end
    end )
    local rolebag = DataMgr.Instance.UserData.RoleBag
    local itdata = itshow.LastItemData
    local detail = itdata.detail
    local params = {
        data = detail,
        anchor = (is_bag and 'L') or 'R',
        
        cb = function(d, eventname, param)
            if eventname == 'Event.OnExit' then
                self.eventDetail = nil
            end
        end
    }
    obj.btn_inf.TouchClick = function(sender)
        
        
        
        
        
        
        if self.eventDetail then
            self.eventDetail:Reset(params)
        else
            local detail_menu, detail_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemDetailMain, -1)
            detail_obj:SetParams(params)
            self.eventDetail = detail_obj
        end
        obj:Close()
        
    end

    local trans_table = { }
    if is_bag then
        
        trans_table.from = rolebag.PackType
        trans_table.to = self.selected_pack.PackType
        trans_table.Text = Text.Push
        trans_table.title = Text.StoreNumTitle
        trans_table.NumText = string.format(Text.NumFormat3, itdata.Num)

        local canDepotRole =(detail.canDepotRole and detail.canDepotRole == 1) or detail.static.NoDepotRole ~= 1
        if not canDepotRole and trans_table.to == PERSON_STORE then
            obj.btn_save.Enable = false
            obj.btn_save.IsGray = true
        end
    else
        
        trans_table.from = self.selected_pack.PackType
        trans_table.to = rolebag.PackType
        trans_table.Text = Text.Pop
        trans_table.title = Text.pickNumTitle
        trans_table.NumText = string.format(Text.pickNumAvailable, itdata.Num)
    end
    obj.btn_save.Text = trans_table.Text


    obj.btn_save.TouchClick = function(sender)
        
        if itdata.Num == 1 then
            ItemModel.TransferItemRequest(trans_table.from, itdata.Index,
            trans_table.to, 1, function()
                UpdateBagSize(self)
            end )
        else
            local function num_input_cb(input_obj, result)
                ItemModel.TransferItemRequest(trans_table.from, itdata.Index,
                trans_table.to, result, function()
                    UpdateBagSize(self)
                end )
            end
            local c = Util.GetQualityColorARGB(detail.static.Qcolor)
            local name_txt = string.format("<f color='%x'>%s</f>", c, detail.static.Name)

            
            EventManager.Fire("Event.ShowNumInput", {
                min = 1,
                max = itdata.Num,
                num = itdata.Num,
                cb = num_input_cb,
                title = trans_table.title,
                item = { icon = detail.static.Icon, quality = detail.static.Qcolor },
                txt = { name_txt, trans_table.NumText },
            } )
        end
        obj:Close()
    end

    local cvs = obj.cvs_operation
    cvs.Visible = true
    local v = itshow:LocalToGlobal()
    local v1 = cvs.Parent:GlobalToLocal(v, true)
    v1 = v1 + Vector2.New(itshow.Width, itshow.Height * 0.5)
    if v1.y + cvs.Height > cvs.Parent.Height - 15 then
        
        cvs.Y = v1.y - cvs.Height
    else
        cvs.Y = v1.y
    end

    if v1.x + cvs.Width > cvs.Parent.Width - 15 then
        
        cvs.X = v1.x - cvs.Width - itshow.Width - 10
    else
        cvs.X = v1.x + 10
    end
end

local btn_save = {
    { title = Util.GetText(TextConfig.Type.ITEM, 'storeOpPush'), eventName = "Event.SaveToStore", clickFunc = nil }
}

local btn_get = {
    { title = Util.GetText(TextConfig.Type.ITEM, 'storeOpPop'), eventName = "Event.GetFromStore", clickFunc = nil }
}

local function operateCallback(sender, name, param)

end

function _M:OnItemClick(itshow, is_bag)
    if self.itshow then
        self.itshow.IsSelected = false
    end
    
    if itshow.LastItemData then
        self.itshow = itshow
        itshow.IsSelected = true
        if itshow.LastItemData then
            local view, itemDetailMenu = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameXMDSUIItemDetail, -1, 0)
            itemDetailMenu:SetItem(itshow.LastItemData, itshow.LastItemData.IsEquip)
            local v = itshow:LocalToGlobal()
            local v1 = itemDetailMenu.cvs_detailed:GlobalToLocal(v, true)

            local trans_table = { }
            if is_bag then
                
                trans_table.from = DataMgr.Instance.UserData.RoleBag.PackType
                trans_table.to = self.selected_pack.PackType
            else
                
                trans_table.from = self.selected_pack.PackType
                trans_table.to = DataMgr.Instance.UserData.RoleBag.PackType
            end
            local function operate()
                local itdata = itshow.LastItemData
                local detail = itdata.detail
                if itdata.Num == 1 then
                    ItemModel.TransferItemRequest(trans_table.from, itdata.Index,
                    trans_table.to, 1, function()
                        UpdateBagSize(self)
                    end )
                else
                    local function num_input_cb(input_obj, result)
                        ItemModel.TransferItemRequest(trans_table.from, itdata.Index,
                        trans_table.to, result, function()
                            UpdateBagSize(self)
                        end )
                    end
                    local c = Util.GetQualityColorARGB(detail.static.Qcolor)
                    local name_txt = string.format("<f color='%x'>%s</f>", c, detail.static.Name)

                    
                    EventManager.Fire("Event.ShowNumInput", {
                        min = 1,
                        max = itdata.Num,
                        num = itdata.Num,
                        cb = num_input_cb,
                        title = trans_table.title,
                        item = { icon = detail.static.Icon, quality = detail.static.Qcolor },
                        txt = { name_txt, trans_table.NumText },
                    } )
                end
                itemDetailMenu:Close()
            end
            if is_bag then
                itemDetailMenu:setXmlPos(Vector2.New(v1.x + self.cvs_item1.Width, self.parent.Y))
                btn_save[1].clickFunc = operate
                itemDetailMenu:setButtons(btn_save, operateCallback)
            else
                itemDetailMenu:setXmlPos(Vector2.New(v1.x - self.menu.Width, self.parent.Y))
                btn_get[1].clickFunc = operate
                itemDetailMenu:setButtons(btn_get, operateCallback)
            end
        end
    end
end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function InitComponent(self, tag, parent)
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/bag/warehouse.gui.xml')
    self.menu.Enable = false
    initControls(self.menu, ui_names, self)
    self.cvs_item1.Visible = false
    self.parent = parent
    if (parent) then
        parent:AddChild(self.menu)
    end
    
    
    
    
    
    
    
    
    

    
    

    self.Container = HZItemsContainer.New()
    self.Container.IsShowNew = true
    self.Container.IsShowLockUnlock = true
    self.Container.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_item1.Size2D)
    self.Container.OnItemClik = function(con, it)
        if self.Container.Filter.Type == ItemData.TYPE_ALL
            and it.Status == HZItemShow.ItemStatus.LOCK then
            
            OpenGrid(self)
        elseif it.LastItemData then
            self:OnItemClick(it, false)
        end
    end
    self.Container:AddItemShowInitHandle('itshow', function(con, it)
        if it.LastItemData then
            Util.ItemshowExt(it, it.LastItemData.detail, it.LastItemData.IsEquip)
        end
    end )
    self.Container.IsShowStrengthenLv = true
    local filter = ItemPack.FilterInfo.New()
    filter.IsSequence = false
    filter.Type = ItemData.TYPE_ALL
    self.Container.Filter = filter
    self.filter = filter
    
    
    


    
    
    
    
    
    
    
    
end


local function Create(tag, parent)
    local ret = { }
    setmetatable(ret, _M)
    InitComponent(ret, tag, parent)
    return ret
end

local function InitItemShow(self, con, it)
    it.Enable = false
    it.IsInteractive = false
    if it.Parent then
        it.Parent.Enable = true
        it.Parent.event_PointerClick = function(sender)
            OnItemClick(self, it, true)
        end
    end
end

local function SetBag(self, bag)
    self.bag = bag
    
    
    
    
    

end


local function SwithToPack(self, pack_type)
    for _, v in ipairs(self.tbts) do
        if v.UserTag == pack_type then
            v.IsChecked = true
            break
        end
    end
end

_M.Create = Create
_M.Close = Close
_M.SetBag = SetBag
_M.SwithToPack = SwithToPack
return _M
