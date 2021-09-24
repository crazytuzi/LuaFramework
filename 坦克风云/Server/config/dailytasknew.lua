local dailytask={
r=10,
t={
s101={type=20,award={userinfo_gold=200000},conditions=3,},        --Íê³É·¢Õ¹ÈÎÎñ
s102={target="s101",type=1,award={userinfo_gold=20000,userinfo_r1=20000},conditions=10,},        --Éú²úÌ¹¿Ë
s103={target="s101",type=2,award={userinfo_gold=20000,userinfo_r2=20000},conditions=1,},        --Éý¼¶½¨Öþ
s104={target="s101",type=3,award={userinfo_gold=20000,userinfo_r3=20000},conditions=1,},         --Éý¼¶¿Æ¼¼

s201={type=21,award={userinfo_exp=30000,props_p673=1},conditions=3,},        --Íê³ÉÕ½¶·ÈÎÎñ
s202={target="s201",type=6,award={userinfo_honors=10},conditions=2,},        --¹¥»÷Íæ¼Ò
s203={target="s201",type=5,award={userinfo_honors=10},conditions=2,},        --¹¥»÷ÆÕÍ¨¹Ø¿¨

s205={target="s201",type=4,award={userinfo_honors=30},conditions=3,},        --¹¥»÷¿óµã

s301={type=22,award={props_p10=1},raising=20,conditions=4,},        --Íê³É¾üÍÅÈÎÎñ
s302={target="s301",type=11,award={props_p19=1},conditions=1,},        --¿Û¹±Ï×Áì±¦Ïä
s303={target="s301",type=12,award={props_p19=1},conditions=1,},        --Ð­·À²¿¶Ó

s305={target="s301",type=14,award={props_p19=3},conditions=5,},        --¾üÍÅ¾èÏ×
s306={target="s301",type=15,award={props_p19=5},conditions=2,},        --¾üÍÅ¸±±¾
s401={type=23,award={props_p416=1},conditions=3,},        --Íê³ÉÌØÈ¨ÈÎÎñ
s402={target="s401",type=16,award={props_p415=1},conditions=1,},        --¼ÓËÙÒ»´Î
s403={target="s401",type=17,award={props_p415=1},conditions=1,},        --³äÖµÒ»´Î
s404={target="s401",type=18,award={props_p415=1},conditions=2,},        --¸ß¼¶³é½±
s405={target="s401",type=19,award={props_p415=1},conditions=1,},        --¹ºÂòÉÌµê
s1={target="s201",type=24,award={props_p416=1},conditions=1,isUrgency=1,time=3600,},        --½Ù¸»¼ÃÆ¶(Ò°¿ó)
s2={target="s201",type=25,award={props_p416=1},conditions=1,isUrgency=1,time=3600,},        --Ç§¾ûÒ»·¢(¹Ø¿¨)
}
}
function dailytask.gets1(lvl)			
    return math.floor(math.min(lvl-24,50))			
end			
			
function dailytask.gets2(lvl)			
    return math.floor(math.min(lvl*1,176))			
end
return dailytask
