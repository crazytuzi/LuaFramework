require"Lang"
UITowerTest = {}

local FREE_RESET_COUNT = 2 --免费重置次数

local ui_fightValue = nil
local ui_gold = nil
local ui_money = nil
local ui_fire = nil
local btn_reset = nil
-- local btn_search = nil
local btn_sweep = nil
local ui_image_base_task = nil
local ui_resetNum = nil
-- local ui_searchNum = nil
local ui_sweepNum = nil
local bgPanel = nil

local ui_anim22s = nil
local ui_anim23s = nil
local ui_anim24 = nil
local ui_anim25 = nil
local ui_anim26 = nil

local _curFightStoreyId = nil --当前战斗的层ID
local _victoryValue = nil --通关条件值
local _isCleanAnim = true --是否清除动画
local _isPass = nil --是否通关
local _prevCardImgs = nil

UITowerTest._isStrong = 0

--获取搜索和重置次数
local function getSearchOrResetNum()
	local searchNum, resetNum = 0, 0
	for key, obj in pairs(DictVIP) do
		if net.InstPlayer.int["19"] == obj.level then
			searchNum = obj.pagodaSearchNum
			resetNum = obj.pagodaResetNum
			break
		end
	end
	return searchNum, resetNum
end

function UITowerTest.checkImageHint()
    local result = false
    if FREE_RESET_COUNT - net.InstPlayerPagoda.int["5"] > 0 then
        result = true
    else
        result = false
    end
    return result
end

local function netCallbackFunc(data)
	local code = tonumber(data.header)
	if code == StaticMsgRule.reset or code == StaticMsgRule.mop then
		UITowerTest.setup()
        UIMenu.showTowerHint()
		if code == StaticMsgRule.mop then
			UIManager.showToast(Lang.ui_tower_test1)
		end
	elseif code == StaticMsgRule.search then
		-- local searchNum, resetNum = getSearchOrResetNum()
		-- ui_searchNum:setString("今日次数：" .. net.InstPlayerPagoda.int["6"] .. "/" .. searchNum)
		-- ui_searchNum:setString("今日次数：" .. (searchNum - net.InstPlayerPagoda.int["6"]) .. "/" .. searchNum)
--		if net.InstPlayerPagoda.int["6"] == 0 then
--			btn_search:loadTextures("ui/tk_btn02.png", "ui/tk_btn02.png")
--			btn_search:setTouchEnabled(false)
--		end
		local flag = data.msgdata.int["1"] --0:失败  1:成功
		if flag == 1 then
			UITowerChallenge.setPagodaStoreyId(_curFightStoreyId)
			UIManager.pushScene("ui_tower_challenge")
		else
			UIManager.showToast(Lang.ui_tower_test2)
		end
	elseif code == StaticMsgRule.war then
        local dictPagodaStoreyData = DictPagodaStorey[tostring(_curFightStoreyId)] --塔层字典数据
	    local pagodaFormationData = DictPagodaFormation[tostring(dictPagodaStoreyData.pagodaFormationId)] --塔阵字典数据
        if Fight.isWin() and _curFightStoreyId ~= pagodaFormationData.pagodaStorey5 then
            UITowerWinSmall.setParam({_curFightStoreyId, _victoryValue}) --[1]:塔层字典ID, [2]:通关条件值
		    UIManager.pushScene("ui_tower_win_small")           
        else
		    UITowerWin.setParam({_curFightStoreyId, _victoryValue}) --[1]:塔层字典ID, [2]:通关条件值
		    UIManager.pushScene("ui_tower_win")           
        end
	end
end

local function sendData(_header, param)
	local sendData
	if _header == StaticMsgRule.reset or _header == StaticMsgRule.search then
		sendData = {
			header = _header,
			msgdata = {
				int = {
					instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
				}
			}
		}
	elseif _header == StaticMsgRule.mop then
		sendData = {
			header = _header,
			msgdata = {
				int = {
					instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
				}
			}
		}
	elseif _header == StaticMsgRule.war then
		local _value = param
		if Fight.isWin() then
			_value = "1_" .. param
		else
			_value = "0_" .. param
		end
		sendData = {
			header = _header,
			msgdata = {
				int = {
					instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
					pagodaStoreyId = _curFightStoreyId,
					type = 0, --0-普通层   1-神秘层
				},
				string = {
					victoryValue = _value, --胜利失败(1:胜利,0:失败)_胜利值
					coredata = GlobalLastFightCheckData
				}
			}
		}
	end
	UIManager.showLoading()
	netSendPackage(sendData, netCallbackFunc)
end

local function showDialog(msg, callfunc)
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
	bg_image:retain()
	bg_image:setAnchorPoint(cc.p(0.5, 0.5))
	bg_image:setPreferredSize(cc.size(500, 300))
	bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2))
	local bgSize = bg_image:getPreferredSize()
	
	local title = ccui.Text:create()
	title:setFontName(dp.FONT)
	title:setString(Lang.ui_tower_test3)
	title:setFontSize(35)
	title:setTextColor(cc.c4b(255, 255, 255, 255))
	title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
	bg_image:addChild(title)
	local msgLabel = ccui.Text:create()
	msgLabel:setString(msg)
	msgLabel:setFontName(dp.FONT)
	msgLabel:setFontSize(26)
	msgLabel:setTextAreaSize(cc.size(bgSize.width * 0.85, 80))
	msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
	msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.6))
	bg_image:addChild(msgLabel)
	
	local closeBtn = nil
	if callfunc == nil then 
		closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
		closeBtn:setPressedActionEnabled(true)
		closeBtn:setTouchEnabled(true)
		closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.3, bgSize.height - closeBtn:getContentSize().height * 0.3))
		bg_image:addChild(closeBtn, 3)
	end
	local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
	sureBtn:setTitleFontName(dp.FONT)
	sureBtn:setTitleText(Lang.ui_tower_test4)
	sureBtn:setTitleFontSize(25)
	sureBtn:setPressedActionEnabled(true)
	sureBtn:setTouchEnabled(true)
	sureBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.25))
	bg_image:addChild(sureBtn)
	local cancelBtn = ccui.Button:create("ui/tk_btn_purple.png", "ui/tk_btn_purple.png")
	cancelBtn:setTitleFontName(dp.FONT)
	cancelBtn:setTitleText(Lang.ui_tower_test5)
	cancelBtn:setTitleFontSize(25)
	cancelBtn:setPressedActionEnabled(true)
	cancelBtn:setTouchEnabled(true)
	cancelBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.25))
	bg_image:addChild(cancelBtn)
	local childs = UIManager.uiLayer:getChildren()
	local function btnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.uiLayer:removeChild(bg_image, true)
			cc.release(bg_image)
			for i = 1, #childs do
				childs[i]:setEnabled(true)
			end
			if sender == sureBtn then
				if callfunc then
					callfunc()
				else
					sendData(StaticMsgRule.reset)
				end
			end
		end
	end
	if closeBtn then
		closeBtn:addTouchEventListener(btnEvent)
	end
	sureBtn:addTouchEventListener(btnEvent)
	cancelBtn:addTouchEventListener(btnEvent)
	
	UIManager.uiLayer:addChild(bg_image, 10000)
	for i = 1, #childs do
		if childs[i]:getTag() ~= bg_image then
			childs[i]:setEnabled(false)
		end
	end
end

local function cleanAnim()
	if ui_anim22s then
		for key, obj in pairs(ui_anim22s) do
			obj:removeFromParent()
		end
		ui_anim22s = nil
	end
	if ui_anim23s then
		for key, obj in pairs(ui_anim23s) do
			obj:removeFromParent()
		end
		ui_anim23s = nil
	end
	if ui_anim24 then
		ui_anim24:removeFromParent()
		ui_anim24 = nil
	end
end

local function setPagodaInfo()
	cleanAnim()
	_curFightStoreyId = net.InstPlayerPagoda.int["3"]
	local data = DictPagodaStorey[tostring(_curFightStoreyId)]
	local _storeyName = ui_image_base_task:getChildByName("text_level_number") --层名称
	local _fightNums = ui_image_base_task:getChildByName("text_challenge_number") --挑战次数
	local _passCondition = ui_image_base_task:getChildByName("text_pass_condition") --通关条件
	-- local _passAward = ui_image_base_task:getChildByName("text_pass_award") --通关奖励
	
	_storeyName:setString(Lang.ui_tower_test6.._curFightStoreyId..Lang.ui_tower_test7)
    if data then
	    local _text = ""
	    if data.victoryMeans == 1 then
		    _text = Lang.ui_tower_test8 .. data.victoryValue
	    elseif data.victoryMeans == 2 then
		    _text = Lang.ui_tower_test9 .. data.victoryValue
	    elseif data.victoryMeans == 3 then
		    _text = Lang.ui_tower_test10 .. data.victoryValue .. "%"
	    elseif data.victoryMeans == 4 then
		    _text = Lang.ui_tower_test11
	    end
	    _fightNums:setString(string.format(Lang.ui_tower_test12, net.InstPlayerPagoda.int["4"]))
	    _passCondition:setString(Lang.ui_tower_test13 .. _text)
	    -- _passAward:setString("通关奖励：" .. data.copper .. "银币 ")
	    -- _passAward:setString("通关奖励：" .. data.copper .. "银币 " .. data.culture .. "修为")
    else
        _storeyName:setString(Lang.ui_tower_test14..(_curFightStoreyId-1)..Lang.ui_tower_test15)
        bgPanel:getChildByName("image_go"):setVisible(true)
    end
	
	bgPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
		local monsterCard, bossCard, _dictStoreId = {}, nil, (data and data.id or (_curFightStoreyId - 1))
		for key, obj in pairs(DictPagodaCard) do
			if _dictStoreId == obj.pagodaStoreyId then
				local isBoss = obj.isBoss --是否Boss 0-不是 1-是
				if isBoss == 1 then
					bossCard = DictCard[tostring(obj.cardId)]
				end
				table.insert(monsterCard, #monsterCard + 1, DictCard[tostring(obj.cardId)])
			end
		end
		if bossCard then
			for key, obj in pairs(monsterCard) do
				if bossCard.id == obj.id then
					table.remove(monsterCard, key)
					break
				end
			end
		end
		ui_anim22s = {}
		_prevCardImgs = {}
		for i = 1, 3 do
			local dictCardData = monsterCard[i]
			if i == 3 and bossCard then
				dictCardData = bossCard
			end
			if i == 3 then
				ui_anim22s[i] = ActionManager.getEffectAnimation(22, function(armature)
					ui_anim24 = ActionManager.getEffectAnimation(24, function(armature)
						armature:getAnimation():playWithIndex(0)
						bgPanel:getChildByName("image_zhan"):setTouchEnabled(true)
					end, 1)
					ui_anim24:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2 - 260)
					ui_anim24:setScale(0.8)
					bgPanel:addChild(ui_anim24)
					bgPanel:getChildByName("image_zhan"):setTouchEnabled(true)
				end)
			else
				ui_anim22s[i] = ActionManager.getEffectAnimation(22)
			end
            if dictCardData then
			    local qualityImg = utils.getQualityImage(dp.Quality.card, dictCardData.qualityId, dp.QualityImageType.middle)
			    ui_anim22s[i]:getBone("Layer59"):addDisplay(ccs.Skin:create(qualityImg), 0)
			    ui_anim22s[i]:getBone("Layer60"):addDisplay(ccs.Skin:create(qualityImg), 0)
			    ui_anim22s[i]:getBone("Layer61"):addDisplay(ccs.Skin:create(qualityImg), 0)
			    ui_anim22s[i]:getBone("Layer62"):addDisplay(ccs.Skin:create(qualityImg), 0)
			    ui_anim22s[i]:getBone("Layer63"):addDisplay(ccs.Skin:create(qualityImg), 0)
			    _prevCardImgs[i] = "image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName
			    ui_anim22s[i]:getBone("Layer64"):addDisplay(ccs.Skin:create(_prevCardImgs[i]), 0)
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
		monsterCard = nil
	end)))
end

local function onBtnResetEvent()
	local searchNum, resetNum = getSearchOrResetNum()
	-- if net.InstPlayerPagoda.int["5"] > 0 then

	if net.InstPlayerPagoda.int["5"] < resetNum then
		if net.InstPlayerPagoda.int["5"] >= FREE_RESET_COUNT and resetNum - net.InstPlayerPagoda.int["5"] > 0 then
			local _index = StaticSysConfig.pagodaResetOne
			if net.InstPlayerPagoda.int["5"] == 3 then
				_index = StaticSysConfig.pagodaResetOne
			elseif net.InstPlayerPagoda.int["5"] == 4 then
				_index = StaticSysConfig.pagodaResetTwo
			elseif net.InstPlayerPagoda.int["5"] == 5 then
				_index = StaticSysConfig.pagodaResetThree
			end
			local price = DictSysConfig[tostring(_index)].value
			if net.InstPlayer.int["5"] < price then
				UIManager.showToast(Lang.ui_tower_test16)
				return
			end
		end
		showDialog(Lang.ui_tower_test17)
	else
		UIManager.showToast(Lang.ui_tower_test18)
	end
end
local function netCallBackStrong( data )
    if data.header == StaticMsgRule.intoPagoda then       
        if UITowerTest._isStrong > 0 then
            local image_strong = ccui.Helper:seekNodeByName( UITowerTest.Widget , "image_strong")
            local aa = data.msgdata.int[ "1" ]
            if aa == 0 then
               image_strong:setVisible( true )   
               if UITowerTest._isStrong == 1 then
                   UIManager.pushScene( "ui_tower_strong" )
               end
            else
               image_strong:setVisible( false )           
            end
        end
    end
end
local function sendDataStrong( type )
    local sendData = {}
    if type == 1 then
        sendData = {
            header = StaticMsgRule.intoPagoda
        }
    elseif type == 2 then
        sendData = {
            header = StaticMsgRule.clickStrongEquip
        }
    end
    netSendPackage( sendData , netCallBackStrong )
end
function UITowerTest.init()
	bgPanel = ccui.Helper:seekNodeByName(UITowerTest.Widget, "image_basemap")
    bgPanel:getChildByName("image_go"):setVisible(false)
    bgPanel:getChildByName("image_go"):setLocalZOrder(10000)
	
	local ui_image_base_title = bgPanel:getChildByName("image_base_title")
	ui_fightValue = ccui.Helper:seekNodeByName(ui_image_base_title, "label_fight")
	ui_gold = ccui.Helper:seekNodeByName(ui_image_base_title, "text_gold_number")
	ui_money = ccui.Helper:seekNodeByName(ui_image_base_title, "text_silver_number")
	ui_fire = ccui.Helper:seekNodeByName(ui_image_base_title, "text_fire_number")
	local btn_preview = ui_image_base_title:getChildByName("btn_preview") --宝物预览按钮
	
	ui_image_base_task = bgPanel:getChildByName("image_base_task")
	local btn_zhan = bgPanel:getChildByName("image_zhan")

	local btn_back = bgPanel:getChildByName("btn_back")
	local btn_shop = bgPanel:getChildByName("btn_shop")
    local btn_up = bgPanel:getChildByName("btn_up")
	
	local ui_image_base_tab = ccui.Helper:seekNodeByName(UITowerTest.Widget, "image_base_tab")
	btn_reset = ui_image_base_tab:getChildByName("btn_reset") --重置按钮
	-- btn_search = ui_image_base_tab:getChildByName("btn_challenge") --搜索按钮
	btn_sweep = ui_image_base_tab:getChildByName("btn_sweep") --扫荡按钮
	ui_resetNum = btn_reset:getChildByName("text_reset_number")
	-- ui_searchNum = btn_search:getChildByName("text_challenge_number")
	ui_sweepNum = btn_sweep:getChildByName("text_sweep_number")

    local image_strong = ccui.Helper:seekNodeByName( UITowerTest.Widget , "image_gift")
    image_strong:getParent():setVisible( false )
	btn_back:setPressedActionEnabled(true)
	btn_shop:setPressedActionEnabled(true)
    btn_up:setPressedActionEnabled(true)
	btn_preview:setPressedActionEnabled(true)
	btn_reset:setPressedActionEnabled(true)
	-- btn_search:setPressedActionEnabled(true)
	btn_sweep:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_preview then
				UIManager.pushScene("ui_tower_preview")
			elseif sender == btn_back then
				-- UIMenu.onActivity()
				UIMenu.onHomepage()
			elseif sender == btn_shop then
				UIManager.pushScene("ui_tower_shop")
			elseif sender == btn_reset then
                if _curFightStoreyId > 1 then
                     onBtnResetEvent()
                else
                    UIManager.showToast(Lang.ui_tower_test19)
                end
				
			-- elseif sender == btn_search then
			-- 	local searchNum, resetNum = getSearchOrResetNum()
			-- 	-- if net.InstPlayerPagoda.int["6"] > 0 then
			-- 	if net.InstPlayerPagoda.int["6"] < searchNum then
			-- 		sendData(StaticMsgRule.search)
			-- 	else
			-- 		UIManager.showToast("今日次数已用完！")
			-- 	end
			elseif sender == btn_sweep then
				if btn_sweep:isBright() then
                    btn_zhan:setTouchEnabled(false)
					sendData(StaticMsgRule.mop)
                    btn_zhan:setTouchEnabled(true)
				else
					UIManager.showToast(Lang.ui_tower_test20)
				end
			elseif sender == btn_zhan then
                if DictPagodaStorey[tostring(_curFightStoreyId)] then
				    AudioEngine.playEffect("sound/pata.mp3")
				    if net.InstPlayerPagoda.int["4"] == 0 then
					    showDialog(Lang.ui_tower_test21, onBtnResetEvent)
					    return
				    end
				    local function callBackFunc(victoryValue)
					    _victoryValue = math.floor(victoryValue)
					    sendData(StaticMsgRule.war, _victoryValue)
                        btn_sweep:setTouchEnabled(true)
				    end
                    btn_sweep:setTouchEnabled(false)
				    utils.sendFightData(_curFightStoreyId,dp.FightType.FIGHT_PAGODA,callBackFunc)
				    _isCleanAnim = false                   
				    UIFightMain.loading()
                else
                    UIManager.showToast(Lang.ui_tower_test22)
                end
            elseif sender == btn_up then
                if net.InstPlayerPagoda.int["7"] >= 60 then
                    UIManager.showWidget("ui_tower_up")
                else
                    UIManager.showToast(Lang.ui_tower_test23)
                end
            elseif sender == image_strong then
                UIManager.pushScene( "ui_tower_strong" )
                sendDataStrong( 2 )
			end
		end
	end
	btn_back:addTouchEventListener(btnTouchEvent)
	btn_shop:addTouchEventListener(btnTouchEvent)
    btn_up:addTouchEventListener(btnTouchEvent)
	btn_preview:addTouchEventListener(btnTouchEvent)
	btn_reset:addTouchEventListener(btnTouchEvent)
	-- btn_search:addTouchEventListener(btnTouchEvent)
	btn_sweep:addTouchEventListener(btnTouchEvent)
	btn_zhan:addTouchEventListener(btnTouchEvent)
    image_strong:addTouchEventListener( btnTouchEvent )
end

function UITowerTest.refreshFire()
    if ui_fire then
        ui_fire:setString(tostring(net.InstPlayer.int["21"]))
    end
end

function UITowerTest.setup()
    bgPanel:getChildByName("image_go"):setVisible(false)
    UITowerTest._isStrong = cc.UserDefault:getInstance():getIntegerForKey( "isStrong" , 0)
    local image_strong = ccui.Helper:seekNodeByName( UITowerTest.Widget , "image_strong")
    image_strong:setVisible( false )
    sendDataStrong( 1 )
	_isCleanAnim = true
	_curFightStoreyId = nil
	ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(net.InstPlayer.string["6"])
	UITowerTest.refreshFire()
	
	local searchNum, resetNum = getSearchOrResetNum()
	-- ui_resetNum:setString("重置次数：" .. net.InstPlayerPagoda.int["5"])
	-- ui_searchNum:setString("今日次数：" .. net.InstPlayerPagoda.int["6"] .. "/" .. searchNum)
	if resetNum - net.InstPlayerPagoda.int["5"] == 0 then
		ui_resetNum:setString(Lang.ui_tower_test24)
	else
		ui_resetNum:setString(Lang.ui_tower_test25 .. (FREE_RESET_COUNT - net.InstPlayerPagoda.int["5"]))
	end
	if net.InstPlayerPagoda.int["5"] >= FREE_RESET_COUNT and resetNum - net.InstPlayerPagoda.int["5"] > 0 then
		ui_resetNum:setVisible(false)
		ui_resetNum:getParent():getChildByName("image_gold"):setVisible(true)
		local _index = StaticSysConfig.pagodaResetOne
		if net.InstPlayerPagoda.int["5"] == 2 then
			_index = StaticSysConfig.pagodaResetOne
		elseif net.InstPlayerPagoda.int["5"] == 3 then
			_index = StaticSysConfig.pagodaResetTwo
		elseif net.InstPlayerPagoda.int["5"] == 4 then
			_index = StaticSysConfig.pagodaResetThree
		end
		local price = DictSysConfig[tostring(_index)].value
		ui_resetNum:getParent():getChildByName("image_gold"):getChildByName("text_gold_number"):setString(tostring(price))
	else
		ui_resetNum:getParent():getChildByName("image_gold"):setVisible(false)
		ui_resetNum:setVisible(true)
	end
	-- ui_searchNum:setString("今日次数：" .. (searchNum - net.InstPlayerPagoda.int["6"]) .. "/" .. searchNum)
	ui_sweepNum:setString(Lang.ui_tower_test26 .. net.InstPlayerPagoda.int["7"])
	bgPanel:getChildByName("image_zhan"):setTouchEnabled(false)
	
	if _isPass ~= nil then
		if ui_anim24 then
			ui_anim24:removeFromParent()
			ui_anim24 = nil
		end
		if _isPass then
			ui_anim25 = ActionManager.getEffectAnimation(25, function(armature)
				armature:removeFromParent()
				ui_anim25 = nil
				ui_anim23s = {}
				for key, cardImg in pairs(_prevCardImgs) do
					if key == #_prevCardImgs then
						ui_anim23s[key] = ActionManager.getEffectAnimation(23, function(armature)
							setPagodaInfo()
						end)
					else
						ui_anim23s[key] = ActionManager.getEffectAnimation(23)
					end
					ui_anim23s[key]:getBone("Layer73"):addDisplay(ccs.Skin:create(cardImg), 0)
					ui_anim23s[key]:setPosition(ui_anim22s[key]:getPosition())
					--[[
					if key == 1 then
						ui_anim23s[key]:setScale(0.5)
						ui_anim23s[key]:setPosition(bgPanel:getContentSize().width / 2 / 2, bgPanel:getContentSize().height / 2)
					elseif key == 2 then
						ui_anim23s[key]:setScale(0.5)
						ui_anim23s[key]:setPosition(bgPanel:getContentSize().width / 2 + bgPanel:getContentSize().width / 2 / 2, bgPanel:getContentSize().height / 2)
					elseif key == 3 then
						ui_anim23s[key]:setScale(0.7)
						ui_anim23s[key]:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2 + 100)
					end
					]]
					bgPanel:addChild(ui_anim23s[key])
				end
				if ui_anim22s then
					for key, obj in pairs(ui_anim22s) do
						obj:removeFromParent()
					end
					ui_anim22s = nil
				end
			end)
			ui_anim25:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2)
			bgPanel:addChild(ui_anim25)
		else
			_curFightStoreyId = net.InstPlayerPagoda.int["3"]
			ui_image_base_task:getChildByName("text_challenge_number"):setString(string.format(Lang.ui_tower_test27, net.InstPlayerPagoda.int["4"]))
			ui_anim26 = ActionManager.getEffectAnimation(26, function(armature)
				armature:removeFromParent()
				ui_anim26 = nil
				ui_anim24 = ActionManager.getEffectAnimation(24, function(armature)
					armature:getAnimation():playWithIndex(0)
					bgPanel:getChildByName("image_zhan"):setTouchEnabled(true)
				end, 1)
				ui_anim24:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2 - 260)
				ui_anim24:setScale(0.8)
				bgPanel:addChild(ui_anim24)
			end)
			ui_anim26:setPosition(bgPanel:getContentSize().width / 2, bgPanel:getContentSize().height / 2)
			bgPanel:addChild(ui_anim26)
		end
		_isPass = nil
	else
		setPagodaInfo()
	end
	
if net.InstPlayerPagoda.int["7"] >= DictSysConfig[tostring(StaticSysConfig.mopNum)].value then --暂定为20层开启扫荡
		-- btn_sweep:setEnabled(true)
		btn_sweep:setBright(true)
	else
		-- btn_sweep:setEnabled(false)
		btn_sweep:setBright(false)
	end
end

function UITowerTest.isWin(isWin)
	_isPass = isWin
end

function UITowerTest.free()
	if _isCleanAnim then
		cleanAnim()
	end
	if ui_anim25 then
		ui_anim25:removeFromParent()
		ui_anim25 = nil
	end
	if ui_anim26 then
		ui_anim26:removeFromParent()
		ui_anim26 = nil
	end
	_isPass = nil
   -- _isStrong = nil
end
