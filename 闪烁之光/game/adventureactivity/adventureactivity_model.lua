-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- --------------------------------------------------------------------
AdventureActivityModel = AdventureActivityModel or BaseClass()

function AdventureActivityModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function AdventureActivityModel:config()
end

function AdventureActivityModel:__delete()
end