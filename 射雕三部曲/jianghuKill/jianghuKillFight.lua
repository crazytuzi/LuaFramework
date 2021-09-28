--[[
    文件名: jianghuKillFight.lua
    描述: 江湖杀战斗结算界面
    创建人: lengjiazhi
    创建时间: 2018.09.21
-- ]]
local jianghuKillFight = class("jianghuKillFight", function(params)
	return display.newLayer()
end)


--[[
	参数
	fightInfo: 战斗数据
    isWin: 胜负
    playerInfo: 进攻方（自己）
    targetInfo: 防守方（对手）
    jobId: 职业
    cikeRadio:是否发动突袭
    atkRadio: 攻击加成
    defRadio: 防御加成
    honorCoin: 获取荣誉点数
    defAtkRadio ：防守方克制攻击加成
    teamAtkRadio: 组队攻击加成
    defTeamAtkRadio ：防守方组队攻击加成
--]]
function jianghuKillFight:ctor(params)
    self.mFightInfo = params.fightInfo
    self.mIsWin = params.isWin
    self.mJobId = params.jobId
    self.mTargetInfo = params.targetInfo
    self.mPlayerInfo = params.playerInfo
    self.mCikeRadio = params.cikeRadio
    self.mAtkRadio = params.atkRadio
    self.mDefRadio = params.defRadio
    self.mHonorCoin = params.honorCoin
    self.mDefAtkRadio = params.defAtkRadio
    self.mTeamAtkRadio = params.teamAtkRadio
    self.mDefTeamAtkRadio = params.defTeamAtkRadio

    self.mIsSpecialFight = self.mIfCike

	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
end

function jianghuKillFight:initUI()
    --黑底
    local blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    blackBg:setContentSize(640, 1136)
    blackBg:setPosition(0, 0)
    self.mParentLayer:addChild(blackBg)
    self.mBlackBg = blackBg

    if self.mIsWin then
        local lightSprite = ui.newSprite("jhs_131.png")
        lightSprite:setPosition(320, 700)
        self.mParentLayer:addChild(lightSprite)

        local rot = cc.RotateBy:create(6, 360)
        lightSprite:runAction(cc.RepeatForever:create(rot))
    end

    local bgSprite = ui.newScale9Sprite("jhs_130.png", cc.size(640, 450))
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local isWinSprite = ui.newSprite(self.mIsWin and "jhs_132.png" or "jhs_133.png")
    isWinSprite:setPosition(320, 800)
    self.mParentLayer:addChild(isWinSprite)

    local vsSprite = ui.newSprite(self.mIsWin and "jhs_135.png" or "jhs_129.png")
    vsSprite:setPosition(320, 690)
    self.mParentLayer:addChild(vsSprite)

    local sureBtn = ui.newButton({
    	text = TR("确定"),
    	normalImage = "c_28.png",
    	clickAction = function()
    		LayerManager.removeLayer(self)
    	end
	})
	sureBtn:setPosition(463, 400)
	self.mParentLayer:addChild(sureBtn)

	local sureBtn = ui.newButton({
    	text = TR("查看回放"),
    	normalImage = "c_28.png",
    	clickAction = function()
            self:fight()
    	end
	})
	sureBtn:setPosition(173, 400)
	self.mParentLayer:addChild(sureBtn)

    local getResBgSprite = ui.newSprite("jhs_134.png")
    getResBgSprite:setPosition(320, 455)
    self.mParentLayer:addChild(getResBgSprite)

    local num = self.mIsWin and JianghukillModel.items[1].challengeSuccessReward or JianghukillModel.items[1].challengeFailReward
    local tempStr 
    if self.mHonorCoin > num then
        tempStr = TR("获得奖励：{jhs_122.png}%s荣誉点%s(+%s%%)", self.mHonorCoin, Enums.Color.eGreenH, JianghukillModel.items[1].winAdd/100)
    else
       tempStr = TR("获得奖励：{jhs_122.png}%s荣誉点", self.mHonorCoin)
    end

    local dropLabel = ui.newLabel({
        text = tempStr,
        outlineColor = Enums.Color.eBlack,
        })
    dropLabel:setPosition(320, 455)
    self.mParentLayer:addChild(dropLabel)

    --突袭图标
    if self.mCikeRadio > 0 then
        local sepcialTipSprite = ui.newSprite("jhs_87.png")
        sepcialTipSprite:setPosition(320, 630)
        self.mParentLayer:addChild(sepcialTipSprite)
    end

    --左边头像
    local leftCard = CardNode.createCardNode({
        resourceTypeSub = Utility.getTypeByModelId(self.mPlayerInfo.HeadImageId),
        modelId = self.mPlayerInfo.HeadImageId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            print("详情")
        end
    })
    leftCard:setPosition(192, 684)
    self.mParentLayer:addChild(leftCard)
    -- 添加攻图标
    local gongSprite = ui.newSprite("jhs_140.png")
    gongSprite:setPosition(85, 85)
    leftCard:addChild(gongSprite)

    --左边名字
    local nameLabelL = ui.newLabel({
        text = self.mPlayerInfo.PlayerName,
        color = cc.c3b(238, 207, 114),
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    self.mParentLayer:addChild(nameLabelL)
    nameLabelL:setPosition(192, 624)

    --战力
    local fapLabelL = ui.newLabel({
        text = Utility.numberWithUnit(self.mPlayerInfo.Fap),
        color = Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    self.mParentLayer:addChild(fapLabelL)
    fapLabelL:setPosition(192, 594)

    --功力消耗
    local tempStr = TR("功力-1")
    if self.mTargetInfo.Profession == 1 then --对手是豪杰
        if self.mPlayerInfo.Profession == 3 then --自己是书生
            tempStr = TR("功力-1")
        else
            tempStr = TR("功力-2")
        end
    end
    local costLabelL = ui.newLabel({
        text = tempStr,
        outlineColor = Enums.Color.eOutlineColor,
        })
    self.mParentLayer:addChild(costLabelL)
    costLabelL:setPosition(192, 565)

    --势力等级
    local tempStr = self.mPlayerInfo.CampId == 1 and TR("武林盟众") or TR("浑天教徒")
    local campLvLabel = ui.newLabel({
        text = TR("%s%s级", tempStr, self.mPlayerInfo.CampLv),
        color = self.mPlayerInfo.CampId == 1 and Enums.Color.eBlue or Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    self.mParentLayer:addChild(campLvLabel)
    campLvLabel:setPosition(192, 535)
    --职业等级
    local tempStr = JianghukillJobModel.items[self.mPlayerInfo.Profession].name 
    local jobLvLabel = ui.newLabel({
        text = TR("%s%s级", tempStr, self.mPlayerInfo.ProfessionLv),
        color = self.mPlayerInfo.CampId == 1 and Enums.Color.eBlue or Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    self.mParentLayer:addChild(jobLvLabel)
    jobLvLabel:setPosition(192, 505)

    local startPosY = 710
    if self.mAtkRadio > 0 then
        local atkAddLabel = ui.newLabel({
            text = TR("克制攻击+%s%%", self.mAtkRadio),
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        atkAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(atkAddLabel)
        atkAddLabel:setPosition(15, startPosY)
        startPosY = startPosY - 40
    end

    if self.mCikeRadio > 0 then
        local cikeAddLabel = ui.newLabel({
            text = TR("突袭攻击+%s%%", self.mCikeRadio),
            color = cc.c3b(238, 207, 114),
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        cikeAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(cikeAddLabel)
        cikeAddLabel:setPosition(15, startPosY)
        startPosY = startPosY - 40
    end

    --组队攻击加成
    if self.mTeamAtkRadio > 0 then
        local teamAtkAddLabel = ui.newLabel({
            text = TR("组队攻击+%s%%", self.mTeamAtkRadio),
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        teamAtkAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(teamAtkAddLabel)
        teamAtkAddLabel:setPosition(15, startPosY)
        startPosY = startPosY - 40
    end

    --右边头像
    local rightCard = CardNode.createCardNode({
        resourceTypeSub = Utility.getTypeByModelId(self.mTargetInfo.HeadImageId),
        modelId = self.mTargetInfo.HeadImageId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            -- print("详情")
        end
    })
    rightCard:setPosition(440, 684)
    self.mParentLayer:addChild(rightCard)
    -- 添加守图标
    local shouSprite = ui.newSprite("jhs_141.png")
    shouSprite:setPosition(85, 85)
    rightCard:addChild(shouSprite)

    --右边名字
    local nameLabelR = ui.newLabel({
        text = self.mTargetInfo.PlayerName,
        color = cc.c3b(238, 207, 114),
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    self.mParentLayer:addChild(nameLabelR)
    nameLabelR:setPosition(440, 624)
    --战力
    local fapLabelR = ui.newLabel({
        text = Utility.numberWithUnit(self.mTargetInfo.Fap),
        color = Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    self.mParentLayer:addChild(fapLabelR)
    fapLabelR:setPosition(440, 594)

    --势力等级
    if self.mTargetInfo.CampId then
        local tempStr = self.mTargetInfo.CampId == 1 and TR("武林盟众") or TR("浑天教徒")
        local campLvLabelR = ui.newLabel({
            text = TR("%s%s级", tempStr, self.mTargetInfo.CampLv),
            color = self.mTargetInfo.CampId == 1 and Enums.Color.eBlue or Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            })
        self.mParentLayer:addChild(campLvLabelR)
        campLvLabelR:setPosition(440, 535)
    end
    --职业等级
    if self.mTargetInfo.Profession then
        local tempStr = JianghukillJobModel.items[self.mTargetInfo.Profession].name 
        local jobLvLabelR = ui.newLabel({
            text = TR("%s%s级", tempStr, self.mTargetInfo.ProfessionLv),
            color = self.mTargetInfo.CampId == 1 and Enums.Color.eBlue or Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            })
        self.mParentLayer:addChild(jobLvLabelR)
        jobLvLabelR:setPosition(440, 505)
    end

    if self.mTargetInfo.Profession then --非NPC显示
        --防守消耗
        local costLabelL = ui.newLabel({
            text = TR("精神-%d", self.mIsWin and 3 or 1),
            outlineColor = Enums.Color.eOutlineColor,
            })
        self.mParentLayer:addChild(costLabelL)
        costLabelL:setPosition(440, 565)
    end

    local startPosY = 710
    if self.mDefAtkRadio > 0 then
        local atkAddLabel = ui.newLabel({
            text = TR("克制攻击+%s%%", self.mDefAtkRadio),
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        atkAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(atkAddLabel)
        atkAddLabel:setPosition(500, startPosY)
        startPosY = startPosY - 40
    end

    --防御加成
    if self.mDefRadio > 0 then
        local defAddLabel = ui.newLabel({
            text = TR("驻守防御+%s%%", self.mDefRadio),
            color = Enums.Color.eBlue,
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        defAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(defAddLabel)
        defAddLabel:setPosition(500, startPosY)
        startPosY = startPosY - 40
    end

    --组队攻击加成
    if self.mDefTeamAtkRadio > 0 then
        local defTeamAtkAddLabel = ui.newLabel({
            text = TR("组队攻击+%s%%", self.mDefTeamAtkRadio),
            color = Enums.Color.eRed,
            outlineColor = Enums.Color.eOutlineColor,
            size = 20,
        })
        defTeamAtkAddLabel:setAnchorPoint(0, 0.5)
        self.mParentLayer:addChild(defTeamAtkAddLabel)
        defTeamAtkAddLabel:setPosition(500, startPosY)
        startPosY = startPosY - 40
    end
end

--战斗
function jianghuKillFight:fight()
    -- 进入战斗页面
    local value = self.mFightInfo
    -- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(ModuleSub.eJiangHuKill)
    -- 调用战斗页面
    local battleLayer
    battleLayer = LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = self.mFightInfo,
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(ModuleSub.eJiangHuKill),
            callback = function(retData)
                LayerManager.removeLayer(battleLayer)
                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
        cleanUp = false,
    })
end

return jianghuKillFight