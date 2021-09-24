--require "luascript/script/componet/commonDialog"
require "luascript/script/game/scene/gamedialog/settingsDialog/changePasswordDialog"
require "luascript/script/game/scene/gamedialog/settingsDialog/gameSettingsDialog"
require "luascript/script/game/scene/gamedialog/settingsDialog/serverListDialog"
require "luascript/script/game/scene/gamedialog/settingsDialog/bindingAccountDialog"
require "luascript/script/game/scene/gamedialog/settingsDialog/languageDialog"
settingsDialog=commonDialog:new()

function settingsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.buttonTab={}

    self.buttonItems={}
     CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/addImageSetting.plist")
    return nc
end

function settingsDialog:initLayer()

    self.bgLayer1=CCLayer:create()
    self.bgLayer:addChild(self.bgLayer1)

    G_isNeedLoginGooleF5=self

    if G_isSendAchievementToGoogle()>1 then
       CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("arImage/googleSettingImage.plist")
    end


    local function callBack1()
        if G_curPlatName()=="androiduc" then
            require "luascript/script/game/scene/gamedialog/helpDialog"
            local dd = helpDialog:new()
            local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,3);
            sceneGame:addChild(vd,4)
        else
            local td=changePasswordDialog:new()
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("changePassword"),false,self.layerNum+1)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end

    local function callBack2()
        local td=serverListDialog:new(self)
        local tbArr={getlocal("recentLogin"),getlocal("allServers")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverListOpt"),false,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local function callBack3()
        local td=gameSettingsDialog:new()
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("gameSetting"),false,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local function callBack4()
        local languageInfo= languageDialog:new()
        local infoBg = languageInfo:init(self.layerNum+1);
    end
    local function callBack5()
        if G_isSendAchievementToGoogle()>0 and G_curPlatName()=="androidarab" then
            PlatformManage:shared():loginOut()
        end
        self:close(false)
        if G_loginType==1 then --第三方绑定
             if G_curPlatName()=="0" or G_curPlatName()=="2" or G_curPlatName()=="googleplay" then
                      FBSdkHelper:exitLogin() --facebook
                      G_setTankIsguest("1")
                      base:changeServer()  
             elseif G_curPlatName()=="1" or G_curPlatName()=="42" then  --快用平台
                    if PlatformManage~=nil then
                 --       PlatformManage:shared():showLogin()
                  --      base:changeServer()
                            base:changeServer()
                            PlatformManage:shared():switchAccount();

                    end
             elseif G_curPlatName()=="qihoo" then --360平台
                      if PlatformManage~=nil then
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                      end
             elseif G_curPlatName()=="memoriki" then --memoriki平台
                      if PlatformManage~=nil then
                            deviceHelper:luaPrint("memoriki")
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                      end
            elseif G_curPlatName()=="11" then --memoriki平台
                      if PlatformManage~=nil then
                            deviceHelper:luaPrint("sevenga ios")
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                      end
             elseif G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" then --efun平台
                      if PlatformManage~=nil then
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                      end
             elseif G_curPlatName()=="6" then
                    if PlatformManage~=nil then
                        base:changeServer()
                        local tmpTb={}
                        tmpTb["action"]="showCustomPanel"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["type"]=2
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                        
                        local tmpTb={}
                        tmpTb["action"]="showCustomPanel"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["type"]=3
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
                    if(G_Version>=6)then
                        local tmpTb={}
                        tmpTb["action"]="showFloatBall"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["value"]="hide"
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
       --      elseif G_curPlatName()=="androidwandoujia" then
       --             local dd = helpDialog:new()
       --         local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,3);
     --           sceneGame:addChild(vd,4)
             elseif G_curPlatName()=="8" then
                    PlatformManage:shared():loginOut()
                    if PlatformManage~=nil then
                        base:changeServer()
                        PlatformManage:shared():switchAccount();
                    end
             elseif(G_isKakao())then
                    G_kakaoLogout=true
                    CCUserDefault:sharedUserDefault():setIntegerForKey("gameHasShown",0)
                    CCUserDefault:sharedUserDefault():flush()
                    if PlatformManage~=nil then
                        base:changeServer()
                        PlatformManage:shared():switchAccount();
                    end
            elseif G_curPlatName()=="androidky7659" or G_curPlatName()=="androidewan" then
                    if PlatformManage~=nil then
                        PlatformManage:shared():switchAccount();
                    end
             else
                      if PlatformManage~=nil then
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                      end
             end
        else --loginType＝2 说明是用的rayjoy账号系统
                      FBSdkHelper:exitLogin() --facebook
                      G_setTankIsguest("1")
                      base:changeServer()
        end
    end
    local function callBack6()
        if G_curPlatName()=="memoriki" then
            if PlatformManage~=nil then
                PlatformManage:shared():contactUs("","","")
            end
            do
                return
            end
        elseif G_curPlatName()=="20" or G_curPlatName()=="31" then
            local str = "<br><br><br><br><br><br><br>---------------------<br>uid:"..playerVoApi:getUid().."<br>userName:"..playerVoApi:getPlayerName().."<br>version:"..G_Version.."<br>zoneId:"..base.curZoneID.."<br>device:".."iPhone".."<br>gameName:"..platFormCfg.gameName[G_getCurChoseLanguage()]
            local tmpTb={}
            tmpTb["action"]="openUrl"
            tmpTb["parms"]={}
            tmpTb["parms"]["url"]="mailto:souzetudaisenso@gmail.com?body="..HttpRequestHelper:URLEncode(str)
            local cjson=G_Json.encode(tmpTb)
            print("ssss=",cjson)
            G_accessCPlusFunction(cjson)
            do
                return
            end
        elseif G_curPlatName()=="62" then
            if PlatformManage~=nil then
                PlatformManage:shared():contactUs("","","")
                do
                    return
                end
            end
        elseif G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="efunandroidmemoriki" or G_curPlatName()=="efunandroid360" or G_curPlatName()=="efunandroidnm" or G_curPlatName()=="efunandroidhuashuo" then
            if PlatformManage~=nil then
                PlatformManage:shared():contactUs(serverCfg.customerurl,"","")
                do
                    return
                end
            end
        elseif G_curPlatName()=="androidyuenan" or G_curPlatName()=="49" or G_curPlatName()=="androidyuenan2" or G_curPlatName()=="53" then
            if PlatformManage~=nil then
                PlatformManage:shared():contactUs("","","")
                do return end
            end
        elseif G_curPlatName()=="android3kwan" or G_curPlatName()=="android3kwan_ndcom" or G_curPlatName()=="android3kbaidu" or G_curPlatName()=="android3ktencent" or G_curPlatName()=="android3ktencent2" or G_curPlatName()=="android3ktencent3" or G_curPlatName()=="android3ktencent4" or G_curPlatName()=="28" or G_curPlatName()=="40" or G_curPlatName()=="54" then
            local function onConfirm()
                local tmpTb={}
                tmpTb["action"]="openUrl"
                tmpTb["parms"]={}
                tmpTb["parms"]["url"]="http://gm.3k.com/?page_code=2&game_id=11&from=sdk"
                local cjson=G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            end
            local sd=smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("redirectToGMSite"),nil,self.layerNum+1)
            do return end
        elseif G_curPlatName()=="androidpipa" and G_Version>=10 then
            self:showHelpfish()
            do return end
        elseif((G_curPlatName()=="androiduc" and G_Version>=6 and G_Version<12) or 
            (G_curPlatName()=="androidwandoujia" and G_Version>=14 and G_Version<20) or 
            (G_curPlatName()=="qihoo" and G_Version>=27 and G_Version<34) or 
            (G_curPlatName()=="androidtencentysdk" and G_Version>=7 and G_Version<23) or 
            (G_curPlatName()=="androidxiaomi" and G_Version>=10 and G_Version<14) or 
            (G_curPlatName()=="androidhuawei2" and G_Version>=16 and G_Version<24) or 
            (G_curPlatName()=="androidrayjoy" and G_Version>=4) or 
            (G_curPlatName()=="androidjinli2" and G_Version>=6) or 
            (G_curPlatName()=="androidmeizu2" and G_Version>=12 and G_Version<14) or 
            (G_curPlatName()=="androidwamai" and G_Version>=8 and G_Version<9))then
            self:showZhichi()
            do return end
        elseif((G_curPlatName()=="androiduc" and G_Version>=12) or 
            (G_curPlatName()=="androidwandoujia" and G_Version>=20) or 
            (G_curPlatName()=="qihoo" and G_Version>=34) or 
            (G_curPlatName()=="androidtencentysdk" and G_Version>=23) or 
            (G_curPlatName()=="androidxiaomi" and G_Version>=14) or 
            (G_curPlatName()=="androidhuawei2" and G_Version>=24) or 
            (G_curPlatName()=="androidmeizu2" and G_Version>=14) or 
            (G_curPlatName()=="androidwamai" and G_Version>=9))then
            G_showZhichiContactSys()
            do return end    
        elseif(platFormCfg.contactLink)then
            local descStr=platFormCfg.contactUsInfo
            if(type(descStr)=="table")then
                descStr=platFormCfg.contactUsInfo[G_getCurChoseLanguage()]
                if(descStr==nil)then
                    for k,v in pairs(platFormCfg.contactUsInfo) do
                        descStr=v
                        break
                    end
                end
            end
            local function onGoto()
                local tmpTb={}
                tmpTb["action"]="openUrl"
                tmpTb["parms"]={}
                tmpTb["parms"]["url"]=platFormCfg.contactLink
                tmpTb["parms"]["connect"]=platFormCfg.contactLink
                local cjson=G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onGoto,getlocal("optContactUs"),descStr,nil,self.layerNum+1,kCCTextAlignmentLeft,nil,nil,getlocal("activity_heartOfIron_goto"))
            do return end
        elseif(base.serverPlatID=="rayjoy_android" or base.serverPlatID=="fl_yueyu" or base.serverPlatID=="5")then
            local tmpTb={}
            tmpTb["action"]="openUrl"
            tmpTb["parms"]={}
            tmpTb["parms"]["url"]="https://www.sobot.com/chat/pc/index.html?sysNum=6456e9315f4948b0922d5aec9c84190d"
            tmpTb["parms"]["connect"]="https://www.sobot.com/chat/pc/index.html?sysNum=6456e9315f4948b0922d5aec9c84190d"
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
            do return end
        end
            local td=smallDialog:new()
            local str1 = getlocal("optContactUs")
            local str2 = platFormCfg.contactUsInfo
            local tabStr ={}
            if type(str2)=="table" and G_getCurChoseLanguage() ~= "tu"then
                 str2 =str2[G_getCurChoseLanguage()]
                 tabStr = {str2,str1}
            elseif G_getCurChoseLanguage() =="tu" then                
                tabStr = str2
            else
                tabStr ={str2,str1}
            end
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
            --dialog:setPosition(getCenterPoint(sceneGame))
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    local function callBack7()
        if G_curPlatName()=="3" or G_curPlatName()=="efunandroidtw" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="efunandroiddnych" or G_curPlatName()=="4" or G_curPlatName()=="47" or G_curPlatName()=="efunandroidhuashuo" then
                    local tmpTb={}
                    tmpTb["action"]="openUrl"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["url"]=serverCfg.bbsurl
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    do
                        return
                    end
            elseif G_curPlatName()=="5" or G_curPlatName()=="9" or G_curPlatName()=="10" or G_curPlatName()=="45" or G_curPlatName()=="58" then
                    local tmpTb={}
                    tmpTb["action"]="showCustomPanel"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["type"]=1
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    do
                        return
                    end
            elseif G_curPlatName()=="6" or G_curPlatName()=="ndcom" or G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" then
                require "luascript/script/game/scene/gamedialog/helpDialog"
                local dd = helpDialog:new()
                    local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,self.layerNum+1);
                    sceneGame:addChild(vd,self.layerNum+1)
            elseif G_curPlatName()=="androidyuenan" or G_curPlatName()=="49" or G_curPlatName()=="androidyuenan2" or G_curPlatName()=="53" then
                local td=smallDialog:new()
                local tabStr={"Facebook: www.facebook.com/daichientanks","Email: daichientanks@gmail.com"}
                local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
                sceneGame:addChild(dialog,self.layerNum+1)
                do return end
            elseif G_curPlatName()=="androidrgame" or G_curPlatName()=="11" then
                PlatformManage:shared():bindAccount(function ( ... )end,"","","")
                do return end
            elseif G_curPlatName()=="androidsevenga" then
                PlatformManage:shared():contactUs("","","")
                do return end
            end
            
            if G_loginType==2 then --绑定邮箱方式登录

                    if platCfg.platCfgLoginSceneBtnType[G_curPlatName()]==8 then
                                local function selectTypeHandler(stype)
                                        if stype==1 then --facebook绑定
                                                local tmpTb={}
                                                tmpTb["action"]="bindAccout"
                                                tmpTb["parms"]={}
                                                tmpTb["parms"]["type"]="facebook"
                                                tmpTb["parms"]["callbackHandler"]="bindFacebookAccount"
                                                local cjson=G_Json.encode(tmpTb)
                                                G_accessCPlusFunction(cjson)
                                        else --自定义账号绑定
                                                 local td=bindingAccountDialog:new()
                                                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("bindAccount"),false,self.layerNum+1)
                                                sceneGame:addChild(dialog,self.layerNum+1)
                                                local tmpTb={}
                                                tmpTb["action"]="bindAccout"
                                                tmpTb["parms"]={}
                                                tmpTb["parms"]["type"]="sdk"
                                                tmpTb["parms"]["callbackHandler"]="bindRaySdkAccount"
                                                local cjson=G_Json.encode(tmpTb)
                                                G_accessCPlusFunction(cjson)

                                        end
                                end
                                --日本IOS特殊处理，没有绑定Facebook了
                                if(G_curPlatName()=="20" and G_Version==4)then
                                    selectTypeHandler(2)
                                    do return end
                                end
                                local td=smallDialog:showBindingSureDialog("panelBg.png",CCSizeMake(600,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),false,self.layerNum+1,selectTypeHandler,getlocal("bindAccount"))
                                --sceneGame:addChild(td,self.layerNum+1)
                    elseif platCfg.platCfgLoginSceneBtnType[G_curPlatName()]==9 then
                                local td=bindingAccountDialog:new()
                                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("bindAccount"),false,self.layerNum+1)
                                sceneGame:addChild(dialog,self.layerNum+1)
                    end
            elseif G_loginType==1 then --第三方平台方式登录
                  
                  local function bindCbackHandler(fn,fbid)
                        G_cancleLoginLoading()
                        if fbid~="" then --账号绑定成功
                                    ------以下调用http绑定账号
                                    G_bindUserACCount(fbid)
                                    ------以上调用http获取uid和token
                        end
                  end
                  if G_loginType==1 then --第三方账号
                         if G_curPlatName()=="0" or G_curPlatName()=="2" or G_curPlatName()=="googleplay" then
                            G_showLoginLoading(10)
                            local fbid=FBSdkHelper:bindAccout(bindCbackHandler) --facebook账号
                         elseif G_curPlatName()=="1" or G_curPlatName()=="42" then  --快用平台
                            if PlatformManage~=nil then
                                base:changeServer()
                                PlatformManage:shared():showLogin()
                            end 
                         elseif G_curPlatName()=="memoriki" or G_curPlatName()=="efunandroidmemoriki" or G_curPlatName()=="android360ausgoogle" then
                             if PlatformManage~=nil then
                                local function bindResultHandler()
                                          local function bindCallBack(fn,sdata)
                                                 base:checkServerData(sdata) 
                                                 global.accountIsBind=true
                                                 smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("congratulation")..getlocal("bindSuccess"),nil,5)
                                                            end
                                          socketHelper:bindingAccount(bindCallBack)
                                end
                                PlatformManage:shared():bindAccount(bindResultHandler,"","","")
                            end 
                         end
                  end

            end
    end

    local function callBack8()
        if G_curPlatName()=="5" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="9" or G_curPlatName()=="10"  or G_curPlatName()=="16" or G_curPlatName()=="45" or G_curPlatName()=="58" then --飞流平台
            local tmpTb={}
            tmpTb["action"]="showCustomPanel"
            tmpTb["parms"]={}
            tmpTb["parms"]["type"]=1
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        elseif G_curPlatName()=="efunandroiddny" or G_curPlatName()=="efunandroiddnych" or G_curPlatName()=="4" or G_curPlatName()=="47" then
            local tmpTb={}
            tmpTb["action"]="openUrl"
            tmpTb["parms"]={}
            if platCfg.platCfgUrl[G_curPlatName()][G_getCurChoseLanguage()]~=nil then
                tmpTb["parms"]["url"]=platCfg.platCfgUrl[G_curPlatName()][G_getCurChoseLanguage()]
            end
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        elseif G_curPlatName()=="1" or G_curPlatName()=="42"  then
            local tmpTb={}
            tmpTb["action"]="showCustomPanel"
            tmpTb["parms"]={}
            tmpTb["parms"]["type"]=1
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
    local function callBack14()
        if G_curPlatName()=="android360ausgoogle" then
            local tmpTb={}
            tmpTb["action"]="openUrl"
            tmpTb["parms"]={}
            tmpTb["parms"]["url"]=serverCfg.bbsurl
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
    local function callBack15()
          local tmpTb={}
          tmpTb["action"]="openUrlInAppWithClose"
          tmpTb["parms"]={}
          tmpTb["parms"]["connect"]="http://tank-korea-in.raysns.com/tankheroclient/tankHtml/koAgreement.html?a="..math.random(1,10000)
          local cjson=G_Json.encode(tmpTb)
          G_accessCPlusFunction(cjson)
    end
    local function callback16()
        local function onConfirm()
            local gucenterUrl=friendVoApi:getGUCenterPrefix()
            local url=gucenterUrl.."deluserinfo.php"
            local reqParam="uid="..playerVoApi:getUid().."&username="..G_getUserPlatID().."&zoneid="..base.curZoneID
            local retStr=G_sendHttpRequestPost(url,reqParam)
            local result=G_Json.decode(retStr)
            if(result and result.ret==0)then
                callBack5()
                if(G_isKakao())then
                    local tmpTb={}
                    tmpTb["action"]="customAction"
                    tmpTb["parms"]={}
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                end
            else
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage1989"),nil,self.layerNum+1)
            end
            CCUserDefault:sharedUserDefault():setIntegerForKey("gameHasShown",0)
            CCUserDefault:sharedUserDefault():flush()
        end
        local sd=smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("clearData_confirm"),nil,self.layerNum+1)
        local lb=sd.bgLayer:getChildByTag(518)
        if(lb and tolua.cast(lb,"CCLabelTTF"))then
            lb=tolua.cast(lb,"CCLabelTTF")
            lb:setColor(G_ColorRed)
        end
    end
    local function callback17()
        require "luascript/script/game/scene/scene/kakaoTermsDialog"
        kakaoDialog=kakaoTermsDialog:new()
        kakaoDialog:init(4,false)
    end
    local function callback18()
        local function onGetPlatformInfo(data)
            PlayEffect(audioCfg.mouseClick)
            local tabStr={"\n",getlocal("membership_show")..": "..data.id,"\n"}
            local tabColor={nil,G_ColorYellowPro,nil}
            local td=smallDialog:new()
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
            sceneGame:addChild(dialog,self.layerNum+1) 
        end
        playerVoApi:getPlatformInfo({},onGetPlatformInfo)
    end
    local function callback19()
        local tmpTb={}
        tmpTb["action"]="openUrlInAppWithClose"
        tmpTb["parms"]={}
        if(G_isKakao())then
            tmpTb["parms"]["connect"]="https://game.nanoo.so/aotkakao"
        end
        local cjson=G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end

    local function callBack20()
          local tmpTb={}
          tmpTb["action"]="showCustomPanel"
          tmpTb["parms"]={}
          tmpTb["parms"]["value"]="leaderboard"
          local cjson=G_Json.encode(tmpTb)
          G_accessCPlusFunction(cjson)
    end
    local function callBack21()
          local tmpTb={}
          tmpTb["action"]="showCustomPanel"
          tmpTb["parms"]={}
          tmpTb["parms"]["value"]="achievements"
          local cjson=G_Json.encode(tmpTb)
          G_accessCPlusFunction(cjson)
    end

    local function callBack22()
        if(G_isSendAchievementToGoogle()>1)then
            local tmpTb={}
            tmpTb["action"]="customAction"
            tmpTb["parms"]={}
            tmpTb["parms"]["value"]="googleLogin"
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        elseif(G_isSendAchievementToGoogle()==1)then
            local sd=smallDialog:new()
            local layerNum=self.layerNum + 1
            sd:initSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),"",nil,layerNum)
            local btn1=LuaCCSprite:createWithSpriteFrameName("arGoogleIcon2.png",callBack21)
            btn1:setTouchPriority(-(layerNum-1)*20-3)
            btn1:setPosition(200,200)
            sd.bgLayer:addChild(btn1,1)
            local btn2=LuaCCSprite:createWithSpriteFrameName("arGoogleIcon3.png",callBack20)
            btn2:setTouchPriority(-(layerNum-1)*20-3)
            btn2:setPosition(350,200)
            sd.bgLayer:addChild(btn2,1)
        end
    end

    local function callBack23()
          local tmpTb={}
          tmpTb["action"]="customAction"
          tmpTb["parms"]={}
          tmpTb["parms"]["value"]="googleLoginOut"
          local cjson=G_Json.encode(tmpTb)
          G_accessCPlusFunction(cjson)
    end

    -- 引导
    local function callBack24()
          require "luascript/script/game/scene/gamedialog/becomeStrongDialog"
         local td=becomeStrongDialog:new()
         local tbArr={}
         local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("become_strong_title"),false,self.layerNum+1)
         sceneGame:addChild(dialog,self.layerNum+1)
    end
    -- 兑换
    local function callBack25()
        smallDialog:showCodeRewardDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1)
    end

    --自有客服系统
    local function callBack26()
        local url=platCfg.platGM[G_curPlatName()]
        if(url)then
            url=url.."?user_id="..playerVoApi:getUid().."&user_name="..playerVoApi:getPlayerName().."&user_level="..playerVoApi:getPlayerLevel().."&vip_level="..playerVoApi:getVipLevel().."&total_cost="..playerVoApi:getBuygems().."&regtime="..playerVoApi:getRegdate().."&appid="..G_getPlatAppID().."&zid="..base.curZoneID.."&color=1".."&language="..G_getCurChoseLanguage()
            local tmpTb={}
            tmpTb["action"]="openUrlInAppWithClose"
            tmpTb["parms"]={}
            tmpTb["parms"]["connect"]=url
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
    local function callBack27()
        if verifyApi:isVerified() == true then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),"您已经进行过实名认证！",30)
            do return end
        end
        require "luascript/script/game/scene/gamedialog/realnameSmallDialog"
        local sd=realnameSmallDialog:new()
        sd:init(self.layerNum + 1, true)
    end
    local function callBack28()
        migrationVoApi:showCodeDialog()
    end
    local function callBack29()
        migrationVoApi:showInputDialog(self.layerNum + 1)
    end

    --b1-b7 "修改密码","服务器列表","游戏设置",“选择语言”,"更换账号",联系我们","绑定账号"
    --b8 巴哈论坛
    --b9 facebook
    --b10 指南
    --b11 账号管理
    --b12 帮助
    --b13 uc帮助
    --b14 360澳大利亚打开论坛

    --b15 韩国需求的协议展示
    --b16 删号, 韩国kakao的特殊需求
    --b17 kakao协议展示
    --b18 显示kakao会员号
    --b19 游戏主页
    --b20~b23:google成就系统
    -- b24 引导
    -- b25 兑换

    --b26: 自有客服系统

    --b20~b23:google成就系统
    --b24: 我要变强
    --b25: 激活码礼包
    --b26: 联系我们
    --b27: 实名认证
    --b28: 数据迁移激活码
    --b29: 数据迁移激活码输入

    self.buttonTb={
    b1={icon="AccountIcon.png",name="changePassword",callBack=callBack1},
    b2={icon="ServeIcon.png",name="serverListOpt",callBack=callBack2},
    b3={icon="SetUpIcon.png",name="gameSetting",callBack=callBack3},
    b4={icon="LanguageIcon.png",name="choiceLanguage",callBack=callBack4},
    b5={icon="ChangeBtn.png",name="changeAccount",callBack=callBack5},
    b6={icon="ContactBtn.png",name="optContactUs",callBack=callBack6},
    b7={icon="AccountIcon.png",name="bindAccount",callBack=callBack7},
    b8={icon="AccountIcon.png",name="directToBBS",callBack=callBack7},
    b9={icon="AccountIcon.png",name="facebookBtn",callBack=callBack7},
    b10={icon="helpIcon.png",name="settingFAQ",callBack=callBack8},
    b11={icon="AccountIcon.png",name="accountManagement",callBack=callBack8},
    b12={icon="AccountIcon.png",name="help",callBack=callBack7},
    b13={icon="AccountIcon.png",name="help",callBack=callBack1},
    b14={icon="AccountIcon.png",name="facebookBtn",callBack=callBack14},
    b15={icon="helpIcon.png",name="agreement",callBack=callBack15},
    b16={icon="AccountIcon.png",name="clearData",callBack=callback16},
    b17={icon="helpIcon.png",name="agreement",callBack=callback17},
    b18={icon="AccountIcon.png",name="membership_show",callBack=callback18},
    b19={icon="helpIcon.png",name="homepage",callBack=callback19},
    b20={icon="googleSet2.png",name="google_rank",callBack=callBack20},
    b21={icon="googleSet3.png",name="google_achievement",callBack=callBack21},
    b22={icon="arGoogleIcon1.png",name="google_connected",callBack=callBack22},
    b23={icon="googleSet1.png",name="google_notconnected",callBack=callBack23},
    b24={icon="userGuideBtn.png",name="user_guide",callBack=callBack24},
    b25={icon="giftChangeBtn.png",name="gift_change",callBack=callBack25},
    b26={icon="ContactBtn.png",name="chat_gm_icon",callBack=callBack26},
    b27={icon="AccountIcon.png",name="registRealName",callBack=callBack27},
    b28={icon="AccountIcon.png",name="migrationCode",callBack=callBack28},
    b29={icon="AccountIcon.png",name="migrationCode",callBack=callBack29},
    }
    
    --初始化按钮列表
    self:initButtonList()

    --kakao logout
    if(G_isKakao())then
        local logoutBtn=LuaCCSprite:createWithFileName("zsyImage/logoutBtn_kakao.png",callBack5)
        logoutBtn:setScale(0.8)
        logoutBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        logoutBtn:setPosition(G_VisibleSizeWidth/2,160)
        self.bgLayer:addChild(logoutBtn)
    end
    
    local uidLb=GetTTFLabelWrap(getlocal("uidIs",{playerVoApi:getUid()}),28,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    uidLb:setPosition(ccp(G_VisibleSizeWidth/2,100))
    self.bgLayer1:addChild(uidLb,2)
    if G_isGlobalServer()==true then
        uidLb:setPosition(ccp(G_VisibleSizeWidth/2,65))
        self.timeLb=GetTTFLabelWrap(getlocal("server_time",{G_formatDate(base.serverTime)}),25,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.timeLb:setPosition(ccp(G_VisibleSizeWidth/2,110))
        self.bgLayer1:addChild(self.timeLb,2)
        self.timeLb:setColor(G_ColorYellowPro)
    end
    if verifyApi:isOpen() == true and verifyApi:isAdult() == false then --未成年人累计在线时长显示
        local olts = playerVoApi:getDailyOnlineTime()
        local onlineTimeLb = GetTTFLabelWrap(getlocal("user_online_time",{GetTimeStr(olts)}),22,CCSizeMake(G_VisibleSizeWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
        onlineTimeLb:setAnchorPoint(ccp(0.5,0))
        onlineTimeLb:setPosition(G_VisibleSizeWidth/2,uidLb:getPositionY() + uidLb:getContentSize().height/2 + 20)
        self.bgLayer:addChild(onlineTimeLb) 
        self.onlineTimeLb = onlineTimeLb
    end
    self:tick()

    local function refreshButtons()
        if self:isClosed() == true then
            do return end
        end
        self:initButtonList()
    end
    migrationVoApi:getMigrateStatusFromServer(refreshButtons)
end

--初始化按钮列表
function settingsDialog:initButtonList()
    self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b25", "b24", "b7"}
    
    local isGoogleAchievements = G_isSendAchievementToGoogle()
    if isGoogleAchievements > 1 and G_isLoginGoole then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b20", "b21", "b23", "b25", "b24", "b7"}
    elseif isGoogleAchievements > 1 and G_isLoginGoole == false then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b22", "b25", "b24", "b7"}
    elseif isGoogleAchievements == 1 then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b22", "b25", "b24", "b7"}
    end
    if(migrationVoApi:checkMigrateStatus() == 1)then
        table.insert(self.buttonTbList, #self.buttonTbList - 1, "b28")
    end
    if(migrationVoApi:checkMigrateStatus() == 2)then
        table.insert(self.buttonTbList, #self.buttonTbList - 1, "b29")
    end
    -- if platCfg.platSettingCfg[G_curPlatName()]~=nil then
    --     self.buttonTbList=G_clone(platCfg.platSettingCfg[G_curPlatName()])
    -- end
    
    if G_curPlatName() == "5" and G_Version < 6 then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b11", "b25", "b24", "b7"}
    end
    
    if G_curPlatName() == "45" and G_Version < 6 then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b11", "b25", "b24", "b7"}
    end
    
    if G_curPlatName() == "9" and G_Version < 2 then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b6", "b11", "b25", "b24", "b7"}
    end
    if self:isEwanAudit() == true then
        self.buttonTbList = {"b1", "b2", "b3", "b4", "b5", "b11", "b25", "b24", "b7"}
    end
    --有些不要实名认证
    -- if(G_isChina() and G_curPlatName() ~= "58" and G_curPlatName() ~= "60" and G_curPlatName() ~= "5" and G_curPlatName() ~= "androiduc" and G_curPlatName() ~= "androidwandoujia" and G_curPlatName() ~= "androidoppo2" and G_curPlatName() ~= "68" and G_curPlatName() ~= "69" and G_curPlatName() ~= "70")then
    if G_isChina() and healthyApi:isUserGuest() ~= true and self:isEwanAudit() == false then --只要是国内的都显示实名认证信息
        local length = #self.buttonTbList
        if(self.buttonTbList[length] == "b7")then
            table.insert(self.buttonTbList, length - 1, "b27")
        else
            table.insert(self.buttonTbList, "b27")
        end
    end
    
    if buildingVoApi:isYouhua() == false then
        for k, v in pairs(self.buttonTbList) do
            if v == "b24" then
                table.remove(self.buttonTbList, k)
            end
        end
    end
    
    if buildingVoApi:isYouhua() == false or base.isCodeSwitch ~= 1 then
        for k, v in pairs(self.buttonTbList) do
            if v == "b25" then
                table.remove(self.buttonTbList, k)
            end
        end
    else
        local flag = false
        for k, v in pairs(self.buttonTbList) do
            if(v == "b25")then
                flag = true
                break
            end
        end
        if(flag == false)then
            local length = #self.buttonTbList
            if(self.buttonTbList[length] == "b7")then
                table.insert(self.buttonTbList, length - 1, "b25")
            else
                table.insert(self.buttonTbList, "b25")
            end
        end
    end
    --德国不要激活码
    if(G_curPlatName() == "11" or G_curPlatName() == "androidsevenga")then
        for k, v in pairs(self.buttonTbList) do
            if(v == "b25")then
                table.remove(self.buttonTbList, k)
            end
        end
    end
    if(base.ifGmOpen == 1 and platCfg.platGM[G_curPlatName()] and G_getPlatAppID())then
        if(self.buttonTbList[#self.buttonTbList] == "b7")then
            table.insert(self.buttonTbList, #self.buttonTbList - 1, "b26")
        else
            table.insert(self.buttonTbList, "b26")
        end
    end
    
    local b7Flag = false
    for k, v in pairs(self.buttonTbList) do
        if(v == "b7")then
            b7Flag = true
            break
        end
    end
    if GM_UidCfg[playerVoApi:getUid()] then
        for k, v in pairs(self.buttonTbList) do
            if v == "b24" then
                table.remove(self.buttonTbList, k)
            end
        end
    end
    if self.buttonTab and next(self.buttonTab) then
        for k, v in pairs(self.buttonTab) do
            if v and tolua.cast(v, "CCMenu") then
                v:removeFromParentAndCleanup(true)
            end
        end
        self.buttonItems = {}
        self.buttonTab = {}
    end

    if self.clearDataLb and tolua.cast(self.clearDataLb, "CCLabelTTF") then
        self.clearDataLb:removeFromParentAndCleanup(true)
        self.clearDataLb = nil
    end

    for k, v in pairs(self.buttonTbList) do
        local btnTextSize = 25
        if G_getCurChoseLanguage() == "pt" then
            btnTextSize = 22
        end
        if v == "b27" then
            if verifyApi:isVerified() == true then
                self.buttonTb[v].name = "user_verified"
            end
        end

        local buttonItem = GetButtonItem("AlllSetUpBtn.png", "AlllSetUpBtn_Down.png", "AlllSetUpBtn_Down.png", self.buttonTb[v].callBack, k, getlocal(self.buttonTb[v].name), btnTextSize, k + 100)
        local btnLabel = buttonItem:getChildByTag(k + 100)
        btnLabel = tolua.cast(btnLabel, "CCLabelTTF")
        btnLabel:setPosition(ccp(buttonItem:getContentSize().width / 2 + 10, buttonItem:getContentSize().height / 2))

        
        local width = k % 2
        if width == 0 then
            width = 2
        end
        --buttonItem:setPosition(ccp(90+120*width,self.bgLayer:getContentSize().height-math.ceil(i/2)*120))
        local buttonMenu = CCMenu:createWithItem(buttonItem);
        buttonMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        buttonMenu:setPosition(ccp(190 + 280 * (width - 1), self.bgLayer:getContentSize().height - 100 - math.ceil(k / 2) * 120))

        if v == "b7" then
            buttonMenu:setPosition(ccp(190, self.bgLayer:getContentSize().height - 100 - math.ceil(1 / 2) * 120))
            if G_curPlatName() == "51" then --巨兽崛起迁移账号先取消绑定账号
                buttonItem:setEnabled(false)
            end
        end

        
        self.bgLayer1:addChild(buttonMenu)
        self.buttonItems[tonumber(RemoveFirstChar(v))] = buttonItem
        self.buttonTab[tonumber(RemoveFirstChar(v))] = buttonMenu
        
        local icon
        if v == "b27" and verifyApi:isVerified() == true then --已实名
            buttonItem:setEnabled(false)
            icon = GraySprite:createWithSpriteFrameName(self.buttonTb[v].icon)
        else
            icon = CCSprite:createWithSpriteFrameName(self.buttonTb[v].icon)
        end
        icon:setPosition(ccp(80 + 280 * (width - 1), self.bgLayer:getContentSize().height - 100 - math.ceil(k / 2) * 120))
        icon:setPosition(ccp(-20, buttonItem:getContentSize().height / 2))
        buttonItem:addChild(icon, 2)

        if(v == "b16")then
            buttonItem:setColor(G_ColorRed)
            local btnLabel = GetTTFLabel(getlocal("clearData"), btnTextSize)
            btnLabel:setPosition(buttonMenu:getPositionX() + 10, buttonMenu:getPositionY())
            self.bgLayer:addChild(btnLabel)
            self.clearDataLb = btnLabel
        end
    end
end

--益玩渠道审核
function settingsDialog:isEwanAudit()
    if G_curPlatName() == "androidewan" then
        return true
    end
    return false
end

--设置对话框里的tableView
function settingsDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setVisible(false)
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-120))
    
    self:initLayer()

    do
        return
    end
	
	--"修改密码","服务器列表","游戏设置",“选择语言”,"更换账号",联系我们","绑定账号"
	local labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","bindAccount"}
    local iconTab={"AccountIcon.png","ServeIcon.png","SetUpIcon.png","LanguageIcon.png","ChangeBtn.png","ContactBtn.png","AccountIcon.png"}
    if G_curPlatName()=="3" or G_curPlatName()=="efunandroidtw" then
    labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","directToBBS"}
    elseif G_curPlatName()=="4" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="47" then
    labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","facebookBtn","settingFAQ"}
    iconTab={"AccountIcon.png","ServeIcon.png","SetUpIcon.png","LanguageIcon.png","ChangeBtn.png","ContactBtn.png","AccountIcon.png","helpIcon.png"}
    elseif G_curPlatName()=="5" or G_curPlatName()=="45" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="9" or G_curPlatName()=="10" then
    labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","bindAccount","accountManagement"}
    iconTab={"AccountIcon.png","ServeIcon.png","SetUpIcon.png","LanguageIcon.png","ChangeBtn.png","ContactBtn.png","AccountIcon.png","AccountIcon.png"}
    elseif  G_curPlatName()=="16" then
    labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","bindAccount"}
    iconTab={"AccountIcon.png","ServeIcon.png","SetUpIcon.png","LanguageIcon.png","ChangeBtn.png","ContactBtn.png","AccountIcon.png"}
    elseif G_curPlatName()=="6" or G_curPlatName()=="ndcom" then
        labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","help"}
    elseif G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" then
    labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","help"}
   -- elseif G_curPlatName()=="androidwandoujia" then
   --     labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","help","optContactUs","bindAccount"}
    elseif G_curPlatName()=="androiduc" then
        labelTab={"help","serverListOpt","gameSetting","choiceLanguage","changeAccount"}
    elseif G_curPlatName()=="0" then
        labelTab={"changePassword","serverListOpt","gameSetting","choiceLanguage","changeAccount","optContactUs","bindAccount"}
        iconTab={"AccountIcon.png","ServeIcon.png","SetUpIcon.png","LanguageIcon.png","ChangeBtn.png","ContactBtn.png","AccountIcon.png"}

    end




	local function clickHandler(tag,object)
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        
		if tag==1 then
            if G_curPlatName()=="androiduc" then
            require "luascript/script/game/scene/gamedialog/helpDialog"
            local dd = helpDialog:new()
                    local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,3);
                    sceneGame:addChild(vd,4)
            else
             local td=changePasswordDialog:new()
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("changePassword"),false,self.layerNum+1)
            sceneGame:addChild(dialog,self.layerNum+1)
            end
        elseif tag==8 then
                if G_curPlatName()=="5" or G_curPlatName()=="45" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="9" or G_curPlatName()=="10"  or G_curPlatName()=="16" or G_curPlatName()=="58" then --飞流平台
                    local tmpTb={}
                    tmpTb["action"]="showCustomPanel"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["type"]=1
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" then
                    local tmpTb={}
                    tmpTb["action"]="openUrl"
                    tmpTb["parms"]={}
                    if platCfg.platCfgUrl[G_curPlatName()][G_getCurChoseLanguage()]~=nil then
                        tmpTb["parms"]["url"]=platCfg.platCfgUrl[G_curPlatName()][G_getCurChoseLanguage()]
                    end
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                end
		elseif tag==2 then
            local td=serverListDialog:new(self)
			local tbArr={getlocal("recentLogin"),getlocal("allServers")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverListOpt"),false,self.layerNum+1)
            sceneGame:addChild(dialog,self.layerNum+1)
		elseif tag==3 then
            local td=gameSettingsDialog:new()
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("gameSetting"),false,self.layerNum+1)
            sceneGame:addChild(dialog,self.layerNum+1)
		elseif tag==4 then
            local languageInfo= languageDialog:new()
            local infoBg = languageInfo:init(self.layerNum+1);
		elseif tag==5 then
            if G_loginType==1 then --第三方绑定
                 if G_curPlatName()=="0" or G_curPlatName()=="2" or G_curPlatName()=="googleplay" then
                          FBSdkHelper:exitLogin() --facebook
                          G_setTankIsguest("1")
                          base:changeServer()  
                 elseif G_curPlatName()=="1" or G_curPlatName()=="42"  then  --快用平台
                          if PlatformManage~=nil then
                                PlatformManage:shared():showLogin()
                          end
                 elseif G_curPlatName()=="qihoo" then --360平台
                          if PlatformManage~=nil then
                                base:changeServer()
                                PlatformManage:shared():switchAccount();
                          end
                 elseif G_curPlatName()=="memoriki" then --memoriki平台
                          if PlatformManage~=nil then
                                deviceHelper:luaPrint("memoriki")
                                base:changeServer()
                                PlatformManage:shared():switchAccount();
                          end
                elseif G_curPlatName()=="11" then --memoriki平台
                          if PlatformManage~=nil then
                                deviceHelper:luaPrint("sevenga ios")
                                base:changeServer()
                                PlatformManage:shared():switchAccount();
                          end
                 elseif G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" then --efun平台
                          if PlatformManage~=nil then
                                base:changeServer()
                                PlatformManage:shared():switchAccount();
                          end
                 elseif G_curPlatName()=="6" then
                        if PlatformManage~=nil then
                            base:changeServer()
                            local tmpTb={}
                            tmpTb["action"]="showCustomPanel"
                            tmpTb["parms"]={}
                            tmpTb["parms"]["type"]=2
                            local cjson=G_Json.encode(tmpTb)
                            G_accessCPlusFunction(cjson)
                            
                            local tmpTb={}
                            tmpTb["action"]="showCustomPanel"
                            tmpTb["parms"]={}
                            tmpTb["parms"]["type"]=3
                            local cjson=G_Json.encode(tmpTb)
                            G_accessCPlusFunction(cjson)
                            do
                                return
                            end
                        end
           --      elseif G_curPlatName()=="androidwandoujia" then
           --             local dd = helpDialog:new()
           --         local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,3);
         --           sceneGame:addChild(vd,4)
                 elseif G_curPlatName()=="8" then
                        PlatformManage:shared():loginOut()
                        if PlatformManage~=nil then
                            base:changeServer()
                            PlatformManage:shared():switchAccount();
                        end
                 
                 else
                          if PlatformManage~=nil then
                                base:changeServer()
                                PlatformManage:shared():switchAccount();
                          end
                 end
            else
                 G_setTankIsguest("1")
                 base:changeServer()  
                 
            end
		elseif tag==6 then
            if G_curPlatName()=="memoriki" then
                if PlatformManage~=nil then
                    PlatformManage:shared():contactUs("","","")
                end
                do
                    return
                end
            elseif G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="efunandroidmemoriki" or G_curPlatName()=="efunandroid360" or G_curPlatName()=="efunandroidnm" or G_curPlatName()=="efunandroidhuashuo"  then
                if PlatformManage~=nil then
                    PlatformManage:shared():contactUs(serverCfg.customerurl,"","")
                    do
                        return
                    end
                end
                --[[do
                    return
                end]]
            end

            local td=smallDialog:new()
            local str1 = getlocal("optContactUs")
            --getlocal("optContactUsMode")
            local str2 = platFormCfg.contactUsInfo
            if type(str2)==type(table) then
                 str2=str2[G_getCurChoseLanguage()]
            end
            local tabStr = {str2,str1}


            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
            --dialog:setPosition(getCenterPoint(sceneGame))
            sceneGame:addChild(dialog,self.layerNum+1)
            
        elseif tag==7 then
            
            if G_curPlatName()=="3" or G_curPlatName()=="efunandroidtw" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" or G_curPlatName()=="efunandroidhuashuo" then
                    local tmpTb={}
                    tmpTb["action"]="openUrl"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["url"]=serverCfg.bbsurl
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    do
                        return
                    end
            elseif G_curPlatName()=="5" or G_curPlatName()=="45" or G_curPlatName()=="9" or G_curPlatName()=="10" or G_curPlatName()=="58" then
                    local tmpTb={}
                    tmpTb["action"]="showCustomPanel"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["type"]=1
                    local cjson=G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    do
                        return
                    end
            elseif G_curPlatName()=="6" or G_curPlatName()=="ndcom" or G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" then
                require "luascript/script/game/scene/gamedialog/helpDialog"
                local dd = helpDialog:new()
                    local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,self.layerNum+1);
                    sceneGame:addChild(vd,self.layerNum+1)

            end
            
            if G_loginType==2 then --绑定邮箱方式登录
                    local td=bindingAccountDialog:new()
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("bindAccount"),false,self.layerNum+1)
                    sceneGame:addChild(dialog,self.layerNum+1)
            elseif G_loginType==1 then --第三方平台方式登录
                  
                  local function bindCbackHandler(fn,fbid)
                        G_cancleLoginLoading()
                        if fbid~="" then --账号绑定成功
                                    ------以下调用http绑定账号
                                    G_bindUserACCount(fbid)
                                    ------以上调用http获取uid和token
                        end
                  end
                  if G_loginType==1 then --第三方账号
                         if G_curPlatName()=="0" or G_curPlatName()=="2" or G_curPlatName()=="googleplay" then
                            G_showLoginLoading(10)
                            local fbid=FBSdkHelper:bindAccout(bindCbackHandler) --facebook账号
                         elseif G_curPlatName()=="1" or G_curPlatName()=="42"  then  --快用平台
                            if PlatformManage~=nil then
                                PlatformManage:shared():showLogin()
                            end 
                         elseif G_curPlatName()=="memoriki" or G_curPlatName()=="efunandroidmemoriki" then
                             if PlatformManage~=nil then
                                local function bindResultHandler()
                                          local function bindCallBack(fn,sdata)
                                                 base:checkServerData(sdata) 
                                                 global.accountIsBind=true
                                                 smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("congratulation")..getlocal("bindSuccess"),nil,5)
                                                            end
                                          socketHelper:bindingAccount(bindCallBack)
                                end
                                PlatformManage:shared():bindAccount(bindResultHandler,"","","")
                            end 
                         end
                  end

            end
			
		end
        PlayEffect(audioCfg.mouseClick)
	end
	
	local labelNum=SizeOfTable(labelTab)
    local minY
	for i=1,labelNum do
		local buttonItem
		--是否是游客登录，没有绑定账号

    local btnTextSize = 25
    if G_getCurChoseLanguage()=="pt" then
        btnTextSize = 22
    end
    buttonItem=GetButtonItem("AlllSetUpBtn.png","AlllSetUpBtn_Down.png","AlllSetUpBtn_Down.png",clickHandler,i,getlocal(labelTab[i]),btnTextSize,i+100)

        self.buttonItems[i]=buttonItem
		local btnLabel=buttonItem:getChildByTag(i+100)
		btnLabel=tolua.cast(btnLabel,"CCLabelTTF")
		btnLabel:setPosition(ccp(buttonItem:getContentSize().width/2+10,buttonItem:getContentSize().height/2))

	    local buttonMenu=CCMenu:createWithItem(buttonItem);
		local width=210+(i+1)%2*275
		local height=self.bgLayer:getContentSize().height-170*math.ceil(i/2)-40
        minY=height
		if i==7 then
			height=self.bgLayer:getContentSize().height-170*math.ceil(1/2)-40
		end
        
        if G_curPlatName()=="5" or G_curPlatName()=="45" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="9" or G_curPlatName()=="10" or G_curPlatName()=="16" or  G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" or G_curPlatName()=="58" then --飞流平台/Efun
            if i==8 then
                width=210+(7+1)%2*275
            end
        end

	    buttonMenu:setPosition(ccp(width,height))
	    buttonMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	    self.bgLayer:addChild(buttonMenu,1)
		table.insert(self.buttonTab,buttonMenu)

		local icon=CCSprite:createWithSpriteFrameName(iconTab[i])
		icon:setPosition(ccp(width-buttonItem:getContentSize().width/2-20,height))
        self.bgLayer:addChild(icon,2)
	end

    local uidLb=GetTTFLabelWrap(getlocal("uidIs",{playerVoApi:getUid()}),28,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    uidLb:setPosition(ccp(G_VisibleSizeWidth/2,minY/2))
    self.bgLayer:addChild(uidLb,2)


    

	self:tick()
end
function settingsDialog:tick()
	--是否是游客登录，没有绑定账号
  -- if G_isNeedLoginGooleF5==true then
  --     self:refresh()
  --     G_isNeedLoginGooleF5=false
  -- end
  if self:isClosed() == true then
    do return end
  end
  if self.buttonTab == nil then
    do return end
  end
    if self.onlineTimeLb and tolua.cast(self.onlineTimeLb,"CCLabelTTF") then
        local olts = playerVoApi:getDailyOnlineTime()
        self.onlineTimeLb:setString(getlocal("user_online_time",{GetTimeStr(olts)}))
    end

	if G_getTankIsguest()=="1" then
		if self.buttonTab[1]~=nil and self.buttonTab[1]:isVisible()==true then
			self.buttonTab[1]:setVisible(false)
		end
		if self.buttonTab[7]~=nil and self.buttonTab[7]:isVisible()==false then
			self.buttonTab[7]:setVisible(true)
		end
	else
		if self.buttonTab[1]~=nil and self.buttonTab[1]:isVisible()==false then
			self.buttonTab[1]:setVisible(true)
		end
		if self.buttonTab[7]~=nil and self.buttonTab[7]:isVisible()==true then
			self.buttonTab[7]:setVisible(false)
		end
        if G_loginType==1 then --第三方账号登陆
                if self.buttonTab[1]~=nil then
                    self.buttonTab[1]:setVisible(false)
                end
                if self.buttonTab[7]~=nil then
                    self.buttonTab[7]:setVisible(true)
                end
                if G_curPlatName()~="androidrgame" then
                    if self.buttonItems[7]~=nil then
                        self.buttonItems[7]:setEnabled(false)
                    end
                end
        elseif G_loginType==2 and base.loginAccountType==0 then
                 if self.buttonItems[1]~=nil then
                        self.buttonItems[1]:setEnabled(false)
                        do
                            return
                        end
                 end
        end
        if G_curPlatName()=="3" or G_curPlatName()=="efunandroidtw" or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" or G_curPlatName()=="androidsevenga" or G_curPlatName()=="11" then
            if self.buttonTab[1]~=nil then
                self.buttonTab[1]:setVisible(false)
            end
            if self.buttonTab[7]~=nil then
                self.buttonTab[7]:setVisible(true)
                self.buttonItems[7]:setEnabled(true)
            end
        end
	end

    if G_curPlatName()=="androiduc" then  --uc 隐藏联系我们
            if self.buttonTab[1]~=nil then
                self.buttonTab[1]:setVisible(true)
                self.buttonItems[1]:setEnabled(true)
            end
    end
    
    if self and self.timeLb and G_isGlobalServer()==true then
        self.timeLb:setString(getlocal("server_time",{G_formatDate(base.serverTime)}))
    end
    if G_isBindMailAndResetPwd()==true then
        if self.buttonTab[1]~=nil then
            -- self.buttonTab[1]:setVisible(false)
            self.buttonItems[1]:setEnabled(false)
        end
        -- if self.buttonTab[7]~=nil then
        --     -- self.buttonTab[7]:setVisible(false)
        --     self.buttonItems[7]:setEnabled(false)
        -- end
    end
end
--G_isNeedLoginGooleF5
function settingsDialog:refresh()
  self.bgLayer1:removeFromParentAndCleanup(true)
  self.buttonTab={}
  self.buttonItems={}
  self:initLayer()
end

--显示helpshift客服系统
function settingsDialog:showHelpfish()
  deviceHelper:luaPrint("showhelpshift")
  local tmpTb={}
  tmpTb["action"]="customAction"
  tmpTb["parms"]={}
  tmpTb["parms"]["value"]="helpshift"
  tmpTb["parms"]["roleId"]=tostring(playerVoApi:getUid())
  tmpTb["parms"]["roleName"]=tostring(playerVoApi:getPlayerName())
  tmpTb["parms"]["level"]=tostring(playerVoApi:getPlayerLevel())
  tmpTb["parms"]["zoneId"]=tostring(base.curOldZoneID)
  local cjson=G_Json.encode(tmpTb)
  G_accessCPlusFunction(cjson)
end

--显示智齿客服系统
function settingsDialog:showZhichi()
    deviceHelper:luaPrint("showZhichi")
    local tmpTb={}
    tmpTb["action"]="startZhiChiCustomerService"
    tmpTb["parms"]={}
    tmpTb["parms"]["userId"]=tostring(playerVoApi:getUid())
    tmpTb["parms"]["nickName"]=tostring(playerVoApi:getPlayerName())
    local cjson=G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

function settingsDialog:dispose()
    local tmpTb={}
    tmpTb["action"]="settingWindowClose"
    tmpTb["parms"]={}
    local cjson=G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
	self.buttonTab=nil
    self.buttonItems=nil
    self.timeLb=nil
    self.clearDataLb=nil
    G_isNeedLoginGooleF5=nil
    self=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/addImageSetting.plist")
    if G_isSendAchievementToGoogle()>1 then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("arImage/googleSettingImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/googleSettingImage.pvr.ccz")
    end
end
