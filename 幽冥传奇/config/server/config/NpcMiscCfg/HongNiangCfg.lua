
HongNiangCfg =
{
	needLevel = 75,
	hongNiangNPCPos = {36,95},
	itemId = 3555,
	conditionDesc = "结婚条件: {color;ff00ff00;%d级、男女双方同在队伍里}\n结婚消耗: {color;ff00ff00;1000万绑金(申请结婚一方出)}",
	okBtn = "{btn;0;确定;%s;}",
	buyBtn = "{btn;0;购买烟花;%s;}",
	radios = {
		{ btnName = "发征婚广告(费用1万绑金)", 	moneyType = 0, money = 10000},
		{ btnName = "进行结婚(费用1000万绑金)", moneyType = 0, money = 10000000},
		{ btnName = "进行离婚(费用100万绑金)", 	moneyType = 0, money = 1000000},
		{ btnName = "强制离婚(费用1000元宝)", 	moneyType = 3, money = 1000},
		{ btnName = "发放100元宝庆祝", 		moneyType = 3, money = 100},
		{ btnName = "发放10000元宝庆祝", 	moneyType = 3, money = 10000},
	},
	mail ={
		title = "解除婚约通知",
		desc = 	"亲爱的玩家:\n\t很遗憾通知您, {color;FF63B8FF;%s}与您解除了婚姻关系。",
	},
}