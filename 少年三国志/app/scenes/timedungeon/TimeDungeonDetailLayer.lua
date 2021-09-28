local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local function _updateImageView(target, name, params)
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end 
end

local FlyText = require("app.scenes.common.FlyText")
local TimeDungeonDetailLayer = class("TimeDungeonDetailLayer", UFCCSModelLayer)

function TimeDungeonDetailLayer.create(nStageId, nStageIndex, nEndTime, nCurStageIndex, ...)
	return TimeDungeonDetailLayer.new("ui_layout/timedungeon_TimeDungeonDetailLayer.json", Colors.modelColor, nStageId, nStageIndex, nEndTime, nCurStageIndex, ...)
end

-- nStageIndex这个城池代表的索引
-- nCurStageIndex当前能攻打的索引
function TimeDungeonDetailLayer:ctor(json, param, nStageId, nStageIndex, nEndTime, nCurStageIndex, ...)
	self.super.ctor(self, json, param, ...)
	self:adapterWithScreen()
	self:registerKeypadEvent(true)

	self._nStageId = nStageId or 1
	self._nStageIndex = nStageIndex or 1
	self._nCurStageIndex = nCurStageIndex or 1
	self._nEndTime = nEndTime
	local tStageTmpl = time_dungeon_stage_info.get(self._nStageId)
	local nDungeonId = tStageTmpl["dungeon_" .. self._nStageIndex]
	self._tDungeonTmpl = time_dungeon_info.get(nDungeonId)

	self._isFlyText = false
	self._nInspireCost = 0
	self._nInspireTime = 0

	self:_initWidgets()
	self:_initWithState()
--	self:_showCountDown()
	self._tTimer = G_GlobalFunc.addTimer(1, handler(self, self._showCountDown))
	
end

function TimeDungeonDetailLayer:onLayerEnter()
	-- 鼓舞成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_DUNGEON_INSPIRE_SUCC, self._onInspireSucc, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_762"), "smoving_bounce")
end

function TimeDungeonDetailLayer:onLayerExit()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
	uf_eventManager:removeListenerWithTarget(self)
end

function TimeDungeonDetailLayer:_initWidgets()
	-- 武将头像
	local imgHead = require("app.scenes.common.KnightPic").createKnightPic(self._tDungeonTmpl.base_id, self:getPanelByName("Panel_Hero"), "head", false)
    imgHead:setScale(0.8)
    imgHead:setPositionX(self:getPanelByName("Panel_Hero"):getContentSize().width*0.4)
    imgHead:setPositionY(self:getPanelByName("Panel_Hero"):getContentSize().height*0.56)	
    -- 武将话语
    _updateLabel(self, "Label_Desc", {text=self._tDungeonTmpl.talk})
	-- 章节名
	_updateLabel(self, "Label_StageName", {text=self._tDungeonTmpl.name, stroke=Colors.strokeBrown, size=2})
	-- 挑战按钮
	self:registerBtnClickEvent("Button_Challenge", handler(self, self._onChallenge))
	-- 关闭按钮
	self:registerBtnClickEvent("closebtn", handler(self, self._onCloseWindows))
	-- 掉落物品
	for i=1, 3 do
		local tGoods = G_Goods.convert(self._tDungeonTmpl["award_type"..i], self._tDungeonTmpl["award_value"..i], self._tDungeonTmpl["award_size"..i])
		self:_initGoods(i, tGoods)
	end
	-- 鼓舞按钮
	self:registerBtnClickEvent("Button_Inspire", handler(self, self._onClickInspire))

	local nBuffId = 0
	if self._nStageIndex == self._nCurStageIndex then
		self._tCurDungeonInfo = G_Me.timeDungeonData:getCurDungeonInfo()
		nBuffId = self._tCurDungeonInfo and self._tCurDungeonInfo._nBuffId or 0
	else
		nBuffId = 0
	end
	self:_updateWithInspire(nBuffId)

 	-- 通关奖励
 	_updateLabel(self, "Label_PassAward", {text=G_lang:get("LANG_TOWER_JIANGLI"), stroke=Colors.strokeBrown})
 	-- 结束时间
 	_updateLabel(self, "Label_EndTime", {text=""})
 	_updateLabel(self, "Label_Time", {text=""})
 	--
 	self._labelEndTime = self:getLabelByName("Label_EndTime")
 	self._labelTime = self:getLabelByName("Label_Time")
 	-- 鼓舞次数 

end

function TimeDungeonDetailLayer:_showCountDown()
	local nCurTime = G_ServerTime:getTime()
	local nLastTime = self._nEndTime - nCurTime
	nLastTime = math.max(0, nLastTime-1)
	local nDay, nHour, nMinute, nSecond = self:_formatTime(nLastTime)
	local szTime = ""
	if nDay > 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_1",{dayValue=nDay, hourValue=nHour, minValue=nMinute, secondValue=nSecond})
	elseif nDay == 0 and nHour > 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_2",{hourValue=nHour, minValue=nMinute, secondValue=nSecond})
	elseif nDay == 0 and nHour == 0 then
		szTime = G_lang:get("LANG_TIME_DUNGEON_FORMAT_3",{minValue=nMinute, secondValue=nSecond})
	end  

	_updateLabel(self, "Label_EndTime", {text=G_lang:get("LANG_TIME_DUNGEON_END_TIME")})
	_updateLabel(self, "Label_Time", {text=szTime})
	self:_centerAlign()
end

-- 将秒转化为时、分、秒
function TimeDungeonDetailLayer:_formatTime(nTotalSecond)
	local nDay = math.floor(nTotalSecond / 24 / 3600)
	local nHour = math.floor((nTotalSecond - nDay*24*3600) / 3600)
	local nMinute = math.floor((nTotalSecond - nDay*24*3600 - nHour*3600) / 60)
	local nSeceod = (nTotalSecond - nDay*24*3600 - nHour*3600) % 60
	return nDay, nHour, nMinute, nSeceod
end

function TimeDungeonDetailLayer:_centerAlign()
	local nTotalLen = self._labelEndTime:getContentSize().width + self._labelTime:getContentSize().width
	local len = self:getPanelByName("Panel_97"):getContentSize().width
	len = (len - nTotalLen) / 2
	self._labelEndTime:setPositionX(len)
	self._labelTime:setPositionX(len + self._labelEndTime:getContentSize().width)
end

function TimeDungeonDetailLayer:_initGoods(nIndex, tGoods)
	local imgBg = self:getImageViewByName("ImageView_bouns" .. nIndex)
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local imgQulaity = self:getImageViewByName("bouns" .. nIndex)
		imgQulaity:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		imgQulaity:setTag(nIndex)
		imgQulaity._nType = tGoods.type
		imgQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = tolua.cast(imgQulaity:getChildByName("bounsnum"), "Label")
		labelDropNum:setText("x".. tGoods.size)
		labelDropNum:createStroke(Colors.strokeBrown,1)
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("ico" .. nIndex)
		imgIcon:loadTexture(tGoods.icon)
		self:registerWidgetTouchEvent("bouns" .. nIndex, handler(self, self._onClickGoods))
	end
end

function TimeDungeonDetailLayer:_onClickGoods(sender, eventType)
	local nType = sender._nType
	local nValue= sender._nValue
    if eventType == TOUCH_EVENT_ENDED then
    	if type(nType) == "number" and type(nValue) == "number" then
        	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
    	end
    end
end

-- 鼓舞
-- nBuffId 当前鼓舞次数，最低为0，最高为3
function TimeDungeonDetailLayer:_updateWithInspire(nBuffId)
	if type(nBuffId) ~= "number" then
		return
	end
	if nBuffId < 0 or nBuffId > 3 then
		assert(false, "error inspire count !")
		return
	end
	self._nInspireTime = 3 - nBuffId

	if self._richTextInspireDesc == nil then
        local label = self:getLabelByName("Label_InspireDesc")
        local pos = ccp(label:getPosition())
        label:setVisible(false)
        self._richTextInspireDesc = CCSRichText:createSingleRow()
        self._richTextInspireDesc:setFontSize(label:getFontSize())
        self._richTextInspireDesc:setFontName(label:getFontName())
        self._richTextInspireDesc:setAnchorPoint(ccp(0.5, 0.5))
        self._richTextInspireDesc:setPosition(pos)
        label:getParent():addChild(self._richTextInspireDesc)
        self._richTextInspireDesc:appendXmlContent(G_lang:get("LANG_TIME_DUNGEON_INSPIRE_BUFF", {num=self._nInspireTime}))
		self._richTextInspireDesc:reloadData()
	else
		self._richTextInspireDesc:clearRichElement()
		self._richTextInspireDesc:appendXmlContent(G_lang:get("LANG_TIME_DUNGEON_INSPIRE_BUFF", {num=self._nInspireTime}))
		self._richTextInspireDesc:reloadData()
	end


	local szAttackAttr = ""
	local szLifeAttr = ""
	local tReduceTmpl = time_dungeon_reduce_info.get(nBuffId)
	if not tReduceTmpl then
		szAttackAttr = G_lang:get("LANG_TIME_DUNGEON_ATTACK_ATTR_0")
		szLifeAttr = G_lang:get("LANG_TIME_DUNGEON_LIFT_ATTR_0")

		_updateLabel(self, "Label_AttackAttr", {text=szAttackAttr, visible=true})
		_updateLabel(self, "Label_LifeAttr", {text=szLifeAttr, visible=true})

		G_Me.timeDungeonData:storeCurInspireAttr(szAttackAttr, szLifeAttr)
	else
		if passive_skill_info.get(tReduceTmpl.buff1) and passive_skill_info.get(tReduceTmpl.buff1).name then
			szAttackAttr = passive_skill_info.get(tReduceTmpl.buff1).name
		end
		if passive_skill_info.get(tReduceTmpl.buff2) and passive_skill_info.get(tReduceTmpl.buff2).name then
			szLifeAttr = passive_skill_info.get(tReduceTmpl.buff2).name
		end
		G_Me.timeDungeonData:storeCurInspireAttr(szAttackAttr, szLifeAttr)

		local function updateAttr()
			_updateLabel(self, "Label_AttackAttr", {text=szAttackAttr})
			_updateLabel(self, "Label_LifeAttr", {text=szLifeAttr})
		end
		if self._isFlyText then
			self._isFlyText = true
			local flyText = FlyText.new(updateAttr)
			flyText:addNormalText(szAttackAttr, Colors.getColor(2), self:getLabelByName("Label_AttackAttr"), nil, nil, 30)
			flyText:addNormalText(szLifeAttr, Colors.getColor(2), self:getLabelByName("Label_LifeAttr"), nil, nil, 30)
			flyText:play()
			self:addChild(flyText)
		else
			_updateLabel(self, "Label_AttackAttr", {text=szAttackAttr})
			_updateLabel(self, "Label_LifeAttr", {text=szLifeAttr})
		end
	end

	-- 下一次鼓舞花费的元宝
	local tNextReduceTmpl = time_dungeon_reduce_info.get(nBuffId + 1)
	if tNextReduceTmpl then
		self._nInspireCost = tNextReduceTmpl and tNextReduceTmpl.gold or 0
		_updateLabel(self, "Label_InspireCost", {text=tostring(self._nInspireCost), stroke=Colors.strokeBrown})
		_updateLabel(self, "Label_InspireEnd", {visible=false})
	else
		_updateImageView(self, "Image_17", {visible=false})
		_updateLabel(self, "Label_InspireCost", {visible=false})
		_updateLabel(self, "Label_InspireEnd", {text=G_lang:get("LANG_TIME_DUNGEON_INSPIRE_FINISHED"), visible=true})
	end

end

function TimeDungeonDetailLayer:onBackKeyEvent()
    self:_onCloseWindows()
    return true
end

-- 鼓舞
function TimeDungeonDetailLayer:_onClickInspire()
	if self._nStageIndex > self._nCurStageIndex then
		G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_CUR_STAGE_CANNOT_INSPIRE"))
		return
	end

	self._tCurDungeonInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	if self._tCurDungeonInfo then
		local nBuffId = self._tCurDungeonInfo._nBuffId + 1
		if nBuffId > 3 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_INSPIRE_COUNT_FINISHED"))
			return
		end
		-- 提示将使用元宝鼓舞
		local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showMessage(box.TypeTimeDungeon,
            			    self._nInspireCost, 
                        	self._nInspireTime,
            			    self._onConfirmInspire,
        				    self._onCancelInspire, 
        				    self)
        self:getButtonByName("Button_Inspire"):setEnabled(false)
	end
end

function TimeDungeonDetailLayer:_onConfirmInspire()
	self:getButtonByName("Button_Inspire"):setEnabled(true)
	self._tCurDungeonInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	if self._tCurDungeonInfo then
		local nBuffId = self._tCurDungeonInfo._nBuffId + 1
		-- 判断元宝够不够
		if G_Me.userData.gold >= self._nInspireCost then
			local nStageId = self._nStageId
			local nStageIndex = self._nStageIndex
			G_HandlersManager.timeDungeonHandler:sendAddTimeDungeonBuff(nStageId, nStageIndex, nBuffId)
		else
			require("app.scenes.shop.GoldNotEnoughDialog").show()
		end
	end
end

function TimeDungeonDetailLayer:_onCancelInspire()
	self:getButtonByName("Button_Inspire"):setEnabled(true)
end

-- 鼓舞成功
function TimeDungeonDetailLayer:_onInspireSucc()
	self._tCurDungeonInfo = G_Me.timeDungeonData:getCurDungeonInfo()
	if self._tCurDungeonInfo then
		self._isFlyText = true
		self:_updateWithInspire(self._tCurDungeonInfo._nBuffId)
	end
end


-- 发协议向服务器请求战斗
function TimeDungeonDetailLayer:_onChallenge()
	if self._nStageIndex == self._nCurStageIndex then
		-- 发送协议,请求战斗
		local nStageId = self._nStageId
		local nStageIndex = self._nStageIndex
		G_Me.timeDungeonData:setAttackStageInfo(nStageId, nStageIndex)
		G_HandlersManager.timeDungeonHandler:sendAttackTimeDungeon(nStageId, nStageIndex)
	elseif self._nStageIndex > self._nCurStageIndex then
		G_MovingTip:showMovingTip(G_lang:get("LANG_TIME_DUNGEON_CUR_STAGE_FINISHED"))
	end
end

-- 提示体力不足，请购买
function TimeDungeonDetailLayer:_showPurchaseVit()
    G_GlobalFunc.showPurchasePowerDialog(1)
end

-- 关闭窗口
function TimeDungeonDetailLayer:_onCloseWindows()
	self:animationToClose()
end

function TimeDungeonDetailLayer:_initWithState()
	if self._nStageIndex == self._nCurStageIndex then
		_updateLabel(self, "Label_OpenDesc", {visible=false})
	elseif self._nStageIndex > self._nCurStageIndex then
		self:getButtonByName("Button_Challenge"):setVisible(false)

		if self._richText == nil then
	        local label = self:getLabelByName("Label_OpenDesc")
	        local pos = ccp(label:getPosition())
	        label:setVisible(false)
	        self._richText = CCSRichText:createSingleRow()
	        self._richText:setFontSize(label:getFontSize())
	        self._richText:setFontName(label:getFontName())
	        self._richText:setAnchorPoint(ccp(0.5, 0.5))
	        self._richText:setPosition(pos)
	        label:getParent():addChild(self._richText)
	        self._richText:appendXmlContent(G_lang:get("LANG_TIME_DUNGEON_BREAK_STAGE_TO_OPEN", {num=self._nStageIndex-1}))
  			self._richText:reloadData()
    	end
	end
end




return TimeDungeonDetailLayer