--[[
 --
 -- add by vicky
 -- 2014.10.16
 --
 --]]

 local STATE_TYPE = {
 	normal = 1, 	-- 不可领取
 	canGet = 2, 	-- 可领取
 	hasGet = 3, 	-- 不可领取 
 }

 local MAX_ZORDER = 100

 local SubmapRewardLayer = class("SubmapRewardLayer", function() 
 		return require("utility.ShadeLayer").new()
 	end)

function SubmapRewardLayer:onEnter()

    TutoMgr.addBtn("guankajiangli_lingqu",self._rootnode["rewardBtn"])
    TutoMgr.active()
end

function SubmapRewardLayer:onExit()
    if self.closeListener ~= nil then 
        self.closeListener() 
    end 

    TutoMgr.removeBtn("guankajiangli_lingqu")
end


 function SubmapRewardLayer:ctor(param) 
    self:setNodeEventEnabled(true)
 	local needStar = param.needStar 
 	local state = param.state 
 	self._itemData = param.itemData 
 	self._id = param.id 
 	self._updateListener = param.updateListener 	-- 上个界面更新宝箱状态 
 	self._bagObj = param.bagState 
 	self._hard = param.hard 
 	self._isFull = false 
    if #self._bagObj > 0 then 
        self._isFull = true 
    end

    self.closeListener = param.closeListener

 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("fuben/sub_map_reward_layer.ccbi", proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2) 
 	self:addChild(node) 

 	self._rootnode["titleLabel"]:setString("星级奖励")

 	self._rootnode["msg_1"]:setColor(ccc3(99, 47, 8)) 
 	self._rootnode["msg_2"]:setColor(ccc3(99, 47, 8)) 
 	local starIcon = self._rootnode["star_icon"] 
 	local starNumLbl = self._rootnode["star_num_lbl"] 
 	starNumLbl:setString(tostring(needStar)) 
 	self._rootnode["msg_1"]:setPositionX(starIcon:getPositionX() - starNumLbl:getContentSize().width) 

 	local rewardBtn = self._rootnode["rewardBtn"] 
 	rewardBtn:addHandleOfControlEvent(function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
            rewardBtn:setEnabled(false) 
 			self:getReward() 
 		end, CCControlEventTouchUpInside) 

 	self._rootnode["tag_close"]:addHandleOfControlEvent(function() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        self:removeFromParentAndCleanup(true) 
    end, CCControlEventTouchUpInside)


 	-- 根据是否可领取状态，改按钮状态
 	local hasNode = self._rootnode["tag_has_get"] 

 	if state == STATE_TYPE.normal then 
 		rewardBtn:setVisible(true)
		rewardBtn:setEnabled(false)
		hasNode:setVisible(false) 
	elseif state == STATE_TYPE.canGet then 
		rewardBtn:setVisible(true)
		rewardBtn:setEnabled(true)
		hasNode:setVisible(false) 
	elseif state == STATE_TYPE.hasGet then 
		rewardBtn:setVisible(false)
		hasNode:setVisible(true) 
	end 

	self:refreshItem() 

 end 


 -- 领取奖励  
 function SubmapRewardLayer:getReward() 
    local function extendBag(data)
        -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size 
        if self._bagObj[1].curCnt < data["1"] then 
            table.remove(self._bagObj, 1)
        else
            self._bagObj[1].cost = data["4"]
            self._bagObj[1].size = data["5"]
        end

        if #self._bagObj > 0 then 
            self:addChild(require("utility.LackBagSpaceLayer").new({
                bagObj = self._bagObj, 
                callback = function(data)
                    extendBag(data)
                end}), MAX_ZORDER)
        else 
            self._isFull = false 
            self._rootnode["rewardBtn"]:setEnabled(true) 
        end
    end

    -- 判断背包是否已满
    if self._isFull then 
        self:addChild(require("utility.LackBagSpaceLayer").new({
            bagObj = self._bagObj, 
            callback = function(data) 
                extendBag(data)
            end
            }), MAX_ZORDER)
    else 
        -- ResMgr.createTutoMask()
        RequestHelper.getBattleReward({
            id = self._id, 
            t = self._hard, 
            callback = function(data)
                dump(data)
                if (data["0"] ~= "") then 
                    dump(data["0"]) 
                else 
                    ResMgr.removeMaskLayer()
                	self._rootnode["rewardBtn"]:setVisible(false)
                	self._rootnode["tag_has_get"]:setVisible(true)

                	-- 领取奖励之后，重新请求更新本关卡的内容
                    if self._updateListener ~= nil then
                        self._updateListener(self._hard) 
                    end 
                    
                    -- 弹出得到奖励提示框 
                    local title = "恭喜您获得如下奖励：" 
                    local msgBox = require("game.Huodong.RewardMsgBox").new({
                        title = title, 
                        cellDatas = self._itemData 
                        })

                    game.runningScene:addChild(msgBox, self:getZOrder())

                    self:removeFromParentAndCleanup(true) 
                end
            end
            })
    end 
 end


 function SubmapRewardLayer:refreshItem()
 	for i, v in ipairs(self._itemData) do 
		local reward = self._rootnode["reward_" ..tostring(i)]
		reward:setVisible(true)

		-- 图标
		local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)] 
        ResMgr.refreshIcon({
            id = v.id, 
            resType = v.iconType, 
            itemBg = rewardIcon, 
            iconNum = v.num, 
            isShowIconNum = false, 
            numLblSize = 22, 
            numLblColor = ccc3(0, 255, 0), 
            numLblOutColor = ccc3(0, 0, 0) 
        })

		-- 属性图标
		local canhunIcon = self._rootnode["reward_canhun_" .. i]
		local suipianIcon = self._rootnode["reward_suipian_" .. i]
		canhunIcon:setVisible(false)
		suipianIcon:setVisible(false)
		if v.type == 3 then
			-- 装备碎片
			suipianIcon:setVisible(true) 
		elseif v.type == 5 then 
			-- 残魂(武将碎片)
			canhunIcon:setVisible(true) 
		end

		-- 名称
		local nameKey = "reward_name_" .. tostring(i)
		local nameColor = ccc3(255, 255, 255) 
		if v.iconType == ResMgr.ITEM or v.iconType == ResMgr.EQUIP then 
			nameColor = ResMgr.getItemNameColor(v.id)
		elseif v.iconType == ResMgr.HERO then 
			nameColor = ResMgr.getHeroNameColor(v.id)
		end

		local nameLbl = ui.newTTFLabelWithShadow({
            text = v.name,
            size = 20,
            color = nameColor,
            shadowColor = ccc3(0, 0, 0), 
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
 		
 		nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2)
 		self._rootnode[nameKey]:removeAllChildren()
	    self._rootnode[nameKey]:addChild(nameLbl) 
	end

	-- 道具类型达不到4个时，剩余的道具框隐藏
	local count = #self._itemData 
	while (count < 4) do
		self._rootnode["reward_" ..tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
 end


 return SubmapRewardLayer 

