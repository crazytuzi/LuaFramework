local Item = require "Zeus.Model.Item"
local Util = require "Zeus.Logic.Util"
local DisplayUtil = {}

function DisplayUtil.playerHtmlName(playerName, playerPro)
    local color = GameUtil.GetProColorARGB(playerPro)
    return string.format('<f color="%08x">%s</f>', color, playerName)
end

function DisplayUtil.itemHtmlName(name, quality)
    local color = Util.GetQualityColorARGB(quality)
    return string.format('<f color="%08x">%s</f>', color, name)
end

function DisplayUtil.getUpLvName(upLv)
    if upLv and upLv > 0 then
        local titleData = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = upLv})[1]
        return titleData.ClassName..titleData.UPName
    end
    return ""
end

function DisplayUtil.upLvOrLvHtmlName(upLv, lv, lvColorRGBA, isLvText)
    local name, color = nil, nil
    if upLv and upLv > 0 then
        local titleData = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = upLv})[1]
        name = titleData.ClassName..titleData.UPName
        color = Util.GetQualityColorARGB(titleData.Qcolor)
    else
        name = tostring(lv)
        color = lvColorRGBA or 0xFFFFFFFF
        if isLvText then
            name = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', lv)
        end
    end
    return string.format('<f color="%08x">%s</f>', color, name)
end

function DisplayUtil.setPlayerName(label, playerName, playerPro)
    label.Text = playerName
    label.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(playerPro))
end

function DisplayUtil.setItemName(label, name, quality)
    label.Text = name
    label.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(quality))
end

function DisplayUtil.setUpLvOrLv(label, upLv, lv, lvColorRGBA, isLvText)
    if upLv and upLv > 0 then
        local titleData = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = upLv})[1]
        label.Text = titleData.ClassName..titleData.UPName
        label.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(titleData.Qcolor))
    else
        if isLvText then
            label.Text = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', lv)
        else
            label.Text = tostring(lv)
        end
        label.FontColor = GameUtil.RGBA2Color(lvColorRGBA or 0xFFFFFFFF)
    end
end

function DisplayUtil.setTestUpOrLv(label, upLv, lv, lvColorRGBA)
    if upLv and upLv > 0 then
        local myUpLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
        local titleData = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = upLv})[1]
        label.Text = titleData.ClassName..titleData.UPName
        label.FontColor = myUpLv >= upLv and GameUtil.RGBA2Color(Util.GetQualityColorRGBA(titleData.Qcolor)) or Util.FontColorRed
    else
        local myLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        label.Text = tostring(lv)
        label.FontColor = myLv >= lv and GameUtil.RGBA2Color(lvColorRGBA or 0xFFFFFFFF) or Util.FontColorRed
    end
end

function DisplayUtil.fillItem(canvas, item, tipFunc)
    local itemShow = Util.ShowItemShow(canvas, item.static.Icon, item.static.Qcolor, item.groupCount or 1)
    local detail = item.detail or Item.GetItemDetailByCode(item.static.Code)
    Util.ItemshowExt(itemShow, detail, detail.equip ~= nil)

    if tipFunc then
        tipFunc(canvas, item, itemShow)
    end
    return itemShow
end

function DisplayUtil.fillItems(canvases, items, tipFunc)
    for i,v in ipairs(items) do
        local canvas = canvases[i]
        if not canvas then return end

        canvas.Visible = true
        DisplayUtil.fillItem(canvas, v, tipFunc)
    end
    for i = #items + 1, #canvases do
        canvases[i].Visible = false
    end
end

function DisplayUtil.itemTouchTips(canvas, item, itemShow)
    canvas.event_PointerDown = function (sender) 
        if itemShow then
            itemShow.IsSelected = true
        end
        Util.ShowItemDetailTips(itemShow, item.detail or Item.GetItemDetailByCode(item.static.Code))
    end
    canvas.event_PointerUp = function (sender)
        if itemShow then
            itemShow.IsSelected = false
        end
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
    end
end

function DisplayUtil.getCell(scrollPan, luaIdx)
    local cols = scrollPan.Columns
    local gx = (luaIdx - 1) % cols
    local gy = math.floor((luaIdx - 1) / cols)
    return scrollPan.Scrollable:GetCell(gx, gy)
end

function DisplayUtil.lookAt(scrollPan, luaIdx, bool)
    local cols = scrollPan.Columns
    local gx = (luaIdx - 1) % cols
    local gy = math.floor((luaIdx - 1) / cols)
    local scrollable = scrollPan.Scrollable
    local cellSize = scrollable.CellSize
    local border = scrollable.Border
    local gap = scrollable.Gap
    local x = border.x + gx * (cellSize.x + gap.x) 
    local y = border.y + gy * (cellSize.y + gap.y) 
    scrollable:LookAt(Vector2.New(x, y), bool or false)
end

function DisplayUtil.resizeByTarget(displayNode, target, isSetPoistion)
    local targetSize = target.Size2D
    local mySize = displayNode.Size2D
    displayNode.Scale = Vector2.New(targetSize.x / mySize.x, targetSize.y / mySize.y)
    if isSetPoistion then
        displayNode.Position2D = target.Position2D
    end
end

return DisplayUtil
