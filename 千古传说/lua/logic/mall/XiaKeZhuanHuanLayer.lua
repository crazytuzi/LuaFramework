--[[
    侠客换功(转换)
]]
local XiaKeZhuanHuanLayer = class("XiaKeZhuanHuanLayer", BaseLayer)

XiaKeZhuanHuanLayer.TAG_ROLE1 = 1
XiaKeZhuanHuanLayer.TAG_ROLE2 = 2

function XiaKeZhuanHuanLayer:ctor(data)
    self.super.ctor(self, data)
    self.ui = nil
    self:init("lua.uiconfig_mango_new.shop.XiaKeZhuanHuan")
end

function XiaKeZhuanHuanLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui
    self.generalHead = CommonManager:addGeneralHead(self, 10)
    self.generalHead:setData(ModuleType.HuanGong, {HeadResType.COIN,HeadResType.SYCEE})

    self.btn_zhuanhuan = TFDirector:getChildByPath(ui, "btn_zhuanhuan")
    self.btn_zhuanhuan.logic = self
    --消耗转换丹数量
    self.txt_coss = TFDirector:getChildByPath(ui,"txt_coss")
    self.icon = TFDirector:getChildByPath(ui, "icon")
    self.item_num = TFDirector:getChildByPath(ui, "TextArea_Zhuanhuan_1")
    self.btn_help = TFDirector:getChildByPath(ui, "btn_help")
    self.btn_help.logic = self
    self.panel_zhandouli1 = TFDirector:getChildByPath(ui, "Panel_zhandouli1")
    self.panel_zhandouli2 = TFDirector:getChildByPath(ui, "Panel_zhandouli2")
    self.txt_power1 = TFDirector:getChildByPath(self.panel_zhandouli1, "txt_power")
    self.txt_power2 = TFDirector:getChildByPath(self.panel_zhandouli2, "txt_power")

    --侠客黑影
    self.img_rolehei1 = TFDirector:getChildByPath(ui, "img_rolehei1")
    self.btn_jiahao1 = TFDirector:getChildByPath(self.img_rolehei1, "btn_jiahao")
    self.btn_jiahao1.logic = self

    self.img_rolehei2 = TFDirector:getChildByPath(ui, "img_rolehei2")
    self.btn_jiahao2 = TFDirector:getChildByPath(self.img_rolehei2, "btn_jiahao")
    self.btn_jiahao2.logic = self

    self.btn_jiahao1.tag = self.TAG_ROLE1
    self.btn_jiahao2.tag = self.TAG_ROLE2

    self.panel_rolelist1 = TFDirector:getChildByPath(ui, "panel_rolelist1")
    self.panel_rolelist2 = TFDirector:getChildByPath(ui, "panel_rolelist2")
    self.panel_rolelist1.tag = self.TAG_ROLE1
    self.panel_rolelist2.tag = self.TAG_ROLE2
    self.panel_rolelist1.logic = self
    self.panel_rolelist2.logic = self

    --侠客纹理
    self.img_role1 = TFDirector:getChildByPath(ui, "img_role1")
    self.img_role2 = TFDirector:getChildByPath(ui, "img_role2")
    self.panel_role = TFDirector:getChildByPath(ui, "panel_1")

    self.panel_head = TFDirector:getChildByPath(ui, "panel_head")

    --星星
    self.panel_xiulian1 = TFDirector:getChildByPath(ui, "panel_xiulian1")
    self.panel_xiulian2 = TFDirector:getChildByPath(ui, "panel_xiulian2")
    self.panel_xiulian = {self.panel_xiulian1, self.panel_xiulian2}
    self.img_starList1 = {}
    self.img_starList2 = {}
    self.img_starList = {self.img_starList1, self.img_starList2}
    for i = 1, 2 do
        for j = 1, 5 do
            self.img_starList[i][j] = TFDirector:getChildByPath(self.panel_xiulian[i], "img_star_light_" .. j)
            self.img_starList[i][j]:setVisible(false)
        end
    end

    --品质
    self.img_pinzhi1 = TFDirector:getChildByPath(ui, "img_pinzhi1")
    self.img_pinzhi2 = TFDirector:getChildByPath(ui, "img_pinzhi2")

    --名字及名字背景
    self.panel_jiemianbiaoti1 = TFDirector:getChildByPath(ui, "panel_jiemianbiaoti1")
    self.panel_jiemianbiaoti2 = TFDirector:getChildByPath(ui, "panel_jiemianbiaoti2")
    self.img_namebg1 = TFDirector:getChildByPath(self.panel_jiemianbiaoti1, "img_namebg")
    self.img_namebg2 = TFDirector:getChildByPath(self.panel_jiemianbiaoti2, "img_namebg")
    self.txt_name1 = TFDirector:getChildByPath(self.panel_jiemianbiaoti1, "txt_name")
    self.txt_name2 = TFDirector:getChildByPath(self.panel_jiemianbiaoti2, "txt_name")

    self:resetSelect()
end

function XiaKeZhuanHuanLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshUI()
end

function XiaKeZhuanHuanLayer:resetSelect()
    self.selectRole1 = nil
    self.selectRole2 = nil
    self.selectRole = {[1] = self.selectRole1, [2] = self.selectRole2}
end

function XiaKeZhuanHuanLayer:refreshDefault()
    self.img_rolehei1:setVisible(true)
    self.img_rolehei2:setVisible(true)
    -- self.img_role1:setVisible(false)
    -- self.img_role2:setVisible(false)
    self.img_namebg1:setTexture(GetRoleNameBgByQuality(1))
    self.img_namebg2:setTexture(GetRoleNameBgByQuality(1))
    self.txt_name1:setText("")
    self.txt_name2:setText("")
    self.img_pinzhi1:setTexture(GetFontByQuality(1))
    self.img_pinzhi2:setTexture(GetFontByQuality(1))
    self.txt_power1:setText(0)
    self.txt_power2:setText(0)

    for i = 1, #self.img_starList1 do
        self.img_starList1[i]:setVisible(false)
    end

    for i = 1, #self.img_starList2 do
        self.img_starList2[i]:setVisible(false)
    end

    self.panel_jiemianbiaoti1:setVisible(false)
    self.panel_jiemianbiaoti2:setVisible(false)
    self.img_pinzhi1:setVisible(false)
    self.img_pinzhi2:setVisible(false)
    self.panel_xiulian1:setVisible(false)
    self.panel_xiulian2:setVisible(false)
end

function XiaKeZhuanHuanLayer:setStarLevel(index, starLevel)
    for i = 1, 5 do
        self.img_starList[index][i]:setVisible(false)
    end
    
    for i = 1, starLevel do
        local starIdx = i
        local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
        if i > 5 then
            starTextrue = 'ui_new/common/xl_dadian23_icon.png'
            starIdx = i - 5
        end
        self.img_starList[index][starIdx]:setTexture(starTextrue)
        self.img_starList[index][starIdx]:setVisible(true)
    end
end

function XiaKeZhuanHuanLayer:setStarBgVisible()

end

-- function XiaKeZhuanHuanLayer:removeModel(index)
--     local model
--     if index == 1 then
--         model = self.model1
--         self.model1 = nil
--     else
--         model = self.model2
--         self.model2 = nil
--     end

--     if model then
--         model:removeFromParent()
--     end
-- end

function XiaKeZhuanHuanLayer:createModel(index, armatureID)
    print("------------>createModel : ", armatureID)
    local model = index == 1 and self.model1 or self.model2
    if model then
        model:removeFromParent()
    end

    ModelManager:addResourceFromFile(1, armatureID, 1)
    model = ModelManager:createResource(1, armatureID)
    -- model:setScale(2)
    model:setZOrder(2)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)

    if index == 1 then
        model:setPosition(self.img_role1:getPosition() + ccp(20, -150))
        self.model1 = model
    else
        model:setPosition(self.img_role2:getPosition() + ccp(-10, -150))
        model:setScaleX(-1)
        self.model2 = model
    end

    self.panel_role:addChild(model)
end

function XiaKeZhuanHuanLayer:refreshUI()
    self:refreshDefault()

    if self.selectRole1 then
        self.panel_xiulian1:setVisible(true)
        self.img_pinzhi1:setVisible(true)
        self.panel_jiemianbiaoti1:setVisible(true)
        -- self.img_role1:setVisible(true)
        self.img_rolehei1:setVisible(false)
        local role = CardRoleManager:getRoleByGmid(self.selectRole1)
        role:updatePower()

        self.img_namebg1:setTexture(GetRoleNameBgByQuality(role.quality))
        self.txt_name1:setText(role.name)
        -- self.img_role1:setTexture(role:getBigImagePath())
        self.img_pinzhi1:setTexture(GetFontByQuality(role.quality))

        self:setStarLevel(1, role.starlevel)
        self.txt_power1:setText(role:getPowerByFightType(1))

        self:createModel(1, role.image)
    end

    if self.selectRole2 then
        self.panel_xiulian2:setVisible(true)
        self.img_pinzhi2:setVisible(true)
        self.panel_jiemianbiaoti2:setVisible(true)
        -- self.img_role2:setVisible(true)
        self.img_rolehei2:setVisible(false)
        local role = CardRoleManager:getRoleByGmid(self.selectRole2)
        role:updatePower()

        self.img_namebg2:setTexture(GetRoleNameBgByQuality(role.quality))
        self.txt_name2:setText(role.name)
        -- self.img_role2:setTexture(role:getBigImagePath())
        self.img_pinzhi2:setTexture(GetFontByQuality(role.quality))

        self:setStarLevel(2, role.starlevel)
        self.txt_power2:setText(role:getPowerByFightType(1))

        self:createModel(2, role.image)
    end

    self.txt_coss:setText(XiaKeExchangeManager:getZhuanhuanNeedNum())
    local num = BagManager:getItemNumById(30079) or 0
    self.item_num:setText(stringUtils.format(localizable.changetProLayer_have, num))
end

function XiaKeZhuanHuanLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function XiaKeZhuanHuanLayer:removeUI()
    self.super.removeUI(self);

    self:resetSelect()
end

--注册事件
function XiaKeZhuanHuanLayer:registerEvents()
    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_zhuanhuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhuanhanClickCallback))
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHelpClickCallback))
    self.btn_jiahao1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiahaoClickCallback))
    self.btn_jiahao2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiahaoClickCallback))
    self.panel_rolelist1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiahaoClickCallback))
    self.panel_rolelist2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJiahaoClickCallback))

    --换功成功
    self.changeSuccess = function(event)       
        self:refreshUI()
        local data = event.data[1]
        if data and data.result then
            if data.result ~= 0 then
                toastMessage(localizable.xiakezhuanhuan_fail)
            else
                TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/xiakehuangong.xml")
                local effect = TFArmature:create("xiakehuangong_anim")
                effect:setAnimationFps(GameConfig.ANIM_FPS)
                effect:setPosition(ccp(self.ui:getContentSize().width / 2, self.ui:getContentSize().height / 2))
                self.ui:addChild(effect, 1)
                effect:playByIndex(0, -1, -1, 0)

                RewardManager:setStopShow(true)
                effect:addMEListener(TFARMATURE_COMPLETE, function()
                    toastMessage(localizable.xiakezhuanhuan_success)
                    if effect then
                        effect:removeFromParent()
                        effect = nil
                    end

                    RewardManager:setStopShow(false)
                end)                
            end
        end        
    end
    TFDirector:addMEGlobalListener(XiaKeExchangeManager.changeRole, self.changeSuccess)  
end

function XiaKeZhuanHuanLayer.onZhuanhanClickCallback(sender)
    local self = sender.logic

    if (not self.selectRole1) or (not self.selectRole2) then
        toastMessage(localizable.xiakezhuanhuan_role_not_enough)
        return
    end

    local num = BagManager:getItemNumById(30079) or 0
    if num < XiaKeExchangeManager:getZhuanhuanNeedNum() then
        if MallManager:checkShopOneKey( 30079 ) == false then
            toastMessage(localizable.ChangeProfessionLayer_zhuanhuandanbuzu)
        end        
        return
    end

    local cardRole1 = CardRoleManager:getRoleByGmid(self.selectRole1)    
    local cardRole2 = CardRoleManager:getRoleByGmid(self.selectRole2)

    if cardRole1.quality ~= cardRole2.quality then
        toastMessage(localizable.xiakezhuanhuan_same_quality)
        return
    end
    
    CommonManager:showOperateSureLayer(function()
            XiaKeExchangeManager:requestChangeRole(cardRole1.gmId,cardRole2.gmId)
        end,
        nil,
        {
        msg = localizable.xiakezhuanhuan_change_role, 
    })
end

function XiaKeZhuanHuanLayer.onHelpClickCallback(sender)
    local self = sender.logic

    CommonManager:showRuleLyaer("xiakehuangong")
end

function XiaKeZhuanHuanLayer.onJiahaoClickCallback(sender)
    local self = sender.logic
    local index = sender.tag

    local tipsTxt = localizable.xiakezhuanhuan_select_role
    local layer = require("lua.logic.factionPractice.PracticeRoleSelect2"):new(index - 1)
    AlertManager:addLayer(layer, AlertManager.BLOCK, AlertManager.TWEEN_NONE)
    self.clickCallBack = function(cardRole)
        --print("{{{{{{{{{{", cardRole.id, FactionPracticeManager:checkRoleInHouseByGmId(cardRole.gmId))
        if FactionPracticeManager:checkRoleInHouseByGmId(cardRole.gmId) then
            toastMessage(localizable.xiakezhuanhuan_xiulianzhong)
            return
        end

        layer:moveOut()
        if index == 1 then
            self.selectRole1 = cardRole.gmId
        elseif index == 2 then
            self.selectRole2 = cardRole.gmId
        end
        play_buzhenluoxia()
    end
    layer:initDate(self:getRoleList(), tipsTxt, self.clickCallBack)
    AlertManager:show()
end

function XiaKeZhuanHuanLayer:getRoleList()
    local role_list = TFArray:new()
    local quality = -1
    for card in CardRoleManager.cardRoleList:iterator() do
        local id1, id2 = -1, -1
        if self.selectRole1 then
            id1 = self.selectRole1
            --local role = CardRoleManager:getRoleById(id1)
            --quality = role.quality
        end
        if self.selectRole2 then
            id2 = self.selectRole2
            --local role = CardRoleManager:getRoleById(id2)
            --quality = role.quality
        end


        if (card.quality == 4 or card.quality == 5) and card.gmId ~= id1 and card.gmId ~= id2 and card.id ~= MainPlayer:getProfession() then
            --[[
            if id1 ~= -1 then
                local role = CardRoleManager:getRoleByGmid(id1)
                local quality = role.quality
                if card.quality == quality then
                    role_list:pushBack(card)
                end
            elseif id2 ~= -1 then
                local role = CardRoleManager:getRoleByGmid(id2)
                local quality = role.quality
                if card.quality == quality then
                    role_list:pushBack(card)
                end
            else
                role_list:pushBack(card)
            end
            ]]
            role_list:pushBack(card)
        end       
    end
    role_list:sort(self.sortFunc)
    return role_list
end

function XiaKeZhuanHuanLayer.sortFunc(cardRole1, cardRole2)
    if cardRole1.quality > cardRole2.quality then
        return true
    elseif cardRole1.quality == cardRole2.quality then
        if cardRole1:getPowerByFightType(1) > cardRole2:getPowerByFightType(1) then
            return true
        end
    end

    return false
end

function XiaKeZhuanHuanLayer:removeEvents()
    TFDirector:removeMEGlobalListener(XiaKeExchangeManager.changeRole, self.changeSuccess)
end

return XiaKeZhuanHuanLayer
