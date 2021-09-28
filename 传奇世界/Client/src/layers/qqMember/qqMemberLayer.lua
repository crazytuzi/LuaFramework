local qqMemberLayer = class("qqMemberLayer", function() return cc.Layer:create() end)

local path = "res/layers/qqMember/"
local pathCommon = "res/common/"

function qqMemberLayer:ctor()
    --local msgids = {QQVIP_SC_REWARD_INFO,QQVIP_SC_GET_REWARD}
    local msgids = {QQVIP_SC_GET_REWARD}
	require("src/MsgHandler").new(self,msgids)

    g_msgHandlerInst:sendNetDataByTableExEx(QQVIP_CS_REWARD_INFO, "QQVipRewardInfoRequest", {})
    cclog("QQVIP_CS_REWARD_INFO")

    self.awardInfo = {}

	self.selIndex = 1
    if game.getVipLevel() == 2 then
        self.selIndex = 2
    end

	local bg = createBgSprite(self, nil,nil,true)
	self.bg = bg

	local menuFunc = function(tag, sender, param1)
		self.selIndex = tag
		self:reset()
	end
	self.menuFunc = menuFunc

	local tabs = {}
	tabs[#tabs+1] = game.getStrByKey("qqmember_text_title")
	tabs[#tabs+1] = game.getStrByKey("super_qqmember_text_title")

	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
			menuFunc(tag)
			local title_label = bg:getChildByTag(12580)
			if title_label then
                --title_label:setString(tabs[tag]) 
                title_label:setString(game.getStrByKey("qqmember_bigTitle")) 
            end
		end,
		selected = self.selIndex,
	})
	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
	self.tab_control = TabControl

	SwallowTouches(self)

    --左侧
    local leftBg = cc.Sprite:create("res/common/scalable/panel_outer_base.png", cc.size(286,501))
	leftBg:setAnchorPoint(cc.p(0.5, 0))
    leftBg:setPosition(cc.p(175,37))
	leftBg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    self.bg:addChild(leftBg)
    self.leftBg = leftBg

    createSprite(leftBg, "res/layers/qqMember/bg_left.jpg", cc.p(2, 2), cc.p(0, 0))
    createScale9Sprite(leftBg, "res/common/scalable/scale15.png", cc.p(143, 462), cc.size(282, 37), cc.p(0.5, 0) )

    --右侧
    local rightBg = cc.Sprite:create("res/common/scalable/panel_outer_base.png", cc.size(602,501))
	rightBg:setAnchorPoint(cc.p(0.5, 0))
    rightBg:setPosition(cc.p(627,37))
	rightBg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    self.bg:addChild(rightBg)
    self.rightBg = rightBg

    createScale9Sprite(rightBg, "res/common/scalable/scale15.png", cc.p(301, 462), cc.size(598, 37), cc.p(0.5, 0) )

    local rb1 = createScale9Sprite(bg, "res/common/scalable/panel_inside_scale9.png", cc.p(427, 43), cc.size(188, 448), cc.p(0.5, 0) )
    local rb2 = createScale9Sprite(bg, "res/common/scalable/panel_inside_scale9.png", cc.p(627, 43), cc.size(188, 448), cc.p(0.5, 0) )
    local rb3 = createScale9Sprite(bg, "res/common/scalable/panel_inside_scale9.png", cc.p(827, 43), cc.size(188, 448), cc.p(0.5, 0) )

    self.subRightBg1 = createSprite(rb1,"res/layers/qqMember/bg_pic.jpg",cc.p(2, 3),cc.p(0,0))
    self.subRightBg2 = createSprite(rb2,"res/layers/qqMember/bg_pic.jpg",cc.p(2, 3),cc.p(0,0))
    self.subRightBg3 = createSprite(rb3,"res/layers/qqMember/bg_pic.jpg",cc.p(2, 3),cc.p(0,0))

    createSprite(rb1,"res/layers/qqMember/zhuanghsi.png",cc.p(94, 428),cc.p(0.5,0.5))
    createSprite(rb2,"res/layers/qqMember/zhuanghsi.png",cc.p(94, 428),cc.p(0.5,0.5))
    createSprite(rb3,"res/layers/qqMember/zhuanghsi.png",cc.p(94, 428),cc.p(0.5,0.5))

    createLabel(rb1, game.getStrByKey("qqmember_text_libao1"), cc.p(94, 428), cc.p(0.5, 0.5), 18, true)
    createLabel(rb2, game.getStrByKey("qqmember_text_libao2"), cc.p(94, 428), cc.p(0.5, 0.5), 18, true)
    createLabel(rb3, game.getStrByKey("qqmember_text_libao3"), cc.p(94, 428), cc.p(0.5, 0.5), 18, true)

    createSprite(rb1,"res/layers/qqMember/fenge.png",cc.p(94, 80),cc.p(0.5,0))
    createSprite(rb2,"res/layers/qqMember/fenge.png",cc.p(94, 80),cc.p(0.5,0))
    createSprite(rb3,"res/layers/qqMember/fenge.png",cc.p(94, 80),cc.p(0.5,0))

    
    self.m_bInit = true
    self:reset()

    self:registerScriptHandler(function(event)
		if event == "enter" then
			qqMemberLayer.curInst = self
		elseif event == "exit" then
			qqMemberLayer.curInst = nil
		end
	end)
end

function qqMemberLayer:reset()
    if not self.m_bInit then
        return
    end

    local textTable = {game.getStrByKey("super_qqmember_text_1"),
                       game.getStrByKey("super_qqmember_text_2"),
                       game.getStrByKey("super_qqmember_text_3"),
                       game.getStrByKey("super_qqmember_text_4"), }
    
    if self.selIndex == 1 then
        textTable = {  game.getStrByKey("qqmember_text_1"),
                       game.getStrByKey("qqmember_text_2"),
                       game.getStrByKey("qqmember_text_3"),
                       game.getStrByKey("qqmember_text_4"), }
    end

    --构造左侧内容
    self.leftBg:removeChildByTag(9)
    local leftNode = cc.Node:create()
    leftNode:setPosition(cc.p(0,0))
    self.leftBg:addChild(leftNode, 1, 9)

    createLabel(leftNode, textTable[1], cc.p(143, 481), cc.p(0.5, 0.5), 20, true)

    local btnCB = function()
        --开通或续费会员
        
        --String[] serviceCodes = {"LTMCLUB", "CJCLUB", "XXJZGW", "XXZXYY"};
        --String[] serviceNames = {"QQ会员", "超级会员", "黄钻", "绿钻"};
        --开通1 续费3

        local curQQVip = game.getVipLevel()
        local zoneid = tostring(userInfo.serverId) .. "_" .. tostring(userInfo.currRoleStaticId)
        if curQQVip == 0 then
            if self.selIndex == 1 then
                callbackTab.qqVipPayMsg="开通QQ会员"
                sdkQQVipPay("LTMCLUB", "QQ会员", 1, zoneid)
                self.payType = 1
            else
                callbackTab.qqVipPayMsg="开通超级会员"
                sdkQQVipPay("CJCLUB", "超级会员", 1, zoneid)
                self.payType = 3
            end
        elseif curQQVip == 1 then
            if self.selIndex == 1 then
                callbackTab.qqVipPayMsg="续费QQ会员"
                sdkQQVipPay("LTMCLUB", "QQ会员", 3, zoneid)
                self.payType = 2
            else
                callbackTab.qqVipPayMsg="开通超级会员"
                sdkQQVipPay("CJCLUB", "超级会员", 1, zoneid)
                self.payType = 3
            end
        elseif curQQVip == 2 then
            callbackTab.qqVipPayMsg="续费超级会员"
            sdkQQVipPay("CJCLUB", "超级会员", 3, zoneid)
            self.payType = 4
        end
    end

    local curQQVip = game.getVipLevel() 
    if curQQVip == 0 then
        local btn = createMenuItem(leftNode, "res/component/button/8.png", cc.p(143, 50), btnCB, 1, true)
	    createLabel(btn, textTable[3], cc.p(110, 33), cc.p(0.5, 0.5), 24, true)
    elseif curQQVip == 1 then
        local btn = createMenuItem(leftNode, "res/component/button/8.png", cc.p(143, 50), btnCB, 1, true)
        if self.selIndex == 1 then           
	        createLabel(btn, textTable[4], cc.p(110, 33), cc.p(0.5, 0.5), 24, true)
        else
            createLabel(btn, textTable[3], cc.p(110, 33), cc.p(0.5, 0.5), 24, true)
        end
    elseif curQQVip == 2 then        
        if self.selIndex == 2 then 
            local btn = createMenuItem(leftNode, "res/component/button/8.png", cc.p(143, 50), btnCB, 1, true)          
	        createLabel(btn, textTable[4], cc.p(110, 33), cc.p(0.5, 0.5), 24, true)
        end
    end
   
    self:createDesp(leftNode)     --特权描述信息

    --右侧
    self.rightBg:removeChildByTag(9)
    local rightNode = cc.Node:create()
    rightNode:setPosition(cc.p(0,0))
    self.rightBg:addChild(rightNode, 1, 9)
    createLabel(rightNode, textTable[2], cc.p(301, 481), cc.p(0.5, 0.5), 20, true)

    --右侧1
    self.subRightBg1:removeChildByTag(9)
    local right1 = cc.Node:create()
    right1:setPosition(cc.p(0,0))
    self.subRightBg1:addChild(right1, 1, 9)
    self:createGrid(right1, 3) 

    --右侧2
    self.subRightBg2:removeChildByTag(9)
    local right2 = cc.Node:create()
    right2:setPosition(cc.p(0,0))
    self.subRightBg2:addChild(right2, 1, 9)
    self:createGrid(right2, 1) 

    --右侧3
    self.subRightBg3:removeChildByTag(9)
    local right3 = cc.Node:create()
    right3:setPosition(cc.p(0,0))
    self.subRightBg3:addChild(right3, 1, 9)
    self:createGrid(right3, 2) 
end

function qqMemberLayer:createDesp(parent)
    local textTable = {game.getStrByKey("super_qqmember_tq1"),
                       game.getStrByKey("super_qqmember_tq2"),
                       game.getStrByKey("super_qqmember_tq3"),
                       game.getStrByKey("super_qqmember_tq4"),
                       game.getStrByKey("super_qqmember_tq5"),
                       game.getStrByKey("super_qqmember_tq6"),
                       game.getStrByKey("super_qqmember_tq7"),
                       game.getStrByKey("super_qqmember_tq8"),
                       game.getStrByKey("super_qqmember_tq9"),
                       game.getStrByKey("super_qqmember_tq10"),
                      }
    local despList = require "src/config/qqPrivilegeDesp"
    local Y = 444
    local X = 28
    for i = 1, #despList do
        local spr = createSprite( parent, "res/layers/qqMember/tequan_bg.png", cc.p( 28 , Y), cc.p( 0 , 1 ) );        
        createLabel(spr, textTable[i], cc.p(1, 14), cc.p(0, 0.5), 18, true)

        local lab = require("src/RichText").new(parent ,cc.p(X, Y - 34), cc.size(320, 30), cc.p(0,1), 26, 20, color)
        lab:setAnchorPoint(cc.p(0,1))
        lab:setAutoWidth()
        lab:addText(despList[i].desp, MColor.deep_brown)
        lab:format()
               
        Y = Y - lab:getContentSize().height - 50
    end
end

function qqMemberLayer:createGrid(parent,idx)
    local idxMap = {17,18,19,20,21,22}   
    local tp = (self.selIndex - 1)*3 + idx   
    local packList = require "src/config/DropAward"
    local tmp1 = {}
    local tmp2 = {}
    local tmp3 = {}
    local count = 0
    for i = 1, #packList do
        if packList[i].q_id == idxMap[tp] then       
            local item = {}
            item.id = packList[i].q_item
            item.num = packList[i].q_count
            item.isBind = packList[i].bdlx > 0
            item.showBind = true
            
            count = count + 1
            if count == 1 or count == 2 then
                tmp1[#tmp1 + 1] = item
            elseif  count == 3 or count == 4 then
                tmp2[#tmp2 + 1] = item
            elseif  count == 5 or count == 6 then 
                tmp3[#tmp3 + 1] = item
            end                                       
        end
    end

    if #tmp1 > 0 then
        local iconGroup = __createAwardGroup(tmp1, nil, 90)
        setNodeAttr(iconGroup, cc.p(-8, 350), cc.p(0, 0.5))
        parent:addChild(iconGroup)
    end

    if #tmp2 > 0 then
        local iconGroup = __createAwardGroup(tmp2, nil, 90)
        setNodeAttr(iconGroup, cc.p(-8, 250), cc.p(0, 0.5))
        parent:addChild(iconGroup)
    end

    if #tmp3 > 0 then
        local iconGroup = __createAwardGroup(tmp3, nil, 90)
        setNodeAttr(iconGroup, cc.p(-8, 150), cc.p(0, 0.5))
        parent:addChild(iconGroup)
    end

    --创建领取按钮
    local getFunc = function()
		g_msgHandlerInst:sendNetDataByTableExEx(QQVIP_CS_GET_REWARD, "QQVipGetRewardRequest", {type = tp})
        addNetLoading(QQVIP_CS_GET_REWARD, QQVIP_SC_GET_REWARD)
        self.lastGet = tp

        cclog("QQVIP_CS_GET_REWARD type=%d",tp)
	end

    local btn = createMenuItem(parent, "res/component/button/2.png", cc.p(92, 40), getFunc)
    if self.awardInfo[tp] == 2 then
        createLabel(btn, game.getStrByKey("getOver"), getCenterPos(btn), nil, 24, true)
    else
        createLabel(btn, game.getStrByKey("get_lq"), getCenterPos(btn), nil, 24, true)
    end
    btn:setEnabled(self.awardInfo[tp] == 1)
end

function qqMemberLayer:networkHander(buff,msgid)
	local switch = {
  --[[      [QQVIP_SC_REWARD_INFO] = function()    
            local t = g_msgHandlerInst:convertBufferToTable("QQVipRewardInfoResult", buff) 

            cclog("QQVIP_SC_REWARD_INFO")

            self.awardInfo = {}
            for i=1, #t.info do
                local tmp = t.info[i]
                self.awardInfo[tmp.type] = tmp.status
                cclog("QQVIP_SC_REWARD_INFO: type=%d  status=%d ", tmp.type, tmp.status)
            end
            
            self:reset()
		end,
]]
        [QQVIP_SC_GET_REWARD] = function()    
            cclog("QQVIP_SC_GET_REWARD")
           
            local t = g_msgHandlerInst:convertBufferToTable("QQVipGetRewardResult", buff) 
            if t.ret > 0 then
                self.awardInfo[self.lastGet] = 2
                self:reset()
            end   
            
            local bHave = false
            for i=1, #self.awardInfo do
                if self.awardInfo[i] == 1 then
                    bHave = true
                end
            end
    
            if TOPBTNMG then TOPBTNMG:showRedMG( "QQ" , bHave )  end      
		end,
	}

 	if switch[msgid] then
 		switch[msgid]()
 	end
end

function qqMemberLayer.onPay()
    if qqMemberLayer.curInst == nil then
        return
    end

    local LoginScene = require("src/login/LoginScene")
    g_msgHandlerInst:sendNetDataByTableExEx(QQVIP_CS_CHARGE_FINISH, "QQVipChargeFinishRequest", {type = qqMemberLayer.curInst.payType, accessToken = LoginScene.user_pwd})


    cclog("QQVIP_CS_CHARGE_FINISH: type=%d  accessToken=%s ",qqMemberLayer.curInst.payType,LoginScene.user_pwd)


    --performWithDelay(qqMemberLayer.curInst, function() g_msgHandlerInst:sendNetDataByTableExEx(QQVIP_CS_REWARD_INFO, "QQVipRewardInfoRequest", {}) end, 3)
end

function qqMemberLayer.onReset(buff)
    if not((LoginUtils.isQQLogin() and isAndroid()) or isWindows()) then
        return
    end
    
    local t = g_msgHandlerInst:convertBufferToTable("QQVipRewardInfoResult", buff) 

    cclog("QQVIP_SC_REWARD_INFO")

    local info = {}
    local bHave = false
    for i=1, #t.info do
        local tmp = t.info[i]
        info[tmp.type] = tmp.status
        if tmp.status == 1 then
            bHave = true
        end
        cclog("QQVIP_SC_REWARD_INFO: type=%d  status=%d ", tmp.type, tmp.status)
    end
    
    if TOPBTNMG then TOPBTNMG:showRedMG( "QQ" , bHave )  end
    
    --刷新界面
    if qqMemberLayer.curInst ~= nil then
        qqMemberLayer.curInst.awardInfo = info
        qqMemberLayer.curInst:reset()
    end   
end

return qqMemberLayer