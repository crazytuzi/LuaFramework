-- Filename: UserUtil.lua
-- Author: all
-- Date: 2013-06-07
-- Purpose: 用户工具方法

module ("UserUtil", package.seeall)

-- 用户信息结构
--[[
    uid:  -- 用户id
    uname: 用户名字
    utid: 用户模板id
    execution: 当前行动力
    execution_time: 上次恢复行动力时间
    vip: vip等级
    silver_num: 银两
    gold_num: 金币RMB
    experience_num: 阅历
    fight_cdtime: 战斗冷却
    ban_chat_time: 禁言结束时间
--]]

--更新用户信息
function updateUser (userInfo)
    if userInfo == nil then
        return false
    end
    require "script/model/user/UserModel"
    UserModel.setUserInfo(userInfo)
    --通知主界面更新信息
    require "script/ui/main/MainScene"
    MainScene.refreshAvatarInfo()
end 

--获得用户信息
function getUserInfo()
    require "script/model/user/UserModel"
    return UserModel.getUserInfo()
end

--是否可发言，true为可发言，false为不可，方法未写完
function isChatable()
    require "script/model/user/UserModel"
    if(UserModel.getUserInfo().ban_chat_time<=0) then
        return true
    else
        return false
    end
end

--[[
    @des    : 得到vip继承提示
    @param  : p_vipNum 
    @return : sprite
--]]
function getVipTipSpriteByVipNum( p_vipNum )
    local retSprite = CCScale9Sprite:create("images/common/bg/hui_bg.png")
    retSprite:setContentSize(CCSizeMake(500,50))

    -- 描述
    local fontTab = {}
    fontTab[1] = CCSprite:create("images/common/viptip.png")

    require "script/libs/LuaCC"
    fontTab[2] = LuaCC.createSpriteOfNumbers("images/common/vip", p_vipNum, 18)

    require "script/utils/BaseUI"
    local desNode = BaseUI.createHorizontalNode(fontTab)
    desNode:setAnchorPoint(ccp(0.5,0.5))
    desNode:setPosition(ccp(retSprite:getContentSize().width*0.5, retSprite:getContentSize().height*0.5))
    retSprite:addChild(desNode)

    return retSprite
end




