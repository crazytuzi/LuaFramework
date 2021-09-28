-- Filename：    PillControler.lua
-- Author：      DJN
-- Date：        2015-5-27
-- Purpose：     丹药控制层
module("PillControler", package.seeall)
require "script/network/RequestCenter"
require "script/ui/pill/PillInfoLayer"
require "script/ui/pill/EatPillLayer"
require "script/ui/pill/PillService"
require "script/ui/pill/PillData"

--发送装丹药请求
function equipPill(p_hid,p_page,p_itemid,p_cb)
    if(p_itemid == nil)then
        --如果没拿到背包的丹药数据  不发请求
        return
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_hid))
    arg:addObject(CCInteger:create(p_page))
    arg:addObject(CCInteger:create(p_itemid))
    RequestCenter.addPillOnHero(p_cb,arg)
    -- body
end
function removeOneAction( ... )
    --银币够不够
    local haveSilver = UserModel.getSilverNumber()
    if(haveSilver < PillData.getCostSilverByNum(1))then
        AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        return
    end
    -- 物品背包满了
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local p_type = PillLayer.getCurType()
    local p_page = PillLayer.getCurPage()
    local p_haveNum  = PillData.getHaveNumByTypeAndPage(p_type,p_page)
    if(p_haveNum <= 0)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_228"))
        return
    end
    local p_heroId = PillLayer.getHeroInfo().hid
  
    local pillDbInfo = PillData.getInfoByTypeAndPage(p_page,p_type)
    local p_id = pillDbInfo.id
    local p_tmpId = pillDbInfo.Pill_id
    local pillId = pillDbInfo.Pill_id
    removePillByNum(p_heroId,p_type,p_page,p_id,p_tmpId)
end
function removeAllAction( ... )
    --银币够不够
    local p_type = PillLayer.getCurType()
    local curPillNum = PillData.getPillNumByType(p_type)
    local haveSilver = UserModel.getSilverNumber()
    if(haveSilver < PillData.getCostSilverByNum(curPillNum))then
        AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
        return
    end
    -- 物品背包满了
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local richInfo = {lineAlignment = 2,elements = {},labelDefaultSize = 28}
        richInfo.elements = {}
        local tmpElement = nil
        tmpElement = { 
                text = GetLocalizeStringBy("djn_229"),
                color = ccc3(0x78, 0x25, 0x00)}
        table.insert(richInfo.elements,tmpElement)
      
    
    local confirmCb = function (p_status)

        if(p_status)then
            local p_type = PillLayer.getCurType()
            local maxTag = PillLayer.getMaxTag()
            local p_page = PillLayer.getCurPage()
            local pillDbInfo = PillData.getInfoByTypeAndPage(p_page,p_type)
            local p_id = pillDbInfo.id

            local canRemove = false
            for i =1,maxTag do 
                local haveNum = PillData.getHaveNumByTypeAndPage(p_type,i)
                if haveNum >0 then
                    canRemove = true
                    break
                end
            end
            if not canRemove then
                AnimationTip.showTip(GetLocalizeStringBy("djn_228"))
                return
            end

            local p_heroId = PillLayer.getHeroInfo().hid
          
            removePillByType(p_heroId,p_type,p_id)
        end
    end
    require "script/ui/tip/RichAlertTip"
    RichAlertTip.showAlert(richInfo, confirmCb, true)   
end
function removePillByType(p_heroId,p_type,p_id)
    local lastFightForce = FightForceModel.dealParticularValues(p_heroId)
    local oldPill = PillData.getPageArryByType(p_type)
    -- print("lastFightForce")
    -- print_t(lastFightForce)
    local netCb = function ( ... )
        local curPillNum = PillData.getPillNumByType(p_type)
        local silverCost = PillData.getCostSilverByNum(curPillNum)
        AnimationTip.showTip(GetLocalizeStringBy("djn_234",silverCost))
        UserModel.addSilverNumber(-silverCost)
        PillData.clearHeroPill(p_heroId,p_type)
        PillData.getAffixByHid(p_heroId,true)
        PillData.addOldPill(oldPill)
        -- PillData.initBagCache()
        PillLayer.refreshUI()

        --属性变化飘窗
        local curFight = FightForceModel.dealParticularValues(p_heroId)
        -- print("curFight")
        -- print_t(curFight)
        ItemUtil.showAttrChangeInfo(lastFightForce,curFight)
    end
    PillService.removePillByType(p_heroId,p_type,netCb)
end
function removePillByNum(p_heroId,p_type,p_page,p_id,p_tmpId)
    --print("removePill p_heroId",p_heroId)
    local lastFightForce = FightForceModel.dealParticularValues(p_heroId)
    -- print("lastFightForce")
    -- print_t(lastFightForce)
    local netCb = function ( ... )
        local silverCost =  PillData.getCostSilverByNum(1)
        UserModel.addSilverNumber(-silverCost)
        AnimationTip.showTip(GetLocalizeStringBy("djn_234",silverCost))
        PillData.changeHeroPill(p_heroId,p_type,p_page,p_id,-1)
        PillData.getAffixByHid(p_heroId,true)  
        PillData.setPropsTab(p_tmpId,1)
        -- PillData.initBagCache()
        PillLayer.refreshUI()
    
        --属性变化飘窗
        local curFight = FightForceModel.dealParticularValues(p_heroId)
        -- print("curFight")
        -- print_t(curFight)
        ItemUtil.showAttrChangeInfo(lastFightForce,curFight)
    end
    PillService.removePill(p_heroId,p_id,netCb)

end
--点击丹药icon的回调
function pillIconCb(p_tag)
    --print("iconCb",p_tag)
    local _curType = PillLayer.getCurType()
    local _curPage = PillLayer.getCurPage()
    local _priority = PillLayer.getTouchPri()
    local _zOrder = PillLayer.getZorder()
    -- local _heroIndex = PillLayer.getHeroIndex()
    -- local heroInfo = PillData.getPillFormationInfo()
    local hid = PillLayer.getHeroInfo().hid

    -- local _curheroInfo = {}
    -- if(heroInfo)then
    --     _curheroInfo = heroInfo[_heroIndex]
    -- end
   
    --先获取一下当前在这个页已经吃了几个丹药
    local pillCount = PillData.getHaveNumByTypeAndPage(_curType,_curPage) or 0 
    if pillCount >= p_tag then
        --弹信息面板
        PillInfoLayer.showLayer(_curType,_curPage,p_tag,_priority -10 ,_zOrder +1 ,true)
    else
        local pillDbInfo = PillData.getInfoByTypeAndPage(_curPage,_curType)
        if(table.isEmpty(pillDbInfo))then return end
        -- if(table.isEmpty(_curheroInfo))then return end
        PillData.initBagCache()
        local itemId,havePillNum = PillData.getPillInBag(pillDbInfo.Pill_id)
        --print("PillControler havePillNumhavePillNum",havePillNum)
        if(havePillNum and havePillNum > 0)then
            --吃丹药面板

            EatPillLayer.showLayer(_curType,_curPage,p_tag,hid,itemId,_priority-10,_zOrder+1,havePillNum)
        end
    end
end

--[[
    @desc   : 一键服用丹药 一键装备同属性所有品质的丹药 
    @param  : 
    @return :
--]]
function addArrPills()
    local curType = PillLayer.getCurType() -- 当前类型 1 防御 2 生命 3 攻击
    local havePillNum = PillData.getPillTotalBagNumByType(curType) -- 丹药背包里的丹药数量

    -- 背包里没有可装备的丹药 "当前无可服用的丹药"
    if ((havePillNum == nil) or (havePillNum <= 0)) then
        AnimationTip.showTip(GetLocalizeStringBy("lgx_1047"))
        return
    end

    local eatNum  = PillData.getPillNumByType(curType) -- 已服用数量
    local fullPillNum = PillData.getPillTotalPageNumByType(curType) -- 总共需要服用的丹药数量
    -- 丹药位已满 "当前丹药位已满"
    if(eatNum >= fullPillNum)then
        AnimationTip.showTip(GetLocalizeStringBy("lgx_1048"))
        return
    end

    local pHeroId = PillLayer.getHeroInfo().hid -- 获取武将ID
    local lastFightForce = FightForceModel.dealParticularValues(pHeroId) -- 获取武将之前属性
    -- 请求回调
    local requestCallback = function ( pData )

        -- 刷新丹药数据
        PillData.updateAllPillData(pHeroId,pData.pill)

        -- 刷新丹药背包数据缓存
        PillData.updateBagCache(pData.bagModify)

        -- 刷新武将属性
        PillData.getAffixByHid(pHeroId,true)

        -- 刷新界面
        PillLayer.refreshUI()

        -- 飘字
        local curFight = FightForceModel.dealParticularValues(pHeroId)
        ItemUtil.showAttrChangeInfo(lastFightForce,curFight)
    end

    -- 请求后端
    PillService.addArrPills(pHeroId,curType,requestCallback)
end


--[[
    @des    :给sprite加效果
    @param  :sprite
--]]
function addActionToSprite(p_sprite)
    --动画
    local actionArray = CCArray:create()
    actionArray:addObject(CCFadeOut:create(1))
    actionArray:addObject(CCFadeIn:create(1))
    local sequence = CCSequence:create(actionArray)
    local action = CCRepeatForever:create(sequence)
    p_sprite:runAction(action)
end

--[[
    @desc   : 丹药全部合成,消耗材料合成当前所能合成的最大值
    @param  : pType 合成丹药类型
    @param  : pCallback 合成成功回调
    @return : 
--]]
function composeAllPill( pCallback, pType )
    require "script/ui/pill/PillComposeLayer"
    local composeNum = PillData.getMaxComposeNumByType(pType)
    if composeNum == 0 then
        -- 材料不够 
        AnimationTip.showTip(GetLocalizeStringBy("zzh_1320"))
        return
    elseif ItemUtil.isPropBagFull(true) then
        -- 道具背包 满了 关闭丹药合成界面
        PillComposeLayer.removeBgLayer()
        return
    end

    -- 加屏蔽层
    PillComposeLayer.addMaskLayer()

    -- 请求回调
    local requestCallback = function(retData)
        if (retData == "err") then
            -- 材料不够 
            AnimationTip.showTip(GetLocalizeStringBy("zzh_1320"))
            PillComposeLayer.removeMaskLayer()
        else
            if pCallback then
                pCallback(retData)
            end
        end
    end
    -- 发送合成请求给后端
    local pIndex = PillData.getIndexByPillType(pType)
    PillService.fusePill(requestCallback,pIndex,1)
end

--[[
    @desc   : 丹药合成,消耗材料合成1个丹药
    @param  : pType 合成丹药类型
    @param  : pCallback 合成成功回调
    @return : 
--]]
function composeOnePill( pCallback, pType )
    require "script/ui/pill/PillComposeLayer"
    local composeNum = PillData.getMaxComposeNumByType(pType)
    if composeNum == 0 then
        -- 材料不够 
        AnimationTip.showTip(GetLocalizeStringBy("zzh_1320"))
        return
    elseif ItemUtil.isPropBagFull(true) then
        -- 道具背包 满了 关闭丹药合成界面
        PillComposeLayer.removeBgLayer()
        return
    end

    -- 加屏蔽层
    PillComposeLayer.addMaskLayer()

    -- 请求回调
    local requestCallback = function(retData)
        if (retData == "err") then
            -- 材料不够 
            AnimationTip.showTip(GetLocalizeStringBy("zzh_1320"))
            PillComposeLayer.removeMaskLayer()
        else
            if pCallback then
                pCallback(retData)
            end
        end
    end
    -- 发送合成请求给后端
    local pIndex = PillData.getIndexByPillType(pType)
    PillService.fusePill(requestCallback,pIndex,0)
end
