require"Lang"
UIBuySlive = {}

UIBuySlive.isSoulFlag = false
local function getNumCallBack( data )
    showNoEnoughDialog( data.msgdata.int["canBuyNum"] )
end
local function netSendDataGetNum()
    local sendData = {
        header = StaticMsgRule.getFightSoulBuySilverTimes,
			msgdata = {
				int = {
					
				}
			}
    }
    netSendPackage( sendData , getNumCallBack )
end
---进入副本
local function onFight(flag)
  if UIFight.Widget and UIFight.Widget:getParent() then
    return
  end
  flag = (flag and flag or 2)
  ----判断卡牌背包------------
	local cardGrid = DictBagType[tostring(StaticBag_Type.card)].bagUpLimit
	if net.InstPlayerBagExpand then
		for key,obj in pairs(net.InstPlayerBagExpand) do
			if obj.int["3"] == StaticBag_Type.card  then
				cardGrid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
			end
		end
	end
	local cardNumber = utils.getDictTableNum(net.InstPlayerCard)
  ----判断装备背包------------
  local equipGrid = DictBagType[tostring(StaticBag_Type.equip)].bagUpLimit
  if net.InstPlayerBagExpand then 
      for key,obj in pairs(net.InstPlayerBagExpand) do
          if obj.int["3"] == StaticBag_Type.equip then 
              equipGrid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
          end
      end
  end
  local equipNumber = utils.getDictTableNum(net.InstPlayerEquip)
	if cardNumber >= cardGrid and not UIGuidePeople.guideFlag then
		fightPromptDialog(StaticBag_Type.card)
	elseif equipNumber >= equipGrid and not UIGuidePeople.guideFlag then
    fightPromptDialog(StaticBag_Type.equip)
  else
		UIFight.setFlag(flag)
		UIManager.showWidget("ui_notice", "ui_team_info","ui_fight","ui_menu")
	end
  UIHomePage.hideMore()
end

function UIBuySlive.init()
	local btn_close = ccui.Helper:seekNodeByName( UIBuySlive.Widget , "btn_colse" )
    local btn_colsed = ccui.Helper:seekNodeByName( UIBuySlive.Widget , "btn_colsed" )
    local btn_buy = ccui.Helper:seekNodeByName( UIBuySlive.Widget ,"btn_buy")
    local btn_fight = ccui.Helper:seekNodeByName(UIBuySlive.Widget,"btn_fight")
    local btn_shenlong = ccui.Helper:seekNodeByName(UIBuySlive.Widget,"btn_shenlong")
    local btn_ore = ccui.Helper:seekNodeByName(UIBuySlive.Widget,"btn_ore")
    local InstPlayerlevel = net.InstPlayer.int["4"]  ---玩家等级
    local oreOpenLv = DictFunctionOpen[tostring(StaticFunctionOpen.mine)].level --资源矿开启条件
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_colsed then
                UIManager.popScene()
            elseif sender == btn_close then
                 UIManager.popScene()    
            elseif sender == btn_buy then
                 netSendDataGetNum()   
            elseif sender == btn_fight then           
                onFight(2)
            elseif sender == btn_shenlong then 
                local slbzOpenLevel = 1
                    for key,obj in pairs(DictBarrier) do
                        if obj.chapterId == DictSysConfig[tostring(StaticSysConfig.slbz)].value and obj.type ==  1  then                            
                            slbzOpenLevel = obj.openLevel  
                            break       
                        end
                    end                    
                if InstPlayerlevel < slbzOpenLevel then 
                    UIManager.showToast("（"..slbzOpenLevel..Lang.ui_buy_slive1)
                else  
                    onFight(3)
                    UIFightActivityChoose.setChapter(DictSysConfig[tostring(StaticSysConfig.slbz)].value , 3 )
                    UIManager.pushScene("ui_fight_activity_choose")                
                end
            elseif sender == btn_ore then
                if InstPlayerlevel < oreOpenLv then
                    UIManager.showToast("（"..oreOpenLv..Lang.ui_buy_slive2)
                else
                    UIBuySlive.isSoulFlag =true
                    UIManager.hideWidget("ui_menu")
                    UIManager.showWidget("ui_ore")
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_colsed:setPressedActionEnabled( true )
    btn_colsed:addTouchEventListener( onEvent )
    btn_buy:setPressedActionEnabled( true )
    btn_buy:addTouchEventListener(onEvent)
    btn_fight:setPressedActionEnabled( true )
    btn_fight:addTouchEventListener(onEvent)
    btn_shenlong:setPressedActionEnabled( true )
    btn_shenlong:addTouchEventListener(onEvent)
    btn_ore:setPressedActionEnabled( true )
    btn_ore:addTouchEventListener(onEvent)

end
function UIBuySlive.setup()
    local btn_shenlong = ccui.Helper:seekNodeByName(UIBuySlive.Widget,"btn_shenlong")
    local ui_number = btn_shenlong:getChildByName("label_left_number")
    local DictChapterObj = DictChapter[tostring(DictSysConfig[tostring(StaticSysConfig.slbz)].value)]
    local haveBarrierNum =0
    if net.InstPlayerChapter then
        for key,ActivityObj in pairs(net.InstPlayerChapter) do
            if ActivityObj.int["3"] == DictChapterObj.id then
                haveBarrierNum = ActivityObj.int["4"]
            end
        end
    end
    local activityBarrierTimes = DictChapterObj.fightNum - haveBarrierNum
    local VipNum = net.InstPlayer.int["19"] 
    if VipNum >= 0 then
        local VipTime1 = DictVIP[tostring(VipNum+1)].silverActivityChapterBuyTimes
        activityBarrierTimes = activityBarrierTimes + VipTime1
    end
    ui_number:setString(tostring(activityBarrierTimes))
end
function UIBuySlive.free()

end
