-- --------------------------------------------------------------------
-- 排行榜单元项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RankItem = class("RankItem", function()
	return ccui.Widget:create()
end)
local elite_level_data = Config.ArenaEliteData.data_elite_level
function RankItem:ctor(index)
	self.width = 630
	self.height = 120
	self.index =index or 1
	self.ctrl = RankController:getInstance()
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(true)   
	self.rank_type = RankConstant.RankType.drama
	self.rank_num = 0
	self:configUI()
end

function RankItem:clickHandler( ... )
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function RankItem:setTouchFunc( value )
	self.call_fun =  value
end
--[[
@功能:创建视图
@参数:
@返回值:
]]
function RankItem:configUI( ... )
	--底内框 
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    -- self.back:setTouchEnabled(true)
    self:addChild(self.back)

    local res = PathTool.getResFrame("common","common_1029")
    self.background = createImage(self.back,res,self.width/2,self.height/2,cc.p(0.5,0.5),true,0,true)
    self.background:setContentSize(cc.size(self.width, self.height))
	self:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =
                    math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                    math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.rank_type ~= RankConstant.RankType.union then 
					self:openChatMessage()
				end
            end
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
		end
    end)
    --选择框
    self.select = ccui.ImageView:create(PathTool.getSelectBg(), LOADTEXT_TYPE_PLIST)
    self.select:setScale9Enabled(true)
	self.select:setContentSize(cc.size(self.width+10, self.height+10))
	self.select:setAnchorPoint(cc.p(0,0))
	self.select:setCapInsets(cc.rect(20,20,2,2))
	self.select:setPosition(cc.p(-5,-5))
	self.select:setVisible(false)
    self:addChild(self.select)

	self.rank_icon = createImage(self, nil, 50,self.height/2, cc.p(0.5,0.5), true, 1, false)
	self.rank_index =  createLabel(30,Config.ColorData.data_color4[186],nil,50,self.height/2,"",self,0, cc.p(0.5,0.5),"fonts/title.ttf")

	self.other_panel = ccui.Widget:create()
	self.other_panel:setContentSize(cc.size(self.width, self.height))
	self.other_panel:setAnchorPoint(cc.p(0, 0))
	self:addChild(self.other_panel)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function RankItem:setData( vo, index)
	if vo == nil then return end
	self.data = vo
	local index = vo._index or index
    self.index = index or 1
	self.rank_index:setString(self.index)
	if self.index >= 1 and self.index <= 3 then
        self.rank_index:setVisible(false)
        self.rank_icon:setVisible(true)
		self.rank_icon:loadTexture(PathTool.getResFrame("common","common_200"..self.index),LOADTEXT_TYPE_PLIST)
		self.rank_icon:setScale(0.7)
    else
        self.rank_index:setVisible(true)
        self.rank_icon:setVisible(false)
    end
	self:updateDataByRankType()
end

function RankItem:setExtendData(data)
	if not data then return end
	self.rank_type = data.rank_type or RankConstant.RankType.drama
	self.is_cluster = data.is_cluster or false
end

function RankItem:updateDataByRankType()
	if not self.data then return end 

	self.other_panel:removeAllChildren()

	local role_name = self.data.name
	if self.is_cluster == true then
		local srv_id = self.data.srv_id or self.data.leader_srvid
		role_name  = transformNameByServ(self.data.name, srv_id) 
	end

	if self.rank_type ~= RankConstant.RankType.union then 
		self.play_head = self:createPlayerHead(105,60)
		local face_id = self.data.face_id or self.data.face
		local avatar_bid = self.data.avatar_bid
		local vo = Config.AvatarData.data_avatar[avatar_bid]
		if vo then
			local res_id = vo.res_id or 1
			local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
			self.play_head:showBg(res, nil, false, vo.offy)
		end

		self.play_head:setHeadRes(face_id, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
		self.play_head:setLev(self.data.lev)
	end
	if self.rank_type == RankConstant.RankType.power or self.rank_type == RankConstant.RankType.action_power then 
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)

		local label = createRichLabel(24, Config.ColorData.data_color4[175],cc.p(0.5,0.5), cc.p(480,self.height/2), 0, 0, 500)
		self.other_panel:addChild(label)
		local power = self.data.val1 or 0
		local res = PathTool.getResFrame('common', 'common_90002')
		label:setString(string.format("<img src='%s' /> %s", res, power))
	elseif self.rank_type == RankConstant.RankType.union_boss then
		local label = createLabel(24, Config.ColorData.data_color4[175], nil, 190, self.height / 2, '', self.other_panel, 0, cc.p(0, 0.5))
		label:setString(role_name)
		--战力
		local label = createRichLabel(24, Config.ColorData.data_color4[175], cc.p(0.5, 0.5), cc.p(505, self.height / 2 + 30), 0, 0, 500)
		self.other_panel:addChild(label)
		local all_dps = self.data.all_dps or 0
		label:setString(all_dps)
		--增加点赞功能
		self:addPraise(self.data)

	elseif self.rank_type == RankConstant.RankType.drama or self.rank_type == RankConstant.RankType.action_drama  then 
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--装备评分
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,495,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		local config = Config.DungeonData.data_drama_dungeon_info(self.data.val1)
		if config then 
			str = config.name
			label:setString(str)
		end
			
	elseif self.rank_type == RankConstant.RankType.union then 
		local step = self.data.step or 0
		step = math.max(step,1)
		step = math.min(step,11)
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,204,80,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(role_name)
		--宗主名字
		local label = createLabel(20,Config.ColorData.data_color4[186],nil,204,50,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(TI18N("会长：")..(self.data.leader_name or ""))
		--等级
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,342,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.lev or 313)
		--人数
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,425,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		local num1 = self.data.members_num or 0
		local num2 = self.data.members_max or 0
		label:setString(num1.."/"..num2)
		--战力
		local label = createRichLabel(24, Config.ColorData.data_color4[186],cc.p(0.5,0.5), cc.p(525,self.height/2), 0, 0, 500)
		self.other_panel:addChild(label)
		local res = PathTool.getResFrame("common","common_90002")
		label:setString(self.data.power or 0)
	elseif self.rank_type == RankConstant.RankType.tower or self.rank_type == RankConstant.RankType.action_tower then 
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--层数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,398,61,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.val1 or 0)
		--通关时间
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,500,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		local num = self.data.val2 or 0
		label:setString(TimeTool.GetTimeMS(num,true))
	elseif self.rank_type == RankConstant.RankType.arena or self.rank_type == RankConstant.RankType.action_arena then 
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--装备评分
		local label = createRichLabel(24, Config.ColorData.data_color4[186],cc.p(0.5,0.5), cc.p(495,self.height/2), 0, 0, 500)
		self.other_panel:addChild(label)
		local res = PathTool.getItemRes("8")
		local score = self.data.score or self.data.val1 or 0
		label:setString(string.format( "<img src='%s' scale=0.35 /> %s",res,score))
	elseif self.rank_type == RankConstant.RankType.action_adventure then  
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)

		--层数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,460,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.val1 or 0)
	elseif self.rank_type == RankConstant.RankType.action_partner then  
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		local vo = self:createPartnerVo()
		self.hero_item = HeroExhibitionItem.new(0.8,true)
		self.hero_item:setPosition(cc.p(403,60))
		self.other_panel:addChild(self.hero_item)
		self.hero_item:addCallBack(function(item)
			local vo = item:getData()
			if vo and next(vo) ~= nil then 
				local rid = self.data.rid or self.data.r_rid
				local srv_id = self.data.srv_id or self.data.r_srvid
				LookController:sender11061(rid,srv_id,vo.partner_id)
			end
		end)
		self.hero_item:setData(vo)
		--层数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,485,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.power or 0)		
	elseif self.rank_type == RankConstant.RankType.action_star or self.rank_type == RankConstant.RankType.star_power or 
		self.rank_type == RankConstant.RankType.hallows_power or self.rank_type == RankConstant.RankType.treasure or 
		self.rank_type == RankConstant.RankType.colors_tone or self.rank_type == RankConstant.RankType.gemstone or 
		self.rank_type == RankConstant.RankType.pointglod or self.rank_type == RankConstant.RankType.speed_fight or
		self.rank_type == RankConstant.RankType.voyage or self.rank_type == RankConstant.RankType.hero_expedit then  
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--层数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,455,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.val1 or 0)		
	elseif self.rank_type == RankConstant.RankType.guild_war then 
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--星数
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,402,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.star or 0)
		--战绩
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,525,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(self.data.war_score or 0)
	elseif self.rank_type == RankConstant.RankType.endless or self.rank_type == RankConstant.RankType.endless_old or 
		   self.rank_type == RankConstant.RankType.adventure or self.rank_type == RankConstant.RankType.adventure_muster then
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--层数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,403,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.val1 or 0)
		--战力
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,535,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.val2 or 0)
	elseif self.rank_type == RankConstant.RankType.holy_device or self.rank_type == RankConstant.RankType.star_master or 
		   self.rank_type == RankConstant.RankType.summon or self.rank_type == RankConstant.RankType.strong_battle or
		   self.rank_type == RankConstant.RankType.consumption then
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--***
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,480,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.val1 or 0)
	elseif self.rank_type == RankConstant.RankType.holy_device_1 then
		--名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)
		--***
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,480,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.val1 or 0)
	elseif self.rank_type == RankConstant.RankType.elite then
        --名字
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,198,self.height/2+20,"",self.other_panel,0, cc.p(0,0.5))
		local server_name = getServerName(self.data.srv_id)
		local str = string.format("[%s]%s",server_name,self.data.name)
		label:setString(str)

		--战力
		local power_bg = createImage(self.other_panel, PathTool.getResFrame("common", "common_90003"), 198, 46, cc.p(0, 0.5), true, 0, true)
		power_bg:setCapInsets(cc.rect(20, 15, 1, 1))
		power_bg:setContentSize(cc.size(159, 31))
		createSprite(PathTool.getResFrame("common", "common_90001"), 29, 16, power_bg, cc.p(0.5,0.5))
		local power = createLabel(22,cc.c4b(0xff,0xee,0xac,0xff),nil,48,16,"",power_bg,0, cc.p(0,0.5))
		power:setString(self.data.power)

		--图标
		local sprite = createSprite("", 439, self.height/2, self.other_panel,cc.p(0.5,0.5),LOADTEXT_TYPE)

		local lev = self.data.elite_lev or 1
        local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",elite_level_data[lev].little_ico, false)
        if not self.elite_load then
            self.elite_load = loadSpriteTextureFromCDN(sprite, bg_res, ResourcesType.single, self.elite_load) 
        end
        if self.elite_load then
        	loadSpriteTexture(sprite, bg_res, LOADTEXT_TYPE)
        end
        --积分
		local score = createLabel(24,Config.ColorData.data_color4[175],nil,509,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		score:setString(self.data.score)
	elseif self.rank_type == RankConstant.RankType.ladder then --天梯排行 --lwc
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2 + 18,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)

		local name = self.data.guild_name 
		local label1 = createLabel(24,Config.ColorData.data_color4[175],nil,480,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		if name == nil or name == "" then
			label1:setString(TI18N("暂未加入公会"))
		else
			label1:setString(name)
		end

		local label = createRichLabel(24, Config.ColorData.data_color4[175],cc.p(0,0.5), cc.p(190,self.height/2 - 18), 0, 0, 500)
		self.other_panel:addChild(label)
		local power = self.data.val1 or 0
		local res = PathTool.getResFrame('common', 'common_90002')
		label:setString(string.format("<img src='%s' /> %s", res, power))
	elseif self.rank_type == RankConstant.RankType.heaven then  -- 天界副本
		local label = createLabel(24, Config.ColorData.data_color4[175], nil, 190, self.height / 2, '', self.other_panel, 0, cc.p(0, 0.5))
		label:setString(role_name)

		-- 通关星数
		local label = createLabel(24,Config.ColorData.data_color4[186],nil,465,self.height/2,"",self.other_panel,0, cc.p(0.5,0.5))
		label:setString(self.data.val1 or 0)
	elseif self.rank_type == RankConstant.RankType.fans then 
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)


		local label = createLabel(24,Config.ColorData.data_color4[175],nil,428,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		local inx = self.data.fans_num or 0
		label:setString(inx)
	elseif self.rank_type == RankConstant.RankType.planes_rank or self.rank_type == RankConstant.RankType.sweet then
		local label = createLabel(24,Config.ColorData.data_color4[175],nil,190,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		label:setString(role_name)

		local label = createLabel(24,Config.ColorData.data_color4[175],nil,428,self.height/2,"",self.other_panel,0, cc.p(0,0.5))
		local inx = self.data.val1 or 0
		label:setString(inx)
	end
end

--个人伤害排行------------start
function RankItem:addCallBack(call_back)
    self.call_back = call_back
end

--增加点赞功能
function RankItem:addPraise(data)
	self._btnPraise = createButton(self.other_panel, nil, 504,43, cc.size(137,49),PathTool.getResFrame("common","common_1027"),24,Config.ColorData.data_color4[1])
	
	self._praise = createSprite(PathTool.getResFrame("common", "common_1045"), 31, 28, self._btnPraise, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
    self._praise:setAnchorPoint(cc.p(0.5, 0.5))
	self._btnPraise:addChild(self._praise, 1)
	
	if self.index <= 3 then
		self._btnPraise:addTouchEventListener(function(sender, event_type)
			customClickAction(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
            	playButtonSound2()
            	if self.call_back ~= nil then
                    self.call_back(self)
                end
            	RoleController:getInstance():requestWorshipRole(data.r_rid, data.r_srvid, self.index, 2)
        	end
        end)
	else
		self._btnPraise:setBright(false)
		setChildUnEnabled(true, self._praise)
	end

    --点赞数字
	self._labelPraise = createLabel(24, Config.ColorData.data_color4[1], nil, 85, 26, '', self._btnPraise, 0, cc.p(0.5, 0.5))
	self._labelPraise:setString(data.worship or 0)
	self._btnPraise:addChild(self._labelPraise)
	self._labelPraise:enableOutline(Config.ColorData.data_color4[264], 2)

	--不可膜拜
	if data.worship_status == 1 then
		self._btnPraise:setBright(false)
    	setChildUnEnabled(true, self._praise)
	end
end
function RankItem:updateWorshipStatus()
    if self.data ~= nil then
        self.data.worship = self.data.worship + 1
        self.data.worship_status = TRUE
        self._labelPraise:setString(self.data.worship)
        self._btnPraise:setBright(false)
    	setChildUnEnabled(true, self._praise)
    end
end
--个人伤害排行------------end
--打开玩家信息
function RankItem:openChatMessage()
	if not self.data then return end
	local rid = self.data.rid or self.data.r_rid
	local srv_id  = self.data.srv_id or self.data.r_srvid
	self.ctrl:openChatMessage(rid, srv_id, self.data.is_robot)
end
--创建一个英雄数据
function RankItem:createPartnerVo()
	local vo = HeroVo.New()
	local data = {
		partner_id = self.data.pid,
		bid = self.data.pbid,
		lev = self.data.plev,
		star = self.data.pstar,
	}
	vo:updateHeroVo(data)
	return vo
end
--创建玩家头像
function RankItem:createPlayerHead(x,y)
	local play_head = PlayerHead.new(PlayerHead.type.circle)
	self.other_panel:addChild(play_head)
	play_head:setPosition(cc.p(x,y))
	play_head:setAnchorPoint(cc.p(0,0.5))
	play_head:setTouchEnabled(false)
	play_head:setScale(0.8)
	--头像不需要点击 本身item就是处理点击了
	return play_head
end

function RankItem:setSelected(bool)
	self.select:setVisible(bool)
	if bool == true then 
		local fadein = cc.FadeIn:create(0.7)
		local action = cc.Blink:create(2,1)
		local fadeout = cc.FadeOut:create(0.7)
		self.select:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein,fadeout)))
	else
		self.select:stopAllActions()
	end
end

function RankItem:reset()
	-- self.back:removeAllChildren()
	if self.num then
		self.num:setVisible(false)
	end
	self.vo = nil
end

function RankItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end
function RankItem:getData( )
	return self.vo
end

function RankItem:DeleteMe()
	if self.play_head then 
		self.play_head:DeleteMe()
		self.play_head = nil
	end
	if self.hero_item then 
        self.hero_item:DeleteMe()
    end
    self.hero_item = nil
    if self.elite_load then
        self.elite_load:DeleteMe()
    end
    self.elite_load = nil

	self:removeAllChildren()
	self:removeFromParent()
	self.vo =nil
end
