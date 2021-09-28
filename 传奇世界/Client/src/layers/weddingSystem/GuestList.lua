local GuestList = class("GuestList", function () return cc.Layer:create() end )

GuestList.guestList = nil

function GuestList:ctor(guestList)
    self.guestList = guestList
    self:addScrollView()
    self:showGuest()
    SwallowTouches(self)
end

function GuestList:addScrollView()
    
    local bg = createSprite(self,"res/common/bg/bg18.png",cc.p(display.cx,display.cy),cc.p(0.5,0.5))
    local title = createLabel(bg,game.getStrByKey("wdsys_guestList"),cc.p(420,500),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_yellow)
    local closeFunc = function() 
		self:removeFromParent()
	end
    local close_item = createTouchItem(bg, "res/component/button/X.png", cc.p(810,500), closeFunc, nil)
	close_item:setLocalZOrder(500)

    local s9 = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(33,22),
        cc.size(790,450),
        5
    )
    s9:setAnchorPoint(cc.p(0,0))

	local s9 = CreateListTitle(bg, cc.p(428,450), 790, 47)
    createLabel(s9,game.getStrByKey("wdsys_roleName"),cc.p(100,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("wdsys_roleSex"),cc.p(230,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("wdsys_zhiye"),cc.p(335,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("wdsys_level"),cc.p(440,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    createLabel(s9,game.getStrByKey("wdsys_redpackageNum"),cc.p(580,26),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    -- scroll view
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 892,400 ))
    scrollView:setPosition( cc.p( 15 , 22 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    --scrollView:setContainer(node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    bg:addChild(scrollView)
    --scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+scrollView:getViewSize().height ))
    self.scrollView = scrollView
end

function GuestList:showGuest()
    -- get server data first ????
    local node = cc.Node:create()
    local dataNum = #self.guestList
    local dataIndex = dataNum
    for k,v in pairs(self.guestList) do
    --[[
    
    optional string roleName = 1;	//角色名字
	optional int32 sex = 2;			//性别
	optional int32 school = 3;		//职业
	optional int32 level = 4;		//等级
	optional int32 bonus1 = 5;		//祝福贺卡红包 0 表示没送过 1 表示送过了
	optional int32 bonus2 = 6;		//庆贺喜酒红包 0 表示没送过 1 表示送过了
	optional int32 bonus3 = 7;		//新婚红包 0 表示没送过 1 表示送过了
	optional string reoleSID = 8;	//用户静态ID

    ]]
        print("add one guest ............................")
        local s9 = cc.Scale9Sprite:create("res/common/scalable/bg5.png")
        s9:setContentSize(cc.size(786,60))
        s9:setAnchorPoint(cc.p(0,0))
        s9:setCapInsets(cc.rect(20,20,80,80))
        s9:setPosition(cc.p(20,(dataIndex-1)*60))
        dataIndex = dataIndex - 1
        node:addChild(s9)

        createLabel(s9,v.roleName,cc.p(95,26),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        createLabel(s9,v.sex == 1 and game.getStrByKey("man") or game.getStrByKey("female"),cc.p(225,26),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        createLabel(s9,getSchoolByName(tonumber(v.school)),cc.p(335,26),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        createLabel(s9,v.level,cc.p(435,26),cc.p(0.5,0.5),24,nil,nil,nil,MColor.lable_black)
        
        local scaleNum = 0.3
        local hl1 = createGraySprite(s9,"res/weddingSystem/cardIcon.png",cc.p(530,26),cc.p(0.5,0.5),true)
        hl1:setScale(scaleNum)
        if v.bonus1 == 1 then
            hl1:removeColorGray()
        end

        local hl2 = createGraySprite(s9,"res/weddingSystem/wineIcon.png",cc.p(580,26),cc.p(0.5,0.5),true)
        hl2:setScale(scaleNum)
        if v.bonus2 == 1 then
            hl2:removeColorGray()
        end

        local hl3 = createGraySprite(s9,"res/weddingSystem/redPackgeIcon.png",cc.p(630,26),cc.p(0.5,0.5),true)
        hl3:setScale(scaleNum)
        if v.bonus3 == 1 then
            hl3:removeColorGray()
        end
        
        local function getMissionBtnFunc()
            local function yesCallBack()
                g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_KICKOUT, "MarriageCSWeddingKickOut", {roleSID=v.reoleSID})
            end
            local textCon = string.format( game.getStrByKey("wdsys_songkeConfirm"),v.roleName)
            MessageBoxYesNo(game.getStrByKey("tip"),textCon,yesCallBack)
        end

        local missionBtn = createMenuItem(node, "res/component/button/48.png", cc.p(735, 26), getMissionBtnFunc)
        createLabel(missionBtn,game.getStrByKey("wdsys_songke"),cc.p(46,21),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    end
    --end
    node:setContentSize(cc.size(790,dataNum*60))
    self.scrollView:setContainer(node)
    self.scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+self.scrollView:getViewSize().height ))
end

return GuestList