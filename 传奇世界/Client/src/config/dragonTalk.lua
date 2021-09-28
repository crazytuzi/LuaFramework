local Items =
{

	{q_plot=1.0, q_id=1001.0, q_role=20002, q_btn_text="继续", q_needName=0, q_text="老兵：^c(lable_black)\n      年轻的勇士，请止步。前面很危险！^"},
	{q_plot=1.0, q_id=1002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      老人家，你好！是圣王派我来这里的，还请您介绍一下这里的情况。^"},
	{q_plot=1.0, q_id=1003.0, q_role=20002, q_btn_text="继续", q_needName=0, q_text="老兵：^c(lable_black)\n      曾经的东方帝王战败后，他的亲信部下将国库宝藏和自己一同作为陪葬埋入陵墓，于是这个陵墓成了所有盗墓者最向往的圣地…^"},
	{q_plot=1.0, q_id=1004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      后来呢？这附近看起来人烟稀少的样子….^"},
	{q_plot=1.0, q_id=1005.0, q_role=20002, q_btn_text="继续", q_needName=0, q_text="老兵：^c(lable_black)\n      后来的盗墓者一个个都有去无回，他们死后变成了尸卫，守卫着整个将军坟洞口，现在竟然游荡到了洞口。^"},
	{q_plot=1.0, q_id=1006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n      原来这就是圣王派我来这里的原因，那么一切交给我吧。^"},
	
	{q_plot=2.0, q_id=2001.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李将军：^c(lable_black)\n      乱世将起，年轻的勇士，有一个艰巨的任务需要拜托你了！^"},
	{q_plot=2.0, q_id=2002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      您太客气了，国王派我过来就是为了这件事的，还请介绍一下具体情况.^"},
	{q_plot=2.0, q_id=2003.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李将军：^c(lable_black)\n      古老的天工族神匠元钺曾经在这里制造了大量机关武器，没想到竟导致整个族人灭绝。后来这里就变成了机关横行的机关洞窟。^"},	
	{q_plot=2.0, q_id=2004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      那么我的任务是什么？^"},
	{q_plot=2.0, q_id=2005.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李将军：^c(lable_black)\n      你要深入机关洞深处，击杀其中的机关巨兽，找寻远古天工一族真正的机关之秘。留给我们的时间不多了！^"},
	{q_plot=2.0, q_id=2006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n      看起来不像是很轻松的任务，不过这样才有挑战么！^"},

	{q_plot=3.0, q_id=3001.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李虎：^c(lable_black)\n      没想到时隔多年又回来这里了！^"},
	{q_plot=3.0, q_id=3002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      蛇魔谷的三头蛇王不是被您和其他勇士杀死了么，为什么还要回到这里？^"},
	{q_plot=3.0, q_id=3003.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李虎：^c(lable_black)\n      这么多年过去，三头蛇王死了又出现了别的蛇王，引起了整个蛇魔谷暴动。^"},	
	{q_plot=3.0, q_id=3004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n      看起来这也是乱世将起的前兆呀！^"},
	{q_plot=3.0, q_id=3005.0, q_role=10396, q_btn_text="继续", q_needName=0, q_text="李虎：^c(lable_black)\n      前方的哨兵已经打探清楚了，新的蛇妖王就在蛇魔谷2层深处，干掉它，然后活着回来！^"},	
	{q_plot=3.0, q_id=3006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n      李队长，等我的好消息吧！^"},

	{q_plot=4.0, q_id=4001.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     你知道逆魔的传说么？^"},
	{q_plot=4.0, q_id=4002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     泥馍，那是什么？可以吃么？^"},
	{q_plot=4.0, q_id=4003.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     咳咳咳，是“逆魔”！有消息传来说这里沉睡的逆魔即将苏醒，我不放心要亲自过来看一下。^"},
	{q_plot=4.0, q_id=4004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     一路从跃马平原赶过来，隐藏在密林深处的古刹竟然还有这样的秘密！^"},
	{q_plot=4.0, q_id=4005.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     传说封印着逆魔的古刹也存在着世界上最珍贵的宝物，年轻的勇士你有没有兴趣一探究竟！^"},
	{q_plot=4.0, q_id=4006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n     管他泥馍还是逆魔，看我把他们统统消灭！^"},
	
	{q_plot=5.0, q_id=5001.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     中州最近的异变我已知晓，最近在铁血魔城附近也发现了修罗一族出没的痕迹，希望你能帮我调查一番！^"},
	{q_plot=5.0, q_id=5002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     圣王大人，请不要客气！刀山火海，在所不辞^"},
	{q_plot=5.0, q_id=5003.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     在你之前，玄玄老人已经进入了魔城但之后却音信全无。如果有可能的话，请你找到玄玄老人！^"},
	{q_plot=5.0, q_id=5004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     年纪这么大了还要到处乱跑，真不让人省心啊。^"},
	{q_plot=5.0, q_id=5005.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     我必须时刻警戒这里的异动，深入魔城后还请勇士一切小心。^"},
	{q_plot=5.0, q_id=5006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n     嘿，不就是铁血魔城么,就让我好好的闯它一闯！^"},
	
	{q_plot=6.0, q_id=6001.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     终于等到你了，年轻的勇士！^"},
	{q_plot=6.0, q_id=6002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     国王大人，中州异变已然发生，我能做点什么？^"},
	{q_plot=6.0, q_id=6003.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     最近通天塔封印泄漏出的魔气越来越浓了，恐怕……。^"},
	{q_plot=6.0, q_id=6004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     这么说来，通天教主即将要突破禁锢的封印了！^"},
	{q_plot=6.0, q_id=6005.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     是的，通天教主就被封印在最高层的九重云霄，你一定不能让他的图谋得逞！^"},
	{q_plot=6.0, q_id=6006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n     无论如何我都会阻止这一切发生，绝不会让梦境中的悲剧重演！^"},
	
	{q_plot=7.0, q_id=7001.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     等待这一天已经很久了，我已经准备好了！^"},
	{q_plot=7.0, q_id=7002.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     等待这一天已经很久了，我已经准备好了！^"},
	{q_plot=7.0, q_id=7003.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     阿修罗神是修罗天中最强大的生物，他的存在使得三界面临彻底毁灭。^"},
	{q_plot=7.0, q_id=7004.0, q_role=0, q_btn_text="继续", q_needName=1, q_text="%s：^c(lable_black)\n     我们曾经战胜过他，这一次我们依然会取得最后的胜利！^"},
	{q_plot=7.0, q_id=7005.0, q_role=10391, q_btn_text="继续", q_needName=0, q_text="孟虎：^c(lable_black)\n     阿修罗神虽然刚刚从封印中苏醒，但是实力依然不可小觑。^"},
	{q_plot=7.0, q_id=7006.0, q_role=0, q_btn_text="挑战", q_needName=1, q_text="%s：^c(lable_black)\n     一起上吧，圣王大人！^"},
}

return Items;