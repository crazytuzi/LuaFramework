-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-02-20
-- --------------------------------------------------------------------
TimesummonModel = TimesummonModel or BaseClass()

function TimesummonModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function TimesummonModel:config()
end

-- 根据获得召唤物品获取对应的特效组合
-- 获取特效类型
--[[
底盘特效+光束特效
紫色弱光（4星碎片）：action3+action4
橙色弱光（5星碎片）：action2+action5
蓝色强光（3星英雄）：action1+action1
紫色强光（4星英雄）：action3+action3
橙色强光（5星英雄）：action2+action2
]]
function TimesummonModel:getEffectAction( award_list )
	local index = 1
	for k,v in pairs(award_list) do
		local item_cfg = Config.ItemData.data_get_data(v.base_id)
		if item_cfg then
			if item_cfg.type == 102 then -- 碎片
				if item_cfg.eqm_jie == 4 and index < 2 then
					index = 2
				elseif item_cfg.eqm_jie == 5 and index < 3 then
					index = 3
				end
			else
				if item_cfg.eqm_jie == 3 and index <= 1 then
					index = 1
				elseif item_cfg.eqm_jie == 4 and index < 4 then
					index = 4
				elseif item_cfg.eqm_jie == 5 and index < 5 then
					index = 5
				end
			end
		end
	end

	local action_list = TimesummonConst.Action_Group[index]
	return action_list[1], action_list[2]
end

function TimesummonModel:__delete()
end