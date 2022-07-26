require"Lang"
UIAllianceBuild = {}

local MAX_PLAN_VALUE = 300 --最大进度值
local PLAN_NODE_1 = 80
local PLAN_NODE_2 = 160
local PLAN_NODE_3 = 250

local _curBoxThings = nil

local netCallbackFunc = nil

local function initAllianceInfo(_msgData)
	local titlePanel = UIAllianceBuild.Widget:getChildByName("image_di_info")
	local ui_offerLabel = ccui.Helper:seekNodeByName(titlePanel, "text_alliance_number")
	local ui_playerGold = ccui.Helper:seekNodeByName(titlePanel, "text_gold")
	local ui_playerMenoy = ccui.Helper:seekNodeByName(titlePanel, "text_slive")
	ui_offerLabel:setString(tostring(net.InstUnionMember.int["5"]))
	ui_playerGold:setString(tostring(net.InstPlayer.int["5"]))
	ui_playerMenoy:setString(net.InstPlayer.string["6"])

	local allianceInfoPanel = UIAllianceBuild.Widget:getChildByName("image_exp")
	local ui_allianceLevel = ccui.Helper:seekNodeByName(allianceInfoPanel, "text_alliance_lv")
	local ui_allianceName = ccui.Helper:seekNodeByName(allianceInfoPanel, "text_alliance_name")
	local ui_allianceExpBar = allianceInfoPanel:getChildByName("bar_exp")
	local ui_allianceExp = ui_allianceExpBar:getChildByName("text_exp")
	ui_allianceLevel:setString(tonumber(_msgData.int["4"]))
	ui_allianceName:setString(_msgData.string["2"])
	local upgradeExp = DictUnionLevelPriv[tostring(_msgData.int["4"])].exp
	ui_allianceExp:setString(_msgData.int["3"].." / "..upgradeExp)
	ui_allianceExpBar:setPercent(utils.getPercent(_msgData.int["3"], upgradeExp))

	local buildLoadingPanel = UIAllianceBuild.Widget:getChildByName("image_base_loading")
    local ui_buildBoxs = {}
	ui_buildBoxs[1] = buildLoadingPanel:getChildByName("image_box_first")
	ui_buildBoxs[2] = buildLoadingPanel:getChildByName("image_box_second")
	ui_buildBoxs[3] = buildLoadingPanel:getChildByName("image_box_third")
	local ui_loadingBar = buildLoadingPanel:getChildByName("bar_loading")
	local ui_loadingLabel = buildLoadingPanel:getChildByName("text_loading_now")
	local ui_loadingCount = buildLoadingPanel:getChildByName("text_loading_member")
	ui_loadingBar:setPercent(utils.getPercent(_msgData.int["12"], MAX_PLAN_VALUE))
	ui_loadingLabel:setString(Lang.ui_alliance_build1 .. _msgData.int["12"])
	ui_loadingCount:setString(string.format(Lang.ui_alliance_build2, _msgData.int["13"], _msgData.int["7"]))

    local buildBoxImgs = {
        {"ui/fb_bx.png", "ui/fb_bx_empty.png", "ui/fb_bx_full.png"},
        {"ui/fb_bx01.png", "ui/fb_bx01_empty.png", "ui/fb_bx01_full.png"},
        {"ui/fb_bx02.png", "ui/fb_bx02_empty.png", "ui/fb_bx02_full.png"}
    }

    for key, obj in pairs(ui_buildBoxs) do
        local dictUnionBoxData = DictUnionBox[tostring(key)]
        local _isStandard = false
        if _msgData.int["12"] >= dictUnionBoxData.plan then
            _isStandard = true
        end
        local _isGetBox = false
        if net.InstUnionBox then
            local _ids = utils.stringSplit(net.InstUnionBox.string["3"], ";")
            for _idKey, _idObj in pairs(_ids) do
                if dictUnionBoxData.id == tonumber(_idObj) then
                    _isGetBox = true
                    break
                end
            end
        end
        local _index = 1
        if _isStandard then
            _index = 3
            if _isGetBox then
                _index = 2
            end
        end
        obj:loadTexture(buildBoxImgs[key][_index])
        local function onButtonEvent(sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
                local _enabled = false
                local _btnTitleText = Lang.ui_alliance_build3
                if _isStandard and not _isGetBox then
                    _enabled = true
                elseif _isGetBox then
                    _btnTitleText = Lang.ui_alliance_build4
                end
                local function boxCallback()
                    _curBoxThings = dictUnionBoxData.things
                    UIManager.showLoading()
	                netSendPackage({header = StaticMsgRule.unionBox, msgdata = {
                        int={instUnionMemberId=net.InstUnionMember.int["1"], instUnionBoxId=net.InstUnionBox and net.InstUnionBox.int["1"] or 0, unionBoxId=dictUnionBoxData.id}
                    }}, netCallbackFunc)
                end
                UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {btnTitleText=_btnTitleText, enabled=_enabled, things=dictUnionBoxData.things, callbackFunc=boxCallback})
	   			UIManager.pushScene("ui_award_get")
--                if _isStandard then
--                    if _isGetBox then
--                        UIManager.showToast("今日已领！")
--                    else
--                        _curBoxThings = dictUnionBoxData.things
--                        UIManager.showLoading()
--	                    netSendPackage({header = StaticMsgRule.unionBox, msgdata = {
--                            int={instUnionMemberId=net.InstUnionMember.int["1"], instUnionBoxId=net.InstUnionBox and net.InstUnionBox.int["1"] or 0, unionBoxId=dictUnionBoxData.id}
--                        }}, netCallbackFunc)
--                    end
--                else
--                    UIManager.showToast("进度未达标！")
--                end
		    end
        end
        obj:addTouchEventListener(onButtonEvent)
    end
end

local function initBuildInfo()
	local ui_buildItem = {}
	ui_buildItem[1] = UIAllianceBuild.Widget:getChildByName("image_people")
	ui_buildItem[2] = UIAllianceBuild.Widget:getChildByName("image_land")
	ui_buildItem[3] = UIAllianceBuild.Widget:getChildByName("image_sky")
	for key, buildItem in pairs(ui_buildItem) do
		local unionBuildData = DictUnionBuild[tostring(key)]
		buildItem:getChildByName("text_loading"):setString(Lang.ui_alliance_build5 .. unionBuildData.plan)
		buildItem:getChildByName("text_exp"):setString(Lang.ui_alliance_build6 .. unionBuildData.exp)
		buildItem:getChildByName("text_congratulate"):setString(Lang.ui_alliance_build7 .. unionBuildData.contribution)
		local ui_goldImg = buildItem:getChildByName("image_gold")
		local ui_price = ui_goldImg:getChildByName("text_gold")
		local ui_builedLabel = buildItem:getChildByName("text_builed")
		if unionBuildData.buyType == 1 then
			ui_goldImg:loadTexture("ui/yin.png")
		else
			ui_goldImg:loadTexture("ui/jin.png")
		end
		ui_price:setString(tostring(unionBuildData.buyValue))
		if unionBuildData.id == net.InstUnionMember.int["7"] then
			ui_goldImg:setVisible(false)
			buildItem:setTouchEnabled(false)
			ui_builedLabel:setVisible(true)
		else
			ui_builedLabel:setVisible(false)
			ui_goldImg:setVisible(true)
			buildItem:setTouchEnabled(true)
		end
		buildItem:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if net.InstUnionMember.int["7"] == nil or net.InstUnionMember.int["7"] == 0 then
					if unionBuildData.buyType == 1 and tonumber(net.InstPlayer.string["6"]) < unionBuildData.buyValue then
						UIManager.showToast(Lang.ui_alliance_build8)
					elseif unionBuildData.buyType == 2 and net.InstPlayer.int["5"] < unionBuildData.buyValue then
						UIManager.showToast(Lang.ui_alliance_build9)
					else
						UIManager.showLoading()
						netSendPackage({header = StaticMsgRule.unionBuild, 
							msgdata = {int={instUnionMemberId=net.InstUnionMember.int["1"],unionBuildId=unionBuildData.id}}}, netCallbackFunc)
					end
				else
					UIManager.showToast(Lang.ui_alliance_build10)
				end
			end
		end)
	end
end

netCallbackFunc = function(msgData)
	local code = tonumber(msgData.header)
	if code == StaticMsgRule.unionDetail then
		local unionDetail = msgData.msgdata.message.unionDetail
		initAllianceInfo(unionDetail)
		UIManager.showLoading()
		netSendPackage({header = StaticMsgRule.unionDynamic, 
		msgdata = {int={instUnionMemberId=net.InstUnionMember.int["1"],type=1}}}, netCallbackFunc)
	elseif code == StaticMsgRule.unionBuild then
		UIManager.showToast(Lang.ui_alliance_build11)
		UIAllianceBuild.setup()
	elseif code == StaticMsgRule.unionDynamic then
		local _msgContent = Lang.ui_alliance_build12
		if msgData.msgdata.message.unionDynamic and msgData.msgdata.message.unionDynamic.message then
			for key, obj in pairs(msgData.msgdata.message.unionDynamic.message) do
				local unionBuildData = DictUnionBuild[tostring(obj.int["4"])]
				_msgContent = Lang.ui_alliance_build13..obj.string["3"].."</color><color=139,69,19>"..unionBuildData.description..Lang.ui_alliance_build14..unionBuildData.plan..Lang.ui_alliance_build15..unionBuildData.exp..Lang.ui_alliance_build16
				break
			end
		end

		local contentData = utils.richTextFormat(_msgContent)
		local msgPanel = UIAllianceBuild.Widget:getChildByName("image_mm"):getChildByName("image_notice")
		if msgPanel:getChildByName("ui_richText") then
			msgPanel:getChildByName("ui_richText"):removeFromParent()
		end
		local _fontSize, _fontName = 22, dp.FONT
		local ui_richText = ccui.RichText:create()
		ui_richText:setName("ui_richText")
		for key, obj in pairs(contentData) do
			ui_richText:pushBackElement(ccui.RichElementText:create(key, obj.color, 255, obj.text, _fontName, _fontSize))
		end
		ui_richText:setPosition(cc.p(msgPanel:getContentSize().width / 2 + 13, msgPanel:getContentSize().height / 2 - 9))
		if #contentData > 1 then
			ui_richText:ignoreContentAdaptWithSize(false)
		end
		ui_richText:setContentSize(cc.size(233, 90))
		msgPanel:addChild(ui_richText)
		contentData = nil
    elseif code == StaticMsgRule.unionBox then
--        UIManager.showToast("宝箱领取成功！")
        if _curBoxThings then
            utils.showGetThings(_curBoxThings)
            _curBoxThings = nil
        end
        UIAllianceBuild.setup()
	end
end

function UIAllianceBuild.init()
	UIAllianceBuild.Widget:setBackGroundImage("image/backgroundWar/star.png")
	local btn_back = UIAllianceBuild.Widget:getChildByName("btn_back")
	local buildLoadingPanel = UIAllianceBuild.Widget:getChildByName("image_base_loading")
	local ui_loadingBar = buildLoadingPanel:getChildByName("bar_loading")
    local ui_buildBoxs = {}
	ui_buildBoxs[1] = buildLoadingPanel:getChildByName("image_box_first")
	ui_buildBoxs[2] = buildLoadingPanel:getChildByName("image_box_second")
	ui_buildBoxs[3] = buildLoadingPanel:getChildByName("image_box_third")
    local ui_buildPlan = {}
    ui_buildPlan[1] = buildLoadingPanel:getChildByName("image_first")
    ui_buildPlan[2] = buildLoadingPanel:getChildByName("image_second")
    ui_buildPlan[3] = buildLoadingPanel:getChildByName("image_third")
	local loadingBarLeftPosX = ui_loadingBar:getPositionX() - ui_loadingBar:getContentSize().width / 2
    for key, obj in pairs(ui_buildBoxs) do
        local _plan = DictUnionBox[tostring(key)].plan
        obj:setPositionX(loadingBarLeftPosX + (_plan / MAX_PLAN_VALUE) * ui_loadingBar:getContentSize().width)
        ui_buildPlan[key]:setPositionX(loadingBarLeftPosX + (_plan / MAX_PLAN_VALUE) * ui_loadingBar:getContentSize().width)
        if key == 1 then
            ui_buildPlan[key]:getChildByName("text_first"):setString(tostring(_plan))
        elseif key == 2 then
	        ui_buildPlan[key]:getChildByName("text_second"):setString(tostring(_plan))
        elseif key == 3 then
	        ui_buildPlan[key]:getChildByName("text_third"):setString(tostring(_plan))
        end
    end

	btn_back:setPressedActionEnabled(true)

	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_back then
				UIManager.hideWidget("ui_team_info")
				UIManager.showWidget("ui_alliance")
			end
		end
	end

	btn_back:addTouchEventListener(onButtonEvent)
end

function UIAllianceBuild.setup()
	UIManager.showLoading()
	netSendPackage({header = StaticMsgRule.unionDetail, 
		msgdata = {int={instUnionMemberId=net.InstUnionMember.int["1"]}}}, netCallbackFunc)
	initBuildInfo()
end

function UIAllianceBuild.free()
    _curBoxThings = nil
end
