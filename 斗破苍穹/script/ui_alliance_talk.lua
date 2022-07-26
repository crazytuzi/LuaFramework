require"Lang"
UIAllianceTalk = {}
local ui_userName = nil
local ui_userLvl = nil
local ui_userFight = nil
local ui_userUnio = nil
local ui_headIcon = nil
local ui_vip = nil
local ui_vipText = nil
local userData = nil
local function netCallbackFunc(msgData)
    local code = tonumber(msgData.header)
    if code == StaticMsgRule.enemyPlayerInfo then
        pvp.loadGameData(msgData)
		UIManager.pushScene("ui_arena_check")
    end
end
function showEmailInfo()
    local dialog = ccui.Layout:create()
	dialog:setContentSize(UIManager.screenSize)
	dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	dialog:setBackGroundColor(cc.c3b(0, 0, 0))
	dialog:setBackGroundColorOpacity(130)
	dialog:setTouchEnabled(true)
	
	local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
      bg_image:setAnchorPoint(cc.p(0.5, 0.5))
      bg_image:setPreferredSize(cc.size(450, 300))
      bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
      dialog:addChild(bg_image)
      local bgSize = bg_image:getPreferredSize()
  
      local title = ccui.Text:create()
      title:setAnchorPoint( 0 , 0.5 )
      title:setString(Lang.ui_alliance_talk1)
      title:setFontName(dp.FONT)
      title:setFontSize(23)
      title:setTextColor(cc.c4b(255, 255, 255, 255))
      title:setPosition(cc.p( bg_image:getPositionX() - bgSize.width / 2 - 50 , bgSize.height * 0.83))
      bg_image:addChild(title)

      local title1 = ccui.Text:create()
      title1:setAnchorPoint( 0 , 0.5 )
      title1:setString( ui_userName:getString() )
      title1:setFontName(dp.FONT)
      title1:setFontSize(23)
      title1:setTextColor(cc.c4b(0, 255, 0, 255))
      title1:setPosition(title:getPositionX() + title:getContentSize().width , title:getPositionY() )
      bg_image:addChild(title1)

      local title2 = ccui.Text:create()
      title2:setAnchorPoint( 0 , 0.5 )
      title2:setString( Lang.ui_alliance_talk2 )
      title2:setFontName(dp.FONT)
      title2:setFontSize(23)
      title2:setTextColor(cc.c4b(255, 255, 255, 255))
      title2:setPosition(title1:getPositionX() + title1:getContentSize().width , title1:getPositionY() )
      bg_image:addChild(title2)


      local text = ccui.RichText:create();
      local re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, Lang.ui_alliance_talk3  , dp.FONT , 23 )  
      text:pushBackElement(re1)
      local imgBg = ccui.Scale9Sprite:create("ui/tk_di02.png")
      imgBg:setPreferredSize(cc.size(400 , 120))
      local msgBox = cc.EditBox:create( cc.size( 400 , 120 ),ccui.Scale9Sprite:create() )
      --msgBox:setPlaceHolder("最多输入40字")
      msgBox:setPlaceholderFontSize( 23 )
      local textContent = ""
      local function editboxEventHandler(eventType)
--        if eventType == "began" then
--            -- 当编辑框获得焦点并且键盘弹出的时候被调用
--            msgBox:setText(textContent)
--        elseif eventType == "ended" then
--            -- 当编辑框失去焦点并且键盘消失的时候被调用
--            textContent = msgBox:getText()
--            text:removeElement( re1 )
--            re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, textContent  , dp.FONT , 23 )  
--            --msgBox:
--            text:pushBackElement(re1)
--            if textContent ~= "" then
--                msgBox:setText("   ")
--            end
--        elseif eventType == "changed" then
--            -- 当编辑框的文本被修改的时候被调用
--            text:removeElement( re1 )
--            re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, msgBox:getText() , dp.FONT , 23 )  
--            --msgBox:
--            text:pushBackElement(re1)
--        elseif eventType == "return" then
--            text:removeElement( re1 )
--            re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, textContent , dp.FONT , 23 )  
--            --msgBox:
--            text:pushBackElement(re1)
--            -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
--        end

        local isIOS = device.platform == "ios"
		if eventType == "return" then
			text:removeElement( re1 )           
            textContent = msgBox:getText()
            if msgBox:getText() == "" then
                msgBox:setZOrder( 2 )
                re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, Lang.ui_alliance_talk4 , dp.FONT , 23 )  
            else
                re1 = ccui.RichElementText:create( 1, cc.c3b(0, 0, 0), 255, msgBox:getText() , dp.FONT , 23 )  
            end
            
            text:pushBackElement(re1)
        elseif eventType == "began" then
            msgBox:setZOrder( 0 )
            if isIOS then text:setVisible(false) msgBox:setZOrder( 2 ) end
        elseif eventType == "ended" then
            if isIOS then text:setVisible(true) msgBox:setZOrder( 0 ) end
		end
      end
     -- msgLabel:setString(msg)
      msgBox:setFontName(dp.FONT)
      msgBox:setFontSize( 23 )  
      msgBox:setFontColor(cc.c3b( 0 , 0 , 0 ))
      msgBox:setMaxLength( 40 )
      msgBox:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2 + 10 ) )
      msgBox:registerScriptEditBoxHandler(editboxEventHandler)
      bg_image:addChild(msgBox , 2 )

      imgBg:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2 + 10 ) )
      bg_image:addChild(imgBg , 1 )

      text:setContentSize( cc.size( msgBox:getContentSize().width - 20 , msgBox:getContentSize().height - 20 ) )
      text:ignoreContentAdaptWithSize( false )
    --  text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    --  text:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
     -- text:setAnchorPoint( cc.p( 0 , 1 ) )
      text:setPosition(cc.p( msgBox:getPositionX() , msgBox:getPositionY()  ) )
      bg_image:addChild(text , 2)


  
      local sureBtn = ccui.Button:create("ui/tk_btn_big_blue.png", "ui/tk_btn_big_blue.png")
      sureBtn:setScale( 0.8 )
  	  sureBtn:setTitleText(Lang.ui_alliance_talk5)
      
      sureBtn:setTitleFontName(dp.FONT)
      sureBtn:setTitleColor(cc.c3b(255, 255, 255))
      sureBtn:setTitleFontSize(30)
      sureBtn:setPressedActionEnabled(true)
      sureBtn:setTouchEnabled(true)
  	  sureBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.2))
      bg_image:addChild(sureBtn)
      local backBtn = ccui.Button:create("ui/tk_btn_big_red.png", "ui/tk_btn_big_red.png")
    
  	  backBtn:setTitleText(Lang.ui_alliance_talk6)
      backBtn:setScale( 0.8 )
	  backBtn:setTitleFontName(dp.FONT)
	  backBtn:setTitleColor(cc.c3b(255, 255, 255))
	  backBtn:setTitleFontSize(30)
	  backBtn:setPressedActionEnabled(true)
	  backBtn:setTouchEnabled(true)
	  backBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.2))
	  bg_image:addChild(backBtn)
     
      local function btnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
            if sender == backBtn then
                cclog("send Email")
                if textContent and textContent ~= "" then
                    netSendPackage(
                        {header = StaticMsgRule.sendMail ,
                         msgdata = { string = { oppoName = ui_userName:getString() , oppoContent = textContent } }
                        }
                    )
                    dialog:removeFromParent()
                else
                    UIManager.showToast(Lang.ui_alliance_talk7)
                end
            elseif sender == sureBtn then
			    dialog:removeFromParent()
            end
		end
	 end
	 sureBtn:addTouchEventListener(btnEvent)
	 backBtn:addTouchEventListener(btnEvent)
	 bg_image:setScale(0.1)
	 UIManager.uiLayer:addChild(dialog, 10000)
	 bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end
function UIAllianceTalk.init()
    --local layout = ccui.Helper:seekNodeByName( UIAllianceTalk.Widget , "ui_middle" )
    local user_bg = ccui.Helper:seekNodeByName( UIAllianceTalk.Widget , "image_di_menber" )
    local user_bg_1 = ccui.Helper:seekNodeByName( user_bg , "image_di_info" )
    ui_userName = ccui.Helper:seekNodeByName( user_bg_1 , "text_name" )
    ui_userLvl = ccui.Helper:seekNodeByName( user_bg_1 , "text_lv" )
    ui_userFight = ccui.Helper:seekNodeByName( user_bg_1 , "text_fight" )
    ui_userUnio = ccui.Helper:seekNodeByName( user_bg_1 , "text_congratulate_all" )
    local icon_img = ccui.Helper:seekNodeByName( user_bg_1 , "image_frame_title" ) 
    ui_headIcon = ccui.Helper:seekNodeByName( icon_img , "image_title" )
    ui_vip = ccui.Helper:seekNodeByName( icon_img , "image_vip" )
    ui_vipText = ccui.Helper:seekNodeByName( user_bg_1 , "text_vip" )
    ui_uidText = ccui.Helper:seekNodeByName( user_bg_1 , "text_congratulate_all_0" )
    local btn_talk = ccui.Helper:seekNodeByName( UIAllianceTalk.Widget , "btn_cancel" )
    local btn_email = ccui.Helper:seekNodeByName( UIAllianceTalk.Widget , "btn_ok" )
    local btn_look = ccui.Helper:seekNodeByName(UIAllianceTalk.Widget, "btn_look")
    btn_talk:setPressedActionEnabled(true)
    btn_email:setPressedActionEnabled(true)
    btn_look:setPressedActionEnabled(true)
    local function onBtnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_talk then
                UIManager.popScene()
                if UITalk.Widget and UITalk.Widget.getParent then
                    UITalk.freshToUser( ui_userName:getString() )
                else
                    UIManager.pushScene("ui_talk")
                    UITalk.freshToUser( ui_userName:getString() )
                end
            elseif sender == btn_email then
                if dp.getUserData().roleLevel < 10 then
                    UIManager.showToast(Lang.ui_alliance_talk8)
                else
                    showEmailInfo()
                end
            elseif sender == btn_look then
                if userData and userData.playerId then
                    UIManager.showLoading()
				    netSendPackage({header = StaticMsgRule.enemyPlayerInfo, msgdata = {int={playerId=userData.playerId}}}, netCallbackFunc)
                end
            else
                UIManager:popScene()  
            end
        end
    end
    btn_talk:addTouchEventListener( onBtnEvent )
    btn_email:addTouchEventListener( onBtnEvent )
    btn_look:addTouchEventListener( onBtnEvent )
    UIAllianceTalk.Widget:addTouchEventListener( onBtnEvent )

end

function UIAllianceTalk.freshInfo( userName , userLvl , userFight , userUnio , headId , vip ,accountId , serverId)
    ui_userName:setString( userName )
    ui_userLvl:setString( Lang.ui_alliance_talk9..userLvl )
    ui_userFight:setString( Lang.ui_alliance_talk10..userFight )
    if userUnio then
        ui_userUnio:setString( Lang.ui_alliance_talk11..userUnio )
    else
        ui_userUnio:setString( Lang.ui_alliance_talk12 )
    end
    
    if string.find(headId,"_") then
        local dictCard = DictCard[ tostring( utils.stringSplit(headId, "_")[1] ) ]
	    if dictCard then
            if utils.stringSplit(headId, "_")[2] == "1" then
		        ui_headIcon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
            else
                ui_headIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            end
	    end
    else
        local dictCard = DictCard[ tostring( headId ) ]
        ui_headIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    end
    
    if tonumber(vip) == 0 then
        ui_vip:setVisible( false )
    else
         ui_vip:setVisible( true )
    end
    ui_vipText:setString("VIP " .. vip)
    
    if serverId and accountId then
        ui_uidText:setVisible(true) 
        math.randomseed(tonumber(serverId) * accountId)
        ui_uidText:setString("Uid:"..tostring(serverId)..accountId..math.random(10000))
    else
        ui_uidText:setVisible(false)
    end
end
function UIAllianceTalk.setup()
end
function UIAllianceTalk.free()
    userData = nil
end

function UIAllianceTalk.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_talk")
    UIAllianceTalk.freshInfo(userData.userName, userData.userLvl, userData.userFight, userData.userUnio, userData.headId,userData.vip,userData.accountId,userData.serverId)
end
