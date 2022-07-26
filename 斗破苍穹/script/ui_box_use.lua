require"Lang"
UIBoxUse = {}

local _MAX_USE_NUMS = 100 --单次最大使用数量

local _thingData = nil
local _haveNums = 0

local function netCallbackFunc(data)
    local _boxData = utils.stringSplit(data.msgdata.string["1"], ";")
	local _openBoxData = {}
	for key, obj in pairs(_boxData) do
		local _thing = utils.stringSplit(obj, "_")
		_openBoxData[#_openBoxData + 1] = (tonumber(_thing[1]) == 1 and DictGenerBoxThing[_thing[2]] or DictSpecialBoxThing[_thing[2]])
	end
    UIManager.popScene()
	if _thingData and _thingData.int["3"] == StaticThing.groupBox then
        utils.showOpenBoxAnimationUI(_openBoxData)
        --[[
        local _boxAnim = ActionManager.getEffectAnimation(63, function(armature)
--                    armature:getAnimation():playWithIndex(1)
            armature:removeFromParent()
        end, 1)
        _boxAnim:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        _boxAnim:setLocalZOrder(999999)

        local _name = ccui.Text:create()
        _name:setFontName(dp.FONT)
	    _name:setString("AAABBBCCC")
	    _name:setFontSize(25)
	    _name:setTextColor(cc.c4b(255, 255, 255, 255))
        _boxAnim:getBone("guge1"):addDisplay(_name, 0)
		_boxAnim:getBone("guge2"):addDisplay(ccs.Skin:create("image/poster_clothes_big_xiangruisijia.png"), 0)

        UIManager.uiLayer:addChild(_boxAnim)
        --]]
    else
	    UIBoxGet.setData(_openBoxData)
	    UIManager.pushScene("ui_box_get")
    end
    UIManager.flushWidget(UIBag)
	UIManager.flushWidget(UITeamInfo)
end

function UIBoxUse.init()
    _MAX_USE_NUMS = 100
	if _thingData and _thingData.int["3"] == StaticThing.groupBox then
        _MAX_USE_NUMS = 10
    end
	local btn_close = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "btn_close")
	local btn_sure = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "btn_sure")
	local btn_undo = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "btn_undo")
	local image_base_sell = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "image_base_sell")
	local ui_selectNums = ccui.Helper:seekNodeByName(image_base_sell, "text_number")
	local btn_add = ccui.Helper:seekNodeByName(image_base_sell, "btn_add")
	local btn_add_ten = ccui.Helper:seekNodeByName(image_base_sell, "btn_add_ten")
	local btn_cut = ccui.Helper:seekNodeByName(image_base_sell, "btn_cut")
	local btn_cut_ten = ccui.Helper:seekNodeByName(image_base_sell, "btn_cut_ten")
	btn_close:setPressedActionEnabled(true)
	btn_sure:setPressedActionEnabled(true)
	btn_undo:setPressedActionEnabled(true)
	btn_add:setPressedActionEnabled(true)
	btn_add_ten:setPressedActionEnabled(true)
	btn_cut:setPressedActionEnabled(true)
	btn_cut_ten:setPressedActionEnabled(true)
	local function onBtnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_undo then
				UIManager.popScene()
			elseif sender == btn_add or sender == btn_add_ten then
				local selectNums = tonumber(ui_selectNums:getString())
				local unitNum = (sender == btn_add and 1 or 10)
				if unitNum == 10 then
					if selectNums + unitNum > _haveNums then
						unitNum = _haveNums - selectNums
					elseif selectNums + unitNum > _MAX_USE_NUMS then
						unitNum = _MAX_USE_NUMS - selectNums
					end
					if unitNum == 0 then
						unitNum = 10
					end
				end
				if selectNums + unitNum > _MAX_USE_NUMS then
					UIManager.showToast(string.format(Lang.ui_box_use1, _MAX_USE_NUMS))
				else
					if selectNums + unitNum > _haveNums then
						UIManager.showToast(Lang.ui_box_use2)
					else
						ui_selectNums:setString(selectNums + unitNum)
					end
				end
			elseif sender == btn_cut or sender == btn_cut_ten then
				local selectNums = tonumber(ui_selectNums:getString())
				local unitNum = (sender == btn_cut and 1 or 10)
				if unitNum == 10 then
					if selectNums - unitNum < 0 then
						unitNum = selectNums
					end
				end
				if selectNums - unitNum >= 0 then
					ui_selectNums:setString(selectNums - unitNum)
				end
			elseif sender == btn_sure then
				local selectNums = tonumber(ui_selectNums:getString())
				if selectNums > 0 then
					local fitNums, fitName = 0, ""
					local _dictThingId = _thingData.int["3"]
					if _dictThingId == StaticThing.goldBox then
						fitNums = utils.getThingCount(StaticThing.goldKey)
						fitName = DictThing[tostring(StaticThing.goldKey)].name
					elseif _dictThingId == StaticThing.silverBox then
						fitNums = utils.getThingCount(StaticThing.silverKey)
						fitName = DictThing[tostring(StaticThing.silverKey)].name
					elseif _dictThingId == StaticThing.copperBox then
						fitNums = utils.getThingCount(StaticThing.copperKey)
						fitName = DictThing[tostring(StaticThing.copperKey)].name
					elseif _dictThingId == StaticThing.goldKey then
						fitNums = utils.getThingCount(StaticThing.goldBox)
						if net.InstPlayerThing then
							for key, obj in pairs(net.InstPlayerThing) do
								if obj.int["3"] == tonumber(StaticThing.goldBox) then
									fitNums = fitNums + obj.int["4"]
									break
								end
							end
						end
						fitName = DictThing[tostring(StaticThing.goldBox)].name
					elseif _dictThingId == StaticThing.silverKey then
						fitNums = utils.getThingCount(StaticThing.silverBox)
						fitName = DictThing[tostring(StaticThing.silverBox)].name
					elseif _dictThingId == StaticThing.copperKey then
						fitNums = utils.getThingCount(StaticThing.copperBox)
						fitName = DictThing[tostring(StaticThing.copperBox)].name
					elseif StaticThing.lihezuixiazhi <= _dictThingId and _dictThingId <= StaticThing.lihezuidazhi then
						fitNums = utils.getThingCount(_dictThingId)
						fitName = DictThing[tostring(_dictThingId)].name
					end
					if fitNums >= selectNums then
                        local _thingId = _thingData.int["1"]                     
                        function frameCallBack()
                            local sendData = {
							    header = StaticMsgRule.openBox,
							    msgdata = {
								    int = {
									    instPlayerThingId = _thingId,
									    num = selectNums
								    }
							    }
						    }
						    UIManager.showLoading()
						    netSendPackage(sendData, netCallbackFunc)                                                                            
                         end
                        if _dictThingId == StaticThing.thing1013 then
                            
                            UIManager.popScene( false , function ()
                                utils.playArmature( 48 , "ui_anim48" , UIManager.gameLayer , 0 , 0 , frameCallBack , "open" )
                            end )   
                        else
                            frameCallBack()
                        end
                        
						
					else
						UIManager.showToast(string.format(Lang.ui_box_use3, fitName, selectNums))
					end
				else
					UIManager.showToast(Lang.ui_box_use4)
				end
			end
		end
	end
	btn_close:addTouchEventListener(onBtnEvent)
	btn_sure:addTouchEventListener(onBtnEvent)
	btn_undo:addTouchEventListener(onBtnEvent)
	btn_add:addTouchEventListener(onBtnEvent)
	btn_add_ten:addTouchEventListener(onBtnEvent)
	btn_cut:addTouchEventListener(onBtnEvent)
	btn_cut_ten:addTouchEventListener(onBtnEvent)

	ccui.Helper:seekNodeByName(UIBoxUse.Widget, "image_base_earnings_info"):getChildByName("text_hint"):setString(string.format(Lang.ui_box_use5, _MAX_USE_NUMS))
end

function UIBoxUse.setup()
	local image_base_sell = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "image_base_sell")
	ccui.Helper:seekNodeByName(image_base_sell, "text_number"):setString("1")
	if _thingData then
		_haveNums = _thingData.int["5"]
		if _thingData.int["3"] == StaticThing.goldBox then
          _haveNums = _haveNums + _thingData.int["4"]
        end
		local dictThingData = DictThing[tostring(_thingData.int["3"])]
		local image_base_hint = ccui.Helper:seekNodeByName(UIBoxUse.Widget, "image_base_hint")
		ccui.Helper:seekNodeByName(image_base_hint, "text_hint"):setString(string.format(Lang.ui_box_use6, dictThingData.name))
		ccui.Helper:seekNodeByName(UIBoxUse.Widget, "text_have_number"):setString(Lang.ui_box_use7.._haveNums)
	end
end

function UIBoxUse.free()
	_haveNums = 0
	_thingData = nil
end

function UIBoxUse.setData(data)
	_thingData = data
end
