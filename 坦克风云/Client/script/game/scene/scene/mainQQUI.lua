require "luascript/script/game/scene/scene/sceneController"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarOverviewDialog"




mainUI={


    myUILayer,
    mySpriteMain,
    mySpriteLeft,
    mySpriteRight,
    mySpriteDown,
    mySpriteWorld,
    m_labelMoney,
    m_labelGold,
    m_labelR1,
    m_labelR2,
    m_labelR3,
    m_labelR4,
    m_labelLevel,
    m_menuToggle,
    m_menuToggleSmall,
    tv,
    m_luaSpTab,
    m_luaLayer,
    m_luaSp1,
    m_luaSp2,
    m_luaSp3,
    m_luaSp4,
    m_luaSp5,
    m_luaSp6,
    m_luaSp7,
    m_luaSpBuff,
  m_luaSpBuffSp1,
 m_luaSpBuffSp2,
 m_luaSpBuffSp3,
    m_skillHeigh,
    m_dis,
    m_luaTime,
    m_pointLuaSp,
    m_pointVip,
    m_menuToggleVip,
	m_vipLevel,
    m_iconScaleX,
    m_iconScaleY,
    m_dailySp,
    m_taskSp,
	m_enemyComingSp,
	m_countdownLabel,
	m_travelSp,
	m_travelTimeLabel,
	m_travelType,
	m_newsIconTab,
	m_newsNumTab,
    m_lastSearchXValue=0,
    m_lastSearchYValue=0,
	m_chatBg,
	m_chatBtn,
	m_labelLastType,
	m_labelLastMsg,
	m_labelLastName,
	m_bookmak,
    m_labelX,
    m_labelY,
	m_flagTab,
    needRefreshPlayerInfo=false,
    m_rankMainUI=nil,
	m_rechargeBtn,
	m_showWelcome=true,
	m_newGiftsSp,
	m_dailyRewardSp,
    m_acAndNoteSp, -- 活动和新闻图标
    dialog_acAndNote, -- 活动和公告的弹出面板
	m_leftIconTab={},
  m_rightTopIconTab = {},
	m_isNewGuide=nil,
	m_isShowDaily=nil,
	m_newYearIcon=nil,
    m_noticeIcon=nil,
    m_helpDefendIcon=nil,
    m_helpDefendLabel=nil,
    m_signIcon=nil,
    m_functionBtnTb=nil,
    fbInviteBtnHasShow=false,
    onlinePackageBtn = nil,
    nameLb,
    isShowNextDay=false,
    mainUIBTNTb={},
    btnList={},
    btnTipsList={},
    isShowEvaluate=false,
}

function mainUI:initButton()

    print("mainQQUI")
   --b1:关卡，b2:部队，b3:配件，b4:商店，b5:背包，b6:邮件，b7:排行榜，b8:兑换，b9:帮助，b10:官网,b11:设置
   local function callback1()
        storyScene:setShow()
        if newGuidMgr:isNewGuiding() then --新手引导
            newGuidMgr:toNextStep()
        end
        local menuItem=self.m_functionBtnTb["b1"]
        if(menuItem~=nil)then
            G_removeFlicker(menuItem)
        end
   end
   local function callback2()
       require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
       local td=tankDefenseDialog:new(3)
       local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
       local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,3)
       sceneGame:addChild(dialog,3)
   end
   local function callback3()
       if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
        else
            local menuItem=self.m_functionBtnTb["b3"]
            if(menuItem~=nil)then
                G_removeFlicker(menuItem)
            end
            accessoryVoApi:showAccessoryDialog(sceneGame,3)
        end
   end
    local function callback4()
        local td=shopVoApi:showPropDialog(3,true)
        td:tabClick(1,false)
   end
   local function callback5()
        local td=shopVoApi:showPropDialog(3,true)
   end
    local function callback6()
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialog"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab1"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab2"
        require "luascript/script/game/scene/gamedialog/emailDialog/emailDialogTab3"
       local td=emailDialog:new()
       local tbArr={getlocal("email_email"),getlocal("email_report"),getlocal("email_send")}
       local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("email_title"),true,3)
       sceneGame:addChild(dialog,3)
   end
   local function callback7()
       rankVoApi:clear()
       require "luascript/script/game/scene/gamedialog/rankDialog"
       local td=rankDialog:new()
       local tbArr={getlocal("RankScene_power"),getlocal("RankScene_star"),getlocal("RankScene_honor")}
       local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("rank"),false,3)
       sceneGame:addChild(dialog,3)
   end
   local function callback8()
       smallDialog:showCodeRewardDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,3)
   end
   local function callback9()
        if platCfg.platCfgHelpConnection[G_curPlatName()]~=nil and platCfg.platCfgHelpConnection[G_curPlatName()][G_getCurChoseLanguage()]~=nil then
            local url=platCfg.platCfgHelpConnection[G_curPlatName()][G_getCurChoseLanguage()]
            local tmpTb={}
            tmpTb["action"]="openUrlInAppWithClose"
            tmpTb["parms"]={}
            tmpTb["parms"]["connect"]=tostring(url)
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        else
            require "luascript/script/game/scene/gamedialog/helpDialog"
            local dd = helpDialog:new()
            local vd = dd:init("panelBg.png", true, CCSizeMake(760,800), CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("help_title"),false,3);
            sceneGame:addChild(vd,3)
        
        end
   end
   local function callback10()
       local tmpTb={}
       tmpTb["action"]="openUrl"
       tmpTb["parms"]={}
       tmpTb["parms"]["url"]=serverCfg.officialUrl
       local cjson=G_Json.encode(tmpTb)
       G_accessCPlusFunction(cjson)
   end
   local function callback11()
       require "luascript/script/game/scene/gamedialog/settingsDialog/settingsDialog"
       local td=settingsDialog:new()
       local tbArr={}
       local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("options"),true,3)
       sceneGame:addChild(dialog,3)
   end
   local function callback12()
      if base.isAllianceWarSwitch==0 then --军团战开关
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4012"),30)
          do return end
      end
      local selfAlliance=allianceVoApi:getSelfAlliance()
      if(selfAlliance==nil or selfAlliance.aid<=0)then
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_errorNeedAlliance"),30)
      else
          local td=allianceWarOverviewDialog:new(3)
          local tbArr={}
          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),false,3)
          sceneGame:addChild(dialog,3)
      end
   end


   self.mainUIBTNTb={b1={bName1="mainBtnCheckpoint.png",bName2="mainBtnCheckpoint_Down.png",btnLb="mainCheckPoint",callback=callback1,tag=0,sortId=1},
    b2={bName1="mainBtnTeam.png",bName2="mainBtnTeam_Down.png",btnLb="mainFleet",callback=callback2,tag=1,sortId=3},
    b3={bName1="mainBtnAccessory.png",bName2="mainBtnAccessory_Down.png",btnLb="accessory",callback=callback3,tag=2,sortId=4},
    b4={bName1="mainBtnItems.png",bName2="mainBtnItems_Down.png",btnLb="market",callback=callback4,tag=3,sortId=5},
    b5={bName1="mainBtnBag.png",bName2="mainBtnBag_Down.png",btnLb="bundle",callback=callback5,tag=4,sortId=6},
    b6={bName1="mainBtnMail.png",bName2="mainBtnMail_Down.png",btnLb="mainMail",callback=callback6,tag=5,sortId=7},
    b7={bName1="mainBtnRank.png",bName2="mainBtnRank_Down.png",btnLb="mainRank",callback=callback7,tag=6,sortId=8},
    b8={bName1="mainBtnGift.png",bName2="mainBtnGiftDown.png",btnLb="code_gift",callback=callback8,tag=7,sortId=9},
    b9={bName1="mainBtnHelp.png",bName2="mainBtnHelp_Down.png",btnLb="help",callback=callback9,tag=8,sortId=10},
    b10={bName1="mainBtnWebsite.png",bName2="mainBtnWebsite_Down.png",btnLb="officialWeb",callback=callback10,tag=9,sortId=11},
    b11={bName1="mainBtnSet.png",bName2="mainBtnSet_Down.png",btnLb="mainOpt",callback=callback11,tag=10,sortId=12},
    b12={bName1="mainBtnFireware.png",bName2="mainBtnFireware_Down.png",btnLb="alliance_war",callback=callback12,tag=10,sortId=2}
    }

    self.btnList={"b1","b2","b3","b4","b5","b6","b7","b8","b9","b11","b12"} --要显示的按钮
    if platCfg.platCfgMainUIButton[G_curPlatName()]~=nil then
        self.btnList=platCfg.platCfgMainUIButton[G_curPlatName()]
    end

    if base.isCodeSwitch==0 then --兑换开关
        for k,v in pairs(self.btnList) do
            if v=="b8" then
                table.remove(self.btnList,k)
            end
        end
    end
    if base.ifAccessoryOpen==0 then --配件开关
        for k,v in pairs(self.btnList) do
            if v=="b3" then
                table.remove(self.btnList,k)
            end
        end
    end
    if base.isAllianceWarSwitch==0 then --军团战开关
       for k,v in pairs(self.btnList) do
            if v=="b12" then
                table.remove(self.btnList,k)
            end
        end
    end
    self.btnTipsList={"b2","b3","b6"} --需要刷新tip的按钮
    table.sort(self.btnList,function(a,b) return tonumber(self.mainUIBTNTb[a].sortId)<tonumber(self.mainUIBTNTb[b].sortId) end) --排序

end


function mainUI:showUI()
    self:initButton()
    if G_curPlatName()=="6" or G_curPlatName()=="7" or G_curPlatName()=="8" or G_curPlatName()=="23" or G_curPlatName()=="26" or G_curPlatName()=="22" then
        local tmpTb={}
        tmpTb["action"]="flmobClick"
        local cjson=G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end

    local function touch(object,name,tag)
        if self.m_menuToggle:getSelectedIndex()==2 then
            do
                return
            end
        end
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
        if tag==1 then

        elseif tag==2 then

        end

    end


--世界地图UI
    self.myUILayer=CCLayer:create()
    sceneGame:addChild(self.myUILayer,2);
	local heightPos=5
    -- 世界地图上面信息条背景
    local function pbUIhandler()
    end
    self.mySpriteWorld =LuaCCSprite:createWithSpriteFrameName("worldBgTop.png",pbUIhandler)
    self.mySpriteWorld:setAnchorPoint(ccp(0,0.5));
    self.mySpriteWorld:setPosition(0,G_VisibleSizeHeight+300);
    self.myUILayer:addChild(self.mySpriteWorld,13);
    
    self.mySpriteWorld:setTouchPriority(-21)
    local function dwHandler() --定位
        PlayEffect(audioCfg.mouseClick)
        worldScene:focus(playerVoApi:getMapX(),playerVoApi:getMapY())
    end
    -- 定位图标
    local dwSprite=GetButtonItem("worldBtnPosition.png","worldBtnPosition_Down.png","worldBtnPosition_Down.png",dwHandler,nil,nil,nil)
    dwSprite:setAnchorPoint(ccp(0,1))
    local dwSpriteMenu=CCMenu:createWithItem(dwSprite);
    dwSpriteMenu:setPosition(ccp(0,self.mySpriteWorld:getContentSize().height-15+heightPos))
    dwSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(dwSpriteMenu)
    
    -- 定位文字
    local dwLabel=GetTTFLabel(getlocal("world_scene_location"),18);
    dwLabel:setAnchorPoint(ccp(0.5,0.5))
    dwLabel:setPosition(dwSprite:getContentSize().width/2-2,heightPos)
    dwSprite:addChild(dwLabel)
    local function scHandler() --收藏
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        require "luascript/script/game/scene/gamedialog/bookmarkDialog"
		local layerNum=3
        local td=bookmarkDialog:new()
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("collect_border_title"),false,layerNum)
        sceneGame:addChild(dialog,layerNum)
        PlayEffect(audioCfg.mouseClick)
	end
    
    local scSprite=GetButtonItem("worldBtnCollection.png","worldBtnCollection_Down.png","worldBtnPosition_Down.png",scHandler,nil,nil,nil)
    scSprite:setAnchorPoint(ccp(0,1))
    local scSpriteMenu=CCMenu:createWithItem(scSprite);
    scSpriteMenu:setPosition(ccp(100,self.mySpriteWorld:getContentSize().height-15+heightPos))
    scSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(scSpriteMenu)
    
    local scLabel=GetTTFLabel(getlocal("world_scene_collect"),18)
    scLabel:setAnchorPoint(ccp(0.5,0.5))
    scLabel:setPosition(scSprite:getContentSize().width/2-2,heightPos)
    scSprite:addChild(scLabel)
    
    local function xxHandler() --信息
        PlayEffect(audioCfg.mouseClick)
        worldScene:setShowInfo()
    end
    
    local xxSprite=GetButtonItem("worldBtnInfor.png","worldBtnInfor_Down.png","worldBtnPosition_Down.png",xxHandler,nil,nil,nil)
    xxSprite:setAnchorPoint(ccp(0,1))
    local xxSpriteMenu=CCMenu:createWithItem(xxSprite);
    xxSpriteMenu:setPosition(ccp(200,self.mySpriteWorld:getContentSize().height-15+heightPos))
    xxSpriteMenu:setTouchPriority(-22);
    self.mySpriteWorld:addChild(xxSpriteMenu)
    
    local xxLabel=GetTTFLabel(getlocal("world_scene_info"),18)
    xxLabel:setAnchorPoint(ccp(0.5,0.5))
    xxLabel:setPosition(xxSprite:getContentSize().width/2-2,heightPos)
    xxSprite:addChild(xxLabel)
    
    local function syClick()
    end

    local xLabel=GetTTFLabel("X",30)
    xLabel:setAnchorPoint(ccp(0,0))
    xLabel:setPosition(305,45)
    self.mySpriteWorld:addChild(xLabel)
    local function tthandler()
    
    end
    local function callBackXHandler(fn,eB,str,type)
         
         if type==1 then  --检测文本内容变化
                 if str=="" then
                     self.m_lastSearchXValue=playerVoApi:getMapX()
                     self.m_labelX:setString(self.m_lastSearchXValue)
                     do
                        return
                     end
                 end
                 if tonumber(str)==nil then
                      eB:setText(self.m_lastSearchXValue)
                 else
                     if tonumber(str)>=1 and tonumber(str)<=600 then
                         self.m_lastSearchXValue=tonumber(str)
                     else
                          if tonumber(str)<1 then
                              eB:setText(1)
                              self.m_lastSearchXValue=1
                          end
                          if tonumber(str)>600 then
                              eB:setText(600)
                              self.m_lastSearchXValue=600
                          end
                          
                     end
                 end
                 self.m_labelX:setString(self.m_lastSearchXValue)
         elseif type==2 then --检测文本输入结束
                 eB:setVisible(false)
         end
    end
    self.m_labelX=GetTTFLabel("",25)
    self.m_labelX:setPosition(ccp(373,65))
    self.mySpriteWorld:addChild(self.m_labelX,2)
    self.m_labelX:setString(playerVoApi:getMapX())
    self.m_lastSearchXValue=playerVoApi:getMapX()
    
    local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    local editXBox
    if G_isIOS()==true then
        editXBox=CCEditBox:createForLua(CCSize(90,50),xBox,nil,nil,callBackXHandler)
    else
        editXBox=CCEditBox:createForLua(CCSize(130,80),xBox,nil,nil,callBackXHandler)
    end
    
    editXBox:setPosition(ccp(373,65))
    if G_isIOS()==true then
        editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    editXBox:setVisible(false)
    self.mySpriteWorld:addChild(editXBox,3)
    
    local function tthandler2()
        PlayEffect(audioCfg.mouseClick)
        editXBox:setVisible(true)
    end
    local xBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler2)
    xBoxBg:setPosition(ccp(363,65))
    xBoxBg:setContentSize(CCSize(80,40))
    xBoxBg:setTouchPriority(-22)
    xBoxBg:setOpacity(0)
    self.mySpriteWorld:addChild(xBoxBg)
    

    local yLabel=GetTTFLabel("Y",30)
    yLabel:setAnchorPoint(ccp(0,0))
    yLabel:setPosition(425,45)
    self.mySpriteWorld:addChild(yLabel)
    
    local function callBackYHandler(fn,eB,str,type)
            if type==1 then  --检测文本内容变化
                     if str=="" then
                         self.m_lastSearchYValue=playerVoApi:getMapY()
                         self.m_labelY:setString(self.m_lastSearchYValue)
                         do
                            return
                         end
                     end
                     if tonumber(str)==nil then
                          eB:setText(self.m_lastSearchYValue)
                     else
                         if tonumber(str)>=1 and tonumber(str)<=600 then
                             self.m_lastSearchYValue=tonumber(str)
                         else
                              if tonumber(str)<1 then
                                  eB:setText(1)
                                  self.m_lastSearchYValue=1
                              end
                              if tonumber(str)>600 then
                                  eB:setText(600)
                                  self.m_lastSearchYValue=600
                              end
                              
                         end
                     end
                     self.m_labelY:setString(self.m_lastSearchYValue)
            elseif type==2 then --
                     eB:setVisible(false)
            end 
    end
    
    self.m_labelY=GetTTFLabel("",25)
    self.m_labelY:setPosition(ccp(495,65))
    self.m_labelY:setString(playerVoApi:getMapY())
    self.m_lastSearchYValue=playerVoApi:getMapY()
    self.mySpriteWorld:addChild(self.m_labelY,2)
    

    local yBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    
    local editYBox
    if G_isIOS()==true then
        editYBox=CCEditBox:createForLua(CCSize(90,50),yBox,nil,nil,callBackYHandler)
    else
        editYBox=CCEditBox:createForLua(CCSize(130,80),yBox,nil,nil,callBackYHandler)
    end
    
    editYBox:setPosition(ccp(495,65))
    editYBox:setVisible(false)
    if G_isIOS()==true then
        editYBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editYBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    self.mySpriteWorld:addChild(editYBox,3)
    
    local function tthandler3()
        PlayEffect(audioCfg.mouseClick)
        editYBox:setVisible(true)
    end
    local yBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler3)
    yBoxBg:setPosition(ccp(480,60))
    yBoxBg:setContentSize(CCSize(80,40))
    yBoxBg:setTouchPriority(-22)
    yBoxBg:setOpacity(0)
    self.mySpriteWorld:addChild(yBoxBg)


    local function ssHandler() --搜索
         PlayEffect(audioCfg.mouseClick)
         worldScene:focus(self.m_lastSearchXValue,self.m_lastSearchYValue)
    end
    
    
    local ssSprite=GetButtonItem("worldBtnSearch.png","worldBtnSearch_Down.png","worldBtnPosition_Down.png",ssHandler,nil,nil,nil)
    ssSprite:setAnchorPoint(ccp(0,1))
    local ssSpriteMenu=CCMenu:createWithItem(ssSprite);
    ssSpriteMenu:setPosition(ccp(540,self.mySpriteWorld:getContentSize().height-15+heightPos))
    ssSpriteMenu:setTouchPriority(-23);
    self.mySpriteWorld:addChild(ssSpriteMenu)

    local ssLabel=GetTTFLabel(getlocal("world_scene_search"),20);
    ssLabel:setAnchorPoint(ccp(0.5,0.5))
    ssLabel:setPosition(ssSprite:getContentSize().width/2,heightPos)
    ssSprite:addChild(ssLabel)
    -- 基地ui
    self.mySpriteMain=LuaCCSprite:createWithSpriteFrameName("mainUiTop.png",touch);
    self.mySpriteMain:setAnchorPoint(ccp(0,1));
    self.mySpriteMain:setPosition(ccp(0,G_VisibleSizeHeight))
    self.myUILayer:addChild(self.mySpriteMain,13);
    
    local function pushLeft()
        if self.m_menuToggle:getSelectedIndex()==2 then
            do
                return
            end
        end
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep==43 then --新手引导
             do
                return
             end
         end
        -- local td=playerDialog:new(1,3)
        -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
        -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
        -- sceneGame:addChild(dialog,3)
        local td=playerVoApi:showPlayerDialog(1,3)
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep~=43 then --新手引导
             newGuidMgr:toNextStep()
        end
    end
    -- 玩家基础信息框
 self.mySpriteLeft=GetButtonItem("mainUiTop_topLeft.png","mainUiTop_topLeft_down.png","mainUiTop_topLeft_down.png",pushLeft,nil,nil,nil)
    local leftMenu=CCMenu:createWithItem(self.mySpriteLeft);
    leftMenu:setTouchPriority(-21);
    self.mySpriteLeft:setAnchorPoint(ccp(0,0));
    leftMenu:setPosition(5,5);
    leftMenu:setTag(1)
    self.mySpriteMain:addChild(leftMenu)
    
    local function pushRight()
        if self.m_menuToggle:getSelectedIndex()==2 then
            do
                return
            end
        end
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==36 or newGuidMgr.curStep==26) then --新手引导
                do
                    return
                end
         end
        local td=isLandStateDialog:new()
        local tbArr={getlocal("resource"),getlocal("state")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("islandState"),true,3)
        sceneGame:addChild(dialog,3)
        if newGuidMgr:isNewGuiding() then --新手引导
                newGuidMgr:toNextStep()
        end

    end
    -- 资源信息条
 self.mySpriteRight=GetButtonItem("mainUiTop_bottom.png","mainUiTop_bottom_down.png","mainUiTop_bottom.png",pushRight,nil,nil,nil)
    local rightMenu=CCMenu:createWithItem(self.mySpriteRight);
    rightMenu:setTouchPriority(-21);
    self.mySpriteRight:setAnchorPoint(ccp(0,1));
    rightMenu:setPosition(0,self.mySpriteMain:getContentSize().height);
    rightMenu:setTag(1)
    self.mySpriteMain:addChild(rightMenu)
    -- 金币按钮
    local function showRechargeDialog()
        if newGuidMgr:isNewGuiding() then
	        	do return end
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        vipVoApi:showRechargeDialog(3)
	end
    
    local goldButton=GetButtonItem("mainUiTop_topRight.png","mainUiTop_topRight_down.png","mainUiTop_topRight.png",showRechargeDialog,nil,nil,nil)



  local spcSp=CCSprite:createWithSpriteFrameName("buy_light_0.png")
  local  spcArr=CCArray:create()
   for kk=0,11 do
        local nameStr="buy_light_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        spcArr:addObject(frame)
   end
   local animation=CCAnimation:createWithSpriteFrames(spcArr)
   animation:setDelayPerUnit(0.06)
   local animate=CCAnimate:create(animation)
   spcSp:setAnchorPoint(ccp(0.5,0.5))
   spcSp:setPosition(ccp(goldButton:getContentSize().width/2,goldButton:getContentSize().height/2))
   goldButton:addChild(spcSp)
   local delayAction=CCDelayTime:create(1)
   local seq=CCSequence:createWithTwoActions(animate,delayAction)
   local repeatForever=CCRepeatForever:create(seq)
   spcSp:runAction(repeatForever)

    local goldMenu=CCMenu:createWithItem(goldButton);
    goldMenu:setTouchPriority(-21);
    goldButton:setAnchorPoint(ccp(1,0));
    
    self.m_labelMoney=GetTTFLabel(FormatNumber(playerVoApi:getGems()),24);
    self.m_labelMoney:setAnchorPoint(ccp(0.5,0.5));
    self.m_labelMoney:setPosition(ccp(goldButton:getContentSize().width/2+12,goldButton:getContentSize().height/2+10));
    goldButton:addChild(self.m_labelMoney);
    
    local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png");
    goldSp:setAnchorPoint(ccp(1,0.5));
    goldSp:setPosition(ccp(0,self.m_labelMoney:getContentSize().height/2));
    self.m_labelMoney:addChild(goldSp);
    
    local getGoldLb=GetTTFLabel(getlocal("getGold"),26);
    getGoldLb:setPosition(ccp(goldButton:getContentSize().width/2,goldButton:getContentSize().height/2-20));
    goldButton:addChild(getGoldLb);

 goldMenu:setPosition(self.mySpriteMain:getContentSize().width-5,6);
    goldMenu:setTag(1)
    self.mySpriteMain:addChild(goldMenu)

    -- 场景下方信息条的背景框
    self.mySpriteDown = LuaCCSprite:createWithSpriteFrameName("mainUiBottom.png",touch);
    self.mySpriteDown:setAnchorPoint(ccp(0.5,0));
    self.mySpriteDown:setPosition(G_VisibleSizeWidth/2,0);
    self.myUILayer:addChild(self.mySpriteDown,2);
    self.mySpriteDown:setTouchPriority(-21);
		
--聊天
	
	local function chatHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        if newGuidMgr:isNewGuiding()==true then
			do return end
		end
    local layerNum=3
    chatVoApi:showChatDialog(layerNum)
	end
	self.m_chatBtn=GetButtonItem("mainBtnChat.png","mainBtnChat_Down.png","mainBtnChat_Down.png",chatHandler,nil,nil,nil)
	self.m_chatBtn:setAnchorPoint(ccp(1,0))
	local chatSpriteMenu=CCMenu:createWithItem(self.m_chatBtn)
	chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth,self.mySpriteDown:getContentSize().height))
	chatSpriteMenu:setTouchPriority(-21)
	self.myUILayer:addChild(chatSpriteMenu,2)

	self.m_chatBg = LuaCCSprite:createWithSpriteFrameName("mainChatBg.png",chatHandler)
	self.m_chatBg:setAnchorPoint(ccp(0,0))
	self.m_chatBg:setPosition(0,self.mySpriteDown:getContentSize().height)
	self.myUILayer:addChild(self.m_chatBg,2)
	self.m_chatBg:setTouchPriority(-21)
	
	self:setLastChat()
	
	
--右边板子 label  资源进度条
    
    local r1P,r2P,r3P,r4P,rGP = buildingVoApi:getResourcePercent();
    local lbSize=20



    
    AddProgramTimer(self.mySpriteRight,ccp(94,93),9,nil,nil,nil,"resourceBar.png");
    local moneyTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(9),"CCProgressTimer")
    moneyTimerSprite:setPercentage(0);

    self.m_labelGold=GetTTFLabel(FormatNumber(playerVoApi:getGold()),lbSize);
    self.m_labelGold:setAnchorPoint(ccp(0,0.5));
    self.m_labelGold:setPosition(ccp(56,26));
    self.m_labelGold:setColor(G_ColorWhite);
    self.mySpriteRight:addChild(self.m_labelGold,5);
    
    AddProgramTimer(self.mySpriteRight,ccp(82,26),10,nil,nil,nil,"resourceBar.png");
    local goldTimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(10),"CCProgressTimer")
    goldTimerSprite:setPercentage(rGP);

    self.m_labelR1=GetTTFLabel(FormatNumber(playerVoApi:getR1()),lbSize);
    self.m_labelR1:setAnchorPoint(ccp(0,0.5));
    self.m_labelR1:setPosition(ccp(183,26));
    self.mySpriteRight:addChild(self.m_labelR1,5);
    
    AddProgramTimer(self.mySpriteRight,ccp(207,26),11,nil,nil,nil,"resourceBar.png");
    local r1TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(11),"CCProgressTimer")
    r1TimerSprite:setPercentage(r1P);

    self.m_labelR2=GetTTFLabel(FormatNumber(playerVoApi:getR2()),lbSize);
    self.m_labelR2:setAnchorPoint(ccp(0,0.5));
    self.m_labelR2:setPosition(ccp(306,26));
    self.m_labelR2:setColor(G_ColorWhite);
    self.mySpriteRight:addChild(self.m_labelR2,5);
    
    AddProgramTimer(self.mySpriteRight,ccp(331,26),12,nil,nil,nil,"resourceBar.png");
    local r2TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(12),"CCProgressTimer")
    r2TimerSprite:setPercentage(r2P);

    self.m_labelR3=GetTTFLabel(FormatNumber(playerVoApi:getR3()),lbSize);
    self.m_labelR3:setAnchorPoint(ccp(0,0.5));
    self.m_labelR3:setPosition(ccp(431,26));
    self.m_labelR3:setColor(G_ColorWhite);
    self.mySpriteRight:addChild(self.m_labelR3,5);
    
    AddProgramTimer(self.mySpriteRight,ccp(456,26),13,nil,nil,nil,"resourceBar.png");
    local r3TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(13),"CCProgressTimer")
    r3TimerSprite:setPercentage(r3P);

    self.m_labelR4=GetTTFLabel(FormatNumber(playerVoApi:getR4()),lbSize);
    self.m_labelR4:setAnchorPoint(ccp(0,0.5));
    self.m_labelR4:setPosition(ccp(555,26));
    self.m_labelR4:setColor(G_ColorWhite);
    self.mySpriteRight:addChild(self.m_labelR4,5);
    
    AddProgramTimer(self.mySpriteRight,ccp(579,26),14,nil,nil,nil,"resourceBar.png");
    local r4TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(14),"CCProgressTimer")
    r4TimerSprite:setPercentage(r4P);

    
    local protectResource =buildingVoApi:getProtectResource()
    if playerVoApi:getR1()>protectResource then
        self.m_labelR1:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR2()>protectResource then
        self.m_labelR2:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR3()>protectResource then
        self.m_labelR3:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getR4()>protectResource then
        self.m_labelR4:setColor(G_ColorYellowPro);
    end
    if playerVoApi:getGold()>protectResource then
        self.m_labelGold:setColor(G_ColorYellowPro);
    end



--左边板子进度条  能量和等级进度条
    AddProgramTimer(self.mySpriteLeft,ccp(252-78,52.5-9.5),11,nil,nil,nil,"xpBar.png");
    local expTimerSprite = tolua.cast(self.mySpriteLeft:getChildByTag(11),"CCProgressTimer")
    expTimerSprite:setPercentage(playerVoApi:getLvPercent());

    AddProgramTimer(self.mySpriteLeft,ccp(252-78,22.5-5.5),10,nil,nil,nil,"energyBar.png");
    local timerSprite = tolua.cast(self.mySpriteLeft:getChildByTag(10),"CCProgressTimer");
    timerSprite:setPercentage(playerVoApi:getEnergyPercent()*100);

    
    
--左边板子 等级label 姓名label
    self.nameLb=GetTTFLabel(playerVoApi:getPlayerName(),20);
    self.nameLb:setAnchorPoint(ccp(0,0.5));
    self.nameLb:setPosition(ccp(165-80,74-4));
    self.nameLb:setColor(G_ColorWhite);
    self.mySpriteLeft:addChild(self.nameLb,5);

    self.m_labelLevel=GetTTFLabel(getlocal("fightLevel",{playerVoApi:getPlayerLevel()}),20);
    self.m_labelLevel:setAnchorPoint(ccp(0,0.5));
    self.m_labelLevel:setPosition(ccp(168-80,53-10));
    self.m_labelLevel:setColor(G_ColorWhite);
    self.mySpriteLeft:addChild(self.m_labelLevel,5);
    
    local energyIconSp = CCSprite:createWithSpriteFrameName("energyIcon.png");
    energyIconSp:setAnchorPoint(ccp(0,0.5));
    energyIconSp:setPosition(ccp(165-80,24.5-4));
    self.mySpriteLeft:addChild(energyIconSp,5);
    
    local personPhotoName="photo"..playerVoApi:getPic()..".png"
    local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
    personPhoto:setAnchorPoint(ccp(0,0.5));
    personPhoto:setPosition(ccp(6,self.mySpriteLeft:getContentSize().height/2));
    personPhoto:setTag(767)
    self.mySpriteLeft:addChild(personPhoto,5);
    
    local rankStr="rank"..playerVoApi:getRank()..".png"
    if playerVoApi:getRank()>11 then
        rankStr="rank11.png";
    end
    self.m_rankMainUI=playerVoApi:getRank();
    local rankSP = CCSprite:createWithSpriteFrameName(rankStr);
    rankSP:setAnchorPoint(ccp(0.5,0.5));
    rankSP:setPosition(ccp(120+200,self.mySpriteLeft:getContentSize().height/2));
    rankSP:setTag(50)
    self.mySpriteLeft:addChild(rankSP,5);
    

-- 一串按钮 main_ui_42.png
    local function pushSmallMenu(tag,object)
        self:pushSmallMenu(tag,object)
    end

    -- 基地右侧缩放按钮
    local selectSp1 = CCSprite:createWithSpriteFrameName("mainBtnDown.png");
    local selectSp2 = CCSprite:createWithSpriteFrameName("mainBtnDown_Down.png");
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2);  --(90,80)

    local selectSp3 = CCSprite:createWithSpriteFrameName("mainBtnUp.png");
    local selectSp4 = CCSprite:createWithSpriteFrameName("mainBtnUp_Down.png");
    local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4);

    self.m_pointLuaSp = ccp(G_VisibleSizeWidth-menuItemSp1:getContentSize().width/2,G_VisibleSizeHeight-185);

    self.m_menuToggleSmall = CCMenuItemToggle:create(menuItemSp1);
    self.m_menuToggleSmall:addSubItem(menuItemSp2)

    self.m_menuToggleSmall:registerScriptTapHandler(pushSmallMenu)
  if newGuidMgr:isNewGuiding() ==true then
        self.m_menuToggleSmall:setSelectedIndex(0)
  else
       self.m_menuToggleSmall:setSelectedIndex(1)
  end

    local menuAllSmall=CCMenu:createWithItem(self.m_menuToggleSmall);
    menuAllSmall:setPosition(self.m_pointLuaSp);
    menuAllSmall:setTouchPriority(-23);
    self.myUILayer:addChild(menuAllSmall,10);
    
    local function touchLuaSp(object,name,tag)
        self:touchLuaSp(object,name,tag)
    end
    
    --[[
    self.m_luaSp1 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp1:setPosition(self.m_pointLuaSp);
    self.m_luaSp1:setTag(101);
    self.myUILayer:addChild(self.m_luaSp1,1);
    self.m_luaSp1:setTouchPriority(-21);
    
    
    self.m_luaSp2 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp2:setPosition(self.m_pointLuaSp);
    self.m_luaSp2:setTag(102);
    self.myUILayer:addChild(self.m_luaSp2,2);
    self.m_luaSp2:setTouchPriority(-21);
    ]]
    -- 图标背景
    self.m_luaSp6 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp6:setPosition(self.m_pointLuaSp);
    self.m_luaSp6:setTag(106);
    self.myUILayer:addChild(self.m_luaSp6,3);
    self.m_luaSp6:setTouchPriority(-21);
    
    self.m_luaSp7 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSp7:setPosition(self.m_pointLuaSp);
    self.m_luaSp7:setTag(107);
    self.myUILayer:addChild(self.m_luaSp7,4);
    self.m_luaSp7:setTouchPriority(-21);
    --[[
    local spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_02.png")
    spriteSp1:setPosition(getCenterPoint(self.m_luaSp1))
    self.m_luaSp1:addChild(spriteSp1,1);
    
    local scaleX =  self.m_luaSp1:getContentSize().width/spriteSp1:getContentSize().width
    local scaleY =  self.m_luaSp1:getContentSize().height/spriteSp1:getContentSize().height
    spriteSp1:setScaleX(scaleX)
    spriteSp1:setScaleY(scaleY)
    self.m_iconScaleX = scaleX
    self.m_iconScaleY = scaleY
    
    local spriteSp2 = CCSprite:createWithSpriteFrameName("Icon_mainui_01.png")
    spriteSp2:setPosition(getCenterPoint(self.m_luaSp2))
    self.m_luaSp2:addChild(spriteSp2,1);
    spriteSp2:setScaleX(scaleX)
    spriteSp2:setScaleY(scaleY)
    ]]
    local spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_02.png")
    
    local scaleX =  self.m_luaSp6:getContentSize().width/spriteSp1:getContentSize().width
    local scaleY =  self.m_luaSp6:getContentSize().height/spriteSp1:getContentSize().height
    self.m_iconScaleX = scaleX
    self.m_iconScaleY = scaleY
    -- 建筑加速的图标
    local spriteSp3 = CCSprite:createWithSpriteFrameName("tech_build_speed_up_main.png")
    spriteSp3:setPosition(getCenterPoint(self.m_luaSp6))
    self.m_luaSp6:addChild(spriteSp3,1);
    local scaleX3 =  self.m_luaSp6:getContentSize().width/spriteSp3:getContentSize().width
    local scaleY3 =  self.m_luaSp6:getContentSize().height/spriteSp3:getContentSize().height
    spriteSp3:setScaleX(scaleX3)
    spriteSp3:setScaleY(scaleY3)
    -- 购买建造位的图标
    local spriteSp4 = CCSprite:createWithSpriteFrameName("new_build_process.png")
    spriteSp4:setPosition(getCenterPoint(self.m_luaSp7))
    self.m_luaSp7:addChild(spriteSp4,1);
    spriteSp4:setScaleX(scaleX)
    spriteSp4:setScaleY(scaleY)

    self.m_newsIconTab={}
	self.m_newsNumTab={}
    self.m_functionBtnTb={}
    local function travelHandler(object,name,tag)
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            if self.m_travelSp:isVisible()==false then
             do
              return
             end
            end
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
        local dlayerNum=3
        local td=tankDefenseDialog:new(dlayerNum)
            local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,dlayerNum)
            td:tabClick(1)
            sceneGame:addChild(dialog,dlayerNum)
    end
    self.m_travelSp=LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",travelHandler)
    self.m_travelSp:setPosition(self.m_pointLuaSp)
    self.myUILayer:addChild(self.m_travelSp)
    self.m_travelSp:setVisible(false)
    self.m_travelSp:setTouchPriority(-21);
    
    if playerVoApi:getBuildingSlotNum()~=7 then
        self.m_luaSpTab = {self.m_luaSp6,self.m_luaSp7,self.m_travelSp}
    else
        self.m_luaSpTab = {self.m_luaSp6,self.m_travelSp}
    end


    
    self:addShortcuts(touchLuaSp);
    
    
    self.m_skillHeigh = self.m_luaSp6:getContentSize().height;
    self.m_luaTime=0.1;
    self.m_dis=3;
    
-- vip按钮
	self:switchVipIcon()
	
	
--左边一列按钮
	self.m_flagTab={}
	self.m_leftIconTab={}
  self.m_rightTopIconTab = {}
	--切换幸运抽奖是否有免费
	self:switchDailyIcon()
	--新手7天礼包
	self:switchNewGiftsIcon()
    --7天之后显示  签到
    local newGiftsState=newGiftsVoApi:hasReward()
    if newGiftsState==-1 then
        self:switchSignIcon()
    end
	--加载和切换任务图片
	self:switchTaskIcon()
	--加载和切换每日领取图片
	self:switchDailyRewardIcon()
	--活动
	-- self:switchNewYearIcon()
    -- 活动图标统一
    -- self.myUILayer:addChild(activityUI:show())

    self:switchStateIcon()

    --显示公告
    -- self:switchNoticeIcon()

    --显示公告
    self.m_flagTab.acAndNoteState = activityVoApi:hadNewActivity() == true or noteVoApi:hadNewNote() == true or activityVoApi:oneCanReward() == true -- 是否需要显示动画
    self.m_flagTab.hadAcAndNote = activityVoApi:hadActivity() or noteVoApi:hadNote() or dailyActivityVoApi:getActivityNum()>0 -- 是否有活动或公告
    self.m_flagTab.newAcAndNoteNum = activityVoApi.newNum + noteVoApi.newNum -- 新活动和新公告个数之和
    self:switchActivityAndNoteIcon()

    --协防
    self:switchHelpDefendIcon()

	--设置左边按钮位置
	self:resetLeftIconPos()
--底下切换按钮
    -- 基地按钮
    local select11 = CCSprite:createWithSpriteFrameName("mainUiBase.png");
    local select12 = CCSprite:createWithSpriteFrameName("mainUiBase_Down.png");
    local menuItem1 = CCMenuItemSprite:create(select11,select12);  --(90,80)
    menuItem1:setTag(21);
    local selectLabel1=GetTTFLabel(getlocal("main_scene_port"),25);
    selectLabel1:setAnchorPoint(ccp(0.5,1))
    selectLabel1:setColor(G_ColorGreen)
    selectLabel1:setPosition(menuItem1:getContentSize().width/2,menuItem1:getContentSize().height-10)
    menuItem1:addChild(selectLabel1)
    
    -- 郊外按钮
    local select21 = CCSprite:createWithSpriteFrameName("mainUiOutskirts.png");
    local select22 = CCSprite:createWithSpriteFrameName("mainUiOutskirts_Down.png");
    local menuItem2 = CCMenuItemSprite:create(select21,select22);
    menuItem2:setTag(22);
    local selectLabel2=GetTTFLabel(getlocal("main_scene_island"),25);
    selectLabel2:setAnchorPoint(ccp(0.5,1))
    selectLabel2:setColor(G_ColorGreen)
    selectLabel2:setPosition(menuItem2:getContentSize().width/2,menuItem1:getContentSize().height-10)
    menuItem2:addChild(selectLabel2)
    -- 世界按钮
    local select31 = CCSprite:createWithSpriteFrameName("mainUiWorld.png");
    local select32 = CCSprite:createWithSpriteFrameName("mainUiWorld_Down.png");
    local menuItem3 = CCMenuItemSprite:create(select31,select32);
    menuItem3:setTag(23);
    local selectLabel3=GetTTFLabel(getlocal("main_scene_world"),25);
    selectLabel3:setAnchorPoint(ccp(0.5,1))
    selectLabel3:setColor(G_ColorGreen)
    selectLabel3:setPosition(menuItem3:getContentSize().width/2,menuItem1:getContentSize().height-10)
    menuItem3:addChild(selectLabel3)
--切换场景
    local function pushMenu(tag,object)
        if newGuidMgr:isNewGuiding() and newGuidMgr.curStep==10 then
			self.m_menuToggle:setSelectedIndex(0)
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        
        if self.m_menuToggle:getSelectedIndex()==2 then
                     if tonumber(playerVoApi:getPlayerLevel())<3 and tonumber(playerVoApi:getMapX())==-1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldSceneWillOpenDesc"),28)
                         do
                         self:changeToMyPort()
                         return
                         end
                     end


        end

        sceneController:changeSceneByIndex(self.m_menuToggle:getSelectedIndex())
        self:changeMainUI(self.m_menuToggle:getSelectedIndex())
        if newGuidMgr:isNewGuiding() then --新手引导
                newGuidMgr:toNextStep()
        end
    end


    self.m_menuToggle = CCMenuItemToggle:create(menuItem1);
    self.m_menuToggle:addSubItem(menuItem2)
    self.m_menuToggle:addSubItem(menuItem3)
    self.m_menuToggle:setSelectedIndex(0)
    self.m_menuToggle:registerScriptTapHandler(pushMenu)

    local menuAll=CCMenu:createWithItem(self.m_menuToggle);
    menuAll:setPosition(ccp(84,64));
    menuAll:setTouchPriority(-23);
    self.mySpriteDown:addChild(menuAll,1);


    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(440,105),nil)
    self.tv:setAnchorPoint(ccp(0,0));
    self.tv:setPosition(ccp(155,10))
    self.tv:setTableViewTouchPriority(-23);
    self.mySpriteDown:addChild(self.tv,90)

   -- self:pushSmallMenu()
   self.m_showWelcome=true
end
-- 让右侧展开
function mainUI:touchLuaSpExpnd()

   if newGuidMgr:isNewGuiding()==true then
        self.m_menuToggleSmall:setSelectedIndex(0)
   else
        self.m_menuToggleSmall:setSelectedIndex(1)
         for  k,v in pairs(self.m_luaSpTab) do
            v:stopAllActions();
            self:moveDown(v,ccp(self.m_pointLuaSp.x,self.m_pointLuaSp.y-k*self.m_skillHeigh-k*self.m_dis),self.m_luaTime+0.02*k);
            local tagV = v:getTag();
        end
   end

end

function mainUI:touchLuaSp(object,name,tag)
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        if newGuidMgr:isNewGuiding() then
             do
                 return
             end
        end
    local isPlayEffect=true;
        if tag==101 then
            local td=isLandStateDialog:new()
            local tbArr={getlocal("resource"),getlocal("state")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("islandState"),true,3)
            sceneGame:addChild(dialog,3)
        
        elseif tag==102 then
            local td=isLandStateDialog:new()
            local tbArr={getlocal("resource"),getlocal("state")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("islandState"),true,3)
            td:tabClick(1)
            sceneGame:addChild(dialog,3)
    isPlayEffect=false;
        
        elseif tag==103 then
            local tabbuildings=buildingVoApi:getBuildingVoByBtype(9)
            local nbid=0;
            for k,v in pairs(tabbuildings) do
                nbid=v.id
            end

            local level = buildingVoApi:getBuildiingVoByBId(6).level
            buildingVoApi:showWorkshop(nbid,9,3,level)
        elseif tag==104 then
            local tabbuildings=buildingVoApi:getBuildingVoByBtype(8)
            local nbid=0;
            local nlevel=0
            for k,v in pairs(tabbuildings) do
                nbid=v.id
                nlevel=v.level
            end

            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
            local td=techCenterDialog:new(nbid,3)
            local bName=getlocal(buildingCfg[8].buildName)
            local tbArr={getlocal("building"),getlocal("startResearch")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."(LV."..nlevel..")",true)
            td:tabClick(1)
            sceneGame:addChild(dialog,3)
     isPlayEffect=false;

        
        elseif tag==105 then
            local bid=11;
            local tankSlot1=tankSlotVoApi:getSoltByBid(11)
            local tankSlot2=tankSlotVoApi:getSoltByBid(12)
            if SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)==0 then
                bid=11;
            elseif SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)>0 then
                bid=11;
            elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)==0 then
                bid=12;
            elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)>0 then
                bid=11;
            end
            
            local buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
            if buildingVo.level==0 then
                bid=11;
                buildingVo=nil
                buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
            end
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td=tankFactoryDialog:new(bid,3)
            local bName=getlocal(buildingCfg[6].buildName)
            
            local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."(LV."..buildingVo.level..")",true,3)
     td:tabClick(1)
            sceneGame:addChild(dialog,3)

        elseif tag==106 then
            -- local td=playerDialog:new(3,3)
            -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,3)
            -- --td:tabClick(2)
            -- sceneGame:addChild(dialog,3)
            local td=playerVoApi:showPlayerDialog(3,3)
        elseif tag==107 then
            

            local vipLv=playerVoApi:getVipLevel()
            local buildQueue=tonumber(Split(playerCfg.vip4BuildQueue,",")[vipLv+1])--当前vip可购买建造位
            local mybuildQueue=playerVoApi:getBuildingSlotNum()--当前拥有建造位
            local maxbuildQueue=tonumber(Split(playerCfg.vip4BuildQueue,",")[10])

            if mybuildQueue<buildQueue then
                local function callBack()
                    if playerVoApi:getGems()<tonumber(playerCfg.buildQueuePrice[mybuildQueue+1]) then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("notEnoughGem"),nil,4)
                        do
                          return
                        end
                    end

                    local function serverBuyBuildingSolt(fn,data)
                          --local retTb=OBJDEF:decode(data)
                          if base:checkServerData(data)==true then
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("promptBuyBuildingQueue",{mybuildQueue+1}),nil,4)
                          end
                     end
                
                    socketHelper:buyBuildingSlot(serverBuyBuildingSolt)
                
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("buyQueueContent",{playerCfg.buildQueuePrice[mybuildQueue+1]}),nil,4)
            
            elseif mybuildQueue==maxbuildQueue then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buidQueueMax"),nil,4)
            
            else

                local needvip=playerCfg.vip4BuildQueueNeed[mybuildQueue+1]
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("needVipContent",{needvip}),nil,4)

            
            end

            
            --tankVoApi:getBestTanks()
            --[[
            require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
            local td=tankAttackDialog:new(2,4)
            local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
            sceneGame:addChild(dialog,4)
            ]]
        end
    if isPlayEffect==true then
        PlayEffect(audioCfg.mouseClick)
    end


end

--判断是否应该有快捷键
function mainUI:addShortcuts(touchLuaSp)
    --判断是否开启某种建筑 加进对应的右侧按钮
    if buildingVoApi:getBuildingVoIsBuildByBtype(9)==true and self.m_luaSp3==nil then
        self.m_luaSp3 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
        self.m_luaSp3:setPosition(self.m_pointLuaSp);
        self.m_luaSp3:setTag(103);
        self.myUILayer:addChild(self.m_luaSp3,2);
        self.m_luaSp3:setTouchPriority(-21);
        table.insert(self.m_luaSpTab, 1 , self.m_luaSp3)
        
        local sp=CCSprite:createWithSpriteFrameName("Icon_dao_ju.png")
        local scale = self.m_luaSp3:getContentSize().width/sp:getContentSize().width
        sp:setScale(scale)
        sp:setTag(10)
        sp:setPosition(getCenterPoint(self.m_luaSp3))
        self.m_luaSp3:addChild(sp)
        
    end
    
    if buildingVoApi:getBuildingVoIsBuildByBtype(8)==true and self.m_luaSp4==nil then
        self.m_luaSp4 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
        self.m_luaSp4:setPosition(self.m_pointLuaSp);
        self.m_luaSp4:setTag(104);
        self.myUILayer:addChild(self.m_luaSp4,2);
        self.m_luaSp4:setTouchPriority(-21);
        if self.m_luaSp3~=nil then
            table.insert(self.m_luaSpTab, 2, self.m_luaSp4)
        else
            table.insert(self.m_luaSpTab, 1, self.m_luaSp4)
        end
        
        local sp=CCSprite:createWithSpriteFrameName("Icon_ke_yan_zhong_xin.png")
        local scale = self.m_luaSp4:getContentSize().width/sp:getContentSize().width
        sp:setScale(scale)
        sp:setTag(10)
        sp:setPosition(getCenterPoint(self.m_luaSp4))
        self.m_luaSp4:addChild(sp)
    
    end
    
    if buildingVoApi:getBuildingVoIsBuildByBtype(6)==true and self.m_luaSp5==nil then
        self.m_luaSp5 = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
        self.m_luaSp5:setPosition(self.m_pointLuaSp);
        self.m_luaSp5:setTag(105);
        self.myUILayer:addChild(self.m_luaSp5,2);
        self.m_luaSp5:setTouchPriority(-21);
        local num=SizeOfTable(self.m_luaSpTab)-1
        table.insert(self.m_luaSpTab, num, self.m_luaSp5)
        
        
        local sp=CCSprite:createWithSpriteFrameName("Icon_tan_ke_gong_chang.png")
        local scale = self.m_luaSp5:getContentSize().width/sp:getContentSize().width
        sp:setScale(scale)
        sp:setTag(10)
        sp:setPosition(getCenterPoint(self.m_luaSp5))
        self.m_luaSp5:addChild(sp)
        
    
    end
    local capInSet = CCRect(5, 5, 1, 1);
    local function touchClick()
    
    end
    --[[
    if self.m_luaSp1:getChildByTag(2)==nil then
        local tab1=useItemSlotVoApi:getAllSlots()
        local str1=useItemSlotVoApi:getNumByState2().."/".."4"
        local label1=GetTTFLabel(str1,20);
        label1:setPosition(ccp(self.m_luaSp1:getContentSize().width/2,10))
        label1:setTag(2)
        self.m_luaSp1:addChild(label1,5)
        
        
        local lbSpBg1 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg1:setContentSize(CCSizeMake(label1:getContentSize().width+12,20))
        lbSpBg1:setPosition(ccp(self.m_luaSp1:getContentSize().width/2,10))
        lbSpBg1:setTag(3)
        self.m_luaSp1:addChild(lbSpBg1,4)
        
        local str2=useItemSlotVoApi:getNumByState1().."/".."5"
        local label2=GetTTFLabel(str2,20);
        label2:setPosition(ccp(self.m_luaSp2:getContentSize().width/2,10))
        label2:setTag(2)
        self.m_luaSp2:addChild(label2,5)
        local lbSpBg2 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg2:setContentSize(CCSizeMake(label2:getContentSize().width+12,20))
        lbSpBg2:setPosition(ccp(self.m_luaSp2:getContentSize().width/2,10))
        lbSpBg2:setTag(3)
        self.m_luaSp2:addChild(lbSpBg2,4)
    
    end]]
    
    
    if self.m_luaSp3~=nil and self.m_luaSp3:getChildByTag(2)==nil then
        local tab3=workShopSlotVoApi:getAllSolts()
        local str3;
        if SizeOfTable(tab3)==0 then
            str3="0".."/".."1"
        else
            local voshop=workShopSlotVoApi:getProductSolt()
            local time=voshop.et-base.serverTime
            str3=GetTimeStr(time)
            
        end
        local label3=GetTTFLabel(str3,20);
        label3:setPosition(ccp(self.m_luaSp3:getContentSize().width/2,10))
        label3:setTag(2)
        self.m_luaSp3:addChild(label3,5)
        
        local lbSpBg3 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg3:setContentSize(CCSizeMake(label3:getContentSize().width+12,20))
        lbSpBg3:setPosition(ccp(self.m_luaSp3:getContentSize().width/2,10))
        lbSpBg3:setTag(3)
        self.m_luaSp3:addChild(lbSpBg3,4)
    end
    
    if self.m_luaSp4~=nil and self.m_luaSp4:getChildByTag(2)==nil then
        local tab4 = technologySlotVoApi:getAllSlotSortBySt()
        local str4="";
        if SizeOfTable(tab4)==0 then
            str4="0".."/".."1"
        else
            local voshop=tab4[1]
            if voshop.et~=nil then
                local time=voshop.et-base.serverTime
                str4=GetTimeStr(time)
            end
        end
        local label4=GetTTFLabel(str4,20);
        label4:setPosition(ccp(self.m_luaSp4:getContentSize().width/2,10))
        label4:setTag(2)
        self.m_luaSp4:addChild(label4,5)
        
        local lbSpBg4 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg4:setContentSize(CCSizeMake(label4:getContentSize().width+12,20))
        lbSpBg4:setPosition(ccp(self.m_luaSp4:getContentSize().width/2,10))
        lbSpBg4:setTag(3)
        self.m_luaSp4:addChild(lbSpBg4,4)
    end
    
    if self.m_luaSp5~=nil and self.m_luaSp5:getChildByTag(2)==nil then
        
        local tab5=buildingVoApi:getBuildingVoHaveByBtype(6)
        local num=0
        local tankTab1=tankSlotVoApi:getTankSlotTab(11)
        local tankTab2=tankSlotVoApi:getTankSlotTab(12)
        local tankSVO;
        local str5;
        if SizeOfTable(tankTab1)>0 and SizeOfTable(tankTab2)>0 then
            if tankTab1[1].et>tankTab2[1].et then
                str5=GetTimeStr(tankTab2[1].et-base.serverTime)
            else
                str5=GetTimeStr(tankTab1[1].et-base.serverTime)
            end
            
        else
            num=num+1;
            str5=num.."/"..SizeOfTable(tab5)
        end

        local label5=GetTTFLabel(str5,20);
        label5:setPosition(ccp(self.m_luaSp5:getContentSize().width/2,10))
        label5:setTag(2)
        self.m_luaSp5:addChild(label5,5)
        
        local lbSpBg5 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
        lbSpBg5:setContentSize(CCSizeMake(label5:getContentSize().width+12,20))
        lbSpBg5:setPosition(ccp(self.m_luaSp5:getContentSize().width/2,10))
        lbSpBg5:setTag(3)
        self.m_luaSp5:addChild(lbSpBg5,4)
    end
    
    if self.m_luaSp6~=nil and self.m_luaSp6:getChildByTag(2)==nil then
        local buildingSlotNum=SizeOfTable(buildingSlotVoApi:getAllBuildingSlots())
        local str6;
        if buildingSlotNum<playerVoApi:getBuildingSlotNum() then
            str6=buildingSlotNum.."/"..playerVoApi:getBuildingSlotNum()
        else
            local tab=buildingSlotVoApi:getShortestSlot()
            local bsvo = tab
            local time=bsvo.et-base.serverTime
            str6=GetTimeStr(time)
        end
        if self.m_luaSp6:getChildByTag(2)==nil then
            local label6=GetTTFLabel(str6,20);
            label6:setPosition(ccp(self.m_luaSp6:getContentSize().width/2,10))
            label6:setTag(2)
            self.m_luaSp6:addChild(label6,5)
            
            local lbSpBg6 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
            lbSpBg6:setContentSize(CCSizeMake(label6:getContentSize().width+12,20))
            lbSpBg6:setPosition(ccp(self.m_luaSp6:getContentSize().width/2,10))
            lbSpBg6:setTag(3)
            self.m_luaSp6:addChild(lbSpBg6,4)
        end
        
        
    end
    
    

end
function mainUI:pushSmallMenu(tag,object)
    PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding() then
             self.m_menuToggleSmall:setSelectedIndex(0)
             do
                 return
             end
        end
        if self.m_menuToggleSmall:getSelectedIndex()==1 then
            local function touchLuaSp(object,name,tag)
                self:touchLuaSp(object,name,tag)
            end
            self:addShortcuts(touchLuaSp);
        
            for  k,v in pairs(self.m_luaSpTab) do

                v:stopAllActions();
                self:moveDown(v,ccp(self.m_pointLuaSp.x,self.m_pointLuaSp.y-k*self.m_skillHeigh-k*self.m_dis),self.m_luaTime+0.02*k);
                local tagV = v:getTag();
            end
            
        elseif self.m_menuToggleSmall:getSelectedIndex()==0 then
            
            local function touchLuaSp(object,name,tag)
                self:touchLuaSp(object,name,tag)
            end
            self:addShortcuts(touchLuaSp);    

            for  k,v in pairs(self.m_luaSpTab) do
            
                v:stopAllActions();
                local pointV = ccp(v:getPositionX(),v:getPositionY())
                self:moveUp(v,pointV,self.m_pointLuaSp,0.1,0.1);
                --local tag = v:getTag();
            end
            
        end

end


--刷新快捷键队列
function mainUI:refreshQueue()
--lb1刷新
    --[[
    local label1=self.m_luaSp1:getChildByTag(2)
    if label1~=nil then
        label1=tolua.cast(label1,"CCLabelTTF")
        local str1=useItemSlotVoApi:getNumByState1().."/".."5"
        label1:setString(str1);
    end

    local label2=self.m_luaSp2:getChildByTag(2)
    if label2~=nil then
        label2=tolua.cast(label2,"CCLabelTTF")
        local str2=useItemSlotVoApi:getNumByState2().."/".."4"
        label2:setString(str2);
    end
    ]]
--lb3刷新
    
    if self.m_luaSp3~=nil and self.m_luaSp3:getChildByTag(2)~=nil then
        local label3=self.m_luaSp3:getChildByTag(2)
        label3=tolua.cast(label3,"CCLabelTTF")
        local tab3=workShopSlotVoApi:getAllSolts()
        local str3;
        if SizeOfTable(tab3)==0 then
            if self.m_luaSp3:getChildByTag(11)~=nil then
                self.m_luaSp3:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            str3="0".."/".."1"
        else
            local voshop=workShopSlotVoApi:getProductSolt()
            if self.m_luaSp3:getChildByTag(11)==nil then
       local pid="p"..voshop.itemId
                local sp=CCSprite:createWithSpriteFrameName(propCfg[pid].icon)
                local scale = self.m_luaSp3:getContentSize().width/sp:getContentSize().width
                sp:setScale(scale)
                sp:setTag(11)
                sp:setPosition(getCenterPoint(self.m_luaSp3))
                self.m_luaSp3:addChild(sp)

            end
            local time=voshop.et-base.serverTime
            str3=GetTimeStr(time)
            
        end
        label3:setString(str3);
        local sp3=self.m_luaSp3:getChildByTag(3)
        sp3:setContentSize(CCSizeMake(label3:getContentSize().width+12,20))
        
    end
    
--lb4刷新
        
        if self.m_luaSp4~=nil and self.m_luaSp4:getChildByTag(2)~=nil then
            local label4=self.m_luaSp4:getChildByTag(2)
            label4=tolua.cast(label4,"CCLabelTTF")
            local tab4 = technologySlotVoApi:getAllSlotSortBySt()
            local str4;
            if SizeOfTable(tab4)==0 then
                if self.m_luaSp4:getChildByTag(11)~=nil then
                    self.m_luaSp4:getChildByTag(11):removeFromParentAndCleanup(true)
                end
                str4="0".."/".."1"
            else
        if self.m_luaSp4:getChildByTag(11)~=nil then
            self.m_luaSp4:getChildByTag(11):removeFromParentAndCleanup(true)
        end
                if self.m_luaSp4:getChildByTag(11)==nil then
                    local sp=CCSprite:createWithSpriteFrameName(techCfg[tonumber(tab4[1].tid)].icon)
                    local scale = self.m_luaSp4:getContentSize().width/sp:getContentSize().width
                    sp:setScale(scale)
                    sp:setTag(11)
                    sp:setPosition(getCenterPoint(self.m_luaSp4))
                    self.m_luaSp4:addChild(sp)
                end
                local voshop=tab4[1]
                local time=voshop.et-base.serverTime
                str4=GetTimeStr(time)
            end
            label4:setString(str4);
            
            local sp4=self.m_luaSp4:getChildByTag(3)
            sp4:setContentSize(CCSizeMake(label4:getContentSize().width+12,20))
        end

--lb5刷新
    if self.m_luaSp5~=nil and self.m_luaSp5:getChildByTag(2)~=nil then
        local label5=self.m_luaSp5:getChildByTag(2)
        label5=tolua.cast(label5,"CCLabelTTF")

        local tab5=buildingVoApi:getBuildingVoHaveByBtype(6)
        local num=0
        local tankTab1=tankSlotVoApi:getSoltByBid(11)
        local tankTab2=tankSlotVoApi:getSoltByBid(12)
        local tankSVO;
        local str5;
        if SizeOfTable(tankTab1)>0 and SizeOfTable(tankTab2)>0 then
            if tankSlotVoApi:getProducingSlotByBid(11).et>tankSlotVoApi:getProducingSlotByBid(12).et then
                 if self.m_luaSp5:getChildByTag(11)==nil then
                    local sp=CCSprite:createWithSpriteFrameName(tankCfg[tonumber(tankSlotVoApi:getProducingSlotByBid(12).itemId)].icon)
                    local scale = self.m_luaSp5:getContentSize().width/sp:getContentSize().width
                    sp:setScale(scale)
                    sp:setTag(11)
                    sp:setPosition(getCenterPoint(self.m_luaSp5))
                    self.m_luaSp5:addChild(sp)
                end
                str5=GetTimeStr(tankSlotVoApi:getProducingSlotByBid(12).et-base.serverTime)
            else
                if self.m_luaSp5:getChildByTag(11)==nil then
                    local sp=CCSprite:createWithSpriteFrameName(tankCfg[tonumber(tankSlotVoApi:getProducingSlotByBid(11).itemId)].icon)
                    local scale = self.m_luaSp5:getContentSize().width/sp:getContentSize().width
                    sp:setScale(scale)
                    sp:setTag(11)
                    sp:setPosition(getCenterPoint(self.m_luaSp5))
                    self.m_luaSp5:addChild(sp)
                end
                str5=GetTimeStr(tankSlotVoApi:getProducingSlotByBid(11).et-base.serverTime)
            end
            
        elseif SizeOfTable(tankTab1)>0 or SizeOfTable(tankTab2)>0 then
            if self.m_luaSp5:getChildByTag(11)~=nil then
                self.m_luaSp5:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            num=num+1;
            str5=num.."/"..SizeOfTable(tab5)
        else
            if self.m_luaSp5:getChildByTag(11)~=nil then
                self.m_luaSp5:getChildByTag(11):removeFromParentAndCleanup(true)
            end
            num=0;
            str5=num.."/"..SizeOfTable(tab5)
        end
        
        label5:setString(str5);
        
        local sp5=self.m_luaSp5:getChildByTag(3)
        sp5:setContentSize(CCSizeMake(label5:getContentSize().width+12,20))
     end

--lb6刷新
    
    if self.m_luaSp6~=nil and self.m_luaSp6:getChildByTag(2)~=nil then
        local label6=self.m_luaSp6:getChildByTag(2)
        label6=tolua.cast(label6,"CCLabelTTF")
        local buildingSlotNum=SizeOfTable(buildingSlotVoApi:getAllBuildingSlots())
        local str6;
        if buildingSlotNum<playerVoApi:getBuildingSlotNum() then
            str6=buildingSlotNum.."/"..playerVoApi:getBuildingSlotNum()
        else
            local tab=buildingSlotVoApi:getShortestSlot()
            local bsvo = tab
            local time=bsvo.et-base.serverTime
            if time<0 then
                time=0;
            end
            str6=GetTimeStr(time)
        end
        label6:setString(str6);
        local sp6=self.m_luaSp6:getChildByTag(3)
        sp6:setContentSize(CCSizeMake(label6:getContentSize().width+12,20))
    end


end

function mainUI:moveDown(node,point,time)
    local moveTo1=CCMoveTo:create(time, ccp(point.x,point.y-20));
    local moveTo2=CCMoveTo:create(0.3, point);
    local acArr=CCArray:create()
    acArr:addObject(moveTo1)
    acArr:addObject(moveTo2)
    local seq=CCSequence:create(acArr);
    node:runAction(seq);
end

function mainUI:moveUp(node,point1,point2,time1,time2)
    local moveTo1=CCMoveTo:create(time1, ccp(point1.x,point1.y-5));
    local moveTo2=CCMoveTo:create(time2, point2);
    local acArr=CCArray:create()
    acArr:addObject(moveTo1)
    acArr:addObject(moveTo2)
    local seq=CCSequence:create(acArr);
    node:runAction(seq);
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function mainUI:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
        local cNum=SizeOfTable(self.btnList)
        return cNum
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize = CCSizeMake(95,105)
              return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()

       local function touch1(tag,object)

            if self.tv:getIsScrolled()==false then
                if newGuidMgr:isNewGuiding()==true then
                    if newGuidMgr.curStep==10 and tag~=11 then
                            do
                                return
                            end
                    end
                    
                    if newGuidMgr.curStep==31 and tag~=13 then
                            do
                                return
                            end
                    end
                end
    
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                PlayEffect(audioCfg.mouseClick)
                self.mainUIBTNTb[self.btnList[idx+1]].callback()


            end

        end
        local select31;
        local select32;
        local menuItem3;
        local titleLb;
		
		local numHeight=25
		local newsNumLabel = GetTTFLabel("0",numHeight)
		newsNumLabel:setTag(10)
	    local capInSet = CCRect(17, 17, 1, 1)
	    local function touchClick()
	    end
		local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet,touchClick)
        newsIcon:setContentSize(CCSizeMake(36,36))
		newsIcon:ignoreAnchorPointForPosition(false)
		newsIcon:setAnchorPoint(CCPointMake(0.5,0))
        newsIcon:setPosition(ccp(75,45))
        newsIcon:addChild(newsNumLabel,1)
		newsIcon:setVisible(false)
        newsNumLabel:setPosition(ccp(newsIcon:getContentSize().width/2,newsIcon:getContentSize().height/2))

        local btnName1 = self.mainUIBTNTb[self.btnList[idx+1]].bName1
        local btnName2 = self.mainUIBTNTb[self.btnList[idx+1]].bName2
        local btnLbStr = self.mainUIBTNTb[self.btnList[idx+1]].btnLb

        select31 = CCSprite:createWithSpriteFrameName(btnName1);
        select32 = CCSprite:createWithSpriteFrameName(btnName2);
        titleLb=GetTTFLabel(getlocal(btnLbStr),22);

        menuItem3 = CCMenuItemSprite:create(select31,select32);
        menuItem3:setAnchorPoint(ccp(0,0));
        menuItem3:setPosition(ccp(0,0))

        titleLb:setPosition(ccp(menuItem3:getContentSize().width/2-8,90))
        titleLb:setColor(G_ColorGreen)
        menuItem3:addChild(titleLb,6)
        menuItem3:addChild(newsIcon,6)
        menuItem3:setTag(idx+11)

        for k,v in pairs(self.btnTipsList) do
            if v==self.btnList[idx+1] then
                self.m_newsNumTab[self.btnList[idx+1]]=newsIcon
            end
        end
        local index=idx+1
        self.m_functionBtnTb[self.btnList[idx+1]]=menuItem3
        local menu3=CCMenu:createWithItem(menuItem3);
        menu3:setAnchorPoint(ccp(0,0));
        menu3:setPosition(ccp(0,0))
        menuItem3:registerScriptTapHandler(touch1)
        menu3:setTouchPriority(-22);

        cell:addChild(menu3,6)
    
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
   elseif fn=="ccTouchMoved" then
       
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   elseif fn=="ccScrollEnable" then
       if newGuidMgr:isNewGuiding()==true then
            return 0
       else
            return 1
       end
   end
end

function mainUI:setNewsNum(num,newsIcon)
    local strLb=newsIcon:getChildByTag(10)
    strLb=tolua.cast(strLb,"CCLabelTTF")
	strLb:setString(num)
	local width=newsIcon:getContentSize().width
	local height=newsIcon:getContentSize().height
	if strLb:getContentSize().width+10>width then
		width=strLb:getContentSize().width+10
	end
	newsIcon:setContentSize(CCSizeMake(width,height))
	strLb:setPosition(getCenterPoint(newsIcon))
	newsIcon:setVisible(true)
end
function mainUI:refreshButtonTips()
    local num=0
    for k,v in pairs(self.m_newsNumTab) do
        if k=="b2" then
            num=SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots())+SizeOfTable(tankVoApi:getRepairTanks())
        elseif k=="b3" then
            num=accessoryVoApi:getLeftECNum()
        elseif k=="b6" then
            num=emailVoApi:getHasUnread()
        end
        if num>0 then
            v:setVisible(true)
            self:setNewsNum(num,v)
        elseif v:isVisible()==true then
            v:setVisible(false)
        end
    end

end

function mainUI:tick()
    self:refreshQueue()
    self:refreshButtonTips()
    self:refreshBuffState()

    if platCfg.platEvaluate[G_curPlatName()]~=nil and base.isEvaluateOnOff==1 and self.isShowEvaluate==false and base.isUserEvaluate~=1 and newGuidMgr:isNewGuiding()==false then
        if playerVoApi:getPlayerLevel()>=platCfg.platEvaluate[G_curPlatName()] then
            popDialog:createEvaluate(sceneGame,30,getlocal("evaluateGift"))
            self.isShowEvaluate=true
        end
    end
    if self.m_rankMainUI~=playerVoApi:getRank() then
        local rankSp=self.mySpriteLeft:getChildByTag(50)
        rankSp:removeFromParentAndCleanup(true)
        self.m_rankMainUI=playerVoApi:getRank();
        local rankStr="rank"..playerVoApi:getRank()..".png"
        local rankSP = CCSprite:createWithSpriteFrameName(rankStr);
        if playerVoApi:getRank()>11 then
            rankStr="rank11.png";
        end
        rankSP:setAnchorPoint(ccp(0.5,0.5));
        rankSP:setPosition(ccp(120+200,self.mySpriteLeft:getContentSize().height/2));
        rankSP:setTag(50)
        self.mySpriteLeft:addChild(rankSP,5);

    end
    self.nameLb:setString(playerVoApi:getPlayerName())
    self.m_labelMoney:setString(FormatNumber(playerVoApi:getGems()))
    self.m_labelGold:setString(FormatNumber(playerVoApi:getGold()))
    self.m_labelR1:setString(FormatNumber(playerVoApi:getR1()))
    self.m_labelR2:setString(FormatNumber(playerVoApi:getR2()))
    self.m_labelR3:setString(FormatNumber(playerVoApi:getR3()))
    self.m_labelR4:setString(FormatNumber(playerVoApi:getR4()))
	self.m_labelLevel:setString(getlocal("fightLevel",{playerVoApi:getPlayerLevel()}))
    if self.needRefreshPlayerInfo==true then
            self.needRefreshPlayerInfo=false
            local timerSprite = self.mySpriteLeft:getChildByTag(10);
            timerSprite=tolua.cast(timerSprite,"CCProgressTimer")
            timerSprite:setPercentage(playerVoApi:getEnergyPercent()*100);


            local expTimerSprite = self.mySpriteLeft:getChildByTag(11);
            expTimerSprite=tolua.cast(expTimerSprite,"CCProgressTimer")
            expTimerSprite:setPercentage(playerVoApi:getLvPercent());
            
            -- self.m_labelMoney:setString(FormatNumber(playerVoApi:getGems()))
            -- self.m_labelGold:setString(FormatNumber(playerVoApi:getGold()))
            -- self.m_labelR1:setString(FormatNumber(playerVoApi:getR1()))
            -- self.m_labelR2:setString(FormatNumber(playerVoApi:getR2()))
            -- self.m_labelR3:setString(FormatNumber(playerVoApi:getR3()))
            -- self.m_labelR4:setString(FormatNumber(playerVoApi:getR4()))
            -- self.m_labelLevel:setString(getlocal("fightLevel",{playerVoApi:getPlayerLevel()}))
            
            local protectResource =buildingVoApi:getProtectResource()
            if playerVoApi:getR1()>protectResource then
                self.m_labelR1:setColor(G_ColorYellowPro);
            else
                self.m_labelR1:setColor(G_ColorWhite);
            end
            if playerVoApi:getR2()>protectResource then
                self.m_labelR2:setColor(G_ColorYellowPro);
            else
                self.m_labelR2:setColor(G_ColorWhite);
            end
            if playerVoApi:getR3()>protectResource then
                self.m_labelR3:setColor(G_ColorYellowPro);
            else
                self.m_labelR3:setColor(G_ColorWhite);
            end
            if playerVoApi:getR4()>protectResource then
                self.m_labelR4:setColor(G_ColorYellowPro);
            else
                self.m_labelR4:setColor(G_ColorWhite);
            end
            if playerVoApi:getGold()>protectResource then
                self.m_labelGold:setColor(G_ColorYellowPro);
            else
                self.m_labelGold:setColor(G_ColorWhite);
            end
            
            local r1P,r2P,r3P,r4P,rGP = buildingVoApi:getResourcePercent();
            
            local r5TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(10),"CCProgressTimer")
            r5TimerSprite:setPercentage(rGP);
            
            local r1TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(11),"CCProgressTimer")
            r1TimerSprite:setPercentage(r1P);
            
            local r2TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(12),"CCProgressTimer")
            r2TimerSprite:setPercentage(r2P);
            
            local r3TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(13),"CCProgressTimer")
            r3TimerSprite:setPercentage(r3P);
            
            local r4TimerSprite = tolua.cast(self.mySpriteRight:getChildByTag(14),"CCProgressTimer")
            r4TimerSprite:setPercentage(r4P);
    end
    
	--外出打仗
	local travelTimeTab=attackTankSoltVoApi:getLeftTimeAll()
	self:showTravelIcon(travelTimeTab)

	--幸运抽奖图标
	local hasReward=dailyVoApi:isFree()
	if hasReward then
		if self.m_flagTab.dailyHasReward==false then
			self:switchDailyIcon()
			self.m_flagTab.dailyHasReward=true
		end
	elseif self.m_flagTab.dailyHasReward==true then
		self:switchDailyIcon()
		self.m_flagTab.dailyHasReward=false
	end

	--新手7天礼包
	local newGiftsState=newGiftsVoApi:hasReward()
    if newGiftsState~=self.m_flagTab.hasNewGifts then
		self:switchNewGiftsIcon()      
		self.m_flagTab.hasNewGifts=newGiftsState
		self:resetLeftIconPos()
	end
    --7天之后显示签到
    if newGiftsState==-1 then
        local isTodaySign=signVoApi:isTodaySign()
        -- if canSign>0 then
        --     canSign=1
        -- end
        if isTodaySign~=self.m_flagTab.isTodaySign then
            self:switchSignIcon()
            self.m_flagTab.isTodaySign=isTodaySign
        end
    end

    --任务
	local tflag=taskVoApi:getRefreshFlag()
	if tflag==0 then
		self:switchTaskIcon()
	end
	--每日领奖图标
	local daily_award=base.daily_award
	if G_isToday(daily_award) then
		if self.m_flagTab.dailyRewardGems==true then
			self:switchDailyRewardIcon()
			self.m_flagTab.dailyRewardGems=false
			self:resetLeftIconPos()
		end
	elseif self.m_flagTab.dailyRewardGems==false then
		self:switchDailyRewardIcon()
		self.m_flagTab.dailyRewardGems=true
		self:resetLeftIconPos()
	end
	--活动
	-- local newYearReward=activityVoApi:canReward("newyear")
	-- if newYearReward~=self.m_flagTab.hasNewYearReward then
	-- 	self:switchNewYearIcon()
	-- 	self.m_flagTab.hasNewYearReward=newYearReward
	-- 	self:resetLeftIconPos()
	-- end

    --敌军来袭倒计时
	local isArrive,attackerName=enemyVoApi:enemyArrive()
	self:showEnemyComingIcon(isArrive,attackerName)
    --协防
    self:switchHelpDefendIcon()
	--vip图标
	self:switchVipIcon()
	
	
	--聊天
	self:setLastChat()
    
    --搜索默认值
    if self.m_labelX~=nil and self.m_labelX:getString()=="-1" then
           if playerVoApi:getMapX()~=-1 then
               self.m_lastSearchXValue=playerVoApi:getMapX()
               self.m_labelX:setString(self.m_lastSearchXValue)
           end
    end
    
    if self.m_labelY~=nil and self.m_labelY:getString()=="-1" then
           if playerVoApi:getMapY()~=-1 then
               self.m_lastSearchYValue=playerVoApi:getMapY()
               self.m_labelY:setString(self.m_lastSearchYValue)
               local allianceName
               if allianceVoApi:isHasAlliance() then
                    allianceName=allianceVoApi:getSelfAlliance().name
               end
                           local params={uid=playerVoApi:getUid(),oldx=0,oldy=0,newx=self.m_lastSearchXValue,newy=self.m_lastSearchYValue,id=100,oid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),type=6,level=1,x=self.m_lastSearchXValue,y=self.m_lastSearchYValue,ptEndTime=playerVoApi:getProtectEndTime(),power=playerVoApi:getPlayerPower(),rank=playerVoApi:getRank(),pic=playerVoApi:getPic(),allianceName=allianceName}
                                      chatVoApi:sendUpdateMessage(3,params)
           end
    end
    
	if self.m_showWelcome==true then
        if newGuidMgr:isNewGuiding()==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("welcomePlayerTip",{playerVoApi:getPlayerName()}),30)
        end
		self.m_showWelcome=false
	end
	if newGuidMgr:isNewGuiding() then
		self:resetLeftFlicker(false)
	else
		self:resetLeftFlicker(true)
	end
    if base.isNd==1 and base.nextDay==nil and self.isShowNextDay==false and G_getWeeTs(base.serverTime) ~= G_getWeeTs(playerVoApi:getRegdate()) and newGuidMgr:isNewGuiding()==false then

        self.isShowNextDay=true
        popDialog:createPowerSurge(sceneGame,30,getlocal("powerSurgeTitle2"),getlocal("powerSurgeDesc2"),2)
        self.m_isShowDaily=true

    elseif self.m_isShowDaily==nil or self.m_isShowDaily==false then
		self.m_isShowDaily=true
		if dailyVoApi:isFreeByType(1) and newGuidMgr:isNewGuiding()==false then
            if G_isIOS()==true then
                self:showDailyDialog()
            end
		end
    end


    --显示公告
    -- self:switchNoticeIcon()

    local acAndNoteState = activityVoApi:hadNewActivity() == true or noteVoApi:hadNewNote() == true or activityVoApi:oneCanReward() == true
    local hadAcAndNote = activityVoApi:hadActivity() or noteVoApi:hadNote() or dailyActivityVoApi:getActivityNum()>0
    local newAcAndNoteNum = activityVoApi.newNum + noteVoApi.newNum

    if self.m_flagTab.acAndNoteState ~=  acAndNoteState or self.m_flagTab.hadAcAndNote ~=  hadAcAndNote or self.m_flagTab.newAcAndNoteNum ~= newAcAndNoteNum then -- 判断是否需要刷新
        if self.m_flagTab.acAndNoteState ~=  acAndNoteState then
            self.m_flagTab.acAndNoteState = acAndNoteState
        end
        if self.m_flagTab.hadAcAndNote ~=  hadAcAndNote then
            self.m_flagTab.hadAcAndNote = hadAcAndNote
        end

        if self.m_flagTab.newAcAndNoteNum ~= newAcAndNoteNum then
            self.m_flagTab.newAcAndNoteNum = newAcAndNoteNum
        end
        self:switchActivityAndNoteIcon()
        self:resetLeftIconPos()
    end

    self:showFBInviteBtn()
    -- 在线礼包
    self:showOnlincePackageBtn()
    if self.onlinePackageBtn ~= nil then
      local dialog = self.onlinePackageBtn.dialog
      if  dialog~= nil and dialog:checkIfBoxOpen() == true then
          dialog:updateOnlinePackage()
      end
    end
    self:judgeShowAccessoryGuide()
    
    --[[
    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then

        end
    end
    local dataTb={p2=1}
    socketHelper:adminAddprop(dataTb,callback)
    ]]
end

function mainUI:showOnlincePackageBtn()
  local t = playerVo.onlineTime
  if t == nil or t < 0 then
      do
          return
      end
  end

  if newGuidMgr:isNewGuiding() == false and playerVoApi:checkIfGetAllOnlinePackage() == false and base.ifOnlinePackageOpen==1  then -- 在线礼包没有领取完
    if self.onlinePackageBtn == nil then
      local function onclick()
        if newGuidMgr:isNewGuiding() ==true then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        self.onlinePackageBtn.dialog = popDialog:createOnlinePackage(sceneGame,3)
      end
      local iconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",onclick);
      iconBg:setAnchorPoint(ccp(0.5,0.5))
      iconBg:setPosition(ccp(G_VisibleSizeWidth-iconBg:getContentSize().width/2-250,G_VisibleSizeHeight-185))
      self.myUILayer:addChild(iconBg,1);
      iconBg:setTouchPriority(-24);
      
      local icon = CCSprite:createWithSpriteFrameName(playerCfg.onlinePackage[playerVo.onlinePackage + 1].icon) -- todo 动态获取
      icon:setPosition(getCenterPoint(iconBg))
      iconBg:addChild(icon,1);
      
      local scaleX =  iconBg:getContentSize().width/icon:getContentSize().width
      local scaleY =  iconBg:getContentSize().height/icon:getContentSize().height
      icon:setScaleX(scaleX)
      icon:setScaleY(scaleY)

      -- 更新按钮状态
      -- local tLable=GetTTFLabel(getlocal("canReward"),30)
      -- tLable:setAnchorPoint(ccp(0.5,0.5))
      -- tLable:setPosition(ccp(icon:getContentSize().width/2,50))
      -- icon:addChild(tLable,1)
      -- tLable:setColor(G_ColorYellowPro)
      -- 时间
      local function cellClick( ... )
      end

      local timeBg = LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",CCRect(5, 5, 1, 1),cellClick)
      timeBg:setContentSize(CCSizeMake(100, 30))
      timeBg:setAnchorPoint(ccp(0.5,0))
      timeBg:setPosition(ccp(icon:getContentSize().width/2,0))
      icon:addChild(timeBg,2)
      
      local needTime = playerVoApi:getLastNeedOnlineTime()
      local showTime = GetTimeForItemStrState(needTime)
      local timeLable=GetTTFLabel(tostring(showTime),30)
      timeLable:setAnchorPoint(ccp(0.5,0.5))
      timeLable:setPosition(ccp(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2))
      timeBg:addChild(timeLable)
      timeLable:setColor(G_ColorYellowPro)

      -- self.onlinePackageBtn={icon=iconBg, tLable = tLable, timeLable = timeLable}
      self.onlinePackageBtn={icon=iconBg, timeLable = timeLable}
      self.m_rightTopIconTab.icon2 = iconBg
      self:resetRightTopIconPos()
    end

    if self.onlinePackageBtn ~= nil then
      local icon = self.onlinePackageBtn.icon
      -- local tLable = self.onlinePackageBtn.tLable
      local timeLable = self.onlinePackageBtn.timeLable
      local flicker = self.onlinePackageBtn.flicker
      local showTime = GetTimeForItemStrState(playerVoApi:getLastNeedOnlineTime())
      timeLable:setString(tostring(showTime))
      if playerVoApi:getLastNeedOnlineTime() == 0 then
        -- tLable:setVisible(true)
        if flicker == nil then
          flicker = G_addFlicker(icon,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        end
        self.onlinePackageBtn.flicker = flicker
      else
        -- tLable:setVisible(false)
        if  flicker~= nil then
          flicker:removeFromParentAndCleanup(true)
          self.onlinePackageBtn.flicker = nil
        end
      end
    end
  else
    if self.onlinePackageBtn ~= nil then
      local icon = self.onlinePackageBtn.icon
      icon:removeFromParentAndCleanup(true) 
      self.onlinePackageBtn = nil
      self.m_rightTopIconTab.icon2 = nil
      self:resetRightTopIconPos()
    end
  end

end

function mainUI:showFBInviteBtn()
    if (base.ifFriendOpen==1 and self.fbInviteBtnHasShow==false and newGuidMgr:isNewGuiding()==false and G_curPlatName()~="androidlongzhong" and G_curPlatName()~="efunandroidmemoriki" and G_curPlatName()~="efunandroid360") then
        local function onclick()
            if newGuidMgr:isNewGuiding() ==true then
                do
                    return
                end
            end
            if(G_curPlatName()=="4") or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="efunandroidnm" or G_curPlatName()=="15"then
                local tmpTb={}
                tmpTb["action"]="showSocialView"
                tmpTb["parms"]={}
                tmpTb["parms"]["uid"]=tostring(G_getTankUserName())
                tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
                tmpTb["parms"]["gameid"]=tostring(playerVoApi:getUid())

                local cjson=G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            else
                local td=friendDialog:new()
                local title=getlocal("friend_title")
                local tbArr={getlocal("friend_tab_gift"),getlocal("friend_title")}
                local tbSubArr={getlocal("RankScene_level"),getlocal("showAttackRank"),getlocal("RankScene_star_num")}
                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,title,true,3)
                sceneGame:addChild(dialog,3)
            end
        end
        local buttonInvite
        
        if G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="12" then
            buttonInvite=GetButtonItem("VK.png","VK_down.png","VK_down.png",onclick,nil,nil,nil)
        else
            buttonInvite=GetButtonItem("facebook.png","facebook_down.png","facebook_down.png",onclick,nil,nil,nil)
        end
        


            buttonInvite:setAnchorPoint(ccp(0.5,0.5))
            local InviteMenu=CCMenu:createWithItem(buttonInvite);
            InviteMenu:setPosition(ccp(G_VisibleSizeWidth-buttonInvite:getContentSize().width/2-buttonInvite:getContentSize().width,G_VisibleSizeHeight-185))
            InviteMenu:setTouchPriority(-23);
            self.myUILayer:addChild(InviteMenu,10)
            self.m_rightTopIconTab.icon1 = InviteMenu
            self:resetRightTopIconPos()
            self.fbInviteBtnHasShow=true  
    end
end


function mainUI:switchVipIcon()
	local viplevel=playerVoApi:getVipLevel()
	if self.m_vipLevel==nil or self.m_vipLevel~=viplevel then
		self.m_vipLevel=viplevel
		if self.m_menuToggleVip then	
			self.myUILayer:removeChild(self.m_menuToggleVip,true)
			self.m_menuToggleVip=nil;
		end	
	    local function openVipView(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
	        if newGuidMgr:isNewGuiding() then
	        	do return end
	        end
            PlayEffect(audioCfg.mouseClick)
            require "luascript/script/game/scene/gamedialog/vipDialog"
	        local vd1 = vipDialog:new();
            local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,3)

	        sceneGame:addChild(vd,3);
	    end
        


	    local vip1 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle.png");
	    local vip2 = CCSprite:createWithSpriteFrameName("mainUiTop_topMiddle_down.png");
	    local menuItemVip = CCMenuItemSprite:create(vip1,vip2);
	    local vipLevel = CCSprite:createWithSpriteFrameName("Vip"..playerVoApi:getVipLevel()..".png");
	    vipLevel:setPosition(vip1:getContentSize().width/2,vip1:getContentSize().height/2);
	    vipLevel:setAnchorPoint(ccp(0.5,0.5));
	    --menuItemVip:addChild(vipLevel,30);
	    --menuItemVip:setTag(51);
    
	    self.m_pointVip = ccp(menuItemVip:getContentSize().width/2-2,G_VisibleSizeHeight-152);

	    self.m_menuToggleVip = CCMenuItemToggle:create(menuItemVip);
	    self.m_menuToggleVip:registerScriptTapHandler(openVipView);
        
        menuItemVip:setAnchorPoint(ccp(0,1));

        local vipButton=GetButtonItem("mainUiTop_topMiddle.png","mainUiTop_topMiddle_down.png","mainUiTop_topMiddle_down.png",openVipView,nil,nil,nil)
        vipButton:setAnchorPoint(ccp(0,0));
        vipButton:setTag(51);
        vipButton:addChild(vipLevel,30);

	    local menuAllVip=CCMenu:createWithItem(vipButton);
	    menuAllVip:setPosition(self.m_pointVip);       
        menuAllVip:setPosition(self.mySpriteLeft:getContentSize().width+12,5);
        menuAllVip:setTouchPriority(-23);
        self.mySpriteMain:addChild(menuAllVip)

	    --self.myUILayer:addChild(menuAllVip,1);
	end
end
function mainUI:iconFlicker(icon,m_iconScaleX,m_iconScaleY)
    return G_addFlicker(icon, 1/(m_iconScaleX/2), 1/(m_iconScaleY/2))
end

function mainUI:showDailyDialog()
    if G_checkClickEnable()==false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
	--dailyVoApi:updateRewardNum()
    require "luascript/script/game/scene/gamedialog/dailyDialog"
    local dd = dailyDialog:new()
	local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
    local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("daily_scene_title"),true,3);
    sceneGame:addChild(vd,3);
    
end
function mainUI:showNewGiftsDialog()
    if G_checkClickEnable()==false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    require "luascript/script/game/scene/gamedialog/newGiftsDialog"
    local nd = newGiftsDialog:new()
	--local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
	local tbArr={}
    local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("newGiftsTitle"),true,3);
    sceneGame:addChild(vd,3);
    
end
function mainUI:showSignDialog()
    if G_checkClickEnable()==false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    require "luascript/script/game/scene/gamedialog/signDialog"
    local nd = signDialog:new()
    local tbArr={}
    local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("signTitle"),true,3);
    sceneGame:addChild(vd,3);
end

function mainUI:showAcAndNote()
    if G_checkClickEnable()==false then
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    if self.dialog_acAndNote ~= nil then
        self.dialog_acAndNote = nil
    end
    activityVoApi:updateAllShowState()
    self.dialog_acAndNote = activityAndNoteDialog:new()
    local tbArr={getlocal("activity"),getlocal("dailyActivity_title"),getlocal("note")}
    local vd = self.dialog_acAndNote:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activityAndNote_title"),true,3);
    if activityVoApi:hadNewActivity() == false and noteVoApi:hadNewNote() == true then
        self.dialog_acAndNote:tabClick(2)
    end
    sceneGame:addChild(vd,3);
end

function mainUI:updateAcAndNote()
    if self.dialog_acAndNote ~= nil then
        self.dialog_acAndNote:updateNewNum()
    end
end

function mainUI:showTaskDialog()
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
	taskVoApi:updateDailyTaskNum()
    require "luascript/script/game/scene/gamedialog/taskDialog"
    require "luascript/script/game/scene/gamedialog/taskDialogTab1"
    require "luascript/script/game/scene/gamedialog/taskDialogTab2"
    local td = taskDialog:new()
    local tbArr={getlocal("taskPage"),getlocal("dailyTaskPage")}
    local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("task"),true,3)
    sceneGame:addChild(vd,3)
end
function mainUI:switchStateIcon()
    
    local function touchLuaSp()
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
        require "luascript/script/game/scene/gamedialog/buffStateDialog"
        local vrd=buffStateDialog:new()
        local vd = vrd:init(4)
       

    end
    self.m_luaSpBuff = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",touchLuaSp);
    self.m_luaSpBuff:setAnchorPoint(ccp(0,0))
    self.m_luaSpBuff:setPosition(0,G_VisibleSizeHeight-225-10);
    self.m_luaSpBuff:setTag(101);
    self.myUILayer:addChild(self.m_luaSpBuff,1);
    self.m_luaSpBuff:setTouchPriority(-21);
    
    local spriteSp1 = CCSprite:createWithSpriteFrameName("Icon_mainui_01.png")
    spriteSp1:setPosition(getCenterPoint(self.m_luaSpBuff))
    self.m_luaSpBuff:addChild(spriteSp1,1);
    
    local scaleX =  self.m_luaSpBuff:getContentSize().width/spriteSp1:getContentSize().width
    local scaleY =  self.m_luaSpBuff:getContentSize().height/spriteSp1:getContentSize().height
    spriteSp1:setScaleX(scaleX)
    spriteSp1:setScaleY(scaleY)
    self:refreshStateIcon()
	if self.m_leftIconTab.icon1~=nil then
		self.m_leftIconTab.icon1=nil
	end
	self.m_leftIconTab.icon1=self.m_luaSpBuff
end
function mainUI:switchDailyIcon()
	if self.m_dailySp then	
		self.myUILayer:removeChild(self.m_dailySp,true)
		self.m_dailySp=nil;
		
		if self.m_leftIconTab.icon2~=nil then
			self.m_leftIconTab.icon2=nil
		end
		if self.m_leftIconTab.flicker2~=nil then
			self.m_leftIconTab.flicker2=nil
		end
	end	
	self.m_dailySp=LuaCCSprite:createWithSpriteFrameName("item_baoxiang_09.png",self.showDailyDialog)
	self.m_dailySp:setTag(1001)
    self.m_dailySp:setAnchorPoint(ccp(0,0))
    self.m_dailySp:setTouchPriority(-23)
    self.m_dailySp:setPosition(0,G_VisibleSizeHeight-304);
    self.m_dailySp:setScaleX(self.m_iconScaleX)
    self.m_dailySp:setScaleY(self.m_iconScaleY)
    self.myUILayer:addChild(self.m_dailySp);	
	self.m_flagTab.dailyHasReward=false
	if dailyVoApi:isFree() then
		self.m_flagTab.dailyHasReward=true
		-- self.m_leftIconTab.flicker2=self:iconFlicker(self.m_dailySp,self.m_iconScaleX,self.m_iconScaleY)
	    self.m_leftIconTab.flicker2=G_addFlicker(self.m_dailySp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
    end
	self.m_leftIconTab.icon2=self.m_dailySp
end
function mainUI:switchNewGiftsIcon()
	if self.m_newGiftsSp then	
		self.myUILayer:removeChild(self.m_newGiftsSp,true)
		self.m_newGiftsSp=nil;
		
		if self.m_leftIconTab.icon3~=nil then
			self.m_leftIconTab.icon3=nil
		end
		if self.m_leftIconTab.flicker3~=nil then
			self.m_leftIconTab.flicker3=nil
		end
	end
	local newGiftsState=newGiftsVoApi:hasReward()
	if newGiftsState~=-1 then
		self.m_newGiftsSp=LuaCCSprite:createWithSpriteFrameName("7days.png",self.showNewGiftsDialog)
		self.m_newGiftsSp:setTag(1008)
	    self.m_newGiftsSp:setAnchorPoint(ccp(0,0))
	    self.m_newGiftsSp:setTouchPriority(-23)
	    self.m_newGiftsSp:setPosition(0,G_VisibleSizeHeight-304-80)
	    self.m_newGiftsSp:setScaleX(self.m_iconScaleX)
	    self.m_newGiftsSp:setScaleY(self.m_iconScaleY)
	    self.myUILayer:addChild(self.m_newGiftsSp)
		if newGiftsState==1 then
			-- self.m_leftIconTab.flicker3=self:iconFlicker(self.m_newGiftsSp,self.m_iconScaleX,self.m_iconScaleY)
		    self.m_leftIconTab.flicker3=G_addFlicker(self.m_newGiftsSp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        end
		self.m_leftIconTab.icon3=self.m_newGiftsSp
	else
		--[[
		if self.m_taskSp then
			self.m_taskSp:setPosition(0,G_VisibleSizeHeight-304-80);
		end
		if self.m_enemyComingSp then
			self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*2);
		end
		]]
	end
	self.m_flagTab.hasNewGifts=newGiftsState
end
function mainUI:switchSignIcon()
    if self.m_signIcon then   
        self.myUILayer:removeChild(self.m_signIcon,true)
        self.m_signIcon=nil;
        
        if self.m_leftIconTab.icon3~=nil then
            self.m_leftIconTab.icon3=nil
        end
        if self.m_leftIconTab.flicker3~=nil then
            self.m_leftIconTab.flicker3=nil
        end
        self:resetLeftIconPos()
    end
    if base.isSignSwitch==0 then
        do return end
    end

    self.m_signIcon=LuaCCSprite:createWithSpriteFrameName("30dayIcon.png",self.showSignDialog)
    self.m_signIcon:setTag(1009)
    self.m_signIcon:setAnchorPoint(ccp(0,0))
    self.m_signIcon:setTouchPriority(-23)
    self.m_signIcon:setPosition(0,G_VisibleSizeHeight-304-80)
    self.m_signIcon:setScaleX(self.m_iconScaleX)
    self.m_signIcon:setScaleY(self.m_iconScaleY)
    self.myUILayer:addChild(self.m_signIcon)
    local isTodaySign=signVoApi:isTodaySign()
    if isTodaySign==false then
        -- self.m_leftIconTab.flicker3=self:iconFlicker(self.m_signIcon,self.m_iconScaleX,self.m_iconScaleY)
        self.m_leftIconTab.flicker3=G_addFlicker(self.m_signIcon,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
    end
    self.m_leftIconTab.icon3=self.m_signIcon

    self:resetLeftIconPos()
end
function mainUI:switchTaskIcon()
	local pic=taskVoApi:showIcon()
	local m_iconScaleX,m_iconScaleY
    if pic and pic~="" then
        if self.m_taskSp then	
            self.myUILayer:removeChild(self.m_taskSp,true)
            self.m_taskSp=nil;
			
			if self.m_leftIconTab.icon4~=nil then
				self.m_leftIconTab.icon4=nil
			end
			if self.m_leftIconTab.flicker4~=nil then
				self.m_leftIconTab.flicker4=nil
			end
        end	
        local function showLeftTaskDialog()
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            PlayEffect(audioCfg.mouseClick)
            if newGuidMgr:isNewGuiding() then --新手引导
                    newGuidMgr:toNextStep()
            end
            self:showTaskDialog()
        end
		local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
		if startIndex~=nil and endIndex~=nil then
			self.m_taskSp=GetBgIcon(pic,showLeftTaskDialog,self.m_taskSp)
		else
			self.m_taskSp=LuaCCSprite:createWithSpriteFrameName(pic,showLeftTaskDialog)
	        if self.m_taskSp:getContentSize().width>100 then
	            self.m_taskSp:setScaleX(2/3*self.m_iconScaleX)
	            self.m_taskSp:setScaleY(2/3*self.m_iconScaleY)
				m_iconScaleX=2/3*self.m_iconScaleX
				m_iconScaleY=2/3*self.m_iconScaleY
			else
				self.m_taskSp:setScaleX(self.m_iconScaleX)
				self.m_taskSp:setScaleY(self.m_iconScaleY)
				m_iconScaleX=self.m_iconScaleX
				m_iconScaleY=self.m_iconScaleY
	        end
		end
		self.m_taskSp:setTag(1002)
	    self.m_taskSp:setAnchorPoint(ccp(0,0))
	    self.m_taskSp:setTouchPriority(-23)
        self.myUILayer:addChild(self.m_taskSp);
        --self.m_taskSp:setPosition(0,G_VisibleSizeHeight-382);
		if self.m_newGiftsSp then
			self.m_taskSp:setPosition(0,G_VisibleSizeHeight-304-80*2)
		else
			self.m_taskSp:setPosition(0,G_VisibleSizeHeight-304-80)
		end
		self.m_leftIconTab.icon4=self.m_taskSp
    end
    local taskIdx=6
	local tasksNum=taskVoApi:hadCompletedTask()
	if tasksNum>0 then
		if self.m_taskSp then
			-- self.m_leftIconTab.flicker4=self:iconFlicker(self.m_taskSp,m_iconScaleX,m_iconScaleY)
		    self.m_leftIconTab.flicker4=G_addFlicker(self.m_taskSp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        end

		-- if self.m_newsNumTab and self.m_newsNumTab[taskIdx] then
		-- 	if self.m_newsNumTab[taskIdx]:isVisible()==false then
		-- 		self.m_newsNumTab[taskIdx]:setVisible(true)
		-- 	end
		-- 	local newsNumLabel=tolua.cast(self.m_newsNumTab[taskIdx]:getChildByTag(200+taskIdx),"CCLabelTTF")
		-- 	if newsNumLabel:getString()~=tostring(tasksNum) then
		-- 		self:setNewsNum(tasksNum,tolua.cast(self.m_newsNumTab[taskIdx]:getChildByTag(200+taskIdx),"CCLabelTTF"),self.m_newsNumTab[taskIdx])
		-- 	end
		-- end
	else
		-- if self.m_newsNumTab and self.m_newsNumTab[taskIdx] and self.m_newsNumTab[taskIdx]:isVisible()==true then
		-- 	self.m_newsNumTab[taskIdx]:setVisible(false)
		-- end
	end
	taskVoApi:setRefreshFlag(1)
    self:resetLeftIconPos()
end
function mainUI:switchDailyRewardIcon()
    if G_curPlatName()~="0" then
        do return end
    end
	if self.m_dailyRewardSp then	
		self.myUILayer:removeChild(self.m_dailyRewardSp,true)
		self.m_dailyRewardSp=nil
		
		if self.m_leftIconTab.icon6~=nil then
			self.m_leftIconTab.icon6=nil
		end
		if self.m_leftIconTab.flicker6~=nil then
			self.m_leftIconTab.flicker6=nil
		end
	end
	if G_isToday(base.daily_award) then
		self.m_flagTab.dailyRewardGems=false
		--[[
		if self.m_enemyComingSp then
			if self.m_newGiftsSp then
				self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*3)
			else
				self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*2)
			end
		end
		]]
	else
		self.m_flagTab.dailyRewardGems=true
		local function dailyRewardHandler(hd,fn,idx)
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
			local function gratisgoodsHandler(fn,data)
				if base:checkServerData(data)==true then
					--smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_scene_get"),rewardStr,nil,4)
					if self.m_dailyRewardSp then	
						self.myUILayer:removeChild(self.m_dailyRewardSp,true)
						self.m_dailyRewardSp=nil
						
						if self.m_leftIconTab.icon6~=nil then
							self.m_leftIconTab.icon6=nil
						end
						if self.m_leftIconTab.flicker6~=nil then
							self.m_leftIconTab.flicker6=nil
						end
						self:resetLeftIconPos()
						local honorNum=playerVoApi:getRankDailyHonor(playerVoApi:getRank())
						local gemNum=playerCfg.dailyAwardGem
						local rewardStr = getlocal("dailyRewardDesc",{gemNum,honorNum})
						local award={u={{honors=honorNum},{gem=gemNum}}}
						award=FormatItem(award)
						popDialog:createNewGuid(sceneGame,4,getlocal("dailyRewardTitle"),rewardStr,award)
					end
				end
			end
			socketHelper:gratisgoods(gratisgoodsHandler)
		end
		self.m_dailyRewardSp=LuaCCSprite:createWithSpriteFrameName("Icon_prestige.png",dailyRewardHandler)
		self.m_dailyRewardSp:setTag(1009)
	    self.m_dailyRewardSp:setAnchorPoint(ccp(0,0))
	    self.m_dailyRewardSp:setTouchPriority(-23)
	    self.m_dailyRewardSp:setScaleX(self.m_iconScaleX)
	    self.m_dailyRewardSp:setScaleY(self.m_iconScaleY)
	    self.myUILayer:addChild(self.m_dailyRewardSp)
		if self.m_newGiftsSp then
			self.m_dailyRewardSp:setPosition(0,G_VisibleSizeHeight-304-80*3)
		else
			self.m_dailyRewardSp:setPosition(0,G_VisibleSizeHeight-304-80*2)
		end
		-- self.m_leftIconTab.flicker6=self:iconFlicker(self.m_dailyRewardSp,self.m_iconScaleX,self.m_iconScaleY)
        self.m_leftIconTab.flicker6=G_addFlicker(self.m_dailyRewardSp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
    
		--[[
		if self.m_enemyComingSp then
			if self.m_newGiftsSp then
				self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*4)
			else
				self.m_enemyComingSp:setPosition(0,G_VisibleSizeHeight-304-80*3)
			end
		end
		]]
		self.m_leftIconTab.icon6=self.m_dailyRewardSp
	end
end
function mainUI:showEnemyComingIcon(isArrive,attackerName)
	local diffTime=isArrive
	if diffTime>=0 then
		if self.m_enemyComingSp~=nil and self.m_countdownLabel~=nil then	
			self.m_countdownLabel:setString(GetTimeStr(diffTime))
		else
			local function showEnemyComingDialog(object,name,tag)
				smallDialog:showEnemyComingDialog("PanelHeaderPopupRed.png",CCSizeMake(600,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,true,getlocal("attackedTitle"),3,enemyAll)
			end	
			self.m_enemyComingSp=LuaCCSprite:createWithSpriteFrameName("Icon_warn.png",showEnemyComingDialog)
			self.m_enemyComingSp:setTag(1003)
		    self.m_enemyComingSp:setAnchorPoint(ccp(0,0))
		    self.m_enemyComingSp:setTouchPriority(-23)
			if self.m_iconScaleX==nil or self.m_iconScaleY==nil then
				self.m_iconScaleX=0.78
				self.m_iconScaleY=0.78
			end
		    self.m_enemyComingSp:setScaleX(self.m_iconScaleX)
		    self.m_enemyComingSp:setScaleY(self.m_iconScaleY)
			self.m_countdownLabel=GetTTFLabel(GetTimeStr(diffTime),20/self.m_iconScaleX)
		    --self.m_countdownLabel:setAnchorPoint(ccp(0.5,0))
		    --self.m_countdownLabel:setPosition(ccp(self.m_enemyComingSp:getContentSize().width/2,0))
		    local capInSet = CCRect(5, 5, 1, 1);
		    local function touchClick()
   		    end
	        local lbSpBg =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
	        lbSpBg:setContentSize(CCSizeMake(100,20/self.m_iconScaleX))
			lbSpBg:ignoreAnchorPointForPosition(false)
			lbSpBg:setAnchorPoint(CCPointMake(0.5,0))
	        lbSpBg:setPosition(ccp(self.m_enemyComingSp:getContentSize().width/2,0))
	        --lbSpBg:setTag(3)
	        lbSpBg:addChild(self.m_countdownLabel,4)
			self.m_countdownLabel:setPosition(getCenterPoint(lbSpBg))
		    self.m_enemyComingSp:addChild(lbSpBg,1)
			
			local height=G_VisibleSizeHeight-304-80*2
			if self.m_newGiftsSp then
				height=height-80
			end
			if self.m_dailyRewardSp then
				height=height-80
			end
		    self.m_enemyComingSp:setPosition(0,height)
			self.myUILayer:addChild(self.m_enemyComingSp);
		
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptEnemyComing",{attackerName}),30)
			PlayEffect(audioCfg.attack_alert)
			self.m_leftIconTab.icon7=self.m_enemyComingSp
			self:resetLeftIconPos()
		end
        --[[
		if diffTime==0 then
				local hasEnemy=enemyVoApi:hasEnemy()
				if hasEnemy==true then
				else
					if self.m_enemyComingSp then
						self.myUILayer:removeChild(self.m_enemyComingSp,true)
						self.m_enemyComingSp=nil
						self.m_countdownLabel=nil

					end
				end
		end
        ]]
	else
		if self.m_enemyComingSp then
			self.myUILayer:removeChild(self.m_enemyComingSp,true)
			self.m_enemyComingSp=nil
			self.m_countdownLabel=nil
			
			if self.m_leftIconTab.icon7~=nil then
				self.m_leftIconTab.icon7=nil
			end
			self:resetLeftIconPos()
		end
	end
end

function mainUI:switchNewYearIcon()
	if self.m_newYearIcon then	
		self.myUILayer:removeChild(self.m_newYearIcon,true)
		self.m_newYearIcon=nil;
		
		if self.m_leftIconTab.icon9~=nil then
			self.m_leftIconTab.icon9=nil
		end
		if self.m_leftIconTab.flicker9~=nil then
			self.m_leftIconTab.flicker9=nil
		end
		self:resetLeftIconPos()
	end
	local newYearState=activityVoApi:canReward("newyear")
	if newYearState==true then
		local function newyearRewardHandler(hd,fn,idx)
			local function newyearRewardCallback(fn,data)
				if base:checkServerData(data)==true then
                -- if true then
					if self.m_newYearIcon then	
						self.myUILayer:removeChild(self.m_newYearIcon,true)
						self.m_newYearIcon=nil
						
						if self.m_leftIconTab.icon9~=nil then
							self.m_leftIconTab.icon9=nil
						end
						if self.m_leftIconTab.flicker9~=nil then
							self.m_leftIconTab.flicker9=nil
						end
						self:resetLeftIconPos()
						local activityVo=activityVoApi:getActivityVo("newyear")
						local award=activityVo.award
						popDialog:createNewGuid(sceneGame,4,getlocal("activity_newYearTitle"),getlocal("activity_newYearDesc"),award)
					end
				end
			end
            -- newyearRewardCallback(nil,nil)
			socketHelper:activeReward("newyear",newyearRewardCallback)
		end
		--self.m_newYearIcon=LuaCCSprite:createWithSpriteFrameName("7days.png",newyearRewardHandler)
		self.m_newYearIcon=LuaCCSprite:createWithFileName("public/newYearIcon.png",newyearRewardHandler)
		self.m_newYearIcon:setTag(1010)
	    self.m_newYearIcon:setAnchorPoint(ccp(0,0))
	    self.m_newYearIcon:setTouchPriority(-23)
	    self.m_newYearIcon:setPosition(0,G_VisibleSizeHeight-304-80)
	    self.m_newYearIcon:setScaleX(self.m_iconScaleX)
	    self.m_newYearIcon:setScaleY(self.m_iconScaleY)
	    self.myUILayer:addChild(self.m_newYearIcon)
		-- self.m_leftIconTab.flicker9=self:iconFlicker(self.m_newYearIcon,self.m_iconScaleX,self.m_iconScaleY)
		self.m_leftIconTab.flicker9=G_addFlicker(self.m_newYearIcon,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        self.m_leftIconTab.icon9=self.m_newYearIcon
		self:resetLeftIconPos()
	end
	self.m_flagTab.hasNewYearReward=newYearState
end

--只有360平台用
function mainUI:switchNoticeIcon()
    if G_curPlatName()~="qihoo" then
        do return end
    end
    if platFormCfg and platFormCfg.noticeTitle and platFormCfg.noticeContent then
        local isShowNoticeIcon=false
        if base.curZoneID==5 then
            G_noticeEndTime=1392688800
        elseif base.curZoneID==6 then
            G_noticeEndTime=1392861600
        else
            G_noticeEndTime=0
        end
        if base.serverTime>G_noticeStartTime and base.serverTime<G_noticeEndTime then
            --[[
            local showNoticeTime=CCUserDefault:sharedUserDefault():getIntegerForKey(G_local_showNoticeTime)
            if showNoticeTime==nil or showNoticeTime==0 then
                isShowNoticeIcon=true
            elseif showNoticeTime<G_getWeeTs(base.serverTime) then
                isShowNoticeIcon=true
            end
            ]]
            isShowNoticeIcon=true
        end
        
        if isShowNoticeIcon==true then
            if self.m_noticeIcon==nil then
                local function showNoticeHandler(hd,fn,idx)
                    local noticeTitle=""
                    local noticeContent=""
                    if platFormCfg and platFormCfg.noticeTitle and platFormCfg.noticeContent then
                        local tmpContent=platFormCfg["noticeContent"..base.curZoneID]
                        if tmpContent==nil then
                            tmpContent=platFormCfg.noticeContent
                        end
                        smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),platFormCfg.noticeTitle,tmpContent,true,3)
                        
                        CCUserDefault:sharedUserDefault():setIntegerForKey(G_local_showNoticeTime,base.serverTime)
                        CCUserDefault:sharedUserDefault():flush()

                        self.myUILayer:removeChild(self.m_noticeIcon,true)
                        self.m_noticeIcon=nil;
                        
                        if self.m_leftIconTab.icon10    ~=nil then
                            self.m_leftIconTab.icon10    =nil
                        end
                        if self.m_leftIconTab.flicker10~=nil then
                            self.m_leftIconTab.flicker10=nil
                        end
                        self:resetLeftIconPos()
                    end
                end
                --self.m_noticeIcon=LuaCCSprite:createWithSpriteFrameName("Icon_taskDone.png",showNoticeHandler)
                self.m_noticeIcon=LuaCCSprite:createWithFileName("public/newYearIcon.png",showNoticeHandler)
                self.m_noticeIcon:setAnchorPoint(ccp(0,0))
                self.m_noticeIcon:setTouchPriority(-23)
                --self.m_noticeIcon:setPosition(0,G_VisibleSizeHeight-304-80)
                self.m_noticeIcon:setScaleX(self.m_iconScaleX)
                self.m_noticeIcon:setScaleY(self.m_iconScaleY)
                self.myUILayer:addChild(self.m_noticeIcon)
                -- self.m_leftIconTab.flicker10=self:iconFlicker(self.m_noticeIcon,self.m_iconScaleX,self.m_iconScaleY)
                self.m_leftIconTab.flicker10=G_addFlicker(self.m_noticeIcon,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
                self.m_leftIconTab.icon10    =self.m_noticeIcon
                self:resetLeftIconPos()
            else
                self:resetLeftIconPos()
            end
        else
            if self.m_noticeIcon then
                self.myUILayer:removeChild(self.m_noticeIcon,true)
                self.m_noticeIcon=nil;
                
                if self.m_leftIconTab.icon10    ~=nil then
                    self.m_leftIconTab.icon10    =nil
                end
                if self.m_leftIconTab.flicker10~=nil then
                    self.m_leftIconTab.flicker10=nil
                end
                self:resetLeftIconPos()
            end
        end
    end
end

function mainUI:switchActivityAndNoteIcon()
    --[[
    if G_ifDebug~=1 then
        if G_curPlatName()~="1" and G_curPlatName()~="42" and G_curPlatName()~="qihoo" and G_curPlatName()~="4" and G_curPlatName()~="efunandroiddny" and G_curPlatName()~="androiduc" then
            do
                return
            end
        end
    end
    ]]
    
    if self.m_acAndNoteSp then    
        self.myUILayer:removeChild(self.m_acAndNoteSp,true)
        self.m_acAndNoteSp=nil
        
        if self.m_leftIconTab.icon5~=nil then
            self.m_leftIconTab.icon5=nil
        end
        if self.m_leftIconTab.flicker5~=nil then
            self.m_leftIconTab.flicker5=nil
        end
    end
    if self.m_flagTab.hadAcAndNote == true then
        local function acAndNoteHandler(hd,fn,idx)
               self:showAcAndNote()    
        end
        self.m_acAndNoteSp=LuaCCSprite:createWithSpriteFrameName("acAndNote.png",acAndNoteHandler)
        self.m_acAndNoteSp:setAnchorPoint(ccp(0,0))
        self.m_acAndNoteSp:setTouchPriority(-23)
        self.m_acAndNoteSp:setScaleX(self.m_iconScaleX)
        self.m_acAndNoteSp:setScaleY(self.m_iconScaleY)
        self.myUILayer:addChild(self.m_acAndNoteSp,4)

        if self.m_flagTab.acAndNoteState then
            -- self.m_leftIconTab.flicker5=self:iconFlicker(self.m_acAndNoteSp,self.m_iconScaleX,self.m_iconScaleY)
            self.m_leftIconTab.flicker5=G_addFlicker(self.m_acAndNoteSp,1/(self.m_iconScaleX/2),1/(self.m_iconScaleY/2))
        end
        self.m_leftIconTab.icon5=self.m_acAndNoteSp
        if self.m_flagTab.newAcAndNoteNum > 0 then
            local numHeight=25
            local iconWidth=36
            local iconHeight=36
            local newsNumLabel = GetTTFLabel(tonumber(self.m_flagTab.newAcAndNoteNum),numHeight)
            local capInSet1 = CCRect(17, 17, 1, 1)
            local function touchClick()
            end
            local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
            if newsNumLabel:getContentSize().width+10>iconWidth then
                iconWidth=newsNumLabel:getContentSize().width+10
            end
            newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
            newsIcon:ignoreAnchorPointForPosition(false)
            newsIcon:setAnchorPoint(CCPointMake(1,0.5))
            newsIcon:setPosition(ccp(110,90))
            newsIcon:addChild(newsNumLabel,1)
            newsNumLabel:setPosition(getCenterPoint(newsIcon))
            self.m_acAndNoteSp:addChild(newsIcon)
        end

    end
end
--协防
function mainUI:switchHelpDefendIcon()
    local helpDefendVo=helpDefendVoApi:getTimeLeast()
    local diffTime=0
    if helpDefendVo and helpDefendVo.time then
        diffTime=helpDefendVo.time-base.serverTime
        if diffTime<0 then
            diffTime=0
        end
    end
    if helpDefendVo and SizeOfTable(helpDefendVo)>0 then
        if self.m_helpDefendIcon==nil then
            local function showNoticeHandler(hd,fn,idx)
                allianceSmallDialog:showHelpDefendDialog("PanelHeaderPopup.png",CCSizeMake(600,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),false,true,getlocal("coverTitle"),3)
            end
            self.m_helpDefendIcon=LuaCCSprite:createWithSpriteFrameName("IconHelp.png",showNoticeHandler)
            self.m_helpDefendIcon:setAnchorPoint(ccp(0,0))
            self.m_helpDefendIcon:setTouchPriority(-23)
            self.m_helpDefendIcon:setScaleX(self.m_iconScaleX)
            self.m_helpDefendIcon:setScaleY(self.m_iconScaleY)
            self.myUILayer:addChild(self.m_helpDefendIcon)
            self.m_leftIconTab.icon8=self.m_helpDefendIcon

            self.m_helpDefendLabel=GetTTFLabel(GetTimeStr(diffTime),20/self.m_iconScaleX)

            local capInSet = CCRect(5, 5, 1, 1)
            local function touchClick()
            end
            local lbSpBg =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
            lbSpBg:setContentSize(CCSizeMake(100,20/self.m_iconScaleX))
            lbSpBg:ignoreAnchorPointForPosition(false)
            lbSpBg:setAnchorPoint(CCPointMake(0.5,0))
            lbSpBg:setTag(33)
            lbSpBg:setPosition(ccp(self.m_helpDefendIcon:getContentSize().width/2,0))
            lbSpBg:addChild(self.m_helpDefendLabel,4)
            self.m_helpDefendLabel:setPosition(getCenterPoint(lbSpBg))
            self.m_helpDefendIcon:addChild(lbSpBg,4)

            if diffTime<=0 then
                lbSpBg:setVisible(false)
            end
            self:resetLeftIconPos()
        else
            if self.m_helpDefendIcon:getChildByTag(33) then
                if diffTime>0 then
                    tolua.cast(self.m_helpDefendIcon:getChildByTag(33),"LuaCCScale9Sprite"):setVisible(true)
                    if self.m_helpDefendLabel~=nil then    
                        self.m_helpDefendLabel:setString(GetTimeStr(diffTime))
                    end
                else
                    tolua.cast(self.m_helpDefendIcon:getChildByTag(33),"LuaCCScale9Sprite"):setVisible(false)
                end
            end
            self:resetLeftIconPos()
        end
    else
        if self.m_helpDefendIcon then
            self.m_helpDefendIcon:removeFromParentAndCleanup(true)
            self.m_helpDefendIcon=nil
            self.m_helpDefendLabel=nil
            
            if self.m_leftIconTab.icon8~=nil then
                self.m_leftIconTab.icon8=nil
            end
            -- if self.m_leftIconTab.flicker8~=nil then
            --     self.m_leftIconTab.flicker8=nil
            -- end
            self:resetLeftIconPos()
        end
        --测试数据
        -- data={{id=1,name="player1",ts=1402969845,status=0},{id=2,name="player2",ts=0,status=1},{id=3,name="player3",ts=1392870545,status=2},{id=3,name="player4",ts=1392979845,status=1},{id=3,name="player5",ts=1333870545,status=1}}
        -- helpDefendVoApi:formatData(data)
    end
end

function mainUI:resetLeftIconPos()
	if self.m_leftIconTab then
		local height=G_VisibleSizeHeight-304-10
		for i=2,15 do
			if self.m_leftIconTab["icon"..i]~=nil then
                if self.m_leftIconTab["icon"..i].getPositionY~=height then
				    self.m_leftIconTab["icon"..i]:setPosition(0,height)
                end
				height=height-78
			end
		end
	end
end

-- 右上角按钮（在线礼包和facebook 好友列表按钮）
function mainUI:resetRightTopIconPos()
  if self.m_rightTopIconTab then
    local iconX = G_VisibleSizeWidth - 135
    local icon = nil
    for i=1,2 do
      icon = self.m_rightTopIconTab["icon"..i]
      if icon~=nil then
          if icon:getPositionX()~=iconX then
            icon:setPosition(iconX,G_VisibleSizeHeight-185)
          end
           iconX = iconX-90
      end
    end
  end
end


function mainUI:resetLeftFlicker(isVisible)
	if self.m_leftIconTab then
		for i=2,10 do
			if self.m_leftIconTab["flicker"..i]~=nil then
				self.m_leftIconTab["flicker"..i]:setVisible(isVisible)
			end
		end
	end
end

function mainUI:showTravelIcon(travelTimeTab)
	if travelTimeTab~=nil and SizeOfTable(travelTimeTab)>0 then
        self.m_travelSp:setVisible(true)
		local travelData=travelTimeTab[1]
		local time=travelData.time
		local type=travelData.type
		local place=travelData.place
		local isGather=travelData.isGather
		local percentRes=travelData.percentRes
		if self.m_travelType~=type then

			if self.m_travelSp~=nil then
				--self.myUILayer:removeChild(self.m_travelSp,true)
				--self.m_travelSp=nil
				self.m_travelTimeLabel=nil

			end
			self.m_travelType=type
		end
		if time>=0 then
			if time==0 then
				if type~=3 then
					if type==2 then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetBackHome"),30)
					--elseif type==1 and isGather==false then
					--	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetBack",{place.x,place.y}),30)
					end

					if self.m_travelSp~=nil then
						--self.myUILayer:removeChild(self.m_travelSp,true)
						--self.m_travelSp=nil
						self.m_travelTimeLabel=nil

					end

					if type==1 then
						--更新邮件
						--G_updateEmailList(2)
					end
				end
			end
			if self.m_travelTimeLabel~=nil then
				if type==3 and percentRes~=nil then
					if percentRes==100 and self.m_travelTimeLabel:getString()~=100 then
						self.m_travelTimeLabel:setString("100%")
					else
						self.m_travelTimeLabel:setString(percentRes.."%")
					end
				elseif type~=5 then
                    self.m_travelTimeLabel=tolua.cast(self.m_travelTimeLabel,"CCLabelTTF")
					self.m_travelTimeLabel:setString(GetTimeStr(time))
				end
            elseif type==5 then
                if self.m_travelSp:getChildByTag(3)~=nil then

                    self.m_travelSp:getChildByTag(3):removeFromParentAndCleanup(true)
                    self.m_travelTimeLabel=nil
                end
                if self.m_travelSp:getChildByTag(2)~=nil then

                    self.m_travelSp:getChildByTag(2):removeFromParentAndCleanup(true)
                end
                if self.m_travelSp:getChildByTag(2)==nil then
                    local iconSp=CCSprite:createWithSpriteFrameName("IconDefense.png")
                    iconSp:setPosition(getCenterPoint(self.m_travelSp))
                    self.m_travelSp:addChild(iconSp)
                    iconSp:setTag(2);
                end

			else
				local function travelHandler(object,name,tag)
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        end
                    require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
					local dlayerNum=3
					local td=tankDefenseDialog:new(dlayerNum)
                        local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,dlayerNum)
                        td:tabClick(1)
                        sceneGame:addChild(dialog,dlayerNum)
				end
				local travelIcon
                local travelIconNameStr=nil
				if type==1 then
                    travelIconNameStr="IconAttack.png"
				elseif type==2 then
                    travelIconNameStr="IconReturn-.png"
				elseif type==3 then
                    travelIconNameStr="IconOccupy.png"
                elseif type==4 then
                    travelIconNameStr="IconAttack.png"
                elseif type==5 then
                    travelIconNameStr="IconDefense.png"
				end
                
                if self.m_travelSp:getChildByTag(2)~=nil then

                    self.m_travelSp:getChildByTag(2):removeFromParentAndCleanup(true)
                end
                if self.m_travelSp:getChildByTag(2)==nil then
                    local iconSp=CCSprite:createWithSpriteFrameName(travelIconNameStr)
                    iconSp:setPosition(getCenterPoint(self.m_travelSp))
                    self.m_travelSp:addChild(iconSp)
                    iconSp:setTag(2);
                end

			    self.m_travelSp:setAnchorPoint(ccp(0.5,0.5))
			    self.m_travelSp:setTouchPriority(-22)
			    --self.m_travelSp:setScaleX(self.m_iconScaleX)
			    --self.m_travelSp:setScaleY(self.m_iconScaleY)
				if type==3 and percentRes~=nil then
				    self.m_travelTimeLabel=GetTTFLabel(percentRes.."%",20)
				elseif type~=5 then
					self.m_travelTimeLabel=GetTTFLabel(GetTimeStr(time),20);
                else
                    self.m_travelTimeLabel=nil
				end
			    --self.m_travelTimeLabel:setAnchorPoint(ccp(0.5,0))
			    --self.m_travelTimeLabel:setPosition(self.m_travelSp:getContentSize().width/2,0)
				

                if self.m_travelTimeLabel~=nil then
                    local capInSet = CCRect(5, 5, 1, 1);
                    local function touchClick()
                    end
                    local lbSpBg =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",capInSet,touchClick)
                    lbSpBg:setContentSize(CCSizeMake(75,20))
                    lbSpBg:ignoreAnchorPointForPosition(false)
                    lbSpBg:setAnchorPoint(CCPointMake(0.5,0))
                    lbSpBg:setPosition(ccp(self.m_travelSp:getContentSize().width/2,0))
                    lbSpBg:setTag(3)
                    lbSpBg:addChild(self.m_travelTimeLabel,4)
                    self.m_travelTimeLabel:setPosition(getCenterPoint(lbSpBg))
                    self.m_travelSp:addChild(lbSpBg,1)
                end

				
			    --self.m_travelSp:addChild(self.m_travelTimeLabel,1)
				local height=self.m_pointVip.y-115-78*2


                    -- 让右侧展开
        self.m_menuToggleSmall:setSelectedIndex(1)
                   for  k,v in pairs(self.m_luaSpTab) do

                        v:stopAllActions();
                        self:moveDown(v,ccp(self.m_pointLuaSp.x,self.m_pointLuaSp.y-k*self.m_skillHeigh-k*self.m_dis),self.m_luaTime+0.02*k);
                        local tagV = v:getTag();
                    end
			end
		else
            self.m_travelSp:setVisible(false)
            self.m_travelTimeLabel=nil
            --[[
			if self.m_travelSp~=nil then
				self.myUILayer:removeChild(self.m_travelSp,true)
				self.m_travelSp=nil
				self.m_travelTimeLabel=nil
			end]]
		end
	else
        self.m_travelSp:setVisible(false)
        self.m_travelTimeLabel=nil
        --[[
		if self.m_travelSp~=nil then
			self.myUILayer:removeChild(self.m_travelSp,true)
			self.m_travelSp=nil
			self.m_travelTimeLabel=nil
		end]]
	end
end

function mainUI:refreshStateIcon()
    
    local function touchLuaSp()
        require "luascript/script/game/scene/gamedialog/buffStateDialog"
        local vrd=buffStateDialog:new()
        local vd = vrd:init(4)
       -- sceneGame:addChild(vd,4)
    end

    self.m_luaSpBuffSp1= LuaCCSprite:createWithSpriteFrameName("IconProtectUi.png",touchLuaSp);
    self.m_luaSpBuffSp1:setAnchorPoint(ccp(0,0))
    self.m_luaSpBuffSp1:setPosition(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp1,1);
    self.m_luaSpBuffSp1:setTouchPriority(-21);
    
    self.m_luaSpBuffSp2= LuaCCSprite:createWithSpriteFrameName("IconAttackUi.png",touchLuaSp);
    self.m_luaSpBuffSp2:setAnchorPoint(ccp(0,0))
    self.m_luaSpBuffSp2:setPosition(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height*2);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp2,1);
    self.m_luaSpBuffSp2:setTouchPriority(-21);
    
    self.m_luaSpBuffSp3= LuaCCSprite:createWithSpriteFrameName("IconResourceUi.png",touchLuaSp);
    self.m_luaSpBuffSp3:setAnchorPoint(ccp(0,0))
    self.m_luaSpBuffSp3:setPosition(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height*3);
    self.m_luaSpBuff:addChild(self.m_luaSpBuffSp3,1);
    self.m_luaSpBuffSp3:setTouchPriority(-21);
    self.m_luaSpBuffSp1:setVisible(false)
    self.m_luaSpBuffSp2:setVisible(false)
    self.m_luaSpBuffSp3:setVisible(false)

end
function mainUI:refreshBuffState()
    local point1 =ccp(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height)
    local point2 =ccp(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height*2)
    local point3 =ccp(self.m_luaSpBuff:getContentSize().width,self.m_luaSpBuff:getContentSize().height-self.m_luaSpBuffSp1:getContentSize().height*3)
    if useItemSlotVoApi:getSlotById(14)==nil then
        self.m_luaSpBuffSp1:setVisible(false)
    else
        self.m_luaSpBuffSp1:setVisible(true)
    end
    if useItemSlotVoApi:getSlotById(12)==nil and useItemSlotVoApi:getSlotById(11)==nil then
        self.m_luaSpBuffSp2:setVisible(false)
    else
        self.m_luaSpBuffSp2:setVisible(true)
    end
    if useItemSlotVoApi:getNumByState1()==0 then
        self.m_luaSpBuffSp3:setVisible(false)
    else
        self.m_luaSpBuffSp3:setVisible(true)
    end
    
    if self.m_luaSpBuffSp1:isVisible()==true then
       self.m_luaSpBuffSp1:setPosition(point1)
       if self.m_luaSpBuffSp2:isVisible()==true then
          self.m_luaSpBuffSp2:setPosition(point2)
          self.m_luaSpBuffSp3:setPosition(point3)
       else
          self.m_luaSpBuffSp3:setPosition(point2)
       end
    else
       if self.m_luaSpBuffSp2:isVisible()==true then
          self.m_luaSpBuffSp2:setPosition(point1)
          self.m_luaSpBuffSp3:setPosition(point2)
       else
          self.m_luaSpBuffSp3:setPosition(point1)
       end
    end

end


function mainUI:setLastChat()
	if chatVoApi:getHasNewData(0)==true then
		local chatVo=chatVoApi:getLast(1)
		if chatVo and chatVo.subType then
			local typeStr,color,icon=chatVoApi:getTypeStr(chatVo.subType)

            local sizeSp=36
            if icon and self.m_chatBg then
                if self.m_labelLastType then
                    self.m_labelLastType:removeFromParentAndCleanup(true)
                    self.m_labelLastType=nil
                end
                self.m_labelLastType = CCSprite:createWithSpriteFrameName(icon)
                local typeScale=sizeSp/self.m_labelLastType:getContentSize().width
                self.m_labelLastType:setAnchorPoint(ccp(0.5,0.5))
                self.m_labelLastType:setPosition(ccp(5+sizeSp/2,self.m_chatBg:getContentSize().height/2))
                self.m_chatBg:addChild(self.m_labelLastType,2)
                self.m_labelLastType:setScale(typeScale)
            end
			-- if self.m_labelLastType then
			-- 	self.m_labelLastType:setString(typeStr)
			-- 	self.m_labelLastType:setColor(color)
			-- else
			--     self.m_labelLastType=GetTTFLabel(typeStr,30)
			--     self.m_labelLastType:setAnchorPoint(ccp(0,0.5))
			--     self.m_labelLastType:setPosition(ccp(5,self.m_chatBg:getContentSize().height/2))
			--     self.m_chatBg:addChild(self.m_labelLastType,2)
			-- 	self.m_labelLastType:setColor(color)
			-- end
			
			local nameStr=chatVoApi:getNameStr(chatVo.type,chatVo.subType,chatVo.senderName,chatVo.reciverName,chatVo.sender)
			--nameStr=nameStr..":"
            if nameStr~=nil and nameStr~="" and chatVo.type<=3 and chatVo.contentType~=3 then
                nameStr=nameStr..":"
				if self.m_labelLastName then
					self.m_labelLastName:setString(nameStr)
                    if color then
					   self.m_labelLastName:setColor(color)
                    end
				else
				    self.m_labelLastName=GetTTFLabel(nameStr,30)
				    self.m_labelLastName:setAnchorPoint(ccp(0,0.5))
				    self.m_labelLastName:setPosition(ccp(5+sizeSp,self.m_chatBg:getContentSize().height/2))
				    self.m_chatBg:addChild(self.m_labelLastName,2)
                    if color then
					   self.m_labelLastName:setColor(color)
                    end
				end
			end
			
			local message=chatVo.content
			if message==nil then
				message=""
			end
            local msgFont=nil
            --处理ios表情在安卓不显示问题
            if G_isIOS()==false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb={}
                    tmpTb["action"]="EmojiConv"
                    tmpTb["parms"]={}
                    tmpTb["parms"]["str"]=tostring(message)
                    local cjson=G_Json.encode(tmpTb)
                    message=G_accessCPlusFunction(cjson)
                    msgFont=G_EmojiFontSrc
                end
            end

			local xPos=sizeSp+5
			if self.m_labelLastName and chatVo.type<=3 then
				if chatVo.contentType==3 then
					--self.m_labelLastName:setString(nameStr)
                    self.m_labelLastName:setString("")
				else
					xPos=xPos+self.m_labelLastName:getContentSize().width
				end
			end
            --local tmpLb=GetTTFLabel(message,30)
			if self.m_labelLastMsg then
				self.m_labelLastMsg:setString(message)
                if msgFont then
                    self.m_labelLastMsg:setFontName(msgFont)
                end
			else
			    --self.m_labelLastMsg=GetTTFLabel(message,30)
				self.m_labelLastMsg=GetTTFLabelWrap(message,30,CCSizeMake(self.m_chatBg:getContentSize().width-100,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,msgFont)
			    self.m_labelLastMsg:setAnchorPoint(ccp(0,0.5))
			    self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
			    self.m_chatBg:addChild(self.m_labelLastMsg,2)
			end

         self.m_labelLastMsg:setDimensions(CCSize(self.m_chatBg:getContentSize().width-xPos-50,40))
          if chatVo.contentType and chatVo.contentType==2 then --战报
              self.m_labelLastMsg:setColor(G_ColorYellow)
          else
              self.m_labelLastMsg:setColor(color)
          end
          self.m_labelLastMsg:setPosition(ccp(xPos,self.m_chatBg:getContentSize().height/2))
  
		end
		chatVoApi:setNoNewData(0)
	end
end

function mainUI:changeToMyPort()

        sceneController:changeSceneByIndex(0)
        self.m_menuToggle:setSelectedIndex(0)
		self:changeMainUI(0)
end
function mainUI:changeToWorld()
        if tonumber(playerVoApi:getPlayerLevel())<3 and tonumber(playerVoApi:getMapX())==-1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("worldSceneWillOpenDesc"),28)
            do
                self:changeToMyPort()
                return
            end

        end

        sceneController:changeSceneByIndex(2)
        self.m_menuToggle:setSelectedIndex(2)
		self:changeMainUI(2)
end
function mainUI:changeToMainLand()

        sceneController:changeSceneByIndex(1)
        self.m_menuToggle:setSelectedIndex(1)
		self:changeMainUI(1)
end


function mainUI:destroySelf()

    mainUI=nil;

end

function mainUI:changeMainUI(sceneIndex)

    if sceneIndex==0 then  --港口
          self.mySpriteWorld:setPosition(0,G_VisibleSizeHeight+300);
          self.mySpriteMain:setPosition(0,G_VisibleSizeHeight);
          self.mySpriteMain:setVisible(true)

          tipDialog:showTipsBar(self.myUILayer,ccp(320,G_VisibleSizeHeight+46),ccp(320,G_VisibleSizeHeight-26-150),getlocal("window1"),80,11);
          
    elseif sceneIndex==1 then --岛屿
          self.mySpriteWorld:setPosition(0,G_VisibleSizeHeight+300);
          self.mySpriteMain:setPosition(0,G_VisibleSizeHeight);
          self.mySpriteMain:setVisible(true)

          tipDialog:showTipsBar(self.myUILayer,ccp(320,G_VisibleSizeHeight+46),ccp(320,G_VisibleSizeHeight-26-150),getlocal("window2"),80,11);
          
    elseif sceneIndex==2 then --世界
          self.mySpriteWorld:setPosition(0,G_VisibleSizeHeight-58);
          self.mySpriteMain:setPosition(0,G_VisibleSizeHeight+500);
          self.mySpriteMain:setVisible(false)

          tipDialog:showTipsBar(self.myUILayer,ccp(320,G_VisibleSizeHeight+46),ccp(320,G_VisibleSizeHeight-26-118),getlocal("window3"),80,11);
    end
end

function mainUI:setHide()
    self.myUILayer:setVisible(false)
end
function mainUI:isVisible()
    return self.myUILayer:isVisible()
end
function mainUI:setShow()
    self.myUILayer:setVisible(true)
	self:tick()
end

function mainUI:dispose()
    local function pbUIhandler()
    end
    self.mySpriteWorld =LuaCCSprite:createWithSpriteFrameName("worldBgTop.png",pbUIhandler)
    self.mySpriteWorld:setAnchorPoint(ccp(0,0.5));
    self.mySpriteWorld:setPosition(0,G_VisibleSizeHeight+300);
    self.myUILayer:addChild(self.mySpriteWorld,13);

end

--取名字的板子
function mainUI:showCreateNewRole()
    --PlayEffect(audioCfg.mouseClick)
    local layerNum=8
    local function touch()
    
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touch)
    
  local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   bgSp:ignoreAnchorPointForPosition(false)
    sceneGame:addChild(bgSp,19)
    bgSp:setTouchPriority(-(layerNum-1)*20-1);
    bgSp:setIsSallow(true)
    
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    local titleLb=GetTTFLabel(getlocal("createRoleTitle"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height-titleLb:getContentSize().height/2-15))
    bgSp:addChild(titleLb)
    --[[
    local function close()
        PlayEffect(audioCfg.mouseClick)
        bgSp:removeFromParentAndCleanup(true)
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    bgSp:addChild(closeBtn)
    ]]

    
  local function bgAnimationSelected()
    local scaleTo=CCScaleTo:create(0.1, 1);
    local fadeOut=CCTintTo:create(0.1,255,255,255)
    --local fadeOut=CCFadeTo:create(0.1,255)
    local carray=CCArray:create()
    carray:addObject(scaleTo)
    carray:addObject(fadeOut)
    local spa=CCSpawn:create(carray)
    return spa;
  end
  
  local function bgAnimationSelected2()
    local scaleTo=CCScaleTo:create(0.1, 0.7);
    local fadeOut=CCTintTo:create(0.1,150,150,150)
    --local fadeOut=CCFadeTo:create(0.1,60)
    local carray=CCArray:create()
    carray:addObject(scaleTo)
    carray:addObject(fadeOut)
    local spa=CCSpawn:create(carray)
    return spa;
  end

    local roleType=1;
    local roleName="";
    local roleTb={"public/man.png","public/woman.png"}
    local rolePh={}
    local function touchPhoto(object,name,tag)
    local sp1=bgSp:getChildByTag(tag);
   local sp2=sp1:getChildByTag(2);
    local spa1=bgAnimationSelected()
         sp1:runAction(spa1)
    local fadeOut=CCTintTo:create(0.1,255,255,255)
    sp2:runAction(fadeOut)
        
    for k,v in pairs(rolePh) do
        if v:getTag()~=tag then

     local spa1=bgAnimationSelected2()
     local sp2=v:getChildByTag(2);
     local fadeOut=CCTintTo:create(0.1,150,150,150)
            v:runAction(spa1)
     sp2:runAction(fadeOut)

        end
    end

        roleType=tag;

    end
    local sign=0;
    local function touchBg()
    
    end
    for k,v in pairs(roleTb) do
       sign=sign+1
       local name=v
       local spBg=LuaCCSprite:createWithFileName("public/framebtn.png",touchPhoto);
       local chSp= LuaCCSprite:createWithFileName(name,touchBg);
   chSp:setTag(2)
       if sign<=3 then
           spBg:setPosition(ccp(185+(sign-1)*270,bgSp:getContentSize().height/2+100));
           chSp:setPosition(getCenterPoint(spBg));
       else
           spBg:setPosition(ccp(155+(sign-4)*160,bgSp:getContentSize().height/2-270));
           chSp:setPosition(getCenterPoint(spBg));
       end
   if k==2 then
      spBg:setScale(0.7)
  spBg:setColor(ccc3(150,150,150))
  chSp:setColor(ccc3(150,150,150))
   end
       spBg:setTag(sign);
       spBg:setIsSallow(true)
       spBg:setTouchPriority(-(layerNum-1)*20-2)
       rolePh[k]=spBg
       bgSp:addChild(spBg,1)
       spBg:addChild(chSp,2)
    end
    
    
    local function tthandler()
    
    end
    local function callBackXHandler(fn,eB,str)
        if str~=nil then
           roleName=str;
           roleName=G_stringGsub(roleName," ","")
           if self.clickHereTipLabel~=nil then
                self.clickHereTipLabel:setVisible(false)
           end
        end
    end
    

    local nameBox=LuaCCScale9Sprite:createWithSpriteFrameName("inputNameBg.png",CCRect(70,35,1,1),tthandler)
    nameBox:setContentSize(CCSize(420,80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width/2,220))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel=GetTTFLabel("",30)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,nameBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local length=20
    customEditBox:init(nameBox,targetBoxLabel,"inputNameBg.png",nil,(-(layerNum-1)*20-2),length,callBackXHandler,nil,nil)

    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()]==nil then
--这里开始


    local tipLabel=GetTTFLabel(getlocal("limitLength",{12}),26)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(ccp(bgSp:getContentSize().width/2-130,185))
    bgSp:addChild(tipLabel,2)
    tipLabel:setColor(G_ColorRed)
    
    
    self.clickHereTipLabel=GetTTFLabel("点击这里输入名称",30)
    self.clickHereTipLabel:setAnchorPoint(ccp(0.5,0.5))
    self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width/2,220))
    bgSp:addChild(self.clickHereTipLabel,10)
    self.clickHereTipLabel:setColor(G_ColorYellow)

    local cannotInputLabel=GetTTFLabel(getlocal("cannotInput"),26)
    cannotInputLabel:setAnchorPoint(ccp(0,1))
    cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width/2-20,185))
    bgSp:addChild(cannotInputLabel,2)
    cannotInputLabel:setColor(G_ColorGreen)
    
        local clickHereLabel=GetTTFLabel(getlocal("clickHere"),26)
    clickHereLabel:setAnchorPoint(ccp(0,1))
    clickHereLabel:setPosition(ccp(bgSp:getContentSize().width/2+108,185))
    bgSp:addChild(clickHereLabel,2)
    clickHereLabel:setColor(G_ColorGreen)
    
    local male1={"阿波","阿道","阿尔","阿姆","阿诺","阿奇","埃达","埃德","埃迪","埃尔","埃里","埃玛","埃文","艾比","艾伯","艾布","艾丹","艾德","艾登","艾尔","艾富","艾理","艾伦","艾略","艾谱","艾萨","艾塞","艾丝","艾文","艾西","爱得","爱德","爱迪","爱尔","爱格","爱莉","爱罗","爱曼","安得","安德","安迪","安东","安格","安纳","安其","安斯","奥布","奥德","奥尔","奥古","奥劳","奥利","奥斯","奥特","巴德","巴顿","巴尔","巴克","巴里","巴伦","巴罗","巴奈","巴萨","巴特","巴泽","柏得","柏德","柏格","柏塔","柏特","柏宜","拜尔","拜伦","班克","班奈","班尼","宝儿","保罗","鲍比","鲍伯","贝尔","贝克","贝齐","本恩","本杰","本森","比尔","比利","比其","彼得","毕维","毕夏","宾尔","波顿","波特","波文","伯顿","伯恩","伯里","伯尼"}
    local male2={"伯特","博格","布德","布拉","布莱","布赖","布兰","布朗","布雷","布里","布鲁","布伦","布尼","布兹","采尼","查德","查尔","达尔","达伦","达尼","大卫","戴夫","戴纳","丹尼","丹普","道格","得利","德博","德尔","德里","德维","德文","邓肯","狄克","迪得","迪恩","迪克","迪伦","迪姆","迪斯","蒂安","蒂莫","杜克","杜鲁","多夫","多洛","多明","尔德","尔特","范尼","菲比","菲蕾","菲力","菲利","菲兹","斐迪","费恩","费力","费奇","费兹","费滋","佛里","夫兰","弗德","弗恩","弗兰","弗朗","弗莉","弗罗","弗农","弗瑞","福特","富宾","富兰","盖尔","盖克","高达","高德","戈登","格吉","格拉","格里","格林","格罗","格纳","葛里","葛列","葛瑞","古斯","哈帝","哈乐","哈里","哈利","哈伦","哈瑞","哈威","海顿","海勒","海洛","海曼"}
    local male3={"韩弗","汉克","汉米","汉姆","汉特","赫伯","赫达","赫尔","赫瑟","亨利","华纳","霍伯","霍尔","霍根","霍华","基诺","吉伯","吉蒂","吉恩","吉罗","吉米","吉姆","吉榭","加百","加比","加尔","加菲","加里","加文","迦勒","迦利","嘉比","贾艾","贾斯","杰弗","杰克","杰奎","杰拉","杰罗","杰农","杰瑞","杰西","杰伊","捷勒","卡尔","卡萝","卡洛","卡玛","卡梅","卡斯","卡特","凯尔","凯里","凯理","凯伦","凯撒","凯斯","凯文","凯希","凯伊","康拉","康那","康奈","康斯","考伯","考尔","柯帝","柯利","科迪","科尔","科林","科兹","克拉","克莱","克劳","克雷","克里","克利","克林","克洛","克思","克斯","肯姆","肯尼","寇里","昆廷","拉丁","拉罕","拉里","拉斯","莱德","莱姆","莱斯","赖安","兰德","兰迪","兰斯","兰特","劳伦","劳瑞"}
    
    if platCfg.platCfgDefaultLocal[G_curPlatName()]=="tw" then
          male1={"阿波","阿道","阿爾","阿姆","阿諾","阿奇","埃達","埃德","埃迪","埃爾","埃裏","埃瑪","埃文","艾比","艾伯","艾布","艾丹","艾德","艾登","艾爾","艾富","艾理","艾倫","艾略","艾譜","艾薩","艾塞","艾絲","艾文","艾西","愛得","愛德","愛迪","愛爾","愛格","愛莉","愛羅","愛曼","安得","安德","安迪","安東","安格","安納","安其","安斯","奧布","奧德","奧爾","奧古","奧勞","奧利","奧斯","奧特","巴德","巴頓","巴爾","巴克","巴裏","巴倫","巴羅","巴奈","巴薩","巴特","巴澤","柏得","柏德","柏格","柏塔","柏特","柏宜","拜爾","拜倫","班克","班奈","班尼","寶兒","保羅","鮑比","鮑伯","貝爾","貝克","貝齊","本恩","本傑","本森","比爾","比利","比其","彼得","畢維","畢夏","賓爾","波頓","波特","波文","伯頓","伯恩","伯裏","伯尼"}
          male2={"伯特","博格","布德","布拉","布萊","布賴","布蘭","布朗","布雷","布裏","布魯","布倫","布尼","布茲","采尼","查德","查爾","達爾","達倫","達尼","大衛","戴夫","戴納","丹尼","丹普","道格","得利","德博","德爾","德裏","德維","德文","鄧肯","狄克","迪得","迪恩","迪克","迪倫","迪姆","迪斯","蒂安","蒂莫","杜克","杜魯","多夫","多洛","多明","爾德","爾特","範尼","菲比","菲蕾","菲力","菲利","菲茲","斐迪","費恩","費力","費奇","費茲","費滋","佛裏","夫蘭","弗德","弗恩","弗蘭","弗朗","弗莉","弗羅","弗農","弗瑞","福特","富賓","富蘭","蓋爾","蓋克","高達","高德","戈登","格吉","格拉","格裏","格林","格羅","格納","葛裏","葛列","葛瑞","古斯","哈帝","哈樂","哈裏","哈利","哈倫","哈瑞","哈威","海頓","海勒","海洛","海曼"}
          male3={"韓弗","漢克","漢米","漢姆","漢特","赫伯","赫達","赫爾","赫瑟","亨利","華納","霍伯","霍爾","霍根","霍華","基諾","吉伯","吉蒂","吉恩","吉羅","吉米","吉姆","吉榭","加百","加比","加爾","加菲","加裏","加文","迦勒","迦利","嘉比","賈艾","賈斯","傑弗","傑克","傑奎","傑拉","傑羅","傑農","傑瑞","傑西","傑伊","捷勒","卡爾","卡蘿","卡洛","卡瑪","卡梅","卡斯","卡特","凱爾","凱裏","凱理","凱倫","凱撒","凱斯","凱文","凱希","凱伊","康拉","康那","康奈","康斯","考伯","考爾","柯帝","柯利","科迪","科爾","科林","科茲","克拉","克萊","克勞","克雷","克裏","克利","克林","克洛","克思","克斯","肯姆","肯尼","寇裏","昆廷","拉丁","拉罕","拉裏","拉斯","萊德","萊姆","萊斯","賴安","蘭德","蘭迪","蘭斯","蘭特","勞倫","勞瑞"}
    end

    local function randRoleName()
           --roleName="克里斯来看看"
           --targetBoxLabel:setString(roleName)
           self.clickHereTipLabel:setVisible(false)
           local orderTb={}
           local maleT=deviceHelper:getRandom()
           if maleT<=33 then
               orderTb[1]=male1
               orderTb[2]=male2
               orderTb[3]=male3
           elseif  maleT>66 then
               orderTb[1]=male3
               orderTb[2]=male1
               orderTb[3]=male2
           else
               orderTb[1]=male2
               orderTb[2]=male3
               orderTb[3]=male1
           end
           local rand1=deviceHelper:getRandom()
           local rand2=deviceHelper:getRandom()
           local rand3=deviceHelper:getRandom()
           local realName=orderTb[1][rand1==0 and 1 or rand1]..orderTb[2][rand2==0 and 1 or rand2]..orderTb[3][rand3==0 and 1 or rand3]
           roleName=realName
           targetBoxLabel:setString(realName)
    end
    local helpmebtn=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn.png",randRoleName,nil,getlocal("serverList"),25)
        helpmebtn:setOpacity(0)        
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu=CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width/2+170,160))
        helpmeMenu:setTouchPriority(-(layerNum-1)*20-4);
        bgSp:addChild(helpmeMenu,1)
            
    randRoleName()
---这里结束
else
     local tipLabel=GetTTFLabel(getlocal("limitLength",{12}),26)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(ccp(bgSp:getContentSize().width/2,185))
    bgSp:addChild(tipLabel,2)
    tipLabel:setColor(G_ColorRed)
end
    



    
    local function createRole()
        local hasEmjoy=G_checkEmjoy(roleName)
        if hasEmjoy==false then
            do return end
        end
        local count=G_utfstrlen(roleName,true)
        if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName)==false then
                do
                    return
                end
            end
        end
        if G_match(roleName)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_illegalCharacters"),true,20,G_ColorRed)
            do 
                return
            end
        end
        print("roleName=",roleName)
        if string.find(roleName, ' ')~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("blankCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        
        local strFisrt=G_stringGetAt(roleName,0,1)
        if tonumber(strFisrt)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("firstCharNoNum"),true,20,G_ColorRed)
            do 
                return
            end
        end

        if roleName=="" then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("nameNullCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        if count>12 then

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,20,G_ColorRed)
        elseif count<3 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("roleNameMinLen"),true,20,G_ColorRed)

        else
            local function serverUserSigupHandler(fn,data)
                  --local sData=G_Json.decode(data)
                  local result,sData=base:checkServerData(data,false)
                  if tonumber(sData.ret)>=0 and tonumber(sData.uid)>0 then  --登记角色名,选择头像成功
                        bgSp:removeFromParentAndCleanup(true)

                          self.mySpriteLeft:getChildByTag(767):removeFromParentAndCleanup(true)
                          local personPhotoName="photo"..roleType..".png"
                          local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
                          personPhoto:setAnchorPoint(ccp(0,0.5));
                          personPhoto:setPosition(ccp(6,self.mySpriteLeft:getContentSize().height/2));
                          personPhoto:setTag(767)
                          self.mySpriteLeft:addChild(personPhoto,5);
                          G_cancleLoginLoading()
                          newGuidMgr:toNextStep()
                  else
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namehasbeenused"),true,20,G_ColorRed)
                        G_cancleLoginLoading() --注册角色名失败 取消loading
                  end

            end
            G_showLoginLoading() --加loading
            socketHelper:userRename(roleName,roleType,serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("LoadingBtn.png","LoadingBtn_Down.png","LoadingBtn.png",createRole,nil,getlocal("createRole"),25);

    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-(layerNum-1)*20-4)
    createBtn:setPosition(ccp(bgSp:getContentSize().width/2,95))
    bgSp:addChild(createBtn)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    
end



--取名字的板子
function mainUI:showCreateNewRoleKunlun()
    --PlayEffect(audioCfg.mouseClick)
    local layerNum=8
    local function touch()
    
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgKunlun.png",CCRect(168, 86, 10, 10),touch)
    
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    bgSp:ignoreAnchorPointForPosition(false)
    sceneGame:addChild(bgSp,19)
    bgSp:setTouchPriority(-(layerNum-1)*20-1);
    bgSp:setIsSallow(true)
    
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    local titleLb=GetTTFLabel(getlocal("createRoleTitle"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height-titleLb:getContentSize().height/2-15))
    bgSp:addChild(titleLb)

    local roleType=math.random(1,6)

    local roleTb={
    {icon="photo5.png",img="kunlunImage/man_3.png",type=5},
    {icon="photo6.png",img="kunlunImage/woman_3.png",type=6},
    {icon="photo3.png",img="kunlunImage/man_2.png",type=3},
    {icon="photo4.png",img="kunlunImage/woman_2.png",type=4},
    {icon="photo1.png",img="public/man.png",type=1},
    {icon="photo2.png",img="public/woman.png",type=2},
    }
    local function touchBg()

    end

    local spBg=LuaCCSprite:createWithFileName("public/framebtn.png",touchBg);
    local rkey = 1
    for k,v in pairs(roleTb) do
      if v.type==roleType then
         rkey=k
      end
    end
    local chSp= LuaCCSprite:createWithFileName(roleTb[rkey].img,touchBg);
    chSp:setTag(20)
    spBg:setAnchorPoint(ccp(0.5,1))
    spBg:setPosition(ccp(bgSp:getContentSize().width/2-80,bgSp:getContentSize().height-160));
    chSp:setPosition(getCenterPoint(spBg));
    spBg:addChild(chSp)
    bgSp:addChild(spBg)

    local wkuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),touchBg)
    wkuangSp:setContentSize(CCSizeMake(108,100))


    local lanTb={}
    local function touch(object,name,tag)
        local sp1=bgSp:getChildByTag(tag);
        wkuangSp:setPosition(sp1:getPosition())
        sp1:setScale(1.2)
        local node = spBg:getChildByTag(20)
        node:removeFromParentAndCleanup(true)
        local chSp= LuaCCSprite:createWithFileName(roleTb[tag].img,touchBg);
        chSp:setPosition(getCenterPoint(spBg));
        chSp:setTag(20)
        spBg:addChild(chSp)
        roleType=roleTb[tag].type
        for k,v in pairs(lanTb) do
            if v:getTag()~=tag then
                v:setScale(1)
            end
        end
    end

    for k,v in pairs(roleTb) do       
       local name=roleTb[k].icon
       local chSp= LuaCCSprite:createWithSpriteFrameName(name,touch)
       chSp:setPosition(ccp(530,bgSp:getContentSize().height-70-(95*k)))
       chSp:setTag(k)
       chSp:setIsSallow(true)
       chSp:setTouchPriority(-(layerNum-1)*20-2)
       local kuangSp = LuaCCSprite:createWithSpriteFrameName("kuangKunlun.png",touchBg);
       kuangSp:setPosition(getCenterPoint(chSp))
       kuangSp:setScale(1.4)
       chSp:addChild(kuangSp)
       bgSp:addChild(chSp,2)
       if roleTb[k].type==roleType then
         wkuangSp:setPosition(chSp:getPosition())
         bgSp:addChild(wkuangSp,3)
         chSp:setScale(1.2)
       end
       lanTb[k]=chSp
   end

    

    
    local function tthandler()
    
    end
    local function callBackXHandler(fn,eB,str)
        if str~=nil then
           roleName=str;
           roleName=G_stringGsub(roleName," ","")
           if self.clickHereTipLabel~=nil then
                self.clickHereTipLabel:setVisible(false)
           end
        end
    end
    

    local nameBox=LuaCCScale9Sprite:createWithSpriteFrameName("inputNameBg.png",CCRect(70,35,1,1),tthandler)
    nameBox:setContentSize(CCSize(420,80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width/2,220))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel=GetTTFLabel("",30)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,nameBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local length=20
    customEditBox:init(nameBox,targetBoxLabel,"inputNameBg.png",nil,(-(layerNum-1)*20-2),length,callBackXHandler,nil,nil)

    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()]==nil then
--这里开始


    local tipLabel=GetTTFLabel(getlocal("limitLength",{12}),26)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(ccp(bgSp:getContentSize().width/2-130,185))
    bgSp:addChild(tipLabel,2)
    tipLabel:setColor(G_ColorRed)
    
    
    self.clickHereTipLabel=GetTTFLabel("点击这里输入名称",30)
    self.clickHereTipLabel:setAnchorPoint(ccp(0.5,0.5))
    self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width/2,220))
    bgSp:addChild(self.clickHereTipLabel,10)
    self.clickHereTipLabel:setColor(G_ColorYellow)

    local cannotInputLabel=GetTTFLabel(getlocal("cannotInput"),26)
    cannotInputLabel:setAnchorPoint(ccp(0,1))
    cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width/2-20,185))
    bgSp:addChild(cannotInputLabel,2)
    cannotInputLabel:setColor(G_ColorGreen)
    
        local clickHereLabel=GetTTFLabel(getlocal("clickHere"),26)
    clickHereLabel:setAnchorPoint(ccp(0,1))
    clickHereLabel:setPosition(ccp(bgSp:getContentSize().width/2+108,185))
    bgSp:addChild(clickHereLabel,2)
    clickHereLabel:setColor(G_ColorGreen)
    
    local male1={"阿波","阿道","阿尔","阿姆","阿诺","阿奇","埃达","埃德","埃迪","埃尔","埃里","埃玛","埃文","艾比","艾伯","艾布","艾丹","艾德","艾登","艾尔","艾富","艾理","艾伦","艾略","艾谱","艾萨","艾塞","艾丝","艾文","艾西","爱得","爱德","爱迪","爱尔","爱格","爱莉","爱罗","爱曼","安得","安德","安迪","安东","安格","安纳","安其","安斯","奥布","奥德","奥尔","奥古","奥劳","奥利","奥斯","奥特","巴德","巴顿","巴尔","巴克","巴里","巴伦","巴罗","巴奈","巴萨","巴特","巴泽","柏得","柏德","柏格","柏塔","柏特","柏宜","拜尔","拜伦","班克","班奈","班尼","宝儿","保罗","鲍比","鲍伯","贝尔","贝克","贝齐","本恩","本杰","本森","比尔","比利","比其","彼得","毕维","毕夏","宾尔","波顿","波特","波文","伯顿","伯恩","伯里","伯尼"}
    local male2={"伯特","博格","布德","布拉","布莱","布赖","布兰","布朗","布雷","布里","布鲁","布伦","布尼","布兹","采尼","查德","查尔","达尔","达伦","达尼","大卫","戴夫","戴纳","丹尼","丹普","道格","得利","德博","德尔","德里","德维","德文","邓肯","狄克","迪得","迪恩","迪克","迪伦","迪姆","迪斯","蒂安","蒂莫","杜克","杜鲁","多夫","多洛","多明","尔德","尔特","范尼","菲比","菲蕾","菲力","菲利","菲兹","斐迪","费恩","费力","费奇","费兹","费滋","佛里","夫兰","弗德","弗恩","弗兰","弗朗","弗莉","弗罗","弗农","弗瑞","福特","富宾","富兰","盖尔","盖克","高达","高德","戈登","格吉","格拉","格里","格林","格罗","格纳","葛里","葛列","葛瑞","古斯","哈帝","哈乐","哈里","哈利","哈伦","哈瑞","哈威","海顿","海勒","海洛","海曼"}
    local male3={"韩弗","汉克","汉米","汉姆","汉特","赫伯","赫达","赫尔","赫瑟","亨利","华纳","霍伯","霍尔","霍根","霍华","基诺","吉伯","吉蒂","吉恩","吉罗","吉米","吉姆","吉榭","加百","加比","加尔","加菲","加里","加文","迦勒","迦利","嘉比","贾艾","贾斯","杰弗","杰克","杰奎","杰拉","杰罗","杰农","杰瑞","杰西","杰伊","捷勒","卡尔","卡萝","卡洛","卡玛","卡梅","卡斯","卡特","凯尔","凯里","凯理","凯伦","凯撒","凯斯","凯文","凯希","凯伊","康拉","康那","康奈","康斯","考伯","考尔","柯帝","柯利","科迪","科尔","科林","科兹","克拉","克莱","克劳","克雷","克里","克利","克林","克洛","克思","克斯","肯姆","肯尼","寇里","昆廷","拉丁","拉罕","拉里","拉斯","莱德","莱姆","莱斯","赖安","兰德","兰迪","兰斯","兰特","劳伦","劳瑞"}
    
    if platCfg.platCfgDefaultLocal[G_curPlatName()]=="tw" then
          male1={"阿波","阿道","阿爾","阿姆","阿諾","阿奇","埃達","埃德","埃迪","埃爾","埃裏","埃瑪","埃文","艾比","艾伯","艾布","艾丹","艾德","艾登","艾爾","艾富","艾理","艾倫","艾略","艾譜","艾薩","艾塞","艾絲","艾文","艾西","愛得","愛德","愛迪","愛爾","愛格","愛莉","愛羅","愛曼","安得","安德","安迪","安東","安格","安納","安其","安斯","奧布","奧德","奧爾","奧古","奧勞","奧利","奧斯","奧特","巴德","巴頓","巴爾","巴克","巴裏","巴倫","巴羅","巴奈","巴薩","巴特","巴澤","柏得","柏德","柏格","柏塔","柏特","柏宜","拜爾","拜倫","班克","班奈","班尼","寶兒","保羅","鮑比","鮑伯","貝爾","貝克","貝齊","本恩","本傑","本森","比爾","比利","比其","彼得","畢維","畢夏","賓爾","波頓","波特","波文","伯頓","伯恩","伯裏","伯尼"}
          male2={"伯特","博格","布德","布拉","布萊","布賴","布蘭","布朗","布雷","布裏","布魯","布倫","布尼","布茲","采尼","查德","查爾","達爾","達倫","達尼","大衛","戴夫","戴納","丹尼","丹普","道格","得利","德博","德爾","德裏","德維","德文","鄧肯","狄克","迪得","迪恩","迪克","迪倫","迪姆","迪斯","蒂安","蒂莫","杜克","杜魯","多夫","多洛","多明","爾德","爾特","範尼","菲比","菲蕾","菲力","菲利","菲茲","斐迪","費恩","費力","費奇","費茲","費滋","佛裏","夫蘭","弗德","弗恩","弗蘭","弗朗","弗莉","弗羅","弗農","弗瑞","福特","富賓","富蘭","蓋爾","蓋克","高達","高德","戈登","格吉","格拉","格裏","格林","格羅","格納","葛裏","葛列","葛瑞","古斯","哈帝","哈樂","哈裏","哈利","哈倫","哈瑞","哈威","海頓","海勒","海洛","海曼"}
          male3={"韓弗","漢克","漢米","漢姆","漢特","赫伯","赫達","赫爾","赫瑟","亨利","華納","霍伯","霍爾","霍根","霍華","基諾","吉伯","吉蒂","吉恩","吉羅","吉米","吉姆","吉榭","加百","加比","加爾","加菲","加裏","加文","迦勒","迦利","嘉比","賈艾","賈斯","傑弗","傑克","傑奎","傑拉","傑羅","傑農","傑瑞","傑西","傑伊","捷勒","卡爾","卡蘿","卡洛","卡瑪","卡梅","卡斯","卡特","凱爾","凱裏","凱理","凱倫","凱撒","凱斯","凱文","凱希","凱伊","康拉","康那","康奈","康斯","考伯","考爾","柯帝","柯利","科迪","科爾","科林","科茲","克拉","克萊","克勞","克雷","克裏","克利","克林","克洛","克思","克斯","肯姆","肯尼","寇裏","昆廷","拉丁","拉罕","拉裏","拉斯","萊德","萊姆","萊斯","賴安","蘭德","蘭迪","蘭斯","蘭特","勞倫","勞瑞"}
    end

    local function randRoleName()
           --roleName="克里斯来看看"
           --targetBoxLabel:setString(roleName)
           self.clickHereTipLabel:setVisible(false)
           local orderTb={}
           local maleT=deviceHelper:getRandom()
           if maleT<=33 then
               orderTb[1]=male1
               orderTb[2]=male2
               orderTb[3]=male3
           elseif  maleT>66 then
               orderTb[1]=male3
               orderTb[2]=male1
               orderTb[3]=male2
           else
               orderTb[1]=male2
               orderTb[2]=male3
               orderTb[3]=male1
           end
           local rand1=deviceHelper:getRandom()
           local rand2=deviceHelper:getRandom()
           local rand3=deviceHelper:getRandom()
           local realName=orderTb[1][rand1==0 and 1 or rand1]..orderTb[2][rand2==0 and 1 or rand2]..orderTb[3][rand3==0 and 1 or rand3]
           roleName=realName
           targetBoxLabel:setString(realName)
    end
    local helpmebtn=GetButtonItem("LoadingSelectServerBtn.png","LoadingSelectServerBtn_Down.png","LoadingSelectServerBtn.png",randRoleName,nil,getlocal("serverList"),25)
        helpmebtn:setOpacity(0)        
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu=CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width/2+170,160))
        helpmeMenu:setTouchPriority(-(layerNum-1)*20-4);
        bgSp:addChild(helpmeMenu,1)
            
    randRoleName()
---这里结束
else
     local tipLabel=GetTTFLabel(getlocal("limitLength",{12}),26)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(ccp(bgSp:getContentSize().width/2,185))
    bgSp:addChild(tipLabel,2)
    tipLabel:setColor(G_ColorRed)
end
    



    
    local function createRole()

        local count=G_utfstrlen(roleName,true)
        if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName)==false then
                do
                    return
                end
            end
        end
        if G_match(roleName)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_illegalCharacters"),true,20,G_ColorRed)
            do 
                return
            end
        end
        print("roleName=",roleName)
        if string.find(roleName, ' ')~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("blankCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        
        local strFisrt=G_stringGetAt(roleName,0,1)
        if tonumber(strFisrt)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("firstCharNoNum"),true,20,G_ColorRed)
            do 
                return
            end
        end

        if roleName=="" then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("nameNullCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        if count>12 then

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,20,G_ColorRed)
        elseif count<3 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("roleNameMinLen"),true,20,G_ColorRed)

        else
            local function serverUserSigupHandler(fn,data)
                  --local sData=G_Json.decode(data)
                  local result,sData=base:checkServerData(data,false)
                  if tonumber(sData.ret)>=0 and tonumber(sData.uid)>0 then  --登记角色名,选择头像成功
                        bgSp:removeFromParentAndCleanup(true)

                          self.mySpriteLeft:getChildByTag(767):removeFromParentAndCleanup(true)
                          local personPhotoName="photo"..roleType..".png"
                          local personPhoto = CCSprite:createWithSpriteFrameName(personPhotoName);
                          personPhoto:setAnchorPoint(ccp(0,0.5));
                          personPhoto:setPosition(ccp(6,self.mySpriteLeft:getContentSize().height/2));
                          personPhoto:setTag(767)
                          self.mySpriteLeft:addChild(personPhoto,5);
                          G_cancleLoginLoading()
                          newGuidMgr:toNextStep()
                  else
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namehasbeenused"),true,20,G_ColorRed)
                        G_cancleLoginLoading() --注册角色名失败 取消loading
                  end

            end
            G_showLoginLoading() --加loading
            socketHelper:userRename(roleName,roleType,serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("LoadingBtn.png","LoadingBtn_Down.png","LoadingBtn.png",createRole,nil,getlocal("createRole"),25);

    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-(layerNum-1)*20-4)
    createBtn:setPosition(ccp(bgSp:getContentSize().width/2,95))
    bgSp:addChild(createBtn)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    
end






function mainUI:judgeShowAccessoryGuide()
    if(base.ifAccessoryOpen~=1)then
        do return end
    end
    if(accessoryVoApi:getGuideStep()==0)then
        local lv=playerVoApi:getPlayerLevel()
        if(lv>=8 and lv<=10)then
            accessoryVoApi:setGuideStep(1)
            local menuItem=self.m_functionBtnTb["b3"]
            if(menuItem~=nil)then
                G_addFlicker(menuItem,2,2)
            end
        end
    end
end
function mainUI:dispose()
    self.myUILayer=nil
    self.mySpriteLeft=nil
    self.mySpriteRight=nil
    self.mySpriteDown=nil
    self.mySpriteWorld=nil
    self.m_labelMoney=nil
    self.m_labelGold=nil
    self.m_labelR1=nil
    self.m_labelR2=nil
    self.m_labelR3=nil
    self.m_labelR4=nil
    self.m_labelLevel=nil
    self.m_menuToggle=nil
    self.m_menuToggleSmall=nil
    self.tv=nil
    self.m_luaSpTab=nil
    self.m_luaLayer=nil
    self.m_luaSp1=nil
    self.m_luaSp2=nil
    self.m_luaSp3=nil
    self.m_luaSp4=nil
    self.m_luaSp5=nil
    self.m_luaSp6=nil
    self.m_luaSp7=nil
    self.m_skillHeigh=nil
    self.m_dis=nil
    self.m_luaTime=nil
    self.m_pointLuaSp=nil
    self.m_pointVip=nil
    self.m_menuToggleVip=nil
	self.m_vipLevel=nil
    self.m_iconScaleX=nil
    self.m_iconScaleY=nil
    self.m_dailySp=nil
    self.m_taskSp=nil
	self.m_enemyComingSp=nil
	self.m_countdownLabel=nil
    self.m_travelTimeLabel=nil
    self.m_travelSp=nil
	self.m_newsIconTab=nil
	self.m_newsNumTab=nil
    self.m_lastSearchXValue=0
    self.m_lastSearchYValue=0
	self.m_chatBg=nil
	self.m_chatBtn=nil
	self.m_labelLastType=nil
	self.m_labelLastMsg=nil
	self.m_labelLastName=nil
	self.m_bookmak=nil
    self.m_labelX=nil
    self.m_labelY=nil
	self.m_flagTab=nil
	self.m_rechargeBtn=nil
	self.m_showWelcome=nil
    self.m_luaSpBuff=nil
    self.m_luaSpBuffSp1=nil
    self.m_luaSpBuffSp2=nil
    self.m_luaSpBuffSp3=nil
	self.m_newGiftsSp=nil
	self.m_dailyRewardSp=nil
    self.m_acAndNoteSp = nil
    self.dialog_acAndNote = nil
	self.m_leftIconTab=nil
  self.m_rightTopIconTab = nil
	self.m_isNewGuide=nil
	self.m_isShowDaily=nil
	self.m_newYearIcon=nil
    self.m_noticeIcon=nil
    self.m_helpDefendIcon=nil
    self.m_helpDefendLabel=nil
    self.fbInviteBtnHasShow=false
    self.onlinePackageBtn=nil
    self.m_signIcon=nil
    m_functionBtnTb=nil
    self.needShowAccessoryGuide=nil
end



