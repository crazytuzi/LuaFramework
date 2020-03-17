--[[
联运平台配置
lizhuangzhuang
2015年11月11日16:41:06
]]

_G.LianYunCfg = {
	--yy
	duowan = {
		chargeUrl = "https://gpay.duowan.com/deposit/depositeFromGame.do?product=DZZ&server=s{skey}&userid={uid}",
		fangChenMiUrl = "http://fcm.duowan.com/user/index.do",
		reportUrl = "http://client.garbage.game.yy.com/reportable.do",
		collectUrl = "http://client.garbage.game.yy.com/collect.do",
		reportProfileUrl = "http://stat.game.yy.com/data.do",
		baifuAct = "http://dzz.yy.com/1512/313170618357.html "
	},
	--顺网
	swjoy = {
		chargeUrl = "http://convert.swjoy.com/3251.htm",
		liaojieVip = "http://vip.kedou.com/front/vipCenter/showMyVipCenter.htm",
		upViplvl = "http://convert.swjoy.com/3250.htm"
	},
	--飞火
	feihuo = {
		chargeUrl = "http://plat.feihuo.com/url/index?type=pay_url&slug=dzz&user={uid}&sid={skey}",
		fangChenMiUrl = "http://plat.feihuo.com/url/index?type=fcm_url&slug=dzz&user={uid}",
		phoneBind = "http://plat.feihuo.com/url/index?type=tel_url&slug=dzz&user={uid}&sid={skey}"
	},
	--迅雷
	xunlei = {
		chargeUrl = "http://pay.niu.xunlei.com/dzz/",
		fangChenMiUrl = "http://youxi.xunlei.com/fcm/",
		boxUrl = "http://down.sandai.net/xlgamebox/XLGameBox.exe",
		webQQUrl = "http://wpa.b.qq.com/cgi/wpa.php?ln=1&key=XzgwMDA1MTU1MV8yMzI1NDFfODAwMDUxNTUxXzJf",
		phoneBind = "http://t.cn/RU7Ifei",
	},
	--37wan
	["37wan"] = {
		chargeUrl = "http://pay.37.com/select.php?gamename=dzz&gameserver=S{skey}&username={uid}",
		fangChenMiUrl = "http://my.37.com/user/",
		phoneBind = "http://gametask.37wan.com/index.php?c=complete_phone&a=game_redirect_platform&gamename=dzz&sid={skey}&username={uid}&actor={roleId}&time={curTime}&sign={sign}",
		key = "z90u3&2IDthMY-N51T(C"
	},
	--602
	["602"] = {
		chargeUrl = "http://pay.602.com/?g=dzz&s={skey}&account={uid}",
		fangChenMiUrl = "http://www.602.com/jiazhang/index.html",
	},
	--52xiyou
	["52xiyou"] = {
		chargeUrl = "www.52xiyou.com/payment.html?gid=86&sno={skey}",
		fangChenMiUrl = "http://www.52xiyou.com/member/addiction_prevention.html",
	},
	--起点
	qidian = {
		chargeUrl = "http://game.qidian.com/game/wsdzz/pay.aspx",
		fangChenMiUrl = "http://game.qidian.com/User/consume/Wallow.aspx",
	},
	--51
	["51"] = {
		chargeUrl = "http://gamepay.51.com/paygame/index.php?appkey=1bd45ad2c5d99c140224fe1eedc3d5f9&areasign={skey}",
		fangChenMiUrl = "http://game.51.com/main/realname/",
	},
	--页游8
	yeyou8 = {
		chargeUrl = "http://www.yeyou8.cn/Payment?gid=4",
	},
	--酷狗
	kugou = {
		chargeUrl = "http://dzz.kugou.com/pay/?server={skey}",
		fangChenMiUrl = "http://dzz.kugou.com/fcm/",
		boxUrl = "http://downmini.kugou.com/KGGouWo-6012.1963-1003.exe",
	},
	--2217
	["2217"] = {
		chargeUrl = "http://www.tonnn.com/payment/?game_id=80&server_id={skey}&username={uid}",
	},
	--哥们网
	game2 = {
		chargeUrl = "http://pay.game2.cn/pay/g/dzz/s/{skey}/u/{uid}/",
		fangChenMiUrl = "https://passport.game2.cn/bindidcard/",
	},
	--快玩
	teeqee = {
		chargeUrl = "http://pay.teeqee.com/pay/index/?game_id=",
		fangChenMiUrl = "http://user.teeqee.com/account/anti/indulged/",
	},
	--pps
	pps = {
		chargeUrl = "http://pay.game.pps.tv/gamepay/game_pay_main/index?g_id=4080&server_type={skey}",
		fangChenMiUrl = "http://game.pps.tv/weblogin/login?preurl=http%3A%2F%2Fvip.game.pps.tv#fill-identity",
	},
	--V1
	v1 = {
		chargeUrl = "http://v1game.cn/pay/pay.shtml?uid={uid}",
	},
	--2144
	["2144"] = {
		chargeUrl = "http://web.2144.cn/orders/index/gid/127",
		fangChenMiUrl = "http://my.2144.cn/safe",
	},
	--光宇
	gyyx = {
		chargeUrl = "http://pay.gyyx.cn/gamepay/paygold?gameId=10052",
		fangChenMiUrl = "http://reg.gyyx.cn/Member/CustomUserCompleteInfo",
	},
	--搜狗
	sogou = {
		chargeUrl = "http://wan.sogou.com/pay.do?gid=607&sid={skey}&u={uid}",
		fangChenMiUrl = "http://wan.sogou.com/u/fcm.do",
		downGameBox = "http://p1.wan.sogoucdn.com/cdn/mini/setup/1277/SogouGame_0.0.0.1.exe",
		downSkin = "http://dl.pinyin.sogou.com/skins/upload_images/20151211123210.ssf?dn=%A1%BE%CB%D1%B9%B7%D3%CE%CF%B7%A1%BF%B4%F3%D6%F7%D4%D7.ssf&skin_id=519087",
	},
	--闯天下
	ccttx = {
		chargeUrl = "http://pay.ccttx.com/?game=dzz",
		fangChenMiUrl = "http://passport.ccttx.com/setreal.shtml",
	},
	--8090
	["8090yxs"] = {
		chargeUrl = "http://member.8090yxs.com/platform/h.php?act=pay&game=dzz&server=s{skey}&username={uid}",
	},
	--pptv
	pptv = {
		chargeUrl = "http://g.pptv.com/link/pay?gid=dzz&sid={skey}",
		fangChenMiUrl = "http://g.pptv.com/link/fcm?gid=dzz",
	},
	--欢乐园
	hly = {
		chargeUrl = "http://pay.hly.com/dzz-{skey}-{uid}.html",
		fangChenMiUrl = "http://my.hly.com/user/fcm",
	},
	--酷客玩
	kukewan = {
		chargeUrl = "http://www.kukewan.com/pay/?game=62&server_id={skey}&user={uid}",
	},
	--51wan
	["51wan"] = {
		chargeUrl = "http://pay.51wan.com/index.php?module=trade&control=index&xy=wsdzz",
		fangChenMiUrl = "http://hi.51wan.com/security.html",
	},
	--265g
	["265g"] = {
		chargeUrl = "http://pay.265g.com",
		fangChenMiUrl = "http://wan.265g.com/usercenter/fcm.html",
	},
	--9211
	["9211"] = {
		chargeUrl = "http://pay.9211.com/?appinfo=1000097,{skey}",
		fangChenMiUrl = "http://passport.9211.com/user/idcard.aspx",
	},
	--CNWAN
	cnwan = {
		chargeUrl = "http://www.cnwan.com/pay",
		fangChenMiUrl = "http://www.cnwan.com/home/aboutcustody",
	},
	--甲子
	ccjoy = {
		chargeUrl = "http://login.ccjoy.cc/GamePayLink.ashx?serviceregion=ZZ&account={uid}&server={skey}",
		fangChenMiUrl = "http://kf.ccjoy.com/jhgc.aspx",
	},
	--77313
	["77313"] = {
		chargeUrl = "http://www.77313.com/pay/payinfo/gameid/59",
		fangChenMiUrl = "http://www.77313.com/user/fcm",
	},
	--缘来网
	yuanlai = {
		chargeUrl = "http://game.yuanlai.com/pay/pay.html?gameId=10062",
	},
	--星碟
	ufojoy = {
		chargeUrl = "http://www.ufojoy.com/api/h.phtml?gid=441&t=pay&u={uid}",
		fangChenMiUrl = "http://www.ufojoy.com/api/h.phtml?gid=441&t=my&u={uid}",
	},
	--i8you
	i8you = {
		chargeUrl = "http://www.i8you.com/pay/index.html?gid=704&sid={skey}&uid={uid}",
		fangChenMiUrl = "http://www.i8you.com/user/certif_edit.php?uid={uid}",
	},
	--kxwan
	kxwan = {
		chargeUrl = "http://c.kxwan.com/pay?gid=55&server_id={skey}",
		fangChenMiUrl = "http://user.kxwan.com/"
	},
	--360uu
	["360uu"] = {
		chargeUrl = "http://www.360uu.com/url-140-pay.html",
		fangChenMiUrl = "http://www.360uu.com/url-140-fcm.html",
	},
	--16768
	["16768"] = {
		chargeUrl = "http://www.16768.com/pay/index/gameId/50",
		fangChenMiUrl = "http://www.16768.com/user/userarchives  ",
	},
	--59yx
	["59yx"] = {
		chargeUrl = "http://www.59yx.com/RchargeWay?gid=127&uid={uid}",
	},
	--511wan
	["511wan"] = {
		chargeUrl = "http://www.511wan.com/link.jsp?t=pay&g=207&e={skey}&u={uid}",
		fangChenMiUrl = "http://www.511wan.com/link.jsp?t=my&g=207",
	},
	--45wan
	["45wan"] = {
		chargeUrl = "http://www.45wan.com/pay.html?uid={uid}",
		fangChenMiUrl = "http://www.45wan.com/user/realname.html"
	},
	--883
	["883"] = {
		chargeUrl = "http://www.883wan.com/pay/index/gid/167/sid/{skey}.html",
		fangChenMiUrl = "http://www.883wan.com/user/indulge.html",
	},
	--wywan
	wywan = {
		chargeUrl = "http://wywan.com/pay-order.html?gid=62464",
		fangChenMiUrl = "http://wywan.com/user/realname.html",
	},
	--97971
	["97971"] = {
		chargeUrl = "http://www.97971.com/game_pay.shtml?gameId=27",
		fangChenMiUrl = "http://member.97971.com/cardno.shtml",
	},
	--6998
	["6998"] = {
		chargeUrl = "http://pay.6998.com/IPay/Index/?g=dzz",
	},
	--sina
	sina = {
		chargeUrl = "http://game.weibo.com/woshidazhuzai?pay=180013041001",
		fangChenMiUrl = "http://game.weibo.com/home/user/authResultOk",
	},
	--ku25
	ku25 = {
		chargeUrl = "http://www.ku25.com/pay.php?id=109",
		fangChenMiUrl = "http://www.ku25.com/fcm.php",
	},
	--u8wan
	u8wan = {
		chargeUrl = "http://pay.u8wan.com/?game_id=dzz&server_id={skey}&player={uid}",
	},
	--yilewan
	yilewan = {
		chargeUrl = "https://billing.stnts.com/api/billing/pay.do?game_code=dzz&uid={uid}",
		fangChenMiUrl = "http://www.yilewan.com/Service/showList/column_id/0803",
	},
	--34560
	["34560"] = {
		chargeUrl = "http://www.34560.com/pay?gid=dzz",
		fangChenMiUrl = "http://www.34560.com/member/fcm",
	},
	--bigzhu
	bigzhu = {
		chargeUrl = "http://www.bigzhu.com/Payment?gid=121&server_id={skey}&uid={uid}",
		fangChenMiUrl = "http://www.bigzhu.com/Usercenter/baseuser/id/1",
	},
	--9377
	["9377"] = {
		chargeUrl = "http://www.9377.com/pay_index.php?game=dzz&server={skey}&uname={uid}",
		fangChenMiUrl = "http://www.9377.com/users/users_index.php?type=3",
	},
	--皮皮
	pipi = {
		chargeUrl = "http://game.pipi.cn/initPay.action?game_id=44",
		fangChenMiUrl = "http://game.pipi.cn/fangchenmi.html",
	},
	--66you
	["66you"] = {
		chargeUrl = "http://dzz.66you.com/go/pay/?u={uid}",
		fangChenMiUrl = "http://dzz.66you.com/go/home/?u={uid}",
	},
	--17aiwan
	["17aiwan"] = {
		chargeUrl = "http://pay.17aiwan.com/?payway=1&gname=dzz",
		fangChenMiUrl = "http://www.17aiwan.com/jzjh/",
	},
	--17lailai
	["17lailai"] = {
		chargeUrl = "http://www.17lailai.com/Charge/Charge.aspx",
		fangChenMiUrl = "http://www.17lailai.com/Activity/wcnbh/service.htm",
	},
	--zixia
	zixia = {
		chargeUrl = "http://paygame.zixia.com/?g=dzz&s={skey}",
		fangChenMiUrl = "http://u.zixia.com/application/index/preventindulge/0/0/0/",
	},
	--160yx
	["160yx"] = {
		chargeUrl = "http://www.160yx.com/paym.html?gid=120",
	},
	--酷我
	kuwo = {
		chargeUrl = "https://pay.kuwo.cn/pay/?g=Dzz&gsid={skey}",
		fangChenMiUrl = "http://game.kuwo.cn/g/st/perfectInfo?act=chenmi",
	},
	--shenmayx
	shenmayx = {
		chargeUrl = "http://member.shenmayx.com/platform/count.php?act=pay&game=dzz&username={uid}&server=s{skey}",
		fangChenMiUrl = "http://member.shenmayx.com/platform/count.php?act=member&game=dzz&username={uid}&server=s{skey}",
	},
	--pkpk6
	pkpk6 = {
		chargeUrl = "http://www.pkpk6.com/pay.html?game_id=42&server_num={skey}&user_id={uid}",
	},
	--
	aiyeyou = {
		chargeUrl = "http://www.aiyeyou.com/Payment?gid=2&server={skey}&user={uid}",
	},
	--3737g
	["3737g"] = {
		chargeUrl = "http://dzz.3737g.com/go/pay/?u={uid}",
		fangChenMiUrl = "http://dzz.3737g.com/go/home/?u={uid}",
	}
}