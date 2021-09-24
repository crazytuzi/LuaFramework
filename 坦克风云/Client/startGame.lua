
--下载的文件解密luaL_loadfile
function __G__TRACKBACK__(msg)
    deviceHelper:luaPrint("---__G__TRACKBACK__ start-------------------------------------")
    deviceHelper:luaPrint("LUA ERROR: " .. tostring(msg) .. "\n")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    deviceHelper:luaPrint(debug.traceback())
    --smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),"前台错误:","前台错误:"..tostring(msg).."\n"..debug.traceback(),nil,10)
    deviceHelper:luaPrint("----__G__TRACKBACK__ end ------------------------------------")
     --只有测试服才弹出错误面板
     

     require "luascript/script/componet/smallDialog2"

    if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest")==1 or PlatformManage:shared():getPlatformType()=="0" then
            smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),"错误","LUA ERROR: " .. tostring(msg) .. "\n"..debug.traceback(),true,100)
     end
    if statisticsHelper~=nil then
        statisticsHelper:clientErr(tostring(msg)..debug.traceback())
    end

end

function tracebackkkk()
    print("tracebackkkk start!!!!")
    print(debug.traceback())
    print("tracebackkkk end!!!!")
end



local function  main()

 print("开始加载lua")
      -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    local startTime=os.clock()
    print("==========",startTime)
  -- local bgSprite = CCSprite:create("scene/lodingxin.jpg")
  -- bgSprite:setPosition(ccp(CCDirector:sharedDirector():getVisibleSize().width/2,CCDirector:sharedDirector():getVisibleSize().height/2))
  -- CCDirector:sharedDirector():getRunningScene():addChild(bgSprite, 9)

  -- local bmLabel=CCLabelTTF:create("loading...","Helvetica",30)
  -- bmLabel:setAnchorPoint(CCPointMake(0.5,0.5))
  -- bmLabel:setPosition(ccp(320,110))
  -- CCDirector:sharedDirector():getRunningScene():addChild(bmLabel, 12)
    
  -- local psSprite1 = CCSprite:create("scene/normalBar.png")
  -- gtimerSprite = CCProgressTimer:create(psSprite1);
  -- gtimerSprite:setMidpoint(ccp(0,1));
  -- gtimerSprite:setBarChangeRate(ccp(1, 0));
  -- gtimerSprite:setType(kCCProgressTimerTypeBar);
  -- gtimerSprite:setPosition(ccp(320,150));

  -- CCDirector:sharedDirector():getRunningScene():addChild(gtimerSprite, 12);
  -- gtimerSprite:setPercentage(0);    --设置初始百分比的值
          
  -- local loadingBk = CCSprite:create("scene/normalBarBg.png")
  -- loadingBk:setPosition(ccp(320,150));
  -- local sce = CCDirector:sharedDirector():getRunningScene()
  -- sce:addChild(loadingBk,10);

  -- g_tickID=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tmptick,0.1, false)
  -- g_index=0

  require "luascript/script/game/base"
  require "luascript/script/config/platconfig/platCfg"
  require "luascript/script/shader/CCShader"
  require "luascript/script/global/global"
  require "luascript/script/global/global2"
  require "luascript/script/global/global3"
  require "luascript/script/global/serverMgr"
  require "luascript/script/config/platconfig/GM_UidCfg"

  --  local function callback()
        require "luascript/script/componet/commonDialog"
        require "luascript/script/componet/smallDialog"
        require "luascript/script/config/language/languageManager"
        if PlatformManage~=nil then--判断不同的平台 加载不同的loginScene-----0:appstore "1":快用 "qihoo":360平台 "2":yeahmobi "googleplay":googleplay

            if platCfg.platCfgLoginScene[G_curPlatName()]~=nil then
              require ("luascript/script/game/scene/scene/platformScene/"..platCfg.platCfgLoginScene[G_curPlatName()])
            else
              require "luascript/script/game/scene/scene/loginScene"
            end
        
        else
            require "luascript/script/game/scene/scene/loginScene"
        end
        require "luascript/script/config/gameconfig/localCfg"
        require "luascript/script/config/gameconfig/keyWordCfg"

        require "luascript/script/config/gameconfig/audioCfg"
        require "luascript/script/config/serverconfig/serverCfg"

        require "luascript/script/componet/popDialog"
        require "luascript/script/componet/customEditBox"
        require "luascript/script/componet/tipDialog"
        require "luascript/script/componet/eventDispatcher"
        require "luascript/script/componet/spriteController"
        require "luascript/script/netapi/json"
        require "luascript/script/mainloading/mainloading"
        require "luascript/script/netapi/socketHelper"
        require "luascript/script/netapi/url"
        require "luascript/script/game/scene/scene/sceneController"
        require "luascript/script/game/gamemodel/push/pushController"
        require "luascript/script/componet/richLabel"

        require "luascript/script/netapi/statisticsHelper"
        require "luascript/script/config/gameconfig/platFormCfg"
        require "luascript/script/game/scene/gamedialog/banSmallDialog"
        require "luascript/script/game/gamemodel/player/playerVoApi"
        require "luascript/script/game/gamemodel/player/userAccountCenterVoApi"

        print("endend=",os.clock())
        print("加载资源")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        --以下是平台特殊需求的一些图片，必须放在后面所有加载图片的最前面
        --以下是平台特殊需求的一些图片，必须放在后面所有加载图片的最前面
        --以下是平台特殊需求的一些图片，必须放在后面所有加载图片的最前面
        --以下是平台特殊需求的一些图片，必须放在后面所有加载图片的最前面
        if(platCfg.platSpecialImage[G_curPlatName()])then
            for k,v in pairs(platCfg.platSpecialImage[G_curPlatName()]) do
                CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(v)
            end
        end
        if G_checkUseAuditUI()==true then
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iostishenUI.plist")
          -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/building_iostishen.plist")
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        end
        if G_isApplyVersion()==true and G_curPlatName()=="androidewantest" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/ewanTestVip.plist")
        end
        --以下是平台特殊需求的一些图片，必须放在后面所有加载图片的最前面
        --昆仑的特殊需求图片
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("kunlunImage/kunlunImage.plist")
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("kunlunImage/kunlunIcon.plist")
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("kunlunImage/vip10.plist")
        end
        --澳大利亚版本特殊图片
        if G_curPlatName()=="android360ausgoogle" then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("auImage/auImage.plist")
        end
        if platCfg.platNewGuideNMChose[G_curPlatName()]~=nil then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("nmImage/photoImage.plist")
        end
        if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("koImage/koImage.plist")
        end
        if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/Hero_Icon_Cartoon/virtualHeroImage.plist")
        end
        --平台end

          --昆仑的特殊需求图片
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("kunlunImage/UsaBtn.plist")
        end
        --东南亚不要中国国旗
        if G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/ChinaBtn.plist")
        end
        if G_curPlatName()=="32" or G_curPlatName()=="androidklfy" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("kunlunImage/franceImage.plist")
        end
          --平台end
        -- ---------------不需要压缩的资源，必现放在前面-----start----------------
        if platCfg.platCfgUseCompressRes and platCfg.platCfgUseCompressRes[G_curPlatName()] then
          local flag=false
          if(type(platCfg.platCfgUseCompressRes[G_curPlatName()])=="number" and G_Version>=platCfg.platCfgUseCompressRes[G_curPlatName()])then
            flag=true
          elseif(type(platCfg.platCfgUseCompressRes[G_curPlatName()])=="table" and G_Version>=platCfg.platCfgUseCompressRes[G_curPlatName()][1] and G_Version<=platCfg.platCfgUseCompressRes[G_curPlatName()][2])then
            flag=true
          end
          if(flag==true)then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressBg.plist")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressCommon1.plist")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressCommon2.plist")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressPropIcon.plist")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressSkillIcon.plist")
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("noCompressRes/noCompressTankIcon.plist")
          end
        end
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/allTankIcon.plist")
        -- ---------------不需要压缩的资源，必现放在前面-----end----------------


        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(G_BoardUIImage)
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(G_BoardExpendUI)
        spriteController:addPlist("scene/preloadedPic.plist")
        spriteController:addTexture("scene/preloadedPic.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(G_MainUIImage)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/startGameUI.plist")
        spriteController:addPlist("public/gameLogin.plist")
        spriteController:addTexture("public/gameLogin.png")
        spriteController:addPlist("scene/loadingEffect.plist")
        spriteController:addTexture("scene/loadingEffect.png")
        spriteController:addPlist("public/startGameUI.plist")
        spriteController:addTexture("public/startGameUI.png")
        spriteController:addPlist("public/startGameUI2.plist")
        spriteController:addTexture("public/startGameUI2.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

        local endTime=os.clock()
        print("endend=",endTime)
        print("加载资源")
        -- require "arImage/testlua"
          if PlatformManage~=nil then
              if platCfg.platCfgGameLogoSingleFile[G_curPlatName()]==nil then
                  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(G_LogoImage)
              end
          end
            deviceHelper:luaPrint("加载完lua")
          print("endend=",os.clock())
                             local tmpTb={}
                        tmpTb["action"]="recordUserStep"
                        tmpTb["parms"]={}
                        tmpTb["parms"]["step"]="5"
                        tmpTb["parms"]["create_time"]=""
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
             

          local tmpTbGetChannel={}
          tmpTbGetChannel["action"]="getChannel"
          local cjsonGetChannel=G_Json.encode(tmpTbGetChannel)
          local thechannelid = G_accessCPlusFunction(cjsonGetChannel)
          local theplatformname =  G_curPlatName()
          if thechannelid ~="" and thechannelid ~=nil then
              if platCfg.platCfgGameLogoSingleFile~=nil then
                  if platCfg.platCfgGameLogoSingleFile[theplatformname.."_"..thechannelid]~=nil then
                      platCfg.platCfgGameLogoSingleFile[theplatformname] =  platCfg.platCfgGameLogoSingleFile[theplatformname.."_"..thechannelid]
                  end
              else
                  if platCfg.platCfgGameLogo[theplatformname.."_"..thechannelid]~=nil then
                      platCfg.platCfgGameLogo[theplatformname] =  platCfg.platCfgGameLogo[theplatformname.."_"..thechannelid]
                  end
              end
          end
          CCShader:loadShaderCache()

          local tmpTb={}
          tmpTb["action"]="luaLoadFinish"
          tmpTb["parms"]={}
          local cjson=G_Json.encode(tmpTb)
          G_accessCPlusFunction(cjson)

           math.randomseed(os.time())
           for i=1,50 do
               math.random()
           end
          G_initAllServer()
          loginScene:showLoginScene()
          loginScene:initTick()
          -- require("/Users/caijinlong/Desktop/CScene"):show()



    -- end

    -- local callFunc=CCCallFunc:create(callback)
    -- local delay=CCDelayTime:create(0.1)
    -- local acArr=CCArray:create()
    -- acArr:addObject(delay)
    -- acArr:addObject(callFunc)
    -- local seq=CCSequence:create(acArr)
    -- CCDirector:sharedDirector():getRunningScene():runAction(seq)

    --下面这句测试代码用于生成激活码礼包
    -- require "luascript/script/config/gameconfig/propCfg"
    -- require "luascript/script/config/gameconfig/tankCfg"
    -- G_getPropStr({{3370,3376}},{"登录豪华礼包","5级豪华礼包","10级豪华礼包","15级豪华礼包","20级豪华礼包","25级豪华礼包","30级豪华礼包"})
    --激活码礼包end
    --下面这段代码用于检测propCfg里面的哪些道具的名字和描述在cn里面没有
    -- print("gogoStart!")
    -- require ("luascript/script/config/language/cn")
    -- require ("luascript/script/config/language/cn2")
    -- require ("luascript/script/config/language/cn3")
    -- for propID,prop in pairs(propCfg) do
    --   local nameKey=prop.name
    --   if(wzCfg["cn"][nameKey]==nil and wzCfg["cn2"][nameKey]==nil and wzCfg["cn3"][nameKey]==nil)then
    --     print("propID,name",propID,nameKey)
    --   end
    --   local descKey=prop.description
    --   if(wzCfg["cn"][descKey]==nil and wzCfg["cn2"][descKey]==nil and wzCfg["cn3"][descKey]==nil)then
    --     print("propID,desc",propID,descKey)
    --   end
    -- end
    -- print("compare end")
    --检测代码end

  end
  
xpcall(main, __G__TRACKBACK__) 