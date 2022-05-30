-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      通用的 ui 控制器
-- <br/>Create: 2019年10月28日
-- --------------------------------------------------------------------
CommonUIController = CommonUIController or BaseClass(BaseController)

function CommonUIController:config()
    -- self.model = ActiontermbeginsModel.New(self)
end

-- function CommonUIController:getModel()
--     return self.model
-- end

function CommonUIController:registerEvents()
    
end

function CommonUIController:registerProtocals()
end


--打开活动主界面
function CommonUIController:openCommonComboboxPanel(status, world_pos, callback, data_list, setting)
    if status == false then
        if self.common_combobox_panel ~= nil then
            self.common_combobox_panel:close()
            self.common_combobox_panel = nil
        end
    else
        if self.common_combobox_panel == nil then
            self.common_combobox_panel = CommonComboboxPanel.New()
        end
        self.common_combobox_panel:open(world_pos, callback, data_list, setting)
    end
end


function CommonUIController:__delete()
    -- if self.model ~= nil then
    --     self.model:DeleteMe()
    --     self.model = nil
    -- end
end