require"Lang"
UICardChange = {}

local scrollView = nil
local sv_item = nil

UICardChange.OperateType = {
	Lineup = 1, --阵容
	Friend = 2, --小伙伴
    Friend2 = 3,--小伙伴培养上阵
    Lineup2 = 4,--小伙伴阵容
}

local _instPlayerFormationId = nil
local _position = nil
local _operateType = nil
local _param = nil

local function netCallbackFunc(data)
	local code = data.header
	if code == StaticMsgRule.cardInPartner then
        UIManager.flushWidget( UIFriend )
        UIManager.popScene()
		if type(_param) == "table" then
			UIManager.popScene()
		end
		UILineup.setup()
	else
		if _instPlayerFormationId then
			_instPlayerFormationId = nil
		end
		UILineup.setup()
		UIManager.popAllScene()
	end
end

local function setScrollViewItem(item, data)
	local dictCardId = data.int["3"] --卡牌字典ID
	local qualityId = data.int["4"] --卡牌品阶ID
	local cardLv = data.int["9"] --卡牌等级
	local dictCardData = DictCard[tostring(dictCardId)]
	local dictTitleDetailData = DictTitleDetail[tostring(data.int["6"])] --详细称号字典表
	local useTalentValue = data.int["11"] --卡牌当前潜力值
	local startLevelId = data.int["5"]
    local isAwake = data.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
	local ui_cardFrame = ccui.Helper:seekNodeByName(item, "image_frame_card")
	local ui_cardIcon = ui_cardFrame:getChildByName("image_card")
	local ui_cardLevel = ccui.Helper:seekNodeByName(item, "text_card_number")
	local ui_cardName = ccui.Helper:seekNodeByName(item, "text_name_card")
	local ui_cardTitle = ccui.Helper:seekNodeByName(item, "image_base_title")
	local ui_cardQuality = ccui.Helper:seekNodeByName(item, "label_lv")
	local btnChoose = ccui.Helper:seekNodeByName(item, "btn_upgrade")
	local ui_pz = item:getChildByName("image_zz"):getChildByName("label_zz")
	local starValue = dictTitleDetailData.value -- 星数
	local titleId= dictTitleDetailData.titleId
	local startLevel = DictStarLevel[tostring(startLevelId)].level
	ui_cardName:setString((isAwake == 1 and Lang.ui_card_change1 or "") .. dictCardData.name)
	ui_cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small))
	utils.changeNameColor(ui_cardName,qualityId)
	ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
	ui_cardLevel:setString(string.format(Lang.ui_card_change2,cardLv))
	utils.setChengHaoImage(ui_cardTitle,starValue,titleId)
	local dictQualityData = DictQuality[tostring(data.int["4"])]
	local dictStarLevelData = DictStarLevel[tostring(data.int["5"])]
	if startLevel == 0 then 
		ui_cardQuality:getParent():setVisible(false)
	else 	
		ui_cardQuality:getParent():setVisible(true)
	end
	ui_pz:setString(tostring(dictCardData.nickname)) -- 假的
	ui_cardQuality:setString(startLevel)  -- 几星
	btnChoose:setPressedActionEnabled(true)
	local function btnChooseEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if _operateType == UICardChange.OperateType.Lineup then
				if _instPlayerFormationId then
					local data = {
						header = StaticMsgRule.convertCard,
						msgdata = {
							int = {
								instPlayerFormationId = _instPlayerFormationId,
								instPlayerCardId = data.int["1"],
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(data, netCallbackFunc)
				else
					local dictData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
					local inTeamCard, benchCard = 0, 0
					for key, obj in pairs(net.InstPlayerFormation) do
						if obj.int["4"] == 1 then	--主力
							inTeamCard = inTeamCard + 1
						elseif obj.int["4"] == 2 then --替补
							benchCard = benchCard + 1
						end
					end
					local _type = nil --1:主力, 2:替补
					if inTeamCard < dictData.inTeamCard then
						_type = 1
					elseif benchCard < dictData.benchCard then
						_type = 2
					end
                    local cardId =data.int["1"]
					if _type then
                        local data = nil
                        if UIGuidePeople.guideStep == "2B9" then
                            data = {
							    header = StaticMsgRule.cardInTeam,
							    msgdata = {
								    int = {
									    instCardId = cardId,
									    type = _type
								    },
                                    string = {
                                        step = "2B10"
                                    }
							    }
						    }
                        elseif UIGuidePeople.guideStep == "5B8" then
                            data = {
							    header = StaticMsgRule.cardInTeam,
							    msgdata = {
								    int = {
									    instCardId = cardId,
									    type = _type
								    },
                                    string = {
                                        step = "5B9"
                                    }
							    }
						    }
                        elseif UIGuidePeople.levelStep == "7_6" then
                            data = {
							    header = StaticMsgRule.cardInTeam,
							    msgdata = {
								    int = {
									    instCardId = cardId,
									    type = _type
								    },
                                    string = {
                                        step = "7_7"
                                    }
							    }
						    }
                        else
                            data = {
							header = StaticMsgRule.cardInTeam,
							msgdata = {
								int = {
									instCardId = cardId,
									type = _type
								}
							}
						}
                        end
						UIManager.showLoading()
						netSendPackage(data, netCallbackFunc)
					else
						cclog("ERROR: -------------->>> 卡槽个数已满！！！")
					end
				end
			elseif _operateType == UICardChange.OperateType.Friend then
				if _position then
					local data = {
						header = StaticMsgRule.cardInPartner,
						msgdata = {
							int = {
								instCardId = data.int["1"],
								position = _position
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(data, netCallbackFunc)
				else
					
				end
            elseif _operateType == UICardChange.OperateType.Friend2 or _operateType == UICardChange.OperateType.Lineup2 then
                if _operateType == UICardChange.OperateType.Lineup2 then
                    _position = net.InstPlayerFormation[ tostring( _instPlayerFormationId ) ].int["10"]
                end
                if _position then
                    local function getFormationIdByInstId( instId )
                        for key ,value in pairs( net.InstPlayerFormation ) do
                            if value.int["3"] == instId then
                                return value.int[ "1" ]
                            end
                        end
                        return 0
                    end
                    local data = {
						header = StaticMsgRule.partnerPos,
						msgdata = {
							int = {
								instFormationId = getFormationIdByInstId( data.int["1"] ),
								pos = _position
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(data, netCallbackFunc)
                end 
			end
		end
	end
	btnChoose:addTouchEventListener(btnChooseEvent)
	if item:getTag() == 1 then 
		UIGuidePeople.isGuide(btnChoose,UICardChange)
	end
end

function UICardChange.init()
	local btn_close = ccui.Helper:seekNodeByName(UICardChange.Widget, "btn_close")
	btn_close:setPressedActionEnabled(true)
	local function closeEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			UIManager.popScene()
		end
	end
	btn_close:addTouchEventListener(closeEvent)
	
	scrollView = ccui.Helper:seekNodeByName(UICardChange.Widget, "view_card")
	sv_item = scrollView:getChildByName("image_base_card")
end

--先比较卡牌的品质 其次在比较等级
local function compareCard(value1,value2)
	if UIGuidePeople.levelStep then 
		if value2.int["3"] == 31  then 
	        return  true
	    end 
	end
    if value1.int["10"] == 1 and  value2.int["10"] == 0 then 
        return  false
    end 
    if value1.int["10"] == 0 and  value2.int["10"] == 1 then 
        return  true
    end 
    if value1.int["4"] > value2.int["4"] then 
        return false
    elseif value1.int["4"] < value2.int["4"] then 
        return true
    else
          if  value1.int["9"] >= value2.int["9"] then 
              return false
          else
              return true
          end
    end
end

function UICardChange.setup()
	scrollView:removeAllChildren()
	local cardThing={}
    if _operateType == UICardChange.OperateType.Friend2 or _operateType == UICardChange.OperateType.Lineup2 then
        local function isFriend( instId )
            if net.InstPlayerFormation then
                for key ,value in pairs( net.InstPlayerFormation ) do
                    if value.int["3"] == instId and value.int["4"] == 3 and value.int["10"] == 0 then--排除在培养界面上之外的小伙伴
                        return true
                    end
                end
            end
            return false
        end
        if net.InstPlayerCard then
		    for key, obj in pairs(net.InstPlayerCard) do
			    if isFriend(obj.int["1"]) then
				    table.insert(cardThing,obj)
			    end
		    end
		    utils.quickSort(cardThing,compareCard)
	    end
    else
	    if net.InstPlayerCard then
		    for key, obj in pairs(net.InstPlayerCard) do
			    local isTeam = obj.int["10"] --是否在队伍中 0-不在 1-在
			    if isTeam == 0 and not utils.isTeam(obj.int["3"]) then
				    table.insert(cardThing,obj)
			    end
		    end
		    utils.quickSort(cardThing,compareCard)
	    end
    end
	if next(cardThing) then
        utils.updateView(UICardChange,scrollView,sv_item,cardThing,setScrollViewItem)
    end
end
function UICardChange.free( ... )
	UIGuidePeople.isGuide(nil,UICardChange)
end
---UI之间传参
--@operateType : 操作类型（参考 UICardChange.OperateType）
--@param : 要传递的参数
function UICardChange.setUIParam(operateType, param)
	_operateType = operateType
	_param = param
	_instPlayerFormationId = nil
	_position = nil
	if _operateType == UICardChange.OperateType.Lineup or _operateType == UICardChange.OperateType.Lineup2 then
		_instPlayerFormationId = param
	elseif _operateType == UICardChange.OperateType.Friend then
		if type(param) == "table" then
			_position = param[1]
		else
			_position = param
		end
    elseif _operateType == UICardChange.OperateType.Friend2 then
        _position = param
	end
end
