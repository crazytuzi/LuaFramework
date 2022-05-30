-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-19
-- --------------------------------------------------------------------
GuildskillController = GuildskillController or BaseClass(BaseController)

function GuildskillController:config()
    self.model = GuildskillModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildskillController:getModel()
    return self.model
end

function GuildskillController:registerEvents()
    -- 背包初始化之后,再请求公会信息,因为要判断是否可以升级技能的
    if self.backpack_init_event == nil then
        self.backpack_init_event = GlobalEvent:getInstance():Bind(BackpackEvent.GET_ALL_DATA, function(bag_code)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self.role_vo = RoleController:getInstance():getRoleVo() 
            if self.role_vo  == nil then
                if self.init_role_event == nil then
                    self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
                        GlobalEvent:getInstance():UnBind(self.init_role_event)
                        self.role_vo = RoleController:getInstance():getRoleVo() 
                        if self.role_vo then
                            self:registerRoleEvent()
                        end
                    end)
                end
            else
                self:registerRoleEvent()
            end
        end)
    end

    if self.re_link_game_event == nil then
	    self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            -- 断线重连关掉面板，同时清清掉数据
            self:openGuildSkillMainWindow(false)
            self.model:clearGuildCareerSkill()
            self:requestInitProtocal()
        end)
    end 
    
end

function GuildskillController:registerRoleEvent()
    self:requestInitProtocal(true)
    if self.role_assets_event == nil then
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "gid" then
                self:requestInitProtocal()
            elseif key == "guild" then -- 公会贡献变化的时候又要判断了
                self.model:checkGuildSkillRedStatus()
            end
        end)
    end 
end 

--==============================--
--desc:请求技能状态，用于初始化红点
--time:2018-06-23 11:56:55
--@return 
--==============================--
function GuildskillController:requestInitProtocal()
    print("请求技能状态，用于初始化红点")
    if self.role_vo ~= nil then
        if self.role_vo.gid ~= 0 then
            self:SendProtocal(23703, {})
            --公会pvp技能信息
            self:send23711()
        else
            self:openGuildSkillMainWindow(false)
            self.model:clearGuildCareerSkill()
        end
    end 
end

function GuildskillController:registerProtocals()
    self:RegisterProtocal(23700, "handle23700")         -- 获取指定职业技能信息
    self:RegisterProtocal(23701, "handle23701")         -- 激活技能
    self:RegisterProtocal(23702, "handle23702")         -- 更新当前分组技能
    self:RegisterProtocal(23703, "handle23703")         -- 可学习技能状态

    self:RegisterProtocal(23704, "handle23704")         -- 重置技能信息消耗
    self:RegisterProtocal(23705, "handle23705")         -- 确定重置技能

    --pvp技能的
    self:RegisterProtocal(23706, "handle23706")         -- 突破
    self:RegisterProtocal(23707, "handle23707")         -- 升级突破后的属性等级
    self:RegisterProtocal(23708, "handle23708")         -- 升级突破后的技能等级
    self:RegisterProtocal(23709, "handle23709")         -- 重置突破后的技能
    self:RegisterProtocal(23710, "handle23710")         -- 查看突破后该类型的信息
    self:RegisterProtocal(23711, "handle23711")         -- 返回所有数据
end

--==============================--
--desc:打开公会技能的主界面
--time:2018-06-19 10:08:41
--@status:
--@return 
--==============================--
function  GuildskillController:openGuildSkillMainWindow(status)
    if status == false then
        if self.main_window ~= nil then
            self.main_window:close()
            self.main_window = nil
        end
    else
        if self.main_window == nil then
            self.main_window = GuildskillMainWindow.New()
        end
        self.main_window:open()
    end
end

--==============================--
--desc:打开公会技能重置界面
--time:2019年3月11日
--@status:
--@return 
--==============================--
function  GuildskillController:openGuildskillResetPanel(status, career, reset_type)
    if status == false then
        if self.guild_skill_reset_panel ~= nil then
            self.guild_skill_reset_panel:close()
            self.guild_skill_reset_panel = nil
        end
    else
        if self.guild_skill_reset_panel == nil then
            self.guild_skill_reset_panel = GuildskillResetPanel.New()
        end
        self.guild_skill_reset_panel:open(career, reset_type)
    end
end
--==============================--
--desc:打开公会技能升级界面
--time:2020年4月12日
--@status:
--@return 
--==============================--
function  GuildskillController:openGuildskillLevelUpPanel(status, career)
    if status == false then
        if self.guildskill_level_up_panel ~= nil then
            self.guildskill_level_up_panel:close()
            self.guildskill_level_up_panel = nil
        end
    else
        if self.guildskill_level_up_panel == nil then
            self.guildskill_level_up_panel = GuildskillLevelUpPanel.New()
        end
        self.guildskill_level_up_panel:open(career)
    end
end
--==============================--
--desc:打开公会技能升级成功
--time:2020年4月12日
--@status:
--@return 
--==============================--
function  GuildskillController:openGuildskillLevelSuccessPanel(status, career)
    if status == false then
        if self.guildskill_level_success_panel ~= nil then
            self.guildskill_level_success_panel:close()
            self.guildskill_level_success_panel = nil
        end
    else
        if self.guildskill_level_success_panel == nil then
            self.guildskill_level_success_panel = GuildskillLevelSuccessPanel.New()
        end
        self.guildskill_level_success_panel:open(career)
    end
end

--==============================--
--desc:请求指定职业的技能信息
--time:2018-06-20 10:47:27
--@career:
--@return 
--==============================--
function GuildskillController:requestCareerSkillInfo(career)
    career = career or GuildskillConst.index.physics
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23700, protocal)
end

function GuildskillController:handle23700(data)
    self.model:initGuildCareerSkill(data)
end

--==============================--
--desc:请求激活技能
--time:2018-06-20 10:50:32
--@skill_id:
--@return 
--==============================--
function GuildskillController:requestActivitySkill(skill_id)
    local protocal = {}
    protocal.skill_id = skill_id
    self:SendProtocal(23701, protocal)
end

function GuildskillController:handle23701(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateGuildCareerSkill(data.career, data.skill_id)
        HeroController:getInstance():getModel():clearHeroVoDetailedInfo()
    end
end

--==============================--
--desc:更新指定职业的分组技能信息，这个时候是主要升级
--time:2018-06-20 10:53:19
--@data:
--@return 
--==============================--
function GuildskillController:handle23702(data)
    self.model:upgradeGuildCareerSkill(data.career, data.group_id)
end

--==============================--
--desc:可学习技能状态
--time:2018-06-23 12:00:51
--@data:
--@return 
--==============================--
function GuildskillController:handle23703(data)
    self.model:initGuildSkillStatus(data)
end

--==============================--
--desc:请求重置技能消耗
--time:2019年3月11日 
--@ 作者: lwc
--@return 
--==============================--
function GuildskillController:send23704(career)
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23704, protocal)
end

function GuildskillController:handle23704(data)
    GlobalEvent:getInstance():Fire(GuildskillEvent.UpdateSkillResetEvent, data)
end
--请求重置
function GuildskillController:send23705(career)
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23705, protocal)
end

function GuildskillController:handle23705(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:resetCareerSkillInfo(data.career)
    end
end

-- 突破
function GuildskillController:send23706(career)
    career = career or GuildskillConst.index.physics
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23706, protocal)
end

function GuildskillController:handle23706(data)
    message(data.msg) 
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(GuildskillEvent.Guild_Pvp_Career_Break_Event, data.career)
    end
end


--升级突破后的属性等级
function GuildskillController:send23707(career, id)
    career = career or GuildskillConst.index.physics
    local protocal = {}
    protocal.career = career
    protocal.id = id
    self.record_id = id
    self:SendProtocal(23707, protocal)
end

function GuildskillController:handle23707(data)
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(GuildskillEvent.Guild_Pvp_Career_Update_Event, data.career, 2, self.record_id)
    end
end

-- 升级突破后的技能等级
function GuildskillController:send23708(career)
    career = career or GuildskillConst.index.physics
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23708, protocal)
end

function GuildskillController:handle23708(data)
    message(data.msg)
    if data.flag == TRUE then
        if self.guildskill_level_up_panel then
            self:openGuildskillLevelUpPanel(false)
        end
        self:openGuildskillLevelSuccessPanel(true, data.career)
        GlobalEvent:getInstance():Fire(GuildskillEvent.Guild_Pvp_Career_Update_Event, data.career, 1)
    end
end

-- 重置突破后的技能
function GuildskillController:send23709(career)
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23709, protocal)
end

function GuildskillController:handle23709(data)
    message(data.msg)
    if data.flag == TRUE then
        self.model:setPvpFisrtReset(false)
    end
end

-- pvp单个creer职业 信息
function GuildskillController:send23710(career)
    career = career or GuildskillConst.index.physics
    local protocal = {}
    protocal.career = career
    self:SendProtocal(23710, protocal)
end

function GuildskillController:handle23710(data)
    self.model:initPvpCareerSkillInfo({data})
    self.model:setPvpFisrtReset(data.is_first == 1)
    GlobalEvent:getInstance():Fire(GuildskillEvent.Guild_Pvp_Career_Info_Event, data.career)
end

-- pvp 所有职业信息
function GuildskillController:send23711()
    local protocal = {}
    self:SendProtocal(23711, protocal)
end

function GuildskillController:handle23711(data)
    self.model:initPvpCareerSkillInfo(data.guild_skill_break_group)
    self.model:setPvpFisrtReset(data.is_first == 1)
    GlobalEvent:getInstance():Fire(GuildskillEvent.Guild_Pvp_Skill_Info_Event, data)
end


function GuildskillController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
