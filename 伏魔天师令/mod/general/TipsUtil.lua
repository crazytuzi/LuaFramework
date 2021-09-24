
--TipsUtil 计算背景长度以及创建背景 按钮 以及回调逻辑
--TipsContainer 显示tips的内容
local TipsUtil = classGc(function(self)
	self.m_good      = nil 
	self.m_showType  = 0 
	self.m_addheight = 0
end)
-- width 340 minheight 200

local WINSIZE=cc.Director:getInstance():getVisibleSize()

local TAG_BTN_STRENG = 1
local TAG_BTN_DRESS  = 2
local TAG_BTN_USE    = 3
local TAG_BTN_UNLOAD = 4
local TAG_BTN_SELL   = 5
local TAG_BTN_BUYBACK= 6 --购回
local TAG_BTN_UPGRADE = 7 --升级
local TAG_BTN_CHAIXIE = 8 --拆卸
local TAG_BTN_INSERT  = 9 --镶嵌
local TAG_BTN_JUMP   = 10 --前往获取
local P_BTN_NAME = {
    [TAG_BTN_UNLOAD] = "卸 下",
    [TAG_BTN_DRESS]  = "穿 戴",
    [TAG_BTN_USE]    = "使 用",
    [TAG_BTN_STRENG] = "更 换",
    [TAG_BTN_SELL]   = "出 售",
    [TAG_BTN_BUYBACK]= "购 回",
    [TAG_BTN_UPGRADE]= "升 级",
    [TAG_BTN_CHAIXIE]= "拆 卸",
    [TAG_BTN_INSERT] = "镶 嵌",
    [TAG_BTN_JUMP]   = "前往获取",
}

--按钮方向
local TAG_BTNPOS_LEFT   = -1
local TAG_BTNPOS_CENTER = 0
local TAG_BTNPOS_RIGHT  = 1



local FONT_SIZE = 18
local PRE_LINE_HEIGHT = 23
local PRE_BACKGROUNGD_WIDTH = 340
-- 卸下 强化
-- 穿戴 出售
-- 使用 出售
--   使用
--   穿戴
--    无
-- 卸下 强化 穿戴 出售 使用

function TipsUtil._reset(self)
	if self._layer ~= nil then
		self._layer : removeFromParent(true)
		self._layer = nil 
	end
    if self.resetCall then
        self.resetCall()
        self.resetCall=nil
    end
end
function TipsUtil.clearLayer(self)
    self._layer=nil
end

function TipsUtil.__registHandle(self)
    local function onTouchBegan(touch, event) 
        print("TipsUtil remove tips1111")
        if self.m_addheight>0 then
            local location=touch:getLocation()
            local bgRect=cc.rect(self.m_position.x,self.m_position.y-self.m_addheight,self.m_bgSprSize.width,self.m_addheight)
            local isInRect=cc.rectContainsPoint(bgRect,location)
            -- print("location===>",location.x,location.y)
            -- print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
            if isInRect then
                return true
            end
        end
        self:_reset()
        return true 
      end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    self._layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self._layer)
end

function TipsUtil.__initParmemt(self)
    self.resetCall=nil
    self.gemInsertCall=nil
    
    if self.m_good.goods_type==_G.Const.CONST_GOODS_MAGIC then
        self.m_good.slots_count=0
        self.m_good.slot_group={}
        return
    elseif self.m_good.isEquip and self.m_good.user then
        local tempType,tempUid
        if self.m_partnerIndex then
            -- print("CCSSSSSSS====>>CONST_PARTNER")
            tempType=_G.Const.CONST_PARTNER
            tempUid=self.m_partnerIndex
        else
            -- print("CCSSSSSSS====>>CONST_PLAYER")
            tempType=_G.Const.CONST_PLAYER
            tempUid=self.m_good.user
        end

        local property=_G.GPropertyProxy:getOneByUid(tempUid,tempType)
        -- print("SSAAAWWWWWWW======>>>>>>",tempUid,tempType,property)
        if property~=nil then
            local equipPartMsg=property:getEquipPartByIdx(self.m_good.index)
            if equipPartMsg then
                self.m_good.slots_count=equipPartMsg.count
                self.m_good.slot_group=equipPartMsg.gem_xxx
                self.m_good.strengthen=equipPartMsg.lv
                self.m_good.attr_count=equipPartMsg.attr_count
                self.m_good.attr_data=equipPartMsg.attr_data
                return
            end
        end
    end
    self.m_good.slots_count=0
    self.m_good.slot_group={}
    self.m_good.strengthen=0
    self.m_good.attr_count=0
    self.m_good.attr_data=nil
end

function TipsUtil.create(self,_good,_showtype,_position,_uid,_func,_partnerIndex)
    self.m_good          = clone(_good)       --物品信息 协议2001
    self.m_good.goodCnf  = _G.Cfg.goods[self.m_good.goods_id]
    self.m_showType      = _showtype   --物品所在位置， 背包， 角色身上， 其他玩家身上
    self.m_position      = {x=_position.x,y=_position.y}   --点击位置
    self.m_characterUid  = _uid or 0  --0主角  非0伙伴ID
    self.m_partnerIndex  = _partnerIndex --是不是查看的id

    
    self:_reset()
    self._layer = cc.Node:create()
    self:__registHandle()

    if _good == nil then 
        local command = CErrorBoxCommand(121)
        controller :sendCommand( command )
        return  self._layer 
    end
    -- local command = CErrorBoxCommand("create tips id =".._good.goods_id.."index=".._good.index)
    -- controller :sendCommand( command )
    self:__initParmemt()
    self:__init()

    return self._layer
end

function TipsUtil.createById( self, _goodid, _showtype, _position, _uid,_func,_partnerIndex)
    self.m_good          = self : useNodeGoodsInfo(_goodid)       --物品信息 协议2001
    self.m_good.goodCnf  = _G.Cfg.goods[self.m_good.goods_id]
    self.m_showType      = _showtype   --物品所在位置， 背包， 角色身上， 其他玩家身上
    self.m_position      = {x=_position.x,y=_position.y}   --点击位置
    self.m_characterUid  = _uid or 0  --0主角  非0伙伴ID
    self.m_partnerIndex  = _partnerIndex --是不是查看的id

    self:_reset()
    self._layer = cc.Node : create()
    self:__registHandle()

    if _goodid == nil then return self._layer end
    self :__init()
    return self._layer
end

function TipsUtil.createByCopyMsg(self,_trueGoodsId,_goodsCopy,_position,_ortherData)
    self.m_good          = clone(_goodsCopy)
    self.m_good.goods_id = _trueGoodsId
    for k,v in pairs(_ortherData) do
        self.m_good[k]=v
    end
    self.m_good.goodCnf  = _G.Cfg.goods[self.m_good.goods_id]
    self.m_showType      = nil   --物品所在位置， 背包， 角色身上， 其他玩家身上
    self.m_position      = {x=_position.x,y=_position.y}   --点击位置
    self.m_characterUid  = _uid or 0  --0主角  非0伙伴ID
    self.m_partnerIndex  = nil --是不是查看的id

    self:_reset()
    self._layer=cc.Node:create()
    self:__initParmemt()
    self:__init()
    self:__registHandle()
    return self._layer
end

function TipsUtil.setFuwenData(self,_lingYaoId)
    self.m_lingYaoId=_lingYaoId
end

function TipsUtil.__init(self)
	self : initView()
	self : setLayerPosition()
end

function TipsUtil.initView( self )
	local good_type = self.m_good.goods_type
    print("TipsUtil 物品id =",self.m_good.goods_id,self.m_showType,good_type)
    if good_type == _G.Const.CONST_GOODS_EQUIP then
        -- print("----Tips_装备武器----")
        --装备，武器  1 
        self :showEquip()
    elseif good_type == _G.Const.CONST_GOODS_WEAPON then 
        --符文 2
        self :showFuwen()
    elseif good_type == _G.Const.CONST_GOODS_MAGIC then
        --神器 5
        -- print("----Tips_神器----")
        self :showGod()
    elseif good_type == _G.Const.CONST_GOODS_MOUNT then
        --武将 7
        local tip = require("mod.partner.PartnerTips")()
        local panel = tip:createPartner(self.m_good.goodCnf.d.as1 ,1,self.m_position,true)
        self.m_bgSprSize = tip:getBgSize()
        self.m_addheight = self.m_bgSprSize.height
        panel : setPosition(0,0)
        self._layer : addChild(panel)
    else
        --道具 非1 2 5
        -- print("----Tips_物品----")
        self :showArticle()
    end	
end

--设置Tip的位置 --使其在屏幕内显示
function TipsUtil.setLayerPosition( self )
    if self.m_position.x+self.m_bgSprSize.width > WINSIZE.width then
        self.m_position.x = WINSIZE.width - self.m_bgSprSize.width
    end
    if self.m_position.y-self.m_bgSprSize.height < 0 then
        self.m_position.y = self.m_bgSprSize.height
    end
    -- print(" TipsUtil.setLayerPosition: ",self.m_position.x, self.m_position.y,self.m_bgSprSize.height)
    self._layer : setPosition( cc.p( self.m_position.x, self.m_position.y))
end

function TipsUtil.showFuwen( self)
    self.m_addheight = 20
    self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT + 90 + PRE_LINE_HEIGHT --名字 装备图标 装备需求
    -- self.m_addheight = self.m_addheight + 20           -- 分割线

    local baseNode = self.m_good.goodCnf
    if baseNode == nil then return end

    if baseNode.f.sell == 1 then
        --价格
        self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT
    end
    --基础属性
    if  baseNode and baseNode.base_type then
        local count=#baseNode.base_type
        self.m_addheight=self.m_addheight+PRE_LINE_HEIGHT*count
        print("showEquip===>> baseNodeCount=",count)
    end 

    --按钮
    if self.m_showType~=nil and self.m_showType~=_G.Const.CONST_GOODS_SITE_OTHERROLE then
        self.m_addheight=self.m_addheight+50
    end
    --容器
    self.m_rootcontainer=cc.Node:create()
    self._layer:addChild(self.m_rootcontainer)
    --底图
    self.m_bgSprSize    = cc.size(PRE_BACKGROUNGD_WIDTH,self.m_addheight)
    self.m_bgSpr        = ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
    self.m_bgSpr        : setPreferredSize(self.m_bgSprSize)
    self.m_bgSpr        : setPosition(self.m_bgSprSize.width/2,-self.m_bgSprSize.height/2)
    self.m_rootcontainer: addChild(self.m_bgSpr)
    --除背景以及按钮得显示内容
    local goodinfoview = require "mod.general.TipsContainer"(self.m_good, self.m_addheight, self.m_showType,self.m_characterUid)
    self.m_rootcontainer :addChild( goodinfoview :create())

    --button创建 分人物背包跟大背包主要是区别 跳转还是直接发协议

    if self.m_showType == nil then return end
    if self.m_showType == _G.Const.CONST_GOODS_SITE_GOODSELL then
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_BUYBACK,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_BACKPACK then
        --背包 button : 穿戴 出售
        local isSell = 1
        if baseNode.f.sell ~= nil then
            isSell = baseNode.f.sell
        end
        if isSell == 1 then
            --可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_LEFT ))
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_SELL,TAG_BTNPOS_RIGHT ))
        else
            --不可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_CENTER ))
        end

    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_OTHERROLE then
        --其他 仅仅显示 button : 无
        print("无按钮")
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_PLAYER then
        --灵妖身上 button :  卸下
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_UNLOAD,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_ROLEBACKPACK then
        --背包 button : 穿戴
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_CENTER ))
    end
end

function TipsUtil.showEquip( self)
	self.m_addheight = 20
	self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT + 90 + PRE_LINE_HEIGHT --名字 装备图标 装备需求
	self.m_addheight = self.m_addheight + 20           -- 分割线

	local baseNode = self.m_good.goodCnf
	if baseNode == nil then return end
	--基础属性
    if  baseNode and baseNode.base_type then
        local count=#baseNode.base_type
        self.m_addheight=self.m_addheight+PRE_LINE_HEIGHT*count
        print("showEquip===>> baseNodeCount=",count)
    end 
    --附魔加成
    if self.m_good.fumo~=nil and self.m_good.fumo>0 then
        self.m_addheight=self.m_addheight+PRE_LINE_HEIGHT
        print("showEquip===>> fumo..")
    end

    --宝石镶嵌
    local havegemcount = 0 
    if self.m_good.slots_count > 0 then
        for i=1,self.m_good.slots_count do 
            if self.m_good.slot_group[i].pearl_id>0 then
                havegemcount = havegemcount + 1
            end
        end
    end
    if havegemcount>0 then
        self.m_addheight = self.m_addheight + 20 -- 分割线
        self.m_addheight = self.m_addheight + havegemcount*PRE_LINE_HEIGHT
        print("showEquip===>> havegemcount=",havegemcount)
    end
    -- 分割线
    self.m_addheight = self.m_addheight + 20 -- 分割线
    --分解材料
    self.m_addheight = self.m_addheight+PRE_LINE_HEIGHT
    local splitArray=self.m_good.goodCnf.split
    if splitArray then
        local splitRow=math.floor(#splitArray/2)
        self.m_addheight = self.m_addheight+PRE_LINE_HEIGHT*splitRow
        print("showEquip===>> splitRow=",splitRow)
    end
    --按钮
    if self.m_showType~=nil and self.m_showType~=_G.Const.CONST_GOODS_SITE_OTHERROLE then
        self.m_addheight=self.m_addheight+50
    end
    --容器
    self.m_rootcontainer=cc.Node:create()
    self._layer:addChild(self.m_rootcontainer)
    --底图
    self.m_bgSprSize    = cc.size(PRE_BACKGROUNGD_WIDTH,self.m_addheight)
    self.m_bgSpr        = ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
	self.m_bgSpr        : setPreferredSize(self.m_bgSprSize)
	self.m_bgSpr        : setPosition(self.m_bgSprSize.width/2,-self.m_bgSprSize.height/2)
    self.m_rootcontainer: addChild(self.m_bgSpr)
	--除背景以及按钮得显示内容
    local goodinfoview = require "mod.general.TipsContainer"(self.m_good, self.m_addheight, self.m_showType,self.m_characterUid)
    self.m_rootcontainer :addChild( goodinfoview :create())

    --button创建 分人物背包跟大背包主要是区别 跳转还是直接发协议

    if self.m_showType == nil then return end
    if self.m_showType == _G.Const.CONST_GOODS_SITE_GOODSELL then
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_BUYBACK,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_BACKPACK then
    	--背包 button : 穿戴 出售
        local isSell = 1
        if baseNode.f.sell ~= nil then
            isSell = baseNode.f.sell
        end
        if isSell == 1 then
            --可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_LEFT ))
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_SELL,TAG_BTNPOS_RIGHT ))
        else
            --不可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_CENTER ))
        end

    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_OTHERROLE then
    	--其他 仅仅显示 button : 无
        print("无按钮")
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_PLAYER then
    	--人物身上 button :  卸下 强化
    	self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_STRENG,TAG_BTNPOS_CENTER ))
    	-- self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_UNLOAD,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_INLAID then
        --人物身上 button :  卸下 强化
        -- self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_STRENG,TAG_BTNPOS_LEFT ))
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_UNLOAD,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_ROLEBACKPACK then
    	--背包 button : 穿戴
    	self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_CENTER ))
    end
end

function TipsUtil.showGod( self)
    self.m_addheight = 20
    self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT + 90 + PRE_LINE_HEIGHT --名字 装备图标 装备需求
    self.m_addheight = self.m_addheight + 20           -- 分割线

    local baseNode = self.m_good.goodCnf
    if baseNode == nil then return end
    --基础属性
    if  baseNode and baseNode.base_type and #baseNode.base_type > 0 then
        self.m_addheight = self.m_addheight + #baseNode.base_type * PRE_LINE_HEIGHT
        
    end 
    --洗练属性
    if self.m_good.plus_msg_no~=nil and #self.m_good.plus_msg_no>0   then
        self.m_addheight = self.m_addheight + 20 -- 分割线

        self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT*#self.m_good.plus_msg_no-- * PRE_LINE_HEIGHT
    end

    -- 分割线
    self.m_addheight = self.m_addheight + 20 -- 分割线
    if baseNode.f.sell == 1 then
        --出售价格
        self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT
    end
    --按钮
    if self.m_showType ~= nil and self.m_showType ~= _G.Const.CONST_GOODS_SITE_OTHERROLE then
        self.m_addheight = self.m_addheight + 50
    end
    --容器
    self.m_rootcontainer = cc.Node : create()
    self._layer : addChild(self.m_rootcontainer)
    --底图
    self.m_bgSprSize    = cc.size(PRE_BACKGROUNGD_WIDTH,self.m_addheight)
    self.m_bgSpr        = ccui.Scale9Sprite : createWithSpriteFrameName( "general_bagkuang.png" ) 
    self.m_bgSpr        : setPreferredSize(self.m_bgSprSize)
    self.m_rootcontainer: addChild(self.m_bgSpr)
    self.m_bgSpr        : setPosition( cc.p( self.m_bgSprSize.width/2, -self.m_bgSprSize.height/2))
    --除背景以及按钮得显示内容
    local goodinfoview = require "mod.general.TipsContainer"(self.m_good, self.m_addheight, self.m_showType,self.m_characterUid)
    self.m_rootcontainer :addChild( goodinfoview :create())

    --button创建 分人物背包跟大背包主要是区别 跳转还是直接发协议
    if self.m_showType == nil then return end
    if self.m_showType == _G.Const.CONST_GOODS_SITE_GOODSELL then
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_BUYBACK,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_BACKPACK then
        --背包 button : 穿戴
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_LEFT ))
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_SELL,TAG_BTNPOS_RIGHT ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_OTHERROLE then
        --其他 仅仅显示 button : 无
        print("无按钮")
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_PLAYER then
        --人物身上 button :  卸下 强化
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_UNLOAD,TAG_BTNPOS_CENTER ))
        -- self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_STRENG,TAG_BTNPOS_RIGHT ))

    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_ROLEBACKPACK then
        --背包 button : 穿戴
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_DRESS,TAG_BTNPOS_CENTER ))
    end
end

function TipsUtil.showArticle( self)
    self.m_addheight = 20
    self.m_addheight = self.m_addheight + 90 + PRE_LINE_HEIGHT -- 装备图标 使用需求
    self.m_addheight = self.m_addheight + 20                   -- 分割线
    -- self.m_addheight = self.m_addheight + 30 -- 分割线

    local baseNode = self.m_good.goodCnf
    if baseNode == nil then return end
    --描述
    if baseNode.remark ~= nil then     
        local m_Lab   = _G.Util:createLabel(baseNode.remark, FONT_SIZE)
        m_Lab         : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)         --左对齐 
        m_Lab         : setDimensions(PRE_BACKGROUNGD_WIDTH-40,0)  --设置文字区域
        local LabSize    = m_Lab : getContentSize()
        self.m_addheight = self.m_addheight + LabSize.height
        m_Lab            = nil
        -- 分割线
        self.m_addheight = self.m_addheight + 20 -- 分割线
    end
    if baseNode.f.sell == 1 then
        --价格
        self.m_addheight = self.m_addheight + PRE_LINE_HEIGHT
    end
    --按钮
    if self.m_showType ~= nil and self.m_showType ~= _G.Const.CONST_GOODS_SITE_OTHERROLE then 
        self.m_addheight = self.m_addheight + 50
    end
    --容器
    self.m_rootcontainer = cc.Node : create()
    self._layer : addChild(self.m_rootcontainer)
    --底图
    self.m_bgSprSize    = cc.size(PRE_BACKGROUNGD_WIDTH,self.m_addheight)
    self.m_bgSpr        = ccui.Scale9Sprite : createWithSpriteFrameName( "general_bagkuang.png" ) 
    self.m_bgSpr        : setPreferredSize(self.m_bgSprSize)
    self.m_rootcontainer: addChild(self.m_bgSpr)
    self.m_bgSpr        : setPosition( cc.p( self.m_bgSprSize.width/2, -self.m_bgSprSize.height/2))
    --除背景以及按钮得显示内容
    print("AAAAAAAAAAAA+===>>",self.m_showType)
    local goodinfoview = require "mod.general.TipsContainer"(self.m_good, self.m_addheight, self.m_showType,self.m_characterUid)
    self.m_rootcontainer :addChild( goodinfoview :create())


    --单独判断是否可购回 可购回则直接创建 购回按钮
    -- if self.m_good.goods_type == _G.Const.CONST_GOODS_SALE then
    --     self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_BUYBACK,TAG_BTNPOS_CENTER ))
    --     return
    -- end
    --button创建 分人物背包跟大背包主要是区别 跳转还是直接发协议
    if self.m_showType == nil then return end
    if self.m_showType == _G.Const.CONST_GOODS_SITE_GOODSELL then
        self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_BUYBACK,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_BACKPACK then
        --背包 button : 使用 出售
        local isSell = 1
        if baseNode.f.sell ~= nil then
            isSell = baseNode.f.sell
        end
        if isSell == 1 then
            --可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_USE,TAG_BTNPOS_LEFT ))
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_SELL,TAG_BTNPOS_RIGHT ))
        else
            --不可出售
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_USE,TAG_BTNPOS_CENTER ))
        end
    --镶嵌宝石专用 升级 拆卸
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_INLAID then
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_UPGRADE,TAG_BTNPOS_LEFT ))
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_CHAIXIE,TAG_BTNPOS_RIGHT ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_INLAIDBAG then
            self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_INSERT,TAG_BTNPOS_CENTER ))
    elseif self.m_showType == _G.Const.CONST_GOODS_SITE_TREASUREUNLOAD then
    	--珍宝 button : 副本跳转
    	self.m_rootcontainer :addChild( self: createBtnByTag( TAG_BTN_JUMP,TAG_BTNPOS_CENTER ))
    else
        print("无按钮")
    end
end
--卸下
function TipsUtil.createBtnByTag( self,_tag,_direction)
	local function local_btncallback(sender, eventType)	
		return self : __createBtnCallBack(sender, eventType)
	end

	local szNormal
	if _direction==TAG_BTNPOS_RIGHT then
		szNormal="general_btn_lv.png"
    else
        szNormal="general_btn_gold.png"
	end
	
	local tempBtn=gc.CButton:create(szNormal) 
    tempBtn:setTitleFontName(_G.FontName.Heiti)
	tempBtn:setTitleText(P_BTN_NAME[_tag])
    tempBtn:setTitleFontSize(FONT_SIZE+6)
	tempBtn:addTouchEventListener(local_btncallback)
	tempBtn:setTag(_tag)	
	--设置按钮位置
	self:setButtonPosition(tempBtn,_direction)
	return tempBtn
end

function TipsUtil.setButtonPosition( self, _button, _direction)
    -- _button :setTouchesPriority( -_G.Const.CONST_MAP_PRIORITY_NOTIC - 1 )
    local itembuttonsize = _button :getContentSize()
    if _direction == TAG_BTNPOS_LEFT then
        _button :setPosition( cc.p( PRE_BACKGROUNGD_WIDTH/2-itembuttonsize.width/2-15, -self.m_addheight+itembuttonsize.height/2 +12))
    elseif _direction == TAG_BTNPOS_CENTER then
        _button :setPosition( cc.p( PRE_BACKGROUNGD_WIDTH/2, -self.m_addheight+itembuttonsize.height/2 +12))
    elseif _direction == TAG_BTNPOS_RIGHT then
        _button :setPosition( cc.p( PRE_BACKGROUNGD_WIDTH/2+itembuttonsize.width/2+15, -self.m_addheight+itembuttonsize.height/2+12))
    end
end


function TipsUtil.__createBtnCallBack(self, sender, eventType)

	if eventType==ccui.TouchEventType.ended then

		local tag_value = sender:getTag()
		print("tips按钮回调 tag_value=",tag_value)

		if tag_value== TAG_BTN_UNLOAD then
            print("装备 卸载")
            if self.m_good.goods_type==_G.Const.CONST_GOODS_WEAPON then
                local msg = REQ_LINGYAO_EQUIP_OFF()
                msg:setArgs(self.m_lingYaoId,self.m_good.goods_id)
                _G.Network :send( msg)
            else
                local msg = REQ_GOODS_USE()
                msg :setArgs(2,self.m_characterUid,self.m_good.index,self.m_good.goods_num)
                _G.Network :send( msg)
                print("使用物品:", self.m_characterUid, self.m_good.index, self.m_good.goods_num)
            end
            
            _G.Util:playAudioEffect("ui_inventory_items")
            self.m_uninstallEquip=self.m_good
			------------------------------------------------------
		elseif tag_value==TAG_BTN_DRESS then
            print("判断是否需要跳转装备 穿戴",self.m_showType)
            if self.m_showType==_G.Const.CONST_GOODS_SITE_ROLEBACKPACK then
                self:GoodDress()
            else
                local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
                controller :sendCommand( command )
                local good_type = self.m_good.goods_type 
                if good_type == _G.Const.CONST_GOODS_MAGIC then
                	_G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT)
                elseif good_type == _G.Const.CONST_GOODS_WEAPON then
                    _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_PARTNER,nil,2)
                else
                	_G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SMITHY)
                end
            end
			------------------------------------------------------
		elseif tag_value==TAG_BTN_USE then
            local isLvOK=self:isEnoughLv() --判断人物等级是满足使用
            if isLvOK==false then return end

            local isJumpView=self:checkJumpView()
            if isJumpView then
                self:_reset()
                return
            end

            if self.m_good.goods_type==_G.Const.CONST_GOODS_ORD then
                if self.m_good.goodCnf~=nil then
                    local subType=self.m_good.goodCnf.type_sub
                    if subType==_G.Const.CONST_GOODS_COMMON_GIFT then
                        _G.Util:playAudioEffect("ui_opengift")
                    end
                end
            end

            if self.m_good.goods_num>1 then
                print("重叠物品 打开重叠道具使用框 如是需要跳转则跳转")
                self:manyGoodsuseMethod()
            else
                print("单个物品使用 直接发协议 如是需要跳转则跳转")
                self:oneGoodsuseMethod()
                _G.Util:playAudioEffect("ui_props")
            end
			------------------------------------------------------
		elseif tag_value==TAG_BTN_STRENG then
            print("跳转强化页面")
            if self.m_good.goodCnf.type_sub >= _G.Const.CONST_GOODS_GOD_WINDS and
              self.m_good.goodCnf.type_sub <= _G.Const.CONST_GOODS_GOD_SIX then
                print("强化按钮跳转 神器装备")
                -- _G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT_OTHER)
            else
                print("强化按钮跳转 普通装备")
                local sysId=_G.Const.CONST_FUNC_OPEN_SMITHY
                if _G.GOpenProxy:showSysNoOpenTips(sysId) then return false end
                -- self:selectContainerByTag(tag)
                -- return true
                local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_ROLE)
                controller :sendCommand( command ) 
                _G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_SMITHY)
            end
			----------------------------------------------------
		elseif tag_value==TAG_BTN_SELL then
            print("物品出售－－－－－")
            self : GoodSell()
			------------------------------------------------------
        elseif tag_value==TAG_BTN_BUYBACK then
            print("物品购回－－－－－")
            self : GoodBuyBack()
            ------------------------------------------------------
        elseif tag_value==TAG_BTN_UPGRADE then
            print("宝石升级－－－－－")
            local command = EquipGemInsertCommand(EquipGemInsertCommand.UPGRADE)
            controller :sendCommand( command ) 
            ------------------------------------------------------
        elseif tag_value==TAG_BTN_CHAIXIE then
            print("宝石拆卸－－－－－")
            local command = EquipGemInsertCommand(EquipGemInsertCommand.CHAIXIE)
            controller :sendCommand( command ) 
            ------------------------------------------------------        
        elseif tag_value==TAG_BTN_INSERT then
            print("宝石镶嵌－－－－－")
            local command = EquipGemInsertCommand(EquipGemInsertCommand.INSERT)
            controller :sendCommand( command )
            if self.gemInsertCall~=nil then
                self.gemInsertCall()
                self.gemInsertCall=nil
            end
            ------------------------------------------------------ 
        elseif tag_value==TAG_BTN_JUMP then
            print("前往获取－－－－－")
            _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_COPY_JEWELLERY)
			------------------------------------------------------
		end

        self : _reset()

	end
end

function TipsUtil.GoodDress( self )
    local msg = REQ_GOODS_USE()
    msg :setArgs(1,self.m_characterUid,self.m_good.index,self.m_good.goods_num)
    _G.Network :send( msg)
end

function TipsUtil.GoodBuyBack( self )
    local index = self.m_good.index
    if index == nil then return end
    
    local msg = REQ_GOODS_BUY_BACK()
    msg : setArgs(index)
    _G.Network :send( msg ) 
end

function TipsUtil.GoodSell( self )
    local function sellFunc( _num)
        print("出售物品更新")
        local msg = REQ_GOODS_P_SELL()
        local tab = {}
        tab[1]    = {}

        tab[1].index = self.m_good.index
        tab[1].count = _num
        print("==",tab[1].index,tab[1].count)
        msg : setArgs( 1,tab)
        _G.Network :send( msg)             
    end
    if self.m_good.goods_num > 1 then 
        --弹出重叠道具使用框
        print(" 出售多个物品")
        
        local NumberTipsBox    = require ("mod.general.NumberTipsBox")(self.m_good.goods_id,self.m_good.goods_num, 1, sellFunc )
        local tipsBoxContainer = NumberTipsBox :create(2)
    else
        print("出售单个物品")
        sellFunc( 1)
    end
end

function TipsUtil.oneGoodsuseMethod(self)
	if self.m_good.goodCnf~=nil and self.m_good.goodCnf.id==59001 then
		print("<<<<<<<<<<<请使用更名卡>>>>>>>>>>>>>>")
		self:__initChangeName(1)
		return
	elseif self.m_good.goodCnf~=nil and self.m_good.goodCnf.id==59002 then
		print("<<<<<<<<<<<请使用门派更名卡>>>>>>>>>>>>>>")
		self:__initChangeName(2)
		return
    elseif self.m_good.goodCnf~=nil and self.m_good.goodCnf.id==64200 then
        print("<<<<<<<<<<<请使用转职卡>>>>>>>>>>>>>>")
        local runningScene=cc.Director:getInstance():getRunningScene()
        -- if myScene:getChildByTag(7795) then return end
        local view =require("mod.smodule.TransferView")()
        local Transfer=view : create()
        -- runningScene:addChild(Transfer,_G.Const.CONST_MAP_ZORDER_LAYER+20,7795)

        return
    elseif self.m_good.goodCnf~=nil and self.m_good.goodCnf.id==64100 then
        print("<<<<<<<<<<<请使用重置卡>>>>>>>>>>>>>>")
        local function fun1()
            local msg = REQ_GOODS_USE()
            msg :setArgs(1,self.m_characterUid,self.m_good.index,self.m_good.goods_num)
            print("单个物品使用 协议发送 参数－－－－－:", self.m_characterUid, self.m_good.index, self.m_good.goods_num)
            _G.Network :send( msg)
        end
        _G.Util:showTipsBox("重置后道行全部返还，技能变为初始状态",fun1)

        return
	end
    --正常使用
    local msg = REQ_GOODS_USE()
    msg :setArgs(1,self.m_characterUid,self.m_good.index,self.m_good.goods_num)
    print("单个物品使用 协议发送 参数－－－－－:", self.m_characterUid, self.m_good.index, self.m_good.goods_num)
    _G.Network :send( msg)

end

function TipsUtil.__initChangeName( self,_type )
	local size = cc.Director : getInstance() : getWinSize()
    local function sureEvent( send,eventType )
        -- if eventType == ccui.TouchEventType.ended then
            self:checkName()
        -- end
    end 
    local name=""
    if _type==1 then
        name="更名卡"
    elseif _type==2 then
        name="门派更名卡"
    end
    local tipsBox = require("mod.general.TipsBox")()
    local tipsNode   = tipsBox : create("", sureEvent)
    tipsBox:setTitleLabel(name)
    cc.Director:getInstance():getRunningScene():addChild(tipsNode,1000)

    local layer=tipsBox:getMainlayer()
	local fontSize = 20
	local tipLeft = _G.Util : createLabel("",20)
	if _type==1 then
		tipLeft : setString("请输入新名字:")
	elseif _type==2 then
		tipLeft : setString("请输入门派名字:")
	end
	tipLeft : setAnchorPoint(cc.p(1,0.5))
	tipLeft : setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
	tipLeft : setPosition(cc.p(-20,15))
	layer   : addChild(tipLeft)

	local textBgSize=cc.size(150,34)
	local fieldSize=cc.size(120,30)
	local textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    local textField=ccui.EditBox:create(textBgSize,textBg)
    textField:setPosition(-10,15)
    textField:setFont(_G.FontName.Heiti,20)
    textField:setPlaceholderFont(_G.FontName.Heiti,20)
    textField:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    textField:setAnchorPoint(cc.p(0,0.5))
    layer:addChild(textField)

    if _type==1 then
		textField:setPlaceHolder("角色名")
        textField:setMaxLength(6)
	elseif _type==2 then
		textField:setPlaceHolder("门派名")
        textField:setMaxLength(8)
	end
    self.m_fieldRoleName=textField
end

function TipsUtil.checkName( self )
	local szName=self.m_fieldRoleName:getText()
    if szName=="" then
        _G.Util:showTipsBox("名字不能为空!")
        return
    end

    local tempLabel=_G.Util:createLabel("",10)
    if tempLabel.isHasUnDefineChar then
        local isNameHasUndefineChar=tempLabel:isHasUnDefineChar(szName)
        if isNameHasUndefineChar then
            local command=CErrorBoxCommand("名字不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end
    end

    self.m_wordFilter=self.m_wordFilter or require("util.WordFilter")
    if not self.m_wordFilter:checkName(szName) then
        return
    end

    local msg = REQ_GOODS_CHANG_NAME()
    msg       : setArgs(self.m_good.index,szName)
    _G.Network: send(msg)
end

function TipsUtil.manyGoodsuseMethod( self)
    --多个物品使用
    print(" 打开重叠道具使用框",self.m_good.goods_id,self.m_good.goods_num)
    local function local_ensureFun( _num )
        local msg = REQ_GOODS_USE()
        msg :setArgs(1,self.m_characterUid,self.m_good.index,_num)
        _G.Network : send(msg)
    end
    
    local NumberTipsBox    = require ("mod.general.NumberTipsBox")(self.m_good.goods_id,self.m_good.goods_num, 1, local_ensureFun )
    local tipsBoxContainer = NumberTipsBox :create(1)
end

function TipsUtil.checkJumpView(self)

    local goodnode = self.m_good.goodCnf
    if goodnode==nil or goodnode.type_sub==nil then return false end

    local type_sub = goodnode.type_sub
    print("跳转type_sub id is",type_sub,self.m_good.goods_id) 
   
    if  type_sub == _G.Const.CONST_GOODS_PET_CARD then
    	local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager : openLayer(_G.Const.CONST_FUNC_OPEN_BEAUTY)
    --伙伴卡 跳转 到灵妖
    elseif type_sub == _G.Const.CONST_GOODS_LINGYAOSUIPIAN then
        _G.GLayerManager :openSubLayer( _G.Const.CONST_FUNC_OPEN_PARTNER ) 
    --坐骑经验丹 跳转到 坐骑界面
    elseif type_sub == _G.Const.CONST_GOODS_COMMON_MOUNT_EXP then
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )
        -- _G.GLayerManager :openSubLayer( _G.Const.CONST_FUNC_OPEN_MOUNT ) 
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_MOUNT)
    --跳转到 翅膀升级界面
    elseif type_sub == _G.Const.CONST_GOODS_FEATHER_UPGRADE then
        if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_FEATHER) then return true end
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )
        -- _G.GLayerManager :openSubLayer( _G.Const.CONST_FUNC_OPEN_MOUNT)
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_FEATHER)
    --跳转到 翅膀升阶界面
    elseif type_sub == _G.Const.CONST_GOODS_FEATHER_UPSTEP then
        if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_FEATHER) then return true end
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )
        -- _G.GLayerManager :openSubLayer( _G.Const.CONST_FUNC_OPEN_MOUNT)
        _G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_FEATHER,false,nil,1)
    --跳到阵法界面
    elseif  type_sub == _G.Const.CONST_GOODS_LV_GOODS then
        if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHEN) then return true end
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_SHEN,false,_G.Const.CONST_FUNC_OPEN_SHEN_QUALITY)
    --宝石碎片转古墓探险的兑换商城
    elseif  type_sub == _G.Const.CONST_GOODS_BAOSHISUIPIAN then  
        print("宝石碎片跳转")
        local command = BagOpenHCCommand()
        controller :sendCommand( command )

    --洗练石跳转    
    elseif  type_sub == _G.Const.CONST_GOODS_STONE_WASH then
    	local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )  
        _G.GLayerManager :openLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT,false, 4)
    --神器碎片跳转    
    elseif  type_sub == _G.Const.CONST_GOODS_FRAGMENT then
    	local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )  
        _G.GLayerManager :openLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT,false, 5)   
    -- 节日活动物品
    elseif  type_sub == _G.Const.CONST_GOODS_HOLIDAY_GOOD then 
        local sysId=_G.Const.CONST_FUNC_OPEN_HOLIDAY
        if not _G.GOpenProxy:showSysNoOpenTips(sysId) then 
            print("开通了")
            local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
            controller :sendCommand( command )
            _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_HOLIDAY_VALUELESS)
        end
    -- 宝石物品     
    elseif type_sub >= _G.Const.CONST_GOODS_STERS_HP and type_sub <= _G.Const.CONST_GOODS_STERS_MIAN then  
        print("宝石跳转")
        if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SMITHY_INLAY) then return true end
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command )
        -- _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN,nil,3)
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY_INLAY)
    -- 附魔石 
    elseif  type_sub  == _G.Const.CONST_GOODS_COMMON_EXP then 
        print("附魔石跳转")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        -- _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN,nil,4)
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_SMITHY_ENCHANTS)
    -- 财神卡     
    elseif type_sub == _G.Const.CONST_GOODS_SPECIAL_CHONGZHI then  
        print("财神卡跳转")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
    -- 打折卡     
    elseif type_sub == _G.Const.CONST_GOODS_SPECIAL_LIBAO then  
        print("打折卡跳转")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SHOP,nil,_G.Const.CONST_MALL_TYPE_SUB_PACKAGE)
        -- _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_FUNC_OPEN_SHOP)
    -- 宠物丹or宠物
    elseif type_sub  == _G.Const.CONST_GOODS_ZHENFA then 
        print("宠物丹or宠物跳转")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_WING)
    -- 悬赏卡
    elseif type_sub  == _G.Const.CONST_GOODS_COMMON_RESET_SKILL then
        print("悬赏卡")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_TASK_DAILY)
    -- 天外陨石
    elseif type_sub  == _G.Const.CONST_GOODS_STORE_EXCHANGE then
        print("天外陨石")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_RECHARGE_SUPREME)
    elseif type_sub  == _G.Const.CONST_GOODS_HUAFEI then
        print("觉醒玉")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_PARTNER_ADVANCED)
    elseif type_sub >= _G.Const.CONST_GOODS_DEBRIS and type_sub < _G.Const.CONST_GOODS_HOLY_WATER then
        print("跳转到神器强化")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayer(_G.Const.CONST_FUNC_OPEN_ARTIFACT_STRENGTHEN)
    elseif type_sub == _G.Const.CONST_GOODS_HOLY_WATER then
        print("跳转到神器进阶")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayerByMapOpenId(_G.Const.CONST_MAP_ARTIFACT_QUALITY)
    elseif type_sub == _G.Const.CONST_GOODS_STORE_EXCHANGES then
        print("跳转到精彩活动")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :openLayer(_G.Const.CONST_FUNC_OPEN_REBATE)
    elseif type_sub == _G.Const.CONST_GOODS_LABA then
        print("跳转到聊天")
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_BAG)
        controller :sendCommand( command ) 
        _G.GLayerManager :delayOpenLayer(_G.Const.CONST_FUNC_OPEN_CHATTING)
    else
        return false
    end
    return true
end

function TipsUtil.isEnoughLv(self)
    local isOK = true
    local m_lv = self : getPlayerData("Lv")
    local node = self.m_good.goodCnf
    if node == nil then  return end
    if node.lv > m_lv then
        local command = CErrorBoxCommand(136)
        controller :sendCommand( command ) 

        self : _reset()

        isOK = false
    end

    return isOK
end

function TipsUtil.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 

    if     _CharacterName == "Lv" then
        CharacterValue = mainplay : getLv()
    elseif _CharacterName == "Vip" then
        CharacterValue = mainplay : getVipLv()
    elseif _CharacterName == "Gold" then
        CharacterValue = mainplay : getGold()
    elseif _CharacterName == "Rmb" then
        CharacterValue = mainplay :getRmb() + mainplay :getBindRmb()
    else
        CharacterValue = mainplay 
    end

    return CharacterValue
end

--初始化数据，没有2001数据时使用
function TipsUtil.useNodeGoodsInfo( self,_goodsId)
    local good = {}
    print("TipsUtil useNodeGoodsInfo _goodsId==== ".._goodsId)
    local node = _G.Cfg.goods[_goodsId]
    good.index        = nil
    good.goods_id     = _goodsId
    good.goods_num    = 0
    good.expiry       = 0
    good.time         = nil
    good.price        = node.price
    good.goods_type   = node.type
    print("大类--->"..good.goods_type)
    if good.goods_type == _G.Const.CONST_GOODS_EQUIP 
        or good.goods_type == _G.Const.CONST_GOODS_WEAPON 
        or good.goods_type == _G.Const.CONST_GOODS_MAGIC then 
        good.is_data      = true
        good.powerful     = nil
        good.pearl_score  = nil
        good.suit_id      = nil
        good.wskill_id    = nil
        good.strengthen   = 0
        good.plus_count   = 0
        good.plus_msg_no  = nil
        good.slots_count  = 0
        good.slot_group   = nil
        good.fumo         = 0
        good.fumoz        = 0
        good.fumov        = 0
        good.attr1        = 0
        good.attr2        = 0
        good.attr3        = 0
        good.attr4        = 0

        local iCount   = 0
        local attrList = {}
        local base_typeList  = node.base_type
        for k,v in pairs(base_typeList) do
            attrList[k] = {}
            attrList[k].attr_base_type  = v.type
            attrList[k].attr_base_value = v.v
        end

        if iCount > 0 then 
            print("有属性")
            good.attr_count   = iCount
            good.attr_data    = attrList
        else 
            good.attr_count   = 0
            good.attr_data    = nil
        end
    else
        good.is_data      = false
        good.powerful     = nil
        good.pearl_score  = nil
        good.suit_id      = nil
        good.wskill_id    = nil
        good.strengthen   = nil
        good.plus_count   = nil
        good.plus_msg_no  = nil
        good.slots_count  = nil
        good.slot_group   = nil
        good.fumo         = nil
        good.fumoz        = nil
        good.attr1        = 0
        good.attr2        = 0
        good.attr3        = 0
        good.attr4        = 0
        good.attr_count   = nil
        good.attr_data    = nil
    end   
    return good
end
return TipsUtil