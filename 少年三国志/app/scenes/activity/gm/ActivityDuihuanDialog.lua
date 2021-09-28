local ActivityDuihuanDialog = class("ActivityDuihuanDialog",UFCCSModelLayer)

function ActivityDuihuanDialog.show(quest,callback)
	local curQuest = G_Me.activityData.custom:getCurQuestByQuest(quest)
	local leftTime = quest.award_limit - curQuest.award_times
	if leftTime > 0 then
		local layer = ActivityDuihuanDialog.create(quest,callback)
		uf_sceneManager:getCurScene():addChild(layer)
	else

	end
end

function ActivityDuihuanDialog.create(quest,callback)
	return ActivityDuihuanDialog.new("ui_layout/shop_PurchaseDialog.json",require("app.setting.Colors").modelColor,quest,callback)
end

function ActivityDuihuanDialog:ctor(json,color,quest,callback)
	self.super.ctor(self)
	self._quest = quest
	self.good = G_Goods.convert(self._quest.consume_type1,self._quest.consume_value1,self._quest.consume_size1)
	self:showAtCenter(true)
	self:_setWidgets()
	self:_initEvent()
	self._maxNum = self:_getMaxNum()
	self._buyNum = 1
	self._callback = callback
end


function ActivityDuihuanDialog:_setWidgets()
	self:getLabelByName("Label_item_num"):createStroke(Colors.strokeBrown,1)
	self:showTextWithLabel("Label_item_num","x" .. self.good.size)
	self:enableLabelStroke("Label_name01", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_jian10", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_jian1", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_jia10", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_jia1", Colors.strokeBrown,1)
	self:enableLabelStroke("Label_item_num", Colors.strokeBrown,1)
	self:showTextWithLabel("Label_name01",self.good.name)
	self:getLabelByName("Label_name01"):setColor(Colors.qualityColors[self.good.quality])
	local _num,name= G_Me.bagData:getNumByTypeAndValue(self.good.type,self.good.value)
	local ownNumLabel = self:getLabelByName("Label_num")
	if not name then
	    --name为空，使用默认单位"个"
	    ownNumLabel:setText(G_lang:get("LANG_GOODS_NUM",{num=_num}))
	else
	    ownNumLabel:setText(_num .. name)
	end
	local curQuest = G_Me.activityData.custom:getCurQuestByQuest(self._quest)
	local leftTime = self._quest.award_limit - curQuest.award_times
	self:showTextWithLabel("Label_buyCount",G_lang:get("LANG_ACTIVITY_DUI_HUAN_CI_SHU",{num=leftTime}))

	self:getImageViewByName("ImageView_item_bg01"):loadTexture(G_Path.getEquipIconBack(self.good.quality))
	self:getImageViewByName("ImageView_item"):loadTexture(self.good.icon,UI_TEX_TYPE_LOCAL)
	local itemButton = self:getButtonByName("Button_item")
	itemButton:loadTextureNormal(G_Path.getEquipColorImage(self.good.quality,self.good.type))
	itemButton:loadTexturePressed(G_Path.getEquipColorImage(self.good.quality,self.good.type))
end

function ActivityDuihuanDialog:_initEvent()
	self:registerBtnClickEvent("Button_subtract10",handler(self,self._clickSub10))
	self:registerBtnClickEvent("Button_subtract01",handler(self,self._clickSub1))
	self:registerBtnClickEvent("Button_add01",handler(self,self._clickAdd1))
	self:registerBtnClickEvent("Button_add10",handler(self,self._clickAdd10))

	self:registerBtnClickEvent("Button_buy",function() 
		if self._callback then
			self._callback(self._buyNum)
		end
		self:animationToClose()
		end)
	self:enableAudioEffectByName("Button_close", false)
	self:registerBtnClickEvent("Button_close",function()
	    self:animationToClose()
	    local soundConst = require("app.const.SoundConst")
	    G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end)
	self:enableAudioEffectByName("Button_cancel", false)
	self:registerBtnClickEvent("Button_cancel",function()
	    self:animationToClose()
	    local soundConst = require("app.const.SoundConst")
	    G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	end)
end

function ActivityDuihuanDialog:_clickAdd1()
	if self._buyNum + 1 > self._maxNum then
		self._buyNum = self._maxNum
	else
		self._buyNum = self._buyNum + 1
	end
	self:showTextWithLabel("Label_count",tostring(self._buyNum))
end
function ActivityDuihuanDialog:_clickAdd10()
	if self._buyNum + 10 > self._maxNum then
		self._buyNum = self._maxNum
	else
		if self._buyNum == 1 then
			self._buyNum = 10
		else
			self._buyNum = self._buyNum + 10
		end
	end
	self:showTextWithLabel("Label_count",tostring(self._buyNum))
end
function ActivityDuihuanDialog:_clickSub1()
	if self._buyNum - 1 > 0 then
		self._buyNum = self._buyNum - 1
	else
		self._buyNum = 1
	end
	self:showTextWithLabel("Label_count",tostring(self._buyNum))
end
function ActivityDuihuanDialog:_clickSub10()
	if self._buyNum - 10 > 0 then
		self._buyNum = self._buyNum - 10
	else
		self._buyNum = 1
	end
	self:showTextWithLabel("Label_count",tostring(self._buyNum))
end

function ActivityDuihuanDialog:_getMaxNum()
	local curQuest = G_Me.activityData.custom:getCurQuestByQuest(self._quest)
	local leftTime = self._quest.award_limit - curQuest.award_times
	local _num,_= G_Me.bagData:getNumByTypeAndValue(self.good.type,self.good.value)  --拥有数量

	local purchaseNum = math.floor(_num/self.good.size)   --最多能兑换的次数

	return leftTime > purchaseNum and purchaseNum or leftTime
end

function ActivityDuihuanDialog:onLayerEnter(...)
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	self:showWidgetByName("Label_buyTips",false)
	self:showWidgetByName("Panel_tagJinZi",false)

end



return ActivityDuihuanDialog