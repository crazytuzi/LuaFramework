-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-01-24
-- --------------------------------------------------------------------
VedioController = VedioController or BaseClass(BaseController)

function VedioController:config()
    self.model = VedioModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function VedioController:getModel()
    return self.model
end

function VedioController:registerEvents()
	if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            -- 登陆时请求今日点赞次数
            --self:requestTodayLikeNum()
        end)
    end

    -- 断线重连的时候
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            --self:requestTodayLikeNum()
        end)
    end
end

function VedioController:registerProtocals()
	self:RegisterProtocal(19901,"handle19901") --个人录像数据返回
	self:RegisterProtocal(19902,"handle19902") --录像大厅数据返回
	self:RegisterProtocal(19903,"handle19903") --点赞返回
	self:RegisterProtocal(19904,"handle19904") --收藏返回
	self:RegisterProtocal(19905,"handle19905") --分享返回
	self:RegisterProtocal(19906,"handle19906") --今日点赞数
    self:RegisterProtocal(19907,"handle19907") --伙伴信息数据

	self:RegisterProtocal(19908,"handle19908") --查看分享录像
end

-- 请求个人录像数据(我的记录、我的收藏)
function VedioController:requestMyVedioByType( type )
    local protocal = {}
    protocal.type = type
    self:SendProtocal(19901, protocal)
end

function VedioController:handle19901( data )
	if data then
		if data.type == VedioConst.MyVedio_Type.Myself then
			GlobalEvent:getInstance():Fire(VedioEvent.UpdateMyselfVedioEvent, data.replay_list)
		elseif data.type == VedioConst.MyVedio_Type.Collect then
			GlobalEvent:getInstance():Fire(VedioEvent.UpdateCollectVedioEvent, data.replay_list)
		end
	end
end

-- 请求录像大厅的数据
function VedioController:requestPublicVedioData( type, cond_type, start, num )
	local protocal = {}
    protocal.type = type
    protocal.cond_type = cond_type
    protocal.start = start
    protocal.num = num
    self:SendProtocal(19902, protocal)
end

function VedioController:handle19902( data )
	if data then
		self.model:setPublicVedioData(data)
		GlobalEvent:getInstance():Fire(VedioEvent.UpdatePublicVedioEvent, data.type)
	end
end

-- 请求录像点赞
function VedioController:requestLikeVedio( id, srv_id, combat_type )
	local protocal = {}
    protocal.id = id
    protocal.srv_id = srv_id
    protocal.combat_type = combat_type
    self:SendProtocal(19903, protocal)
end

function VedioController:handle19903( data )
	message(data.msg)
end

-- 请求录像收藏
function VedioController:requestCollectVedio( id, type, srv_id, combat_type, vedioType )
	self.vedioType_flag = vedioType  -- 记录一下请求收藏的类型
	local protocal = {}
    protocal.id = id
    protocal.type = type
    protocal.srv_id = srv_id
    protocal.combat_type = combat_type
    self:SendProtocal(19904, protocal)
end

function VedioController:handle19904( data )
	message(data.msg)
	if data.code == 1 and data.type == 1 then -- 收藏成功
		local new_data = self.model:updateVedioData(self.vedioType_flag, data.id, "is_collect", 1)
		GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
		GlobalEvent:getInstance():Fire(VedioEvent.CollectSuccessVedioEvent, data.id)
	end
	if data.type == 0 then
		GlobalEvent:getInstance():Fire(VedioEvent.CancelCollectVedioEvent, data.id)
	end
end

-- 请求录像分享
function VedioController:requestShareVedio( id, channel, srv_id, combat_type )
	local protocal = {}
    protocal.id = id
    protocal.channel = channel
    protocal.srv_id = srv_id
    protocal.combat_type = combat_type
    self:SendProtocal(19905, protocal)
end

function VedioController:handle19905( data )
	message(data.msg)
end

-- 今日点赞数
function VedioController:requestTodayLikeNum(  )
	local protocal = {}
    self:SendProtocal(19906, protocal)
end

function VedioController:handle19906( data )
	if data.like then
		self.model:setTodayLikeNum(data.like)
		GlobalEvent:getInstance():Fire(VedioEvent.UpdateTodayLikeNum)
	end
end

-- 请求伙伴信息
function VedioController:requestVedioHeroData( replay_id, partner_id, type, srv_id, combat_type )
    local protocal = {}
    protocal.replay_id = replay_id
    protocal.partner_id = partner_id
    protocal.type = type
    protocal.srv_id = srv_id
    protocal.combat_type = combat_type
    self:SendProtocal(19907, protocal)
end

function VedioController:handle19907( data )
    if data then
        local config = Config.PartnerData.data_partner_base[data.bid]
        local camp_type = 1
        if config then
            camp_type = config.camp_type
        end
        data.camp_type = camp_type
        data.ext_data = data.ext
        for i,v in ipairs(data.ext) do
            if v.key == 111 then --命中
                data.hit_rate = v.val
            elseif v.key == 112 then --闪避
                data.dodge_rate = v.val
            elseif v.key == 117 then --抗暴
                data.tenacity = v.val
            elseif v.key == 121 then --伤害加成
                data.dam = v.val
            elseif v.key == 122 then --免伤
                data.res = v.val
            elseif v.key == 123 then --被治疗
                data.be_cure = v.val
            elseif v.key == 124 then --治疗
                data.cure = v.val
            elseif v.key == 125 then --物伤
                data.dam_p = v.val
            elseif v.key == 126 then --法伤
                data.dam_s = v.val
            elseif v.key == 127 then --物免
                data.res_p = v.val
            elseif v.key == 128 then --法免
                data.res_s = v.val
            end
        end

        --后端问题.没法改结构..现在模拟神装数据 从artifacts里面拿数据
        data.holy_eqm = {}
        for i,v in ipairs(data.artifacts) do
            if v.artifact_pos == BackPackConst.item_type.GOD_EARRING + 100 or
                v.artifact_pos == BackPackConst.item_type.GOD_RING + 100 or
                v.artifact_pos == BackPackConst.item_type.GOD_NECKLACE + 100 or
                v.artifact_pos == BackPackConst.item_type.GOD_BANGLE + 100 then
                --说明是神装
                local holy_data = {}
                holy_data.id = v.id
                holy_data.base_id = v.base_id
                holy_data.main_attr = v.attr
                holy_data.holy_eqm_attr = v.extra_attr
                for i,v in ipairs(holy_data.holy_eqm_attr) do
                    v.pos = i
                end
                table.insert(data.holy_eqm, holy_data)
            end
        end
        HeroController:getInstance():openHeroTipsPanel(true, data)
    end
end

-- 录像信息
function VedioController:send19908( replay_id, srv_id, type, channel, hall_srv_id )
	local protocal = {}
	protocal.replay_id = replay_id
	protocal.srv_id = srv_id
	protocal.type = type
    protocal.channel = channel
    protocal.hall_srv_id = hall_srv_id
    self:SendProtocal(19908, protocal)
end

function VedioController:handle19908(data)
    self:openVedioLookPanel(true, data)
	-- GlobalEvent:getInstance():Fire(VedioEvent.LOOK_VEDIO_EVENT, data)
end

----------------------@ open view
-- 打开录像馆
function VedioController:openVedioMainWindow( status, sub_type )
	if status == true then
        if not sub_type and SysEnv:getInstance():getBool(SysEnv.keys.video_first_open, true) then
            sub_type = VedioConst.Tab_Index.Newhero
        end
		if not self.vedio_main_wnd then
			self.vedio_main_wnd = VedioMainWindow.New()
		end
		if self.vedio_main_wnd:isOpen() == false then
			self.vedio_main_wnd:open(sub_type)
		end
	else
		if self.vedio_main_wnd then
			self.vedio_main_wnd:close()
			self.vedio_main_wnd = nil
		end
	end
end

-- 打开录像收藏界面
function VedioController:openVedioCollectWindow( status )
	if status == true then
		if not self.vedio_collect_win then
			self.vedio_collect_win = VedioCollectWindow.New()
		end
		if self.vedio_collect_win:isOpen() == false then
			self.vedio_collect_win:open()
		end
	else
		if self.vedio_collect_win then
			self.vedio_collect_win:close()
			self.vedio_collect_win = nil
		end
	end
end

-- 打开个人记录界面
function VedioController:openVedioMyselfWindow( status )
	if status == true then
		if not self.vedio_myself_win then
			self.vedio_myself_win = VedioMyselfWindow.New()
		end
		if self.vedio_myself_win:isOpen() == false then
			self.vedio_myself_win:open()
		end
	else
		if self.vedio_myself_win then
			self.vedio_myself_win:close()
			self.vedio_myself_win = nil
		end
	end
end

--打开详情
function VedioController:openVedioLookPanel(status, data)
    if status == true then
        if not self.vedio_look_panel then
            self.vedio_look_panel = VedioLookPanel.New()
        end
        if self.vedio_look_panel:isOpen() == false then
            self.vedio_look_panel:open(data)
        end
    else
        if self.vedio_look_panel then
            self.vedio_look_panel:close()
            self.vedio_look_panel = nil
        end
    end
end
--打开详情
function VedioController:openVedioSharePanel(status,  vedio_id, world_pos, callback, srv_id, combat_type)
    if status == true then
        if not self.vedio_share_panel then
            self.vedio_share_panel = VedioSharePanel.New()
        end
        if self.vedio_share_panel:isOpen() == false then
            self.vedio_share_panel:open(vedio_id, world_pos, callback, srv_id, combat_type)
        end
    else
        if self.vedio_share_panel then
            self.vedio_share_panel:close()
            self.vedio_share_panel = nil
        end
    end
end


function VedioController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end