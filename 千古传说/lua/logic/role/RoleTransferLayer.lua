--[[
******角色传功*******

    -- by haidong.gan
    -- 2014/4/16
]]

local RoleTransferLayer = class("RoleTransferLayer", BaseLayer)

local TransferRoleCost = ConstantData:getValue("Transfer.Role.Cost")
local TransferSoulCost = ConstantData:getValue("Transfer.Soul.Cost")
local RoleLevelMaxMultiple = ConstantData:getValue("Role.Level.MaxMultiple")
local TransferRoleRate = ConstantData:getValue("Transfer.Role.Rate")

function RoleTransferLayer:ctor(data)
    self.super.ctor(self,data)
    self.selectType = 2;
    self.fightType = EnumFightStrategyType.StrategyType_PVE
    self:init("lua.uiconfig_mango_new.role.RoleTransferLayer")
end

function RoleTransferLayer:initUI(ui)
	self.super.initUI(self,ui)
    
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.RoleTransfer,{HeadResType.COIN,HeadResType.SYCEE})

    self.img_role           = TFDirector:getChildByPath(ui, 'img_role')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.txt_level          = TFDirector:getChildByPath(ui, 'txt_level')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
    self.img_quality_icon   = TFDirector:getChildByPath(ui, 'img_quality_icon')
    self.img_star           = {}
    for i=1,5 do
        local str = "img_star"..i
        local star = TFDirector:getChildByPath(ui, str)
        if star then
            self.img_star[i]  = TFDirector:getChildByPath(star, 'img_starliang')
        end
    end

    self.panel_menu         = TFDirector:getChildByPath(ui, 'panel_menu')
    self.btn_xiahun         = TFDirector:getChildByPath(ui, 'btn_xiahun')
    self.btn_xiake          = TFDirector:getChildByPath(ui, 'btn_xiake')

    self.panel_list         = TFDirector:getChildByPath(ui, 'panel_list')
    self.btn_reset          = TFDirector:getChildByPath(ui, 'btn_reset')
    self.btn_transfer       = TFDirector:getChildByPath(ui, 'btn_transfer')
    self.txt_needCoin       = TFDirector:getChildByPath(ui, 'txt_needCoin')

    self.txt_addExp         = TFDirector:getChildByPath(ui, 'txt_addExp')
    self.bar_percent        = TFDirector:getChildByPath(ui, 'bar_percent')
    self.txt_addLevel       = TFDirector:getChildByPath(ui, 'txt_addLevel')

    self.txt_levelup        = TFDirector:getChildByPath(ui, 'txt_levelup')
    self.img_diwen1        = TFDirector:getChildByPath(ui, 'img_diwen1')
    self:addQualityEffect()

    self.panel_content     = TFDirector:getChildByPath(ui, 'panel_content')


    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun_btn.png")

    self:initTableView()


    self.btn_xiake:setVisible(false)-- 牛逼的策划要屏蔽侠客传功的功能
    self.btn_xiahun:setVisible(false)-- 牛逼的策划要屏蔽侠客传功的功能
    -- 牛逼的策划 要左右滑动角色
    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.positiony          = self.btn_right:getPosition().y
    self.panel_rolelist     = TFDirector:getChildByPath(ui, 'panel_rolelist')
    self:drawRoleList()
end

function RoleTransferLayer:addQualityEffect()
    local eftID = "qualityeft"
    ModelManager:addResourceFromFile(2, eftID, 1)
    local eft = ModelManager:createResource(2, eftID)
    eft:setPosition(ccp(212, 215))
    self.img_diwen1:addChild(eft)
    ModelManager:playWithNameAndIndex(eft, "", 0, 1, -1, -1)
end

function RoleTransferLayer:loadData(gmId,fightType)
    self.roleGmId = gmId;
    self.fightType = fightType
end

function RoleTransferLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleTransferLayer:reShow()
    self:refreshUI();
end

function RoleTransferLayer:refreshBaseUI()

end

function RoleTransferLayer:refreshUI()
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    self.selectIndex = self.roleMainList:indexOf(self.cardRole)
    self:refreshRoleList(self.selectIndex)

    -- if not self.isShow then
    --     return;
    -- end

    -- self.cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )

    -- local function cmpFun( cardRole1, cardRole2 )
    --     if cardRole1.quality <= cardRole2.quality then
    --         if cardRole1:getpower() <= cardRole2:getpower() then
    --             return true
    --         end
    --         return true
    --     else
    --         return false
    --     end
    -- end

    -- local function soulcmp( soul1, soul2 )
    --     if soul1.kind == 3 and soul2.kind ~= 3 then
    --         return true;
    --     elseif soul1.kind ~= 3 and  soul2.kind == 3 then
    --         return false;
    --     elseif soul1.kind == 3 and  soul2.kind == 3 then
    --         if soul1.quality <= soul2.quality then
    --             return true;
    --         else
    --             return false;
    --         end
    --     elseif soul1.quality <= soul2.quality then
    --         if soul1.id <= soul2.id then
    --             return true
    --         end
    --         return true
    --     else
    --         return false
    --     end
    -- end
    -- self.roleList = CardRoleManager:getOtherNotUsed(self.roleGmId)
    -- self.roleList:sort(cmpFun)
    -- self.soulList = BagManager:getItemByType(EnumGameItemType.Soul)
    -- for v in self.soulList:iterator() do
    --     if v.type == EnumGameItemType.Soul and v.kind == 2 then
    --         self.soulList:removeObject(v)
    --     end
    -- end
    -- for v in self.roleList:iterator() do
    --     if v:getIsMainPlayer() then
    --         self.roleList:removeObject(v)
    --     end
    -- end

    -- --却掉自己的侠魂
    -- local selfSoul = BagManager:getItemById(self.cardRole.soul_card_id );
    -- if selfSoul then
    --     self.soulList:removeObject(selfSoul);
    -- end

    -- self.soulList:sort(soulcmp)

    -- self.dogfood = TFArray:new()
    -- self.catfood = TFArray:new()

    -- self.costcoin = 0


    -- self.tableView:reloadData();
    -- self.tableView:scrollToYTop(0);


    -- self.templevel = self.cardRole.level    
    -- self.tempexp   = self.cardRole.curExp
    -- print("self.templevel , self.tempexp",self.templevel,self.tempexp,self.cardRole:getBigImagePath())
    -- self.img_role:setTexture(self.cardRole:getBigImagePath())
    -- self.txt_name:setText(self.cardRole.name)
    -- self.img_diwen1:setTexture(GetRoleNameBgByQuality(self.cardRole.quality))
    -- -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality))
    -- self.txt_level:setText(self.cardRole.level .. "d")
    -- self.txt_power:setText(self.cardRole:getPowerByFightType(self.fightType))
    -- self.img_quality_icon:setTexture(GetFontByQuality( self.cardRole.quality ))

    -- self:setRoleExpInfo()

end

function RoleTransferLayer:setRoleExpInfo()
    -- for i=1,5 do
    --     if i <= self.cardRole.starlevel then
    --         self.img_star[i]:setVisible(true)
    --     else
    --         self.img_star[i]:setVisible(false)
    --     end
    -- end
    for i=1,5 do
        self.img_star[i]:setVisible(false)
    end
    for i=1,self.cardRole.starlevel do
        local starIdx = i
        local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
        if i > 5 then
            starTextrue = 'ui_new/common/xl_dadian23_icon.png'
            starIdx = i - 5
        end
        self.img_star[starIdx]:setTexture(starTextrue)
        self.img_star[starIdx]:setVisible(true)
    end

    local tmpLevel = self.templevel
    local tmpExp   = self.tempexp

    local maxExp = LevelData:getMaxRoleExp(self.templevel)
    if maxExp == 0 then
        --self.txt_addExp:setText("满级")
        self.txt_addExp:setText(localizable.common_max_level)
        self.bar_percent:setPercent(100)
    else
        if  self.templevel > MainPlayer:getLevel() then
            maxExp = LevelData:getMaxRoleExp(math.min(self.templevel, MainPlayer:getLevel()))

            self.txt_addExp:setText(maxExp .. "/" .. maxExp)
            self.bar_percent:setPercent(100)

            tmpLevel = MainPlayer:getLevel()
            tmpExp   = maxExp
        else
            self.txt_addExp:setText(self.tempexp .. "/" .. maxExp)
            self.bar_percent:setPercent(100*self.tempexp/maxExp)
        end
    end

    -- print("---------------")
    -- print("tmpLevel = ", tmpLevel)
    -- 角色传功消耗铜币 =传功经验 * 0.1 --土匪广
    local needTotalExp = 0
    if tmpLevel - self.cardRole.level > 0 then
        local needExp  = 0
        for i=self.cardRole.level,tmpLevel do
            needExp = LevelData:getMaxRoleExp(i)

            needTotalExp = needTotalExp + needExp
        end

        -- print('needTotalExp1  = ', needTotalExp)
        -- print('curExp  = ', self.cardRole.curExp)
        -- print('tmpExp  = ', tmpExp)
        -- print("(needExp - tmpExp) = ", (needExp - tmpExp))
        needTotalExp = needTotalExp - self.cardRole.curExp - (needExp - tmpExp)

    else
        needTotalExp = tmpExp - self.cardRole.curExp
    end 

    -- print("tmpLevel = ", tmpLevel)
    -- print("needTotalExp2 = ", needTotalExp)
    self.costcoin = math.ceil(needTotalExp * 0.1) 

    if self.templevel - self.cardRole.level > 0 then
        self.txt_addLevel:setVisible(true);
        -- self.txt_addLevel:setText("+" .. math.min(self.templevel - self.cardRole.level, MainPlayer:getLevel() - self.cardRole.level) .. "级");
        self.txt_addLevel:setText(stringUtils.format(localizable.RoleTransferLayer_add_level, math.min(self.templevel - self.cardRole.level, MainPlayer:getLevel() - self.cardRole.level) ));
    else
        self.txt_addLevel:setVisible(false);
    end

    self.txt_needCoin:setText(self.costcoin)
    if self.costcoin > MainPlayer:getCoin() then
        self.txt_needCoin:setColor(ccc3(255,0,0))
    else
        self.txt_needCoin:setColor(ccc3(255,255,255))
    end
end

function RoleTransferLayer:removeUI()
    self.super.removeUI(self)
end

function RoleTransferLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function RoleTransferLayer:registerEvents()
    self.super.registerEvents(self)

    -- ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)
    -- self.btn_close:setClickAreaLength(100);

    self.btn_xiahun.logic       = self
    self.btn_xiake.logic        = self
    self.btn_reset.logic        = self
    self.btn_transfer.logic     = self

    self.btn_xiahun:addMEListener(TFWIDGET_CLICK, audioClickfun(self.XiaHunClickHandle))
    self.btn_xiake:addMEListener(TFWIDGET_CLICK, audioClickfun(self.XiaKeClickHandle))
    self.btn_reset:addMEListener(TFWIDGET_CLICK, audioClickfun(self.RefreshClickHandle),1)
    self.btn_transfer:addMEListener(TFWIDGET_CLICK, audioClickfun(self.TransferClickHandle),1)


    self.RoleTransferpResultCallBack = function (event)
        self.dogfood = nil;
        
        local data = event.data[1]

        self.newarr = {}
        --角色属性
        for i=1,EnumAttributeType.Max do
            self.newarr[i] = self.cardRole:getTotalAttribute(i);
        end

        local newpower = self.cardRole:getPowerByFightType(self.fightType);
        local newlevel = self.cardRole.level;
        local newcurExp = self.cardRole.curExp;

        self:refreshUI()

        self:levelChange(self.oldlevel,self.oldcurExp,newlevel,newcurExp,self.oldpower,newpower);
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT,self.RoleTransferpResultCallBack)

    self.MoneyRefreshCallBack = function (event)
        self.txt_needCoin:setText(self.costcoin)
        if self.costcoin > MainPlayer:getCoin() then
            self.txt_needCoin:setColor(ccc3(255,0,0))
        else
            self.txt_needCoin:setColor(ccc3(0,0,0))
        end
    end
    TFDirector:addMEGlobalListener(MainPlayer.SyceeChange,self.MoneyRefreshCallBack)
    TFDirector:addMEGlobalListener(MainPlayer.CoinChange,self.MoneyRefreshCallBack)

    if self.generalHead then
        self.generalHead:registerEvents()
    end


    -- 牛逼的策划要加左右滑动
    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1)
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1)


end


function RoleTransferLayer:levelChange(oldlevel,oldcurExp,newlevel,newcurExp,oldpower,newpower)
    local maxExp = LevelData:getMaxRoleExp(oldlevel)
    self.txt_level:setText(oldlevel .. "d");
    self.txt_power:setText(oldpower);

    if maxExp == 0 then
        --self.txt_addExp:setText("满级")
        self.txt_addExp:setText(localizable.common_max_level)
        self.bar_percent:setPercent(100)
        return;
    end

    self.txt_addExp:setText(oldcurExp .. "/" .. maxExp)
    self.bar_percent:setPercent(100*oldcurExp/maxExp)

    local levelTimes = 0;
    local oldLevelTimes = 0;

    local expTimes = math.floor((oldcurExp/maxExp)*100);

    function change()
        play_chuangongrenwushengji()
    
        local fromx = self.img_role:getPosition().x
        local fromy = self.img_role:getPosition().y

        local pos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x,self.img_role:getPosition().y))
        pos = self:convertToNodeSpace(pos);

        local effectID = "role_transfe_level_up"
        ModelManager:addResourceFromFile(2, effectID, 1)
        local upPic = ModelManager:createResource(2, effectID)

        upPic:setPosition(pos + ccp(0, -250))
        self:addChild(upPic,100)

        ModelManager:addListener(upPic, "ANIMATION_COMPLETE", function() 
            ModelManager:removeListener(upPic, "ANIMATION_COMPLETE")
            upPic:removeFromParent()
        end)

        ModelManager:playWithNameAndIndex(upPic, "", 0, 0, -1, -1)

        -- local resPath = "effect/role_transfe_level_up.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- local upPic = TFArmature:create("role_transfe_level_up_anim")

        -- upPic:setAnimationFps(GameConfig.ANIM_FPS)
        -- upPic:setPosition(pos)

        -- self:addChild(upPic,100)
        -- upPic:playByIndex(0, -1, -1, 0)
        -- upPic:addMEListener(TFARMATURE_COMPLETE,function()
        --     upPic:removeMEListener(TFARMATURE_COMPLETE) 
        --     upPic:removeFromParent()
        -- end)

        local levelTween = {
              target = self.txt_level,
              {

                duration = 0.3,
                scale = 1.3;
              },
              { 
                duration = 0.2,
                scale = 1, 
              }
        }

        TFDirector:toTween(levelTween);
        

        self:powerChange(oldpower,newpower);
    
        if self.oldarr and self.newarr then
            self:arrChange( self.oldarr,self.newarr);
        end
        if newlevel > oldlevel then
            self:addToast(newlevel - oldlevel)
        end

        -- 显示最后的
        self.txt_level:setText(newlevel .. "d");

        self.templevel = self.cardRole.level    
        self.tempexp   = self.cardRole.curExp
        

        self:setRoleExpInfo()
    end

    -- if self.levelTimeId ~= nil then
    --     TFDirector:removeTimer(self.levelTimeId);
    --     self.levelTimeId = nil;
    -- end
    change()
    -- self.levelTimeId = TFDirector:addTimer(0.01, -1, nil, change);

end


function RoleTransferLayer:addToast(value)

    local label = TFLabelBMFont:create();

    self.toastLabelList = self.toastLabelList or {}
    self.toastLabelList[30] = label

    label:setPosition(ccp(self.txt_addLevel:getPosition().x + 30 ,self.txt_addLevel:getPosition().y - 20));
    label:setFntFile("font/new/num_22.fnt");
    -- label:setFontName("黑体");
    label:setAnchorPoint(ccp(0,0.5))

    self.txt_addLevel:getParent():addChild(label,10);

    label:setColor(ccc3(  0, 255,   0));
    label:setText("D" .. value);
   
    local toY = label:getPosition().y + 40 ;
    local toX = label:getPosition().x ;
    

    local toastTween = {
          target = label,
          {
            duration = 0.5,
            x = toX,
            y = toY
          },
          { 
            duration = 0,
            delay = 2, 
          },
          {
             duration = 0.5,
             alpha = 1,
          },
          {
            duration = 0,
            onComplete = function() 
                if self.toastLabelList then
                    self.toastLabelList[30] = nil
                end
                label:removeFromParent();
           end
          }
        }

    TFDirector:toTween(toastTween);
end

function RoleTransferLayer:powerChange(oldValue,newValue)
    self.txt_power:setText(oldValue);

    local changeSum = newValue - oldValue

    if self.power_effect == nil then
        -- local resPath = "effect/ui/power_change.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- effect = TFArmature:create("power_change_anim")

        -- self.txt_power:addChild(effect,2)
        local effect = Public:addEffect("power_change", self.txt_power, 0, -10, 0.5, 0)
        effect:setZOrder(2)
        self.power_effect = effect
        self.power_effect:setVisible(false)
    end

    local frame = 1
    self.txt_power:setScale(1)
    self.ui:setAnimationCallBack("power_change", TFANIMATION_FRAME, function()
        if frame == 11 then
            self.power_effect:setVisible(true)
            -- self.power_effect:playByIndex(0, -1, -1, 0)
             ModelManager:playWithNameAndIndex(self.power_effect, "", 0, 0, -1, -1)
        end
        if frame >= 11 and frame < 34 then
             if newValue > oldValue then
                play_shuzibiandong()
            end
            local tempValue = oldValue + (frame - 11) *(changeSum/23)
            self.txt_power:setText(math.floor(tempValue));
        end
        if frame == 34 then
            self.power_effect:removeFromParent()
            self.power_effect = nil
            self.txt_power:setText(newValue);
        end
        frame = frame + 1
    end)
    self.ui:runAnimation("power_change",1);
end
function RoleTransferLayer:arrChange(oldarr,newarr)
    local changeArrTemp = {}
    local changeLength = 0;
    for i=1,EnumAttributeType.Max do
        local offset = newarr[i] - oldarr[i];
        if offset ~= 0 then
            changeLength = changeLength + 1;
            changeArrTemp[changeLength] = {i,offset};

        end
    end

    local changeArr = {}

    local index = 0;
    for i=1,#changeArrTemp do
        local offsetTb = changeArrTemp[i];
        if offsetTb[2] > 0 then
            index = index + 1;
            changeArr[index] = offsetTb;
        end
    end

    for i=1,#changeArrTemp do
        local offsetTb = changeArrTemp[i];
        if offsetTb[2] < 0 then
            index = index + 1;
            changeArr[index] = offsetTb;
        end
    end


    local index = 1;
    function addToast()

        if #changeArr < 1 then
            return;
        end

        local offsetTb = changeArr[index];

        -- print("offset:",AttributeTypeStr[offsetTb[1]],offsetTb[2])

        local label = TFLabelBMFont:create();
        local pos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x ,self.img_role:getPosition().y - 150))
        pos = self:convertToNodeSpace(pos);

        self.toastLabelList = self.toastLabelList or {}
        self.toastLabelList[offsetTb[1]] = label
        label:setPosition(pos);

        self:addChild(label,10);

        if offsetTb[2] > 0 then
            label:setFntFile("font/num_100.fnt")
            label:setColor(ccc3(  0, 255,   0));
            label:setText(AttributeTypeStr[offsetTb[1]] .. "+" .. covertToDisplayValue(offsetTb[1],offsetTb[2]));
        end

        if offsetTb[2] < 0 then
            label:setFntFile("font/num_99.fnt")
            label:setColor(ccc3(255,   0,   0));
            label:setText(AttributeTypeStr[offsetTb[1]] .. covertToDisplayValue(offsetTb[1],offsetTb[2]));
        end

        local toY = label:getPosition().y + 167;
        local toX = label:getPosition().x;
        
        label:setScale(0.5)
        label:setOpacity(0.1);
        local toastTween = {
              target = label,
              {
                duration = 7/24,
                x = toX,
                y = toY,
                scale = 1,
                alpha = 1,
              },
              {
                duration = 17/24,
                x = toX,
                y = toY+114,
                alpha = 0,
                onComplete = function()
                    if self.toastLabelList then
                        self.toastLabelList[offsetTb[1]] = nil
                    end
                    label:removeFromParent();
               end
              }
            }
 
        TFDirector:toTween(toastTween);
        index = index + 1;
    end

    function addToastCom()
        TFDirector:removeTimer(self.toastTimeId);
        self.toastTimeId = nil;
    end

    addToast();

    if self.toastTimeId ~= nil then
        TFDirector:removeTimer(self.toastTimeId);
        self.toastTimeId = nil;   
    end
    if  changeLength > 1 then
        self.toastTimeId = TFDirector:addTimer(334, changeLength -1, addToastCom, addToast);
    end
end

function RoleTransferLayer:removeEvents()
    self.super.removeEvents(self)
    
    TFDirector:removeTimer(self.toastTimeId);
    self.toastTimeId = nil;
    TFDirector:removeTimer(self.textTimeId);
    self.textTimeId = nil;
    TFDirector:removeTimer(self.levelTimeId);
    self.levelTimeId = nil;

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_TRANSFER_RESULT,self.RoleTransferpResultCallBack)
    TFDirector:removeMEGlobalListener(MainPlayer.SyceeChange,self.MoneyRefreshCallBack)
    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange,self.MoneyRefreshCallBack)

    -- self.ui:updateToFrame("power_change",100)
    if self.toastLabelList then
        for k,v in pairs(self.toastLabelList) do
            v:removeFromParent()
            v = nil
        end
        self.toastLabelList = nil
    end
    if self.power_effect then
        self.power_effect:setVisible(false)
    end
    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function RoleTransferLayer:HaveSelectFood()
    if self.dogfood:length() == 0 and self.catfood:length() == 0 then
        return false
    else
        return true
    end
end

function RoleTransferLayer.RefreshClickHandle(sender)
    local self = sender.logic
    if not self:HaveSelectFood() then
        -- toastMessage("没有选择任何传功材料，无需重置！");
        toastMessage(localizable.RoleTransferLayer_resetDesc)
    else
        self.dogfood = nil
        self:refreshUI()
    end
end

function RoleTransferLayer.TransferClickHandle(sender)
    local self = sender.logic

    if not MainPlayer:isEnoughCoin( self.costcoin , true) then
        return
    end

    local isHaveQualityJia = false;

    local dogfoodlist = {}
    local catfoodlist = {}
    local temp = 1
    for v in self.dogfood:iterator() do
        dogfoodlist[temp] = v
        temp = temp + 1
        local cardRole = CardRoleManager:getRoleByGmid( v )
        if cardRole == nil then
            print("该角色不存在 gmId =="..v)
        else
            local card = RoleData:objectByID(cardRole.id);
            if card.quality == QUALITY_JIA then
                isHaveQualityJia = true;
            end
        end
    end
    temp = 1
    for v in self.catfood:iterator() do
        local tbl = {
            v.id,
            v.num,
        }
        catfoodlist[temp] = tbl
        temp = temp + 1

        local item = ItemData:objectByID(v.id);
        -- kind == 3 排除甲级的蛇胆
        -- if item.quality == QUALITY_JIA and item.kind ~= 3 then
        if item.kind ~= 3 then
            if item.quality == QUALITY_JIA or item.quality == QUALITY_CHUANSHUO then
                 isHaveQualityJia = true
            end
        end
    end

    self.oldarr = {}
    --角色属性
    for i=1,EnumAttributeType.Max do
        self.oldarr[i] = self.cardRole:getTotalAttribute(i);
    end
    self.oldpower = self.cardRole:getPowerByFightType(self.fightType);
    self.oldlevel = self.cardRole.level;
    self.oldcurExp = self.cardRole.curExp;

    if isHaveQualityJia then
        CommonManager:showOperateSureLayer(
                function()
                    CardRoleManager:roleTransfer( self.cardRole.gmId , dogfoodlist , catfoodlist )
                end,
                nil,
                {
                msg = localizable.RoleTransferLayer_tishi --"吞噬的卡牌中，存在传说或宗师的侠魂或侠客，若继续传功则这些侠魂或侠客将转换为经验值。\n是否确定继续传功？"
                }
        )
    else
        CardRoleManager:roleTransfer( self.cardRole.gmId , dogfoodlist , catfoodlist )
    end
end

function RoleTransferLayer.XiaHunClickHandle(sender)
    local self = sender.logic
    self.selectType = 2
    self.tableView:reloadData()
    self.tableView:scrollToYTop(0);
    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun_btn.png")
    self.btn_xiake:setTextureNormal("ui_new/rolebreakthrough/xl_xiake1_btn.png")
end
function RoleTransferLayer.XiaKeClickHandle(sender)
    local self = sender.logic
    self.selectType = 1
    self.tableView:reloadData()
    self.tableView:scrollToYTop(0);
    self.btn_xiahun:setTextureNormal("ui_new/rolebreakthrough/xl_xiahun1_btn.png")
    self.btn_xiake:setTextureNormal("ui_new/rolebreakthrough/xl_xiake_btn.png")
end


function RoleTransferLayer.cellSizeForTable(table,idx)
    return 140,500
end

function RoleTransferLayer.tableCellAtIndex(table, idx)
    local numInCell = 3
    local cell = table:dequeueCell()
    local self = table.logic
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        for i=1,numInCell do
            local equip_panel = require('lua.logic.role.DogfoodIcon'):new()
            equip_panel.panel_empty = TFDirector:getChildByPath(equip_panel, 'panel_empty');
            equip_panel.panel_info = TFDirector:getChildByPath(equip_panel, 'panel_info');

            equip_panel:setPosition(ccp(125*(i-1) + 15,0))
            equip_panel:setLogic( self )
            cell:addChild(equip_panel)
            cell.equip_panel = cell.equip_panel or {}
            cell.equip_panel[i] = equip_panel
        end
    end
    if self.selectType == 1 then
        for i=1,numInCell do
            if (idx * numInCell + i) <= self.roleList:length() then
                local role = self.roleList:objectAt(idx * numInCell + i)
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(true);
                if self.dogfood:indexOf(role.gmId) == -1 then

                    cell.equip_panel[i]:setRoleGmId( role.gmId , 0)
                else
                    cell.equip_panel[i]:setRoleGmId( role.gmId , 1)
                end
            else
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(false);
            end
        end
    else
        for i=1,numInCell do
            if (idx * numInCell + i) <= self.soulList:length() then
                local soul = self.soulList:objectAt(idx * numInCell + i)
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(true);

                local catSoul = self:findInCatfood(soul.id)
                if catSoul then
                    cell.equip_panel[i]:setSoulId( soul.id ,catSoul.num)
                else
                    cell.equip_panel[i]:setSoulId( soul.id ,0)
                end
            else
                cell.equip_panel[i].panel_empty:setVisible(true);
                cell.equip_panel[i].panel_info:setVisible(false);
            end
        end
    end
    return cell
end

function RoleTransferLayer.numberOfCellsInTableView(table)
    local self = table.logic
    local num = 0
    if self.selectType == 1 then
        math.max(math.ceil(CardRoleManager.cardRoleList:length()/3)  ,3);
        num = math.max(math.ceil(self.roleList:length()/4),2);
    else
        num = math.max(math.ceil(self.soulList:length()/4),2);
    end
    return num
end



function RoleTransferLayer:initTableView()
    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(0)
    --tableView:setPosition(self.panel_list:getPosition())
    self.tableView = tableView
    self.tableView.logic = self
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleTransferLayer.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleTransferLayer.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleTransferLayer.numberOfCellsInTableView)
    Public:bindScrollFun(tableView);
    self.panel_list:addChild(tableView,2)
end


function RoleTransferLayer:addExp( gmid , exp)
    local maxExp = LevelData:getMaxRoleExp(self.templevel)
    self.tempexp = self.tempexp + exp
    while self.tempexp >= maxExp and maxExp > 0  do
        self.templevel = self.templevel + 1
        self.tempexp = self.tempexp - maxExp
        maxExp = LevelData:getMaxRoleExp(self.templevel)
    end
end

function RoleTransferLayer:delExp( gmid , exp)
    self.tempexp = self.tempexp - exp
    while self.tempexp < 0 do
        self.templevel = self.templevel - 1
        local newExp = LevelData:getMaxRoleExp(self.templevel)
        self.tempexp = self.tempexp + newExp
    end

end

function RoleTransferLayer:addDogFood( gmid , icon)

    local maxExp = LevelData:getMaxRoleExp(self.templevel)

    if  self.templevel > MainPlayer:getLevel() or maxExp == 0 or (self.templevel == MainPlayer:getLevel() and self.tempexp >= maxExp) then
        --toastMessage("等级到达上限");
        toastMessage(localizable.RoleTransferLayer_max_level)
        return;
    end

    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end

    local addExp = role.provide_exp + math.floor(role:getTotalRoleExp() * TransferRoleRate/100);

    self:addExp( gmid , addExp);

    self.costcoin = self.costcoin + TransferRoleCost

    icon:changeNum(1)

    self:setRoleExpInfo()

    self.dogfood:pushBack(gmid)

    local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
    pos = self:convertToNodeSpace(pos);
    print("RoleTransferLayer:addDogFood( gmid , icon)")
    self:showFly( role:getIconPath() , pos)

    maxExp = LevelData:getMaxRoleExp(self.templevel)
    if self.templevel > MainPlayer:getLevel() or maxExp == 0 then
        -- toastMessage("等级到达上限");
        toastMessage(localizable.RoleTransferLayer_max_level)
        return false;
    end
    return true;
end

function RoleTransferLayer:delDogFood( gmid , icon)
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        print("该角色不存在 gmId =="..gmid)
        return
    end

 
    local delExp = role.provide_exp + math.floor(role:getTotalRoleExp() * TransferRoleRate/100);

    self:delExp(gmid , delExp);

    icon:changeNum(0)
    -- self.costcoin = self.costcoin - TransferRoleCost

    -- 角色传功消耗铜币 =传功经验 * 0.1 --土匪广
    self.costcoin = (self.tempexp - self.cardRole.curExp) * 0.1

    self:setRoleExpInfo()
    self.dogfood:removeObject(gmid)
    local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
    pos = self:convertToNodeSpace(pos);

    self:showFlyBack( role:getIconPath() , pos)
end

function RoleTransferLayer:addCatFood( id , icon, num,isLongTouch)
    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local soulInfo = self:findInCatfood(id)
    if not soulInfo then
        soulInfo = {}
        soulInfo.id  = id
        soulInfo.num = 0
        self.catfood:pushBack(soulInfo)
    end

    local isConLongTouch = true;
    for i=1,num do
        local maxExp = LevelData:getMaxRoleExp(self.templevel)

        if  self.templevel > MainPlayer:getLevel() or maxExp == 0 or (self.templevel == MainPlayer:getLevel() and self.tempexp >= maxExp) then
            -- toastMessage("等级到达上限");
            toastMessage(localizable.RoleTransferLayer_max_level)
            if i == 1 then
                return false;
            end
            isConLongTouch = false;
            break;
        end

        local maxExp = LevelData:getMaxRoleExp(self.templevel)
        local addExp = item.provide_exp
        self:addExp( gmid , addExp);

        self.costcoin = self.costcoin + TransferSoulCost

        soulInfo.num = soulInfo.num + 1
    end

    self:setRoleExpInfo()
    icon:changeNum(soulInfo.num)

    if not isLongTouch then
        local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
        pos = self:convertToNodeSpace(pos);
        if item.kind == 3 then
            self:showFly( "icon/roleicon/" .. item.display .. ".png" , pos)
        else
            local role = RoleData:objectByID(item.usable)
            if role == nil then
                print("无法找到角色信息 id ==".. item.usable)
                return
            end
            self:showFly( role:getIconPath() , pos)
        end
    end
    PlayerGuideManager:showNextGuideStep()
    return isConLongTouch;
end

function RoleTransferLayer:showAddCatFoodFly( id , icon)

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
    pos = self:convertToNodeSpace(pos);
    if item.kind == 3 then
        self:showFly( "icon/roleicon/" .. item.display .. ".png" , pos)
    else
        local role = RoleData:objectByID(item.usable)
        if role == nil then
            print("无法找到角色信息 id ==".. item.usable)
            return
        end
        self:showFly( role:getIconPath() , pos)
    end
end


function RoleTransferLayer:delCatFood( id , icon,isLongTouch)

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local delExp = item.provide_exp
    self:delExp(gmid , delExp);


    local soulInfo = self:findInCatfood(id)
    soulInfo.num = soulInfo.num - 1
    icon:changeNum(soulInfo.num)

    self.costcoin = self.costcoin - TransferSoulCost
    
    self:setRoleExpInfo()

    if soulInfo.num <= 0 then
        self.catfood:removeObject(soulInfo)
    end

    if not isLongTouch then
        local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
        pos = self:convertToNodeSpace(pos);

        if item.kind == 3 then
            self:showFlyBack( "icon/roleicon/" .. item.display .. ".png" , pos)
        else
            local role = RoleData:objectByID(item.usable)
            if role == nil then
                print("无法找到角色信息 id ==".. item.usable)
                return
            end
            self:showFlyBack( role:getIconPath() , pos)
        end
    end
end
function RoleTransferLayer:showDelCatFoodFly( id , icon)

    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end
    
    local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
    pos = self:convertToNodeSpace(pos);

    if item.kind == 3 then
        self:showFlyBack( "icon/roleicon/" .. item.display .. ".png" , pos)
    else
        local role = RoleData:objectByID(item.usable)
        if role == nil then
            print("无法找到角色信息 id ==".. item.usable)
            return
        end
        self:showFlyBack( role:getIconPath() , pos)
    end
end
function RoleTransferLayer:findInCatfood( id )
    for v in self.catfood:iterator() do
        if v.id == id then
            return v
        end
    end
end

function RoleTransferLayer:showFly( texture , pos)
    -- print(texture,pos)
    -- local flyPic = TFImage:create()
    -- flyPic:setTexture(texture)
    -- flyPic:setScale(0.5)
    -- flyPic:setAnchorPoint(CCPointMake(0,0))
    -- flyPic:setPosition(pos)

    -- if self.flyPic then
    --     self.flyPic:removeFromParentAndCleanup(true)
    --     self.flyPic= nil
    -- end
    
    -- if self.moveEffect then
    --     self.moveEffect:removeFromParentAndCleanup(true)
    --     self.moveEffect= nil
    -- end

    -- if self.endEffect then
    --     self.endEffect:removeFromParentAndCleanup(true)
    --     self.endEffect= nil
    -- end



    self:showFlyBegin(pos)
    if 1 then
        return
    end

    -- if not self.flyPic then
    --     play_chuangonghunpoyidong()

    --     local resPath = "effect/role_transfer_begin.xml"
    --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --     local flyPic = TFArmature:create("role_transfer_begin_anim")

    --     flyPic:setAnimationFps(GameConfig.ANIM_FPS)
    --     flyPic:setPosition(ccp(pos))

    --     self.effectPos = pos
    --     self:addChild(flyPic,100)
        
    --     flyPic:addMEListener(TFARMATURE_COMPLETE,function()
    --         self.flyPic:removeFromParentAndCleanup(true)
    --         self.flyPic= nil
    --         -- 开始移动


    --     end)

    --     flyPic:playByIndex(0, -1, -1, 1)
    --     self.flyPic = flyPic;

        
    --     -- local topos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x - 100,self.img_role:getPosition().y - self.img_role:getContentSize().height/2  - 50))
    --     -- topos = self:convertToNodeSpace(topos);

    --     -- local tox = topos.x
    --     -- local toy = topos.y
    --     -- local tween = 
    --     -- {
    --     --     target = flyPic,
    --     --     {
    --     --         ease = {type=TFEaseType.EASE_IN_OUT, rate=9},
    --     --         duration = 0.6,
    --     --         x = tox,
    --     --         y = toy,
    --     --         onComplete = function ()
             
    --     --             local resPath = "effect/role_transfer_end.xml"
    --     --             TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --     --             local endPic = TFArmature:create("role_transfer_end_anim")

    --     --             endPic:setAnimationFps(GameConfig.ANIM_FPS)
    --     --             endPic:setPosition(ccp(tox,toy))

    --     --             self:addChild(endPic,100)
                    
    --     --             endPic:addMEListener(TFARMATURE_COMPLETE,function()
    --     --                 endPic:removeMEListener(TFARMATURE_COMPLETE) 
    --     --                 endPic:removeFromParent()
    --     --             end)
    --     --             endPic:playByIndex(0, -1, -1, 0)

    --     --             flyPic:removeFromParentAndCleanup(true)
    --     --             self.flyPic = nil  
    --     --         end,
    --     --     },
    --     -- }
    --     -- TFDirector:toTween(tween)
    -- end
end

function RoleTransferLayer:showFlyBack( texture , pos)
    if 1 then
        return
    end

    -- if not self.flyPic then

    --     -- local flyPic = TFImage:create()
    --     -- flyPic:setTexture(texture)
    --     -- flyPic:setScale(0.5)
    --     -- flyPic:setAnchorPoint(CCPointMake(0,0))
    --     -- flyPic:setPosition(ccp(self.img_role:getPosition().x - flyPic:getContentSize().width/2,self.img_role:getPosition().y - flyPic:getContentSize().height/2))
    --     -- self:addChild(flyPic)
    --     -- flyPic:setZOrder(100)
    --     play_chuangonghunpoyidong()

    --     local frompos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x - 100,self.img_role:getPosition().y - self.img_role:getContentSize().height/2  - 50))
    --     frompos = self:convertToNodeSpace(frompos);

    --     local fromx = frompos.x
    --     local fromy = frompos.y

    --     local resPath = "effect/role_transfer_begin.xml"
    --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --     local flyPic = TFArmature:create("role_transfer_begin_anim")

    --     flyPic:setAnimationFps(GameConfig.ANIM_FPS)
    --     flyPic:setPosition(ccp(fromx,fromy))

    --     self:addChild(flyPic,100)
    --     flyPic:playByIndex(0, -1, -1, 1)
    --     self.flyPic = flyPic;  
    --     -- flyPic:addMEListener(TFARMATURE_COMPLETE,function()
    --     --     flyPic:removeMEListener(TFARMATURE_COMPLETE) 
    --     --     flyPic:removeFromParent()
    --     -- end)
        
    --     local tween = 
    --     {
    --         target = flyPic,
    --         {
    --             ease = {type=TFEaseType.EASE_IN_OUT, rate=8},
    --             duration = 0.4,
    --             x = pos.x,
    --             y = pos.y,
    --             onComplete = function ()
    --                 flyPic:removeFromParentAndCleanup(true)
    --                 self.flyPic = nil           
    --             end,
    --         },
    --     }
    --     TFDirector:toTween(tween)
    -- end
end

function RoleTransferLayer:showLongClickAddCatFoodFly( id , icon,_speed)
    if self.isFly == true then
        return
    end
    self.isFly = true
    local speed = 1 or _speed
    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local pos = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x + icon:getSize().width/2 + 20,icon:getPosition().y + icon:getSize().height/2 + 10))
    pos = self:convertToNodeSpace(pos);
    self:showLongClickFlyBegin(pos,speed)
end

function RoleTransferLayer:showLongClickFlyBegin(pos,speed)

    play_chuangonghunpoyidong()

    -- local resPath = "effect/role_transfer_begin.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local flyPic = TFArmature:create("role_transfer_begin_anim")

    -- flyPic:setAnimationFps(GameConfig.ANIM_FPS*speed)
    -- flyPic:setPosition(ccp(pos.x + 21, pos.y- 100))

    -- self.effectPos = pos
    -- self:addChild(flyPic,100)
    
    -- flyPic:addMEListener(TFARMATURE_COMPLETE,function()
    --     self.isFly = false
    --     flyPic:removeFromParentAndCleanup(true)
    --     -- self:showFlyMove(pos)
    -- end)
    -- local temp = 0
    -- flyPic:addMEListener(TFARMATURE_UPDATE,function()
    --     temp = temp + 1
    --     if temp == 2 then
    --         self:showFlyMove(pos)
    --     end
    -- end)

    -- flyPic:playByIndex(0, -1, -1, 0)

    local effectID = "role_transfer_begin"
    ModelManager:addResourceFromFile(2, effectID, 1)
    local effect = ModelManager:createResource(2, effectID)

    effect:setPosition(ccp(pos.x - 23, pos.y))
    effect:setScale(1.2)
    self:addChild(effect,100)
    self.effectPos = pos

    ModelManager:addListener(effect, "ANIMATION_COMPLETE", function() 
        self.isFly = false
        effect:removeFromParentAndCleanup(true)
    end)

    local temp = 0
    effect:addMEListener(TFSKELETON_UPDATE, function ()
        temp = temp + 1
        if temp == 2 then
            self:showFlyMove(pos)
        end
    end)

    ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
end

function RoleTransferLayer:showFlyBegin(pos)
    play_chuangonghunpoyidong()

    -- local resPath = "effect/role_transfer_begin.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local flyPic = TFArmature:create("role_transfer_begin_anim")

    -- flyPic:setAnimationFps(GameConfig.ANIM_FPS)
    -- flyPic:setPosition(ccp(pos.x + 21, pos.y- 100))

    -- self.effectPos = pos
    -- self:addChild(flyPic,100)
    
    -- flyPic:addMEListener(TFARMATURE_COMPLETE,function()
    --     flyPic:removeFromParentAndCleanup(true)
    --     -- self:showFlyMove(pos)
    -- end)
    -- local temp = 0
    -- flyPic:addMEListener(TFARMATURE_UPDATE,function()
    --     temp = temp + 1
    --     if temp == 2 then
    --         self:showFlyMove(pos)
    --     end
    -- end)

    -- flyPic:playByIndex(0, -1, -1, 0)

    local effectID = "role_transfer_begin"
    ModelManager:addResourceFromFile(2, effectID, 1)
    local effect = ModelManager:createResource(2, effectID)

    effect:setPosition(ccp(pos.x - 23, pos.y))
    effect:setScale(1.2)
    self:addChild(effect,100)
    self.effectPos = pos

    ModelManager:addListener(effect, "ANIMATION_COMPLETE", function() 
        self.isFly = false
        effect:removeFromParentAndCleanup(true)
    end)

    local temp = 0
    effect:addMEListener(TFSKELETON_UPDATE, function ()
        temp = temp + 1
        if temp == 2 then
            self:showFlyMove(pos)
        end
    end)

    ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
end

function RoleTransferLayer:showFlyMove(pos)
    play_chuangonghunpoyidong()

    -- local resPath = "effect/role_transfer_move.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local moveEffect = TFArmature:create("role_transfer_move_anim")

    -- moveEffect:setAnimationFps(GameConfig.ANIM_FPS)
    -- moveEffect:setPosition(ccp(pos.x - 20, pos.y))

    -- self:addChild(moveEffect,100)

    -- moveEffect:playByIndex(0, -1, -1, 1)

    local effectID = "role_transfer_move"
    ModelManager:addResourceFromFile(2, effectID, 1)
    local moveEffect = ModelManager:createResource(2, effectID)

    moveEffect:setPosition(ccp(pos.x - 20, pos.y))
    self:addChild(moveEffect,100)

    ModelManager:playWithNameAndIndex(moveEffect, "", 0, 0, -1, -1)

    if not moveEffect then
        self:showFlyEnd()
        return
    end

    local topos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x - 120,self.img_role:getPosition().y - self.img_role:getContentSize().height/2  - 325))
    topos = self:convertToNodeSpace(topos);

    local tox = topos.x
    local toy = topos.y
    local tween = 
    {
        target = moveEffect,
        {
            ease = {type=TFEaseType.EASE_IN_OUT, rate=9},
            duration = 0.6,
            x = tox,
            y = toy + 60,
            onComplete = function ()
                local effectID = "role_transfer_end"
                ModelManager:addResourceFromFile(2, effectID, 1)
                local endEffect = ModelManager:createResource(2, effectID)

                endEffect:setPosition(ccp(100, 43))
                self.panel_content:addChild(endEffect, 100)

                ModelManager:addListener(endEffect, "ANIMATION_COMPLETE", function() 
                    ModelManager:removeListener(endEffect, "ANIMATION_COMPLETE")
                    endEffect:removeFromParent()
                end)

                ModelManager:playWithNameAndIndex(endEffect, "", 0, 0, -1, -1)

                -- local resPath = "effect/role_transfer_end.xml"
                -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                -- local endEffect = TFArmature:create("role_transfer_end_anim")

                -- endEffect:setAnimationFps(GameConfig.ANIM_FPS)
                -- -- endEffect:setPosition(ccp(tox, toy))
                -- endEffect:setPosition(ccp(520, 318))
                -- -- print("x = ", tox)
                -- -- print("y = ", toy)
                -- -- print("self.effectPos.x = ", self.effectPos.x)
                -- -- print("self.effectPos.y = ", self.effectPos.y)

                -- self:addChild(endEffect,100)
                
                -- endEffect:addMEListener(TFARMATURE_COMPLETE,function()
                --     endEffect:removeMEListener(TFARMATURE_COMPLETE) 
                --     endEffect:removeFromParent()
                -- end)
                -- endEffect:playByIndex(0, -1, -1, 0)


                moveEffect:removeFromParentAndCleanup(true)
            end,
        },
    }
    TFDirector:toTween(tween)

end

function RoleTransferLayer:showFlyEnd()
    -- body
end


function RoleTransferLayer:setRoleList(cardRoleList)
    self.roleList = cardRoleList
end

function RoleTransferLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex - 1);

    -- TFDirector:dispatchGlobalEventWith("MoveRoleListToLeft")
end

function RoleTransferLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex + 1);


    -- TFDirector:dispatchGlobalEventWith("MoveRoleListToRight")
end

function RoleTransferLayer:drawRoleList()
    local pageView = TPageView:create()

    self.pageView = pageView

    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_rolelist:getContentSize())
    pageView:setAnchorPoint(self.panel_rolelist:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index)
    end 
    pageView:setAddFunc(itemAdd)

    self.panel_rolelist:addChild(pageView,2)
end


function RoleTransferLayer:addPage(pageIndex) 
    local page = TFPanel:create();
    page:setSize(self.panel_list:getContentSize())

    local cardRole = self.roleMainList:objectAt(pageIndex)

    local armatureID = cardRole.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(320/2, 500/2 - 140))
    model:setScale(0.9)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    page:addChild(model)
  
    self.pageList[cardRole.id] = page

    return page;
end

function RoleTransferLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex()
    TFDirector:dispatchGlobalEventWith("MoveRoleListToLeft",{pageIndex = pageIndex-self.selectIndex})

    self:showInfoForPage(pageIndex);

end

function RoleTransferLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex;

    -- self:refreshRoleInfo()
    local pageCount = self.roleMainList:length()

    self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,1000))
    self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,1000))

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,self.positiony))
    end 

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,self.positiony))
    end


    self:drawRole()

end

function RoleTransferLayer:refreshRoleList(pageIndex)
    self.pageView:_removeAllPages();

    self.pageView:setMaxLength(self.roleMainList:length())

    self.pageList        = {};

    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);      
end

function RoleTransferLayer:setRoleList(roleList)
    self.roleMainList = roleList
end

function RoleTransferLayer:drawRole()
    self.cardRole   = self.roleMainList:objectAt(self.selectIndex);
    self.roleGmId   = self.cardRole.gmId;

    -- self.cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )

    local function cmpFun( cardRole1, cardRole2 )
        if cardRole1.quality <= cardRole2.quality then
            if cardRole1:getpower() <= cardRole2:getpower() then
                return true
            end
            return true
        else
            return false
        end
    end

    local function soulcmp( soul1, soul2 )
        if soul1.kind == 3 and soul2.kind ~= 3 then
            return true;
        elseif soul1.kind ~= 3 and  soul2.kind == 3 then
            return false;
        elseif soul1.kind == 3 and  soul2.kind == 3 then
            if soul1.quality <= soul2.quality then
                return true;
            else
                return false;
            end
        elseif soul1.quality <= soul2.quality then
            if soul1.id <= soul2.id then
                return true
            end
            return true
        else
            return false
        end
    end
    self.roleList = CardRoleManager:getOtherNotUsed(self.roleGmId)
    self.roleList:sort(cmpFun)
    self.soulList = BagManager:getItemByType(EnumGameItemType.Soul)
    for v in self.soulList:iterator() do
        if v.type == EnumGameItemType.Soul and v.kind == 2 then
            self.soulList:removeObject(v)
        end
    end
    for v in self.roleList:iterator() do
        if v:getIsMainPlayer() then
            self.roleList:removeObject(v)
        end
    end

    --却掉自己的侠魂
    local selfSoul = BagManager:getItemById(self.cardRole.soul_card_id );
    if selfSoul then
        self.soulList:removeObject(selfSoul);
    end

    self.soulList:sort(soulcmp)

    self.dogfood = TFArray:new()
    self.catfood = TFArray:new()

    self.costcoin = 0


    self.tableView:reloadData();
    self.tableView:scrollToYTop(0);


    self.templevel = self.cardRole.level    
    self.tempexp   = self.cardRole.curExp
    print("self.templevel , self.tempexp",self.templevel,self.tempexp,self.cardRole:getBigImagePath())
    -- self.img_role:setTexture(self.cardRole:getBigImagePath())
    self.txt_name:setText(self.cardRole.name)
    self.img_diwen1:setTexture(GetRoleNameBgByQuality(self.cardRole.quality))
    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality))
    self.txt_level:setText(self.cardRole.level .. "d")
    self.txt_power:setText(self.cardRole:getPowerByFightType(self.fightType))
    self.img_quality_icon:setTexture(GetFontByQuality( self.cardRole.quality ))

    self:setRoleExpInfo()

    self.img_role:setVisible(false)
end

return RoleTransferLayer
