


local cjson = require "cjson"

local Util = require 'Zeus.Logic.Util'
local Helper = require 'Zeus.Logic.Helper'
local DetailModel = require 'Zeus.Model.Item'
local DetailFormat = require "Zeus.UI.ItemDetailMenu"
local Text = require 'Zeus.Logic.Text'
local CardRq = require "Zeus.Model.Card"
local Player = require "Zeus.Model.Player"

local POS_LEFT = 2.7

local POS_RIGHT


local _M = { }
_M.__index = _M



local running_stack = { }

local function PushRunning(e)
    table.insert(running_stack, e)
end

local function PeekRunning()
    return running_stack[#running_stack]
end


local function PopRunning()
    table.remove(running_stack)
end


local function CallBack(self, name, param)
    if self.cb then
        self.cb(self, name, param)
    end
end

local function OnExit(self)
    CallBack(self, 'Event.OnExit')
end

local function Close(self)
    if self then
        OnExit(self)
        if self.menu then
            self.menu:Close()
        end
        CallBack(self, 'Event.InternalClose')
    end
end


local function CheckItem(self)
    if self.item and self.item.Id and self.item.Id ~= '' then
        self.item = DetailModel.GetItemById(self.item.Id)
    end
end

local function OnCardSubmit(self)
    
    
    
    local BcardLVUp = false
    local cardlist = Player.GetBindPlayerData().cardIdList
    

    for k, v in pairs(cardList) do
        if v.id + 0 == self.item.TemplateId + 0 then
            BcardLVUp = true
        end
    end

    if BcardLVUp == false then
        local allcard = CardRq.GetAllCardInfo().s2c_card
        if allcard == nil then allcard = { } end
        for k, v in pairs(allcard) do
            if (v.isActive ~= 0) and(v.levelUpItemId + 0 == self.item.TemplateId + 0) then
                BcardLVUp = true
            end
        end
    end

    if BcardLVUp then
        CardRq.CardPreLevelUpRequest(self.item.TemplateId, function()
            Close(self)
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUICardUpLv, 0, CardRq.GetPreLvUPCard().s2c_card.id)
        end )
    else
        CardRq.CardRegistRequest(self.item.TemplateId, function()
            Close(self)
        end )
    end
end

local function OnUnEquip(self)
    CheckItem(self)
    
    if self.item then
        DetailModel.UnEquipItem(self.item.Index, function()
            EventManager.Fire("Event.PageUIProperty.HideEffect",{})
            CallBack(self, 'Event.UnEquipItem', self.item)
            Close(self)
        end )
    end
end

local function OnEquip(self)
    CheckItem(self)
    local function DoEquip()
        if self.item then
            DetailModel.EquipItem(self.item.Index, function()
                EventManager.Fire("Event.PageUIProperty.ShowEffect",{item = self.item})
                CallBack(self, 'Event.EquipItem', self.item)
                CallBack(self, 'Event.OnUseItemClean', self.item)
                Close(self)
            end )
            
        end
    end
    if self.detail.bindType ~= 1 then
        
        GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL,
        Util.GetText(TextConfig.Type.ITEM, 'bindTips'),
        '',
        '', nil,
        function()
            DoEquip()
        end ,
        function() end)
    else
        DoEquip()
    end

end

local function OnDiscardItem(self)
    CheckItem(self)
    DataMgr.Instance.UserData:DiscardBagItem(self.item.Index, 1)
    Close(self)
end


local function OnShowCompareMenu(self)
    if self.compareMenu then
        self.menu.Enable = false
        self.compareMenu:Close()
        self.compareMenu = nil
    else
        
        local score_compare = 0
        if self.detail.equip then
            if self.detail.equip.score > self.cmpDetail.equip.score then
                score_compare = -1
            elseif self.detail.equip.score < self.cmpDetail.equip.score then
                score_compare = 1
            end
        end

        local cmp = DetailFormat.CreateWithXml(self.cmpDetail, score_compare)
        local ib_vs = cmp.menu:GetComponent('ib_vs')
        ib_vs.Visible = true
        local rootBg1 = cmp.menu:GetComponent('cvs_GearInfo')
        self.menu.Enable = true
        local closeBtn = cmp.menu:GetComponent('btn_Close')

        closeBtn.TouchClick = function(sender)
            OnShowCompareMenu(self)
        end
        local ib_mine = cmp.menu:GetComponent('ib_mine')
        ib_mine.Visible = true
        self.menu:AddSubMenu(cmp.menu)
        self.compareMenu = cmp
        rootBg1.X = POS_RIGHT
    end
end

















local function OnSellItem(self)
  CheckItem(self)
  local item = self.item

  if item == nil then
    return
  end
  
  local c = Util.GetQualityColorARGB(item.Quality)
  
  
  if item.Type <= 10 then 
    local indexs = {} 
        table.insert(indexs,item.Index)
        if item.Quality > GameUtil.Quality_Purple then
            
            local ctxt = Util.GetQualityConfig(item.Quality).Name
            local txt = Util.GetText(TextConfig.Type.ITEM, 'meltWarn')
            txt = string.format(txt, c, ctxt)
            GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL,
            txt,
            '',
            '',
            Util.GetText(TextConfig.Type.ITEM, 'meltWarnTitle'),
            nil,
            function()
                DetailModel.EquipSmeltRequest(indexs, function (data)
                    
                     CallBack(self, 'Event.OnSellItemClean', self.item)
                    Close(self)
                end)
                
            end ,
            function() end
            )
        else
            DetailModel.EquipSmeltRequest(indexs, function(data)
                
                Close(self)
                CallBack(self, 'Event.OnSellItemClean', self.item)
            end)
        end
  elseif item.Type == ItemData.TYPE_TASK then
    local indexs = {} 
        table.insert(indexs,item.Index)
        if item.Quality > GameUtil.Quality_Purple then
            
            local ctxt = Util.GetQualityConfig(item.Quality).Name
            local txt = Util.GetText(TextConfig.Type.ITEM, 'bloodMeltWarn')
            txt = string.format(txt, c, ctxt)
            GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL,
            txt,
            '',
            '',
            Util.GetText(TextConfig.Type.ITEM, 'meltWarnTitle'),
            nil,
            function()
                DetailModel.EquipSmeltRequest(indexs, function (data)
                    
                     CallBack(self, 'Event.OnSellItemClean', self.item)
                    Close(self)
                end)
                
            end ,
            function() end
            )
        else
            DetailModel.EquipSmeltRequest(indexs, function(data)
                
                Close(self)
                CallBack(self, 'Event.OnSellItemClean', self.item)
            end)
        end
  else  
    if item.MaxNum > 1 then    
      local name_txt = string.format("<f color='%x'>%s</f>",c,self.detail.static.Name)
      local num_format = Util.GetText(TextConfig.Type.ITEM,'sellNumAvailable')

      num_format = string.format(num_format,item.Num)
      local CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costGold')
      local scale = 1
      local ele = unpack(GlobalHooks.DB.Find('Parameters',{ParamName='NpcShop.ItemPrice.CutRate'}))
      if ele then
        scale = ele.ParamValue * 0.01
      end
      local function num_input_cb(input_obj,result)
        local pre_num = item.Num
        DetailModel.SellItem(item.Index, result)
        if result == pre_num then
            CallBack(self, 'Event.OnSellItemClean', self.item)
         else
             CallBack(self, 'Event.SellItem', self.item)
        end
      end
      Close(self)
      local unit_price = Util.GetRounding(self.detail.static.Price * scale)
      local function num_change(input_obj, num)
        input_obj.tb_cost.XmlText = string.format(CostDiamond,num * unit_price)
      end
      EventManager.Fire("Event.ShowNumInput",{
        min=1,max=item.Num,num=item.Num,
        cb=num_input_cb,
        change_cb=num_change,
        title=Util.GetText(TextConfig.Type.ITEM,'sellNumTitle'),
        item={icon=item.IconId,quality=item.Quality},
        txt={name_txt,num_format},
      })    
    else
      if item.Quality >= GameUtil.Quality_Purple then
        
        local ctxt = Util.GetQualityConfig(item.Quality).Name
        local txt = Util.GetText(TextConfig.Type.ITEM,'sellWarn')
        txt = string.format(txt,c,ctxt)
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL,
            txt,
            '',
            '',
            Util.GetText(TextConfig.Type.ITEM,'sellWarnTitle'),
            nil,
            function ()
              DetailModel.SellItem(item.Index, 1) 
              CallBack(self, 'Event.OnSellItemClean', self.item)
              Close(self)              
            end,
            function() end
        )
      else
        DetailModel.SellItem(item.Index, 1)
        CallBack(self, 'Event.OnSellItemClean', self.item)
        Close(self)       
      end
    end
  end
end

local function OnIdentifyEquip(self)
    CheckItem(self)
    local item = self.item
    DetailModel.IdentifyEquip(item.Index, function()
        local ib_effects = self.detailMenu.menu:GetComponent('ib_effects')
        ib_effects:SetAnchor(Vector2.New(0.5, 0.5))
        ib_effects.Scale = Vector2.New(2, 2)
        ib_effects.Visible = true
        local control = ib_effects.Layout.SpriteController
        control:PlayAnimate(0, 1, function(sender)
            ib_effects.Visible = false
            CallBack(self, 'Event.IdentifyEquip', item)
        end )
    end )
end



local function OnUseItem(self)
    CheckItem(self)
    local item = self.item
    if item.Num > 1 and item.Type ~= ItemData.TYPE_POTION then
        local c = Util.GetQualityColorARGB(item.Quality)
        local name_txt = string.format("<f color='%x'>%s</f>", c, self.detail.static.Name)
        local num_format = Util.GetText(TextConfig.Type.ITEM, 'storeGridFmt3')

        num_format = string.format(num_format, item.Num)
        local scale = 1
        local ele = unpack(GlobalHooks.DB.Find('Parameters', { ParamName = 'NpcShop.ItemPrice.CutRate' }))
        if ele then
            scale = ele.ParamValue * 0.01
        end
        local function num_input_cb(input_obj, result)
            local pre_num = item.Num
            DetailModel.UseItemRequest(item.Index, result, function(items)
                if items then
                    EventManager.Fire('Event.OnShowNewItems', { items = items })
                end
                if result == pre_num then
                    CallBack(self, 'Event.OnUseItemClean', self.item)
                    Close(self)
                else
                    CallBack(self, 'Event.OnUseItem', self.item)
                end
            end )
        end

        

        EventManager.Fire("Event.ShowNumInput", {
            min = 1,
            max = item.Num,
            num = item.Num,
            cb = num_input_cb,
            title = Util.GetText(TextConfig.Type.ITEM,'useNumTitle'),
            item = { icon = item.IconId, quality = item.Quality },
            txt = { name_txt, num_format },
        } )
    else
        local num = item.Num
        DetailModel.UseItemRequest(item.Index, 1, function(items)
            if items then
                EventManager.Fire('Event.OnShowNewItems', { items = items })  
            end
            if num == 1 then
                CallBack(self, 'Event.OnUseItemClean', self.item)    
            end 
            Close(self)
        end )
    end
end

local function UpMedalItem(self)
    
    
    Close(self)
end

local function OnEntryStrengthen(self)
    local id = self.item.Id
    Close(self)
    local menu, obj = GlobalHooks.OpenUI(
    GlobalHooks.UITAG.GameUIStrengthenMain, -1,
    tostring(GlobalHooks.UITAG.GameUIStrengthen))
    if menu then
        obj:SetSelectItem(id)
    end
end

local function SetBackGround(self, var)
    if var then
        self.menu.Enable = true
        local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png', LayoutStyle.IMAGE_STYLE_BACK_4, 8)
        self.menu:SetFullBackground(lrt)
    else
        self.menu:SetFullBackground(nil)
    end
end


local function OnItemCombine(self)
    if self.combine then
        self.combine:Close()
    else
        local menu, obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIItemCombine, 0)
        if not menu then
            return
        end
        self.menu:AddSubMenu(menu)
        self.combine = obj

        local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png', LayoutStyle.IMAGE_STYLE_BACK_4, 8)
        self.menu:SetFullBackground(lrt)
        self.menu.Enable = true

        obj:SubscribOnExit( function()
            self.combine = nil
            self.menu.Enable = false
            self.menu:SetFullBackground(nil)
        end )
        obj:SetCombineID(self.detail.static.DestID, self.item.Index)
    end

end

local function OnItemInlay(self)
    
    
    
    
    
    
end





local button_text = {
    ['Event.SellItem'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnSell'), func = OnSellItem },
    ['Event.EquipItem'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnEquip'), func = OnEquip },
    ['Event.UnEquipItem'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnUnequip'), func = OnUnEquip },
    ['Event.DiscardItem'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnDiscard'), func = OnDiscardItem },
    ['Event.IdentifyEquip'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnIdentify'), func = OnIdentifyEquip },
    
    
    ['Event.UseItem'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnUse'), func = OnUseItem },
    ['Event.UpMedalItem'] = { txt = Util.GetText(TextConfig.Type.MEDAL, 'medal_levelup'), func = UpMedalItem },
    ['Event.EntryStrengthen'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnStrengthen'), func = OnEntryStrengthen },
    ['Event.EquipCompare'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnCompare'), func = OnShowCompareMenu },
    ['Event.CloseItemDetail'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'btnClose'), func = Close },
    ['Event.ItemCombine'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'combine'), func = OnItemCombine },
    ['Event.JewelryInlay'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'inset'), func = OnItemInlay },
    ['Event.SaveToStore'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'storeOpPush') },
    ['Event.GetFromStore'] = { txt = Util.GetText(TextConfig.Type.ITEM, 'storeOpPop') }
}

function _M:bindBtnEvent(btn, key, clickFunc)
    btn.TouchClick = function(sender)
        self.touched_btn = sender
        if clickFunc then
            clickFunc()
        else
            local func =(button_text[key] and button_text[key].func) or nil
            if func then
                func(self)
            end
        end

        self.touched_btn = nil
    end
end

local function TryCreateBtn(self, str, event)
    local menu = self.detailMenu.menu
    local btn = menu:GetComponent(str)
    if not event or not btn then
        return false
    end

    btn.Visible = true
    if type(event) == 'table' then
        btn.Text = event.text
        Util.HZClick(btn, function(sender, e)
            event.callback(self, event)
        end )
    elseif type(event) == 'string' then
        local is_equip =(self.detail.equip and true) or false
        local is_identify = false
        if is_equip and self.detail.equip.isIdentfied == 1 then
            is_identify = true
        end

        if event == 'Event.EquipItem' and not(is_equip and is_identify) then
            btn.Visible = false
            return false
        elseif event == 'Event.EntryStrengthen' then
            local bl = GlobalHooks.CheckFuncWaitToPlay("Strengthen") or GlobalHooks.CheckFuncWaitToPlay("SetNew") or GlobalHooks.CheckFuncWaitToPlay("Enchant")
            menu:GetComponent("lb_bj_strengthen").Visible = bl
        elseif event == 'Event.IdentifyEquip' and not(is_equip and not is_identify) then
            
            btn.Visible = false
            return false
        elseif event == 'Event.EquipCompare' then
            if not is_identify then
                btn.Visible = false
                return false
            else
                local detail = DetailModel.GetLocalCompareDetail(self.detail.itemSecondType)
                self.cmpDetail = detail
                if not self.cmpDetail then
                    btn.Visible = false
                    return false
                else
                    btn.LayoutDown = XmdsUISystem.CreateLayoutFroXml('#static_n/static_pic/static001.xml|static001|126', LayoutStyle.IMAGE_STYLE_ALL_9, 20)
                    btn.SetPressDown = function()
                        return self.compareMenu ~= nil
                    end
                end
            end
        elseif event == 'Event.ItemCombine' then
            
            if not self.detail.static.DestID or self.detail.static.DestID <= 0 then
                btn.Visible = false
                return false
            else
                btn.LayoutDown = XmdsUISystem.CreateLayoutFroXml('#static_n/static_pic/static001.xml|static001|126', LayoutStyle.IMAGE_STYLE_ALL_9, 20)
                btn.SetPressDown = function()
                    return self.combine ~= nil
                end
            end
        elseif event == 'Event.UseItem' then
            local check =(self.detail.static.IsApply == 1)
            if not check then
                btn.Visible = false
                return false
            end
        elseif event == 'Event.UseAllItem' then
            local check =(self.detail.static.IsApply == 1)
            if not check or self.item.Num <= 1 then
                btn.Visible = false
                return false
            end
        elseif event == 'Event.SellItem' and self.detail.static.NoSell == 1 then
            btn.Visible = false
            return false
        elseif event == 'Event.JewelryInlay' and self.item.Type ~= ItemData.TYPE_BIJOU then
            btn.Visible = false
            return false
        end
        btn.Text =(button_text[event] and button_text[event].txt) or 'undefined'
        btn.TouchClick = function(sender)
            self.touched_btn = sender
            local func =(button_text[event] and button_text[event].func) or nil
            if func then
                func(self)
            end
            self.touched_btn = nil
        end
        
    end
    return true
end

local function OnShowBtnClick(self)
    
    local ChatUIItemShow = require "Zeus.UI.Chat.ChatUIItemShow"
    ChatUIItemShow.ShowItemClick(self.detail)
end

local function CreateBtn(self, btnData)
    local count = 0
    local index = 1
    local btns = { btnData.button1, btnData.button2, btnData.button3, btnData.button4 }


    for i = 1, #btns do
        local createOk = false
        local btnStr = 'btn_' .. i
        while not createOk do
            if index > #btns then
                break
            end
            createOk = TryCreateBtn(self, btnStr, btns[index])
            index = index + 1
        end
        if createOk then
            count = count + 1
        end
    end
    self.detailMenu:ResetButtonPos(self.anchor)

    local btn_show = self.detailMenu.menu:GetComponent('btn_show')
    if btn_show then
        if btnData.show_sidebtn then
            btn_show.Visible = true
            btn_show.TouchClick = function()
                OnShowBtnClick(self)
            end
        else
            btn_show.Visible = false
        end
    end

    return count
end 


local function SubscribCallBack(self, cb)
    self.cb = cb
end

local function GetData(self)
    return self.detail
end

function _M.Close(self)
    CallBack(self, 'Event.ExternClose')
    if self.menu then
        self.menu:Close()
    end
end

local function ParseParams(self, params)
    
    local menu = self.detailMenu.menu
    local rootBg = menu:GetComponent('cvs_GearInfo')
    SubscribCallBack(self, params.cb)
    if not POS_RIGHT then
        POS_RIGHT = rootBg.X
    end
    self.anchor = params.anchor
    if type(self.anchor) == 'table' and #self.anchor >= 2 then
        
        
        local offset = Vector2.New(self.anchor[3] or 0, self.anchor[4] or 0)
        XmdsUISystem.AroundRelativeNode(self.anchor[1], rootBg, self.anchor[2], offset)
    elseif params.anchor == 'L' then
        rootBg.X = POS_RIGHT - rootBg.Width
    elseif params.anchor == 'R' then
        rootBg.X = POS_RIGHT
    elseif params.x or params.y then
        if params.x then
            rootBg.X = params.x
        end
        if params.y then
            rootBg.Y = params.y
        end
    else
        rootBg.X =(menu.mRoot.Width - rootBg.Width) * 0.5
        
    end

    local close_btn = menu:GetComponent('btn_Close')
    close_btn.TouchClick = function(sender)
        Close(self)
    end
    if self.detail then
        CreateBtn(self, params)
    end
end






local function CreateShowMenu(self, params)

    
    

    self.detailMenu = DetailFormat.CreateWithXml(self.detail, params.score_compare)
    if type(params.anchor) == 'table' then
        self.detailMenu.menu:SubscribOnEnter( function()
            ParseParams(self, params)
        end )
    else
        ParseParams(self, params)
    end

    self.menu:AddSubMenu(self.detailMenu.menu)

    
end


local function GetItemDetailAndItem(params)
    local detail, item
    if params.data then
        detail = params.data
        item = params.item
    elseif params.id then
        item = params.item or DetailModel.GetItemById(params.id)
        detail = DetailModel.GetItemDetailById(params.id)
        if item and detail then
            detail.item = { num = item.Num }
        end
    elseif params.templateId then
        item = params.item
        detail = DetailModel.GetItemDetailByCode(params.templateId)
    end
    return detail, item
end

local function SetParams(self, params)
    local function Show()
        if self.detailMenu then
            self.detailMenu:Reset(self.detail, params.score_compare)
            ParseParams(self, params)
        else
            CreateShowMenu(self, params)
        end
    end
    local detail, item = GetItemDetailAndItem(params)
    self.detail = detail
    self.item = item
    Show()
end

local function SetItem(self, item)
    self.item = item
    self.detail = self.item.detail
end















local itemDetailSingles = { }

local function OnShowItemDetail(eventname, params)
    local menu, obj = nil, nil
    local singleId = params.singleId
    if singleId then
        local single = itemDetailSingles[singleId]
        if not single then
            menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemDetailMain, -1)
            single = { menu, obj }
            itemDetailSingles[singleId] = single
        end
        menu, obj = single[1], single[2]
        if single[3] then
            single[3].IsSelected = false
        end
        single[3] = params.itemShow
        if single[3] then
            single[3].IsSelected = true
        end
        local cb = params.cb
        params.cb = function(xxx, evtName)
            if evtName == "Event.OnExit" then
                itemDetailSingles[singleId] = nil
                if single[3] then
                    single[3].IsSelected = false
                    if cb then cb(xxx, eventname) end
                end
            end
        end
    else
        menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemDetailMain, -1)
        menu.Enable = true
        menu.event_PointerClick = function(sender)
            Close(obj)
        end
    end
    
    
    obj:SetParams(params)
end


local function OnShowItemDetailTips(eventname, params)
    local detail, item = GetItemDetailAndItem(params)
    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail, -1)
    obj:Set(detail)
end

local function CloseItemDetail(eventname, params)
    if params.singleId then
        local single = itemDetailSingles[params.singleId]
        if single then
            itemDetailSingles[params.singleId] = nil
            single[1]:Close()
            if single[3] then
                single[3].IsSelected = false
            end
        end
    else
        local self = PeekRunning()
        if self then
            if params.id then
                if self.detail.id == params.id then
                    Close(self)
                end
            else
                Close(self)
            end
        end
    end
end

local detail_filter
local function initial()
    EventManager.Subscribe("Event.CloseItemDetail", CloseItemDetail)
   
    EventManager.Subscribe("Event.ShowItemDetailTips", OnShowItemDetailTips)

    detail_filter = ItemPack.FilterInfo.New()
    detail_filter.NofityCB = function(pack, status, index)
        local self = PeekRunning()
        if self and status == ItemPack.NotiFyStatus.RMITEM then
            local it = detail_filter:GetItemDataAt(index)
            if it and it.Id == self.detail.id then
                if not GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIItemCombine) then
                    Close(self)
                end
            end
        end
    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(detail_filter)
end

local function fin()
    if detail_filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
        detail_filter = nil
    end
end

local function OnEnter(self)
    for _, v in ipairs(self.enter_cb or { }) do
        v(self)
    end
end

local function CreateMainMenu(self, tag)
    self.menu = LuaMenuU.Create(tag)
    self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = false
    self.menu.CacheLevel = -1
    self.menu.LuaTable = self
    self.menu:SubscribOnExit( function()
        PopRunning(self)
        OnExit(self)
    end )

    self.menu:SubscribOnEnter( function()
        PushRunning(self)
        OnEnter(self)
    end )
end

local function Create(tag)
    local ret = { }
    setmetatable(ret, _M)
    
    return ret
end

_M.initial = initial
_M.Create = Create
_M.SetParams = SetParams
_M.Reset = SetParams
_M.SubscribCallBack = SubscribCallBack
_M.GetData = GetData
_M.Close = Close
_M.SetBackGround = SetBackGround
_M.SetItem = SetItem
_M.OnEquip = OnEquip

return _M
