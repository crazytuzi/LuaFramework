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
TipsModel = TipsModel or BaseClass()

function TipsModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function TipsModel:config()
end

function TipsModel:__delete()
end