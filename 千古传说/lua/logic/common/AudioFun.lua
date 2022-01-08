

function audioClickfun(fun,effectFun)
  return function( sender )
  	effectFun = effectFun or play_press;
     effectFun();
     fun(sender);
  end
end

function play_press()
     TFAudio.playEffect("sound/effect/queding.mp3", false)
end

--布阵-落下ok
function play_buzhenluoxia()
     TFAudio.playEffect("sound/effect/buzhen-luoxia.mp3", false)
end
--布阵-移动ok
function play_buzhenyidong()
     TFAudio.playEffect("sound/effect/buzhen-yidong.mp3", false)
end
--冲穴ok
function play_chongxue()
     TFAudio.playEffect("sound/effect/chongxue.mp3", false)
end
--冲穴ok
function play_chongxuefail()
     TFAudio.playEffect("sound/effect/roleupgrade.mp3", false)
end
--传功-魂魄移动ok
function play_chuangonghunpoyidong()
     TFAudio.playEffect("sound/effect/chuangong-hunpoyidong.mp3", false)
end
--传功-人物升级ok
function play_chuangongrenwushengji()
     TFAudio.playEffect("sound/effect/chuangong-renwushengji.mp3", false)
end
--返回ok
function play_fanhui()
     TFAudio.playEffect("sound/effect/fanhui.mp3", false)
end
--合成-宝石嵌入ok
function play_hechengbaoshiqianru()
     TFAudio.playEffect("sound/effect/hecheng-baoshiqianru.mp3", false)
end
--合成-合成ok
function play_hechenghecheng()
     TFAudio.playEffect("sound/effect/hecheng-hecheng.mp3", false)
end
--技能修炼ok
function play_jinengxiulian()
     TFAudio.playEffect("sound/effect/jinengxiulian.mp3", false)
end
--进入游戏ok
function play_jinruyouxi()
     TFAudio.playEffect("sound/effect/jinruyouxi.mp3", false)
end
--精炼ok
function play_jinglian()
     TFAudio.playEffect("sound/effect/jinglian.mp3", false)
end
--精炼上锁ok
function play_linglianshangsuo()
     TFAudio.playEffect("sound/effect/jingliangshangsuo.mp3", false)
end
--强化暴击&升星成功ok
function play_qianghuabaoji_shengxingchenggong()
     TFAudio.stopAllEffects()
     TFAudio.playEffect("sound/effect/qianghuabaoji_shengxingchenggong.mp3", false)
end
--确定
function play_queding()
     TFAudio.playEffect("sound/effect/queding.mp3", false)
end
--升星失败ok
function play_shengxingshibai()
     TFAudio.playEffect("sound/effect/shengxingshibai.mp3", false)
end
--十里&百里招募ok
function play_shili_bailizhaomu()
     TFAudio.playEffect("sound/effect/shili_bailizhaomu.mp3", false)
end
--数字变动
function play_shuzibiandong()
     TFAudio.playEffect("sound/effect/shuzibiandong.mp3", false)
end
--万里-甲级出现ok
function play_wanlijiajichuxian()
     TFAudio.playEffect("sound/effect/wanli-jiajichuxian.mp3", false)
end
--万里-招募ok
function play_wanlizhaomu()
     TFAudio.playEffect("sound/effect/wanli-zhaomu.mp3", false)
end
--镶嵌ok
function play_xiangqian()
     TFAudio.playEffect("sound/effect/xiangqian.mp3", false)
end
--修炼等级提升ok
function play_xiuliandengjitisheng()
     TFAudio.playEffect("sound/effect/xiuliandengjitisheng.mp3", false)
end
--选择
function play_xuanze()
     TFAudio.stopAllEffects()
     TFAudio.playEffect("sound/effect/xuanze.mp3", false)
end
--一键上阵ok
function play_yijianshangzhen()
     TFAudio.playEffect("sound/effect/yijianshangzhen.mp3", false)
end
--操作失败
function play_caozuoshibai()
     TFAudio.playEffect("sound/effect/caozuoshibai.mp3", false)
end
--领取（元宝、铜币类、包括成就内领取）
function play_lingqu()
     TFAudio.playEffect("sound/effect/lingqu.mp3", false)
end
--任何人民币购买、充值成功（如月卡、元宝）
function play_chongzhichenggong()
     TFAudio.playEffect("sound/effect/chongzhichenggong.mp3", false)
end

--领导力提升界面（领导力升级的光效）
function play_lingdaolitisheng()
     TFAudio.playEffect("sound/effect/lingdaolitisheng.mp3", false)
end

--扫荡结算动画（最后面扫荡结算的光效）
function play_saodangjiesuan()
     TFAudio.playEffect("sound/effect/saodangjiesuan.mp3", false)
end

--碰碗
function play_zhaomu_pengwan()
     TFAudio.playEffect("sound/effect/pengwan.mp3", false)
end

--抽到侠客时播放
function play_zhaomu_chouquxiake()
     TFAudio.playEffect("sound/effect/chouquxiake.mp3", false)
end
--抽到侠魂时
function play_zhaomu_chouquxiahun()
     TFAudio.playEffect("sound/effect/chouquxiahun.mp3", false)
end

--战斗开始
function play_fight_begin()
     TFAudio.playEffect("sound/effect/fight_begin.mp3", false)
end

--采矿刷新品质
function play_caikuang_shuaxin()
     TFAudio.playEffect("sound/effect/martial.mp3",false) 
end

--有人采矿、带开采和采矿中
function play_daicaikuang()
     return TFAudio.playEffect("sound/effect/intensify.mp3", false)
end

--采矿领取佣金
function play_lingquyongjin()
     return TFAudio.playEffect("sound/effect/openbox.mp3", false)
end

--八卦转动
function play_baguazhuandong()
     TFAudio.playEffect("sound/effect/baguazhuandong.mp3", false)
end

--祭拜成功、开启研究修炼技能成功
function play_jibaichenggong()
     TFAudio.playEffect("sound/effect/yijianshangzhen.mp3", false)
end

--前行脚步声
function play_qianxing_jiaobusheng()
     return TFAudio.playEffect("sound/effect/jiaobusheng.mp3", false)
end
