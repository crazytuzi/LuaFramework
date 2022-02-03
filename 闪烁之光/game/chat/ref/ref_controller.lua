-- 聊天引用协议
-- author:cloud
-- date:2017.1.12
RefController = RefController or BaseClass(BaseController)

-- 初始
function RefController:config()

end

--打开引用界面
function RefController:openView(from, setting, channel)
	if not self.ref_ui then
		self.ref_ui = RefPanel.New()
	end
    self:setFrom(from)
	self.ref_ui:open(setting, channel)
    self.open_flag = true
end

-- 关闭引用界面
function RefController:closeView()
	if self.ref_ui then
		self.ref_ui:close()
		self.ref_ui = nil
	end
     self:setFrom(nil)
end


--注册协议
function RefController:registerProtocals()
    self:RegisterProtocal(12418, "handle12418")  --发送任务到聊天
    self:RegisterProtocal(12419, "handle12419")  --点击任务返回数据
    self:RegisterProtocal(11221, "handle11221")  --发送伙伴到聊天
    self:RegisterProtocal(11222, "handle11222")  --点击伙伴返回数据

    self:RegisterProtocal(10535, "handle10535")  
    self:RegisterProtocal(10536, "handle10536")  --点击物品返回数据  
end

-- 构造物品 click=点击类型|唯一ID|物品bid
function RefController:buildItemMsg(item_bid, srv_id, share_id, count)
    local config_data = Config.ItemData.data_get_data(item_bid)
    count = count or 0
    local item_name = config_data.name
    if count > 1 then
        item_name = item_name.."x"..count
    end
    if config_data then
        return string.format("<div fontcolor=%s href=%s|%s|%s>[%s]</div>",
                tranformC3bTostr(BackPackConst.ref_color[config_data.quality]),
                ChatConst.Link.Item_Show,
                srv_id,
                share_id,
                item_name)
    end
end

-- 构造任务 click=点击类型|唯一ID|任务bid
function RefController:buildMisMsg(mission_vo, uniq_id)
    if mission_vo then
        return string.format("<div fontcolor=%s click=%s|%s|%s>[%s]</div>",
            tranformC3bTostr(18),
            ChatConst.Link.Mission,
            uniq_id,
            mission_vo.mis_bid,
            MissionTitleII[mission_vo.mis_type] .. "-" .. MissionUtil.replaceColor(mission_vo.mis_content,MissionLinkColor,true))
    end
end

-- 构造伙伴 click=点击类型|唯一ID|伙伴bid
function RefController:buildPartnerMsg(partner_id, uniq_id)
    local partner_vo = HeroCalculate.getPartnerById(partner_id)
    if partner_vo then
        local config_data = Config.PartnerBase[partner_vo.bid]
        if config_data then
            local color = partner_vo.color or 2
            local base_name = config_data.name
            local prefix = HeroCalculate.getPrefixNameByVoForSpecial(partner_vo)
            if partner_vo.stage > 0 then
                base_name = string.format("%s+%s", base_name, partner_vo.stage)
            end
            base_name = string.format("%s%s", prefix, base_name)

            return string.format("<div fontcolor=%s click=%s|%s|%s>[%s]</div>",
                c3bToStr(BackPackConst.quality_3_color[color]),
                ChatConst.Link.Partner,
                uniq_id,
                partner_id,
                base_name)
        end
    end
end

-- 打开聊天引用来源
function RefController:getFrom()
    return self.where or "chatPanel"
end

function RefController:setFrom(where)
    self.where = where
end

function RefController:getChannel()
    return ChatCtrl:getRefChannel(self.where)
end

-----------------
-- 聊天-物品展示
-----------------
--通知server缓存物品数据
function RefController:showGoods(srv_id, share_id)
end

--获取物品Tips
function RefController:getGoodsTips(share_id, srv_id)
    if not share_id then return end
    local protocal = {}
    protocal.srv_id = srv_id
    protocal.id = share_id 
    self:SendProtocal(10536, protocal)
end

--显示物品Tips
function RefController:handle10536(data)
    -- if #data.items > 0 then
    local item_vo = GoodsVo.New()
    item_vo:initAttrData(data)
    if item_vo.config == nil then
        message(TI18N("数据异常"))
        return
    end

    if BackPackConst.checkIsEquip(item_vo.config.type) then 
        HeroController:getInstance():openEquipTips(true, item_vo, PartnerConst.EqmTips.other)
    elseif BackPackConst.checkIsArtifact(item_vo.config.type) then
        HeroController:getInstance():openArtifactTipsWindow(true, item_vo, PartnerConst.ArtifactTips.normal)
    else
        TipsManager:getInstance():showGoodsTips(item_vo.config)
    end
end


-----------------
-- 聊天-任务展示
-----------------
-- 展示任务
function RefController:showMission(mission_vo, channel)
    if GameData:getInstance():getRoleVo().lev < 25 then
        message(getString("25级方可发送，请提升等级！"))
        return
    end
    if not ChatMgr:getInstance():canSpeak(channel) then
        return
    end
    self.show_mission_vo = mission_vo
    self.show_channel  = channel
    local protocal = ProtocalRulesMgr:getInstance():GetPrototype(12418)
    protocal.mission_bid = mission_vo.mis_bid
    self:SendProtocal(protocal)
end

-- 点击展示任务
function RefController:clickMission(uniq_id, pos, srv_id)
    self.show_click_pos = pos
    local protocal = ProtocalRulesMgr:getInstance():GetPrototype(12419)
    protocal.srv_id = srv_id
    protocal.uniq_id = uniq_id
    self:SendProtocal(protocal)
end

-- 展示任务返回
function RefController:handle12418(data)
    if data.uniq_id > 0 then
        local str = self:buildMisMsg(self.show_mission_vo, data.uniq_id)
        if str then
            ChatCtrl:getInstance():sendMessage(str, self.show_channel, nil, 2)
        end
    end
end

-- 展示任务TIps
function RefController:handle12419(data)
    if data.mission_bid == 0 then
        message(getString("任务数据已过期"))
        return
    end
    local mission_vo = MissionCtrl:getInstance():createMis(data, true, true)
    if self.show_click_pos and mission_vo then
        local tips_str = string.format(getString("任务名称：<div fontcolor=#00ff00>%s</div>"), mission_vo.mis_config.name)
        tips_str = (tips_str .. string.format(getString("\n任务目标：<div fontcolor=#00ff00>%s</div>"), MissionUtil.replaceColor(mission_vo.mis_content,MissionColor)))
        tips_str = (tips_str .. string.format(getString("\n任务描述：<div fontcolor=#00ff00>%s</div>"), MissionUtil.replaceColor(mission_vo.mis_config.desc,MissionColor)))
        CommonTipsManager:getInstance():showCommonTipsII(tips_str, self.show_click_pos)
    end
end


-----------------
-- 聊天-伙伴展示
-----------------
-- 展示伙伴
function RefController:showPartner(partner_bid, partner_id, channel)
    if GameData:getInstance():getRoleVo().lev < 25 then
        message(getString("25级方可发送，请提升等级！"))
        return
    end
    if not ChatMgr:getInstance():canSpeak(channel) then
        return
    end
    self.show_channel  = channel
    self.show_partner_id = partner_id
    local protocal = ProtocalRulesMgr:getInstance():GetPrototype(11222)
    protocal.id = partner_id
    self:SendProtocal(protocal)
end

-- 点击伙伴任务
function RefController:clickPartner(uniq_id, pos, srv_id)
    self.show_click_pos = pos
    local protocal = ProtocalRulesMgr:getInstance():GetPrototype(11221)
    protocal.srv_id = srv_id
    protocal.cache_id = uniq_id
    self:SendProtocal(protocal)
end

-- 展示伙伴返回
function RefController:handle11222(data)
    message(data.msg)
    if data.code>0 and self.show_partner_id>0 then
        local str = self:buildPartnerMsg(self.show_partner_id, data.code)
        if str then
            ChatCtrl:getInstance():sendMessage(str, self.show_channel, nil, 2)
        end
    end
end

-- 展示任务TIps
function RefController:handle11221(data)
    if #data.partner_list == 0 then
        message(getString("伙伴数据已过期"))
        return
    else
        local eqv_list = {}
        for k, v in pairs(data.eqm_list) do
            local vo = GoodsVo.New()
            vo:initAttrData(v)
            table.insert(eqv_list, vo)
        end
        local partner_vo = HeroVo.New()
        partner_vo:updateHeroVo(data.partner_list[1])
        partner_vo.eqv_list = eqv_list
        HeroEquipCtrl:getInstance():openShowPanel(partner_vo)
    end
end

function RefController:send10535(type, id, partner_id, code)
    local protocal = {}
    protocal.type = type
    protocal.id = id
    protocal.partner_id = partner_id
    protocal.code = code
    self:SendProtocal(10535, protocal)
end

function RefController:handle10535(data)
    if data.flag == 1 then
        GlobalEvent:getInstance():Fire(EventId.CHAT_SELECT_ITEM, data, self:getFrom())
    else
        message(data.msg)
    end
end

--保存常用语
function RefController:setGreenting(value)
    if value then
        self.greeting_now = value
    end
end
