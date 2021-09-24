local PrivilegeView = classGc(view, function(self, _panelType)
	self.m_panelType = _panelType
end)

local LEFTTAG  = 1
local RIGHTTAG = 2
local Tag_REWARD=3

local FONTSIZE = 20
-- local R_COUNT  = 6 --总数
local R_ROWNO  = 2 --行数
local vip_max  = _G.Const.CONST_VIP_MOST_LV --vip最高级

local rdownSize= cc.size(620,430)
local doubleSize = cc.size(rdownSize.width,260)

function PrivilegeView.create(self)
	self.m_container = cc.Node:create()

    self.privilebg   = ccui.Widget:create()
	self.privilebg   : setContentSize(rdownSize)
	self.privilebg	 : setPosition(cc.p(110,-80))
	self.m_container : addChild(self.privilebg)

    local mainplay = _G.GPropertyProxy : getMainPlay()
    self.lvPrivilege = tonumber(mainplay : getVipLv()) 
    if self.lvPrivilege < 1 then
        self.lvPrivilege = 1
    end

    self.doubleSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_zhongbg.png")
    self.doubleSpr : setPreferredSize(doubleSize)
    self.doubleSpr : setPosition(110, 12)
    self.m_container : addChild(self.doubleSpr)

	local function pageCallBack(sender, eventType)
		self : onPageCallBack(sender, eventType)
	end

    self.leftSpr = gc.CButton:create()
    self.leftSpr : loadTextures("general_fanye.png")
    self.leftSpr : setPosition(rdownSize.width/2-260, -135)
    self.leftSpr : setTag(LEFTTAG)
    self.leftSpr : addTouchEventListener(pageCallBack)
    -- self.leftSpr : ignoreContentAdaptWithSize(false)
    -- self.leftSpr : setContentSize(cc.size(80,80))
    self.doubleSpr : addChild(self.leftSpr)

    self.rightSpr = gc.CButton:create()
    self.rightSpr : loadTextures("general_fanye.png")
    self.rightSpr : setPosition(rdownSize.width/2+260, -135)
    self.rightSpr : setRotation(180)
    self.rightSpr : setTag(RIGHTTAG)
    self.rightSpr : addTouchEventListener(pageCallBack)
    -- self.rightSpr : ignoreContentAdaptWithSize(false)
    -- self.rightSpr : setContentSize(cc.size(80,80))
    self.doubleSpr : addChild(self.rightSpr)

    local vipSpr = cc.Sprite : createWithSpriteFrameName("general_vip.png")
    vipSpr : setPosition(doubleSize.width/2-30, doubleSize.height-40)
    self.doubleSpr : addChild(vipSpr)

--  初始化
    if self.lvPrivilege == 1 then
        self.leftSpr : setVisible(false)
    elseif self.lvPrivilege == vip_max then
        self.rightSpr: setVisible(false)
    end

    local msg = REQ_REWARD_VIP_MSG()
    _G.Network:send(msg)

    self : vipPrivilege()
    self : vipTitleView()
    return self.m_container
end

function PrivilegeView.vipPrivilege(self)
    if self.lv_container ~= nil then
        self.lv_container : removeFromParent(true)
        self.lv_container = nil
    end
    self.lv_container = cc.Node : create()
    local spriteWidth = doubleSize.width/2-10
    local length      = string.len( self.lvPrivilege)
    for i=1, length do
        local nowvipSpr   = cc.Sprite:createWithSpriteFrameName( "general_vipno_"..string.sub(self.lvPrivilege,i,i)..".png")
        local vipSprSize  = nowvipSpr : getContentSize()
        spriteWidth       = spriteWidth + vipSprSize.width / 2+5
        nowvipSpr : setPosition(spriteWidth, doubleSize.height-40)
        self.lv_container : addChild( nowvipSpr )
    end
    self.doubleSpr  : addChild(self.lv_container)
end

function PrivilegeView.rightRewardView(self)
    if self.rewardSpr~=nil then
        self.rewardSpr:removeFromParent(true)
        self.rewardSpr=nil
    end

    local rewardSize=cc.size(425,100)
    self.rewardSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    self.rewardSpr : setPreferredSize(rewardSize)
    self.rewardSpr : setPosition(rdownSize.width/2,-60)
    self.doubleSpr:addChild(self.rewardSpr)

    local function pageCallBack(sender, eventType)
        self : onPageCallBack(sender, eventType)
    end

    self.RewardBtn = gc.CButton:create()
    self.RewardBtn : loadTextures("general_btn_gold.png")
    self.RewardBtn : setPosition(rewardSize.width/2, -35)
    self.RewardBtn : setTag(Tag_REWARD)
    self.RewardBtn : addTouchEventListener(pageCallBack)
    self.RewardBtn : setTitleText("领 取")
    self.RewardBtn : setTitleFontName(_G.FontName.Heiti)
    self.RewardBtn : setTitleFontSize(FONTSIZE+4)
    self.rewardSpr : addChild(self.RewardBtn)

    -- self.alreadySpr=cc.Sprite:createWithSpriteFrameName("main_already.png")
    -- self.alreadySpr:setPosition(rewardSize.width/2, 65)
    -- self.alreadySpr:setVisible(false)
    -- self.rewardSpr:addChild(self.alreadySpr)

    local function roleCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local role_tag  = sender : getTag()
            local Position  = sender : getWorldPosition()
            print("－－－-选中role_tag:", role_tag)
            if role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local icondata=self.VIPMsg[self.lvPrivilege]
    self.iconSpr={}
    for i=1,4 do
        local rolekuang=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        rolekuang:setPosition(i*100-38,rewardSize.height/2)
        self.rewardSpr : addChild(rolekuang)

        if icondata~=nil and icondata[i] ~= nil then
            print("请求物品图片", icondata[i].id,icondata[i].count)
            local goodId      = icondata[i].id
            local goodCount   = icondata[i].count
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                self.iconSpr[i] = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                self.iconSpr[i] : setPosition(i*100-38,rewardSize.height/2)
                self.rewardSpr : addChild(self.iconSpr[i])
            end
        end
    end

    print("self.State[self.lvPrivilege]",self.State[self.lvPrivilege])
    if self.State[self.lvPrivilege]==1 then
        self.RewardBtn : setBright(false)
        self.RewardBtn : setEnabled(false)
    elseif self.State[self.lvPrivilege]==3 then
        self.RewardBtn : setTitleText("已领取")
        self.RewardBtn : setBright(false)
        self.RewardBtn : setEnabled(false)
    end
end

function PrivilegeView.removeRewardIcon(self)
    if self.iconSpr==nil then return end
    for k,v in pairs(self.iconSpr) do
        v:removeFromParent(true)
        v=nil
    end

    local function roleCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local role_tag  = sender : getTag()
            local Position  = sender : getWorldPosition()
            print("－－－-选中role_tag:", role_tag)
            if role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local icondata=self.VIPMsg[self.lvPrivilege]
    self.iconSpr={}
    for i=1,4 do
        if icondata~=nil and icondata[i] ~= nil then
            print("请求物品图片", icondata[i].id,icondata[i].count)
            local goodId      = icondata[i].id
            local goodCount   = icondata[i].count
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                self.iconSpr[i] = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                self.iconSpr[i] : setPosition(i*100-38,50)
                self.rewardSpr : addChild(self.iconSpr[i])
            end
        end
    end

    print("self.State[self.lvPrivilege]",self.State[self.lvPrivilege])
    if self.State[self.lvPrivilege]==1 then
        self.RewardBtn : setTitleText("领 取")
        self.RewardBtn : setBright(false)
        self.RewardBtn : setEnabled(false)
    elseif self.State[self.lvPrivilege]==3 then
        self.RewardBtn : setTitleText("已领取")
        self.RewardBtn : setBright(false)
        self.RewardBtn : setEnabled(false)
    else
        self.RewardBtn : setTitleText("领 取")
        self.RewardBtn : setBright(true)
        self.RewardBtn : setEnabled(true)
    end
end

function PrivilegeView.VIPPrivilegeData(self,_data)
    if _data==nil then return end
    print("VIPPrivilegeData",_data[1].count)
    self.State={}
    self.VIPMsg={}
    for k,v in pairs(_data) do
        self.State[v.viplv]=v.state
        self.VIPMsg[v.viplv]=v.msg_xxx
    end

    self : rightRewardView()
end

function PrivilegeView.vipTitleView(self)
    if self.Sc_Container ~= nil then
        self.Sc_Container : removeFromParent(true)
        self.Sc_Container = nil
    end
    self.Sc_Container = cc.Node : create()
    
    local pribegin = {}
    local primid_1 = {}
    local pril_end = {}
    local addRowNo = -1 -- 第几行
    local addColum = -1 -- 第几列
    local NO_Pri   = self.lvPrivilege.."_1"
    local plgNode  = _G.Cfg.vip_show[tostring(NO_Pri)]

    local plg_lv   = plgNode.lv
    local plg_sum  = plgNode.sum
    
    local mmmm      = math.ceil(plg_sum/3)
    print("数目、等级、倍数",  plg_sum, plg_lv, mmmm)
    if plg_sum == nil then return end
    for i=1, plg_sum do  

        if i % R_ROWNO == 1 then
            addColum = 0
            addRowNo = addRowNo + 1
        end
        addColum   = addColum + 1
        print("addRowNo,addColum",addRowNo,addColum)
        local posX = 40+(doubleSize.width/2+20)*(addColum-1)
        local posY = doubleSize.height-90-30*addRowNo
        local plg_id  = plg_lv.."_"..i
        local tequanNode = _G.Cfg.vip_show[tostring(plg_id)]
        local l_begin  = ""
        local l_mid_1  = ""
        local l_end    = ""
        local sz_begin = ""
        local sz_mid_1 = ""
        local sz_end   = ""
        l_begin = tequanNode.begin
        l_mid_1 = tequanNode.mid_1
        l_end   = tequanNode["end"]

        if l_begin ~= -1 then
            sz_begin = l_begin
        end

        local vipNode   = _G.Cfg.vip[tonumber(self.lvPrivilege)]                                      
        if l_mid_1 ~= -1 or l_mid_1 > 0 then
            if vipNode[l_mid_1] ~= nil then
                sz_mid_1         = vipNode[l_mid_1]
            end
        end
        
        if l_end ~= "-1" or tonumber(l_end) ~= -1 then
            sz_end = l_end
        end

        pribegin[i] = _G.Util:createLabel(string.format("%d.%s",i,sz_begin),FONTSIZE)
        primid_1[i] = _G.Util:createLabel(sz_mid_1,FONTSIZE)
        pril_end[i] = _G.Util:createLabel(sz_end,FONTSIZE)

        -- pribegin[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        primid_1[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        -- pril_end[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
        
        local beginWidth = pribegin[i] : getContentSize().width 
        local midWidth = primid_1[i] : getContentSize().width
        local l_endWidth = pril_end[i] : getContentSize().width
        pribegin[i] : setPosition(cc.p(posX, posY))
        pribegin[i] : setAnchorPoint( cc.p(0.0,0.5) ) 
        
        primid_1[i] : setPosition(cc.p(posX+beginWidth, posY))
        primid_1[i] : setAnchorPoint( cc.p(0.0,0.5) )
        
        pril_end[i] : setPosition(cc.p(posX+beginWidth+midWidth, posY))
        pril_end[i] : setAnchorPoint( cc.p(0.0,0.5) )
        
        local LabWidth=beginWidth+midWidth+l_endWidth
        -- local LabNode = cc.Node:create()
        self.Sc_Container : addChild(pribegin[i])
        self.Sc_Container : addChild(primid_1[i])
        self.Sc_Container : addChild(pril_end[i])
    end

    self.doubleSpr  : addChild(self.Sc_Container)
end

function PrivilegeView.onPageCallBack(self, sender, eventType)
    if eventType==ccui.TouchEventType.ended then
        local btnTag = sender : getTag()
        if btnTag == LEFTTAG then
            self.rightSpr : setVisible(true)
            self.lvPrivilege = self.lvPrivilege - 1
            if self.lvPrivilege-2 < 0 then
                self.lvPrivilege = 1
                self.leftSpr : setVisible(false)
            end
            self : vipPrivilege()
            self : vipTitleView()
            self : removeRewardIcon()
            print("左:", self.lvPrivilege)
        elseif btnTag == RIGHTTAG then
            self.leftSpr : setVisible(true)
            self.lvPrivilege = self.lvPrivilege + 1
            if self.lvPrivilege+1 > vip_max then
                self.lvPrivilege = vip_max
                self.rightSpr : setVisible(false)
            end
            self : vipPrivilege()
            self : vipTitleView()
            self : removeRewardIcon()
            print("右:", self.lvPrivilege)
        else
            print("领取奖励",self.nowViplv)
            local msg = REQ_REWARD_VIP()
            msg:setArgs(self.lvPrivilege)
            _G.Network:send(msg)
        end
    end
end

function PrivilegeView.SuccessVip(self)
    _G.Util:playAudioEffect("ui_receive_awards")
end

return PrivilegeView