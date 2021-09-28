

local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = { }
_M.__index = _M
local ORANGE_MAX_SIZE = 8

local Text = {
    FormatNum = '(%d/%d)',
    noMelt = Util.GetText(TextConfig.Type.ITEM,'noMelt'),
    notSmeltNoBind = Util.GetText(TextConfig.Type.ITEM,'notSmeltNoBind'),
    notSmeltSelf = Util.GetText(TextConfig.Type.ITEM,'notSmeltSelf'),
}

















function _M:CloseMenu()
    self.menu.Visible = false
end


local function CreateMoveItemShow(cvs, template_itshow, cb)
    local srt = HZItemShow.New(cvs.Width, cvs.Height)
    srt:SetItemData(template_itshow.LastItemData)
    srt.EnableTouch = true
    cvs:AddChild(srt)
    
    
    
    local v = template_itshow:LocalToGlobal()
    local v1 = srt:GlobalToLocal(v, true)
    srt.Position2D = v1
    srt.Enable = false
    Util.ItemshowExt(srt, template_itshow.LastItemData.detail, true)
    local ma = MoveAction.New()
    ma.TargetX = 0
    ma.TargetY = 0
    ma.Duration = 0.8
    ma.ActionEaseType = EaseType.easeInOutQuad
    srt:AddAction(ma)
    ma.ActionFinishCallBack = function(sender)
        srt.Enable = true
        if cb then
            cb(sender)
        end
    end
    return srt
end

local function UpdateEquipNum(self, q, itshow, checked)
    local filter = self.filters[q]
    if filter == nil then
        return
    end
    local cvs = self.q_map[q]
    local lb_num = cvs:FindChildByEditName('lb_num', false)

    local cur =(self.selects[q] and #self.selects[q]) or 0
    if q  == GameUtil.Quality_Red or q == GameUtil.Quality_Green then
        
        if itshow then
            if checked then
                for i = 1, ORANGE_MAX_SIZE do
                    local icon = cvs:FindChildByEditName('cvs_icon' .. i, false)
                    if icon.UserTag == 0 then
                        icon.UserTag = itshow.LastItemData.Index
                        local move_show = CreateMoveItemShow(icon, itshow)
                        move_show.TouchClick = function(sender)
                            
                            if (itshow.Parent) then
                                local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
                                itshow.IsSelected = false
                                tbt_gou.IsChecked = false
                            end
                        end
                        break
                    end
                end
            else
                for i = 1, ORANGE_MAX_SIZE do
                    local icon = cvs:FindChildByEditName('cvs_icon' .. i, false)
                    if icon.UserTag == itshow.LastItemData.Index then
                        Util.RemoveChildrenWithType(icon, 'HZItemShow')
                        icon.UserTag = 0
                        break
                    end
                end
            end
        end
    else
        local tbt_gou = cvs:FindChildByEditName('tbt_gou', false)
        if itshow and not checked then
            tbt_gou.IsChecked = false
        end
        local lb_title = cvs:FindChildByEditName('lb_title', false)
        local text = Util.GetText(TextConfig.Type.ITEM, "melting" .. q)
        if text and lb_title~=nil then
            lb_title.Text = string.format(text, cur, filter.ItemCount)
        end
        if (cur < filter.ItemCount or filter.ItemCount == 0) then
            tbt_gou.IsChecked = false
        else
            tbt_gou.IsChecked = true
        end
    end
    self.lb_cost_num.Text = self.gold_num
end 


local function GetCost(detail)
    local search_t = { EquipQColor = detail.static.Qcolor, MeltLevel = detail.static.MeltLevel }
    local ret = GlobalHooks.DB.Find('MeltConfig', search_t)
    return unpack(ret)
end


local function CheckCanSelect(self, detail, showTips)
    local self_pro = DataMgr.Instance.UserData.Pro
    local canMelt = detail.static.NoMelt ~= 1
    local bindEquip = not self.tbt_gou_bind.IsChecked or detail.bindType == 1
    local otherPro = not self.tbt_gou_pro.IsChecked or detail.equip.pro ~= self_pro
    if showTips then
        if not canMelt then
            GameAlertManager.Instance:ShowNotify(Text.noMelt)
        elseif not bindEquip then
            GameAlertManager.Instance:ShowNotify(Text.notSmeltNoBind)
        elseif not otherPro then
            GameAlertManager.Instance:ShowNotify(Text.notSmeltSelf)
        end
    end
    return canMelt and bindEquip and otherPro
end


local function NotifySelect(self, checked, itshow)
    local detail = ItemModel.GetItemDetailById(itshow.LastItemData.Id)
    if not detail then return end
    local detail = ItemModel.GetItemDetailById(itshow.LastItemData.Id)

    local count = 0







    local ret = GetCost(detail)
    if checked then
        self.spec_count = self.spec_count + count
        self.selects[itshow.Quality] = self.selects[itshow.Quality] or { }
        table.insert(self.selects[itshow.Quality], itshow.LastItemData.Index)
        self.gold_num = self.gold_num + ret.CostGold
    else
        self.selects[itshow.Quality] = self.selects[itshow.Quality] or { }
        local q_all = self.selects[itshow.Quality]
        for i, v in ipairs(q_all) do
            if v == itshow.LastItemData.Index then
                self.gold_num = self.gold_num - ret.CostGold
                self.spec_count = self.spec_count - count
                table.remove(q_all, i)
                break
            end
        end
    end
    UpdateEquipNum(self, itshow.Quality, itshow, checked)
end


local function SetMeltSelected(self, checked, itshow)
    if itshow:GetCustomAttribute('melt_selectd') ~= tostring(checked) then
        itshow:SetCustomAttribute('melt_selectd', tostring(checked))
        NotifySelect(self, checked, itshow)
    end
end


local function OnQualitySelected(self, q, checked)
    local showdata = self.bag.Container.Filter.ShowData
    for i = 1, showdata.Count do
        local itshow = self.bag.Container:GetItemShowAt(i)
        if itshow.LastItemData and itshow.Quality == q then
            local detail = ItemModel.GetItemDetailById(itshow.LastItemData.Id)
            
            if CheckCanSelect(self, detail) then
                if detail.equip.isIdentfied ~= 1 or not
                    (detail.equip.enLevel > 0 or detail.equip.magicDes or detail.equip.jewelAtts) then
                    if itshow.Parent then
                        local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
                        tbt_gou.IsChecked = checked
                    end
                    SetMeltSelected(self, checked, itshow)
                end
            end
        end
    end
end

local function ReCheckSelects(self)
    local cvs = self.cvs_choose5
    for i = 1, ORANGE_MAX_SIZE do
        local icon = cvs:FindChildByEditName('cvs_icon' .. i, false)
        local itshow = Util.GetFirstChildWithType(icon, 'HZItemShow')
        if itshow and not CheckCanSelect(self, itshow.LastItemData.detail) then
            local cost = GetCost(itshow.LastItemData.detail)
            Util.RemoveChildrenWithType(icon, 'HZItemShow')
            icon.UserTag = 0 


        end
    end
    local select_q = { }
    for q, cvs in pairs(self.q_map) do
        local tbt_gou = cvs:FindChildByEditName('tbt_gou', false)
        if tbt_gou and tbt_gou.IsChecked then
            select_q[q] = tbt_gou
        end
    end

    local itlist = { }
    self.bag.Container:ForEachAllItemShow( function(con, itshow)
        if itshow.LastItemData and not CheckCanSelect(self, itshow.LastItemData.detail) then
            if itshow.Parent then
                local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
                tbt_gou.IsChecked = false
            end
            SetMeltSelected(self, false, itshow)
        end
    end )

    for q, tbt_gou in pairs(select_q) do
        OnQualitySelected(self, q, true)
        tbt_gou.IsChecked = true
    end


end

local function CleanSelects(self)
    
    self.selects = { }
    local cvs = self.cvs_choose5
    for i = 1, ORANGE_MAX_SIZE do
        local icon = cvs:FindChildByEditName('cvs_icon' .. i, false)
        Util.RemoveChildrenWithType(icon, 'HZItemShow')
        icon.UserTag = 0
    end
    for q, cvs in pairs(self.q_map) do
        local tbt_gou = cvs:FindChildByEditName('tbt_gou', false)
        if tbt_gou then
            tbt_gou.IsChecked = false
        end
    end

    self.gold_num = 0
    self.spec_count = 0
    for q = GameUtil.Quality_Default, GameUtil.Quality_Red do
        UpdateEquipNum(self, q)
    end
    if self.bag then
        self.bag.Container:ForEachAllItemShow( function(con, itshow)
            if itshow.LastItemData then
                if itshow.Parent then
                    local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
                    tbt_gou.IsChecked = false
                end
                itshow:SetCustomAttribute('melt_selectd', tostring(false))
            end
        end )
    end
end


local function OnEquipMeltSuccess(self, data)
    
    
    self.ib_succeed.Visible = true

    self.ib_succeed:SetAnchor(Vector2.New(0.5, 0.5))
    self.ib_succeed.Scale = Vector2.New(2, 2)

    local control = self.ib_succeed.Layout.SpriteController
    self.btn_smelt.Enable = false
    self.menu.Enable = true
    control:PlayAnimate(0, 1, function(sender)
        self.btn_smelt.Enable = true
        self.menu.Enable = false
        self.ib_succeed.Visible = false
    end )
    CleanSelects(self)

end

local function GetQualitySelectCount(self, q)
    return(self.selects[q] and #self.selects[q]) or 0
end

local function RequestEquipMelt(self)

    local indexs = { }
    for _, v in pairs(self.selects) do
        for __, index in ipairs(v) do
            table.insert(indexs, index)
        end
    end
    
    local count_green = GetQualitySelectCount(self, GameUtil.Quality_Green)
    local count_red = GetQualitySelectCount(self, GameUtil.Quality_Red)
    local count =  count_green + count_red
    print(count)
    if count > 0 then
        GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL,
        Util.GetText(TextConfig.Type.ITEM, 'meltWarn'),
        '', '', Util.GetText(TextConfig.Type.ITEM, 'meltWarnTitle'), nil,
        function()
            ItemModel.EquipSmeltRequest(indexs, function(data)
                
                 for i=1,count_orange+count_green,1 do
                     local iconitem = self.cvs_choose5:FindChildByEditName('cvs_icon' .. i, false)
                     Util.showUIEffect(iconitem,20)
                 end

                 CleanSelects(self)

                 
                 
            end )
        end ,
        function() end)
        
    else
        ItemModel.EquipSmeltRequest(indexs, function(data)
            
            CleanSelects(self)
            
            
            
        end )
    end

    self.tbn_choose.IsChecked = false
    
end


local function InitQualityChoose(self)
    self.q_map = {          
        [GameUtil.Quality_Default] = self.cvs_choose1,
        [GameUtil.Quality_Blue] = self.cvs_choose2,
        [GameUtil.Quality_Purple] = self.cvs_choose3,
        [GameUtil.Quality_Orange] = self.cvs_choose4,
        [GameUtil.Quality_Green] = self.cvs_choose5,
        [GameUtil.Quality_Red] = self.cvs_choose5
    }
    self.filters = { }
    self.selects = { }
    local function notify_cb(q, pack, status, index)
        if status ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
            UpdateEquipNum(self, q)
        elseif table.getCount(self.selects) then
            CleanSelects(self)
        end
    end

    for q, cvs in pairs(self.q_map) do
        local tbt_gou = cvs:FindChildByEditName('tbt_gou', false)
        if tbt_gou then
            tbt_gou.IsChecked = false
            tbt_gou.TouchClick = function(sender)
                OnQualitySelected(self, q, sender.IsChecked)
            end
        end
    end

    for q = GameUtil.Quality_Default, GameUtil.Quality_Red do
        local filter = ItemPack.FilterInfo.New()
        filter.Type = ItemData.TYPE_EQUIP
        self.filters[q] = filter
        filter.CheckHandle = function(item)
            return(item.Quality == q and item.detail.static.NoMelt ~= 1)
        end
        filter.NofityCB = function(pack, status, index)
            notify_cb(q, pack, status, index)
        end
    end

end

function _M:OnEnter()
    

    local select_q = { }
    for q, cvs in pairs(self.q_map) do
        local tbt_gou = cvs:FindChildByEditName('tbt_gou', false)
        if tbt_gou and tbt_gou.IsChecked then
            select_q[q] = tbt_gou
        end
    end

    CleanSelects(self)

    local role_bag = DataMgr.Instance.UserData.RoleBag
    for _, filter in pairs(self.filters) do
        role_bag:AddFilter(filter)
    end

    for q, tbt in pairs(select_q) do
        tbt.IsChecked = true
        OnQualitySelected(self, q, true)
    end

    GlobalHooks.Drama.Start("guide_melt", true)
end

local function OnExit(self)
    
    if self.bag then
        self.bag.btn_apart.IsChecked = false
    end
    local role_bag = DataMgr.Instance.UserData.RoleBag
    for _, filter in pairs(self.filters) do
        role_bag:RemoveFilter(filter)
    end
    self.bag.Container:ForEachAllItemShow( function(con, itshow)
        if itshow.Parent then
            local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
            tbt_gou.Visible = false
            tbt_gou.Selected = nil
            tbt_gou.IsChecked = false
        end
    end )
    self.bag.Container:RemoveItemShowInit('melt')
    self.select_pack = nil
    self.bag = nil
    self.menu.Enable = false
    
    self.btn_smelt.Enable = true
    self.tbn_choose.IsChecked = false
end

local function OnDestory(self)
    
end

local ui_names =
{
    
    
    { name = 'cvs_choose1' },
    { name = 'cvs_choose2' },
    { name = 'cvs_choose3' },
    { name = 'cvs_choose4' },
    { name = 'cvs_choose5' },
    { name = 'lb_cost_num' },
    { name = "ib_title" },
    { name = 'btn_smelt', click = RequestEquipMelt },
    
    {
        name = 'btn_set',
        click = function(self)

        end
    },
    { name = 'tbn_choose' },
    { name = 'cvs_choose' },
    { name = "cvs_chooseBack"},
    {
        name = 'tbt_gou_bind',
        click = function(self)
            ReCheckSelects(self)
        end
    },
    {
        name = 'tbt_gou_pro',
        click = function(self)
            ReCheckSelects(self)
        end
    },
    {
        name = 'tbh_bind',
    },
    {
        name = 'tbh_pro',
    },
    
    
    
}

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
    
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/bag/smelt.gui.xml')
    self.menu.Enable = false
    initControls(self.menu, ui_names, self)
    if (parent) then
        parent:AddChild(self.menu)
    end
    
    
    
    
    
    
    
    
    
    InitQualityChoose(self)
    self.cvs_chooseBack.IsInteractive = true
    self.tbh_bind.Enable = true
    self.tbh_bind.IsInteractive = true
    self.tbh_bind.event_PointerClick = function(sender)
        self.tbt_gou_bind.IsChecked = not self.tbt_gou_bind.IsChecked
        ReCheckSelects(self)
    end
    self.tbh_pro.Enable = true
    self.tbh_pro.IsInteractive = true
    self.tbh_pro.event_PointerClick = function(sender)
        self.tbt_gou_pro.IsChecked = not self.tbt_gou_pro.IsChecked
        ReCheckSelects(self)
    end
    
    if GameSetting.GetValue("tbt_gou_pro")~=nil and GameSetting.GetValue("tbt_gou_bind")~=nil then
         self.tbt_gou_pro.IsChecked = GameSetting.GetValue("tbt_gou_pro") == 0
    
         self.tbt_gou_bind.IsChecked = GameSetting.GetValue("tbt_gou_bind") == 0
    end
    self.cvs_chooseBack.event_PointerClick = function(sender)
        self.tbn_choose.IsChecked = false
        
        GameSetting.AddDiskKey("tbt_gou_bind")
        GameSetting.SetValue("tbt_gou_bind" , self.tbt_gou_bind.IsChecked and 0 or 1)  
        GameSetting.AddDiskKey("tbt_gou_pro")
        GameSetting.SetValue("tbt_gou_pro" , self.tbt_gou_pro.IsChecked and 0 or 1) 
    end
    self.tbn_choose.Selected = function(sender)
        self.cvs_chooseBack.Visible = sender.IsChecked
    end
end



local function Create(tag, parent)
    local ret = { }
    setmetatable(ret, _M)
    InitComponent(ret, tag, parent)
    return ret
end




local function OnMeltItemSelect(self, sender)
    local itshow = sender.Parent:GetChildAt(0)
    if itshow:GetCustomAttribute('melt_selectd') == tostring(true) and sender.IsChecked then
        return
    end
    local isSpec = itshow.LastItemData.Quality == GameUtil.Quality_Red or
    itshow.LastItemData.Quality == GameUtil.Quality_Green
    local count_green = GetQualitySelectCount(self, GameUtil.Quality_Green)
    local count_red = GetQualitySelectCount(self, GameUtil.Quality_Red)
    local count = count_green + count_red
    self.spec_count = count + 1
    if isSpec and sender.IsChecked and count == ORANGE_MAX_SIZE then
        sender.IsChecked = false
        GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.ITEM, 'meltSelectWarn'))
    else
        SetMeltSelected(self, sender.IsChecked, itshow)
    end
end

function _M:SelectItem(node, itemData)
    local tbt_gou = node:FindChildByEditName('tbt_gou', false)
    local detail = itemData.detail
    tbt_gou.Selected = function(sender)
        if CheckCanSelect(self, detail) then
            OnMeltItemSelect(self, sender)
        end
    end
    if tbt_gou.IsChecked then
        if not CheckCanSelect(self, detail, true) then
            tbt_gou.IsChecked = false
        end
        tbt_gou.IsChecked = false
    else
        tbt_gou.IsChecked = true
    end
    return tbt_gou.IsChecked
end

local function ItemShowInit(self, con, itshow)
    if not itshow.LastItemData or not itshow.Parent then return end
    local tbt_gou = itshow.Parent:FindChildByEditName('tbt_gou', false)
    tbt_gou.Visible = true
    if itshow:GetCustomAttribute('melt_selectd') == tostring(true) then
        tbt_gou.IsChecked = true
    else
        tbt_gou.IsChecked = false
    end
    local detail = itshow.LastItemData.detail
    tbt_gou.Selected = function(sender)
        if CheckCanSelect(self, detail) then
            OnMeltItemSelect(self, sender)
        end
    end
    tbt_gou.TouchClick = function(sender)
        if sender.IsChecked then
            if not CheckCanSelect(self, detail, true) then
                sender.IsChecked = false
            end
        end
        self.tbn_choose.IsChecked = false
    end
end

local function SetBag(self, bag)
    self.bag = bag
    self.bag.Container:RemoveItemShowInit("melt")
    self.bag.Container:RemoveItemShowInit("normal")
    self.bag.Container:AddItemShowInitHandle('melt', function(con, it)
        ItemShowInit(self, con, it)
    end )
end

_M.Create = Create
_M.SetBag = SetBag

return _M
