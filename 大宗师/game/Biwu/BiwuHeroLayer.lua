--
-- Author: Daneil
-- Date: 2015-01-15 18:01:08
--
local DialyTimes = 20
local ReFreshBtnRes = {
    normal   =  "#refresh_n.png",
    pressed  =  "#refresh_p.png",
    disabled =  "#refresh_p.png"
}
local TAG = { 
	TAG_HERO_NAME     = 10,
	TAG_HERO_LEVEL    = 20,
	TAG_HERO_DIS      = 30,
	TAG_HERO_HERO     = 40,
	TAG_LABEL_COUNT   = 50,
	TAG_HERO_BNG   = 60,
	TAG_HERO_BNG_LABEL   = 70,


}


local BiwuHeroLayer = class("BiwuHeroLayer", function()
    return display.newLayer("BiwuHeroLayer")
end)

function BiwuHeroLayer:ctor(param)
    self:setContentSize(param.size)
	--设置背景
	--以0.7为基准进行屏幕适配
    local bng = CCSprite:create("bg/biwu_bg.jpg",CCRectMake(0,0,display.width,display.width / 0.77))
    bng:setScaleY((param.size.height/ display.width) * 0.77)
    self:addChild(bng)
	bng:setAnchorPoint(cc.p(0,0))  	

	--服务器获取数据
	self:_getData()
	self._scheduler = require("framework.scheduler")
end

function BiwuHeroLayer:setUpLabelView()
	
	local res = { 
		{ icon = "#naili.png" , text = "38/38" , font = FONTS_NAME.font_fzcy },
		{ icon = "#times.png" , text = "12/38" , font = FONTS_NAME.font_fzcy },
		{ icon = "#jifen.png" , text = "311" , font = FONTS_NAME.font_fzcy},
		{ icon = "#paiming.png", text = "312" , font = FONTS_NAME.font_fzcy },
	}

	local function createAddBtn(node)
		--购买耐力按钮
		local buyBtn = display.newSprite("#add.png")
		buyBtn:setPosition(cc.p(node:getContentSize().width - 20,node:getContentSize().height/2))
		buyBtn:setAnchorPoint(cc.p(0.5,0.5))
		buyBtn:setTouchEnabled(true)
	    node:addChild(buyBtn,10)
	    buyBtn:setTouchEnabled(true)

	    addTouchListener(buyBtn, function (sender,eventType)
	    	if eventType == EventType.began then
	    		sender:setScale(0.9)
	    	elseif eventType == EventType.ended then
	    		sender:setScale(1.0)
	    		buyBtn:setScale(1)
            if self._isWeekDay then
            	show_tip_label("非比武时间不能购买挑战次数")
            	return 
            end
            if self.dataCenter.role.buynum == 0 then
            	show_tip_label("您的剩余购买次数为0")
            	return
            end
            if self.dataCenter.role.cishu ~= 0 then
            	--show_tip_label("你有可用的剩余次数，暂不能购买")
            	--return
            end
            local fuc = function (num,cost)
            	RequestHelper.biwuSystem.addChallengeTimes({
                callback = function(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        self.labelObj[2]:getChildByTag(TAG.TAG_LABEL_COUNT):setString(data.rtnObj.times.."/20")
                        game.player:setGold(data.rtnObj.gold)
                        self.dataCenter.role.cishu = self.dataCenter.role.cishu + num
                        self.dataCenter.role.buynum = self.dataCenter.role.buynum - num
                        PostNotice(NoticeKey.CommonUpdate_Label_Gold)
                        PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                    end
                end,
                times = num
                })
            end
			local param = { 
				 addPrice  = 0,
				 baseprice = self.dataCenter.role.cost,
				 coinType  = 1,
				 desc      = "使用后可获得10000银币。",
			     hadBuy    = 0,
			     havenum   = 1,
			     icon      = "yidaiyinbi",
			     id        = 1,
			     itemId    = 4302,
			     maxN      = self.dataCenter.role.buynum,
			     maxnum    = self.dataCenter.role.buynum,
			     name      = "比武次数",
			     price     = self.dataCenter.role.cost,
			     remainnum = self.dataCenter.role.buynum,
			}
			
			CCDirector:sharedDirector():getRunningScene():addChild(require("game.Biwu.BiwuByTimesCountBox").new(
	    			param,
	    			fuc
	    	),100000)
			elseif eventType == EventType.cancel then
	    		sender:setScale(1.0)
	    	end
    	end)
	end

	self.labelObj = {}

	--玩家基础数据
	local baseData = { 
		self.dataCenter.role.naili,
		self.dataCenter.role.cishu,
		self.dataCenter.role.jifen,
		self.dataCenter.role.paiming,
	}

	for k,v in pairs(res) do
		local labelNode = self:creatDislabel(v.icon,v.text,v.font)
		labelNode:setPosition(cc.p(0,self:getContentSize().height - 40 * (k - 1) - 15))
		labelNode:setAnchorPoint(cc.p(0,1))
		if k == 2 then
			createAddBtn(labelNode)
		end
		self:addChild(labelNode)
		local text = baseData[k]
		if k == 1 then
			text = baseData[k].."/"..game.player.m_maxEnergy
		end

		if k == 2 then
			text = baseData[k].."/20"
		end
		labelNode:getChildByTag(TAG.TAG_LABEL_COUNT):setString(text)
		self.labelObj[k] = labelNode
	end


	--底部刷新按钮
    self.refreshBtn = display.newSprite(ReFreshBtnRes.normal)  
    self.refreshBtn:setPosition(cc.p(self:getContentSize().width/2 , self:getContentSize().height * 0.2))  
    self:addChild(self.refreshBtn)
    addTouchListener(self.refreshBtn, function (sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		if game.player._biwuCollTime ~= 0 then
    			show_tip_label("下次刷新时间未到，不能刷新对手。") 
    			return 
    		end
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
        	self:_getRefreshData()
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    --底部倒计时label
    local titleLabel = ui.newTTFLabelWithShadow({  text = "下次刷新", 
											size = 22, 
											color = FONT_COLOR.WHITE,
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })

    --底部倒计时label
    self.countDownLabel = ui.newTTFLabelWithShadow({  text = "00:00:00", 
											size = 22, 
											color = ccc3(0,219,52),
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy })
   	if self._isWeekDay then
   		self.countDownLabel:setVisible(false)
   		titleLabel:setVisible(false)
   		self.refreshBtn:setVisible(false)
   	else
   		self.countDownLabel:setVisible(true)
   		titleLabel:setVisible(true)
   		self.refreshBtn:setVisible(true)
   	end

    --奖励预览按钮
    local jiangliBnt = display.newSprite("#wj_extraReward_btn.png")
    jiangliBnt:setPosition(display.width * 0.9,self:getContentSize().height * 0.9)
    self:addChild(jiangliBnt)


    addTouchListener(jiangliBnt, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
        		CCDirector:sharedDirector():getRunningScene():addChild(require ("game.Biwu.BiwuGiftPrePopup").new(self.dataCenter.role.paiming),1222222,10000000)
        	end
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


    titleLabel:setPosition(cc.p(display.width * 0.35,display.height * 0.06))
    self.countDownLabel:setPosition(cc.p(display.width * 0.5,display.height * 0.06))
    self:addChild(titleLabel)
    self:addChild(self.countDownLabel)


    if self._isWeekDay then
    	--self.refreshBtn:setButtonEnabled(false)
    end


    RegNotice(self,
        function()
            self.labelObj[1]:getChildByTag(TAG.TAG_LABEL_COUNT):setString(game.player.m_energy.."/"..game.player.m_maxEnergy)
        end,
        NoticeKey.BIWu_update_naili)

end

function BiwuHeroLayer:setUpHeroView( ... )
	local pos02 = cc.p(display.width * 0.16 , display.height * 0.10)
	local pos03 = cc.p(display.width * 0.84 , display.height * 0.10)
	local pos01 = cc.p(display.width * 0.5 , display.height * 0.24)
	
	

	self._hero01 = self:createHeros(pos01,1)
	self._hero02 = self:createHeros(pos02,2)
	self._hero03 = self:createHeros(pos03,3)

	self:refreshHeros()
end

--创建左侧label
function BiwuHeroLayer:creatDislabel(titleicon,count,fontType)
	local disBng  = display.newSprite("#labebng.png")
	local disIcon = display.newSprite(titleicon)
	disIcon:setPosition(cc.p(disBng:getContentSize().width * 0.2, disBng:getContentSize().height / 2))
	disBng:addChild(disIcon)

	local countLabel = ui.newTTFLabel({text = count, 
												color = FONT_COLOR.YELLOW,
												size = self._titleDisFontSize, 
										        align= ui.TEXT_ALIGN_LEFT,
										        shadowColor = ccc3(0,0,0),
										        font = fontType })
	countLabel:setAnchorPoint(cc.p(0,0.5))
	countLabel:setPosition(cc.p(disBng:getContentSize().width * 0.4, disBng:getContentSize().height / 2))
	disBng:addChild(countLabel,0,TAG.TAG_LABEL_COUNT)
	return disBng
end

function BiwuHeroLayer:createHeros(pos,index)
	self.nameBng = display.newSprite("#hero_label_bng.png")
	local dizuoBng = display.newNode()


	local disLabel   = ui.newTTFLabelWithOutline({  text = "", 
											size = 24,
											color = FONT_COLOR.YELLOW,
									        align= ui.TEXT_ALIGN_CENTE,
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy})
	local levelLabel = ui.newTTFLabelWithShadow({  text = "", 
											size = 22, 
											color = FONT_COLOR.WHITE,
											shadowColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy })
	local nameLabel  = ui.newTTFLabelWithShadow({  text = "", 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.YELLOW,
									        shadowColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local fationLabel  = ui.newTTFLabelWithShadow({  text = "", 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        shadowColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })

	disLabel:setPosition(cc.p(dizuoBng:getContentSize().width/2 - disLabel:getContentSize().width / 2,dizuoBng:getPositionY() + 330))
	levelLabel:setPosition(cc.p(dizuoBng:getContentSize().width/2 - levelLabel:getContentSize().width / 2, dizuoBng:getPositionY() + 50))
	nameLabel:setPosition(cc.p(dizuoBng:getContentSize().width/2 - nameLabel:getContentSize().width / 2, dizuoBng:getPositionY() + 25))
	fationLabel:setPosition(cc.p(dizuoBng:getContentSize().width/2 - fationLabel:getContentSize().width / 2, dizuoBng:getPositionY()))
	fationLabel:setVisible(true)
	local hero  = display.newSprite("hero/large/banshuxian.png")
	
	hero:setPosition(cc.p(dizuoBng:getContentSize().width/2,dizuoBng:getPositionY() + 200))
	hero:setScale(0.6)
	dizuoBng:addChild(disLabel,1,  TAG.TAG_HERO_DIS)
	dizuoBng:addChild(levelLabel,1,TAG.TAG_HERO_LEVEL)
	dizuoBng:addChild(nameLabel,1,TAG.TAG_HERO_NAME)
	dizuoBng:addChild(hero,-1,TAG.TAG_HERO_HERO)
	dizuoBng:addChild(fationLabel,1,TAG.TAG_HERO_BNG_LABEL)
	dizuoBng:addChild(self.nameBng,0,TAG.TAG_HERO_BNG)

	dizuoBng:setPosition(pos)
	self:addChild(dizuoBng)

	self.nameBng:setPositionY(self.nameBng:getPositionY() + 25)
	if (display.width / display.height) >= (768 / 1024) then
		dizuoBng:setScale(0.77)
	else
		dizuoBng:setScale(0.9)
	end
	addTouchListener(hero,function(sender,event)
		print(event)
		if event == EventType.began then
			sender:setScale(0.63)
		elseif event == EventType.ended then
			sender:setScale(0.6)
			if self._isWeekDay then
				local layer = require("game.form.EnemyFormLayer").new(1,self.dataCenter.enemy[index].acc)
		        layer:setPosition(0, 0)
		        CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000000)
			else
				if self.dataCenter.role.cishu == 0 then
	            	show_tip_label("您的今日挑战次数为0")
	            	return
            	end
            	self["fightFuc"..index]()
            end
		elseif event == EventType.cancel then
			sender:setScale(0.6)
		end
	end)
	return dizuoBng
end

function BiwuHeroLayer:refreshHeros()
	
	for i = 1,3 do
		self:refreshHeroByPos(i,self.dataCenter.enemy[i])
	end
	--判断是否开启倒计时
    if game.player._biwuCollTime > 0 then
    	self:countDownLogic()
    end
end

function BiwuHeroLayer:refreshHeroByPos(pos,data)
	local level = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_LEVEL)
	local name  = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_NAME)
	local icon  = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_HERO)
	local dis  = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_DIS)
	local bng  = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_BNG)
	local fation  = self["_hero0"..pos]:getChildByTag(TAG.TAG_HERO_BNG_LABEL)

	if data == nil then
		dis:setString("")
		level:setString("")
		name:setString("")
		icon:setVisible(false)
		return
	end
	icon:setVisible(true)
	

	level:setString("LV:"..data.level)
	name:setString(data.name)
	local _levelDis 
	if not self._isWeekDay then
		_levelDis = { 
						{ dis = "可获得\n少量积分", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.GREEN},
						{ dis = "可获得\n一般积分", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.BLUE},
						{ dis = "可获得\n极高积分", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.YELLOW}
					}
	else
		_levelDis = { 
						{ dis = "天榜第一名", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.YELLOW},
						{ dis = "天榜第二名", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.BLUE},
						{ dis = "天榜第三名", font = "fonts/font_yellow_brown_num.fnt",color = FONT_COLOR.GREEN}
					}
	end
	dis:setString(_levelDis[data.quality].dis)
	dis:setColor(_levelDis[data.quality].color)
	if data.faction ~= "" then
		bng:setScaleY(1.7)
		if not fation:isVisible() then
			bng:setPositionY(level:getPositionY() - 26)
		end
		fation:setVisible(true)
		fation:setString("【"..data.faction.."】")
	else
		bng:setScaleY(1)
		bng:setPositionY(level:getPositionY() - 13)
		fation:setVisible(false)
	end

	local data_card_card = require("data.data_card_card")
	local iconPath = data_card_card[data.leadId]["arr_body"][data.cls + 1]
	icon:setDisplayFrame(display.newSprite("hero/large/"..iconPath..".png"):getDisplayFrame())
	self["fightFuc"..pos] = function ()
		BiwuController.sendFightData(BiwuConst.BIWU,data.roleId,TabIndex.BIWU)
	end
end

function BiwuHeroLayer:countDownLogic( ... )
	if self.dataCenter.colltime == 0 then
		self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.normal):getDisplayFrame())
	else
		self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.pressed):getDisplayFrame())
	end
	
    local countDown = function()
			if game.player._biwuCollTime ~= 0 then
				self.countDownLabel:setString(format_time(game.player._biwuCollTime))
			else
				self.refreshBtn:setDisplayFrame(display.newSprite(ReFreshBtnRes.normal):getDisplayFrame())
				self._scheduler.unscheduleGlobal(self._schedule)
				self.countDownLabel:setString(format_time(game.player._biwuCollTime))
			end
		end

	self._schedule = self._scheduler.scheduleGlobal(countDown, 1, false )	
end

function BiwuHeroLayer:remove()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	UnRegNotice(self, NoticeKey.BIWu_update_naili)
	self:removeFromParent()
end

--获得基础数据
function BiwuHeroLayer:_getData()
	local function initData(data)
		self.dataCenter = {}
		self.dataCenter.role = {}
		self.dataCenter.role.naili = data.resisVal
		self.dataCenter.role.cishu = data.challengeTimes
		self.dataCenter.role.paiming = data.rank
		self.dataCenter.role.jifen = data.score
		self.dataCenter.role.buynum = data.buy_num
		self.dataCenter.role.cost = data.cost
		if data.rank == 0 then
			self.dataCenter.role.paiming = "无"
		else
			self.dataCenter.role.paiming = data.rank
		end
		if #data.top3 == 0 then
			self.dataCenter.enemy = data.opponents
			self._isWeekDay = false
		else
			self.dataCenter.enemy = data.top3
			self._isWeekDay = true
		end
		self.dataCenter.colltime = (data.nextFleshTime / 1000 - os.time() + GameModel.deltaTime) 

		self:setUpLabelView()
		self:setUpHeroView()
	end
	RequestHelper.biwuSystem.getBaseInfo({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

--请求服务器刷新三组敌人
function BiwuHeroLayer:_getRefreshData( ... )

	local function initEnemy(data)
		self.dataCenter.enemy = data.opponents
		--重置冷却时间
		game.player._biwuCollTime = 10
	end

	RequestHelper.biwuSystem.getRefreshHero({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initEnemy(data.rtnObj)
                        self:refreshHeros()
                    end
                end 
                })
end




return BiwuHeroLayer
    
    


