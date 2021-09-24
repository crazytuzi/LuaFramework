serverCfg={}
if G_curPlatName()=="0" then --facebook 台湾
             serverCfg.allserver={
                cn={
                    {name="213-15009",userip="192.168.8.213",ip="192.168.8.213",port="15009",isnew=1,zoneid=9,domain="/gucenter/"},
                    {name="213-15008",userip="192.168.8.213",ip="192.168.8.213",port="15008",isnew=1,zoneid=8,domain="/gucenter/"},
                    {name="213-15007",userip="192.168.8.213",ip="192.168.8.213",port="15007",isnew=1,zoneid=7,domain="/gucenter/"},
                    {name="213-15006",userip="192.168.8.213",ip="192.168.8.213",port="15006",isnew=1,zoneid=6,domain="/gucenter/"},
                    {name="213-15005",userip="192.168.8.213",ip="192.168.8.213",port="15005",isnew=1,zoneid=5,domain="/gucenter/"},
                    {name="213-15004",userip="192.168.8.213",ip="192.168.8.213",port="15004",isnew=1,zoneid=4,domain="/gucenter/"},
                    {name="213-15003",userip="192.168.8.213",ip="192.168.8.213",port="15003",isnew=1,zoneid=3,domain="/gucenter/"},
                    {name="213-15002",userip="192.168.8.213",ip="192.168.8.213",port="15002",isnew=1,zoneid=2,domain="/gucenter/"},
                    {name="213-15001",userip="192.168.8.213",ip="192.168.8.213",port="15001",oldzoneid=1,zoneid=1,domain="/gucenter/"}

                },
                tw={
                    {name="223-15009",userip="192.168.8.223",ip="192.168.8.223",port="15009",isnew=1,zoneid=9,domain="/gucenter/"},
                    {name="223-15008",userip="192.168.8.223",ip="192.168.8.223",port="15008",isnew=1,zoneid=8,domain="/gucenter/"},
                    {name="223-15007",userip="192.168.8.223",ip="192.168.8.223",port="15007",isnew=1,zoneid=7,domain="/gucenter/"},
                    {name="223-15006",userip="192.168.8.223",ip="192.168.8.223",port="15006",isnew=1,zoneid=6,domain="/gucenter/"},
                    {name="223-15005",userip="192.168.8.223",ip="192.168.8.223",port="15005",isnew=1,zoneid=5,domain="/gucenter/"},
                    {name="223-15004",userip="192.168.8.223",ip="192.168.8.223",port="15004",isnew=1,zoneid=4,domain="/gucenter/"},
                    {name="223-15003",userip="192.168.8.223",ip="192.168.8.223",port="15003",isnew=1,zoneid=3,domain="/gucenter/"},
                    {name="223-15002",userip="192.168.8.223",ip="192.168.8.223",port="15002",isnew=1,zoneid=2,domain="/gucenter/"},
                    {name="223-15001",userip="192.168.8.223",ip="192.168.8.223",port="15001",zoneid=1,domain="/gucenter/"}
                },
                en={
                    {name="206-15009",userip="192.168.8.206",ip="192.168.8.206",port="15009",isnew=1,zoneid=9,domain="/gucenter/"},
                    {name="206-15008",userip="192.168.8.206",ip="192.168.8.206",port="15008",isnew=1,zoneid=8,domain="/gucenter/"},
                    {name="206-15007",userip="192.168.8.206",ip="192.168.8.206",port="15007",isnew=1,zoneid=7,domain="/gucenter/"},
                    {name="206-15006",userip="192.168.8.206",ip="192.168.8.206",port="15006",isnew=1,zoneid=6,domain="/gucenter/"},
                    {name="206-15005",userip="192.168.8.206",ip="192.168.8.206",port="15005",isnew=1,zoneid=5,domain="/gucenter/"},
                    {name="206-15004",userip="192.168.8.206",ip="192.168.8.206",port="15004",isnew=1,zoneid=4,domain="/gucenter/"},
                    {name="206-15003",userip="192.168.8.206",ip="192.168.8.206",port="15003",isnew=1,zoneid=3,domain="/gucenter/"},
                    {name="206-15002",userip="192.168.8.206",ip="192.168.8.206",port="15002",isnew=1,zoneid=2,domain="/gucenter/"},
                    {name="206-15001",userip="192.168.8.206",ip="192.168.8.206",port="15001",zoneid=1,domain="/gucenter/"}
                },
                de={
                    {name="207-15009",userip="192.168.8.207",ip="192.168.8.207",port="15009",isnew=1,zoneid=9,domain="/gucenter/"},
                    {name="207-15008",userip="192.168.8.207",ip="192.168.8.207",port="15008",isnew=1,zoneid=8,domain="/gucenter/"},
                    {name="207-15007",userip="192.168.8.207",ip="192.168.8.207",port="15007",isnew=1,zoneid=7,domain="/gucenter/"},
                    {name="207-15006",userip="192.168.8.207",ip="192.168.8.207",port="15006",isnew=1,zoneid=6,domain="/gucenter/"},
                    {name="207-15005",userip="192.168.8.207",ip="192.168.8.207",port="15005",isnew=1,zoneid=5,domain="/gucenter/"},
                    {name="207-15004",userip="192.168.8.207",ip="192.168.8.207",port="15004",isnew=1,zoneid=4,domain="/gucenter/"},
                    {name="207-15003",userip="192.168.8.207",ip="192.168.8.207",port="15003",isnew=1,zoneid=3,domain="/gucenter/"},
                    {name="207-15002",userip="192.168.8.207",ip="192.168.8.207",port="15002",isnew=1,zoneid=2,domain="/gucenter/"},
                    {name="207-15001",userip="192.168.8.207",ip="192.168.8.207",port="15001",zoneid=1,domain="/gucenter/"}
                },
                thai={
                    {name="208-15002",userip="192.168.8.208",ip="192.168.8.208",port="15002",isnew=1,zoneid=998,domain="/gucenter/"},
                    {name="208-15001",userip="192.168.8.208",ip="192.168.8.208",port="15001",zoneid=997,domain="/gucenter/"}
                },
                ["in"]={
                    {name="204-15004",userip="192.168.8.204",ip="192.168.8.204",port="15004",zoneid=4,domain="/gucenter/"},
                    {name="204-15003",userip="192.168.8.204",ip="192.168.8.204",port="15003",zoneid=3,domain="/gucenter/"},
                    {name="204-15002",userip="192.168.8.204",ip="192.168.8.204",port="15002",zoneid=998,domain="/gucenter/"},
                    {name="204-15001",userip="192.168.8.204",ip="192.168.8.204",port="15001",zoneid=997,domain="/gucenter/"},
                },
                ["MemoryServer"]={ --MS为1是怀旧服，mspid：怀旧服所在平台id，msip��怀旧服的gucenter入口机域名
                    {name="MS204-03",userip="192.168.8.204",ip="192.168.8.204",port="15003",zoneid=3,domain="/gucenter/",MS=1,mspid="fl_yueyu",msip="192.168.8.204"},
                },
                ["运维测试"]={
                    {name="52-15005",userip="192.168.8.52",ip="192.168.8.52",port="15005",zoneid=5,domain="/gucenter/"},
                    {name="52-15004",userip="192.168.8.52",ip="192.168.8.52",port="15004",zoneid=4,domain="/gucenter/"},
                    {name="52-15003",userip="192.168.8.52",ip="192.168.8.52",port="15003",zoneid=3,domain="/gucenter/"},
                    {name="52-15002",userip="192.168.8.52",ip="192.168.8.52",port="15002",zoneid=2,domain="/gucenter/"},
                    {name="52-15001",userip="192.168.8.52",ip="192.168.8.52",port="15001",zoneid=1,domain="/gucenter/"},
                }
           }
           serverCfg.allChatServer={
                cn={
                    {name="213-15009",ip="192.168.8.213",port=3091},
                    {name="213-15008",ip="192.168.8.213",port=3081},
                    {name="213-15007",ip="192.168.8.213",port=3071},
                    {name="213-15006",ip="192.168.8.213",port=3061},
                    {name="213-15005",ip="192.168.8.213",port=3051},
                    {name="213-15004",ip="192.168.8.213",port=3041},
                    {name="213-15003",ip="192.168.8.213",port=3031},
                    {name="213-15002",ip="192.168.8.213",port=3021},
                    {name="213-15001",ip="192.168.8.213",port=3001}
                },
                tw={
                    {name="223-15009",ip="192.168.8.223",port=3091},
                    {name="223-15008",ip="192.168.8.223",port=3081},
                    {name="223-15007",ip="192.168.8.223",port=3071},
                    {name="223-15006",ip="192.168.8.223",port=3061},
                    {name="223-15005",ip="192.168.8.223",port=3051},
                    {name="223-15004",ip="192.168.8.223",port=3041},
                    {name="223-15003",ip="192.168.8.223",port=3031},
                    {name="223-15002",ip="192.168.8.223",port=3021},
                    {name="223-15001",ip="192.168.8.223",port=3001}
                },
                en={
                    {name="206-15009",ip="192.168.8.206",port=3091},
                    {name="206-15008",ip="192.168.8.206",port=3081},
                    {name="206-15007",ip="192.168.8.206",port=3071},
                    {name="206-15006",ip="192.168.8.206",port=3061},
                    {name="206-15005",ip="192.168.8.206",port=3051},
                    {name="206-15004",ip="192.168.8.206",port=3041},
                    {name="206-15003",ip="192.168.8.206",port=3031},
                    {name="206-15002",ip="192.168.8.206",port=3021},
                    {name="206-15001",ip="192.168.8.206",port=3001}
                },
                de={
                    {name="207-15009",ip="192.168.8.207",port=3091},
                    {name="207-15008",ip="192.168.8.207",port=3081},
                    {name="207-15007",ip="192.168.8.207",port=3071},
                    {name="207-15006",ip="192.168.8.207",port=3061},
                    {name="207-15005",ip="192.168.8.207",port=3051},
                    {name="207-15004",ip="192.168.8.207",port=3041},
                    {name="207-15003",ip="192.168.8.207",port=3031},
                    {name="207-15002",ip="192.168.8.207",port=3021},
                    {name="207-15001",ip="192.168.8.207",port=3001}
                },
                thai={
                    {name="208-15002",ip="192.168.8.208",port=3021},
                    {name="208-15001",ip="192.168.8.208",port=3001}
                },
                ["in"]={
                    {name="204-15004",ip="192.168.8.204",port=3041},
                    {name="204-15003",ip="192.168.8.204",port=3031},
                    {name="204-15002",ip="192.168.8.204",port=3021},
                    {name="204-15001",ip="192.168.8.204",port=3001}
                },
                ["MemoryServer"]={
                    {name="MS204-03",ip="192.168.8.204",port=3031},
                },
                ["运维测试"]={
                    {name="52-15005",ip="192.168.8.52",port=3051},
                    {name="52-15004",ip="192.168.8.52",port=3041},
                    {name="52-15003",ip="192.168.8.52",port=3031},
                    {name="52-15002",ip="192.168.8.52",port=3021},
                    {name="52-15001",ip="192.168.8.52",port=3001},
                }
            }
            serverCfg.baseUrl="http://devtank.raysns.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/googleplay"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl="market://details?id=com.rayjoy.android.googleplay.tank"
            serverCfg.officialUrl="http://www.kotank.com"
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
elseif G_curPlatName()=="1"  then --快用平台
            serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-002",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-003",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15003",zoneid=3,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-004",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15004",isnew=1,zoneid=4,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="}}
                }
            serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-ky-cn.raysns.com",port=3001},{name="CN-002",ip="tank-ky-cn.raysns.com",port=3021},
                       {name="CN-003",ip="tank-ky-cn.raysns.com",port=3031},{name="CN-004",ip="tank-ky-cn.raysns.com",port=3041}}           
                   }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.svrCfgUrl="http://tank-ky-cn.raysns.com/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://tank-ky-cn.raysns.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-flyueyu-war.raysns.com/"

elseif G_curPlatName()=="42"  then --快用平台
            serverCfg.allserver={
            cn={{name="CN-001",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-002",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-003",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15003",zoneid=3,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="},{name="CN-004",userip="tank-ky-cn.raysns.com",ip="tank-ky-cn.raysns.com",port="15004",isnew=1,zoneid=4,domain="/gucenter/",loginurl="http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin",payurl="http://tank-ky-cn.raysns.com/tank_pay/index.php/kyorder?pm="}}
            }
            serverCfg.allChatServer={
                cn={{name="CN-001",ip="tank-ky-cn.raysns.com",port=3001},{name="CN-002",ip="tank-ky-cn.raysns.com",port=3021},
                {name="CN-003",ip="tank-ky-cn.raysns.com",port=3031},{name="CN-004",ip="tank-ky-cn.raysns.com",port=3041}}
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"

            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.svrCfgUrl="http://tank-ky-cn.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"
            serverCfg.checkEmojiUrl="http://tank-ky-cn.raysns.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-flyueyu-war.raysns.com/"


elseif G_curPlatName()=="2" then --yeahmobi 繁体版
            serverCfg.allserver={
                    tw={{name="TW-001",ip="tank-yemb-tw.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/"}}
                }
            serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank-yemb-tw.raysns.com",port=4001}}
                   }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
elseif G_curPlatName()=="qihoo" or G_curPlatName()=="androidqihoohjdg" then
            serverCfg.allserver={
                    cn={{name="CN-001",userip="114.67.212.154",ip="114.67.212.154",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-002",userip="114.67.212.154",ip="114.67.212.154",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},
                        {name="CN-003",userip="114.67.212.154",ip="114.67.212.154",port="15003",zoneid=3,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},
                        {name="CN-004",userip="114.67.212.154",ip="114.67.212.154",port="15001",zoneid=4,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},

                        {name="CN-005",userip="114.67.212.154",ip="114.67.212.154",port="15002",zoneid=5,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-006",userip="114.67.212.154",ip="114.67.212.154",port="15001",zoneid=6,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-007",userip="114.67.212.154",ip="114.67.212.154",port="15002",zoneid=7,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-008",userip="114.67.212.154",ip="114.67.212.154",port="15003",zoneid=8,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-009",userip="114.67.212.154",ip="114.67.212.154",port="15001",zoneid=9,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-010",userip="114.67.212.154",ip="114.67.212.154",port="15002",zoneid=10,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-011",userip="114.67.212.154",ip="114.67.212.154",port="15003",zoneid=11,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-012",userip="114.67.212.154",ip="114.67.212.154",port="15001",zoneid=12,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-013",userip="114.67.212.154",ip="114.67.212.154",port="15002",zoneid=13,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-014",userip="114.67.212.154",ip="114.67.212.154",port="15003",zoneid=14,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-015",userip="114.67.212.154",ip="114.67.212.154",port="15003",zoneid=15,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-016",userip="114.67.212.154",ip="114.67.212.154",port="15004",zoneid=16,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-017",userip="114.67.212.154",ip="114.67.212.154",port="15004",zoneid=17,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-018",userip="114.67.212.154",ip="114.67.212.154",port="15004",zoneid=18,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-019",userip="114.67.212.154",ip="114.67.212.154",port="15004",zoneid=19,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-020",userip="114.67.212.154",ip="tank-360-06.raysns.com",port="15001",zoneid=20,isnew=1,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"},{name="CN-021",userip="114.67.212.154",ip="tank-360-06.raysns.com",port="15002",zoneid=21,isnew=1,domain="/gucenter/",loginurl="http://114.67.212.154/qihooucenter/login.php",payurl="http://114.67.212.154/tank_pay/index.php/qihoo"}}
                }
            serverCfg.allChatServer={
                   cn={{name="CN-001",ip="114.67.212.154",port=3001},{name="CN-002",ip="114.67.212.154",port=3021},{name="CN-003",ip="114.67.212.154",port=3031},
                       {name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021},{name="CN-008",ip="114.67.212.154",port=3031},{name="CN-009",ip="114.67.212.154",port=3001},{name="CN-010",ip="114.67.212.154",port=3021},{name="CN-011",ip="114.67.212.154",port=3031},{name="CN-012",ip="114.67.212.154",port=3001},{name="CN-013",ip="114.67.212.154",port=3021},{name="CN-014",ip="114.67.212.154",port=3031},{name="CN-015",ip="114.67.212.154",port=3031},{name="CN-016",ip="114.67.212.154",port=3041},{name="CN-017",ip="114.67.212.154",port=3041},{name="CN-018",ip="114.67.212.154",port=3041},{name="CN-019",ip="114.67.212.154",port=3041},
                           {name="CN-020",ip="tank-360-06.raysns.com",port=3001},
                           {name="CN-021",ip="tank-360-06.raysns.com",port=3021}}
                   }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
            serverCfg.updateurl="http://114.67.212.154/TankHeroClient/getAppUrl.php"
            
elseif G_curPlatName()=="googleplay" then
            serverCfg.allserver={
                cn={{name="CN-002",userip="devtank.raysns.com",ip="devtank.raysns.com,devtank.raysns.com",port="15001,15001",isnew=1,zoneid=1,domain="/tank/"},{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",zoneid=1,domain="/tank/"}},
                tw={{name="TW-002",userip="devtank.raysns.com",ip="devtank.raysns.com,devtank.raysns.com",port="15001,15001",isnew=1,zoneid=1,domain="/tank/"},{name="TW-001",userip="devtank.raysns.com",ip="devtank.raysns.com,devtank.raysns.com",port="15001,15001",zoneid=1,domain="/tank/"}},
           }
           serverCfg.allChatServer={
                   cn={{name="CN-002",ip="devtank.raysns.com",port=3008},{name="CN-001",ip="devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="http://devtank.raysns.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/googleplay"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl="market://details?id=com.rayjoy.android.googleplay.tank"
elseif G_curPlatName()=="android360ausgoogle" then
            serverCfg.allserver={
                au={{name="AU-001",userip="tank-au-in.raysns.com",ip="tank-au-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"},
                   },
           }
           serverCfg.allChatServer={
                   au={{name="AU-001",ip="tank-au-web01.raysns.com",port=3001},},
            
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/googleplay"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankhtml/tank.html"
            serverCfg.updateurl="market://details?id=com.rayjoy.android.googleplay.tank"
            serverCfg.svrCfgUrl="http://tank-au-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.bbsurl="http://www.facebook.com/Gears.au"
elseif G_curPlatName()=="androidjapan" then
            serverCfg.allserver={
                           ja={{name="JP-001",userip="tank-jp-in.raysns.com",ip="tank-jp-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl=""}},
        }
           serverCfg.allChatServer={
                   ja={{name="JP-001",ip="tank-jp-web01.raysns.com",port=3001}},
            
            }
            serverCfg.baseUrl="tank-jp-in.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/googleplay"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl="market://details?id=com.rayjoy.android.googleplay.tank"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-jp-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.pushMessageUrl="http://tank-jp-in.raysns.com/"
elseif G_curPlatName()=="memoriki" then
           serverCfg.allserver={
                tw={{name="TW-001",userip="tank-merk-ggplay.raysns.com",ip="tank-merk-ggplay.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}}
            }
            serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank-merk-ggplay.raysns.com",port=3001}}
            }
            
            serverCfg.baseUrl="tank-merk-ggplay.raysns.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/memoriki"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl="market://details?id=com.memoriki.tankonline"
elseif G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="efunandroidhuashuo" then
           serverCfg.allserver={
                    tw={
                        {name="TW-001",userip="tank001.efuntw.com",ip="tank001.efuntw.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank001.efuntw.com",port=3001}}

            }

            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl="http://forum.gamer.com.tw/A.php?bsn=26066"
            serverCfg.customerurl="http://question.efuntw.com/tkfy/index.html"
            serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"	
            serverCfg.checkEmojiUrl="http://tank001.efuntw.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank001.efuntw.com/"
elseif G_curPlatName()=="efunandroidmemoriki" then
           serverCfg.allserver={
                    tw={
                        {name="TW-001",userip="tank001.efuntw.com",ip="tank001.efuntw.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank001.efuntw.com",port=3001}}

            }

            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl="http://tank.mplusfun.com"
            serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"	
            serverCfg.checkEmojiUrl="http://tank001.efuntw.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank001.efuntw.com/"
elseif G_curPlatName()=="efunandroid360" then
           serverCfg.allserver={
                    tw={
                        {name="TW-001",userip="tank001.efuntw.com",ip="tank001.efuntw.com",port="15001",isnew=1,zoneid=1,domain="/tank/"}},
            }
           serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank001.efuntw.com",port=3001}}

            }

            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl="http://question.efuntw.com/tkfy/index.html"
            serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"	
            serverCfg.checkEmojiUrl="http://tank001.efuntw.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank001.efuntw.com/"
elseif G_curPlatName()=="efunandroidnm" or G_curPlatName()=="15" or G_curPlatName()=="efunandroidnmopera" then
           serverCfg.allserver={
                    tw={
                        {name="TW-001",userip="tanksa001.efunsa.com",ip="tanksa001.efunsa.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tanksa001.efunsa.com",port=3001}}

            }

            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tanksa001.efunsa.com/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://tanksa001.efunsa.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tanksa001.efunsa.com/"
elseif G_curPlatName()=="testServer" then
            serverCfg.allserver={
                cn={{name="CN-001",userip="tank-test.raysns.com",ip="tank-test.raysns.com",port="15001",zoneid=1,isnew=1,domain="/gucenter/",loginurl="",payurl=""}}
            }
            serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-test.raysns.com",port=3001}},
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
           serverCfg.payDir="/tank_pay/index.php/kyorder"            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""

elseif G_curPlatName()=="efunandroiddny" or G_curPlatName()=="efunandroiddnych" or G_curPlatName()=="4" or G_curPlatName()=="47" then
           serverCfg.allserver={
                    en={{name="EN-001",userip="app0ts.efunen.com",ip="app0ts.efunen.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   en={{name="EN-001",ip="app0ts.efunen.com",port=3001}}

            }

            serverCfg.baseUrl="http://app0ts.efunen.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl="http://www.facebook.com/tankefun"
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://app0ts.efunen.com/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://app0ts.efunen.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://app0ts.efunen.com/"
elseif G_curPlatName()=="androidwandoujia" then
            serverCfg.allserver={
            cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidwandoujialogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            
            
            


            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir=""
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
            serverCfg.pushMessageUrl="http://tank-android-01.raysns.com/"
elseif  G_curPlatName()=="androidlewandf1" or G_curPlatName()=="androidlewandf2" or G_curPlatName()=="androidlewandf3" or G_curPlatName()=="androidlewandf4" or G_curPlatName()=="androidlewandf5" or G_curPlatName()=="androidlewandf6" or G_curPlatName()=="androidlewandf7" or G_curPlatName()=="androidlewandf8" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-lewan-in.raygame1.com",ip="tank-lewan-in.raygame1.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-lewan-in.raygame1.com/tank_rayapi/index.php/androidlewandf1login"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-lewan-in.raygame1.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-lewan-in.raygame1.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-lewan-in.raygame1.com/tankheroclient/getconfig.php"
                serverCfg.pushMessageUrl="http://tank-lewan-in.raygame1.com/"
elseif  G_curPlatName()=="androidduoku" or G_curPlatName()=="androidbdduoku" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidduokulogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-android-01.raysns.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
                serverCfg.pushMessageUrl="http://tank-android-01.raysns.com/"
elseif  G_curPlatName()=="androidbaidumobile" or G_curPlatName()=="androidbaidumobile2" or G_curPlatName()=="androidlewan" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidbaidumobilelogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-android-01.raysns.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
                --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig1.php"
                serverCfg.pushMessageUrl="http://tank-android-01.raysns.com/"
elseif G_curPlatName()=="androidxiaomi" or G_curPlatName()=="androidxiaomiad" or G_curPlatName()=="androidrgame" or G_curPlatName()=="androidrgame2" or G_curPlatName()=="androidtaptap" or G_curPlatName()=="androiddianyou" then
            serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidxiaomilogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},

            }

            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="ndcom" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/android91login"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="android3kwan" then
           serverCfg.allserver={
            cn={{name="CN-001",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"},
            {name="CN-002",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"},{name="CN-003",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15003",zoneid=3,isnew=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"}},

            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-3k-01.raysns.com",port=3001},
                   {name="CN-002",ip="tank-3k-01.raysns.com",port=3021},{name="CN-003",ip="tank-3k-01.raysns.com",port=3031}},

            }

            serverCfg.baseUrl="http://tank-3k-01.raysns.com/gucenter/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-3k-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="android3ktest" then
           serverCfg.allserver={
            cn={{name="CN-001",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"},
            {name="CN-002",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"},{name="CN-003",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15003",zoneid=3,isnew=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanlogin",payurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanpay",orderurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android3kwanorder"}},

            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-3k-01.raysns.com",port=3001},
                   {name="CN-002",ip="tank-3k-01.raysns.com",port=3021},{name="CN-003",ip="tank-3k-01.raysns.com",port=3031}},

            }

            serverCfg.baseUrl="http://tank-3k-01.raysns.com/gucenter/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-3k-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="android3kwan_ndcom" then
            serverCfg.allserver={
            cn={{name="CN-001",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"},
            {name="CN-002",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"},
	    {name="CN-003",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15003",zoneid=3,isnew=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-3k-01.raysns.com",port=3001},
                   {name="CN-002",ip="tank-3k-01.raysns.com",port=3021},
		   {name="CN-003",ip="tank-3k-01.raysns.com",port=3031}},
            }

            serverCfg.baseUrl="http://tank-3k-01.raysns.com/gucenter/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-3k-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="android3kbaidu" or G_curPlatName()=="android3ktencent" or G_curPlatName()=="android3ktencent2" or G_curPlatName()=="android3ktencent3" or G_curPlatName()=="android3ktencent4" then
            serverCfg.allserver={
            cn={{name="CN-001",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"},
            {name="CN-002",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15002",zoneid=2,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"},
        {name="CN-003",userip="tank-3k-01.raysns.com",ip="tank-3k-01.raysns.com",port="15003",zoneid=3,isnew=1,domain="/gucenter/",loginurl="http://tank-3k-01.raysns.com/tank_rayapi/index.php/android91login"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-3k-01.raysns.com",port=3001},
                   {name="CN-002",ip="tank-3k-01.raysns.com",port=3021},
           {name="CN-003",ip="tank-3k-01.raysns.com",port=3031}},
            }

            serverCfg.baseUrl="http://tank-3k-01.raysns.com/gucenter/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-3k-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidlenovo" then
             serverCfg.allserver={
               cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidlenovologin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-android-01.raysns.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidtencent" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidtencently" or G_curPlatName()=="androidtencentysdk" then --接入ysdk以后用androidtencentysdk
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidrjtencent" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidruigame2" or G_curPlatName()=="androidruigame3" or G_curPlatName()=="androidruigame4" or G_curPlatName()=="androidyoutong" or G_curPlatName()=="androidhongen" or G_curPlatName()=="androidfengyou" or G_curPlatName()=="androidshangba" or G_curPlatName()=="androiddushibao" or G_curPlatName()=="androidsina" or G_curPlatName()=="androidyoutong2" or G_curPlatName()=="android4399" or G_curPlatName()=="androidhuli" or G_curPlatName()=="androidhaima" or G_curPlatName()=="androidayouxi" or G_curPlatName()=="androidsuning" or G_curPlatName()=="android37wan" or G_curPlatName()=="android37wan2" or G_curPlatName()=="android19196" or G_curPlatName()=="androidruigame" or G_curPlatName()=="androidyiwan" or G_curPlatName()=="androidyuwan" or G_curPlatName()=="androidmuzhiyouwan" or G_curPlatName()=="android37wan3" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"


elseif G_curPlatName()=="androidxunlei" or G_curPlatName()=="androidtuhao" then
            serverCfg.allserver={
                cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
                }
            serverCfg.allChatServer={
                cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

                }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"


elseif G_curPlatName()=="androidwangmeng" or G_curPlatName()=="androidpaojiaowang" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"   
elseif G_curPlatName()=="androidlvan" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidduomi" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidtoutiao" or G_curPlatName()=="androidrayjoy" or G_curPlatName()=="androidtiexue1" or G_curPlatName()=="androidtiexue2" or G_curPlatName()=="androidtiexue3" or G_curPlatName()=="androidtiexue4" or G_curPlatName()=="androidtiexue5" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidhtc" or G_curPlatName()=="androidhtc2" or G_curPlatName()=="androidsamsung" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"    
elseif G_curPlatName()=="androidaiyouxi" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"   

elseif G_curPlatName()=="androidmeizu" or G_curPlatName()=="androidyouku" or G_curPlatName()=="androidmeizu2" then
           serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidrjtencentlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=3001}},

            }

            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"           
elseif G_curPlatName()=="androidmumayi" then
            serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidmumayilogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},

            }

            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidanzhi" then
            serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidanzhilogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},

            }

            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidbaiduyun" or G_curPlatName()=="androidbaiduyun2" then
            serverCfg.allserver={
                    cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidbaiduyunlogin"}},
            }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},

            }

            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androiddownjoy" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiddownjoylogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidmuzhiwan" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidmuzhiwanlogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidewan" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-ewan-in.raygame1.com",ip="tank-ewan-in.raygame1.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-ewan-in.raygame1.com/tank_rayapi/index.php/androidewanlogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-ewan-in.raygame1.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-ewan-in.raygame1.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-ewan-in.raygame1.com/tankheroclient/getconfig.php"
                serverCfg.pushMessageUrl="tank-ewan-in.raygame1.com/"
elseif  G_curPlatName()=="androidewantest" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-ewan-in.raygame1.com",ip="tank-ewan-in.raygame1.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-ewan-in.raygame1.com/tank_rayapi/index.php/androidewanlogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-ewan-in.raygame1.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-ewan-in.raygame1.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-ewan-in.raygame1.com/tankheroclient/getconfig.php"
                serverCfg.pushMessageUrl="tank-ewan-in.raygame1.com/"
elseif  G_curPlatName()=="androidlongyuan" or G_curPlatName()=="androidlongyuantx" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-longyuan-in.raygame1.com",ip="tank-longyuan-in.raygame1.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-longyuan-in.raygame1.com/tank_rayapi/index.php/androidlongyuanlogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-ewan-in.raygame1.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-longyuan-in.raygame1.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-longyuan-in.raygame1.com/tankheroclient/getconfig.php"
                --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient4/getconfig.php"
                serverCfg.pushMessageUrl="tank-longyuan-in.raygame1.com/"
elseif  G_curPlatName()=="androidlongyuantest" then
                serverCfg.allserver={
               cn={{name="CN-001",userip="tank-longyuan-in.raygame1.com",ip="tank-longyuan-in.raygame1.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",payurl="",loginurl="http://tank-longyuan-in.raygame1.com/tank_rayapi/index.php/androidlongyuanlogin"}},
            }
               serverCfg.allChatServer={
                       cn={{name="CN-001",ip="tank-ewan-in.raygame1.com",port=4001}},
                
                }
                serverCfg.baseUrl="tank-longyuan-in.raygame1.com"
                serverCfg.serverTokenUrl="getaccess_token.php"
                serverCfg.serverBindCountUrl="bin_account.php"
                serverCfg.serverUpdatePwdUrl="updatepwd.php"
                serverCfg.statisticsUrl=""
                serverCfg.statisticsDir="/gamemetrics/public/index.php/"
                serverCfg.clientErrLogUrl=""
                serverCfg.clientErrLogDir="/tank_client/index.php"
                serverCfg.payUrl=""
                serverCfg.payDir=""
                --feed图片
                serverCfg.feedPicUrl=""
                serverCfg.feedPicDir="/tankheroclient/feedPic/"
                serverCfg.feedGameUrl=""
                serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
                serverCfg.updateurl=""
                serverCfg.svrCfgUrl="http://tank-longyuan-in.raygame1.com/tankheroclient/getconfig.php"
                serverCfg.pushMessageUrl="tank-longyuan-in.raygame1.com/"
elseif  G_curPlatName()=="androidappchina" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidappchinalogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidyymg" or G_curPlatName()=="androidlxlx" or G_curPlatName()=="androidxunleich" or G_curPlatName()=="androidkaopu" or G_curPlatName()=="androidky7659" or G_curPlatName()=="android49you" or G_curPlatName()=="androidkoudai" or G_curPlatName()=="androidwamai2" or G_curPlatName()=="androidtoutiao2" or G_curPlatName()=="androidtoutiao3" or G_curPlatName()=="androidtuitui" or G_curPlatName()=="androidtianwan" or G_curPlatName()=="androidbdydyx" or G_curPlatName()=="androidkuwo" or G_curPlatName()=="androidwamai" or G_curPlatName()=="androidjifeng" or G_curPlatName()=="androidnduo" or G_curPlatName()=="androidwostore" or G_curPlatName()=="androidwostore2" or G_curPlatName()=="androidkupai" or G_curPlatName()=="androidkupai2" or G_curPlatName()=="androidpipa" or G_curPlatName()=="androidhuawei" or G_curPlatName()=="androidhuawei2" or G_curPlatName()=="androidchongchong" or G_curPlatName()=="androidquick" or G_curPlatName()=="androidifeng" or G_curPlatName()=="androidleshi" or G_curPlatName()=="androidmoge" or G_curPlatName()=="androidoppo" or G_curPlatName()=="androidoppo2" or G_curPlatName()=="androidjinli" or G_curPlatName()=="androidjinli2" or G_curPlatName()=="androidvivo" or G_curPlatName()=="androidvivo2" or G_curPlatName()=="androiduucun" or G_curPlatName()=="androidjunhai" or G_curPlatName()=="androidjunhai2" or G_curPlatName()=="androidkuaifa" then
            serverCfg.allserver={
              cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
    
elseif  G_curPlatName()=="androidzhongshouyoucn" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidzhongshouyoucnlogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="http://tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidydmm" or G_curPlatName()=="android3kydmm" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-mobile-sis-web01.raysns.com",ip="tank-mobile-sis-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-mobile-sis-web01.raysns.com/tank_rayapi/index.php/androidydmmlogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-mobile-sis-web01.raysns.com",port=3001}},
            
            }
            serverCfg.baseUrl="tank-mobile-sis-web01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-mobile-sis-web01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="andgamesdealru" then
             serverCfg.allserver={
           cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzhongshouyourulogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="devtank.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.officialUrl="http://www.kotank.com"
            serverCfg.svrCfgUrl="http://tank-russia-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.pushMessageUrl="http://tank-russia-in.raysns.com/"

elseif  G_curPlatName()=="12" then
             serverCfg.allserver={
           ru={{name="RU-001",userip="tank-russia-in.raysns.com",ip="tank-russia-in.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://tank-russia-in.raysns.com/tank_rayapi/index.php/ioszhongshouyourulogin",payurl="http://tank-russia-in.raysns.com/tank_rayapi/index.php/ioszhongshouyourupay"}},
        }
           serverCfg.allChatServer={
                   ru={{name="RU-001",ip="http://tank-russia-in.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="tank-russia-in.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.officialUrl="http://www.kotank.com"
            serverCfg.svrCfgUrl="http://tank-russia-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.pushMessageUrl="http://tank-russia-in.raysns.com/"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
elseif  G_curPlatName()=="52" then
             serverCfg.allserver={
           ru={{name="RU-001",userip="tank-russia-in.raysns.com",ip="tank-russia-in.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://tank-russia-in.raysns.com/tank_rayapi/index.php/ioszhongshouyourulogin",payurl="http://tank-russia-in.raysns.com/tank_rayapi/index.php/ioszhongshouyourupay"}},
        }
           serverCfg.allChatServer={
                   ru={{name="RU-001",ip="http://tank-russia-in.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="tank-russia-in.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.officialUrl="http://www.kotank.com"
            serverCfg.svrCfgUrl="http://tank-russia-gnetop-in.raygame1.com/tankheroclient/getconfig.php"
            serverCfg.pushMessageUrl="http://tank-russia-in.raysns.com/"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"

elseif  G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="13" or G_curPlatName()=="andgamesdealko" then
             serverCfg.allserver={
           cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzhongshouyourulogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="devtank.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-korea-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://tank-korea-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-korea-in.raysns.com/"

elseif  G_curPlatName()=="androidzsykonaver" then
             serverCfg.allserver={
           ko={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykonaverlogin",payurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykonaverpay",}},
        }
           serverCfg.allChatServer={
                   ko={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="devtank.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-korea-in.raysns.com/tankheroclient/getconfig.php"
	    serverCfg.checkEmojiUrl="http://tank-korea-in.raysns.com/tankheroclient/emoji.php"
        serverCfg.pushMessageUrl="http://tank-korea-in.raysns.com/"
elseif  G_curPlatName()=="androidzsykoolleh" then
             serverCfg.allserver={
           ko={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykoollehlogin",payurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykoollehpay"}},
        }
           serverCfg.allChatServer={
                   ko={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="devtank.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
	    serverCfg.svrCfgUrl="http://tank-korea-in.raysns.com/tankheroclient/getconfig.php"
	    serverCfg.checkEmojiUrl="http://tank-korea-in.raysns.com/tankheroclient/emoji.php"
        serverCfg.pushMessageUrl="http://tank-korea-in.raysns.com/"
elseif  G_curPlatName()=="androidzsykotstore" then
             serverCfg.allserver={
           ko={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykotstorelogin",payurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidzsykotstorepay"}},
        }
           serverCfg.allChatServer={
                   ko={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl="devtank.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
	    serverCfg.svrCfgUrl="http://tank-korea-in.raysns.com/tankheroclient/getconfig.php"
	    serverCfg.checkEmojiUrl="http://tank-korea-in.raysns.com/tankheroclient/emoji.php"
        serverCfg.pushMessageUrl="http://tank-korea-in.raysns.com/"
elseif  G_curPlatName()=="androidsougou" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androidsougoulogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidkunlun" or G_curPlatName()=="androidkunlunz" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlunlogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-na-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://tank-na-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.en"
            serverCfg.pushMessageUrl="http://tank-na-war.raysns.com/"
elseif G_curPlatName()=="flandroid" or G_curPlatName()=="flandroid_rgame" or G_curPlatName()=="androiddidi" or G_curPlatName()=="androidxyzs" then
           
           serverCfg.allserver={
                   cn={{name="CN-001",userip="tank-fl-yueyu.raysns.com",ip="tank-fl-yueyu.raysns.com",isnew=1,port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-fl-yueyu/tank_rayapi/index.php/flandroidlogin"}},

                }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-fl-yueyu.raysns.com",port=3001}},
            
            }
            serverCfg.baseUrl="http://tank-fl-yueyu.raysns.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            if G_curPlatName()=="flandroid_rgame" then --越狱flandroid_rgame渠道接入的是rgame的SDK无需配置改支付地址
                serverCfg.payUrl=""
            else
                serverCfg.payUrl="http://tank-fl-yueyu.raysns.com/tank_rayapi/index.php/flandroidpay"
            end
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
           --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig3.php"
elseif  G_curPlatName()=="androidkunlun1mobile" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlun1mobilelogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-NA-mobile-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://tank-NA-mobile-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.en"
            serverCfg.pushMessageUrl="http://tank-NA-mobile-in.raysns.com/"
elseif  G_curPlatName()=="14" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlunlogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},
            
            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-na-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://tank-na-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.en"
            serverCfg.pushMessageUrl="http://tank-na-war.raysns.com/"
           -- serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" then
           serverCfg.allserver={
                    tw={
                        {name="TW-001",userip="tank001.efuntw.com",ip="tank001.efuntw.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   tw={{name="TW-001",ip="tank001.efuntw.com",port=3001}}

            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl=""
            serverCfg.customerurl="http://www.pubgame.tw/m/cc/tkfy.do"
            serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://tank001.efuntw.com/tankheroclient/emoji.php"
elseif G_curPlatName()=="5" or G_curPlatName()=="51" or G_curPlatName()=="58" or G_curPlatName()=="64" or G_curPlatName()=="60" or G_curPlatName()=="61" or G_curPlatName()=="66" then
            local serverIp = G_getServerIp()
            if serverIp=="" then
                serverIp="114.67.212.154"
            end
            -- print("serverIp====????",serverIp)
               serverCfg.allserver={
                   cn={},
                }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip=serverIp,port=3001},{name="CN-002",ip="114.67.212.154",port=3001},{name="CN-003",ip="114.67.212.154",port=3021},{name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021}},
            
            }
            serverCfg.baseUrl="http://"..serverIp.."/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://"..serverIp.."/tank_rayapi/index.php/flappstorepay"
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://"..serverIp.."/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
            serverCfg.checkEmojiUrl="http://"..serverIp.."/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-fl-app-war.raysns.com/"
elseif G_curPlatName() =="androidappstore" then
               serverCfg.allserver={
                   cn={},
                }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="114.67.212.154",port=3001},{name="CN-002",ip="114.67.212.154",port=3001},{name="CN-003",ip="114.67.212.154",port=3021},{name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021}},
            
            }
            serverCfg.baseUrl="http://114.67.212.154/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://114.67.212.154/tank_rayapi/index.php/ioskaipaopay"
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
            serverCfg.checkEmojiUrl="http://114.67.212.154/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-fl-app-war.raysns.com/"
elseif G_curPlatName()=="65" then
            serverCfg.allserver={
            cn={},
            }
            serverCfg.allChatServer={
            cn={{name="CN-001",ip="114.67.212.154",port=3001},{name="CN-002",ip="114.67.212.154",port=3001},{name="CN-003",ip="114.67.212.154",port=3021},{name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021}},

            }
            serverCfg.baseUrl="http://114.67.212.154/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://114.67.212.154/tank_rayapi/index.php/flappstorepay"
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
            serverCfg.checkEmojiUrl="http://114.67.212.154/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-fl-app-war.raysns.com/"

elseif G_curPlatName()=="45" or G_curPlatName()=="48" then
            serverCfg.allserver={
                cn={},
            }
            serverCfg.allChatServer={
                cn={{name="CN-001",ip="114.67.212.154",port=3001},{name="CN-002",ip="114.67.212.154",port=3001},{name="CN-003",ip="114.67.212.154",port=3021},{name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021}},

            }
            serverCfg.baseUrl="http://114.67.212.154/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://114.67.212.154/tank_rayapi/index.php/flappstorepay"
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"
            serverCfg.checkEmojiUrl="http://114.67.212.154/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-fl-app-war.raysns.com/"

elseif G_curPlatName()=="androidtencentyxb" or G_curPlatName()=="androidfltencent" then --飞流应用宝��与飞流国内ios正版同服,接入ysdk以后用androidfltencent
               serverCfg.allserver={
                   cn={},
                }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="114.67.212.154",port=3001},{name="CN-002",ip="114.67.212.154",port=3001},{name="CN-003",ip="114.67.212.154",port=3021},{name="CN-004",ip="114.67.212.154",port=3001},{name="CN-005",ip="114.67.212.154",port=3021},{name="CN-006",ip="114.67.212.154",port=3001},{name="CN-007",ip="114.67.212.154",port=3021}},
            
            }
            serverCfg.baseUrl="http://114.67.212.154/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://114.67.212.154/tank_rayapi/index.php/flappstorepay"
            serverCfg.payDir="/tank_pay/index.php/apple"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
            serverCfg.checkEmojiUrl="http://114.67.212.154/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://tank-fl-app-war.raysns.com/"
elseif G_curPlatName()=="androidflbaidu" or G_curPlatName()=="6" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="9" or G_curPlatName()=="10" or G_curPlatName()=="16" or G_curPlatName()=="46" or G_curPlatName()=="50" or G_curPlatName()=="63" or G_curPlatName()=="69" or G_curPlatName()=="70" then --6=91 7=pp "9"=feiliuyueyu1  "10"=feiliuyueyu2 "8"=TBT "16"=itools
           
           serverCfg.allserver={
                   cn={{name="CN-001",userip="tank-fl-yueyu.raysns.com",ip="tank-fl-yueyu.raysns.com",isnew=1,port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-fl-yueyu.raysns.com/tank_rayapi/index.php/"}},

                }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-fl-yueyu.raysns.com",port=3001}},
            
            }
            serverCfg.baseUrl="http://tank-fl-yueyu.raysns.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl="http://tank-fl-yueyu.raysns.com/tank_rayapi/index.php/fliosnd91pay"
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/TankHeroClient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/TankHeroClient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
           serverCfg.pushMessageUrl="http://tank-flyueyu-war.raysns.com/"
           serverCfg.checkEmojiUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/emoji.php"
elseif G_curPlatName()=="11" then
            serverCfg.allserver={
                de={
                {name="DE-001",userip="tank-ger-ios-web01.raysns.com",ip="tank-ger-ios-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-ger-ios-web01.raysns.com/tank_rayapi/index.php/iossevengalogin",payurl=""}
                },
                }
            serverCfg.allChatServer={
            de={
                {name="DE-001",ip="tank-ger-ios-web01.raysns.com",port=3001}
            },
        }
        serverCfg.baseUrl=""
        serverCfg.serverTokenUrl="getaccess_token.php"
        serverCfg.serverBindCountUrl="bin_account.php"
        serverCfg.serverUpdatePwdUrl="updatepwd.php"
        serverCfg.statisticsUrl=""
        serverCfg.statisticsDir="/gamemetrics/public/index.php/"
        serverCfg.clientErrLogUrl=""
        serverCfg.clientErrLogDir="/tank_client/index.php"
        serverCfg.payUrl=""
        serverCfg.payDir=""
        --feed图片
        serverCfg.feedPicUrl=""
        serverCfg.feedPicDir="/tankheroclient/feedPic/"
        serverCfg.feedGameUrl=""
        serverCfg.feedGameDir=""
        serverCfg.updateurl=""
        serverCfg.bbsurl=""
        serverCfg.customerurl=""
        --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
        serverCfg.svrCfgUrl="http://tank-ger-web01.raysns.com/tankheroclient/getconfig.php"
elseif G_curPlatName()=="androidsevenga" then
            serverCfg.allserver={
                de={
                {name="DE-001",userip="tank-ger-web01.raysns.com",ip="tank-ger-web01.raysns.com",port="15001",zoneid=1,domain="/gucenter/",loginurl="http://tank-ger-web01.raysns.com/tank_rayapi/index.php/androidsevengalogin",payurl=""}
                },
                }
            serverCfg.allChatServer={
            de={
                {name="DE-001",ip="tank-ger-web01.raysns.com",port=3001}
            },
        }
        serverCfg.baseUrl=""
        serverCfg.serverTokenUrl="getaccess_token.php"
        serverCfg.serverBindCountUrl="bin_account.php"
        serverCfg.serverUpdatePwdUrl="updatepwd.php"
        serverCfg.statisticsUrl=""
        serverCfg.statisticsDir="/gamemetrics/public/index.php/"
        serverCfg.clientErrLogUrl=""
        serverCfg.clientErrLogDir="/tank_client/index.php"
        serverCfg.payUrl=""
        serverCfg.payDir=""
        --feed图片
        serverCfg.feedPicUrl=""
        serverCfg.feedPicDir="/tankheroclient/feedPic/"
        serverCfg.feedGameUrl=""
        serverCfg.feedGameDir=""
        serverCfg.updateurl=""
        serverCfg.bbsurl=""
        serverCfg.customerurl=""
        serverCfg.svrCfgUrl="http://tank-ger-web01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androiduc" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="114.67.212.154",ip="114.67.212.154",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://114.67.212.154/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="114.67.212.154",port=3001}},
            
            }
            serverCfg.baseUrl="114.67.212.154"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://114.67.212.154/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidnjyidong" or G_curPlatName()=="androidnjyidong2" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-android-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="17" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"

elseif  G_curPlatName()=="18" or  G_curPlatName()=="androidtuerqi" then
            serverCfg.allserver={
           tu={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   en={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-turkey-in.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfigworldwarxw.php"

elseif  G_curPlatName()=="19" then
            serverCfg.allserver={
           en={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   en={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="20" or G_curPlatName()=="31"  then
            serverCfg.allserver={
           ja={{name="JP-001",userip="tank-jp-in.raysns.com",ip="tank-jp-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl=""}},
        }
           serverCfg.allChatServer={
                   ja={{name="JP-001",ip="tank-jp-web01.raysns.com",port=3001}},
            
            }
            serverCfg.baseUrl="tank-jp-in.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-jp-in.raysns.com/tankheroclient/getconfig.php"

elseif  G_curPlatName()=="41"  or G_curPlatName()=="62" then
        serverCfg.allserver={
            ja={{name="JP-001",userip="tank-jp-in.raysns.com",ip="tank-jp-web01.raysns.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl=""}},
        }
        serverCfg.allChatServer={
            ja={{name="JP-001",ip="tank-jp-web01.raysns.com",port=3001}},

        }
        serverCfg.baseUrl="tank-jp-in.raysns.com"
        serverCfg.serverTokenUrl="getaccess_token.php"
        serverCfg.serverBindCountUrl="bin_account.php"
        serverCfg.serverUpdatePwdUrl="updatepwd.php"
        serverCfg.statisticsUrl=""
        serverCfg.statisticsDir="/gamemetrics/public/index.php/"
        serverCfg.clientErrLogUrl=""
        serverCfg.clientErrLogDir="/tank_client/index.php"
        serverCfg.payUrl=""
        serverCfg.payDir=""
        --feed图片
        serverCfg.feedPicUrl=""
        serverCfg.feedPicDir="/tankheroclient/feedPic/"
        serverCfg.feedGameUrl=""
        serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
        serverCfg.updateurl=""
        --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
        serverCfg.svrCfgUrl="http://tank-jp-in.raysns.com/tankheroclient/getconfig.php"


elseif  G_curPlatName()=="21" or  G_curPlatName()=="androidarab" then
            serverCfg.allserver={
           ar={{name="AR-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   ar={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="tank-ar-in.raysns.com/tankheroclient/getconfig.php"

elseif  G_curPlatName()=="23" or G_curPlatName()=="67" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   ja={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"

            
elseif  G_curPlatName()=="25" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
            
    --飞流预装
elseif  G_curPlatName()=="26" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            
    --飞流越狱XY助手22��魔品科技55
elseif  G_curPlatName()=="22" or G_curPlatName()=="55" or G_curPlatName()=="56" or G_curPlatName()=="68" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
    --3k玩越狱
elseif  G_curPlatName()=="28" or G_curPlatName()=="40" or G_curPlatName()=="54" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   cn={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-3k-01.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="androidom2" then
            serverCfg.allserver={
               tw={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
            }
           serverCfg.allChatServer={
               tw={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"
            serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"

elseif  G_curPlatName()=="32" then
            serverCfg.allserver={
            fr={{name="FR-001",userip="tank-fr-in.raysns.com",ip="tank-fr-in.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://tank-fr-in.raysns.com/tank_rayapi/index.php/androidkunlunfylogin"}},
            }
            serverCfg.allChatServer={
            fr={{name="FR-001",ip="http://tank-fr-in.raysns.com",port=3008}},

            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-fr-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://tank-fr-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.fr"
            -- serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="33" then
            serverCfg.allserver={
            cn={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlunlogin"}},
            }
            serverCfg.allChatServer={
            cn={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},

            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-na-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.fr"
            -- serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient/getconfig.php"
elseif  G_curPlatName()=="34" then
            serverCfg.allserver={
            tw={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
            }
            serverCfg.allChatServer={
                tw={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://tank001.efuntw.com/tankheroclient/getconfig.php"

elseif  G_curPlatName()=="androidklfy" then
            serverCfg.allserver={
            fr={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlunlogin"}},
            }
            serverCfg.allChatServer={
                fr={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},

            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-fr-in.raysns.com/tankheroclient/emoji.php"
            serverCfg.svrCfgUrl="http://tank-fr-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.fr"

elseif  G_curPlatName()=="35" then
            serverCfg.allserver={
           cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
        }
           serverCfg.allChatServer={
                   en={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},
            
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"

elseif  G_curPlatName()=="39" then
            serverCfg.allserver={
                cn={{name="CN-001",userip="tank-android-01.raysns.com",ip="tank-android-01.raysns.com",port="16001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
            }
            serverCfg.allChatServer={
                en={{name="CN-001",ip="tank-android-01.raysns.com",port=4001}},

            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-fl-yueyu.raysns.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientWzh/getconfig.php"
elseif  G_curPlatName()=="androidkakaogoogle" or G_curPlatName()=="androidkakaonaver" or G_curPlatName()=="androidkakaotstore" then
            serverCfg.allserver={
                ko={{name="ko-001",userip="tank-korea-kk-in.raygame1.com",ip="tank-korea-kk-in.raygame1.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/",loginurl="http://tank-android-01.raysns.com/tank_rayapi/index.php/androiduclogin"}},
            }
            serverCfg.allChatServer={
                en={{name="CN-001",ip="tank-korea-kk-in.raygame1.com",port=2001}},
            }
            serverCfg.baseUrl="tank-android-01.raysns.com"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.svrCfgUrl="http://tank-korea-kk-in.raygame1.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientzmm/getconfig.php"
elseif G_curPlatName()=="49" or G_curPlatName()=="androidyuenan" or G_curPlatName()=="androidyuenan2" or G_curPlatName()=="53" then
           serverCfg.allserver={
                    vi={{name="ko-001",userip="tank-vietnam-in.raygame1.com",ip="tank-vietnam-in.raygame1.com",port="15001",isnew=1,zoneid=1,domain="/gucenter/"}},
            }
           serverCfg.allChatServer={
                   vi={{name="vi-001",ip="tank-vietnam-in.raygame1.com",port=3001}}

            }

            serverCfg.baseUrl="http://app0ts.efunen.com/tank/"
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir=""
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.bbsurl="http://www.facebook.com/tankefun"
            serverCfg.customerurl=""
            serverCfg.svrCfgUrl="http://tank-vietnam-in.raygame1.com/tankheroclient/getconfig.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclient3/getconfig.php"
            serverCfg.checkEmojiUrl="http://app0ts.efunen.com/tankheroclient/emoji.php"
            serverCfg.pushMessageUrl="http://app0ts.efunen.com/"
elseif  G_curPlatName()=="androidcmge" or G_curPlatName()=="59" then
            serverCfg.allserver={
            fr={{name="CN-001",userip="devtank.raysns.com",ip="devtank.raysns.com",port="15001",isnew=1,zoneid=1,domain="/tank/",loginurl="http://devsdk.raysns.com/tank_rayapi/index.php/androidkunlunlogin"}},
            }
            serverCfg.allChatServer={
                fr={{name="CN-001",ip="http://devtank.raysns.com",port=3008}},

            }
            serverCfg.baseUrl=""
            serverCfg.serverTokenUrl="getaccess_token.php"
            serverCfg.serverBindCountUrl="bin_account.php"
            serverCfg.serverUpdatePwdUrl="updatepwd.php"
            serverCfg.statisticsUrl=""
            serverCfg.statisticsDir="/gamemetrics/public/index.php/"
            serverCfg.clientErrLogUrl=""
            serverCfg.clientErrLogDir="/tank_client/index.php"
            serverCfg.payUrl=""
            serverCfg.payDir="/tank_pay/index.php/kyorder"
            --feed图片
            serverCfg.feedPicUrl=""
            serverCfg.feedPicDir="/tankheroclient/feedPic/"
            serverCfg.feedGameUrl=""
            serverCfg.feedGameDir="/tankheroclient/tankHtml/tank.html"
            serverCfg.updateurl=""
            serverCfg.checkEmojiUrl="http://tank-fr-in.raysns.com/tankheroclient/emoji.php"
            --serverCfg.svrCfgUrl="http://devsdk.raysns.com/tankheroclientcwj/getconfig.php"
            serverCfg.svrCfgUrl="http://tank-krandroid-in.raysns.com/tankheroclient/getconfig.php"
            serverCfg.officialUrl="http://www.facebook.com/SteelAvengers.fr"

end




function serverCfg:checkServerValid(k1,k2)
    if self.allserver[k1]~=nil then
        for k,v in pairs(self.allserver[k1]) do
             if v.name==k2 then
                do
                    return true
                end
             end
        end
    end
    return false
end

function serverCfg:getBestServer(key)
     print("要连哪个服务器",key,self.allserver[key])
     if G_getServerCfgFromHttp~=nil then
        G_getServerCfgFromHttp(false)
     end
     
     
     

    --如果服务器列表配置了多个地区则需要根据玩家手机默认的语言来选择

    if SizeOfTable(serverCfg.allserver)>1 then
        local str=G_getOSCurrentLanguage() --获取设备当前选择的语言
        local platName=G_curPlatName()
        if(platName=="efunandroidtw" or platName=="3" or platName=="androidlongzhong" or
            platName=="14" or platName=="androidkunlun" or platName=="androidkunlunz" or platName=="0")then
            str="global"
        end
        if platCfg.platCfgDeviceLangToGameLang[str]~=nil then
             str=platCfg.platCfgDeviceLangToGameLang[str]
             if G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" then
                str="en"
             end
             print("设备设置的语言",str)
        end
        if serverCfg.allserver[str]~=nil then --默认的语言有配置服务器
             G_country=str
             key=str
             print("服务器变更为",key,self.allserver[key])
        end

    end
    --如果系统语言没有对应语种的服务器，那么就随机选一个
    local countryServers
    local realKey
    if(self.allserver[key])then
        countryServers=self.allserver[key]
        realKey=key
    else
        for key2,v in pairs(self.allserver) do
            countryServers=v
            realKey=key2
            break
        end
    end
    if(countryServers)then
         for k,v in pairs(countryServers) do
             if v.isnew~=nil and tostring(v.isnew)=="1" then
                 do
                     print("返回的是什么",realKey,v.name)
                     return realKey..","..v.name
                end
            end
        end
        for k,v in pairs(countryServers) do
            print("返回的是什么",realKey,v.name)
            return realKey..","..v.name
        end
    end
end

function serverCfg:getServerInfo(country,name)
      for k,v in pairs(self.allserver[country]) do
            if v.name==name then
                do
                    return v
                end
            end
      end
      return nil
end

--获取访问游戏gucenter的域名地址
--如果是怀旧服就取怀旧服的入口机地址，否则取本平台的入口机地址
function serverCfg:gucenterServerIp()
    if base.memoryServerIp and base.memoryServerIp ~= "" then
        return base.memoryServerIp
    end
    return base.serverUserIp
end
