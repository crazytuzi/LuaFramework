require "base64"
local Util = require "Zeus.Logic.Util"
local FubenAPI = require "Zeus.Model.Fuben"
local ChatUtil = require "Zeus.UI.Chat.ChatUtil"

local EnterFubenState = {
    None = 0,       
    Wait = 1,       
    Accept = 2,     
    Reject = 3,     
}
local HeadStateImgs = {
    [EnterFubenState.Wait]   = "#static_n/func/common2.xml|common2|177",
    [EnterFubenState.Accept] = "#static_n/func/common2.xml|common2|92",
    [EnterFubenState.Reject] = "#static_n/func/common2.xml|common2|93",
}


local TargetDiffText = {
    Util.GetText(TextConfig.Type.FUBEN, "hardName_11"),
    Util.GetText(TextConfig.Type.FUBEN, "hardName_22"),
    Util.GetText(TextConfig.Type.FUBEN, "hardName_33"),
}

local fubenHardColors = {
    "ff21b2ef", "ffcc00ff", "fff43a1c"
}

local FubenUtil = {
    EnterFubenState = EnterFubenState
}

function FubenUtil.GetFubenHardText(hard)
    return TargetDiffText[hard]
end

function FubenUtil.GetFubenNeedPower(fubenId)
    local info = GlobalHooks.DB.Find("DungeonMap", {MapID=fubenId})[1]
    if info ~= nil then
        return info.FcValue
    else
        return 0
    end
end



function FubenUtil.formatCondition(info)
    
    
    
    
    
    
    
    
    
        
        local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        local text = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', info.ReqLevel)
        if info.ReqLevel > lv then
            return text, 0
        elseif info.ReqLevel > lv-30 then
            return text, 2
        elseif info.ReqLevel <= lv-30 then
            return text, 1
        end
end

function FubenUtil.setEnterCondition( canvas, labelName, info)
    local text, goStatus = FubenUtil.formatCondition(info)
    local conditionLabel = canvas:FindChildByEditName(labelName, true)
    conditionLabel.Text = text
    conditionLabel.FontColor = (goStatus > 0 and Util.FontColorBlue) or Util.FontColorRed
    return goStatus
end

function FubenUtil.setOpenTime( canvas, dayName, timeName, staticVo )
    local dayLabel = canvas:FindChildByEditName(dayName, false)
    local timeLabel = canvas:FindChildByEditName(timeName, false)
    dayLabel.Visible = staticVo.OpenRule ~= 0
    timeLabel.Visible = staticVo.OpenRule ~= 0
    if staticVo.OpenRule == 0 then return end


    if staticVo.OpenRule == 1 then
        dayLabel.Text = Util.GetText(TextConfig.Type.FUBEN, "openEveryDay")
    elseif staticVo.OpenRule == 2 then
        local days = string.split(staticVo.OpenDate, ',')
        local comma = Util.GetText(TextConfig.Type.FUBEN, "comma")
        dayLabel.Text = Util.GetText(TextConfig.Type.FUBEN, "openSomeDay", table.concat(days, comma))
    end

    local beginTime = string.split(staticVo.BeginTime, '-')
    local endTime = string.split(staticVo.EndTime, '-')
    table.remove(beginTime)
    table.remove(endTime)
    beginTime = table.concat(beginTime, ':')
    endTime = table.concat(endTime, ':')
    timeLabel.Text = string.format("%s-%s", beginTime, endTime)
end

function FubenUtil.setRemainTimes( canvas, labelName, info )
    local label = canvas:FindChildByEditName(labelName, true)
    label.Text = string.format("%d/%d", info.remainTimes, info.allEnterTimes)
    label.FontColor = (info.remainTimes > 0 and Util.FontColorWhite) or Util.FontColorRed
end

function FubenUtil.setCostItem( canvas, labelName, labelNumName, info )
    canvas:FindChildByEditName(labelName, true).Visible = info.costItem ~= nil
    local costLabel = canvas:FindChildByEditName(labelNumName, true)
    costLabel.Visible = info.costItem ~= nil
    if info.costItem then
        costLabel.FontColor = (info.hasItem == 1 and Util.FontColorWhite) or Util.FontColorRed
        costLabel.Text = string.format("%s x %d", info.costItem.name, info.costItem.groupCount)
    end
end

function FubenUtil.confirmEnterDigong(info)
    local name = string.format("<f color='%s'>%s</f>", "ffef880e", info.staticVo.Name)
    local texts = {Util.GetText(TextConfig.Type.FUBEN,"confirmEnterDigong", name)}
    if info.costItem then
        local color = info.hasItem == 1 and 0xFFE7E5D1 or 0xFFFF0000
        local cost = string.format("<f color='%08x'>%s x %d</f>", color, info.costItem.name, info.costItem.groupCount)
        table.insert(texts, Util.GetText(TextConfig.Type.FUBEN,"costItem", name))
    end
    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        string.format("<f>%s</f>", table.concat(texts, '<br/>')),
        Util.GetText(TextConfig.Type.FUBEN, "enter"),
        Util.GetText(TextConfig.Type.FUBEN, "cancel"),
        nil,
        nil,
        function()
            FubenAPI.requestEnterFuben(info.fubenId)
        end,
        nil
    )
end


function FubenUtil.setTeamMemberHead(canvas, info)
    if info == nil then
        canvas.Visible = false
        return
    else
        canvas.Visible = true
    end

    local lvLabel = canvas:FindChildByEditName("lb_level", false)
    lvLabel.Text = tostring(info.level)
    local nameLabel = canvas:FindChildByEditName("lb_name", false)
    Util.SetLabelShortText(nameLabel, info.name)
    
    local headIcon = canvas:FindChildByEditName("ib_head", false)
    Util.HZSetImage(headIcon, PublicConst.GetProIcon(info.pro))
end

function FubenUtil.setTeamMemberState(canvas, state)
    local readyInfoIcon = canvas:FindChildByEditName("ib_ok", false)
    readyInfoIcon.Visible = true
    local path = HeadStateImgs[1]
    if state > EnterFubenState.None then
        Util.HZSetImage(readyInfoIcon, HeadStateImgs[state])
    end
end

function FubenUtil.getFubenHardStr(hard)
    return Util.GetText(TextConfig.Type.FUBEN, "hardName"..hard)
end

function FubenUtil.getFubenHardHtml(hard)
    local name = FubenUtil.getFubenHardStr(hard)
    return string.format("<font color='%s'>%s</font>", fubenHardColors[hard], name)
end

function FubenUtil.getInviteTeamMsg(formatStr, fubenId, pros, slogan)
    local fubenVo = FubenAPI.getStaticFubenVo(fubenId)
    local link = FubenUtil.encodeTeamInfo(fubenId, fubenVo.AllowedPlayers, pros, slogan)
    link = ChatUtil.AddSendTeamMsg(link)

    local comma = Util.GetText(TextConfig.Type.FUBEN, "comma")
    local prosStr = nil
    if #pros == 0 or #pros == 5 then
        prosStr = Util.GetText(TextConfig.Type.FUBEN, "allpro")
    else
        local prosTable = {}
        for i, v in ipairs(pros) do
            table.insert(prosTable, PublicConst.GetProName(v))
        end
        prosStr = table.concat(prosTable, comma)
    end

    local fubenNameStr = string.format("<font color='%s'>%s</font>", "ffef880e", fubenVo.Name)
    local fubenHardStr = FubenUtil.getFubenHardHtml(fubenVo.HardModel)

    local player = {}
    player.s2c_playerId = DataMgr.Instance.UserData.RoleID
    player.s2c_name = DataMgr.Instance.UserData.Name
    player.s2c_level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
    player.s2c_pro = DataMgr.Instance.UserData.Pro
    player.MsgType = 3
    local playerLink = cjson.encode(player)
    local playerName = player.s2c_name
    
    return Util.GetText(TextConfig.Type.FUBEN, formatStr, playerLink, playerName, link, fubenNameStr, fubenHardStr, slogan, prosStr)
end









function FubenUtil.encodeTeamInfo(fubenId, needNum, pros, slogan)
    local userData = DataMgr.Instance.UserData
    local data = {
        fubenId = fubenId,
        playerId = userData.RoleID,
        teamId = DataMgr.Instance.TeamData.TeamId,
        hasNum = DataMgr.Instance.TeamData.MemberCount + 1,
        needNum = needNum,
        pros = pros,
        slogan = slogan,
    }
    return ZZBase64.encode(cjson.encode(data))
end

function FubenUtil.decodeTeamInfo( data )
    return cjson.decode(ZZBase64.decode(data))
end

function FubenUtil.onTeamLinkClick(data)
    local info = FubenUtil.decodeTeamInfo(data)
    print("onTeamLinkClickonTeamLinkClickonTeamLinkClick")
    
    
    FubenAPI.requestJoinFubenTeam(info.teamId, info.playerId)
end

FubenUtil.itemTipAnchor = nil

function FubenUtil.showItemTip(code, itemShow)
    EventManager.Fire("Event.ShowItemDetail", {
        templateId = code,
        anchor = FubenUtil.itemTipAnchor,
        singleId = "FubenUI",
        itemShow = itemShow,
    })
end

function FubenUtil.closeItemTip()
    EventManager.Fire("Event.CloseItemDetail", {
        singleId = "FubenUI",
    })
end


return FubenUtil
