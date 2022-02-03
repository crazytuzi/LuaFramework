-- --------------------------------------------------------------------
-- 跨服时空
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      跨服时空, 策划 晓勤 后端 爵爷
-- <br/>Create: 2019-03-15
-- --------------------------------------------------------------------
CrossshowModel = CrossshowModel or BaseClass()

function CrossshowModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function CrossshowModel:config()
end

function CrossshowModel:__delete()
end