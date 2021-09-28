
local ShowExpLayer = class("ShowExpLayer",UFCCSNormalLayer)
local FightEnd = require("app.scenes.common.fightend.FightEnd")

function ShowExpLayer.create(...)
    return ShowExpLayer.new("ui_layout/fightend_FightEndShowExpLayer.json")
end


function ShowExpLayer:getContentSize( )
    return self:getPanelByName("Panel_container"):getContentSize()
    
end

function ShowExpLayer:setEndCallback(endCallback)
    self._endCallback = endCallback

    self._flashInterval = 1/30
    self._maxFlashCount = 10

    self._currentValue = 0
    self._valueDelta = 0
    self._timer = nil
    self._oldTotalExp = 0 --之前用户的总经验
end




function ShowExpLayer:setData(key, value)
    self:setClickSwallow(true)
	self._value = value
	self._key = key
	self:getLabelByName("Label_title"):setColor(Colors.darkColors.TITLE_02)
	self:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_GETEXP"))
	self:getLabelByName("Label_value"):setColor(Colors.darkColors.DESCRIPTION)
	self:getLabelByName("Label_value"):setText(tostring(self._currentValue))


	--新手光环经验
	self:getLabelByName("Label_rookieBuffValue"):setText(G_Me.userData:getExpAdd(self._value))

    self:getLabelByName("Label_rookieBuffValue"):createStroke(Colors.strokeBrown,1)
	

    self:getImageViewByName("ImageView_icon"):loadTexture("icon_mini_jinyan.png",  UI_TEX_TYPE_PLIST )

    self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_value"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_level"):createStroke(Colors.strokeBrown,1)

	---self:getLoadingBarByName("LoadingBar_bar"):setPercent(0)


	--玩家现在的等级, 现在的经验, 算一下玩家总经验, 减去玩家现在的经验, 可以得到玩家之前的总经验, 从而得到玩家之前的等级
	local totalExp = FightEnd.getTotalExpLevelRange(1, G_Me.userData.level -1) + G_Me.userData.exp
	local oldTotalExp = totalExp - value
    self._oldTotalExp = oldTotalExp
	self:_updateExpBar(self._oldTotalExp)

end





function ShowExpLayer:_updateExpBar(oldTotalExp)
	if oldTotalExp < 0 then
		oldTotalExp = 0
	end
	local leftExp, level = FightEnd.getLevelExpFromTotalExp(oldTotalExp)
	self:getLabelByName("Label_level"):setColor(Colors.darkColors.ATTRIBUTE)
	self:getLabelByName("Label_level"):setText(G_lang:get("LANG_LEVEL_FORMAT_CHN", {levelValue=level}))
	
    local needExp = role_info.get(level).experience

    self:getLoadingBarByName("LoadingBar_bar"):setPercent(leftExp/needExp*100)

end



function ShowExpLayer:play()
	--闪动数字直到目标self._value
	self._timer = GlobalFunc.addTimer(self._flashInterval, handler(self, self._refreshValue))
	self._valueDelta = math.ceil(self._value / self._maxFlashCount)
	if self._valueDelta < 1 then
		self._valueDelta = 1
	end
end

function ShowExpLayer:_refreshValue()
	--闪动数字直到目标self._value
	self._currentValue = self._currentValue + self._valueDelta
	if self._currentValue >= self._value then
		self._currentValue = self._value		
	end


	self:getLabelByName("Label_value"):setText(tostring(self._currentValue))
    self:_updateExpBar(self._oldTotalExp + self._currentValue)

	if self._currentValue >= self._value then
		self:_end()		
	end

end

function ShowExpLayer:_end()
	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end

	if self._endCallback ~= nil then
		self._endCallback()
		self._endCallback = nil
	end
end
return ShowExpLayer
