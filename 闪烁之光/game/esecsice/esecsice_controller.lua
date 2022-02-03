-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-09-01
-- --------------------------------------------------------------------
EsecsiceController = EsecsiceController or BaseClass(BaseController)

function EsecsiceController:config()
    self.model = ActivityModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function EsecsiceController:getModel()
    return self.model
end

function EsecsiceController:registerEvents()

end

function EsecsiceController:registerProtocals()
    
end

function EsecsiceController:openEsecsiceView(bool)
    if bool == true then 
        if not self.esecsiceView then
            self.esecsiceView = EsecsiceWindow.New()
        end
        self.esecsiceView:open()
    else
        if self.esecsiceView then 
            self.esecsiceView:close()
            self.esecsiceView = nil
        end
    end
end

--- 引导使用
function  EsecsiceController:getEsecsiceRoot()
    if self.esecsiceView then
        return self.esecsiceView.root_wnd
    end
end

function EsecsiceController:switchEcersiceActivityView(type)
    if type == EsecsiceConst.exercise_index.endless then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Endless)
    elseif type == EsecsiceConst.exercise_index.stonedungeon then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.DungeonStone)
    elseif type == EsecsiceConst.exercise_index.honourfane then --荣耀神殿玩法
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PrimusWar)
    elseif type == EsecsiceConst.exercise_index.heroexpedit then
        --HeroExpeditController:getInstance():requestEnterHeroExpedit()
        -- PlanesController:getInstance():openPlanesMainWindow(true)
        -- PlanesafkController:getInstance():openPlanesafkMainWindow(true)
        PlanesafkController:getInstance():sender28601()
    end
end

function EsecsiceController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
