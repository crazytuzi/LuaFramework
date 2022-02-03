-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-26
-- --------------------------------------------------------------------
PokedexController = PokedexController or BaseClass(BaseController)

function PokedexController:config()
    self.model = PokedexModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PokedexController:getModel()
    return self.model
end

function PokedexController:registerEvents()

    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.role_vo = RoleController:getInstance():getRoleVo()
            -- self:sender11040() --登录先请求一下当前的图书馆信息
        end)
    end
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then 
                self:checkRedPoint(temp_add)
            end
        end)
    end

    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then 
                self:checkRedPoint(temp_del)
            end
        end)
    end

    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then 
                self:checkRedPoint(temp_list)
            end
        end)
    end
    if not self.add_partner_event then
        self.add_partner_event = GlobalEvent:getInstance():Bind(PartnerEvent.Partner_Data_Update, function(_partner_vo, is_add)
            if is_add then 
                -- self:checkIsCanCall()
            end
        end)
    end
    if not self.get_all_data then 
        self.get_all_data =  GlobalEvent:getInstance():Bind(BackpackEvent.GET_ALL_DATA, function(bag_code)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then 
                -- self:checkIsCanCall()
            end
        end)
    end
end

function PokedexController:registerProtocals()
    -- self:RegisterProtocal(11040, "handle11040")     --请求所有获得过的伙伴

    self:RegisterProtocal(11041, "handle11041")     --请求指定英雄评论信息
    self:RegisterProtocal(11042, "handle11042")     --设置伙伴为喜欢
    self:RegisterProtocal(11043, "handle11043")     --伙伴评论
    self:RegisterProtocal(11044, "handle11044")     --评论点赞    
    self:RegisterProtocal(11046, "handle11046")     --推送伙伴总星数改变    
    self:RegisterProtocal(11047, "handle11047")     --图书馆加成等级升级
    -- self:RegisterProtocal(11048, "handle11048")     --请求图书馆当前加成等级

end


--打开图书馆界面
--==============================--
--desc:
--time:2018-07-07 11:06:50
--@bool:
--@group:英雄分组组名
--@return 
--==============================--
function PokedexController:openPokedexWindow(bool,group,index,dun_id)
    if bool == false then
        if self.pokedex_window ~= nil then
            self.pokedex_window:close()
            self.pokedex_window = nil
        end
    else
        local data = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.library)
        if data and data.is_lock then
            message(data.desc)
            return
        end
        if self.pokedex_window == nil then
            self.pokedex_window = PokedexWindow.New()
        end
        if self.pokedex_window:isOpen() == false then
            self.pokedex_window:open(group, index, dun_id)
        end
    end
end


--查看伙伴
function PokedexController:openCheckHeroWindow(bool,data)
    if bool == false then
        if self.check_hero ~= nil then
            self.check_hero:close()
            self.check_hero = nil
        end
    else
        if self.check_hero == nil then
            self.check_hero = PokedexCheckWindow.New()
        end
        if self.check_hero:isOpen() == false then
            self.check_hero:open(data)
        end
    end
    
end
--评论
function PokedexController:openCommentWindow(bool,data)
    if bool == false then
        if self.comment_window ~= nil then
            self.comment_window:close()
            self.comment_window = nil
        end
    else
        if self.comment_window == nil then
            self.comment_window = PartnerCommentWindow.New(data)
        end
        if self.comment_window:isOpen() == false then
            self.comment_window:open()
        end
    end
    
end

--总星数提升一级
function PokedexController:openStarUpWindow(bool,data)
    if bool == false then
        if self.star_window ~= nil then
            self.star_window:close()
            self.star_window = nil
            self:checkIsCanCall()
        end
    else
        if self.star_window == nil then
            self.star_window = PokedexStarWindow.New(data)
        end
        if self.star_window:isOpen() == false then
            self.star_window:open()
        end
    end
    
end

--==============================--
--desc:红点判断
--time:2018-06-29 02:18:10
--@return 
--==============================--
function PokedexController:checkRedPoint(good_list)
    good_list = good_list or {}
    local is_check = false
    for i,v in pairs(good_list) do
        if v and v.config and v.config.type == BackPackConst.item_type.PARTNER_DEBRIS then 
            is_check = true
            break
        end
    end
    if is_check == true then 
        -- self:checkIsCanCall()
    end
end

function PokedexController:checkIsCanCall()
    -- local list = BackpackController:getInstance():getModel():getBackPackItemListByType(BackPackConst.item_type.PARTNER_DEBRIS) or {}

    -- local partner_model = PartnerController:getInstance():getModel()
    -- local is_show = false
    -- local data = BattleDramaController:getInstance():getModel():getDramaData()
    -- local const_config = Config.PartnerData.data_partner_const["checkpoint_open"]
    -- if const_config and data and data.max_dun_id and data.max_dun_id < const_config.val then 
    --     local list = {bid=1,status = is_show}
    --     MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.library,list)
    --     return 
    -- end
    -- for i,v in pairs(list) do
    --     local bool = false
    --     if v and v.config and v.config.effect and v.config.effect[1] then
    --         local partner_bid = v.config.effect[1].val or 0
    --         local vo = partner_model:getPartnerByBid(partner_bid)
    --         if vo and next(vo) ~=nil then 
    --             bool = false
    --         else
    --             local partner_config = Config.PartnerData.data_partner_base[partner_bid]
    --             if partner_config and partner_config.chips_num then 
    --                 if v.quantity >= partner_config.chips_num then 
    --                     bool = true
    --                 end
    --             end
    --         end
    --     end
    --     is_show = is_show or bool
    -- end
    -- local config = Config.PartnerData.data_pokedex_attr
    -- local all_data = self.model:getAllData()
    -- if  all_data and next(all_data or {}) ~= nil and all_data.lev  then
    --     local lev = all_data.lev  or 0
    --     local next_lev = math.min(lev + 1,tableLen(config))
    --     if Config.PartnerData.data_pokedex_attr[next_lev] then
    --         local next_config = Config.PartnerData.data_pokedex_attr[next_lev]
    --         if all_data and next_config then
    --             if all_data.all_star and all_data.all_star >= next_config.star and next_config.next_star ~= 0 then
    --                 is_show = true
    --             end
    --         end
    --     end
    -- end
    -- local list = {bid=1,status = is_show}
    -- MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.library,list)
end

function PokedexController:sender11040()
    local protocal ={}
    self:SendProtocal(11040,protocal)
end
function PokedexController:handle11040( data )
    self.model:setHavePartner(data)
    for i,v in ipairs(data.decompose_partners) do
        self.model:setDisbandPartner(v.partner_id)
    end

    GlobalEvent:getInstance():Fire(PokedexEvent.Get_All_Event,data)
    self:checkIsCanCall()
end

function PokedexController:setDisbandPartner(id)
    self.model:setDisbandPartner(id)
end

--请求指定英雄评论信息
function PokedexController:sender11041(partner_id,start,num)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.start = start
    protocal.num = num
    self:SendProtocal(11041,protocal)
end
function PokedexController:handle11041( data )
    GlobalEvent:getInstance():Fire(PokedexEvent.Comment_List_Event,data)
    
end
--设置伙伴为喜欢
function PokedexController:sender11042(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11042,protocal)
end
function PokedexController:handle11042( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(PokedexEvent.Comment_Like_Event,data)
    end
end
--伙伴评论
function PokedexController:sender11043(partner_id,msg)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.msg = msg
    self:SendProtocal(11043,protocal)
end
function PokedexController:handle11043( data )
    message(data.msg)
    if data.result ==1 then
        GlobalEvent:getInstance():Fire(PokedexEvent.Comment_Say_Event,data)
        
    end
end
--评论点赞
function PokedexController:sender11044(partner_id,comment_id,type)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.comment_id = comment_id
    protocal.type = type
    
    self:SendProtocal(11044,protocal)
end
function PokedexController:handle11044( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(PokedexEvent.Comment_Zan_Event,data)
    end
end


--推送伙伴总星数改变
function PokedexController:handle11046( data )
    message(data.msg)
    if data then
        local all_data = self.model:getAllData()
        all_data.all_star = data.new_star
        self:checkIsCanCall()
    end    
end

function PokedexController:send11047()
    local protocal = {}
    self:SendProtocal(11047, protocal)
end

function PokedexController:handle11047(data)
    message(data.msg)
    if data.result == 1 then
        local config = Config.PartnerData.data_pokedex_attr
        local all_data = self.model:getAllData()
        local cur_lev = all_data.lev
        if cur_lev == nil then return end

        all_data.lev = data.lev
        local next_lev = math.min(data.lev + 1, tableLen(config))
        local next_config = Config.PartnerData.data_pokedex_attr[next_lev]
        self.star_data = {old_star = all_data.all_star, new_star = next_config.star,old_lev = cur_lev,cur_lev = data.lev}
        if self.star_data then
            self:openStarUpWindow(true, self.star_data)
        end
        GlobalEvent:getInstance():Fire(PokedexEvent.Up_End_Event,self.star_data)
    end
end

function PokedexController:send11048()
    local protocal = {}
    self:SendProtocal(11048, protocal)
end


function PokedexController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
