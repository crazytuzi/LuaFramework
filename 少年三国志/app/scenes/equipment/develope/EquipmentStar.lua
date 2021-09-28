-- EquipmentStar.lua

local string = string

require("app.cfg.equipment_star_info")

local EquipmentConst = require("app.const.EquipmentConst")
local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")
local EquipmentStarResultLayer = require("app.scenes.equipment.develope.EquipmentStarResultLayer")

local EffectNode = require "app.common.effects.EffectNode"

local EquipmentStar= class("EquipmentStar")

local SQRT = math.sqrt
local POW = math.pow
local ASIN = math.asin
local DEG = math.deg

-- 商品类型映射到本界面的id
EquipmentStar.GOODSMAP = {
	[G_Goods.TYPE_MONEY]    = 1,
	[G_Goods.TYPE_GOLD]     = 2,
	[G_Goods.TYPE_FRAGMENT] = 3,
}

-- 求角度
EquipmentStar.calAngle = function (startx, starty, endx, endy)
	local zjx = endx
	local zjy = starty
	local xb_dis = SQRT( POW((startx- endx), 2) +  POW((starty- endy), 2) )
	local db_dis = SQRT( POW((zjx- endx), 2) +  POW((zjy- endy), 2) )
    return DEG(ASIN(db_dis / xb_dis)) + 180
end

-- 进度条步长
EquipmentStar.PROGRESSSTEP = 530 / 100

function EquipmentStar:ctor(container)

	self._container = container or {}

	self._starImageViews = {}

	for i = 1, EquipmentConst.Star_MAX_LEVEL do

		self._starImageViews[i] = container:getImageViewByName(string.format("Image_start_%d_full", i))
	end

	self._luckyValueLabel    = container:getLabelByName("Label_luck_value")
	self._luckyDescLabel     = container:getLabelByName("Label_luck_desc")
	self._loadingBar         = container:getLoadingBarByName("LoadingBar_starProgress")
	self._barLabel           = container:getLabelByName("Label_starProgress")
	self._starEffectPanel    = container:getPanelByName("Panel_star_effect")
	self._successLabel       = container:getLabelByName("Label_success_value")
	self._nextAttrTitleLabel = container:getLabelByName("Label_next_attr_title")
	self._nextAttrValueLabel = container:getLabelByName("Label_next_attr_value")
	self._starsEquipPanel    = container:getPanelByName("Panel_stars_equip")
	self._luckPanel          = container:getPanelByName("Panel_luck")
	self._successPanel       = container:getPanelByName("Panel_success")
	self._nextAttrPanel      = container:getPanelByName("Panel_next_attr")
	self._starButton         = container:getButtonByName("Button_star")

	self._panelResouces         = {}
	self._checkBoxs             = {}
	self._isPlayingAnim         = false
	self._fire                  = nil
	self._checkstate            = 1
	self._attrs                 = {}
	self._lightEffect           = nil
	self._baojiEffect           = nil
	self._jingzhiStarEffect     = nil
	self._moveStarEffect        = nil
	self._equipStarEffect       = nil
	self._miniFagangEffect      = nil
	self._bigFagangEffect       = nil
	self._equipmentStarInfo     = nil
	self._equipmentNextStarInfo = nil
	self._equipment             = nil

	for i = 1, 3 do
		self._panelResouces[i] = container:getPanelByName(string.format("Panel_res%d", i))
		self._checkBoxs[i]     = container:getCheckBoxByName(string.format("CheckBox_Select%d", i))
	end
end

function EquipmentStar:onLayerLoad()

	self:_createStroke()

	-- container:attachImageTextForBtn("Button_star","ImageView_star_text")
	self._starEffectPanel:removeAllNodes()
	if self._jingzhiStarEffect == nil then
		self._jingzhiStarEffect = EffectNode.new("effect_zbsx_startgun_b")
	end
	self._jingzhiStarEffect:play()

	if self._moveStarEffect == nil then
		self._moveStarEffect = EffectNode.new("effect_zbsx_startgun_a")
	end
	self._moveStarEffect:play()

	self._moveStarEffect:setVisible(false)

	self._starEffectPanel:addNode(self._jingzhiStarEffect)
	self._starEffectPanel:addNode(self._moveStarEffect)

	self._container:registerBtnClickEvent("Button_help",handler(self, self._onHelp))

    self._container:registerBtnClickEvent("Button_star",handler(self, self._doStar))

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIPMENT_STAR, self._onStarResult, self)

end

function EquipmentStar:_onHelp()
	require("app.scenes.common.CommonHelpLayer").show(
		{
			{content = G_lang:get("LANG_EQUIPMENT_STAR_HELP")},
		})
end

function EquipmentStar:_createStroke()
	
	self._container:getLabelByName("Label_starCurrentAttr1Title"):createStroke(Colors.strokeBrown,1)
    self._container:getLabelByName("Label_starCurrentAttr1Value"):createStroke(Colors.strokeBrown,1)

    self._container:getLabelByName("Label_starNextAttr1Title"):createStroke(Colors.strokeBrown,1)
    self._container:getLabelByName("Label_starNextAttr1Value"):createStroke(Colors.strokeBrown,1)
    self._container:getLabelByName("Label_starNextAttr2Title"):createStroke(Colors.strokeBrown,1)
    self._container:getLabelByName("Label_starNextAttr2Value"):createStroke(Colors.strokeBrown,1)

    self._container:getLabelByName("Label_star_benjie"):createStroke(Colors.strokeBrown,2)
    self._container:getLabelByName("Label_star_xiayijie"):createStroke(Colors.strokeBrown,2)
    self._container:getLabelByName("Label_starProgress"):createStroke(Colors.strokeBrown,1)

    self._container:getLabelByName("Label_success_value"):createStroke(Colors.strokeBrown,1)
end


-- 加载装备升星配置表信息
function EquipmentStar:_loadEquipmentStarInfo()

	if self._equipmentStarInfo == nil then

		local baseInfo = self._equipment:getInfo()

		if baseInfo.equip_star_id > 0 then
			local starLevel = self._equipment.star >= self._equipment:getMaxStarLevel() and self._equipment.star - 1 or self._equipment.star
			self._equipmentStarInfo = equipment_star_info.get(starLevel, baseInfo.equip_star_id)

			local nextLevel = self._equipment:getNextStarLevel()
			self._equipmentNextStarInfo = equipment_star_info.get(nextLevel, baseInfo.equip_star_id)
		end
	end
	if self._equipmentStarInfo == nil then
		G_MovingTip:showMovingTip(G_lang:get("LANG_EQUIPMENT_STAR_CAN_NOT_DO_DESC"))
		if CCDirector:sharedDirector():getSceneCount() > 1 then 
            uf_sceneManager:popScene()
        else
            uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
        end
        return false
	end
	return true
end

function EquipmentStar:_reloadEquipmentStarInfo()
	self._equipmentStarInfo = nil
	self._equipmentNextStarInfo = nil
	self:_loadEquipmentStarInfo()
end

-- 更新左右两边属性栏信息
function EquipmentStar:_updateAttrsInfo()

	--当前升星属性
    local attrs = self._equipment:getStarAttrs() or {}
    self._attrs = attrs
    EquipmentInfo.setAttrLabels(self._container, attrs,  {"Label_starCurrentAttr1Title", "Label_starCurrentAttr1Value",} )


    --下个升星属性
    local ewai = self._equipmentNextStarInfo.star_value1 - self._equipmentStarInfo.star_value1 - self._equipmentStarInfo.bar_value

    local nextLevel = self._equipment:getNextStarLevel() or 0
    local next_attrs = clone(attrs)
    next_attrs[1].valueString = self._equipmentNextStarInfo.star_value1 - ewai

    local isMaxLevel = self._equipment.star >= self._equipment:getMaxStarLevel()
    self._container:getLabelByName("Label_starNextAttr2Title"):setText(isMaxLevel and "" or G_lang:get("LANG_EQUIPMENT_STAR_COST_EWAI"))
    
    self._container:getLabelByName("Label_starNextAttr2Value"):setText(isMaxLevel and "" or "+" .. ewai)

    EquipmentInfo.setAttrLabels(self._container, next_attrs,  {"Label_starNextAttr1Title", "Label_starNextAttr1Value",} )

    self._container:getLabelByName("Label_star_xiayijie"):setText(G_lang:get("LANG_EQUIPMENT_STAR_NEXT_LEVEL_DESC",
    {level = nextLevel}))
end

function EquipmentStar:_setCheckBoxState(st)

	self._checkstate = self._checkstate or 1
	self._checkstate = st or self._checkstate

	local goodsInfo = self:_getGoodsInfo()

	for i =1, 3 do

		self._checkBoxs[i]:setZOrder(3)
		self._checkBoxs[i]:setSelectedState(self._checkstate == i)
	end

	self:_updateNextAttrInfo()
end

-- 资源商品信息
function EquipmentStar:_getGoodsInfo()

	local goodsInfo = {}
	if self._equipmentStarInfo.money_cost > 0 then
		goodsInfo[#goodsInfo + 1] = G_Goods.convert(G_Goods.TYPE_MONEY, 0, self._equipmentStarInfo.money_cost)
	end
	if self._equipmentStarInfo.gold_cost > 0 then
		goodsInfo[#goodsInfo + 1] = G_Goods.convert(G_Goods.TYPE_GOLD, 0, self._equipmentStarInfo.gold_cost)
	end
	if self._equipmentStarInfo.fragment_id > 0 and self._equipmentStarInfo.fragment_cost > 0 then
		goodsInfo[#goodsInfo + 1] = G_Goods.convert(G_Goods.TYPE_FRAGMENT, self._equipmentStarInfo.fragment_id, 
			self._equipmentStarInfo.fragment_cost)
	end
	return goodsInfo
end

function EquipmentStar:_updateNextAttrInfo()
	local goodsInfo = self:_getGoodsInfo()
	local resId = EquipmentStar.GOODSMAP[goodsInfo[self._checkstate].type]
	local baseInfo = self._equipment:getInfo()

	self._nextAttrTitleLabel:setText(self._attrs[1].typeString .. G_lang:get("LANG_MAOHAO"))
    
    local nextValue = self._equipmentStarInfo.star_value1 + math.floor((self._equipment.star_exp + self._equipmentStarInfo["basic_exp_step" .. resId]) / self._equipmentStarInfo.total_exp * self._equipmentStarInfo.bar_value)
    local nowValue = self._equipmentStarInfo.star_value1 + math.floor(self._equipment.star_exp / self._equipmentStarInfo.total_exp * self._equipmentStarInfo.bar_value)
    self._nextAttrValueLabel:setText("+" .. (nextValue - nowValue))

    local isMaxLevel = self._equipment.star >= self._equipment:getMaxStarLevel()
    self._nextAttrPanel:setVisible(not isMaxLevel)
end

-- 更新资源数量信息
function EquipmentStar:_updateCostNumInfo()

	local goodsInfo = self:_getGoodsInfo()

	for i = 1, 3 do
		local goods = goodsInfo[i]
	
		-- 判断是否足够
		if goods and self._equipment.star < self._equipment:getMaxStarLevel() then

			local size
			local enough = true
			if goods.type == G_Goods.TYPE_MONEY then

				size = goods.size
				if size > G_Me.userData.money then enough = false end
			elseif goods.type == G_Goods.TYPE_GOLD then

				size = goods.size
				if size > G_Me.userData.gold then enough = false end
			elseif goods.type == G_Goods.TYPE_FRAGMENT then

				local fragment = G_Me.bagData.fragmentList:getItemByKey(self._equipmentStarInfo.fragment_id)
				local num = fragment and fragment.num or 0
				size = goods.size .. "/" .. num
				if goods.size > num then enough = false end
			end

			local costNumLabel = self._container:getLabelByName(string.format("Label_res_num%d", i))

			costNumLabel:setText(size)

			if not enough then
		        --字体设置红色

		        costNumLabel:setColor(Colors.lightColors.TIPS_01)
		    else
		        --字体设置白色

		        costNumLabel:setColor(Colors.lightColors.DESCRIPTION)
		    end
		end
	end

end

-- 更新资源显示信息
function EquipmentStar:_updateResourceInfo()

	local goodsInfo = self:_getGoodsInfo()

	for i = 1, 3 do
    	
    	local root = self._panelResouces[i]
    	local goods = goodsInfo[i]

    	self._panelResouces[i]:setVisible(true)

    	if goods and self._equipment.star < self._equipment:getMaxStarLevel() then

    		-- 商品对应的UI
    		local resId = EquipmentStar.GOODSMAP[goods.type]

    		local resTitleLabel = self._container:getLabelByName(string.format("Label_res_title%d", i))
    		resTitleLabel:setText(G_lang:get(string.format("LANG_EQUIPMENT_STAR_COST_TITLE%d", resId)))

    		local RES_PATH = {
    			[1] = {path = "icon_mini_yingzi.png", type_ = UI_TEX_TYPE_PLIST},
    			[2] = {path = "icon_mini_yuanbao.png", type_ = UI_TEX_TYPE_PLIST},
    			[3] = {path = "ui/equipment/icon_mini_suipian.png", type_ = UI_TEX_TYPE_LOCAL},
    		}

    		local resIconImage = self._container:getImageViewByName(string.format("Image_icon%d", i))
    		resIconImage:loadTexture(RES_PATH[resId].path, RES_PATH[resId].type_)

    		

			self._container:registerCheckboxEvent(string.format("CheckBox_Select%d", i), function()
				
				self:_setCheckBoxState(i)
			end)

			self._container:registerWidgetTouchEvent(string.format("Image_icon%d", i), function()
				
				self:_setCheckBoxState(i)
			end)

			self._container:registerWidgetTouchEvent(string.format("Label_res_title%d", i), function()
				
				self:_setCheckBoxState(i)
			end)

			self._container:registerWidgetTouchEvent(string.format("Label_res_num%d", i), function()
				
				self:_setCheckBoxState(i)
			end)
		else

			self._panelResouces[i]:setVisible(false)
		end
    end

    local pos = {26, -18, -64}
    if #goodsInfo == 1 then
    	self._panelResouces[1]:setPositionY(pos[2])
    elseif #goodsInfo == 2 then
    	self._panelResouces[1]:setPositionY((pos[1] + pos[2])/ 2)
    	self._panelResouces[2]:setPositionY((pos[2] + pos[3])/ 2)
    elseif #goodsInfo == 3 then
    	self._panelResouces[1]:setPositionY(pos[1])
    	self._panelResouces[2]:setPositionY(pos[2])
    	self._panelResouces[3]:setPositionY(pos[3])
    end


    self:_updateCostNumInfo()

end

-- 更新星星显示
function EquipmentStar:_updateStarInfo()

	local baseInfo = self._equipment:getInfo()
	local star4Image = self._container:getImageViewByName("Image_start_4")
	local star5Image = self._container:getImageViewByName("Image_start_5")

	if baseInfo.potentiality < EquipmentConst.Star_Potentiality_FiveStar_Value then

		self._starsEquipPanel:setPositionX(38)
		star4Image:setVisible(false)
		star5Image:setVisible(false)
	else

		self._starsEquipPanel:setPositionX(-3)
		star4Image:setVisible(true)
		star5Image:setVisible(true)
	end

	local starLevel = self._equipment.star or 0

	for i = 1, EquipmentConst.Star_MAX_LEVEL do

		self._starImageViews[i]:setVisible(i <= starLevel)
	end
end

-- 更新进度条
function EquipmentStar:_updateProgress()

	-- 进度条
    local completeRait = self._equipment.star_exp / self._equipmentStarInfo.total_exp * 100
    if self._equipment.star >= self._equipment:getMaxStarLevel() then
    	-- 满级界面显示
    	completeRait = 100
    	self._loadingBar:setPercent(100)
    	self._barLabel:setText(string.format("%d/%d", self._equipmentStarInfo.total_exp, self._equipmentStarInfo.total_exp))
    	self._jingzhiStarEffect:setVisible(false)
    else
    	self._jingzhiStarEffect:setVisible(true)
    	self._loadingBar:setPercent(completeRait)
    	self._barLabel:setText(string.format("%d/%d", self._equipment.star_exp, self._equipmentStarInfo.total_exp))
    end

    self._starEffectPanel:setPositionX(completeRait * EquipmentStar.PROGRESSSTEP)

    
end

-- 成功率信息
function EquipmentStar:_getSuccessGailvInfo()

	local t_info = {
		[1] = {txt = G_lang:get("LANG_EQUIPMENT_STAR_COST_SUCCESS1"), color = Colors.uiColors.BLUE },
		[2] = {txt = G_lang:get("LANG_EQUIPMENT_STAR_COST_SUCCESS2"), color = Colors.uiColors.PURPLE },
		[3] = {txt = G_lang:get("LANG_EQUIPMENT_STAR_COST_SUCCESS3"), color = Colors.uiColors.ORANGE },
	}

	local value = self._equipmentStarInfo.basic_success + math.floor(self._equipment.luck_value * EquipmentConst.Lucky_Beilv)
	if value > self._equipmentStarInfo.max_success then
		value = self._equipmentStarInfo.max_success
	end

	local inter = 1
	if value <= 50 then
		inter = 1
	elseif value < 70 then
		inter = 2
	elseif value <= 100 then
		inter = 3
	end

	return t_info[inter]
end

-- 更新幸运值信息
function EquipmentStar:_updateLuckValue()

	self._luckPanel:setVisible(self._equipment.star >= 1)
	self._successPanel:setPositionX(self._equipment.star >= 1 and 64 or 250)

	self._luckyValueLabel:setText(self._equipment.luck_value)
    self._luckyDescLabel:setPositionX(self._luckyValueLabel:getPositionX() + self._luckyValueLabel:getContentSize().width + 4)

    local successInfo = self:_getSuccessGailvInfo()
    self._successLabel:setText(successInfo.txt)
    self._successLabel:setColor(successInfo.color)

    if self._equipment.star >= self._equipment:getMaxStarLevel() then
    	self._luckPanel:setVisible(false)
		self._successPanel:setVisible(false)
    end
end

function EquipmentStar:_setAllStarState()
	local isMax = self._equipment.star >= self._equipment:getMaxStarLevel()
	self._container:showWidgetByName("Image_progress_bg",not isMax)
	self._container:showWidgetByName("ImageView_res_bg",not isMax)
	self._container:showWidgetByName("Button_star",not isMax)
	self._container:showWidgetByName("Panel_starNext",not isMax)
	self._container:showWidgetByName("Label_starProgress",not isMax)
	self._container:showWidgetByName("Label_full",isMax)
end

function EquipmentStar:updateView()

	G_Me.equipmentData:updateLuck()

	if not self._equipment then
		self._equipment = self._container:getEquipment()
	end

	self._isPlayingAnim = false
	self._starButton:setTouchEnabled(true)

	-- 加载配置信息
	if not self:_loadEquipmentStarInfo() then
		return
	end

	self:_updateStarInfo()

	self:_updateAttrsInfo()

    -- 幸运值
    self:_updateLuckValue()

    -- 进度条
    self:_updateProgress()

    -- 更新资源icon显示
    self:_updateResourceInfo()

    -- 更新选择状态
    self:_setCheckBoxState()

    self:_setAllStarState()

end

function EquipmentStar:_doStar()
	self:stopAllEffect()
	self:updateView()

    if self._equipment.star >= self._equipment:getMaxStarLevel() then
    	G_MovingTip:showMovingTip(G_lang:get("LANG_EQUIPMENT_STAR_LEVEL_LIMIT"))
    	return
    end

    local goodsInfo = self:_getGoodsInfo()

    local goods_type = goodsInfo[self._checkstate].type

    if goods_type == G_Goods.TYPE_MONEY then

    	if G_Me.userData.money < self._equipmentStarInfo.money_cost then
    		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
    			GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {self._equipment, EquipmentConst.StarMode}))
    		return
    	end
    elseif goods_type == G_Goods.TYPE_GOLD then

    	if G_Me.userData.gold < self._equipmentStarInfo.gold_cost then
    		require("app.scenes.shop.GoldNotEnoughDialog").show()
    		return
    	end
    elseif goods_type == G_Goods.TYPE_FRAGMENT then

    	local fragment = G_Me.bagData.fragmentList:getItemByKey(self._equipmentStarInfo.fragment_id)
    	if fragment == nil or fragment.num < self._equipmentStarInfo.fragment_cost then
    		require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, self._equipmentStarInfo.fragment_id,
    			GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {self._equipment, EquipmentConst.StarMode}))
    		return
    	end
    end

    local cost_type = EquipmentStar.GOODSMAP[goodsInfo[self._checkstate].type]
    -- 碎片的话，type要改成6
    if cost_type == EquipmentStar.GOODSMAP[G_Goods.TYPE_FRAGMENT] then cost_type = 6 end

    self._oldStarLevel = self._equipment.star
    self._oldLuckValue = self._equipment.luck_value
    self._oldExp = self._equipment.star_exp
    self._attrs = self._equipment:getStarAttrs() or {}
    self._oldAttrs = clone(self._attrs)
    self._oldExpTotal = self._equipmentStarInfo.total_exp
    self._oldEWai = self._equipmentNextStarInfo.star_value1 - self._equipmentStarInfo.star_value1 - self._equipmentStarInfo.bar_value
	-- for i = 1, 10 do
		G_HandlersManager.equipmentStrengthenHandler:sendUpStarEquipment(cost_type, self._equipment.id)
	-- end
end


function EquipmentStar:_onStarResult(data)
	self:_updateCostNumInfo()
	self._equipmentStarInfo = nil
	self:_loadEquipmentStarInfo()

	local container = self._container
	local equipment = container:getEquipment()
	local oldAttrs  = self._oldAttrs
	local newAttrs  = equipment:getStarAttrs()
	local isSucced  = equipment.star_exp ~= self._oldExp
	local isUpLevel = self._oldStarLevel + 1 == equipment.star

	if isUpLevel then self._checkstate = 1 end

    self._starButton:setTouchEnabled(false)

    local function playlightAnim()

    	if not self._isPlayingAnim then return end

		self:_playLightEffect(function()
	    	EquipmentStarResultLayer.showEquipmentStarResultLayer(equipment, oldAttrs, function()

	    		self._starButton:setTouchEnabled(true)
	    		self._isPlayingAnim = false
	    		self:updateView()
	    		self:_playLevelUpStarEffect(equipment.star)
	    	end)
	    end)
	end

	local function playBigFaguangAnim()

		if not self._isPlayingAnim then return end

		self:_playBigFaguangEffect(playlightAnim)
	end

    local function playAttrAnim()

    	if not self._isPlayingAnim then return end

    	self:_playAttrAnim(data, oldAttrs, newAttrs, isUpLevel, function()

    		if isUpLevel then
    			self:_playStarFlyToEquipmentAction(playBigFaguangAnim)
    		else
    			self:_updateNextAttrInfo()
    			-- self._isPlayingAnim = false
    		end
    	end)
	end

	local function playResultAnim()

		if not self._isPlayingAnim then return end

		if not isUpLevel then
			self._starButton:setTouchEnabled(true)
		end

		if isSucced then

			playAttrAnim()
	    	
    	else
    		local attrs = {}
    		attrs[1] = {}
    		attrs[1].typeString = G_lang:get("LANG_EQUIPMENT_STAR_LUCK")
    		attrs[1].delta = equipment.luck_value - self._oldLuckValue
    		self:_flyAttr(attrs, G_lang:get("LANG_EQUIPMENT_STAR_STAR_FAILE"), Colors.uiColors.LYELLOW, "Label_luck_value", function()
    			self:_updateLuckValue()
    			self._starButton:setTouchEnabled(true)
    			-- self._isPlayingAnim = false
    		end)

    	end
	end

	local function playShanGaungAnim()
		if not self._isPlayingAnim then return end
		if isSucced then
     		self:_playMiniFaguangEffect()	
     	end
     	playResultAnim()
	end

    local function playFireAnim()
    	if not self._isPlayingAnim then return end
    	self:_playBigFireEffect(playShanGaungAnim)
    end

    self._isPlayingAnim = true

    playFireAnim()
end

function EquipmentStar:stopAllEffect()

	G_flyAttribute._clearFlyAttributes()
	self:_stopBigFireEffect()
	self:_stopMiniFaguangEffect()
	self:_stopBigFaguangEffect()
	self:_stopLightEffect()
	self:_stopBaojiEffect()
	self:_stopStarFlyToEquipmentAction()
	self._loadingBar:stopAllActions()
	self._container:stopAllActions()
	self._isPlayingAnim = false
end

-- 生大火的特效
function EquipmentStar:_playBigFireEffect(cb)

	if self._fire == nil then
	    self._fire = EffectNode.new("effect_hotfire", 
	        function(event, frameIndex)
	            if event == "finish" then
	               
	            	self:_stopBigFireEffect()
	                if cb then cb() end
	            end
	        end
	    )
	    self._fire:setPositionXY(0,-100)
    	self._fire:setScale(2)
	    self._container:getEffectNode():addNode(self._fire)
  	end

  	self._fire:play()
end

function EquipmentStar:_stopBigFireEffect()
	if self._fire then
        self._fire:removeFromParentAndCleanup(true)
        self._fire = nil
    end
end

-- 小的发光特效
function EquipmentStar:_playMiniFaguangEffect(cb)
	if self._miniFagangEffect == nil then
		self._miniFagangEffect = EffectNode.new("effect_particle_star", 
            function(event, frameIndex)
                if event == "forever" then
                    
                	self:_stopMiniFaguangEffect()
	                if cb then cb() end
                end
            end
        )
        self._container:getEffectNode():addNode(self._miniFagangEffect)
	end

	self._miniFagangEffect:play()
end

function EquipmentStar:_stopMiniFaguangEffect()
	if self._miniFagangEffect then
	    self._miniFagangEffect:removeFromParentAndCleanup(true)
	    self._miniFagangEffect = nil
	end
end

-- 大的发光特效
function EquipmentStar:_playBigFaguangEffect(cb)
	if self._bigFagangEffect == nil then
		self._bigFagangEffect = EffectNode.new("effect_zbsx_over", 
            function(event, frameIndex)
                if event == "finish" then
                    
                	self:_stopBigFaguangEffect()
	                if cb then cb() end
                end
            end
        )
        self._container:getEffectNode():addNode(self._bigFagangEffect)
	end

	self._bigFagangEffect:play()
end

function EquipmentStar:_stopBigFaguangEffect()
	if self._bigFagangEffect then
	    self._bigFagangEffect:removeFromParentAndCleanup(true)
	    self._bigFagangEffect = nil
	end
end

-- 全屏发光特效
function EquipmentStar:_playLightEffect(cb)
	
	if self._lightEffect == nil then
		self._lightEffect = EffectNode.new("effect_circle_light", function(event, frameIndex)
	        if event == "finish" then
	        	
	        	self:_stopLightEffect()
	            if cb then cb() end
	        end
	    end)
        uf_sceneManager:getCurScene():addChild(self._lightEffect)
	end
    -- 白光特效从中间开始扩散
    self._lightEffect:setPositionXY(display.cx,display.cy)
    self._lightEffect:play()
end

function EquipmentStar:_stopLightEffect()
	if self._lightEffect then
    	self._lightEffect:removeFromParentAndCleanup(true)
    	self._lightEffect = nil
    end
end

-- 暴击特效
function EquipmentStar:_playBaojiEffect(cb)
	if self._baojiEffect == nil then
		self._baojiEffect = EffectNode.new("effect_baoji", 
	        function(event, frameIndex)
	            if event == "finish" then

	                self:_stopBaojiEffect()
			        if cb then cb() end
	            end
	        end,
	        nil,
	        nil,
	        function (sprite, png, key) 
	            
	            return true, CCSprite:create(G_Path.getTextPath("zbyc_baoji.png"))
	        end
	    )
	end
	self._baojiEffect:play()
    self._container:getEffectNode():addNode(self._baojiEffect,3)
end

function EquipmentStar:_stopBaojiEffect()
	if self._baojiEffect ~= nil then
		self._baojiEffect:stop()
		self._container:getEffectNode():removeChild(self._baojiEffect)
		self._baojiEffect = nil
	end
end

-- 星星移动到装备特效
function EquipmentStar:_playStarFlyToEquipmentAction(cb)
	self._moveStarEffect:setVisible(false)
	self._jingzhiStarEffect:setVisible(false)
	if self._equipStarEffect == nil then
		self._equipStarEffect = EffectNode.new("effect_zbsx_startgun_a")
		uf_sceneManager:getCurScene():addChild(self._equipStarEffect,7)
	end

	local container = self._container
    local equipment = container:getEquipment()

	local starPanel = container:getPanelByName("Panel_star")
   	local stareffectPanel = container:getPanelByName("Panel_star_effect")

    local startx, starty = starPanel:convertToWorldSpaceXY(stareffectPanel:getPositionX(), stareffectPanel:getPositionY())

	self._equipStarEffect:setPositionXY(startx, starty)

	local imageBG = container:getImageViewByName("ImageView_bg")
	local imageEquip = container:getImageViewByName("ImageView_pic")
	local endx, endy = imageBG:convertToWorldSpaceXY(imageEquip:getPositionX(), imageEquip:getPositionY())
	self._equipStarEffect:setRotation(EquipmentStar.calAngle(startx, starty, endx, endy))

	self._equipStarEffect:play()
	
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(1, ccp(endx, endy)))
	arr:addObject(CCCallFunc:create(function()
			
			self:_stopStarFlyToEquipmentAction()
			if cb then cb() end
			
		end))
	self._equipStarEffect:runAction(CCSequence:create(arr))
end

function EquipmentStar:_stopStarFlyToEquipmentAction()

	if self._equipStarEffect then
    	self._equipStarEffect:removeFromParentAndCleanup(true)
    	self._equipStarEffect = nil
    end
end

-- 星星移动的动作
function EquipmentStar:_playStarMoveAction(completeRait, cb)

	self._moveStarEffect:setVisible(true)
	self._jingzhiStarEffect:setVisible(false)

	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(0.5, ccp(completeRait * EquipmentStar.PROGRESSSTEP, self._starEffectPanel:getPositionY())))
	arr:addObject(CCCallFunc:create(function()

			self._moveStarEffect:setVisible(false)
			self._jingzhiStarEffect:setVisible(true)

			if cb then cb() end
			
		end))
	
	self._starEffectPanel:runAction(CCSequence:create(arr))
end

-- 进度条移动
function EquipmentStar:_playProgressAction(isLevelUp, cb)

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(2.6))
	arr:addObject(CCCallFunc:create(function()

			local completeRait = self._equipment.star_exp / self._equipmentStarInfo.total_exp * 100
			completeRait = completeRait > 100 and 100 or completeRait
			if isLevelUp then completeRait = 100 end
			self._loadingBar:runToPercent(completeRait, 3)

			self:_playStarMoveAction(completeRait, cb)
			
		end))
	self._loadingBar:runAction(CCSequence:create(arr))
end

-- 升级加星动画
function EquipmentStar:_playLevelUpStarEffect(level, cb)
    
    local imgStar = self._starImageViews[level]
    imgStar:stopAllActions()
    imgStar:setPositionY(imgStar:getPositionY() + 30)
    imgStar:setOpacity(0)
    imgStar:setVisible(true)

    local actionArr = CCArray:create()
    actionArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.3, ccp(0, -30)), CCFadeIn:create(0.3)))
    actionArr:addObject(CCCallFunc:create(function()

        imgStar:removeAllNodes()

        local _effectStar = EffectNode.new("effect_juexing_c")
        imgStar:addNode(_effectStar)
        _effectStar:play()

        if cb then cb() end
    end))

    imgStar:runAction(CCSequence:create(actionArr))
end

function EquipmentStar:_playAttrAnim(data, oldAttrs, newAttrs, isUpLevel, cb)

	if not self._isPlayingAnim then return end
	-- 暴击
	if data.crit > 1 then
		self:_playBaojiEffect()
	end

	--属性变化:
    for i=1,#oldAttrs do
    	if oldAttrs[i].type then
        	local deltaString
        	if isUpLevel then
        		-- fuck,谦信这里让计算一个满经验的数值用来显示
    			local attrValue = newAttrs[i].value - self._oldEWai
    			deltaString = G_lang.getGrowthValue(oldAttrs[i].type, attrValue - oldAttrs[i].value)
    			oldAttrs[i].value = attrValue
    		else

    			deltaString = G_lang.getGrowthValue(oldAttrs[i].type, newAttrs[i].value - oldAttrs[i].value)
        	end
        	
        	oldAttrs[i].delta = deltaString
        end
    end

    local attr = {}
    attr.typeString = G_lang:get("LANG_EQUIPMENT_STAR_EXP")
    if isUpLevel then
    	attr.delta = self._oldExpTotal - self._oldExp
    else
    	attr.delta = self._equipment.star_exp - self._oldExp
    end
    

    local color = Colors.uiColors.ORANGE
    local baojiTxt = ""
    if data.crit > 1 then

    	baojiTxt = G_lang:get("LANG_EQUIPMENT_STAR_ATTR_BAOJI", {num = data.crit / 10})
    	local isBigBaoji = false
    	if self._equipmentStarInfo.exp_doge_value2 == data.crit then
    		isBigBaoji = true
    	end
    	color = isBigBaoji and Colors.uiColors.YELLOW or Colors.uiColors.RED
    end

    oldAttrs[#oldAttrs + 1] = attr

    self:_flyAttr(oldAttrs, G_lang:get("LANG_EQUIPMENT_STAR_STAR_MOVE") .. baojiTxt, color, 
			"Label_starCurrentAttr1Value", function()
				if not isUpLevel then
					self._starButton:setTouchEnabled(true)
				end
				
			end)
	

	self:_playProgressAction(isUpLevel, function()
		if cb then cb() end
	end)
end

-- 属性飞行动画
function EquipmentStar:_flyAttr(attrsNext, title_text, color, value_label, finish_callback)
    if not self._container or not self._container.isRunning or not self._container:isRunning() then 
        return 
    end

    G_flyAttribute._clearFlyAttributes()

    local deltaLevel = 1
    local levelTxt = title_text

    local basePic = self._container:getImageViewByName("ImageView_pic")
    local basePos = basePic:getParent():convertToWorldSpace(ccp(basePic:getPosition()))
    local size = basePic:getContentSize()
    G_flyAttribute.addNormalText(levelTxt,color or Colors.uiColors.ORANGE, self._container:getLabelByName(value_label))
    
    --属性加成
    for i, attrInfo in ipairs(attrsNext) do 
        local labelName 
        if i == 1 then
            labelName = value_label
        elseif i == 2 then
        	labelName = "Label_starProgress"
        else
            break
        end
        --print("attr" .. i .. "," .. attrInfo.typeString  .. ":" .. attrInfo.delta)
        G_flyAttribute.addAttriChange(attrInfo.typeString, attrInfo.delta, self._container:getLabelByName(labelName))
    end
    attrsNext = {}

    G_flyAttribute.play(function ( ... )
    	if not self._isPlayingAnim then return end
    	if finish_callback then
        	finish_callback()
        end
    end)
end

function EquipmentStar:setTouchable(able)

    self._starButton:setTouchEnabled(able)
end

function EquipmentStar:onLayerUnload()
   
	uf_eventManager:removeListenerWithTarget(self)
end

return EquipmentStar