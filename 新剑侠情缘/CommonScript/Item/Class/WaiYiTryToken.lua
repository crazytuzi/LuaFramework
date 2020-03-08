local tbItem = Item:GetClass("WaiYiTryToken")

function tbItem:OnUse(it)
    local szMsg = "大侠的服务器等级大于可体验等级，可前往[FFFE0D]黎饰商店[-]购买华美外装"
    me.CenterMsg(szMsg)
	--[[
    if GetTimeFrameState(WaiYiTry.Def.szMaxTimeframe) == 1 then
        local szMsg = "大侠的服务器等级大于可体验等级，可前往[FFFE0D]黎饰商店[-]购买华美外装"
        me.CenterMsg(szMsg)
        me.Msg(szMsg)
		return 1
    end
	me.CallClientScript("Ui:OpenWindow", "WaiYiTryPanel")
	]]
	return 0
end
