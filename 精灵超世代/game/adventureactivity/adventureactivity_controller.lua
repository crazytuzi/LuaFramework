-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- --------------------------------------------------------------------
AdventureActivityController = AdventureActivityController or BaseClass(BaseController)

function AdventureActivityController:config()
    self.model = AdventureActivityModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function AdventureActivityController:getModel()
    return self.model
end

function AdventureActivityController:registerEvents()
end

function AdventureActivityController:registerProtocals()
end

---------------------------@ 界面相关
-- 打开冒险活动主界面
function AdventureActivityController:openAdventureActivityMainWindow(status)
	if status == true then
		if self.adventure_activity_window == nil then
			self.adventure_activity_window = AdventureActivityWindow.New()
		end
		if self.adventure_activity_window:isOpen() == false then
			self.adventure_activity_window:open()
		end
	else
		if self.adventure_activity_window then
			self.adventure_activity_window:close()
			self.adventure_activity_window = nil
		end
	end
end

-- 宝可梦神装穿戴
function AdventureActivityController:getAdventureActivityWindowRoot(  )
    if self.adventure_activity_window ~= nil then
        return self.adventure_activity_window.root_wnd
    end
end


-- 点击冒险活动item
function AdventureActivityController:onClickGotoAdvenTureAcivity(id)
	if id == AdventureActivityConst.Ground_Type.adventure then  -- 冒险
		AdventureController:getInstance():requestEnterAdventure()
	elseif id == AdventureActivityConst.Ground_Type.element then -- 元素神殿
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ElementWar)
	elseif id == AdventureActivityConst.Ground_Type.heaven then  -- 天界副本
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.HeavenWar) 
    elseif id == AdventureActivityConst.Ground_Type.adventure_mine then --秘矿冒险
        AdventureController:getInstance():requestEnterMaxAdventureMine()
	end
end
--判断活动是否开启 true:开启  false：未开启
function AdventureActivityController:isOpenActivity(id)
    if not Config.CrossGroundData then return false end
	local data = Config.CrossGroundData.data_adventure_activity
	if not data then return false end
	local status = false
	if data[id] then
		local is_open = MainuiController:getInstance():checkIsOpenByActivate(data[id].activate)
		local is_open_2 = MainuiController:getInstance():checkIsOpenByActivate(data[id].activate_2)
        if is_open == true or is_open_2 == true then
            status = true
        end
	end
	return status
end

function AdventureActivityController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end