require"Lang"
UILianDan = {}

local ui_fightValue = nil
local ui_gold = nil
local ui_money = nil
local ui_pillRecipeName = nil
local ui_pillRecipeIcon = nil
--local ui_pillRecipeCount = nil
local ui_pillCount = nil
local ui_pillEffect = nil
local ui_selectText = nil
local ui_arrow = nil
local ui_pillThingFrame1 = nil
local ui_pillThingFrame2 = nil
local ui_pillThingFrame3 = nil

local _pillName = nil
local _pillCountText = Lang.ui_liandan1
local _instPillRecipeId = nil --丹药丹方实例ID
local _refineType = nil --1-炼制  2-一键炼制

local function showToast(msg)
	local toast_bg = cc.Scale9Sprite:create("ui/dialog_bg.png")
	toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
  toast_bg:setPreferredSize(cc.size(500, 120))
	toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
	local bgSize = toast_bg:getPreferredSize()
	local text = ccui.Text:create()
	text:setFontName(dp.FONT)
	text:setString(msg)
	text:setFontSize(20)
	text:setTextColor(cc.c4b(255, 255, 255, 255))
  text:setTextAreaSize(bgSize)
	text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
  text:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	text:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2))
	toast_bg:addChild(text)
	UIManager.gameLayer:addChild(toast_bg, 100)
	local function hideToast()
		if toast_bg then
			UIManager.gameLayer:removeChild(toast_bg, true)
		end
	end
	toast_bg:setScale(0.1)
	toast_bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1), cc.DelayTime:create(1.5), cc.CallFunc:create(hideToast)))
end

---@flag : 0表示坐下,1表示右上
local function myPathFun(controlX, controlY, w, flag)
	local time = 0.2
	if flag == 0 then
		local bezier1 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(w, 0))
		local bezier2 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(-w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		return path
	elseif flag == 1 then
	 	local bezier1 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(-w, 0))
		local bezier2 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		return path
	end
end

local function addPillEffect(pillThingFrame)
	local effect1 = cc.ParticleSystemQuad:create("particle/ui_anim9_effect_1.plist")
	effect1:setName("particle_effect1")
	effect1:setPosition(cc.p(10, 0))
	pillThingFrame:addChild(effect1)
	local effect2 = cc.ParticleSystemQuad:create("particle/ui_anim9_effect_2.plist")
	effect2:setName("particle_effect2")
	effect2:setPosition(cc.p(pillThingFrame:getContentSize().width - 10, pillThingFrame:getContentSize().height))
	pillThingFrame:addChild(effect2)
	effect1:runAction(myPathFun(10, pillThingFrame:getContentSize().height, pillThingFrame:getContentSize().width - 10 * 2, 0))
	effect2:runAction(myPathFun(10, pillThingFrame:getContentSize().height, pillThingFrame:getContentSize().width - 10 * 2, 1))
end

local function netCallbackFunc(data)
	if _refineType == 1 then
		local animation = ActionManager.getUIAnimation(9, function()
--			UIManager.showToast("炼制成功！")
			UILianDan.setInstPillRecipeId(_instPillRecipeId)
			local function resetPillFrame(pillThingFrame)
				local childs = pillThingFrame:getChildren()
				for key, obj in pairs(childs) do
					if obj:getName() == "particle_effect1" or obj:getName() == "particle_effect2" then
						obj:removeFromParent()
					end
				end
				pillThingFrame:setVisible(true)
			end
			resetPillFrame(ui_pillThingFrame1)
			resetPillFrame(ui_pillThingFrame2)
			resetPillFrame(ui_pillThingFrame3)
		end)
		local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "event_1" then
				addPillEffect(ui_pillThingFrame1)
			elseif evt == "event_2" then
				addPillEffect(ui_pillThingFrame3)
			elseif evt == "event_3" then
				addPillEffect(ui_pillThingFrame2)
			elseif evt == "event_4" then
				ui_pillThingFrame1:setVisible(false)
				ui_pillThingFrame2:setVisible(false)
				ui_pillThingFrame3:setVisible(false)
			elseif evt == "event_5" then
				if _pillName then
					showToast(Lang.ui_liandan2.._pillName.."！")
				end
			end
		end
		animation:getAnimation():setSpeedScale(1.3)
		animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
		animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 - 6))
		UIManager.uiLayer:addChild(animation, 1000)
	else
		UIManager.showToast(Lang.ui_liandan3)
		UILianDan.setInstPillRecipeId(_instPillRecipeId)
	end
end

--炼制 (1-炼制  2-一键炼制)
local function refine(_type)
	if _instPillRecipeId == nil then
		UIManager.showToast(Lang.ui_liandan4)
		return
	end
	local _count = nil
	local ui_pillThingCount1 = ccui.Helper:seekNodeByName(ui_pillThingFrame1, "text_good_number1")
	_count = utils.stringSplit(ui_pillThingCount1:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_liandan5)
		return
	end
	local ui_pillThingCount2 = ccui.Helper:seekNodeByName(ui_pillThingFrame2, "text_good_number2")
	_count = utils.stringSplit(ui_pillThingCount2:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_liandan6)
		return
	end
	local ui_pillThingCount3 = ccui.Helper:seekNodeByName(ui_pillThingFrame3, "text_good_number3")
	_count = utils.stringSplit(ui_pillThingCount3:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_liandan7)
		return
	end
	
    local sendData = nil
    if UIGuidePeople.levelStep == "20_5" then
        sendData = {
		    header = StaticMsgRule.addPills,
		    msgdata = {
			    int = {
				    instPlayerPillRecipeId = _instPillRecipeId,
				    type = _type  --1-炼制  2-一键炼制
			    },
                string = {
                    step = "20_6"
                }
		    }
	    }
    else
        sendData = {
		    header = StaticMsgRule.addPills,
		    msgdata = {
			    int = {
				    instPlayerPillRecipeId = _instPillRecipeId,
				    type = _type  --1-炼制  2-一键炼制
			    }
		    }
	    }
    end
	UIManager.showLoading()
	netSendPackage(sendData, netCallbackFunc)
	_refineType = _type
end

function UILianDan.init()
	ui_fightValue = ccui.Helper:seekNodeByName(UILianDan.Widget, "label_fight")
	ui_gold = ccui.Helper:seekNodeByName(UILianDan.Widget, "text_gold_number")
	ui_money = ccui.Helper:seekNodeByName(UILianDan.Widget, "text_silver_number")

	local btn_liandan = ccui.Helper:seekNodeByName(UILianDan.Widget, "btn_liandan") --炼丹标签
	local btn_danfang = ccui.Helper:seekNodeByName(UILianDan.Widget, "btn_danfang") --丹方标签
	local btn_danyao = ccui.Helper:seekNodeByName(UILianDan.Widget, "btn_danyao") --丹药标签
	local btn_yaocai = ccui.Helper:seekNodeByName(UILianDan.Widget, "btn_yaocai") --药材标签
	local function labelTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_liandan then
--				UIManager.showWidget("ui_liandan")
			elseif sender == btn_danfang then
				UIManager.showWidget("ui_danfang")
			elseif sender == btn_danyao then
				UIDanYao.setShowType(UIDanYao.ShowType.ShowDanYao)
				UIManager.showWidget("ui_danyao")
			elseif sender == btn_yaocai then
				UIDanYao.setShowType(UIDanYao.ShowType.ShowYaoCai)
				UIManager.showWidget("ui_danyao")
			end
		end
	end
	btn_liandan:addTouchEventListener(labelTouchEvent)
	btn_danfang:addTouchEventListener(labelTouchEvent)
	btn_danyao:addTouchEventListener(labelTouchEvent)
	btn_yaocai:addTouchEventListener(labelTouchEvent)
	
	local ui_image_base_liandan = ccui.Helper:seekNodeByName(UILianDan.Widget, "image_base_liandan")
	ui_pillRecipeName = ccui.Helper:seekNodeByName(ui_image_base_liandan, "text_hint_name")
	ui_pillRecipeIcon = ccui.Helper:seekNodeByName(ui_image_base_liandan, "image_danfang")
	ui_pillRecipeIcon:setTouchEnabled(true)
--	ui_pillRecipeCount = ccui.Helper:seekNodeByName(ui_pillRecipeIcon, "text_number")
	ui_pillCount = ccui.Helper:seekNodeByName(ui_image_base_liandan, "text_property_medicine_0")
	ui_pillEffect = ccui.Helper:seekNodeByName(ui_image_base_liandan, "text_property_medicine")
	ui_selectText = ccui.Helper:seekNodeByName(ui_image_base_liandan, "text_hint")
	ui_arrow = ccui.Helper:seekNodeByName(ui_image_base_liandan, "image_arrow")
	local arrowAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(ui_arrow:getPositionX(), ui_arrow:getPositionY() + 30)), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		ui_arrow:setPositionY(ui_arrow:getPositionY() - 30)
		ui_arrow:setOpacity(255)
	end)))
	ui_arrow:runAction(arrowAction)
	
	local ui_image_base_tab = ccui.Helper:seekNodeByName(UILianDan.Widget, "image_base_liandan_info")
	ui_pillThingFrame1 = ccui.Helper:seekNodeByName(ui_image_base_tab, "image_frame_need_good1")
	ui_pillThingFrame2 = ccui.Helper:seekNodeByName(ui_image_base_tab, "image_frame_need_good2")
	ui_pillThingFrame3 = ccui.Helper:seekNodeByName(ui_image_base_tab, "image_frame_need_good3")
	local btn_alchemy_onekey = ccui.Helper:seekNodeByName(ui_image_base_tab, "btn_alchemy_onekey")
	local btn_alchemy = ccui.Helper:seekNodeByName(ui_image_base_tab, "btn_alchemy")
	btn_alchemy_onekey:setPressedActionEnabled(true)
	btn_alchemy:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_alchemy_onekey then
				refine(2)
			elseif sender == btn_alchemy then
				refine(1)
			elseif sender == ui_pillRecipeIcon then
				UIManager.showWidget("ui_danfang")
			end
		end
	end
	btn_alchemy_onekey:addTouchEventListener(btnTouchEvent)
	btn_alchemy:addTouchEventListener(btnTouchEvent)
	ui_pillRecipeIcon:addTouchEventListener(btnTouchEvent)
end

function UILianDan.setup()
	ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(tostring(net.InstPlayer.string["6"]))
	
	UILianDan.setInstPillRecipeId(nil)
end

function UILianDan.setInstPillRecipeId(instPillRecipeId)
	_instPillRecipeId = instPillRecipeId
	
	local ui_pillThingIcon1 = ui_pillThingFrame1:getChildByName("image_need_good1")
	local ui_pillThingCount1 = ccui.Helper:seekNodeByName(ui_pillThingFrame1, "text_good_number1")
	local ui_pillThingIcon2 = ui_pillThingFrame2:getChildByName("image_need_good2")
	local ui_pillThingCount2 = ccui.Helper:seekNodeByName(ui_pillThingFrame2, "text_good_number2")
	local ui_pillThingIcon3 = ui_pillThingFrame3:getChildByName("image_need_good3")
	local ui_pillThingCount3 = ccui.Helper:seekNodeByName(ui_pillThingFrame3, "text_good_number3")
	
	if _instPillRecipeId and net.InstPlayerPillRecipe[tostring(_instPillRecipeId)] then
		local instPillRecipeData = net.InstPlayerPillRecipe[tostring(_instPillRecipeId)]
		local pillRecipeId = instPillRecipeData.int["3"] --丹药丹方字典ID
		local pillRecipeCount = instPillRecipeData.int["4"] --丹药丹方数量
		local dictPillRecipeData = DictPillRecipe[tostring(pillRecipeId)] --丹药丹方字典数据
		_pillName = DictPill[tostring(dictPillRecipeData.pillId)].name
		ui_pillRecipeName:setString(dictPillRecipeData.name)
		ui_pillRecipeIcon:loadTexture("image/" .. DictUI[tostring(dictPillRecipeData.smallUiId)].fileName)
--		ui_pillRecipeCount:setString(tostring(pillRecipeCount))
		local dictPillData = DictPill[tostring(dictPillRecipeData.pillId)]
		ui_pillCount:setString(string.format(_pillCountText, utils.getPillCount(dictPillRecipeData.pillId)))
		local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
		if dictTableType.id == StaticTableType.DictFightProp then
			local dictFightProp = DictFightProp[tostring(dictPillData.tableFieldId)]
			ui_pillEffect:setString(Lang.ui_liandan8 .. dictFightProp.name .. "+" .. dictPillData.value)
		elseif dictTableType.id == StaticTableType.DictCardBaseProp then
			local dictCardBaseProp = DictCardBaseProp[tostring(dictPillData.tableFieldId)]
			ui_pillEffect:setString(Lang.ui_liandan9 .. dictCardBaseProp.name .. "+" .. dictPillData.value)
		end
		ui_selectText:setVisible(false)
		ui_arrow:setVisible(false)
		
		local thingOne = utils.stringSplit(dictPillRecipeData.thingOne, "_")
		local dictPillThingData1 = DictPillThing[tostring(thingOne[1])]
		ui_pillThingIcon1:loadTexture("image/" .. DictUI[tostring(dictPillThingData1.smallUiId)].fileName)
		ui_pillThingCount1:setString(utils.getPillThingCount(dictPillThingData1.id) .. "/" .. thingOne[2])
		
		local thingTwo = utils.stringSplit(dictPillRecipeData.thingTwo, "_")
		local dictPillThingData2 = DictPillThing[tostring(thingTwo[1])]
		ui_pillThingIcon2:loadTexture("image/" .. DictUI[tostring(dictPillThingData2.smallUiId)].fileName)
		ui_pillThingCount2:setString(utils.getPillThingCount(dictPillThingData2.id) .. "/" .. thingTwo[2])
		
		local thingThree = utils.stringSplit(dictPillRecipeData.thingThree, "_")
		local dictPillThingData3 = DictPillThing[tostring(thingThree[1])]
		ui_pillThingIcon3:loadTexture("image/" .. DictUI[tostring(dictPillThingData3.smallUiId)].fileName)
		ui_pillThingCount3:setString(utils.getPillThingCount(dictPillThingData3.id) .. "/" .. thingThree[2])
		
		ui_pillThingFrame1:setTouchEnabled(true)
		ui_pillThingFrame2:setTouchEnabled(true)
		ui_pillThingFrame3:setTouchEnabled(true)
		local function frameTouchEvent(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if sender == ui_pillThingFrame1 then
					utils.storyDropOutDialog(dictPillThingData1)
				elseif sender == ui_pillThingFrame2 then
					utils.storyDropOutDialog(dictPillThingData2)
				elseif sender == ui_pillThingFrame3 then
					utils.storyDropOutDialog(dictPillThingData3)
				end
			end
		end
		ui_pillThingFrame1:addTouchEventListener(frameTouchEvent)
		ui_pillThingFrame2:addTouchEventListener(frameTouchEvent)
		ui_pillThingFrame3:addTouchEventListener(frameTouchEvent)
	else
		_instPillRecipeId = nil
		ui_pillRecipeName:setString(Lang.ui_liandan10)
		ui_pillRecipeIcon:loadTexture("ui/frame_tianjia.png")
--		ui_pillRecipeCount:setString(tostring(0))
		ui_pillCount:setString("")
		ui_pillEffect:setString("")
		ui_selectText:setVisible(true)
		ui_arrow:setVisible(true)
		ui_pillThingFrame1:setTouchEnabled(false)
		ui_pillThingFrame2:setTouchEnabled(false)
		ui_pillThingFrame3:setTouchEnabled(false)
		ui_pillThingIcon1:loadTexture("ui/frame_tianjia.png")
		ui_pillThingIcon2:loadTexture("ui/frame_tianjia.png")
		ui_pillThingIcon3:loadTexture("ui/frame_tianjia.png")
		ui_pillThingCount1:setString("0/0")
		ui_pillThingCount2:setString("0/0")
		ui_pillThingCount3:setString("0/0")
	end
end
