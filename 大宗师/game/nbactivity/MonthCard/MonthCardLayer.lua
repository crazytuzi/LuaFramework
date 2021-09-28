--[[
 --
 -- add by vicky
 -- 2014.10.27
 --
 --]]

 local data_yueka_yueka = require("data.data_yueka_yueka") 
 require("data.data_error_error") 
 local data_item_item = require("data.data_item_item") 
 local data_card_card = require("data.data_card_card") 

 local MAX_ZORDER = 1111 

 local MonthCardLayer = class("MonthCardLayer", function()
 		return display.newNode()
 	end)


 function MonthCardLayer:getMonthData()
 	RequestHelper.monthCard.getData({
 		callback = function(data)
 			dump(data)
 			if data["0"] ~= "" then 
 				CCMessageBox(data["0"], "Error")
 			else
 				self:initData(data) 
 			end 
	 	end
 		})
 end 


 function MonthCardLayer:getReward()
 	RequestHelper.monthCard.getReward({
 		callback = function(data)
 			dump(data)
 			if data["0"] ~= "" then 
 				CCMessageBox(data["0"], "Error")
 			else
 				-- getResult:	领取结果 1-成功 2-失败
 				local rtnObj = data.rtnObj
 				local getResult = rtnObj.getResult 
 				if getResult == 1 then 
 					self._isHasGet = true 
 					self:updateRewardBtn(true) 

                    -- 弹出得到奖励提示框
                    local title = "恭喜您获得如下奖励："
                    local msgBox = require("game.Huodong.RewardMsgBox").new({
                        title = title, 
                        cellDatas = self._rewardDatas 
                        })

                    game.runningScene:addChild(msgBox, MAX_ZORDER)
 				end 
 			end 
	 	end
 		})
 end


 function MonthCardLayer:updateRewardBtn(isHasGet)
    if isHasGet then 
        self._rootnode["getRewardBtn"]:setEnabled(false) 
        self._rootnode["getRewardBtn"]:setVisible(false)
        self._rootnode["tag_has_get"]:setVisible(true)
    else
        self._rootnode["getRewardBtn"]:setEnabled(true)
        self._rootnode["getRewardBtn"]:setVisible(true) 
        self._rootnode["tag_has_get"]:setVisible(false)
    end 
 end


 function MonthCardLayer:ctor(param)
    self._curInfoIndex = -1 
    
 	local viewSize = param.viewSize 
 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	
    local node = CCBuilderReaderLoad("nbhuodong/month_card_layer.ccbi", proxy, self._rootnode, self, viewSize)
    self:addChild(node) 

    local titleIcon = self._rootnode["title_icon"] 
    local bottomNode = self._rootnode["bottom_node"] 

    -- 底部信息 
    local disH = viewSize.height - titleIcon:getContentSize().height - bottomNode:getContentSize().height 
    if disH > 10 then 
    	bottomNode:setPosition(bottomNode:getPositionX(), disH/2) 
    end 

    -- 标题自适应
    local scaleY = (viewSize.height - bottomNode:getContentSize().height)/titleIcon:getContentSize().height 
    if scaleY > 1 then 
    	scaleY = 1 
    end 
    self._rootnode["title_icon"]:setScale(scaleY)  

    self:getMonthData() 
 end 


 function MonthCardLayer:buyFunc()
 	-- 购买后更新领取状态、是否可购买
 	local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
 	game.runningScene:addChild(chongzhiLayer, MAX_ZORDER)

 end


 function MonthCardLayer:initData(data) 
	local rtnObj = data.rtnObj 
	
	-- 月卡剩余天数
	self._days = rtnObj.days or 0 
	self._isCanBuy = false 	
	self._isHasGet = true 

	-- 是否可购买月卡	1-是 2-否
	if rtnObj.isCanBuy and rtnObj.isCanBuy == 1 then 
		self._isCanBuy = true 
	end 

	-- 是否已领取	 1-是 2-否
	if rtnObj.isget and rtnObj.isget == 2 then 
		self._isHasGet = false 
	end 

	-- 购买按钮 
    self._rootnode["buyBtn"]:addHandleOfControlEvent(function(eventName, sender) 
        	if self._isCanBuy then 
               self:buyFunc() 
            else 
            	show_tip_label(data_error_error[1800].prompt)
            end 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchUpInside) 

    -- 领取奖励按钮 
    local getRewardBtn = self._rootnode["getRewardBtn"] 
    getRewardBtn:addHandleOfControlEvent(function(eventName, sender)
            getRewardBtn:setEnabled(false) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if self._days > 0 and not self._isHasGet then 
           		self:getReward() 
            else
           		show_tip_label(data_error_error[1801].prompt) 
                getRewardBtn:setEnabled(true) 
            end 
        end, CCControlEventTouchUpInside)

    if self._days > 0 and self._isHasGet then 
        self:updateRewardBtn(true)
    else 
        self:updateRewardBtn(false)
    end 

    -- 月卡剩余3天
    local msgLbl1 = ui.newTTFLabelWithShadow({
        text = "月卡剩余3天",
        size = 22,
        color = ccc3(60, 243, 35),
        shadowColor = ccc3(0, 0, 0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER 
    })
	
	msgLbl1:setPosition(0, -msgLbl1:getContentSize().height/2)
	self._rootnode["msg_lbl_1"]:removeAllChildren()
    self._rootnode["msg_lbl_1"]:addChild(msgLbl1)

    -- 内可续购
    local msgLbl2 = ui.newTTFLabelWithShadow({
        text = "内可续购",
        size = 22,
        color = ccc3(60, 243, 35),
        shadowColor = ccc3(0, 0, 0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER
    })
    
    msgLbl2:setPosition(0, msgLbl2:getContentSize().height/2)
    self._rootnode["msg_lbl_2"]:removeAllChildren()
    self._rootnode["msg_lbl_2"]:addChild(msgLbl2)


    -- 剩余天数
    local leftLbl = ui.newTTFLabelWithShadow({
        text = "剩余天数：",
        size = 22,
        color = ccc3(60, 243, 35),
        shadowColor = ccc3(0, 0, 0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT
    })

	leftLbl:setPosition(0, leftLbl:getContentSize().height/2)
	self._rootnode["leftDay_lbl"]:removeAllChildren()
    self._rootnode["leftDay_lbl"]:addChild(leftLbl)

    -- 天数num
    local dayLbl = ui.newTTFLabelWithShadow({
        text = tostring(self._days), 
        size = 22,
        color = ccc3(247, 31, 31), 
        shadowColor = ccc3(0, 0, 0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT
    })
	
	dayLbl:setPosition(0, dayLbl:getContentSize().height/2)
	self._rootnode["day_num_lbl"]:removeAllChildren()
    self._rootnode["day_num_lbl"]:addChild(dayLbl)


    self._rewardDatas = {}
    local yuekaData = data_yueka_yueka[2] 
    for i = 1, yuekaData.num do 
    	local type = yuekaData.arr_type[i] 
    	ResMgr.showAlert(type, "data_yueka_yueka表，月卡赠送物品的type数量和num数量不匹配")
    	local num = yuekaData.arr_num[i]  
    	ResMgr.showAlert(num, "data_yueka_yueka表，月卡赠送物品的num数量和num数量不匹配")
    	local itemId = yuekaData.arr_item[i] 
    	ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的item数量和num数量不匹配")

    	local iconType = ResMgr.getResType(type)
    	local itemData 
    	if iconType == ResMgr.HERO then 
    		itemData = data_card_card[itemId] 
    	elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then 
    		itemData = data_item_item[itemId] 
    	else
    		ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的数据不对index:" .. i) 
    	end 

    	table.insert(self._rewardDatas,  {
    		id = itemId, 
    		name = itemData.name, 
    		num = num, 
    		type = type, 
    		iconType = iconType, 
    		})
    end 

    self:initRewardListView(self._rewardDatas) 
 end


 function MonthCardLayer:initRewardListView(rewardDatas)
	
	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height

    -- 创建 
    local function createFunc(index)
    	local item = require("game.nbactivity.MonthCard.MonthCardRewardItem").new()
    	return item:create({
    		id = index, 
    		viewSize = CCSizeMake(boardWidth, boardHeight), 
    		itemData = rewardDatas[index + 1]
    		})
    end

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            itemData = rewardDatas[index + 1]
            })
    end

    local cellContentSize = require("game.nbactivity.MonthCard.MonthCardRewardItem").new():getContentSize()

    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #rewardDatas, 
        cellSize    = cellContentSize, 
        touchFunc = function(cell)
            if self._curInfoIndex ~= -1 then 
                return 
            end 
            local idx = cell:getIdx() + 1 
            self._curInfoIndex = idx 
            
            local itemData = rewardDatas[idx] 
            local itemInfo = require("game.Huodong.ItemInformation").new({
                    id = itemData.id,
                    type = itemData.type,
                    name = itemData.name,
                    describe = itemData.describe, 
                    endFunc = function() 
                        self._curInfoIndex = -1 
                    end 
                })
             game.runningScene:addChild(itemInfo, 100) 
        end 
    	})

    self.ListTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self.ListTable)

end


 return MonthCardLayer 

