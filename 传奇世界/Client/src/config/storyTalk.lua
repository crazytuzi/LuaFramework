local Items=
{
  {q_id=1.0, q_role=12, q_text="法神·洪：^c(lable_black)\n      我们终于突破到这里了……^"},
  {q_id=2.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      可恶！这些修罗快要把封印完全破坏了！^"},
  {q_id=3.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      不能再等了，为了阻止阿修罗神，我们必须马上战斗起来！^"},
  {q_id=4.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      烈火剑法！^"},
  {q_id=5.0, q_role=12, q_text="法神·洪：^c(lable_black)\n      流星火雨！^"},
  {q_id=6.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      %s，一起战斗！^"},
  {q_id=7.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      三圣王！来送死了么！^"},
  {q_id=8.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      三圣王！来送死了么！你们阻止不了我！这个世界终将由我来掌控！^"},
  {q_id=9.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      不能让修罗再次乱世，我们要决一死战，重新封印阿修罗神！大家一起上！^"},
  {q_id=10.0, q_role=12, q_text="法神·洪：^c(lable_black)\n      狂龙紫电！^"},
  {q_id=11.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      幽冥火咒！大家一起上！^"},
  {q_id=12.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      哈哈哈！我早有准备！今天你们必死无疑！^"},
  {q_id=13.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      可恶，已经被包围了，没有退路了！^"},
  {q_id=14.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      不能让修罗再次乱世，看来只能拼死一搏了！^"},
  {q_id=15.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      邪恶才是这个世界的本源！你们阻止不了我！全给我上！^"},
  {q_id=16.0, q_role=12, q_text="法神·洪：^c(lable_black)\n      让这些修罗尝尝烧灼的滋味！^"},
  {q_id=17.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      神圣战甲术！ 出发！^"},
  {q_id=18.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      强化攻杀！^"},
  {q_id=19.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      你应该庆幸，没有多少人能见识到我的真面目！变身！^"},
  {q_id=20.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊!^"},
  {q_id=21.0, q_role=14, q_text="阿修罗神：^c(lable_black)\n      小的们，给我消灭人类!^"},

  {q_id=30.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      可恶！又被他们追上来了！^"},
  {q_id=31.0, q_role=0, q_text="%s：^c(lable_black)\n      圣王大人，让我来消灭这些喽啰，千万不能让阿修罗神突破封印！^"},
  {q_id=32.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      %s，一切就拜托你了，我们走...^"},
  {q_id=33.0, q_role=0, q_text="%s：^c(lable_black)\n      不能再耽搁了，我得赶紧去支援三圣王...^"},
  {q_id=34.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      %s已经赶到了，重整队形，为了阻止阿修罗神，我们必须马上战斗起来！^"},
  {q_id=35.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      %s，快去阻止阿修罗神，否则中州将会生灵涂炭！^"},
-----------------------------------------------------------------------------------------------------------------------------
  {q_id=51.0, q_role=1, q_text="%s：^c(lable_black)\n      怎么会有这样的噩梦？^"},
  {q_id=52.0, q_role=0, q_text="小岩：^c(lable_black)\n      勇士%s，那不是一场噩梦，而是一个预兆。^"},
  {q_id=53.0, q_role=1, q_text="%s：^c(lable_black)\n      神仙？妖怪？你到底是谁！^"},
  {q_id=54.0, q_role=0, q_text="小岩：^c(lable_black)\n      我是中州大陆的勇士指引者，是时候接受成为真正勇士的试炼了！^"},
  {q_id=55.0, q_role=1, q_text="%s：^c(lable_black)\n      我不知道这究竟是怎么回事，但我不会退缩的。^"},
  {q_id=56.0, q_role=0, q_text="小岩：^c(lable_black)\n      先去找村长聊聊吧。^"},
  {q_id=57.0, q_role=1, q_text="%s：^c(lable_black)\n      事不宜迟，那我这就出发！^"},
-----------------------------------------------------------------------------------------------------------------------------
  {q_id=70.0, q_role=12, q_text="法神·洪：^c(lable_black)\n      可恶，竟然被这些魔族包围了！^"},
  {q_id=71.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      哼！竟然又来了一群送死的！^"},
  {q_id=72.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      不要轻敌，我们的目标是守护公主！^"},
  {q_id=73.0, q_role=15, q_text="逆魔：^c(lable_black)\n      这只是一次小小的失利，我还会再回来的！哈哈哈哈......^"},
  {q_id=74.0, q_role=0, q_text="%s：^c(lable_black)\n      公主殿下，让您受惊了！^"},
-----------------------------------------------------------------------------------------------------------------------------
  {q_id=80.0, q_role=5, q_text="小岩：^c(lable_black)\n      矿石是强化装备的必备材料，近期矿区中的僵尸数量激增，很多采矿的村民都遭到了偷袭，你去矿区看看，多消灭些僵尸吧！^"},
  {q_id=81.0, q_role=0, q_text="%s：^c(lable_black)\n      我这就去！^"},
  {q_id=82.0, q_role=5, q_text="小岩：^c(lable_black)\n      %s果然身手不凡，看到那个金矿了吗，那可是产量最高的矿了，顺便采集一些结晶给我！^"},
  {q_id=83.0, q_role=11, q_text="恶人：^c(lable_black)\n      那里来的小毛孩，敢抢我的矿，待我杀了你，你头顶的矿石结晶就是我的了，哈哈！^"},
  {q_id=84.0, q_role=5, q_text="小岩：^c(lable_black)\n      僵尸和恶人都被你教训了，还采集到了矿石结晶，勇士果然实力超群，相信在不久的将来，你的大名必将传遍整个中州大陆！^"},
  {q_id=85.0, q_role=5, q_text="小岩：^c(lable_black)\n      在矿区，不仅要当心周围的僵尸怪物，另外在这里靠武力抢夺矿石结晶也是正常不过的事情！^"},
  {q_id=86.0, q_role=12, q_text="恶人：^c(lable_black)\n      是你！上次竟敢反抗？真是冤家路窄啊，看我今天不弄死你！^"},
  {q_id=87.0, q_role=5, q_text="小岩：^c(lable_black)\n      顶在头顶的矿石结晶在角色死亡时会掉落在地上哦，赶快捡起来吧，这可比你自己采集要来得容易多了哦！^"},
  {q_id=88.0, q_role=5, q_text="小岩：^c(lable_black)\n      没想到你这么快就采集了这么多矿石结晶，果然是英雄出少年啊！^"},
-----------------------------------------------------------------------------------------------------------------------------
  {q_id=101.0, q_role=5, q_text="小岩：^c(lable_black)\n      勇士，这里就是沙城了，沙城城主就在皇宫内，前往击杀他就可以占领沙城了！^"},
  {q_id=102.0, q_role=0, q_text="%s：^c(lable_black)\n      他们人数众多，想要冲入皇宫非常困难。^"},
  {q_id=103.0, q_role=5, q_text="小岩：^c(lable_black)\n      没关系，你的兄弟会帮你。相信你的兄弟，团结一致，你一定会夺下沙城的！^"},
  {q_id=104.0, q_role=0, q_text="%s：^c(lable_black)\n      既然如此，兄弟们，随我攻下沙城！^"},
  {q_id=105.0, q_role=5, q_text="小岩：^c(lable_black)\n     勇士，这里就是沙城皇宫了，沙城成员就在这里防守，杀光他们，并守住这里5秒钟，就可以占领沙城了！ ^"},
  {q_id=106.0, q_role=0, q_text="%s：^c(lable_black)\n      保证5秒钟内只有我们行会的成员在皇宫内吗？这个要求很困难！^"},
  {q_id=107.0, q_role=5, q_text="小岩：^c(lable_black)\n      没关系，你的兄弟会在皇宫外阻挡他们！^"},
  {q_id=108.0, q_role=0, q_text="%s：^c(lable_black)\n      既然如此，兄弟们，杀光他们！^"},
------------------------------------------------------------------------------------------------------------------------------
  {q_id=201.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      入侵者攻过来了！大伙守住皇宫！^"},
  {q_id=202.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      %s，来我这里，速回皇宫支援！^"},
  {q_id=203.0, q_role=13, q_text="道尊·百谷：^c(lable_black)\n      不好，他们霸占了皇宫的复活点！！^"},
  {q_id=204.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      大伙一起杀出去！^"},
  {q_id=206.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      随我推过去！^"},
  {q_id=207.0, q_role=11, q_text="战神·孟虎：^c(lable_black)\n      守住了！胜！^"},
  {q_id=208.0, q_role=0, q_text="众人：^c(lable_black)\n      胜！！！！^"},
------------------------------------------------------------------------------------------------------------------------------
  {q_id=301.0, q_role=13, q_text="百谷：^c(lable_black)\n      中州形式越来越严峻，魔界妖怪居然开始伪装成中州勇士通过这条物资线往中州城内运送魔界秽物！^"},
  {q_id=302.0, q_role=0, q_text="%s：^c(lable_black)\n      这么可恶，我们必须阻止他们！^"},
  {q_id=303.0, q_role=13, q_text="百谷：^c(lable_black)\n      是的，必须仔细辨别这条路的运镖者，发现魔界伪装人立刻拦截！^"},
  {q_id=304.0, q_role=13, q_text="百谷：^c(lable_black)\n      根据侦查军士报告，前方正好有一批魔界妖怪伪装的运镖队，我们去截住他们！^"},
  {q_id=305.0, q_role=13, q_text="百谷：^c(lable_black)\n     终于击败了这些魔界的伪装者，%s以后得时刻留意这些运镖者！ ^"},
  {q_id=306.0, q_role=0, q_text="%s：^c(lable_black)\n      我会的，请百谷放心！^"},
  {q_id=307.0, q_role=13, q_text="百谷：^c(lable_black)\n     我再去前方看看，你留下来先把这里清理了吧！^"},
-----------------------------------------------------------------------------------------------------------------------------
  {q_id=320.0, q_role=13, q_text="百谷：^c(lable_black)\n      可恶，这是援助中州抵御魔界入侵的物资，你们竟然敢抢夺？^"},
  {q_id=321.0, q_role=10021, q_text="劫镖者：^c(lable_black)\n      中州是大家的，所以也是我们的，兄弟们，抢！^"},
  {q_id=322.0, q_role=0, q_text="%s：^c(lable_black)\n      前方好像出现了什么情况，赶紧去看看！^"},
  {q_id=323.0, q_role=0, q_text="%s：^c(lable_black)\n     无恶不作，连中州物资也抢夺！^"},
  {q_id=324.0, q_role=13, q_text="百谷：^c(lable_black)\n      %s，来的正好，助我退敌！^"},
  {q_id=325.0, q_role=10021, q_text="劫镖者：^c(lable_black)\n     又来一个送死的！ ^"},
  {q_id=326.0, q_role=13, q_text="百谷：^c(lable_black)\n     感谢%s的帮助，终于赶走了这帮镖贼，最后这段物资通路越来越不安全，%s帮我一起运送完这批物资吧！^"},
  {q_id=327.0, q_role=13, q_text="百谷：^c(lable_black)\n    果不其然，杀过去再说！^"},
  {q_id=328.0, q_role=0, q_text="%s：^c(lable_black)\n     好！这些真的是人类的败类！^"},
  {q_id=329.0, q_role=13, q_text="百谷：^c(lable_black)\n     感谢%s的帮助，前面就是物资接引点了，应该安全了！ ^"},
  {q_id=330.0, q_role=0, q_text="%s：^c(lable_black)\n     不用客气，保卫中州是我的责任，每趟物资都需要你亲自押运，抵御魔界大军的事怎么办？^"},
  {q_id=331.0, q_role=13, q_text="百谷：^c(lable_black)\n     目前还好，魔界大军还没有大举进攻，有洪和猛虎在，暂时可抵御住，不过情形不太乐观，后面还是要中州的勇士们帮忙运送，以后你押运时最好和其他勇士组队一起，防止被这些败类劫掠！^"},
  {q_id=332.0, q_role=13, q_text="百谷：^c(lable_black)\n   感谢你的帮助，我们先走了！^"},
}


return Items