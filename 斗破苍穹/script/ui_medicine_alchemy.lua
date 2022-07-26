require"Lang"
UIMedicineAlchemy = {}

local btn_alchemy = nil
local ui_pillBg = nil
local ui_pillIcon = nil
local ui_pillName = nil
local ui_pillCount = nil
local ui_pillEffect = nil
local ui_pillRecipeFrame = nil
local ui_pillThingFrame1 = nil
local ui_pillThingFrame2 = nil
local ui_pillThingFrame3 = nil
local ui_heroLv = nil

local _instConstellId = nil --命宫实例ID
local _dictPillData = nil --丹药字典数据
local _position = nil --位置
local _curCardLv = 0

local function netCallbackFunc(data)
	local code = tonumber(data.header)
	if code == StaticMsgRule.addPill then
		UIMedicineAlchemy.setup()
	--	UIManager.showToast("恭喜你，炼制成功！")

        utils.playArmature(  41 , "ui_anim41_1" , UIMedicineAlchemy.Widget , 0 , 120 )

		UIMedicine.setup()
	else
        UIMedicine.isOpenNew = true
		UIMedicine.setup()
		UIManager.popScene()
		UILineup.setup()
		UICardInfo.setup()
	end
end

--炼制
local function refine()
	local _count = nil
	local ui_pillRecipeCount = ccui.Helper:seekNodeByName(ui_pillRecipeFrame, "text_number_prescription")
	_count = utils.stringSplit(ui_pillRecipeCount:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_medicine_alchemy1)
		return
	end
	local ui_pillThingCount1 = ccui.Helper:seekNodeByName(ui_pillThingFrame1, "text_number_crudedrugs1")
	_count = utils.stringSplit(ui_pillThingCount1:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_medicine_alchemy2)
		return
	end
	local ui_pillThingCount2 = ccui.Helper:seekNodeByName(ui_pillThingFrame2, "text_number_crudedrugs2")
	_count = utils.stringSplit(ui_pillThingCount2:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_medicine_alchemy3)
		return
	end
	local ui_pillThingCount3 = ccui.Helper:seekNodeByName(ui_pillThingFrame3, "text_number_crudedrugs3")
	_count = utils.stringSplit(ui_pillThingCount3:getString(), "/")
	if tonumber(_count[1]) < tonumber(_count[2]) then
		UIManager.showToast(Lang.ui_medicine_alchemy4)
		return
	end
	
    local sendData = nil
    if UIGuidePeople.levelStep == "18_5" then
        sendData = {
		    header = StaticMsgRule.addPill,
		    msgdata = {
			    int = {
				    instPlayerConstellId = _instConstellId,
				    position = _position
			    },
                string = {
                    step = "18_6"
                }
		    }
	    }
    else
        sendData = {
		    header = StaticMsgRule.addPill,
		    msgdata = {
			    int = {
				    instPlayerConstellId = _instConstellId,
				    position = _position
			    }
		    }
	    }
    end
	UIManager.showLoading()
	netSendPackage(sendData, netCallbackFunc)
end

function UIMedicineAlchemy.init()
	ui_pillBg = ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "image_basecolour")
	ui_pillIcon = ui_pillBg:getChildByName("image_medicine")
	ui_pillName = ccui.Helper:seekNodeByName(ui_pillBg, "text_name")
	ui_pillCount = ccui.Helper:seekNodeByName(ui_pillBg, "text_number")
	ui_pillEffect = ccui.Helper:seekNodeByName(ui_pillBg, "text_medicine_property")
	local ui_image_base_demand = ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "image_base_demand")
	ui_pillRecipeFrame = ccui.Helper:seekNodeByName(ui_image_base_demand, "image_frame_prescription")
	ui_pillThingFrame1 = ccui.Helper:seekNodeByName(ui_image_base_demand, "image_frame_crudedrugs1")
	ui_pillThingFrame2 = ccui.Helper:seekNodeByName(ui_image_base_demand, "image_frame_crudedrugs2")
	ui_pillThingFrame3 = ccui.Helper:seekNodeByName(ui_image_base_demand, "image_frame_crudedrugs3")
	ui_heroLv = ccui.Helper:seekNodeByName(ui_image_base_demand, "label_number_lv")

	local btn_close = ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "btn_close")
	btn_alchemy = ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "btn_alchemy")
	local btn_use = ccui.Helper:seekNodeByName(UIMedicineAlchemy.Widget, "btn_use")
	btn_close:setPressedActionEnabled(true)
	btn_alchemy:setPressedActionEnabled(true)
	btn_use:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close then
				UIManager.popScene()
			elseif sender == btn_alchemy then
				refine()
			elseif sender == btn_use then
				if utils.getPillCount(_dictPillData.id) <= 0 then
					UIManager.showToast(Lang.ui_medicine_alchemy5)
					return
				end
			
				if _curCardLv >= _dictPillData.cardlevel then
					local sendData = {
						    header = StaticMsgRule.usePill,
						    msgdata = {
							    int = {
								    instPlayerConstellId = _instConstellId,
								    position = _position
							    }
						    }
					    }
--                    local sendData = nil
--                    if UIGuidePeople.levelStep == "20_6" then
--                        sendData = {
--						    header = StaticMsgRule.usePill,
--						    msgdata = {
--							    int = {
--								    instPlayerConstellId = _instConstellId,
--								    position = _position
--							    },
--                                string = {
--                                    step = "20_7"
--                                }
--						    }
--					    }
--                    else
--                        sendData = {
--						    header = StaticMsgRule.usePill,
--						    msgdata = {
--							    int = {
--								    instPlayerConstellId = _instConstellId,
--								    position = _position
--							    }
--						    }
--					    }
--                    end
					UIManager.showLoading()
					netSendPackage(sendData, netCallbackFunc)
				else
					UIManager.showToast(Lang.ui_medicine_alchemy6)
				end
			end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_alchemy:addTouchEventListener(btnTouchEvent)
	btn_use:addTouchEventListener(btnTouchEvent)
end

function UIMedicineAlchemy.setup()
	UIGuidePeople.isGuide(nil,UIMedicineAlchemy)
	if _dictPillData then
		ui_pillName:setString(_dictPillData.name)
		ui_pillIcon:loadTexture("image/" .. DictUI[tostring(_dictPillData.bigUiId)].fileName)
		ui_pillCount:setString(tostring(utils.getPillCount(_dictPillData.id)))
		
		local dictTableType = DictTableType[tostring(_dictPillData.tableTypeId)]
		if dictTableType.id == StaticTableType.DictFightProp then
			local dictFightProp = DictFightProp[tostring(_dictPillData.tableFieldId)]
			ui_pillEffect:setString(Lang.ui_medicine_alchemy7 .. dictFightProp.name .. _dictPillData.value)
		end
		local dictPillRecipeData = DictPillRecipe[tostring(_dictPillData.prescriptId)] --药方字典数据
		local ui_pillRecipeIcon = ui_pillRecipeFrame:getChildByName("image_prescription")
		local ui_pillRecipeName = ui_pillRecipeFrame:getChildByName("text_prescription_name")
		local ui_pillRecipeCount = ccui.Helper:seekNodeByName(ui_pillRecipeFrame, "text_number_prescription")
		ui_pillRecipeName:setString(dictPillRecipeData.name)
		ui_pillRecipeIcon:loadTexture("image/" .. DictUI[tostring(dictPillRecipeData.smallUiId)].fileName)
		ui_pillRecipeCount:setString(utils.getPillRecipeCount(_dictPillData.prescriptId) .. "/1")
		
		local thingOne = utils.stringSplit(dictPillRecipeData.thingOne, "_")
		local ui_pillThingIcon1 = ui_pillThingFrame1:getChildByName("image_crudedrugs1")
		local ui_pillThingName1 = ui_pillThingFrame1:getChildByName("text_crudedrugs1_name")
		local ui_pillThingCount1 = ccui.Helper:seekNodeByName(ui_pillThingFrame1, "text_number_crudedrugs1")
		local dictPillThingData1 = DictPillThing[tostring(thingOne[1])]
		ui_pillThingName1:setString(dictPillThingData1.name)
		ui_pillThingIcon1:loadTexture("image/" .. DictUI[tostring(dictPillThingData1.smallUiId)].fileName)
		ui_pillThingCount1:setString(utils.getPillThingCount(dictPillThingData1.id) .. "/" .. thingOne[2])
		
		local thingTwo = utils.stringSplit(dictPillRecipeData.thingTwo, "_")
		local ui_pillThingIcon2 = ui_pillThingFrame2:getChildByName("image_crudedrugs2")
		local ui_pillThingName2 = ui_pillThingFrame2:getChildByName("text_crudedrugs2_name")
		local ui_pillThingCount2 = ccui.Helper:seekNodeByName(ui_pillThingFrame2, "text_number_crudedrugs2")
		local dictPillThingData2 = DictPillThing[tostring(thingTwo[1])]
		ui_pillThingName2:setString(dictPillThingData2.name)
		ui_pillThingIcon2:loadTexture("image/" .. DictUI[tostring(dictPillThingData2.smallUiId)].fileName)
		ui_pillThingCount2:setString(utils.getPillThingCount(dictPillThingData2.id) .. "/" .. thingTwo[2])
		
		local thingThree = utils.stringSplit(dictPillRecipeData.thingThree, "_")
		local ui_pillThingIcon3 = ui_pillThingFrame3:getChildByName("image_crudedrugs3")
		local ui_pillThingName3 = ui_pillThingFrame3:getChildByName("text_crudedrugs3_name")
		local ui_pillThingCount3 = ccui.Helper:seekNodeByName(ui_pillThingFrame3, "text_number_crudedrugs3")
		local dictPillThingData3 = DictPillThing[tostring(thingThree[1])]
		ui_pillThingName3:setString(dictPillThingData3.name)
		ui_pillThingIcon3:loadTexture("image/" .. DictUI[tostring(dictPillThingData3.smallUiId)].fileName)
		ui_pillThingCount3:setString(utils.getPillThingCount(dictPillThingData3.id) .. "/" .. thingThree[2])
		
		ui_pillRecipeFrame:setTouchEnabled(true)
		ui_pillThingFrame1:setTouchEnabled(true)
		ui_pillThingFrame2:setTouchEnabled(true)
		ui_pillThingFrame3:setTouchEnabled(true)
		local function frameTouchEvent(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if sender == ui_pillRecipeFrame then
					utils.storyDropOutDialog(dictPillRecipeData)
				elseif sender == ui_pillThingFrame1 then
					utils.storyDropOutDialog(dictPillThingData1)
				elseif sender == ui_pillThingFrame2 then
					utils.storyDropOutDialog(dictPillThingData2)
				elseif sender == ui_pillThingFrame3 then
					utils.storyDropOutDialog(dictPillThingData3)
				end
			end
		end
		-- ui_pillRecipeFrame:addTouchEventListener(frameTouchEvent)
		ui_pillThingFrame1:addTouchEventListener(frameTouchEvent)
		ui_pillThingFrame2:addTouchEventListener(frameTouchEvent)
		ui_pillThingFrame3:addTouchEventListener(frameTouchEvent)
		
		ui_heroLv:setString(tostring(_dictPillData.cardlevel))
	end
end

function UIMedicineAlchemy.setDictPillData(dictPillData)
	_dictPillData = dictPillData
end

function UIMedicineAlchemy.setPosition(position)
	_position = position
end

function UIMedicineAlchemy.setCurCardLv(cardLv)
	_curCardLv = cardLv
end

function UIMedicineAlchemy.setInstConstellId(instConstellId)
	_instConstellId = instConstellId
end
