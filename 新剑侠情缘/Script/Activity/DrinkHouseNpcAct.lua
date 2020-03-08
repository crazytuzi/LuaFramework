
local tbAct      = Activity:GetUiSetting("DrinkHouseNpcAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "盛典内容征集"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]盛典内容征集活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]2018年11月3日4点-2018年11月22日4点[-]
[FFFE0D]参与等级：[-]20级
盛典即将来临，新任武林盟主南宫飞云想一睹诸位侠士的风采！
活动期间玩家可前往忘忧酒馆[FFFE0D][url=pos:南宫飞云, 8011, 5167, 17699][-]处对话打开内容征集页面，在4个板块中或写下自己的江湖故事，或说出自己的江湖经历，或留下自己游历江湖的照片，或展示自己扮演能力的倩影，最后经过玩家的评选，每个板块进入[FFFE0D]前10[-]的玩家均可获得丰厚奖励，奖励如下：
[FFFE0D]忘忧酿·故事：[-]豪华称号·衷情述梦 20000元气真气贡献任选礼盒
[FFFE0D]绕梁春·声音：[-]豪华称号·声不负雁 20000元气真气贡献任选礼盒
[FFFE0D]珍忆露·照片：[-]豪华称号·诗图洒意 20000元气真气贡献任选礼盒
[FFFE0D]剑影液·扮演：[-]豪华称号·湖心泛影 20000元气真气贡献任选礼盒
另外，获得每个板块[FFFE0D]第一名[-]的玩家，还将获得豪华神秘外装！
活动期间还可以找[FFFE0D][url=pos:南宫飞云, 8011, 5167, 17699][-]领取一次见面礼哦！
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc10(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc10(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end