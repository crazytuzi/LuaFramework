local FactionQFTLayer = class("FactionQFTLayer", function() return cc.Layer:create() end )

local FactionPrayType = 
{	
	None = 0,
	BTcandle = 1,		--白檀香
	CMcandle = 2,		--沉木香
	--LYcandle = 3,		--龙蜒香
}

function FactionQFTLayer:ctor(factionData, bg, mainLayer)
    self.mainLayer = mainLayer

    local msgids = {FACTION_SC_GETPRAYINFO_RET,FACTION_SC_PRAY_RET,FACTION_SC_CONTRIBUTE_RET}
	require("src/MsgHandler").new(self,msgids)
    local MRoleStruct = require("src/layers/role/RoleStruct")
    if MRoleStruct ~= nil then
 	    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETPRAYINFO, "GetFactionPrayInfo", {factionID=MRoleStruct:getAttr(PLAYER_FACTIONID)})
        addNetLoading(FACTION_CS_GETPRAYINFO, FACTION_SC_GETPRAYINFO_RET)
    end

    local factionUpdateCfg = getConfigItemByKey("FactionUpdate")
    self.updateCfg = unserialize(factionUpdateCfg[1].contriScale)
    dump(self.updateCfg)
	
    self.m_prayLeftCounts = {};
    self.m_richtextBT = nil;
    self.m_richtextCM = nil;
    self.m_richtextLY = nil;

    --背景图
    local imageBg = createSprite(self, "res/faction/bg_qft.png", cc.p(0, 0), cc.p(0, 0))
    self.imageBg = imageBg

    local leftX = imageBg:getContentSize().width/2 - 150
    self.leftX = leftX
    local rightX = imageBg:getContentSize().width/2 + 150
    self.rightX = rightX

    createSprite(imageBg, "res/faction/xiang1.png", cc.p(leftX, 110), cc.p(0.5, 0))
    createSprite(imageBg, "res/faction/xiang2.png", cc.p(rightX, 110), cc.p(0.5, 0))
    --createSprite(imageBg, "res/faction/xiang3.png", cc.p(574, 110), cc.p(0.5, 0))

    -- 货币显示
    self.factionData = factionData
    local Mcurrency = require "src/functional/currency"  
    Mnode.addChild(
    {
        parent = imageBg,
        child = Mnode.combineNode(
        {
            nodes =
            {
                [1] = Mcurrency.new(
                {
                    cate = PLAYER_INGOT,
                    color = MColor.yellow,
                } ),

                [2] = Mcurrency.new(
                {
                    cate = PLAYER_MONEY,
                    color = MColor.yellow,
                } ),
            },

            ori = "-",
            margins = 0,
        } ),
        anchor = cc.p(0,0.5),
        pos = cc.p(20,480),
    } )

    --帮助
    __createHelp(
		{parent = imageBg, 
		 str = require("src/config/PromptOp"):content(58),
		 pos = cc.p( 674 , 466),
		}
	)

    local iconPath = "res/group/currency/"

    --上香提示
    local function confirmCostBox(PrayType, str)
        if FactionQFTLayer.noConfirm then
            g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_PRAY, "FactionPray", {prayType=PrayType})
            return
        end

        local boxBg = MessageBoxYesNo(nil, str, function() g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_PRAY, "FactionPray", {prayType=PrayType}) end)
        local Mcheckbox = require "src/component/checkbox/view"
        local checkbox = Mcheckbox.new(
        {
            label =
            {
                src = game.getStrByKey("download_text9"),
                size = 20,
                color = MColor.green,
            },
            margin = 0,
            value = false,
            cb = function(value, root)
                FactionQFTLayer.noConfirm = value
            end,
        } )
        boxBg:addChild(checkbox, 100)
        checkbox:setPosition(cc.p(boxBg:getContentSize().width / 2, 110))
        checkbox:setAnchorPoint(cc.p(0.5, 0.5))
    end

    --白檀香
    local function BtnFunc1()        
        if (self.m_prayLeftCounts[FactionPrayType.BTcandle] == nil or self.m_prayLeftCounts[FactionPrayType.BTcandle] == 0) then
             TIPS({type = 1 , str=game.getStrByKey("factionQFT_operError0")})
             return
        end

        --发送上香协议
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_PRAY, "FactionPray", {prayType=FactionPrayType.BTcandle})
	end

	local Btn1 = createMenuItem(imageBg, "res/component/button/39.png", cc.p(leftX, 80), BtnFunc1)
    self.Btn1 = Btn1
    local icon = createSprite(Btn1, iconPath.."1.png", cc.p(33, Btn1:getContentSize().height/2), cc.p(0.5, 0.5))
    icon:setScale(0.6)
    createLabel(Btn1, game.getStrByKey("free"), cc.p(53, Btn1:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)

	createLabel(imageBg, string.format(game.getStrByKey("factionQFT_text1"), self.updateCfg[1].facXp, self.updateCfg[1].conbri), cc.p(leftX, 40), nil, 20, true, nil, nil, MColor.lable_yellow)

    --沉木香
    local function BtnFunc2()     
        if (self.m_prayLeftCounts[FactionPrayType.CMcandle] == nil or self.m_prayLeftCounts[FactionPrayType.CMcandle] == 0) then
             TIPS({type = 1 , str=game.getStrByKey("factionQFT_operError0")})
             return
        end
           
        --发送上香协议
        confirmCostBox(FactionPrayType.CMcandle, string.format(game.getStrByKey("factionQFT_cost_tip1"), self.updateCfg[2].needIngot))
	end
	local Btn2 = createMenuItem(imageBg, "res/component/button/39.png", cc.p(rightX, 80), BtnFunc2)
    self.Btn2 = Btn2
    icon = createSprite(Btn2, iconPath.."3.png", cc.p(42, Btn2:getContentSize().height/2), cc.p(0.5, 0.5))
    icon:setScale(0.6)
    createLabel(Btn2, self.updateCfg[2].needIngot, cc.p(68, Btn2:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)

	createLabel(imageBg, string.format(game.getStrByKey("factionQFT_text2"), self.updateCfg[2].facXp, self.updateCfg[2].conbri), cc.p(rightX, 40), nil, 20, true, nil, nil, MColor.lable_yellow)

    --龙涎香
 --    local function BtnFunc3()     
 --        if (self.m_prayLeftCounts[FactionPrayType.LYcandle] == nil or self.m_prayLeftCounts[FactionPrayType.LYcandle] == 0) then
 --             TIPS({type = 1 , str=game.getStrByKey("factionQFT_operError0")})
 --             return
 --        end
           
 --        --发送上香协议
 --        confirmCostBox(FactionPrayType.LYcandle, game.getStrByKey("factionQFT_cost_tip2"))
	-- end
	-- local Btn3 = createMenuItem(imageBg, "res/component/button/39.png", cc.p(574, 80), BtnFunc3)
 --    icon = createSprite(Btn3, iconPath.."3.png", cc.p(45, Btn3:getContentSize().height/2), cc.p(0.5, 0.5))
 --    icon:setScale(0.6)
 --    createLabel(Btn3, "500", cc.p(65, Btn3:getContentSize().height/2), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)
	-- createLabel(imageBg, game.getStrByKey("factionQFT_text3"), cc.p(574, 40), nil, 20, true, nil, nil, MColor.lable_yellow) 
end

function FactionQFTLayer:updateUI()
	if self.m_prayLeftCounts[FactionPrayType.BTcandle] <= 0 then
        self.Btn1:setEnabled(false)
        startTimerAction(self, 0.3, false, function() self.Btn1:setEnabled(false) end)
    end

    if self.m_prayLeftCounts[FactionPrayType.CMcandle] <= 0 then
        self.Btn2:setEnabled(false)
        startTimerAction(self, 0.3, false, function() self.Btn2:setEnabled(false) end)
    end
end

function FactionQFTLayer:updateRed(leftNum)
    if self.mainLayer and self.mainLayer.changeRed then
        if leftNum > 0 then
            self.mainLayer:changeRed(1, true)
        else
            self.mainLayer:changeRed(1, false)
        end
    end
end

function FactionQFTLayer:networkHander(buff, msgid)
	local switch = {
        -- 返回行会成员今日剩余行会祈福数据
		[FACTION_SC_GETPRAYINFO_RET] = function()    
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionPrayInfoRet", buff) 
            
            local num = #t.infos
            for i=1, num do
                self.m_prayLeftCounts[t.infos[i].prayType] = t.infos[i].dayLeftCount
            end

            if self.m_richtextBT ~= nil then
                self.m_richtextBT:removeFromParent(true);
                self.m_richtextBT = nil;
            end

            if self.m_richtextCM ~= nil then
                self.m_richtextCM:removeFromParent(true);
                self.m_richtextCM = nil;
            end

            -- if self.m_richtextLY ~= nil then
            --     self.m_richtextLY:removeFromParent(true);
            --     self.m_richtextLY = nil;
            -- end

            --剩余次数
            local leftNum = self.m_prayLeftCounts[FactionPrayType.BTcandle] or 0
            self:updateRed(leftNum)
            local text = string.format(game.getStrByKey("factionQFT_leftCount"), leftNum);
            self.m_richtextBT = require("src/RichText").new(self.imageBg, cc.p(self.leftX, 16), cc.size(200, 20), cc.p(0.5, 0.5), 20, 18, MColor.lable_black)
            self.m_richtextBT:addText(text)
            self.m_richtextBT:setAutoWidth()
            self.m_richtextBT:format()
            
            leftNum = self.m_prayLeftCounts[FactionPrayType.CMcandle] or 0
            text = string.format(game.getStrByKey("factionQFT_leftCount"), leftNum);
            self.m_richtextCM = require("src/RichText").new(self.imageBg, cc.p(self.rightX, 16), cc.size(200, 20), cc.p(0.5, 0.5), 20, 18, MColor.lable_black)
            self.m_richtextCM:addText(text)
            self.m_richtextCM:setAutoWidth()
            self.m_richtextCM:format()
            
            -- leftNum = self.m_prayLeftCounts[FactionPrayType.LYcandle] or 0
            -- text = string.format(game.getStrByKey("factionQFT_leftCount"), leftNum);
            -- self.m_richtextLY = require("src/RichText").new(self.imageBg, cc.p(520, 16), cc.size(200, 20), cc.p(0, 0.5), 20, 18, MColor.lable_black)
            -- self.m_richtextLY:addText(text)
            -- self.m_richtextLY:format()
            self:updateUI()
		end,
        [FACTION_SC_PRAY_RET] = function()    
			local t0 = g_msgHandlerInst:convertBufferToTable("FactionPrayRet", buff)
            local errorId = t0.retCode
            local oper = t0.prayType

            --错误码处理
            if errorId > 0 then
                local t = {game.getStrByKey("factionQFT_operError1"), 
                           game.getStrByKey("factionQFT_operError2"),
                           game.getStrByKey("factionQFT_operError3"),
                           game.getStrByKey("factionQFT_operError4"),
                           game.getStrByKey("factionQFT_operError5"),
                           game.getStrByKey("factionQFT_operError6"),
                           game.getStrByKey("factionQFT_operError7"),
                           game.getStrByKey("factionQFT_operError8") }
                
                if t[errorId] ~= nil then
                    TIPS({type = 1 , str=t[errorId]})
                end

                return
            end 

            local strSucc = game.getStrByKey("factionQFT_succ")
            if oper == FactionPrayType.BTcandle then
                if self.m_prayLeftCounts[FactionPrayType.BTcandle] then
                    self.m_prayLeftCounts[FactionPrayType.BTcandle] = self.m_prayLeftCounts[FactionPrayType.BTcandle] - 1
                    self:updateRed(self.m_prayLeftCounts[FactionPrayType.BTcandle])

                    if self.m_richtextBT ~= nil then
                        self.m_richtextBT:removeFromParent(true)
                        self.m_richtextBT = nil;
                    end
                    
                    local text = string.format(game.getStrByKey("factionQFT_leftCount"), self.m_prayLeftCounts[FactionPrayType.BTcandle]);
                    self.m_richtextBT = require("src/RichText").new(self.imageBg, cc.p(self.leftX, 16), cc.size(200, 20), cc.p(0.5, 0.5), 20, 18, MColor.lable_black)
                    self.m_richtextBT:addText(text)
                    self.m_richtextBT:setAutoWidth()
                    self.m_richtextBT:format()
                end
                
                strSucc = string.format(game.getStrByKey("factionQFT_text1"), self.updateCfg[1].facXp, self.updateCfg[1].conbri)
            elseif oper == FactionPrayType.CMcandle then
                if self.m_prayLeftCounts[FactionPrayType.CMcandle] then
                    self.m_prayLeftCounts[FactionPrayType.CMcandle] = self.m_prayLeftCounts[FactionPrayType.CMcandle] - 1

                    if self.m_richtextCM ~= nil then
                        self.m_richtextCM:removeFromParent(true)
                        self.m_richtextCM = nil;
                    end
                    
                    local text = string.format(game.getStrByKey("factionQFT_leftCount"), self.m_prayLeftCounts[FactionPrayType.CMcandle]);
                    self.m_richtextCM = require("src/RichText").new(self.imageBg, cc.p(self.rightX, 16), cc.size(200, 20), cc.p(0.5, 0.5), 20, 18, MColor.lable_black)
                    self.m_richtextCM:addText(text)
                    self.m_richtextCM:setAutoWidth()
                    self.m_richtextCM:format()
                end

                strSucc = string.format(game.getStrByKey("factionQFT_text2"), self.updateCfg[2].facXp, self.updateCfg[2].conbri)
            else
                -- if self.m_prayLeftCounts[FactionPrayType.LYcandle] then
                --     self.m_prayLeftCounts[FactionPrayType.LYcandle] = self.m_prayLeftCounts[FactionPrayType.LYcandle] - 1;

                --     if self.m_richtextLY ~= nil then
                --         self.m_richtextLY:removeFromParent(true)
                --         self.m_richtextLY = nil;
                --     end
                    
                --     local text = string.format(game.getStrByKey("factionQFT_leftCount"), self.m_prayLeftCounts[FactionPrayType.LYcandle]);
                --     self.m_richtextLY = require("src/RichText").new(self.imageBg, cc.p(520, 16), cc.size(200, 20), cc.p(0, 0.5), 20, 18, MColor.lable_black)
                --     self.m_richtextLY:addText(text)
                --     self.m_richtextLY:format()
                -- end

                -- strSucc = strSucc..game.getStrByKey("factionQFT_text3")
            end  
            
            --TIPS({type = 1 , str=strSucc})  
            
            --上香特效
            local effect = Effects:create(false)
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            if oper == FactionPrayType.BTcandle then
                effect:playActionData("shangxiang1", 6, 1.5, 1)
                effect:setPosition(cc.p(self.leftX, 174))
            elseif oper == FactionPrayType.CMcandle then
                effect:playActionData("shangxiang2", 7, 1.5, 1)
                effect:setPosition(cc.p(self.rightX, 198))
            else
                effect:playActionData("shangxiang3", 7, 1.5, 1)
                effect:setPosition(cc.p(574, 190))
            end
            self.imageBg:addChild(effect)
            addEffectWithMode(effect, 3) 
            startTimerAction(self.imageBg, 2, false, function() removeFromParent(effect) end) 
            self:updateUI()  
		end,
        [FACTION_SC_CONTRIBUTE_RET] = function() 
			local t = g_msgHandlerInst:convertBufferToTable("FactionContributeRet", buff)
			self.factionData.myMoney = t.contribution
			--self.factionData.money = t.factionMoney
            self.factionData.exp = t.facXp
            dump(self.factionData)
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionQFTLayer