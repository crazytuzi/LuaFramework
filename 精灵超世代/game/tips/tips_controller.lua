-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: cloud@1206802428@qq.com(必填, 创建模块的人员)
-- @editor: cloud@1206802428@qq.com(必填, 后续维护以及修改的人员)
-- @description:
--    tips的相关处理
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-02-15
-- --------------------------------------------------------------------
TipsController = TipsController or BaseClass(BaseController)

function TipsController:config()
    self.model = TipsModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function TipsController:getModel()
    return self.model
end

function TipsController:registerEvents()
end

function TipsController:registerProtocals()
end

--==============================--
--desc:来源跳转
--time:2017-07-01 11:53:25
--@index:跳转ID
--@return 
--==============================--
function TipsController:openSourceByIndex(index)
    index = index or 1
    if index == 1 then
    
    elseif index >= 4 and index <= 9 then 
         MainuiController:getInstance():openDungeonWithBid(MainuiModel.DUN_ENTER_BIND_ID.Meterial)
    end
end

--==============================--
--desc:
--time:2018-07-05 05:17:45
--@value:支持传过来的是source_data的数据，也可以直接是来源id
--@return 
--==============================--
function TipsController:clickSourceBtn(value)
    local config 
    if type(value) == "number" then 
        config = Config.SourceData.data_source_data[value]
    else
        config = value
    end
	if config and config.evt_type and config.extend then
		local evt_type = config.evt_type
		local extend = config.extend
        BackpackController:getInstance():gotoItemSources(evt_type, extend)
	end
end


--打开历练任务tips
function TipsController:openTaskExpTips(status, setting)
    if status == false then
        if self.task_exp_tips ~= nil then
            self.task_exp_tips:close()
            self.task_exp_tips = nil
        end
    else
        if self.task_exp_tips == nil then
            self.task_exp_tips = TaskExpTips.New()
        end
        if self.task_exp_tips:isOpen() == false then
            self.task_exp_tips:open(setting)
        end
    end
end

--打开荣誉icon tips
function TipsController:openHonorIconTips(status, setting)
    if status == false then
        if self.honor_icon_tips ~= nil then
            self.honor_icon_tips:close()
            self.honor_icon_tips = nil
        end
    else
        if self.honor_icon_tips == nil then
            self.honor_icon_tips = HonorIconTips.New()
        end
        if self.honor_icon_tips:isOpen() == false then
            self.honor_icon_tips:open(setting)
        end
    end
end

--打开荣誉等级 tips
function TipsController:openHonorLevelTips(status, setting)
    if status == false then
        if self.honor_level_tips ~= nil then
            self.honor_level_tips:close()
            self.honor_level_tips = nil
        end
    else
        if self.honor_level_tips == nil then
            self.honor_level_tips = HonorLevelTips.New()
        end
        if self.honor_level_tips:isOpen() == false then
            self.honor_level_tips:open(setting)
        end
    end
end
--打开荣誉等级 tips
function TipsController:openHonorNextLevelTips(status, setting)
    if status == false then
        if self.honor_next_level_tips ~= nil then
            self.honor_next_level_tips:close()
            self.honor_next_level_tips = nil
        end
    else
        if self.honor_next_level_tips == nil then
            self.honor_next_level_tips = HonorNextLevelTips.New()
        end
        if self.honor_next_level_tips:isOpen() == false then
            self.honor_next_level_tips:open(setting)
        end
    end
end


function TipsController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end