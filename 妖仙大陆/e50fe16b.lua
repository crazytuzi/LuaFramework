local Util = require "Zeus.Logic.Util"
local Item = require "Zeus.Model.Item"
local ExchangeUtil      = require "Zeus.UI.ExchangeUtil"

local ActivityUtil = {}

function ActivityUtil.fillItemsStatic(items)
    for _,v in ipairs(items) do
        v.static = GlobalHooks.DB.Find("Items", v.code)
    end
end

function ActivityUtil.fillItems(canvas, items, maxCount)
    for i=1, maxCount do
        local icon = canvas:FindChildByEditName("cvs_icon" .. i, true)
        if not icon then return end

        local item = items[i]
        icon.Visible = item ~= nil and item.static ~= nil
        if item and item.static then
            local itemShow = Util.ShowItemShow(icon, item.static.Icon, item.static.Qcolor, item.groupCount)
            Util.NormalItemShowTouchClick(itemShow,item.code,false)
        end
    end
end

function ActivityUtil.lookAtItemIdx(scrollPan, cell, idx)
    local y = (idx - 1) * cell.Height
    scrollPan.Scrollable:LookAt(Vector2.New(0, y), true)
end

function ActivityUtil.DealItem(node, data, notshownum)
    if data == nil then
        node.Visible = false
    else
        node.Visible = true
        local str = split(data, ":")
        
        if str ~= nil and #str > 1 then
            
            local item = Item.GetItemDetailByCode(str[1])
            
            if notshownum then
                ExchangeUtil.ShowItemShowType2(node, item.static.Icon, item.static.Qcolor, 0, 0, item.static.Code)
            else
                ExchangeUtil.ShowItemShowType2(node, item.static.Icon, item.static.Qcolor, str[2], 0, item.static.Code, nil, true)
            end
        end
        return str
    end
end

function ActivityUtil.ParametersValue(key)
    
    local search_t = {ParamName = key}
    local ret = GlobalHooks.DB.Find('Parameters',search_t)
    if ret ~= nil and #ret > 0 then
        if ret[1].ParamType == "NUMBER" then
            return tonumber(ret[1].ParamValue)
        else
            return ret[1].ParamValue
        end
    end
    return 0
end

function ActivityUtil.GetSwitchCardCost(opennum)
    
    if opennum == 1 then
        return 0
    else
        if opennum == 2 then
            return ActivityUtil.ParametersValue("Activity.LuckDrwa.Cost")
        else
            return ActivityUtil.ParametersValue("Activity.LuckDrwa.Cost") + (opennum - 2) * ActivityUtil.ParametersValue("Activity.LuckDrwa.CumulativeCost")
        end
    end
end

function ActivityUtil.GetConfigTimeXml(s2c_beginTime, s2c_endTime, s2c_content)
    
    local timeStr
    if s2c_endTime == nil or s2c_endTime == "" or s2c_endTime == "3016-01-01 23:59:59" then
        timeStr = Util.GetText(TextConfig.Type.ACTIVITY, "forever") .. "<br/>"
    else
        local beginTime = string.gsub(s2c_beginTime, '%-', '/')
        local endTime = string.gsub(s2c_endTime, '%-', '/')
        timeStr = Util.GetText(TextConfig.Type.ACTIVITY, "activityTime", beginTime, endTime) .. "<br/>"
    end
    local descStr = "<f>" .. timeStr.. Util.GetText(TextConfig.Type.ACTIVITY, "activityDesc", s2c_content or "") .. "</f>"
    return descStr
end


return ActivityUtil
