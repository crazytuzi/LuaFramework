local m_winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize  = cc.size(626,517) 

local FONTSIZE     = 20
local R_COUNT      = 6 --总数
local R_ROWNO      = 3 --列数

local RECHARGE     = 1
local PRIVILEGE    = 2
-- local PMFUND       = 3
-- local THFUND       = 4
local ZZSHOP       = 3
local CARD         = 4
local ZCPCTAG      = 5
    
local zhuRechargeView = classGc(view, function(self,_subType)
	self.pMediator = require("mod.recharge.zhuRechargeMadiator")()
    self.pMediator : setView(self)
    print("_subType",_subType)
    self.rechargeType = _subType or RECHARGE
end)

function zhuRechargeView.create(self)
	self.rechargeView = require("mod.general.TabLeftView")()
  	self.m_rootLayer  = self.rechargeView : create("充 值")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

  	self : init()
	return tempScene
end

function zhuRechargeView.networksend( self )
    local msg_vip = REQ_ROLE_VIP_MY()
    _G.Network : send( msg_vip)
    print("请求协议")
end

function zhuRechargeView.init( self )
	self.RechargeNode=cc.Node:create()
	self.RechargeNode:setPosition(m_winSize.width/2,m_winSize.height/2)
	self.m_rootLayer:addChild(self.RechargeNode)
	
	local function closeFunRecharge()
		self : onCloseCallBack()
	end
	local function tabOfFun(tag)
		self : tabOperate(tag)
	end
	self.rechargeView : addCloseFun(closeFunRecharge)
	self.rechargeView : addTabFun(tabOfFun)
	-- self.rechargeView : showUpRightSpr()
	self.rechargeView : addTabButton("充 值", RECHARGE)
	self.rechargeView : addTabButton("VIP特权", PRIVILEGE)
	-- self.rechargeView : addTabButton("平民基金", PMFUND)
	-- self.rechargeView : addTabButton("土豪基金", THFUND)
	self.rechargeView : addTabButton("陨石商城", ZZSHOP)
    if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE_YUEKA,true)==false then
        self.rechargeView : addTabButton("月 卡", CARD,true)
    end
    if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE_JIJIN,true)==false then
        self.rechargeView : addTabButton("招财貔貅", ZCPCTAG,true)
    end

    -- local msg = REQ_WEAGOD_RMB_CALL()
    -- _G.Network : send( msg)

    local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_RECHARGE_YUEKA)
    print("rewardIconCount1",rewardIconCount)
    if rewardIconCount>0 then
      self.rechargeView:setTagIconNum(CARD,rewardIconCount)
    end
    local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_RECHARGE_VIP_PRIVILEGE)
    print("rewardIconCount2",rewardIconCount)
    if rewardIconCount>0 then
        self.rechargeView:setTagIconNum(PRIVILEGE,rewardIconCount)
    end

    local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_RECHARGE_S_FUND)
    print("rewardIconCount3",rewardIconCount)
    --rewardIconCount = 1
    if rewardIconCount>0 then
        self.rechargeView:setTagIconNum(ZCPCTAG,rewardIconCount)
    end    
	
	self.tagContainer = {1,2,3,4,5}
	self.tagPanel = {}
	self.tagPanelClass={}
	self.leftSpr  = {1,2,3,4,5}
	for i=1,5 do
		self.tagContainer[i] = cc.Node:create()
        -- self.tagContainer[i] : setPosition(0,-110)
    	self.RechargeNode : addChild(self.tagContainer[i],10)
	end

	-- 默认页面
    print("self.rechargeType",self.rechargeType)
	self.rechargeView : selectTagByTag(self.rechargeType)
    self : RightExpView()
    -- self : RightLab()
	self : initViewData(self.rechargeType, true)
end

function zhuRechargeView.chuangIconNum(self,_sysId,_number)
    print("chuangIconNum-->",_sysId,_number)
    if _G.Const.CONST_FUNC_OPEN_RECHARGE_YUEKA==_sysId then
        self.rechargeView:setTagIconNum(CARD,_number)
    end
    if _G.Const.CONST_FUNC_OPEN_RECHARGE_VIP_PRIVILEGE==_sysId then
        self.rechargeView:setTagIconNum(PRIVILEGE,_number)
    end
    if _G.Const.CONST_FUNC_OPEN_RECHARGE_JIJIN==_sysId then
        self.rechargeView:setTagIconNum(ZCPCTAG,_number)
    end
   if _G.Const.CONST_FUNC_OPEN_RECHARGE_S_FUND==_sysId then
        self.rechargeView:setTagIconNum(ZCPCTAG,_number)
   end
  -- if _G.Const.CONST_FUNC_OPEN_RECHARGE_B_FUND==_sysId then
  --   self.rechargeView:setTagIconNum(THFUND,_number)
  -- end
end

function zhuRechargeView.tabOperate( self, _tag )
	print("SettingView --- tag --->",_tag)
    -- if _tag~=ZZSHOP then
    --     self.right_bg   : setPreferredSize(rightSize)
    --     self.right_bg   : setPosition(rightSize.width/2,rightSize.height/2)
    -- else
    --     self.right_bg   : setPreferredSize(cc.size(rightSize.width,rightSize.height-40))
    --     self.right_bg   : setPosition(rightSize.width/2,rightSize.height/2+20)
    -- end
	for i=1,5 do
        if i ~= _tag then
            print("self.tagContainer setVisible false----------",i)
            self.tagContainer[i] : setVisible(false)
        else
            print("self.tagContainer setVisible true--------",i)
            self.tagContainer[i] : setVisible(true)
            self : initViewData(i,true)
        end
    end
end

function zhuRechargeView.initViewData( self,_tag,_isVisible )
    if _tag==RECHARGE or _tag==PRIVILEGE then
        self.rightup:setVisible(true)
    else
        self.rightup:setVisible(false)
    end
  	if self.tagPanel[_tag] == nil then
    	print("创建 panel type visible",_tag,_isVisible)
    	local view = nil
    	if _tag == RECHARGE then
    		view = require "mod.recharge.RechargeView"()
    	elseif _tag == PRIVILEGE then
    		view = require "mod.recharge.PrivilegeView"()
    	-- elseif _tag == PMFUND then
    	-- 	view = require "mod.recharge.PMfundView"(2)
    	-- elseif _tag == THFUND then
    	-- 	view = require "mod.recharge.PMfundView"(3)
    	elseif _tag == ZZSHOP then
    		view = require "mod.recharge.ZZShopView"()
        elseif _tag == CARD then
            view = require "mod.recharge.THfundView"()
        elseif _tag == ZCPCTAG then
            view = require "mod.recharge.ZCRechargeView"()
    	end
    	if view == nil then return end
    	self.tagPanelClass[_tag] = view
    	self.tagPanel[_tag] = view : create ()
    	print("_tag值", _tag)
    	self.tagContainer[_tag] : addChild(self.tagPanel[_tag])
    	self.tagContainer[_tag] : setVisible(true)       
  	end
end

function zhuRechargeView.onRecharge( self )
    print("onRecharge==>>>")
    self:tabOperate(RECHARGE)
    self.rechargeView:selectTagByTag(RECHARGE)
end

function zhuRechargeView.onCloseCallBack(self, sender, eventType)
	print("关闭")
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self : unregister()
end

function zhuRechargeView.RightExpView(self)
    print("有经验条")
    local rupSize=cc.size(rightSize.width,80)
    self.rightup = ccui.Scale9Sprite:createWithSpriteFrameName("general_daybg.png")
    self.rightup : setPreferredSize(rupSize)
    self.rightup : setPosition(110,173)
    self.RechargeNode : addChild(self.rightup)

    self.tureNode = cc.Node:create()
    self.rightup : addChild(self.tureNode)

    local rupStr={"当前 ","再充值 ","升级到 "}
    local StrpoX={15,rupSize.width/2,rupSize.width/2+180}
    local StrpoY={rupSize.height/2+5,rupSize.height/2+5,rupSize.height/2+5}
    for i=1,3 do
        local upStrLab = _G.Util : createLabel(rupStr[i], FONTSIZE)
        -- upStrLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
        upStrLab : setPosition(StrpoX[i], StrpoY[i])
        upStrLab : setAnchorPoint( cc.p(0,0.5) )
        if i==1 then
            self.rightup : addChild(upStrLab)
        else
            self.tureNode : addChild(upStrLab)
        end
    end

    local expdiSpr = ccui.Scale9Sprite:createWithSpriteFrameName("vip_expbg.png")
    expdiSpr : setAnchorPoint( cc.p(0,0.5) )
    expdiSpr : setPreferredSize(cc.size(172,18))
    expdiSpr : setPosition(125, rupSize.height/2+5)
    self.rightup : addChild( expdiSpr )

    self.expSize = expdiSpr:getContentSize()
    self.expSpr = ccui.LoadingBar:create()
    self.expSpr : loadTexture("vip_exp.png",ccui.TextureResType.plistType)
    self.expSpr : setPosition(self.expSize.width/2,self.expSize.height/2)
    self.expSpr : setPercent( 0 )
    expdiSpr:addChild(self.expSpr)

    local jadeSpr=cc.Sprite:createWithSpriteFrameName("general_xianYu.png")
    jadeSpr:setPosition(rupSize.width/2+80,rupSize.height/2+4)
    self.tureNode : addChild(jadeSpr)

    self.rmbNumLab = _G.Util : createLabel("0", FONTSIZE)
    self.rmbNumLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.rmbNumLab : setPosition(rupSize.width/2+100, rupSize.height/2+5)
    self.rmbNumLab : setAnchorPoint( cc.p(0,0.5) )
    self.tureNode : addChild(self.rmbNumLab)

    self.expNumLab = _G.Util : createLabel("0/0", FONTSIZE)
    -- self.expNumLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    self.expNumLab : setPosition(215, rupSize.height/2+5)
    self.rightup : addChild(self.expNumLab)

    self.maxlvLab = _G.Util : createLabel("已经是VIP最高等级", FONTSIZE)
    self.maxlvLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    self.maxlvLab : setPosition(rupSize.width/2+50, rupSize.height/2+5)
    self.maxlvLab : setAnchorPoint( cc.p(0,0.5) )
    self.maxlvLab : setVisible(false)
    self.rightup : addChild(self.maxlvLab)

    local mainplay = _G.GPropertyProxy : getMainPlay()
    self.palyerviplv = tonumber(mainplay : getVipLv())

    self.nowvipLab = _G.Util : createLabel(string.format("VIP %d",self.palyerviplv), FONTSIZE)
    self.nowvipLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    self.nowvipLab : setPosition(61, rupSize.height/2+5)
    self.nowvipLab : setAnchorPoint( cc.p(0,0.5) )
    self.rightup : addChild(self.nowvipLab)

    local willlv = self.palyerviplv + 1
    if willlv > _G.Const.CONST_VIP_MOST_LV then
        willlv = self.palyerviplv
        self.expSpr : setPercent(100)
        self.expNumLab : setString("MAX")
        self.tureNode : setVisible(false)
        self.maxlvLab : setVisible(true)
    end
    self.willvipLab = _G.Util : createLabel(string.format("VIP %d",willlv), FONTSIZE)
    self.willvipLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    self.willvipLab : setPosition(rupSize.width-67, rupSize.height/2+5)
    self.willvipLab : setAnchorPoint( cc.p(0,0.5) )
    self.tureNode : addChild(self.willvipLab)

    self:networksend()
end

-- function zhuRechargeView.RightLab(self)
    -- self.LabNode = cc.Node:create()
    -- self.RechargeNode: addChild(self.LabNode)
--     local nowLab={}
--     local nowStr={"当前","再充值","升级到"}
--     local nowPoX={70,210,400}
--     for i=1, 3 do 
--         nowLab[i] = _G.Util:createLabel(nowStr[i],FONTSIZE)
--         nowLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
--         nowLab[i] : setAnchorPoint( cc.p(0,0.5) )
--         nowLab[i] : setPosition(nowPoX[i],rightSize.height-60)
        -- self.LabNode : addChild(nowLab[i])
--     end

--     local LabWidth=nowLab[1]:getContentSize().width+2
--     local nowVipLab=_G.Util:createLabel(string.format("VIP%d",self.palyerviplv),FONTSIZE)
--     nowVipLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
--     nowVipLab : setAnchorPoint( cc.p(0,0.5) )
--     nowVipLab : setPosition(70+LabWidth,rightSize.height-60)
    -- self.LabNode : addChild(nowVipLab)

--     local LabWidth=nowLab[3]:getContentSize().width+2
--     local willVipLab=_G.Util:createLabel(string.format("VIP%d",self.palyerviplv+1),FONTSIZE)
--     willVipLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
--     willVipLab : setAnchorPoint( cc.p(0,0.5) )
--     willVipLab : setPosition(400+LabWidth,rightSize.height-60)
    -- self.LabNode : addChild(willVipLab)

--     local iconSpr = cc.Sprite : createWithSpriteFrameName( "general_xianYu.png" )
--     iconSpr : setPosition(282,rightSize.height-57)
    -- self.LabNode : addChild(iconSpr)

--     local LabWidth=nowLab[2]:getContentSize().width+2
--     self.numsLab = _G.Util:createLabel("",FONTSIZE)
--     self.numsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
--     self.numsLab : setAnchorPoint( cc.p(0,0.5) )
--     self.numsLab : setPosition(240+LabWidth,rightSize.height-60)
    -- self.LabNode : addChild(self.numsLab)

--     self.maxLab = _G.Util : createLabel("已经是VIP最高等级", FONTSIZE)
--     -- self.maxLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
--     self.maxLab : setPosition(rightSize.width/2, rightSize.height-60)
--     self.maxLab : setVisible(false)
--     self.RechargeNode : addChild(self.maxLab)
-- end

function zhuRechargeView.pushData(self, _lv,_exp)     --mediator传过来的数据
    print("RechargeView传过来的数据:", _lv,_exp)
    if _lv ~= nil and _lv > self.palyerviplv then
        self.palyerviplv = _lv
    end
    --当前vip 经验条
    local vipNode 	= _G.Cfg.vip[tonumber(_lv)]
    self.m_exp  	= _exp or 0

    local nextviplv = _lv + 1

    if nextviplv > _G.Const.CONST_VIP_MOST_LV then
        self.m_expn = self.m_exp
        nextviplv = _lv
        self.expSpr : setPercent(100)
        self.expNumLab : setString("MAX")
        self.tureNode : setVisible(false)
        self.maxlvLab : setVisible(true)
    else
        local nextvipNode = _G.Cfg.vip[tonumber(nextviplv)]
        self.m_expn = nextvipNode.vip_up
        print("下一级：", nextviplv,self.m_exp,self.m_expn)
        self.expNumLab : setString(string.format("%d/%d",self.m_exp,self.m_expn))
        local expWidth = self.m_exp/self.m_expn*self.expSize.width
        self.expSpr : setPercent( expWidth/self.expSize.width*100 )
        --再充值
        local rechargeValue = 100
        rechargeValue = nextvipNode.vip_up-_exp
        print("nextvipNode:", nextvipNode.vip_up,_exp, rechargeValue)        
        if rechargeValue > 0 then 
            self.rmbNumLab : setString(rechargeValue)
            -- self.numsLab : setString(rechargeValue)
        end
    end
end

-- function zhuRechargeView.ReturnVipNowLvNumSpr(self,_num)
    -- local rupSize=cc.size(rightSize.width-14,96)
    -- if self.vipnowlvNode~=nil then
    --     self.vipnowlvNode:removeFromParent(true)
    --     self.vipnowlvNode=nil
    -- end
    -- self.vipnowlvNode = cc.Node:create()
    -- self.vipnowlvNode:setPosition(136,rupSize.height-32)
    -- self.vipnowlvNode:setAnchorPoint( cc.p(0,0.5) )
    -- self.rightup :addChild(self.vipnowlvNode)

    -- local vipValue    = _num or 0
    -- local length      = string.len( vipValue)
    -- local spriteWidth = 0

    -- print("vipValue:", vipValue)
    -- for i=1, length do
    --     local nowvipSpr = cc.Sprite:createWithSpriteFrameName( "general_vipno_"..string.sub(vipValue,i,i)..".png")
    --     self.vipnowlvNode : addChild( nowvipSpr )

    --     local vipSprSize = nowvipSpr : getContentSize()
    --     spriteWidth      = spriteWidth + vipSprSize.width/2+4
    --     nowvipSpr        : setPosition(spriteWidth, 0)
    -- end
-- end

-- function zhuRechargeView.ReturnVipWillLvNumSpr(self,_num) 
    -- local rupSize=cc.size(rightSize.width-14,96)
    -- if self.vipwilllvNode~=nil then
    --     self.vipwilllvNode:removeFromParent(true)
    --     self.vipwilllvNode=nil
    -- end
    -- self.vipwilllvNode = cc.Node:create()
    -- self.vipwilllvNode : setPosition(rupSize.width/2+170,27)
    -- self.vipwilllvNode : setAnchorPoint( cc.p(0,0.5) )
    -- self.tureNode :addChild(self.vipwilllvNode)

    -- local vipValue    = _num or 0
    -- local length      = string.len( vipValue)
    -- local spriteWidth = 0

    -- print("vipValue:", vipValue)
    -- for i=1, length do
    --     local willvipSpr = cc.Sprite:createWithSpriteFrameName( "general_vipno_"..string.sub(vipValue,i,i)..".png")
    --     self.vipwilllvNode : addChild( willvipSpr )

    --     local vipSprSize = willvipSpr : getContentSize()
    --     spriteWidth      = spriteWidth + vipSprSize.width/2+4
    --     willvipSpr        : setPosition(spriteWidth, 0)
    -- end
-- end

function zhuRechargeView.ZCPXpushdata(self,_data) 
    self.tagPanelClass[ZCPCTAG] : pushdata(_data)
end
function zhuRechargeView.SuccessBuy(self,_flag) 
    self.tagPanelClass[ZCPCTAG] : SuccessBuy(_flag)
end
function zhuRechargeView.SuccessReward(self,_id) 
    self.tagPanelClass[ZCPCTAG] : SuccessReward(_id)
end

function zhuRechargeView.PrivilegeData(self,_data) 
    self.tagPanelClass[PRIVILEGE] : VIPPrivilegeData(_data)
end

function zhuRechargeView.SuccessVip(self) 
    self.tagPanelClass[PRIVILEGE] : SuccessVip()
end

function zhuRechargeView.ZCViewFlag( self, _flag )
    if _flag==1 then
        self.rechargeView : addTabButton("招财貔貅", ZCPCTAG)
        local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_RECHARGE_JIJIN)
        print("rewardIconCount3",rewardIconCount)
        if rewardIconCount>0 then
            self.rechargeView:setTagIconNum(ZCPCTAG,rewardIconCount)
        end
    end
end

function zhuRechargeView.rechargeMoney( self )
    print("转入充值网页")
end

function zhuRechargeView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
   for _tag=1,4 do
      if self.tagPanelClass[_tag]~=nil and _tag~=PRIVILEGE then
          self.tagPanelClass[_tag] : unregister()
      end
  end
end

return zhuRechargeView