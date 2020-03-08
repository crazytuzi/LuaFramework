local tbAct = Activity:GetUiSetting("JiziAct")
tbAct.nShowLevel = 20
tbAct.szTitle    = "盛典·缘聚江湖"
tbAct.szUiName   = "Normal"
tbAct.nOperationType   = 3
tbAct.nShowPriority = 99
tbAct.szContent  = [[
[c8ff00]江湖盛典庆四方 武林盛事惠天下[-]

      刀光剑影记恩仇，江湖纷纭事未休。新一届的[c8ff00]江湖盛典·缘聚江湖[-]即将召开，同时准备了丰富的活动以响应武林，共同庆贺，诸位侠士准备好了吗？
      活动时间：[c8ff00]2017.10.14-2017.10.29[-]
      江湖盛典发布会直播时间：[c8ff00]2017.10.29 18:30-2017.10.29 20:30[-]
    
      [c8ff00]【帛书收集】[-]
      2017.10.14-2017.10.21期间内，打开每日活跃宝箱可额外获得对应档次的[11adf6]江湖盛典活跃宝箱[-]，并有概率获得一种帛书，集齐八种帛书可合成[ff8f06] [url=openwnd: 江湖盛典欢庆礼盒, ItemTips, "Item", nil, 6694] [-]，使用将获得丰富奖励。与此同时，完成帛书收集将有概率获得[FFFE0D]江湖盛典发布会现场门票[-]（活动结束后通过邮件统一发放和通知），明星代言人也会莅临现场与诸位侠士见面交流哦！
    
      [c8ff00]【登录领奖】[-]
      2017.10.22日将开启江湖盛典倒计时，每天会通过邮件形式为大家派发[FFFE0D]倒计时登录奖励[-]。同时也请诸位侠士多多关注聊天频道，我们的[FFFE0D]明星代言人颖宝宝和林更新会在倒计时期间内与大家进行聊天互动[-]，他们可知道不少关于江湖盛典的小道消息！
    
      [c8ff00]【盛典直播】[-]
      2017.10.29 18:30-2017.10.29 20:30将进行江湖盛典发布会的现场直播，诸位侠士可点击“江湖盛典”按钮打开直播频道进行观看。观看过程中可不要分神，[FFFE0D]明星代言人会在现场发布指定口令[-]，有效时间内在世界频道准确发送口令的侠士将有机会进行[FFFE0D]口令红包[-]的抢夺。除此之外，直播过程中还会[FFFE0D]开启跨服互动地图[-]，与明星角色“零距离”亲密接触，是守护还是厮杀？你说的算！
      
      [c8ff00]*上述所有时间均以活动开启时的准确时间为准，若有临时调整还请诸位侠士理解海涵。[-]
]]

tbAct.FnCustomData = function (szKey, tbData)
        local szStart = Lib:TimeDesc10(tbData.nStartTime)
        local szEnd   = Lib:TimeDesc10(tbData.nEndTime)
        return {string.format(tbAct.szContent, szStart, szEnd, tbAct.nShowLevel)}
end