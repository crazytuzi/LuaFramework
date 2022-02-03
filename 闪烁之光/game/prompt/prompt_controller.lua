-- --------------------------------------------------------------------
-- 小图标提示控制器,比如收到切磋,添加好友等其他
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-03-06
-- --------------------------------------------------------------------
PromptController = PromptController or BaseClass(BaseController)

function PromptController:config()
    self.model = PromptModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.cache_list = {}
end

function PromptController:getModel()
    return self.model
end

function PromptController:registerEvents()
end

function PromptController:setPromptStatus(status)
end

function PromptController:registerProtocals()
    self:RegisterProtocal(16800, "hander16800")
end

function PromptController:hander16800(data)
    if data.type == PromptTypeConst.Join_guild then
        GuildController:getInstance():setApplyListStatus(data)
    elseif data.type == PromptTypeConst.World_boss or data.type == PromptTypeConst.Escort then
        self.model:addPromptData(data)
    elseif data.type == PromptTypeConst.Private_chat or data.type == PromptTypeConst.At_notice then
        -- 延迟2秒，因为这里可能会先收到协议再收到好友的数据协议
        GlobalTimeTicket:getInstance():add(function (  )
            local is_need_add = true
            if data.type == PromptTypeConst.Private_chat then
                local rid
                local srv_id
                for k,v in pairs(data.arg_uint32 or {}) do
                    if v.key == 1 then
                        rid = v.value
                        break
                    end
                end

                for k,v in pairs(data.arg_str or {}) do
                    if v.key == 1 then
                        srv_id = v.value
                        break
                    end
                end
                -- 当对方先发私聊再把我删除好友，则会出现非好友却收到私聊提示，这时直接告诉后端删除这个灯泡消息
                if not rid or not srv_id or not FriendController:getInstance():isFriend(srv_id, rid) then
                    is_need_add = false
                    if rid and srv_id then
                        ChatController:getInstance():noticeReader(srv_id, rid)
                    end
                end
            end
            if is_need_add then
                self.model:addPromptData(data)
            end
        end, 2, 1)
    elseif data.type == PromptTypeConst.Endless_trail then
        local is_infight = BattleController:getInstance():isInFight()
        local cur_fight_type = BattleController:getInstance():getCurFightType()
        -- 不在无尽试炼的战斗中,才需要显示这个
        if is_infight == false or cur_fight_type ~= BattleConst.Fight_Type.Endless then
            self.model:addPromptData(data)
        end
    elseif data.type == PromptTypeConst.GuileMuster then
        self.model:addPromptData(data)
    elseif data.type == PromptTypeConst.Challenge then
        self.model:addPromptData(data)
    elseif data.type == PromptTypeConst.Guild 
        or data.type == PromptTypeConst.Guild_war 
        or data.type == PromptTypeConst.Guild_voyage 
        or data.type == PromptTypeConst.BBS_message 
        or data.type == PromptTypeConst.BBS_message_reply 
        or data.type == PromptTypeConst.BBS_message_reply_self  
        or data.type == PromptTypeConst.Mine_defeat then 
        self.model:addPromptData(data)
    end
end

function PromptController:openPromptPanel(status)
end

function PromptController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
