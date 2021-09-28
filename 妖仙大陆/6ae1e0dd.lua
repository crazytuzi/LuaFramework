local Util = require "Zeus.Logic.Util"
local ShopAPI = require "Zeus.Model.Shop"

local ShopUtil = {}

local moneyImages = {
    "#static_n/func/common2.xml|common2|173",  
    "#static_n/func/common2.xml|common2|171", 
    "#static_n/func/common2.xml|common2|171",     
}

local proIntMap = {}
for i=1, 5 do
    proIntMap[PublicConst.GetProName(i)] = i
end

function ShopUtil.setMoneyIcon(icon, moneyType)
    Util.HZSetImage(icon, moneyImages[moneyType])
end

function ShopUtil.setItemIcon(canvas, item)
    local icon = canvas:FindChildByEditName("cvs_icon", true)
    Util.ShowItemShow(icon, item.detail.static.Icon, item.detail.static.Qcolor, item.groupCount)
end

function ShopUtil.setItemName(canvas, item)
    local nameLabel = canvas:FindChildByEditName("lb_name", true)
    nameLabel.Text = item.detail.static.Name
    nameLabel.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(item.detail.static.Qcolor))
end

function ShopUtil.itemHtmlName(item)
    local color = Util.GetQualityColorARGB(item.detail.static.Qcolor)
    return string.format('<f color="%08x">%s</f>', color, item.detail.static.Name)
end

function ShopUtil.playerHtmlName(player)
    local color = GameUtil.GetProColorARGBHexString(player.pro)
    return string.format('<f color="%s">%s</f>', color, player.name)
end

function ShopUtil.isPro(item, pro)
    if pro == 0 then return true end

    local proStr = item.detail.static.Pro
    return not proStr or pro == proIntMap[proStr]
end

function ShopUtil.updateCellByIdx(scrollPan, idx, item, updateCell)
    local gx = (idx - 1) % 3
    local gy = math.floor((idx - 1) / 3)
    local cell = scrollPan.Scrollable:GetCell(gx, gy)
    if cell then
        updateCell(gx, gy, cell)
    end
end

function ShopUtil.attachNotify(intKey, func, ...)
    local notifyStates = {...}
    local obj = {
        Notify = function(status, userdata, opt, t)
            for _,v in ipairs(notifyStates) do
                if userdata:ContainsKey(status, v) then
                    func()
                    break
                end
            end
        end
    }
    DataMgr.Instance.UserData:AttachLuaObserver(intKey, obj)
end

function ShopUtil.detachNotify(intKey)
    DataMgr.Instance.UserData:DetachLuaObserver(intKey)
end

function ShopUtil.confirmBuyItem(countStr, item, count, playerId, buyCb, successCb, buyType)
    if buyCb then buyCb(item, count) end
    ShopAPI.requestBuyShopItem(item.id, count, playerId, buyType, function(totalNum)
        if successCb then successCb(item, count,totalNum) end
    end)
end

local moneyEnums = {
    UserData.NotiFyStatus.DIAMOND,
    UserData.NotiFyStatus.TICKET,
    UserData.NotiFyStatus.CONSUMEPOINT,
}
local moneyTips = {
    "notEnoughDiamond",
    "notEnoughTicket",
    "notEnoughConsumePoint",
}

function ShopUtil.checkMoney(moneyType, needMoney, cb)
    
    local moneyEnum = moneyEnums[moneyType]
    local text = moneyTips[moneyType]

    local hasMoney = DataMgr.Instance.UserData:TryToGetLongAttribute(moneyEnum, 0)
    
    if hasMoney >= needMoney then
        cb(0)
        return
    end

    
    if moneyType == 2 then
        local msgEntry = GlobalHooks.DB.Find("FunGoTo", {FunGoID = 10})[1]
        local content = Util.FormatKV(msgEntry.FunTips, {diamond = needMoney - hasMoney})
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            content,
            msgEntry.okBtn,
            msgEntry.cancelBtn,
            msgEntry.FunTitle,
            nil,
            function()
                cb(1)
            end,
            nil
        )
    else
        local tip = Util.GetText(TextConfig.Type.SHOP,'notEnoughDiamond')
        GameAlertManager.Instance:ShowNotify(tip)
        
    end
end

function ShopUtil.resetRedPoint(redPoints, tabs)
    for i = #redPoints + 1, #tabs do
        local point = redPoints[1]:Clone()
        local relPos = redPoints[1].Position2D - tabs[1].Position2D
        point.Position2D = tabs[i].Position2D + relPos
        redPoints[i] = point
        redPoints[1].Parent:AddChild(point)
    end
    for i = #tabs + 1, #redPoints do
        redPoints[i].Visible = false
    end
end
function ShopUtil.updateRedPoint(redPoints, datas)
    for i,v in ipairs(datas) do
        redPoints[i].Visible = v.scriptNum == 1
    end
end

function ShopUtil.hasLimitItem(itemList)
    for _,v in ipairs(itemList) do
        if v.endTime > 0 then return true end
    end
    return false
end

return ShopUtil
