FestivalActionConst = FestivalActionConst or {}

FestivalActionConst.ColorConst = {
	[1] = cc.c4b(0x64,0x32,0x23,0xff),
	[2] = cc.c4b(0x95,0x53,0x32,0xff),
	[3] = cc.c4b(0x95,0x53,0x22,0xff),
	[4] = cc.c4b(0x5f,0xd5,0x4c,0xff),
	[5] = cc.c4b(0xed,0xd7,0xb2,0xff),
	[6] = cc.c4b(0xb7,0xff,0x46,0xff),
}

--倒计时
function FestivalActionConst.CountDownTime(node,data)
    local less_time = data.less_time or 0
    local time_model = data.time_model or 1
    local text = data.text or ""
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    local function setRemainTimeString(time)
        if time > 0 then
            if time_model == 1 then
                node:setString(TimeTool.GetTimeFormat(time))
            elseif time_model == 2 then
                node:setString(TimeTool.GetTimeFormatDayII(less_time)..text)
            end
        else
            doStopAllActions(node)
            node:setString("00:00:00")
            if time_model == 2 then
                FestivalActionController:getInstance():openPersonalGiftView(false)
            end
        end
    end

    if less_time > 0 then
        setRemainTimeString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                setRemainTimeString(less_time)
            end
        end))))
    else
        setRemainTimeString(less_time)
    end
end