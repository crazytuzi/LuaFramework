--[[
	文件名：GuildPvpFormationLayer.lua
	描述：帮派战斗前阵容查看界面
	创建人：yanghongsheng
	创建时间： 2017.12.5
--]]

local GuildPvpFormationLayer = class("GuildPvpFormationLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		Id				对方玩家实体id(必须)
		FashionModelId 	对方时装
		Name 			对方玩家名
		Order 			对方位置序号
		FAP 			对方战力

		challengeType 	对战类型（1:挑战，0:切磋）(默认挑战)
]]

function GuildPvpFormationLayer:ctor(params)
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})
    -- 参数
    params = params or {}
    self.mOtherPlayerInfo = params
    self.mOtherPlayerId = params.Id
    self.mOtherPlayerName = params.Name
    self.mOtherFashionId = params.FashionModelId
    self.mOtherOrder = params.Order or 1
    self.mOtherFAP = params.FAP or 0
    self.mChallengeType = params.challengeType or 1

    -- 变量
    self.mOwnFormation = {}
    self.mOtherFormation = {}
    self.mChallengeNum = 0

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()

    self:requesetInfo()
end


function GuildPvpFormationLayer:initUI()
	-- 地图背景
	ui.newEffect({
			parent = self.mParentLayer,
			effectName = "ui_effect_wudang",
			animation = "xia",
			loop       = true,
			position = cc.p(320, 568),
		})
	ui.newEffect({
			parent = self.mParentLayer,
			effectName = "ui_effect_wudang",
			animation = "shang",
			loop       = true,
			position = cc.p(320, 568),
		})


	-- 帮派对战显示
	local guildBg = ui.newSprite("bpz_08.png")
	guildBg:setPosition(320, 1090)
	self.mParentLayer:addChild(guildBg)

	local guildBgSize = guildBg:getContentSize()
	-- vs图标
	local vsSprite = ui.newSprite("zdjs_07.png")
	vsSprite:setScale(0.6)
	vsSprite:setPosition(guildBgSize.width*0.5, guildBgSize.height*0.5)
	guildBg:addChild(vsSprite)
	-- 自己
	local ownOrder = 0
	for _, heroInfo in pairs(GuildObj:getGuildBattlePlayerInfo()) do
		if heroInfo.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
			ownOrder = heroInfo.Order
			break
		end
	end
	local ownOrderLabel = ui.createSpriteAndLabel({
			imgName = "bpz_28.png",
			labelStr = ownOrder,
		})
	local ownLv = PlayerAttrObj:getPlayerAttrByName("Lv")
	local ownName = PlayerAttrObj:getPlayerAttrByName("PlayerName")
	ownOrderLabel:setPosition(0, guildBgSize.height*0.5)
	guildBg:addChild(ownOrderLabel)
	local ownNameLabel = ui.newLabel({
			text = TR("等级%d  %s%s", ownLv, Enums.Color.eYellowH, ownName),
			color = Enums.Color.eWhite,
			size = 20,
		})
	ownNameLabel:setAnchorPoint(cc.p(0, 0.5))
	ownNameLabel:setPosition(30, guildBgSize.height*0.5)
	guildBg:addChild(ownNameLabel)
	-- 对方玩家
	local otherOrder, otherOrderLabel = ui.createSpriteAndLabel({
			imgName = "bpz_28.png",
			labelStr = self.mOtherOrder,
		})
	otherOrder:setPosition(guildBgSize.width, guildBgSize.height*0.5)
	guildBg:addChild(otherOrder)
	self.otherOrderLabel = otherOrderLabel
	local otherNameLabel = ui.newLabel({
			text = TR("等级%d  %s%s", self.mOtherPlayerInfo.Lv, Enums.Color.eYellowH, self.mOtherPlayerInfo.Name),
			color = Enums.Color.eWhite,
			size = 20,
		})
	otherNameLabel:setAnchorPoint(cc.p(1, 0.5))
	otherNameLabel:setPosition(guildBgSize.width-30, guildBgSize.height*0.5)
	guildBg:addChild(otherNameLabel)
	self.otherNameLabel = otherNameLabel
	-- 挑战次数
	local challengeNumLabel = ui.newLabel({
			text = TR("剩余挑战次数: 0"),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 24,
		})
	challengeNumLabel:setPosition(320, 130)
	self.mParentLayer:addChild(challengeNumLabel)
	self.challengeNumLabel = challengeNumLabel
	-- 已打过提示文字
	local hintLabel = ui.newLabel({
			text = TR("已攻打该玩家"),
			color = Enums.Color.eRed,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	hintLabel:setPosition(320, 45)
	self.mParentLayer:addChild(hintLabel)
	self.hintLabel = hintLabel
	-- 三星获得积分
	local sorce = 3*(51-self.mOtherOrder)*2
	local sorceLabel = ui.newLabel({
			text = TR("三星胜利可获得: \n积分: #d17b00%d \n#F7F5F0帮派武技: #249029%d", sorce, sorce),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	sorceLabel:setAnchorPoint(cc.p(0, 0))
	sorceLabel:setPosition(70, 980)
	self.mParentLayer:addChild(sorceLabel)
	self.sorceLabel = sorceLabel
	-- 阵容
	self:refreshCamp()

	--按钮
    local btnLayer = self:createBtnLayer()

    -- 挑战按钮
    local challengeBtn = ui.newButton({
    		normalImage = "bpz_34.png",
    		position = cc.p(100, 80),
    		clickAction = function ()
    			LayerManager.addLayer({
    					name = "guild.GuildPvpComCampLayer",
    					cleanUp = false,
    					data = {
    						titleText = TR("进攻布阵"),
    						FormationData = self.mOwnFormation,
    						recruitCallBack = function ()
    							LayerManager.addLayer({
    									name = "guild.GuildPvpRecruiteLayer",
    								})
    						end,
    						exchangeCallBack = function (formationList)
    							self:requesetFormationChang(formationList)
    						end,
    					}
    				})
    		end
    	})
    btnLayer:addChild(challengeBtn)
    self.challengeBtn = challengeBtn
end

-- 刷新两方阵容显示
function GuildPvpFormationLayer:refreshCamp()
	-- 整理数据
	local campList = {}
	for i = 1, 6 do
		if self.mOwnFormation[tostring(i)] then
			campList[i] = self.mOwnFormation[tostring(i)]
		end
		if self.mOtherFormation[tostring(i)] then
			campList[i+6] = self.mOtherFormation[tostring(i)]
		end
	end
	-- 刷新显示
	self:refreshCampShow(campList)
end

-- 创建对战两方阵容
--[[
	campList = {
		[1] = {HeroModelId = 12011404, step = 12},
		...
		[12] = {HeroModelId = 12011404, step = 19},
	}
]]
function GuildPvpFormationLayer:refreshCampShow(campList)
	-- 阵容显示层
	if not self.heroLayer then
		self.heroLayer = cc.Layer:create()
		self:addChild(self.heroLayer)
	end

	self.heroLayer:removeAllChildren()

	for posId, heroInfo in pairs(campList) do
		if heroInfo.HeroModelId ~= 0 and heroInfo.HeroModelId ~= nil then
			-- 人物父节点
			local heroNode = cc.Node:create()
			local pos = bd.interface.getStandPos(posId)
			heroNode:setPosition3D(pos)
			heroNode:setScale(Adapter.MinScale)
			heroNode:setLocalZOrder(bd.interface.getHeroZOrder(pos))
			self.heroLayer:addChild(heroNode)

			-- 幻化模型信息
			local illusionModelId = (type(heroInfo.IllusionModelId) == type(0)) and heroInfo.IllusionModelId or ConfigFunc:getIllusionModelId(heroInfo.IllusionModelId)
			local illusionInfo = IllusionModel.items[illusionModelId]
            -- 时装模型信息
            local heroFashionId = ConfigFunc:getHeroFashionModelId(heroInfo.IllusionModelId)
            local fashionInfo = HeroFashionRelation.items[heroFashionId]

			-- 人物名字
			heroInfo.heroId = heroInfo.HeroModelId
			heroInfo.idx = posId
			heroInfo.step = heroInfo.Step
			heroInfo.name = illusionInfo and illusionInfo.name or nil
			local heroNameStr = bd.interface.getHeroNodeName(heroInfo)

			-- 主角时装
			local fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId")

			local heroModel = HeroModel.items[heroInfo.HeroModelId]
			-- 如果是对方主角
			if heroModel.specialType == Enums.HeroType.eMainHero and posId >=7 and posId <= 12 then
				heroNameStr = self.mOtherPlayerName
				fashionModelID = self.mOtherFashionId
				if heroInfo.step - 15 > 0 then
					heroNameStr = heroNameStr .. "+" .. heroInfo.step - 15
				elseif heroInfo.step - 10 > 0 then
					heroNameStr = heroNameStr .. "+" .. heroInfo.step - 10
				else
					heroNameStr = heroNameStr .. "+" .. heroInfo.step
				end
			end

			-- 阴影
			local shadeSprite = ui.newSprite("ef_c_67.png")
			heroNode:addChild(shadeSprite)

			-- 创建人物名字显示
			local colorLv = Utility.getColorLvByModelId(heroInfo.HeroModelId, ResourcetypeSub.eHero)
			local heroNameLabel = ui.newLabel({
					text = heroNameStr,
					size = 22,
					outlineColor = cc.c3b(0x46, 0x22, 0x0d),
					color = Utility.getColorValue(colorLv, 1),
					align = cc.TEXT_ALIGNMENT_CENTER,
					valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
				})
			heroNode:addChild(heroNameLabel)

			-- 创建人物战力显示
			local fapBg = ui.newSprite("c_23.png")
			heroNode:addChild(fapBg)
			local fapLabel = ui.newLabel({
					text = TR("{c_127.png} %s", Utility.numberFapWithUnit(heroInfo.FAP)),
					color = Enums.Color.eWhite,
					outlineColor = cc.c3b(0x46, 0x22, 0x0d),
				})
			fapLabel:setAnchorPoint(cc.p(0, 0))
			fapLabel:setPosition(0, -10)
			fapBg:addChild(fapLabel)

			-- 创建人物突破超高15显示圣，尊
			local titleSprite = nil
			if heroInfo.step and heroInfo.step > 10 and heroInfo.step <= 15 then
				titleSprite = "zd_22.png"
			elseif heroInfo.step and heroInfo.step > 15 and heroInfo.step <= 20 then
				titleSprite = "zd_21.png"
			elseif heroInfo.step and heroInfo.step > 20 and heroInfo.step <= 25 then
	            titleSprite = "zd_23.png"
			end
			if titleSprite then
				titleSprite = ui.newSprite(titleSprite)
				titleSprite:setScale(1.5)
				titleSprite:setAnchorPoint(cc.p(0, 0))
				heroNode:addChild(titleSprite)
			end

			-- 创建人物动作
			Figure.newHero({
				heroModelID = heroInfo.HeroModelId,
				fashionModelID = fashionModelID,
				IllusionModelId = illusionModelId,
                heroFashionId = heroFashionId,
				parent = heroNode,
				scale = 0.24*(bd.patch.nodeScale or 1),
				position = cc.p(0, 0),
				async = function(figureNode)
					figureNode:setRotationSkewY(bd.ui_config.posSkew[posId] and 180 or 0)

					Utility.performWithDelay(figureNode, function()
						local boundingBox = figureNode:getBoundingBox()
						heroNameLabel:setPosition(0, boundingBox.height)

						fapBg:setPosition(0, boundingBox.height + 30)
						
						if titleSprite then
							local fapWidth = fapBg:getContentSize().width
							titleSprite:setPosition(-60-fapWidth/2, boundingBox.height - 10)
						end
					end,0.01)
                end,
			})
		end
	end

	local function createZhenshouNode(zhenshouModelId, pos, isSkewY)
		local zhenshouNode = cc.Node:create()
		zhenshouNode:setScale(Adapter.MinScale)
		zhenshouNode:setPosition(pos)
		self.heroLayer:addChild(zhenshouNode)

		-- 珍兽模型
		local zhenshouObj = Figure.newZhenshou({modelId = zhenshouModelId}) 
		zhenshouObj:setRotationSkewY(isSkewY and 180 or 0)
		zhenshouObj:setScale((bd.patch.nodeScale*0.8))
		zhenshouNode:addChild(zhenshouObj)
		-- 珍兽名字
		local zhenshenName = ui.newLabel({
				text = ZhenshouModel.items[zhenshouModelId].name,
				color = Utility.getColorValue(ZhenshouModel.items[zhenshouModelId].colorLv, 1),
				outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		zhenshouNode:addChild(zhenshenName)
		Utility.performWithDelay(zhenshouObj, function()
			local boundingBox = zhenshouObj:getBoundingBox()
			zhenshenName:setPosition(0, boundingBox.height-230)
		end,0.01)
	end
	-- 添加我方珍兽
	if self.mOwnFormation.ZhenshouModelId and self.mOwnFormation.ZhenshouModelId ~= 0 then
		createZhenshouNode(self.mOwnFormation.ZhenshouModelId, cc.p(180*Adapter.MinScale, 320*Adapter.MinScale), false)
	end
	-- 添加敌方珍兽
	if self.mOtherFormation.ZhenshouModelId and self.mOtherFormation.ZhenshouModelId ~= 0 then
		createZhenshouNode(self.mOtherFormation.ZhenshouModelId, cc.p(450*Adapter.MinScale, 320*Adapter.MinScale), true)
	end
	
end

-- 创建按钮层
function GuildPvpFormationLayer:createBtnLayer()
	local btnLayer = ui.newStdLayer()
	self:addChild(btnLayer)

	local btnList = {
		-- 关闭
		{
			normalImage = "c_29.png",
			position = cc.p(594, 1030),
			clickAction = function ()
				LayerManager.removeLayer(self)
			end,
		},
		-- 战斗
		{
			normalImage = self.mChallengeType == 1 and "bpz_35.png" or "bpz_43.png",
			tag = 1,
			position = cc.p(320, 80),
			clickAction = function ()
				if self.mChallengeNum < 1 then
					ui.showFlashView({text = TR("%s次数不足", self.mChallengeType == 1 and TR("挑战") or TR("切磋"))})
					return
				end
				self:requesetFight()
			end,
		},
		-- 前一个
		{
			normalImage = "bpz_46.png",
			position = cc.p(50, 950),
			clickAction = function ()
				local curOrder = self.mOtherOrder - 1
				-- 越界判断
				if curOrder < 1 then
					ui.showFlashView({text = TR("已是第一个敌方帮派成员")})
					return
				end
				self:nextOther(curOrder)
			end,
		},
		-- 后一个
		{
			normalImage = "bpz_45.png",
			position = cc.p(594, 950),
			clickAction = function ()
				local curOrder = self.mOtherOrder + 1
				local otherPlayerList = GuildObj:getMatchGuildBattlePlayerInfo()
				-- 越界判断
				if curOrder > #otherPlayerList then
					ui.showFlashView({text = TR("已是最后一个敌方帮派成员")})
					return
				end
				self:nextOther(curOrder)
			end,
		},
	}

	for _, btnInfo in pairs(btnList) do
		local tempBtn = ui.newButton(btnInfo)
		-- 挑战按钮
		if btnInfo.tag == 1 then
			self.battleBtn = tempBtn
		end
		btnLayer:addChild(tempBtn)
	end

	return btnLayer
end

function GuildPvpFormationLayer:nextOther(order)
	-- 查找对应玩家信息
	local otherPlayerInfo = nil
	local otherPlayerList = GuildObj:getMatchGuildBattlePlayerInfo()
	for _, playerInfo in pairs(otherPlayerList) do
		if order == playerInfo.Order then
			otherPlayerInfo = playerInfo
			break
		end
	end
	-- 刷新界面
	if otherPlayerInfo then
		self.mOtherPlayerInfo = otherPlayerInfo
		otherPlayerInfo.challengeType = otherPlayerInfo.Star < 3 and 1 or 0
		self.mOtherPlayerId = otherPlayerInfo.Id
	    self.mOtherPlayerName = otherPlayerInfo.Name
	    self.mOtherFashionId = otherPlayerInfo.FashionModelId
	    self.mOtherOrder = otherPlayerInfo.Order or 1
	    self.mOtherFAP = otherPlayerInfo.FAP or 0
	    self.mChallengeType = otherPlayerInfo.challengeType or 1

	    self:requesetInfo()
	else
		ui.showFlashView({text = TR("没有该序号成员")})
	end
end

function GuildPvpFormationLayer:refreshUI()
	self:refreshCamp()

	-- 是否已招募了佣兵
	local isHire = false
	for i = 1, 7 do
		local formationInfo = self.mOwnFormation[tostring(i)]
		if formationInfo and formationInfo.Formation == 7 and formationInfo.HeroModelId ~= 0 then
			isHire = true
		end
	end
	if isHire then
		self.challengeBtn:loadTextures("tb_11.png", "tb_11.png")
	else
		self.challengeBtn:loadTextures("bpz_34.png", "bpz_34.png")
	end

	-- 挑战次数
	if self.mChallengeType == 1 then
		self.mChallengeNum = GuildObj:getPlayerGuildBattleInfo().ChallengeNum
		self.challengeNumLabel:setString(TR("剩余挑战次数: %d", self.mChallengeNum))
	else
		self.mChallengeNum = GuildObj:getPlayerGuildBattleInfo().RollingNum
		self.challengeNumLabel:setString(TR("剩余切磋次数: %d", self.mChallengeNum))
	end

	-- 挑战按钮刷新
	self.hintLabel:setVisible(false)
	if self.battleBtn then
		-- 挑战还是切磋
		if self.mChallengeType == 1 then
			self.battleBtn:loadTextures("bpz_35.png", "bpz_35.png")
		else
			self.battleBtn:loadTextures("bpz_43.png", "bpz_43.png")
		end
		self.battleBtn:setEnabled(true)
		-- 是否可以挑战
		local hadBattleNodeInfo = GuildObj:getPlayerGuildBattleInfo().BattleNodeIdStr or {}
		if hadBattleNodeInfo[tostring(self.mOtherOrder)] then
			self.battleBtn:setEnabled(false)
			self.hintLabel:setVisible(true)
		end
	end

	-- 获取积分刷新
	local sorce = 3*(51-self.mOtherOrder)*2
	self.sorceLabel:setString(TR("三星胜利可获得: \n积分: #d17b00%d \n#F7F5F0帮派武技: #249029%d", sorce, sorce))

	-- 对方玩家序号
	self.otherOrderLabel:setString(self.mOtherOrder)
	-- 对方玩家名字
	self.otherNameLabel:setString(TR("等级%d  %s%s", self.mOtherPlayerInfo.Lv, Enums.Color.eYellowH, self.mOtherPlayerInfo.Name))
end

--==========================服务器相关=====================
-- 请求阵容信息
function GuildPvpFormationLayer:requesetInfo()
	HttpClient:request({
	    moduleName = "GuildbattleInfo",
	    methodName = "GetChallengeInfo",
	    svrMethodData = {self.mOtherPlayerId},
	    callbackNode = self,
	    callback = function (response)
	    	if not response or response.Status ~= 0 then
	    		LayerManager.removeLayer(self)
	    	    return
	    	end
	    	self.mOwnFormation = response.Value.FormationInfo
	    	self.mOtherFormation = response.Value.TargetFormationInfo

	    	self:refreshUI()
	    end
	})
end
-- 调整阵容
function GuildPvpFormationLayer:requesetFormationChang(formationList)
	local formation = {PlayerAttrObj:getPlayerAttrByName("PlayerId")}
	for _, formationInfo in pairs(formationList) do
		table.insert(formation, formationInfo.Formation)
	end
	HttpClient:request({
        moduleName = "GuildbattleInfo",
        methodName = "FormationChang",
        svrMethodData = formation,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("修改布阵成功"))

            for i = 1, 7 do
            	self.mOwnFormation[tostring(i)] = formationList[i]
            end

            self:refreshCamp()
        end,
    })
end

-- 帮派战战斗
function GuildPvpFormationLayer:requesetFight()
	HttpClient:request({
	    moduleName = "GuildbattleInfo",
	    methodName = "ChallengeFight",
	    svrMethodData = {self.mOtherPlayerId, self.mChallengeType},
	    callbackNode = self,
	    callback = function (response)
	    	if not response or response.Status ~= 0 then
	    	    return
	    	end

        	local otherInfo = {
        		PlayerName = self.mOtherPlayerName,
        		FAP = self.mOtherFAP,
	        }
	    	-- 战斗信息
	    	local value = response.Value

	    	-- 战斗页面控制信息
	    	local controlParams = Utility.getBattleControl(ModuleSub.eGuildBattle)
	    	-- 调用战斗页面
	    	LayerManager.addLayer({
	    	    name = "ComBattle.BattleLayer",
	    	    data = {
	    	        data = value.FightInfo,
	    	        skip = controlParams.skip,
	    	        trustee = controlParams.trustee,
	    	        skill = controlParams.skill,
	    	        map = Utility.getBattleBgFile(ModuleSub.eGuildBattle),
	    	        callback = function(retData)
	    	            PvpResult.showPvpResultLayer(
	    	                ModuleSub.eGuildBattle,
	    	                value,
	    	                {
	    	                    PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
	    	                    FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
	    	                },
	    	                otherInfo
	    	            )

	    	            if controlParams.trustee and controlParams.trustee.changeTrusteeState then
	    	                controlParams.trustee.changeTrusteeState(retData.trustee)
	    	            end
	    	        end
	    	    },
	    	})

	    	-- 删除阵容界面
            LayerManager.deleteStackItem("guild.GuildPvpFormationLayer")
	    end
	})
end


return GuildPvpFormationLayer