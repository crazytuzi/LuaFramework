--
-- facebook用户登录奖励
-- User: luoning
-- Date: 14-7-21
-- Time: 下午2:18
--
--[[
local facebook = {
    facebook用户奖励
    user = {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
    好友数量的当数
    invitation = {
        {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=100,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=100,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
        {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
    },
    每日首次邀请奖励
    dailyFirst = {userinfo_honors=70,userinfo_gems=500,props_p47=300,props_p31=400,props_p2=200,},
}
--]]
friendCfg=
{
    loginReward={reward={u={{gems=50}},p={{p20=3}},o={{a10003=20}},},serverreward={userinfo_gems=50,props_p20=3,troops_a10003=20,}},
    totalReward={
        {num=1,reward={u={{gems=20}},p={{p15=1},},},serverreward={userinfo_gems=20,props_p15=1,}},
        {num=5,reward={u={{gems=30}},p={{p12=1},{p19=20},},},serverreward={userinfo_gems=30,props_p12=1,props_p19=20,}},
        {num=10,reward={u={{gems=50}},p={{p11=2},{p20=5},},},serverreward={userinfo_gems=50,props_p11=2,props_p20=5,}},
        {num=20,reward={u={{gems=80}},p={{p14=2},{p19=100},},},serverreward={userinfo_gems=80,props_p14=2,props_p19=100,}},
        {num=50,reward={u={{gems=150}},p={{p47=10},{p2=1},},},serverreward={userinfo_gems=150,props_p47=10,props_p2=1,}},
        {num=100,reward={u={{gems=300}},p={{p5=2},{p20=10},},o={{a10004=20},},},serverreward={userinfo_gems=300,props_p5=2,props_p20=10,troops_a10004=20,}},
        {num=200,reward={u={{gems=500}},p={{p16=1},{p4=1},},o={{a10034=50},},},serverreward={userinfo_gems=500,props_p16=1,props_p4=1,troops_a10034=50,}},
    },
    inviteReward={reward={u={{gems=10}}},serverreward={userinfo_gems=10}},
}

return friendCfg
