require"Lang"
UIPilltower = {}
local Encrypt = require("EncryptLuaTable")

local PARTICLE_EFFECT_TAG = -10000
local MAX_POINT_COUNT = Encrypt.encryptNumber(5) --最大显示的关卡点位数量
local MOP_UP_OPEN_CONDITION = Encrypt.encryptNumber(DictSysConfig[tostring(StaticSysConfig.dantaOpenNum)].value) --扫荡开启条件(层数)
UIPilltower.UserData = Encrypt.new()
UIPilltower.UserData.curFightPoint = 1 --当前正在战斗的关卡层数(id)
UIPilltower.UserData.medalCount = 0 --勋章数量
UIPilltower.UserData.myCardData = nil --我方卡牌数据
UIPilltower.UserData.pointMedalCount = Encrypt.new() --通关的关卡勋章数([id])
UIPilltower.UserData.historyMaxPoint = nil --历史最高层数
UIPilltower.UserData.challengeNums = nil --挑战次数
UIPilltower.UserData.isDebug = false --是否Debug模式(true:单机版)

local ui_fightPoints = nil
local _randomMonsterData = nil

local _onFightWinCallback = nil --战斗胜利回调
local _awardThings = false --每5关大奖

local function addParticleEffect(node)
    if not node then
        return
    end
	for _i = 1, 2 do
		local effect = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
		node:addChild(effect)
        effect:setTag(PARTICLE_EFFECT_TAG + _i)
		effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
		if _i == 1 then
			effect:setPosition(cc.p(10, 10))
			effect:runAction(utils.MyPathFun(10, node:getContentSize().height-20, node:getContentSize().width-25, 0.5, 1))
		else
			effect:setPosition(cc.p(node:getContentSize().width-10, node:getContentSize().height-10))
			effect:runAction(utils.MyPathFun(10, node:getContentSize().height-20, node:getContentSize().width-25, 0.5, 2))
		end
	end
end
local function removeParticleEffect(node)
    if not node then
        return
    end
    for _i = 1, 2 do
        local _effectNode = node:getChildByTag(PARTICLE_EFFECT_TAG + _i)
        if _effectNode then
            _effectNode:removeFromParent()
            _effectNode = nil
        end
    end
end

local function initMyCardData()
    UIPilltower.UserData.myCardData = nil
    UIPilltower.UserData.myCardData = Encrypt.new()
    local formation1, formation2 = {}, {}
	for key, obj in pairs(net.InstPlayerFormation) do
		if obj.int["4"] == 1 then	--主力
			formation1[#formation1 + 1] = obj
		elseif obj.int["4"] == 2 then --替补
			formation2[#formation2 + 1] = obj
		end
	end
	local function compareFunc(obj1, obj2)
		if obj1.int["1"] > obj2.int["1"] then
			return true
		end
		return false
	end
	utils.quickSort(formation1, compareFunc)
	utils.quickSort(formation2, compareFunc)
    for i = 1, 9 do
        local obj = nil
		if formation1[i] then
			obj = formation1[i]
		elseif formation2[i - #formation1] then
			obj = formation2[i - #formation1]
		end
        UIPilltower.UserData.myCardData[i] = obj and Encrypt.new() or nil
        if UIPilltower.UserData.myCardData[i] then
--            UIPilltower.UserData.myCardData[i].cardId = obj.int["6"]
            UIPilltower.UserData.myCardData[i].instCardId = obj.int["3"]
            UIPilltower.UserData.myCardData[i].cardBlood = math.floor(utils.getCardAttribute(obj.int["3"])[StaticFightProp.blood])
            UIPilltower.UserData.myCardData[i].lineupPosition = nil
    --*****测试
--            UIPilltower.UserData.myCardData[i].cardBlood = utils.random(0, utils.getCardAttribute(obj.int["3"])[StaticFightProp.blood])
        end
    end
    formation1 = nil
    formation2 = nil
end

--重置丹塔
function UIPilltower.resetData(_notResetChallengeNums)
    UIPilltower.UserData.curFightPoint = 1
    UIPilltower.UserData.myCardData = nil
    UIPilltower.resetPointData()
    UIPilltower.UserData.medalCount = 0
    if not _notResetChallengeNums then
        UIPilltower.UserData.challengeNums = nil
    end
end
--重置关卡数据
function UIPilltower.resetPointData()
    _randomMonsterData = nil
    UIPilltower.UserData.pointMedalCount = nil
    UIPilltower.UserData.pointMedalCount = Encrypt.new()
end

local function setUIEnabled(_enabled)
    local childs = UIManager.uiLayer:getChildren()
    for key, obj in pairs(childs) do
	    if (not tolua.isnull(obj)) then
		    obj:setEnabled(_enabled)
	    end
    end
    if _enabled then
        _onFightWinCallback = nil
    end
end

local function runFloorAction()
    local image_basemap = UIPilltower.Widget:getChildByName("image_basemap")
    local _pointY, spaceH = 236.5, -80
    local floorPanel = image_basemap:getChildByName("panel")
    local ui_floorItem = floorPanel:getChildByName("image_di_floor")
    if ui_floorItem == nil then
        ui_floorItem = floorPanel:getChildByName("image_di_floor1")
    end
    ui_floorItem:setName("image_di_floor1")
    for i = 1, 6 do
        local floorItem = floorPanel:getChildByName("image_di_floor"..i)
        if floorItem == nil then
            floorItem = ui_floorItem:clone()
            floorPanel:addChild(floorItem)
            floorItem:setName("image_di_floor"..i)
            floorItem:setLocalZOrder(6-i)
            floorItem:setPositionY(_pointY)
        end
        _pointY = floorItem:getTopBoundary() + floorItem:getContentSize().height / 2 + spaceH
        if i > 3 then
            for _i = 1, 2 do
                local _cardItem = floorItem:getChildByName("image_floor".._i)
                _cardItem:setVisible(false)
            end
        end
    end
    local runPointAction = function()
        local _pCount = 0
        for i = 1, 3 do
            local floorItem = floorPanel:getChildByName("image_di_floor"..i)
            floorItem:setVisible(true)
            for _i = 1, 2 do
                _pCount = _pCount + 1
                if _pCount <= Encrypt.decryptNumber(MAX_POINT_COUNT) then
                    local _cardItem = floorItem:getChildByName("image_floor".._i)
                    _cardItem:setScale(0)
                    _cardItem:setVisible(true)
                    if _pCount == Encrypt.decryptNumber(MAX_POINT_COUNT) then
                        _cardItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1), cc.CallFunc:create(function()
                            setUIEnabled(true)
                        end)))
                    else
                        _cardItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1)))
                    end
                end
            end
        end
    end
    local _moveH = UIManager.screenSize.height - 236.5
    for i = 1, 6 do
        local floorItem = floorPanel:getChildByName("image_di_floor"..i)
        if i == 6 then
            floorItem:runAction(cc.Sequence:create(cc.MoveBy:create(1, cc.p(0, -_moveH)), cc.CallFunc:create(
                function()
                    for _k = 1, 3 do
                        local _floorItem = floorPanel:getChildByName("image_di_floor".._k)
                        _floorItem:setVisible(false)
                        for _i = 1, 2 do
                            _floorItem:getChildByName("image_floor".._i):setVisible(false)
                        end
                        _floorItem:setPositionY(_floorItem:getPositionY() + _moveH)
--                        _floorItem:setVisible(true)
                        floorPanel:getChildByName("image_di_floor".._k+3):removeFromParent()
                    end
--                    runPointAction()
                    _onFightWinCallback()
                    _onFightWinCallback = nil
                    UIPilltower.setup(runPointAction)
                end
            )))
        else
            floorItem:runAction(cc.Sequence:create(cc.MoveBy:create(1, cc.p(0, -_moveH))))
        end
    end
end

local function runMedalAction(_item, _medalNums)
    --获得勋章动画
    if not _medalNums then
        _medalNums = 0
    end
    local _index = 1
    local runAction = nil
    runAction = function()
        if _index > _medalNums then
            if UIPilltower.UserData.curFightPoint % 5 == 0 then
                if _awardThings and string.len(_awardThings) > 0 then
                    UIPilltowerGet.show({pointId=UIPilltower.UserData.curFightPoint,things=_awardThings,callback=runFloorAction})
                    _awardThings = nil
                else
                    runFloorAction()
                end
            else
                _onFightWinCallback()
                setUIEnabled(true)
                UIPilltower.setup()
            end
        else
            local ui_medal = _item:getChildByName("image_star".._index)
            ui_medal:setScale(0)
            ui_medal:setVisible(true)
            ui_medal:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1), cc.CallFunc:create(runAction)))
        end
        _index = _index + 1
    end
    runAction()
end

local function runPassAction(_item, _medalNums)
    --已通关动画
    local ui_pass = _item:getChildByName("image_pass")
    ui_pass:setVisible(false)
    ui_pass:setScale(5)
    ui_pass:setOpacity(0)
    ui_pass:setVisible(true)
    ui_pass:runAction(cc.Sequence:create(cc.Spawn:create(
        cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2)
    ), cc.CallFunc:create(function() runMedalAction(_item, _medalNums) end)))
end

local function initPointsData()
    local _curFightPoint = UIPilltower.UserData.curFightPoint
    local pillTowerData = DictDantaLayer[tostring(_curFightPoint)]
    if pillTowerData then
        local _curFightStartPointId = 1
        if _curFightPoint % Encrypt.decryptNumber(MAX_POINT_COUNT) == 0 then
            _curFightStartPointId = _curFightPoint - 4
        else
            _curFightStartPointId = math.floor(_curFightPoint / Encrypt.decryptNumber(MAX_POINT_COUNT)) * Encrypt.decryptNumber(MAX_POINT_COUNT) + 1
        end
        if not _randomMonsterData then
            _randomMonsterData = {}
            _randomMonsterData.layerIds = utils.randoms(_curFightStartPointId, _curFightStartPointId + 3, 4)
            for key, _id in pairs(_randomMonsterData.layerIds) do
                local _monsterIds = utils.stringSplit(DictDantaLayer[tostring(_id)].monsters, ",")
                if not _randomMonsterData.headIds then
                    _randomMonsterData.headIds = {}
                end
                _randomMonsterData.headIds[key] = _monsterIds[utils.random(1, #_monsterIds)]
                _monsterIds = nil
            end
            local _monsterIds = utils.stringSplit(DictDantaLayer[tostring(_curFightStartPointId + 4)].monsters, ",")
            for _i, _monsterId in pairs(_monsterIds) do
                if DictDantaMonster[tostring(_monsterId)].isBoss == 1 then
                    _randomMonsterData.headIds[Encrypt.decryptNumber(MAX_POINT_COUNT)] = _monsterId
                    break
                end
            end
            _monsterIds = nil
        end
--        for _id = _curFightStartPointId, _curFightStartPointId + 4 do
--        end
        if ui_fightPoints then
            for key, pointItem in pairs(ui_fightPoints) do
                local ui_cardIcon = pointItem:getChildByName("image_card")
                local ui_passImg = pointItem:getChildByName("image_pass")
                for _starI = 1, 3 do
                    pointItem:getChildByName("image_star".._starI):setVisible(false)
                end
                if _curFightPoint >= _curFightStartPointId then
                    local _dantaLayerId = _curFightStartPointId
                    if _randomMonsterData.layerIds[key] then
                        _dantaLayerId = _randomMonsterData.layerIds[key]
                    end
--                    local _monsterId = utils.stringSplit(DictDantaLayer[tostring(_dantaLayerId)].monsters, ",")[1]
                    local _cardId = DictDantaMonster[tostring(_randomMonsterData.headIds[key])].cardId
                    local _cardIcon = "image/" .. DictUI[tostring(DictCard[tostring(_cardId)].smallUiId)].fileName
                    ui_cardIcon:loadTexture(_cardIcon)
                    if _curFightPoint == _curFightStartPointId then --当前正在进行的...
                        if _onFightWinCallback then
                            runPassAction(pointItem, UIPilltower.UserData.pointMedalCount[_curFightStartPointId])
                        else
                            addParticleEffect(pointItem)
                            ui_passImg:setVisible(false)
                            pointItem:setTouchEnabled(true)
                            pointItem:addTouchEventListener(function(sender, eventType)
                                if eventType == ccui.TouchEventType.ended then
                                    if type(UIPilltower.UserData.challengeNums) == "number" and UIPilltower.UserData.challengeNums > 0 or _curFightPoint ~= 1 then
                                        UIPilltowerEmbattle.show({monsterId=_dantaLayerId})
                                    else
                                        UIManager.showToast(Lang.ui_pilltower1)
                                    end
                                end
                            end)
                        end
                    else --已通关的
                        local _medalCount = UIPilltower.UserData.pointMedalCount[_curFightStartPointId]
                        if not _medalCount then _medalCount = 0 end
                        for _starI = 1, 3 do
                            pointItem:getChildByName("image_star".._starI):setVisible((_medalCount >= _starI) and true or false)
                        end
                        ui_passImg:setVisible(true)
                    end
                else --未开启的
                    ui_passImg:setVisible(false)
                    ui_cardIcon:loadTexture("ui/mg_suo.png")
                end
                ccui.Helper:seekNodeByName(pointItem, "text_name"):setString(Lang.ui_pilltower2 .. _curFightStartPointId .. Lang.ui_pilltower3)
                _curFightStartPointId = _curFightStartPointId + 1
            end
        else
            cclog("LUA ERROR：添加台阶UI出错了！~")
        end
    else
        cclog("LUA ERROR：当前数据已达到最高层数了！~")
    end
end

local function initFloorUI()
    local image_basemap = UIPilltower.Widget:getChildByName("image_basemap")
    local _pointCount = 0
    local _pointY, spaceH = 236.5, -80
    local floorPanel = image_basemap:getChildByName("panel")
    local ui_floorItem = floorPanel:getChildByName("image_di_floor")
    if ui_floorItem == nil then
        ui_floorItem = floorPanel:getChildByName("image_di_floor1")
    end
    ui_floorItem:setName("image_di_floor1")
    for i = 1, 3 do
        local floorItem = floorPanel:getChildByName("image_di_floor"..i)
        if floorItem == nil then
            floorItem = ui_floorItem:clone()
            floorPanel:addChild(floorItem)
            floorItem:setName("image_di_floor"..i)
        end
        floorItem:setLocalZOrder(2*3-i)
        floorItem:setPositionY(_pointY)
        _pointY = floorItem:getTopBoundary() + floorItem:getContentSize().height / 2 + spaceH
        for _i = 1, 2 do
            _pointCount = _pointCount + 1
            local _cardItem = floorItem:getChildByName("image_floor".._i)
            removeParticleEffect(_cardItem)
            _cardItem:setTouchEnabled(false)
            if _pointCount <= Encrypt.decryptNumber(MAX_POINT_COUNT) then
                if not ui_fightPoints then
                    ui_fightPoints = {}
                end
                ui_fightPoints[_pointCount] = _cardItem
            else
                _cardItem:setVisible(false)
            end
        end
    end
end

--下一阶段扫荡开启条件
local function nextMopUpCondition()
    for i = 0, 999 do
        local _curMopUpCondition = Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION) + (i * DictSysConfig[tostring(StaticSysConfig.dantaFloorNum)].value)
        local _nextMopUpCondition = Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION) + ((i+1) * DictSysConfig[tostring(StaticSysConfig.dantaFloorNum)].value)
        if UIPilltower.UserData.historyMaxPoint >= _curMopUpCondition and UIPilltower.UserData.historyMaxPoint < _nextMopUpCondition then
            return _nextMopUpCondition
        end
    end
    return Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION)
end

--扫荡
local function onMopUp(_msgData)
    if _msgData then
        setUIEnabled(false)
        UIPilltower.setFightWinCallback(function()
            UIPilltower.resetPointData()
            if UIPilltower.UserData.curFightPoint == 1 and UIPilltower.UserData.challengeNums > 0 then
                UIPilltower.UserData.challengeNums = UIPilltower.UserData.challengeNums - 1
            end
            local _awards = _msgData.msgdata.string.r3
            UIPilltower.UserData.curFightPoint = _msgData.msgdata.int.r4 + 1
            UIPilltower.UserData.medalCount = _msgData.msgdata.int.r5
            UIPilltower.refreshMedalCount()
            if _awards and string.len(_awards) > 0 then
                UIPilltowerGet.show({pointId=0,things=_awards})
                _awards = nil
            else
                UIManager.showToast(Lang.ui_pilltower4)
            end
        end)
        runFloorAction()
    elseif UIPilltower.UserData.isDebug then
        setUIEnabled(false)
        UIPilltower.setFightWinCallback(function()
            UIPilltower.resetPointData()
            UIPilltower.UserData.curFightPoint = UIPilltower.UserData.historyMaxPoint + 1
            UIPilltower.UserData.medalCount = DictSysConfig[tostring(StaticSysConfig.dantaGiveStar)].value
            UIPilltower.refreshMedalCount()
            if UIPilltower.UserData.curFightPoint == 1 and UIPilltower.UserData.challengeNums > 0 then
                UIPilltower.UserData.challengeNums = UIPilltower.UserData.challengeNums - 1
            end
            UIManager.showToast(Lang.ui_pilltower5)
        end)
        runFloorAction()
    end
end

function UIPilltower.init()
    local image_basemap = UIPilltower.Widget:getChildByName("image_basemap")
    local image_base_title = image_basemap:getChildByName("image_base_title")
    local image_di_reset = image_basemap:getChildByName("image_di_reset")
    local btn_back = image_base_title:getChildByName("btn_back")
    local btn_help = image_base_title:getChildByName("btn_help")
    local btn_preview = image_base_title:getChildByName("btn_preview")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local btn_reset = image_di_reset:getChildByName("btn_reset")
    local btn_again = image_di_reset:getChildByName("btn_again")
    btn_back:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    btn_preview:setPressedActionEnabled(true)
    btn_rank:setPressedActionEnabled(true)
    btn_reset:setPressedActionEnabled(true)
    btn_again:setPressedActionEnabled(true)
    local function onClickEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                -- if not UIPilltower.exitWaring(UIMenu.onActivity) then
                    -- UIMenu.onActivity()
                if not UIPilltower.exitWaring(UIMenu.onHomepage) then
                    UIMenu.onHomepage()
                end
            elseif sender == btn_help then
                UIAllianceHelp.show({type=5,titleName=Lang.ui_pilltower6})
            elseif sender == btn_preview then
                UIPilltowerPreview.show({maxPointCount=Encrypt.decryptNumber(MAX_POINT_COUNT)})
            elseif sender == btn_rank then
                if UIPilltower.UserData.isDebug then
                    UIManager.showToast(Lang.ui_pilltower7)
                else
                    UIPilltowerRank.show()
                end
            elseif sender == btn_reset then
                if UIPilltower.UserData.curFightPoint == 1 then
                    UIManager.showToast(Lang.ui_pilltower8)
                    return
                end
                utils.showDialog(Lang.ui_pilltower9, function()
                    UIPilltower.netSendPackage({int={p2=4}}, function(_msgData)
                        UIPilltower.resetData(true)
                        UIPilltower.setup()
                    end)
                end)
            elseif sender == btn_again then
                if UIPilltower.UserData.historyMaxPoint and UIPilltower.UserData.historyMaxPoint >= Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION) then
                    if UIPilltower.UserData.curFightPoint ~= 1 then
                        UIManager.showToast(Lang.ui_pilltower10)
                        return
                    end
                    if UIPilltower.UserData.challengeNums == nil or (UIPilltower.UserData.challengeNums and UIPilltower.UserData.challengeNums == 0) then
                        UIManager.showToast(Lang.ui_pilltower11)
                        return
                    end
                    UIPilltower.netSendPackage({int={p2=9}}, function(_msgData)
                        if _msgData then
                            local _state = _msgData.msgdata.int.r1 -- 0成功,1失败
                            if type(_state) == "number" and _state == 1 then
                                utils.showSureDialog(_msgData.msgdata.string.r2, function()
                                    UIManager.popAllScene()
                                    UIPilltower.resetData(true)
                                    UIPilltower.UserData.challengeNums = DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value
                                    UIPilltower.setup()
                                end)
                            else
                                onMopUp(_msgData)
                            end
                        elseif UIPilltower.UserData.isDebug then
                            onMopUp()
                        end
                    end)
                else
                    UIManager.showToast(string.format(Lang.ui_pilltower12, Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION)))
                end
            end
        end
    end
    btn_back:addTouchEventListener(onClickEvent)
    btn_help:addTouchEventListener(onClickEvent)
    btn_preview:addTouchEventListener(onClickEvent)
    btn_rank:addTouchEventListener(onClickEvent)
    btn_reset:addTouchEventListener(onClickEvent)
    btn_again:addTouchEventListener(onClickEvent)
end

function UIPilltower.netSendPackage(_params, _callFunc)
    if UIPilltower.UserData.isDebug then
        _callFunc()
    else
        UIManager.showLoading()
        netSendPackage({
            header = StaticMsgRule.dantaHandler,
		    msgdata = _params
	    }, _callFunc)
    end
end

function UIPilltower.setup(_callback)
    if _onFightWinCallback and not _callback then
        setUIEnabled(false)
    end
    local image_basemap = UIPilltower.Widget:getChildByName("image_basemap")
    local image_base_title = image_basemap:getChildByName("image_base_title")
    ccui.Helper:seekNodeByName(image_base_title, "label_fight"):setString(tostring(utils.getFightValue())) --战力值
    ccui.Helper:seekNodeByName(image_base_title, "text_gold_number"):setString(tostring(net.InstPlayer.int["5"])) --元宝数
    ccui.Helper:seekNodeByName(image_base_title, "text_silver_number"):setString(net.InstPlayer.string["6"]) --银币数
    ccui.Helper:seekNodeByName(image_base_title, "text_star_number"):setString(tostring(UIPilltower.UserData.medalCount)) --勋章数量
    local image_di_reset = image_basemap:getChildByName("image_di_reset")
    local ui_floorNum = image_base_title:getChildByName("text_floor")
    ui_floorNum:setString(string.format(Lang.ui_pilltower13, UIPilltower.UserData.historyMaxPoint and UIPilltower.UserData.historyMaxPoint or 0))
    local ui_resetNum = image_di_reset:getChildByName("text_reset")
    local _challengeNums = UIPilltower.UserData.challengeNums and UIPilltower.UserData.challengeNums or 0
    if _challengeNums == 0 then
        ui_resetNum:setString(Lang.ui_pilltower14)
    else
        ui_resetNum:setString(string.format(Lang.ui_pilltower15, _challengeNums, DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value))
    end

    local ui_againText = image_di_reset:getChildByName("text_again")
    if UIPilltower.UserData.historyMaxPoint and UIPilltower.UserData.historyMaxPoint >= Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION) then
        if UIPilltower.UserData.curFightPoint == 1 then
            ui_againText:setString(Lang.ui_pilltower16)
        else
            ui_againText:setString(string.format(Lang.ui_pilltower17, nextMopUpCondition()))
        end
    else
        ui_againText:setString(string.format(Lang.ui_pilltower18, Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION)))
    end
    

    initFloorUI()
    initPointsData()
    if not UIPilltower.UserData.myCardData then
        initMyCardData()
    end
    if (not UIPilltower.UserData.historyMaxPoint) or (not UIPilltower.UserData.challengeNums) then
        UIPilltower.netSendPackage({int={p2=1}}, function(_msgData)
            if _msgData then
                UIPilltower.UserData.historyMaxPoint = _msgData.msgdata.int.r2
                UIPilltower.UserData.challengeNums = _msgData.msgdata.int.r3
            elseif UIPilltower.UserData.isDebug then
                UIPilltower.UserData.historyMaxPoint = 0
                UIPilltower.UserData.challengeNums = DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value
            end
            ui_floorNum:setString(string.format(Lang.ui_pilltower19, UIPilltower.UserData.historyMaxPoint))
            if UIPilltower.UserData.challengeNums == 0 then
                ui_resetNum:setString(Lang.ui_pilltower20)
            else
                ui_resetNum:setString(string.format(Lang.ui_pilltower21, UIPilltower.UserData.challengeNums, DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value))
            end
            if UIPilltower.UserData.historyMaxPoint >= Encrypt.decryptNumber(MOP_UP_OPEN_CONDITION) then
                if UIPilltower.UserData.curFightPoint == 1 then
                    ui_againText:setString(Lang.ui_pilltower22)
                else
                    ui_againText:setString(string.format(Lang.ui_pilltower23, nextMopUpCondition()))
                end
            end
        end)
    end
    if _callback then
        _callback()
    end
    UIMenu.hint_pilltower = false
end

function UIPilltower.setFightWinCallback(_callbackFunc, _things)
    _onFightWinCallback = _callbackFunc
    _awardThings = _things
end

function UIPilltower.refreshMedalCount()
    local image_basemap = UIPilltower.Widget:getChildByName("image_basemap")
    local image_base_title = image_basemap:getChildByName("image_base_title")
    ccui.Helper:seekNodeByName(image_base_title, "text_star_number"):setString(tostring(UIPilltower.UserData.medalCount)) --勋章数量
end

function UIPilltower.free()
     --*****测试
--    UIPilltower.UserData.curFightPoint = utils.random(1, 25)
--    UIPilltower.UserData.myCardData = nil
--    _randomMonsterData = nil
--    UIPilltower.UserData.medalCount = 0
     --*****测试
     _onFightWinCallback = nil
     _awardThings = nil
end

function UIPilltower.exitWaring(_callFunc)
    if UIPilltower.Widget and UIPilltower.Widget:getParent() then
        if UIPilltower.UserData.curFightPoint > 1 then
            utils.showDialog(Lang.ui_pilltower24, function()
                UIPilltower.netSendPackage({int={p2=4}}, function(_msgData)
                    if _callFunc then _callFunc() end
                    UIPilltower.resetData()
                end)
    --            {_callFunc,UIPilltower.resetData}
            end)
            return true
        end
        UIPilltower.resetData()
    end
end

function UIPilltower.checkImageHint()
    if not UIPilltower.UserData.isDebug then
        if UIMenu.hint_pilltower == nil then
            if net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level then
                UIPilltower.netSendPackage({int={p2=1}}, function(_msgData)
                    if _msgData and _msgData.msgdata.int.r3 >= 0 then
                        if _msgData.msgdata.int.r3 > 0 then
                            UIMenu.hint_pilltower = true
                        else
                            UIMenu.hint_pilltower = false
                        end
                        UIMenu.showPilltowerHint()
                    end
                end)
            end
        else
            return UIMenu.hint_pilltower
        end
    end
    return false
end
