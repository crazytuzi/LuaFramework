--[[
 --
 -- add by vicky
 -- 2014.10.08
 --
 --]]


local data_item_item = require("data.data_card_card") 
local data_card_card = require("data.data_item_item") 
 require("data.data_error_error") 

local CHUI_ZI = 1
local JIAN_ZI = 2
local BU      = 3

-- local print = ResMgr.debugBanner

 local CaiQuanLayer = class("CaiQuanLayer", function()
 		return display.newNode()
 	end)




function CaiQuanLayer:onFanPaiView()
    self._rootnode["main_node"]:setVisible(false)
    self._rootnode["jiujianxian"]:setVisible(false)
    self._rootnode["fanpai_node"]:setVisible(true)


    if self.firstShowFanPai == nil then
        self.firstShowFanPai = 1
        self._rootnode["fanpai_confirm"]:addHandleOfControlEvent(function()
            if  self.isTimeOut == true then
                 show_tip_label("活动已结束")
                 return
             end
            self:onMainView()
        end, 
        CCControlEventTouchUpInside)

        for k,v in pairs(self.caiQuanModel.choosePosList) do
            
            local itemIcon = self._rootnode["card_"..(tonumber(k)+1)]

            local cellData = self.caiQuanModel.itemList[v+1]

            itemIcon:setTouchEnabled(false)
            ResMgr.refreshItemWithTagNumName({
                itemType = cellData.t,
                id       = cellData.id,
                itemNum  = cellData.n,
                itemBg   = itemIcon
                }) 
        end
            
    end

    self:setChooseCnt(self.caiQuanModel.chooseCount)
    

end

function CaiQuanLayer:setChooseCnt(num)
    self.caiQuanModel.chooseCount = num
    self._rootnode["rest_ttf"]:setString("您的剩余翻牌次数:  "..self.caiQuanModel.chooseCount)
    self._rootnode["fan_pai_rest"]:setString("您的剩余翻牌次数:  "..self.caiQuanModel.chooseCount)

end

function CaiQuanLayer:timeSchedule(param)
    self.restTime = param.time/1000
    local timeLabel = param.label
    local callBack = param.callBack --时间执行完毕后的回调

    timeLabel:setString("酒剑仙"..format_time_unit(self.restTime).."后离开")
    local function update( dt )

        if timeLabel == nil  or timeLabel:getParent()==nil  or self.restTime <= 0 then
            self.scheduler.unscheduleGlobal(self.timeData)
            if self.restTime <= 0 then
                timeLabel:setString("酒剑仙已经离开，大侠请明日再战")
                callBack()
            end
        else
            self.restTime = self.restTime - 1
            local timeStr = "酒剑仙"..format_time_unit(self.restTime).."后离开"
            timeLabel:setString(timeStr)
            -- PostNotice(NoticeKey.ArenaRestTime, CCFloat:create(self.restTime))
        end

    end
    self.scheduler = require("framework.scheduler")
    if self.timeData ~= nil then
        self.scheduler.unscheduleGlobal(self.timeData)
    end
    self.timeData = self.scheduler.scheduleGlobal( update, 1, false )
end



 function CaiQuanLayer:onMainView(data)
    -- if  self.isTimeOut == true then
    --     show_tip_label("活动已结束")
    --     return
    -- end

    self._rootnode["main_node"]:setVisible(true)
    self._rootnode["jiujianxian"]:setVisible(true)
    self._rootnode["fanpai_node"]:setVisible(false)    

    if self.isFirstShow then
        self.isFirstShow = false
        for i = 1,#self.caiQuanModel.itemList do
            local cellData = self.caiQuanModel.itemList[i]
            -- print("cellData")
            dump(cellData)
            self._rootnode["item_icon_"..i]:removeAllChildrenWithCleanup(true)
            ResMgr.refreshItemWithTagNumName({
                itemType = cellData.t,
                id       = cellData.id,
                itemNum  = cellData.n,
                itemBg   = self._rootnode["item_icon_"..i]
                })
            self._rootnode["item_icon_"..i]:setTouchEnabled(true)
            self._rootnode["item_icon_"..i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                 local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = cellData.id,
                        type = cellData.t
                        
                        })

                 display.getRunningScene():addChild(itemInfo, 100000)
            
            end) 

        end

       

        for i = 1,3 do
            self._rootnode["hand_btn_"..i]:addHandleOfControlEvent(function()
                if self.isTimeOut == true then
                     show_tip_label("活动已结束")
                     return
                end

                if self.caiQuanModel.guessCount > 0 then
                    self.caiQuanModel.curState = i
                    self:sendGuessRes()
                else
                    show_tip_label("猜拳次数不足")
                end
            end, 
            CCControlEventTouchUpInside)
        end

        self._rootnode["jingjiu_btn"]:addHandleOfControlEvent(function()
            if  self.isTimeOut == true then
                 show_tip_label("活动已结束")
                 return
             end
            local choseCount = 0
            for k,v in pairs(self.caiQuanModel.choosePosList) do
                choseCount = choseCount + 1
            end

            if self.caiQuanModel.guessCount > 0 then
                show_tip_label("嗝～你还有机会，不需要敬酒")
            elseif game.player.m_gold < self.caiQuanModel.buyGold then
                show_tip_label("元宝不足，无法敬酒")
            elseif self.caiQuanModel.chooseCount + choseCount > 2 then
                show_tip_label("你今日已能领取所有宝物，不需敬酒")                
            else
                --敬酒
            local layer = require("utility.MsgBox").new({
            size = CCSizeMake(500, 300),
            leftBtnName = "取消",
            rightBtnName = "确定",
            content = "小小美酒不成敬意，酒剑仙前辈再给次机会吧！T.T",           
            rightBtnFunc = function()
                self:sendGuessBuy()               
            end

            })
            
            display.getRunningScene():addChild(layer, 100)
                
            end            
        end, 
        CCControlEventTouchUpInside)
    end

    self:setChooseCnt(self.caiQuanModel.chooseCount)

    self:updateDown()
 end

function CaiQuanLayer:sendGuessBuy()
--如果有钱
--否则没钱
    RequestHelper.buyGuessTime({
        callback = function(data)
            print("bugguessTime")
            dump(data)
            self:setGuessCount(1)
            game.player.m_gold = data.rtnObj.gold
            self.caiQuanModel.buyGold = data.rtnObj.spend
            self:setBuyGold(self.caiQuanModel.buyGold)
            -- self:setBuyGold(1)            
        end
        })
end

 function CaiQuanLayer:sendGuessRes()
     RequestHelper.guessing({
        callback = function(data)
            print("sendguessRes")
            dump(data)
            local objData = data["rtnObj"]
            
            self:onGuessShow(objData.win)
           
            self:setGuessCount(objData.guessCount)
            
            self:setChooseCnt(objData.chooseCount)
        end
        })
 end

function CaiQuanLayer:onGuessShow(win)
    if  self.isTimeOut == true then
        show_tip_label("活动已结束")
        return
    end

    local left = self.caiQuanModel.curState
    local right = 0
    if win == 1 then
        right = left +1
    else
        right = left -1
    end
    
    if right > 3 then
        right = 1 
    elseif right < 1 then
        right = 3
    end

   local function getHand(num)        
        if num == 1 then
            return "caiquan_shitou"
        elseif num ==2 then
            return "caiquan_jiandao"
        elseif num == 3 then
            return "caiquan_bu"
        end
   end

   self.maskLayer = require("utility.ShadeLayer").new()
   display.getRunningScene():addChild(self.maskLayer)

   -- show_tip_label("左边是"..getHand(left).."  右边是"..getHand(right))

   local bgWidth = self._rootnode["cai_bg"]:getContentSize().width
   local bgHeight = self._rootnode["cai_bg"]:getContentSize().height

    local leftHandAnim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = getHand(left),
        isRetain = false
    })
    leftHandAnim:setPosition(0,display.height/2)
    display.getRunningScene():addChild(leftHandAnim, 100)

    


    local rightHandAnim = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = getHand(right),
        isRetain = false,
        frameFunc = function()
            local resultAnimName
            local resultFunc
            if win == 1 then
                --赢了
                --播放胜利动画，动画完事后,播放获得一次翻牌次数
                resultAnimName = "caiquan_chenggong" 
                resultFunc = function()
                    show_tip_label("恭喜您获得一次翻牌次数")
                end
                local path = "sound/sfx/".."u_caiquanshengli"..".mp3"
                GameAudio.playSound(path, false)               
            else
                resultAnimName = "caiquan_shibai"
                local path = "sound/sfx/".."u_caiquanshibai"..".mp3"
                GameAudio.playSound(path, false)  
                --输了播放失败动画               
            end

            local resultAnim = ResMgr.createArma({
                resType = ResMgr.UI_EFFECT,
                armaName = resultAnimName,
                isRetain = false,
                finishFunc = resultFunc
            })
            resultAnim:setPosition(display.width/2,display.height/2)
            display.getRunningScene():addChild(resultAnim, 1000000)
        end,
        finishFunc = function()
            self.maskLayer:removeSelf()
            if win == 1 then                
                self:onFanPaiView()
            else                
                --失败动画结束后，回到主界面
                self:onMainView()
            end

        end
    })
    rightHandAnim:setPosition(display.width,display.height/2)
    rightHandAnim:setScaleX(-1)
    display.getRunningScene():addChild(rightHandAnim, 100)


    
end

function CaiQuanLayer:setGuessCount(num)
    self.caiQuanModel.guessCount = num
    self._rootnode["rest_cai_num"]:setString(num)
end





 function CaiQuanLayer:updateDown()
    self:setGuessCount(self.caiQuanModel.guessCount)

    self:setBuyGold(self.caiQuanModel.buyGold)
 end

 function CaiQuanLayer:showRace(data)
    self._rootnode["main_node"]:setVisible(false)
    self._rootnode["fanpai_node"]:setVisible(false)
    self._rootnode["jiujianxian"]:setVisible(true)
 end

 function CaiQuanLayer:initModel()
     self.caiQuanModel = {}
     --猜拳剩余次数
     self.caiQuanModel.guessCount = 0
     --翻牌剩余次数
     self.caiQuanModel.chooseCount = 0
     --在主界面显示的全部的宝物 
     self.caiQuanModel.itemList ={}
     --一共猜了多少次
     self.caiQuanModel.allGuessCount = 0


     --猜拳宝物状态列表,当打开猜拳的时候 就是这个
     self.caiQuanModel.choosePosList = {} 

     --购买的次数
     self.caiQuanModel.buyCount = 0

     --敬酒的钱数
     self.caiQuanModel.buyGold = 0

     --出了啥 剪子 包袱 锤？
     self.caiQuanModel.curState = 0

 end

 function CaiQuanLayer:setBuyGold(num)
    self.caiQuanModel.buyGold =num
    self._rootnode["jingjiu_cost"]:setString(self.caiQuanModel.buyGold)
 end

function CaiQuanLayer:sendInitRes()
    RequestHelper.getGuessInfo({
        callback = function(data)
            print("ininini")
            dump(data)
            local objData = data["rtnObj"]
            dump(objData.itemList)
           
            self:setGuessCount(objData.guessCount)

            self:setChooseCnt(objData.chooseCount)
            self:setBuyGold(objData.buyGold)
            

            self.caiQuanModel.itemList = objData.itemList
            self.caiQuanModel.allGuessCount = objData.allGuessCount

            self.caiQuanModel.choosePosList = objData.choosePosList

            self.caiQuanModel.buyCount = objData.buyCount

            self.caiQuanModel.endTime = objData.endTime

            self.endTimeLabel = ResMgr.createShadowMsgTTF({color = FONT_COLOR.GREEN})

            self._rootnode["fan_yan"]:addChild(self.endTimeLabel)

            self.endTimeLabel:setPosition(self._rootnode["fan_yan"]:getContentSize().width/2 ,self._rootnode["fan_yan"]:getContentSize().height*0.6)

            self:timeSchedule({time = self.caiQuanModel.endTime,label = self.endTimeLabel,callBack = function()

                self.isTimeOut= true
                print("time out")
                -- if self.tType == 1 then
                --     self.tType = 2
                --     --挑战结束倒计时
                --     self._rootnode["rest_type_name"]:setString("领奖倒计时：")
                -- else
                --     self.tType = 1
                --     --发奖结束倒计时
                --     self._rootnode["rest_type_name"]:setString("奖励发放中：")
                -- end
                -- PostNotice(NoticeKey.SwitchArenaTimeType)
            end})
            

            self:onMainView()
       end
       })
end

 
function CaiQuanLayer:ctor(param)

	local viewSize = param.viewSize 
	self:setNodeEventEnabled(true) 

    self.isFirstShow = true
    --建立一个model对象用来管理当前界面所有可能
    self:initModel()


    local proxy = CCBProxy:create()
    self._rootnode = {}

	-- 创建UI 
    local contentNode = CCBuilderReaderLoad("nbhuodong/caiquan_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(contentNode) 

    --
    for i = 1,3 do
        local itemIcon = self._rootnode["card_"..i]
        --如果
        local isCurPosTouch = true
        local cellData
        print("self.caiQuanModel.choosePosList")
        dump(self.caiQuanModel.choosePosList)
        for k,v in pairs(self.caiQuanModel.choosePosList) do
            if i == tonumber(k) + 1 then  --瞳瞳用的是他娘的java 下标从0开始
                print("isTouchchch")
                isCurPosTouch = false
                cellData = self.caiQuanModel.itemList[ v + 1]
            end
        end
       
        
        if isCurPosTouch == true then
            itemIcon:setTouchEnabled(true)
            
            itemIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                if (event.name == "began") then
                        if  self.isTimeOut == true then
                            show_tip_label("活动已结束")
                            return
                        end

                    if self.caiQuanModel.chooseCount > 0 then
                        ResMgr.createMaskLayer()
                        RequestHelper.guessChoseCard({
                            pos = i - 1, --瞳瞳用的是他娘的java 下标从0开始
                            callback = function(data)                      


                            self:setChooseCnt(data.rtnObj.chooseCnt)
                            itemIcon:setTouchEnabled(false)
                            ResMgr.removeMaskLayer()
                            local itemData = data.rtnObj.item
                            self.caiQuanModel.choosePosList[tostring(i-1)] =  data.rtnObj.index
                            ResMgr.flipCard(itemIcon,function()
                                    ResMgr.refreshItemWithTagNumName({
                                    itemType = itemData.t,
                                    id       = itemData.id,
                                    itemNum  = itemData.n,
                                    itemBg   = itemIcon
                                    })
                                end)     
                                

                            end})
                    else
                        show_tip_label("剩余翻牌次数不足")
                    end          
                    return true
                end
            end)     
        else

            itemIcon:setTouchEnabled(false)
            ResMgr.refreshItemWithTagNumName({
                itemType = cellData.t,
                id       = cellData.id,
                itemNum  = cellData.n,
                itemBg   = self._rootnode["card_"..i]
                }) 

        end   
    end

     self._rootnode["start_fan_pai_btn"]:addHandleOfControlEvent(function()
                if  self.isTimeOut == true then
                     show_tip_label("活动已结束")
                     return
                 end
                    self:onFanPaiView()
                -- else
                --     show_tip_label("剩余翻牌次数不足")
                -- end
            end, 
            CCControlEventTouchUpInside)



    self:sendInitRes()
end 

function  CaiQuanLayer:onExit()
   
    if self.timeData ~= nil then
        self.scheduler.unscheduleGlobal(self.timeData)
    end
    
    -- body
end


 function CaiQuanLayer:updateRefreshMsg() 
    -- 更新UI 
    if self._refreshNum > 0 then 
        if self._refreshType == RefreshType.Free and self._refreshNum >= self._vipFreeTimes then 
            self._rootnode["freeLimit"]:setVisible(true) 
        else
            self._rootnode["freeLimit"]:setVisible(false)  
        end 

        if self._refreshType == RefreshType.Free then 
            self._rootnode["refresh_free_lbl"]:setString(tostring(self._refreshNum)) 
            self._rootnode["free_node"]:setVisible(true) 
            self._rootnode["shuaxinling_node"]:setVisible(false) 
            self._rootnode["gold_node"]:setVisible(false) 

        elseif self._refreshType == RefreshType.Token then 
            self._rootnode["refresh_shuaxinling_lbl"]:setString(tostring(self._refreshNum)) 
             
            self._rootnode["shuaxinling_node"]:setVisible(true) 
            self._rootnode["gold_node"]:setVisible(false) 
            self._rootnode["free_node"]:setVisible(false) 

        elseif self._refreshType == RefreshType.Gold then 
            game.player:setGold(self._refreshNum) 
            
            self._rootnode["refresh_gold_lbl"]:setString(tostring(self._goldRefreshTimes)) 

            self._rootnode["gold_node"]:setVisible(true) 
            self._rootnode["shuaxinling_node"]:setVisible(false) 
            self._rootnode["free_node"]:setVisible(false) 
        end
    end 
 end





 return CaiQuanLayer 


