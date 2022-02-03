-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-03-02
-- --------------------------------------------------------------------
CrossgroundController = CrossgroundController or BaseClass(BaseController)

function CrossgroundController:config()
    self.model = CrossgroundModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function CrossgroundController:getModel()
    return self.model
end

function CrossgroundController:registerEvents()
end

function CrossgroundController:registerProtocals()
end

---------------------------@ 界面相关
-- 打开跨服战场主界面
function CrossgroundController:openCrossGroundMainWindow( status )
	if status == true then
		if self.cross_ground_window == nil then
			self.cross_ground_window = CrossgroundMainWindow.New()
		end
		if self.cross_ground_window:isOpen() == false then
			self.cross_ground_window:open()
		end
	else
		if self.cross_ground_window then
			self.cross_ground_window:close()
			self.cross_ground_window = nil
		end
	end
end

-- 点击跨服战场item
function CrossgroundController:onClickCrossgroundItem( id )
	if id == CrossgroundConst.Ground_Type.Ladder then  -- 跨服天梯
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LadderWar)
	elseif id == CrossgroundConst.Ground_Type.EliteMatch then -- 精英大赛
        ElitematchController:getInstance():openElitematchMainWindow(true)
	elseif id == CrossgroundConst.Ground_Type.CrossArena then -- 跨服竞技场
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossArenaWar)
    elseif id == CrossgroundConst.Ground_Type.CrossChampion then -- 跨服冠军赛
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.CrossChampion)
    elseif id == CrossgroundConst.Ground_Type.Arenateam then -- 组队竞技场
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arean_Team)
    elseif id == CrossgroundConst.Ground_Type.peakChampion then -- 巅峰冠军赛
        ArenapeakchampionController:getInstance():openArenapeakchampionMainWindow(true)
	end
end

function CrossgroundController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end