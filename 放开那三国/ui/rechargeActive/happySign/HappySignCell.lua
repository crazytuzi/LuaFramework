-- FileName: HappySignCell.lua 
-- Author: shengyixian
-- Date: 15-9-25
-- Purpose: 欢乐签到表单元

module("HappySignCell",package.seeall)
require "script/ui/rechargeActive/happySign/HappySignData"

local _cell = nil
local _tableView = nil
-- 当前是第几天的奖励
local _curDay = nil
local _touchPriority = -345
local _currData = nil
-- 向上的箭头
local _upArrowSp = nil
-- 向下的箭头
local _downArrowSp = nil
-- 奖励背景
local _rewardBg = nil
-- 当前奖励的数据
local _curRewardData = nil
-- 当前奖励的个数
local _curRewardNum = nil
-- 当前正在显示第几个奖励
local _curRewardIndex = nil
-- 当前被选择的领取按钮
local _currReceiveBtn = nil
-- 当前被选择的领取按钮对应的receive_alreadySp
local _currReceiveSp = nil
local _receiveBtn     = nil
local _receiveBtn1    = nil
function init( ... )
	-- body
	_cell = nil
	_curDay = nil
	_tableView = nil
	_upArrowSp = nil
	_downArrowSp = nil
	_rewardBg = nil
	_curRewardData = nil
	_curRewardNum = nil
	_curRewardIndex = 0
	_currReceiveBtn = nil
	_currReceiveSp = nil
	_receiveBtn = nil
	_receiveBtn1  = nil
end
--[[
	@des 	: 初始化界面
	@param 	: 
	@return : 
--]]
function initView()
	-- cell 的背景
	local size = _cell:getContentSize()
	local bg = CCScale9Sprite:create(g_pathCommonImage .. "bg/change_bg.png")
	bg:setContentSize(CCSizeMake(610,200))
	_cell:addChild(bg)
	-- 标题背景
    local titleBg = CCScale9Sprite:create("images/sign/sign_bottom.png")
    titleBg:setContentSize(CCSizeMake(270,60))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,bg:getContentSize().height))
    bg:addChild(titleBg)
    local titleBgSize = titleBg:getContentSize()
    -- 标题文本
    local  titleLabel = CCRenderLabel:create(_currData.des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(titleBgSize.width / 2,titleBgSize.height / 2)
    titleBg:addChild(titleLabel)
    _rewardBg = CCScale9Sprite:create(g_pathCommonImage .. "bg/goods_bg.png")
	_rewardBg:setContentSize(CCSizeMake(447,130))
	_rewardBg:setAnchorPoint(ccp(0,1))
	_rewardBg:setPosition(ccp(10,138))
	bg:addChild(_rewardBg)
	local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
	receive_alreadySp:setPosition(ccp(bg:getContentSize().width*0.76,bg:getContentSize().height*72/182))
	receive_alreadySp:setAnchorPoint(ccp(0,0))
	receive_alreadySp:setVisible(false)
	bg:addChild(receive_alreadySp,0,4)
	local tSignDays = HappySignData.getHadSignIdArr()
	print("tSignDays~~~~")
	print_t(tSignDays)
	
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		menu:setTouchPriority(_touchPriority - 1)
		bg:addChild(menu)
		local normalReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_n.png")
		local btnSize = normalReceiveSprite:getContentSize()
		local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2877"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		normalLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		normalLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		normalLabel:setAnchorPoint(ccp(0.5,0.5))
		normalReceiveSprite:addChild(normalLabel,0,101)
		-- selectedSprite,
		local selectReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_h.png")
		local selectLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2877"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		selectLabel:setColor(ccc3(0xfe,0xdb,0x1c))
		selectLabel:setAnchorPoint(ccp(0.5,0.5))
		selectLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		selectReceiveSprite:addChild(selectLabel,0,101)
		-- disable Sprite
		local disabledReceiveSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
		local disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2877"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		disabledLabel:setColor(ccc3(0xab,0xab,0xab))
		disabledLabel:setAnchorPoint(ccp(0.5,0.5))
		disabledLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		disabledReceiveSprite:addChild(disabledLabel,0,101)
		_receiveBtn = CCMenuItemSprite:create(normalReceiveSprite,selectReceiveSprite, disabledReceiveSprite)
		_receiveBtn:setAnchorPoint(ccp(1,0.5))
		_receiveBtn:setPosition(ccp(590,bg:getContentSize().height*0.5))
	local todayNum = HappySignData.getTodayNum()
	--先获取应经领取奖励的信息，若还没有已经领取的奖励
	if not(tSignDays[_curDay]) then
		--判断id等于今天登陆天数的,显示为可以签到,判断id大于今天登陆天数的,显示为灰色签到
		print("todayNum~~",todayNum)
		print("_curDay~~",_curDay)
		if todayNum <= _curDay then
		-- 按钮
		if todayNum < _curDay then
			_receiveBtn:setEnabled(false)
		end
		_receiveBtn:registerScriptTapHandler(function ( tag,item )
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
			-- 活动是否已经结束
			if (getTimeIsOver()) then
				AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
				return
			end
			-- body
			-- 检查背包是否已满
			if (ItemUtil.isBagFull()) then
				return
			end
			_currReceiveBtn = item
			_currReceiveSp = receive_alreadySp
			local isSelected = HappySignData.getIsSelectedByID(tag)
			if isSelected then
				local rewardData = HappySignData.getRewardInfoById(tag).reward
				-- 进入单选
				require "script/ui/bag/UseGiftLayer"
				UseGiftLayer.showTipLayer(nil,rewardData,function ( rewardId )
					-- body
					-- 活动是否已经结束
					if (getTimeIsOver()) then
						AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
						return
					end
					HappySignController.receive(tag,rewardId)
				end)
			else
				HappySignController.receive(tag)
			end
		end)
		menu:addChild(_receiveBtn,0,_curDay)
		
	else
		--再判断id小于今天登陆天数的,显示为补签
		-- 按钮
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		menu:setTouchPriority(_touchPriority - 1)
		bg:addChild(menu)
		local normalReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_n.png")
		local btnSize = normalReceiveSprite:getContentSize()
		local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_057"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		normalLabel:setColor(ccc3(0xf1,0xf1,0xf1))
		normalLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		normalLabel:setAnchorPoint(ccp(0.5,0.5))
		normalReceiveSprite:addChild(normalLabel,0,101)
		-- selectedSprite,
		local selectReceiveSprite = CCScale9Sprite:create("images/level_reward/receive_btn_h.png")
		local selectLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_057"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		selectLabel:setColor(ccc3(0xf1,0xf1,0xf1))
		selectLabel:setAnchorPoint(ccp(0.5,0.5))
		selectLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		selectReceiveSprite:addChild(selectLabel,0,101)
		-- disable Sprite
		local disabledReceiveSprite = BTGraySprite:create("images/level_reward/receive_btn_n.png")
		local disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_057"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
		disabledLabel:setColor(ccc3(0xab,0xab,0xab))
		disabledLabel:setAnchorPoint(ccp(0.5,0.5))
		disabledLabel:setPosition(ccp(btnSize.width/2,btnSize.height/2))
		disabledReceiveSprite:addChild(disabledLabel,0,101)
		_receiveBtn1 = CCMenuItemSprite:create(normalReceiveSprite,selectReceiveSprite, disabledReceiveSprite)
		_receiveBtn1:setAnchorPoint(ccp(1,0.5))
		_receiveBtn1:setPosition(ccp(590,bg:getContentSize().height*0.5))
		_receiveBtn1:registerScriptTapHandler(function ( tag,item )
		
        local function callBack( ... )
        	local todayNum = HappySignData.getTodayNum()
			-- 金币是否充足
    		local goldCost =tonumber(_currData.cost)
    		print("goldCost~~~",goldCost)
    		if goldCost > UserModel.getGoldNumber() then
       		AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
       	 		return
    		end
    		-- 活动是否已经结束
			local getTimeIsOver = HappySignCell.getTimeIsOver()
			if getTimeIsOver then
				AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
				return
			end
			-- body
			-- 检查背包是否已满
			if (ItemUtil.isBagFull()) then
				return
			end
			_currReceiveBtn = item
			_currReceiveSp = receive_alreadySp
			local isSelected = HappySignData.getIsSelectedByID(tag)

			if isSelected then
				local rewardData = HappySignData.getRewardInfoById(tag).reward
				-- 进入单选
				require "script/ui/bag/UseGiftLayer"
				UseGiftLayer.showTipLayer(nil,rewardData,function ( rewardId )
					-- body
					-- 活动是否已经结束
					if getTimeIsOver then
						AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
						return
					end
					HappySignController.receive(tag,rewardId,goldCost)
				end)
			else
				HappySignController.receive(tag,nil,goldCost)
			end
        end

        local goldCost =tonumber(_currData.cost)
			-- 提示
        local richInfo = {
            elements = {
                
                {
                    text = goldCost
                },
                {
                	["type"] = "CCSprite",
                	image = "images/common/gold.png"
           		 }
            }
        }
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_058"), richInfo)  
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            
            callBack()
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil)


			
		end)
		menu:addChild(_receiveBtn1,0,_curDay)
	end	
	else
		--显示已领取
		receive_alreadySp:setVisible(true)
	end
	

	createInnerScrollView()
	-- 向左的箭头
	_upArrowSp = CCSprite:create("images/common/arrow_left.png")
	_upArrowSp:setPosition(0, _rewardBg:getContentSize().height / 2)
	_upArrowSp:setAnchorPoint(ccp(0,0.5))
	_rewardBg:addChild(_upArrowSp,1, 101)
	-- _upArrowSp:setVisible(false)
	_upArrowSp:setVisible(true)
	-- 向右的箭头
	_downArrowSp = CCSprite:create( "images/common/arrow_right.png")
	_downArrowSp:setPosition(_rewardBg:getContentSize().width, _rewardBg:getContentSize().height / 2)
	_downArrowSp:setAnchorPoint(ccp(1,0.5))
	_rewardBg:addChild(_downArrowSp,1, 102)
	_downArrowSp:setVisible(true)

	arrowAction(_downArrowSp)
	arrowAction(_upArrowSp)
end
--[[
	@des 	: 箭头的动画
	@param 	: 
	@return : 
--]]
function arrowAction( arrow)
	local arrActions_2 = CCArray:create()
	arrActions_2:addObject(CCFadeOut:create(1))
	arrActions_2:addObject(CCFadeIn:create(1))
	local sequence_2 = CCSequence:create(arrActions_2)
	local action_2 = CCRepeatForever:create(sequence_2)
	arrow:runAction(action_2)
end
--[[
	@des 	: 创建内部表视图
	@param 	: 
	@return : 
--]]
function createInnerScrollView( ... )
	-- body
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
			local tag = t:getTag()
			if (tag ~= -1) then
				_curDay = t:getTag()
			end
			local isSelected = HappySignData.getIsSelectedByID(_curDay)
			_curRewardData = HappySignData.getRewardById(_curDay)
			_curRewardNum = table.count(_curRewardData)
			local ret
			if fn == "cellSize" then
				ret = CCSizeMake(150,130)
			elseif fn == "cellAtIndex" then
				ret = createInnerCell(a1 + 1,isSelected)
			elseif fn == "numberOfCells" then
				ret = _curRewardNum
			elseif fn == "cellTouched" then
			end
			return ret
		end
	)
	_tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(430,130))
	_tableView:setTouchPriority(_touchPriority - 1)
	_tableView:setBounceable(true)
	_tableView:setDirection(kCCScrollViewDirectionHorizontal)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(8,-10))
	_rewardBg:addChild(_tableView,1,_curDay)
end
--[[
	@des 	: 创建表单元
	@param 	: 
	@return : 
--]]
function create(id)
	init()
	_curDay = id
	_currData = HappySignData.getRewardInfoById(_curDay)
	print("_currData~~~~")
	print_t(_currData)
	_cell = CCTableViewCell:create()
	initView()
	return _cell
end

function createInnerCell(i,isSelected)
	-- body
	local rewardData = _curRewardData[i]
	local cell = CCTableViewCell:create()
	--商品图标
	local itemInfo = ItemUtil.getItemsDataByStr(rewardData)[1]
	local icon = ItemUtil.createGoodsIcon(itemInfo,_touchPriority - 1,1234,-555,nil,nil,false)
	icon:setAnchorPoint(ccp(0.5,0.5))
	icon:setPosition(ccp(75,85))
	cell:addChild(icon)
	if isSelected and i < _curRewardNum then
		local orSp = CCSprite:create("images/recharge/or.png")
		orSp:setAnchorPoint(ccp(0.5,0.5))
		orSp:setPosition(ccp(150,85))
		cell:addChild(orSp)
	end
	return cell
end

function reveiveCallBack( ... )
	-- body
	_currReceiveBtn:removeFromParentAndCleanup(true)
	_currReceiveSp:setVisible(true)
	-- _currReceiveSp:setVisible(false)
end

function getTimeIsOver( ... )
	-- body
	local currTime = TimeUtil.getSvrTimeByOffset()
	local endTime = HappySignData.getEndTime()
	return currTime >= endTime
end

--补签的回调
function repairButtonCallback( tag,item )
	-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
			
	 -- 提示
         local cost = tonumber(_currData.cost)
        local richInfo = {
            elements = {
                
                {
                    text = cost
                }
            }
        }
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_058"), richInfo)  
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            repair(tag,item)
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --字是“确定”

end
--补签
function repair(tag,item)
	local todayNum = HappySignData.getTodayNum()
	-- 金币是否充足
    local goldCost =tonumber(_currData.cost)
    print("goldCost~~~",goldCost)
    if goldCost > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        return
    end
	-- 活动是否已经结束
	local getTimeIsOver = HappySignCell.getTimeIsOver()
			if getTimeIsOver then
				AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
				return
			end
			-- body
			-- 检查背包是否已满
			if (ItemUtil.isBagFull()) then
				return
			end
			_currReceiveBtn = item
			_currReceiveSp = _receive_alreadySp
			local isSelected = HappySignData.getIsSelectedByID(tag)
			if isSelected then
				local rewardData = HappySignData.getRewardInfoById(tag).reward
				-- 进入单选
				require "script/ui/bag/UseGiftLayer"
				UseGiftLayer.showTipLayer(nil,rewardData,function ( rewardId )
					-- body
					-- 活动是否已经结束
					if getTimeIsOver then
						AnimationTip.showTip(GetLocalizeStringBy("key_1925"))
						return
					end
					HappySignController.receive(tag,rewardId,goldCost)
				end)
			else
				HappySignController.receive(tag,nil,goldCost)
			end
end
