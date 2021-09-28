local ComSdkProxyConfig = class("ComSdkProxyConfig")


local ComSdkUtils = require("upgrade.ComSdkUtils")

require("app.cfg.packages_config")



function ComSdkProxyConfig:ctor()
 
end

function ComSdkProxyConfig.setRechargeInfo(productList)
    if not productList then
        return
    end

    require("app.cfg.recharge_info")
    for i=1,recharge_info.getLength() do
        local info = recharge_info.indexOf(i)
        if productList[info.product_id] then
            recharge_info.set(info.id,"product_id",productList[info.product_id])
        end
    end
end

function ComSdkProxyConfig.setSpecialRechargeList(opId)
    local productList = {}
    if tostring(opId) == "2138" then
        --haima
        require("app.cfg.recharge_info")
        productList["gold1"]    = "11"
        productList["gold6"]    = "1"
        productList["gold30"]   = "2"
        productList["gold50"]   = "3"
        productList["gold128"]  = "4"
        productList["gold288"]  = "5"
        productList["gold548"]  = "6"
        productList["gold648"]  = "7"
        productList["gold2048"] = "10"
        -- recharge_info.set(701, 'product_id', '1')
        -- recharge_info.set(702, 'product_id', '2')
        -- recharge_info.set(703, 'product_id', '3')
        -- recharge_info.set(704, 'product_id', '4')
        -- recharge_info.set(705, 'product_id', '5')
        -- recharge_info.set(706, 'product_id', '6')
        -- recharge_info.set(707, 'product_id', '7')
        -- recharge_info.set(708, 'product_id', '10')

        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '8')
        month_card_info.set(2, 'product_id', '9')
    
    elseif  tostring(opId) == "2141" then
        --联想
        require("app.cfg.recharge_info")
        require("app.cfg.month_card_info")

         if  GAME_VERSION_NO < 10600  then
            -- recharge_info.set(701, 'product_id', '1')
            -- recharge_info.set(702, 'product_id', '2')
            -- recharge_info.set(703, 'product_id', '3')
            -- recharge_info.set(704, 'product_id', '4')
            -- recharge_info.set(705, 'product_id', '5')
            -- recharge_info.set(706, 'product_id', '6')
            -- recharge_info.set(707, 'product_id', '7')
            -- recharge_info.set(708, 'product_id', '10')
            productList["gold1"]    = "11"
            productList["gold6"]    = "1"
            productList["gold30"]   = "2"
            productList["gold50"]   = "3"
            productList["gold128"]  = "4"
            productList["gold288"]  = "5"
            productList["gold548"]  = "6"
            productList["gold648"]  = "7"
            productList["gold2048"] = "10"
            month_card_info.set(1, 'product_id', '8')
            month_card_info.set(2, 'product_id', '9')
        else
            -- recharge_info.set(701, 'product_id', '1813')
            -- recharge_info.set(702, 'product_id', '1814')
            -- recharge_info.set(703, 'product_id', '1815')
            -- recharge_info.set(704, 'product_id', '1816')
            -- recharge_info.set(705, 'product_id', '1817')
            -- recharge_info.set(706, 'product_id', '1818')
            -- recharge_info.set(707, 'product_id', '1819')
            -- recharge_info.set(708, 'product_id', '2605')
            productList["gold1"]    = "12371"
            productList["gold6"]    = "1813"
            productList["gold30"]   = "1814"
            productList["gold50"]   = "1815"
            productList["gold128"]  = "1816"
            productList["gold288"]  = "1817"
            productList["gold548"]  = "1818"
            productList["gold648"]  = "1819"
            productList["gold2048"] = "2605"
            
            month_card_info.set(1, 'product_id', '1820')
            month_card_info.set(2, 'product_id', '1821')
        end
      
    elseif  tostring(opId) == "2140" then
        --coolpai
        require("app.cfg.recharge_info")

        -- recharge_info.set(701, 'product_id', '1')
        -- recharge_info.set(702, 'product_id', '2')
        -- recharge_info.set(703, 'product_id', '3')
        -- recharge_info.set(704, 'product_id', '4')
        -- recharge_info.set(705, 'product_id', '5')
        -- recharge_info.set(706, 'product_id', '6')
        -- recharge_info.set(707, 'product_id', '7')
        -- recharge_info.set(708, 'product_id', '10')
        productList["gold1"]    = "11"
        productList["gold6"]    = "1"
        productList["gold30"]   = "2"
        productList["gold50"]   = "3"
        productList["gold128"]  = "4"
        productList["gold288"]  = "5"
        productList["gold548"]  = "6"
        productList["gold648"]  = "7"
        productList["gold2048"] = "10"
        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '8')
        month_card_info.set(2, 'product_id', '9')

    elseif tostring(opId) == "2164" then   
        --麟游
        require("app.cfg.recharge_info")

        -- recharge_info.set(701, 'product_id', '1')
        -- recharge_info.set(702, 'product_id', '2')
        -- recharge_info.set(703, 'product_id', '3')
        -- recharge_info.set(704, 'product_id', '4')
        -- recharge_info.set(705, 'product_id', '5')
        -- recharge_info.set(706, 'product_id', '6')
        -- recharge_info.set(707, 'product_id', '7')
        -- recharge_info.set(708, 'product_id', '10')
        productList["gold1"]    = "11"
        productList["gold6"]    = "1"
        productList["gold30"]   = "2"
        productList["gold50"]   = "3"
        productList["gold128"]  = "4"
        productList["gold288"]  = "5"
        productList["gold548"]  = "6"
        productList["gold648"]  = "7"
        productList["gold2048"] = "10"
        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '8')
        month_card_info.set(2, 'product_id', '9')
    elseif tostring(opId) == "2156" then  --联通
        --[[
            9022765659720150407152446188200002  150407099303    25元月卡   道具  2500
            9022765659720150407152446188200001  150407099302    50元月卡   道具  5000

            9022765659720150407152446188200003  150407099304    60元宝    道具  600
            9022765659720150407152446188200004  150407099305    300元宝   道具  3000
            9022765659720150407152446188200005  150407099306    500元宝   道具  5000
            9022765659720150407152446188200006  150407099307    1280元宝  道具  12800
            9022765659720150407152446188200007  150407099308    2880元宝  道具  28800
            9022765659720150407152446188200008  150407099309    5480元宝  道具  54800
            9022765659720150407152446188200009  150407099310    6480元宝  道具  64800
            [1] = {1,"1","smc2","50元月卡",50,500,200,30,999,},
            [2] = {2,"1","smc1","25元月卡",25,250,100,30,998,},
            [1] = {1,"1","gold6","60元宝",1,6,60,60,0,},
            [2] = {2,"1","gold30","300元宝",2,30,300,300,30,},
            [3] = {3,"1","gold50","500元宝",3,50,500,500,55,},
            [4] = {4,"1","gold128","1280元宝",4,128,1280,1280,145,},
            [5] = {5,"1","gold288","2880元宝",5,288,2880,2880,335,},
            [6] = {6,"1","gold548","5480元宝",6,548,5480,5480,650,},
            [7] = {7,"1","gold648","6480元宝",7,648,6480,6480,780,},
        ]]
        --联通
        require("app.cfg.recharge_info")

        -- recharge_info.set(501, 'product_id', '003|150407099304')
        -- recharge_info.set(502, 'product_id', '004|150407099305')
        -- recharge_info.set(503, 'product_id', '005|150407099306')
        -- recharge_info.set(504, 'product_id', '006|150407099307')
        -- recharge_info.set(505, 'product_id', '007|150407099308')
        -- recharge_info.set(506, 'product_id', '008|150407099309')
        -- recharge_info.set(507, 'product_id', '009|150407099310')
        productList["gold6"]    = "003|150407099304"
        productList["gold30"]   = "004|150407099305"
        productList["gold50"]   = "005|150407099306"
        productList["gold128"]  = "006|150407099307"
        productList["gold288"]  = "007|150407099308"
        productList["gold548"]  = "008|150407099309"
        productList["gold648"]  = "009|150407099310"
        
        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '001|150407099302')
        month_card_info.set(2, 'product_id', '002|150407099303')
    elseif tostring(opId) == "2155" then    --移动
        --[[
            006067952001 60元宝600 审批通过 ..
            006067952002 25元月卡2500 审批通过 ..
            006067952003 300元宝3000 审批通过 ..
            006067952004 50元月卡5000 审批通过 ..
            006067952005 500元宝5000 审批通过 ..
        ]]

        require("app.cfg.recharge_info")

        -- recharge_info.set(501, 'product_id', '001')
        -- recharge_info.set(502, 'product_id', '003')
        -- recharge_info.set(503, 'product_id', '005')
        productList["gold6"]    = "001"
        productList["gold30"]   = "003"
        productList["gold50"]   = "005"
        -- 2015年11月27日 新增5个计费点
        productList["gold1"]   = "006"
        productList["gold128"]   = "007"
        productList["gold288"]   = "008"
        productList["gold548"]   = "009"
        productList["gold648"]   = "010"

        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '004')
        month_card_info.set(2, 'product_id', '002')
    elseif tostring(opId) == "2197" then    --盛大ghome

        require("app.cfg.recharge_info")

        -- recharge_info.set(701, 'product_id', '20156')
        -- recharge_info.set(702, 'product_id', '201530')
        -- recharge_info.set(703, 'product_id', '201550')
        -- recharge_info.set(704, 'product_id', '2015128')
        -- recharge_info.set(705, 'product_id', '2015288')
        -- recharge_info.set(706, 'product_id', '2015548')
        -- recharge_info.set(707, 'product_id', '2015648')
        -- recharge_info.set(708, 'product_id', '20152048')
        productList["gold1"]    = "20151"
        productList["gold6"]    = "20156"
        productList["gold30"]   = "201530"
        productList["gold50"]   = "201550"
        productList["gold128"]  = "2015128"
        productList["gold288"]  = "2015288"
        productList["gold548"]  = "2015548"
        productList["gold648"]  = "2015648"
        productList["gold2048"] = "20152048"

        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', '2015smc2') --50
        month_card_info.set(2, 'product_id', '2015smc1')
    end
    if LANG == "tw" then
        require("app.cfg.recharge_info")

        -- recharge_info.set(1, 'product_id', 'com.icantw.ss.item01')
        -- recharge_info.set(2, 'product_id', 'com.icantw.ss.item02')
        -- recharge_info.set(3, 'product_id', 'com.icantw.ss.item03')
        -- recharge_info.set(4, 'product_id', 'com.icantw.ss.item04')
        -- recharge_info.set(5, 'product_id', 'com.icantw.ss.item05')
        -- recharge_info.set(6, 'product_id', 'com.icantw.ss.item06')
        -- recharge_info.set(7, 'product_id', 'com.icantw.ss.item07')
        
        productList["gold6"]    = "com.icantw.ss.item01"
        productList["gold30"]   = "com.icantw.ss.item02"
        productList["gold50"]   = "com.icantw.ss.item03"
        productList["gold128"]  = "com.icantw.ss.item04"
        productList["gold288"]  = "com.icantw.ss.item05"
        productList["gold548"]  = "com.icantw.ss.item06"
        productList["gold648"]  = "com.icantw.ss.item07"

        require("app.cfg.month_card_info")
        month_card_info.set(1, 'product_id', 'com.icantw.ss.item09')
        month_card_info.set(2, 'product_id', 'com.icantw.ss.item08')
    end
    ComSdkProxyConfig.setRechargeInfo(productList)
end


function ComSdkProxyConfig.getWeixinAppkey()
    local packageName =  UFPlatformHelper:getPackageName()

    local record =  packages_config.get(packageName)
    if record then
        return record.weixin_appkey
    else
        return ""
    end
end




return ComSdkProxyConfig
