-- --------------------------------------------------------------------
-- 子活动的显示数据,主要是左侧标签以及部分活动面板内部使用
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
ActionSubTabVo = ActionSubTabVo or BaseClass(EventDispatcher)

ActionSubTabVo.UPDATE_TIPS_STATUS = "ActionSubTabVo.UPDATE_TIPS_STATUS"

function ActionSubTabVo:__init()
    self.bid = 0            --子活动编号
	self.sort_val = 0       --排序
	self.title = ""         --子活动标题
    self.ico = ""           --子活动左侧图标
	self.type_ico = 0       --子活动热门等戳
	self.panel_type = 0     --子活动客户端面板类型(3-介绍)

    self.is_show_in_action = true
    
    ----------------------以上是标签需要的数据,下面是扩展数据,不一定需要

    self.reward_title = ""  --子活动子项背景
	self.aim_title = ""     --子活动目标标题(现在用于活动标签面板的背景)
    self.title2 = ""        --子活动标题2,显示在横幅上面
	self.top_banner = ""    --子活动顶部横幅图片
	self.rule_str = ""      --子活动规则
	self.time_str = ""      --子活动时间
	self.bottom_alert = ""  --子活动底部提示
	self.channel_ban = ""   --不显示的渠道(只有客户端用)
	self.remain_sec = 0     --子活动剩余活动秒数

    self.cli_type = 0       --活动类型,现在对应的是活动图标id
    self.cli_type_name = "" --活动图标的名字,动态调整

    self.camp_id = 0        --活动编号

    self.tips_status = false
end

function ActionSubTabVo:update(data)
    if data then
        for k, v in pairs(data) do
            self:setParam(k, v)
        end
    end
end

--==============================--
--desc:设置是否在活动界面显示
--time:2018-10-19 02:21:31
--@status:
--@return 
--==============================--
function ActionSubTabVo:setShowStatus(status)
    self.is_show_in_action = status
end

function ActionSubTabVo:isShowInAction()
    return self.is_show_in_action
end

function ActionSubTabVo:setTipsStatus(status)
    self.tips_status = status ~= FALSE
    self:Fire(ActionSubTabVo.UPDATE_TIPS_STATUS)
end

function ActionSubTabVo:setParam(key, value)
    if self[key] ~= value then
        self[key] = value
    end
end