local MailList = class("MailList", require("src/LeftSelectNode") )

function MailList:ctor( params )

    local isRed = false
    if G_MAIL_INFO and G_MAIL_INFO.emaliCount then
      isRed = G_MAIL_INFO.emaliCount > 0 
    end
    if G_MAINSCENE and G_MAINSCENE.__mailRed then G_MAINSCENE.__mailRed:setVisible( false ) end
    if G_MAINSCENE and G_MAINSCENE.__mailRed2 then G_MAINSCENE.__mailRed2:setVisible( false ) end

    if G_MAINSCENE and G_MAINSCENE.mailFlag then
      removeFromParent( G_MAINSCENE.mailFlag ) 
      G_MAINSCENE.mailFlag = nil 
    end

  

    params = params or {}
    self.selectIdx = params.activityID or 0  --初始化活动默认激活项
    getRunScene():addChild(self)

    self.base_node = popupBox({ parent = self , 
                         bg = COMMONPATH .. "bg/bg18.png" , 
                         close = { path = "res/component/button/x2.png" , offX = -38 , offY = -27 , callback = function() if G_MAINSCENE and G_MAINSCENE.__MaileListRefresh then G_MAINSCENE.__MaileListRefresh = nil end removeFromParent( self )   end } , 
                         zorder = 200 , 
                         actionType = 1 ,
                       })
    local size = self.base_node:getContentSize()
    createLabel(self.base_node ,  game.getStrByKey("title_Mail"), cc.p(size.width/2,size.height-28),cc.p(0.5, 0.5), 24, true, nil, nil)

    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 15),
        cc.size(350, 454),
        4
    )

    self.leftBg = createScale9Sprite(
        self.base_node,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(41, 15 + 60),
        cc.size(332, 386),
        cc.p(0, 0)
    )

    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(389, 15),
        cc.size(434, 454),
        4
    )

    createSprite(self.base_node, "res/layers/mail/r_bg2.png", cc.p(390 , 15), cc.p(0, 0))

    self.getAll = createTouchItem( self.base_node,"res/component/button/49.png",cc.p(205, 48) , function() g_msgHandlerInst:sendNetDataByTable(ITEM_CS_PICKEALLMAIL, "ItemPickAllEmailProtocol", {}) end)
    createLabel( self.getAll , game.getStrByKey("mail_recvAll") , getCenterPos( self.getAll ) , nil, 20,true)

    __createHelp({parent = self.base_node, str =  game.getStrByKey('mail_help_tip' ) , pos = cc.p( 70 , 48) , zorder = 10 })

    self.numTip = createLabel( self.base_node , "0/24" , cc.p(300, 48) , cc.p(0, 0.5), 22, true)

    self.callBackFunc = function(idx)
        --更新右侧界面
        self:updateRight()
    end
    
    self.normal_img = "res/component/button/42.png"
    self.select_img = "res/component/button/42_sel.png"
    local msize = cc.size( 360 , 370   )
    self:createTableView(self.base_node, msize,  cc.p( 45 , 86 ) , true)


    self.view_node = cc.Node:create()
    setNodeAttr( self.view_node , cc.p( 390 , 12 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.view_node )

    self:updateRight()

    if G_MAINSCENE then G_MAINSCENE.__MaileListRefresh = function() self:refreshDataFun() end end
    if G_TUTO_NODE then
      G_TUTO_NODE:setTouchNode(self.base_node:getCloseBtn(), TOUCH_MAILBOX_CLOSE)
      G_TUTO_NODE:setShowNode(self, SHOW_MAILBOX)
    end

end

function MailList:getBaseNode()
    return self.base_node
end

function MailList:refreshDataFun()
    local num = self.selectIdx - 1 
    local emaliCount =  G_MAIL_INFO.emaliCount - 1 
    self.selectIdx = num > emaliCount  and  emaliCount or num
    self.selectIdx = self.selectIdx < 0 and 0 or self.selectIdx 

    self:getTableView():reloadData()
    self:updateRight()
end

function MailList:updateRight()     
    if self.view_node then self.view_node:removeAllChildren()  end --清除可视内容

    if G_MAIL_INFO.emailInfo == nil then
        return
    end

    --dump(G_MAIL_INFO)
    local mailCount = 0
    if G_MAIL_INFO and G_MAIL_INFO.emaliCount then
      mailCount = G_MAIL_INFO.emaliCount
      if self.numTip then
        self.numTip:setString(mailCount.."/24")
        if mailCount > 0 then
          self.numTip:setVisible(true)
        else
          self.numTip:setVisible(false)
        end
      end
    end

    if not G_MAIL_INFO.emaliCount or G_MAIL_INFO.emaliCount == 0  then
      self.getAll:setVisible( false  ) 
      self.leftBg:setVisible( false )
      createSprite( self.view_node , "res/mainui/npc_big_head/0.png" , cc.p( -182 , 5 ) , cc.p( 0.5 , 0) )
      createSprite( self.view_node , "res/layers/mail/speak_bg.png" , cc.p( -182 , 383 ) , cc.p( 0.5 , 0) )
      createLabel(self.view_node , game.getStrByKey("mail_tip") , cc.p( -182 , 418 ) , cc.p( 0.5 , 0 ), 20, nil , nil , nil , MColor.lable_yellow )
      return
    end
    self.leftBg:setVisible( true )
    self.getAll:setVisible( true ) 


    local item = G_MAIL_INFO.emailInfo[ self.selectIdx +  1]
    if item == nil then return end
    local str= item.title or ""
    if str == ""  then
      str = game.getStrByKey( "system" ) .. game.getStrByKey( "info" )
    end

    createLabel( self.view_node , str , cc.p( 30 , 425 ) ,  cc.p( 0.0 , 0.5 ) ,  22  , nil , nil , nil , MColor.lable_yellow  )
    local getBtn = createMenuItem(self.view_node,"res/component/button/49.png",cc.p(608 - 390, 35 ),function() g_msgHandlerInst:sendNetDataByTable( ITEM_CS_PICKEMAIL, "ItemPickEmailProtocol", { emailId = G_MAIL_INFO.emailInfo[ self.selectIdx + 1 ].emailIDX } ) end)
    createLabel(getBtn , game.getStrByKey("mail_receive") , getCenterPos( getBtn ) , nil, 20,true)
    G_TUTO_NODE:setTouchNode(getBtn, TOUCH_MAILBOX_TAKE)

    createLabel(self.view_node , game.getStrByKey("attachment") ,cc.p( 30 , 425  - 139 -18 ) , cc.p( 0 , 0 ), 20, nil , nil , nil , MColor.black )



    local width , height = 400 , 110


    local function createLayout()
        local tempNode = cc.Node:create()

        local dates = os.date("*t",item.startDate)
        local sendTimeStr = string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
        

        local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( 400 , 10 ) , cc.p( 0 , 1 ) , 22 , 18 , MColor.black )
        text:addText( item.desc ,  MColor.black , false )
        --超链接处理
        if item.hyperlink and item.linkContent then text:addUrlItem( "\n" .. item.linkContent .. "|" .. item.hyperlink ,  MColor.green ) end
        text:format()

        local senderTxt = createLabel( tempNode  , item.sender or "" , cc.p( 400 , 407 - 90 ) , cc.p( 1 , 0 ) ,  18  , nil , nil , nil , MColor.black )
        local timeTxt = createLabel( tempNode  , sendTimeStr or "" , cc.p( 0 , 0 ) , cc.p( 1 , 0 ) ,  18  , nil , nil , nil , MColor.black )

        tempNode:setContentSize( cc.size( width , math.abs( text:getContentSize().height + 40 )  ) )

        setNodeAttr( text , cc.p( 0 , text:getContentSize().height + 40 ) , cc.p( 0 , 1  ) )
        setNodeAttr( senderTxt , cc.p( 400 , 20 ) , cc.p( 1 , 0  ) )
        setNodeAttr( timeTxt , cc.p( 400 , 0 ) , cc.p( 1 , 0  ) )

        return tempNode
    end

    local scrollView1 = cc.ScrollView:create()    
    scrollView1:setViewSize(cc.size( width + 40  , height ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
    scrollView1:setPosition( cc.p( 20 , 407 - 110  ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    local layer = createLayout()
    scrollView1:setContainer( layer )
    scrollView1:updateInset()
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    self.view_node:addChild(scrollView1)

    local layerSize = layer:getContentSize()
    scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height  ) )


  





    if tablenums( item.awards ) > 0 then
        local width = 485 + 25 - 137
        local height = 190
        local scrollView1 = cc.ScrollView:create()
        scrollView1:setViewSize(cc.size( width , height ) )
        scrollView1:setPosition( cc.p(  576/2 - 70 , 140 + 35  ) )
        scrollView1:ignoreAnchorPointForPosition(false)

        local groupAwards =  __createAwardGroup( item.awards , nil , 85 , nil , false )
        setNodeAttr( groupAwards , cc.p( 0 , 30 ) , cc.p( 0.5 , 0 ) )

        scrollView1:setContainer( groupAwards )
        scrollView1:updateInset()

        scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
        scrollView1:setClippingToBounds(true)
        scrollView1:setBounceable(true)
        scrollView1:setDelegate()
        self.view_node:addChild(scrollView1)

        if groupAwards:getContentSize().width < width - 100 then
          scrollView1:setTouchEnabled( false )
          scrollView1:setContentOffset( cc.p( ( width - groupAwards:getContentSize().width )/2 , 40 ) )
        else
          scrollView1:setTouchEnabled( true )
        end    

    end



end



function MailList:cellSizeForTable(table,idx) 
    return 120,432
end

function MailList:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()

    if nil == cell then
        cell = cc.TableViewCell:new()   
    else
        cell:removeAllChildren()
    end
    
    local button = createSprite(cell, self.normal_img, cc.p(0, 0), cc.p(0, 0))
    button:setTag(10)
    if button then
        local size = button:getContentSize()
        if idx == self.selectIdx then button:setTexture(self.select_img) end
        if idx == 0 then G_TUTO_NODE:setTouchNode(button, TOUCH_MAILBOX_FIRST) end

        local mailData = G_MAIL_INFO.emailInfo[ idx + 1 ]
        if mailData then
              local itemBg = createSprite( cell , "res/common/bg/itemBg.png" , cc.p( 15 , size.height/2 ) , cc.p( 0.0 , 0.5) )
              local iconSp = "res/layers/mail/default.png"
              -- if mailData.itemCount>0 then 
              --   iconSp = require("src/config/propOp").icon( mailData.items[1].id ) 
              -- end
              local icon = createSprite( itemBg , iconSp , getCenterPos( itemBg ) , cc.p( 0.5 , 0.5) )
              local str= mailData.title or ""
              if str == "" then
                str = game.getStrByKey( "system" ) .. game.getStrByKey( "info" )
              end
              createLabel( cell , str , cc.p( 100 , size.height/4*3 ) , cc.p( 0.0 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow )
              createLabel( cell , game.getStrByKey("mail_sender") , cc.p( 100 , size.height/4*2 ) , cc.p( 0.0 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow)
              createLabel( cell , game.getStrByKey("system") , cc.p( 180 , size.height/4*2 ) , cc.p( 0.0 , 0.5 ) , 22 , nil , nil , nil , MColor.red )

              local dates = os.date("*t",mailData.startDate)
              local sendTimeStr = string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
              createLabel( cell , sendTimeStr , cc.p( 100 , size.height/4 ) , cc.p( 0.0 , 0.5 ) , 18 , nil , nil , nil , MColor.lable_black )
        end

    end


    return cell
end



function MailList:numberOfCellsInTableView(table)
   	return  G_MAIL_INFO.emaliCount
end


return MailList