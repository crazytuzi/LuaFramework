--
-- @Author: LaoY
-- @Date:   2018-07-13 20:39:21
--
Notify = Notify or {}

Notify.isShowPickup = true

function Notify.SetPickupNotify(bool)
    Notify.isShowPickup = bool
end

function Notify.ShowExp(exp, way, percent)
    if (way ~= logConsumeDef.LOG_CREEP_DROP) and (way ~= logConsumeDef.LOG_WEDDING_PARTY) then
        Notify.ShowText("EXP earned " ..  GetShowNumber(exp))--tostring(exp))
    else
        local str
        if(percent) then
            str = "jy+" .. exp .. percent
        else
            str = "jy+" .. exp
        end
        SystemTipManager:GetInstance():ShowExpNotify(str)
    end
end

function Notify.ShowText(...)
    local param = {...}
    local str
    if #param == 0 then
        return
    elseif #param == 1 then
        str = param[1]
    else
        str = table.concat(param, " ")
    end
    SystemTipManager:GetInstance():ShowTextNotify(str)
end

function Notify.ShowGoods(goods_id, number)
    SystemTipManager:GetInstance():ShowGoodsNotify(goods_id, number)
end

function Notify.ShowPickupList(items)
    for i, v in pairs(items) do
        Notify.ShowPickup(v.id, v.num)
    end
end

function Notify.ShowPickup(id, num)	
    local item = Config.db_item[id]

    if item and item.point_tips == 1 and Notify.isShowPickup then
        --local txt = string.format("获得: <color=#%s>%s</color> x%s", ColorUtil.GetColor(item.color), item.name, num)
        local txt = string.format("Obtained: %s x%s",  item.name, num)
        Notify.ShowText(txt)
    end
end

function Notify.ShowMoney(itemId, num)

    if Constant.PickUpSkip[itemId] or (not Constant.GoldIDMap[itemId]) then
        return
    end

    local count =  RoleInfoModel:GetInstance():GetRoleValue(itemId)
    if(num <= count) then
        return
    end

    Notify.ShowPickup(itemId, num - count)
end

function Notify.SHowChuanWen(str)
end
