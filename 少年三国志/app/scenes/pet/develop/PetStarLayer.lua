local PetStarLayer = class("PetStarLayer",UFCCSNormalLayer)
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local PetBagConst = require "app.const.PetBagConst"
require("app.cfg.pet_star_info")
require("app.cfg.pet_info")
require("app.cfg.skill_info")
require("app.cfg.fragment_info")

local prop_id = 204

function PetStarLayer:create(container)
    local layer = PetStarLayer.new("ui_layout/petbag_Star.json",container) 
    return layer
end

function PetStarLayer:ctor(json,container)
    self.super.ctor(self,json)
    self._playing = false
    self._container = container
    self._pet = container._pet
    self._pet_info = pet_info.get(self._pet.base_id)
    self._maxStar = 5   -- 星级上线
    self._effect = nil
    self._attrNum = 5
    for i = 1 , self._attrNum do
        self:getLabelByName("Label_left_type" .. i):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_right_type" .. i):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_left_type" .. i):setText(G_lang:get("LANG_PET_ATTR"..i))
        self:getLabelByName("Label_right_type" .. i):setText(G_lang:get("LANG_PET_ATTR"..i))
    end

    self:getLabelByName("Label_left_skill"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_right_skill"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_left_title"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_right_title"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_middle_type"):setText(G_lang:get("LANG_PET_LEVEL_TIP"))

    -- 点击升星
    self:registerBtnClickEvent("Button_shengxing", function()
        local funLevelConst = require("app.const.FunctionLevelConst")
        if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.PET_STAR) then
            return
        end
        -- 判断碎片、银两数量和宠物等级是否满足需求，不满足则返回错误提示并终止操作。
        if self._playing then return end
        local cost = pet_star_info.get(self._pet_info.star , 
            self._pet_info.quality)
        if G_Me.userData.money < cost.cost_money then 
            -- 银两不足提示
            G_MovingTip:showMovingTip(G_lang:get("LANG_PET_NEED_MONEY"))
            return
        elseif G_Me.bagData:getFragmentNumById( self._pet_info.relife_id )
            < cost.cost_fragment then 
            -- 碎片不足提示
            G_MovingTip:showMovingTip(G_lang:get("LANG_PET_NEED_FRAGMENT"))
            return
        elseif G_Me.bagData:getPropCount( prop_id )
            < cost.cost_size then 
            -- 道具不足提示
            G_MovingTip:showMovingTip(G_lang:get("LANG_PET_NEED_STONE"))
            return
        elseif self._pet.level < cost.level_ban then
            G_MovingTip:showMovingTip(G_lang:get("LANG_PET_NEED_LEVEL"))
            -- 宠物等级不足提示
            return
        end

        -- local funLevelConst = require("app.const.FunctionLevelConst")
        -- if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_TRAINING) then
        
            G_HandlersManager.petHandler:sendPetUpStar(self._pet.id)
        -- end
    end)

    -- 宠物碎片
    self:registerBtnClickEvent("Button_board1", function()
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, self._pet_info.relife_id,
            GlobalFunc.sceneToPack("app.scenes.pet.develop.PetDevelopeScene", {self._pet, PetBagConst.DevelopType.STAR})) 
    end)
    -- 道具
    self:registerBtnClickEvent("Button_board2", function()
        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, prop_id,
            GlobalFunc.sceneToPack("app.scenes.pet.develop.PetDevelopeScene", {self._pet, PetBagConst.DevelopType.STAR}))
    end)
end

function PetStarLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_UPSTAR, self._recvUpstar ,self)
end

function PetStarLayer:enter()
    self._playing = false
    -- 动画效果Panel_left
    G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_left")} ,
        true, 0.2, 2, 20)
    G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_right")} ,
        false, 0.2, 2, 20)
    G_GlobalFunc.flyIntoScreenTB({self:getWidgetByName("Panel_bottom_0")}, 
        false, 0.2, 2, 20)
    self:updateView()
end

-- 升星后刷新显示数值
function PetStarLayer:updateView()
    __Log("PetStarLayer:updateView()")

    self._pet = G_Me.bagData.petData:getPetById(self._pet.id)
    self._pet_info = pet_info.get(self._pet.base_id)
    for index = 1 , self._maxStar do 
        self:getImageViewByName("Image_left_star"..index):loadTexture(self._pet_info.star >= index and "ui/yangcheng/star_juexing.png" or "ui/yangcheng/star_juexing_kong.png")
        self:getImageViewByName("Image_right_star"..index):loadTexture(self._pet_info.star + 1 >= index and "ui/yangcheng/star_juexing.png" or "ui/yangcheng/star_juexing_kong.png")
    end

    -- 升星需要的消耗
    local cost = pet_star_info.get(self._pet_info.star , self._pet_info.quality)
    -- 当前碎片和需要的碎片
    self:getLabelByName("Label_num"):setText(
        tostring(G_Me.bagData:getFragmentNumById( self._pet_info.relife_id )) .. 
        "/"..tostring(cost.cost_fragment))
    self:getLabelByName("Label_num"):setColor( (cost.cost_fragment > G_Me.bagData:getFragmentNumById( self._pet_info.relife_id )) 
        and Colors.titleRed or Colors.inActiveSkill)

    -- 当前道具和需要的道具
    self:getLabelByName("Label_num2"):setText(
        tostring(G_Me.bagData:getPropCount( prop_id )) .. 
        "/"..tostring(cost.cost_size))
    self:getLabelByName("Label_num2"):setColor( (cost.cost_size > G_Me.bagData:getPropCount( prop_id )) and Colors.titleRed or Colors.inActiveSkill)

    -- 升星等级 self._pet.level < cost.level_ban  等级限制为0就不要显示
    self:getLabelByName("Label_middle_value"):setText(tostring(self._pet.level) .. "/"..tostring(cost.level_ban))
    if cost.level_ban > self._pet.level then
      self:getLabelByName("Label_middle_value"):setColor(Colors.lightColors.TIPS_01) 
    else
    self:getLabelByName("Label_middle_value"):setColor(Colors.lightColors.DESCRIPTION) 
    end
    -- if cost.level_ban == 0 then 
        self:getLabelByName("Label_middle_value"):setVisible( cost.level_ban > 0) 
        self:getLabelByName("Label_middle_type"):setVisible(cost.level_ban > 0)
    -- end

    -- 银两
    self:getLabelByName("Label_money"):setColor((cost.cost_money > G_Me.userData.money) and Colors.titleRed or Colors.inActiveSkill)
    self:getLabelByName("Label_money"):setText(tostring(cost.cost_money))
    
    -- nAttack, nHp, nPhyDef, nMagDef
    self._leftValue = {G_Me.bagData.petData:getBaseAttr(self._pet.level, self._pet.base_id,self._pet.addition_lvl)}
    -- 注意边界值处理  不能再升星的情况 
    self._rightValue = {G_Me.bagData.petData:getBaseAttr(self._pet.level , self:_isMaxStar() and self._pet.base_id or self._pet_info.next_star_id,self._pet.addition_lvl)}
    table.insert(self._leftValue,#self._leftValue+1,self._pet_info.harm_add)
    table.insert(self._rightValue,#self._rightValue+1,self:_isMaxStar() and self._pet_info.harm_add or pet_info.get(self._pet_info.next_star_id).harm_add)
    -- 升星前后的数值
    for index = 1 , self._attrNum do 
        if index == self._attrNum then 
            self:getLabelByName("Label_left_value"..tostring(index)):setText(tostring(self._leftValue[index]/10 .. "%"))
            self:getLabelByName("Label_right_value"..tostring(index)):setText(tostring(self._rightValue[index]/10 .. "%"))
        else 
            self:getLabelByName("Label_left_value"..tostring(index)):setText(tostring(self._leftValue[index]))
            self:getLabelByName("Label_right_value"..tostring(index)):setText(tostring(self._rightValue[index]))
        end
        self:getLabelByName("Label_left_value" .. index):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_right_value" .. index):createStroke(Colors.strokeBrown, 1)
    end
    -- 技能名字
    self:getLabelByName("Label_left_skill"):setText(tostring(skill_info.get(self._pet_info.active_skill_id).name))
    self:getLabelByName("Label_right_skill"):setText(self:_isMaxStar() and
        tostring(skill_info.get(self._pet_info.active_skill_id).name) or
        -- 升星后的技能名字
        tostring(skill_info.get( pet_info.get(self._pet_info.next_star_id).active_skill_id ).name) )

    -- 战宠碎片icon
    local fragment = fragment_info.get( self._pet_info.relife_id )
    self:getImageViewByName("Image_icon1"):loadTexture(G_Path.getPetIcon(fragment.res_id),UI_TEX_TYPE_LOCAL)
    self:getButtonByName("Button_board1"):loadTextureNormal(G_Path.getEquipColorImage(fragment.quality,G_Goods.TYPE_FRAGMENT))
    self:getButtonByName("Button_board1"):loadTexturePressed(G_Path.getEquipColorImage(fragment.quality,G_Goods.TYPE_FRAGMENT))
    self:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(self._pet_info.quality))
    -- 战宠名字  超过3个字换行处理
    local tempName = GlobalFunc.autoNewLine(fragment.name,4)
    CommonFunc._updateLabel(self, "Label_pet_name", {text=tempName , 
        color=Colors.qualityColors[fragment.quality], stroke=Colors.strokeBrown})

    local itemInfo = item_info.get(prop_id)

    -- 道具icon
    self:getImageViewByName("Image_icon2"):loadTexture(G_Path.getItemIcon(itemInfo.res_id),UI_TEX_TYPE_LOCAL)
    self:getButtonByName("Button_board2"):loadTextureNormal(G_Path.getEquipColorImage(itemInfo.quality,G_Goods.TYPE_ITEM))
    self:getButtonByName("Button_board2"):loadTexturePressed(G_Path.getEquipColorImage(itemInfo.quality,G_Goods.TYPE_ITEM))

    -- 消耗道具名字
    tempName = itemInfo.name
    -- if tempName and #tempName > 9 then
    --     tempName = string.sub(tempName, 1, 9) .. "\n" .. string.sub(tempName, 10, #tempName)
    -- end
    CommonFunc._updateLabel(self, "Label_pet_name2", {text=tempName, 
        color=Colors.qualityColors[itemInfo.quality], stroke=Colors.strokeBrown})


    -- 流光特效  升级后状态可能变化
    if G_Me.userData.money >= cost.cost_money and self._pet.level >= cost.level_ban
            and G_Me.bagData:getFragmentNumById( self._pet_info.relife_id ) >= cost.cost_fragment 
            and G_Me.bagData:getPropCount( prop_id ) >= cost.cost_size
            then
        if not self._effect or not self._effect:isPlaying() then   
            local EffectNode = require "app.common.effects.EffectNode"
            self._effect = EffectNode.new("effect_around2")
            self._effect:setScale(1.5)
            self._effect:setPositionXY(0, -4)
            self:getButtonByName("Button_shengxing"):addNode(self._effect)
            self._effect:play()
        end 
    elseif self._effect then  
        self._effect:removeFromParent()
        self._effect = nil
    end
    self:_handleMaxStar()
end

-- 是否达到最大星级
function PetStarLayer:_isMaxStar()
    return self._pet_info.next_star_id == 0
end

-- 升星满级处理
function PetStarLayer:_handleMaxStar()
    if self:_isMaxStar() then 
        self:getImageViewByName("Image_choose"):setVisible(false)
        self:getPanelByName("Panel_up"):setVisible(false)
        self:getPanelByName("Panel_right"):setVisible(false)
        self:getLabelByName("Label_middle_type"):setVisible(false)
        self:getLabelByName("Label_middle_value"):setVisible(false)
        self:getLabelByName("Label_max"):setText(G_lang:get("LANG_PET_MAX_LEVEL"))
        self:getLabelByName("Label_max"):setVisible(true)
    end

end

-- 获取升星反馈
function PetStarLayer:_recvUpstar(decodeBuffer)
    -- dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        self:runEffect()
    end
end

-- 升星特效
function PetStarLayer:runEffect()
    self._playing = true
    self._container:getEffectNode():removeAllNodes()

    self._container:addPetYing(true)

    local EffectNode = require "app.common.effects.EffectNode"
    local effect = EffectNode.new("effect_shoulian_shengxin", function(event, frameIndex, _effect)
        if event == "finish" then
            _effect:removeFromParent()
            self._container:addPetYing(false)
            -- 第二个特效
            self._lightEffect = EffectNode.new("effect_circle_light", function(event, frameIndex , _effect)
                if event == "finish" then
                    _effect:removeFromParent()  
                    require("app.scenes.pet.develop.PetStarResult").create(self._pet,self._container,self)
                end
            end)
            uf_notifyLayer:getModelNode():addChild(self._lightEffect)
            -- 白光特效从中间开始扩散
            self._lightEffect:setPositionXY(display.cx,display.cy)
            self._lightEffect:play()
        end
    end)
    self._container:getEffectNode():addNode(effect)
    self._container:getPanelByName("Panel_top"):setZOrder(0)
    effect:setPositionXY(15,173)
    effect:play()
end

-- clean
function PetStarLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function PetStarLayer:adapterLayer()
    local maxHeight = display.height
    self:getPanelByName("Panel_middle_0"):setPositionXY(0,maxHeight*2/3-250)
    self:getPanelByName("Panel_bottom_0"):setPositionXY(0,0)
end


function PetStarLayer:_flyAttr( deltaAttr,finish_callback)
    G_flyAttribute._clearFlyAttributes()
    local info = pet_info.get(self._pet.base_id)
    local levelTxt = G_lang:get("LANG_PET_STAR_SUCC", {pet=info.name,level=self._pet_info.star + 1})
    G_flyAttribute.addNormalText(levelTxt,Colors.uiColors.ORANGE, nil)

    --属性加成
    for k, v in pairs(deltaAttr) do 
        G_flyAttribute.addAttriChange(v.title, v.value, self:getLabelByName("Label_left_value"..k))
    end
    G_flyAttribute.play(function ( ... )
        if finish_callback then
            finish_callback()
        end
    end)
end

-- 开始属性提升特效
function PetStarLayer:_starUpAnime()
    local attrs = {}
    for i = 1 , 4 do 
        table.insert(attrs,#attrs+1,{title=G_lang:get("LANG_PET_ATTR"..i),value=self._rightValue[i]-self._leftValue[i]})
    end
    table.insert(attrs,#attrs+1,{title=G_lang:get("LANG_PET_ATTR"..self._attrNum),value=(self._rightValue[self._attrNum]-self._leftValue[self._attrNum])/10 .. "%"})
    self:_flyAttr(attrs,function ( ... )
        self._playing = false
        self:updateView()
    end)
end

return PetStarLayer
