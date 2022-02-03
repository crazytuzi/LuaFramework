--******** 文件说明 ********
-- @Author:      lc 
-- @description: 
-- @DateTime:    2019-03-28 20:25:00
LimitTimeActionModel = LimitTimeActionModel or BaseClass()

function LimitTimeActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function LimitTimeActionModel:config()
end


function LimitTimeActionModel:__delete()
end
