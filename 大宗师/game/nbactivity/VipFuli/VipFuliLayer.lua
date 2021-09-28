--[[
 --
 -- add by vicky
 -- 2014.11.03 
 --
 --]]

 require("data.data_error_error") 
 local data_item_item = require("data.data_item_item") 
 local data_card_card = require("data.data_card_card") 

 local MAX_ZORDER = 1111 

 local VipFuliLayer = class("VipFuliLayer", function()
 		return display.newNode()
 	end)


 function VipFuliLayer:getVipData()
 	RequestHelper.vipFuli.getData({
 		callback = function(data)
 			dump(data)
 			if data.err ~= "" then 
                dump(data.err)
 			else
 				self:initData(data) 
 			end 
	 	end
 		})
 end 


 function VipFuliLayer:getReward()
 	RequestHelper.vipFuli.getReward({
 		callback = function(data)
 			dump(data)
 			if data.err ~= "" then 
 				dump(data.err) 
 			else
 				-- result:	领取结果 1-成功 2-失败
 				local rtnObj = data.rtnObj
 				local result = rtnObj.result 

 				if result == 1 then 
 					self._isHasGet = true 
 					self:updateRewardBtn()

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


 function VipFuliLayer:ctor(param)
    self._curInfoIndex = -1 
    
 	local viewSize = param.viewSize 
 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	
    local node = CCBuilderReaderLoad("nbhuodong/vipFuli_layer.ccbi", proxy, self._rootnode, self, viewSize)
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

    self._isHasGet = true 

    self:getVipData() 
 end 


 function VipFuliLayer:updateRewardBtn()
     if self._isHasGet then 
        self._rootnode["getRewardBtn"]:setEnabled(false) 
        self._rootnode["tag_has_get"]:setVisible(true)
        self._rootnode["getRewardBtn"]:setVisible(false) 
    else
        self._rootnode["getRewardBtn"]:setEnabled(true) 
        self._rootnode["tag_has_get"]:setVisible(false)
        self._rootnode["getRewardBtn"]:setVisible(true) 
    end 
 end


 function VipFuliLayer:initData(data) 
	local rtnObj = data.rtnObj 
    local curVipLevel = rtnObj.curVipLevel  -- 当前VIP等级 
    local curExp = rtnObj.curExp            -- 当前经验值累计
    local curExpLimit = rtnObj.curExpLimit  -- 当前经验值上限

    -- 是否已领取   // 1-已领取 2-未领取
    if rtnObj.isGet and rtnObj.isGet == 2 then 
        self._isHasGet = false 
    end 

    self._rootnode["vip_level_lbl"]:setString(tostring(curVipLevel)) 

    -- 查看VIP特权
    local checkVipBtn = self._rootnode["checkBtn"]
    checkVipBtn:addHandleOfControlEvent(function(eventName, sender)
        checkVipBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local vipInfoLayer = require("game.shop.Chongzhi.ChongzhiVipDesInfoLayer").new({
            curVipLv = curVipLevel, 
            curVipExp = curExp,  
            vipExpLimit = curExpLimit, 
            confirmFunc = function() 
                checkVipBtn:setEnabled(true) 
            end
        }) 
        game.runningScene:addChild(vipInfoLayer, MAX_ZORDER)
    end, CCControlEventTouchUpInside) 

    -- 领取奖励按钮 
    self._rootnode["getRewardBtn"]:addHandleOfControlEvent(function(eventName, sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if not self._isHasGet then 
       		self:getReward() 
        else
       		show_tip_label(data_error_error[1801].prompt)
        end 
    end, CCControlEventTouchUpInside)

    self:updateRewardBtn() 

    self._rewardDatas = {}
    
    local vipData = ResMgr.getVipLevelData(curVipLevel) 
    if vipData ~= nil then 
        for i = 1, #vipData.arr_type2 do 
        	local type = vipData.arr_type2[i] 
        	ResMgr.showAlert(type, "data_yueka_yueka表，月卡赠送物品的type数量和num数量不匹配")
        	local num = vipData.arr_num2[i]  
        	ResMgr.showAlert(num, "data_yueka_yueka表，月卡赠送物品的num数量和num数量不匹配")
        	local itemId = vipData.arr_item2[i] 
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
 end


 function VipFuliLayer:initRewardListView(rewardDatas)
	
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


 return VipFuliLayer 

