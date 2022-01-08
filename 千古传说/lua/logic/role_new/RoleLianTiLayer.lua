--[[
******炼体界面*******

    -- by Chikui Peng
    -- 2016/4/28
]]
local RoleLianTiLayer = class("RoleLianTiLayer", BaseLayer)

function RoleLianTiLayer:ctor(data)
    self.super.ctor(self,data)
    self.roleId = data
    self.cardRole = CardRoleManager:getRoleById(self.roleId)
    self:init("lua.uiconfig_mango_new.role_new.LianTiLayer")
end

function RoleLianTiLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_lianti_up = TFDirector:getChildByPath(ui, 'btn_lianti_up')
    self.img_lianti_h = TFDirector:getChildByPath(ui, 'img_lianti_h')
    self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')
    self.panel_res = TFDirector:getChildByPath(ui, 'Panel_LianTiLayer')
    self.panel_details_1 = TFDirector:getChildByPath(ui, 'panel_details_1')
    self.Node_Point = {}
    for i=1,5 do
        self.Node_Point[i] = {}
        local node = TFDirector:getChildByPath(ui, 'btn_point'..i)
        self.Node_Point[i].baseNode = node
        local img_unlock = TFDirector:getChildByPath(node, 'img_unlock')
        self.Node_Point[i].img_unlock = img_unlock
        self.Node_Point[i].img_icon = TFDirector:getChildByPath(img_unlock, 'img_icon')
        self.Node_Point[i].txt_level = TFDirector:getChildByPath(img_unlock, 'txt_level')
        self.Node_Point[i].txt_Info = TFDirector:getChildByPath(img_unlock, 'txt_Info')
        self.Node_Point[i].img_lock = TFDirector:getChildByPath(node, 'btn_lock_h')
    end
    self.Node_Attri = {}
    for i=1,5 do
        self.Node_Attri[i] = {}
        local txt_name = TFDirector:getChildByPath(ui, 'txt_attri_'..i)
        self.Node_Attri[i].txt_name = txt_name
        self.Node_Attri[i].txt_num = TFDirector:getChildByPath(txt_name, 'txt_number')
    end
    self.Node_Extra_Attri = {}
    local txt_node = TFDirector:getChildByPath(ui, 'txt_jibenshuxing')
    self.Node_Extra_Attri[1] = TFDirector:getChildByPath(txt_node, 'txt_number')
    txt_node = TFDirector:getChildByPath(ui, 'txt_chongxue')
    self.Node_Extra_Attri[2] = TFDirector:getChildByPath(txt_node, 'txt_number')
    txt_node = TFDirector:getChildByPath(ui, 'txt_tupo')
    self.Node_Extra_Attri[3] = TFDirector:getChildByPath(txt_node, 'txt_number')
end

function RoleLianTiLayer:removeUI()
    self.super.removeUI(self)
end

function RoleLianTiLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100)
    self.btn_lianti_up:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(self.OnLianTiClick,self)))
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(self.OnRuleClick,self)))

    for i=1,5 do
        self.Node_Point[i].baseNode.idx = i
        self.Node_Point[i].baseNode:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(self.OnPointClick,self)))
    end
    self.RoleLianTiResultCallBack = function (event)
        self:brushPointState()
        self:brushPointInfo()
        self:showLianTiAttri()
        self:showConsume(self.selectId)
        self:addResultEffect()
        self:addSuccessEffect(self.Node_Point[self.selectId].baseNode)
    end
    TFDirector:addMEGlobalListener(LianTiManager.lianTiResult,self.RoleLianTiResultCallBack)

end

function RoleLianTiLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(LianTiManager.lianTiResult,self.RoleLianTiResultCallBack)
end

-----断线重连支持方法
function RoleLianTiLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function RoleLianTiLayer:refreshUI()
    self.selectId = self.selectId or 1
    self:brushUnlockShow()
    self:brushPointState()
    self:brushPointInfo()
    self:showLianTiAttri()
    self:showConsume(self.selectId)
end

function RoleLianTiLayer:dispose()
    self.super.dispose(self)
end

function RoleLianTiLayer:OnRuleClick( sender )
    CommonManager:showRuleLyaer('lianti')
end

function RoleLianTiLayer:OnPointClick(sender)
    local pointData = self.cardRole:getLianTiDataById(sender.idx)
    if nil == pointData or pointData.isOpen == false then
        local tipStr = localizable["RoleLianTiLayer_Point_tip_"..sender.idx - 1]
        if tipStr and tipStr ~= "" then
            toastMessage(tipStr)
        end
        return
    end
    if self.selectId == sender.idx then
        return
    end
    self.selectId = sender.idx
    self:brushUnlockShow()
    self:showConsume(self.selectId)
end

function RoleLianTiLayer:OnLianTiClick(sender)
    if self.isEnough ~= true then
        if self.needItemName then
            toastMessage(stringUtils.format(localizable.Common_good_buzu,self.needItemName))
        end
        return
    end
    LianTiManager:requestLianti(self.cardRole.gmId,self.selectId)
end

function RoleLianTiLayer:brushPointInfo()
    local attriList = {}
    for k,v in ipairs(self.Node_Point) do
        local pointData = self.cardRole:getLianTiDataById(k)
        if nil == pointData or pointData.isOpen == false then
            if v.img_lock then
                v.img_lock:setVisible(true)
            end
        else
            if v.img_lock then
                v.img_lock:setVisible(false)
            end
            if self.selectId == k then
                v.img_unlock:setVisible(true)
            else
                v.img_unlock:setVisible(false)
            end
            local quality = pointData.quality or 0
            if quality <= 0 then 
                quality = 1
            end
            v.txt_level:setText(LianTiQualityNameStr[quality]..' Lv'..pointData.level)
            
            local attriType = LianTiManager:getPointAttriType(k,self.cardRole.quality)
            local attriNum = self.cardRole:getLianTiTotalAttribute(attriType)
            v.txt_Info:setText(AttributeTypeStr[attriType]..' +'..attriNum or 0)
            if nil == v.effect then
                v.effect = self:getPointEffectByQuality(pointData.quality or 0)
                if v.effect then
                    v.baseNode:addChild(v.effect)
                    v.effect:playByIndex(0, -1, -1, 1)
                end
            else
                if v.effect.quality ~= pointData.quality then
                    v.effect:removeFromParent()
                    v.effect = self:getPointEffectByQuality(pointData.quality or 0)
                    if v.effect then
                        v.baseNode:addChild(v.effect)
                        v.effect:playByIndex(0, -1, -1, 1)
                    end
                end
            end
        end
    end
end

function RoleLianTiLayer:showConsume(index)
    local pointData = self.cardRole:getLianTiDataById(index)
    if pointData and pointData.isOpen == true then
        print("LianTiManager:getMaxPointLvl  ",LianTiManager:getMaxPointLvl(index))
        if pointData.level >= LianTiManager:getMaxPointLvl(index) then
            self.panel_res:setVisible(false)
            self.btn_lianti_up:setVisible(false)
            self.img_lianti_h:setVisible(true)
            return
        end
        self.btn_lianti_up:setVisible(true)
        self.img_lianti_h:setVisible(false)
        local level = pointData.level + 1
        self.panel_res:setVisible(true)
        self.panel_res:removeAllChildren()
        local quality = self.cardRole.quality
        if self.cardRole:getIsMainPlayer() then
            quality = QualityHeroType.ChuanShuo
        end
        local consumeList = LianTiData:getConsume(index,level,quality) or {}
        self.isEnough = true
        self.needItemName = nil
        for i=1,#consumeList do
            local icon = require('lua.logic.role_new.RoleStarUpPreviewNumCell'):new()
            icon:setPosition(ccp((i-1)*92, 0))
            item = consumeList[i]
            local itemName = ""
            local curr_num = 0
            if item.type == 1 then
                curr_num = BagManager:getItemNumById( item.id )
                local dataConfig = ItemData:objectByID(item.id)
                itemName = dataConfig.name
            else
                curr_num = MainPlayer:getResValueByType(item.type)
                if item.type == 5 then
                    itemName = localizable.common_zhenqi
                elseif item.type == 14 then
                    itemName = localizable.common_jinglu
                else
                    itemName = localizable.common_res
                end
            end
            icon:setData(item.id,curr_num,item.num,item.type)
            self.panel_res:addChild(icon)
            if curr_num < item.num then
                self.isEnough = false
                self.needItemName = itemName
            end
        end
    else
        self.panel_res:setVisible(false)
        self.btn_lianti_up:setVisible(false)
        self.img_lianti_h:setVisible(true)
    end
end

function RoleLianTiLayer:showLianTiAttri()
    for i=1,5 do
        local attribute = self.cardRole:getLianTiTotalAttribute(i)
        self.Node_Attri[i].txt_name:setText(AttributeTypeStr[i])
        self.Node_Attri[i].txt_num:setText("+"..attribute)
    end
    local attriExtra = self.cardRole:getExtraLianTiAttri()
    local num = (attriExtra.addNum or 0)/100
    self.Node_Extra_Attri[1]:setText("+"..num.."%")
    self.Node_Extra_Attri[2]:setText("+"..attriExtra.meridians)
    self.Node_Extra_Attri[3]:setText("+"..attriExtra.breakthrough)
end

function RoleLianTiLayer:getPointEffectByQuality(quality)
    if quality <= 0 then 
        return nil 
    end
    TFResourceHelper:instance():addArmatureFromJsonFile('effect/lianti'..quality..'.xml')
    local effect = TFArmature:create('lianti'..quality..'_anim')
    effect.quality = quality
    return effect
end

function RoleLianTiLayer:brushPointState()
    for k,v in ipairs(self.Node_Point) do
        local pointData = self.cardRole:getLianTiDataById(k)
        if nil == pointData or pointData.isOpen == false then
            if v.img_lock then
                v.img_lock:setVisible(true)
            end
        else
            if v.img_lock then
                v.img_lock:setVisible(false)
            end
        end
    end
end

function RoleLianTiLayer:brushUnlockShow()
    for k,v in ipairs(self.Node_Point) do
        if self.selectId == k then
            v.img_unlock:setVisible(true)
        else
            v.img_unlock:setVisible(false)
        end
    end
end

function RoleLianTiLayer:addSuccessEffect( widget )
    if self.successEffect then
        self.successEffect:removeMEListener(TFARMATURE_COMPLETE)
        self.successEffect:removeFromParent()
        self.successEffect = nil
    end
    
    local resPath = "effect/role_train.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("role_train_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(0,0))
    effect:setZOrder(100)
    self.successEffect = effect    
    self.successEffect:playByIndex(0, -1, -1, 0)
    widget:addChild(effect)

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeFromParent()
        self.successEffect = nil
    end)
end

function RoleLianTiLayer:addResultEffect() 

    if self.rightEffect then
        self.rightEffect:removeMEListener(TFARMATURE_COMPLETE)
        self.rightEffect:removeFromParent()
        self.rightEffect = nil
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equipment_refining.xml")
    local effect = TFArmature:create("equipment_refining_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    self.panel_details_1:addChild(effect)
    effect:setPosition(ccp(120,100))
    effect:setScaleX(0.8)
    effect:setZOrder(100)
    self.rightEffect = effect
    self.rightEffect:playByIndex(0, -1, -1, 0)

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeFromParent()
        self.rightEffect = nil
    end)
end

return RoleLianTiLayer
