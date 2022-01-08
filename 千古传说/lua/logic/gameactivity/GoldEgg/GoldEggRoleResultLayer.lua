
local GoldEggRoleResultLayer = class("GoldEggRoleResultLayer", BaseLayer)

function GoldEggRoleResultLayer:ctor(data)
	self.cardType 	= data[1]
	self.roleIndex = data[2]
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.zadan.GetRoleResultLayer")
    	self:PlayStartEffect()
    	play_zhaomu_chouquxiake()
end

function GoldEggRoleResultLayer:setEggType(EggType)
	self.EggType = EggType
end

function GoldEggRoleResultLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.rolebgImg = TFDirector:getChildByPath(ui, "rolebgImg")
	self.rolebgImg:setVisible(false)
	self.ui = ui


	self.getCardBtn 	= TFDirector:getChildByPath(ui, "getCardBtn")
	self.getTenCardBtn  = TFDirector:getChildByPath(ui, "getTenCardBtn")
	self.getCardBtn:setVisible(false)
	self.getTenCardBtn:setVisible(false)
	self.getCardBtn.logic 		= self
	self.getTenCardBtn.logic 	= self
	self.getCardBtn.times 		= 1
	self.getTenCardBtn.times 	= 10
end

function GoldEggRoleResultLayer:registerEvents(ui)
	self.super.registerEvents(self)

	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
    ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)
    self.returnBtn.logic = self
    self.returnBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickComfirm),1)

    self.zhiyePanel = TFDirector:getChildByPath(ui, 'zyImg')
    self.zhiyePanel:setVisible(false)

    self.jieshaoPanel = TFDirector:getChildByPath(ui, 'jsImg')
    self.jieshaoPanel:setVisible(false)


    self.getCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)
    self.getTenCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)

	self.ui:setTouchEnabled(false)
	if self.cardType == 3 then
		-- self.ui:setTouchEnabled(true)
		self.ui:addMEListener(TFWIDGET_CLICK, 
		audioClickfun(function()
			local roleIndex = self.roleIndex
			AlertManager:close()
			local tenLayer = AlertManager:getLayerByName("lua.logic.gameactivity.GoldEgg.GoldEggTenRoleResultLayer")
			if tenLayer ~= nil then
				tenLayer:ShowRoleIcon(roleIndex)
			end
		end))
	end
end

function GoldEggRoleResultLayer:PlayStartEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm1.xml")
	local effect = TFArmature:create("zm1_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(-100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))

	self.ui:addChild(effect)

	local timerID = TFDirector:addTimer(200, 1, nil,
	function()
		-- self.ui:setTouchEnabled(false)
		-- self.ui:removeMEListener(TFWIDGET_CLICK)
		TFDirector:removeTimer(timerID)
		self:PlayShowRoleEffect()
	end)

	-- self.ui:setTouchEnabled(true)
	-- self.ui:addMEListener(TFWIDGET_CLICK, 
	-- audioClickfun(function()
	-- 	self.ui:setTouchEnabled(false)
	-- 	effect:setAnimationScale(100)
	-- 	TFDirector:removeTimer(timerID)
	-- 	self:PlayShowRoleEffect()
	-- 	self.ui:removeMEListener(TFWIDGET_CLICK)
	-- end),1)
end

function GoldEggRoleResultLayer:PlayShowRoleEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm3.xml")
	local effect = TFArmature:create("zm3_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(-99)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 1)
	effect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2 + 130))
	self.ui:addChild(effect)

	TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm4.xml")
	local roleBgEffect = TFArmature:create("zm4_anim")
	if roleBgEffect == nil then
		return
	end
	roleBgEffect:setZOrder(10)
	roleBgEffect:setAnimationFps(GameConfig.ANIM_FPS)
	roleBgEffect:playByIndex(0, -1, -1, 0)
	roleBgEffect:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2))
	self.ui:addChild(roleBgEffect)

	self:ShowRole()
end

function GoldEggRoleResultLayer:ShowRole()
	local newCardRoleData = RoleData:objectByID(GoldEggManager.getCardTypeList[self.roleIndex].resId)
	if newCardRoleData == nil then
		print(GoldEggManager.getCardTypeList[self.roleIndex].resId.."role not find")
		assert(false)
		return
	end
	RoleSoundData:playSoundByIndex(GoldEggManager.getCardTypeList[self.roleIndex].resId)
	self.rolebgImg:setVisible(true)
	local nameLabel = TFDirector:getChildByPath(self.rolebgImg, "nameLabel")
	local tipLabel = TFDirector:getChildByPath(self.rolebgImg, "tipLabel")
	local gxhdImg = TFDirector:getChildByPath(self.rolebgImg, "gxhdImg")
	local qualityIcon = TFDirector:getChildByPath(self.rolebgImg, "qualityIcon")
	local footImg = TFDirector:getChildByPath(self.rolebgImg, "footImg")
	footImg:setVisible(false)
	nameLabel:setVisible(false)
	tipLabel:setVisible(false)
	gxhdImg:setVisible(false)
	qualityIcon:setVisible(false)

	local roleImg = TFDirector:getChildByPath(self.rolebgImg, "roleImg")
	roleImg:setTexture(newCardRoleData:getBigImagePath())
	roleImg:setScale(2)
	roleImg:setOpacity(80)
	local roleTween = 
	{
		target = roleImg,
		{
			duration = 0.3,
			alpha = 255,
			scale = 0.2,
		},
		{ 
   			duration = 0.2,
   			scale = 0.43,

   			onComplete = function ()
				self:OnRoleShowEnd(newCardRoleData)
				self:ShowRoleDetail(newCardRoleData)
			end	
		},
	}
	TFDirector:toTween(roleTween)
end

function GoldEggRoleResultLayer:DrawAttrPolygon(attribute_level)
 	local attrPolygon = TFDrawNode:create()
    self.zhiyePanel:addChild(attrPolygon)
    attrPolygon:setColor(ccc4(0x5b,0xc4,0xff, 80))
    attrPolygon:setBorderWidth(0)

    local attrLevel = string.split(attribute_level, ",")
    for i=1,#attrLevel do
    	attrLevel[i] = 0.4 + 0.6*attrLevel[i]/10
    	attrLevel[i] = math.min(1, attrLevel[i])
    end

    local tb = 
    {
        ccp(0, 68*attrLevel[1]), 
        ccp(70*attrLevel[4],  15*attrLevel[4]),
        ccp(43*attrLevel[5], -68*attrLevel[5]), 
        ccp(-43*attrLevel[3],-68*attrLevel[3]), 
        ccp(-70*attrLevel[2], 15*attrLevel[2])
    }

    attrPolygon:drawPolygon(tb)
    attrPolygon:setPosition(ccp(0, 26))
end

function GoldEggRoleResultLayer:ShowRoleDetail(newCardRoleData)
	self.zhiyePanel:setVisible(true)

	local zhiyeIcon = TFDirector:getChildByPath(self.zhiyePanel, "zhiyeIcon")
	zhiyeIcon:setTexture("ui_new/common/img_zy"..newCardRoleData.outline..".png")

	local zhiyeLabel = TFDirector:getChildByPath(self.zhiyePanel, "zhiyeLabel")
	zhiyeLabel:setText(newCardRoleData.attr_description)

	local trainItem = RoleTrainData:getRoleTrainByQuality(newCardRoleData.quality, 0)
	local attribute = GetAttrByString(newCardRoleData.attribute)
	local attrLevel = string.split(newCardRoleData.attribute_level, ",")

	local temp = attrLevel[4]
	attrLevel[4] = attrLevel[3]
	attrLevel[3] = temp
	local maxAttrIndex = 1
	local maxAttrNum = 0
	for i=1,5 do
		local attrImg = TFDirector:getChildByPath(self.zhiyePanel, "attrImg"..i)
		local numberLabel = TFDirector:getChildByPath(attrImg, "numberLabel")
		local attrNum = math.floor(attribute[i]*trainItem.streng_then)
		numberLabel:setText(attrNum)
		if tonumber(attrLevel[i]) > maxAttrNum then
			maxAttrIndex = i
			maxAttrNum = tonumber(attrLevel[i])
		end
	end

	self:DrawAttrPolygon(newCardRoleData.attribute_level)

	local imgName = {"zm_qixue2", "zm_wuli2", "zm_fangyu2", "zm_neili2", "zm_shenfa2"}
	local maxAttrImg = TFDirector:getChildByPath(self.zhiyePanel, "attrImg"..maxAttrIndex)
	maxAttrImg:setTexture("ui_new/shop/"..imgName[maxAttrIndex]..".png")

	local panelPos = self.zhiyePanel:getPosition()
	self.zhiyePanel:setPosition(ccp(0, panelPos.y))
	local zhiyeMoveTween = 
	{
		target = self.zhiyePanel,
		{
			duration = 0.2,
			x = panelPos.x,
			y = panelPos.y,

			onComplete = function ()
				self.ui:setTouchEnabled(true)
			end
		},
	}
	TFDirector:toTween(zhiyeMoveTween)

	self.jieshaoPanel:setVisible(true)
	local tipLabel = TFDirector:getChildByPath(self.jieshaoPanel, "tipLabel")
	tipLabel:setText(newCardRoleData.description)

	panelPos = self.jieshaoPanel:getPosition()
	self.jieshaoPanel:setPosition(ccp(GameConfig.WS.width, panelPos.y))
	local jieshaoMoveTween = 
	{
		target = self.jieshaoPanel,
		{
			duration = 0.3,
			x = panelPos.x,
			y = panelPos.y,
		},
	}
	TFDirector:toTween(jieshaoMoveTween)
end

function GoldEggRoleResultLayer:OnRoleShowEnd(newCardRoleData)
	local rolebgImg = self.rolebgImg

	local nameLabel = TFDirector:getChildByPath(rolebgImg, "nameLabel")
	nameLabel:setVisible(true)
	nameLabel:setText(newCardRoleData.name)

	local footImg = TFDirector:getChildByPath(rolebgImg, "footImg")
	footImg:setVisible(true)
	footImg:setTexture("ui_new/shop/zm_role"..newCardRoleData.quality..".png")

	local tipLabel = TFDirector:getChildByPath(rolebgImg, "tipLabel")
	local gxhdImg = TFDirector:getChildByPath(rolebgImg, "gxhdImg")
	if GoldEggManager.getCardTypeList[self.roleIndex].number == 0 then
		local pos = nameLabel:getPosition()
		tipLabel:setVisible(false)
		gxhdImg:setVisible(false)
	else
		tipLabel:setVisible(true)
		--tipLabel:setText("此侠客自动转换为"..GoldEggManager.getCardTypeList[self.roleIndex].number.."张同角色魂卡")
		tipLabel:setText(stringUtils.format(localizable.goldEggRole_zhuanhuan,GoldEggManager.getCardTypeList[self.roleIndex].number))		
		gxhdImg:setVisible(true)
	end

	local qualityIcon = TFDirector:getChildByPath(rolebgImg, "qualityIcon")
	qualityIcon:setTexture(GetFontByQuality(newCardRoleData.quality))
	qualityIcon:setVisible(true)

	local getCardBtnPath = {"ui_new/shop/zmdj.png", "ui_new/shop/zmj.png", "ui_new/shop/zmjs.png"}
	self.getCardBtn:setTextureNormal(getCardBtnPath[self.cardType])

	if self.cardType ~= 3 then
		-- self.getCardBtn:setVisible(true)
		self.returnBtn:setVisible(true)
		self:drawBtn(true)
	else
		self.returnBtn:setVisible(true)
		self:drawBtn(false)
	end

end


function GoldEggRoleResultLayer:drawBtn(bIsVisible)
	self.getTenCardBtn:setVisible(bIsVisible)
	self.getCardBtn:setVisible(bIsVisible)

	local img_icon1  = TFDirector:getChildByPath(self.getCardBtn, 'img_cost') 
	local img_icon2  = TFDirector:getChildByPath(self.getTenCardBtn, 'img_cost') 

	local txt_cost1 = TFDirector:getChildByPath(self.getCardBtn, 'txt_cost') 
	local txt_cost2 = TFDirector:getChildByPath(self.getTenCardBtn, 'txt_cost')

	local eggType = self.EggType
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    txt_cost1:setText(eggInfo.number)
    txt_cost2:setText(eggInfo.number*10)

    local iconPath = "ui_new/zadan/"
    if eggType == 1 then
		iconPath = iconPath .. "img_yincz.png"
	elseif eggType == 2 then
		iconPath = iconPath .. "img_jincz.png"
	end
	img_icon1:setTexture(iconPath)
	img_icon2:setTexture(iconPath)
end

function GoldEggRoleResultLayer:reqeustHitEgg(times)
    --local hammerDesc = {"银锤子", "金锤子"}
    local hammerDesc = localizable.goldEggItem_hammer_type

	local eggType = self.EggType
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    local commonReward = {}
    commonReward.type   = tonumber(eggInfo.resType)
    commonReward.itemid = tonumber(eggInfo.resId)
    commonReward.number = tonumber(eggInfo.number)
    local rewarddata = BaseDataManager:getReward(commonReward)

    local myToolNum = MainPlayer:getGoodsNum(rewarddata)
	
    if myToolNum < (commonReward.number * times) then
        --toastMessage("没有足够的"..hammerDesc[eggType])
        toastMessage(stringUtils.format(localizable.goldEggItem_no_hammer,hammerDesc[eggType]))
        return false
    end

    return true
end


function GoldEggRoleResultLayer.onClickAgain(sender)
  	local self  = sender.logic
  	local tiems = sender.times

  	if self:reqeustHitEgg(tiems) == false then
  		return
  	end

  	GoldEggManager:RequestBreakGoldEgg(self.EggType, tiems)
	self.getCardCompelete = false
	AlertManager:close()
end

function GoldEggRoleResultLayer.onClickComfirm(sender)
  	local self  = sender.logic

  	print("11GoldEggRoleResultLayer.onClickComfirm  cardType= ", self.cardType)
  	print("222GoldEggRoleResultLayer.onClickComfirm roleIndex= ", self.roleIndex)
  	if self.cardType == 3 then
		local roleIndex = self.roleIndex
		AlertManager:close()
		local tenLayer = AlertManager:getLayerByName("lua.logic.gameactivity.GoldEgg.GoldEggTenRoleResultLayer")
		if tenLayer ~= nil then
			tenLayer:ShowRoleIcon(roleIndex)
		end
	else
		AlertManager:close()
	end
end


return GoldEggRoleResultLayer
