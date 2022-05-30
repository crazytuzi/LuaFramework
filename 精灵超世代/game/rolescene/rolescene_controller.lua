-- --------------------------------------------------------------------
-- 有角色移动的场景控制器
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-10-09
-- --------------------------------------------------------------------
RolesceneController = RolesceneController or BaseClass(BaseController)

function RolesceneController:config()
    self.model = RolesceneModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function RolesceneController:getModel()
    return self.model
end

function RolesceneController:registerEvents()
end

function RolesceneController:registerProtocals()
	self:RegisterProtocal(10200, "on10200") -- 操作地图单位
	self:RegisterProtocal(10210, "on10210") -- 服务端通知地图切换
    self:RegisterProtocal(10213, "on10213") -- 角色进入地图事件
    self:RegisterProtocal(10214, "on10214") -- 角色离开地图事件
    self:RegisterProtocal(10215, "on10215") -- 角色移动事件
    self:RegisterProtocal(10220, "on10220") -- 推送当前地图单位列表
    self:RegisterProtocal(10222, "on10222") -- 推送当前角色列表
    self:RegisterProtocal(10260, "on10260") -- 单位进入地图事件
    self:RegisterProtocal(10262, "on10262") -- 单位离开地图事件

    self:RegisterProtocal(10216, "on10216") -- 服务端主动发送的新网格的角色列表
    self:RegisterProtocal(10217, "on10217") -- 角色信息更新事件
    self:RegisterProtocal(10218, "on10218") -- 角色传送事件
    self:RegisterProtocal(10219, "on10219") -- 外观变化处理
    self:RegisterProtocal(10266, "on10266") -- 单位信息更新事件
end


function RolesceneController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--==============================--
--desc:退出角色自由移动场景
--time:2017-10-09 11:17:23
--@return 
--==============================--
function RolesceneController:exitRoleScene(enter_city)
    if self.model:getScene() == nil then return end
    if self.model then
        self.model:DeleteMe()
    end
    self.last_pos = nil

    -- -- 因为退出角色场景是请求服务器返回退出的,这个时候就有可能是点击切换其他场景更快,所以这个时候不能更改状态了
    -- local scene_status = MainSceneController:getInstance():getSceneStatus()
    -- if scene_status == MainSceneStatus.role_scene then
    --     MainSceneController:getInstance():setSceneStatus(MainSceneStatus.none)
    -- end

    -- --联盟领地的
    -- if self.is_enter_main == true or enter_city == true then
    --     self.is_enter_main = nil
    --     MainSceneController:getInstance():requestEnterMainScene(true)
    -- end
    
    -- MainuiController:getInstance():removeFunctionIconById(MainuiController.icon.exit_map)
    -- MainuiController:getInstance():removeFunctionIconById(MainuiController.icon.guild_hall)
end

--==============================--
--desc:设置显示或者隐藏角色地图
--time:2017-10-10 08:25:25
--@status:
--@return 
--==============================--
function RolesceneController:handleRoleScene(status)
    self.model:handleScene(status)
end

--==============================--
--desc:请求操作单位
--time:2017-10-09 10:30:01
--@battle_id:
--@id:
--@code:
--@return 
--==============================--
function RolesceneController:requestHandleUnit(battle_id, id, code)
    code = code or 0
    local protocal = {}
    protocal.battle_id = battle_id
    protocal.id = id
    protocal.code = code
    self:SendProtocal(10200,protocal)
end
function RolesceneController:on10200(data)
    if data.result == FALSE then
        message(data.msg)
    end
end

--==============================--
--desc:请求退出当前地图
--time:2017-10-10 08:48:28
--@return 
--==============================--
function RolesceneController:requestExitRoleScene(status)
    if self.model:getScene() ~= nil then
        self.is_enter_main = status
        self:SendProtocal(13567,{})
    end
end

--==============================--
--desc:服务端通知切换地图
--time:2017-10-09 10:35:33
--@data:
--@return 
--==============================--
function RolesceneController:on10210(data)
    if data.bid == 0 then
        self:exitRoleScene()
    elseif data.bid == 1 then
        self:exitRoleScene(true)
    else
        -- 把主城隐藏掉
        MainSceneController:getInstance():destroyMainScene(MainSceneStatus.role_scene)
        --如果是副本玩法场景，隐藏主界面
        if self:isHideMainUI(data.bid) == true or data.bid == Config.CrossHallData.data_const.hall_map.val then 
            MainuiController:getInstance():openMainUI(false)
        end
        self.model:changeScene(data)
    end
end

--判断是否是副本玩法活动场景
function RolesceneController:isHideMainUI(bid)
    bid = bid or 0
    local config = Config.Map[bid]
    if not config then return false end
    if not config.client_type then return false end
    if config.client_type == 1 or config.client_type == 2 then 
        return true
    end
    return false
end
--==============================--
--desc:角色进入场景事件
--time:2017-10-09 12:01:45
--@data:
--@return 
--==============================--
function RolesceneController:on10213(data)
    self.model:addRole(data)
end

--==============================--
--desc:角色离场事件
--time:2017-10-09 01:51:05
--@data:
--@return 
--==============================--
function RolesceneController:on10214(data)
    if self.model and self.model:getSceneId() == data.bid then
		for _, v in pairs(data.role_ids) do 
			self.model:removeRole(v.srv_id, v.rid)
		end
    end
end

--==============================--
--desc:单位进入场景事件
--time:2017-10-09 12:01:45
--@data:
--@return 
--==============================--
function RolesceneController:on10260(data)
    self.model:addUnit(data)
end
--==============================--
--desc:单位离场事件
--time:2017-10-09 01:51:05
--@data:
--@return 
--==============================--
function RolesceneController:on10262(data)
    if self.model and data then 
		self.model:removeUnit(data.id,data.battle_id)
    end
end

--==============================--
--desc:单位更新事件
--time:2017-10-09 01:51:05
--@data:
--@return 
--==============================--
function RolesceneController:on10266(data)
    self.model:addUnit(data)
end
--==============================--
--desc:移动请求
--time:2017-10-09 02:02:51
--@pos:
--@dir:
--@return 
--==============================--
function RolesceneController:move(pos, dir)
    pos = pos or cc.p(0, 0)
    local _x = math.floor(math.max(pos.x, 0))
    local _y = math.floor(math.max(pos.y, 0))
    if self.last_pos ~= nil then
        if self.last_pos.x == _x and self.last_pos.y == _y then return end
        self.last_pos = cc.p(_x, _y)
    end
    local protocal = {}
    protocal.x = _x
    protocal.y = _y
    protocal.dir = dir
    protocal.base_id = self.model:getSceneId()
    self:SendProtocal(10215, protocal)
end

--==============================--
--desc:广播其他玩家移动
--time:2017-10-09 01:57:49
--@data:
--@return 
--==============================--
function RolesceneController:on10215(data)
	if data then
		self.model:syncRoles(data)
	end
end

--==============================--
--desc:服务端主动发送新网格的角色列表
--time:2017-10-09 02:07:47
--@data:
--@return 
--==============================--
function RolesceneController:on10216(data)
    if data and next(data.role_list) ~= nil then 
        for _, v in pairs(data.role_list) do
            self:on10213(v)
        end
    end
end

--==============================--
--desc:附近角色进入
--time:2017-10-09 02:09:23
--@data:
--@return 
--==============================--
function RolesceneController:on10217(data)
    self:on10213(data)
end

--==============================--
--desc:角色瞬移
--time:2017-10-09 02:09:23
--@data:
--@return 
--==============================--
function RolesceneController:on10218(data)
    -- data.x = data.dx
    -- data.y = data.dy
    self.model:updateHeroPos(data)
end

--==============================--
--desc:场景所有单位信息
--time:2017-10-09 02:10:23
--@data:
--@return 
--==============================--
function RolesceneController:on10220(data)
	for _, v in pairs(data.unit_list) do
		self.model:addUnit(v)
	end
end

--==============================--
--desc:场景所有角色信息
--time:2017-10-09 02:10:45
--@data:
--@return 
--==============================--
function RolesceneController:on10222(data)
	for _, v in pairs(data.role_list) do
        self:on10213(v)
	end	
end

--==============================--
--desc:外观变化处理
--time:2017-10-12 04:27:46
--@data:
--@return 
--==============================--
function RolesceneController:on10219(data)
    self.model:updateRoleLooks(data)
end

--判断是否在首席争霸
function RolesceneController:getIsInChiefWar()
    local bid = self:getSceneID() or 0
    local config = Config.Map[bid]
    if not config then return false end
    if config.client_type == RolesceneConst.type.chiefwar_formal then 
        return true
    end
    return false
end

function RolesceneController:getSceneID()
    local scene_id = self.model:getSceneId() or 0
    return scene_id
end