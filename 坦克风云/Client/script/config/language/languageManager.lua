languageManager={}
wzCfg={}
illegalWords={  
    {"h","时",pattern="(%d+h)"},
    {"h","时",pattern="(/h)"},
    {"m","分",pattern="(%d+m)"},
    {"s","秒",pattern="(%d+s)"},
    {"d","天",pattern="(%d+d)"},
    {"K","千",pattern="(%d+K)"},
    {"M","兆",pattern="(%d+M)"},
    {"G","千兆",pattern="(%d+G)"},
    {"[Ll][Vv]","等级"},
    {"[Bb][Uu][Ff][Ff]","增益效果"},
    {"攻占","采集"},
    {"掠夺","探索"},
    {"VIP贵族","贵族"},
    {"[Vv][Ii][Pp]","贵族"},
}

function languageManager:init()
    local str= CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)
    if str=="" then
        local tmpLanCfg=platCfg.platCfgDefaultLan[G_curPlatName()]
        if tmpLanCfg~=nil then
              str=tmpLanCfg
        else
              str=G_getOSCurrentLanguage() --获取设备当前选择的语言
        end
        if platCfg.platCfgDeviceLangToGameLang[str]~=nil then
             str=platCfg.platCfgDeviceLangToGameLang[str]
        end
        if platCfg.platCfgLanType[G_curPlatName()]~=nil then

             local allLang=platCfg.platCfgLanType[G_curPlatName()]
             if type(allLang)=="table" then
                    local hasLang=false
                    for k,v in pairs(allLang) do
                        if k==str then
                            hasLang=true
                        end
                    end
                    if hasLang==false then
                        str="en"
                    end
             else
                    if str~=allLang then
                         str="en"
                    end
             end
        end
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_curLanguage,str)    
    end
    if  platCfg.platCfgSetSDKUserLanguage[G_curPlatName()]~=nil then
    
        local  cvrtTb=platCfg.platCfgDeviceLangToGameLang
        local  curDeviceLang=str
        for k,v in pairs(cvrtTb) do
             if v==str then
                  curDeviceLang=k
             end
        end
        local tmpTb={}
        tmpTb["action"]="setLanguage"
        tmpTb["parms"]={}
        tmpTb["parms"]["language"]=curDeviceLang
        local cjson=G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
    if str=="en" and platCfg.platCfgChoseEn[G_curPlatName()]~=nil then
        str=platCfg.platCfgChoseEn[G_curPlatName()]
    elseif str=="fr" and platCfg.platCfgChoseFr[G_curPlatName()]~=nil then
        str=platCfg.platCfgChoseFr[G_curPlatName()]    end
    G_CurLanguageName=str

    require ("luascript/script/config/language/"..str)
    require ("luascript/script/config/language/"..str.."2")
    require ("luascript/script/config/language/"..str.."3")
    require ("luascript/script/config/language/"..str.."4")
    require "luascript/script/config/gameconfig/platFormCfg"
    platFormCfg:changePlatCfg()
end

--params: text:要替换的文字
function replaceIllegal(text)
    local wz=text
    if(G_isHexie())then
        for k,v in pairs(illegalWords) do
            local function realReplace(illegalStr,replaceStr,pattern)
                if illegalStr and replaceStr then
                    if pattern then
                        for matchStr in string.gmatch(wz,pattern) do
                            local realReplaceStr=string.gsub(matchStr,illegalStr,replaceStr)
                            wz=string.gsub(wz,matchStr,realReplaceStr)
                        end
                    else
                        wz=string.gsub(wz,illegalStr,replaceStr)
                    end
                end
            end
            if type(v[1])=="table" then
                for k,str in pairs(v[1]) do
                    realReplace(str,v[2],v.pattern)
                end
            else
                realReplace(v[1],v[2],v.pattern)
            end
        end
    end
    return wz
end

function getlocal(key,value,subValue)
    local wz
    wz=wzCfg[G_getCurChoseLanguage().."4"][key]
    if wz==nil then
        wz=wzCfg[G_getCurChoseLanguage().."3"][key]
    end
    if wz ==nil then
        wz=wzCfg[G_getCurChoseLanguage().."2"][key]
    end
    if wz==nil then
        local ishavekey=false
        if wzCfg[G_getCurChoseLanguage()]~=nil then
            wz=wzCfg[G_getCurChoseLanguage()][key]
            if wz~=nil then
                 ishavekey=true
            end
        end
        if ishavekey==false then

            if platFormCfg[key]==nil then
                do
                    return "**"..key
                end
            else
                do
                    return platFormCfg[key]
                end
            end
        end
    end
    if value and type(value)=="table" then
        for k,v in pairs(value) do
            wz = string.gsub(wz,"%%s",v,1)
            wz = string.gsub(wz,"{"..k.."}",v)
        end
    end
	while string.find(wz,"#(.-)#")~=nil do
		local startIdx,endIdx=string.find(wz,"#(.-)#")
		
		local firstStr=""
		local endStr=""
		if startIdx>1 then
			firstStr=string.sub(wz,1,startIdx-1)
		end
		if endIdx<string.len(wz) then
			endStr=string.sub(wz,endIdx+1)
		end
		if endIdx-startIdx>1 then
            local newKey=string.sub(wz,startIdx+1,endIdx-1)
            wz=firstStr..getlocal(newKey,subValue)..endStr
		else
			wz=firstStr..endStr
		end
	end

    if G_getBHVersion()==2 then
        if string.find(wz,"统率书")~=nil then
            wz=G_stringGsub(wz,"统率书","声望书")
        end
        if key=="sample_prop_des_2022" then
            wz="使用后可获得1点声望值，并额外赠送声望或提升统率等级"

        end
        if key=="sample_prop_des_5015" then
            wz="珍贵的硬币，大家通常使用它兑换资源矿产！"
        end
        if key=="sample_prop_des_2021" then
            wz="提升指挥官技能等级，可以关卡，每日任务和资源兑换中获得"
        end
        
    end
    
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then 

        if string.find(wz,"VIP10")~=nil then
            wz=G_stringGsub(wz,"VIP10",platCfg.platCfgShowVipText[G_curPlatName()]["VIP10"])
        
        elseif string.find(wz,"VIP")~=nil then
            local a,b=string.find(wz,"VIP")
            local c=G_stringGetAt(wz,b+1,b+1)
            if tonumber(c)~=nil then
                if platCfg.platCfgShowVipText[G_curPlatName()]~=nil then
                    local hhh="VIP"..c
                    wz=G_stringGsub(wz,"VIP"..c,platCfg.platCfgShowVipText[G_curPlatName()]["VIP"..c])
                end
            else
                wz=G_stringGsub(wz,"VIP","Medal")
            end
        end
        for i=1,3 do
            if string.find(wz,"VIP10")~=nil then
                wz=G_stringGsub(wz,"VIP10",platCfg.platCfgShowVipText[G_curPlatName()]["VIP10"])
        
            elseif string.find(wz,"VIP")~=nil then
                local a,b=string.find(wz,"VIP")
                local c=G_stringGetAt(wz,b+1,b+1)
                if tonumber(c)~=nil then
                    if platCfg.platCfgShowVipText[G_curPlatName()]~=nil then
                        local hhh="VIP"..c
                        wz=G_stringGsub(wz,"VIP"..c,platCfg.platCfgShowVipText[G_curPlatName()]["VIP"..c])
                    end
                else
                    wz=G_stringGsub(wz,"VIP","Medal")
                end
            else
                break
            end 
        end


        
        if string.find(wz,"vip")~=nil then
            wz=G_stringGsub(wz,"vip","Medal")
        end
    end
    if wz then
        wz=replaceIllegal(wz)
    end
    return wz
end
function getBMFntSrc()
    if G_country=="cn" then
        return "zh-Hans.fnt"
    end
end

--获取当前使用的语言文件的行数，用来判断lua是否更新到最新版本
function languageManager:getLanguageVersion()
    if(wzCfg and G_getCurChoseLanguage() and wzCfg[G_getCurChoseLanguage().."4"])then
        return SizeOfTable(wzCfg[G_getCurChoseLanguage().."4"])
    else
        return 0
    end
end

--检测文字是否存在
function languageManager:isHaveText(key)
    local wz
    local curLan = G_getCurChoseLanguage()
    for k = 4, 1, -1 do
        print("k===>",k)
        wz = wzCfg[curLan..k]
        if wz then
            return true
        end
    end
    return false
end