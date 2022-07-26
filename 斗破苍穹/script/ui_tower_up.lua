require"Lang"
UITowerUp = {}

local _lineupData = nil
local _lifeUp = 0
local _fightUp = 0
local _buyCount = 0
local _freeCount = 0
local ui_anim22s = nil

local function refreshMoney()
    local image_basemap = ccui.Helper:seekNodeByName(UITowerUp.Widget, "image_basemap")
	local ui_image_base_title = image_basemap:getChildByName("image_base_title")
	local ui_fightValue = ccui.Helper:seekNodeByName(ui_image_base_title, "label_fight")
	local ui_gold = ccui.Helper:seekNodeByName(ui_image_base_title, "text_gold_number")
	local ui_money = ccui.Helper:seekNodeByName(ui_image_base_title, "text_silver_number")
	local ui_fire = ccui.Helper:seekNodeByName(ui_image_base_title, "text_fire_number")
    ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(net.InstPlayer.string["6"])
    ui_fire:setString(tostring(utils.getThingCount(StaticThing.thing99)))
end

local function cleanAnim()
	if ui_anim22s then
		for key, obj in pairs(ui_anim22s) do
			obj:removeFromParent()
		end
		ui_anim22s = nil
	end
end

local function onEnterAnim(bgPanel)
    ui_anim22s = {}
    local _data = utils.stringSplit(_lineupData, ";")
	for i = 1, 3 do
        local dictCardData = nil
        local qualityId = 1
        if _data and _data[i] then
            local _tempData = utils.stringSplit(_data[i], "_")
            dictCardData = DictCard[_tempData[1]]
            qualityId = tonumber(_tempData[3])
            _tempData = nil
        end
		ui_anim22s[i] = ActionManager.getEffectAnimation(22)
        if dictCardData then
			local qualityImg = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle)
			ui_anim22s[i]:getBone("Layer59"):addDisplay(ccs.Skin:create(qualityImg), 0)
			ui_anim22s[i]:getBone("Layer60"):addDisplay(ccs.Skin:create(qualityImg), 0)
			ui_anim22s[i]:getBone("Layer61"):addDisplay(ccs.Skin:create(qualityImg), 0)
			ui_anim22s[i]:getBone("Layer62"):addDisplay(ccs.Skin:create(qualityImg), 0)
			ui_anim22s[i]:getBone("Layer63"):addDisplay(ccs.Skin:create(qualityImg), 0)
			local _cardImage = "image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName
			ui_anim22s[i]:getBone("Layer64"):addDisplay(ccs.Skin:create(_cardImage), 0)
        end
		if i == 1 then
			ui_anim22s[i]:setScale(0.5)
			ui_anim22s[i]:setPosition(bgPanel:getContentSize().width / 2 / 2, bgPanel:getContentSize().height / 2 - 100)
		elseif i == 2 then
			ui_anim22s[i]:setScale(0.5)
			ui_anim22s[i]:setPosition(bgPanel:getContentSize().width / 2 + bgPanel:getContentSize().width / 2 / 2, bgPanel:getContentSize().height / 2 - 100)
		elseif i == 3 then
			ui_anim22s[i]:setScale(0.7)
			ui_anim22s[i]:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2)
		end
        if bgPanel:getChildByName("ui_anim22s"..i) then
            bgPanel:getChildByName("ui_anim22s"..i):removeFromParent()
        end
        ui_anim22s[i]:setName("ui_anim22s"..i)
		bgPanel:addChild(ui_anim22s[i])
	end
end

local function onFightDoneDialog(_hurtValue)
    local toast_bg = cc.Scale9Sprite:create("ui/quality_middle.png")
    toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
    toast_bg:setPreferredSize(cc.size(474, 105))
    toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    local description = ccui.Text:create()
    description:setFontSize(35)
    description:setFontName(dp.FONT)
    description:setTextColor(cc.c3b(255, 255, 0))
    description:setString(Lang.ui_tower_up1 .. _hurtValue)
    description:setPosition(cc.p(toast_bg:getPreferredSize().width / 2, toast_bg:getPreferredSize().height / 2))
    toast_bg:addChild(description)
    UIManager.uiLayer:addChild(toast_bg, 1000)
    toast_bg:retain()
    local hideToast = function()
        if toast_bg then
            UIManager.uiLayer:removeChild(toast_bg, true)
            cc.release(toast_bg)
        end
    end
    toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 80)), cc.DelayTime:create(0.8), cc.MoveBy:create(0.3, cc.p(0, 120)), cc.CallFunc:create(hideToast)))
end

function UITowerUp.init()
    local image_basemap = UITowerUp.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local btn_tower = image_basemap:getChildByName("btn_tower")
    local btn_find = image_basemap:getChildByName("btn_find")
    local btn_reset = image_basemap:getChildByName("image_shadow"):getChildByName("btn_reset")
    btn_back:setPressedActionEnabled(true)
    btn_rank:setPressedActionEnabled(true)
    btn_tower:setPressedActionEnabled(true)
    btn_find:setPressedActionEnabled(true)
    btn_reset:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                -- UIMenu.onActivity()
                UIMenu.onHomepage()
            elseif sender == btn_rank then
                UITowerRank.show()
            elseif sender == btn_tower then
                UIManager.showWidget("ui_tower_test")
            elseif sender == btn_find then
                UITowerCheck.show({lineupData = _lineupData})
            elseif sender == btn_reset then
                local _todayCount = DictSysConfig[tostring(StaticSysConfig.tianguan_freeNum)].value - _freeCount
                if _todayCount <= 0 and _buyCount >= DictSysConfig[tostring(StaticSysConfig.tianguan_goldNum)].value then
                    return UIManager.showToast(Lang.ui_tower_up2)
                elseif _todayCount <= 0 then
                    if StaticSysConfig["tianguan_moeny".._buyCount+1] then
                        local _price = DictSysConfig[tostring(StaticSysConfig["tianguan_moeny".._buyCount+1])].value
                        if net.InstPlayer.int["5"] >= _price then
                            UIAlliance.showDialog(string.format(Lang.ui_tower_up3, _price), function()
                                UIManager.showLoading()
                                netSendPackage({header=StaticMsgRule.buyTianGuanFightData, msgdata={}}, function(_msgData)
                                    UITowerUp.setup(true)
                                    UIManager.showToast(Lang.ui_tower_up4)
                                end)
                            end)
                        else
                            UIManager.showToast(Lang.ui_tower_up5)
                        end
                    end
                    return
                end
                local onFightDoneCall = function(_isWin, _hurtValue)
                    UIManager.showLoading()
	                netSendPackage({header=StaticMsgRule.tianGuanWarWin, msgdata={int={hurt=_hurtValue}}}, function(_msgData)
                        local animationId = _isWin and 11 or 12
                        local animation = ActionManager.getUIAnimation(animationId, function(armature)
                            UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
                                if armature and armature:getParent() then armature:removeFromParent() end
                                UIManager.showWidget("ui_notice", "ui_tower_up", "ui_menu")
                            end )))
                        end )
                        animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height * 0.75))
                        UIManager.gameLayer:addChild(animation, 1000000)
                        onFightDoneDialog(_hurtValue)
                    end)
                end
                UIManager.showLoading()
	            netSendPackage({header=StaticMsgRule.fightTianGuanWar, msgdata={}}, function(_msgData)
                    pvp.loadGameData(_msgData)
                    utils.sendFightData({lifeUp=_lifeUp/100, fightUp=_fightUp/100}, dp.FightType.FIGHT_TOWER_UP, onFightDoneCall)
                    UIFightMain.loading()
                end)
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    btn_tower:addTouchEventListener(onButtonEvent)
    btn_find:addTouchEventListener(onButtonEvent)
    btn_reset:addTouchEventListener(onButtonEvent)
end

function UITowerUp.setup(_isReloadAnim)
    if not _isReloadAnim then
        cleanAnim()
    end
    refreshMoney()
    local image_basemap = UITowerUp.Widget:getChildByName("image_basemap")
    local image_base_info = image_basemap:getChildByName("image_base_info")
    local ui_name = image_base_info:getChildByName("text_name")
    local ui_lifeUp = image_base_info:getChildByName("text_life")
    local ui_fightUp = image_base_info:getChildByName("text_fight")
    local image_base_hurt = image_basemap:getChildByName("image_base_hurt")
    local ui_hurt = image_base_hurt:getChildByName("text_hurt")
    local ui_rank = image_base_hurt:getChildByName("text_rank")
    local ui_fightCount = image_basemap:getChildByName("image_shadow"):getChildByName("text_reset_number")

    --default
    ui_name:setString(Lang.ui_tower_up6)
    ui_lifeUp:setString(Lang.ui_tower_up7)
    ui_fightUp:setString(Lang.ui_tower_up8)
    ui_hurt:setString(Lang.ui_tower_up9)
    ui_rank:setString(Lang.ui_tower_up10)
    ui_fightCount:setString(Lang.ui_tower_up11)

    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.openTianGuanPanel, msgdata={}}, function(_msgData)
        ui_name:setString(Lang.ui_tower_up12 .. _msgData.msgdata.string.bossName)
        _lifeUp = _msgData.msgdata.int.blood --生命提升
        _fightUp = _msgData.msgdata.int.attack --攻击提升
        _buyCount = _msgData.msgdata.int.buyCount --购买次数
        _freeCount = _msgData.msgdata.int.freeCount --已经使用的免费次数
        _lineupData = _msgData.msgdata.string.format --阵型英雄 卡牌ID_星级_品质_位置_类型(1主力,2替补);
        ui_lifeUp:setString(string.format(Lang.ui_tower_up13, _msgData.msgdata.int.blood))
        ui_fightUp:setString(string.format(Lang.ui_tower_up14, _msgData.msgdata.int.attack))
        ui_hurt:setString(Lang.ui_tower_up15 .. _msgData.msgdata.int.hurt)
        ui_rank:setString(Lang.ui_tower_up16 .. _msgData.msgdata.int.rank)
        local _todayCount = DictSysConfig[tostring(StaticSysConfig.tianguan_freeNum)].value - _freeCount
        if _todayCount == 0 then
            local _canBuyCount = DictSysConfig[tostring(StaticSysConfig.tianguan_goldNum)].value - _buyCount
            ui_fightCount:setString(Lang.ui_tower_up17 .. _todayCount .. string.format(Lang.ui_tower_up18, _canBuyCount))
        else
            ui_fightCount:setString(Lang.ui_tower_up19 .. _todayCount)
        end
        if not _isReloadAnim then
            onEnterAnim(image_basemap)
        end
    end)
end

function UITowerUp.free()
    cleanAnim()
    _lineupData = nil
    _lifeUp = 0
    _fightUp = 0
    _buyCount = 0
    _freeCount = 0
end
