--[[
******VIP特权管理器*******

	-- david.dai
]]
local VipRuleManager = class("VipRuleManager")

function VipRuleManager:ctor()
end

function VipRuleManager:restart()

end

function VipRuleManager:covertToGHType(type)
    if type == EnumRecoverableResType.BAOZI then
        return HeadResType.BAOZI
    end
    return 8 + type
end

function VipRuleManager:showItemUseLayer(type,id)
    local holdGoods = BagManager:getItemById(id)
    if not holdGoods then
        return false
    end
    BagManager:useItem( id ,false)
    -- local headType = self:covertToGHType(type)
    -- local resName = GetResourceNameForGeneralHead(headType)
    -- local itemdata = holdGoods.itemdata
    -- local num = holdGoods.num
    -- if num > 0 then
    --     local layer = CommonManager:showOperateSureLayer(
    --         function()
    --             BagManager:useBatchItem( itemdata.id,num )
    --             toastMessage(resName.."增加" .. itemdata.usable * num)
    --         end,
    --         nil,
    --         {
    --         uiconfig = "lua.uiconfig_mango_new.common.UseCoinComfirmLayer",
    --         title = itemdata.name .. num .. "个",
    --         msg = "可兑换" .. itemdata.usable * num
    --         }
    --     )
    --     local img1 = TFDirector:getChildByPath(layer, 'img1')
    --     local img2 = TFDirector:getChildByPath(layer, 'img2')
    --     img1:setTexture(itemdata:GetPath())
    --     img2:setTexture(GetResourceIconForGeneralHead(headType))
    return true
    -- end
end

function VipRuleManager:showBuyLayer(resType,isadd,minVipLevel,vipRuleCode)
    local timesInfo = MainPlayer:GetChallengeTimesInfo(resType)
    local resConfigure = PlayerResConfigure:objectByID(resType)
    local headType = self:covertToGHType(resType)
    local resName = GetResourceNameForGeneralHead(headType)
    local maxBuyTime = resConfigure:getMaxBuyTime(MainPlayer:getVipLevel())
    
    --vip限制功能
    if MainPlayer:getVipLevel() < minVipLevel then
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                title = isadd and "提升VIP" or resName.."不足",
                -- msg = "VIP" .. ConstantData:getValue("Challenge.Time.Chapter.NeedVIP") .. "方可购买体力。",
                msg = "VIP" .. minVipLevel .. "方可购买"..resName.."。\n\n是否前往充值？",
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )
        return
    else
        if maxBuyTime - timesInfo.todayBuyTime < 1 then
            --判断是否有没有更高的vip能够增加购买次数
            local nextUpVip = VipData:getVipNextAddValueVip(vipRuleCode,MainPlayer:getVipLevel())
            if nextUpVip then
                --local msg = "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可购买" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？";				
				local msg = stringUtils.format(localizable.VipRuleManager_tisheng_vip, nextUpVip.vip_level, nextUpVip.benefit_value)
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        title =  isadd and "购买次数已用完" or resName.."不足",
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
            else
                if isadd then
                    toastMessage("今日购买次数已用完")
                else
                    toastMessage(resName.."不足，今日购买次数已用完")
                end
            end
            return
        end
    end
    return true
end

function VipRuleManager:showStaminaLayer(isadd)
    local resType = EnumRecoverableResType.PUSH_MAP
    if self:showItemUseLayer(resType,30010) then
        return
    elseif self:showItemUseLayer(resType,30018) then
        return
    end
    
    return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Chapter.NeedVIP"),2000)
end

function VipRuleManager:showArenaLayer(isadd)
    local resType = EnumRecoverableResType.QUNHAO
    if self:showItemUseLayer(resType,30011) then
        return
    end
    
    return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Herolist.NeedVIP"),2001)
end

function VipRuleManager:showClimbLayer(isadd)
    local resType = EnumRecoverableResType.CLIMB
    if self:showItemUseLayer(resType,30014) then
        return
    end
    
    return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Climb.NeedVIP"),2002)
end

function VipRuleManager:showSkillPointLayer(isadd)
    local resType = EnumRecoverableResType.SKILL_POINT
    
    return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Skill.NeedVIP"),2004)
end

--祈愿次数增加
function VipRuleManager:getQiYuanTimesAddNum()
    if MainPlayer == nil then
        return 0
    end
    local vipInfo = VipData:getVipItemByTypeAndVip(4009,MainPlayer:getVipLevel())
    if vipInfo then
        return vipInfo.benefit_value
    end
    return 0
end

--主角属性
function VipRuleManager:addMainPlayerAttr()
    local vipInfo = VipData:getVipItemByTypeAndVip(4002,MainPlayer:getVipLevel())
    if vipInfo then
        return vipInfo.benefit_value
    end
    return 0
end

--好友个数
function VipRuleManager:getFriendNum()
    local vipInfo = VipData:getVipItemByTypeAndVip(6000,MainPlayer:getVipLevel())
    if vipInfo then
        return vipInfo.benefit_value
    end
    return 0
end

--鼓舞效果
function VipRuleManager:addInspireEffect()
    local vipInfo = VipData:getVipItemByTypeAndVip(4005,MainPlayer:getVipLevel())
    if vipInfo then
        return vipInfo.benefit_percent*100
    end
    return 0
end
--鼓舞效果
function VipRuleManager:isCanIntensify(ishow)
    local vip_level = VipData:getMinLevelDeclear(4001)
    if vip_level == nil then
        return true
    end
    if MainPlayer:getVipLevel() >= vip_level then
        return true
    end
    if ishow then
        local msg =  stringUtils.format(localizable.vip_intensify_not_enough,vip_level);
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                title = "提升VIP",
                msg = msg,
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )
    end
    return false
end

function VipRuleManager:showReplyLayer(type, isadd)
    if isadd == nil then
        isadd = true;
    end
   
    if type == EnumRecoverableResType.PUSH_MAP then
        if not self:showStaminaLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.QUNHAO then
        if not self:showArenaLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.CLIMB then
        if not self:showClimbLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.SKILL_POINT then
        if not self:showSkillPointLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.MINE then
        if not self:showMineTimesLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.BAOZI then
        if not self:showBaoziTimesLayer(isadd) then
            return
        end
    elseif type == EnumRecoverableResType.SHALU_COUNT then
        if not self:showShaLuTimesLayer(isadd) then
            return
        end
    end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ReplyLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:setType(type,isadd);
    AlertManager:show()
end

function VipRuleManager:showBuyReplyLayer(type, isadd)
    if isadd == nil then
        isadd = true;
    end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.ReplyLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:setType(type,isadd);
    AlertManager:show()
end

function VipRuleManager:showMineTimesLayer(isadd)
    local resType = EnumRecoverableResType.MINE
    if self:showItemUseLayer(resType,30067) then
        return
    end
    
    toastMessage(TFLanguageManager:getString(ErrorCodeData.Mining_No_Rob_frequency))
    -- return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Climb.NeedVIP"),2002)
end

function VipRuleManager:showBaoziTimesLayer(isadd)
    local resType = EnumRecoverableResType.BAOZI
    if self:showItemUseLayer(resType,30107) then
        return
    end
    
    local item = PlayerResConfigure:objectByID(10) or {}
    local vipRuleCode = item.buy_vip_rule or 2005
    -- toastMessage(localizable.youli_text3)
    return self:showBuyLayer(resType,isadd,0,vipRuleCode)
end

function VipRuleManager:showShaLuTimesLayer(isadd)
    local resType = EnumRecoverableResType.SHALU_COUNT
    if self:showItemUseLayer(resType,30106) then
        return
    end
    
    local item = PlayerResConfigure:objectByID(11) or {}
    local vipRuleCode = item.buy_vip_rule or 2006
    -- toastMessage(localizable.youli_text3)
    return self:showBuyLayer(resType,isadd,0,vipRuleCode)

    --toastMessage(localizable.youli_text15)
    -- return self:showBuyLayer(resType,isadd,ConstantData:getValue("Challenge.Time.Climb.NeedVIP"),2002)
end


return VipRuleManager:new();
