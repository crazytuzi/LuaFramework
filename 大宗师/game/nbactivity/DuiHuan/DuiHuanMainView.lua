--
-- Author: Daneil
-- Date: 2015-01-15 22:13:07
--
require("game.Biwu.BiwuFuc")
local DuiHuanMainView = class("DuiHuanMainView", function ()
    return display.newLayer("DuiHuanMainView")
end)

local data_item_item = require("data.data_item_item")

function DuiHuanMainView:setUpView(param)
	self:setContentSize(param.size)
    self:setUpExtraView(param)

    local listViewSize = self.mainFrameBng:getContentSize()

    local sizeGroup = { 
    	cc.size(listViewSize.width,520 * 0.66),
    	cc.size(listViewSize.width,520 * 0.91),
    	cc.size(listViewSize.width,520 * 0.91)
	}
    
	local refreshCallFunc
	local exChangeCallFunc
    refreshCallFunc = function(index,id)
    	local func = function (data)
    		--这里边更换数据  更新界面
    		self._data[index + 1].exchExp = data.exchExp
    		self._data[index + 1].refGold = data.refGold

    		local param =  {
						viewSize = sizeGroup[self._data[index + 1].type], 
			            data = self._data[index + 1],
			            index  = index,
			            refreshFunc = refreshCallFunc,
			            exChangeFunc = exChangeCallFunc
	            	   }
	 		self._tableView:reloadCell(index,param)
    	end
    	self:refresh(func,id)
    end

    exChangeCallFunc = function (index,id)
    	local func = function (data)
    		--这里边更换数据  更新界面
    		self._data[index + 1].exchExp = data.exchExp
    		self._data[index + 1].exchNum = data.exchNum
    		local param =  {
						viewSize = sizeGroup[self._data[index + 1].type], 
			            data = self._data[index + 1],
			            index  = index,
			            refreshFunc = refreshCallFunc,
			            exChangeFunc = exChangeCallFunc
	            	   }
	 		self._tableView:reloadCell(index,param)

	 		local func = function()
	 			--全部刷新
		 		self:getData(function()
		 			
		 		end)
	 		end
	 		--弹框
	 		local data = {}
	 		for k,v in pairs(self._data[index + 1].exchExp.exchRst) do
	 			local temp = {}
	 			temp.id = v.id
	 			temp.num = v.num
	 			temp.type = v.type
	 			temp.iconType = ResMgr.getResType(v.type)
	 			temp.name = require("data.data_item_item")[v.id].name
	 			table.insert(data,temp)
	 		end

 			local title = "恭喜您获得如下物品："
            local msgBox = require("game.Huodong.RewardMsgBox").new({
                title = title, 
                cellDatas = data,
                confirmFunc = func
                })
            CCDirector:sharedDirector():getRunningScene():addChild(msgBox,1000)
    	end
    	self:exchange(func,id)
    end

	local touchNode = display.newNode()
    touchNode:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)
    touchNode:setContentSize(cc.size(display.width,display.height))
    self:addChild(touchNode,20)

    -- 创建
    local function createFunc(index)
		local item = require("game.nbactivity.DuiHuan.DuiHuanItemView").new()
		return item:create({
            viewSize = sizeGroup[self._data[index + 1].type], 
            data = self._data[index + 1],
            index  = index,
            refreshFunc = refreshCallFunc,
            exChangeFunc = exChangeCallFunc
            })
    end

    -- 刷新
    local function refreshFunc(cell, index)
        cell:refresh({ 
        	viewSize = sizeGroup[self._data[index + 1].type], 
            data = self._data[index + 1],
            index  = index,
            refreshFunc = refreshCallFunc,
            exChangeFunc = exChangeCallFunc,
			})
    end

    local function cellSizeFunc(view, idx)
    	print(idx)
        return sizeGroup[idx + 1]
    end

    local boardWidth  = listViewSize.width
    local boardHeight = listViewSize.height 
    self._tableView = require("utility.TableViewExt").new({
        size        = CCSizeMake(boardWidth, boardHeight - 20), 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum     = #self._data, 
        cellSize    = sizeGroup[1],
        cellSizeFunc = cellSizeFunc,
        touchFunc = function(cell)
            	for i = 1, #cell:getData() do
	                local icon = cell:getIcon(i)
	                local pos = icon:convertToNodeSpace(ccp(posX, posY))
	                local itemdata  = cell:getItemData(i)
	                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
	                    if itemdata.type ~= 6 then
		                    local itemInfo = require("game.Huodong.ItemInformation").new({
		                        id = itemdata.id, 
		                        type = itemdata.type, 
		                        name = data_item_item[itemdata.id].name, 
		                        describe = data_item_item[itemdata.id].dis
		                        })
							CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
						else
							local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {resId = itemdata.id})
				        	CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 1000)
						end
						break
	                end
            	end
        	end
        })

    self._tableView:setPosition(0, 10)
    self._tableView:setAnchorPoint(cc.p(0,0))
    self.mainFrameBng:addChild(self._tableView)
end

function DuiHuanMainView:setUpExtraView(param)

	local titleBng = display.newSprite("#titlebng.png")
	titleBng:setTouchEnabled(true)
	titleBng:setAnchorPoint(cc.p(0.5,1))
	titleBng:setPosition(cc.p(param.size.width * 0.5, param.size.height * 1))
	self:addChild(titleBng,10)

	local titleBngSize = titleBng:getContentSize()
	local piaodaiBng = display.newSprite("#piaodai.png")
	piaodaiBng:setAnchorPoint(cc.p(0.5,1))
	piaodaiBng:setPosition(cc.p(titleBngSize.width * 0.6, titleBngSize.height * 0.9))
	titleBng:addChild(piaodaiBng)

	local piaodaiBngSize = piaodaiBng:getContentSize()
	local titleLabel = display.newSprite("#duihuanxianshi.png")
	titleLabel:setAnchorPoint(cc.p(0.5,0.5))
	titleLabel:setPosition(cc.p(piaodaiBngSize.width * 0.5, piaodaiBngSize.height * 0.7))
	piaodaiBng:addChild(titleLabel)

	--活动描述
	local disLabel1 = ui.newTTFLabelWithOutline({  text = "活动时间:", 
											size = 23, 
											color = FONT_COLOR.WHITE,
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel1:setPosition(cc.p(titleBngSize.width * 0.07,titleBngSize.height * 0.5))
	titleBng:addChild(disLabel1)

	dump(self._data)
	--活动时间
    local startTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._start) / 1000))
    local endTimeStr = os.date("%Y-%m-%d", math.ceil(tonumber(self._end) / 1000))

    local startTimeStr = string.split(startTimeStr,"-")
    local startTime
    startTime = startTimeStr[1].."年"
    startTime = startTime..startTimeStr[2].."月"
    startTime = startTime..startTimeStr[3].."日"

    local endTimeStr = string.split(endTimeStr,"-")
    local endTime
    endTime = endTimeStr[1].."年"
    endTime = endTime..endTimeStr[2].."月"
    endTime = endTime..endTimeStr[3].."日"



	local disLabelValue1 = ui.newTTFLabelWithOutline({  text = startTime.."--"..endTime, 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabelValue1:setPosition(cc.p(titleBngSize.width * 0.27,titleBngSize.height * 0.5))
	titleBng:addChild(disLabelValue1)


	--活动描述
	local disLabel2 = ui.newTTFLabelWithOutline({  text = "活动剩余时间:", 
											size = 23, 
											color = FONT_COLOR.WHITE,
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel2:setPosition(cc.p(titleBngSize.width * 0.07,titleBngSize.height * 0.35))
	titleBng:addChild(disLabel2)

	local timeAll = math.floor((self._end - self._now) / 1000)
	local disLabelValue2 = ui.newTTFLabelWithOutline({  text = self:timeFormat(timeAll), 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabelValue2:setPosition(cc.p(titleBngSize.width * 0.34,titleBngSize.height * 0.35))
	titleBng:addChild(disLabelValue2)

	
	local countDown = function()
		--剩余时间 
		timeAll = timeAll - 1
		if timeAll <= 0 then
			self._scheduler.unscheduleGlobal(self._schedule)
			disLabelValue2:setString("活动已结束")
			disLabelValue2:setPositionX(disLabelValue2:getPositionX() + 20)
			show_tip_label("活动已结束")
		else
			disLabelValue2:setString(self:timeFormat(timeAll))
		end
		
	end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(countDown, 1, false )	


	--兑换预览
	local yulanBtn = display.newSprite("#duihuanyulan.png")
    yulanBtn:setPosition(titleBngSize.width * 0.92, titleBngSize.height * 0.4)
    titleBng:addChild(yulanBtn)

	addTouchListener(yulanBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
        		CCDirector:sharedDirector():getRunningScene():addChild(require ("game.nbactivity.DuiHuan.DuiHuanGiftPopup").new(),1222222,10000000)
        	end
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    --背景框
    self.mainFrameBng = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, 
                        cc.size(param.size.width,param.size.height -  titleBng:getContentSize().height + 30))
    self.mainFrameBng:setAnchorPoint(cc.p(0.5,0))
    self.mainFrameBng:setPosition(param.size.width * 0.5, 10)
    self:addChild(self.mainFrameBng)


end

function DuiHuanMainView:clear()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
		print("----clear----")
	end
end

function DuiHuanMainView:timeFormat(timeAll)
	local basehour = 60 * 60
	local basemin  = 60
	local hour = math.floor(timeAll / basehour) 
	local time = timeAll - hour * basehour
	local min  = math.floor(time / basemin) 
	local time = time - basemin * min
	local sec  = math.floor(time)
	hour = hour < 10 and "0"..hour or hour
	min = min < 10 and "0"..min or min
	sec = sec < 10 and "0"..sec or sec
	local nowTimeStr = hour.."时"..min.."分"..sec.."秒"
	return nowTimeStr
end

function DuiHuanMainView:ctor(param)
	self:load()
    local bng = display.newScale9Sprite("#month_bg.png", 0, 0, 
                param.size)
    bng:setAnchorPoint(cc.p(0,0))
    self:addChild(bng)

    local func = function ()
		self:setUpView(param)
	end
	self:getData(func)
end 

function DuiHuanMainView:getData(func)
	local init = function (data)
		self._data = data.list
		self._start = data["start"]
		self._end = data["end"]
		self._now = data["now"]

		func()
	end
	RequestHelper.exchangeSystem.getExchangeList({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end 
                })
end

function DuiHuanMainView:refresh(func,id)
	local init = function (data)
		func(data)
	end
	RequestHelper.exchangeSystem.refresh({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                id = id
                })
end

function DuiHuanMainView:exchange(func,id)
	local init = function (data)
		if data.checkBag and #data.checkBag > 0 then
        	local layer = require("utility.LackBagSpaceLayer").new({
                bagObj = data.checkBag,
            })
            self:addChild(layer, 10)
        else
        	func(data)
        end
		
	end
	RequestHelper.exchangeSystem.exchange({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                id = id
                })
end

function DuiHuanMainView:load()
	display.addSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")  
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
end

function DuiHuanMainView:release()
	display.removeSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png") 
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")   
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")  
	display.removeSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
end

return DuiHuanMainView


