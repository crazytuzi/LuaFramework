-- --------------------------------------------------------------------
-- 
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

PromptVo = RoleVo or BaseClass(EventDispatcher)

PromptVo.UPDATE_SELF_EVENT = "PromptVo.UPDATE_SELF_EVENT"

function PromptVo:__init(type, id)
    self.list = {}
    self.type = type
    self.id = id
    self.auto_id = 0
    self.name = ""
    self.is_show_bubble = false -- 是否弹出过气泡提示
end

function PromptVo:update(data)
    self.auto_id = self.auto_id + 1
        
    if self.type == PromptTypeConst.BBS_message_reply then
        local rid, srv_id, role_name, _ ,bbs_id = self:getSridByData(data)
        local name = role_name or TI18N("名字")
        self.name = name..TI18N("回复了你")
    else
        self.name = Config.NoticeData.data_get[self.type].name    
    end

    table.insert( self.list, {id = self.auto_id, data = data,time = GameNet:getInstance():getTime()} )
    self:Fire(PromptVo.UPDATE_SELF_EVENT)
end

function PromptVo:removeDataById(id)
    for i,v in ipairs(self.list) do
        if v.id == id then
            table.remove( self.list, i )
        end
    end
    self:Fire(PromptVo.UPDATE_SELF_EVENT)
end

function PromptVo:getNum()
    return #self.list
end

function PromptVo:setShowBubbleStatus( status )
    self.is_show_bubble = status
end

--==============================--
--desc:获取指定的对象
--time:2017-08-28 04:53:05
--@data:
--@return 
--==============================--
function PromptVo:getSridByData(data)
	local rid, srv_id, role_name = 0, "", ""
	local bbs_id = 0
    if data and data.arg_uint32 and #data.arg_uint32 > 0 then
        for i = 1, #data.arg_uint32 do
            local temp = data.arg_uint32[i]
            if temp then
                if temp.key == 1 then
                    rid = temp.value
                elseif temp.key == 2 then
                    bbs_id = temp.value --留言板那边的..表示留言id
                end
            end
        end     
    end

	if data and data.arg_str and #data.arg_str > 0 then
        for i = 1, #data.arg_str do
            local temp = data.arg_str[i]
            if temp then
                if temp.key == 1 then
                    srv_id = temp.value
                elseif temp.key == 2 then
                    role_name = temp.value
                elseif temp.key == 3 then
                    guild_name = temp.value
                end
            end
        end
	end
	return rid, srv_id, role_name, guild_name, bbs_id
end

-- type = 9,	
-- arg_uint32 = {	
-- },	
-- idx = 0,	
-- arg_str = {	
-- },