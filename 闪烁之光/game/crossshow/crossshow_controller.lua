-- --------------------------------------------------------------------
-- 跨服时空
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      跨服时空, 策划 晓勤 后端 爵爷
-- <br/>Create: 2019-03-15
-- --------------------------------------------------------------------
CrossshowController = CrossshowController or BaseClass(BaseController)

function CrossshowController:config()
    self.model = CrossshowModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function CrossshowController:getModel()
    return self.model
end

function CrossshowController:registerEvents()

end

function CrossshowController:registerProtocals()
    self:RegisterProtocal(22150, "handle22150")  --跨服时空当前信息
end

--:跨服时空当前信息
function CrossshowController:sender22150()
    local protocal = {}
    self:SendProtocal(22150, protocal)
end
function CrossshowController:handle22150(data)
    GlobalEvent:getInstance():Fire(CrossshowEvent.Get_Cross_Show_Info_Event, data)
end



--打开跨服战场主界面
function CrossshowController:openCrossshowMainWindow(status)
    if status == true then
        if self.cross_show_main_window == nil then
            self.cross_show_main_window = CrossshowMainWindow.New()
        end
        if self.cross_show_main_window:isOpen() == false then
            self.cross_show_main_window:open(index)
        end
    else
        if self.cross_show_main_window then
            self.cross_show_main_window:close()
            self.cross_show_main_window = nil
        end
    end
end

function CrossshowController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end