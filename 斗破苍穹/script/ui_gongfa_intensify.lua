require"Lang"
UIGongfaIntensify = {}

local ui_basePanel = nil

local _curInstMagicId = nil
local _instMagicIds = nil

local ui_cardExpBarNew = nil
local ui_cardLvUp = nil
local _curCardExp = 0
local _tempExp = 0 
local _tempLv = 0
local _curLevel = 0
local _maxLevel = 40
local function getDictMagicLevelExp( lvl )
   -- cclog("lvl : "..lvl)
    if _curInstMagicId then
		local instMagicData = net.InstPlayerMagic[tostring(_curInstMagicId)]
		local magicType = instMagicData.int["4"]
        for key , value in pairs( DictMagicLevel ) do
            if value.type == magicType and value.level == lvl then
                return value.exp
            end
        end
    end
    return DictMagicLevel[tostring(lvl)].exp
end
local function startFade()
    if _tempLv > _curLevel then
        ui_cardLvUp:setString("→" .. _tempLv)
		ui_cardLvUp:setVisible(true)
		ui_cardLvUp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))))
		ui_cardExpBarNew:setPercent(100)
	else
		local maxExp = getDictMagicLevelExp( _tempLv ) --DictMagicLevel[tostring(_tempLv)].exp
		ui_cardExpBarNew:setPercent(_tempExp / maxExp * 100)
	end
	ui_cardExpBarNew:setVisible(true)
	ui_cardExpBarNew:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))))
end

local function stopFade()
	ui_cardLvUp:stopAllActions()
	ui_cardLvUp:setVisible(false)
	ui_cardExpBarNew:stopAllActions()
	ui_cardExpBarNew:setVisible(false)
	ui_cardLvUp:setOpacity(255)
	ui_cardExpBarNew:setOpacity(255)
end

local function netCallbackFunc(data)
	AudioEngine.playEffect("sound/strengthen.mp3")
	local animation = ActionManager.getUIAnimation(15, function()
		UIGongfaIntensify.setup()
		UIManager.flushWidget(UIGongfaInfo)
		UIManager.flushWidget(UILineup)
		UIManager.flushWidget(UIBagGongFa)
	end)
	animation:getAnimation():playWithIndex(1)
	animation:setPosition(cc.p(UIManager.screenSize.width / 4 + 50, UIManager.screenSize.height / 2))
	UIManager.uiLayer:addChild(animation, UIGongfaIntensify.Widget:getLocalZOrder() + 1)
end

function UIGongfaIntensify.init()
	ui_basePanel = ccui.Helper:seekNodeByName(UIGongfaIntensify.Widget, "image_basemap")
	local btn_close = ui_basePanel:getChildByName("btn_close")
	local btn_back = ui_basePanel:getChildByName("btn_exit")
	local btn_onekey = ui_basePanel:getChildByName("btn_onekey")
	local btn_intensify = ui_basePanel:getChildByName("btn_lineup")
	btn_close:setPressedActionEnabled(true)
	btn_back:setPressedActionEnabled(true)
	btn_onekey:setPressedActionEnabled(true)
	btn_intensify:setPressedActionEnabled(true)
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_back then
				UIManager.popScene()
			elseif sender == btn_onekey then
				if net.InstPlayerMagic then
					local selectedInstMagicIds = {}
					if _instMagicIds then
						selectedInstMagicIds = utils.stringSplit(_instMagicIds, ";")
					end
					local function isContain(instMagicId)
						for key, obj in pairs(selectedInstMagicIds) do
							if instMagicId == tonumber(obj) then
								return true
							end
						end
						return false
					end
					local instMagicData = net.InstPlayerMagic[tostring(_curInstMagicId)]
					local _curMagicType = instMagicData.int["4"]
                    local tempMagic = {}
                    for key , obj in pairs( net.InstPlayerMagic ) do
                        table.insert( tempMagic , obj )
                    end
                    local function compareMagic(value1,value2)   
                        if DictMagic[tostring(value1.int["3"])].value1 == "3" and DictMagic[tostring(value2.int["3"])].value1 ~= "3" then
                            return false
                        elseif DictMagic[tostring(value1.int["3"])].value1 ~= "3" and DictMagic[tostring(value2.int["3"])].value1 == "3" then
                            return true
                        elseif DictMagic[tostring(value1.int["3"])].magicQualityId > DictMagic[tostring(value2.int["3"])].magicQualityId then
		                    return false
                        elseif DictMagic[tostring(value1.int["3"])].magicQualityId < DictMagic[tostring(value2.int["3"])].magicQualityId then
                            return true
	                    elseif DictMagic[tostring(value1.int["3"])].id > DictMagic[tostring(value2.int["3"])].id then
		                    return true
                        else
                            return false
	                    end
                    end
                    utils.quickSort(tempMagic,compareMagic)
                    local isHighQ = false
					for key, obj in pairs(tempMagic) do
                       -- cclog("tempMagic : ".. DictMagic[tostring(obj.int["3"])].magicQualityId )
						local instMagicId = obj.int["1"]
						local magicType = obj.int["4"]
						local isUse = obj.int["8"] --是否被使用  0-未使用 1-使用
						if isUse == 0 and not isContain(instMagicId) and _curInstMagicId ~= instMagicId and _curMagicType == magicType then
                            if DictMagic[ tostring( obj.int["3"] ) ].value1 ~= "3" and tonumber ( DictMagic[ tostring( obj.int["3"] ) ].magicQualityId ) <= 2 then
                                isHighQ = true
                            else
							    if #selectedInstMagicIds >= 5 then
								    break
							    else
								    selectedInstMagicIds[#selectedInstMagicIds + 1] = instMagicId
							    end
                            end
						end
					end
                    if isHighQ and #selectedInstMagicIds < 1 then
                        UIManager.showToast(Lang.ui_gongfa_intensify1)
                    end
					UIGongfaIntensify.setSelectedInstMagicIds(selectedInstMagicIds)
				end
			elseif sender == btn_intensify then
                stopFade()
				if _curInstMagicId then
					if _instMagicIds then
						local sendData = {
							header = StaticMsgRule.strengthenMagic,
							msgdata = {
								int = {
									instPlayerMagicId = _curInstMagicId
								},
								string = {
									instPlayerMagicIdList = _instMagicIds
								}
							}
						}
						UIManager.showLoading()
						netSendPackage(sendData, netCallbackFunc)
					else
						local instMagicData = net.InstPlayerMagic[tostring(_curInstMagicId)]
						local magicType = instMagicData.int["4"]
						UIManager.showToast(Lang.ui_gongfa_intensify2 .. (magicType == dp.MagicType.gongfa and Lang.ui_gongfa_intensify3 or Lang.ui_gongfa_intensify4) .. "!")
					end
				end
			end
		end
	end
	btn_close:addTouchEventListener(onButtonEvent)
	btn_back:addTouchEventListener(onButtonEvent)
	btn_onekey:addTouchEventListener(onButtonEvent)
	btn_intensify:addTouchEventListener(onButtonEvent)

	local ui_upgradePanel = ccui.Helper:seekNodeByName(ui_basePanel, "image_base_luck")
	for i = 1, 5 do
		local magicItem = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. i)
		magicItem:setTouchEnabled(true)
		magicItem:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				local instMagicData = net.InstPlayerMagic[tostring(_curInstMagicId)]
				if instMagicData then
					UIBagGongFaList.setOperateType(UIBagGongFaList.OperateType.magicUpgrade, instMagicData.int["4"], _instMagicIds, _curInstMagicId)
					UIManager.pushScene("ui_bag_gongfa_list")
				end
			end
		end)
	end
end

function UIGongfaIntensify.setup()
	if _curInstMagicId then
		local ui_titleText = ccui.Helper:seekNodeByName(ui_basePanel, "text_gongfa_up")
		local image_basecolour = ui_basePanel:getChildByName("image_basecolour")
		local ui_propPanel = ccui.Helper:seekNodeByName(image_basecolour, "image_base_property")
		local ui_magicIcon = ccui.Helper:seekNodeByName(image_basecolour, "image_gongfa")
		local ui_magicQualityBg = ccui.Helper:seekNodeByName(image_basecolour, "image_base_name")
		local ui_magicName = ui_magicQualityBg:getChildByName("text_name")
		local ui_magicLv = ui_magicQualityBg:getChildByName("text_lv")
		local ui_magicQuality = ccui.Helper:seekNodeByName(image_basecolour, "text_number_quality")
		local ui_magicExpBar = ccui.Helper:seekNodeByName(image_basecolour, "bar_exp")
        ui_cardExpBarNew = ccui.Helper:seekNodeByName(image_basecolour, "bar_exp_new")
        ui_cardLvUp = ui_magicQualityBg:getChildByName("text_lv_0")
		local instMagicData = net.InstPlayerMagic[tostring(_curInstMagicId)]
		local dictMagicId = instMagicData.int["3"]
		local magicType = instMagicData.int["4"]
		local magicQualityId = instMagicData.int["5"]
		local magicLevleId = instMagicData.int["6"]
		local magicExp = instMagicData.int["7"]
		local dictMagicData = DictMagic[tostring(dictMagicId)]
		_curLevel = DictMagicLevel[tostring(magicLevleId)].level

        local magicAdvanceId = instMagicData.int["10"]
        if magicAdvanceId and magicAdvanceId > 0 then
            _maxLevel = DictMagicrefining[tostring(magicAdvanceId)].maxStrengthen
        else
            _maxLevel = 40
        end

        ccui.Helper:seekNodeByName( UIGongfaIntensify.Widget , "text_hint"):setString( Lang.ui_gongfa_intensify5 .. _maxLevel ..Lang.ui_gongfa_intensify6 )

		local magicMaxExp = DictMagicLevel[tostring(magicLevleId)].exp
        local ui_expText = ui_magicExpBar:getChildByTag(100)
        if not ui_expText then
            local ui_expText = ccui.Text:create()
		    ui_expText:setString("EXP "..tostring(magicExp).."/"..tostring(magicMaxExp))
		    ui_expText:setFontSize(20)
		    ui_expText:setFontName("data/ui_font.ttf")
		    ui_expText:setTextColor(cc.c4b(255, 255, 255, 255))
            ui_expText:enableOutline(cc.c4b(0,0,0,255),1)
            local contentSize = ui_magicExpBar:getContentSize()
		    ui_expText:setPosition(cc.p(contentSize.width/2.0,contentSize.height/2.0-3))
            ui_expText:setTag(100)
            ui_magicExpBar:addChild(ui_expText)
        else
             ui_expText:setString("EXP "..tostring(magicExp).."/"..tostring(magicMaxExp))
        end
        _curCardExp = magicExp
        
		
		ui_titleText:setString((magicType == dp.MagicType.gongfa and Lang.ui_gongfa_intensify7 or Lang.ui_gongfa_intensify8) .. Lang.ui_gongfa_intensify9)
		ui_magicIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.bigUiId)].fileName)
		ui_magicQualityBg:loadTexture(utils.getQualityImage(dp.Quality.gongFa, magicQualityId, dp.QualityImageType.small, true))
		ui_magicName:setString(dictMagicData.name)
		ui_magicLv:setString("LV " .. _curLevel)
		ui_magicQuality:setString(tostring(dictMagicData.grade))
        if magicMaxExp==0 then
            ui_magicExpBar:setPercent(0)
        else
            ui_magicExpBar:setPercent(magicExp / magicMaxExp * 100)
        end
		
		for i = 1, 6 do
			local ui_propText = ui_propPanel:getChildByName("text_prop" .. i)
			local _tValues = utils.stringSplit(dictMagicData["value" .. i], "_")
            local textColor = cc.c4b(255, 255, 255, 255)
			if string.len(dictMagicData["value" .. i]) > 0 and _tValues and #_tValues > 0 then
				if i <= 3 then
					ui_propText:setString(DictFightProp[_tValues[2]].name .. " +" .. formula.getMagicValue1(_curLevel, tonumber(_tValues[3]), tonumber(_tValues[4]))
						.. (tonumber(_tValues[1]) == 1 and "%" or ""))
				else
					local _textLv = ""
					if i == 4 then
                        if _curLevel >= 10 then
                            _textLv = Lang.ui_gongfa_intensify10
                            textColor = cc.c4b(255, 255, 0, 255)
                        else
                            _textLv = Lang.ui_gongfa_intensify11
                            textColor = cc.c4b(255, 255, 255, 255)
                        end
                    elseif i == 5 then
                         if _curLevel >= 20 then
                            _textLv = Lang.ui_gongfa_intensify12
                            textColor = cc.c4b(255, 255, 0, 255)
                        else
                            _textLv = Lang.ui_gongfa_intensify13
                            textColor = cc.c4b(255, 255, 255, 255)
                        end
                    elseif i == 6 then
                         if _curLevel >= 40 then
                            _textLv = Lang.ui_gongfa_intensify14
                            textColor = cc.c4b(255, 255, 0, 255)
                        else
                            _textLv = Lang.ui_gongfa_intensify15
                            textColor = cc.c4b(255, 255, 255, 255)
                        end
                    end
                    ui_propText:setTextColor(textColor)
					ui_propText:setString(DictFightProp[_tValues[1]].name .. " +" .. _tValues[2] .. "%" .. _textLv)
				end
			else
				ui_propText:setString("")
			end
		end
		
	end
	UIGongfaIntensify.setSelectedInstMagicIds()
end

function UIGongfaIntensify.setInstMagicId(instMagicId)
	_curInstMagicId = instMagicId
end

local function getMagicTotoalExp(levelId, curExp, dictMagicData)
	local totalExp = 0
	local magicLv = DictMagicLevel[tostring(levelId)].level
   -- cclog("magicLv : "..magicLv)
	if magicLv > 1 then
		local magicType = DictMagicLevel[tostring(levelId)].type
		for key, obj in pairs(DictMagicLevel) do
			if magicType == obj.type and obj.level >= 1 and obj.level < magicLv then
				totalExp = totalExp + obj.exp
			end
		end
	else
		totalExp = dictMagicData.exp
	end
	return totalExp + curExp
end

function UIGongfaIntensify.setSelectedInstMagicIds(selectedInstMagicIds)
    _instMagicIds = nil
	local ui_upgradePanel = ccui.Helper:seekNodeByName(ui_basePanel, "image_base_luck")
	for i = 1, 5 do
		local magicFrame = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card"..i)
		magicFrame:loadTexture("ui/quality_small_white.png")
		magicFrame:getChildByName("image_card" .. i):loadTexture("ui/frame_tianjia.png")
	end
    if _curLevel >= _maxLevel then
        stopFade()
        UIManager.showToast(Lang.ui_gongfa_intensify16)
        return
    end
	_instMagicIds = nil
	local ui_upgradePanel = ccui.Helper:seekNodeByName(ui_basePanel, "image_base_luck")
	for i = 1, 5 do
		local magicFrame = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card"..i)
		magicFrame:loadTexture("ui/quality_small_white.png")
		magicFrame:getChildByName("image_card" .. i):loadTexture("ui/frame_tianjia.png")
	end
    local totalExp = 0
	if selectedInstMagicIds and #selectedInstMagicIds > 0 then
		for key, id in pairs(selectedInstMagicIds) do
			local magicFrame = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card"..key)
			local magicIcon = magicFrame:getChildByName("image_card" .. key)
			local instMagicData = net.InstPlayerMagic[tostring(id)]
			local dictMagicData = DictMagic[tostring(instMagicData.int["3"])]
            local magicType = instMagicData.int["4"]
            local magicLevelID = instMagicData.int["6"]
            local curExp = instMagicData.int["7"]
            totalExp = totalExp + getMagicTotoalExp(magicLevelID,curExp,dictMagicData)
			magicFrame:loadTexture(utils.getQualityImage(dp.Quality.gongFa, instMagicData.int["5"], dp.QualityImageType.small))
			magicIcon:loadTexture("image/" .. DictUI[tostring(dictMagicData.smallUiId)].fileName)
			if _instMagicIds == nil then
				_instMagicIds = ""
			end
			if key == #selectedInstMagicIds then
				_instMagicIds = _instMagicIds .. tostring(id)
			else
				_instMagicIds = _instMagicIds .. tostring(id) .. ";"
			end
		end
	end
   if totalExp >= 0 then
		stopFade()
		_prevLv = _curLevel
		_tempExp, _tempLv = _curCardExp + totalExp, _curLevel
		local function onCardUpgrade()
			local maxExp = getDictMagicLevelExp(_tempLv) --DictMagicLevel[tostring(_tempLv)].exp
            if maxExp > 0 then
                if _tempExp >= maxExp then
				    _tempExp = _tempExp - maxExp
				    _tempLv = _tempLv + 1
				    onCardUpgrade()
			    end
            end
		end
		onCardUpgrade()
		startFade()
		_tempPercent = _tempExp / DictCardExp[tostring(_tempLv)].exp * 100
		if _tempLv > _prevLv then
			_addValue = (_tempLv - _prevLv) * 2 + 1
		else
			_addValue = 5
		end
	end
end

function UIGongfaIntensify.free()
	_curInstMagicId = nil
end
