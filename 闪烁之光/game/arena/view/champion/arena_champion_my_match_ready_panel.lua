-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      我的竞赛等待界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionMyMatchReadyPanel = class("ArenaChampionMyMatchReadyPanel", function()
	return ccui.Layout:create()
end)

local string_format = string.format
local game_net = GameNet:getInstance()

function ArenaChampionMyMatchReadyPanel:ctor(view_type)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_champion_my_match_ready_panel"))

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end
	
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd) 

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    local info_panel = container:getChildByName("info_panel")
    info_panel:setLocalZOrder(1)

    self.left_img = container:getChildByName("left_img")
    self.left_img:ignoreContentAdaptWithSize(true) 
    self.right_img = container:getChildByName("right_img")
    self.right_img:ignoreContentAdaptWithSize(true) 

    if self.view_type == ArenaConst.champion_type.normal then
        local res = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_46")
        self.resource_load = createResourcesLoad(res, ResourcesType.single, function() 
            self.left_img:loadTexture(res,LOADTEXT_TYPE)
            self.right_img:loadTexture(res,LOADTEXT_TYPE)
        end)
        self.left_img:setVisible(true)
        self.right_img:setVisible(true)
        self:handleFlagEffect(false)
    else
        self.left_img:setVisible(false)
        self.right_img:setVisible(false)
        self:handleFlagEffect(true)
    end

    self.image_title = info_panel:getChildByName("Image_3")
    self.image_title:ignoreContentAdaptWithSize(true) 
    if self.view_type == ArenaConst.champion_type.normal then
        self.image_title:loadTexture(PathTool.getResFrame("arena","arenachampion_1004",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
    else
        self.image_title:loadTexture(PathTool.getResFrame("arena","arenachampion_1033",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
    end
    self.notice_label = info_panel:getChildByName("notice_label")

    self.extend_desc = createRichLabel(24, cc.c4b(0xff,0xf3,0x91,0xff), cc.p(0, 1), cc.p(92, 228), 2, nil, 278)
    info_panel:addChild(self.extend_desc)

    if self.view_type == ArenaConst.champion_type.normal then
        local base_config = Config.ArenaChampionData.data_const.battle_members
        if base_config then
            self.need_rank_index = base_config.val
        else
            self.need_rank_index = 128
        end
    else
        local base_config = Config.ArenaClusterChampionData.data_const.battle_members
        if base_config then
            self.need_rank_index = base_config.val
        else
            self.need_rank_index = 256
        end
    end
end

function ArenaChampionMyMatchReadyPanel:handleFlagEffect( status )
    if status == false then
        if self.flag_effect then
            self.flag_effect:clearTracks()
            self.flag_effect:removeFromParent()
            self.flag_effect = nil
        end
    else
        if not tolua.isnull(self.container) and self.flag_effect == nil then
            self.flag_effect = createEffectSpine(Config.EffectData.data_effect_info[1321], cc.p(222, -23), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.container:addChild(self.flag_effect)
        end
    end
end

function ArenaChampionMyMatchReadyPanel:addToParent(status)
    self:setVisible(status)
    if status == false then
        self:clearTimeTicket()
    end
end

function ArenaChampionMyMatchReadyPanel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

--==============================--
--desc:主窗口用于更新的处理
--time:2018-08-04 10:43:02
--@return 
--==============================--
function ArenaChampionMyMatchReadyPanel:updateInfo()
    local my_status = self.model:getMyMatchStatus()
    if my_status == ArenaConst.champion_my_status.in_match then return end

    if my_status == ArenaConst.champion_my_status.unopened then
        if self.view_type == ArenaConst.champion_type.normal then
            self.notice_label:setString(TI18N("本次冠军赛尚未开启"))
        else
            self.notice_label:setString(TI18N("本次周冠军赛尚未开启"))
        end
        if self.time_ticket == nil then
            self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                self:countDownTimeTicket()
            end, 1)
        end 
        self:countDownTimeTicket()
    elseif my_status == ArenaConst.champion_my_status.unjoin then
        if self.view_type == ArenaConst.champion_type.normal then
            self.notice_label:setString(TI18N("您未能参与本次冠军赛"))
        else
            self.notice_label:setString(TI18N("您未能参与本次周冠军赛"))
        end
        str = string_format(TI18N("可前往竞猜界面参与竞猜玩法，各种稀有道具等你来兑换"))
        self.extend_desc:setString(str) 
    end
end

--==============================--
--desc:倒计时处理
--time:2018-08-04 11:35:30
--@return 
--==============================--
function ArenaChampionMyMatchReadyPanel:countDownTimeTicket()
    local base_info = self.model:getBaseInfo()
    if base_info == nil then 
        self:clearTimeTicket()
        return
    end
    local less_time = base_info.step_status_time - game_net:getTime()
	-- local less_time = base_info.end_time - GameNet:getInstance():getTime()
    if less_time < 0 then
        less_time = 0
        self:clearTimeTicket()
    end
    local str = string_format(TI18N("开启倒计时:<div fontColor=#66e734 >%s</div>\n竞技场排名前<div fontColor=#66e734 >%s名</div>的玩家将自动参与"), TimeTool.GetTimeFormat(less_time) , self.need_rank_index)
    if self.view_type == ArenaConst.champion_type.cross then
        str = string_format(TI18N("开启倒计时:<div fontColor=#66e734 >%s</div>\n跨服天梯前<div fontColor=#66e734 >%s名</div>的玩家将自动参与"), TimeTool.GetTimeFormat(less_time) , self.need_rank_index)
    end
    self.extend_desc:setString(str)
end

function ArenaChampionMyMatchReadyPanel:DeleteMe()
    self:clearTimeTicket()
    self:handleFlagEffect(false)
    if self.resource_load then
        self.resource_load:DeleteMe()
        self.resource_load = nil
    end
end
