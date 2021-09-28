local _data = {
    --错误报告相关
    ["report_save"] = "1",
    ["report_max_len"] = 1,

    ["report_send_url"] = "",
    -- 版本相关    
    ["build_version"] = "1404313624",
    --充值是否开启 0关闭,1开启
    ["open_recharge"] = "1",

    --礼品码是否开启 0关闭,1开启
    ["open_giftcode"] = "1",

    --基金是否开启 0关闭,1开启
    ["open_fund"] = "1",

    --拉新是否开启 0关闭,1开启
    ["open_invitor"] = "0",

    --对酒是否开启
    ["open_wine"] = "1",

    --手机绑定是否开启
    ["open_phone"] = "1",

    --手机绑定url
    --testUrl = "http://qavipsupport.youzu.com/"
    --formalUrl = "http://vipsupport.youzu.com/"
    ["phone_send_url"] = "http://vipsupport.youzu.com/",

    --充值返还是否开启
    ["open_fanhuan"] = "1",

    --vip周礼包是否开启
    ["open_vipDiscount"] = "1",

    --漫画是否开启
    ["open_manhua"] = "1",

    --检查变速是否开启
    ["open_check_speed"] = "0",

    --一元充值是否开启, 把充值金额变成1元, 方便测试
    ["open_1yuan"] = "0",
    
    -- 是否开启分享, 0关闭，1开启
    ["open_share"] = "0",

    --分享是否要等待回调，
    ["open_share_wait"] = "1",

    -- 微信分享
    ["open_wechat_share"] = "1",
    
    -- 微博分享
    ["open_weibo_share"] = "0",


    ["open_share_image"] = "1",

    --应用宝礼包
    ["open_tencent_gift_url"] = "",

    
    --默认服务器ID

    ["default_server"] = "2",

    -- 默认显示聊天悬浮窗
    ["default_show_chat"] = "1",

    --是否在所有页面都显示iSDK悬浮
    ["open_always_show_float"] = "0",

    --是否关闭首页的充值按钮
    ["open_mainscene_recharge"] = "1",

    --是否打开充值网页领奖活动
    ["open_activity_recharge"] = "0",
    ["open_activity_recharge_url"] = "",

    --是否是appstore和谐提审版本
    ["appstore_version"] = "0",

    ['open_notification'] = '1', --开启本地对推送
    ["drink_desc1"] = G_lang:get("LANG_LOCAL_DRINK1"),  --对酒推送
    ["drink_desc2"] = G_lang:get("LANG_LOCAL_DRINK2"),

    ["appstore_sandbox"] = "", -- appstore沙盒测试, 取值true, false, ""
    ["popupUrl"] = "",  --活动弹窗
    ["popupNotice"] = "",  --标准弹窗

    ['test_version'] = "0.0.0",  --如果当前版本等于这个值, 服务器列表使用test_servers
    ['test_servers'] = '',
    ['showRechargeTip'] = '0',

    ["no_server_txt"] = "暂未开服",

    
    ["invite_content"] = "我在玩".. GAME_PACKAGE_NAME .."，2015最炫酷的动作卡牌游戏，没有之一！我叫#role_name#, 在#server_name#服，大家一起来玩吧！",
    ["phone_content"] = "绑定手机,即可获取游戏内奖励,更可以获取免费手机流量包!\n活动时间：2015.12.2-2015.12.22",

    ["invite_content_base"] = "小伙伴们~陪我一起玩手游《" .. GAME_PACKAGE_NAME .. "》吧！我已经嗨翻天了！真的很好玩！来吧~我们一起组建军团，打遍三国！秒天秒地秒空气！我在【#serverName#】服务器，我叫#role_name#，ID：#id#，你可以在30级以前，在游戏的活动->新手礼包界面，绑定我的ID，与我建立伙伴关系！",
    ["invite_content_rich"] = "<root><text value='小伙伴们~陪我一起玩手游《" .. GAME_PACKAGE_NAME .. "》吧！我已经嗨翻天了！真的很好玩！来吧~我们一起组建军团，打遍三国！秒天秒地秒空气！我在' color='5258818'/><text value='【#serverName#】' color='11039782'/><text value='服务器，' color='5258818'/><text value='我叫#role_name#，ID：#id#' color='3509514'/><text value='，你可以在' color='5258818'/><text value='30级以前' color='12922112'/><text value='，在游戏的活动->新手礼包界面，绑定我的ID，与我建立伙伴关系！' color='5258818'/></root>",
    
    ["super_debug_panel"] = "1",
    ["broadcast_url"] = "",

    ["gm_black_list"] = "",


    ["blocked_server_list"] = "",

    ["corp_cross_open"] = "1",

    ["ecustom_version"] = "ecustom_version",
    
    ["useSpecialPay"] = "0", --苹果特殊充值开关（为1 是关掉币种检查)
    ["rechargeCurrencyTips"] = "", --外币无法充值的提示



    --分享是否要等待回调，
    ["destroy_supersdk_db"] = "0",


    --是否把角色信息登记到远程服务器上
    ["open_remote_role_history"] = "1",

    --一般是通过op id来区分充值列表， 但是下面这个开关可以把这个区分 改成用opgameId
    ["appid"] = "1",

    ["open_user_protocal"] = "http://m.youzu.com/xy",


    --使用dnspod, 在访问域名之前先使用dnspod做IP解析
    ["open_dnspod"] = "0",

    --默认2， 如果坑爹的武汉网络出问题，调整这个数字试试
    ["flush_segment_n"] = "2",


    --测试服务器的密码
    ["server_lock_password"] = "9527",

    --可以创角的服务器，按开服时间排序，前n个可以进
    ["allow_create_servers_n"] = "1",

    --打开缓存登录数据的开关,缓存短时间以内的user,knight数据
    ["open_cache_login"] = "1",

    --双12淘宝送礼
    ["open_taobao_gift"] = "0",

    ["hd_res_download"] = "0",

    ["hd_res_url"] = "http://192.168.180.33/pack/res/",
}

local Setting = {}
local inited = false

function Setting:get(k)
    if not inited then
        inited = true
        local ComSdkUtils = require("upgrade.ComSdkUtils")
        local configContent =  ComSdkUtils.getCacheConfigContent()
      
        if configContent then

            for k, v in pairs(configContent) do
                _data[k] = v
            end
        end
    end


    return _data[k]
end






return Setting
