--[[
******铁匠铺强化界面*******

	-- by Stephen.tao
	-- 2014/5/6
]]

local SmithyIntensify = class("SmithyIntensify", BaseLayer)

function SmithyIntensify:ctor(gmId)
    self.super.ctor(self,data)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.SmithyIntensify")
end

function SmithyIntensify:initUI(ui)
	self.super.initUI(self,ui)
	--左侧详情
	self.scroll_left			= TFDirector:getChildByPath(ui, 'scroll_left')
	self.info_panel				= require('lua.logic.smithy.EquipInfoPanel'):new(self.gmId)
	self.scroll_left:addChild(self.info_panel)

	--右侧信息
	self.scroll_right			= TFDirector:getChildByPath(ui, 'scroll_right')
    --强化信息
    self.img_intensify_lv		= TFDirector:getChildByPath(ui, 'img_intensify_lv')
    self.txt_now_level			= TFDirector:getChildByPath(self.img_intensify_lv, 'txt_current_lv')
    self.txt_next_level			= TFDirector:getChildByPath(self.img_intensify_lv, 'txt_next_lv')
    self.img_to_arrow_lv		= TFDirector:getChildByPath(self.img_intensify_lv, 'img_to')
   	self.img_base_attr			= TFDirector:getChildByPath(ui, 'img_base_attr')
	self.txt_oldAttr			= TFDirector:getChildByPath(self.img_base_attr, 'txt_current_val')
	self.txt_newAttr			= TFDirector:getChildByPath(self.img_base_attr, 'txt_next_val')
	self.img_to_arrow_attr		= TFDirector:getChildByPath(self.img_base_attr, 'img_to')
	--vip信息
	self.txt_vip_lv				= TFDirector:getChildByPath(ui, 'txt_vip_lv')
	self.txt_critical			= TFDirector:getChildByPath(ui, 'txt_critical')
    --消耗
    self.img_res_icon			= TFDirector:getChildByPath(ui, 'img_res_icon')
    self.txt_cost				= TFDirector:getChildByPath(ui, 'txt_cost')
    --强化按钮
    self.btn_strenthen			= TFDirector:getChildByPath(ui, 'btn_strenthen')
	self.btn_strenthen.logic	= self

    self.btn_yijianqianghua		= TFDirector:getChildByPath(ui, 'btn_yijianqianghua')
	self.btn_yijianqianghua.logic	= self

    self.img_res_icon2		= TFDirector:getChildByPath(ui, 'img_res_icon2')
    self.img_di2		= TFDirector:getChildByPath(ui, 'img_di2')
	self.img_res_icon2:setVisible(false)
	self.img_di2:setVisible(false)

	self.btn_equip                      = TFDirector:getChildByPath(ui, "btn_equip")
    self.btn_equip.logic = self


	--强化上限
	self.txt_limit				= TFDirector:getChildByPath(ui, 'txt_limit')
	local txt_numLv_effect = TFDirector:getChildByPath(self.ui, 'txt_numLv_effect')
	local txt_numattr_effect = TFDirector:getChildByPath(self.ui, 'txt_numattr_effect')
	txt_numLv_effect:setVisible(false)
	txt_numattr_effect:setVisible(false)

	-- 
	self.btn_equip:setVisible(false)
end

function SmithyIntensify:onShow()
	self.super.onShow(self)
    self:refreshUI()
    self.info_panel:onShow()
end

function SmithyIntensify:dispose()
	self.info_panel:dispose()
	self.super.dispose(self)
end

function SmithyIntensify:refreshUI()
	
    self.info_panel:setEquipGmId(self.gmId)
    local vipLevel = MainPlayer:getVipLevel()
    self.txt_vip_lv:setText(vipLevel)
    local intensifyVip = IntensifyVipData:objectByID(vipLevel)
    if intensifyVip then
    	self.txt_critical:setText(intensifyVip.min .. "-" .. intensifyVip.max)
    else
    	self.txt_critical:setText("1 - 1")
    end
	self:updateLevel()
end

function SmithyIntensify:removeUI()
	self.super.removeUI(self)
end

function SmithyIntensify:setEquipGmId(gmId)
	self.gmId = gmId
	self:refreshUI()
end

function SmithyIntensify:updateLevel()
	local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    if equipmentTemplate == nil then
        print("没有此类装备模板信息")
        return
    end

    local attribute_index , attribute_num = equip:getBaseAttribute():getAttributeByIndex(1)
    local attribute_index1 , attribute_num1 = equip:getBaseAttributeOnOne():getAttributeByIndex(1)

    if attribute_index == EnumAttributeType.Blood then
    	self.img_base_attr:setTexture("ui_new/smithy/blood.png")
    elseif attribute_index == EnumAttributeType.Force then
    	self.img_base_attr:setTexture("ui_new/smithy/force.png")
    elseif attribute_index == EnumAttributeType.Defence then
    	self.img_base_attr:setTexture("ui_new/smithy/def.png")
    elseif attribute_index == EnumAttributeType.Magic then
    	self.img_base_attr:setTexture("ui_new/smithy/inforce.png")
    elseif attribute_index == EnumAttributeType.Agility then
    	self.img_base_attr:setTexture("ui_new/smithy/speed.png")
    end

    self.txt_cost:setColor(ccc3(255,255,255))
    self.txt_now_level:setText("+"..equip.level)
    self.txt_oldAttr:setText(attribute_num)

	--所需金钱结算
	local coin = IntensifyData:getConsumeByIntensifyLevel(equip.level + 1,equip.quality)
	if coin == nil then
		--self.txt_limit:setText("已经达到最高等级不能再强化")
		self.txt_limit:setText(localizable.smithyIntensify_max)
		self.btn_strenthen:setGrayEnabled(true)
		self.btn_strenthen:setClickMoveEnabled(true)
		self.btn_strenthen:setTouchEnabled(false)
		self.btn_yijianqianghua:setGrayEnabled(true)
		self.btn_yijianqianghua:setClickMoveEnabled(true)
		self.btn_yijianqianghua:setTouchEnabled(false)
		self.img_res_icon:setVisible(false)
		self.txt_cost:setVisible(false)
		self.img_to_arrow_lv:setVisible(false)
		self.img_to_arrow_attr:setVisible(false)
		self.txt_next_level:setVisible(false)
		self.txt_newAttr:setVisible(false)
		print(">= 150…!!!…………………")
		return
	end

	print("< 150……………………")

	local maxIntensifyLevel = MainPlayer:getMaxIntensifyLevel()
    --self.txt_limit:setText("最高可强化等级：" .. maxIntensifyLevel)
    self.txt_limit:setText(stringUtils.format(localizable.smithyIntensify_level, maxIntensifyLevel))
	self.img_res_icon:setVisible(true)
	self.txt_cost:setVisible(true)
	self.img_to_arrow_lv:setVisible(true)
	self.img_to_arrow_attr:setVisible(true)
	self.txt_next_level:setVisible(true)
	self.txt_newAttr:setVisible(true)

	self.txt_next_level:setText(equip.level + 1)

    local totalGrowNum = GetTotalGrowNumByKind( attribute_index ,(equip.level + 1))
    local num = math.floor((attribute_num1 + totalGrowNum)*equip:getGrow())
    -- local recastPercent = equip:getRecastPercent()
    -- num = num
    self.txt_newAttr:setText(num)

	local enough = MainPlayer:isEnoughCoin(coin,false)
	self.consumeCoin = coin
	self.txt_cost:setText(coin)
	
	if not enough then
		self.txt_cost:setColor(ccc3(255,0,0))
		self.btn_strenthen:setGrayEnabled(true)
		self.btn_strenthen:setClickMoveEnabled(true)
		self.btn_strenthen:setTouchEnabled(true)
		self.btn_yijianqianghua:setGrayEnabled(true)
		self.btn_yijianqianghua:setClickMoveEnabled(true)
		self.btn_yijianqianghua:setTouchEnabled(true)
	end
	if maxIntensifyLevel <= equip.level then
		self.btn_strenthen:setGrayEnabled(true)
		self.btn_strenthen:setClickMoveEnabled(true)
		self.btn_strenthen:setTouchEnabled(false)
		self.btn_yijianqianghua:setGrayEnabled(true)
		self.btn_yijianqianghua:setClickMoveEnabled(true)
		self.btn_yijianqianghua:setTouchEnabled(false)
	else
		self.btn_strenthen:setGrayEnabled(false)
		self.btn_strenthen:setClickHighLightEnabled(true)
		self.btn_strenthen:setTouchEnabled(true)
		self.btn_yijianqianghua:setTouchEnabled(true)
		if VipRuleManager:isCanIntensify(false) == false then
			self.btn_yijianqianghua:setGrayEnabled(true)
			self.btn_yijianqianghua:setClickMoveEnabled(true)
		else
			self.btn_yijianqianghua:setGrayEnabled(false)
			self.btn_yijianqianghua:setClickHighLightEnabled(true)
		end
	end

end


function SmithyIntensify:updateIntensifyResult(data)
	-- if self.layer_result == nil then
	-- 	self.layer_result = require("lua.logic.item.EquipmentIntensifyResult"):new()
	-- 	self.layer_result:setPosition(ccp(self.ui:getContentSize().width/2,self.ui:getContentSize().height/2))
	-- 	self.ui:addChild(self.layer_result)
	-- end
	-- TFDirector:killAllTween(self.layer_result)
	-- self.layer_result:setVisible(true)
	-- self.layer_result:setResult(data)
	-- self.layer_result:setZOrder(100)
	-- --self.layer_result:setAnchorPoint(ccp(0.5,0.5))
	-- self.layer_result:setScale(0.1)
	-- local tween = {
	-- 	target = self.layer_result,
	-- 		{
	-- 			duration = 0.1,
	-- 			scale = 1,
	-- 		},
	-- 		{
	-- 			duration = 0.1,
	-- 			scale = 0.8,
	-- 		},
	-- 		{
	-- 			duration = 0.1,
	-- 			scale = 1,
	-- 		},
	-- 		{
	-- 			duration = 0,
	-- 			delay = 1,
	-- 			onComplete = function ()
	-- 				self.layer_result:setVisible(false)
	-- 			end,
	-- 		},
	-- }
	-- TFDirector:toTween(tween)
	self:intensifyEquipEffect()
	local txt_numLv_effect = TFDirector:getChildByPath(self.ui, 'txt_numLv_effect')
	self:intensifyNumEffect(txt_numLv_effect , data.level)
	local txt_numattr_effect = TFDirector:getChildByPath(self.ui, 'txt_numattr_effect')

	for i=1,(EnumAttributeType.Max-1) do
		if data.change_attr[i] and data.change_attr[i] ~= 0 then
			self:intensifyNumEffect(txt_numattr_effect , data.change_attr[i])
		end
	end
end


function SmithyIntensify:intensifyEquipEffect()
	if self.equipEffect == nil then
		-- self.equipEffect:removeFromParentAndCleanup(true)
		-- self.equipEffect = nil
		TFResourceHelper:instance():addArmatureFromJsonFile("effect/equiIntensify.xml")
		local effect = TFArmature:create("equiIntensify_anim")
		effect:setAnimationFps(GameConfig.ANIM_FPS)

		local img_icon = TFDirector:getChildByPath(self.info_panel, 'img_icon')
		effect:setPosition(ccp(360,-35))
		img_icon:addChild(effect)
		self.equipEffect = effect
	end
	self.equipEffect:playByIndex(0, -1, -1, 0)

	if self.shuaguang_effect_1 == nil then
		TFResourceHelper:instance():addArmatureFromJsonFile("effect/equipIntensify_3.xml")
		local effect = TFArmature:create("equipIntensify_3_anim")
		effect:setAnimationFps(GameConfig.ANIM_FPS)

		local img_intensify_lv = TFDirector:getChildByPath(self.ui, 'img_intensify_lv')
		effect:setPosition(ccp(130,-47))
		img_intensify_lv:addChild(effect)
		self.shuaguang_effect_1 = effect
	end
	if self.shuaguang_effect_2 == nil then
		TFResourceHelper:instance():addArmatureFromJsonFile("effect/equipIntensify_3.xml")
		local effect = TFArmature:create("equipIntensify_3_anim")
		effect:setAnimationFps(GameConfig.ANIM_FPS)

		local img_base_attr = TFDirector:getChildByPath(self.ui, 'img_base_attr')
		effect:setPosition(ccp(130,-47))
		img_base_attr:addChild(effect)
		self.shuaguang_effect_2 = effect
	end
	-- if self.num_effect_1 == nil then
	-- 	TFResourceHelper:instance():addArmatureFromJsonFile("effect/equipIntensify_2.xml")
	-- 	local effect = TFArmature:create("equipIntensify_2_anim")
	-- 	effect:setAnimationFps(GameConfig.ANIM_FPS)

	-- 	local img_intensify_lv = TFDirector:getChildByPath(self.ui, 'img_intensify_lv')
	-- 	effect:setPosition(ccp(120,-92))
	-- 	img_intensify_lv:addChild(effect)
	-- 	self.num_effect_1 = effect
	-- end
	-- if self.num_effect_2 == nil then
	-- 	TFResourceHelper:instance():addArmatureFromJsonFile("effect/equipIntensify_2.xml")
	-- 	local effect = TFArmature:create("equipIntensify_2_anim")
	-- 	effect:setAnimationFps(GameConfig.ANIM_FPS)

	-- 	local img_base_attr = TFDirector:getChildByPath(self.ui, 'img_base_attr')
	-- 	effect:setPosition(ccp(125,-92))
	-- 	img_base_attr:addChild(effect)
	-- 	self.num_effect_2 = effect
	-- end
	self.shuaguang_effect_1:playByIndex(0, -1, -1, 0)
	self.shuaguang_effect_2:playByIndex(0, -1, -1, 0)
	-- self.num_effect_1:playByIndex(0, -1, -1, 0)
	-- self.num_effect_2:playByIndex(0, -1, -1, 0)
end

function SmithyIntensify:intensifyNumEffect(widget , text)
	
	widget:setText("+"..text);
	TFDirector:killAllTween(widget)
	widget:setVisible(true)
	widget:setScale(0.1)
	local tween = {
		target = widget,
			{
				duration = 0.1,
				scale = 1,
			},
			{
				duration = 0.1,
				scale = 0.8,
			},
			{
				duration = 0.1,
				scale = 1,
			},
			{
				duration = 0,
				delay = 1,
				onComplete = function ()
					widget:setVisible(false)
				end,
			},
	}
	TFDirector:toTween(tween)

end


function SmithyIntensify.intensifyBtnClickHandle(btn)
	local self = btn.logic
	if self then
		local coin = self.consumeCoin
		local enough = MainPlayer:isEnoughCoin(coin,true)
		if not enough then
			return
		end
		EquipmentManager:EquipmentIntensify(self.gmId)
	end
end

function SmithyIntensify.intensifyOnceBtnClickHandle(btn)
	if VipRuleManager:isCanIntensify(true) == false then
		return
	end
	local self = btn.logic
	if self then
		local coin = self.consumeCoin
		local enough = MainPlayer:isEnoughCoin(coin,true)
		if not enough then
			return
		end
		EquipmentManager:EquipmentIntensifyToTop(self.gmId)
	end
end

function SmithyIntensify:registerEvents()
	self.super.registerEvents(self)

	self.btn_strenthen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.intensifyBtnClickHandle),1)
	self.btn_yijianqianghua:addMEListener(TFWIDGET_CLICK, audioClickfun(self.intensifyOnceBtnClickHandle),1)

	self.GotoEquipClickHandle = function(event)
        local topPowerRole = StrategyManager:getTopPowerRole()
        CardRoleManager:openRoleInfo(topPowerRole.gmId,function() AlertManager:close() end)
    end
	self.btn_equip:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GotoEquipClickHandle),1)
	self.equipmentIntensifyCallBack = function(event)
 		self:refreshUI()
        self:updateIntensifyResult(event.data[1]);        
		TFAudio.playEffect("sound/effect/intensify.mp3", false)
    end
	TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.equipmentIntensifyCallBack)

	self.CoinChangeCallback = function(event)
		self:refreshUI()
	end
	TFDirector:addMEGlobalListener(MainPlayer.CoinChange,self.CoinChangeCallback)
end


function SmithyIntensify:removeEvents()
    self.super.removeEvents(self)
    
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT,self.equipmentIntensifyCallBack)
    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange,self.CoinChangeCallback)
end

return SmithyIntensify;
