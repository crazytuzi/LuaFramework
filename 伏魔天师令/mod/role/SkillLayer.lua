local SkillLayer=classGc(view, function(self)
    self.pMediator=require("mod.role.SkillLayerMediator")(self)
end)

local TAG_LVNUM = 10
local TAG_POWER = 20
local TAG_DES   = 30
local TAG_STRXH = 40
local FONT_SIZE = 18
local TAG_EQUIP_BTN1 = 1
local TAG_EQUIP_BTN2 = 2
local TAG_EQUIP_BTN3 = 3
local TAG_EQUIP_BTN3 = 4
local m_winSize=cc.Director:getInstance():getWinSize()

function SkillLayer.__create(self)
    self.m_mainProperty = _G.GPropertyProxy :getMainPlay()

    self.m_container = cc.Node:create()

    --外层绿色底图大小
    self.m_rootBgSize = cc.size(828,492)
    --左边内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
    local bgSpr1Size = cc.size(690,470)
    self.m_bgSpr1 = ccui.Scale9Sprite:createWithSpriteFrameName("general_login_dawaikuan.png")
    self.m_bgSpr1 : setPreferredSize( bgSpr1Size )
    self.m_container: addChild(self.m_bgSpr1,11111)
    self.m_bgSpr1 : setPosition(71,-50)
    --右左下内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
    local bgSpr3Size  = cc.size(133,470)
    self.m_bgSpr3     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" )
    self.m_bgSpr3     : setPreferredSize( bgSpr3Size )
    self.m_container  : addChild(self.m_bgSpr3)
    self.m_bgSpr3     : setPosition(-self.m_rootBgSize.width/2+68 ,-50)

    local doubleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
    doubleSpr:setPreferredSize(cc.size(bgSpr3Size.width-15,bgSpr3Size.height-10))
    doubleSpr:setPosition(bgSpr3Size.width/2,bgSpr3Size.height/2-1)
    self.m_bgSpr3 : addChild(doubleSpr)

    self:updateSkillData(true)
    self:createLeft()
    self:createSkillEquip()
    self:updateSkillEquip(true)
    return self.m_container
end

function SkillLayer.unregister(self)
    print("SkillLayer.unregister")
    if self.pMediator ~= nil then
        self.pMediator : destroy()
        self.pMediator = nil 
    end
end

-- 左边内容
function SkillLayer.createLeft(self)

    self.m_leftPanel = cc.Node:create()
    self.m_bgSpr1    : addChild(self.m_leftPanel)
    local width      = 676
    self.svSize      = cc.size(width,self.m_rootBgSize.height-30)
    self.oneSize     = cc.size(width,self.svSize.height/4)
    self.innerSize   = cc.size(width,self.oneSize.height*self.skillCount)
    local scrollView = cc.ScrollView:create()
    scrollView       : setViewSize(self.svSize)
    scrollView       : setTouchEnabled(true)
    scrollView       : setBounceable(false)
    scrollView       : setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView       : setContentSize(self.innerSize)
    scrollView       : setContentOffset(cc.p(0, self.svSize.height-self.innerSize.height))
    scrollView       : setPosition(6,3)
    self.m_leftPanel : addChild(scrollView)

    local scrollBar =require("mod.general.ScrollBar")(scrollView)
    scrollBar:setDirPosOff(cc.p(1,-4))
    self.m_scrollView = scrollView

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            sender : setTouchEnabled(false)
            local function canTouch()
                sender: setTouchEnabled(true)
            end
            sender:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(canTouch)))

            local Position  = sender : getWorldPosition()
            Position.y = Position.y
            local x,y = self.m_scrollView:getPosition()
            local pos = self.m_scrollView:convertToWorldSpace(cc.p(x,y))
            if not cc.rectContainsPoint(cc.rect(pos.x,pos.y,self.svSize.width,self.svSize.height),Position) then
                return
            end

            local tag=sender:getTag()
            self:selectSkill(tag)
        end
    end
 
    local function btn_update(sender,eventType)
        local Position  = sender : getWorldPosition()
        print("Position.y",Position.y,m_winSize.height/2+self.m_rootBgSize.height/2-100,m_winSize.height/2-self.m_rootBgSize.height/2-10)
        if Position.y>m_winSize.height/2+self.m_rootBgSize.height/2-100 or Position.y<m_winSize.height/2-self.m_rootBgSize.height/2-10 then return end
        self : selectSkill(sender:getTag())
        self : updateCallback(sender,eventType)
    end

    self.m_canDrag = true
    local function onTouchBegan(touch, event)
        if not self.m_canDrag then return end
        if self.m_skillIconSpr ~= nil then
            self.m_skillIconSpr : removeFromParent(true)
            self.m_skillIconSpr = nil 
        end
        local pos = touch:getLocation()
        for k,btn in pairs(self.m_skillBtn) do
            local posBtn = btn:getWorldPosition()
            local x,y = self.m_scrollView:getPosition()
            local posSv = self.m_scrollView:convertToWorldSpace(cc.p(x,y))
            if not cc.rectContainsPoint(cc.rect(posSv.x-120,posSv.y,self.svSize.width+120,self.svSize.height),pos) then
                return
            end
            if cc.rectContainsPoint(cc.rect(posBtn.x-self.m_equipSize.width/2,posBtn.y-self.m_equipSize.height/2,self.m_equipSize.width,self.m_equipSize.height),pos) then
                local iconString = _G.Cfg.skill[self.m_currentSkillId].icon
                self.m_skillIconSpr = _G.ImageAsyncManager:createSkillSpr(iconString)
                -- self.m_skillIconSpr : setScale(0.9)
                self.m_skillIconSpr : setPosition(pos)
                self.m_skillIconSpr : setOpacity(180)
                cc.Director:getInstance():getRunningScene(): addChild(self.m_skillIconSpr,500)
                self.m_canRemove = nil
                return true
            end
        end
        for k,btn in pairs(self.m_lpEquipBtns) do
            local posBtn = btn:getWorldPosition()
            if cc.rectContainsPoint(cc.rect(posBtn.x-self.m_equipSize.width/2,posBtn.y-self.m_equipSize.height/2,self.m_equipSize.width,self.m_equipSize.height),pos) then
                if self.m_tableEquipList[k].skill_id == 0 then return end
                self:selectSkill(self.m_tableEquipList[k].skill_id)
                local iconString = _G.Cfg.skill[self.m_currentSkillId].icon
                self.m_skillIconSpr = _G.ImageAsyncManager:createSkillSpr(iconString)
                -- self.m_skillIconSpr : setScale(0.9)
                self.m_skillIconSpr : setPosition(pos)
                self.m_skillIconSpr : setOpacity(180)
                cc.Director:getInstance():getRunningScene(): addChild(self.m_skillIconSpr,500)
                self.m_canRemove = true
                return true
            end
        end
    end
    local function onTouchMoved(touch, event)
        if self.m_skillIconSpr ~= nil then
            local pos = touch:getLocation()
            self.m_skillIconSpr : setPosition(pos)
        end
    end
    local function onTouchEnded(touch, event)
        if self.m_skillIconSpr ~= nil then
            local pos = touch:getLocation()
            for i,btn in pairs(self.m_lpEquipBtns) do
                -- local x,y = btn:getPosition()
                local posBtn = btn:getWorldPosition()
                if cc.rectContainsPoint(cc.rect(posBtn.x-self.m_equipSize.width/2,posBtn.y-self.m_equipSize.height/2,self.m_equipSize.width,self.m_equipSize.height),pos) then
                    self : equipCallback(i,self.m_currentSkillId)
                    break
                end
                if i>=3 and self.m_canRemove == true then
                    print(self.m_currentSkillId,"@#@$@$@$$")
                    self : equipCallback(0,self.m_currentSkillId)
                end
            end
            self.m_skillIconSpr : removeFromParent(true)
            self.m_skillIconSpr = nil 
        end
    end
    local function onTouchCancelled(touch, event)
        if self.m_skillIconSpr ~= nil then
            self.m_skillIconSpr : removeFromParent(true)
            self.m_skillIconSpr = nil 
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener       : setSwallowTouches(true)
    listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    local node = cc.Node:create()
    scrollView : addChild(node)

    local eventDispatcher = node : getEventDispatcher() -- 得到事件派发器
    eventDispatcher : addEventListenerWithSceneGraphPriority(listener, node) -- 将监听器注册到派发器中

    self.m_leftNodeList = {}
    self.m_skillBtn     = {}
    local levelUpBtnArray={}
    for i=1,self.skillCount do
        local skillId   = self.skillIds[i]
        local skillInfo = self.m_skillInfos[skillId]
        if skillInfo == nil then
            break
        end
        local widget = ccui.Widget:create()
        widget       : setContentSize(self.oneSize)
        widget       : setTouchEnabled(true)
        widget       : addTouchEventListener(c)
        widget       : setSwallowTouches(false)
        widget       : setTag(skillInfo.skill_id)

        local bgSize = cc.size(self.oneSize.width,self.oneSize.height-5)
        local bgSpr1  = ccui.Scale9Sprite : createWithSpriteFrameName("general_nothis.png") 
        bgSpr1        : setPreferredSize( bgSize )
        widget: addChild(bgSpr1 )
        bgSpr1 : setAnchorPoint(0,0)

        local btn = gc.CButton:create("battle_skill_box.png") 
        local sprSize= btn:getContentSize()
        -- btn          : setButtonScale(0.9)
        btn          : setSwallowTouches(false)
        btn          : setPosition(60 , bgSize.height/2 )
        btn          : setTag(skillInfo.skill_id)
        widget       : addChild(btn,10)
        self.m_skillBtn[i] = btn
        self         : addSkillIcon(skillId,btn,sprSize)

        -- 名字
        local name      = skillInfo.name
        local nameLabel = _G.Util:createLabel(name,FONT_SIZE+4)
        nameLabel       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        nameLabel       : setAnchorPoint(0,0.5)
        nameLabel       : setPosition(130, bgSize.height/2+25)
        widget          : addChild(nameLabel)

        -- 战功
        local strLab  = _G.Util:createLabel("消耗道行:",FONT_SIZE+4)
        strLab        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        strLab        : setPosition(self.oneSize.width/2+80, bgSize.height/2+25)
        strLab        : setTag(TAG_STRXH)
        widget        : addChild(strLab)

        local nameWidth=nameLabel:getContentSize().width+10
        local power   = _G.Util:createLabel("12",FONT_SIZE+4)
        power         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
        power         : setAnchorPoint(0,0.5)
        power         : setPosition(self.oneSize.width/2+132, bgSize.height/2+25)
        power         : setTag(TAG_POWER)
        widget        : addChild(power)
        self:setPower(skillInfo.power or 0,widget)

        -- 描述
        local des   = _G.Util:createLabel("12",FONT_SIZE+2)
        des         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        des         : setDimensions(430, 50)
        des         : setAnchorPoint(0,0.5)
        des         : setPosition(130, bgSize.height/2-18)
        des         : setTag(TAG_DES)
        widget      : addChild(des)
        print('')
        self:setDes(skillInfo.remark,widget)

        local lv   = _G.Util:createLabel("12",FONT_SIZE+4)
        lv         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
        lv         : setAnchorPoint(0,0.5)
        lv         : setPosition(130+nameWidth, bgSize.height/2+25)
        lv         : setTag(TAG_LVNUM)
        widget     : addChild(lv)
        self:setLvNum(skillInfo.skill_lv or 0,widget)

        widget     : setPosition(self.oneSize.width/2,self.innerSize.height-self.oneSize.height*i+self.oneSize.height/2)

        scrollView : addChild(widget)

        -- 升级按钮

        btn = gc.CButton:create("general_add.png") 
        btn : setTitleFontName(_G.FontName.Heiti)
        btn : addTouchEventListener(btn_update)
        btn : setTitleFontSize(FONT_SIZE)
        btn : setPosition(self.oneSize.width-60,self.oneSize.height/2)
        btn : setTag(skillInfo.skill_id)
        btn : setContentSize(cc.size(100,100))
        widget:addChild(btn)

        levelUpBtnArray[i]=btn

        self.m_leftNodeList[skillInfo.skill_id] = widget

    end
    self:selectSkill(self.skillIds[1])

    local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL3 then
        local function nnnnn()
            _G.GGuideManager:runNextStep()
        end
        self.m_guide_wait_up_level=6
        _G.GGuideManager:registGuideData(2,levelUpBtnArray[2])
        levelUpBtnArray[2]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(nnnnn)))
        scrollView:setTouchEnabled(false)
    -- elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL4 then
    --     local function nnnnn()
    --         _G.GGuideManager:runNextStep()
    --     end
    --     self.m_guide_wait_up_level=21
    --     _G.GGuideManager:registGuideData(2,levelUpBtnArray[4])
    --     levelUpBtnArray[4]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(nnnnn)))
    --     scrollView:setTouchEnabled(false)
    else
        local guideEquipIdx=nil
        if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL1 then
            guideEquipIdx=2
            _G.Util:playAudioEffect("sys_skill")
        elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL2 then
            guideEquipIdx=3
        elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL4 then
            guideEquipIdx=4
        end
        if guideEquipIdx~=nil then
            local function nnnnn()
                _G.GGuideManager:runNextStep()
            end
            _G.GGuideManager:registGuideData(2,self.m_skillBtn[guideEquipIdx])
            self.m_skillBtn[guideEquipIdx]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(nnnnn)))
            self.m_guide_wait_equip_pos=guideEquipIdx
            scrollView:setTouchEnabled(false)
        end
    end
end

function SkillLayer.setLvNum(self,val,panel)
    local label = panel:getChildByTag(TAG_LVNUM)
    local powerlabel = panel:getChildByTag(TAG_POWER)
    local strlabel = panel:getChildByTag(TAG_STRXH)
    if self.m_roleLv >= val then
        label:setString(string.format("(Lv.%d)",val))
        label:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
        powerlabel:setVisible(true)
        strlabel : setVisible(true)
    else
        label:setString(string.format("(领悟要求:Lv.%d)",val))
        label:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
        powerlabel:setVisible(false)
        strlabel : setVisible(false)
    end
end
function SkillLayer.setPower(self,val,panel)
    local label = panel:getChildByTag(TAG_POWER)
    label:setString(string.format("%d/%d",self.m_myPower,val))
    if self.m_myPower<val then
        label:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    else
    	label:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    end
end
function SkillLayer.setDes(self,val,panel)
    local label = panel:getChildByTag(TAG_DES)
    label:setString(val)
end

function SkillLayer.createSkillEquip( self )
    print("createSkillEquip")
    if self.m_equipLayer ~= nil then
        self.m_equipLayer :removeFromParentAndCleanup( true)
        self.m_equipLayer = nil
    end

    self.m_equipLayer = cc.Node:create()
    self.m_bgSpr3     : addChild(self.m_equipLayer,1000)

    local function btn_equipCallback( sender, eventType)
        self: equipCallback(sender,eventType)
    end

    self.m_lpEquipBtns={}
    local numArray = {"一","二","三","四"}
    local midPos_x  = 67
    local pos_y     = 515
    local pianyiLiang = -10
    for i=1,3 do
        local btn = gc.CButton:create() 
        btn : loadTextures("battle_skill_box.png")
        btn : setTouchEnabled(false)
        -- btn : setButtonScale(0.9)

        local val=self.m_skillInfos[self.skillIds[i]].skill_lv
        if self.m_roleLv < val then
            string = string.format("%s级开放",val)
            local lbe = _G.Util:createLabel(string,18)
            lbe : setPosition(47,45)
            btn : addChild(lbe,-10)
        end
        
        
        self.m_lpEquipBtns[i] = btn
        self.m_equipLayer:addChild(self.m_lpEquipBtns[i],0,i)
        if not self.m_equipSize then
            self.m_equipSize = btn:getContentSize()
        end
        self.m_lpEquipBtns[i]:setPosition(midPos_x,pos_y - i*140)
    end
end

function SkillLayer.updateSkillData(self,_isInit)
    local mainSkillData =  self.m_mainProperty : getSkillData()
    self.m_roleLv     =  self.m_mainProperty : getLv()        --玩家等级
    self.m_rolePro    =  self.m_mainProperty : getPro()
    self.m_myGold     =  self.m_mainProperty : getGold()
    self.m_myPower    =  self.m_mainProperty : getPower()
    self.m_skinId     =  self.m_mainProperty : getSkinArmor()
    --已经学习的技能列表
    self.m_tableStudySkillList  = mainSkillData.skill_study_list
    --已装备的技能信息
    self.m_tableEquipList       = mainSkillData.skill_equip_list
    --当前职业的技能表(包括已学及未学的技能)  skill_count    skill..
    --xml信息
    self.m_skillInfos = {}

    if self.m_rolePro == 0 then
        print("self.m_rolePro is error")
        self.m_rolePro = self.m_skinId%10000
    end
    self.skillIds =_G.Cfg.player_init[self.m_rolePro].skill_learn
    self.skillCount=#self.skillIds

    local learn_max_lv=0
    for _,skill_id in ipairs(self.skillIds) do
        local skillInfo= {}
        skillInfo.skill_id= skill_id
        skillInfo.isStart = false

        local skillNode =_G.Cfg.skill[skill_id]
        if skillNode==nil then
          CCMessageBox("skilltable not found id:"..tostring(skill_id), "error")
          return
        end

        --显示的所有技能id 与已经学习的技能列表比较  获取技能当前等级， 如果没学 默认为0
        for key, value in pairs( self.m_tableStudySkillList ) do
          if key == skillInfo.skill_id then
              print("学习了该技能", key, skillInfo.skill_id, value.skill_lv)
              skillInfo.skill_lv= value.skill_lv
              break
          end
        end
        skillInfo.skill_lv = skillInfo.skill_lv or skillNode.lv_min
        skillInfo.isStart  = skillInfo.skill_lv <= self.m_roleLv

        --技能id 与已经装备的技能列表比较，获取技能的 equip_pos,如果没有装备 equip_pos默认为 -1
        for i=1,3 do
          if self.m_tableEquipList[i] ~= nil then
              if self.m_tableEquipList[i].skill_id == skillInfo.skill_id then
                  print("装备的技能xml", self.m_tableEquipList[i].skill_id, skillInfo.skill_id, self.m_tableEquipList[i].equip_pos)
                  skillInfo.equip_pos = self.m_tableEquipList[i].equip_pos
                  break
              end
          end
        end
        skillInfo.equip_pos = skillInfo.equip_pos or -1
        skillInfo.lv_max    = skillNode.lv_max        --技能最大等级
        skillInfo.name      = skillNode.name  --技能名字

        local nMaxLv = self.m_roleLv
        local nLv = skillInfo.skill_lv
        if skillInfo.skill_lv~=nil and skillInfo.skill_lv>0 and skillInfo.isStart then
            learn_max_lv=learn_max_lv<nLv and nLv or learn_max_lv
            -- if skillInfo.skill_lv<nMaxLv then
            --     nLv = nLv + 1
            -- end
        end
        print("nLv=",nLv,learn_max_lv)

        local skillNode =_G.g_SkillDataManager:getSkillData(skill_id)
        local lvsNode = skillNode.lv
        if lvsNode~=nil then
            local lvNode = lvsNode[nLv]
            local nextLvNode = lvsNode[nLv+1]
            if lvNode~=nil then
                skillInfo.remark= lvNode.remark or ""   --技能描述
                skillInfo.power= nextLvNode.power or 0  --所需战功
                skillInfo.must_lv= lvNode.lv or 0  --所需等级
            end
        end

        self.m_skillInfos[skill_id]=skillInfo
    end

    if self.m_guide_wait_up_level and not _isInit then
        if self.m_guide_wait_up_level<=learn_max_lv then
            if self.m_guide_wait_up_level==6 then
                _G.Util:playAudioEffect("sys_praise")
            end
            self.m_guide_wait_up_level=nil
            _G.GGuideManager:runNextStep()
        end
    end
end

function SkillLayer.selectSkill(self,skillId)
    self.m_currentSkillId = skillId
end

--更新技能信息
function SkillLayer.updateSkillInfo( self )
    print("----->updateSkillInfo")
    if self.m_currentSkillId==nil then
        return
    end
    local skillInfo=self.m_skillInfos[self.m_currentSkillId]
    if skillInfo == nil then
        CCMessageBox("updateSkillInfo  skillInfo==nil","出错")
        return
    end

    print("skillInfo.must_lv=",skillInfo.must_lv,"skillInfo.power=",skillInfo.power,"skillInfo.remark=",skillInfo.remark )

end

--更新技能列表(等级、是否已装备)
function SkillLayer.updateSkillBtnList( self )
    local skillInfo = self.m_skillInfos[self.m_currentSkillId]
    local panel = self.m_leftNodeList[self.m_currentSkillId]
    self:setLvNum(skillInfo.skill_lv, panel)
    for k,v in pairs(self.m_leftNodeList) do
        local data = self.m_skillInfos[k]
        self:setPower(data.power,v)
    end
    self:setDes(skillInfo.remark,panel)
end

--更新技能装备
function SkillLayer.updateSkillEquip( self,_isInit )
    print("----->updateSkillEquip")
    local equipCount=0
    for i=1,3 do
        if self.m_tableEquipList[i] ~= nil then
            if self.m_tableEquipList[i].skill_id == 0 then
                self :removeSkillIcon(self.m_lpEquipBtns[i])
            else
                equipCount=equipCount+1
                self :addSkillIcon(self.m_tableEquipList[i].skill_id, self.m_lpEquipBtns[i],self.m_equipSize)
            end
        end
    end
    if self.m_guide_wait_equip_pos~=nil and not _isInit then
        if equipCount>=self.m_guide_wait_equip_pos then
            _G.GGuideManager:runNextStep()
            self.m_guide_wait_equip_pos=nil
        end
    end
end

--添加技能图标
function SkillLayer.addSkillIcon( self, _skillId, _iconBg,size )
    if _skillId == nil or _iconBg == nil then
        return
    end
    local iconString = _G.Cfg.skill[_skillId].icon
    self :removeSkillIcon(_iconBg)
    local skillIconSpr = _G.ImageAsyncManager:createSkillSpr(iconString)
    skillIconSpr       : setPosition(size.width/2,size.height/2)
    _iconBg :addChild( skillIconSpr, -1, 100 )
end

--删除技能图标
function SkillLayer.removeSkillIcon( self, _iconBg )
    if _iconBg :getChildByTag( 100 ) ~= nil then
        _iconBg :removeChildByTag( 100 )
    end
end

function SkillLayer.updateCallback(self,sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        print("updateCallback")
        local skillId   = self.m_currentSkillId
        local skillInfo = self.m_skillInfos[skillId]
        local nLv       = skillInfo.skill_lv
        self :REQ_SKILL_LEARN( skillId, nLv )
    end
end

function SkillLayer.equipCallback(self,tag,skillId)
    if skillId==nil then
      local command = CErrorBoxCommand( 8202 )
      controller : sendCommand(command)
      return
    end
    self:REQ_SKILL_EQUIP(tag, skillId)
end

function SkillLayer.REQ_SKILL_LEARN( self, _skillId, _nLv )
    local msg = REQ_SKILL_LEARN()
    msg :setArgs(_skillId,_nLv)
    _G.Network:send( msg)
end

function SkillLayer.REQ_SKILL_EQUIP( self,index, _skillId )
    local msg = REQ_SKILL_EQUIP()
    msg :setArgs(index, _skillId)
    _G.Network:send( msg)
end

function SkillLayer.showSkill( self,skillId )
    self.m_player:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
    -- self.m_player:hideEskillEffect()
    for k,v in pairs(_G.CharacterManager.m_lpVitroArray) do
      print("----------------------sdada--->>>",k,v)
      _G.g_Stage :removeVitro(v)
    end
    self.m_player:useSkill(skillId)

    local function show(  )
    self.m_player:useSkill(skillId)
    end
    -- self.m_bgSpr2:stopAllActions()
    -- self.m_bgSpr2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(8),cc.CallFunc:create(show))))
end

return SkillLayer