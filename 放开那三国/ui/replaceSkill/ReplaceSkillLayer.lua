-- Filename: ReplaceSkillLayer.lua
-- Author: zhangqiang
-- Date: 2014-08-04
-- Purpose: 主将更换技能主界面

module("ReplaceSkillLayer",package.seeall)


--[[
	desc :	根据技能id创建技能图标
--]]
require "db/skill"
function createSkillIcon(p_skillId)
	p_skillId = tonumber(p_skillId)
	local skillIconBg = CCSprite:create("images/item/bg/itembg_4.png")
	local skillIconSize = skillIconBg:getContentSize()

	local skillTemplate = skill.getDataById(tonumber(p_skillId))
	print("createSkillIcon",p_skillId)
	local skillIconSprite = CCSprite:create("images/replaceskill/skillicon/" .. skillTemplate.roleSkillPic)
	skillIconSprite:setAnchorPoint(ccp(0.5,0.5))
	skillIconSprite:setPosition(skillIconSize.width/2, skillIconSize.height/2)
	skillIconBg:addChild(skillIconSprite)

	return skillIconBg
end
