local tbNpc = Npc:GetClass("ActivityQuestion");

function tbNpc:OnDialog()
    if ActivityQuestion:CheckSubmitTask() then
        Dialog:Show(
        {
            Text    = "今日的侠士是否已经拜访完毕了？对江湖之事是否有了更多的了解？",
            OptList = {
                { Text = "完成答题", Callback = function ()
                    ActivityQuestion:TrySubmitTask()
                end},
            },
        }, me, him)
    else
        Npc:ShowDefaultDialog()
    end
end