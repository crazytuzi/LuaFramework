local _M = {}
_M.__index = _M


local cjson     = require "cjson"
local Util      = require "Zeus.Logic.Util"
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"
local DetailModel           = require 'Zeus.Model.Item'
local ItemModel = require 'Zeus.Model.Item'

function _M.UpdateGoldShow(labelnode)
    
    local gold = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)
    labelnode.Text = GameUtil.FormatMoney(gold)
    return gold
end

function _M.UpdateDiamondShow(labelnode)
    
    local diamond = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)
    labelnode.Text = GameUtil.FormatMoney(diamond)
    return diamond
end

function _M.UpdateTicketShow(labelnode)
    
    local ticket = tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.TICKET))
    if ticket == nil then
        ticket = 0
    end
    labelnode.Text = GameUtil.FormatMoney(ticket)
    return ticket
end

function _M.UpdateCurrencyShow(labelnode, type)
    
    local currency = DataMgr.Instance.UserData:GetAttribute(type)
    labelnode.Text = GameUtil.FormatMoney(currency)
    return currency
end

function _M.CheckIsBetter(baseScore, code)
    
    local detail = DetailModel.GetItemDetailByCode(code)
    
    if detail.equip == nil or (detail.equip.pro ~= 0 and detail.equip.pro ~= DataMgr.Instance.UserData.Pro) then
        return false
    end
    local itemdata2 = DataMgr.Instance.UserData.RoleEquipBag:GetItemAt(detail.itemSecondType)   
    if itemdata2 ~= nil then
      itemdata2 = ItemModel.GetItemDetailById(itemdata2.Id)
    end

    if itemdata2 == nil then
        return true
    else
        if itemdata2.equip.baseScore < baseScore then
            return true
        else
            return false
        end 
    end
    return false
end

function _M.GetItemDes(type1, num, Des, newLine)
    
    
    local msg = Util.GetText(TextConfig.Type.CHANGE,'condition_' .. type1)
    local data = {}
    if type1 == 1 then
    	if num <= DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0) then
        	data[1] = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', num)
        else
        	data[1] = "<font color='ffff0000'>" .. Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', num) .. "</font>"
        end
    elseif type1 == 2 then
        data[1] = _M.GetUpLevelXmL(num, true)
    else
    	data[1] = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', num)
    end
    if newLine == nil then
    	msg =  ChatUtil.HandleString(msg, data) .. "<br/>" .. Des
    else
    	msg =  ChatUtil.HandleString(msg, data)  .. Des
    end
    return msg
end

function _M.GetItemNameColor(name, argb, size)
    local msg = "<f size= '|3|' color='|1|'>|2|</f>"
    local strdata = {}
    strdata[1] = string.format("%08X",  argb)
    strdata[2] = name
    if size == nil then
        msg = "<f color='|1|'>|2|</f>"
    else
        strdata[3] = size
    end
    msg = ChatUtil.HandleString(msg, strdata)
    return msg
end

function _M.GetItemName(name, qColor, size)
    return _M.GetItemNameColor(name, Util.GetQualityColorARGB(tonumber(qColor)), size)
end

function _M.GetItemNameByCode(code)
    local detail = ItemModel.GetItemDetailByCode(code)
    
    if detail == nil then 
        return nil 
    else
        
        return _M.GetItemName(detail.static.Name, detail.static.Qcolor)
    end
end

function _M.GetUpLevelXmL(uplevel, needcompare)
    
    local text, rgba = Util.GetUpLvTextAndColorRGBA(uplevel)
    if needcompare then
        local curuplevel = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
        if curuplevel < uplevel then
            return _M.GetItemNameColor(text, 0xffff0000)
        end
    end
    return _M.GetItemNameColor(text, GameUtil.RGBA_To_ARGB(rgba))
end

function _M.SetLabelItemName(label, name, color)
    
    label.Text = name
    label.FontColorRGBA = Util.GetQualityColorRGBA(tonumber(color))
end

local function ExchangeNode(data)
    
    local canvas = HZCanvas.New()
    local img = HZCanvas.New()
    img.Size2D = Vector2.New(350, 5)
    local layout = XmdsUISystem.CreateLayoutFroXml('#static_n/static_pic/static001.xml|static001|28', LayoutStyle.IMAGE_STYLE_ALL_9, 0)
    img.Layout = layout
    img.X = 5
    canvas:AddChild(img)    
    local label = HZRichTextPan.New()
    label.Size2D = Vector2.New(350, 5)
    label.XmlText = "<f size= '20'>" .. data .. "</f>"
    label.X = 10
    label.Y = img.Height
    canvas:AddChild(label)
    canvas.Height = img.Height + label.RichTextLayer.ContentHeight
    return canvas
end

function _M.ShowItemShowType2(node, icon, qColor, num, star, code, strTip, forceShownum, isBind)
    return _M.ShowItemShowType2Goto(node, icon, qColor, num, star, code, strTip, false, forceShownum, isBind)
end

function _M.ShowItemShowType2Goto(node, icon, qColor, num, star, code, strTip, goto, forceShownum, isBind)

    local item = Util.ShowItemShow(node, icon, qColor, num, forceShownum)
    item:SetNodeConfigVal(HZItemShow.CompType.bind, isBind == 1)

    local red_limit = false
    local detail = ItemModel.GetItemDetailByCode(code)
    if detail.equip ~= nil then
        red_limit = detail.equip.pro ~= DataMgr.Instance.UserData.Pro and detail.equip.pro ~= 0
    end
    item:SetNodeConfigVal(HZItemShow.CompType.red_limit,red_limit)
    
    item.Star = star
    item.EnableTouch = true
    if goto then
        item.event_PointerDown = function (sender)
        end
        item.event_PointerUp = function (sender)
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, code)
        end
    else
        item.event_PointerDown = function (sender)
            item.IsSelected = true
            local LastItemData = DetailModel.GetItemDetailByCode(code)
            if isBind ~= nil then
                LastItemData.bindType = isBind
            end
            
            local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail,0)
            obj:SetItemDetail(LastItemData)
            if strTip ~= nil then
                obj:AddExtraNode(ExchangeNode(strTip))
            end
            item:SetCustomAttribute('detail_tips','true')
            local cvs = obj.content_node
            local v  = item:LocalToGlobal()
            local v1 = cvs.Parent:GlobalToLocal(v,true) 
            v1 = v1 + Vector2.New(item.Width,item.Height * 0.5)

            if v1.x - item.Width - cvs.Width > 15 then
              
              cvs.X = v1.x - cvs.Width - item.Width - 10
            else
              cvs.X = v1.x + 10
            end
        end
        item.event_PointerUp = function (sender)
            item.IsSelected = false
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
        end
    end
    return item
end

function _M.ShowItemShow(node, icon, qColor, num, star, code, strTip, isBind)
    return _M.ShowItemShowGoto(node, icon, qColor, num, star, code, strTip, false, isBind)
end

function _M.ShowItemShowGoto(node, icon, qColor, num, star, code, strTip, goto, isBind)
    
    local longPress = false
    local item = Util.ShowItemShow(node, icon, qColor, num)
    item:SetNodeConfigVal(HZItemShow.CompType.bind, isBind == 1)

    local red_limit = false
    local detail = ItemModel.GetItemDetailByCode(code)
    if detail.equip ~= nil then
        red_limit = detail.equip.pro ~= DataMgr.Instance.UserData.Pro and detail.equip.pro ~= 0
    end
    item:SetNodeConfigVal(HZItemShow.CompType.red_limit,red_limit)

    item.Star = star
    item.EnableTouch = true
    if goto then
        item.event_PointerUp = function (sender)
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, code)
        end
    else
        item.event_PointerDown = function (sender)
            item.IsSelected = true
            longPress = true
            local LastItemData = DetailModel.GetItemDetailByCode(code)
            if isBind ~= nil then
                LastItemData.bindType = isBind
            end
            
            local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail,-1)
            obj:Set(LastItemData)
            if strTip ~= nil then
                obj:AddExtraNode(ExchangeNode(strTip))
            end
            item:SetCustomAttribute('detail_tips','true')
            local cvs = obj.content_node
            local v  = item:LocalToGlobal()
            local v1 = cvs.Parent:GlobalToLocal(v,true) 
            v1 = v1 + Vector2.New(item.Width,item.Height * 0.5)

            if v1.x - item.Width - cvs.Width > 15 then
              
              cvs.X = v1.x - cvs.Width - item.Width - 10
            else
              cvs.X = v1.x + 10
            end
        end
        item.event_PointerUp = function (sender)
            item.IsSelected = false
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
            longPress = false
        end
    end
    return item
end

function _M.ShowItemShowDetailNoClose(node, detail)
    local item = Util.ShowItemShow(node, detail.static.Icon, detail.static.Qcolor)
    item:SetNodeConfigVal(HZItemShow.CompType.bind, detail.bindType == 1)

    local red_limit = false
    if detail.equip ~= nil then
        red_limit = detail.equip.pro ~= DataMgr.Instance.UserData.Pro and detail.equip.pro ~= 0
    end
    item:SetNodeConfigVal(HZItemShow.CompType.red_limit,red_limit)

    item.EnableTouch = true
    local width = Screen.width / 2
    item.event_PointerDown = function (sender, pos)
        item.IsSelected = true
        if pos.position.x < width then
            EventManager.Fire('Event.ShowItemDetail', {data=detail, anchor = 'R',cb=function (edetail,name,p)
                if name == 'Event.OnExit' then
                    item.IsSelected = false
                end
            end}) 
        else
            EventManager.Fire('Event.ShowItemDetail', {data=detail, anchor = 'L',cb=function (edetail,name,p)
                if name == 'Event.OnExit' then
                    item.IsSelected = false
                end
            end}) 
        end
    end
    return item
end

function _M.ShowItemShowDetail(node, detail)
    local item = _M.ShowItemShowDetailNoClose(node, detail)

    item.event_PointerUp = function (sender)
        item.IsSelected = false
        EventManager.Fire("Event.CloseItemDetail", {})
    end
    return item
end

function _M.GetBtnText(num)
    
    
    local msg = Util.GetText(TextConfig.Type.CHANGE,'can_change')
    local data = {}
    data[1] = num
    msg = ChatUtil.HandleString(msg, data)
    
    return msg
end

function _M.ShowNodeToFullScreen(node)
    
    local root = XmdsUISystem.Instance.RootRect
    local scale = root.width > XmdsUISystem.SCREEN_WIDTH and root.width / XmdsUISystem.SCREEN_WIDTH or root.height / XmdsUISystem.SCREEN_HEIGHT
            
    local mMaskW = node.Width * scale;
    local mMaskH = node.Height * scale;

    local mMaskOffsetX = (XmdsUISystem.SCREEN_WIDTH - mMaskW) * 0.5
    local mMaskOffsetY = (XmdsUISystem.SCREEN_HEIGHT - mMaskH) * 0.5

    node.Position2D = Vector2.New(mMaskOffsetX, mMaskOffsetY);
    node.Size2D = Vector2.New(mMaskW, mMaskH)
end

local iconPath = {
    "#static_n/static_pic/static001.xml|static001|87",
    "#static_n/static_pic/static001.xml|static001|88",
    "#static_n/static_pic/static001.xml|static001|147",
    "#static_n/static_pic/static001.xml|static001|148",
    "#static_n/static_pic/static001.xml|static001|87",
    "#static_n/static_pic/static001.xml|static001|87",
    "#dynamic_n/dynamic_new/social/social.xml|social|1",
    "#static_n/static_pic/static001.xml|static001|48",
}

local iconBigPath = {
    "gold",
    "diamond",
    "cash",
    "presitge",
    "gold",
    "gold",
    "friendly",
    "treasurespoint",
}

local STATUS_LIST = {
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.DIAMOND,
    
    UserData.NotiFyStatus.TICKET,
    
    UserData.NotiFyStatus.PRESTIGE,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.GOLD,
    
    UserData.NotiFyStatus.FRIENDLY,
    
    UserData.NotiFyStatus.TREASUREPOINT,
}


function _M.GetIconSmallPath(index)
	return iconPath[index]
end

function _M.GetIconBigPath(index)
	return iconBigPath[index]
end

function _M.GetStatus(index)
    return STATUS_LIST[index]
end

return _M
