


local ShowDailyPVPValueLayer = class("ShowDailyPVPValueLayer",UFCCSNormalLayer)


function ShowDailyPVPValueLayer.create(compare_value)
    return ShowDailyPVPValueLayer.new("ui_layout/fightend_FightEndDailyPVPShowValueLayer.json",compare_value)
end

function ShowDailyPVPValueLayer:ctor( json,compare_value,... )
	self._compare_value = compare_value
	self.super.ctor(self, ...)
	self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_title"):setColor(Colors.darkColors.TITLE_02)
  self:getLabelByName("Label_value"):createStroke(Colors.strokeBrown,1)
  self:getLabelByName("Label_value"):setColor(Colors.darkColors.DESCRIPTION)
  self:getLabelByName("Label_title"):setText("")
  self:getLabelByName("Label_value"):setText("")

    self:setClickSwallow(true)
end

function ShowDailyPVPValueLayer:getContentSize( )
	return self:getPanelByName("Panel_container"):getContentSize()
	
end

function ShowDailyPVPValueLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

    self._flashInterval = 1/30
    self._maxFlashCount = 10

    self._currentValue = 0
    self._valueDelta = 0
    self._timer = nil
end



function ShowDailyPVPValueLayer:setData(key, value)
	self._value = value
	self._key = key
  
  local label = self:getLabelByName("Label_title")
  local img = self:getImageViewByName("ImageView_icon")
  local labelAdd = self:getLabelByName("Label_jianglijiacheng")
  local doubleLabel = self:getLabelByName("Label_double")

  if not label or not img or not labelAdd then
      return
  end

	if key == "daily_pvp_score" then
      label:setText(G_lang:get("LANG_DAILY_END_GET_SCORE"))
      img:loadTexture("icon_mini_jizhanjifen.png", UI_TEX_TYPE_PLIST)
      labelAdd:setText(G_lang:get("LANG_DAILY_END_AWARD_ADD_VALUE", {score=self._value[2],num=self._value[3]}))
      doubleLabel:setVisible(self._value[4])
  elseif key == "daily_pvp_honor" then
      label:setText(G_lang:get("LANG_DAILY_END_GET_HONOR"))
      img:setVisible(false)
      labelAdd:setText(G_lang:get("LANG_DAILY_END_AWARD_ADD_VALUE", {score=self._value[2],num=self._value[3]}))
      doubleLabel:setVisible(self._value[4])
  end
 


end


function ShowDailyPVPValueLayer:play()
	--闪动数字直到目标self._value
	self._timer = GlobalFunc.addTimer(self._flashInterval, handler(self, self._refreshValue))
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_SHORT)

	self._valueDelta = math.ceil(self._value[1] / self._maxFlashCount)
	if self._valueDelta < 1 then
		self._valueDelta = 1
	end
end

function ShowDailyPVPValueLayer:_refreshValue()
	--闪动数字直到目标self._value
	self._currentValue = self._currentValue + self._valueDelta
	if self._currentValue >= self._value[1] then
		self._currentValue = self._value[1]		
	end


	self:getLabelByName("Label_value"):setText(tostring(self._currentValue))

	if self._currentValue >= self._value[1] then
		self:_end()		
	end

end

function ShowDailyPVPValueLayer:_end()
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end

	if self._endCallback ~= nil then
		self._endCallback()
		self._endCallback = nil
	end
end
return ShowDailyPVPValueLayer
